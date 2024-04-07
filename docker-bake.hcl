variable "USERNAME" {
    default = "ashleykza"
}

variable "APP" {
    default = "stable-diffusion-webui"
}

variable "RELEASE" {
    default = "4.3.0"
}

variable "CU_VERSION" {
    default = "118"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["${USERNAME}/${APP}:${RELEASE}"]
    args = {
        RELEASE = "${RELEASE}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION}"
        TORCH_VERSION = "2.1.2+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.23.post1+cu${CU_VERSION}"
        WEBUI_VERSION = "v1.8.0"
        CONTROLNET_COMMIT = "eb451a007f7040288e865f96e9ee0842aa6ef91c"
        DREAMBOOTH_COMMIT = "30bfbc289a1d90153a3e5a5ab92bf5636e66b210"
        CIVITAI_BROWSER_PLUS_VERSION = "v3.5.2"
        KOHYA_VERSION = "v23.1.0"
        RUNPODCTL_VERSION = "v1.14.2"
        CIVITAI_DOWNLOADER_VERSION = "2.1.0"
        VENV_PATH = "/workspace/venvs/${APP}"
    }
}
