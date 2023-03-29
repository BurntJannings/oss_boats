local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- Prompts (start)
local OpenShops
local CloseShops
local OpenReturn
local CloseReturn
local ShopPrompt1 = GetRandomIntInRange(0, 0xffffff)
local ShopPrompt2 = GetRandomIntInRange(0, 0xffffff)
local ReturnPrompt1 = GetRandomIntInRange(0, 0xffffff)
local ReturnPrompt2 = GetRandomIntInRange(0, 0xffffff)
--Prompts (end)

local PlayerJob
local JobName
local JobGrade
local InMenu = false
local IsBoating = false
local isAnchored
local OwnedData = {}
local MyBoat
MenuData = {}

TriggerEvent("menuapi:getData", function(call)
    MenuData = call
end)

-- Start Boats
Citizen.CreateThread(function()
    ShopOpen()
    ShopClosed()
    ReturnOpen()
    ReturnClosed()

    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local sleep = true
        local dead = IsEntityDead(player)
        local hour = GetClockHours()

        if InMenu == false and not dead then
            for shopId, shopConfig in pairs(Config.boatShops) do
                if shopConfig.shopHours then
                    if hour >= shopConfig.shopClose or hour < shopConfig.shopOpen then
                        if Config.blipAllowedClosed then
                            if not Config.boatShops[shopId].BlipHandle and shopConfig.blipAllowed then
                                AddBlip(shopId)
                            end
                        else
                            if Config.boatShops[shopId].BlipHandle then
                                RemoveBlip(Config.boatShops[shopId].BlipHandle)
                                Config.boatShops[shopId].BlipHandle = nil
                            end
                        end
                            if Config.boatShops[shopId].BlipHandle then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.boatShops[shopId].BlipHandle, GetHashKey(shopConfig.blipColorClosed)) -- BlipAddModifier
                            end
                            if shopConfig.NPC then
                                DeleteEntity(shopConfig.NPC)
                                DeletePed(shopConfig.NPC)
                                SetEntityAsNoLongerNeeded(shopConfig.NPC)
                                shopConfig.NPC = nil
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                        local coordsBoat = vector3(shopConfig.boatx, shopConfig.boaty, shopConfig.boatz)
                        local distanceShop = #(coordsDist - coordsShop)
                        local distanceBoat = #(coordsDist - coordsBoat)

                        if (distanceShop <= shopConfig.distanceShop) and not IsPedInAnyBoat(player) then
                            sleep = false
                            local shopClosed = CreateVarString(10, 'LITERAL_STRING', shopConfig.shopName .. _U("closed"))
                            PromptSetActiveGroupThisFrame(ShopPrompt2, shopClosed)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, CloseShops) then -- UiPromptHasStandardModeCompleted

                                Wait(100)
                                VORPcore.NotifyRightTip(shopConfig.shopName .. _U("hours") .. shopConfig.shopOpen .. _U("to") .. shopConfig.shopClose .. _U("hundred"), 5000)
                            end
                        elseif (distanceBoat <= shopConfig.distanceReturn) and IsPedInAnyBoat(player) then
                            sleep = false
                            local returnClosed = CreateVarString(10, 'LITERAL_STRING', shopConfig.shopName .. _U("closed"))
                            PromptSetActiveGroupThisFrame(ReturnPrompt2, returnClosed)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, CloseReturn) then -- UiPromptHasStandardModeCompleted

                                Wait(100)
                                VORPcore.NotifyRightTip(shopConfig.shopName .. _U("hours") .. shopConfig.shopOpen .. _U("to") .. shopConfig.shopClose .. _U("hundred"), 5000)
                            end
                        end
                    elseif hour >= shopConfig.shopOpen then
                        if not Config.boatShops[shopId].BlipHandle and shopConfig.blipAllowed then
                            AddBlip(shopId)
                        end
                        if not shopConfig.NPC and shopConfig.npcAllowed then
                            SpawnNPC(shopId)
                        end
                        if not next(shopConfig.allowedJobs) then
                            if Config.boatShops[shopId].BlipHandle then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.boatShops[shopId].BlipHandle, GetHashKey(shopConfig.blipColorOpen)) -- BlipAddModifier
                            end
                            local coordsDist = vector3(coords.x, coords.y, coords.z)
                            local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                            local coordsBoat = vector3(shopConfig.boatx, shopConfig.boaty, shopConfig.boatz)
                            local distanceShop = #(coordsDist - coordsShop)
                            local distanceBoat = #(coordsDist - coordsBoat)

                            if (distanceShop <= shopConfig.distanceShop) and not IsPedInAnyBoat(player) then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                                PromptSetActiveGroupThisFrame(ShopPrompt1, shopOpen)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted

                                    MainMenu(shopId)
                                    DisplayRadar(false)
                                    TaskStandStill(player, -1)
                                end
                            elseif (distanceBoat <= shopConfig.distanceReturn) and IsPedInAnyBoat(player) then
                                sleep = false
                                local returnOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                                PromptSetActiveGroupThisFrame(ReturnPrompt1, returnOpen)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted

                                        ReturnBoat(shopId)
                                end
                            end
                        else
                            if Config.boatShops[shopId].BlipHandle then
                                Citizen.InvokeNative(0x662D364ABF16DE2F, Config.boatShops[shopId].BlipHandle, GetHashKey(shopConfig.blipColorJob)) -- BlipAddModifier
                            end
                            local coordsDist = vector3(coords.x, coords.y, coords.z)
                            local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                            local coordsBoat = vector3(shopConfig.boatx, shopConfig.boaty, shopConfig.boatz)
                            local distanceShop = #(coordsDist - coordsShop)
                            local distanceBoat = #(coordsDist - coordsBoat)

                            if (distanceShop <= shopConfig.distanceShop) and not IsPedInAnyBoat(player) then
                                sleep = false
                                local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                                PromptSetActiveGroupThisFrame(ShopPrompt1, shopOpen)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted

                                    TriggerServerEvent("oss_boats:getPlayerJob")
                                    Wait(200)
                                    if PlayerJob then
                                        if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                            if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                                MainMenu(shopId)
                                                DisplayRadar(false)
                                                TaskStandStill(player, -1)
                                            else
                                                VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
                                            end
                                        else
                                            VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
                                    end
                                end
                            elseif (distanceBoat <= shopConfig.distanceReturn) and IsPedInAnyBoat(player) then
                                sleep = false
                                local returnOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                                PromptSetActiveGroupThisFrame(ReturnPrompt1, returnOpen)

                                if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted

                                    ReturnBoat(shopId)
                                end
                            end
                        end
                    end
                else
                    if not Config.boatShops[shopId].BlipHandle and shopConfig.blipAllowed then
                        AddBlip(shopId)
                    end
                    if not shopConfig.NPC and shopConfig.npcAllowed then
                        SpawnNPC(shopId)
                    end
                    if not next(shopConfig.allowedJobs) then
                        if Config.boatShops[shopId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.boatShops[shopId].BlipHandle, GetHashKey(shopConfig.blipColorOpen)) -- BlipAddModifier
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                        local coordsBoat = vector3(shopConfig.boatx, shopConfig.boaty, shopConfig.boatz)
                        local distanceShop = #(coordsDist - coordsShop)
                        local distanceBoat = #(coordsDist - coordsBoat)

                        if (distanceShop <= shopConfig.distanceShop) and not IsPedInAnyBoat(player) then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                            PromptSetActiveGroupThisFrame(ShopPrompt1, shopOpen)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted

                                MainMenu(shopId)
                                DisplayRadar(false)
                                TaskStandStill(player, -1)
                            end
                        elseif (distanceBoat <= shopConfig.distanceReturn) and IsPedInAnyBoat(player) then
                            sleep = false
                            local returnOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                            PromptSetActiveGroupThisFrame(ReturnPrompt1, returnOpen)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted

                                ReturnBoat(shopId)
                            end
                        end
                    else
                        if Config.boatShops[shopId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.boatShops[shopId].BlipHandle, GetHashKey(shopConfig.blipColorJob)) -- BlipAddModifier
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsShop = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz)
                        local coordsBoat = vector3(shopConfig.boatx, shopConfig.boaty, shopConfig.boatz)
                        local distanceShop = #(coordsDist - coordsShop)
                        local distanceBoat = #(coordsDist - coordsBoat)

                        if (distanceShop <= shopConfig.distanceShop) and not IsPedInAnyBoat(player) then
                            sleep = false
                            local shopOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                            PromptSetActiveGroupThisFrame(ShopPrompt1, shopOpen)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenShops) then -- UiPromptHasStandardModeCompleted

                                TriggerServerEvent("oss_boats:getPlayerJob")
                                Wait(200)
                                if PlayerJob then
                                    if CheckJob(shopConfig.allowedJobs, PlayerJob) then
                                        if tonumber(shopConfig.jobGrade) <= tonumber(JobGrade) then
                                            MainMenu(shopId)
                                            DisplayRadar(false)
                                            TaskStandStill(player, -1)
                                        else
                                            VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
                                        end
                                    else
                                        VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U("needJob") .. JobName .. " " .. shopConfig.jobGrade,5000)
                                end
                            end
                        elseif (distanceBoat <= shopConfig.distanceReturn) and IsPedInAnyBoat(player) then
                            sleep = false
                            local returnOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                            PromptSetActiveGroupThisFrame(ReturnPrompt1, returnOpen)

                            ReturnBoat(shopId)
                        end
                    end
                end
            end
        end
        if sleep then
            Citizen.Wait(1000)
        end
    end
end)

-- Main Boats Menu
function MainMenu(shopId)
    MenuData.CloseAll()
    InMenu = true
    local elements = {
        {
            label = _U("buyBoat"),
            value = "buy",
            desc = _U("newBoat")
        },
        {
            label = _U("own"),
            value = "own",
            desc = _U("owned")
        }
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
    {
        title = Config.boatShops[shopId].shopName,
        subtext = _U("mainMenu"),
        align = "top-left",
        elements = elements,
    },
    function(data, menu)
        if data.current == "backup" then
            _G[data.trigger]()
        end
        if data.current.value == "buy" then
            BuyMenu(shopId)
        end
        if data.current.value == "own" then
            
            TriggerServerEvent('oss_boats:GetOwnedBoats', shopId)
        end
    end,
    function(data, menu)
        menu.close()
        InMenu = false
        ClearPedTasksImmediately(PlayerPedId())
        DisplayRadar(true)
    end)
end

-- Buy Boats Menu
function BuyMenu(shopId)
    MenuData.CloseAll()
    InMenu = true
    local player = PlayerPedId()
    local elements = {}

    for boat, boatConfig in pairs(Config.boatShops[shopId].boats) do
        elements[#elements + 1] = {
            label = boatConfig.boatName,
            value = boat,
            desc = _U("price") .. boatConfig.buyPrice .. " " .. boatConfig.currencyType,
            info = boatConfig,
        }
    end
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
    {
        title = Config.boatShops[shopId].shopName,
        subtext = _U("buyBoat"),
        align = "top-left",
        elements = elements,
        lastmenu = 'MainMenu',
    },
    function(data, menu)
        if data.current == "backup" then
            _G[data.trigger](shopId)
        end
        if data.current.value then
            local buyData = data.current.info

            TriggerServerEvent('oss_boats:BuyBoat', buyData)
            menu.close()
            InMenu = false
            ClearPedTasksImmediately(player)
            DisplayRadar(true)
        end
    end,
    function(data, menu)
        menu.close()
        InMenu = false
        ClearPedTasksImmediately(player)
        DisplayRadar(true)
    end)
end

-- Menu to Manage Owned Boats at Shop Location
RegisterNetEvent("oss_boats:OwnedBoatsMenu")
AddEventHandler("oss_boats:OwnedBoatsMenu", function(ownedBoats, shopId)
    MenuData.CloseAll()
    InMenu = true
    local elements = {}

    for boat, ownedBoatData in pairs(ownedBoats) do
        elements[#elements + 1] = {
            label = ownedBoatData.name,
            value = boat,
            desc = _U("chooseBoat"),
            info = ownedBoatData,
        }
    end
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
    {
        title = Config.boatShops[shopId].shopName,
        subtext = _U("own"),
        align = "top-left",
        elements = elements,
        lastmenu = 'MainMenu',
    },
    function(data, menu)
        if data.current == "backup" then
            _G[data.trigger](shopId)
        end
        OwnedData = data.current.info
        if data.current.value then
            BoatMenu(shopId)
        end
    end,
    function(data, menu)
        menu.close()
        InMenu = false
        ClearPedTasksImmediately(PlayerPedId())
        DisplayRadar(true)
    end)
end)

-- Menu to Launch, Sell or Transfer Owned Boats
function BoatMenu(shopId)
    MenuData.CloseAll()
    InMenu = true
    local boatName = OwnedData.name
    local boatModel = OwnedData.model
    local boatData = Config.boatShops[shopId].boats[boatModel]
    local currencyType = boatData.currencyType
    local sellPrice = boatData.sellPrice
    local player = PlayerPedId()
    local descSell
    if currencyType == "cash" then
        descSell = _U("sell") .. boatName .. _U("frcash2") .. sellPrice

    elseif currencyType == "gold" then
        descSell = _U("sell") .. boatName .. _U("fr2") .. sellPrice .. _U("ofgold2")
    end

    local elements = {
        {
            label = _U("launch"),
            value = "launch",
            desc = _U("launchBoat") .. boatName
        },
        {
            label = _U("sellBoat"),
            value = "sell",
            desc = descSell
        }
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi' .. shopId,
    {
        title = Config.boatShops[shopId].shopName,
        subtext = boatName,
        align = "top-left",
        elements = elements,
        lastmenu = 'MainMenu',
    },
    function(data, menu)
        if data.current == "backup" then
            _G[data.trigger](shopId)
        end
        if data.current.value == "launch" then

            menu.close()
            InMenu = false
            ClearPedTasksImmediately(player)
            DisplayRadar(true)
            SpawnBoat(shopId)

        elseif data.current.value == "sell" then

            TriggerServerEvent('oss_boats:SellBoat', OwnedData, boatData)
            menu.close()
            InMenu = false
            ClearPedTasksImmediately(player)
            DisplayRadar(true)
        end
    end,
    function(data, menu)
        menu.close()
        InMenu = false
        ClearPedTasksImmediately(player)
        DisplayRadar(true)
    end)
end

-- Boat Anchor Operation and Boat Return at Non-Shop Locations
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if IsControlJustReleased(0, Config.optionKey) then
            if IsPedInAnyBoat(PlayerPedId()) and IsBoating == true then
                    BoatOptionsMenu()
            else
                return
            end
        end
    end
end)

function BoatOptionsMenu()
    MenuData.CloseAll()
    InMenu = true
    local player = PlayerPedId()
    local elements = {
        {
            label = _U("anchorMenu"),
            value = "anchor",
            desc = _U("anchorAction")
        },
        {
            label = _U("returnMenu"),
            value = "return",
            desc = _U("returnAction")
        }
    }
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi', {
        title    = _U("boatMenu"),
        subtext  = _U("boatSubMenu"),
        align    = "top-left",
        elements = elements,
    }, function(data, menu)
        if data.current.value == "anchor" then
            if IsPedInAnyBoat(player) then
                local playerBoat = GetVehiclePedIsIn(player, true)
                if not isAnchored then
                    SetBoatAnchor(playerBoat, true)
                    SetBoatFrozenWhenAnchored(playerBoat, true)
                    isAnchored = true
                    VORPcore.NotifyRightTip(_U("anchorDown"),4000)
                else
                    SetBoatAnchor(playerBoat, false)
                    isAnchored = false
                    VORPcore.NotifyRightTip(_U("anchorUp"),4000)
                end
            end
            menu.close()
            InMenu = false
        elseif data.current.value == "return" then
            TaskLeaveVehicle(player, MyBoat, 0)
            menu.close()
            InMenu = false
            IsBoating = false
            Wait(15000)
            DeleteEntity(MyBoat)
        end
    end,
    function(data, menu)
        menu.close()
        InMenu = false
        ClearPedTasksImmediately(player)
        DisplayRadar(true)
    end)
end

-- Spawn New or Owned Boat
function SpawnBoat(shopId)
    if MyBoat then
        DeleteEntity(MyBoat)
    end
    local player = PlayerPedId()
    local name = OwnedData.name
    local model = OwnedData.model
    local boatConfig = Config.boatShops[shopId]
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end
    MyBoat = CreateVehicle(model, boatConfig.boatx, boatConfig.boaty, boatConfig.boatz, boatConfig.boath, true, false)
    SetVehicleOnGroundProperly(MyBoat)
    SetModelAsNoLongerNeeded(model)
    SetEntityInvincible(MyBoat, 1)
    DoScreenFadeOut(500)
    Wait(500)
    SetPedIntoVehicle(player, MyBoat, -1)
    Wait(500)
    DoScreenFadeIn(500)
    local boatBlip = Citizen.InvokeNative(0x23F74C2FDA6E7C61, -1749618580, MyBoat) -- BlipAddForEntity
    SetBlipSprite(boatBlip, GetHashKey("blip_canoe"), true)
    Citizen.InvokeNative(0x9CB1A1623062F402, boatBlip, name) -- SetBlipName
    IsBoating = true
    VORPcore.NotifyRightTip(_U("boatMenuTip"),4000)
end

-- Return Boat Using Prompt at Shop Location
function ReturnBoat(shopId)
    local player = PlayerPedId()
    local shopConfig = Config.boatShops[shopId]
    local coords = vector3(shopConfig.playerx, shopConfig.playery, shopConfig.playerz)
    TaskLeaveVehicle(player, MyBoat, 0)
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoords(player, coords.x, coords.y, coords.z)
    Wait(500)
    DoScreenFadeIn(500)
    IsBoating = false
    DeleteEntity(MyBoat)
end

-- Prevents Boat from Sinking
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        if IsPedInAnyBoat(player) then
            SetPedResetFlag(player, 364, 1)
        end
    end
end)

-- Menu Prompts
function ShopOpen()
    local str = _U("shopPrompt")
    OpenShops = PromptRegisterBegin()
    PromptSetControlAction(OpenShops, Config.shopKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(OpenShops, str)
    PromptSetEnabled(OpenShops, 1)
    PromptSetVisible(OpenShops, 1)
    PromptSetStandardMode(OpenShops, 1)
    PromptSetGroup(OpenShops, ShopPrompt1)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, OpenShops, true) -- UiPromptSetUrgentPulsingEnabled
    PromptRegisterEnd(OpenShops)
end

function ShopClosed()
    local str = _U("shopPrompt")
    CloseShops = PromptRegisterBegin()
    PromptSetControlAction(CloseShops, Config.shopKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(CloseShops, str)
    PromptSetEnabled(CloseShops, 1)
    PromptSetVisible(CloseShops, 1)
    PromptSetStandardMode(CloseShops, 1)
    PromptSetGroup(CloseShops, ShopPrompt2)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, CloseShops, true) -- UiPromptSetUrgentPulsingEnabled
    PromptRegisterEnd(CloseShops)
end

function ReturnOpen()
    local str = _U("returnPrompt")
    OpenReturn = PromptRegisterBegin()
    PromptSetControlAction(OpenReturn, Config.returnKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(OpenReturn, str)
    PromptSetEnabled(OpenReturn, 1)
    PromptSetVisible(OpenReturn, 1)
    PromptSetStandardMode(OpenReturn, 1)
    PromptSetGroup(OpenReturn, ReturnPrompt1)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, OpenReturn, true) -- UiPromptSetUrgentPulsingEnabled
    PromptRegisterEnd(OpenReturn)
end

function ReturnClosed()
    local str = _U("returnPrompt")
    CloseReturn = PromptRegisterBegin()
    PromptSetControlAction(CloseReturn, Config.returnKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(CloseReturn, str)
    PromptSetEnabled(CloseReturn, 1)
    PromptSetVisible(CloseReturn, 1)
    PromptSetStandardMode(CloseReturn, 1)
    PromptSetGroup(CloseReturn, ReturnPrompt2)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, CloseReturn, true) -- UiPromptSetUrgentPulsingEnabled
    PromptRegisterEnd(CloseReturn)
end

-- Blips
function AddBlip(shopId)
    local shopConfig = Config.boatShops[shopId]
    if shopConfig.blipAllowed then
        shopConfig.BlipHandle = N_0x554d9d53f696d002(1664425300, shopConfig.npcx, shopConfig.npcy, shopConfig.npcz) -- BlipAddForCoords
        SetBlipSprite(shopConfig.BlipHandle, shopConfig.blipSprite, 1)
        SetBlipScale(shopConfig.BlipHandle, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, shopConfig.BlipHandle, shopConfig.blipName) -- SetBlipName
    end
end

-- NPCs
function SpawnNPC(shopId)
    local shopConfig = Config.boatShops[shopId]
    LoadModel(shopConfig.npcModel)
    if shopConfig.npcAllowed then
        local npc = CreatePed(shopConfig.npcModel, shopConfig.npcx, shopConfig.npcy, shopConfig.npcz, shopConfig.npch, false, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
        SetEntityCanBeDamaged(npc, false)
        SetEntityInvincible(npc, true)
        Wait(500)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        Config.boatShops[shopId].NPC = npc
    end
end

function LoadModel(npcModel)
    local model = GetHashKey(npcModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(100)
    end
end

-- Check if Player has Job
function CheckJob(allowedJob, playerJob)
    for _, jobAllowed in pairs(allowedJob) do
        JobName = jobAllowed
        if JobName == playerJob then
            return true
        end
    end
    return false
end

RegisterNetEvent("oss_boats:sendPlayerJob")
AddEventHandler("oss_boats:sendPlayerJob", function(Job, grade)
    PlayerJob = Job
    JobGrade = grade
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if InMenu == true then
        ClearPedTasksImmediately(PlayerPedId())
        PromptDelete(OpenShops)
        PromptDelete(CloseShops)
        PromptDelete(OpenReturn)
        PromptDelete(CloseReturn)
        MenuData.CloseAll()
    end

    if MyBoat then
        DeleteEntity(MyBoat)
    end

    for _, shopConfig in pairs(Config.boatShops) do
        if shopConfig.BlipHandle then
            RemoveBlip(shopConfig.BlipHandle)
        end
        if shopConfig.NPC then
            DeleteEntity(shopConfig.NPC)
            DeletePed(shopConfig.NPC)
            SetEntityAsNoLongerNeeded(shopConfig.NPC)
        end
    end
end)
