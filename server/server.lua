local config = {
    botToken = "ur token here",
    channelId = "ur channel id here",
    messageId = "YOUR_MESSAGE_ID_HERE", --dont touch it will update automatically
    updateInterval = 1
}

local playerTimes = {}
local playerDiscordIds = {}

MySQL.ready(function()
    MySQL.Async.fetchAll('SELECT * FROM player_playtime', {}, function(results)
        if results then
            for _, row in ipairs(results) do
                playerTimes[row.identifier] = row.minutes
                if row.discord_id then
                    playerDiscordIds[row.identifier] = row.discord_id
                end
            end
            print('[mh-playtime] Loaded ' .. #results .. ' player records from database')
        end
    end)
end)

local function getDiscordId(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, "discord:") then
            return string.gsub(identifier, "discord:", "")
        end
    end
    return nil
end

local function savePlayerTime(identifier, minutes, name, discord_id)
    if identifier then
        MySQL.Async.execute('INSERT INTO player_playtime (identifier, name, minutes, discord_id) VALUES (@identifier, @name, @minutes, @discord_id) ON DUPLICATE KEY UPDATE minutes = @minutes, name = @name, discord_id = @discord_id', {
            ['@identifier'] = identifier,
            ['@name'] = name or "Unknown",
            ['@minutes'] = minutes,
            ['@discord_id'] = discord_id
        })
    end
end

local function formatTime(minutes)
    local days = math.floor(minutes / 1440)
    local hours = math.floor((minutes % 1440) / 60)
    local mins = minutes % 60
    
    if days > 0 then
        return string.format("%dd %dh %dm", days, hours, mins)
    elseif hours > 0 then
        return string.format("%dh %dm", hours, mins)
    else
        return string.format("%dm", mins)
    end
end

local function getCurrentDate()
    return os.date("%d.%m.%Y %H:%M")
end

local function updateDiscordMessage()
    local players = {}
    for identifier, time in pairs(playerTimes) do
        local playerName = GetPlayerName(identifier) or "Unknown"
        table.insert(players, {
            identifier = identifier,
            name = playerName,
            time = time
        })
    end

    table.sort(players, function(a, b)
        return a.time > b.time
    end)

    local message = {
        embeds = {
            {
                title = "TOP GODZINY - na serwerze!", --title of discord message u can edit 
                color = 0xe08012,
                fields = {
                    {
                        name = "Gracze",
                        value = "",
                        inline = false
                    }
                },
                footer = {
                    text = "ur project name here • Today at " .. os.date("%H:%M") .. " • by matimh.fun" --yk the script is free u can modify it but please keep this credit "matimh.fun" - thx <3
                }
            }
        }
    }

    local playerList = ""
    
    for i = 1, math.min(20, #players) do
        local player = players[i]
        local discordMention = playerDiscordIds[player.identifier] and string.format("<@%s>", playerDiscordIds[player.identifier]) or player.name
        playerList = playerList .. string.format("%d. %s - %s\n", i, discordMention, formatTime(player.time))
    end

    message.embeds[1].fields[1].value = playerList

    local headers = {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bot ' .. config.botToken
    }
    
    if config.messageId == "YOUR_MESSAGE_ID_HERE" then
        local url = string.format('https://discord.com/api/v10/channels/%s/messages', config.channelId)
        PerformHttpRequest(url, function(err, text, headers)
            if err == 200 or err == 201 then
                local data = json.decode(text)
                config.messageId = data.id
                print('[mh-playtime] Created initial Discord message with ID: ' .. config.messageId)
            else
                print('[mh-playtime] Failed to send initial Discord message: ' .. tostring(err))
            end
        end, 'POST', json.encode(message), headers)
    else
        local url = string.format('https://discord.com/api/v10/channels/%s/messages/%s', config.channelId, config.messageId)
        PerformHttpRequest(url, function(err, text, headers)
            if err ~= 200 then
                print('[mh-playtime] Failed to update Discord message: ' .. tostring(err))
            end
        end, 'PATCH', json.encode(message), headers)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) 
        
        for _, playerId in ipairs(GetPlayers()) do
            local identifier = GetPlayerIdentifier(playerId, 0)
            if identifier then
                playerTimes[identifier] = (playerTimes[identifier] or 0) + 1
                local discord_id = getDiscordId(playerId)
                if discord_id then
                    playerDiscordIds[identifier] = discord_id
                end
                savePlayerTime(identifier, playerTimes[identifier], GetPlayerName(playerId), discord_id)
            end
        end
        
        if (os.time() % (config.updateInterval * 60)) < 60 then
            updateDiscordMessage()
        end
    end
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local identifier = GetPlayerIdentifier(source, 0)
    if identifier and not playerTimes[identifier] then
        playerTimes[identifier] = 0
        local discord_id = getDiscordId(source)
        if discord_id then
            playerDiscordIds[identifier] = discord_id
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    for identifier, minutes in pairs(playerTimes) do
        local name = "Unknown"
        for _, playerId in ipairs(GetPlayers()) do
            if GetPlayerIdentifier(playerId, 0) == identifier then
                name = GetPlayerName(playerId)
                break
            end
        end
        savePlayerTime(identifier, minutes, name)
    end
end)
