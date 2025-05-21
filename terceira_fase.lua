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
local fonte      = require "fonte"
local pontos     = require "pontos"

local terceira_fase = {}
local cam = Camera()
terceira_fase.cam = cam   -- expõe a câmera para uso externo

local world, mapa, player
local enemies = {}
local pontos_coletaveis = {}
local boss

-- Variáveis para background
local backgroundImage
local backgroundScale = 1

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
  local fontArial = love.graphics.newFont("fonts/arial.ttf", 18)
  fonte.setar(fontArial)

  world = bump.newWorld(32)
  mapa  = sti("maps/terceira_fase.lua", { "bump" })
  mapa:resize()
  pontos.reset()
  Blocos.carregar(world, mapa)
  mapa:bump_init(world)

  -- Carregar imagem de fundo e calcular escala para cobrir a tela
  backgroundImage = love.graphics.newImage("maps/fundo3.png")
  backgroundScale = math.max(
    love.graphics.getWidth() / backgroundImage:getWidth(),
    love.graphics.getHeight() / backgroundImage:getHeight()
  )

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

  -- Carrega pontos do mapa
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
  for _, n in ipairs({ "Walls_fase3"}) do
    if mapa.layers[n] then mapa.layers[n].visible = false end
  end

  -- Spawna jogador (agora passando a câmera)
  local sx, sy = encontrarSpawn(mapa)
  player = Player.new(cam)
  player:load(world, sx, sy)
  player.shootEnabled = true  -- Ativa o tiro apenas nesta fase
  terceira_fase.player = player   -- expõe o player para uso externo

  -- Carrega inimigos
  enemies = {}
  boss = nil
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
          boss = e               -- guarda referência ao boss
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
  player:update(dt, mapa)

  for _, e in ipairs(enemies) do
    e:update(dt, player)
  end

  utils.coletarPontos(player, pontos_coletaveis)

  local px, py = player:getPosition()
  utils.limitarCamera(
    cam, px, py,
    mapa.width * mapa.tilewidth,
    mapa.height * mapa.tileheight,
    love.graphics.getWidth(),
    love.graphics.getHeight()
  )

  -- requer derrotar boss antes de sair
  if player.dead then
    return "dead"
  elseif player.reachedExit then
    if boss and not boss.isDead then
      -- jogador atingiu saída mas boss ainda vivo: bloqueia saída
      return "alive"
    end
    return "exit"
  else
    return "alive"
  end
end

function terceira_fase.draw()
  cam:attach()

  -- Desenha background fixo seguindo a câmera
  if backgroundImage then
    love.graphics.draw(
      backgroundImage,
      cam.x - love.graphics.getWidth() / 2,
      cam.y - love.graphics.getHeight() / 2,
      0,
      backgroundScale,
      backgroundScale
    )
  end

  -- Desenho do mapa e entidades
  for _, layerName in ipairs({ "fundo", "floor", "bpulo", "espinhos"}) do
    if mapa.layers[layerName] then
      mapa:drawLayer(mapa.layers[layerName])
    end
  end

  for _, e in ipairs(enemies) do
    e:draw()
  end

  -- Desenhar pontos coletáveis
  for _, p in ipairs(pontos_coletaveis) do
    love.graphics.setColor(1, 1, 0) -- amarelo
    love.graphics.rectangle("fill", p.x, p.y, p.w, p.h)
  end
  love.graphics.setColor(1, 1, 1)

  player:draw()
  cam:detach()

  -- HUD (barra de vida do boss) na parte inferior
  if boss and not boss.isDead then
    local sw, sh  = love.graphics.getWidth(), love.graphics.getHeight()
    local barW, barH = sw * 0.6, 20
    local bx = (sw - barW) / 2
    local by = sh * 0.9  -- posiciona a 90% da altura da tela

    local pct = math.max(boss.health, 0) / boss.maxHealth

    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", bx, by, barW, barH)

    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", bx, by, barW * pct, barH)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", bx, by, barW, barH)
  end
end

function terceira_fase.mousepressed(x, y, button)
  if player and player.mousepressed then
    player:mousepressed(x, y, button)
  end
end

return terceira_fase
