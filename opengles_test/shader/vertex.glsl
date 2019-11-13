attribute vec4 position;
attribute vec4 color;

uniform mat4 transform;
varying vec4 fColor;

void main(void) {
    fColor = color;
    gl_Position = transform * position;
}
