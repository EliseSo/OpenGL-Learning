
precision mediump float;

varying mediump vec2 textureCoordsVarying;
uniform sampler2D texture;
uniform int mosaicType;

const vec2 TexSize = vec2(400.0, 400.0);
const vec2 mosaicSize = vec2(16.0, 16.0);
const float hexagonSize = 0.03;
const float triangleSize = 0.03;


void main()
{
    if (mosaicType == 0) {
        vec2 intXY = vec2(textureCoordsVarying.x * TexSize.x, textureCoordsVarying.y * TexSize.y);
        vec2 XYMosaic = vec2(floor(intXY.x/mosaicSize.x)*mosaicSize.x, floor(intXY.y/mosaicSize.y)*mosaicSize.y);
        vec2 UVMosaic = vec2(XYMosaic.x/TexSize.x, XYMosaic.y/TexSize.y);
        vec4 color = texture2D(texture, UVMosaic);
        gl_FragColor = color;
    }
    else if(mosaicType == 1) {
        float length = hexagonSize;
        float TR = 0.866025;

        float x = textureCoordsVarying.x;
        float y = textureCoordsVarying.y;

        int wx = int(x / 1.5 / length);
        int wy = int(y / TR / length);
        vec2 v1, v2, vn;

        if (wx/2 * 2 == wx) {
            if (wy/2 * 2 == wy) {
                //(0,0),(1,1)
                v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy));
                v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy + 1));
            } else {
                //(0,1),(1,0)
                v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy + 1));
                v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy));
            }
        }else {
            if (wy/2 * 2 == wy) {
                //(0,1),(1,0)
                v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy + 1));
                v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy));
            } else {
                //(0,0),(1,1)
                v1 = vec2(length * 1.5 * float(wx), length * TR * float(wy));
                v2 = vec2(length * 1.5 * float(wx + 1), length * TR * float(wy + 1));
            }
        }
        float s1 = sqrt(pow(v1.x - x, 2.0) + pow(v1.y - y, 2.0));
        float s2 = sqrt(pow(v2.x - x, 2.0) + pow(v2.y - y, 2.0));
        if (s1 < s2) {
            vn = v1;
        } else {
            vn = v2;
        }
        vec4 color = texture2D(texture, vn);

        gl_FragColor = color;

    }
    else if(mosaicType == 2) {
        const float TR = 0.866025;
        const float PI6 = 0.523599;

        float x = textureCoordsVarying.x;
        float y = textureCoordsVarying.y;

        int wx = int(x/(1.5 * triangleSize));
        int wy = int(y/(TR * triangleSize));

        vec2 v1, v2, vn;

        if (wx / 2 * 2 == wx) {
            if (wy/2 * 2 == wy) {
                v1 = vec2(triangleSize * 1.5 * float(wx), triangleSize * TR * float(wy));
                v2 = vec2(triangleSize * 1.5 * float(wx + 1), triangleSize * TR * float(wy + 1));
            } else {
                v1 = vec2(triangleSize * 1.5 * float(wx), triangleSize * TR * float(wy + 1));
                v2 = vec2(triangleSize * 1.5 * float(wx + 1), triangleSize * TR * float(wy));
            }
        } else {
            if (wy/2 * 2 == wy) {
                v1 = vec2(triangleSize * 1.5 * float(wx), triangleSize * TR * float(wy + 1));
                v2 = vec2(triangleSize * 1.5 * float(wx+1), triangleSize * TR * float(wy));
            } else {
                v1 = vec2(triangleSize * 1.5 * float(wx), triangleSize * TR * float(wy));
                v2 = vec2(triangleSize * 1.5 * float(wx + 1), triangleSize * TR * float(wy+1));
            }
        }

        float s1 = sqrt(pow(v1.x - x, 2.0) + pow(v1.y - y, 2.0));
        float s2 = sqrt(pow(v2.x - x, 2.0) + pow(v2.y - y, 2.0));

        if (s1 < s2) {
            vn = v1;
        } else {
            vn = v2;
        }

        vec4 mid = texture2D(texture, vn);
        float a = atan((x - vn.x)/(y - vn.y));
        //1
        vec2 area1 = vec2(vn.x, vn.y - triangleSize * TR / 2.0);
        // 2
        vec2 area2 = vec2(vn.x + triangleSize / 2.0, vn.y - triangleSize * TR / 2.0);
        //3
        vec2 area3 = vec2(vn.x + triangleSize / 2.0, vn.y + triangleSize * TR / 2.0);
        //4
        vec2 area4 = vec2(vn.x, vn.y + triangleSize * TR / 2.0);
        // 5
        vec2 area5 = vec2(vn.x - triangleSize / 2.0, vn.y + triangleSize * TR / 2.0);
        // 6
        vec2 area6 = vec2(vn.x - triangleSize / 2.0, vn.y - triangleSize * TR / 2.0);

        if (a >= PI6 && a < PI6 * 3.0) {
            vn = area1;
        } else if (a >= PI6 * 3.0 && a < PI6 * 5.0) {
            vn = area2;
        } else if ((a >= PI6 * 5.0 && a <= PI6 * 6.0) || (a < -PI6 * 5.0 && a > -PI6 * 6.0)) {
            vn = area3;
        } else if (a < -PI6 * 3.0 && a >= -PI6 * 5.0) {
            vn = area4;
        } else if(a <= -PI6 && a> -PI6 * 3.0) {
            vn = area5;
        } else if (a > -PI6 && a < PI6) {
            vn = area6;
        }

        vec4 color = texture2D(texture, vn);
        gl_FragColor = color;
    }
    else {
        gl_FragColor = texture2D(texture, textureCoordsVarying);
    }
}


