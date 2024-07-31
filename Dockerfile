FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

ENV NODE_VERSION 20.16.0

RUN groupadd -g 1000 node \
  && useradd -u 1000 -g node -s /bin/sh -m node \
  && apt-get update && apt-get install -y \
  curl \
  build-essential \
  libssl-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
  && export NVM_DIR="$HOME/.nvm" \
  && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
  && nvm install $NODE_VERSION \
  && nvm use $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && node -v \
  && npm -v

# Set up the environment
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Copy the entrypoint script and set permissions
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD [ "node" ]
