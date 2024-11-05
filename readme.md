# Gang-Enabled Spraypaint System for ESX
A unique gang-based spray paint system that allows players to showcase their gang’s presence and dominance on the map. Built to support OX features, this system includes territory management, protection rewards, and detailed notifications to enhance gang interactions and rivalries.

Special thanks to kalajiqta for the original inspiration fromt [qb-graffiti](https://github.com/Kalajiqta/qb-graffiti)

# Requirements
* [ox_lib](https://github.com/overextended/ox_lib)
* [ox_inventory](https://github.com/overextended/ox_inventory)
* [eth-gangs](https://github.com/jumaaaar/eth-gangs)(You can use your own gang script)

# Features
* OX-Ready Integration: Compatible with OX targeting, inventory, and menu systems.
* Gang-Restricted Spraypaint: Spraypaint can only be used if it belongs to your gang, ensuring only authorized members can mark territory.
* Territory Blips: Each spray creates a blip on the map, clearly indicating gang territory and enhancing gang presence.
* Radius Detection: Ensures sprays can only be placed within a specific radius, maintaining balance and preventing indiscriminate tagging.
* Protection Rewards: Gangs can claim rewards from stores under their control. Rewards are exclusive to gang-controlled areas, creating an incentive to capture and defend territories.
* Spray Removal Alerts: If a rival gang attempts to remove your gang’s spray, your gang receives a notification, allowing you to defend your territory actively.

# Installation
* ensure to have spray-props to server.cfg
* ensure to add eth-graffiti to you server.cfg

# Export
Use these exports to integrate and extend functionality within your existing scripts:
* exports['eth-graffiti']:GetClosestGraffiti(radius)
-- Returns: sprayId, gang, closest graffiti

# [SHOWCASE](https://youtu.be/3MfrgI7eHgY)