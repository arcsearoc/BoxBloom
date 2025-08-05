uniform float blurRadius;
uniform vec2 textureSize;
vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
    vec4 sum = vec4(0.0);
    float count = 0.0;
    float step = 1.0 / textureSize.y;
    
    for (float i = -blurRadius; i <= blurRadius; i++) {
        vec2 offset = vec2(0.0, i * step);
        sum += Texel(texture, texCoords + offset);
        count += 1.0;
    }
    
    return sum / count;
}