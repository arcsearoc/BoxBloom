// 盒型滤波实现 - 基于论文 "The Power of Box Filters"
uniform float blurRadius;
uniform vec2 textureSize;

vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
    // 由于LÖVE不直接支持在着色器中访问mipmap级别，我们使用盒型滤波的简化实现
    // 这个实现基于论文思想，但使用多个不同大小的采样区域来模拟mipmap效果
    
    float sigma = blurRadius * 0.5;
    vec4 result = vec4(0.0);
    float totalWeight = 0.0;
    
    // 使用不同大小的采样步长来模拟不同mipmap级别
    // 每个级别的步长是前一级别的2倍（模拟mipmap的2x2降采样）
    float baseStep = 1.0 / max(textureSize.x, textureSize.y);
    
    // 模拟多个mipmap级别（通常5-8个级别就足够了）
    int levels = 5;
    
    for (int level = 0; level < levels; level++) {
        // 计算当前级别的步长
        float step = baseStep * pow(2.0, float(level));
        
        // 计算当前级别的权重（基于论文中的公式简化版）
        float pi = 3.14159265359;
        float levelF = float(level);
        float power4L = pow(4.0, levelF);
        float weight = exp(-power4L / (2.0 * pi * sigma * sigma)) / power4L;
        
        // 在当前级别进行采样（使用盒型滤波的思想，但通过手动采样实现）
        vec4 levelSum = vec4(0.0);
        float sampleCount = 0.0;
        
        // 采样区域大小随级别增加而增大
        int sampleRadius = int(pow(2.0, float(level)));
        
        // 在当前级别的采样区域内进行均匀采样
        for (int y = -sampleRadius; y <= sampleRadius; y += max(1, sampleRadius / 2)) {
            for (int x = -sampleRadius; x <= sampleRadius; x += max(1, sampleRadius / 2)) {
                vec2 offset = vec2(float(x), float(y)) * step;
                levelSum += Texel(texture, texCoords + offset);
                sampleCount += 1.0;
            }
        }
        
        // 计算当前级别的平均值
        if (sampleCount > 0.0) {
            levelSum /= sampleCount;
        }
        
        // 累加到结果中
        result += weight * levelSum;
        totalWeight += weight;
    }
    
    // 归一化结果
    if (totalWeight > 0.0) {
        result /= totalWeight;
    }
    
    return result;
}
