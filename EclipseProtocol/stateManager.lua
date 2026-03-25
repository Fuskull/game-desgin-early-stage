-- stateManager.lua
-- game state managment system

stateManager = {}
stateManager.states = {}
stateManager.current = nil

function stateManager.switch(stateName)
    -- unload current state
    if stateManager.current and stateManager.current.exit then
        stateManager.current.exit()
    end
    
    -- switch to new state
    stateManager.current = stateManager.states[stateName]
    
    -- load new state
    if stateManager.current and stateManager.current.enter then
        stateManager.current.enter()
    end
end

function stateManager.register(name, state)
    stateManager.states[name] = state
end

function stateManager.update(dt)
    if stateManager.current and stateManager.current.update then
        stateManager.current.update(dt)
    end
end

function stateManager.draw()
    if stateManager.current and stateManager.current.draw then
        stateManager.current.draw()
    end
end

function stateManager.keypressed(key)
    if stateManager.current and stateManager.current.keypressed then
        stateManager.current.keypressed(key)
    end
end
