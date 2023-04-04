# Boats v2

#### Description
This is a boating script for RedM servers using the [VORP framework](https://github.com/VORPCORE). Boats can be bought and sold through shops. There are 6 shops configured, more shop locations may be added using the `config.lua` file.

#### Features
- Buy and sell boats through the boat shops
- Cash or gold may be used for payments
- Shop hours may be set individually for each shop or disabled to allow the shop to remain open
- Shop blips are colored and changeable per shop location
- Blips can change color reflecting if shop is open, closed or job locked
- Shop access can be limited by job and jobgrade
- Boats can be returned at any shop location via prompt or remotely using the in-boat menu after parking/beaching the boat somewhere
- In-boat menu for anchor operation and remote boat return
- Config setting to prevent the spawning of NPC boats
- Boats can be driven across the map without sinking
- Give your boat a special name at purchase time
- Set a max number of boats per player in the config

#### Configuration
Settings can be changed in the `config.lua` file. Here is an example of one shop:
```lua
    lagras = {
        shopName = "Lagras Boats", -- Name of Shop on Menu
        promptName = "Lagras Boats", -- Text Below the Prompt Button
        blipAllowed = true, -- Turns Blips On / Off
        blipName = "Lagras Boats", -- Name of the Blip on the Map
        blipSprite = 2005921736, -- 2005921736 = Canoe / -1018164873 = Tugboat
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32", -- Shop Open - Default: White - Blip Colors Shown Below
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10", -- Shop Closed - Default: Red - Blip Colors Shown Below
        blipColorJob = "BLIP_MODIFIER_MP_COLOR_23", -- Shop Job Locked - Default: Yellow - Blip Colors Shown Below
        npcx = 2123.95, npcy = -551.63, npcz = 41.53, npch = 113.62, -- Blip and NPC Positions
        boatx = 2122.8, boaty = -544.76, boatz = 40.55, boath = 46.69, -- Boat Spawn and Return Positions
        playerx = 2121.31, playery = -552.65, playerz = 42.7, playerh = 316.34, -- Player Return Teleport Position
        boatCamx = 2123.95, boatCamy = -551.63, boatCamz = 41.53, -- Camera Location to View Boat When In-Menu
        distanceShop = 2.0, -- Distance from NPC to Get Menu Prompt
        distanceReturn = 6.0, -- Distance from Shop to Get Return Prompt
        npcAllowed = true, -- Turns NPCs On / Off
        npcModel = "A_M_M_UniBoatCrew_01", -- Sets Model for NPCs
        allowedJobs = {}, -- Empty, Everyone Can Use / Insert Job to limit access - ex. "police"
        jobGrade = 0, -- Enter Minimum Rank / Job Grade to Access Shop
        shopHours = false, -- If You Want the Shops to Use Open and Closed Hours
        shopOpen = 7, -- Shop Open Time / 24 Hour Clock
        shopClose = 21, -- Shop Close Time / 24 Hour Clock
        boats = { -- Change ONLY These Values: boatType, label, cashPrice, goldPrice and sellPrice
            {
                boatType = "Canoes",
                ["canoetreetrunk"] = { label = "Dugout Canoe",  cashPrice = 25,   goldPrice = 1,  sellPrice = 15  },
                ["canoe"]          = { label = "Canoe",         cashPrice = 45,   goldPrice = 2,  sellPrice = 25  },
                ["pirogue"]        = { label = "Pirogue Canoe", cashPrice = 60,   goldPrice = 3,  sellPrice = 35  }
            },
            {
                boatType = "Rowboats",
                ["skiff"]          = { label = "Skiff",         cashPrice = 100,  goldPrice = 5,  sellPrice = 60  },
                ["rowboat"]        = { label = "Rowboat",       cashPrice = 150,  goldPrice = 7,  sellPrice = 90  },
                ["rowboatSwamp"]   = { label = "Swamp Rowboat", cashPrice = 125,  goldPrice = 6,  sellPrice = 75  }
            },
            {
                boatType = "Steamboats",
                ["boatsteam02x"]   = { label = "Steamboat",     cashPrice = 550,  goldPrice = 25, sellPrice = 330, },
                ["keelboat"]       = { label = "Keelboat",      cashPrice = 800,  goldPrice = 40, sellPrice = 480, }
            }
        }
    },
```

#### Dependencies
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [menuapi](https://github.com/outsider31000/menuapi)

#### Installation
- Ensure that the dependancies are added and started
- Add `oss_boats` folder to your resources folder
- Add `ensure oss_boats` to your `resources.cfg`
- Run the included database file `boats.sql`

#### Credits
- kcrp_boats
- vorp_stores
- Hobbs
- SavSin

#### GitHub
- https://github.com/JusCampin/oss_boats