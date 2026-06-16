#version 330

in vec3 fragWorldPos;
in vec4 fragColor;

uniform vec3  playerPos;
uniform float lanternRadius;
uniform vec3  amberPos;
uniform float amberRadius; // 0.0 = no amber placed

out vec4 finalColor;

void main() {
    float dist1 = length(fragWorldPos - playerPos);
    float b1    = clamp(1.0 - dist1 / lanternRadius, 0.0, 1.0);

    float b2 = 0.0;
    if (amberRadius > 0.0) {
        float dist2 = length(fragWorldPos - amberPos);
        b2 = clamp(1.0 - dist2 / amberRadius, 0.0, 1.0);
    }

    float brightness = clamp(b1 + b2, 0.0, 1.0);
    finalColor = vec4(fragColor.rgb * brightness, fragColor.a);
}
