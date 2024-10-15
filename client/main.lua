local QBCore = exports['qb-core']:GetCoreObject()


CreateThread(function()
    for k, v in pairs(Config.WhitelistedJob) do
         wjob = v
    end
end)

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
                    local plate = exports["pd_plate_flipper"]:GetVehiclePlate(veh)
                    if plate then
                        local kmh = (speed * 3.9500)
                        local billammount = v.billammount
                        if kmh > v.speed then
                            if math.floor(kmh-v.speed) < 30 then
                                billammount = billammount
                            elseif math.floor(kmh-v.speed) > 30 and math.floor(kmh-v.speed) <= 50 then
                                billammount = billammount + math.floor(billammount*0.15)
                            elseif math.floor(kmh-v.speed) > 50 and math.floor(kmh-v.speed) <= 80 then
                                billammount = billammount + math.floor(billammount*0.25)
                            elseif math.floor(kmh-v.speed) > 80 and math.floor(kmh-v.speed) <= 120 then
                                billammount = billammount + math.floor(billammount*0.50)
                            elseif math.floor(kmh-v.speed) > 120 then
                                billammount = billammount + math.floor(billammount*1.00)
                            end
                            local coords = v.coords
                            local streetnamehash = GetStreetNameAtCoord(v.coords.x, v.coords.y, v.coords.z)
                            local streetname = GetStreetNameFromHashKey(streetnamehash)
                            local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
                            TriggerServerEvent('police:server:send:alert:speedcam', coords, streetname, plate)
                            TriggerServerEvent('SpeedCam:BillPlayer', billammount, plate, kmh, vehname )
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
        AddTextComponentString("Rilevatore di velocità")
        EndTextCommandSetBlipName(blip)
    end
end)

RegisterNetEvent('alertsounds', function(primary, vehname, streetname, kmh, plate, coords2)
    if QBCore.Functions.GetPlayerData().job.name == wjob then
        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        Wait(100)
        PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
        Wait(100)
        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        Wait(100)
        PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
        TriggerEvent("QBCore:Notify", 'Una ' .. primary .. " " .. vehname .. ' a ' .. streetname .. ' Eccesso di velocita: '  .. math.floor(kmh) ..  ' kmh Targa: '  .. plate .. '')
        local transG = 250
        local blip = AddBlipForCoord(coords2.x, coords2.y)
        SetBlipSprite(blip, 184)
        SetBlipColour(blip, 1)
        SetBlipDisplay(blip, 4)
        SetBlipAlpha(blip, transG)
        SetBlipScale(blip, 1.2)
        SetBlipFlashes(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Veicolo a folle velocita")
        EndTextCommandSetBlipName(blip)
        while transG ~= 0 do
            Wait(180)
            transG = transG - 1
            SetBlipAlpha(blip, transG)
            if transG == 0 then
                SetBlipSprite(blip, 2)
                RemoveBlip(blip)
                return
            end
        end
    end
end)

colorNames = {
    ['0'] = "Metallic Black",
    ['1'] = "Metallic Graphite Black",
    ['2'] = "Metallic Black Steal",
    ['3'] = "Metallic Dark Silver",
    ['4'] = "Metallic Silver",
    ['5'] = "Metallic Blue Silver",
    ['6'] = "Metallic Steel Gray",
    ['7'] = "Metallic Shadow Silver",
    ['8'] = "Metallic Stone Silver",
    ['9'] = "Metallic Midnight Silver",
    ['10'] = "Metallic Gun Metal",
    ['11'] = "Metallic Anthracite Grey",
    ['12'] = "Matte Black",
    ['13'] = "Matte Gray",
    ['14'] = "Matte Light Grey",
    ['15'] = "Util Black",
    ['16'] = "Util Black Poly",
    ['17'] = "Util Dark silver",
    ['18'] = "Util Silver",
    ['19'] = "Util Gun Metal",
    ['20'] = "Util Shadow Silver",
    ['21'] = "Worn Black",
    ['22'] = "Worn Graphite",
    ['23'] = "Worn Silver Grey",
    ['24'] = "Worn Silver",
    ['25'] = "Worn Blue Silver",
    ['26'] = "Worn Shadow Silver",
    ['27'] = "Metallic Red",
    ['28'] = "Metallic Torino Red",
    ['29'] = "Metallic Formula Red",
    ['30'] = "Metallic Blaze Red",
    ['31'] = "Metallic Graceful Red",
    ['32'] = "Metallic Garnet Red",
    ['33'] = "Metallic Desert Red",
    ['34'] = "Metallic Cabernet Red",
    ['35'] = "Metallic Candy Red",
    ['36'] = "Metallic Sunrise Orange",
    ['37'] = "Metallic Classic Gold",
    ['38'] = "Metallic Orange",
    ['39'] = "Matte Red",
    ['40'] = "Matte Dark Red",
    ['41'] = "Matte Orange",
    ['42'] = "Matte Yellow",
    ['43'] = "Util Red",
    ['44'] = "Util Bright Red",
    ['45'] = "Util Garnet Red",
    ['46'] = "Worn Red",
    ['47'] = "Worn Golden Red",
    ['48'] = "Worn Dark Red",
    ['49'] = "Metallic Dark Green",
    ['50'] = "Metallic Racing Green",
    ['51'] = "Metallic Sea Green",
    ['52'] = "Metallic Olive Green",
    ['53'] = "Metallic Green",
    ['54'] = "Metallic Gasoline Blue Green",
    ['55'] = "Matte Lime Green",
    ['56'] = "Util Dark Green",
    ['57'] = "Util Green",
    ['58'] = "Worn Dark Green",
    ['59'] = "Worn Green",
    ['60'] = "Worn Sea Wash",
    ['61'] = "Metallic Midnight Blue",
    ['62'] = "Metallic Dark Blue",
    ['63'] = "Metallic Saxony Blue",
    ['64'] = "Metallic Blue",
    ['65'] = "Metallic Mariner Blue",
    ['66'] = "Metallic Harbor Blue",
    ['67'] = "Metallic Diamond Blue",
    ['68'] = "Metallic Surf Blue",
    ['69'] = "Metallic Nautical Blue",
    ['70'] = "Metallic Bright Blue",
    ['71'] = "Metallic Pfrple Blue",
    ['72'] = "Metallic Spinnaker Blue",
    ['73'] = "Metallic Ultra Blue",
    ['74'] = "Metallic Bright Blue",
    ['75'] = "Util Dark Blue",
    ['76'] = "Util Midnight Blue",
    ['77'] = "Util Blue",
    ['78'] = "Util Sea Foam Blue",
    ['79'] = "Uil Lightning blue",
    ['80'] = "Util Maui Blue Poly",
    ['81'] = "Util Bright Blue",
    ['82'] = "Matte Dark Blue",
    ['83'] = "Matte Blue",
    ['84'] = "Matte Midnight Blue",
    ['85'] = "Worn Dark blue",
    ['86'] = "Worn Blue",
    ['87'] = "Worn Light blue",
    ['88'] = "Metallic Taxi Yellow",
    ['89'] = "Metallic Race Yellow",
    ['90'] = "Metallic Bronze",
    ['91'] = "Metallic Yellow Bird",
    ['92'] = "Metallic Lime",
    ['93'] = "Metallic Champagne",
    ['94'] = "Metallic Pueblo Beige",
    ['95'] = "Metallic Dark Ivory",
    ['96'] = "Metallic Choco Brown",
    ['97'] = "Metallic Golden Brown",
    ['98'] = "Metallic Light Brown",
    ['99'] = "Metallic Straw Beige",
    ['100'] = "Metallic Moss Brown",
    ['101'] = "Metallic Biston Brown",
    ['102'] = "Metallic Beechwood",
    ['103'] = "Metallic Dark Beechwood",
    ['104'] = "Metallic Choco Orange",
    ['105'] = "Metallic Beach Sand",
    ['106'] = "Metallic Sun Bleeched Sand",
    ['107'] = "Metallic Cream",
    ['108'] = "Util Brown",
    ['109'] = "Util Medium Brown",
    ['110'] = "Util Light Brown",
    ['111'] = "Metallic White",
    ['112'] = "Metallic Frost White",
    ['113'] = "Worn Honey Beige",
    ['114'] = "Worn Brown",
    ['115'] = "Worn Dark Brown",
    ['116'] = "Worn straw beige",
    ['117'] = "Brushed Steel",
    ['118'] = "Brushed Black steel",
    ['119'] = "Brushed Aluminium",
    ['120'] = "Chrome",
    ['121'] = "Worn Off White",
    ['122'] = "Util Off White",
    ['123'] = "Worn Orange",
    ['124'] = "Worn Light Orange",
    ['125'] = "Metallic Securicor Green",
    ['126'] = "Worn Taxi Yellow",
    ['127'] = "police car blue",
    ['128'] = "Matte Green",
    ['129'] = "Matte Brown",
    ['130'] = "Worn Orange",
    ['131'] = "Matte White",
    ['132'] = "Worn White",
    ['133'] = "Worn Olive Army Green",
    ['134'] = "Pure White",
    ['135'] = "Hot Pink",
    ['136'] = "Salmon pink",
    ['137'] = "Metallic Vermillion Pink",
    ['138'] = "Orange",
    ['139'] = "Green",
    ['140'] = "Blue",
    ['141'] = "Mettalic Black Blue",
    ['142'] = "Metallic Black Pfrple",
    ['143'] = "Metallic Black Red",
    ['144'] = "hunter green",
    ['145'] = "Metallic Pfrple",
    ['146'] = "Metaillic V Dark Blue",
    ['147'] = "MODSHOP BLACK1",
    ['148'] = "Matte Pfrple",
    ['149'] = "Matte Dark Pfrple",
    ['150'] = "Metallic Lava Red",
    ['151'] = "Matte Forest Green",
    ['152'] = "Matte Olive Drab",
    ['153'] = "Matte Desert Brown",
    ['154'] = "Matte Desert Tan",
    ['155'] = "Matte Foilage Green",
    ['156'] = "DEFAULT ALLOY COLOR",
    ['157'] = "Epsilon Blue",
}
