-- weapons.lua
-- weapon system with melee and ranged

weapons = {}
weapons.bullets = {}

-- weapon types
weapons.MELEE = "melee"
weapons.GUN = "gun"

function weapons.init()
    weapons.currentWeapon = weapons.MELEE
    weapons.meleeCooldown = 0
    weapons.gunCooldown = 0
    weapons.bullets = {}
    
    -- base damage values
    weapons.baseMeleeDamage = 36  -- 1.8x gun damage (20 * 1.8 = 36)
    weapons.baseGunDamage = 20
    
    -- melee stats
    weapons.meleeRange = 60
    weapons.meleeDamage = weapons.baseMeleeDamage
    weapons.meleeCooldownTime = 0.5
    weapons.meleeSwing = nil  -- visual swing effect
    
    -- gun stats with magazine system
    weapons.gunDamage = weapons.baseGunDamage
    weapons.gunCooldownTime = 0.3
    weapons.bulletSpeed = 400
    weapons.magazineSize = 5  -- NEW: 5 bullets per magazine
    weapons.currentMag = 5    -- bullets in current magazine
    weapons.ammo = 100        -- total reserve ammo
    weapons.maxAmmo = 100
    weapons.multiShot = 1
    weapons.reloading = false
    weapons.reloadTime = 1.5  -- seconds to reload
    weapons.reloadTimer = 0
    
    -- load sounds
    local success, sound = pcall(love.audio.newSource, "assets/sounds/shoot.wav", "static")
    if success then
        weapons.shootSound = sound
    else
        weapons.shootSound = nil
    end
end

function weapons.update(dt)
    -- update cooldowns
    if weapons.meleeCooldown > 0 then
        weapons.meleeCooldown = weapons.meleeCooldown - dt
    end
    if weapons.gunCooldown > 0 then
        weapons.gunCooldown = weapons.gunCooldown - dt
    end
    
    -- update reload
    if weapons.reloading then
        weapons.reloadTimer = weapons.reloadTimer - dt
        if weapons.reloadTimer <= 0 then
            -- reload complete
            local ammoNeeded = weapons.magazineSize - weapons.currentMag
            local ammoToReload = math.min(ammoNeeded, weapons.ammo)
            weapons.currentMag = weapons.currentMag + ammoToReload
            weapons.ammo = weapons.ammo - ammoToReload
            weapons.reloading = false
        end
    end
    
    -- update melee swing animation
    if weapons.meleeSwing then
        weapons.meleeSwing.lifetime = weapons.meleeSwing.lifetime - dt
        if weapons.meleeSwing.lifetime <= 0 then
            weapons.meleeSwing = nil
        end
    end
    
    -- update bullets
    for i = #weapons.bullets, 1, -1 do
        local bullet = weapons.bullets[i]
        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt
        bullet.lifetime = bullet.lifetime - dt
        
        -- remove if expired or out of bounds
        if bullet.lifetime <= 0 or bullet.x < 0 or bullet.x > 800 or bullet.y < 0 or bullet.y > 600 then
            table.remove(weapons.bullets, i)
        end
    end
end

function weapons.switchWeapon()
    if weapons.currentWeapon == weapons.MELEE then
        weapons.currentWeapon = weapons.GUN
    else
        weapons.currentWeapon = weapons.MELEE
    end
end

function weapons.attack(playerX, playerY, mouseX, mouseY, direction)
    if weapons.currentWeapon == weapons.MELEE then
        return weapons.meleeAttack(playerX, playerY, direction)
    else
        weapons.gunAttack(playerX, playerY, mouseX, mouseY)
    end
end

function weapons.meleeAttack(playerX, playerY, direction)
    if weapons.meleeCooldown > 0 then return end
    
    weapons.meleeCooldown = weapons.meleeCooldownTime
    
    -- calculate attack direction based on player facing direction
    local dx, dy = 0, 0
    if direction == "up" then
        dy = -1
    elseif direction == "down" then
        dy = 1
    elseif direction == "left" then
        dx = -1
    elseif direction == "right" then
        dx = 1
    end
    
    -- create visual swing effect
    weapons.meleeSwing = {
        x = playerX + 20,
        y = playerY + 20,
        dirX = dx,
        dirY = dy,
        lifetime = 0.2,
        range = weapons.meleeRange
    }
    
    -- return attack data for collision checking
    return {
        x = playerX + 20,
        y = playerY + 20,
        dirX = dx,
        dirY = dy,
        range = weapons.meleeRange,
        damage = weapons.meleeDamage
    }
end

function weapons.gunAttack(playerX, playerY, mouseX, mouseY)
    if weapons.gunCooldown > 0 then return end
    if weapons.reloading then return end  -- can't shoot while reloading
    if weapons.currentMag <= 0 then
        -- auto reload if magazine empty
        weapons.reload()
        return
    end
    
    weapons.gunCooldown = weapons.gunCooldownTime
    weapons.currentMag = weapons.currentMag - 1
    
    -- calculate bullet direction
    local dx = mouseX - playerX
    local dy = mouseY - playerY
    local length = math.sqrt(dx * dx + dy * dy)
    
    if length > 0 then
        dx = dx / length
        dy = dy / length
    end
    
    -- create bullets (multi-shot support)
    for i = 1, weapons.multiShot do
        local angle = 0
        if weapons.multiShot > 1 then
            -- spread bullets in a cone
            local spread = 0.3
            angle = -spread/2 + (spread / (weapons.multiShot - 1)) * (i - 1)
        end
        
        -- rotate direction by angle
        local cos_a = math.cos(angle)
        local sin_a = math.sin(angle)
        local rotDx = dx * cos_a - dy * sin_a
        local rotDy = dx * sin_a + dy * cos_a
        
        local bullet = {
            x = playerX + 20,
            y = playerY + 20,
            vx = rotDx * weapons.bulletSpeed,
            vy = rotDy * weapons.bulletSpeed,
            width = 8,
            height = 8,
            damage = weapons.gunDamage,
            lifetime = 3.0,
            color = {1.0, 1.0, 0.0}
        }
        
        table.insert(weapons.bullets, bullet)
    end
    
    -- play sound
    if weapons.shootSound then
        weapons.shootSound:play()
    end
end

function weapons.reload()
    if weapons.reloading then return end
    if weapons.currentMag >= weapons.magazineSize then return end
    if weapons.ammo <= 0 then return end
    
    weapons.reloading = true
    weapons.reloadTimer = weapons.reloadTime
end

function weapons.draw(playerX, playerY)
    -- draw melee swing effect
    if weapons.meleeSwing then
        local swing = weapons.meleeSwing
        local alpha = swing.lifetime / 0.2  -- fade out
        
        -- draw arc
        love.graphics.setColor(1, 1, 1, alpha * 0.7)
        local angle = math.atan2(swing.dirY, swing.dirX)
        for i = -0.5, 0.5, 0.1 do
            local a = angle + i
            local x1 = swing.x + math.cos(a) * 20
            local y1 = swing.y + math.sin(a) * 20
            local x2 = swing.x + math.cos(a) * swing.range
            local y2 = swing.y + math.sin(a) * swing.range
            love.graphics.line(x1, y1, x2, y2)
        end
    end
    
    -- draw bullets
    for i, bullet in ipairs(weapons.bullets) do
        love.graphics.setColor(bullet.color)
        love.graphics.circle("fill", bullet.x, bullet.y, 4)
    end
    
    -- draw weapon indicator
    love.graphics.setColor(1, 1, 1)
    local weaponText = weapons.currentWeapon == weapons.MELEE and "MELEE" or "GUN"
    love.graphics.print("Weapon: " .. weaponText, 10, 140)
    
    -- draw ammo/magazine if using gun
    if weapons.currentWeapon == weapons.GUN then
        if weapons.reloading then
            love.graphics.setColor(1, 0.5, 0)
            love.graphics.print("RELOADING... " .. string.format("%.1f", weapons.reloadTimer), 10, 155)
        else
            local color = weapons.currentMag == 0 and {1, 0, 0} or {1, 1, 1}
            love.graphics.setColor(color)
            love.graphics.print("Mag: " .. weapons.currentMag .. "/" .. weapons.magazineSize, 10, 155)
            love.graphics.print("Ammo: " .. weapons.ammo, 10, 170)
            
            if weapons.currentMag == 0 and weapons.ammo > 0 then
                love.graphics.setColor(1, 1, 0)
                love.graphics.print("Press R to reload!", 10, 185)
            end
        end
    end
    
    -- draw cooldown indicator
    if weapons.currentWeapon == weapons.MELEE and weapons.meleeCooldown > 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Cooldown: " .. string.format("%.1f", weapons.meleeCooldown), 10, 155)
    elseif weapons.currentWeapon == weapons.GUN and weapons.gunCooldown > 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Cooldown: " .. string.format("%.1f", weapons.gunCooldown), 10, 200)
    end
end

function weapons.addAmmo(amount)
    weapons.ammo = math.min(weapons.ammo + amount, weapons.maxAmmo)
end

function weapons.checkBulletCollision(entity)
    for i = #weapons.bullets, 1, -1 do
        local bullet = weapons.bullets[i]
        
        if bullet.x > entity.x and bullet.x < entity.x + entity.width and
           bullet.y > entity.y and bullet.y < entity.y + entity.height then
            table.remove(weapons.bullets, i)
            return true, bullet.damage
        end
    end
    return false, 0
end

function weapons.applyDamageMultiplier(multiplier)
    weapons.meleeDamage = math.floor(weapons.baseMeleeDamage * multiplier)
    weapons.gunDamage = math.floor(weapons.baseGunDamage * multiplier)
end
