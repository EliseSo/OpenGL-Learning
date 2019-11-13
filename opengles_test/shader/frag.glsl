precision mediump float;
varying lowp vec4 fColor;
//attribute vec4 color;
//uniform vec4 color;


void main(void) {
//    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
//    gl_FragColor = color;
    gl_FragColor = fColor;
}


