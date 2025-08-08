-- 引入BloomEffect类（主要管理参数，实际计算在shader中）
local BloomEffect = {}
BloomEffect.__index = BloomEffect

function BloomEffect.new(config)
    local self = setmetatable({}, BloomEffect)
    self.threshold = config.threshold or 150
    self.blurRadius = config.blurRadius or 3
    self.intensity = config.intensity or 1.2
    self:createShaders()
    return self
end

-- 创建所需的shader
function BloomEffect:createShaders()
    -- 加载外部shader文件
    local function loadShaderFromFile(path)
        local file = love.filesystem.newFile(path)
        file:open("r")
        local content = file:read()
        file:close()
        return love.graphics.newShader(content)
    end

    -- 提取高亮区域的shader
    self.extractShader = loadShaderFromFile("shader-glsl/extract_highlights.glsl")
    
    -- 盒型滤波shader (替代原来的水平和垂直模糊)
    self.boxFilterShader = loadShaderFromFile("shader-glsl/box_filter_blur.glsl")
    
    -- 合并效果shader
    self.combineShader = loadShaderFromFile("shader-glsl/combine_effect.glsl")
end

-- 更新shader参数
function BloomEffect:updateShaderParams()
    self.extractShader:send("threshold", self.threshold)
    self.boxFilterShader:send("blurRadius", self.blurRadius)
    self.combineShader:send("intensity", self.intensity)
end

-- 生成Bloom效果的主函数（使用盒型滤波shader）
function BloomEffect:generateBloom(originalImage)
    self:updateShaderParams()
    
    local width, height = originalImage:getWidth(), originalImage:getHeight()
    
    -- 创建临时画布用于处理
    local canvas1 = love.graphics.newCanvas(width, height)
    local canvas2 = love.graphics.newCanvas(width, height)
    
    -- 1. 提取高亮区域
    love.graphics.setCanvas(canvas1)
    love.graphics.setShader(self.extractShader)
    love.graphics.draw(originalImage)
    love.graphics.setShader()
    
    -- 2. 应用盒型滤波（一次性完成模糊，不需要分水平和垂直两步）
    love.graphics.setCanvas(canvas2)
    love.graphics.setShader(self.boxFilterShader)
    self.boxFilterShader:send("textureSize", {width, height})
    love.graphics.draw(canvas1)
    love.graphics.setShader()
    
    -- 3. 与原图合并
    love.graphics.setCanvas(canvas1)
    love.graphics.setShader(self.combineShader)
    self.combineShader:send("original", originalImage)
    love.graphics.draw(canvas2)
    love.graphics.setShader()
    
    -- 恢复画布
    love.graphics.setCanvas()
    
    -- 返回处理结果
    return canvas1
end

-- 主程序逻辑
function love.load()
    -- 配置参数
    config = {
        imageUrl = "test.png",  -- 请将图片放在项目目录下
        threshold = 150,
        blurRadius = 3,
        intensity = 1.2,
        dividerX = 400  -- 初始分隔线位置
    }

    -- 状态变量
    isDragging = false
    originalImage = nil
    bloomImage = nil
    isProcessing = false
    bloomEffect = BloomEffect.new(config)  -- 创建Bloom效果实例

    -- 加载图像
    loadImage()
end

function loadImage()
    -- 直接加载为Image
    originalImage = love.graphics.newImage(config.imageUrl)
    
    if originalImage then
        -- 开始处理Bloom效果
        isProcessing = true
        
        -- 使用协程避免处理时界面冻结
        coroutine.wrap(function()
            generateBloomTexture()
            isProcessing = false
        end)()
    else
        print("Failed to load image, please ensure " .. config.imageUrl .. " exists in the project directory")
    end
end

function generateBloomTexture()
    if not originalImage then return end
    
    -- 使用BloomEffect类生成效果（现在使用shader）
    bloomImage = bloomEffect:generateBloom(originalImage)
end

function love.update(dt)
    -- 处理窗口大小变化时的分隔线位置调整
    if love.mouse.isDown(1) and isDragging then
        local mouseX = love.mouse.getX()
        -- 限制分隔线在窗口内
        config.dividerX = math.max(10, math.min(mouseX, love.graphics.getWidth() - 10))
    end
end

function love.draw()
    -- 设置背景色
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    
    -- 检查图像是否加载完成
    if not originalImage then
        love.graphics.printf("Failed to load image: " .. config.imageUrl, 0, 50, love.graphics.getWidth(), "center")
        return
    end
    
    if isProcessing then
        love.graphics.printf("Processing bloom effect...", 0, 50, love.graphics.getWidth(), "center")
        return
    end
    
    -- 绘制左侧原图
    love.graphics.setScissor(0, 0, config.dividerX, love.graphics.getHeight())
    drawImageCentered(originalImage)
    love.graphics.setScissor()
    
    -- 绘制右侧Bloom效果
    love.graphics.setScissor(config.dividerX, 0, love.graphics.getWidth() - config.dividerX, love.graphics.getHeight())
    if bloomImage then
        drawImageCentered(bloomImage)
    else
        drawImageCentered(originalImage)
        love.graphics.printf("Bloom effect generation failed", 0, 50, love.graphics.getWidth(), "center")
    end
    love.graphics.setScissor()
    
    -- 绘制分隔线
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", config.dividerX - 1, 0, 2, love.graphics.getHeight())
    
    -- 绘制提示文本
    love.graphics.print("Drag the white divider to compare effects", 10, 10)
    love.graphics.print("Press UP/DOWN to adjust threshold (" .. config.threshold .. ")", 10, 30)
    love.graphics.print("Press LEFT/RIGHT to adjust blur radius (" .. config.blurRadius .. ")", 10, 50)
    love.graphics.print("Press +/- to adjust intensity (" .. config.intensity .. ")", 10, 70)
end

-- 居中绘制图像的辅助函数
function drawImageCentered(image)
    local imgWidth, imgHeight = image:getWidth(), image:getHeight()
    local winWidth, winHeight = love.graphics.getWidth(), love.graphics.getHeight()
    
    -- 计算缩放比例以适应窗口
    local scale = math.min(winWidth / imgWidth, winHeight / imgHeight) * 0.8
    
    -- 计算居中位置
    local x = winWidth / 2 - (imgWidth * scale) / 2
    local y = winHeight / 2 - (imgHeight * scale) / 2
    
    -- 绘制图像
    love.graphics.draw(image, x, y, 0, scale, scale)
end

function love.mousepressed(x, y, button)
    -- 检查是否点击了分隔线
    if button == 1 and math.abs(x - config.dividerX) <= 5 then
        isDragging = true
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        isDragging = false
    end
end

function love.keypressed(key)
    -- 按ESC键退出
    if key == "escape" then
        love.event.quit()
    end
    
    -- 增加交互性：调整参数
    local needsUpdate = false
    
    if key == "up" then
        config.threshold = math.min(255, config.threshold + 5)
        bloomEffect.threshold = config.threshold
        needsUpdate = true
    elseif key == "down" then
        config.threshold = math.max(0, config.threshold - 5)
        bloomEffect.threshold = config.threshold
        needsUpdate = true
    elseif key == "right" then
        config.blurRadius = math.min(10, config.blurRadius + 1)
        bloomEffect.blurRadius = config.blurRadius
        needsUpdate = true
    elseif key == "left" then
        config.blurRadius = math.max(1, config.blurRadius - 1)
        bloomEffect.blurRadius = config.blurRadius
        needsUpdate = true
    elseif key == "+" or key == "kp+" then
        config.intensity = math.min(5, config.intensity + 0.1)
        bloomEffect.intensity = config.intensity
        needsUpdate = true
    elseif key == "-" or key == "kp-" then
        config.intensity = math.max(0, config.intensity - 0.1)
        bloomEffect.intensity = config.intensity
        needsUpdate = true
    end
    
    -- 如果参数变化，重新生成效果
    if needsUpdate and originalImage then
        isProcessing = true
        coroutine.wrap(function()
            generateBloomTexture()
            isProcessing = false
        end)()
    end
end

function love.resize(w, h)
    -- 窗口大小改变时保持分隔线在中间
    if config.dividerX > w then
        config.dividerX = w / 2
    end
end