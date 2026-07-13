package main

import (
	"encoding/json"
	"log"
	"net"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/websocket"
	"golang.org/x/crypto/ssh"
)

type Target struct {
	Host string `json:"host"`
	User string `json:"user"`
	Key  string `json:"key"`
	Cmd  string `json:"cmd"`
}

func env(k, d string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return d
}

var (
	upgrader   = websocket.Upgrader{CheckOrigin: func(r *http.Request) bool { return true }, Subprotocols: []string{"binary"}}
	targets    = map[string]Target{}
	vncTargets = map[string]string{}
)

func loadTargets() {
	b, err := os.ReadFile(env("TARGETS_PATH", "/targets.json"))
	if err != nil {
		log.Println("targets load error:", err)
		return
	}
	if err := json.Unmarshal(b, &targets); err != nil {
		log.Println("targets parse error:", err)
	}
	log.Printf("loaded %d targets", len(targets))
}

func loadVNCTargets() {
	b, err := os.ReadFile(env("VNC_TARGETS_PATH", "/vnc-targets.json"))
	if err != nil {
		log.Println("vnc targets load error:", err)
		return
	}
	if err := json.Unmarshal(b, &vncTargets); err != nil {
		log.Println("vnc targets parse error:", err)
	}
	log.Printf("loaded %d vnc targets", len(vncTargets))
}

// handleVNC bridges a browser WebSocket (noVNC RFB) to a raw TCP VNC server.
func handleVNC(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		return
	}
	defer c.Close()
	addr, ok := vncTargets[r.URL.Query().Get("t")]
	if !ok {
		c.WriteMessage(websocket.BinaryMessage, []byte("unknown vnc target"))
		return
	}
	tcp, err := net.DialTimeout("tcp", addr, 10*time.Second)
	if err != nil {
		log.Println("vnc dial", addr, err)
		return
	}
	defer tcp.Close()
	done := make(chan struct{}, 2)
	go func() {
		buf := make([]byte, 32768)
		for {
			n, rerr := tcp.Read(buf)
			if n > 0 {
				if werr := c.WriteMessage(websocket.BinaryMessage, buf[:n]); werr != nil {
					break
				}
			}
			if rerr != nil {
				break
			}
		}
		done <- struct{}{}
	}()
	go func() {
		for {
			_, data, rerr := c.ReadMessage()
			if rerr != nil {
				break
			}
			if _, werr := tcp.Write(data); werr != nil {
				break
			}
		}
		done <- struct{}{}
	}()
	<-done
}

func fail(c *websocket.Conn, msg string) {
	c.WriteMessage(websocket.BinaryMessage, []byte("\r\n[webterm: "+msg+"]\r\n"))
}

func handleWS(w http.ResponseWriter, r *http.Request) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		return
	}
	defer c.Close()

	tg, ok := targets[r.URL.Query().Get("t")]
	if !ok {
		fail(c, "unknown target: "+r.URL.Query().Get("t"))
		return
	}
	keyPath := tg.Key
	if keyPath == "" {
		keyPath = env("SSH_KEY", "/key")
	}
	key, err := os.ReadFile(keyPath)
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
		User:            tg.User,
		Auth:            []ssh.AuthMethod{ssh.PublicKeys(signer)},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}
	client, err := ssh.Dial("tcp", tg.Host, cfg)
	if err != nil {
		fail(c, "ssh dial "+tg.Host+": "+err.Error())
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

	if tg.Cmd != "" {
		sess.Start(tg.Cmd)
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
	loadTargets()
	loadVNCTargets()
	idx := env("INDEX_PATH", "/www/index.html")
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		b, err := os.ReadFile(idx)
		if err != nil {
			http.Error(w, "index missing", 500)
			return
		}
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		w.Write(b)
	})
	http.HandleFunc("/font.woff2", func(w http.ResponseWriter, r *http.Request) {
		b, err := os.ReadFile(env("FONT_PATH", "/font.woff2"))
		if err != nil {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "font/woff2")
		w.Header().Set("Cache-Control", "public, max-age=604800")
		w.Write(b)
	})
	http.HandleFunc("/vnc.html", func(w http.ResponseWriter, r *http.Request) {
		b, err := os.ReadFile(env("VNC_INDEX_PATH", "/www/vnc.html"))
		if err != nil {
			http.Error(w, "vnc index missing", 500)
			return
		}
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		w.Write(b)
	})
	http.HandleFunc("/vncws", handleVNC)
	http.HandleFunc("/ws", handleWS)
	log.Println("webterm listening on :8091")
	log.Fatal(http.ListenAndServe(":8091", nil))
}
