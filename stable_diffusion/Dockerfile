# Stage 1: Base
FROM ashleykza/stable-diffusion-models:1.0.0 as sd-models
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 as base

ARG WEBUI_VERSION=v1.5.1
ARG DREAMBOOTH_COMMIT=c2a5617c587b812b5a408143ddfb18fc49234edf
ARG KOHYA_VERSION=V21.8.5

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Africa/Johannesburg \
    PYTHONUNBUFFERED=1 \
    SHELL=/bin/bash

# Add Stable Diffusion 1.5 model and VAE
RUN mkdir -p /sd-models
COPY --from=sd-models /v1-5-pruned.safetensors /sd-models/v1-5-pruned.safetensors
COPY --from=sd-models /vae-ft-mse-840000-ema-pruned.safetensors /sd-models/vae-ft-mse-840000-ema-pruned.safetensors

# Create workspace working directory
WORKDIR /

# Install Ubuntu packages
RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends \
        build-essential \
        software-properties-common \
        python3.10-venv \
        python3-pip \
        python3-tk \
        python3-dev \
        bash \
        git \
        ncdu \
        nginx \
        net-tools \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        zip \
        unzip \
        p7zip-full \
        htop \
        pkg-config \
        libcairo2-dev \
        libgoogle-perftools4 libtcmalloc-minimal4 \
        apt-transport-https ca-certificates && \
    update-ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Set Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Stage 2: Install applications
FROM base as setup

# Clone the git repo of the Stable Diffusion Web UI by Automatic1111
# and set version
WORKDIR /
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
    cd /stable-diffusion-webui && \
    git reset ${WEBUI_VERSION} --hard

WORKDIR /stable-diffusion-webui
RUN python3 -m venv --system-site-packages /venv && \
    source /venv/bin/activate && \
    pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
    pip install --no-cache-dir xformers && \
    deactivate

# Install the dependencies for the Automatic1111 Stable Diffusion Web UI
COPY requirements.txt requirements_versions.txt ./
COPY cache-sd-model.py install-automatic.py ./
RUN source /venv/bin/activate && \
    python -m install-automatic --skip-torch-cuda-test && \
    deactivate

# Clone the Automatic1111 Extensions
RUN git clone https://github.com/d8ahazard/sd_dreambooth_extension.git extensions/sd_dreambooth_extension && \
    git clone https://github.com/deforum-art/sd-webui-deforum extensions/deforum && \
    git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet && \
    git clone https://github.com/kohya-ss/sd-webui-additional-networks extensions/sd-webui-additional-networks && \
    git clone https://github.com/ashleykleynhans/a1111-sd-webui-locon extensions/a1111-sd-webui-locon && \
    git clone https://github.com/s0md3v/sd-webui-roop extensions/sd-webui-roop

# Install depenencies for Deforum, ControlNet and roop
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/deforum && \
    pip3 install -r requirements.txt && \
    cd /stable-diffusion-webui/extensions/sd-webui-controlnet && \
    pip3 install -r requirements.txt && \
    cd /stable-diffusion-webui/extensions/sd-webui-roop && \
    pip3 install -r requirements.txt && \
    deactivate

# Set Dreambooth extension version
WORKDIR /stable-diffusion-webui/extensions/sd_dreambooth_extension
RUN git checkout main && \
    git reset ${DREAMBOOTH_COMMIT} --hard

# Install the dependencies for the Dreambooth extension
WORKDIR /stable-diffusion-webui
COPY requirements_dreambooth.txt ./requirements.txt
RUN source /venv/bin/activate && \
    cd /stable-diffusion-webui/extensions/sd_dreambooth_extension && \
    pip3 install -r requirements.txt && \
    deactivate

# Cache the SD 1.5 model
RUN source /venv/bin/activate && \
    python3 cache-sd-model.py --use-cpu=all --ckpt /sd-models/v1-5-pruned.safetensors && \
    deactivate

# Fix Tensorboard
RUN source /venv/bin/activate && \
    pip3 uninstall -y tensorboard tb-nightly && \
    pip3 install tensorboard tensorflow && \
    pip3 cache purge && \
    deactivate

# Install Kohya_ss
RUN git clone https://github.com/bmaltais/kohya_ss.git /kohya_ss
WORKDIR /kohya_ss
RUN git checkout ${KOHYA_VERSION} && \
    python3 -m venv --system-site-packag venv && \
    source venv/bin/activate && \
    pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
    pip3 install --no-cache-dir xformers==0.0.20 \
        bitsandbytes==0.35.0 \
        tensorboard==2.12.3 \
        tensorflow==2.12.0 \
        wheel \
        tensorrt && \
    pip3 install -r requirements.txt && \
    pip3 install . && \
    pip3 cache purge && \
    deactivate

# Install Jupyter
RUN pip3 install -U --no-cache-dir jupyterlab \
        jupyterlab_widgets \
        ipykernel \
        ipywidgets \
        gdown

# Install runpodctl
RUN wget https://github.com/runpod/runpodctl/releases/download/v1.10.0/runpodctl-linux-amd -O runpodctl && \
    chmod a+x runpodctl && \
    mv runpodctl /usr/local/bin

# Install CivitAI Model Downloader
RUN git clone https://github.com/ashleykleynhans/civitai-downloader.git && \
    mv civitai-downloader/download.sh /usr/local/bin/download-model && \
    chmod +x /usr/local/bin/download-model

# Copy Stable Diffusion Web UI config files
COPY relauncher.py webui-user.sh config.json ui-config.json /stable-diffusion-webui/

# NGINX Proxy
COPY nginx.conf /etc/nginx/nginx.conf
COPY 502.html /usr/share/nginx/html/502.html

# Copy the README.md
COPY README.md /usr/share/nginx/html/README.md

# Set up the container startup script
WORKDIR /
COPY pre_start.sh start.sh fix_venv.sh accelerate.yaml ./
RUN chmod +x /start.sh && \
    chmod +x /pre_start.sh && \
    chmod +x /fix_venv.sh

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]