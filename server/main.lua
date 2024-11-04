ESX = exports['es_extended']:getSharedObject()

lib.callback.register("eth-graffiti:getGangCounts", function(source, gang)
    return tonumber(getGangCount(gang))
end)


CreateThread(function()
    MySQL.query('SELECT `key`, `owner`, `model`, `coords`, `rotation` FROM `graffitis`', {}, function(result)
        if result and #result > 0 then
            for _, v in pairs(result) do
                if v then
                    local coords = json.decode(v.coords)
                    local rotation = json.decode(v.rotation)
                    local graffitiData = {
                        id = v.key,
                        model = tostring(v.model),
                        coords = vector3(tonumber(string.format("%.2f", coords.x)), tonumber(string.format("%.2f", coords.y)), tonumber(string.format("%.2f", coords.z))),
                        rotation = vector3(tonumber(string.format("%.2f", rotation.x)), tonumber(string.format("%.2f", rotation.y)), tonumber(string.format("%.2f", rotation.z))),
                        gang = v.owner,
                        blipcolor = GetGangBlipColor(v.owner)
                    }
                    Config.Graffitis[v.key] = graffitiData
                end
            end
        end
    end)
end)

lib.callback.register("eth-graffiti:getGraffitiData", function(source, gang)
    return Config.Graffitis
end)


RegisterServerEvent("eth-graffiti:notifyGangMember", function(gang, location, coords)
	local message = string.format("Homies, heads up! Our graffiti in %s is being removed. Time to rally and defend our art!", location)
	local subject = GetGangLabel(gang)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        local PlayerGang = GetPlayerGang(playerId)
        if PlayerGang == gang then
            NotifyGangMembers(xPlayer.source, subject, message)
        end
    end
end)

RegisterServerEvent('eth-graffiti:addServerGraffiti', function(model, coords, rotation, gang)
    local src = source
    local player = ESX.GetPlayerFromId(src)

    if player then
        local id = generateGraffitiID()

        if gang then

            local roundedCoords = vector3(tonumber(string.format("%.2f", coords.x)), tonumber(string.format("%.2f", coords.y)), tonumber(string.format("%.2f", coords.z)))
            local roundedRotation = vector3(tonumber(string.format("%.2f", rotation.x)), tonumber(string.format("%.2f", rotation.y)), tonumber(string.format("%.2f", rotation.z)))

            MySQL.insert('INSERT INTO `graffitis` (`key`, `owner`, `model`, `coords`, `rotation`) VALUES (@key, @owner, @model, @coords, @rotation)', {
                ['@key'] = id,
                ['@owner'] = gang,
                ['@model'] = tostring(model),
                ['@coords'] = json.encode(roundedCoords),
                ['@rotation'] = json.encode(roundedRotation)
            }, function(key)

                local graffitiData = {
                    id = id,
                    model = tostring(model),
                    coords = coords,
                    rotation = rotation,
                    gang = gang,
                    blipcolor = GetGangBlipColor(gang)
                }
    
                Config.Graffitis[id] = graffitiData        
                TriggerClientEvent('eth-graffiti:updateGraffitiData', -1, id, Config.Graffitis[id], true)
            end)
        end
    end
end)


RegisterServerEvent('eth-graffiti:removeServerGraffitiByID', function(id)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
	
	if not Config.Graffitis[id] then return end

    MySQL.query('DELETE from graffitis WHERE `key` = ?', {
        id
    }, function(response)
        if response then
            Config.Graffitis[id] = nil	
            TriggerClientEvent('eth-graffiti:updateGraffitiData', -1, id, {}, false)
        end
    end)
end)


RegisterServerEvent('eth-graffiti:Graffitishop', function(data)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    if Player then
		local moneyCount = exports.ox_inventory:Search(src, 'count', 'money')
		if moneyCount >= data.price then
			exports.ox_inventory:RemoveItem(src, 'money', data.price)
			exports.ox_inventory:AddItem(src, 'spraycan', 1, {
                model = data.model,
                name = data.name,
				gang = data.gang
            })
			--Notify(src, 'success', 'You bought a graffiti can for $'..data.price..' with the name: '..data.name)		
		else
            local morePrice = data.price - moneyCount
			--Notify(src, 'success', 'You not have enough money. You need more '..morePrice)							
		end
    end
end)


-- ITEMS

ESX.RegisterUsableItem('spraycan', function(source, item, info)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    if Player then
        if info.metadata then			
            TriggerClientEvent('eth-graffiti:placeGraffiti', source, info.metadata.gang, info.metadata.model, info.slot)
        else
			Notify(src, 'error', 'Seems like I can\'t do that at the moment...', 5000, 'red')     	       
        end
    end
end)

ESX.RegisterUsableItem('sprayremover', function(source, item, info)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    if Player then
        TriggerClientEvent('eth-graffiti:removeClosestGraffiti', source, info.slot)
    end
end)


RegisterServerEvent('eth-graffiti:removeServerItem', function(item, amount, slot)
    local src = source
    local Player = ESX.GetPlayerFromId(src)

    if Player then
        if slot then
			exports.ox_inventory:RemoveItem(Player.source, item, amount, nil, slot)
        else
            exports.ox_inventory:RemoveItem(Player.source, item, amount)
        end
    end
end)