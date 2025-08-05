uniform float threshold;
vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
    vec4 pixel = Texel(texture, texCoords);
    float luminance = 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
    float thresholdNorm = threshold / 255.0;
    
    if (luminance > thresholdNorm) {
        float factor = (luminance - thresholdNorm) / (1.0 - thresholdNorm);
        return vec4(pixel.rgb * factor, pixel.a);
    } else {
        return vec4(0.0, 0.0, 0.0, pixel.a);
    }
}