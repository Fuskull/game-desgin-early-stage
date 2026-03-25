-- hunter.lua
-- hunter enemy with fsm ai

hunter = {}
hunter.list = {}

-- fsm states
hunter.STATE_IDLE = "idle"
hunter.STATE_PATROL = "patrol"
hunter.STATE_CHASE = "chase"
hunter.STATE_RETURN = "return"

function hunter.create(x, y)
    local h = {
        x = x,
        y = y,
        width = 40,
        height = 40,
        
        -- health system (NEW)
        health = 100,
        maxHealth = 100,
        
        -- movement
        speed = 120,
        chaseSpeed = 180,
        vx = 0,
        vy = 0,
        
        -- fsm
        state = hunter.STATE_PATROL,
        stateTimer = 0,
        
        -- patrol
        patrolPoints = {
            {x = x - 100, y = y},
            {x = x + 100, y = y}
        },
        currentPoint = 1,
        
        -- detection
        detectionRange = 200,
        loseRange = 300,
        
        -- spawn point for return
        spawnX = x,
        spawnY = y,
        
        -- visual
        color = {1.0, 0.5, 0.0},
        
        -- damage flash
        flashTimer = 0
    }
    
    table.insert(hunter.list, h)
    return h
end

function hunter.updateAll(dt, playerX, playerY)
    for i, h in ipairs(hunter.list) do
        hunter.updateOne(h, dt, playerX, playerY)
    end
end

function hunter.updateOne(h, dt, playerX, playerY)
    h.stateTimer = h.stateTimer + dt
    
    -- update flash timer
    if h.flashTimer > 0 then
        h.flashTimer = h.flashTimer - dt
    end
    
    -- calculate distance to player
    local dx = playerX - h.x
    local dy = playerY - h.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- fsm logic
    if h.state == hunter.STATE_IDLE then
        if h.stateTimer > 1.0 then
            h.state = hunter.STATE_PATROL
            h.stateTimer = 0
        end
        
    elseif h.state == hunter.STATE_PATROL then
        -- check if player detected
        if distance < h.detectionRange then
            h.state = hunter.STATE_CHASE
            h.stateTimer = 0
        else
            -- patrol movment
            local target = h.patrolPoints[h.currentPoint]
            local tdx = target.x - h.x
            local tdy = target.y - h.y
            local tdist = math.sqrt(tdx * tdx + tdy * tdy)
            
            if tdist < 10 then
                -- reached patrol point
                h.currentPoint = h.currentPoint + 1
                if h.currentPoint > #h.patrolPoints then
                    h.currentPoint = 1
                end
            else
                -- store old position
                local oldX = h.x
                local oldY = h.y
                
                -- move toward patrol point
                h.x = h.x + (tdx / tdist) * h.speed * dt
                h.y = h.y + (tdy / tdist) * h.speed * dt
                
                -- check wall collision
                if world and world.checkWallCollision then
                    local hitWall = world.checkWallCollision(h)
                    if hitWall then
                        h.x = oldX
                        h.y = oldY
                    end
                end
            end
        end
        
    elseif h.state == hunter.STATE_CHASE then
        -- check if player escaped
        if distance > h.loseRange then
            h.state = hunter.STATE_RETURN
            h.stateTimer = 0
        else
            -- store old position
            local oldX = h.x
            local oldY = h.y
            
            -- chase player
            local length = math.sqrt(dx * dx + dy * dy)
            if length > 0 then
                h.x = h.x + (dx / length) * h.chaseSpeed * dt
                h.y = h.y + (dy / length) * h.chaseSpeed * dt
            end
            
            -- check wall collision
            if world and world.checkWallCollision then
                local hitWall = world.checkWallCollision(h)
                if hitWall then
                    h.x = oldX
                    h.y = oldY
                end
            end
        end
        
    elseif h.state == hunter.STATE_RETURN then
        -- return to spawn
        local sdx = h.spawnX - h.x
        local sdy = h.spawnY - h.y
        local sdist = math.sqrt(sdx * sdx + sdy * sdy)
        
        if sdist < 10 then
            h.state = hunter.STATE_PATROL
            h.stateTimer = 0
        else
            -- store old position
            local oldX = h.x
            local oldY = h.y
            
            h.x = h.x + (sdx / sdist) * h.speed * dt
            h.y = h.y + (sdy / sdist) * h.speed * dt
            
            -- check wall collision
            if world and world.checkWallCollision then
                local hitWall = world.checkWallCollision(h)
                if hitWall then
                    h.x = oldX
                    h.y = oldY
                end
            end
        end
    end
end

function hunter.drawAll()
    for i, h in ipairs(hunter.list) do
        hunter.drawOne(h)
    end
end

function hunter.drawOne(h)
    -- flash white when damaged
    if h.flashTimer > 0 then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(h.color)
    end
    love.graphics.rectangle("fill", h.x, h.y, h.width, h.height)
    
    -- draw border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", h.x, h.y, h.width, h.height)
    
    -- draw health bar
    local healthBarWidth = h.width
    local healthBarHeight = 5
    local healthPercent = h.health / h.maxHealth
    
    -- background
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", h.x, h.y - 10, healthBarWidth, healthBarHeight)
    
    -- health
    love.graphics.setColor(1.0, 0.5, 0.0)
    love.graphics.rectangle("fill", h.x, h.y - 10, healthBarWidth * healthPercent, healthBarHeight)
    
    -- draw state indicator
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.print(h.state, h.x, h.y - 20)
    
    -- draw detection range (debug)
    love.graphics.setColor(1, 0.5, 0, 0.2)
    love.graphics.circle("line", h.x + h.width/2, h.y + h.height/2, h.detectionRange)
end

function hunter.takeDamage(hunter, damage)
    hunter.health = hunter.health - damage
    hunter.flashTimer = 0.1
    return hunter.health <= 0
end

function hunter.clear()
    hunter.list = {}
end
