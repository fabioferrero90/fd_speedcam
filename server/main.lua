
local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('SpeedCam:CheckOwner', function(source, cb, plate)
    local src = source
    local pData = QBCore.Functions.GetPlayer(src)
    MySQL.query('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?',{plate, pData.PlayerData.citizenid}, function(result)
        if result[1] then
            cb(true)
        else
            cb(false)
        end
    end)
end)

RegisterNetEvent('SpeedCam:server:SendBillEmail', function(player, amount, plate, kmh, vehname)
    SetTimeout(math.random(2500, 4000), function()
        local gender = "Sig."
        if player.PlayerData.charinfo.gender == 1 then
            gender = "Sig.ra"
        end
        local charinfo = player.PlayerData.charinfo
        local messaggio = "Gentile " .. gender .. " " .. charinfo.lastname .. ",\n le inviamo questa mail per notificarle una multa per eccesso di velocità,\n\nLei stava viaggiando a una velocità di "..math.floor(kmh).." KM orari, superiore a quella consentita dal codice stradale a bordo del veicolo "..vehname.." targato "..plate..",\n\nLa sanzione è stato addebitata sul suo conto corrente e ammonta a $"..amount..".00 "
        -- exports['qs-smartphone-pro']:sendNewMail(player.PlayerData.source, {
        --     sender = "Dipartimento di Polizia",
        --     subject = "Sanzione per eccesso di velocità",
        --     message = messaggio
        -- })
        -- local phone = exports['qs-smartphone-pro']:GetPhoneNumberFromIdentifier(player.PlayerData.citizenid, false)
        -- exports['qs-smartphone-pro']:sendNotificationOld(phone, {
        --     app = 'mail',
        --     msg = "Sanzione per eccesso di velocità",
        --     head = "Dipartimento di Polizia"
        -- }, false)
        TriggerEvent('qb-log:server:CreateSpeedCamLog', 'autovelox', 'Multa per eccesso di velocità', 'white', 'Il veicolo modello: **'..vehname..'** targato **'..plate..'** è stato segnalato mentre percorreva il tratto di strada sottoposto a sorveglianza dall\'autovelox fisso, alla velocità di **'..math.floor(kmh)..'** Km orari.\n\nIl veicolo risulta intestato al nominativo di **'..charinfo.firstname..' '..charinfo.lastname..'** al quale è stata emessa e addebitata automaticamente una sanzione pari a **$'..amount..'.00**\n\nNel caso di recidività, si consiglia di convocare il cittadino per avvertirlo di possibili provvedimenti a suo carico.')
        local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(player.PlayerData.source) or nil
        if phoneNumber then
        local mailAddress = exports["lb-phone"]:GetEmailAddress(phoneNumber)
            exports["lb-phone"]:SendMail({
                to = mailAddress,
                sender = "Dipartimento di Polizia",
                subject = "Sanzione per eccesso di velocità",
                message = messaggio,
                attachments = {},
            })
        end
    end)
end)

RegisterNetEvent('SpeedCam:server:SendBillEmailOffline', function(citizenid, amount, plate, kmh, vehname)
    MySQL.query('SELECT phone_number FROM `phone_last_phone` WHERE id = citizenid', {citizenid = citizenid}, function(mresult)
        if mresult then 
            for i = 1, #mresult do

                local playerDataquery = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ?', { citizenid })
                local playerData = playerDataquery[1]
                local phoneData = mresult[i]
                local phoneNumber = phoneData.phone_number
                local mailAddress = exports["lb-phone"]:GetEmailAddress(phoneNumber)
                local messaggio = "Gentile " .. playerData.charinfo.gender .. " " .. playerData.charinfo.lastname .. ",\n le inviamo questa mail per notificarle una multa per eccesso di velocità,\n\nLei stava viaggiando a una velocità di "..math.floor(kmh).." KM orari, superiore a quella consentita dal codice stradale a bordo del veicolo "..vehname.." targato "..plate..",\n\nLa sanzione è stato addebitata sul suo conto corrente e ammonta a $"..amount..".00 "

                if mailAddress then
                    exports["lb-phone"]:SendMail({
                        to = mailAddress,
                        sender = "Dipartimento di Polizia",
                        subject = "Sanzione per eccesso di velocità",
                        message = messaggio,
                        attachments = {},
                    })
                    TriggerEvent('qb-log:server:CreateSpeedCamLog', 'autovelox', 'Multa per eccesso di velocità', 'white', 'Il veicolo modello: **'..vehname..'** targato **'..plate..'** è stato segnalato mentre percorreva il tratto di strada sottoposto a sorveglianza dall\'autovelox fisso, alla velocità di **'..math.floor(kmh)..'** Km orari.\n\nIl veicolo risulta intestato al nominativo di **'..playerData["firstname"]..' '..playerData["lastname"]..'** al quale è stata emessa e addebitata automaticamente una sanzione pari a **$'..amount..'.00**\n\nNel caso di recidività, si consiglia di convocare il cittadino per avvertirlo di possibili provvedimenti a suo carico.')
                    print("Notifica Speedcam via mail offline inviata a "..playerData["firstname"].." "..playerData["lastname"])
                else
                    print("Non sono riuscito a trovare la mail del player per inviare la notifica di sanzione via mail, probabilmente il player non ha un account inserito o c'è un problema con il codice")
                end
            end
        end
    end)
end)

RegisterNetEvent('SpeedCam:BillPlayer', function(bill, plate, kmh, vehname)
    local src = source
    MySQL.query('SELECT citizenid FROM `player_vehicles` WHERE plate=:plate', { plate = plate}, function(result)
        if result then 
            for i = 1, #result do
                local data = result[i]
                local player = QBCore.Functions.GetPlayerByCitizenId(data.citizenid)
                if player then
                    TriggerEvent('SpeedCam:server:SendBillEmail', player, bill, plate, kmh, vehname)
                    player.Functions.RemoveMoney("bank", bill, "Multa Stradale")
                    local amount = math.floor(bill * 0.5)
                    TriggerEvent('qb-bossmenu:server:addAccountMoney', src, "police", (amount/2))
                    TriggerEvent('qb-bossmenu:server:addAccountMoney', src, "sheriff", (amount/2))
                else
                    TriggerEvent('SpeedCam:server:SendBillEmailOffline', data.citizenid, bill, plate, kmh, vehname)
                    local PlayerData = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ?', { data.citizenid })
                    Wait(500)
                    local moneyData = PlayerData[1].money
                    moneyData = json.decode(moneyData)
                    moneyData["bank"] = moneyData["bank"] - bill
                    local amount = math.floor(bill * 0.5)
                    exports.oxmysql:execute('UPDATE players SET money = ? WHERE citizenid = ?', { json.encode(moneyData), data.citizenid })
                    TriggerEvent('qb-bossmenu:server:addAccountMoney', src, "police", (amount/2))
                    TriggerEvent('qb-bossmenu:server:addAccountMoney', src, "sheriff", (amount/2))
                end
            end
        end
    end)
end)

