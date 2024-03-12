variable "RELEASE" {
    default = "4.2.1"
}

variable "CU_VERSION" {
    default = "118"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["ashleykza/stable-diffusion-webui:${RELEASE}"]
    args = {
        RELEASE = "${RELEASE}"
        CU_VERSION = "${CU_VERSION}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION}"
        TORCH_VERSION = "2.1.2+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.23.post1+cu${CU_VERSION}"
        WEBUI_VERSION = "v1.8.0"
        DREAMBOOTH_COMMIT = "30bfbc289a1d90153a3e5a5ab92bf5636e66b210"
        KOHYA_VERSION = "v23.0.6"
        VENV_PATH = "/workspace/venvs/stable-diffusion-webui"
    }
}
