local Blocos = {}

function Blocos.carregar(world, mapa)
    -- Blocos de pulo
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
                    forcaDoPulo = obj.properties.forcaDoPulo 
                }
                world:add(bloco, obj.x, obj.y, obj.width, obj.height)
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
                world:add(bloco, obj.x, obj.y, obj.width, obj.height)
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
                world:add(spike, obj.x, obj.y, obj.width, obj.height)
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
                world:add(exitZone, obj.x, obj.y, obj.width, obj.height)
            end
        end
    end
end

return Blocos
