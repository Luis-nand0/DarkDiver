-- blocos.lua
local Blocos = {}

function Blocos.carregar(world, mapa)
    -- Blocos de pulo
    local jumpLayer = mapa.layers.jumpBlocks
    if jumpLayer and jumpLayer.objects then
        for _, obj in ipairs(jumpLayer.objects) do
            if obj.properties and obj.properties.isJumpBlock then
                -- Criar um objeto que tem o 'isJumpBlock' como propriedade
                local bloco = {
                    x = obj.x, 
                    y = obj.y, 
                    w = obj.width, 
                    h = obj.height, 
                    isJumpBlock = true
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
end
return Blocos