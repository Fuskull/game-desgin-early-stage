-- boss.lua
-- boss enemy system with two phases

boss = {}
boss.active = false
boss.instance = nil

-- boss phases
boss.PHASE_MELEE_ONLY = 1  -- only takes damage from melee
boss.PHASE_GUN_ONLY = 2    -- only takes damage from gun

function boss.init()
    -- load boss sprite (using turret alive as base, scaled 2x)
    local success, img = pcall(love.graphics.newImage, "assets/images/turret alive.png")
    if success then
        boss.sprite = img
    else
        boss.sprite = nil
        print("Warning: boss sprite not found, using turret alive.png")
    end
end

function boss.create(x, y)
    boss.active = true
    
    boss.instance = {
        x = x,
        y = y,
        width = 70,   -- 2x original size (35 * 2)
        height = 70,  -- 2x original size (35 * 2)
        
        -- health system (much more health than regular enemies)
        health = 500,
        maxHealth = 500,
        
        -- phase system
        currentPhase = boss.PHASE_MELEE_ONLY,
        phaseHealth = 250,  -- switch phase at 50% health
        
        -- movement (faster than regular turrets)
        speed = 120,
        direction = 1,
        minX = x - 150,
        maxX = x + 150,
        
        -- shooting behavior (more aggressive)
        shootTimer = 0,
        shootCooldown = 1.5,  -- shoots faster than turrets
        bulletSpeed = 250,
        bulletDamage = 15,
        range = 400,
        
        color = {1.0, 0.1, 0.1},
        flashTimer = 0,
        scale = 2.4  -- 2x scale for sprite
    }
    
    return boss.instance
end

function boss.update(dt, playerX, playerY)
    if not boss.active or not boss.instance then return end
    
    local b = boss.instance
    
    -- movement (back and forth, faster than regular enemies)
    local oldX = b.x
    b.x = b.x + b.speed * b.direction * dt
    
    -- check wall collision
    if world and world.checkWallCollision then
        local hitWall = world.checkWallCollision(b)
        if hitWall then
            b.x = oldX
            b.direction = -b.direction
        end
    end
    
    -- change direction at boundaries
    if b.x > b.maxX then
        b.direction = -1
        b.x = b.maxX
    elseif b.x < b.minX then
        b.direction = 1
        b.x = b.minX
    end
    
    -- update shoot timer
    b.shootTimer = b.shootTimer + dt
    
    -- check if player in range
    local dx = playerX - (b.x + b.width/2)
    local dy = playerY - (b.y + b.height/2)
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- shoot at player if in range and cooldown ready
    if distance < b.range and b.shootTimer >= b.shootCooldown then
        boss.shoot(b, playerX, playerY)
        b.shootTimer = 0
    end
    
    -- update flash timer
    if b.flashTimer > 0 then
        b.flashTimer = b.flashTimer - dt
    end
    
    -- check phase transition
    if b.health <= b.phaseHealth and b.currentPhase == boss.PHASE_MELEE_ONLY then
        b.currentPhase = boss.PHASE_GUN_ONLY
        -- visual feedback for phase change
        b.flashTimer = 0.5
    end
end

function boss.shoot(b, targetX, targetY)
    -- calculate direction to player
    local dx = targetX - (b.x + b.width/2)
    local dy = targetY - (b.y + b.height/2)
    local length = math.sqrt(dx * dx + dy * dy)
    
    if length > 0 then
        dx = dx / length
        dy = dy / length
    end
    
    -- create bullet (using enemy bullet system)
    local bullet = {
        x = b.x + b.width/2,
        y = b.y + b.height/2,
        vx = dx * b.bulletSpeed,
        vy = dy * b.bulletSpeed,
        width = 8,
        height = 8,
        damage = b.bulletDamage,
        lifetime = 5.0,
        color = {1.0, 0.2, 0.2}  -- red bullets for boss
    }
    
    table.insert(enemy.bullets, bullet)
end

function boss.draw()
    if not boss.active or not boss.instance then return end
    
    local b = boss.instance
    
    -- draw boss sprite
    if boss.sprite then
        -- flash effect based on phase
        if b.flashTimer > 0 then
            love.graphics.setColor(1, 1, 1)
        elseif b.currentPhase == boss.PHASE_MELEE_ONLY then
            love.graphics.setColor(1, 0.3, 0.3)  -- red tint for melee phase
        else
            love.graphics.setColor(0.3, 0.3, 1)  -- blue tint for gun phase
        end
        
        love.graphics.draw(
            boss.sprite,
            b.x + b.width/2,
            b.y + b.height/2,
            0,
            b.scale,
            b.scale,
            boss.sprite:getWidth()/2,
            boss.sprite:getHeight()/2
        )
    else
        -- fallback rectangle
        if b.flashTimer > 0 then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(b.color)
        end
        love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", b.x, b.y, b.width, b.height)
    end
    
    -- draw large health bar above boss
    local healthBarWidth = 200
    local healthBarHeight = 20
    local healthPercent = b.health / b.maxHealth
    
    local barX = 300  -- centered on screen
    local barY = 30
    
    -- background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", barX, barY, healthBarWidth, healthBarHeight)
    
    -- health bar (color changes based on phase)
    if b.currentPhase == boss.PHASE_MELEE_ONLY then
        love.graphics.setColor(1.0, 0.3, 0.3)  -- red for melee phase
    else
        love.graphics.setColor(0.3, 0.5, 1.0)  -- blue for gun phase
    end
    love.graphics.rectangle("fill", barX, barY, healthBarWidth * healthPercent, healthBarHeight)
    
    -- border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", barX, barY, healthBarWidth, healthBarHeight)
    
    -- phase indicator
    local phaseText = b.currentPhase == boss.PHASE_MELEE_ONLY and "MELEE ONLY" or "GUN ONLY"
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("BOSS - " .. phaseText, barX + 5, barY + 3)
    
    -- health text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(math.floor(b.health) .. "/" .. b.maxHealth, barX + 140, barY + 3)
    
    -- draw movement path indicator
    love.graphics.setColor(1, 0.1, 0.1, 0.3)
    love.graphics.line(b.minX, b.y + b.height/2, b.maxX, b.y + b.height/2)
end

function boss.takeDamage(damage, damageType)
    if not boss.active or not boss.instance then return false end
    
    local b = boss.instance
    
    -- check if damage type matches current phase
    if b.currentPhase == boss.PHASE_MELEE_ONLY and damageType ~= "melee" then
        -- show visual feedback that damage was blocked
        b.flashTimer = 0.05
        return false
    elseif b.currentPhase == boss.PHASE_GUN_ONLY and damageType ~= "gun" then
        -- show visual feedback that damage was blocked
        b.flashTimer = 0.05
        return false
    end
    
    -- apply damage
    b.health = b.health - damage
    b.flashTimer = 0.1
    
    if b.health <= 0 then
        boss.active = false
        boss.instance = nil
        return true  -- boss defeted
    end
    
    return false
end

function boss.checkBulletCollision()
    if not boss.active or not boss.instance then return false, 0 end
    
    local b = boss.instance
    
    for i = #weapons.bullets, 1, -1 do
        local bullet = weapons.bullets[i]
        
        if bullet.x > b.x and bullet.x < b.x + b.width and
           bullet.y > b.y and bullet.y < b.y + b.height then
            table.remove(weapons.bullets, i)
            return true, bullet.damage
        end
    end
    
    return false, 0
end

function boss.checkMeleeHit(playerX, playerY, meleeRange)
    if not boss.active or not boss.instance then return false end
    
    local b = boss.instance
    local dx = (b.x + b.width/2) - (playerX + 20)
    local dy = (b.y + b.height/2) - (playerY + 20)
    local distance = math.sqrt(dx * dx + dy * dy)
    
    return distance < meleeRange
end

function boss.clear()
    boss.active = false
    boss.instance = nil
end
