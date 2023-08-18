# Starting from the base image
FROM nvidia/cuda:11.0.3-base-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && \
    apt install -y \
    python3-pip \
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
    liblzma-dev \
    # Added ffmpeg for sadtalker - EB
    ffmpeg \
    # Added in attempt to get xformers to work - EB
    python3-tqdm

# Install specific Python version
RUN wget https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tgz && \
    tar -xf Python-3.10.6.tgz && \
    cd Python-3.10.6 && \
    ./configure --enable-optimizations && \
    make install

# Create symbolic links
RUN ln -sf /usr/local/bin/python3.10 /usr/bin/python3 \
    && ln -sf /usr/local/bin/python3.10 /usr/bin/python

# Install pip for Python 3.10
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python get-pip.py

#RUN python -m pip install virtualenv && \
#    virtualenv --python=python3.10 /usr/src/app/venv && \
#    echo "source /usr/src/app/venv/bin/activate" >> ~/.bashrc && \
#    /usr/src/app/venv/bin/pip install tqdm

# trying to fix a problem with sadtalker
RUN mkdir /tmp/gradio

WORKDIR /usr/src/app
COPY . .

CMD nvidia-smi \
    && python --version \
    && touch /usr/src/app/styles.csv \
    && ssh -f -N -R 5000:127.0.0.1:7860 skittixch@ericbacus.com -i ~/.ssh/corey_id_rsa \
    && python launch.py --listen --api --enable-insecure-extension-access --cors-allow-origins=* --xformers
ENV LISTEN 7860
EXPOSE 7860
