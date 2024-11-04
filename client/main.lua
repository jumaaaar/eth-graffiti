
ESX = exports['es_extended']:getSharedObject()

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

	local curGang = GetPlayerGang()

	if gangName ~= curGang then
		Notify("error", 5000 , "Where did I find this spray can..." , "SYSTEM")
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

				TriggerServerEvent('eth-graffiti:removeServerItem', 'spraycan', 1, slot)				
				TriggerServerEvent('eth-graffiti:addServerGraffiti', model, coords, rotation, gangName)
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

RegisterNetEvent('eth-graffiti:placeGraffiti', function(gangName, model, slot)
	useSprayCan(gangName, model, slot)
end)

RegisterNetEvent('eth-graffiti:removeClosestGraffiti', function(slot)
    local ped = PlayerPedId()
    local graffiti, gang, coords = GetClosestGraffiti(5.0)
	
	if not graffiti then return end
	
	local location = getLocation(coords)
	
	TriggerServerEvent('eth-graffiti:notifyGangMember', gang, location, coords)
	
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
		TriggerServerEvent('eth-graffiti:removeServerItem', 'sprayremover', 1, slot)
		TriggerServerEvent('eth-graffiti:removeServerGraffitiByID', graffiti)
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

local blipBlinking = false

RegisterNetEvent('eth-graffiti:updateGraffitiBlip', function(coords)
    CreateThread(function()
        local blip = AddBlipForRadius(coords, Config.GraffitiBlipRadius) 
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


AddEventHandler('esx:onPlayerSpawn', function()
	local data = lib.callback.await("eth-graffiti:getGraffitiData", false)
	Config.Graffitis = data
end)

RegisterNetEvent('eth-graffiti:updateGraffitiData', function(id, data, bool)
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
	local data = lib.callback.await("eth-graffiti:getGraffitiData", false)
	Config.Graffitis = data
end)
