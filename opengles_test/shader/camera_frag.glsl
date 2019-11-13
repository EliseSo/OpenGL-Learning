precision mediump float;

varying lowp vec4 fColor;
varying lowp vec3 fragPos;
varying lowp vec3 fragNormal;

uniform lowp vec3 color;
uniform lowp float ambientIntensity;
uniform lowp float diffuseIntensity;
uniform lowp vec3 lightPos;
uniform float specularIntensity;
uniform float shininess;

void main(void) {

    // Ambient
    lowp vec3 ambientColor = color * ambientIntensity;

    // Diffuse
    lowp vec3 normal = normalize(fragNormal);
    lowp vec3 lightDir = normalize(lightPos - fragPos);
    lowp float diffuseFactor = max(-dot(normal, lightDir), 0.0);
    lowp vec3 diffuseColor = color * diffuseIntensity * diffuseFactor;

    // Specular
    lowp vec3 eye = normalize(fragPos);
    lowp vec3 reflection = reflect(-lightDir, normal);
    lowp float specularFactor = pow(max(0.0, dot(reflection, eye)), shininess);
    lowp vec3 specularColor = color * specularIntensity * specularFactor;

    gl_FragColor = fColor * vec4((ambientColor + diffuseColor + specularColor), 1.0);
}

