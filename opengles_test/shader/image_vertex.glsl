attribute vec4 position;
attribute vec2 textureCoords;

varying vec2 textureCoordsVarying;

void main (void) {
    gl_Position = position;
    textureCoordsVarying = textureCoords;
}
