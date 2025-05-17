local Pontos = {}

local valor = 0
local sprite = nil

-- Carrega o sprite usado para desenhar os pontos coletáveis
function Pontos.load(caminho)
    sprite = love.graphics.newImage(caminho or "sprites/ponto.png")
end

function Pontos.getSprite()
    return sprite
end

-- Adiciona pontos
function Pontos.add(qtd)
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
