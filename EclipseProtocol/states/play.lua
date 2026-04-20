-- states/play.lua
-- main gameplay state

local play = {}

function play.enter()
    -- check if loading custom level from developer mode
    if _G.customLevel then
        play.loadCustomLevel()
    else
        -- initialize game timer first
        play.gameTimer = 0
        play.victoryTime = 180  -- 3 minutes to win
        
        -- initialize game
        player.load()
        enemy.init()  -- initialize turret sprites
        boss.init()   -- initialize boss sprites
        world.init()
        weapons.init()
        pickups.init()
        progression.init()
    end
    
    -- load background music
    local success, music = pcall(love.audio.newSource, "assets/sounds/music.mp3", "stream")
    if success then
        play.music = music
        play.music:setLooping(true)
        play.music:setVolume(0.3)
        play.music:play()
    else
        play.music = nil
        print("Warning: music.mp3 not found")
    end
end

function play.loadCustomLevel()
    -- initialize systems
    play.gameTimer = 0
    play.victoryTime = 180
    
    player.load()
    enemy.init()
    boss.init()
    weapons.init()
    pickups.init()
    progression.init()
    
    -- load custom level data
    local level = _G.customLevel
    
    -- set player spawn
    if level.spawnPoint then
        player.x = level.spawnPoint.x
        player.y = level.spawnPoint.y
    end
    
    -- setup world with custom data
    world.roomCount = 1
    world.width = 800
    world.height = 600
    world.walls = level.walls or {}
    
    -- setup door
    if level.exitDoor then
        world.door = {
            x = level.exitDoor.x,
            y = level.exitDoor.y,
            width = level.exitDoor.width,
            height = level.exitDoor.height,
            color = {0.2, 0.8, 0.2},
            visible = false
        }
    else
        world.door = {
            x = 700,
            y = 300,
            width = 50,
            height = 80,
            color = {0.2, 0.8, 0.2},
            visible = false
        }
    end
    
    -- spawn enemies
    enemy.list = {}
    if level.enemies then
        for i, e in ipairs(level.enemies) do
            enemy.create(e.x, e.y, 1)
        end
    end
    
    -- spawn hunters
    hunter.list = {}
    if level.hunters then
        for i, h in ipairs(level.hunters) do
            hunter.create(h.x, h.y)
        end
    end
    
    -- clear custom level flag
    _G.customLevel = nil
end

function play.update(dt)
    -- pause if upgrade menu is showing
    if progression.showUpgradeMenu then
        return
    end
    
    play.gameTimer = play.gameTimer + dt
    
    -- check victory condition (10 rooms cleared)
    if world.roomCount >= 10 then
        stateManager.switch("victory")
        return
    end
    
    -- update player
    player.update(dt)
    
    -- update weapons
    weapons.update(dt)
    
    -- update pickups
    pickups.update(dt)
    
    -- update progression
    progression.update(dt)
    
    -- check pickup collection
    local collected = pickups.checkCollision(player)
    if collected then
        if collected.type == pickups.TYPE_HEALTH_SMALL or collected.type == pickups.TYPE_HEALTH_LARGE then
            player.health = math.min(player.health + collected.value, player.maxHealth)
        elseif collected.type == pickups.TYPE_AMMO then
            weapons.addAmmo(collected.value)
        elseif collected.type == pickups.TYPE_XP then
            progression.addXP(collected.value)
        end
    end
    
    -- update enemies (turrets need player position)
    enemy.updateAll(dt, player.x + player.width/2, player.y + player.height/2)
    hunter.updateAll(dt, player.x, player.y)
    boss.update(dt, player.x + player.width/2, player.y + player.height/2)
    
    -- check turret bullet hits on player
    local hitByTurret, turretDamage = enemy.checkBulletCollision(player)
    if hitByTurret then
        player.takeDamage(turretDamage)
        if player.hitSound then
            player.hitSound:play()
        end
    end
    
    -- update world (check door visibility)
    world.update()
    
    -- check bullet hits on enemies
    for i = #enemy.list, 1, -1 do
        local e = enemy.list[i]
        local hit, damage = weapons.checkBulletCollision(e)
        if hit then
            local dead = enemy.takeDamage(e, damage)
            if dead then
                table.remove(enemy.list, i)
                -- drop xp
                pickups.spawnXP(e.x, e.y, 15)
                -- chance for health pack
                if math.random() < 0.3 then
                    pickups.spawnHealthPack(e.x + 20, e.y, math.random() < 0.2)
                end
                -- chance for ammo
                if math.random() < 0.4 then
                    pickups.spawnAmmo(e.x - 20, e.y)
                end
            end
        end
    end
    
    for i = #hunter.list, 1, -1 do
        local h = hunter.list[i]
        local hit, damage = weapons.checkBulletCollision(h)
        if hit then
            local dead = hunter.takeDamage(h, damage)
            if dead then
                table.remove(hunter.list, i)
                -- drop more xp
                pickups.spawnXP(h.x, h.y, 25)
                -- better drop chances
                if math.random() < 0.5 then
                    pickups.spawnHealthPack(h.x + 20, h.y, math.random() < 0.3)
                end
                if math.random() < 0.6 then
                    pickups.spawnAmmo(h.x - 20, h.y)
                end
            end
        end
    end
    
    -- check bullet hits on boss
    if boss.active then
        local hit, damage = boss.checkBulletCollision()
        if hit then
            local dead = boss.takeDamage(damage, "gun")
            if dead then
                -- boss defeated - drop lots of rewards
                pickups.spawnXP(boss.instance.x, boss.instance.y, 100)
                pickups.spawnHealthPack(boss.instance.x + 30, boss.instance.y, true)
                pickups.spawnAmmo(boss.instance.x - 30, boss.instance.y)
            end
        end
    end
    
    -- check collisions with hunters
    for i, h in ipairs(hunter.list) do
        if checkCollision(player, h) then
            player.takeDamage(15)
            if player.hitSound then
                player.hitSound:play()
            end
        end
    end
    
    -- check door collision
    if world.checkDoorCollision(player) then
        world.generateRoom()
        player.x = 50
        player.y = world.height / 2
    end
    
    -- check game over
    if player.health <= 0 then
        stateManager.switch("gameover")
    end
end

function play.draw()
    world.draw()
    pickups.draw()
    enemy.drawAll()
    hunter.drawAll()
    boss.draw()
    weapons.draw(player.x, player.y)
    player.draw()
    ui.draw(player.health, player.energy, false, world.roomCount, play.gameTimer)
    progression.drawXPBar()
    progression.drawUpgradeMenu()
end

function play.keypressed(key)
    if progression.showUpgradeMenu then
        -- handle upgrade selection
        if key == "1" then
            progression.selectUpgrade(1)
        elseif key == "2" then
            progression.selectUpgrade(2)
        elseif key == "3" then
            progression.selectUpgrade(3)
        end
    else
        if key == "escape" then
            stateManager.switch("pause")
        elseif key == "q" then
            weapons.switchWeapon()
        elseif key == "r" then
            weapons.reload()
        end
    end
end

function play.mousepressed(x, y, button)
    if progression.showUpgradeMenu then
        return  -- don't attack during upgrade menu
    end
    
    if button == 1 then  -- left click
        if weapons.currentWeapon == weapons.GUN then
            -- gun attacks use mouse position
            weapons.attack(player.x, player.y, x, y, player.direction)
        elseif weapons.currentWeapon == weapons.MELEE then
            -- melee attacks check nearby enemies
            local attackData = weapons.attack(player.x, player.y, nil, nil, player.direction)
            
            if attackData then
                -- check melee hits on enemies (check if enemy is close to player)
                for i = #enemy.list, 1, -1 do
                    local e = enemy.list[i]
                    local dx = (e.x + e.width/2) - (player.x + player.width/2)
                    local dy = (e.y + e.height/2) - (player.y + player.height/2)
                    local distance = math.sqrt(dx * dx + dy * dy)
                    
                    if distance < attackData.range then
                        local dead = enemy.takeDamage(e, attackData.damage)
                        if dead then
                            table.remove(enemy.list, i)
                            -- drop xp
                            pickups.spawnXP(e.x, e.y, 15)
                            -- chance for health pack
                            if math.random() < 0.3 then
                                pickups.spawnHealthPack(e.x + 20, e.y, math.random() < 0.2)
                            end
                            -- chance for ammo
                            if math.random() < 0.4 then
                                pickups.spawnAmmo(e.x - 20, e.y)
                            end
                        end
                    end
                end
                
                -- check melee hits on hunters
                for i = #hunter.list, 1, -1 do
                    local h = hunter.list[i]
                    local dx = (h.x + h.width/2) - (player.x + player.width/2)
                    local dy = (h.y + h.height/2) - (player.y + player.height/2)
                    local distance = math.sqrt(dx * dx + dy * dy)
                    
                    if distance < attackData.range then
                        local dead = hunter.takeDamage(h, attackData.damage)
                        if dead then
                            table.remove(hunter.list, i)
                            -- drop more xp
                            pickups.spawnXP(h.x, h.y, 25)
                            -- better drop chances
                            if math.random() < 0.5 then
                                pickups.spawnHealthPack(h.x + 20, h.y, math.random() < 0.3)
                            end
                            if math.random() < 0.6 then
                                pickups.spawnAmmo(h.x - 20, h.y)
                            end
                        end
                    end
                end
                
                -- check melee hits on boss
                if boss.active then
                    local hit = boss.checkMeleeHit(player.x, player.y, attackData.range)
                    if hit then
                        local dead = boss.takeDamage(attackData.damage, "melee")
                        if dead then
                            -- boss defeated - drop lots of rewards
                            pickups.spawnXP(boss.instance.x, boss.instance.y, 100)
                            pickups.spawnHealthPack(boss.instance.x + 30, boss.instance.y, true)
                            pickups.spawnAmmo(boss.instance.x - 30, boss.instance.y)
                        end
                    end
                end
            end
        end
    end
end

function play.exit()
    if play.music then
        play.music:stop()
    end
end

-- aabb collision detection
function checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

return play
