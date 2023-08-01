#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

echo "Container is running"

# Sync venv to workspace to support Network volumes
echo "Syncing venv to workspace, please wait..."
rsync -au /venv/ /workspace/venv/
rm -rf /venv

# Sync Web UI to workspace to support Network volumes
echo "Syncing Stable Diffusion Web UI to workspace, please wait..."
rsync -au /stable-diffusion-webui/ /workspace/stable-diffusion-webui/
rm -rf /stable-diffusion-webui

# Sync Kohya_ss to workspace to support Network volumes
echo "Syncing Kohya_ss to workspace, please wait..."
rsync -au /kohya_ss/ /workspace/kohya_ss/
rm -rf /kohya_ss

# Fix the venvs to make them work from /workspace
echo "Fixing Stable Diffusion Web UI venv..."
/fix_venv.sh /venv /workspace/venv

echo "Fixing Kohya_ss venv..."
/fix_venv.sh /kohya_ss/venv /workspace/kohya_ss/venv

# Link model and VAE
ln -s /sd-models/v1-5-pruned.safetensors /workspace/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned.safetensors
ln -s /sd-models/vae-ft-mse-840000-ema-pruned.safetensors workspace/stable-diffusion-webui/models/VAE/vae-ft-mse-840000-ema-pruned.safetensors

# Configure accelerate
echo "Configuring accelerate..."
mkdir -p /root/.cache/huggingface/accelerate
mv /accelerate.yaml /root/.cache/huggingface/accelerate/default_config.yaml

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the applications will not be started automatically"
    echo "You can launch them manually using the launcher scripts:"
    echo ""
    echo "   Stable Diffusion Web UI:"
    echo "   ---------------------------------------------"
    echo "   cd /workspace/stable-diffusion-webui"
    echo "   deactivate && source /workspace/venv/bin/activate"
    echo "   ./webui.sh -f"
    echo ""
    echo "   Kohya_ss"
    echo "   ---------------------------------------------"
    echo "   cd /workspace/kohya_ss"
    echo "   deactivate"
    echo "   ./gui.sh --listen 0.0.0.0 --server_port 3011 --headless"
else
    mkdir -p /workspace/logs
    echo "Starting Stable Diffusion Web UI"
    cd /workspace/stable-diffusion-webui
    source /workspace/venv/bin/activate
    nohup ./webui.sh -f > /workspace/logs/webui.log 2>&1 &
    echo "Stable Diffusion Web UI started"
    echo "Log file: /workspace/logs/webui.log"
    deactivate

    echo "Starting Kohya_ss Web UI"
    cd /workspace/kohya_ss
    source venv/bin/activate
    nohup ./gui.sh --listen 0.0.0.0 --server_port 3011 --headless > /workspace/logs/kohya_ss.log 2>&1 &
    echo "Kohya_ss started"
    echo "Log file: /workspace/logs/kohya_ss.log"
    deactivate
fi

if [ ${ENABLE_TENSORBOARD} ]; then
    echo "Starting Tensorboard"
    cd /workspace
    mkdir -p /workspace/logs/ti
    mkdir -p /workspace/logs/dreambooth
    ln -s /workspace/stable-diffusion-webui/models/dreambooth /workspace/logs/dreambooth
    ln -s /workspace/stable-diffusion-webui/textual_inversion /workspace/logs/ti
    source /workspace/venv/bin/activate
    nohup tensorboard --logdir=/workspace/logs --port=6066 --host=0.0.0.0 &
    deactivate
    echo "Tensorboard Started"
fi

echo "All services have been started"

if [ ${DOWNLOAD_SDXL} ]; then
    # Only download the models if they have not already been downloaded previously
    if [[ ! -e "/workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_base_1.0_0.9vae.safetensors" ]];
    then
        echo "Beginning download of SDXL models"
        /download_sdxl_models.sh
        echo "SDXL model download complete"
        echo "Beginning download of SDXL styles"
        cd /workspace/stable-diffusion-webui
        wget https://raw.githubusercontent.com/Douleb/SDXL-750-Styles-GPT4-/main/styles.csv
        echo "SDXL styles download complete"
    fi
fi
