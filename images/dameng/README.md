# Dameng DM8 Docker Image

Ubuntu 22.04 x86_64 DM8 image built from the official package:

`https://download.dameng.com/eco/adapter/DM8/202605/dm8_20260428_x86_Ubuntu22_64.zip`

The ZIP contains the ISO installation media. The Docker build extracts the ISO,
performs a silent installation as `dmdba:dinstall` (UID/GID 2001), and removes
the installation media from the final image.

## Build

From the repository root:

```bash
./build-images.sh dameng
```

The package is about 1 GiB, so the first build needs sufficient network,
temporary storage, and Docker build cache space.

## Run

The database instance is initialized on the first start of an empty `/dmdata`
volume. Set a strong SYSDBA password for a new volume:

```bash
docker run -d \
  --name dameng \
  --restart unless-stopped \
  -p 5236:5236 \
  -e DM_SYSDBA_PWD='ChangeMe@2026' \
  -v dameng-data:/dmdata \
  dameng:latest
```

The default DM8 initialization reserves a large data area; provide at least
10 GiB for `/dmdata` (more for real workloads). A small tmpfs can fail during
`dminit` even though the image itself builds successfully.

The container exposes the default DM port `5236`. The persistent volume
contains the instance data under `/dmdata/data`, archive files under
`/dmdata/arch`, and backups under `/dmdata/dmbak`.

Useful startup variables:

- `DM_SYSDBA_PWD_FILE`: read the password from a Docker secret file instead of
  passing it directly as an environment variable.
- `DM_DB_NAME`: database name; default `DAMENG`.
- `DM_INSTANCE_NAME`: instance name; default `DMSERVER`.
- `DM_PORT`: database port; default `5236`.
- `DM_CHARSET`: `dminit` charset value; default `1` (UTF-8).
- `DM_CASE_SENSITIVE`: `dminit` case-sensitivity value; default `Y`.

The image is intentionally published for `linux/amd64` only because the
provided installer is an x86_64 package.

The platform restriction is declared in `build.env`; the repository's generic
GitHub Actions workflow reads that optional per-image configuration. The
workflow entry and the container `ENTRYPOINT` are unchanged.

This image does not include a `dm.key` license file. The installer therefore
uses the package's default evaluation license; configure the appropriate
official license during your production installation.
