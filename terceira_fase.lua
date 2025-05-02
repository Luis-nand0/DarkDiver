local sti        = require "libs.sti"
local bump       = require "libs.bump"
local Camera     = require "libs.hump.camera"
local utils      = require "utils"
local Player     = require "player"
local Blocos     = require "blocos"
local Enemy      = require "enemy"
local Boss       = require "boss"
local Sentinela  = require "sentinela"
local Rebatedor  = require "rebatedor"
local Caranguejo = require "caranguejo"

local terceira_fase = {}
local cam = Camera()
terceira_fase.cam = cam   -- expõe a câmera para uso externo

local world, mapa, player
local enemies = {}

local function encontrarSpawn(mapa)
  local x, y = 100, 100
  local layer = mapa.layers["spawn"]
  if layer and layer.objects then
    for _, obj in ipairs(layer.objects) do
      if obj.name == "playerSpawn" then
        x, y = obj.x, obj.y
        break
      end
    end
  end
  return x, y
end

function terceira_fase.load()
  world = bump.newWorld(32)
  mapa  = sti("maps/terceira_fase.lua", { "bump" })
  mapa:resize()

  Blocos.carregar(world, mapa)
  mapa:bump_init(world)

  -- Zonas de saída
  local exitLayer = mapa.layers["exitZone"]
  if exitLayer and exitLayer.objects then
    for _, obj in ipairs(exitLayer.objects) do
      if obj.properties and obj.properties.isExit then
        local zone = { x = obj.x, y = obj.y, w = obj.width, h = obj.height, isExit = true }
        world:add(zone, obj.x, obj.y, obj.width, obj.height)
      end
    end
  end

  -- Oculta colisões visuais
  for _, n in ipairs({ "Walls_fase3"}) do
    if mapa.layers[n] then mapa.layers[n].visible = false end
  end

  -- Spawna jogador
  local sx, sy = encontrarSpawn(mapa)
  player = Player.new()
  player:load(world, sx, sy)
  player.shootEnabled = true  -- Ativa o tiro apenas nesta fase
  terceira_fase.player = player   -- expõe o player para uso externo

  -- Carrega inimigos
  enemies = {}
  local enemyLayer = mapa.layers["enemies"]
  if enemyLayer and enemyLayer.objects then
    for _, obj in ipairs(enemyLayer.objects) do
      local p = obj.properties
      if p then
        if p.isEnemy then
          local e = Boss.new(world, obj.x, obj.y, {
            width           = obj.width,
            height          = obj.height,
            speed           = p.speed,
            detectionRadius = p.detectionRadius
          })
          table.insert(enemies, e)

        elseif p.isSentinela then
          local s = Sentinela.new(obj.x, obj.y)
          s:load(world)
          table.insert(enemies, s)

        elseif p.isRebatedor then
          local r = Rebatedor.new(obj.x, obj.y, p)
          r:load(world)
          table.insert(enemies, r)

        elseif p.isCaranguejo then
          local c = Caranguejo.new(obj.x, obj.y, p)
          c:load(world)
          table.insert(enemies, c)
        end
      end
    end
  end
end

function terceira_fase.update(dt)
  mapa:update(dt)
  player:update(dt,mapa)

  for _, e in ipairs(enemies) do
    e:update(dt, player)
  end

  local px, py = player:getPosition()
  utils.limitarCamera(
    cam, px, py,
    mapa.width * mapa.tilewidth,
    mapa.height * mapa.tileheight,
    love.graphics.getWidth(),
    love.graphics.getHeight()
  )

  if player.dead then
    return "dead"
  elseif player.reachedExit then
    return "exit"
  else
    return "alive"
  end
end

function terceira_fase.draw()
  cam:attach()
  for _, layerName in ipairs({ "fundo", "floor", "bpulo", "espinhos"}) do
    if mapa.layers[layerName] then
      mapa:drawLayer(mapa.layers[layerName])
    end
  end

  for _, e in ipairs(enemies) do
    e:draw()
  end

  player:draw()
  cam:detach()
end

-- Adiciona o tratamento de clique do mouse
function terceira_fase.mousepressed(x, y, button)
  if player and player.mousepressed then
    player:mousepressed(x, y, button)
  end
end

return terceira_fase
