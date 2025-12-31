FROM mcr.microsoft.com/devcontainers/go:1.25

# Install Google Cloud SDK
RUN apt-get update && apt-get install -y \
    curl \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
      | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
      > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get update && apt-get install -y google-cloud-cli

# Optional but useful
#RUN gcloud components install beta --quiet
# Install plugins one-by-one with apt-get like:
# sudo apt-get install google-cloud-cli-gke-gcloud-auth-plugin
