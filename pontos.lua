local Pontos = {}
local valor = 0

-- Adiciona pontos
function Pontos.add(qtd)
    valor = valor + qtd
end

-- Retorna os pontos atuais
function Pontos.get()
    return valor
end

-- Zera os pontos
function Pontos.reset()
    valor = 0
end

-- Define um valor específico (opcional)
function Pontos.set(novoValor)
    valor = novoValor or 0
end

return Pontos

