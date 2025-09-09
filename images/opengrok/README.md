# opengrok Docker Image

Docker image for opengrok.

## Usage

```bash
# Build the image
docker build -t opengrok .

# Run the container
docker run -d opengrok
```

## Files

- `Dockerfile`: Main Docker image definition
- `build.sh`: Build script for image setup
- `entry.sh`: Container entrypoint script

## Original Implementation

This image was migrated from the `opengrok` branch of the original repository structure.
