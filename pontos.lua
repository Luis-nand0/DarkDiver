local Pontos = {}

local valor = 0
local sprite = nil

local soundFxPoints = nil

-- Carrega o sprite usado para desenhar os pontos coletáveis
function Pontos.load(caminho)
    sprite = love.graphics.newImage(caminho or "sprites/ponto.png")
    soundFxPoints = love.audio.newSource("soundEffects/collect-points-190037.mp3", "static")
end

function Pontos.getSprite()
    return sprite
end

-- Adiciona pontos
function Pontos.add(qtd)
    soundFxPoints:stop()
    soundFxPoints:play()
    valor = valor + (qtd or 1)
end

-- Retorna os pontos atuais
function Pontos.get()
    return valor
end

-- Zera os pontos
function Pontos.reset()
    valor = 0
end

-- Define um valor específico
function Pontos.set(novoValor)
    valor = novoValor or 0
end

return Pontos
