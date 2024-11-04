function generateGraffitiID()
	local id = math.random(111, 999).."-ETH-" .. math.random(111, 999)
	
	while Config.Graffitis[id] ~= nil do
		id = math.random(111, 999).."-ETH-" .. math.random(111, 999)
	end
	
	return id
end

local function getGraffiti(gangName)
	for k, v in pairs(Config.Sprays) do
		if v.gang == gangName then
			return k, v
		end
	end
	
	return false
end 



---- GANG FUNCTIONS

function GetPlayerGang(player)
   return exports['eth-gangs']:SVGetPlayerGang(player)
end

function GetGangLabel(playerGangName)
   return exports['eth-gangs']:SVGetGangLabel(playerGangName)
end

function GetGangBlipColor(playerGang)
    if Config.BlipColors[playerGang] then
        return Config.BlipColors[playerGang].color
    end
    return 0
end

function NotifyGangMembers(source, subject, message)
    TriggerClientEvent('eth-graffiti:Notify', source, 'inform' , 10000, message , subject)
end

