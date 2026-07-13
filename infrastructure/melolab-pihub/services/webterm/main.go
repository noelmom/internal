package main

import (
	"encoding/json"
	_ "embed"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/websocket"
	"golang.org/x/crypto/ssh"
)

//go:embed index.html
var indexHTML []byte

func env(k, d string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return d
}

var upgrader = websocket.Upgrader{CheckOrigin: func(r *http.Request) bool { return true }}

func fail(c *websocket.Conn, msg string) {
	c.WriteMessage(websocket.BinaryMessage, []byte("\r\n[webterm: "+msg+"]\r\n"))
}

func handleWS(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		return
	}
	defer c.Close()

	key, err := os.ReadFile(env("SSH_KEY", "/key"))
	if err != nil {
		fail(c, "key read: "+err.Error())
		return
	}
	signer, err := ssh.ParsePrivateKey(key)
	if err != nil {
		fail(c, "key parse: "+err.Error())
		return
	}
	cfg := &ssh.ClientConfig{
		User:            env("SSH_USER", "noelmomelo"),
		Auth:            []ssh.AuthMethod{ssh.PublicKeys(signer)},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}
	client, err := ssh.Dial("tcp", env("SSH_HOST", "172.19.0.1:22"), cfg)
	if err != nil {
		fail(c, "ssh dial: "+err.Error())
		return
	}
	defer client.Close()

	sess, err := client.NewSession()
	if err != nil {
		fail(c, "session: "+err.Error())
		return
	}
	defer sess.Close()

	sess.RequestPty("xterm-256color", 40, 120, ssh.TerminalModes{ssh.ECHO: 1})
	stdin, _ := sess.StdinPipe()
	stdout, _ := sess.StdoutPipe()

	if cmd := env("SSH_CMD", ""); cmd != "" {
		sess.Start(cmd)
	} else {
		sess.Shell()
	}

	go func() {
		buf := make([]byte, 8192)
		for {
			n, err := stdout.Read(buf)
			if n > 0 {
				c.WriteMessage(websocket.BinaryMessage, buf[:n])
			}
			if err != nil {
				break
			}
		}
		c.Close()
	}()

	for {
		_, data, err := c.ReadMessage()
		if err != nil {
			break
		}
		if len(data) == 0 {
			continue
		}
		switch data[0] {
		case 0:
			stdin.Write(data[1:])
		case 1:
			var m struct{ Cols, Rows int }
			if json.Unmarshal(data[1:], &m) == nil && m.Cols > 0 {
				sess.WindowChange(m.Rows, m.Cols)
			}
		}
	}
	sess.Close()
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		w.Write(indexHTML)
	})
	http.HandleFunc("/ws", handleWS)
	log.Println("webterm listening on :8091")
	log.Fatal(http.ListenAndServe(":8091", nil))
}
