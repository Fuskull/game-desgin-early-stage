# Eclipse Protocol

A top-down action game built with LÖVE (Love2D) featuring animated sprites, weapon systems, enemy AI, and a level creator.

![Eclipse Protocol](https://img.shields.io/badge/LÖVE-11.4-pink)
![Lua](https://img.shields.io/badge/Lua-5.1-blue)

## Features

### Gameplay
- **Animated Player Character** - Sprite animations with weapon-based variants (melee/gun)
- **Smooth Dash System** - Speed boost mechanic with visual effects
- **Dual Weapon System** - Switch between melee and ranged combat
- **Magazine System** - Realistic reload mechanics for guns
- **Enemy Types**:
  - **Turrets** - Moving enemies that shoot bullets on patrol paths
  - **Hunters** - AI enemies with FSM (Finite State Machine) behavior
- **Progression System** - XP, leveling, and 8 different upgrades
- **Pickup System** - Health packs, ammo, and XP orbs
- **Room Progression** - Clear rooms to advance

### Developer Mode
- **Level Creator** - Build custom levels with a visual editor
- **Place Walls** - Create obstacles and cover
- **Place Enemies** - Position turrets and hunters
- **Test Levels** - Instantly playable custom levels
- **Save/Load** - Persistent level storage

## Controls

### Gameplay
- **WASD / Arrow Keys** - Move
- **Shift** - Dash (speed boost)
- **Q** - Switch weapon
- **R** - Reload gun
- **Left Click** - Attack
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
   git clone https://github.com/YOUR_USERNAME/eclipse-protocol.git
   ```
3. Run the game:
   ```bash
   love EclipseProtocol
   ```
   Or drag the `EclipseProtocol` folder onto `love.exe`

### Linux
1. Install LÖVE:
   ```bash
   sudo apt-get install love
   ```
2. Clone and run:
   ```bash
   git clone https://github.com/YOUR_USERNAME/eclipse-protocol.git
   cd eclipse-protocol
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
├── player.lua            # Player system with animations
├── enemy.lua             # Turret enemy system
├── hunter.lua            # Hunter AI enemy
├── weapons.lua           # Weapon and combat system
├── world.lua             # Room generation
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
│   │   └── turret dead.png
│   └── sounds/
│       ├── hit.wav
│       ├── dash.wav
│       └── shoot.wav
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
- **Melee**: 50 damage, close range, visual swing effect
- **Gun**: 20 damage, ranged, 5-bullet magazine, reload required

### Enemy System
- **Turrets**: Move on fixed paths, shoot bullets every 2 seconds
- **Hunters**: Chase player with FSM AI (Idle, Patrol, Chase, Return states)

### Progression
- Gain XP from killing enemies
- Level up to choose from 3 random upgrades
- 8 upgrade types: Health, Regen, Ammo, Multi-Shot, Dash, Speed, Cooldowns, Energy

### Developer Mode
Create custom levels with:
- Walls for obstacles
- Turret placements
- Hunter placements
- Custom spawn points
- Custom exit doors

## Technologies

- **Engine**: LÖVE (Love2D) 11.4
- **Language**: Lua 5.1
- **Animation**: anim8 library by kikito
- **Graphics**: Pixel art sprites

## Credits

- **Game Engine**: [LÖVE](https://love2d.org/)
- **Animation Library**: [anim8](https://github.com/kikito/anim8) by kikito

## License

This project is open source and available under the MIT License.

## Development

### Phase 1 Features
- Basic player movement
- Single enemy type
- Collision detection
- Health system
- Basic UI
- Sound effects

### Phase 2 Features
- Hunter enemy with FSM
- Energy and dash system
- Full game state system
- Difficulty scaling
- Sound system
- Procedural rooms
- Sprite animations

### Current Features
- Animated sprites (player + enemies)
- Turret shooting system
- Developer mode / level creator
- Magazine reload system
- Complete progression system

## Contributing

Feel free to fork this project and submit pull requests!

## Support

For issues or questions, please open an issue on GitHub.

---

**Enjoy playing Eclipse Protocol!** 🎮
