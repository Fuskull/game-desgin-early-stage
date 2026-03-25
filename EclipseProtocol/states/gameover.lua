-- states/gameover.lua
-- game over state

local gameover = {}
local playState

function gameover.enter()
    playState = stateManager.states["play"]
    
    -- load game over sound
    local success, sound = pcall(love.audio.newSource, "assets/sounds/gameover.wav", "static")
    if success then
        sound:play()
    end
end

function gameover.update(dt)
    -- no updates
end

function gameover.draw()
    -- draw game in backround
    if playState then
        playState.draw()
    end
    
    -- draw overlay
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf("GAME OVER", 0, 200, 800, "center")
    
    love.graphics.setColor(1, 1, 1)
    if playState then
        love.graphics.printf("Rooms Cleared: " .. (world.roomCount or 0), 0, 260, 800, "center")
        love.graphics.printf("Time Survived: " .. math.floor(playState.gameTimer or 0) .. "s", 0, 280, 800, "center")
    end
    
    love.graphics.printf("Press R to restart", 0, 340, 800, "center")
    love.graphics.printf("Press ESC to return to menu", 0, 370, 800, "center")
end

function gameover.keypressed(key)
    if key == "r" then
        stateManager.switch("play")
        stateManager.states["play"].enter()
    elseif key == "escape" then
        stateManager.switch("menu")
    end
end

function gameover.exit()
    -- cleanup
end

return gameover
