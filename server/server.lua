local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
-- Buy New Boats
RegisterServerEvent('oss_boats:BuyBoat')
AddEventHandler('oss_boats:BuyBoat', function(buyData, location)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local name = buyData.boatName
    local model = buyData.boatModel
    local currencyType = buyData.currencyType
    local buyPrice = buyData.buyPrice
    if currencyType == "cash" then
        local money = Character.money
        if money >= buyPrice then
            Character.removeCurrency(0, buyPrice)
            VORPcore.NotifyRightTip(_source, _U("bought") .. name .. _U("frcash") .. buyPrice, 5000)
        else
            VORPcore.NotifyRightTip(_source, _U("shortCash"), 5000)
            return
        end
    elseif currencyType == "gold" then
        local gold = Character.gold
        if gold >= buyPrice then
            Character.removeCurrency(1, buyPrice)
            VORPcore.NotifyRightTip(_source, _U("bought") .. name .. _U("fr") .. buyPrice .. _U("ofgold"), 5000)
        else
            VORPcore.NotifyRightTip(_source, _U("shortGold"), 5000)
            return
        end
    end
    MySQL.Async.execute('INSERT INTO boats (identifier, charid, name, model, location) VALUES (?, ?, ?, ?, ?)', {identifier, charid, name, model, location},
    function(done)
    end)
end)
-- Get List of Owned Boats
RegisterServerEvent('oss_boats:GetOwnedBoats')
AddEventHandler('oss_boats:GetOwnedBoats', function(location, shopId)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    MySQL.Async.fetchAll('SELECT * FROM boats WHERE identifier = ? AND charid = ? AND location = ?', {identifier, charid, location},
    function(result)
        if result[1] then
            TriggerClientEvent("oss_boats:OwnedBoatsMenu", _source, result, shopId)
        else
            VORPcore.NotifyRightTip(_source, _U("noBoats"), 5000)
        end
    end)
end)
-- Sell Owned Boats
RegisterServerEvent('oss_boats:SellBoat')
AddEventHandler('oss_boats:SellBoat', function(ownedData, boatData)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local name = ownedData.name
    local model = ownedData.model
    local location = ownedData.location
    local sellPrice = boatData.sellPrice
    local currencyType = boatData.currencyType
    if currencyType == "cash" then
        Character.addCurrency(0, sellPrice)
        VORPcore.NotifyRightTip(_source, _U("sold") .. name .. _U("frcash") .. sellPrice, 5000)
    elseif currencyType == "gold" then
        Character.addCurrency(1, sellPrice)
        VORPcore.NotifyRightTip(_source, _U("sold") .. name .. _U("fr") .. sellPrice .. _U("ofgold"), 5000)
    end
    MySQL.Async.execute('DELETE FROM boats WHERE identifier = ? AND charid = ? AND location = ? AND name = ? AND model = ? LIMIT 1', {identifier, charid, location, name, model},
    function(done)
    end)
end)
-- Transfer Owned Boats Between Shops
RegisterServerEvent('oss_boats:TransferBoat')
AddEventHandler('oss_boats:TransferBoat', function(ownedData, transferLocation, menuTransfer, boatData, shopName)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    local name = ownedData.name
    local model = ownedData.model
    local location = ownedData.location
    if menuTransfer then
        local currencyType = boatData.currencyType
        local transferPrice = boatData.transferPrice
        if currencyType == "cash" then
            local money = Character.money
            if money >= transferPrice then
                Character.removeCurrency(0, transferPrice)
                VORPcore.NotifyRightTip(_source, _U("transferred") .. name .. _U("to") .. shopName .. _U("frcash") .. transferPrice, 5000)
            else
                VORPcore.NotifyRightTip(_source, _U("shortCash"), 5000)
                return
            end
        elseif currencyType == "gold" then
            local gold = Character.gold
            if gold >= transferPrice then
                Character.removeCurrency(1, transferPrice)
                VORPcore.NotifyRightTip(_source, _U("transferred") .. name .. _U("to") .. shopName .. _U("fr") .. transferPrice .. _U("ofgold"), 5000)
            else
                VORPcore.NotifyRightTip(_source, _U("shortGold"), 5000)
                return
            end
        end
    end
    MySQL.Async.execute('UPDATE boats SET location = ? WHERE identifier = ? AND charid = ? AND location = ? AND name = ? AND model = ? LIMIT 1', {transferLocation, identifier, charid, location, name, model},
    function(done)
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
