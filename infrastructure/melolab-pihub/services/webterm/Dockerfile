FROM golang:1.22-alpine AS build
WORKDIR /src
COPY . .
RUN go mod tidy && CGO_ENABLED=0 go build -o /webterm .

FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=build /webterm /webterm
EXPOSE 8091
ENTRYPOINT ["/webterm"]
