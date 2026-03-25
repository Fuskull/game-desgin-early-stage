-- world.lua
-- procedural room generation system

world = {}

function world.init()
    math.randomseed(os.time())
    world.roomCount = 0
    world.width = 800
    world.height = 600
    enemy.init()  -- initialize turret sprites
    
    -- load wall texture
    love.graphics.setDefaultFilter("nearest", "nearest")
    local success, wallImg = pcall(love.graphics.newImage, "assets/images/cartoon-stone-wall-texture-with-spider-web-for-2d-game-halloween-texture-vector.jpg")
    if success then
        world.wallTexture = wallImg
        world.wallTexture:setWrap("repeat", "repeat")
    else
        world.wallTexture = nil
        print("Warning: wall texture not found")
    end
    
    world.generateRoom()
end

function world.generateRoom()
    world.roomCount = world.roomCount + 1
    
    -- fixed room size for now (easier to see everything)
    world.width = 800
    world.height = 600
    
    -- door position (exit) - hidden until enemies cleared
    world.door = {
        x = world.width - 80,
        y = world.height / 2 - 30,
        width = 60,
        height = 60,
        color = {0.2, 0.8, 0.2},
        visible = false  -- NEW: hidden until room cleared
    }
    
    -- generate walls for cover
    world.walls = {}
    local wallCount = math.random(3, 6)
    for i = 1, wallCount do
        local wall = {
            x = math.random(100, world.width - 200),
            y = math.random(100, world.height - 150),
            width = math.random(60, 120),
            height = math.random(20, 40),
            color = {0.4, 0.4, 0.4}
        }
        table.insert(world.walls, wall)
    end
    
    -- difficulty scaling
    local difficulty = 1 + (world.roomCount * 0.2)
    
    -- clear old enemies
    enemy.list = {}
    enemy.bullets = {}
    hunter.list = {}
    
    -- spawn turrets (stationary shooters)
    local turretCount = math.min(2 + world.roomCount, 5)
    for i = 1, turretCount do
        local ex = math.random(200, world.width - 200)
        local ey = math.random(100, world.height - 100)
        enemy.create(ex, ey, difficulty)
    end
    
    -- spawn hunters with scaled health
    local hunterCount = math.min(math.floor(world.roomCount / 2), 3)
    for i = 1, hunterCount do
        local hx = math.random(300, world.width - 300)
        local hy = math.random(150, world.height - 150)
        local h = hunter.create(hx, hy)
        -- scale hunter health with room count
        h.health = 100 + (world.roomCount - 1) * 30
        h.maxHealth = h.health
    end
end

function world.checkDoorCollision(player)
    if not world.door.visible then return false end  -- can't use if not visible
    
    if player.x < world.door.x + world.door.width and
       player.x + player.width > world.door.x and
       player.y < world.door.y + world.door.height and
       player.y + player.height > world.door.y then
        return true
    end
    return false
end

function world.update()
    -- check if all enemies are dead
    if #enemy.list == 0 and #hunter.list == 0 then
        world.door.visible = true
    end
end

function world.draw()
    -- draw room boundries
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("line", 0, 0, world.width, world.height)
    
    -- draw walls
    if world.walls then
        for i, wall in ipairs(world.walls) do
            if world.wallTexture then
                -- draw textured wall
                love.graphics.setColor(1, 1, 1)
                
                -- create a quad for the wall size
                local quad = love.graphics.newQuad(
                    0, 0, 
                    wall.width, wall.height,
                    world.wallTexture:getWidth(), world.wallTexture:getHeight()
                )
                
                love.graphics.draw(world.wallTexture, quad, wall.x, wall.y)
                
                -- draw border
                love.graphics.setColor(0.3, 0.3, 0.3)
                love.graphics.rectangle("line", wall.x, wall.y, wall.width, wall.height)
            else
                -- fallback: draw solid color walls
                local wallColor = wall.color or {0.4, 0.4, 0.4}
                love.graphics.setColor(wallColor)
                love.graphics.rectangle("fill", wall.x, wall.y, wall.width, wall.height)
                love.graphics.setColor(0.6, 0.6, 0.6)
                love.graphics.rectangle("line", wall.x, wall.y, wall.width, wall.height)
            end
        end
    end
    
    -- draw door (only if visible)
    if world.door and world.door.visible then
        love.graphics.setColor(world.door.color)
        love.graphics.rectangle("fill", world.door.x, world.door.y, world.door.width, world.door.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", world.door.x, world.door.y, world.door.width, world.door.height)
        love.graphics.print("EXIT", world.door.x + 10, world.door.y + 20)
    else
        -- show message where door will be
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        love.graphics.rectangle("line", world.door.x, world.door.y, world.door.width, world.door.height)
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.print("Clear", world.door.x + 8, world.door.y + 15)
        love.graphics.print("Room!", world.door.x + 8, world.door.y + 30)
    end
    
    -- show enemy count
    local totalEnemies = #enemy.list + #hunter.list
    if totalEnemies > 0 then
        love.graphics.setColor(1, 0.5, 0.5)
        love.graphics.print("Enemies: " .. totalEnemies, world.width - 100, 10)
    end
end

function world.checkWallCollision(entity)
    if not world.walls then return false end
    
    for i, wall in ipairs(world.walls) do
        if entity.x < wall.x + wall.width and
           entity.x + entity.width > wall.x and
           entity.y < wall.y + wall.height and
           entity.y + entity.height > wall.y then
            return true, wall
        end
    end
    return false
end
