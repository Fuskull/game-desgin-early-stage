-- pickups.lua
-- health packs, ammo, and xp drops

pickups = {}
pickups.list = {}

-- pickup types
pickups.TYPE_HEALTH_SMALL = "health_small"
pickups.TYPE_HEALTH_LARGE = "health_large"
pickups.TYPE_AMMO = "ammo"
pickups.TYPE_XP = "xp"

function pickups.init()
    pickups.list = {}
    
    -- set pixel art filter
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- load pickup sprites
    local successHealth, healthImg = pcall(love.graphics.newImage, "assets/images/health.png")
    if successHealth then
        pickups.healthSprite = healthImg
    else
        pickups.healthSprite = nil
        print("Warning: health.png not found")
    end
    
    local successAmmo, ammoImg = pcall(love.graphics.newImage, "assets/images/ammo pack.png")
    if successAmmo then
        pickups.ammoSprite = ammoImg
    else
        pickups.ammoSprite = nil
        print("Warning: ammo pack.png not found")
    end
    
    local successCoin, coinImg = pcall(love.graphics.newImage, "assets/images/coin.png")
    if successCoin then
        pickups.coinSprite = coinImg
    else
        pickups.coinSprite = nil
        print("Warning: coin.png not found")
    end
end

function pickups.spawnHealthPack(x, y, large)
    local pickup = {
        x = x,
        y = y,
        width = 25,
        height = 25,
        type = large and pickups.TYPE_HEALTH_LARGE or pickups.TYPE_HEALTH_SMALL,
        value = large and 100 or 50,
        color = large and {1.0, 0.0, 1.0} or {0.0, 1.0, 0.0},
        lifetime = 15.0,
        scale = large and 0.12 or 0.1  -- 0.1 original size
    }
    table.insert(pickups.list, pickup)
end

function pickups.spawnAmmo(x, y)
    local pickup = {
        x = x,
        y = y,
        width = 25,
        height = 25,
        type = pickups.TYPE_AMMO,
        value = 30,
        color = {1.0, 0.8, 0.0},
        lifetime = 15.0,
        scale = 0.05  -- much smaller
    }
    table.insert(pickups.list, pickup)
end

function pickups.spawnXP(x, y, amount)
    local pickup = {
        x = x,
        y = y,
        width = 20,
        height = 20,
        type = pickups.TYPE_XP,
        value = amount or 10,
        color = {0.0, 0.8, 1.0},
        lifetime = 10.0,
        scale = 0.04  -- much smaller
    }
    table.insert(pickups.list, pickup)
end

function pickups.update(dt)
    for i = #pickups.list, 1, -1 do
        local pickup = pickups.list[i]
        pickup.lifetime = pickup.lifetime - dt
        
        if pickup.lifetime <= 0 then
            table.remove(pickups.list, i)
        end
    end
end

function pickups.checkCollision(player)
    for i = #pickups.list, 1, -1 do
        local pickup = pickups.list[i]
        
        if player.x < pickup.x + pickup.width and
           player.x + player.width > pickup.x and
           player.y < pickup.y + pickup.height and
           player.y + player.height > pickup.y then
            
            local collected = pickup
            table.remove(pickups.list, i)
            return collected
        end
    end
    return nil
end

function pickups.draw()
    for i, pickup in ipairs(pickups.list) do
        -- calculate fade effect near end of lifetime
        local alpha = 1.0
        if pickup.lifetime < 3.0 then
            alpha = 0.5 + 0.5 * math.sin(pickup.lifetime * 5)  -- blink effect
        end
        
        love.graphics.setColor(1, 1, 1, alpha)
        
        -- draw sprite based on type
        if pickup.type == pickups.TYPE_HEALTH_SMALL or pickup.type == pickups.TYPE_HEALTH_LARGE then
            if pickups.healthSprite then
                local scale = pickup.scale or 1.0
                love.graphics.draw(
                    pickups.healthSprite,
                    pickup.x + pickup.width/2,
                    pickup.y + pickup.height/2,
                    0,
                    scale,
                    scale,
                    pickups.healthSprite:getWidth()/2,
                    pickups.healthSprite:getHeight()/2
                )
            else
                -- fallback
                love.graphics.setColor(pickup.color[1], pickup.color[2], pickup.color[3], alpha)
                love.graphics.rectangle("fill", pickup.x, pickup.y, pickup.width, pickup.height)
                love.graphics.setColor(1, 1, 1, alpha)
                love.graphics.rectangle("line", pickup.x, pickup.y, pickup.width, pickup.height)
                local text = pickup.type == pickups.TYPE_HEALTH_LARGE and "H+" or "H"
                love.graphics.print(text, pickup.x + 5, pickup.y + 3)
            end
        elseif pickup.type == pickups.TYPE_AMMO then
            if pickups.ammoSprite then
                local scale = pickup.scale or 1.0
                love.graphics.draw(
                    pickups.ammoSprite,
                    pickup.x + pickup.width/2,
                    pickup.y + pickup.height/2,
                    0,
                    scale,
                    scale,
                    pickups.ammoSprite:getWidth()/2,
                    pickups.ammoSprite:getHeight()/2
                )
            else
                -- fallback
                love.graphics.setColor(pickup.color[1], pickup.color[2], pickup.color[3], alpha)
                love.graphics.rectangle("fill", pickup.x, pickup.y, pickup.width, pickup.height)
                love.graphics.setColor(1, 1, 1, alpha)
                love.graphics.rectangle("line", pickup.x, pickup.y, pickup.width, pickup.height)
                love.graphics.print("A", pickup.x + 5, pickup.y + 3)
            end
        elseif pickup.type == pickups.TYPE_XP then
            if pickups.coinSprite then
                local scale = pickup.scale or 1.0
                love.graphics.draw(
                    pickups.coinSprite,
                    pickup.x + pickup.width/2,
                    pickup.y + pickup.height/2,
                    0,
                    scale,
                    scale,
                    pickups.coinSprite:getWidth()/2,
                    pickups.coinSprite:getHeight()/2
                )
            else
                -- fallback
                love.graphics.setColor(pickup.color[1], pickup.color[2], pickup.color[3], alpha)
                love.graphics.rectangle("fill", pickup.x, pickup.y, pickup.width, pickup.height)
                love.graphics.setColor(1, 1, 1, alpha)
                love.graphics.rectangle("line", pickup.x, pickup.y, pickup.width, pickup.height)
                love.graphics.print("XP", pickup.x + 2, pickup.y + 3)
            end
        end
    end
end

function pickups.clear()
    pickups.list = {}
end
