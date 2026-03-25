-- states/developer.lua
-- level creator / developer mode

local developer = {}

function developer.enter()
    -- initialize level editor
    developer.gridSize = 40
    developer.cameraX = 0
    developer.cameraY = 0
    developer.roomWidth = 800
    developer.roomHeight = 600
    
    -- editor state
    developer.selectedTool = "wall"  -- wall, enemy, hunter, spawn, exit
    developer.tools = {"wall", "enemy", "hunter", "spawn", "exit", "erase"}
    developer.currentToolIndex = 1
    
    -- level data
    developer.walls = {}
    developer.enemies = {}
    developer.hunters = {}
    developer.spawnPoint = {x = 100, y = 300}
    developer.exitDoor = {x = 700, y = 300, width = 50, height = 80}
    
    -- ui state
    developer.showHelp = true
    developer.gridSnap = true
    developer.isPainting = false
    
    -- load default level if exists
    developer.levelName = "custom_level"
end

function developer.update(dt)
    -- camera movement with arrow keys
    local camSpeed = 300
    if love.keyboard.isDown("up") then
        developer.cameraY = developer.cameraY - camSpeed * dt
    end
    if love.keyboard.isDown("down") then
        developer.cameraY = developer.cameraY + camSpeed * dt
    end
    if love.keyboard.isDown("left") then
        developer.cameraX = developer.cameraX - camSpeed * dt
    end
    if love.keyboard.isDown("right") then
        developer.cameraX = developer.cameraX + camSpeed * dt
    end
    
    -- mouse painting
    if love.mouse.isDown(1) then
        developer.isPainting = true
        local mx, my = love.mouse.getPosition()
        mx = mx + developer.cameraX
        my = my + developer.cameraY
        
        if developer.gridSnap then
            mx = math.floor(mx / developer.gridSize) * developer.gridSize
            my = math.floor(my / developer.gridSize) * developer.gridSize
        end
        
        developer.placeTool(mx, my)
    else
        developer.isPainting = false
    end
end

function developer.placeTool(x, y)
    local tool = developer.tools[developer.currentToolIndex]
    
    if tool == "wall" then
        -- check if wall already exists at this position
        local exists = false
        for i, wall in ipairs(developer.walls) do
            if wall.x == x and wall.y == y then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(developer.walls, {
                x = x,
                y = y,
                width = developer.gridSize,
                height = developer.gridSize
            })
        end
        
    elseif tool == "enemy" then
        -- check if enemy already exists nearby
        local exists = false
        for i, e in ipairs(developer.enemies) do
            if math.abs(e.x - x) < 20 and math.abs(e.y - y) < 20 then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(developer.enemies, {x = x, y = y})
        end
        
    elseif tool == "hunter" then
        local exists = false
        for i, h in ipairs(developer.hunters) do
            if math.abs(h.x - x) < 20 and math.abs(h.y - y) < 20 then
                exists = true
                break
            end
        end
        if not exists then
            table.insert(developer.hunters, {x = x, y = y})
        end
        
    elseif tool == "spawn" then
        developer.spawnPoint.x = x
        developer.spawnPoint.y = y
        
    elseif tool == "exit" then
        developer.exitDoor.x = x
        developer.exitDoor.y = y
        
    elseif tool == "erase" then
        -- remove walls
        for i = #developer.walls, 1, -1 do
            local wall = developer.walls[i]
            if math.abs(wall.x - x) < developer.gridSize and math.abs(wall.y - y) < developer.gridSize then
                table.remove(developer.walls, i)
            end
        end
        -- remove enemies
        for i = #developer.enemies, 1, -1 do
            local e = developer.enemies[i]
            if math.abs(e.x - x) < 40 and math.abs(e.y - y) < 40 then
                table.remove(developer.enemies, i)
            end
        end
        -- remove hunters
        for i = #developer.hunters, 1, -1 do
            local h = developer.hunters[i]
            if math.abs(h.x - x) < 40 and math.abs(h.y - y) < 40 then
                table.remove(developer.hunters, i)
            end
        end
    end
end

function developer.draw()
    love.graphics.push()
    love.graphics.translate(-developer.cameraX, -developer.cameraY)
    
    -- draw grid
    if developer.gridSnap then
        love.graphics.setColor(0.2, 0.2, 0.2, 0.3)
        for x = 0, developer.roomWidth, developer.gridSize do
            love.graphics.line(x, 0, x, developer.roomHeight)
        end
        for y = 0, developer.roomHeight, developer.gridSize do
            love.graphics.line(0, y, developer.roomWidth, y)
        end
    end
    
    -- draw room boundary
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("line", 0, 0, developer.roomWidth, developer.roomHeight)
    
    -- draw walls
    love.graphics.setColor(0.5, 0.5, 0.5)
    for i, wall in ipairs(developer.walls) do
        love.graphics.rectangle("fill", wall.x, wall.y, wall.width, wall.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", wall.x, wall.y, wall.width, wall.height)
        love.graphics.setColor(0.5, 0.5, 0.5)
    end
    
    -- draw enemies
    love.graphics.setColor(1, 0.3, 0.3)
    for i, e in ipairs(developer.enemies) do
        love.graphics.rectangle("fill", e.x, e.y, 35, 35)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("E", e.x + 10, e.y + 10)
        love.graphics.setColor(1, 0.3, 0.3)
    end
    
    -- draw hunters
    love.graphics.setColor(1, 0.5, 0)
    for i, h in ipairs(developer.hunters) do
        love.graphics.rectangle("fill", h.x, h.y, 40, 40)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("H", h.x + 12, h.y + 12)
        love.graphics.setColor(1, 0.5, 0)
    end
    
    -- draw spawn point
    love.graphics.setColor(0.2, 1, 0.2)
    love.graphics.circle("fill", developer.spawnPoint.x, developer.spawnPoint.y, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SPAWN", developer.spawnPoint.x - 20, developer.spawnPoint.y - 30)
    
    -- draw exit door
    love.graphics.setColor(0.2, 0.8, 0.2)
    love.graphics.rectangle("fill", developer.exitDoor.x, developer.exitDoor.y, developer.exitDoor.width, developer.exitDoor.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("EXIT", developer.exitDoor.x + 5, developer.exitDoor.y + 30)
    
    -- draw cursor preview
    local mx, my = love.mouse.getPosition()
    mx = mx + developer.cameraX
    my = my + developer.cameraY
    if developer.gridSnap then
        mx = math.floor(mx / developer.gridSize) * developer.gridSize
        my = math.floor(my / developer.gridSize) * developer.gridSize
    end
    
    local tool = developer.tools[developer.currentToolIndex]
    love.graphics.setColor(1, 1, 1, 0.5)
    if tool == "wall" then
        love.graphics.rectangle("line", mx, my, developer.gridSize, developer.gridSize)
    elseif tool == "enemy" then
        love.graphics.rectangle("line", mx, my, 35, 35)
    elseif tool == "hunter" then
        love.graphics.rectangle("line", mx, my, 40, 40)
    elseif tool == "spawn" or tool == "exit" then
        love.graphics.circle("line", mx, my, 15)
    elseif tool == "erase" then
        love.graphics.line(mx - 10, my - 10, mx + 10, my + 10)
        love.graphics.line(mx - 10, my + 10, mx + 10, my - 10)
    end
    
    love.graphics.pop()
    
    -- draw ui overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 800, 80)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("DEVELOPER MODE - Level Creator", 10, 10)
    love.graphics.print("Tool: " .. tool:upper(), 10, 30)
    love.graphics.print("Walls: " .. #developer.walls .. " | Enemies: " .. #developer.enemies .. " | Hunters: " .. #developer.hunters, 10, 50)
    
    -- draw controls
    if developer.showHelp then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 550, 0, 250, 600)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("CONTROLS:", 560, 10)
        love.graphics.print("TAB - Switch tool", 560, 30)
        love.graphics.print("Left Click - Place", 560, 50)
        love.graphics.print("Arrow Keys - Move camera", 560, 70)
        love.graphics.print("G - Toggle grid", 560, 90)
        love.graphics.print("H - Toggle help", 560, 110)
        love.graphics.print("T - Test level", 560, 130)
        love.graphics.print("S - Save level", 560, 150)
        love.graphics.print("L - Load level", 560, 170)
        love.graphics.print("C - Clear all", 560, 190)
        love.graphics.print("ESC - Back to menu", 560, 210)
        
        love.graphics.print("TOOLS:", 560, 240)
        love.graphics.print("1. Wall", 560, 260)
        love.graphics.print("2. Enemy (patrol)", 560, 280)
        love.graphics.print("3. Hunter (AI)", 560, 300)
        love.graphics.print("4. Spawn point", 560, 320)
        love.graphics.print("5. Exit door", 560, 340)
        love.graphics.print("6. Erase", 560, 360)
    end
end

function developer.keypressed(key)
    if key == "escape" then
        stateManager.switch("menu")
        
    elseif key == "tab" then
        -- cycle through tools
        developer.currentToolIndex = developer.currentToolIndex + 1
        if developer.currentToolIndex > #developer.tools then
            developer.currentToolIndex = 1
        end
        
    elseif key == "g" then
        developer.gridSnap = not developer.gridSnap
        
    elseif key == "h" then
        developer.showHelp = not developer.showHelp
        
    elseif key == "c" then
        -- clear all
        developer.walls = {}
        developer.enemies = {}
        developer.hunters = {}
        
    elseif key == "t" then
        -- test level
        developer.testLevel()
        
    elseif key == "s" then
        -- save level
        developer.saveLevel()
        
    elseif key == "l" then
        -- load level
        developer.loadLevel()
        
    -- number keys for quick tool selection
    elseif key == "1" then developer.currentToolIndex = 1
    elseif key == "2" then developer.currentToolIndex = 2
    elseif key == "3" then developer.currentToolIndex = 3
    elseif key == "4" then developer.currentToolIndex = 4
    elseif key == "5" then developer.currentToolIndex = 5
    elseif key == "6" then developer.currentToolIndex = 6
    end
end

function developer.testLevel()
    -- load the custom level into the game
    developer.applyLevelToGame()
    stateManager.switch("play")
end

function developer.applyLevelToGame()
    -- this will be called before switching to play state
    -- store level data globally so play state can use it
    _G.customLevel = {
        walls = developer.walls,
        enemies = developer.enemies,
        hunters = developer.hunters,
        spawnPoint = developer.spawnPoint,
        exitDoor = developer.exitDoor
    }
end

function developer.saveLevel()
    -- save level to file
    local data = {
        walls = developer.walls,
        enemies = developer.enemies,
        hunters = developer.hunters,
        spawnPoint = developer.spawnPoint,
        exitDoor = developer.exitDoor
    }
    
    local serialized = developer.serialize(data)
    local success = love.filesystem.write(developer.levelName .. ".lua", serialized)
    
    if success then
        print("Level saved: " .. developer.levelName .. ".lua")
    else
        print("Failed to save level")
    end
end

function developer.loadLevel()
    -- load level from file
    local success, chunk = pcall(love.filesystem.load, developer.levelName .. ".lua")
    if success and chunk then
        local data = chunk()
        developer.walls = data.walls or {}
        developer.enemies = data.enemies or {}
        developer.hunters = data.hunters or {}
        developer.spawnPoint = data.spawnPoint or {x = 100, y = 300}
        developer.exitDoor = data.exitDoor or {x = 700, y = 300, width = 50, height = 80}
        print("Level loaded: " .. developer.levelName .. ".lua")
    else
        print("Failed to load level or file not found")
    end
end

function developer.serialize(tbl, indent)
    indent = indent or 0
    local result = "{\n"
    local indentStr = string.rep("  ", indent + 1)
    
    for k, v in pairs(tbl) do
        result = result .. indentStr
        if type(k) == "string" then
            result = result .. k .. " = "
        end
        
        if type(v) == "table" then
            result = result .. developer.serialize(v, indent + 1)
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '"'
        else
            result = result .. tostring(v)
        end
        result = result .. ",\n"
    end
    
    result = result .. string.rep("  ", indent) .. "}"
    return result
end

function developer.exit()
    -- cleanup
end

return developer
