-- enemy.lua
-- turret enemy system (stationary, shoots bullets)

enemy = {}
enemy.list = {}
enemy.bullets = {}

function enemy.init()
    -- load turret sprites
    local successAlive, aliveImg = pcall(love.graphics.newImage, "assets/images/turret alive.png")
    local successDead, deadImg = pcall(love.graphics.newImage, "assets/images/turret dead.png")
    
    if successAlive then
        enemy.spriteAlive = aliveImg
    else
        enemy.spriteAlive = nil
        print("Warning: turret alive.png not found")
    end
    
    if successDead then
        enemy.spriteDead = deadImg
    else
        enemy.spriteDead = nil
        print("Warning: turret dead.png not found")
    end
end

function enemy.create(x, y, difficulty)
    difficulty = difficulty or 1
    
    local e = {
        x = x,
        y = y,
        width = 35,
        height = 35,
        
        -- health system
        health = 50 + (difficulty - 1) * 20,
        maxHealth = 50 + (difficulty - 1) * 20,
        
        -- movement (back and forth on fixed path)
        speed = 80 * difficulty,
        direction = 1,
        minX = x - 100,
        maxX = x + 100,
        
        -- turret behavior (shoots while moving)
        shootTimer = 0,
        shootCooldown = 2.0,  -- shoots every 2 seconds
        bulletSpeed = 200,
        bulletDamage = 10,
        range = 300,  -- detection range
        
        -- state
        isAlive = true,
        
        -- visual
        color = {1.0, 0.3, 0.3},
        flashTimer = 0
    }
    
    table.insert(enemy.list, e)
    return e
end

function enemy.updateAll(dt, playerX, playerY)
    -- update turrets
    for i, e in ipairs(enemy.list) do
        if e.isAlive then
            -- movement (back and forth on fixed path)
            local oldX = e.x
            e.x = e.x + e.speed * e.direction * dt
            
            -- check wall collision
            if world and world.checkWallCollision then
                local hitWall = world.checkWallCollision(e)
                if hitWall then
                    e.x = oldX
                    e.direction = -e.direction
                end
            end
            
            -- change direction at boundaries
            if e.x > e.maxX then
                e.direction = -1
                e.x = e.maxX
            elseif e.x < e.minX then
                e.direction = 1
                e.x = e.minX
            end
            
            -- update shoot timer
            e.shootTimer = e.shootTimer + dt
            
            -- check if player in range
            local dx = playerX - (e.x + e.width/2)
            local dy = playerY - (e.y + e.height/2)
            local distance = math.sqrt(dx * dx + dy * dy)
            
            -- shoot at player if in range and cooldown ready
            if distance < e.range and e.shootTimer >= e.shootCooldown then
                enemy.shoot(e, playerX, playerY)
                e.shootTimer = 0
            end
        end
        
        -- update flash timer
        if e.flashTimer > 0 then
            e.flashTimer = e.flashTimer - dt
        end
    end
    
    -- update bullets
    for i = #enemy.bullets, 1, -1 do
        local bullet = enemy.bullets[i]
        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt
        bullet.lifetime = bullet.lifetime - dt
        
        -- remove if expired or out of bounds
        if bullet.lifetime <= 0 or bullet.x < 0 or bullet.x > 800 or bullet.y < 0 or bullet.y > 600 then
            table.remove(enemy.bullets, i)
        end
    end
end

function enemy.shoot(turret, targetX, targetY)
    -- calculate direction to player
    local dx = targetX - (turret.x + turret.width/2)
    local dy = targetY - (turret.y + turret.height/2)
    local length = math.sqrt(dx * dx + dy * dy)
    
    if length > 0 then
        dx = dx / length
        dy = dy / length
    end
    
    -- create bullet
    local bullet = {
        x = turret.x + turret.width/2,
        y = turret.y + turret.height/2,
        vx = dx * turret.bulletSpeed,
        vy = dy * turret.bulletSpeed,
        width = 6,
        height = 6,
        damage = turret.bulletDamage,
        lifetime = 5.0,
        color = {1.0, 0.5, 0.0}
    }
    
    table.insert(enemy.bullets, bullet)
end

function enemy.drawAll()
    -- draw turrets
    for i, e in ipairs(enemy.list) do
        if e.isAlive then
            -- draw alive turret
            if enemy.spriteAlive then
                -- flash white when damaged
                if e.flashTimer > 0 then
                    love.graphics.setColor(1, 1, 1)
                else
                    love.graphics.setColor(1, 1, 1)
                end
                
                local scale = 1.2  -- smaller scale
                love.graphics.draw(
                    enemy.spriteAlive,
                    e.x + e.width/2,
                    e.y + e.height/2,
                    0,
                    scale,
                    scale,
                    enemy.spriteAlive:getWidth()/2,
                    enemy.spriteAlive:getHeight()/2
                )
            else
                -- fallback rectangle
                if e.flashTimer > 0 then
                    love.graphics.setColor(1, 1, 1)
                else
                    love.graphics.setColor(e.color)
                end
                love.graphics.rectangle("fill", e.x, e.y, e.width, e.height)
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("line", e.x, e.y, e.width, e.height)
            end
            
            -- draw health bar
            local healthBarWidth = e.width
            local healthBarHeight = 4
            local healthPercent = e.health / e.maxHealth
            
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", e.x, e.y - 8, healthBarWidth, healthBarHeight)
            
            love.graphics.setColor(1.0, 0.0, 0.0)
            love.graphics.rectangle("fill", e.x, e.y - 8, healthBarWidth * healthPercent, healthBarHeight)
            
            -- draw movement path indicator
            love.graphics.setColor(1, 0.3, 0.3, 0.2)
            love.graphics.line(e.minX, e.y + e.height/2, e.maxX, e.y + e.height/2)
        else
            -- draw dead turret
            if enemy.spriteDead then
                love.graphics.setColor(1, 1, 1, 0.7)
                local scale = 1.2  -- smaller scale
                love.graphics.draw(
                    enemy.spriteDead,
                    e.x + e.width/2,
                    e.y + e.height/2,
                    0,
                    scale,
                    scale,
                    enemy.spriteDead:getWidth()/2,
                    enemy.spriteDead:getHeight()/2
                )
            else
                -- fallback
                love.graphics.setColor(0.3, 0.3, 0.3)
                love.graphics.rectangle("fill", e.x, e.y, e.width, e.height)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print("X", e.x + 12, e.y + 10)
            end
        end
    end
    
    -- draw bullets
    for i, bullet in ipairs(enemy.bullets) do
        love.graphics.setColor(bullet.color)
        love.graphics.circle("fill", bullet.x, bullet.y, 3)
    end
end

function enemy.takeDamage(turret, damage)
    if not turret.isAlive then return true end
    
    turret.health = turret.health - damage
    turret.flashTimer = 0.1
    
    if turret.health <= 0 then
        turret.isAlive = false
        return true
    end
    return false
end

function enemy.checkBulletCollision(player)
    for i = #enemy.bullets, 1, -1 do
        local bullet = enemy.bullets[i]
        
        if bullet.x > player.x and bullet.x < player.x + player.width and
           bullet.y > player.y and bullet.y < player.y + player.height then
            table.remove(enemy.bullets, i)
            return true, bullet.damage
        end
    end
    return false, 0
end

function enemy.clear()
    enemy.list = {}
    enemy.bullets = {}
end
