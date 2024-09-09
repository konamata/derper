FROM ghcr.io/bariiss/golang-upx:1.23.1-bookworm AS builder

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOPROXY=https://proxy.golang.org

WORKDIR /app

RUN go install tailscale.com/cmd/derper@latest
RUN upx --ultra-brute /go/bin/derper && upx -t /go/bin/derper

FROM alpine:latest AS final
LABEL org.opencontainers.image.source "https://ghcr.io/konamata/derper"

RUN apk add --no-cache libc6-compat

COPY --from=builder /go/bin/derper /usr/local/bin/derper

EXPOSE 8039/tcp
EXPOSE 3439/udp

CMD ["derper", "-a", ":8039", "-stun-port", "3439"]