-- progression.lua
-- xp system and upgrades

progression = {}

function progression.init()
    progression.xp = 0
    progression.level = 1
    progression.xpToNextLevel = 100
    progression.xpScaling = 1.5  -- each level needs 50% more xp
    
    -- upgrades
    progression.maxHealth = 100
    progression.healthRegen = 0
    progression.ammoCapacity = 100
    progression.multiShot = 1  -- number of bullets per shot
    progression.dashSpeed = 500  -- dash speed (changed from dashDistance)
    progression.dashDuration = 0.3  -- dash duration
    progression.moveSpeed = 200
    
    -- upgrade state
    progression.showUpgradeMenu = false
    progression.upgradeOptions = {}
    
    -- load sound
    local success, sound = pcall(love.audio.newSource, "assets/sounds/levelup.wav", "static")
    if success then
        progression.levelupSound = sound
    else
        progression.levelupSound = nil
    end
end

function progression.addXP(amount)
    progression.xp = progression.xp + amount
    
    -- check level up
    if progression.xp >= progression.xpToNextLevel then
        progression.levelUp()
    end
end

function progression.levelUp()
    progression.level = progression.level + 1
    progression.xp = progression.xp - progression.xpToNextLevel
    progression.xpToNextLevel = math.floor(progression.xpToNextLevel * progression.xpScaling)
    
    -- play sound
    if progression.levelupSound then
        progression.levelupSound:play()
    end
    
    -- generate upgrade options
    progression.generateUpgradeOptions()
    progression.showUpgradeMenu = true
end

function progression.generateUpgradeOptions()
    local allUpgrades = {
        {
            name = "Max Health +20",
            description = "Increase maximum health",
            apply = function()
                progression.maxHealth = progression.maxHealth + 20
                player.maxHealth = progression.maxHealth
                player.health = math.min(player.health + 20, player.maxHealth)
            end
        },
        {
            name = "Health Regen",
            description = "Regenerate 5 HP per second",
            apply = function()
                progression.healthRegen = progression.healthRegen + 5
            end
        },
        {
            name = "Ammo Capacity +50",
            description = "Carry more ammo",
            apply = function()
                progression.ammoCapacity = progression.ammoCapacity + 50
                weapons.maxAmmo = progression.ammoCapacity
            end
        },
        {
            name = "Multi-Shot",
            description = "Fire additional bullets",
            apply = function()
                progression.multiShot = progression.multiShot + 1
                weapons.multiShot = progression.multiShot
            end
        },
        {
            name = "Dash Speed +100",
            description = "Dash faster and longer",
            apply = function()
                progression.dashSpeed = progression.dashSpeed + 100
                progression.dashDuration = progression.dashDuration + 0.05
                player.dashSpeed = progression.dashSpeed
                player.dashDuration = progression.dashDuration
            end
        },
        {
            name = "Move Speed +20",
            description = "Move faster",
            apply = function()
                progression.moveSpeed = progression.moveSpeed + 20
                player.speed = progression.moveSpeed
            end
        },
        {
            name = "Faster Cooldowns",
            description = "Reduce weapon cooldowns",
            apply = function()
                weapons.gunCooldownTime = weapons.gunCooldownTime * 0.8
                weapons.meleeCooldownTime = weapons.meleeCooldownTime * 0.8
            end
        },
        {
            name = "Energy Regen +5",
            description = "Regenerate energy faster",
            apply = function()
                player.energyRegen = player.energyRegen + 5
            end
        }
    }
    
    -- pick 3 random upgrades
    progression.upgradeOptions = {}
    local available = {}
    for i, upgrade in ipairs(allUpgrades) do
        table.insert(available, upgrade)
    end
    
    for i = 1, 3 do
        if #available > 0 then
            local index = math.random(1, #available)
            table.insert(progression.upgradeOptions, available[index])
            table.remove(available, index)
        end
    end
end

function progression.selectUpgrade(index)
    if progression.upgradeOptions[index] then
        progression.upgradeOptions[index].apply()
        progression.showUpgradeMenu = false
        progression.upgradeOptions = {}
    end
end

function progression.drawXPBar()
    local barX = 220
    local barY = 10
    local barWidth = 300
    local barHeight = 20
    
    -- background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
    -- xp progress
    local progress = progression.xp / progression.xpToNextLevel
    local currentWidth = barWidth * progress
    love.graphics.setColor(0.0, 0.8, 1.0)
    love.graphics.rectangle("fill", barX, barY, currentWidth, barHeight)
    
    -- border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
    
    -- text
    love.graphics.print("Level " .. progression.level, barX + 5, barY + 3)
    love.graphics.print(progression.xp .. "/" .. progression.xpToNextLevel, barX + 100, barY + 3)
end

function progression.drawUpgradeMenu()
    if not progression.showUpgradeMenu then return end
    
    -- darken background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- title
    love.graphics.setColor(0, 1, 1)
    love.graphics.printf("LEVEL UP!", 0, 100, 800, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Choose an upgrade:", 0, 130, 800, "center")
    
    -- draw upgrade options
    local startX = 100
    local startY = 200
    local boxWidth = 180
    local boxHeight = 150
    local spacing = 20
    
    for i, upgrade in ipairs(progression.upgradeOptions) do
        local x = startX + (i - 1) * (boxWidth + spacing)
        local y = startY
        
        -- box
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", x, y, boxWidth, boxHeight)
        love.graphics.setColor(0.5, 0.5, 1.0)
        love.graphics.rectangle("line", x, y, boxWidth, boxHeight)
        
        -- text
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(upgrade.name, x + 10, y + 20, boxWidth - 20, "center")
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf(upgrade.description, x + 10, y + 60, boxWidth - 20, "center")
        
        -- number
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("Press " .. i, x + 10, y + 110, boxWidth - 20, "center")
    end
end

function progression.update(dt)
    -- health regen
    if progression.healthRegen > 0 and player.health < player.maxHealth then
        player.health = math.min(player.health + progression.healthRegen * dt, player.maxHealth)
    end
end
