# hexo Docker Image

Docker image for hexo.

## Usage

```bash
# Build the image
docker build -t hexo .

# Run the container
docker run -d hexo
```

## Files

- `Dockerfile`: Main Docker image definition
- `build.sh`: Build script for image setup
- `entry.sh`: Container entrypoint script

## Original Implementation

This image was migrated from the `hexo` branch of the original repository structure.
