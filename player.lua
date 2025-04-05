local Input = require "libs.boipushy.input"

local Player = {}
Player.__index = Player

function Player:load(world, x, y)
    self.input = Input()
    self.input:bind("right", "right")
    self.input:bind("left", "left")
    self.input:bind("w", "w")     -- Pular
    self.input:bind("down", "down")

    self.speed = 200
    self.jumpForce = 400
    self.isGrounded = false

    self.collider = world:newRectangleCollider(x, y, 32, 32)
    self.collider:setFixedRotation(true)
    self.collider:setRestitution(0) -- sem quique
    self.collider:setType("dynamic")
end

function Player:update(dt)
    self.input:update()

    -- Checar se está no chão
    local contacts = self.collider:getContacts()
    self.isGrounded = false
    for _, contact in ipairs(contacts) do
        if contact:isTouching() then
            local nx, ny = contact:getNormal()
            if nx < 0 then
                self.isGrounded = true
                break
            end
        end
    end

    local moveX = 0
    if self.input:down("right") then moveX = self.speed end
    if self.input:down("left") then moveX = -self.speed end

    local vx, vy = self.collider:getLinearVelocity()
    self.collider:setLinearVelocity(moveX, vy)

    -- Pulo
    if self.input:pressed("w") and self.isGrounded then
        self.collider:setLinearVelocity(vx, self.jumpForce)
    end
end

function Player:draw()
    love.graphics.setColor(0, 1, 0)
    local x, y = self.collider:getPosition()
    love.graphics.rectangle("fill", x - 16, y - 16, 32, 32)
    love.graphics.setColor(1, 1, 1)
end

function Player:getPosition()
    return self.collider:getPosition()
end

return Player
