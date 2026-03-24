-- ==========================================
-- ✈️ D.VID AIRLINES QUEUE & IMIGRASI (TRAVEL / GEN Z EDITION)
-- 👨‍💻 Author: D.VID
-- 📦 Version: 5.0.0
-- ==========================================

local CurrentVersion = "5.0.0"
local JoinDelay = 15
local LastJoinTime = 0
local Banner = Config.Banner

local SpinnerFrames = { "🌍", "🌎", "🌏" }

local RandomTips = {
    "Nyelip antrean boarding fix lu no rizz 💅",
    "Pesawat lagi dipanasin, let the pilot cook FR FR ✈️",
    "Pake spoofer pas check-in? Skill issue bro, mending touch grass 🌿",
    "Delay bentar ngab, ngopi dulu di VIP Lounge ☕",
    "Bawa koper jangan berat-berat, beban hidup lu udah berat 🗿",
    "Miles/Poin lu ngaruh banget buat dapet kursi first class 👑"
}

local Queue = {}
local GraceList = {}
local SessionData = {}

-- [[ 0. STARTUP BANNER & VERSION CHECK (CONSOLE LOGS) ]]
local function PrintStartupLogo()
    print("^4================================================================^0")
    print("^6  ██████╗  ██╗   ██╗██╗██████╗ ^0")
    print("^6  ██╔══██╗ ██║   ██║██║██╔══██╗^0")
    print("^6  ██║  ██║ ██║   ██║██║██║  ██║^0")
    print("^6  ██║  ██║ ╚██╗ ██╔╝██║██║  ██║^0")
    print("^6  ██████╔╝  ╚████╔╝ ██║██████╔╝^0")
    print("^6  ╚═════╝    ╚═══╝  ╚═╝╚═════╝ ^0")
    print("^0")
    print("^b^7✈️  D.VID AIRLINES QUEUE SYSTEM ✈️^0")
    print("^3👨‍💻 Author  : ^7D.VID")
    print("^3📦 Version : ^7" .. CurrentVersion)
    print("^4================================================================^0")
    print("^2[SYSTEM] ^7Memuat modul keamanan bandara...^0")
    Wait(500)
    print("^2[MODULE] ^7Paspor & Visa (Anti-Spoofer) ... ^2[ACTIVE]^0")
    Wait(100)
    print("^2[MODULE] ^7Radar Cuaca (Anti-VPN) ... ^2[ACTIVE]^0")
    Wait(100)
    if Config.Webhooks.Enable then
        print("^2[MODULE] ^7CCTV Bandara (Discord Logs) ... ^2[ACTIVE]^0")
    else
        print("^1[MODULE] ^7CCTV Bandara (Discord Logs) ... ^1[DISABLED]^0")
    end
    Wait(100)
    print("^2[MODULE] ^7Sistem Boarding (Queue) ... ^2[ACTIVE]^0")
end

local function CheckVersion()
    -- Kalau kamu punya file version.txt di raw github, masukin URL-nya di sini
    local versionUrl = "https://raw.githubusercontent.com/DummyRepo/DVID/main/version.txt"

    PerformHttpRequest(versionUrl, function(err, text, headers)
        print("^4----------------------------------------------------------------^0")
        if err == 200 then
            local latestVersion = string.gsub(text, "%s+", "")
            if CurrentVersion == latestVersion then
                print("^2[UPDATE] ^7Script up to date! (Versi " .. CurrentVersion .. ")^0")
            else
                print("^1[UPDATE] ^0Versi baru tersedia! ^1(Latest: " .. latestVersion .. ")^0")
                print("^1[UPDATE] ^7Segera hubungi D.VID untuk update script.^0")
            end
        else
            -- Kalau URL Gak ada/belum di-set, kita anggep aja udah versi terbaru
            print("^2[UPDATE] ^7D.VID Airlines beroperasi di Versi " .. CurrentVersion .. "^0")
        end
        print("^4================================================================^0")
    end, "GET", "", "")
end

-- [[ 1. FUNGSI WEBHOOK LOG (CCTV ADMIN) ]]
local function SendSecurityLog(title, desc, color)
    if not Config.Webhooks.Enable or Config.Webhooks.SecurityLog == "URL_WEBHOOK_SECURITY_DISINI" then return end
    local embed = { { ["color"] = color, ["title"] = title, ["description"] = desc, ["footer"] = { ["text"] = "D.VID Airlines Security | " .. os.date("%d/%m/%Y %H:%M") } } }
    PerformHttpRequest(Config.Webhooks.SecurityLog, function() end, 'POST',
        json.encode({ username = "Imigrasi Bandara", embeds = embed }), { ['Content-Type'] = 'application/json' })
end

-- [[ 2. FUNGSI VALIDASI NAMA (CEK PASPOR) ]]
local function IsValidName(playerName)
    if not playerName or playerName == "" then return false, "Nama paspor kosong." end
    playerName = playerName:gsub("^%s*(.-)%s*$", "%1")
    if string.match(playerName, "[^%a%d%s]") then return false, "Terdeteksi simbol aneh di paspor." end
    if string.len(playerName) < 3 then return false, "Nama paspor terlalu pendek (Min 3 huruf)." end
    return true, ""
end

-- [[ 3. FUNGSI DATABASE (SQL) ]]
local function SQL_Query(query, params)
    local p = promise.new()
    exports.oxmysql:execute(query, params, function(result) p:resolve(result) end)
    return Citizen.Await(p)
end

local function GetSQLData(license)
    if not license then return { points = 0, total_time = 0 } end
    local result = SQL_Query('SELECT points, total_time FROM dvid_queue_data WHERE identifier = ?', { license })
    if result and result[1] then return result[1] end
    SQL_Query('INSERT INTO dvid_queue_data (identifier, points, total_time) VALUES (?, 0, 0)', { license })
    return { points = 0, total_time = 0 }
end

-- [[ 4. FUNGSI DISCORD & MILES VIP ]]
local function GetDiscordData(userDiscordID)
    if not Config.EnableDiscord or not userDiscordID then return 0, false end
    local p = promise.new()
    local endpoint = ("https://discord.com/api/v10/guilds/%s/members/%s"):format(Config.GuildId, userDiscordID)
    PerformHttpRequest(endpoint, function(errorCode, resultData, resultHeaders)
        local points, hasWhitelist = 0, false
        if errorCode == 200 then
            local data = json.decode(resultData)
            if data and data.roles then
                for _, roleID in ipairs(data.roles) do
                    if Config.RolePoints[roleID] then points = points + Config.RolePoints[roleID] end
                    if roleID == Config.WhitelistRoleID then hasWhitelist = true end
                end
            end
        end
        p:resolve({ points = points, wl = hasWhitelist })
    end, "GET", "", { ["Authorization"] = "Bot " .. Config.DiscordToken })
    SetTimeout(3000, function() p:resolve({ points = 0, wl = false }) end)
    local result = Citizen.Await(p)
    return result.points, result.wl
end

-- [[ 5. FUNGSI VPN CHECKER (RADAR CUACA) ]]
local function CheckVPN(ip)
    local p = promise.new()
    PerformHttpRequest("http://proxycheck.io/v2/" .. ip .. "?vpn=1", function(err, text, headers)
        if err == 200 and text and string.find(text, '"proxy": "yes"') then p:resolve(true) else p:resolve(false) end
    end, "GET", "", { ["Content-Type"] = "application/json" })
    SetTimeout(4000, function() p:resolve(false) end)
    return Citizen.Await(p)
end

-- [[ 6. VISUAL: UI ADAPTIVE CARD (FLIGHT BOARDING MODE ✈️) ]]
local function GetAdaptiveCard(title, subtitle, checks, queueData, frameIndex)
    local spinIcon = "⏳"
    if frameIndex then spinIcon = SpinnerFrames[(frameIndex % #SpinnerFrames) + 1] end
    local randomTip = RandomTips[(frameIndex % #RandomTips) + 1] or RandomTips[1]
    local playerCount = GetNumPlayerIndices()

    local bodyItems = {
        { type = "Image", url = Banner, size = "Stretch", height = "130px", horizontalAlignment = "Center" },
        { type = "TextBlock", text = "✈️ " .. Config.ServerName .. " AIRLINES ✈️", size = "ExtraLarge", weight = "Bolder", horizontalAlignment = "Center", color = "Light" },
        { type = "TextBlock", text = "Penumpang di Kabin: " .. playerCount .. " / " .. Config.MaxSlots, size = "Small", color = "Good", horizontalAlignment = "Center", isSubtle = true },
        { type = "TextBlock", text = title, size = "Large", weight = "Bolder", horizontalAlignment = "Center", color = "Accent", spacing = "Medium" },
        { type = "TextBlock", text = subtitle, isSubtle = true, horizontalAlignment = "Center", spacing = "None" }
    }

    if queueData then
        local percentage = queueData.total > 0 and math.floor(((queueData.total - queueData.pos) / queueData.total) * 10) or
        0
        local flightPath = ""

        for i = 1, 10 do
            if i == (11 - percentage) then
                flightPath = flightPath .. "✈️"
            else
                flightPath = flightPath .. "➖"
            end
        end
        if queueData.total == 0 or queueData.pos == 1 then flightPath = "➖➖➖➖➖➖➖➖✈️" end
        local finalProgressBar = "🛫 " .. flightPath .. " 🛬"

        table.insert(bodyItems, {
            type = "Container",
            style = "emphasis",
            items = {
                {
                    type = "ColumnSet",
                    columns = {
                        { type = "Column", width = "auto", items = { { type = "TextBlock", text = spinIcon, size = "ExtraLarge", color = "Accent", horizontalAlignment = "Center" } } },
                        { type = "Column", width = "stretch", items = { { type = "TextBlock", text = "BOARDING GROUP", size = "Small", isSubtle = true }, { type = "TextBlock", text = "🎫 " .. tostring(queueData.pos) .. " / " .. tostring(queueData.total), size = "Large", weight = "Bolder" } } },
                        { type = "Column", width = "stretch", items = { { type = "TextBlock", text = "PRIORITY MILES", size = "Small", isSubtle = true }, { type = "TextBlock", text = "🌟 " .. tostring(queueData.priority), size = "Large", weight = "Bolder", color = "Good" } } }
                    }
                },
                { type = "TextBlock", text = "Status Penerbangan: " .. (queueData.status or "Menunggu Delay... ☕"), weight = "Bolder", color = "Warning", spacing = "Medium", horizontalAlignment = "Center" },
                { type = "TextBlock", text = finalProgressBar, color = "Accent", size = "Medium", horizontalAlignment = "Center", spacing = "None" }
            }
        })
    end

    if checks then
        local checkContainer = { type = "Container", spacing = "Medium", items = {} }
        for _, check in ipairs(checks) do
            local color = check.state == "passed" and "Good" or (check.state == "failed" and "Attention" or "Warning")
            local icon = check.state == "passed" and "✅" or (check.state == "failed" and "❌" or "🔄")
            table.insert(checkContainer.items, {
                type = "ColumnSet",
                columns = {
                    { type = "Column", width = "stretch", items = { { type = "TextBlock", text = check.label, weight = "Bolder", color = "Light" } } },
                    { type = "Column", width = "auto",    items = { { type = "TextBlock", text = icon, color = color, horizontalAlignment = "Right" } } }
                }
            })
        end
        table.insert(bodyItems, checkContainer)
    end

    table.insert(bodyItems,
        { type = "TextBlock", text = "📢 Info: " .. randomTip, size = "Small", color = "Accent", horizontalAlignment =
        "Center", wrap = true, weight = "Bolder", spacing = "Large" })

    return { type = "AdaptiveCard", version = "1.2", body = bodyItems, ["$schema"] =
    "http://adaptivecards.io/schemas/adaptive-card.json" }
end

-- [[ 7. MAIN EVENT LOGIC (PLAYER CONNECTING) ]]
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local ipIdentifier = GetPlayerEndpoint(src)
    local ipAsli = string.gsub(ipIdentifier, ":%d+", "")

    local steamID, discordID, license, fivemID = nil, nil, nil, nil

    deferrals.defer()
    Wait(50)

    local isNameValid, nameErrorReason = IsValidName(name)
    if not isNameValid then
        SendSecurityLog("🚩 Paspor Ditolak",
            "**Nama:** " .. name .. "\n**IP:** ||" .. ipAsli .. "||\n**Alasan:** " .. nameErrorReason, 15158332)
        print("^1[D.VID AIRLINES] ^7Menolak " .. name .. " (Alasan: " .. nameErrorReason .. ")^0")
        deferrals.done("❌ [D.VID AIRLINES] Check-in Ditolak! " ..
        nameErrorReason .. "\nGanti nama profil Steam/FiveM lu yang bener!")
        return
    end

    local frame = 0
    local myChecks = {
        { label = "Cek Paspor & Visa (License)",  state = "checking" },
        { label = "Tiket Boarding (Cfx.re)",      state = "checking" },
        { label = "Metal Detector (Anti-Spoof)",  state = "checking" },
        { label = "Radar Bandara (Anti-VPN)",     state = "checking" },
        { label = "Akses VIP Lounge (Whitelist)", state = "checking" }
    }

    deferrals.presentCard(GetAdaptiveCard("🛂 GATE KEBERANGKATAN", "Halo " .. name .. ", siapkan tiket boarding lu...",
        myChecks, nil, frame))
    Wait(2000)

    for _, id in ipairs(identifiers) do
        if string.find(id, "steam:") then steamID = id end
        if string.find(id, "discord:") then discordID = string.gsub(id, "discord:", "") end
        if string.find(id, "license:") then license = id end
        if string.find(id, "fivem:") then fivemID = id end
    end
    frame = frame + 1

    if not license or not steamID or not discordID then
        SendSecurityLog("💀 Spoofer Terdeteksi",
            "**Nama:** " .. name .. "\n**IP:** ||" .. ipAsli .. "||\n**Alasan:** Identitas bodong.", 15158332)
        print("^1[D.VID AIRLINES] ^7Spoofer ditolak (KTP Bodong) -> " .. name .. "^0")
        deferrals.done("❌ [D.VID AIRLINES] Paspor lu bodong ngab! Steam/Discord ga nyambung. Jangan nyelundup 💀")
        return
    end
    myChecks[1].state = "passed"
    frame = frame + 1

    if not fivemID then
        deferrals.done(
        "❌ [D.VID AIRLINES] Lu belum cetak Tiket Boarding (Login Cfx.re/FiveM)! Balik ke menu awal sana 🗿")
        return
    end
    myChecks[2].state = "passed"
    frame = frame + 1

    local hwidCount = GetNumPlayerTokens(src)
    if hwidCount == 0 or hwidCount == nil then
        SendSecurityLog("🤡 HWID Spoofer Blocked",
            "**Nama:** " .. name .. "\n**License:** " .. license .. "\n**Alasan:** Hardware Token Kosong.", 15158332)
        print("^1[D.VID AIRLINES] ^7HWID Spoofer diblokir -> " .. name .. "^0")
        deferrals.done("❌ [D.VID AIRLINES] Koper lu bunyi pas di Metal Detector (HWID Kosong/Spoofer). Gagal terbang 🌿🤡")
        return
    end
    myChecks[3].state = "passed"
    deferrals.presentCard(GetAdaptiveCard("🛂 GATE KEBERANGKATAN", "Neropong lokasi asal lu dulu...", myChecks, nil, frame))
    frame = frame + 1

    local isUsingVPN = CheckVPN(ipAsli)
    if isUsingVPN then
        SendSecurityLog("🌍 VPN Terdeteksi",
            "**Nama:** " .. name .. "\n**IP VPN:** ||" .. ipAsli .. "||\n**License:** " .. license, 16753920)
        print("^1[D.VID AIRLINES] ^7VPN User dicegat -> " .. name .. " (IP: " .. ipAsli .. ")^0")
        deferrals.done("❌ [D.VID AIRLINES] Lu masuk no-fly list! Ketahuan pake VPN/Proxy. Matiin dulu bang 🚩")
        return
    end
    myChecks[4].state = "passed"
    deferrals.presentCard(GetAdaptiveCard("🛂 GATE KEBERANGKATAN", "Ngecek akses VIP Lounge...", myChecks, nil, frame))
    Wait(1000)
    frame = frame + 1

    local dcPoints, isWhitelisted = GetDiscordData(discordID)
    if Config.RequireWhitelist and not isWhitelisted then
        SendSecurityLog("⛔ Gagal Whitelist", "**Nama:** " .. name .. "\n**Discord:** <@" .. discordID .. ">", 10038562)
        deferrals.done("❌ [D.VID AIRLINES] Lu belum punya Paspor Warga (Whitelist) ngab! Bikin dulu di Discord kita.")
        return
    end
    myChecks[5].state = "passed"

    deferrals.presentCard(GetAdaptiveCard("✅ CHECK-IN BERHASIL", "Tiket valid, silakan masuk ruang tunggu...", myChecks,
        nil, frame))
    Wait(1500)

    local points = dcPoints
    local sqlData = GetSQLData(license)
    points = points + (sqlData.points or 0)

    local isGrace = false
    if GraceList[license] and (os.time() - GraceList[license]) < (Config.GracePeriod or 300) then
        points = 99999
        isGrace = true
    end

    table.insert(Queue, { source = src, points = points, license = license, deferrals = deferrals, name = name })
    SendSecurityLog("⏳ Penumpang Boarding",
        "**Nama:** " .. name .. "\n**Discord:** <@" .. discordID .. ">\n**Priority Miles:** " .. points, 3066993)
    print("^2[D.VID AIRLINES] ^7" .. name .. " masuk antrean Boarding (Poin: " .. points .. ")^0")

    local inQueue = true
    while inQueue do
        Wait(2500)
        frame = frame + 1

        if GetPlayerPing(src) == 0 then
            for i, p in ipairs(Queue) do if p.source == src then
                    table.remove(Queue, i)
                    break
                end end
            print("^3[D.VID AIRLINES] ^7" .. name .. " membatalkan penerbangan (Cancel Queue).^0")
            return
        end

        table.sort(Queue, function(a, b) return a.points > b.points end)

        local myPos = 0
        for i, p in ipairs(Queue) do if p.source == src then
                myPos = i
                break
            end end

        local playerCount = GetNumPlayerIndices()
        local maxSlots = Config.MaxSlots - Config.ReservedSlots
        if points >= 500 then maxSlots = Config.MaxSlots end

        if myPos == 1 and playerCount < maxSlots then
            local timeSinceLastJoin = os.time() - LastJoinTime

            if timeSinceLastJoin >= JoinDelay or isGrace then
                inQueue = false
                table.remove(Queue, 1)
                LastJoinTime = os.time()

                if GraceList[license] then GraceList[license] = nil end
                SessionData[license] = os.time()

                print("^2[D.VID AIRLINES] ^7" .. name .. " berhasil TAKEOFF! 🛫^0")
                deferrals.presentCard(GetAdaptiveCard("🛬 PREPARE FOR TAKEOFF",
                    "Kencangkan sabuk pengaman, Welcome to " .. Config.ServerName .. " 🥶", nil, nil, frame))
                Wait(1500)
                deferrals.done()
            else
                local waitTime = JoinDelay - timeSinceLastJoin
                local qInfo = { pos = myPos, total = #Queue, priority = points, status = "Landasan lagi dibersihin: " ..
                waitTime .. "s 😮‍💨" }
                deferrals.presentCard(GetAdaptiveCard("🚧 HOLD UP!", "Antre masuk landasan pacu...", myChecks, qInfo,
                    frame))
            end
        else
            local statusInfo = isGrace and "PRIORITAS FIRST CLASS 🤫" or "Pesawat lagi penuh, nongkrong dulu ☕"
            local qInfo = { pos = myPos, total = #Queue, priority = (isGrace and "MAX (Asuransi)" or points), status =
            statusInfo }
            deferrals.presentCard(GetAdaptiveCard("🛋️ VIP LOUNGE", "Duduk manis ngab, tunggu panggilan...", myChecks,
                qInfo, frame))
        end
    end
end)

-- [[ 8. SAVE WAKTU & GRACE PERIOD SAAT DC ]]
AddEventHandler('playerDropped', function(reason)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)
    local license = nil
    for _, id in ipairs(identifiers) do
        if string.find(id, "license:") then
            license = id; break
        end
    end

    if license and SessionData[license] then
        local sessionSeconds = os.time() - SessionData[license]
        if sessionSeconds > 0 then
            SQL_Query('UPDATE dvid_queue_data SET total_time = total_time + ? WHERE identifier = ?',
                { sessionSeconds, license })
        end
        SessionData[license] = nil

        if string.find(string.lower(reason), "time") or string.find(string.lower(reason), "crash") then
            GraceList[license] = os.time()
            print("^3[D.VID AIRLINES] ^7Menyiapkan asuransi (Grace Period) untuk " ..
            license .. " karena Crash/Timeout.^0")
        end
    end
end)

-- [[ 9. AUTO INIT DB & STARTUP ]]
AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res then return end

    -- Print Logo & Versi
    PrintStartupLogo()

    -- Init Database
    SQL_Query([[
        CREATE TABLE IF NOT EXISTS `dvid_queue_data` (
          `identifier` varchar(50) NOT NULL,
          `points` int(11) DEFAULT 0,
          `total_time` int(11) DEFAULT 0,
          PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {})
    print("^2[MODULE] ^7Database Passenger ... ^2[CONNECTED]^0")

    -- Check Version
    CheckVersion()
end)
