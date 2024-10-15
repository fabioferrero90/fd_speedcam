local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    for k, v in pairs(Config.cams) do
        local CircleZone = CircleZone:Create(vector3(v.coords.x, v.coords.y, v.coords.z), v.dist, {
            name="SpeedZone",
            debugPoly=false,
            useZ = true
        })
        CircleZone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside)
        local pData = QBCore.Functions.GetPlayerData()
        if isPointInside then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            local speed = GetEntitySpeed(veh)
            local seat = GetPedInVehicleSeat(veh, -1)
            if PlayerPedId() == seat then
                if pData.job.type == "leo" and pData.job.onduty or pData.job.type == "ems" and pData.job.onduty then return end
                    local plate = nil
                    if Config.PlateFlipperScript then
                        plate = exports["pd_plate_flipper"]:GetVehiclePlate(veh)
                    else
                        plate = GetVehicleNumberPlateText(veh)
                    end
                    if plate then
                        local kmh = (speed * 3.9500)
                        local billamount = v.billamount
                        if kmh > v.speed then
                            if math.floor(kmh-v.speed) < 30 then
                                billamount = billamount
                            elseif math.floor(kmh-v.speed) > 30 and math.floor(kmh-v.speed) <= 50 then
                                billamount = billamount + math.floor(billamount*0.15)
                            elseif math.floor(kmh-v.speed) > 50 and math.floor(kmh-v.speed) <= 80 then
                                billamount = billamount + math.floor(billamount*0.25)
                            elseif math.floor(kmh-v.speed) > 80 and math.floor(kmh-v.speed) <= 120 then
                                billamount = billamount + math.floor(billamount*0.50)
                            elseif math.floor(kmh-v.speed) > 120 then
                                billamount = billamount + math.floor(billamount*1.00)
                            end
                            local coords = v.coords
                            local streetnamehash = GetStreetNameAtCoord(v.coords.x, v.coords.y, v.coords.z)
                            local streetname = GetStreetNameFromHashKey(streetnamehash)
                            local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
                            TriggerServerEvent('police:server:send:alert:speedcam', coords, streetname, plate)
                            TriggerServerEvent('SpeedCam:BillPlayer', billamount, plate, kmh, vehname )
                        end
                    end
                end
            end
        end)
    end
end)

CreateThread(function()
for k, v in pairs(Config.cams) do
        local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        local blipradius = AddBlipForRadius(v.coords.x, v.coords.y, v.coords.z, 40.0)
        SetBlipSprite(blip, 184)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 5)
        SetBlipColour(blipradius, 5)
        SetBlipAlpha(blipradius, 70)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Locales[Config.Locale].blipname)
        EndTextCommandSetBlipName(blip)
    end
end)