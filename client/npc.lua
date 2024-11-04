
ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function(xPlayer, isNew, skin)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)



CreateThread(function()
    RequestModel(GetHashKey(Config.Ped.Model))
    while not HasModelLoaded(GetHashKey('a_m_m_rurmeth_01')) do
        Wait(0)
    end

    local blip = AddBlipForCoord(Config.Ped.Location)

    SetBlipSprite(blip, 72)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 17)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Graffiti Shop')
    EndTextCommandSetBlipName(blip)

    -- Create the NPC
    local npc = CreatePed(4, GetHashKey('a_m_m_rurmeth_01'), vector3(109.24, -1090.58, 28.3), 347.5, false, false)
    
    SetPedFleeAttributes(npc, 0, 0)
    SetEntityInvincible(npc , true)
    FreezeEntityPosition(npc, true)
    SetPedDiesWhenInjured(npc, false)
    SetPedDropsWeaponsWhenDead(npc, false)
    SetBlockingOfNonTemporaryEvents(npc, true)

    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'graffiti_shop',
            event = 'eth-graffiti:graffitiShop',
            icon = 'fa-solid fa-palette',
            label = 'Graffiti Shop',
            distance = 3.0
        }
    })

    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if ESX.PlayerLoaded  then
            for k, v in pairs(Config.Graffitis) do
                local information = GetInfo(tonumber(v.model))

                if information then
                    if #(coords - v.coords) < 100.0 then
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

                    if information.blip == true then
                        if not DoesBlipExist(v.blip) then
                            v.blip = AddBlipForRadius(v.coords, 100.0)
                            SetBlipAlpha(v.blip, 100)
                            SetBlipColour(v.blip, information.blipcolor)
                        end
                    end
                end
            end
        end

        Wait(1000)
    end
end)




RegisterNetEvent('eth-graffiti:graffitiShop', function()
    local PlayerGang = GetPlayerGang()
    local graffitiMenu = {}
    if ESX.PlayerLoaded  then
        for k, v in pairs(Config.Sprays) do
            graffitiMenu[#graffitiMenu + 1] = {
                title = v.name .. ' - ' .. v.price .. '$',
                description = '',
                icon = 'fa-solid fa-brush',
                disabled = CheckShopData(v.gang, PlayerGang),
                onSelect = function()
                    TriggerServerEvent('eth-graffiti:Graffitishop', {
                        model = k,
                        name = v.name,
                        gang = v.gang,
                        price = v.price
                    })
                end
            }
        end
        lib.registerContext({
            id = 'graffiti_shop_menu',
            title = 'Graffiti Shop',
            icon = 'fa-solid fa-palette',
            options = graffitiMenu
        })

        lib.showContext('graffiti_shop_menu')
    end
end)
