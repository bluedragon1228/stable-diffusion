#!/usr/bin/env bash

export PYTHONUNBUFFERED=1

echo "Template version: ${TEMPLATE_VERSION}"

if [[ -e "/workspace/template_version" ]]; then
    EXISTING_VERSION=$(cat /workspace/template_version)
else
    EXISTING_VERSION="0.0.0"
fi

sync_apps() {
    # Sync venv to workspace to support Network volumes
    echo "Syncing venv to workspace, please wait..."
    rsync --remove-source-files -rlptDu /venv/ /workspace/venv/
    rm -rf /venv

    # Sync Web UI to workspace to support Network volumes
    echo "Syncing Stable Diffusion Web UI to workspace, please wait..."
    rsync --remove-source-files -rlptDu /stable-diffusion-webui/ /workspace/stable-diffusion-webui/
    rm -rf /stable-diffusion-webui

    # Sync Kohya_ss to workspace to support Network volumes
    echo "Syncing Kohya_ss to workspace, please wait..."
    rsync --remove-source-files -rlptDu /kohya_ss/ /workspace/kohya_ss/
    rm -rf /kohya_ss

    # Sync ComfyUI to workspace to support Network volumes
    echo "Syncing ComfyUI to workspace, please wait..."
    rsync --remove-source-files -rlptDu /ComfyUI/ /workspace/ComfyUI/
    rm -rf /ComfyUI

    # Sync Application Manager to workspace to support Network volumes
    echo "Syncing Application Manager to workspace, please wait..."
    rsync --remove-source-files -rlptDu /app-manager/ /workspace/app-manager/
    rm -rf /app-manager
}

fix_venvs() {
    echo "Fixing Stable Diffusion Web UI venv..."
    /fix_venv.sh /venv /workspace/venv

    echo "Fixing Kohya_ss venv..."
    /fix_venv.sh /kohya_ss/venv /workspace/kohya_ss/venv

    echo "Fixing ComfyUI venv..."
    /fix_venv.sh /ComfyUI/venv /workspace/ComfyUI/venv
}

link_models() {
   # Link models and VAE if they are not already linked
   if [[ ! -L /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_base_1.0.safetensors ]]; then
       ln -s /sd-models/sd_xl_base_1.0.safetensors /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_base_1.0.safetensors
   fi

   if [[ ! -L /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_refiner_1.0.safetensors ]]; then
       ln -s /sd-models/sd_xl_refiner_1.0.safetensors /workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_refiner_1.0.safetensors
   fi

   if [[ ! -L /workspace/stable-diffusion-webui/models/VAE/sdxl_vae.safetensors ]]; then
       ln -s /sd-models/sdxl_vae.safetensors /workspace/stable-diffusion-webui/models/VAE/sdxl_vae.safetensors
   fi
}

if [ "$(printf '%s\n' "$EXISTING_VERSION" "$TEMPLATE_VERSION" | sort -V | head -n 1)" = "$EXISTING_VERSION" ]; then
    if [ "$EXISTING_VERSION" != "$TEMPLATE_VERSION" ]; then
        sync_apps
        fix_venvs
        link_models

        # Configure accelerate
        echo "Configuring accelerate..."
        mkdir -p /root/.cache/huggingface/accelerate
        mv /accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

        # Create logs directory
        mkdir -p /workspace/logs
    else
        echo "Existing version is the same as the template version, no syncing required."
    fi
fi

# Start application manager
cd /workspace/app-manager
npm start > /workspace/logs/app-manager.log 2>&1 &

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the applications will not be started automatically"
    echo "You can launch them manually using the launcher scripts:"
    echo ""
    echo "   Stable Diffusion Web UI:"
    echo "   ---------------------------------------------"
    echo "   /start_a1111.sh"
    echo ""
    echo "   Kohya_ss"
    echo "   ---------------------------------------------"
    echo "   /start_kohya.sh"
    echo ""
    echo "   ComfyUI"
    echo "   ---------------------------------------------"
    echo "   /start_comfyui.sh"
else
    /start_a1111.sh
    /start_kohya.sh
    /start_comfyui.sh
fi

if [ ${ENABLE_TENSORBOARD} ];
then
    /start_tensorboard.sh
fi

echo "All services have been started"
