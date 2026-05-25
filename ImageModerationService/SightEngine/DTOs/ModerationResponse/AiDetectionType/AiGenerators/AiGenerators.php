<?php

namespace App\Services\ImageModerationService\SightEngine\DTOs\ModerationResponse\AiDetectionType\AiGenerators;

class AiGenerators {
    public float $dalle;
    public float $firefly;
    public float $flux;
    public float $gan;
    public float $gpt;
    public float $higgsfield;
    public float $ideogram;
    public float $kling;
    public float $imagen;
    public float $midjourney;
    public float $qwen;
    public float $recraft;
    public float $reve;
    public float $seedream;
    public float $stableDiffusion;
    public float $wan;
    public float $zImage;
    public float $other;
    public function __construct(array $data) {
        $this->dalle = $data['dalle'];
        $this->firefly = $data['firefly'];
        $this->flux = $data['flux'];
        $this->gan = $data['gan'];
        $this->gpt = $data['gpt'];
        $this->higgsfield = $data['higgsfield'];
        $this->ideogram = $data['ideogram'];
        $this->kling = $data['kling'];
        $this->imagen = $data['imagen'];
        $this->midjourney = $data['midjourney'];
        $this->qwen = $data['qwen'];
        $this->recraft = $data['recraft'];
        $this->reve = $data['reve'];
        $this->seedream = $data['seedream'];
        $this->stableDiffusion = $data['stable_diffusion'];
        $this->wan = $data['wan'];
        $this->zImage = $data['z_image'];
        $this->other = $data['other'];
    }

}
