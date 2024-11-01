rotationCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', 0)
sprayingParticle = nil
placingObject = nil
sprayingCan = nil
isPlacing = false
canPlace = false
isLoaded = false


CreateThread( function()
    exports.ox_inventory:displayMetadata({
        model = "Model",
        name = "Name",
        gang = 'Gang'
    })
end)



function useSprayCan(gangName, model, slot)
    local ped = cache.ped
    if isPlacing then
        return
    end

	local identifier = ESX.PlayerData.identifier
	local curGang = ESX.PlayerData.gang
	print(gangName, curGang)
	if gangName ~= curGang then
		ESX.ShowNotification("error", 5000 , "Where did I find this spray can..." , "SYSTEM")
		return
	end
	
	PlaceGraffiti(model, function(result, coords, rotation)
		if result then
	
			local tempAlpha = 0
			local tempSpray = CreateObjectNoOffset(model, coords, false, false, false)
			

			SetEntityRotation(tempSpray, rotation.x, rotation.y, rotation.z)
			FreezeEntityPosition(tempSpray, true)
			SetEntityAlpha(tempSpray, 0, false)

			CreateThread(function()
				while tempAlpha < 255 do
					tempAlpha = tempAlpha + 51
					SetEntityAlpha(tempSpray, tempAlpha, false)
					Wait(8000)
				end
			end)

			SprayingAnim()

			if lib.progressBar({
					duration = 40000,
					label = 'Spraying with paint',
					useWhileDead = false,
					canCancel = true,
					disable = {
						move = true,
					},
					anim = {},

				}) then
				StopAnimTask(ped, 'switch@franklin@lamar_tagging_wall', 'lamar_tagging_exit_loop_lamar', 1.0)
				StopParticleFxLooped(sprayingParticle, true)
				DeleteObject(sprayingCan)
				DeleteObject(tempSpray)
				sprayingParticle = nil
				sprayingCan = nil

				TriggerServerEvent('eth-gangs:server:removeServerItem', 'spraycan', 1, slot)				
				TriggerServerEvent('eth-gangs:client:addServerGraffiti', model, coords, rotation, gangName)
			else
				StopAnimTask(ped, 'switch@franklin@lamar_tagging_wall', 'lamar_tagging_exit_loop_lamar', 1.0)
				StopParticleFxLooped(sprayingParticle, true)
				DeleteObject(sprayingCan)
				DeleteObject(tempSpray)
				sprayingParticle = nil
				sprayingCan = nil
			end
		end
	end)	
end

RegisterNetEvent('eth-gangs:client:placeGraffiti', function(gangName, model, slot)
	useSprayCan(gangName, model, slot)
end)

RegisterNetEvent('eth-gangs:client:removeClosestGraffiti', function(slot)
    local ped = PlayerPedId()
    local graffiti, gang, coords = GetClosestGraffiti(5.0)
	
	if not graffiti then return end
	
	local location = getLocation(coords)
	
	TriggerServerEvent('eth-gangs:server:notifyGangMember', gang, location, coords)
	
	if lib.progressBar({
			duration = 240 * 1000,
			label = 'Washing the wall',
			useWhileDead = false,
			canCancel = true,
			disable = {
				move = true,
			},
			anim = {
				scenario = 'WORLD_HUMAN_MAID_CLEAN',
			},

		}) then
		ClearPedTasks(ped)
		TriggerServerEvent('eth-gangs:server:removeServerItem', 'sprayremover', 1, slot)
		TriggerServerEvent('eth-gangs:server:removeServerGraffitiByID', graffiti)
	else
		ClearPedTasks(ped)
	end
end)

CreateThread(function()
    while true do
		if next(Config.Graffitis) then
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)		
			for k,v in pairs(Config.Graffitis) do
				--local information = GetInfo(tonumber(v.model))
				--if information then
					if #(coords - v.coords) < 20.0 then
						if not DoesEntityExist(v.entity) then
							RequestModel(tonumber(v.model))
							while not HasModelLoaded(tonumber(v.model)) do
								Wait(0)
							end
							v.entity = CreateObjectNoOffset(tonumber(v.model), v.coords, false, false)
							SetEntityRotation(v.entity, v.rotation.x, v.rotation.y, v.rotation.z)
							FreezeEntityPosition(v.entity, true)
						end
					else
						if DoesEntityExist(v.entity) then
							DeleteEntity(v.entity)
							v.entity = nil
						end
					end

					if not DoesBlipExist(v.blip) then
						v.blip = AddBlipForRadius(v.coords, 50.0)
						SetBlipAlpha(v.blip, 100)
						SetBlipColour(v.blip, v.blipcolor)
					end
				--end
			end
		end
        Wait(1000)
    end
end)

AddEventHandler('eth-gangs:client:openCloset', function()
	TriggerEvent('illenium-appearance:client:openCloset', true, 'outfit')
end)

local blipBlinking = false

RegisterNetEvent('eth-gangs:client:updateGraffitiBlip', function(coords)
    CreateThread(function()
        local blip = AddBlipForRadius(coords, 100.0) 
        SetBlipColour(blip, 1) 
		
        local blinkInterval = 5000 -- every 5 seconds
        blipBlinking = true

        while blipBlinking do
            SetBlipAlpha(blip, 100) 
            Wait(blinkInterval) 

            SetBlipAlpha(blip, 0) 
            Wait(blinkInterval)
        end
    end)
    
    Wait(10 * 60000) 
    blipBlinking = false
end)



RegisterNetEvent('eth-gangs:client:graffitiShop', function()
    local graffitiMenu = {}
        for k,v in pairs(Config.Sprays) do
			graffitiMenu[#graffitiMenu+1] = {
				title = v.name .. ' - ' .. v.price .. '$',
				server = true,
				description = "",
				icon = 'fa-solid fa-brush',
				event = "eth-gangs:server:graffitiShop", 
				data = { model = k, name = v.name, price = v.price, gang = v.gang },
				distance = -1.0,
				close = true
			}		
        end
		
		exports['ecstasy-menu']:CreateMenu(graffitiMenu, true)
end)

AddEventHandler('esx:onPlayerSpawn', function()
	local data = lib.callback.await("eth-gangs:server:getGraffitiData", false)
	Config.Graffitis = data
end)

RegisterNetEvent('eth-gangs:client:updateGraffitiData', function(id, data, bool)
    local graffiti = Config.Graffitis[id]

    if graffiti then
        if DoesEntityExist(graffiti.entity) then
            DeleteEntity(graffiti.entity)
        end

        if DoesBlipExist(graffiti.blip) then
            RemoveBlip(graffiti.blip)
        end
    end

    if bool then
        Config.Graffitis[id] = data
    else
        Config.Graffitis[id] = nil
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end    
    
    Wait(2000)
	local data = lib.callback.await("eth-gangs:server:getGraffitiData", false)
	Config.Graffitis = data
	
   --[[ local graffitiMenu = {}
        for k,v in pairs(Config.Sprays) do
			graffitiMenu[#graffitiMenu+1] = {
				title = v.name .. ' - ' .. v.price .. '$',
				server = true,
				description = "",
				icon = 'fa-solid fa-brush',
				event = "eth-gangs:server:graffitiShop", 
				data = { model = k, name = v.name, price = v.price, gang = v.gang },
				distance = -1.0,
				close = true
			}		
        end
		
		exports['ecstasy-menu']:CreateMenu(graffitiMenu, true)]]
end)
