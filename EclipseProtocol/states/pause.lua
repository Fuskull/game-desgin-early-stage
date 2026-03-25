-- states/pause.lua
-- pause state

local pause = {}
local playState

function pause.enter()
    -- store reference to play state
    playState = stateManager.states["play"]
end

function pause.update(dt)
    -- dont update game
end

function pause.draw()
    -- draw game in background
    if playState then
        playState.draw()
    end
    
    -- draw pause overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("PAUSED", 0, 250, 800, "center")
    love.graphics.printf("Press ESC to resume", 0, 300, 800, "center")
    love.graphics.printf("Press R to restart", 0, 330, 800, "center")
end

function pause.keypressed(key)
    if key == "escape" then
        stateManager.switch("play")
    elseif key == "r" then
        stateManager.switch("play")
        stateManager.states["play"].enter()
    end
end

function pause.exit()
    -- cleanup
end

return pause
