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
end

function pickups.spawnHealthPack(x, y, large)
    local pickup = {
        x = x,
        y = y,
        width = 20,
        height = 20,
        type = large and pickups.TYPE_HEALTH_LARGE or pickups.TYPE_HEALTH_SMALL,
        value = large and 100 or 50,
        color = large and {1.0, 0.0, 1.0} or {0.0, 1.0, 0.0},
        lifetime = 15.0
    }
    table.insert(pickups.list, pickup)
end

function pickups.spawnAmmo(x, y)
    local pickup = {
        x = x,
        y = y,
        width = 18,
        height = 18,
        type = pickups.TYPE_AMMO,
        value = 30,
        color = {1.0, 0.8, 0.0},
        lifetime = 15.0
    }
    table.insert(pickups.list, pickup)
end

function pickups.spawnXP(x, y, amount)
    local pickup = {
        x = x,
        y = y,
        width = 15,
        height = 15,
        type = pickups.TYPE_XP,
        value = amount or 10,
        color = {0.0, 0.8, 1.0},
        lifetime = 10.0
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
        -- draw pickup
        love.graphics.setColor(pickup.color)
        love.graphics.rectangle("fill", pickup.x, pickup.y, pickup.width, pickup.height)
        
        -- draw border
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", pickup.x, pickup.y, pickup.width, pickup.height)
        
        -- draw icon/text
        love.graphics.setColor(1, 1, 1, 0.9)
        if pickup.type == pickups.TYPE_HEALTH_SMALL then
            love.graphics.print("H", pickup.x + 5, pickup.y + 3)
        elseif pickup.type == pickups.TYPE_HEALTH_LARGE then
            love.graphics.print("H+", pickup.x + 3, pickup.y + 3)
        elseif pickup.type == pickups.TYPE_AMMO then
            love.graphics.print("A", pickup.x + 5, pickup.y + 3)
        elseif pickup.type == pickups.TYPE_XP then
            love.graphics.print("XP", pickup.x + 2, pickup.y + 3)
        end
    end
end

function pickups.clear()
    pickups.list = {}
end
