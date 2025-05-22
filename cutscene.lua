local Cutscene = {}
Cutscene.__index = Cutscene

function Cutscene.new(images)
    local self = setmetatable({}, Cutscene)
    self.images = {} -- array de imagens carregadas
    for _, path in ipairs(images) do
        table.insert(self.images, love.graphics.newImage(path))
    end
    self.current = 1
    self.finished = false
    return self
end

function Cutscene:update(dt)
    -- nada aqui por enquanto
end

function Cutscene:draw()
    if self.finished then return end

    local image = self.images[self.current]
    if image then
        local iw = image:getWidth()
        local ih = image:getHeight()

        local sw, sh = love.graphics.getDimensions()

        -- Calcula a escala para preencher a tela inteira
        local scaleX = sw / iw
        local scaleY = sh / ih

        -- Para preencher totalmente a tela, usamos o maior fator
        local scale = math.max(scaleX, scaleY)

        -- Centraliza a imagem na tela
        local offsetX = (sw - iw * scale) / 2
        local offsetY = (sh - ih * scale) / 2

        love.graphics.draw(image, offsetX, offsetY, 0, scale, scale)
    end
end

function Cutscene:keypressed(key)
    if self.finished then return end
    if key == "space" or key == "return" then
        self.current = self.current + 1
        if self.current > #self.images then
            self.finished = true
        end
    end
end

return Cutscene
