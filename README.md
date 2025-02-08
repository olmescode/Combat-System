# Combat System

A combat system originally developed for Monsta's BoBoiBoy game. This system provides dynamic fighting mechanics with element-based attacks, originally designed for the 3D animated series where the main character can control seven different elements.

<p align="center">
  <img src="https://github.com/user-attachments/assets/54f7285f-3854-40bc-9f03-365a8ae201b5">
</p>

## Features
- Two distinct combat systems (FightingMoves1 & FightingMoves2)
- Sophisticated server-side and client-side validation
- Synchronized visual effects replication across all clients
- Actor-based task desynchronization for improved performance

### Combat Actions Directory
The `Combat Actions` folder contains all available attack types:
```lua
Combat Actions/
├── MeleeAttacks/
├── RangedAttacks/
└── ElementalAttacks/
```
<p align="center">
  <img src="https://github.com/user-attachments/assets/3fe91496-f8c1-40d8-ba84-3708c28daaeb" width="40%">
  <img src="https://github.com/user-attachments/assets/abff902f-b428-4019-b8e8-b90d6e200da0" width="40%">
</p>

### Initialization Flow
1. Client/Server entry points (`ClientCombatScript.client.luau`/`ServerCombatScript.server.luau`)
2. System scans and loads all combat actions in the CombatActions directory
3. Each action is instantiated and registered with the ActionManager
4. ActionManager binds keyboard/gamepad inputs to corresponding actions

### Validation System
The validation system operates on both client and server to ensure fair combat:

**Client Validation**
1. When a combat action is triggered, the client performs initial validation
2. A blockcast check identifies potential valid targets
3. If a valid target is found, hit data is transmitted to the server

**Server Validation**
1. Server receives and processes incoming hit data
2. Validates hit position and distance calculations
3. Performs obstruction detection via raycasting
4. If all validation checks pass, damage is applied to the target

This dual-layer validation ensures combat integrity and prevents exploitation.

## Installation
1. Clone the repository
2. Import into your Roblox project
3. Configure necessary assets:
    - Import required animations
    - Sound effects
    - Setup particle effects and visual elements

## Usage Examples
Creating a new Combat Action:
```lua
-- Example Combat Action structure
local Network = require(CombatSystem.Modules.Network)

local NewAttack = {}
NewAttack.__index = NewAttack


function NewAttack.new(tool)
    local self = setmetatable({}, NewAttack)
    self._tool = tool
    self.name = "NewAttack"
    self.energyCost = 10
    self.attacking = false
    return self
end

function NewAttack:startAction()
    -- Attack logic here

    Network.fireServer(Network.RemoteEvents.CombatHit, self.name, hitCharacter, hitPosition)
end

function NewAttack:endAction()
    self.attacking = false
end

return NewAttack
```

## Credits
- Animation assets based on BoBoiBoy™, used with permission from Monsta Studios
- External modules used:
    - [Signal Module](https://create.roblox.com/store/asset/15239217296/Signal)
    - [Network Library](https://create.roblox.com/marketplace/asset/8341695391/)
    - [Action Manager](https://create.roblox.com/store/asset/13549359972/Action-Manager)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
