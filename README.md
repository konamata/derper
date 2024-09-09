# Derper Docker

This repository contains the necessary files to build and run a Docker container for the `derper` service, which is part of the Tailscale ecosystem.

## Contents

- `Dockerfile`: Defines the multi-stage build process for the derper service.
- `docker-compose.yaml`: Provides an easy way to run the derper container.
- `.github/workflows/docker-image.yml`: GitHub Actions workflow for building and pushing multi-architecture Docker images.

## Dockerfile

The Dockerfile uses a multi-stage build process:

1. It starts with the `ghcr.io/bariiss/golang-upx:1.23.1-bookworm` base image for building.
2. It installs the latest version of `derper` from the Tailscale repository.
3. The binary is compressed using UPX for size reduction.
4. The final stage uses a `scratch` image for minimal size, copying only the necessary files.

## GitHub Actions Workflow

The workflow (`docker-image.yml`) does the following:

- Triggered on push to main, pull requests to main, a daily schedule, and manual dispatch.
- Checks out the code and sets up Go.
- Fetches the latest Tailscale version tag.
- Checks if a Docker image for this tag already exists.
- If the image doesn't exist (or on manual dispatch), it builds and pushes a multi-architecture Docker image to GitHub Container Registry.

## Usage

To run the derper service using Docker Compose:

1. Ensure you have Docker and Docker Compose installed.
2. Clone this repository.
3. Run the following command in the repository root:

```bash
docker compose up -d
```

This will start the derper service, exposing ports 8039 (TCP) and 3439 (UDP).

## Building Manually

If you want to build the image manually:

```bash
docker build -t derper .
```

Then run it with:

```bash
docker run -p 8039:8039 -p 3439:3439/udp derper
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

Please add appropriate license information here.