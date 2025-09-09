# snmpd Docker Image

Docker image for snmpd.

## Usage

```bash
# Build the image
docker build -t snmpd .

# Run the container
docker run -d snmpd
```

## Files

- `Dockerfile`: Main Docker image definition
- `build.sh`: Build script for image setup
- `entry.sh`: Container entrypoint script

## Original Implementation

This image was migrated from the `snmpd` branch of the original repository structure.
