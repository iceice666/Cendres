#version 330

// rlgl batch renderer pre-applies the model matrix CPU-side,
// so vertexPosition arrives in world space. mvp = proj * view.
in vec3 vertexPosition;
in vec4 vertexColor;

uniform mat4 mvp;

out vec3 fragWorldPos;
out vec4 fragColor;

void main() {
    fragWorldPos = vertexPosition;
    fragColor    = vertexColor;
    gl_Position  = mvp * vec4(vertexPosition, 1.0);
}
