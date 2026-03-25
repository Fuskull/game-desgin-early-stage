-- states/victory.lua
-- victory state

local victory = {}
local playState

function victory.enter()
    playState = stateManager.states["play"]
    
    -- load victory sound
    local success, sound = pcall(love.audio.newSource, "assets/sounds/Victory Sound Effect.mp3", "static")
    if success then
        sound:play()
    else
        print("Warning: Victory sound not found")
    end
end

function victory.update(dt)
    -- no updates
end

function victory.draw()
    -- draw game in backround
    if playState then
        playState.draw()
    end
    
    -- draw overlay
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf("VICTORY!", 0, 200, 800, "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("You survived the Eclipse Protocol!", 0, 240, 800, "center")
    
    if playState then
        love.graphics.printf("Rooms Cleared: " .. (world.roomCount or 0), 0, 280, 800, "center")
        love.graphics.printf("Time: " .. math.floor(playState.gameTimer or 0) .. "s", 0, 300, 800, "center")
    end
    
    love.graphics.printf("Press R to play again", 0, 360, 800, "center")
    love.graphics.printf("Press ESC to return to menu", 0, 390, 800, "center")
end

function victory.keypressed(key)
    if key == "r" then
        stateManager.switch("play")
        stateManager.states["play"].enter()
    elseif key == "escape" then
        stateManager.switch("menu")
    end
end

function victory.exit()
    -- cleanup
end

return victory
