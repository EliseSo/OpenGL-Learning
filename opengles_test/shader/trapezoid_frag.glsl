precision mediump float;

uniform sampler2D texture;
varying mediump vec2 textureCoordsVarying;

void main()
{
    gl_FragColor = texture2D(texture, textureCoordsVarying);
}
