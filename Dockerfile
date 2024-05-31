ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN mkdir -p /sd-models

# Add SDXL models and VAE
# These need to already have been downloaded:
#   wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
#   wget https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
#   wget https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors
COPY sd_xl_base_1.0.safetensors /sd-models/sd_xl_base_1.0.safetensors
COPY sd_xl_refiner_1.0.safetensors /sd-models/sd_xl_refiner_1.0.safetensors
COPY sdxl_vae.safetensors /sd-models/sdxl_vae.safetensors

# Copy the build scripts
WORKDIR /
COPY --chmod=755 build/* ./

# Install A1111 Web UI
ARG WEBUI_VERSION
ARG TORCH_VERSION
ARG XFORMERS_VERSION
ARG INDEX_URL
ARG CONTROLNET_COMMIT
ARG CIVITAI_BROWSER_PLUS_VERSION
ARG DREAMBOOTH_COMMIT
RUN /install_a1111.sh

# Cache the Stable Diffusion Models
# SDXL models result in OOM kills with 8GB system memory, need 30GB+ to cache these
WORKDIR /stable-diffusion-webui
COPY a1111/cache-sd-model.py ./
RUN source /venv/bin/activate && \
    python3 cache-sd-model.py --skip-torch-cuda-test --use-cpu=all --ckpt /sd-models/sd_xl_base_1.0.safetensors && \
    python3 cache-sd-model.py --skip-torch-cuda-test --use-cpu=all --ckpt /sd-models/sd_xl_refiner_1.0.safetensors && \
    deactivate

# RUN cd /stable-diffusion-webui && python cache.py --use-cpu=all --ckpt /model.safetensors

# Copy Stable Diffusion Web UI config files
COPY a1111/relauncher.py a1111/webui-user.sh a1111/config.json a1111/ui-config.json /stable-diffusion-webui/

# ADD SDXL styles.csv
ADD https://raw.githubusercontent.com/Douleb/SDXL-750-Styles-GPT4-/main/styles.csv /stable-diffusion-webui/styles.csv

# Install ComfyUI
RUN /install_comfyui.sh

# Copy ComfyUI Extra Model Paths (to share models with A1111)
COPY comfyui/extra_model_paths.yaml /ComfyUI/

# Install InvokeAI
ARG INVOKEAI_VERSION
RUN /install_invokeai.sh

# Copy InvokeAI config file
COPY invokeai/invokeai.yaml /InvokeAI/

# Install Kohya_ss
ARG KOHYA_VERSION
ARG KOHYA_TORCH_VERSION
ARG KOHYA_XFORMERS_VERSION
COPY kohya_ss/requirements* ./
RUN /install_kohya.sh

# Copy the accelerate configuration
COPY kohya_ss/accelerate.yaml ./

# Install Tensorboard
RUN /install_tensorboard.sh

# Install Application Manager
ARG APP_MANAGER_VERSION
RUN /install_app_manager.sh
COPY app-manager/config.json /app-manager/public/config.json

# Install CivitAI Model Downloader
ARG CIVITAI_DOWNLOADER_VERSION
RUN /install_civitai_model_downloader.sh

# Cleanup installation scripts
RUN rm -f /install_*.sh

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Set template version
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# Set the main venv path
ARG VENV_PATH
ENV VENV_PATH=${VENV_PATH}

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
