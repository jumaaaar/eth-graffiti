
local PlayerData = {gang = "none", gang_rank = "none"}

RegisterNetEvent('esx:setGang')
AddEventHandler('esx:setGang', function(gang, gang_rank)
    PlayerData.gang = gang
    PlayerData.gang_rank = gang_rank
end)



--- GET YOUR OWN GANG HERE

function GetPlayerGang()
    return PlayerData.gang
end
function fetchGraffitiData(pEntity)
	for k, v in pairs(Config.Graffitis) do
		if pEntity == v.entity then
			return v
		end
	end
	
	return false
end 

function GetInfo(model)
    return Config.Sprays[model]
end

function CheckRay(coords, direction)
    local rayEndPoint = coords + direction * 1000.0
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(coords.x, coords.y, coords.z, rayEndPoint.x, rayEndPoint.y, rayEndPoint.z, 19, PlayerPedId(), 7)
    local retval, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultEx(rayHandle)
    return surfaceNormal, GetEntityType(entityHit) == 0
end

function GetRotation(coords, direction)
    local normal, typed = CheckRay(coords + vector3(0.0, 0.0, 0.0), direction + vector3(0.0, 0.0, 0.0))
    local camLookPosition = coords - normal * 10

    SetCamCoord(rotationCam, coords.x, coords.y, coords.z)
    PointCamAtCoord(rotationCam, camLookPosition.x, camLookPosition.y, camLookPosition.z)
    SetCamActive(rotationCam, true)

    Citizen.Wait(0)

    local rot = GetCamRot(rotationCam, 2)
    SetCamActive(rotationCam, false)

    return rot, typed
end

function SetRotation(entity)
    Citizen.CreateThread(function()
        local direction = RotationToDirection(GetGameplayCamRot())
        local rotation, hastype = GetRotation(GetEntityCoords(PlayerPedId()), direction)
        SetEntityRotation(entity, rotation.x, rotation.y, rotation.z)

        local markerCoords = GetOffsetFromEntityInWorldCoords(placingObject, 0, -0.1, 0)
        
        if canPlace and (rotation.x < -1.0 or rotation.x > 1.0) then 
            canPlace = false 
        end

        if canPlace and GetEntityHeightAboveGround(entity) < 2.0 then
            canPlace = false
        end

        if canPlace and not hastype then
            canPlace = false
        end

        DrawMarker(6, markerCoords.x, markerCoords.y, markerCoords.z, 0.0, 0.0, 0.0, rotation.x, rotation.y, rotation.z, 0.8, 0.3, 0.8, canPlace and 0 or 255, canPlace and 255 or 0, 0, 255, false, false, false, false, false, false, false)
    end)
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance, 
        y = cameraCoord.y + direction.y * distance, 
        z = cameraCoord.z + direction.z * distance
    }

    local a, b, c, d, e = GetShapeTestResult(StartExpensiveSynchronousShapeTestLosProbe(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))

    return b, c, e
end

function RotationToDirection(rotation)
	local adjustedRotation = {
        x = (math.pi / 180) * rotation.x, 
        y = (math.pi / 180) * rotation.y, 
        z = (math.pi / 180) * rotation.z
    }

	return vector3(-math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), math.sin(adjustedRotation.x))
end

function CheckShopData(gang, playerGang)
    if not gang then
        return false
    else
        if PlayerData then
            if gang == playerGang then
                return false
            else
                return true
            end
        else
            return true
        end
    end
end



function PlaceGraffiti(model, cb)
    local ped = PlayerPedId()

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local centerCoords = GetEntityCoords(ped) + (GetEntityForwardVector(ped) * 1.5)
    placingObject = CreateObject(model, centerCoords, false, false)

    if placingObject then
        isPlacing = true

        CreateThread(function()
            while isPlacing do
                lib.showTextUI('[E] to Spray', { position = 'left-center'})
                local ped = PlayerPedId()
                local hit, coords, entity = RayCastGamePlayCamera(10.0)
                local graffiti = GetClosestGraffiti(100.0)
                local blacklist = GetInBlacklistedZone()

                DisableControlAction(0, 24, true)
                DisableControlAction(0, 44, true)
                DisableControlAction(0, 142, true)
                DisablePlayerFiring(ped, true)

                SetEntityCoords(placingObject, coords.x, coords.y, coords.z)
                SetRotation(placingObject)

                if IsControlJustPressed(0, 177) then
                    DeleteEntity(placingObject)
                    placingObject = nil
                    isPlacing = false
                    canPlace = false
                    lib.hideTextUI()
                    cb(false)
                end

                if graffiti then
                    ESX.ShowNotification("error", 5000 ,'Someone has already put graffiti nearby.' , "SYSTEM")
                    DeleteEntity(placingObject)
                    placingObject = nil
                    isPlacing = false
                    canPlace = false
                    lib.hideTextUI()
                    cb(false)
                end

                if blacklist then
                    ESX.ShowNotification("error", 5000 , 'You cannot put graffiti on this place.' , "SYSTEM")
                    DeleteEntity(placingObject)
                    placingObject = nil
                    isPlacing = false
                    canPlace = false
                    lib.hideTextUI()
                    cb(false)
                end

                if hit == 1 then
                    canPlace = true
                    if canPlace and IsControlJustPressed(0, 38) then
                        local entityCoords = GetEntityCoords(placingObject)
                        local entityRotation = GetEntityRotation(placingObject)
                        DeleteEntity(placingObject)
                        placingObject = nil
                        isPlacing = false
                        lib.hideTextUI()
                        cb(true, entityCoords, entityRotation)
                    end

                    if placingObject and #(GetEntityCoords(ped) - GetEntityCoords(placingObject)) > 5.0 then
                        lib.hideTextUI()
                        canPlace = false
                    end
                else
                    lib.hideTextUI()
                    canPlace = false
                end
                Wait(0)
            end
        end)
    else
        cb(false)
    end
end

function SprayingAnim()
    local ped = PlayerPedId()

    RequestAnimDict('switch@franklin@lamar_tagging_wall')
    while not HasAnimDictLoaded('switch@franklin@lamar_tagging_wall') do 
        Wait(0)
    end

    RequestModel('prop_cs_spray_can')
    while not HasModelLoaded('prop_cs_spray_can') do 
        Wait(0)
    end

    RequestNamedPtfxAsset('scr_playerlamgraff')
    while not HasNamedPtfxAssetLoaded('scr_playerlamgraff') do 
        Wait(0)
    end

    local coords = GetEntityCoords(ped)
    sprayingCan = CreateObject('prop_cs_spray_can', coords.x, coords.y, coords.z, true, true)
    AttachEntityToEntity(sprayingCan, ped, GetPedBoneIndex(ped, 28422), 0, -0.01, -0.012, 0, 0, 0, true, true, false, false, 2, true)

    CreateThread(function()
        TaskPlayAnim(ped, 'switch@franklin@lamar_tagging_wall', 'lamar_tagging_wall_loop_lamar', 8.0, -8.0, -1, 8192, 0.0, false, false, false)
        Wait(5500)
        TaskPlayAnim(ped, 'switch@franklin@lamar_tagging_wall', 'lamar_tagging_exit_loop_lamar', 8.0, -2.0, -1, 8193, 0.0, false, false, false)
    
        if not sprayingParticle then
            UseParticleFxAssetNextCall('scr_playerlamgraff')
            sprayingParticle = StartParticleFxLoopedOnEntity('scr_lamgraff_paint_spray', sprayingCan, 0, 0, 0, 0, 0, 0, 1.0, false, false, false)
            SetParticleFxLoopedColour(sprayingParticle, 1.0, 0.5, 0.5, 0)
            SetParticleFxLoopedAlpha(sprayingParticle, 0.25)
        end
    end)
end

function GetClosestGraffiti(distance)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    for k,v in pairs(Config.Graffitis) do
        if v then
            if #(coords - v.coords) < distance then
                return v.id, v.gang, v.coords
            end
        end
    end

    return nil
end

exports("GetClosestGraffiti" , GetClosestGraffiti)

function GetInBlacklistedZone()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    for k,v in pairs(Config.BlacklistedZones) do
        if v then
            if #(coords - v.coords) < v.radius then
                return true
            end
        end
    end

    return false
end

function getLocation(coords)			
	local zoneName = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
	local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z, currentStreetHash, intersectStreetHash)
	local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
	local intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
			
	return currentStreetName .. ', ' .. zoneName
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    for k,v in pairs(Config.Graffitis) do
        if v.entity then
            if DoesEntityExist(v.entity) then
                DeleteEntity(v.entity)
            end
        end
    end
end)
