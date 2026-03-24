Config = {}

-- [[ SETTING UTAMA BANDARA ]]
Config.ServerName = "D.VID ROLEPLAY"
-- Banner Aesthetic Penerbangan
Config.Banner = "https://media.giphy.com/media/l41JRsph73VokN6ik/giphy.gif"

-- [[ KAPASITAS KABIN PESAWAT (SLOT) ]]
Config.MaxSlots = 128    -- Total slot server
Config.ReservedSlots = 8 -- Kursi khusus admin/donatur (Biar VIP tetep bisa masuk)

-- [[ DISCORD CONFIG & WHITELIST (PASPOR) ]]
Config.EnableDiscord = true
Config.DiscordToken = "DISCORD_BOT_TOKEN_DISINI"
Config.GuildId = "1466430024100872397"

Config.RequireWhitelist = false               -- Ubah ke 'true' kalau server di-lock
Config.WhitelistRoleID = "444444444444444444" -- ID Role Warga / Whitelist di Discord

-- [[ PRIORITY MILES (TIER ROLE DISCORD) ]]
Config.RolePoints = {
    ['111111111111111111'] = 1000, -- Founder (Sultan)
    ['222222222222222222'] = 500,  -- Admin (Pilot)
    ['333333333333333333'] = 300,  -- Donatur VIP (First Class)
    ['444444444444444444'] = 100,  -- Warga Whitelist (Business Class)
    ['555555555555555555'] = 50    -- Booster (Economy Premium)
}

-- [[ FITUR ASURANSI PENERBANGAN ]]
Config.GracePeriod = 300 -- (Detik) Waktu asuransi kalau crash (5 menit)

-- [[ CCTV BANDARA (WEBHOOK LOG ADMIN) ]]
Config.Webhooks = {
    Enable = true,
    QueueLog = "URL_WEBHOOK_QUEUE_DISINI",
    SecurityLog = "URL_WEBHOOK_SECURITY_DISINI" -- Webhook buat pantau Spoofer/VPN
}
