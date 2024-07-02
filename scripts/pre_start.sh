#!/usr/bin/env bash

export PYTHONUNBUFFERED=1
export APP="stable-diffusion-webui"
DOCKER_IMAGE_VERSION_FILE="/workspace/${APP}/docker_image_version"

echo "Template version: ${TEMPLATE_VERSION}"
echo "venv: ${VENV_PATH}"

if [[ -e ${DOCKER_IMAGE_VERSION_FILE} ]]; then
    EXISTING_VERSION=$(cat ${DOCKER_IMAGE_VERSION_FILE})
else
    EXISTING_VERSION="0.0.0"
fi

rsync_with_progress() {
    stdbuf -i0 -o0 -e0 rsync -au --info=progress2 "$@" | stdbuf -i0 -o0 -e0 tr '\r' '\n' | stdbuf -i0 -o0 -e0 grep -oP '\d+%|\d+.\d+[mMgG]' | tqdm --bar-format='{l_bar}{bar}' --total=100 --unit='%' > /dev/null
}

sync_apps() {
    # Only sync if the DISABLE_SYNC environment variable is not set
    if [ -z "${DISABLE_SYNC}" ]; then
        # Sync main venv to workspace to support Network volumes
        echo "Syncing main venv to workspace, please wait..."
        mkdir -p ${VENV_PATH}
        rsync_with_progress --remove-source-files /venv/ ${VENV_PATH}/

        # Sync application to workspace to support Network volumes
        echo "Syncing ${APP} to workspace, please wait..."
        rsync_with_progress --remove-source-files /${APP}/ /workspace/${APP}/

        # Sync Kohya_ss to workspace to support Network volumes
        echo "Syncing Kohya_ss to workspace, please wait..."
        rsync_with_progress --remove-source-files /kohya_ss/ /workspace/kohya_ss/

        # Sync ComfyUI to workspace to support Network volumes
        echo "Syncing ComfyUI to workspace, please wait..."
        rsync_with_progress --remove-source-files /ComfyUI/ /workspace/ComfyUI/

        # Sync InvokeAI to workspace to support Network volumes
        echo "Syncing InvokeAI to workspace, please wait..."
        rsync_with_progress --remove-source-files /InvokeAI/ /workspace/InvokeAI/

        echo "${TEMPLATE_VERSION}" > ${DOCKER_IMAGE_VERSION_FILE}
        echo "${VENV_PATH}" > "/workspace/${APP}/venv_path"
    fi
}

fix_venvs() {
    echo "Fixing A1111 Web UI venv..."
    /fix_venv.sh /venv ${VENV_PATH}

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

        # Add VENV_PATH to webui-user.sh
        sed -i "s|venv_dir=VENV_PATH|venv_dir=${VENV_PATH}\"\"|" /workspace/stable-diffusion-webui/webui-user.sh

        # Configure accelerate
        echo "Configuring accelerate..."
        mkdir -p /root/.cache/huggingface/accelerate
        mv /accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

        # Create logs directory
        mkdir -p /workspace/logs
    else
        echo "Existing version is the same as the template version, no syncing required."
    fi
else
    echo "Existing version is newer than the template version, not syncing!"
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
    echo ""
    echo "   InvokeAI"
    echo "   ---------------------------------------------"
    echo "   /start_invokeai.sh"
else
    /start_a1111.sh
    /start_kohya.sh
    /start_comfyui.sh
    /start_invokeai.sh
fi

if [ ${ENABLE_TENSORBOARD} ];
then
    /start_tensorboard.sh
fi

echo "All services have been started"
