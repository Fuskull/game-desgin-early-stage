# Eclipse Protocol

A top-down action roguelike game built with LÖVE (Love2D) featuring animated sprites, dual weapon systems, enemy AI, progression mechanics, and a level creator.

![Eclipse Protocol](https://img.shields.io/badge/LÖVE-11.4-pink)
![Lua](https://img.shields.io/badge/Lua-5.1-blue)

## Features

### Gameplay
- **Animated Player Character** - Sprite animations with weapon-based variants (melee/gun)
- **Smooth Dash System** - Speed boost mechanic with energy cost and visual effects
- **Dual Weapon System** - Switch between melee and ranged combat
  - **Melee**: 36 damage (1.8x gun damage), close-range area attack
  - **Gun**: 20 damage, ranged, 5-bullet magazine with reload mechanics
- **Enemy Types**:
  - **Turrets** - Moving enemies that shoot bullets while patrolling fixed paths
  - **Hunters** - AI enemies with FSM (Finite State Machine) behavior
- **Progression System** - XP, leveling, and 9 different upgrades including weapon damage boost
- **Pickup System** - Health packs, ammo, and XP orbs
- **Room Progression** - Clear 10 rooms to win, with scaling difficulty
- **Textured Environment** - Stone wall textures and door sprites

### Developer Mode
- **Level Creator** - Build custom levels with a visual editor
- **Place Walls** - Create obstacles and cover
- **Place Enemies** - Position turrets and hunters
- **Test Levels** - Instantly playable custom levels
- **Save/Load** - Persistent level storage

## Controls

### Gameplay
- **WASD / Arrow Keys** - Move
- **Shift** - Dash (speed boost, costs 25 energy)
- **Q** - Switch weapon (Melee/Gun)
- **R** - Reload gun
- **Left Click** - Attack (both melee and gun)
- **1/2/3** - Select upgrade (on level up)
- **ESC** - Pause

### Developer Mode
- **Left Click** - Place tool
- **TAB** - Switch tool
- **1-6** - Quick tool select
- **Arrow Keys** - Move camera
- **G** - Toggle grid
- **H** - Toggle help
- **T** - Test level
- **S** - Save level
- **L** - Load level
- **C** - Clear all
- **ESC** - Exit to menu

## Installation

### Prerequisites
- [LÖVE (Love2D)](https://love2d.org/) version 11.4 or higher

### Windows
1. Download and install LÖVE from [love2d.org](https://love2d.org/)
2. Clone this repository:
   ```bash
   git clone https://github.com/Fuskull/game-desgin-early-stage.git
   ```
3. Run the game:
   - Double-click `RUN_GAME.bat` or `run_eclipse_protocol.bat`
   - Or run: `love EclipseProtocol`
   - Or drag the `EclipseProtocol` folder onto `love.exe`

### Linux
1. Install LÖVE:
   ```bash
   sudo apt-get install love
   ```
2. Clone and run:
   ```bash
   git clone https://github.com/Fuskull/game-desgin-early-stage.git
   cd game-desgin-early-stage
   love EclipseProtocol
   ```

### macOS
1. Download LÖVE from [love2d.org](https://love2d.org/)
2. Clone this repository
3. Run:
   ```bash
   love EclipseProtocol
   ```

## Project Structure

```
EclipseProtocol/
├── main.lua              # Game entry point
├── conf.lua              # LÖVE configuration
├── player.lua            # Player system with animations
├── enemy.lua             # Turret enemy system
├── hunter.lua            # Hunter AI enemy
├── weapons.lua           # Weapon and combat system
├── world.lua             # Room generation and rendering
├── progression.lua       # XP and upgrade system
├── pickups.lua           # Item pickup system
├── ui.lua                # User interface
├── stateManager.lua      # Game state management
├── libraries/
│   └── anim8.lua         # Animation library
├── assets/
│   ├── images/
│   │   ├── player-sheet.png
│   │   ├── player-sheet gun.png
│   │   ├── turret alive.png
│   │   ├── turret dead.png
│   │   ├── door.png
│   │   └── cartoon-stone-wall-texture-*.jpg
│   └── sounds/
│       ├── hit.wav
│       ├── dash.wav
│       ├── shoot.wav
│       ├── levelup.wav
│       └── music.mp3
└── states/
    ├── menu.lua          # Main menu
    ├── play.lua          # Gameplay state
    ├── pause.lua         # Pause menu
    ├── gameover.lua      # Game over screen
    ├── victory.lua       # Victory screen
    └── developer.lua     # Level creator
```

## Gameplay Systems

### Weapon System
- **Melee**: 
  - 36 base damage (1.8x gun damage)
  - Close-range area attack (60 unit radius)
  - Attacks in player's facing direction
  - 0.5 second cooldown
  - Visual swing effect
  
- **Gun**: 
  - 20 base damage per bullet
  - Ranged projectile attack
  - 5-bullet magazine system
  - Manual reload required (R key)
  - 0.3 second cooldown between shots
  - Supports multi-shot upgrade

### Enemy System
- **Turrets**: 
  - Move on fixed patrol paths
  - Shoot bullets every 2 seconds
  - 300 unit detection range
  - Health scales with room difficulty
  
- **Hunters**: 
  - FSM AI with Idle, Patrol, Chase, and Return states
  - Chase player when in range
  - Higher health and damage than turrets
  - Health scales with room count

### Progression System
Gain XP from killing enemies and level up to choose from 3 random upgrades:
1. **Max Health +20** - Increase maximum health
2. **Health Regen** - Regenerate 5 HP per second
3. **Ammo Capacity +50** - Carry more ammo
4. **Multi-Shot** - Fire additional bullets
5. **Dash Speed +100** - Dash faster and longer
6. **Move Speed +20** - Move faster
7. **Faster Cooldowns** - Reduce weapon cooldowns by 20%
8. **Energy Regen +5** - Regenerate energy faster
9. **Weapon Damage +20%** - Increase all weapon damage (NEW!)

### Room System
- Clear all enemies to unlock the exit door
- Progress through 10 rooms to win
- Difficulty scales with room count
- More enemies spawn in later rooms
- Procedurally generated wall layouts

### Developer Mode
Create custom levels with:
- Walls for obstacles and cover
- Turret placements with patrol paths
- Hunter placements
- Custom spawn points
- Custom exit doors
- Save/load functionality

## Technologies

- **Engine**: LÖVE (Love2D) 11.4
- **Language**: Lua 5.1
- **Animation**: anim8 library by kikito
- **Graphics**: Pixel art sprites and textures

## Credits

- **Game Engine**: [LÖVE](https://love2d.org/)
- **Animation Library**: [anim8](https://github.com/kikito/anim8) by kikito

## License

This project is open source and available under the MIT License.

## Recent Updates

### Latest Features
- Improved melee system with proximity-based damage
- Weapon damage upgrade card (+20% to all weapons)
- Stone wall textures with spider webs
- Door sprite for exit
- Melee damage balanced at 1.8x gun damage
- Magazine reload system for guns

### Completed Features
- Animated sprites (player + enemies)
- Turret shooting system
- Hunter AI with FSM
- Developer mode / level creator
- Complete progression system
- Energy and dash mechanics
- Sound effects and music
- Victory condition (10 rooms)

## Contributing

Feel free to fork this project and submit pull requests!

## Support

For issues or questions, please open an issue on GitHub.

---

**Enjoy playing Eclipse Protocol!** 🎮
