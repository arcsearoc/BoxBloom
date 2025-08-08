// 盒型滤波实现 - 基于论文 "The Power of Box Filters" 的极简版
uniform float blurRadius;
uniform vec2 textureSize;

vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
    // 简化版盒型滤波实现，完全避免数组和类型转换
    float sigma = blurRadius * 0.5;
    vec4 result = vec4(0.0);
    float totalWeight = 0.0;
    
    // 基础步长
    float baseStep = 1.0 / max(textureSize.x, textureSize.y);
    
    // 级别1 - 小范围采样
    {
        float step = baseStep * 1.0;
        float weight = exp(-1.0 / (2.0 * 3.14159 * sigma * sigma)) / 1.0;
        
        vec4 levelSum = vec4(0.0);
        float sampleCount = 0.0;
        
        // 3x3 采样
        for (float y = -1.0; y <= 1.0; y += 1.0) {
            for (float x = -1.0; x <= 1.0; x += 1.0) {
                vec2 offset = vec2(x, y) * step;
                levelSum += Texel(texture, texCoords + offset);
                sampleCount += 1.0;
            }
        }
        
        levelSum /= sampleCount;
        result += weight * levelSum;
        totalWeight += weight;
    }
    
    // 级别2 - 中范围采样
    {
        float step = baseStep * 4.0;
        float weight = exp(-4.0 / (2.0 * 3.14159 * sigma * sigma)) / 4.0;
        
        vec4 levelSum = vec4(0.0);
        float sampleCount = 0.0;
        
        // 5x5 采样
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            for (float x = -2.0; x <= 2.0; x += 1.0) {
                vec2 offset = vec2(x, y) * step;
                levelSum += Texel(texture, texCoords + offset);
                sampleCount += 1.0;
            }
        }
        
        levelSum /= sampleCount;
        result += weight * levelSum;
        totalWeight += weight;
    }
    
    // 级别3 - 大范围采样
    {
        float step = baseStep * 16.0;
        float weight = exp(-16.0 / (2.0 * 3.14159 * sigma * sigma)) / 16.0;
        
        vec4 levelSum = vec4(0.0);
        float sampleCount = 0.0;
        
        // 5x5 采样，但步长更大
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            for (float x = -2.0; x <= 2.0; x += 1.0) {
                vec2 offset = vec2(x, y) * step;
                levelSum += Texel(texture, texCoords + offset);
                sampleCount += 1.0;
            }
        }
        
        levelSum /= sampleCount;
        result += weight * levelSum;
        totalWeight += weight;
    }
    
    // 归一化结果
    if (totalWeight > 0.0) {
        result /= totalWeight;
    }
    
    return result;
}