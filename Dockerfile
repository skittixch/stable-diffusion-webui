# Starting from the base image
FROM nvidia/cuda:11.0.3-cudnn8-devel-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && \
    apt install -y \
    software-properties-common \
    git-all \
    pkg-config \
    wget \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libsqlite3-dev \
    libreadline-dev \
    libffi-dev \
    curl \
    libbz2-dev \
    liblzma-dev

# Install specific Python version
RUN wget https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tgz && \
    tar -xf Python-3.10.6.tgz && \
    cd Python-3.10.6 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    ln -sf /usr/local/bin/python3.10 /usr/bin/python

WORKDIR /usr/src/app
COPY . .

CMD nvidia-smi \
    && python --version \
    && touch /usr/src/app/styles.csv \
    && ssh -f -N -R 5000:127.0.0.1:7860 skittixch@ericbacus.com -i ~/.ssh/id_rsa \
    && python launch.py --listen --api --enable-insecure-extension-access --cors-allow-origins=*
# --server-name ai.ericbacus.com --tls-keyfile /root/.ssh/privkey.pem --tls-certfile /root/.ssh/fullchain.pem --disable-tls-verify
ENV LISTEN 7860
EXPOSE 7860
