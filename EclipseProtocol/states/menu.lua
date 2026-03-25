-- states/menu.lua
-- main menu state

local menu = {}

function menu.enter()
    -- setup menu
end

function menu.update(dt)
    -- menu logic
end

function menu.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("ECLIPSE PROTOCOL", 0, 150, 800, "center")
    love.graphics.printf("Phase 2 - Final Version", 0, 180, 800, "center")
    
    love.graphics.printf("Press SPACE to Start", 0, 280, 800, "center")
    love.graphics.printf("Press D for Developer Mode", 0, 310, 800, "center")
    love.graphics.printf("Press ESC to Quit", 0, 340, 800, "center")
    
    love.graphics.printf("Objective: Survive and reach the exit door", 0, 400, 800, "center")
    love.graphics.printf("Avoid enemies and use dash (Shift) wisely", 0, 420, 800, "center")
end

function menu.keypressed(key)
    if key == "space" then
        stateManager.switch("play")
    elseif key == "d" then
        stateManager.switch("developer")
    elseif key == "escape" then
        love.event.quit()
    end
end

function menu.exit()
    -- cleanup
end

return menu
