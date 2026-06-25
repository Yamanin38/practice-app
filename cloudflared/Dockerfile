FROM alpine:latest
RUN apk add --no-cache ca-certificates wget
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O /usr/local/bin/cloudflared
RUN chmod +x /usr/local/bin/cloudflared
ENTRYPOINT ["/usr/local/bin/cloudflared"]