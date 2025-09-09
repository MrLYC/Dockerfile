# alpine-sshd Docker Image

Docker image for alpine-sshd.

## Usage

```bash
# Build the image
docker build -t alpine-sshd .

# Run the container
docker run -d alpine-sshd
```

## Files

- `Dockerfile`: Main Docker image definition
- `build.sh`: Build script for image setup
- `entry.sh`: Container entrypoint script

## Original Implementation

This image was migrated from the `alpine-sshd` branch of the original repository structure.
