local P = {}

P.valor = 0

function P.reset()
    P.valor = 0
end

function P.adicionar(qtd)
    P.valor = P.valor + qtd
end

function P.get()
    return P.valor
end

return P
