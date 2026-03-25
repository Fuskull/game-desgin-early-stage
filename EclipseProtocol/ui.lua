-- ui.lua
-- user interface system

ui = {}

function ui.load()
    -- ui setings
    ui.padding = 10
    ui.healthBarWidth = 200
    ui.healthBarHeight = 25
    ui.energyBarWidth = 200
    ui.energyBarHeight = 20
end

function ui.draw(health, energy, gameOver, roomCount, timer)
    -- default values if nil
    health = health or 100
    energy = energy or 100
    gameOver = gameOver or false
    roomCount = roomCount or 0
    timer = timer or 0
    
    -- ensure ui is initialized
    if not ui.healthBarWidth then
        ui.load()
    end
    
    -- draw helth bar backround
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", ui.padding, ui.padding, ui.healthBarWidth, ui.healthBarHeight)
    
    -- draw health bar (curent health)
    local healthPercent = health / 100
    local currentWidth = ui.healthBarWidth * healthPercent
    
    -- color based on helth level
    if healthPercent > 0.6 then
        love.graphics.setColor(0.2, 0.8, 0.2)
    elseif healthPercent > 0.3 then
        love.graphics.setColor(0.9, 0.7, 0.2)
    else
        love.graphics.setColor(0.9, 0.2, 0.2)
    end
    
    love.graphics.rectangle("fill", ui.padding, ui.padding, currentWidth, ui.healthBarHeight)
    
    -- draw health bar bordr
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", ui.padding, ui.padding, ui.healthBarWidth, ui.healthBarHeight)
    
    -- draw helth text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Health: " .. math.floor(health) .. "/100", ui.padding + 5, ui.padding + 5)
    
    -- draw energy bar (NEW)
    local energyY = ui.padding + ui.healthBarHeight + 5
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", ui.padding, energyY, ui.energyBarWidth, ui.energyBarHeight)
    
    local energyPercent = energy / 100
    local energyWidth = ui.energyBarWidth * energyPercent
    love.graphics.setColor(0.2, 0.5, 1.0)
    love.graphics.rectangle("fill", ui.padding, energyY, energyWidth, ui.energyBarHeight)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", ui.padding, energyY, ui.energyBarWidth, ui.energyBarHeight)
    love.graphics.print("Energy: " .. math.floor(energy), ui.padding + 5, energyY + 2)
    
    -- draw stats (NEW)
    love.graphics.print("Room: " .. roomCount, ui.padding, 70)
    love.graphics.print("Time: " .. math.floor(timer) .. "s", ui.padding, 85)
    
    -- draw contrls
    love.graphics.print("WASD: Move | Shift: Dash | Q: Switch", ui.padding, 105)
    love.graphics.print("Left Click: Attack | R: Reload | ESC: Pause", ui.padding, 120)
    
    -- draw game over mesage
    if gameOver then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER", 0, 250, 800, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Press R to restart or ESC to quit", 0, 300, 800, "center")
    end
end
