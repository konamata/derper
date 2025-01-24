# Tailscale Derper (Docker)

This repository contains the necessary files to build and run a Docker container for the `derper` service, which is part of the `Tailscale` ecosystem.

## 📂 Contents

- `Dockerfile`: Defines the multi-stage build process for the derper service.
- `.github/workflows/docker-image.yml`: GitHub Actions workflow for building and pushing multi-architecture Docker images.

## 🛠 Dockerfile Overview

The Dockerfile uses a multi-stage build process:

1. Starts with the `ghcr.io/konamata/golang-upx:1.23.4-bookworm` base image.
2. Installs the latest version of `derper` from the Tailscale repository.
3. Compresses the binary using `UPX` to optimize size.
4. Uses a `scratch` image for the final stage to keep the image minimal, copying only necessary files.

## 🚀 GitHub Actions Workflow

The workflow (`docker-image.yml`) does the following:

- Triggered on push to main, pull requests to main, a daily schedule, and manual dispatch.
- Checks out the code and sets up Go.
- Fetches the latest Tailscale version tag.
- Checks if a Docker image for this tag already exists.
- If the image doesn't exist (or on manual dispatch), it builds and pushes a multi-architecture Docker image to GitHub Container Registry.

## 🏗️ Manual Build Instructions

If you want to build the image manually:

```bash
docker build -t derper .
```

Then run local image with:

```bash
docker run -p 8039:8039 -p 3439:3439/udp derper
```

Then run pre-built image with:

```bash
docker run -p 8039:8039 -p 3439:3439/udp ghcr.io/konamata/derper:latest
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📜 License

Please add appropriate license information here.
