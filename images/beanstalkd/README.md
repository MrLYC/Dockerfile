# beanstalkd Docker Image

Docker image for beanstalkd.

## Usage

```bash
# Build the image
docker build -t beanstalkd .

# Run the container
docker run -d beanstalkd
```

## Files

- `Dockerfile`: Main Docker image definition
- `build.sh`: Build script for image setup
- `entry.sh`: Container entrypoint script

## Original Implementation

This image was migrated from the `beanstalkd` branch of the original repository structure.
