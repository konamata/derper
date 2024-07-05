# Use the official Golang image to build the binary
FROM golang:1.22 AS builder

# Set necessary environment variables
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn

# Create and change to the app directory
WORKDIR /app

# Download and install the application dependencies
RUN go install tailscale.com/cmd/derper@main

# Use an Alpine base image with GLIBC installed
FROM alpine:latest

# Install GLIBC
RUN apk add --no-cache libc6-compat

# Copy the compiled binary from the builder stage
COPY --from=builder /go/bin/derper /usr/local/bin/derper

# Expose necessary ports
EXPOSE 8039/tcp
EXPOSE 3439/udp

# Run the binary
CMD ["derper", "-a", ":8039", "-stun-port", "3439"]
