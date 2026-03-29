-- player.lua
-- player system with velocity based movment and anim8 animations

player = {}

function player.load()
    -- load anim8 library
    local success, anim8 = pcall(require, 'libraries/anim8')
    if not success then
        print("Warning: anim8 library not found. animations disabled.")
        player.anim8 = nil
    else
        player.anim8 = anim8
    end
    
    -- set pixel art filter
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- position
    player.x = 100
    player.y = 300
    player.width = 40
    player.height = 40
    
    -- velocity based movment
    player.vx = 0
    player.vy = 0
    player.speed = 200
    
    -- helth system
    player.health = 100
    player.maxHealth = 100
    
    -- energy system
    player.energy = 100
    player.maxEnergy = 100
    player.energyRegen = 15
    
    -- dash ability (CHANGED: now speed boost instead of teleport)
    player.isDashing = false
    player.dashSpeed = 500  -- speed during dash
    player.dashDuration = 0.3  -- how long dash lasts
    player.dashTimer = 0
    player.dashCost = 25
    player.canDash = true
    player.dashCooldown = 0
    player.dashCooldownTime = 1.0
    player.dashDirX = 0
    player.dashDirY = 0
    
    -- damage cooldown
    player.damageCooldown = 0
    player.damageCooldownTime = 1.0
    
    -- animation system with anim8
    player.direction = "down"  -- current facing direction
    player.isMoving = false
    
    -- load new sprite sheet (robocharacter)
    local successRobo, roboSheet = pcall(love.graphics.newImage, "assets/images/robocharacter.png")
    
    if successRobo and player.anim8 then
        player.spriteSheet = roboSheet
        player.spriteWidth = 189
        player.spriteHeight = 209
        
        -- create grid for animations (7 columns, 4 rows)
        player.grid = player.anim8.newGrid(
            player.spriteWidth, 
            player.spriteHeight, 
            roboSheet:getWidth(), 
            roboSheet:getHeight()
        )
        
        -- create animations based on weapon type
        player.animations = {}
        
        -- row 1: gun animations (walking frames 1-5, dashing frames 6-7)
        player.animations.gun = {}
        player.animations.gun.walk = player.anim8.newAnimation(player.grid('1-5', 1), 0.15)
        player.animations.gun.dash = player.anim8.newAnimation(player.grid('6-7', 1), 0.15)
        
        -- row 2: melee/knife animations (walking frames 1-5, dashing frames 6-7)
        player.animations.melee = {}
        player.animations.melee.walk = player.anim8.newAnimation(player.grid('1-5', 2), 0.15)
        player.animations.melee.dash = player.anim8.newAnimation(player.grid('6-7', 2), 0.15)
        
        -- set initial animation
        player.currentAnim = player.animations.melee.walk
    else
        player.spriteSheet = nil
        print("Warning: robocharacter.png not found or anim8 missing.")
    end
    
    -- load sound efect (with error handeling)
    local success, sound = pcall(love.audio.newSource, "assets/sounds/hit.wav", "static")
    if success then
        player.hitSound = sound
    else
        player.hitSound = nil
        print("Warning: hit.wav not found. Sound disabled.")
    end
    
    -- load dash sound
    local success2, sound2 = pcall(love.audio.newSource, "assets/sounds/dash.wav", "static")
    if success2 then
        player.dashSound = sound2
    else
        player.dashSound = nil
    end
    
    -- visual (fallback color)
    player.color = {0.2, 0.6, 1.0}
end

function player.update(dt)
    -- handle dash state
    if player.isDashing then
        player.dashTimer = player.dashTimer - dt
        if player.dashTimer <= 0 then
            player.isDashing = false
        end
    end
    
    -- reset velocity
    player.vx = 0
    player.vy = 0
    player.isMoving = false
    
    -- keyboard input (wasd)
    local inputDirX = 0
    local inputDirY = 0
    
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        inputDirY = -1
        player.direction = "up"
        player.isMoving = true
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        inputDirY = 1
        player.direction = "down"
        player.isMoving = true
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        inputDirX = -1
        player.direction = "left"
        player.isMoving = true
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        inputDirX = 1
        player.direction = "right"
        player.isMoving = true
    end
    
    -- determine movement speed (normal or dashing)
    local currentSpeed = player.speed
    if player.isDashing then
        currentSpeed = player.dashSpeed
        -- use stored dash direction
        inputDirX = player.dashDirX
        inputDirY = player.dashDirY
    end
    
    -- normalize diagonal movement
    local length = math.sqrt(inputDirX * inputDirX + inputDirY * inputDirY)
    if length > 0 then
        player.vx = (inputDirX / length) * currentSpeed
        player.vy = (inputDirY / length) * currentSpeed
    end
    
    -- aply velocity to position
    local newX = player.x + player.vx * dt
    local newY = player.y + player.vy * dt
    
    -- check wall collision before moving
    player.x = newX
    player.y = newY
    
    if world and world.checkWallCollision then
        local hitWall = world.checkWallCollision(player)
        if hitWall then
            -- revert movement
            player.x = player.x - player.vx * dt
            player.y = player.y - player.vy * dt
        end
    end
    
    -- dash ability (CHANGED: now initiates speed boost)
    if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
        if not player.isDashing and player.energy >= player.dashCost and player.dashCooldown <= 0 then
            -- start dash
            if inputDirX ~= 0 or inputDirY ~= 0 then
                player.isDashing = true
                player.dashTimer = player.dashDuration
                player.dashDirX = inputDirX
                player.dashDirY = inputDirY
                player.energy = player.energy - player.dashCost
                player.dashCooldown = player.dashCooldownTime
                
                -- play dash sound
                if player.dashSound then
                    player.dashSound:play()
                end
            end
        end
    end
    
    -- energy regeneration
    player.energy = math.min(player.energy + player.energyRegen * dt, player.maxEnergy)
    
    -- update dash cooldown
    if player.dashCooldown > 0 then
        player.dashCooldown = player.dashCooldown - dt
    end
    
    -- screen boundries
    if player.x < 0 then player.x = 0 end
    if player.x + player.width > 800 then player.x = 800 - player.width end
    if player.y < 0 then player.y = 0 end
    if player.y + player.height > 600 then player.y = 600 - player.height end
    
    -- update damage cooldown
    if player.damageCooldown > 0 then
        player.damageCooldown = player.damageCooldown - dt
    end
    
    -- update animation based on weapon type
    if player.animations then
        -- choose animation set based on current weapon
        local animSet = nil
        if weapons and weapons.currentWeapon == weapons.MELEE then
            animSet = player.animations.melee
        else
            animSet = player.animations.gun
        end
        
        -- update current animation based on state
        if animSet then
            if player.isDashing then
                player.currentAnim = animSet.dash
                player.currentAnim:update(dt)
            elseif player.isMoving then
                player.currentAnim = animSet.walk
                player.currentAnim:update(dt)
            else
                -- idle frame (frame 1 for standing pose)
                player.currentAnim = animSet.walk
                player.currentAnim:gotoFrame(1)
            end
        end
    end
end

function player.draw()
    if player.currentAnim and player.spriteSheet then
        -- draw sprite animation using anim8
        love.graphics.setColor(1, 1, 1)
        
        -- add dash effect (slight transparency trail)
        if player.isDashing then
            love.graphics.setColor(1, 1, 1, 0.7)
        end
        
        -- draw with anim8 (scale down for proper size)
        local scale = 0.25  -- scale factor to make sprite fit (189px -> ~47px)
        player.currentAnim:draw(
            player.spriteSheet,
            player.x + player.width/2,
            player.y + player.height/2,
            nil,  -- rotation
            scale,  -- scale x
            scale,  -- scale y
            player.spriteWidth / 2,  -- origin x (center)
            player.spriteHeight / 2  -- origin y (center)
        )
        
        -- draw dash trail effect
        if player.isDashing then
            love.graphics.setColor(0.2, 0.6, 1.0, 0.3)
            love.graphics.circle("fill", player.x + player.width/2, player.y + player.height/2, player.width/2 + 5)
        end
    else
        -- fallback: draw player rectange
        love.graphics.setColor(player.color)
        love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
        
        -- draw player border
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", player.x, player.y, player.width, player.height)
        
        -- dash effect for rectangle
        if player.isDashing then
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.circle("line", player.x + player.width/2, player.y + player.height/2, player.width/2 + 10)
        end
    end
end

function player.takeDamage(amount)
    -- only take damge if cooldown expired
    if player.damageCooldown <= 0 then
        player.health = player.health - amount
        if player.health < 0 then
            player.health = 0
        end
        player.damageCooldown = player.damageCooldownTime
    end
end
