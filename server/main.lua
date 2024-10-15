
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

function BuildMailMessage(gender, lastname, speed, vehname, plate, amount)
    local text = Locales[Config.Locale].dear.." " .. gender .. " " .. lastname .. ",\n "..Locales[Config.Locale].msgpt1..",\n\n"..Locales[Config.Locale].msgpt2.." "..speed.." "..Locales[Config.Locale].msgpt3.." "..vehname.." "..Locales[Config.Locale].msgpt4.." "..plate..",\n\n"..Locales[Config.Locale].msgpt5..amount..".00"
    return text
end

function BuildDiscordLogMessage(vehname, plate, speed, firstname, lastname, amount)
    local discordtext = Locales[Config.Locale].dsmsgpt1..' **'..vehname..'** '..Locales[Config.Locale].msgpt4..' **'..plate..'** '..Locales[Config.Locale].dsmsgpt2..' **'..speed..'** '..Locales[Config.Locale].dsmsgpt3..'.\n\n'..Locales[Config.Locale].dsmsgpt4..' **'..firstname..' '..lastname..'** '..Locales[Config.Locale].dsmsgpt5..' **$'..amount..'.00**\n\n'..Locales[Config.Locale].dsmsgpt6
    return discordtext
end

RegisterNetEvent("SpeedCam:server:CreateSpeedCamLog", function(message)
    if DiscordLogs.enabled then
        local webHook = DiscordLogs.webhook
        local embedData = {
            {
                ["title"] = Locales[Config.Locale].discordlogtitle,
                ["color"] = DiscordLogs.embeedColor,
                ["footer"] = {
                    ["text"] = os.date("%d-%m-%Y %H:%M"),
                },
                ["description"] = message,
                ["author"] = {
                    ["name"] = DiscordLogs.embeedName,
                    ["icon_url"] = DiscordLogs.embeedIcon,
                },
            }
        }
        PerformHttpRequest(webHook, function() end, "POST", json.encode({ username = "SpeedCamera Report", embeds = embedData}), { ["Content-Type"] = "application/json" })
        Wait(100)
        if DiscordLogs.tagUsers then
            PerformHttpRequest(webHook, function() end, "POST", json.encode({ username = "SpeedCamera Report", content = DiscordLogs.roleIdtotag}), { ["Content-Type"] = "application/json" })
        end
    end
end)


RegisterNetEvent('SpeedCam:server:SendBillEmail', function(player, amount, plate, kmh, vehname)
    SetTimeout(math.random(2500, 4000), function()
        local speed = math.floor(kmh)
        local gender = Locales[Config.Locale].mr
        if player.PlayerData.charinfo.gender == 1 then
            gender = Locales[Config.Locale].miss
        end
        local charinfo = player.PlayerData.charinfo
        local messaggio = BuildMailMessage(gender, charinfo.lastname, speed, vehname, plate, amount)
        
        TriggerEvent('SpeedCam:server:CreateSpeedCamLog', BuildDiscordLogMessage(vehname, plate, speed, charinfo.firstname, charinfo.lastname, amount))

        if Config.phonescript == "lb-phone" then
            local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(player.PlayerData.source) or nil
            if phoneNumber then
            local mailAddress = exports["lb-phone"]:GetEmailAddress(phoneNumber)
                exports["lb-phone"]:SendMail({
                    to = mailAddress,
                    sender = Locales[Config.Locale].policedept,
                    subject = Locales[Config.Locale].mailobj,
                    message = messaggio,
                    attachments = {},
                })
            end
        elseif Config.phonescript == "qs-smartphone-pro" then
            exports['qs-smartphone-pro']:sendNewMail(player.PlayerData.source, {
                sender = Locales[Config.Locale].policedept,
                subject = Locales[Config.Locale].mailobj,
                message = messaggio
            })
            local phone = exports['qs-smartphone-pro']:GetPhoneNumberFromIdentifier(player.PlayerData.citizenid, false)
            exports['qs-smartphone-pro']:sendNotificationOld(phone, {
                app = 'mail',
                msg = Locales[Config.Locale].mailobj,
                head = Locales[Config.Locale].policedept
            }, false)
        end
    end)
end)

RegisterNetEvent('SpeedCam:server:SendBillEmailOffline', function(citizenid, amount, plate, kmh, vehname)
    MySQL.query('SELECT phone_number FROM `phone_last_phone` WHERE id = citizenid', {citizenid = citizenid}, function(mresult)
        local speed = math.floor(kmh)
        if mresult then 
            for i = 1, #mresult do

                local playerDataquery = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ?', { citizenid })
                local playerData = playerDataquery[1]
                local phoneData = mresult[i]
                local phoneNumber = phoneData.phone_number
                local mailAddress = exports["lb-phone"]:GetEmailAddress(phoneNumber)
                local charinfo = playerData.charinfo
                local messaggio = BuildMailMessage(playerData.charinfo.gender, charinfo.lastname, speed, vehname, plate, amount)

                if mailAddress then
                    exports["lb-phone"]:SendMail({
                        to = mailAddress,
                        sender = Locales[Config.Locale].policedept,
                        subject = Locales[Config.Locale].mailobj,
                        message = messaggio,
                        attachments = {},
                    })

                    TriggerEvent('SpeedCam:server:CreateSpeedCamLog', BuildDiscordLogMessage(vehname, plate, speed, charinfo.firstname, charinfo.lastname, amount))
                    
                    print("Offline Speedcam mail sent to "..playerData["firstname"].." "..playerData["lastname"])
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
                    player.Functions.RemoveMoney("bank", bill, Locales[Config.Locale].bill)
                    TriggerEvent('qb-bossmenu:server:addAccountMoney', src, "police", (bill/2))
                    TriggerEvent('qb-bossmenu:server:addAccountMoney', src, "sheriff", (bill/2))
                else
                    TriggerEvent('SpeedCam:server:SendBillEmailOffline', data.citizenid, bill, plate, kmh, vehname)
                    local PlayerData = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ?', { data.citizenid })
                    Wait(500)
                    local moneyData = PlayerData[1].money
                    moneyData = json.decode(moneyData)
                    moneyData["bank"] = moneyData["bank"] - bill
                    exports.oxmysql:execute('UPDATE players SET money = ? WHERE citizenid = ?', { json.encode(moneyData), data.citizenid })
                    TriggerEvent('qb-bossmenu:server:addAccountMoney', src, "police", (bill/2))
                    TriggerEvent('qb-bossmenu:server:addAccountMoney', src, "sheriff", (bill/2))
                end
            end
        end
    end)
end)

