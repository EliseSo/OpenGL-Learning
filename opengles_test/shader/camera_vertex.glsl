attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;

uniform mat4 projectionMatrix;
uniform mat4 cameraMatrix;
uniform mat4 modelMatrix;

varying vec4 fColor;
varying lowp vec3 fragPos;
varying lowp vec3 fragNormal;

void main(void) {
    fColor = color;
    fragNormal = vec3(modelMatrix * vec4(normal, 0.0));
    fragPos = vec3(modelMatrix * position);
    gl_Position = projectionMatrix * cameraMatrix * modelMatrix * position;
}
