uniform sampler2D video;
uniform sampler2D usermask;
uniform float threshold;

varying vec4 vertTexCoord;

float thresholdColor(float edge, vec4 color) {
    return step(edge,
        // (color.r + color.g + color.b) / 3.0
        // max(color.r, max(color.g, color.b))
        color.r
    );
}

void main() {
    vec4 texelColor = texture(video, vertTexCoord);
    vec4 texelUser = texture(usermask, vertTexCoord);

    vec3 rgb;
    if (threshold > 0.0) {
        rgb = vec3(thresholdColor(threshold, texelColor));
    } else {
        rgb = texelColor.rgb;
    }

    gl_FragColor = vec4(rgb, texelUser.r);
}
