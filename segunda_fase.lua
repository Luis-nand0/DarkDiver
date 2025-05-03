-- segunda_fase.lua
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
local fonte = require "fonte"
local pontos = require "pontos"

local segunda_fase = {}
local cam = Camera()
segunda_fase.cam = cam   -- expõe a câmera para uso externo

local world, mapa, player
local enemies = {}
local pontos_coletaveis = {}  -- NOVO


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

function segunda_fase.load()

  local fontHacker= love.graphics.newFont("fonts/hacker.ttf", 18)
    fonte.setar(fontHacker)

  world = bump.newWorld(32)
  mapa  = sti("maps/segunda_fase.lua", { "bump" })
  mapa:resize()
  pontos.reset()
  Blocos.carregar(world, mapa)
  mapa:bump_init(world)

  pontos_coletaveis = {}  -- Reinicia os pontos da fase


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
  for _, n in ipairs({ "Walls_fase2"}) do
    if mapa.layers[n] then mapa.layers[n].visible = false end
  end

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

  -- Spawna jogador
  local sx, sy = encontrarSpawn(mapa)
  player = Player.new()
  player:load(world, sx, sy)
  segunda_fase.player = player   -- expõe o player para uso externo

  -- Carrega inimigos
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

function segunda_fase.update(dt)
  mapa:update(dt)
  player:update(dt)

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

  -- Coletar pontos
  utils.coletarPontos(player, pontos_coletaveis)

  if player.dead then
    return "dead"
  elseif player.reachedExit then
    return "exit"
  else
    return "alive"
  end
end

function segunda_fase.draw()
  cam:attach()
  for _, layerName in ipairs({ "fundo", "floor", "blocos" }) do
    if mapa.layers[layerName] then
      mapa:drawLayer(mapa.layers[layerName])
    end
  end

  for _, e in ipairs(enemies) do
    e:draw()
  end

  for _, p in ipairs(pontos_coletaveis) do
    love.graphics.setColor(1, 1, 0) -- amarelo
    love.graphics.rectangle("fill", p.x, p.y, p.w, p.h)
  end
  love.graphics.setColor(1, 1, 1)

  player:draw()
  cam:detach()
end

return segunda_fase
