# Docker image for Stable Diffusion WebUI and ControlNet, Dreambooth, Deforum and roop extensions, as well as Kohya_ss

Now with SDXL support.

## Installs

* Ubuntu 22.04 LTS
* CUDA 11.8
* Python 3.10.6
* [Automatic1111 Stable Diffusion Web UI](
  https://github.com/AUTOMATIC1111/stable-diffusion-webui.git) 1.5.1
* [Dreambooth extension](
  https://github.com/d8ahazard/sd_dreambooth_extension) 1.0.14
* [Deforum extension](
  https://github.com/deforum-art/sd-webui-deforum)
* [ControlNet extension](
  https://github.com/Mikubill/sd-webui-controlnet) v1.1.233
* [Additional networks extension](
  https://github.com/kohya-ss/sd-webui-additional-networks)
* [Locon extension](
  https://github.com/ashleykleynhans/a1111-sd-webui-locon)
* [roop extension](https://github.com/s0md3v/sd-webui-roop) 0.0.2
* [Kohya_ss](https://github.com/bmaltais/kohya_ss) v21.8.5
* Torch 2.0.1
* xformers 0.0.20
* v1-5-pruned.safetensors
* vae-ft-mse-840000-ema-pruned.safetensors

## Available on RunPod

This image is designed to work on [RunPod](https://runpod.io?ref=2xxro4sy).
You can use my custom [RunPod template](
https://runpod.io/gsc?template=ya6013lj5a&ref=2xxro4sy)
to launch it on RunPod.

## Acknowledgements

1. [RunPod](https://runpod.io?ref=2xxro4sy) for providing most
   of the [container](https://github.com/runpod/containers) code.
2. Dr. Furkan Gözükara for his amazing
   [YouTube videos](https://www.youtube.com/@SECourses/videos]).
3. [Bernard Maltais](https://github.com/bmaltais) (core developer of Kohya_ss)
   for assisting with optimizing the Docker image.

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/ashleykleynhans/stable-diffusion-docker)
are welcome. Bug fixes and new features are encouraged.

You can contact me and get help with deploying your Serverless
worker to RunPod on the RunPod Discord Server below,
my username is **ashleyk**.

<a target="_blank" href="https://discord.gg/pJ3P2DbUUq">![Discord Banner 2](https://discordapp.com/api/guilds/912829806415085598/widget.png?style=banner2)</a>

## Appreciate my work?

<a href="https://www.buymeacoffee.com/ashleyk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
