FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

ENV NODE_VERSION 20.16.0

RUN groupadd -g 1000 node \
  && useradd -u 1000 -g node -s /bin/sh -m node \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  libstdc++6 \
  && apt-get install -y --no-install-recommends \
  curl \
  && ARCH= OPENSSL_ARCH='linux*' && ubuntuArch="$(dpkg --print-architecture)" \
  && case "${ubuntuArch}" in \
  amd64) ARCH='x64' CHECKSUM="40efcec63e42ca58a39cc89c99d8852bd31ea09e046966b321fd337be999651d" OPENSSL_ARCH=linux-x86_64;; \
  i386) OPENSSL_ARCH=linux-elf;; \
  arm64) OPENSSL_ARCH=linux-aarch64;; \
  arm*) OPENSSL_ARCH=linux-armv4;; \
  ppc64el) OPENSSL_ARCH=linux-ppc64le;; \
  s390x) OPENSSL_ARCH=linux-s390x;; \
  *) ;; \
  esac \
  && if [ -n "${CHECKSUM}" ]; then \
  set -eu; \
  curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"; \
  echo "$CHECKSUM  node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
  else \
  echo "Building from source" \
  # backup build \
  && apt-get install -y --no-install-recommends \
  build-essential \
  curl \
  python3 \
  g++ \
  make \
  gnupg2 \
  dirmngr \
  && export GNUPGHOME="$(mktemp -d)" \
  # gpg keys listed at https://github.com/nodejs/node#release-keys \
  && for key in \
  4ED778F539E3634C779C87C6D7062848A1AB005C \
  141F07595B7B3FFE74309A937405533BE57C7D57 \
  74F12602B6F1C4E913FAA37AD3A89613643B6201 \
  DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
  61FC681DFB92A079F1685E77973F295594EC4689 \
  8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
  C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
  C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
  108F52B48DB57BB0CC439B2997B01419BD92F80A \
  A363A499291CBBC940DD62E41F10027AF002F8B0 \
  CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
  ; do \
  gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
  gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && gpgconf --kill all \
  && rm -rf "$GNUPGHOME" \
  && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xf "node-v$NODE_VERSION.tar.xz" \
  && cd "node-v$NODE_VERSION" \
  && ./configure \
  && make -j$(getconf _NPROCESSORS_ONLN) V= \
  && make install \
  && cd .. \
  && rm -Rf "node-v$NODE_VERSION" \
  && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
  fi \
  && rm -f "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" \
  # Remove unused OpenSSL headers to save space
  && find /usr/local/include/node/openssl/archs -mindepth 1 -maxdepth 1 ! -name "$OPENSSL_ARCH" -exec rm -rf {} \; \
  && apt-get purge -y --auto-remove \
  curl \
  gnupg2 \
  dirmngr \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  # smoke tests \
  && node --version \
  && npm --version


COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD [ "node" ]
