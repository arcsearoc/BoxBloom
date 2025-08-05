uniform float intensity;
uniform Image original;
vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
    vec4 bloom = Texel(texture, texCoords);
    vec4 orig = Texel(original, texCoords);
    vec3 combined = orig.rgb + bloom.rgb * intensity;
    return vec4(clamp(combined, 0.0, 1.0), orig.a);
}