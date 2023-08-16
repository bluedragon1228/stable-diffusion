#!/usr/bin/env bash

if [ "${DOWNLOAD_SDXL}" == "1" ];
then
    # Only download the models if they have not already been downloaded previously
    if [[ ! -e "/workspace/stable-diffusion-webui/models/Stable-diffusion/sd_xl_base_1.0.safetensors" ]];
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
