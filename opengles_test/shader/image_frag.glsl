precision mediump float;

uniform sampler2D texture;
varying vec2 textureCoordsVarying;

void main (void) {
    vec4 mask = texture2D(texture, textureCoordsVarying);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
