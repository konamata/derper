FROM golang:1.23 AS builder

ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn

WORKDIR /app

RUN go install tailscale.com/cmd/derper@latest

FROM alpine:latest AS final
LABEL org.opencontainers.image.source = "https://github.com/konamata/derper"

RUN apk add --no-cache libc6-compat

COPY --from=builder /go/bin/derper /usr/local/bin/derper

EXPOSE 8039/tcp
EXPOSE 3439/udp

CMD ["derper", "-a", ":8039", "-stun-port", "3439"]