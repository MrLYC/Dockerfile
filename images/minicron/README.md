# minicron Docker Image

Docker image for minicron.

## Usage

```bash
# Build the image
docker build -t minicron .

# Run the container
docker run -d minicron
```

## Files

- `Dockerfile`: Main Docker image definition
- `build.sh`: Build script for image setup
- `entry.sh`: Container entrypoint script

## Original Implementation

This image was migrated from the `minicron` branch of the original repository structure.
