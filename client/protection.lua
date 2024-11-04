Citizen.CreateThread(function()
    while true do
        local waitTime = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i, area in pairs(Config.ProtectionArea) do
            local distance = #(playerCoords - area.coords)
            if distance < 0.8 then
                waitTime = 0 
                local graffiti, graffitiGang, graffitiCoords = GetClosestGraffiti(100.0)
                
                if graffiti then
                    local graffitiDistance = #(area.coords - graffitiCoords)
                    if graffitiGang == GetPlayerGang() then
                        ESX.DrawText3D(area.coords.x, area.coords.y, area.coords.z, '[E] Protection Rewards')

                        if IsControlJustPressed(0, 38) then
                            TriggerServerEvent("eth-graffiti:claimProtectionReward", i)
                        end
                    else
                        ESX.DrawText3D(area.coords.x, area.coords.y, area.coords.z, "This area is protected by another gang.")
                    end
                else
                    ESX.DrawText3D(area.coords.x, area.coords.y, area.coords.z, "This area is not protected by any gang.")
                end
            elseif  distance < 10.0 then
                waitTime = 0 
                DrawMarker(29, area.coords.x, area.coords.y, area.coords.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
            end
        end

        Wait(waitTime)
    end
end)
