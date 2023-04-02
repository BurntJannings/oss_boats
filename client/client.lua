local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
-- Start Prompts
local OpenShops
local CloseShops
local OpenReturn
local CloseReturn
local ShopPrompt1 = GetRandomIntInRange(0, 0xffffff)
local ShopPrompt2 = GetRandomIntInRange(0, 0xffffff)
local ReturnPrompt1 = GetRandomIntInRange(0, 0xffffff)
local ReturnPrompt2 = GetRandomIntInRange(0, 0xffffff)
-- End Prompts

local SpawnPoint = {}
local BoatShopName
local ShowroomBoat_entity
local MyBoat_entity
local PlayerJob
local JobName
local JobGrade
local InMenu = false
local IsBoating = false
local isAnchored
--local OwnedData = {}
local MyBoat
--local MyBoatId
local MyBoatModel
local MyBoatName
local ShopId
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

                                    OpenMenu(shopId)
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
                                                OpenMenu(shopId)
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

                                OpenMenu(shopId)
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
                                            OpenMenu(shopId)
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

function OpenMenu(shopId)
    InMenu = true
    ShopId = shopId

    shopConfig = Config.boatShops[ShopId]
    BoatShopName = shopConfig.shopName
    SpawnPoint = {x = shopConfig.boatx, y = shopConfig.boaty, z = shopConfig.boatz, h = shopConfig.boath}

    createCamera()

    SendNUIMessage({
        action = "show",
        shopData = getShopData(),
        location = BoatShopName
    })
    SetNuiFocus(true, true)

    TriggerServerEvent('oss_boats:GetMyBoats')
end

function getShopData()
    local ret = Config.boatShops[ShopId].boats
    return ret
end

RegisterNetEvent('oss_boats:ReceiveBoatsData')
AddEventHandler('oss_boats:ReceiveBoatsData', function(dataBoats)

    SendNUIMessage({ myBoatsData = dataBoats })
end)

RegisterNUICallback("LoadBoat", function(data)
    local boatModel = data.boatModel

    if MyBoat_entity ~= nil then
        DeleteEntity(MyBoat_entity)
        MyBoat_entity = nil
    end

    local modelHash = GetHashKey(boatModel)
    if IsModelValid(modelHash) then
        if not HasModelLoaded(modelHash) then
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Citizen.Wait(10)
            end
        end
    end

    if ShowroomBoat_entity ~= nil then
        DeleteEntity(ShowroomBoat_entity)
        ShowroomBoat_entity = nil
    end

    ShowroomBoat_entity = CreateVehicle(modelHash, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z, SpawnPoint.h, false, false)
    Citizen.InvokeNative(0x7263332501E07F52, ShowroomBoat_entity, true) -- SetVehicleOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, ShowroomBoat_entity, true) -- FreezeEntityPosition
end)

RegisterNUICallback("BuyBoat", function(data)
    TriggerServerEvent('oss_boats:BuyBoat', data)
end)

RegisterNetEvent('oss_boats:SetBoatName')
AddEventHandler('oss_boats:SetBoatName', function(data)
    print("set boat name")

    SendNUIMessage({ action = "hide" })
    SetNuiFocus(false, false)

    print("menu hidden")
    Wait(200)
    local boatName = ""
    print("local boatname")
	Citizen.CreateThread(function()
        print("enter thread")
		AddTextEntry('FMMC_MPM_NA', "Name your boat:")
        print("name boat")
		DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
		while (UpdateOnscreenKeyboard() == 0) do
			DisableAllControlActions(0)
			Citizen.Wait(0)
		end
		if (GetOnscreenKeyboardResult()) then
            boatName = GetOnscreenKeyboardResult()
            TriggerServerEvent('oss_boats:SaveNewBoat', data, boatName)
            print("show menu next")

            SendNUIMessage({
                action = "show",
                shopData = getShopData(),
                location = BoatShopName
            })
            SetNuiFocus(true, true)
            print("get myboats")
        Wait(1000)
        TriggerServerEvent('oss_boats:GetMyBoats')
		end
    end)
end)

RegisterNUICallback("LoadMyBoat", function(data)
    local boatModel = data.BoatModel

    if ShowroomBoat_entity ~= nil then
        DeleteEntity(ShowroomBoat_entity)
        ShowroomBoat_entity = nil
    end

    if MyBoat_entity ~= nil then
        DeleteEntity(MyBoat_entity)
        MyBoat_entity = nil
    end

    local modelHash = GetHashKey(boatModel)
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(10)
        end
    end

    MyBoat_entity = CreateVehicle(modelHash, SpawnPoint.x, SpawnPoint.y, SpawnPoint.z, SpawnPoint.h, false, false)
    Citizen.InvokeNative(0x7263332501E07F52, MyBoat_entity, true) -- SetVehicleOnGroundProperly
    Citizen.InvokeNative(0x7D9EFB7AD6B19754, MyBoat_entity, true) -- FreezeEntityPosition
end)

RegisterNUICallback("SelectBoat", function(data)
    TriggerServerEvent('oss_boats:GetBoatInfo', tonumber(data.boatID))
end)

RegisterNetEvent('oss_boats:SetBoatInfo')
AddEventHandler('oss_boats:SetBoatInfo', function(model, name)
    MyBoatModel = model
    MyBoatName = name
end)

RegisterNUICallback("LaunchBoat", function()
    if MyBoat then
        DeleteEntity(MyBoat)
    end
    local player = PlayerPedId()
    local boatConfig = Config.boatShops[ShopId]
    RequestModel(MyBoatModel)
    while not HasModelLoaded(MyBoatModel) do
        Wait(100)
    end
    MyBoat = CreateVehicle(MyBoatModel, boatConfig.boatx, boatConfig.boaty, boatConfig.boatz, boatConfig.boath, true, false)
    SetVehicleOnGroundProperly(MyBoat)
    SetModelAsNoLongerNeeded(MyBoatModel)
    SetEntityInvincible(MyBoat, 1)
    DoScreenFadeOut(500)
    Wait(500)
    SetPedIntoVehicle(player, MyBoat, -1)
    Wait(500)
    DoScreenFadeIn(500)
    local boatBlip = Citizen.InvokeNative(0x23F74C2FDA6E7C61, -1749618580, MyBoat) -- BlipAddForEntity
    SetBlipSprite(boatBlip, GetHashKey("blip_canoe"), true)
    Citizen.InvokeNative(0x9CB1A1623062F402, boatBlip, MyBoatName) -- SetBlipName
    IsBoating = true
    VORPcore.NotifyRightTip(_U("boatMenuTip"),4000)
end)

RegisterNUICallback("SellBoat", function(data)
    DeleteEntity(MyBoat_entity)

    local boatId = tonumber(data.boatID)
    TriggerServerEvent('oss_boats:SellBoat', boatId, ShopId)
    Wait(300)

    SendNUIMessage({
        action = "show",
        shopData = getShopData(),
        location = BoatShopName
    })
    TriggerServerEvent('oss_boats:GetMyBoats')
end)

RegisterNUICallback("CloseMenu", function()
    local player = PlayerPedId()

    SendNUIMessage({ action = "hide" })
    SetNuiFocus(false, false)

    SetEntityVisible(player, true)

    if ShowroomBoat_entity ~= nil then
        DeleteEntity(ShowroomBoat_entity)
    end

    if MyBoat_entity ~= nil then
        DeleteEntity(MyBoat_entity)
    end

    DestroyAllCams(true)
    ShowroomBoat_entity = nil
    DisplayRadar(true)
    InMenu = false
    ClearPedTasksImmediately(player)
end)

RegisterNetEvent('oss_boats:BoatMenu')
AddEventHandler('oss_boats:BoatMenu', function()
    if ShowroomBoat_entity ~= nil then
        DeleteEntity(ShowroomBoat_entity)
        ShowroomBoat_entity = nil
    end

    SendNUIMessage({
        action = "show",
        shopData = getShopData(),
        location = BoatShopName
    })
    TriggerServerEvent('oss_boats:GetMyBoats')
end)

function createCamera()
    local shopConfig = Config.boatShops[ShopId]
    local boatCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(boatCam, shopConfig.boatCamx, shopConfig.boatCamy, shopConfig.boatCamz + 1.2 )
    SetCamActive(boatCam, true)
    PointCamAtCoord(boatCam, SpawnPoint.x - 0.5, SpawnPoint.y, SpawnPoint.z)
    DoScreenFadeOut(500)
    Wait(500)
    DoScreenFadeIn(500)
    RenderScriptCams(true, false, 0, 0, 0)
end

RegisterNUICallback("Rotate", function(data)
    local direction = data.RotateBoat

    if direction == "left" then
        Rotation(20)
    elseif direction == "right" then
        Rotation(-20)
    end
end)

function Rotation(dir)
    local ownedBoat = MyBoat_entity
    local shopBoat = ShowroomBoat_entity

    if ownedBoat then
        local ownedRot = GetEntityHeading(ownedBoat) + dir
        SetEntityHeading(ownedBoat, ownedRot % 360)

    elseif shopBoat then
        local shopRot = GetEntityHeading(shopBoat) + dir
        SetEntityHeading(shopBoat, shopRot % 360)
    end
end

function printTable(t)
    local printTable_cache = {}
    local function sub_printTable(t, indent)

        if (printTable_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            printTable_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos,val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t).. " {")
                        sub_printTable(val, indent .. string.rep(" ", string.len(pos)+8))
                        print(indent .. string.rep(" ", string.len(pos)+6 ) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end

    if (type(t) == "table") then
        print(tostring(t) .. " {")
        sub_printTable(t, "  ")
        print("}")
    else
        sub_printTable(t, "  ")
    end
end

--[[function MainMenu(shopId)
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
end]]

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
--[[function SpawnBoat(shopId)
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
end]]

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
