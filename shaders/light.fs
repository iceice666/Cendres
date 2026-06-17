#version 330

in vec3 fragWorldPos;
in vec4 fragColor;

#define MAX_LIGHTS 8
uniform vec3  lightPos[MAX_LIGHTS];
uniform float lightRadius[MAX_LIGHTS];
uniform float lightIntensity[MAX_LIGHTS];
uniform int   lightCount;

out vec4 finalColor;

void main() {
    float total = 0.0;
    for (int i = 0; i < lightCount; i++) {
        vec2  diff = fragWorldPos.xz - lightPos[i].xz;
        float dist = length(diff);
        if (dist < lightRadius[i]) {
            total += lightIntensity[i] * (1.0 - dist / lightRadius[i]);
        }
    }
    float brightness = clamp(total, 0.0, 1.0);

    // Amber #F5C842 ↔ Void Black #2A2A2A
    vec3 amber     = vec3(0.961, 0.784, 0.259);
    vec3 voidBlack = vec3(0.165, 0.165, 0.165);
    finalColor = vec4(mix(voidBlack, amber, brightness) * fragColor.rgb, 1.0);
}
