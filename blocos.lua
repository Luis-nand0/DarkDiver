local Blocos = {}

local blocos = {}
Blocos.lista = blocos

local spriteBolha = love.graphics.newImage("Spritesheets/bolha_spritesheet.png") -- sprite das bolhas

function Blocos.carregar(world, mapa)
    -- Limpa a lista anterior (caso recarregue a fase)
    for i = #blocos, 1, -1 do table.remove(blocos, i) end

    -- Blocos de pulo (bolhas)
    local jumpLayer = mapa.layers.jumpBlocks
    if jumpLayer and jumpLayer.objects then
        for _, obj in ipairs(jumpLayer.objects) do
            if obj.properties and obj.properties.isJumpBlock then
                local bloco = {
                    x = obj.x,
                    y = obj.y,
                    w = obj.width,
                    h = obj.height,
                    isJumpBlock = true,
                   forcaDoPulo = obj.properties.forcaDoPulo,
                    sprite = spriteBolha
                }
                world:add(bloco, bloco.x, bloco.y, bloco.w, bloco.h)
                table.insert(blocos, bloco)
            end
        end
    end

    -- Blocos de wall-jump
    local wallJumpLayer = mapa.layers.wallJumpBlocks
    if wallJumpLayer and wallJumpLayer.objects then
        for _, obj in ipairs(wallJumpLayer.objects) do
            if obj.properties and obj.properties.isWallJumpBlock then
                local bloco = {
                    x = obj.x,
                    y = obj.y,
                    w = obj.width,
                    h = obj.height,
                    isWallJumpBlock = true,
                    jumpDirection = obj.properties.jumpDirection or "right"
                }
                world:add(bloco, bloco.x, bloco.y, bloco.w, bloco.h)
                table.insert(blocos, bloco)
            end
        end
    end

    -- Blocos de espinhos (spikes)
    local spikeLayer = mapa.layers.spikes
    if spikeLayer and spikeLayer.objects then
        for _, obj in ipairs(spikeLayer.objects) do
            if obj.properties and obj.properties.isSpike then
                local spike = {
                    x = obj.x,
                    y = obj.y,
                    w = obj.width,
                    h = obj.height,
                    isSpike = true,
                }
                world:add(spike, spike.x, spike.y, spike.w, spike.h)
                table.insert(blocos, spike)
            end
        end
    end

    -- Blocos de saída (exit)
    local exitLayer = mapa.layers.exits
    if exitLayer and exitLayer.objects then
        for _, obj in ipairs(exitLayer.objects) do
            if obj.properties and obj.properties.isExit then
                local exitZone = {
                    x = obj.x,
                    y = obj.y,
                    w = obj.width,
                    h = obj.height,
                    isExit = true,
                }
                world:add(exitZone, exitZone.x, exitZone.y, exitZone.w, exitZone.h)
                table.insert(blocos, exitZone)
            end
        end
    end
end

function Blocos.draw()
    for _, bloco in ipairs(blocos) do
        if bloco.isJumpBlock and bloco.sprite then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(bloco.sprite, bloco.x, bloco.y)
        end
        -- Se quiser desenhar outros blocos com sprites futuramente, você pode estender aqui
    end
end

return Blocos
