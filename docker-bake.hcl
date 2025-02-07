variable "REGISTRY" {
    default = "docker.io"
}

variable "REGISTRY_USER" {
    default = "ashleykza"
}

variable "APP" {
    default = "stable-diffusion-webui"
}

variable "RELEASE" {
    default = "6.5.1"
}

variable "CU_VERSION" {
    default = "121"
}

variable "BASE_IMAGE_REPOSITORY" {
    default = "ashleykza/runpod-base"
}

variable "BASE_IMAGE_VERSION" {
    default = "1.7.0"
}

variable "CUDA_VERSION" {
    default = "12.1.1"
}

variable "TORCH_VERSION" {
    default = "2.3.0"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:${RELEASE}"]
    args = {
        RELEASE = "${RELEASE}"
        BASE_IMAGE = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-cuda${CUDA_VERSION}-torch${TORCH_VERSION}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION}"
        TORCH_VERSION = "${TORCH_VERSION}+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.26.post1"
        WEBUI_VERSION = "v1.9.4"
        CONTROLNET_COMMIT = "ee96dc9229e454b8add38c0ca99a92efa97ef238"
        DREAMBOOTH_COMMIT = "45a12fe5950bf93205b6ef2b7511eb94052a241f"
        CIVITAI_BROWSER_PLUS_VERSION = "v3.5.4"
        KOHYA_VERSION = "v24.1.4"
        KOHYA_TORCH_VERSION = "2.1.2+cu${CU_VERSION}"
        KOHYA_XFORMERS_VERSION = "0.0.23.post1"
        COMFYUI_COMMIT = "537f35c7bc76e611b53102d3b5a2926e46ec7362"
        INVOKEAI_VERSION = "4.2.5"
        APP_MANAGER_VERSION = "1.2.0"
        CIVITAI_DOWNLOADER_VERSION = "2.1.0"
        VENV_PATH = "/workspace/venvs/${APP}"
    }
}
