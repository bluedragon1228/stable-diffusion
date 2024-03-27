variable "USERNAME" {
    default = "ashleykza"
}

variable "APP" {
    default = "stable-diffusion-webui"
}

variable "RELEASE" {
    default = "4.2.11"
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
        CONTROLNET_COMMIT = "0b90426254debf78bfc09d88c064d2caf0935282"
        DREAMBOOTH_COMMIT = "30bfbc289a1d90153a3e5a5ab92bf5636e66b210"
        KOHYA_VERSION = "v23.0.15"
        RUNPODCTL_VERSION = "v1.14.2"
        VENV_PATH = "/workspace/venvs/${APP}"
    }
}
