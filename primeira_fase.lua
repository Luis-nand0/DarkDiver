local sti        = require "libs.sti"
local bump       = require "libs.bump"
local Camera     = require "libs.hump.camera"

local utils      = require "utils"
local Player     = require "player"
local Blocos     = require "blocos"
local Enemy      = require "enemy"
local Sentinela  = require "sentinela"
local Rebatedor  = require "rebatedor"
local Caranguejo = require "caranguejo"
local pontos     = require "pontos"
local fonte      = require "fonte"

local primeira_fase = {}
local cam = Camera()
primeira_fase.cam = cam

local world, mapa, player
local enemies = {}
local pontos_coletaveis = {}

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

function primeira_fase.load()
  local fontRidiculo = love.graphics.newFont("fonts/Ridiculo.ttf", 18)
  fonte.setar(fontRidiculo)

  world = bump.newWorld(32)
  mapa  = sti("maps/primeira_fase.lua", { "bump" })
  mapa:resize()
  pontos.reset()
  pontos.load("Spritesheets/nacho_sprite.png") -- <== define o sprite da fase

  Blocos.carregar(world, mapa)
  mapa:bump_init(world)

  pontos_coletaveis = {}

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

  -- Pontos coletáveis
  local pontoLayer = mapa.layers["pontos"]
  if pontoLayer and pontoLayer.objects then
    for _, obj in ipairs(pontoLayer.objects) do
      if obj.properties and obj.properties.isPoint then
        table.insert(pontos_coletaveis, {
          x = obj.x,
          y = obj.y,
          w = obj.width or 16,
          h = obj.height or 16
        })
      end
    end
  end

  -- Oculta colisões visuais
  for _, n in ipairs({ "Walls_fase1", "borders_fase1" }) do
    if mapa.layers[n] then mapa.layers[n].visible = false end
  end

  local sx, sy = encontrarSpawn(mapa)
  player = Player.new()
  player:load(world, sx, sy)
  primeira_fase.player = player

  -- Inimigos
  enemies = {}
  local enemyLayer = mapa.layers["enemies"]
  if enemyLayer and enemyLayer.objects then
    for _, obj in ipairs(enemyLayer.objects) do
      local p = obj.properties
      if p then
        if p.isEnemy then
          local e = Enemy.new(world, obj.x, obj.y, {
            width           = obj.width,
            height          = obj.height,
            speed           = p.speed,
            detectionRadius = p.detectionRadius,
            fase = 1
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

function primeira_fase.update(dt)
  mapa:update(dt)
  player:update(dt)

  for _, e in ipairs(enemies) do
    e:update(dt, player)
  end

  -- Coleta de pontos
  utils.coletarPontos(player, pontos_coletaveis)

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

function primeira_fase.draw()
  cam:attach()

  -- Desenha as bolhas com sprite
  Blocos.draw()

  -- Desenha camadas do Tiled
  for _, layerName in ipairs({ "fundo", "floor", "espinhos", "decoracao" }) do
    if mapa.layers[layerName] then
      mapa:drawLayer(mapa.layers[layerName])
    end
  end

  -- Desenha inimigos
  for _, e in ipairs(enemies) do
    e:draw()
  end

  -- Desenha pontos coletáveis com sprite
  local img = pontos.getSprite()
  if img then
    for _, p in ipairs(pontos_coletaveis) do
      local scale = 2
      local spriteW, spriteH = 16, 16
      love.graphics.draw(img, p.x, p.y, 0, scale, scale, spriteW / 2, spriteH / 2)
    end
  end

  -- Desenha o jogador
  player:draw()

  cam:detach()
end

return primeira_fase
