local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- Buy New Boats
RegisterServerEvent('oss_boats:BuyBoat')
AddEventHandler('oss_boats:BuyBoat', function(data)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local maxBoats = Config.maxBoats

    MySQL.Async.fetchAll('SELECT * FROM boats WHERE identifier = ? AND charid = ?', {identifier, charid},
    function(boats)
        if #boats >= maxBoats then
            VORPcore.NotifyRightTip(_source, _U("boatLimit") .. maxBoats .. _U("boats"), 5000)
            TriggerClientEvent('oss_boats:BoatMenu', _source)
            return
        end
        if data.IsCash then
            local charCash = Character.money
            local cashPrice = data.Cash

            if charCash >= cashPrice then
                Character.removeCurrency(0, cashPrice)
            else
                VORPcore.NotifyRightTip(_source, _U("shortCash"), 5000)
                TriggerClientEvent('oss_boats:BoatMenu', _source)
                return
            end
        else
            local charGold = Character.gold
            local goldPrice = data.Gold

            if charGold >= goldPrice then
                Character.removeCurrency(1, goldPrice)
            else
                VORPcore.NotifyRightTip(_source, _U("shortGold"), 5000)
                TriggerClientEvent('oss_boats:BoatMenu', _source)
                return
            end
        end
        TriggerClientEvent('oss_boats:SetBoatName', _source, data)
    end)
end)

RegisterServerEvent('oss_boats:SaveNewBoat')
AddEventHandler('oss_boats:SaveNewBoat', function(data, name)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.execute('INSERT INTO boats (identifier, charid, name, model) VALUES (?, ?, ?, ?)', {identifier, charid, tostring(name), data.ModelB},
        function(done)
    end)
end)

-- Get List of Owned Boats
RegisterServerEvent('oss_boats:GetMyBoats')
AddEventHandler('oss_boats:GetMyBoats', function()
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier

    MySQL.Async.fetchAll('SELECT * FROM boats WHERE identifier = ? AND charid = ?', {identifier, charid},
    function(boats)
        TriggerClientEvent('oss_boats:ReceiveBoatsData', _source, boats)
    end)
end)

-- Sell Owned Boats
RegisterServerEvent('oss_boats:SellBoat')
AddEventHandler('oss_boats:SellBoat', function(boatId, boatName, shopId)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local modelBoat = nil

    MySQL.Async.fetchAll('SELECT * FROM boats WHERE identifier = ? AND charid = ?', {identifier, charid},
    function(boats)
        for i = 1, #boats do
            if tonumber(boats[i].id) == tonumber(boatId) then
                modelBoat = boats[i].model
                MySQL.Async.execute('DELETE FROM boats WHERE identifier = ? AND charid = ? AND id = ?', {identifier, charid, boatId},
                function(done)
                end)
            end
        end

        for _,boatModels in pairs(Config.boatShops[shopId].boats) do
            for model,boatConfig in pairs(boatModels) do
                if model ~= "boatType" then
                    if model == modelBoat then
                        local sellPrice = boatConfig.sellPrice
                        Character.addCurrency(0, sellPrice)
                        VORPcore.NotifyRightTip(_source, _U("soldBoat") .. boatName .. _U("frcash") .. sellPrice, 5000)
                    end
                end
            end
        end
        TriggerClientEvent('oss_boats:BoatMenu', _source)
    end)
end)

-- Prevent NPC Boat Spawns
if Config.blockNpcBoats then
    AddEventHandler('entityCreating', function(entity)
        if GetEntityType(entity) == 2 then
            if GetVehicleType(entity) == "boat" then
                if GetEntityPopulationType(entity) ~= 7 and GetEntityPopulationType(entity) ~= 8 then
                    CancelEvent()
                end
            end
        end
    end)
end

-- Check Player Job and Job Grade
RegisterServerEvent('oss_boats:getPlayerJob')
AddEventHandler('oss_boats:getPlayerJob', function()
    local _source = source
    if _source then
        local Character = VORPcore.getUser(_source).getUsedCharacter
        local CharacterJob = Character.job
        local CharacterGrade = Character.jobGrade
        TriggerClientEvent('oss_boats:sendPlayerJob', _source, CharacterJob, CharacterGrade)
    end
end)

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