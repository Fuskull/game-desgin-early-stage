-- main.lua
-- game loop with state managment system

-- import modules
require("player")
require("enemy")
require("hunter")
require("ui")
require("world")
require("weapons")
require("pickups")
require("progression")
require("stateManager")

function love.load()
    -- window setup
    love.window.setTitle("Eclipse Protocol - Phase 2")
    love.window.setMode(800, 600)
    
    -- register all game states
    stateManager.register("menu", require("states.menu"))
    stateManager.register("play", require("states.play"))
    stateManager.register("pause", require("states.pause"))
    stateManager.register("gameover", require("states.gameover"))
    stateManager.register("victory", require("states.victory"))
    stateManager.register("developer", require("states.developer"))
    
    -- start with menu
    stateManager.switch("menu")
end

function love.update(dt)
    stateManager.update(dt)
end

function love.draw()
    stateManager.draw()
end

function love.keypressed(key)
    stateManager.keypressed(key)
end

function love.mousepressed(x, y, button)
    if stateManager.current and stateManager.current.mousepressed then
        stateManager.current.mousepressed(x, y, button)
    end
end
