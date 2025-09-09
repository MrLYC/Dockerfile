# minio Docker Image

Docker image for minio.

## Usage

```bash
# Build the image
docker build -t minio .

# Run the container
docker run -d minio
```

## Files

- `Dockerfile`: Main Docker image definition
- `build.sh`: Build script for image setup
- `entry.sh`: Container entrypoint script

## Original Implementation

This image was migrated from the `minio` branch of the original repository structure.
