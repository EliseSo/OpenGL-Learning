attribute vec4 position;
attribute vec2 textureCoords;
varying vec2 textureCoordsVarying;
uniform mat4 proMatrix;

void main()
{
    gl_Position = proMatrix * position;
//    gl_Position = position;
    textureCoordsVarying = textureCoords;
}
