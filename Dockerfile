FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

ENV NODE_VERSION 20.16.0

RUN groupadd -g 1000 node \
  && useradd -u 1000 -g node -s /bin/sh -m node \
  && apt-get update \
  && apt-get install -y curl git \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update \
  && apt-get install -y \
  nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

CMD [ "node","--security-opt seccomp=unconfined" ]
