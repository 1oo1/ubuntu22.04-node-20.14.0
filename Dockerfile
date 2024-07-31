FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

ENV NODE_VERSION 20.16.0

RUN groupadd -g 1000 node \
  && useradd -u 1000 -g node -s /bin/sh -m node \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update \
  && apt-get install -y \
  nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copy the entrypoint script and set permissions
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD [ "node" ]
