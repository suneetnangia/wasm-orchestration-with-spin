# Continuous Integration (CI)

This documents describes the CI process for the solution - in partucular for the Spin apps.

## Integration Tests

The workflow [PR](../.github/workflows/PR.yaml) is used as a validation pipeline for pull requests created against the main branch.

The job contains the generation and setup of the devcontainer including the docker-in-docker installation. That is required to build the wasm apps because it can be configured to use the containerd runtime for pulling and storing images as explaining in the [Docker-In-Docker](../docs/dev.md#docker-in-docker) section.
The pipeline also configures the k3d cluster and deploys the apps into the cluster. The apps are validated by running the integration tests as part of the makefile experience.

## Release Pipeline

The workflow [Release](../.github/workflows/Release.yaml) is triggered when check-in into the main branch is commited (ideally as part of the PR merge) and is used to push the apps images into the GitHub Container Registry (GHCR).

The pipeline runs the setup of the devcontainer and k3d cluster creation as well and logs in to the GHCR by using the default environment variables and secrets (GITHUB_TOKEN).

Finally, the workflow executes a script via make command to build and push the images into the GHCR.

## Configuration

### GITHUB_TOKEN

The GITHUB_TOKEN secret is required to be configured with "packages write" permission to be able to push the images into the GHCR from the Docker-In-Docker container.

```yaml
permissions:
    packages: write
```

### Tagging and labeling

Since the script [build-push-workload-image](../deployment/build-push-workload-image.sh) uses the "docker push" command to push the images into the GHCR, the images are tagged with the GHCR repository name (GitHub organization) and the image name.
The right version is read from the spin.toml file and applied as one tag aside the "latest" tag.
Additionally, the image is labeled with the GitHub repository name to connect it explicitly to the source code.

`LABEL org.opencontainers.image.source=https://github.com/OWNER/REPO`

More details can be found [here](https://docs.github.com/en/packages/learn-github-packages/connecting-a-repository-to-a-package#connecting-a-repository-to-a-container-image-using-the-command-line)
