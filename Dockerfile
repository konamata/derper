FROM ghcr.io/konamata/golang-upx:1.23.5-bookworm AS builder

ARG TARGETARCH
ARG TARGETOS

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOPROXY=https://proxy.golang.org

WORKDIR /app

RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go install tailscale.com/cmd/derper@latest

RUN if [ -f "/go/bin/derper" ]; then \
      upx --ultra-brute /go/bin/derper && upx -t /go/bin/derper; \
    fi

FROM scratch AS final

WORKDIR /usr/local/bin
COPY --from=builder /etc/ssl/certs /etc/ssl/certs/
COPY --from=builder /go/bin/derper /usr/local/bin/derper

EXPOSE 8039/tcp
EXPOSE 3439/udp

CMD ["derper", "-a", ":8039", "-stun-port", "3439"]
