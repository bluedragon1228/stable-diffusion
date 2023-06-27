# Docker image for Stable Diffusion WebUI and Dreambooth extension

## Installs

* Ubuntu 22.04 LTS
* CUDA 11.8
* Python 3.10.6
* [Automatic1111 Stable Diffusion Web UI](
  https://github.com/AUTOMATIC1111/stable-diffusion-webui.git) 1.4.0
* [Dreambooth extension](
  https://github.com/d8ahazard/sd_dreambooth_extension) 1.0.14
* [Deforum extension](
  https://github.com/deforum-art/sd-webui-deforum)
* [ControlNet extension](
  https://github.com/Mikubill/sd-webui-controlnet) v1.1.227
* [Kohya_ss](https://github.com/bmaltais/kohya_ss) v21.7.16
* Torch 2.0.1
* xformers 0.0.20
* v1-5-pruned.safetensors
* vae-ft-mse-840000-ema-pruned.safetensors

## Available on RunPod

This image is designed to work on [RunPod](https://runpod.io?ref=w18gds2n).
You can use my custom [RunPod template](
https://runpod.io/gsc?template=ya6013lj5a&ref=w18gds2n)
to launch it on RunPod.

## Credits

1. [RunPod](https://runpod.io?ref=w18gds2n) for providing most
   of the [container](https://github.com/runpod/containers) code.
2. Dr. Furkan Gözükara for his amazing
   [YouTube videos](https://www.youtube.com/@SECourses/videos]).
3. [bmaltais](https://github.com/bmaltais) (core develiper of Kohya_ss)
   for assisting with optimizing the Docker image.