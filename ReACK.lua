-- t.me/viberscript
-- t.me/viberscript
-- t.me/viberscript

local env = type(getgenv) == "function" and getgenv() or _G
if env.Viber and type(env.Viber.Unload) == "function" then
    pcall(env.Viber.Unload)
end
if env.ReACK and type(env.ReACK.Unload) == "function" then
    pcall(env.ReACK.Unload)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local BRAND_NAME = "ReACK"
local TELEGRAM_INVITE = "https://t.me/viberscript"
local CONFIG_PATH = "reack_config.json"
local LOADER_DURATION = 2.3
local LOGO_ASSET_ID = ""
local FARM_ATTACK_INTERVAL = 0.15

local BASE_WIN_W = 568
local BASE_WIN_H = 420

local DEFAULT_ORB_POS = { 0.5, 0, 0, 38 }

local FONT_REG = Enum.Font.Gotham
local FONT_MED = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

local function copyToClipboard(text)
    local fnClip = (type(setclipboard) == "function" and setclipboard)
        or (type(toclipboard) == "function" and toclipboard)
        or (type(syn) == "table" and type(syn.write_clipboard) == "function" and syn.write_clipboard)
    if fnClip then
        return pcall(fnClip, text)
    end
    return false
end

local fnWrite = type(writefile) == "function" and writefile or nil
local fnRead = type(readfile) == "function" and readfile or nil
local fnIsFile = type(isfile) == "function" and isfile or nil
local fnDelFile = type(delfile) == "function" and delfile or nil
local canUseFS = (fnWrite ~= nil and fnRead ~= nil)
local hasDrawing = (type(Drawing) == "table" or type(Drawing) == "userdata") and type(Drawing.new) == "function"

local FARM_MODES = { "Legit", "Semi-Rage", "Rage" }
local FARM_PRESETS = {
    ["Legit"] = {
        SearchRange = 120,
        BehindDist = 5.0,
        MoveSpeed = 32,
        UseSkills = false,
    },
    ["Semi-Rage"] = {
        SearchRange = 250,
        BehindDist = 4.2,
        MoveSpeed = 68,
        UseSkills = true,
    },
    ["Rage"] = {
        SearchRange = 500,
        BehindDist = 3.8,
        MoveSpeed = 125,
        UseSkills = true,
    },
}

local function getDefaultState()
    return {
        Active = true,
        Lang = "RU",
        SeenLanguagePopup = false,
        SeenTelegramPopup = false,

        AutoM1 = false,
        KillAura = false,
        AutoFarm = false,
        InfinitePunch = false,
        SpeedBoost = false,
        InfiniteDash = false,

        EspEnabled = false,
        EspBox = true,
        EspSkeleton = false,
        EspTracers = false,
        EspInfo = true,
        EspHighlight = true,
        EspTargetAccent = true,
        EspColorR = 255,
        EspColorG = 255,
        EspColorB = 255,

        AutoSave = true,

        AutoM1Range = 14,
        AutoM1FOV = 110,
        AutoM1WallCheck = true,
        M1Interval = 0.15,
        ShowAutoM1FloatingBtn = false,

        KillAuraRange = 18,
        KillAuraAutoFace = true,
        KillAuraInterval = 0.15,
        ShowKillAuraFloatingBtn = false,

        FarmMode = "Semi-Rage",
        FarmAutoReturn = true,
        FarmAntiRagdoll = true,
        FarmSearchRange = 250,
        FarmAttackRange = 9.5,
        FarmBehindDist = 4.2,
        FarmMoveSpeed = 68,
        FarmUseSkills = true,
        FarmTargetLowHP = false,
        ShowAutoFarmFloatingBtn = false,

        PunchCooldown = 0.01,
        WalkSpeedValue = 36,
        DefaultWalkSpeed = 16,

        OrbPos = { DEFAULT_ORB_POS[1], DEFAULT_ORB_POS[2], DEFAULT_ORB_POS[3], DEFAULT_ORB_POS[4] },
        HudPos = { 0.015, 0, 0.25, 0 },
        AutoM1BtnPos = { 0.86, 0, 0.22, 0 },
        KillAuraBtnPos = { 0.86, 0, 0.31, 0 },
        AutoFarmBtnPos = { 0.86, 0, 0.40, 0 },
    }
end

local State = getDefaultState()

local function getEspColor()
    return Color3.fromRGB(
        math.clamp(math.floor(State.EspColorR + 0.5), 0, 255),
        math.clamp(math.floor(State.EspColorG + 0.5), 0, 255),
        math.clamp(math.floor(State.EspColorB + 0.5), 0, 255)
    )
end

local I18N = {
    RU = {
        tab_Combat = "Бой",
        tab_Farm = "Фарм",
        tab_Player = "Игрок",
        tab_Settings = "Настройки",

        sec_AutoM1 = "Auto M1",
        sec_KillAura = "Kill Aura",
        sec_InfPunch = "Infinite Punch",
        sec_FarmMain = "Авто-фарм",
        sec_FarmOpt = "Цели и способности",
        sec_Movement = "Передвижение",
        sec_EspTypes = "Подсветка (ESP)",
        sec_EspColor = "Палитра ESP",
        sec_Buttons = "Кнопки на экране",
        sec_Account = "Аккаунт и сообщество",
        sec_Settings = "Основные",
        sec_System = "Сервер и конфиг",

        en_AutoM1 = "Auto M1",
        en_AutoM1_desc = "Сам бьёт врагов, которые попадают в угол обзора перед тобой.",
        wall_Chk = "Проверка стен",
        wall_Chk_desc = "Не реагировать на противников за стенами и укрытиями.",
        atk_Delay = "Задержка удара",
        atk_Delay_desc = "Пауза между обычными атаками M1.",
        dist = "Дистанция атаки",
        dist_desc = "На каком расстоянии начнёт срабатывать Auto M1.",
        fov = "Угол обзора (FOV)",
        fov_desc = "Ширина сектора захвата цели перед персонажем.",

        en_KA = "Kill Aura",
        en_KA_desc = "Автоматически атакует всех врагов вокруг тебя на 360°.",
        auto_Face = "Поворот к цели",
        auto_Face_desc = "Плавно разворачивает персонажа лицом к ближайшему врагу.",
        ka_Delay = "Задержка ауры",
        ka_Delay_desc = "Пауза между ударами в режиме Kill Aura.",
        ka_Range = "Радиус ауры",
        ka_Range_desc = "Дистанция вокруг тебя, в которой аура цепляет врагов.",

        en_Inf = "Infinite Punch",
        en_Inf_desc = "Снимает кулдаун и блокировки с базовых ударов.",
        punch_Cd = "Кулдаун удара",
        punch_Cd_desc = "Минимальная задержка восстановления атаки.",

        en_Farm = "Auto Farm",
        en_Farm_desc = "Находит врага, заходит за спину и добивает серией ударов.",
        farm_Mode = "Режим фарма",
        farm_Mode_desc = "Legit - обычный бег, Semi-Rage - рывки, Rage - жёсткий стрейф.",
        farm_Behind = "Дистанция за спиной",
        farm_Behind_desc = "Насколько близко держаться за спиной у противника.",
        farm_Search = "Радиус поиска",
        farm_Search_desc = "Дистанция по арене, в которой бот ищет цели.",
        farm_LowHP = "Приоритет по HP",
        farm_LowHP_desc = "В первую очередь добивать игроков с минимальным здоровьем.",
        farm_Skills = "Авто-скиллы (E / R)",
        farm_Skills_desc = "Автоматически прожимать способности вплотную к врагу.",
        farm_Return = "Возврат на арену",
        farm_Return_desc = "Сам выходит из лобби обратно в бой после смерти.",
        farm_AntiRagdoll = "Anti-Ragdoll",
        farm_AntiRagdoll_desc = "Не даёт сбить тебя с ног или застанить во время фарма.",
        farm_Spd = "Скорость сближения",
        farm_Spd_desc = "Скорость, с которой персонаж летит или бежит к цели.",

        en_Speed = "Speed Boost",
        en_Speed_desc = "Увеличивает базовую скорость бега твоего персонажа.",
        walk_Spd = "Скорость бега",
        walk_Spd_desc = "Желаемая скорость передвижения по карте.",
        en_InfDash = "Infinite Dash",
        en_InfDash_desc = "Убирает перезарядку рывков на Q - можно дэшиться без пауз.",

        en_Esp = "Включить ESP",
        en_Esp_desc = "Подсвечивает игроков сквозь стены и препятствия.",
        esp_Box = "2D Рамка",
        esp_Box_desc = "Аккуратный квадрат вокруг каждого противника.",
        esp_Skel = "Скелет",
        esp_Skel_desc = "Отрисовка костей и линий тела персонажей.",
        esp_Tracers = "Трейсеры",
        esp_Tracers_desc = "Линии от низа экрана прямо к врагам.",
        esp_Info = "Инфо над головой",
        esp_Info_desc = "Показывает ник, здоровье, дистанцию и мувсет игрока.",
        esp_Highlight = "Chams подсветка",
        esp_Highlight_desc = "Контурная заливка силуэта игрока сквозь стены.",
        esp_TargetCol = "Выделять текущую цель",
        esp_TargetCol_desc = "Подсвечивает активную цель фарма или ауры ярким цветом.",
        esp_Presets = "Готовые цвета",
        esp_Presets_desc = "Быстрый выбор цвета подсветки в один клик.",
        esp_R = "Красный (R)",
        esp_R_desc = "Насыщенность красного оттенка.",
        esp_G = "Зелёный (G)",
        esp_G_desc = "Насыщенность зелёного оттенка.",
        esp_B = "Синий (B)",
        esp_B_desc = "Насыщенность синего оттенка.",

        btn_M1 = "Кнопка Auto M1",
        btn_M1_desc = "Вынести отдельную кнопку Auto M1 прямо на экран.",
        btn_KA = "Кнопка Kill Aura",
        btn_KA_desc = "Вынести отдельную кнопку Kill Aura прямо на экран.",
        btn_Farm = "Кнопка Auto Farm",
        btn_Farm_desc = "Вынести отдельную кнопку Auto Farm прямо на экран.",

        tg_ChannelBtn = "Наш телеграм-канал",
        tg_ChannelSub = "Новости, обновления и поддержка - t.me/viberscript",
        tg_CopyAct = "Перейти",

        en_Save = "Авто-сохранение",
        en_Save_desc = "Автоматически запоминает все изменения в настройках.",
        lang_Btn = "Язык интерфейса",
        lang_Btn_desc = "Переключить язык меню между русским и английским.",
        lang_Val = "Русский",
        reset_Pos = "Сброс позиций",
        reset_Pos_desc = "Вернуть кнопку меню и HUD на стартовые места.",
        reset_PosBtn = "Сбросить",
        srv_HopBtn = "Сменить сервер",
        srv_HopBtn_desc = "Перекинет на другой живой сервер со свободными местами.",
        srv_HopAct = "Найти",
        srv_Searching = "Поиск...",
        srv_None = "Нет мест",
        srv_Err = "Ошибка",
        reset_Save = "Сбросить всё",
        reset_Save_desc = "Очистить сохранения и вернуть настройки по умолчанию.",
        reset_SaveBtn = "Сбросить",

        tg_PopupTitle = "Сообщество",
        tg_PopupMsg = "Загляни в наш Telegram-канал",
        tg_PopupSub = "Свежие апдейты, новости и помощь по скрипту",
        tg_NoThanks = "Позже",
        tg_Subscribe = "Подписаться",
        tg_Copied = "Скопировано!",

        close_PopupTitle = "Выход",
        close_PopupMsg = "Закрыть скрипт ReACK?",
        close_PopupSub = "Все активные функции и подсветка будут отключены",
        close_Cancel = "Отмена",
        close_Confirm = "Закрыть",
    },
    EN = {
        tab_Combat = "Combat",
        tab_Farm = "Farm",
        tab_Player = "Player",
        tab_Settings = "Settings",

        sec_AutoM1 = "Auto M1",
        sec_KillAura = "Kill Aura",
        sec_InfPunch = "Infinite Punch",
        sec_FarmMain = "Automation",
        sec_FarmOpt = "Targets & Skills",
        sec_Movement = "Movement",
        sec_EspTypes = "Visuals (ESP)",
        sec_EspColor = "ESP Palette",
        sec_Buttons = "Screen Buttons",
        sec_Account = "Account & Community",
        sec_Settings = "General",
        sec_System = "Server & Config",

        en_AutoM1 = "Auto M1",
        en_AutoM1_desc = "Automatically swings at enemies inside your front vision cone.",
        wall_Chk = "Wall Check",
        wall_Chk_desc = "Ignore targets hiding behind solid walls and cover.",
        atk_Delay = "Attack Delay",
        atk_Delay_desc = "Pause between standard M1 punches.",
        dist = "Attack Distance",
        dist_desc = "Maximum reach for Auto M1 activation.",
        fov = "Vision FOV",
        fov_desc = "Target acquisition angle in front of your character.",

        en_KA = "Kill Aura",
        en_KA_desc = "Automatically strikes all nearby enemies in a 360° radius.",
        auto_Face = "Auto Face Target",
        auto_Face_desc = "Smoothly rotates your character toward the closest enemy.",
        ka_Delay = "Aura Delay",
        ka_Delay_desc = "Pause between hits while Kill Aura is active.",
        ka_Range = "Aura Radius",
        ka_Range_desc = "Distance around you where Kill Aura locks onto targets.",

        en_Inf = "Infinite Punch",
        en_Inf_desc = "Strips cooldowns and action locks from your primary attacks.",
        punch_Cd = "Punch Cooldown",
        punch_Cd_desc = "Minimum recovery delay between punches.",

        en_Farm = "Auto Farm",
        en_Farm_desc = "Locks onto a target, slips behind them, and finishes the combo.",
        farm_Mode = "Farm Mode",
        farm_Mode_desc = "Legit - smooth run, Semi-Rage - dashes, Rage - fast back strafe.",
        farm_Behind = "Behind Distance",
        farm_Behind_desc = "How close to stick behind the target's back.",
        farm_Search = "Search Radius",
        farm_Search_desc = "Arena radius scanned for valid enemies.",
        farm_LowHP = "Lowest HP First",
        farm_LowHP_desc = "Prioritize enemies with the lowest remaining health.",
        farm_Skills = "Auto Skills (E / R)",
        farm_Skills_desc = "Automatically fires your abilities when close to a target.",
        farm_Return = "Auto Lobby Return",
        farm_Return_desc = "Automatically jumps back into the arena after respawning.",
        farm_AntiRagdoll = "Anti-Ragdoll",
        farm_AntiRagdoll_desc = "Prevents knockdowns and ragdoll stuns while farming.",
        farm_Spd = "Approach Speed",
        farm_Spd_desc = "How fast your character closes the gap to a target.",

        en_Speed = "Speed Boost",
        en_Speed_desc = "Boosts your character's base running speed.",
        walk_Spd = "Walk Speed",
        walk_Spd_desc = "Desired movement speed across the map.",
        en_InfDash = "Infinite Dash",
        en_InfDash_desc = "Removes Q-dash cooldowns - dash freely without pauses.",

        en_Esp = "Enable ESP",
        en_Esp_desc = "Reveals players cleanly through walls and obstacles.",
        esp_Box = "2D Box",
        esp_Box_desc = "Draws a crisp bounding box around each enemy.",
        esp_Skel = "Skeleton",
        esp_Skel_desc = "Renders live bone connections for enemy characters.",
        esp_Tracers = "Tracers",
        esp_Tracers_desc = "Draws lines from the bottom of your screen to enemies.",
        esp_Info = "Player Info",
        esp_Info_desc = "Displays name, health, distance, and moveset overhead.",
        esp_Highlight = "Chams Highlight",
        esp_Highlight_desc = "Full-body silhouette outline visible through walls.",
        esp_TargetCol = "Highlight Active Target",
        esp_TargetCol_desc = "Accents your current farm or aura target in bright red.",
        esp_Presets = "Color Presets",
        esp_Presets_desc = "Pick a clean highlight color in a single tap.",
        esp_R = "Red (R)",
        esp_R_desc = "Red color channel intensity.",
        esp_G = "Green (G)",
        esp_G_desc = "Green color channel intensity.",
        esp_B = "Blue (B)",
        esp_B_desc = "Blue color channel intensity.",

        btn_M1 = "Auto M1 Button",
        btn_M1_desc = "Places a floating quick-toggle button for Auto M1 on screen.",
        btn_KA = "Kill Aura Button",
        btn_KA_desc = "Places a floating quick-toggle button for Kill Aura on screen.",
        btn_Farm = "Auto Farm Button",
        btn_Farm_desc = "Places a floating quick-toggle button for Auto Farm on screen.",

        tg_ChannelBtn = "Our Telegram Channel",
        tg_ChannelSub = "Updates, news, and support - t.me/viberscript",
        tg_CopyAct = "Open",

        en_Save = "Auto-Save Config",
        en_Save_desc = "Automatically remembers every setting you change.",
        lang_Btn = "Interface Language",
        lang_Btn_desc = "Switch menu language between Russian and English.",
        lang_Val = "English",
        reset_Pos = "Reset Positions",
        reset_Pos_desc = "Returns the floating pill and HUD to their default spots.",
        reset_PosBtn = "Reset",
        srv_HopBtn = "Server Hop",
        srv_HopBtn_desc = "Moves you to another active server with open slots.",
        srv_HopAct = "Hop",
        srv_Searching = "Searching...",
        srv_None = "No slots",
        srv_Err = "Error",
        reset_Save = "Reset All Data",
        reset_Save_desc = "Clears saved data and restores default settings.",
        reset_SaveBtn = "Reset",

        tg_PopupTitle = "Community",
        tg_PopupMsg = "Join our Telegram channel",
        tg_PopupSub = "Fresh updates, news, and script support",
        tg_NoThanks = "Later",
        tg_Subscribe = "Subscribe",
        tg_Copied = "Copied!",

        close_PopupTitle = "Exit",
        close_PopupMsg = "Close ReACK script?",
        close_PopupSub = "All active features and visuals will be turned off",
        close_Cancel = "Cancel",
        close_Confirm = "Close",
    }
}

local function tr(key)
    local dict = I18N[State.Lang] or I18N.RU
    return dict[key] or I18N.EN[key] or key
end

local Connections, BehaviorCache, OriginalCooldowns, OriginalDashValues = {}, {}, {}, {}
local OriginalCollide = {}
local GameModules = {
    Ready = false,
    Registry = nil,
    CharacterUtil = nil,
    Behaviors = nil,
    DashController = nil,
    ExtraDashModules = {},
}

local syncAutoM1UI, syncKillAuraUI, syncAutoFarmUI, updateSaveStatusLabel, buildMainUI
local updAutoM1Float, updKillAuraFloat, updAutoFarmFloat
local unload

local function buildPayload()
    return {
        Lang = State.Lang,
        SeenLanguagePopup = State.SeenLanguagePopup,
        SeenTelegramPopup = State.SeenTelegramPopup,
        AutoSave = State.AutoSave,

        AutoM1Range = State.AutoM1Range,
        AutoM1FOV = State.AutoM1FOV,
        AutoM1WallCheck = State.AutoM1WallCheck,
        M1Interval = State.M1Interval,
        ShowAutoM1FloatingBtn = State.ShowAutoM1FloatingBtn,

        KillAuraRange = State.KillAuraRange,
        KillAuraAutoFace = State.KillAuraAutoFace,
        KillAuraInterval = State.KillAuraInterval,
        ShowKillAuraFloatingBtn = State.ShowKillAuraFloatingBtn,

        FarmMode = State.FarmMode,
        FarmAutoReturn = State.FarmAutoReturn,
        FarmAntiRagdoll = State.FarmAntiRagdoll,
        FarmSearchRange = State.FarmSearchRange,
        FarmAttackRange = State.FarmAttackRange,
        FarmBehindDist = State.FarmBehindDist,
        FarmMoveSpeed = State.FarmMoveSpeed,
        FarmUseSkills = State.FarmUseSkills,
        FarmTargetLowHP = State.FarmTargetLowHP,
        ShowAutoFarmFloatingBtn = State.ShowAutoFarmFloatingBtn,

        PunchCooldown = State.PunchCooldown,
        WalkSpeedValue = State.WalkSpeedValue,
        InfiniteDash = State.InfiniteDash,

        EspEnabled = State.EspEnabled,
        EspBox = State.EspBox,
        EspSkeleton = State.EspSkeleton,
        EspTracers = State.EspTracers,
        EspInfo = State.EspInfo,
        EspHighlight = State.EspHighlight,
        EspTargetAccent = State.EspTargetAccent,
        EspColorR = State.EspColorR,
        EspColorG = State.EspColorG,
        EspColorB = State.EspColorB,

        OrbPos = State.OrbPos,
        HudPos = State.HudPos,
        AutoM1BtnPos = State.AutoM1BtnPos,
        KillAuraBtnPos = State.KillAuraBtnPos,
        AutoFarmBtnPos = State.AutoFarmBtnPos,
    }
end

local function saveConfigNow(forceSave)
    if not forceSave and not State.AutoSave then
        return false
    end
    local payload = buildPayload()
    env.ReACKPersist = payload

    local savedToFile = false
    if canUseFS then
        local okEnc, encoded = pcall(HttpService.JSONEncode, HttpService, payload)
        if okEnc and type(encoded) == "string" and #encoded > 2 then
            if pcall(fnWrite, CONFIG_PATH, encoded) then
                savedToFile = true
            end
        end
    end

    if updateSaveStatusLabel then
        if savedToFile then
            updateSaveStatusLabel(State.Lang == "RU" and "Статус: Сохранено" or "Status: Saved")
        else
            updateSaveStatusLabel(State.Lang == "RU" and "Статус: В памяти" or "Status: In Memory")
        end
    end
    return true
end

local sliderSaveToken = 0
local function autoSaveImmediate()
    if State.AutoSave then
        saveConfigNow(false)
    end
end

local function autoSaveDebounced()
    if not State.AutoSave then return end
    sliderSaveToken = sliderSaveToken + 1
    local tok = sliderSaveToken
    task.delay(0.2, function()
        if State.Active and State.AutoSave and sliderSaveToken == tok then
            saveConfigNow(false)
        end
    end)
end

local function applyLoadedData(data)
    if type(data) ~= "table" then return false end
    if data.Lang == "RU" or data.Lang == "EN" then State.Lang = data.Lang end

    if type(data.SeenLanguagePopup) == "boolean" then
        State.SeenLanguagePopup = data.SeenLanguagePopup
    else
        State.SeenLanguagePopup = true
    end

    if type(data.SeenTelegramPopup) == "boolean" then
        State.SeenTelegramPopup = data.SeenTelegramPopup
    else
        State.SeenTelegramPopup = false
    end

    for k, v in pairs(data) do
        if State[k] ~= nil and type(v) == type(State[k]) and not string.find(k, "Pos") then
            State[k] = v
        end
    end

    if not FARM_PRESETS[State.FarmMode] then
        State.FarmMode = "Semi-Rage"
    end

    for _, pk in ipairs({ "OrbPos", "HudPos", "AutoM1BtnPos", "KillAuraBtnPos", "AutoFarmBtnPos" }) do
        if type(data[pk]) == "table" and #data[pk] == 4 then
            State[pk] = data[pk]
        end
    end

    if math.abs((State.OrbPos[3] or 0) - 0.055) < 0.001 and (State.OrbPos[4] or 0) == 0 then
        State.OrbPos = { DEFAULT_ORB_POS[1], DEFAULT_ORB_POS[2], DEFAULT_ORB_POS[3], DEFAULT_ORB_POS[4] }
    end

    env.ReACKPersist = buildPayload()
    return true
end

local function loadInitialConfig()
    if canUseFS then
        local exists = true
        if fnIsFile then
            local okE, resE = pcall(fnIsFile, CONFIG_PATH)
            exists = (okE and resE == true)
        end
        if exists then
            local okR, raw = pcall(fnRead, CONFIG_PATH)
            if okR and type(raw) == "string" and #raw > 2 then
                local okD, data = pcall(HttpService.JSONDecode, HttpService, raw)
                if okD and applyLoadedData(data) then
                    return true
                end
            end
        end
    end

    if type(env.ReACKPersist) == "table" then
        return applyLoadedData(env.ReACKPersist)
    end
    return false
end

loadInitialConfig()

local function tryResolveModules()
    local ok = pcall(function()
        local sh = ReplicatedStorage:FindFirstChild("Shared")
        if not sh then error("No Shared") end
        local ab = sh:FindFirstChild("Abilities")
        local ut = sh:FindFirstChild("Util")
        local cl = sh:FindFirstChild("Client")
        if not ab or not ut then error("No Folders") end
        local reg = ab:FindFirstChild("Registry")
        local cu = ut:FindFirstChild("CharacterUtil")
        local beh = ab:FindFirstChild("Behaviors")
        if not reg or not cu or not beh then error("No Modules") end
        GameModules.Registry = require(reg)
        GameModules.CharacterUtil = require(cu)
        GameModules.Behaviors = beh

        table.clear(GameModules.ExtraDashModules)
        if cl then
            if cl:FindFirstChild("DashController") then
                pcall(function()
                    GameModules.DashController = require(cl.DashController)
                end)
            end
            for _, child in ipairs(cl:GetDescendants()) do
                if child:IsA("ModuleScript") and string.find(string.lower(child.Name), "dash") then
                    pcall(function()
                        local m = require(child)
                        if type(m) == "table" then
                            table.insert(GameModules.ExtraDashModules, m)
                            if not GameModules.DashController then
                                GameModules.DashController = m
                            end
                        end
                    end)
                end
            end
        end
        GameModules.Ready = true
    end)
    if not ok then
        GameModules.Ready = false
    end
    return GameModules.Ready
end

local function getCharacterParts(plr)
    if GameModules.Ready and GameModules.CharacterUtil then
        local ok, c, h, r = pcall(GameModules.CharacterUtil.GetParts, plr)
        if ok and c then return c, h, r end
    end
    local char = plr and plr.Character
    if not char then return nil, nil, nil end
    return char, char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

local function getMoveset()
    if not GameModules.Ready and not tryResolveModules() then return nil end
    if not GameModules.Registry then return nil end
    local ok, ms = pcall(GameModules.Registry.GetMoveset, localPlayer:GetAttribute("Moveset"))
    if ok and ms and ms.Abilities then
        return ms
    end
    return nil
end

local function getPrimaryAttack()
    local ms = getMoveset()
    if not ms then return nil end
    local ab = ms.Abilities[1]
    return (ab and ab.Config and ab.Config.Kind == "Attack") and ab or nil
end

local CooldownModule = nil
local COOLDOWN_KEYS = {
    "Cooldown", "MinCooldown", "MaxCooldown",
    "AttackCooldown", "ComboCooldown", "M1Cooldown",
    "Endlag", "Recovery", "Delay", "GlobalCooldown"
}
local COOLDOWN_TIMESTAMPS = {
    "LastUsed", "NextUse", "CooldownEnd", "CooldownUntil",
    "_lastUsed", "_nextUse", "_cooldownEnd", "_cooldownUntil", "Timer"
}
local COMBAT_LOCK_ATTRS = {
    "Attacking", "IsAttacking", "Busy", "InAction",
    "GlobalCooldown", "M1Cooldown", "AttackCooldown", "PunchCooldown"
}

local DASH_COOLDOWN_KEYS = {
    "Cooldown", "DashCooldown", "SideDashCooldown", "FrontDashCooldown",
    "BackDashCooldown", "MinCooldown", "MaxCooldown", "GlobalCooldown",
    "Recovery", "Endlag", "Delay", "DashDelay"
}
local DASH_TIMESTAMPS = {
    "LastDash", "NextDash", "LastUsed", "NextUse",
    "CooldownEnd", "CooldownUntil", "_lastDash", "_nextDash",
    "_cooldownEnd", "_cooldownUntil", "Timer", "LastSideDash"
}
local DASH_LOCK_ATTRS = {
    "DashCooldown", "SideDashCooldown", "Dashing", "IsDashing", "DashBusy", "NoDash", "CantDash"
}

local fnGetUpvalues = (type(debug) == "table" and type(debug.getupvalues) == "function" and debug.getupvalues)
    or (type(getupvalues) == "function" and getupvalues) or nil
local fnSetUpvalue = (type(debug) == "table" and type(debug.setupvalue) == "function" and debug.setupvalue)
    or (type(setupvalue) == "function" and setupvalue) or nil

local function makeTableWritable(tbl)
    if type(tbl) ~= "table" then return end
    if type(setreadonly) == "function" then
        pcall(setreadonly, tbl, false)
    elseif type(make_writeable) == "function" then
        pcall(make_writeable, tbl)
    end
end

local function resolveCooldownModule()
    if CooldownModule ~= nil then return CooldownModule end
    CooldownModule = false
    pcall(function()
        local sh = ReplicatedStorage:FindFirstChild("Shared")
        if not sh then return end
        for _, desc in ipairs(sh:GetDescendants()) do
            if desc:IsA("ModuleScript") and string.find(string.lower(desc.Name), "cooldown") then
                local ok, mod = pcall(require, desc)
                if ok and type(mod) == "table" then
                    CooldownModule = mod
                    break
                end
            end
        end
    end)
    return CooldownModule
end

local function resetAbilityTimers(ab)
    if type(ab) ~= "table" then return end
    makeTableWritable(ab)
    for _, tKey in ipairs(COOLDOWN_TIMESTAMPS) do
        if type(ab[tKey]) == "number" then
            ab[tKey] = 0
        end
    end

    local cdMod = resolveCooldownModule()
    if type(cdMod) == "table" then
        for _, fnName in ipairs({ "Clear", "Reset", "Remove", "EndCooldown", "ResetAll" }) do
            if type(cdMod[fnName]) == "function" then
                pcall(cdMod[fnName], ab)
                pcall(cdMod[fnName], localPlayer, ab)
                pcall(cdMod[fnName], localPlayer)
            end
        end
        for _, tblKey in ipairs({ "Active", "Cooldowns", "_cooldowns", "Timers" }) do
            if type(cdMod[tblKey]) == "table" then
                makeTableWritable(cdMod[tblKey])
                cdMod[tblKey][ab] = nil
                if ab.Name then cdMod[tblKey][ab.Name] = nil end
                if ab.Id then cdMod[tblKey][ab.Id] = nil end
            end
        end
    end
end

local function clearCombatLockAttributes()
    local char = localPlayer.Character
    for _, attr in ipairs(COMBAT_LOCK_ATTRS) do
        if localPlayer:GetAttribute(attr) == true then
            pcall(localPlayer.SetAttribute, localPlayer, attr, false)
        elseif type(localPlayer:GetAttribute(attr)) == "number" and localPlayer:GetAttribute(attr) > 0 then
            pcall(localPlayer.SetAttribute, localPlayer, attr, 0)
        end
        if char then
            if char:GetAttribute(attr) == true then
                pcall(char.SetAttribute, char, attr, false)
            elseif type(char:GetAttribute(attr)) == "number" and char:GetAttribute(attr) > 0 then
                pcall(char.SetAttribute, char, attr, 0)
            end
        end
    end
end

local function patchConfigTable(cfg, cdVal)
    if type(cfg) ~= "table" then return end
    makeTableWritable(cfg)
    for _, k in ipairs(COOLDOWN_KEYS) do
        if type(cfg[k]) == "number" then
            OriginalCooldowns[cfg] = OriginalCooldowns[cfg] or {}
            if OriginalCooldowns[cfg][k] == nil then
                OriginalCooldowns[cfg][k] = cfg[k]
            end
            cfg[k] = math.min(OriginalCooldowns[cfg][k], cdVal)
        end
    end
end

local function applyInfinitePunch()
    if not State.InfinitePunch then return end
    if not GameModules.Ready then tryResolveModules() end

    local ms = getMoveset()
    if not ms or type(ms.Abilities) ~= "table" then return end

    for idx, ab in pairs(ms.Abilities) do
        if type(ab) == "table" then
            local isAttack = (idx == 1)
                or (ab.Config and (ab.Config.Kind == "Attack" or ab.Config.Slot == 1 or ab.Config.IsPrimary == true))
            if isAttack then
                patchConfigTable(ab, State.PunchCooldown)
                if type(ab.Config) == "table" then
                    patchConfigTable(ab.Config, State.PunchCooldown)
                    if type(ab.Config.Combo) == "table" then
                        for _, stepCfg in pairs(ab.Config.Combo) do
                            patchConfigTable(stepCfg, State.PunchCooldown)
                        end
                    end
                end
                resetAbilityTimers(ab)
            end
        end
    end
    clearCombatLockAttributes()
end

local function restoreCooldowns()
    for cont, keys in pairs(OriginalCooldowns) do
        makeTableWritable(cont)
        for k, v in pairs(keys) do
            cont[k] = v
        end
    end
    table.clear(OriginalCooldowns)
end

local function patchDashFunctionUpvalues(fn)
    if type(fn) ~= "function" or not fnGetUpvalues or not fnSetUpvalue then return end
    local ok, upvals = pcall(fnGetUpvalues, fn)
    if not ok or type(upvals) ~= "table" then return end
    for idx, val in pairs(upvals) do
        if type(val) == "number" and val > 0.05 then
            pcall(fnSetUpvalue, fn, idx, 0)
        elseif type(val) == "boolean" and val == false then
            pcall(fnSetUpvalue, fn, idx, true)
        elseif type(val) == "table" then
            makeTableWritable(val)
            for k, subV in pairs(val) do
                local lk = string.lower(tostring(k))
                if type(subV) == "number" and (string.find(lk, "dash") or string.find(lk, "cool") or string.find(lk, "last") or string.find(lk, "next") or string.find(lk, "time")) then
                    val[k] = 0
                elseif type(subV) == "boolean" and (string.find(lk, "can") or string.find(lk, "ready")) then
                    val[k] = true
                elseif type(subV) == "boolean" and (string.find(lk, "busy") or string.find(lk, "dashing") or string.find(lk, "cool")) then
                    val[k] = false
                end
            end
        end
    end
end

local function patchDashTable(tbl, depth)
    if type(tbl) ~= "table" or depth > 3 then return end
    makeTableWritable(tbl)
    for _, k in ipairs(DASH_COOLDOWN_KEYS) do
        if type(tbl[k]) == "number" then
            OriginalDashValues[tbl] = OriginalDashValues[tbl] or {}
            if OriginalDashValues[tbl][k] == nil then
                OriginalDashValues[tbl][k] = tbl[k]
            end
            tbl[k] = 0
        end
    end
    for _, tKey in ipairs(DASH_TIMESTAMPS) do
        if type(tbl[tKey]) == "number" then
            tbl[tKey] = 0
        end
    end
    if type(tbl.CanDash) == "boolean" then tbl.CanDash = true end
    if type(tbl.IsDashing) == "boolean" then tbl.IsDashing = false end
    if type(tbl.MaxCharges) == "number" and type(tbl.Charges) == "number" then
        tbl.Charges = tbl.MaxCharges
    end
    for k, v in pairs(tbl) do
        if type(v) == "function" then
            patchDashFunctionUpvalues(v)
        elseif type(v) == "table" and depth < 3 then
            local lk = string.lower(tostring(k))
            if string.find(lk, "config") or string.find(lk, "state") or string.find(lk, "cool") or string.find(lk, "dash") or string.find(lk, "setting") then
                patchDashTable(v, depth + 1)
            end
        end
    end
end

local function applyInfiniteDash()
    if not State.InfiniteDash then return end
    if not GameModules.Ready then tryResolveModules() end

    local targets = {}
    if type(GameModules.DashController) == "table" then
        table.insert(targets, GameModules.DashController)
    end
    for _, extra in ipairs(GameModules.ExtraDashModules) do
        table.insert(targets, extra)
    end

    for _, dc in ipairs(targets) do
        patchDashTable(dc, 1)
        for _, fnName in ipairs({ "ResetCooldown", "ClearCooldown", "Reset", "EndCooldown" }) do
            if type(dc[fnName]) == "function" then
                pcall(dc[fnName])
                pcall(dc[fnName], dc)
            end
        end
    end

    local char = localPlayer.Character
    for _, attr in ipairs(DASH_LOCK_ATTRS) do
        if localPlayer:GetAttribute(attr) == true then
            pcall(localPlayer.SetAttribute, localPlayer, attr, false)
        elseif type(localPlayer:GetAttribute(attr)) == "number" and localPlayer:GetAttribute(attr) > 0 then
            pcall(localPlayer.SetAttribute, localPlayer, attr, 0)
        end
        if char then
            if char:GetAttribute(attr) == true then
                pcall(char.SetAttribute, char, attr, false)
            elseif type(char:GetAttribute(attr)) == "number" and char:GetAttribute(attr) > 0 then
                pcall(char.SetAttribute, char, attr, 0)
            end
        end
    end
end

local function restoreDashCooldowns()
    for cont, keys in pairs(OriginalDashValues) do
        makeTableWritable(cont)
        for k, v in pairs(keys) do
            cont[k] = v
        end
    end
    table.clear(OriginalDashValues)
end

local function activateAbilityObject(ab)
    if not ab or not ab.Config or not GameModules.Behaviors then return false end

    if State.InfinitePunch then
        applyInfinitePunch()
        resetAbilityTimers(ab)
        clearCombatLockAttributes()
    end

    local kind = ab.Config.Kind
    local beh = BehaviorCache[kind]
    if not beh then
        local mod = GameModules.Behaviors:FindFirstChild(kind)
        if not mod then return false end
        local ok, loaded = pcall(require, mod)
        if not ok then return false end
        beh = loaded
        BehaviorCache[kind] = beh
    end
    local okAct = pcall(function()
        local inst = beh.new(ab)
        if State.InfinitePunch and type(inst) == "table" then
            resetAbilityTimers(inst)
        end
        inst:Activate()
    end)
    return okAct
end

local function triggerM1()
    if localPlayer:GetAttribute("InGame") == false then return end
    local c, h, r = getCharacterParts(localPlayer)
    if not c or not h or not r or h.Health <= 0 then return end

    if not GameModules.Ready then
        tryResolveModules()
    end

    local fired = false
    if GameModules.Ready then
        local ab = getPrimaryAttack()
        if ab then
            fired = activateAbilityObject(ab)
        end
    end

    if not fired then
        local tool = c:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
        end
    end
end

local function triggerSkillSlots()
    local ms = getMoveset()
    if not ms or not GameModules.Registry then return end
    for slot = 1, 3 do
        local ok, ab = pcall(GameModules.Registry.AbilityForSlot, ms, slot)
        if ok and ab and ab.Config and ab.Config.Kind ~= "Attack" then
            activateAbilityObject(ab)
        end
    end
end

local function restoreNoclip()
    for part, origVal in pairs(OriginalCollide) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = origVal
            end)
        end
    end
    table.clear(OriginalCollide)
end

local RAGDOLL_ATTRS = { "Ragdoll", "Ragdolled", "IsRagdoll", "Downed", "Knocked" }

local function applyAntiRagdoll(char, hum)
    if not char or not hum or hum.Health <= 0 then return end
    if hum.PlatformStand then hum.PlatformStand = false end
    if hum.Sit then hum.Sit = false end

    local hState = hum:GetState()
    if hState == Enum.HumanoidStateType.Physics
        or hState == Enum.HumanoidStateType.Ragdoll
        or hState == Enum.HumanoidStateType.FallingDown then
        pcall(hum.ChangeState, hum, Enum.HumanoidStateType.Running)
    end

    for _, attr in ipairs(RAGDOLL_ATTRS) do
        if char:GetAttribute(attr) == true then pcall(char.SetAttribute, char, attr, false) end
        if localPlayer:GetAttribute(attr) == true then pcall(localPlayer.SetAttribute, localPlayer, attr, false) end
    end

    for _, inst in ipairs(char:GetDescendants()) do
        if inst:IsA("Motor6D") then
            if not inst.Enabled then inst.Enabled = true end
        elseif inst:IsA("BallSocketConstraint") then
            inst.Enabled = false
            pcall(inst.Destroy, inst)
        elseif inst:IsA("BodyVelocity") or inst:IsA("LinearVelocity") or inst:IsA("BodyAngularVelocity") then
            pcall(inst.Destroy, inst)
        end
    end
end

local function isGuiAncestryVisible(inst)
    local cur = inst
    while cur and cur ~= localPlayer do
        if cur:IsA("ScreenGui") then
            if not cur.Enabled then return false end
        elseif cur:IsA("GuiObject") then
            if not cur.Visible then return false end
        end
        cur = cur.Parent
    end
    return true
end

local function findVisiblePlayButton()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end

    for _, desc in ipairs(pg:GetDescendants()) do
        if desc:IsA("GuiButton") and isGuiAncestryVisible(desc) then
            local selfTxt = (desc:IsA("TextButton") and desc.Text) or ""
            local cleanSelf = string.lower((selfTxt:gsub("[%s!]+", "")))
            if cleanSelf == "play" then
                return desc
            end
            for _, sub in ipairs(desc:GetDescendants()) do
                if sub:IsA("TextLabel") and sub.Visible then
                    local cleanSub = string.lower((sub.Text:gsub("[%s!]+", "")))
                    if cleanSub == "play" then
                        return desc
                    end
                end
            end
        end
    end
    return nil
end

local function isPlayerInLobby()
    local inGame = localPlayer:GetAttribute("InGame")
    if inGame == false then return true end
    if inGame == nil and findVisiblePlayButton() ~= nil then return true end
    return false
end

local function fireGuiButton(btn)
    if not btn then return false end
    local fired = false
    if type(getconnections) == "function" then
        for _, sigName in ipairs({ "Activated", "MouseButton1Click", "MouseButton1Down" }) do
            local okS, sig = pcall(function() return btn[sigName] end)
            if okS and sig then
                local okC, conns = pcall(getconnections, sig)
                if okC and type(conns) == "table" then
                    for _, c in ipairs(conns) do
                        if c.Fire then pcall(c.Fire, c); fired = true
                        elseif c.Function then task.spawn(c.Function); fired = true end
                    end
                end
            end
        end
    end
    if type(firesignal) == "function" then
        pcall(firesignal, btn.Activated)
        pcall(firesignal, btn.MouseButton1Click)
        fired = true
    end
    return fired
end

local function tryReturnFromLobby()
    local _, hum, myRoot = getCharacterParts(localPlayer)
    if not hum or not myRoot or hum.Health <= 0 then return end

    local playBtn = findVisiblePlayButton()
    if playBtn then
        fireGuiButton(playBtn)
        task.wait(0.35)
        if not isPlayerInLobby() then return end
    end

    if type(firetouchinterest) == "function" then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
                local part = desc.Parent
                local fullName = string.lower(part:GetFullName())
                local dist = (part.Position - myRoot.Position).Magnitude
                if dist <= 120 and (
                    string.find(fullName, "portal") or string.find(fullName, "arena")
                    or string.find(fullName, "play") or string.find(fullName, "enter")
                    or string.find(fullName, "teleport") or string.find(fullName, "gate")
                ) then
                    pcall(firetouchinterest, myRoot, part, 0)
                    task.wait(0.05)
                    pcall(firetouchinterest, myRoot, part, 1)
                end
            end
        end
    end

    hum:MoveTo(myRoot.Position + myRoot.CFrame.LookVector * 40)
end

local isServerHopping = false

local function httpGetRequest(url)
    local reqFn = (type(request) == "function" and request)
        or (type(http_request) == "function" and http_request)
        or (type(syn) == "table" and type(syn.request) == "function" and syn.request)
        or (type(fluxus) == "table" and type(fluxus.request) == "function" and fluxus.request)

    if reqFn then
        local ok, res = pcall(reqFn, {
            Url = url,
            Method = "GET",
            Headers = { ["Accept"] = "application/json" }
        })
        if ok and type(res) == "table" and type(res.Body) == "string" then
            return res.Body
        end
    end

    local okGet, body = pcall(game.HttpGet, game, url)
    if okGet and type(body) == "string" then
        return body
    end
    return nil
end

local function performPopulatedServerHop(statusCallback)
    if isServerHopping then return end
    isServerHopping = true
    if statusCallback then statusCallback(tr("srv_Searching")) end

    task.spawn(function()
        local placeId = game.PlaceId
        local currentJob = game.JobId
        local candidates = {}
        local cursor = nil
        local pagesFetched = 0
        local fetchFailed = false

        while pagesFetched < 3 and #candidates < 15 do
            pagesFetched = pagesFetched + 1
            local url = string.format(
                "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100%s",
                placeId,
                cursor and ("&cursor=" .. HttpService:UrlEncode(cursor)) or ""
            )

            local raw = httpGetRequest(url)
            if not raw then
                fetchFailed = true
                break
            end

            local okDec, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
            if not okDec or type(decoded) ~= "table" or type(decoded.data) ~= "table" then
                fetchFailed = true
                break
            end

            for _, srv in ipairs(decoded.data) do
                if type(srv) == "table"
                    and type(srv.id) == "string"
                    and srv.id ~= ""
                    and srv.id ~= currentJob
                    and type(srv.playing) == "number"
                    and type(srv.maxPlayers) == "number"
                    and srv.playing > 0
                    and srv.playing < srv.maxPlayers then
                    table.insert(candidates, {
                        id = srv.id,
                        playing = srv.playing,
                        maxPlayers = srv.maxPlayers,
                    })
                end
            end

            if type(decoded.nextPageCursor) == "string" and decoded.nextPageCursor ~= "" then
                cursor = decoded.nextPageCursor
            else
                break
            end
        end

        if #candidates == 0 then
            isServerHopping = false
            if statusCallback then
                statusCallback(fetchFailed and tr("srv_Err") or tr("srv_None"))
            end
            return
        end

        table.sort(candidates, function(a, b)
            if a.playing ~= b.playing then
                return a.playing > b.playing
            end
            return (a.maxPlayers - a.playing) < (b.maxPlayers - b.playing)
        end)

        local attemptIdx = 1
        local failConn
        failConn = TeleportService.TeleportInitFailed:Connect(function(plr)
            if plr ~= localPlayer then return end
            attemptIdx = attemptIdx + 1
            local nextSrv = candidates[attemptIdx]
            if nextSrv and State.Active then
                if statusCallback then
                    statusCallback(string.format("%d/%d...", nextSrv.playing, nextSrv.maxPlayers))
                end
                pcall(TeleportService.TeleportToPlaceInstance, TeleportService, placeId, nextSrv.id, localPlayer)
            else
                if failConn then failConn:Disconnect() end
                isServerHopping = false
                if statusCallback then statusCallback(tr("srv_None")) end
            end
        end)

        local first = candidates[1]
        if statusCallback then
            statusCallback(string.format("%d/%d...", first.playing, first.maxPlayers))
        end
        pcall(TeleportService.TeleportToPlaceInstance, TeleportService, placeId, first.id, localPlayer)

        task.delay(12, function()
            if failConn then failConn:Disconnect() end
            isServerHopping = false
        end)
    end)
end

local function isEnemyAttackable(plr)
    if plr == localPlayer then return false end
    local inMatch = plr:GetAttribute("InGame")
    if inMatch == false then return false end
    local tChar, tHum, tRoot = getCharacterParts(plr)
    if not tChar or not tHum or not tRoot or tHum.Health <= 0 then return false end
    if tChar:FindFirstChildOfClass("ForceField") then return false end
    return true, tChar, tHum, tRoot
end

local function isSolidWallBlocked(myChar, myRoot, tChar, tRoot)
    local origin = myRoot.Position + Vector3.new(0, 1.5, 0)
    local goal = tRoot.Position + Vector3.new(0, 1.5, 0)
    local dir = goal - origin
    if dir.Magnitude <= 0.1 then return false end

    local ignore = { myChar, tChar }
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true

    for _ = 1, 5 do
        rp.FilterDescendantsInstances = ignore
        local hit = workspace:Raycast(origin, dir, rp)
        if not hit then return false end
        local inst = hit.Instance
        if inst and (not inst.CanCollide or inst.Transparency >= 0.95) then
            table.insert(ignore, inst)
        else
            return true
        end
    end
    return false
end

local function hasVisibleTargetInFront(maxRange)
    local myChar, myHum, myRoot = getCharacterParts(localPlayer)
    if not myChar or not myHum or not myRoot or myHum.Health <= 0 then return false end

    local lookFlat = Vector3.new(myRoot.CFrame.LookVector.X, 0, myRoot.CFrame.LookVector.Z)
    lookFlat = (lookFlat.Magnitude < 0.001) and myRoot.CFrame.LookVector or lookFlat.Unit
    local minDot = math.cos(math.rad(State.AutoM1FOV * 0.5))

    for _, plr in ipairs(Players:GetPlayers()) do
        local ok, tChar, _, tRoot = isEnemyAttackable(plr)
        if ok then
            local off = tRoot.Position - myRoot.Position
            if off.Magnitude <= maxRange then
                local dir = Vector3.new(off.X, 0, off.Z)
                if dir.Magnitude <= 0.1 or lookFlat:Dot(dir.Unit) >= minDot then
                    if not State.AutoM1WallCheck or not isSolidWallBlocked(myChar, myRoot, tChar, tRoot) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function getNearestAuraTarget(maxRange)
    local _, myHum, myRoot = getCharacterParts(localPlayer)
    if not myHum or not myRoot or myHum.Health <= 0 then return nil end

    local best, bestDist = nil, maxRange
    for _, plr in ipairs(Players:GetPlayers()) do
        local ok, _, _, tRoot = isEnemyAttackable(plr)
        if ok then
            local d = (myRoot.Position - tRoot.Position).Magnitude
            if d <= bestDist then
                bestDist = d
                best = tRoot
            end
        end
    end
    return best
end

local function getBestFarmTarget()
    local _, _, myRoot = getCharacterParts(localPlayer)
    if not myRoot then return nil, nil, nil end

    local bestRoot, bestPlr, bestHum = nil, nil, nil
    local bestScore = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        local ok, _, tHum, tRoot = isEnemyAttackable(plr)
        if ok then
            local dist = (myRoot.Position - tRoot.Position).Magnitude
            if dist <= State.FarmSearchRange then
                local score = State.FarmTargetLowHP and (tHum.Health * 10 + dist) or dist
                if score < bestScore then
                    bestScore = score
                    bestRoot = tRoot
                    bestPlr = plr
                    bestHum = tHum
                end
            end
        end
    end
    return bestRoot, bestPlr, bestHum
end

local THEME = {
    WindowBg     = Color3.fromRGB(16, 16, 18),
    SidebarBg    = Color3.fromRGB(20, 20, 22),
    RowHover     = Color3.fromRGB(26, 26, 29),
    ControlBg    = Color3.fromRGB(26, 26, 29),
    ControlHover = Color3.fromRGB(36, 36, 40),
    Border       = Color3.fromRGB(38, 38, 42),
    BorderLight  = Color3.fromRGB(56, 56, 62),

    PillBg       = Color3.fromRGB(14, 14, 16),
    ToggleOff    = Color3.fromRGB(44, 44, 48),
    ToggleOn     = Color3.fromRGB(236, 236, 240),
    ThumbOff     = Color3.fromRGB(236, 236, 240),
    ThumbOn      = Color3.fromRGB(16, 16, 18),

    White        = Color3.fromRGB(244, 244, 246),
    TextPrimary  = Color3.fromRGB(240, 240, 244),
    TextDim      = Color3.fromRGB(136, 136, 142),
    TextSubHdr   = Color3.fromRGB(178, 178, 185),
    TextMuted    = Color3.fromRGB(98, 98, 104),
    TrackBg      = Color3.fromRGB(38, 38, 42),
    ScrollBar    = Color3.fromRGB(80, 80, 86),
    OnlineDot    = Color3.fromRGB(84, 226, 134),
    Danger       = Color3.fromRGB(215, 65, 72),
    DangerHover  = Color3.fromRGB(190, 52, 58),
}

local function addCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = parent
    return c
end

local function addPillCorner(parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = parent
    return c
end

local function addStroke(parent, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or THEME.Border
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function mountScreenGui(guiObj)
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            local old = hui:FindFirstChild(guiObj.Name); if old then old:Destroy() end
            guiObj.Parent = hui
            return
        end
    end
    local okC = pcall(function()
        local old = CoreGui:FindFirstChild(guiObj.Name); if old then old:Destroy() end
        guiObj.Parent = CoreGui
    end)
    if not okC then
        local pg = localPlayer:WaitForChild("PlayerGui", 5)
        if pg then
            local old = pg:FindFirstChild(guiObj.Name); if old then old:Destroy() end
            guiObj.Parent = pg
        end
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReACKGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mountScreenGui(screenGui)

local windowSize = Vector2.new(BASE_WIN_W, BASE_WIN_H)
local currentAdaptiveScale = 1
local mainFrame, mainScaleObj, loaderScaleObj, langScaleObj, popupScaleObj, closeScaleObj, hudScaleObj

local function isMobileDevice()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return true
    end
    if vp.X < 1024 or vp.Y < 540 then
        return true
    end
    return false
end

local function computeAdaptiveScale()
    local cam = workspace.CurrentCamera
    if not cam then return 1 end
    local vp = cam.ViewportSize
    if vp.X <= 0 or vp.Y <= 0 then return 1 end

    local mobile = isMobileDevice()
    if mobile then
        local maxW = vp.X * 0.72
        local maxH = vp.Y * 0.82
        local s = math.min(maxW / windowSize.X, maxH / windowSize.Y)
        return math.clamp(s, 0.56, 1.15)
    else
        local targetW = vp.X * 0.48
        local targetH = vp.Y * 0.64
        local s = math.min(targetW / windowSize.X, targetH / windowSize.Y)
        return math.clamp(s, 0.85, 1.25)
    end
end

local function updateAdaptiveScale()
    currentAdaptiveScale = computeAdaptiveScale()
    if mainScaleObj and mainScaleObj.Parent then
        mainScaleObj.Scale = currentAdaptiveScale
    end
    if loaderScaleObj and loaderScaleObj.Parent then
        loaderScaleObj.Scale = currentAdaptiveScale
    end
    if langScaleObj and langScaleObj.Parent then
        langScaleObj.Scale = currentAdaptiveScale
    end
    if popupScaleObj and popupScaleObj.Parent then
        popupScaleObj.Scale = currentAdaptiveScale
    end
    if closeScaleObj and closeScaleObj.Parent then
        closeScaleObj.Scale = currentAdaptiveScale
    end
    if hudScaleObj and hudScaleObj.Parent then
        hudScaleObj.Scale = math.clamp(currentAdaptiveScale, 0.78, 1.15)
    end
end

updateAdaptiveScale()
if workspace.CurrentCamera then
    table.insert(Connections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateAdaptiveScale))
end

local cachedPlaceName = "Roblox"
task.spawn(function()
    local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
    if ok and type(info) == "table" and type(info.Name) == "string" and info.Name ~= "" then
        cachedPlaceName = info.Name
    end
end)

local ESPCache = {}

local R15_BONES = {
    { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
}
local R6_BONES = {
    { "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" }, { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
}

local function newDraw(kind, props)
    if not hasDrawing then return nil end
    local ok, obj = pcall(Drawing.new, kind)
    if not ok or not obj then return nil end
    for k, v in pairs(props) do
        pcall(function() obj[k] = v end)
    end
    return obj
end

local function destroyESPEntry(uid)
    local e = ESPCache[uid]
    if not e then return end
    if e.box then pcall(function() e.box:Remove() end) end
    if e.tracer then pcall(function() e.tracer:Remove() end) end
    if e.infoTxt then pcall(function() e.infoTxt:Remove() end) end
    if e.bones then
        for _, ln in ipairs(e.bones) do
            pcall(function() ln:Remove() end)
        end
    end
    if e.cham then pcall(function() e.cham:Destroy() end) end
    ESPCache[uid] = nil
end

local function hideESPEntry(e)
    if not e then return end
    if e.box then e.box.Visible = false end
    if e.tracer then e.tracer.Visible = false end
    if e.infoTxt then e.infoTxt.Visible = false end
    if e.bones then
        for _, ln in ipairs(e.bones) do
            ln.Visible = false
        end
    end
    if e.cham then e.cham.Enabled = false end
end

local function clearAllEsp()
    for uid in pairs(ESPCache) do
        destroyESPEntry(uid)
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            for _, child in ipairs(char:GetChildren()) do
                if child:IsA("Highlight") and child.Name == "ReACKChams" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

local function getOrCreateESPEntry(plr)
    local e = ESPCache[plr.UserId]
    if e then return e end
    e = {
        box = newDraw("Square", { Thickness = 1.4, Filled = false, Visible = false }),
        tracer = newDraw("Line", { Thickness = 1.2, Visible = false }),
        infoTxt = newDraw("Text", { Size = 13, Center = true, Outline = true, Visible = false }),
        bones = {},
        cham = nil,
    }
    for i = 1, 14 do
        local ln = newDraw("Line", { Thickness = 1.3, Visible = false })
        if ln then e.bones[i] = ln end
    end
    ESPCache[plr.UserId] = e
    return e
end

table.insert(Connections, Players.PlayerRemoving:Connect(function(plr)
    if plr then
        destroyESPEntry(plr.UserId)
    end
end))

local function createReackLogo(parent, x, y, sizePx)
    if LOGO_ASSET_ID ~= "" then
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(0, sizePx, 0, sizePx)
        img.Position = UDim2.new(0, x, 0, y)
        img.BackgroundTransparency = 1
        img.Image = LOGO_ASSET_ID
        img.ScaleType = Enum.ScaleType.Fit
        img.ZIndex = 8
        img.Parent = parent
        return img
    end

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, sizePx, 0, sizePx)
    holder.Position = UDim2.new(0, x, 0, y)
    holder.BackgroundColor3 = THEME.ControlBg
    holder.BorderSizePixel = 0
    holder.ZIndex = 8
    holder.Parent = parent
    addCorner(holder, math.max(5, math.floor(sizePx * 0.26)))
    addStroke(holder, THEME.White, 1.25, 0.25)

    local outerDiamond = Instance.new("Frame")
    outerDiamond.AnchorPoint = Vector2.new(0.5, 0.5)
    outerDiamond.Position = UDim2.fromScale(0.5, 0.5)
    outerDiamond.Size = UDim2.fromScale(0.56, 0.56)
    outerDiamond.Rotation = 45
    outerDiamond.BackgroundColor3 = THEME.White
    outerDiamond.BorderSizePixel = 0
    outerDiamond.ZIndex = 9
    outerDiamond.Parent = holder
    addCorner(outerDiamond, 2)

    local innerCut = Instance.new("Frame")
    innerCut.AnchorPoint = Vector2.new(0.5, 0.5)
    innerCut.Position = UDim2.fromScale(0.5, 0.5)
    innerCut.Size = UDim2.fromScale(0.46, 0.46)
    innerCut.BackgroundColor3 = THEME.WindowBg
    innerCut.BorderSizePixel = 0
    innerCut.ZIndex = 10
    innerCut.Parent = outerDiamond
    addCorner(innerCut, 1)

    local coreSlash = Instance.new("Frame")
    coreSlash.AnchorPoint = Vector2.new(0.5, 0.5)
    coreSlash.Position = UDim2.fromScale(0.52, 0.52)
    coreSlash.Size = UDim2.fromScale(0.34, 0.14)
    coreSlash.Rotation = -45
    coreSlash.BackgroundColor3 = THEME.White
    coreSlash.BorderSizePixel = 0
    coreSlash.ZIndex = 11
    coreSlash.Parent = holder
    addPillCorner(coreSlash)

    return holder
end

local function attachButtonAnim(btn, normalBg, hoverBg)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.14, Enum.EasingStyle.Quad), { BackgroundColor3 = hoverBg or THEME.ControlHover }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.14, Enum.EasingStyle.Quad), { BackgroundColor3 = normalBg or THEME.ControlBg }):Play()
    end)
end

local function drawIcon(parent, kind, color)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 20, 0, 20)
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.fromScale(0.5, 0.5)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 8
    holder.Parent = parent

    local fills = {}
    local softFills = {}
    local strokes = {}

    local function bar(cx, cy, w, h, rot, isSoft, zAdd)
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.new(0, cx, 0, cy)
        f.Size = UDim2.new(0, w, 0, h)
        f.Rotation = rot or 0
        f.BackgroundColor3 = color
        f.BackgroundTransparency = isSoft and 0.72 or 0
        f.BorderSizePixel = 0
        f.ZIndex = 9 + (zAdd or 0)
        f.Parent = holder
        addPillCorner(f)
        if isSoft then
            table.insert(softFills, f)
        else
            table.insert(fills, f)
        end
        return f
    end

    local function box(cx, cy, w, h, rot, rad, isCutout, zAdd)
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.new(0, cx, 0, cy)
        f.Size = UDim2.new(0, w, 0, h)
        f.Rotation = rot or 0
        f.BackgroundColor3 = isCutout and THEME.ControlBg or color
        f.BorderSizePixel = 0
        f.ZIndex = 9 + (zAdd or 0)
        f.Parent = holder
        if rad and rad > 0 then
            addCorner(f, rad)
        end
        if not isCutout then
            table.insert(fills, f)
        end
        return f
    end

    local function ring(cx, cy, w, h, thick, isPill, rad, rot, filledSoft)
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.new(0, cx, 0, cy)
        f.Size = UDim2.new(0, w, 0, h)
        f.Rotation = rot or 0
        f.BackgroundColor3 = color
        f.BackgroundTransparency = filledSoft and 0.85 or 1
        f.BorderSizePixel = 0
        f.ZIndex = 8
        f.Parent = holder
        if isPill then
            addPillCorner(f)
        elseif rad and rad > 0 then
            addCorner(f, rad)
        end
        local s = addStroke(f, color, thick or 1.5)
        table.insert(strokes, s)
        if filledSoft then
            table.insert(softFills, f)
        end
        return f
    end

    if kind == "Combat" then
        bar(10, 10, 16.5, 2.0, -45)
        bar(6.2, 13.8, 5.4, 1.7, 45)
        bar(4.2, 15.8, 2.4, 2.4, 45)

        bar(10, 10, 16.5, 2.0, 45)
        bar(13.8, 13.8, 5.4, 1.7, -45)
        bar(15.8, 15.8, 2.4, 2.4, 45)

    elseif kind == "Farm" then
        ring(10, 10, 15.5, 15.5, 1.4, true, 0, 0, true)
        bar(10.8, 6.8, 6.4, 2.1, -55)
        bar(10.0, 10.0, 6.2, 1.9, 0)
        bar(9.2, 13.2, 6.4, 2.1, -55)

    elseif kind == "Player" then
        ring(10, 6.6, 6.4, 6.4, 1.5, true, 0, 0, true)
        bar(10, 6.6, 3.6, 3.6, 0)
        ring(10, 15.2, 13.0, 7.2, 1.5, true, 0, 0, true)
        bar(10, 15.4, 9.6, 3.4, 0)

    elseif kind == "Settings" then
        bar(10, 10, 2.4, 16.4, 0)
        bar(10, 10, 16.4, 2.4, 0)
        bar(10, 10, 2.4, 16.4, 45)
        bar(10, 10, 2.4, 16.4, -45)
        box(10, 10, 11.4, 11.4, 0, 6, false, 1)
        box(10, 10, 5.2, 5.2, 0, 3, true, 2)

    elseif kind == "Telegram" then
        ring(10, 10, 17, 17, 1.3, true, 0, 0, true)
        bar(9.2, 8.0, 8.6, 2.0, -25, false, 1)
        bar(10.0, 12.2, 7.6, 2.0, 22, false, 1)
        bar(13.0, 10.0, 7.6, 1.9, 76, false, 1)
        bar(9.6, 10.4, 5.2, 1.5, -38, true, 2)

    elseif kind == "Minimize" then
        bar(10, 10, 11, 1.6, 0)

    elseif kind == "Close" then
        bar(10, 10, 11.5, 1.6, 45)
        bar(10, 10, 11.5, 1.6, -45)

    elseif kind == "Resize" then
        bar(11, 11, 9.5, 1.4, -45)
        bar(13.4, 13.4, 5.4, 1.4, -45)

    else
        ring(10, 10, 11, 11, 1.5, true)
        bar(10, 10, 3.5, 3.5, 0)
    end

    return function(newCol)
        for _, f in ipairs(fills) do
            TweenService:Create(f, TweenInfo.new(0.16, Enum.EasingStyle.Quad), { BackgroundColor3 = newCol }):Play()
        end
        for _, f in ipairs(softFills) do
            TweenService:Create(f, TweenInfo.new(0.16, Enum.EasingStyle.Quad), { BackgroundColor3 = newCol }):Play()
        end
        for _, s in ipairs(strokes) do
            TweenService:Create(s, TweenInfo.new(0.16, Enum.EasingStyle.Quad), { Color = newCol }):Play()
        end
    end
end

local function createDropdownDiamond(parent, xOffset)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 12, 0, 12)
    holder.AnchorPoint = Vector2.new(1, 0.5)
    holder.Position = UDim2.new(1, xOffset or -10, 0.5, 0)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 10
    holder.Parent = parent

    local d = Instance.new("Frame")
    d.AnchorPoint = Vector2.new(0.5, 0.5)
    d.Position = UDim2.fromScale(0.5, 0.5)
    d.Size = UDim2.new(0, 5, 0, 5)
    d.Rotation = 45
    d.BackgroundTransparency = 1
    d.ZIndex = 10
    d.Parent = holder
    local st = addStroke(d, THEME.TextDim, 1.2, 0.1)

    return function(isOpen)
        TweenService:Create(st, TweenInfo.new(0.16), {
            Color = isOpen and THEME.White or THEME.TextDim
        }):Play()
    end
end

local activeTabKey = "Combat"
local isMenuOpen = true
local isMenuAnimating = false
local farmHudFrame, pillBtn, pillScaleObj, autoM1Float, killAuraFloat, autoFarmFloat
local loopsStarted = false
local currentFarmTarget, currentFarmPlr, currentFarmHum = nil, nil, nil
local currentKillAuraTarget = nil
local wasAutoRotateDisabled = false
local hudStatusLbl, hudTargetLbl, hudStatsLbl, hudArenaLbl

local function updateHudVisibility()
    if farmHudFrame and farmHudFrame.Parent then
        local show = State.AutoFarm
        if show and not farmHudFrame.Visible then
            farmHudFrame.Visible = true
            farmHudFrame.Size = UDim2.new(0, 180, 0, 96)
            TweenService:Create(farmHudFrame, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 208, 0, 114)
            }):Play()
        elseif not show and farmHudFrame.Visible then
            farmHudFrame.Visible = false
        end
    end
end

local function setAutoFarmEnabled(enabled)
    State.AutoFarm = (enabled == true)
    updateHudVisibility()
    if not State.AutoFarm then
        currentFarmTarget, currentFarmPlr, currentFarmHum = nil, nil, nil
        restoreNoclip()
        local _, h, r = getCharacterParts(localPlayer)
        if h then
            h.WalkSpeed = State.DefaultWalkSpeed
            h.PlatformStand = false
        end
        if r then
            r.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

local function syncAllCombatVisuals()
    if syncAutoM1UI then syncAutoM1UI(State.AutoM1, true) end
    if syncKillAuraUI then syncKillAuraUI(State.KillAura, true) end
    if syncAutoFarmUI then syncAutoFarmUI(State.AutoFarm, true) end
    if updAutoM1Float then updAutoM1Float() end
    if updKillAuraFloat then updKillAuraFloat() end
    if updAutoFarmFloat then updAutoFarmFloat() end
    updateHudVisibility()
end

local showSimpleLoader, showLanguagePopup, showTelegramPopup, showCloseConfirmPopup

local function resetAllSavedData()
    State = getDefaultState()
    env.ReACKPersist = nil
    windowSize = Vector2.new(BASE_WIN_W, BASE_WIN_H)
    updateAdaptiveScale()

    if fnDelFile then
        pcall(fnDelFile, CONFIG_PATH)
    end

    setAutoFarmEnabled(false)
    clearAllEsp()
    restoreCooldowns()
    restoreDashCooldowns()
    restoreNoclip()
    local _, h = getCharacterParts(localPlayer)
    if h then
        h.WalkSpeed = State.DefaultWalkSpeed
        h.AutoRotate = true
    end

    syncAutoM1UI, syncKillAuraUI, syncAutoFarmUI, updateSaveStatusLabel = nil, nil, nil, nil
    updAutoM1Float, updKillAuraFloat, updAutoFarmFloat = nil, nil, nil
    hudStatusLbl, hudTargetLbl, hudStatsLbl, hudArenaLbl = nil, nil, nil, nil

    for _, name in ipairs({
        "ReACKMainFrame",
        "ReACKAutoFarmHUD",
        "ReACKDynamicPillBtn",
        "ReACKAutoM1Float",
        "ReACKKillAuraFloat",
        "ReACKAutoFarmFloat",
        "ReACKLoaderFrame",
        "ReACKLanguagePopupOverlay",
        "ReACKTelegramPopupOverlay",
        "ReACKCloseConfirmOverlay",
    }) do
        local old = screenGui:FindFirstChild(name)
        if old then old:Destroy() end
    end

    mainFrame, mainScaleObj, farmHudFrame, pillBtn, pillScaleObj = nil, nil, nil, nil, nil
    autoM1Float, killAuraFloat, autoFarmFloat = nil, nil, nil
    activeTabKey = "Combat"
    isMenuOpen = true
    isMenuAnimating = false

    showSimpleLoader(function()
        showLanguagePopup(function()
            buildMainUI(true)
            task.delay(0.25, function()
                showTelegramPopup(false)
            end)
        end)
    end)
end

local function startBackgroundLoops()
    if loopsStarted then return end
    loopsStarted = true

    table.insert(Connections, localPlayer.CharacterAdded:Connect(function()
        task.wait(0.15)
        if State.InfinitePunch then applyInfinitePunch() end
        if State.InfiniteDash then applyInfiniteDash() end
    end))

    table.insert(Connections, UserInputService.InputBegan:Connect(function(inp, gameProcessed)
        if gameProcessed or not State.Active or not State.InfiniteDash then return end
        if inp.KeyCode == Enum.KeyCode.Q then
            applyInfiniteDash()
            local dc = GameModules.DashController
            if type(dc) == "table" then
                if type(dc.TryDash) == "function" then
                    pcall(dc.TryDash)
                elseif type(dc.Dash) == "function" then
                    pcall(dc.Dash)
                end
            end
        end
    end))

    task.spawn(function()
        local lastSkillTick = 0
        local lastDashTick = 0
        local lastLobbyReturnTick = 0
        while State.Active do
            if State.AutoFarm then
                local _, myHum, myRoot = getCharacterParts(localPlayer)
                if myHum and myRoot and myHum.Health > 0 then
                    if isPlayerInLobby() then
                        currentFarmTarget, currentFarmPlr, currentFarmHum = nil, nil, nil
                        if State.FarmAutoReturn and (os.clock() - lastLobbyReturnTick) >= 1.1 then
                            lastLobbyReturnTick = os.clock()
                            tryReturnFromLobby()
                        end
                        task.wait(0.2)
                    else
                        local targetRoot, targetPlr, targetHum = getBestFarmTarget()
                        currentFarmTarget = targetRoot
                        currentFarmPlr = targetPlr
                        currentFarmHum = targetHum
                        if targetRoot then
                            local dist = (myRoot.Position - targetRoot.Position).Magnitude

                            if State.FarmMode ~= "Legit" and dist > 16 and GameModules.DashController and (os.clock() - lastDashTick) >= 1.15 then
                                lastDashTick = os.clock()
                                pcall(GameModules.DashController.TryDash)
                            end

                            if dist <= State.FarmAttackRange then
                                triggerM1()
                                if State.FarmUseSkills and (os.clock() - lastSkillTick) >= 0.42 then
                                    lastSkillTick = os.clock()
                                    triggerSkillSlots()
                                end
                                task.wait(FARM_ATTACK_INTERVAL)
                            else
                                task.wait(0.05)
                            end
                        else
                            task.wait(0.1)
                        end
                    end
                else
                    currentFarmTarget, currentFarmPlr, currentFarmHum = nil, nil, nil
                    task.wait(0.12)
                end
            else
                currentFarmTarget, currentFarmPlr, currentFarmHum = nil, nil, nil
                task.wait(0.12)
            end
        end
    end)

    task.spawn(function()
        while State.Active do
            if State.AutoM1 and not State.AutoFarm then
                if hasVisibleTargetInFront(State.AutoM1Range) then
                    triggerM1()
                    task.wait(math.clamp(State.M1Interval, 0.05, 1.5))
                else
                    task.wait(0.06)
                end
            else
                task.wait(0.09)
            end
        end
    end)

    task.spawn(function()
        while State.Active do
            if State.KillAura and not State.AutoFarm then
                local target = getNearestAuraTarget(State.KillAuraRange)
                currentKillAuraTarget = target
                if target then
                    triggerM1()
                    task.wait(math.clamp(State.KillAuraInterval, 0.05, 1.5))
                else
                    task.wait(0.06)
                end
            else
                currentKillAuraTarget = nil
                task.wait(0.09)
            end
        end
    end)

    task.spawn(function()
        while State.Active do
            if farmHudFrame and farmHudFrame.Visible and hudStatusLbl then
                local moveset = tostring(localPlayer:GetAttribute("Moveset") or "Default")
                local inMatch = (localPlayer:GetAttribute("InGame") == true)

                if not inMatch and isPlayerInLobby() then
                    hudStatusLbl.Text = "Status: Lobby Return"
                elseif currentFarmPlr then
                    hudStatusLbl.Text = "Status: Hunting (" .. State.FarmMode .. ")"
                else
                    hudStatusLbl.Text = "Status: Searching"
                end

                if currentFarmPlr and currentFarmHum and currentFarmHum.Parent then
                    hudTargetLbl.Text = string.format("Target: %s [%d/%d]", currentFarmPlr.DisplayName, math.max(0, math.floor(currentFarmHum.Health)), math.floor(currentFarmHum.MaxHealth))
                else
                    hudTargetLbl.Text = "Target: None"
                end

                hudStatsLbl.Text = string.format("Range: %d | Dist: %.1f", math.floor(State.FarmSearchRange), State.FarmBehindDist)
                hudArenaLbl.Text = string.format("Moveset: %s | Arena: %s", moveset, inMatch and "Yes" or "No")
            end
            task.wait(0.2)
        end
    end)

    table.insert(Connections, RunService.Stepped:Connect(function()
        if not State.Active then return end
        local char, hum = getCharacterParts(localPlayer)
        if not char or not hum then return end

        local inLobby = isPlayerInLobby()

        if State.AutoFarm and State.FarmAntiRagdoll and not inLobby then
            applyAntiRagdoll(char, hum)
        end

        local needNoclip = State.AutoFarm and not inLobby and (State.FarmMode == "Semi-Rage" or State.FarmMode == "Rage")
        if needNoclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if OriginalCollide[part] == nil then
                        OriginalCollide[part] = part.CanCollide
                    end
                    if part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        elseif next(OriginalCollide) ~= nil then
            restoreNoclip()
        end
    end))

    local orbitAngle = 0
    table.insert(Connections, RunService.Heartbeat:Connect(function(dt)
        if not State.Active then return end
        local char, hum, myRoot = getCharacterParts(localPlayer)
        if not char or not hum or not myRoot or hum.Health <= 0 then return end

        local inLobby = isPlayerInLobby()

        if State.InfinitePunch then
            clearCombatLockAttributes()
            local m1 = getPrimaryAttack()
            if m1 then
                resetAbilityTimers(m1)
            end
        end

        if State.InfiniteDash then
            applyInfiniteDash()
        end

        if State.AutoFarm and not inLobby then
            if State.FarmAntiRagdoll then
                applyAntiRagdoll(char, hum)
            end

            if currentFarmTarget and currentFarmTarget.Parent then
                if wasAutoRotateDisabled then
                    hum.AutoRotate = true
                    wasAutoRotateDisabled = false
                end

                local tPos = currentFarmTarget.Position
                local tVel = currentFarmTarget.AssemblyLinearVelocity
                local tLook = currentFarmTarget.CFrame.LookVector
                local tRight = currentFarmTarget.CFrame.RightVector

                local predPos = tPos + Vector3.new(tVel.X, 0, tVel.Z) * 0.12
                local behindPos = predPos - (tLook * State.FarmBehindDist)
                local flatLookTarget = Vector3.new(tPos.X, myRoot.Position.Y, tPos.Z)

                if State.FarmMode == "Legit" then
                    if hum.WalkSpeed < State.FarmMoveSpeed then
                        hum.WalkSpeed = State.FarmMoveSpeed
                    end
                    hum:MoveTo(behindPos)
                    if (behindPos.Y - myRoot.Position.Y) > 2.2 then
                        hum.Jump = true
                    end
                    if (flatLookTarget - myRoot.Position).Magnitude > 0.2 then
                        local goalCF = CFrame.new(myRoot.Position, flatLookTarget)
                        myRoot.CFrame = myRoot.CFrame:Lerp(goalCF, math.clamp(dt * 14, 0, 1))
                    end

                elseif State.FarmMode == "Semi-Rage" then
                    local delta = behindPos - myRoot.Position
                    local dist = delta.Magnitude
                    if dist > 0.8 then
                        local speed = math.min(State.FarmMoveSpeed, math.max(dist * 9, 28))
                        myRoot.AssemblyLinearVelocity = delta.Unit * speed
                    else
                        myRoot.AssemblyLinearVelocity = Vector3.new(tVel.X, 0, tVel.Z)
                    end
                    if (flatLookTarget - myRoot.Position).Magnitude > 0.1 then
                        myRoot.CFrame = CFrame.new(myRoot.Position, flatLookTarget)
                    end

                else
                    orbitAngle = orbitAngle + dt * 7.0
                    local strafeOffset = tRight * (math.sin(orbitAngle) * 2.2)
                    local rageGoal = behindPos + strafeOffset
                    local delta = rageGoal - myRoot.Position
                    local dist = delta.Magnitude

                    local step = math.min(dist, State.FarmMoveSpeed * dt)
                    local nextPos = (dist > 0.05) and (myRoot.Position + delta.Unit * step) or rageGoal

                    myRoot.AssemblyLinearVelocity = Vector3.new(tVel.X, 0, tVel.Z)
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                    if (flatLookTarget - nextPos).Magnitude > 0.1 then
                        myRoot.CFrame = CFrame.new(nextPos, flatLookTarget)
                    else
                        myRoot.CFrame = CFrame.new(nextPos)
                    end
                end
            end
        else
            if State.KillAura and State.KillAuraAutoFace and currentKillAuraTarget and currentKillAuraTarget.Parent then
                hum.AutoRotate = false
                wasAutoRotateDisabled = true
                local flatLook = Vector3.new(currentKillAuraTarget.Position.X, myRoot.Position.Y, currentKillAuraTarget.Position.Z)
                if (flatLook - myRoot.Position).Magnitude > 0.1 then
                    myRoot.CFrame = CFrame.new(myRoot.Position, flatLook)
                end
            elseif wasAutoRotateDisabled then
                hum.AutoRotate = true
                wasAutoRotateDisabled = false
            end

            if State.SpeedBoost and hum.WalkSpeed ~= State.WalkSpeedValue then
                hum.WalkSpeed = State.WalkSpeedValue
            end
        end
    end))

    table.insert(Connections, RunService.RenderStepped:Connect(function()
        if not State.Active then return end
        local cam = workspace.CurrentCamera
        if not cam then return end

        local _, _, myRoot = getCharacterParts(localPlayer)
        local baseCol = getEspColor()
        local targetAccentCol = Color3.fromRGB(255, 95, 95)
        local vp = cam.ViewportSize

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer then
                local char, hum, root = getCharacterParts(plr)
                local alive = (char ~= nil and hum ~= nil and root ~= nil and hum.Health > 0)

                if not State.EspEnabled or not alive then
                    hideESPEntry(ESPCache[plr.UserId])
                else
                    local e = getOrCreateESPEntry(plr)
                    local isLockedTarget = State.EspTargetAccent and ((currentFarmPlr == plr) or (currentKillAuraTarget == root))
                    local col = isLockedTarget and targetAccentCol or baseCol

                    local head = char:FindFirstChild("Head")
                    local topWorld = (head and head.Position + Vector3.new(0, 1.1, 0)) or (root.Position + Vector3.new(0, 3, 0))
                    local botWorld = root.Position - Vector3.new(0, 3, 0)

                    local topScr, topVis = cam:WorldToViewportPoint(topWorld)
                    local botScr, botVis = cam:WorldToViewportPoint(botWorld)
                    local onScreen = (topVis or botVis) and topScr.Z > 0

                    if e.box then
                        if State.EspBox and onScreen then
                            local h = math.max(math.abs(botScr.Y - topScr.Y), 12)
                            local w = h * 0.58
                            e.box.Size = Vector2.new(w, h)
                            e.box.Position = Vector2.new(topScr.X - w * 0.5, topScr.Y)
                            e.box.Color = col
                            e.box.Visible = true
                        else
                            e.box.Visible = false
                        end
                    end

                    if #e.bones > 0 then
                        if State.EspSkeleton and onScreen then
                            local boneList = char:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
                            for i, ln in ipairs(e.bones) do
                                local pair = boneList[i]
                                local p1 = pair and char:FindFirstChild(pair[1])
                                local p2 = pair and char:FindFirstChild(pair[2])
                                if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                                    local s1, v1 = cam:WorldToViewportPoint(p1.Position)
                                    local s2, v2 = cam:WorldToViewportPoint(p2.Position)
                                    if v1 and v2 and s1.Z > 0 and s2.Z > 0 then
                                        ln.From = Vector2.new(s1.X, s1.Y)
                                        ln.To = Vector2.new(s2.X, s2.Y)
                                        ln.Color = col
                                        ln.Visible = true
                                    else
                                        ln.Visible = false
                                    end
                                else
                                    ln.Visible = false
                                end
                            end
                        else
                            for _, ln in ipairs(e.bones) do
                                ln.Visible = false
                            end
                        end
                    end

                    if e.tracer then
                        if State.EspTracers and onScreen then
                            e.tracer.From = Vector2.new(vp.X * 0.5, vp.Y)
                            e.tracer.To = Vector2.new(botScr.X, botScr.Y)
                            e.tracer.Color = col
                            e.tracer.Visible = true
                        else
                            e.tracer.Visible = false
                        end
                    end

                    if e.infoTxt then
                        if State.EspInfo and onScreen then
                            local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude + 0.5) or 0
                            local hpCur = math.max(0, math.floor(hum.Health + 0.5))
                            local hpMax = math.max(1, math.floor(hum.MaxHealth + 0.5))
                            local mv = tostring(plr:GetAttribute("Moveset") or "Default")
                            e.infoTxt.Text = string.format("%s [%d/%d] [%dm] %s", plr.DisplayName, hpCur, hpMax, dist, mv)
                            e.infoTxt.Position = Vector2.new(topScr.X, topScr.Y - 16)
                            e.infoTxt.Color = col
                            e.infoTxt.Visible = true
                        else
                            e.infoTxt.Visible = false
                        end
                    end

                    if State.EspHighlight then
                        if not e.cham or e.cham.Parent ~= char then
                            if e.cham then pcall(function() e.cham:Destroy() end) end
                            local oldHl = char:FindFirstChild("ReACKChams")
                            if oldHl then pcall(function() oldHl:Destroy() end) end

                            local hl = Instance.new("Highlight")
                            hl.Name = "ReACKChams"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.FillTransparency = 0.72
                            hl.OutlineTransparency = 0.15
                            hl.Adornee = char
                            hl.Parent = char
                            e.cham = hl
                        end
                        e.cham.FillColor = col
                        e.cham.OutlineColor = isLockedTarget and THEME.White or col
                        e.cham.Enabled = true
                    elseif e.cham then
                        e.cham.Enabled = false
                    end
                end
            end
        end
    end))

    table.insert(Connections, localPlayer:GetAttributeChangedSignal("Moveset"):Connect(function()
        if State.InfinitePunch then task.wait(0.1); applyInfinitePunch() end
    end))
end

local function attachHoldToDrag(btn, onTap, onSaved, onRestoreVisual)
    local isTouching = false
    local activeTouchType = nil
    local isDragging = false
    local holdReady = false
    local token = 0
    local startP, origP = Vector3.zero, btn.Position
    local lastTapTick = 0
    local st = btn:FindFirstChildOfClass("UIStroke")

    local function fireTapOnce()
        local now = os.clock()
        if (now - lastTapTick) >= 0.16 then
            lastTapTick = now
            onTap()
        end
    end

    btn.InputBegan:Connect(function(inp)
        local uType = inp.UserInputType
        if uType ~= Enum.UserInputType.MouseButton1 and uType ~= Enum.UserInputType.Touch then
            return
        end
        if isTouching then return end

        isTouching = true
        activeTouchType = uType
        isDragging = false
        holdReady = false
        startP = inp.Position
        origP = btn.Position

        token = token + 1
        local myT = token
        task.delay(0.32, function()
            if isTouching and token == myT and not isDragging then
                holdReady = true
                if st then
                    TweenService:Create(st, TweenInfo.new(0.15), { Color = THEME.White, Thickness = 1.6 }):Play()
                end
            end
        end)
    end)

    local function onInputMove(inp)
        if not isTouching then return end
        local isMove = (activeTouchType == Enum.UserInputType.Touch and inp.UserInputType == Enum.UserInputType.Touch)
            or (activeTouchType == Enum.UserInputType.MouseButton1 and inp.UserInputType == Enum.UserInputType.MouseMovement)
        if not isMove then return end

        local delta = inp.Position - startP
        if not isDragging and holdReady and delta.Magnitude > 10 then
            isDragging = true
        end

        if isDragging then
            btn.Position = UDim2.new(origP.X.Scale, origP.X.Offset + delta.X, origP.Y.Scale, origP.Y.Offset + delta.Y)
        end
    end

    local function onInputRelease(inp)
        if not isTouching then return end
        local uType = inp.UserInputType
        if uType ~= Enum.UserInputType.Touch and uType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        local wasDragging = isDragging
        local wasHoldReady = holdReady

        isTouching = false
        activeTouchType = nil
        isDragging = false
        holdReady = false
        token = token + 1

        if wasHoldReady or wasDragging then
            if onRestoreVisual then onRestoreVisual() end
        end

        if wasDragging then
            if onSaved then
                local p = btn.Position
                onSaved({ p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset })
            end
        else
            fireTapOnce()
        end
    end

    btn.InputChanged:Connect(onInputMove)
    table.insert(Connections, UserInputService.InputChanged:Connect(onInputMove))

    btn.InputEnded:Connect(onInputRelease)
    table.insert(Connections, UserInputService.InputEnded:Connect(onInputRelease))
end

local function bindReliableClick(btn, callback)
    local lastClick = 0
    local function trigger()
        local now = os.clock()
        if (now - lastClick) < 0.18 then return end
        lastClick = now
        callback()
    end

    btn.Activated:Connect(trigger)
    btn.MouseButton1Click:Connect(trigger)
    btn.TouchTap:Connect(trigger)
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            trigger()
        end
    end)
end

local function toggleMainMenuAnimated()
    if isMenuAnimating or not mainFrame then return end
    isMenuAnimating = true
    isMenuOpen = not isMenuOpen
    local targetScale = computeAdaptiveScale()
    currentAdaptiveScale = targetScale

    if isMenuOpen then
        if pillBtn and pillBtn.Parent then
            if pillScaleObj then
                TweenService:Create(pillScaleObj, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Scale = 0.25
                }):Play()
            end
            task.delay(0.14, function()
                if pillBtn and pillBtn.Parent then
                    pillBtn.Visible = false
                end
                if pillScaleObj then
                    pillScaleObj.Scale = 1
                end
            end)
        end

        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, windowSize.X, 0, windowSize.Y)
        if mainScaleObj then
            mainScaleObj.Scale = targetScale * 0.88
            TweenService:Create(mainScaleObj, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Scale = targetScale
            }):Play()
        end
        task.delay(0.27, function()
            isMenuAnimating = false
        end)
    else
        if mainScaleObj then
            TweenService:Create(mainScaleObj, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Scale = targetScale * 0.88
            }):Play()
        end
        task.delay(0.17, function()
            if mainFrame then
                mainFrame.Visible = false
            end
            if mainScaleObj then
                mainScaleObj.Scale = targetScale
            end

            if pillBtn and pillBtn.Parent then
                pillBtn.Visible = true
                if pillScaleObj then
                    pillScaleObj.Scale = 0.3
                    TweenService:Create(pillScaleObj, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Scale = 1
                    }):Play()
                end
            end
            isMenuAnimating = false
        end)
    end
end

local function ensureFloatingControls()
    if not pillBtn or not pillBtn.Parent then
        pillBtn = Instance.new("TextButton")
        pillBtn.Name = "ReACKDynamicPillBtn"
        pillBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        pillBtn.Size = UDim2.new(0, 128, 0, 42)
        pillBtn.Position = UDim2.new(State.OrbPos[1], State.OrbPos[2], State.OrbPos[3], State.OrbPos[4])
        pillBtn.BackgroundColor3 = THEME.PillBg
        pillBtn.BackgroundTransparency = 0.04
        pillBtn.BorderSizePixel = 0
        pillBtn.Text = ""
        pillBtn.AutoButtonColor = false
        pillBtn.Visible = (not isMenuOpen)
        pillBtn.ZIndex = 30
        pillBtn.Parent = screenGui

        addPillCorner(pillBtn)
        local pillStroke = addStroke(pillBtn, THEME.White, 1.15, 0.72)

        pillScaleObj = Instance.new("UIScale")
        pillScaleObj.Scale = 1
        pillScaleObj.Parent = pillBtn

        local dotAura = Instance.new("Frame")
        dotAura.AnchorPoint = Vector2.new(0.5, 0.5)
        dotAura.Position = UDim2.new(0, 25, 0.5, 0)
        dotAura.Size = UDim2.new(0, 22, 0, 22)
        dotAura.BackgroundColor3 = THEME.White
        dotAura.BackgroundTransparency = 0.78
        dotAura.BorderSizePixel = 0
        dotAura.ZIndex = 31
        dotAura.Parent = pillBtn
        addPillCorner(dotAura)

        local dotCore = Instance.new("Frame")
        dotCore.AnchorPoint = Vector2.new(0.5, 0.5)
        dotCore.Position = UDim2.new(0, 25, 0.5, 0)
        dotCore.Size = UDim2.new(0, 11, 0, 11)
        dotCore.BackgroundColor3 = THEME.White
        dotCore.BorderSizePixel = 0
        dotCore.ZIndex = 32
        dotCore.Parent = pillBtn
        addPillCorner(dotCore)

        TweenService:Create(
            dotAura,
            TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Size = UDim2.new(0, 28, 0, 28), BackgroundTransparency = 0.92 }
        ):Play()

        local brandLbl = Instance.new("TextLabel")
        brandLbl.Size = UDim2.new(1, -48, 1, 0)
        brandLbl.Position = UDim2.new(0, 42, 0, 0)
        brandLbl.BackgroundTransparency = 1
        brandLbl.Text = BRAND_NAME
        brandLbl.TextColor3 = THEME.White
        brandLbl.TextSize = 14
        brandLbl.Font = FONT_BOLD
        brandLbl.TextXAlignment = Enum.TextXAlignment.Left
        brandLbl.ZIndex = 32
        brandLbl.Parent = pillBtn

        pillBtn.MouseEnter:Connect(function()
            TweenService:Create(pillStroke, TweenInfo.new(0.15), { Transparency = 0.35 }):Play()
        end)
        pillBtn.MouseLeave:Connect(function()
            TweenService:Create(pillStroke, TweenInfo.new(0.15), { Transparency = 0.72 }):Play()
        end)

        local function resetPillVisual()
            TweenService:Create(pillStroke, TweenInfo.new(0.15), { Color = THEME.White, Thickness = 1.15, Transparency = 0.72 }):Play()
        end

        attachHoldToDrag(pillBtn, toggleMainMenuAnimated, function(p)
            State.OrbPos = p
            autoSaveImmediate()
        end, resetPillVisual)
    else
        pillBtn.Visible = (not isMenuOpen)
    end

    if not farmHudFrame or not farmHudFrame.Parent then
        farmHudFrame = Instance.new("Frame")
        farmHudFrame.Name = "ReACKAutoFarmHUD"
        farmHudFrame.Size = UDim2.new(0, 208, 0, 114)
        farmHudFrame.Position = UDim2.new(State.HudPos[1], State.HudPos[2], State.HudPos[3], State.HudPos[4])
        farmHudFrame.BackgroundColor3 = THEME.WindowBg
        farmHudFrame.BackgroundTransparency = 0.04
        farmHudFrame.BorderSizePixel = 0
        farmHudFrame.Visible = State.AutoFarm
        farmHudFrame.ZIndex = 24
        farmHudFrame.Parent = screenGui

        addCorner(farmHudFrame, 10)
        addStroke(farmHudFrame, THEME.BorderLight, 1, 0.35)

        hudScaleObj = Instance.new("UIScale")
        hudScaleObj.Scale = math.clamp(computeAdaptiveScale(), 0.78, 1.15)
        hudScaleObj.Parent = farmHudFrame

        local hIconSlot = Instance.new("Frame")
        hIconSlot.Size = UDim2.new(0, 16, 0, 16)
        hIconSlot.Position = UDim2.new(0, 10, 0, 8)
        hIconSlot.BackgroundTransparency = 1
        hIconSlot.ZIndex = 26
        hIconSlot.Parent = farmHudFrame
        drawIcon(hIconSlot, "Farm", THEME.White)

        local hTitle = Instance.new("TextLabel")
        hTitle.Size = UDim2.new(1, -34, 0, 20)
        hTitle.Position = UDim2.new(0, 32, 0, 6)
        hTitle.BackgroundTransparency = 1
        hTitle.Text = "Auto Farm HUD"
        hTitle.TextColor3 = THEME.White
        hTitle.TextSize = 11
        hTitle.Font = FONT_BOLD
        hTitle.TextXAlignment = Enum.TextXAlignment.Left
        hTitle.ZIndex = 26
        hTitle.Parent = farmHudFrame

        local function makeHudLine(yPos, col, fontObj)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, -20, 0, 16)
            l.Position = UDim2.new(0, 10, 0, yPos)
            l.BackgroundTransparency = 1
            l.TextColor3 = col or THEME.TextDim
            l.TextSize = 10
            l.Font = fontObj or FONT_REG
            l.TextTruncate = Enum.TextTruncate.AtEnd
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.ZIndex = 25
            l.Parent = farmHudFrame
            return l
        end

        hudStatusLbl = makeHudLine(32, THEME.TextDim, FONT_REG)
        hudTargetLbl = makeHudLine(50, THEME.White, FONT_BOLD)
        hudStatsLbl  = makeHudLine(68, THEME.TextDim, FONT_REG)
        hudArenaLbl  = makeHudLine(86, THEME.TextMuted, FONT_REG)

        local dragHud, startH, origH = false, Vector3.zero, farmHudFrame.Position
        farmHudFrame.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragHud = true; startH = i.Position; origH = farmHudFrame.Position
            end
        end)
        table.insert(Connections, UserInputService.InputChanged:Connect(function(i)
            if dragHud and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - startH
                farmHudFrame.Position = UDim2.new(origH.X.Scale, origH.X.Offset + d.X, origH.Y.Scale, origH.Y.Offset + d.Y)
            end
        end))
        table.insert(Connections, UserInputService.InputEnded:Connect(function(i)
            if dragHud and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
                dragHud = false
                local p = farmHudFrame.Position
                State.HudPos = { p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset }
                autoSaveImmediate()
            end
        end))
    end

    local function makeFloatBtn(objName, labelKey, posArr, getSt, onTog, posKey)
        local b = Instance.new("TextButton")
        b.Name = objName
        b.AnchorPoint = Vector2.new(0.5, 0.5)
        b.Size = UDim2.new(0, 154, 0, 34)
        b.Position = UDim2.new(posArr[1], posArr[2], posArr[3], posArr[4])
        b.BackgroundColor3 = THEME.WindowBg
        b.BackgroundTransparency = 0.04
        b.BorderSizePixel = 0
        b.Text = ""
        b.AutoButtonColor = false
        b.Visible = false
        b.ZIndex = 25
        b.Parent = screenGui

        addCorner(b, 8)
        local s = addStroke(b, THEME.BorderLight, 1, 0.4)

        local pillBg = Instance.new("Frame")
        pillBg.AnchorPoint = Vector2.new(1, 0.5)
        pillBg.Position = UDim2.new(1, -10, 0.5, 0)
        pillBg.Size = UDim2.new(0, 32, 0, 18)
        pillBg.BackgroundColor3 = THEME.ToggleOff
        pillBg.BorderSizePixel = 0
        pillBg.ZIndex = 26
        pillBg.Parent = b
        addPillCorner(pillBg)

        local pillKnob = Instance.new("Frame")
        pillKnob.AnchorPoint = Vector2.new(0, 0.5)
        pillKnob.Position = UDim2.new(0, 2, 0.5, 0)
        pillKnob.Size = UDim2.new(0, 14, 0, 14)
        pillKnob.BackgroundColor3 = THEME.ThumbOff
        pillKnob.BorderSizePixel = 0
        pillKnob.ZIndex = 27
        pillKnob.Parent = pillBg
        addPillCorner(pillKnob)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -52, 1, 0)
        lbl.Position = UDim2.new(0, 11, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = THEME.TextDim
        lbl.TextSize = 11
        lbl.Font = FONT_MED
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 26
        lbl.Parent = b

        local function upd()
            local isOn = (getSt() == true)
            b.Text = ""
            lbl.Text = tr(labelKey)
            s.Thickness = 1
            TweenService:Create(lbl, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
                TextColor3 = isOn and THEME.White or THEME.TextDim
            }):Play()
            TweenService:Create(s, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
                Color = isOn and THEME.White or THEME.BorderLight,
                Transparency = isOn and 0.35 or 0.55
            }):Play()
            TweenService:Create(pillBg, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
                BackgroundColor3 = isOn and THEME.ToggleOn or THEME.ToggleOff
            }):Play()
            TweenService:Create(pillKnob, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
                Position = isOn and UDim2.new(0, 16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = isOn and THEME.ThumbOn or THEME.ThumbOff
            }):Play()
        end

        attachHoldToDrag(b, function()
            onTog()
            syncAllCombatVisuals()
            autoSaveImmediate()
        end, function(p)
            State[posKey] = p
            autoSaveImmediate()
        end, upd)

        upd()
        return b, upd
    end

    if not autoM1Float or not autoM1Float.Parent then
        autoM1Float, updAutoM1Float = makeFloatBtn("ReACKAutoM1Float", "en_AutoM1", State.AutoM1BtnPos, function() return State.AutoM1 end, function()
            State.AutoM1 = not State.AutoM1
        end, "AutoM1BtnPos")
        autoM1Float.Visible = State.ShowAutoM1FloatingBtn
    end

    if not killAuraFloat or not killAuraFloat.Parent then
        killAuraFloat, updKillAuraFloat = makeFloatBtn("ReACKKillAuraFloat", "en_KA", State.KillAuraBtnPos, function() return State.KillAura end, function()
            State.KillAura = not State.KillAura
        end, "KillAuraBtnPos")
        killAuraFloat.Visible = State.ShowKillAuraFloatingBtn
    end

    if not autoFarmFloat or not autoFarmFloat.Parent then
        autoFarmFloat, updAutoFarmFloat = makeFloatBtn("ReACKAutoFarmFloat", "en_Farm", State.AutoFarmBtnPos, function() return State.AutoFarm end, function()
            setAutoFarmEnabled(not State.AutoFarm)
        end, "AutoFarmBtnPos")
        autoFarmFloat.Visible = State.ShowAutoFarmFloatingBtn
    end
end

buildMainUI = function(animateEntrance)
    startBackgroundLoops()
    ensureFloatingControls()

    if State.InfinitePunch then applyInfinitePunch() end
    if State.InfiniteDash then applyInfiniteDash() end

    local savedPos = mainFrame and mainFrame.Position or UDim2.new(0.5, 0, 0.5, 0)
    if mainFrame then mainFrame:Destroy() end

    local targetScale = computeAdaptiveScale()
    currentAdaptiveScale = targetScale

    mainFrame = Instance.new("Frame")
    mainFrame.Name = "ReACKMainFrame"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Size = UDim2.new(0, windowSize.X, 0, windowSize.Y)
    mainFrame.Position = savedPos
    mainFrame.BackgroundColor3 = THEME.WindowBg
    mainFrame.BackgroundTransparency = 0.02
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Visible = isMenuOpen
    mainFrame.ZIndex = 2
    mainFrame.Parent = screenGui

    addCorner(mainFrame, 10)
    addStroke(mainFrame, THEME.Border, 1, 0.25)

    mainScaleObj = Instance.new("UIScale")
    mainScaleObj.Scale = (animateEntrance and isMenuOpen) and (targetScale * 0.88) or targetScale
    mainScaleObj.Parent = mainFrame

    if animateEntrance and isMenuOpen then
        TweenService:Create(mainScaleObj, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = targetScale
        }):Play()
    end

    local TOP_H = 44
    local SIDEBAR_W = 136

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, TOP_H)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundTransparency = 1
    topBar.BorderSizePixel = 0
    topBar.ZIndex = 6
    topBar.Parent = mainFrame

    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(1, 0, 0, 1)
    topLine.Position = UDim2.new(0, 0, 1, -1)
    topLine.BackgroundColor3 = THEME.Border
    topLine.BackgroundTransparency = 0.45
    topLine.BorderSizePixel = 0
    topLine.ZIndex = 6
    topLine.Parent = topBar

    local leftHeaderGroup = Instance.new("Frame")
    leftHeaderGroup.Size = UDim2.new(1, -88, 1, 0)
    leftHeaderGroup.Position = UDim2.new(0, 14, 0, 0)
    leftHeaderGroup.BackgroundTransparency = 1
    leftHeaderGroup.ZIndex = 7
    leftHeaderGroup.Parent = topBar

    local leftHLayout = Instance.new("UIListLayout")
    leftHLayout.FillDirection = Enum.FillDirection.Horizontal
    leftHLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    leftHLayout.Padding = UDim.new(0, 10)
    leftHLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftHLayout.Parent = leftHeaderGroup

    local logoSlot = Instance.new("Frame")
    logoSlot.Size = UDim2.new(0, 22, 0, 22)
    logoSlot.BackgroundTransparency = 1
    logoSlot.LayoutOrder = 1
    logoSlot.ZIndex = 8
    logoSlot.Parent = leftHeaderGroup
    createReackLogo(logoSlot, 0, 0, 22)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0, 0, 1, 0)
    titleLbl.AutomaticSize = Enum.AutomaticSize.X
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = BRAND_NAME .. " | " .. cachedPlaceName
    titleLbl.TextColor3 = THEME.White
    titleLbl.TextSize = 13
    titleLbl.Font = FONT_MED
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    titleLbl.LayoutOrder = 2
    titleLbl.ZIndex = 8
    titleLbl.Parent = leftHeaderGroup

    task.spawn(function()
        for _ = 1, 12 do
            if not titleLbl or not titleLbl.Parent then break end
            local expected = BRAND_NAME .. " | " .. cachedPlaceName
            if titleLbl.Text ~= expected then
                titleLbl.Text = expected
                break
            end
            task.wait(0.5)
        end
    end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseScriptBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, -9, 0.5, 0)
    closeBtn.BackgroundColor3 = THEME.Danger
    closeBtn.BackgroundTransparency = 1
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = ""
    closeBtn.Active = true
    closeBtn.Selectable = true
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 20
    closeBtn.Parent = topBar
    addCorner(closeBtn, 6)

    local closeIconSlot = Instance.new("Frame")
    closeIconSlot.Size = UDim2.new(0, 16, 0, 16)
    closeIconSlot.AnchorPoint = Vector2.new(0.5, 0.5)
    closeIconSlot.Position = UDim2.fromScale(0.5, 0.5)
    closeIconSlot.BackgroundTransparency = 1
    closeIconSlot.ZIndex = 21
    closeIconSlot.Parent = closeBtn
    local setCloseColor = drawIcon(closeIconSlot, "Close", THEME.TextDim)

    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.14), { BackgroundTransparency = 0.15 }):Play()
        setCloseColor(THEME.White)
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
        setCloseColor(THEME.TextDim)
    end)
    bindReliableClick(closeBtn, function()
        showCloseConfirmPopup()
    end)

    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeScriptBtn"
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.AnchorPoint = Vector2.new(1, 0.5)
    minBtn.Position = UDim2.new(1, -43, 0.5, 0)
    minBtn.BackgroundColor3 = THEME.RowHover
    minBtn.BackgroundTransparency = 1
    minBtn.BorderSizePixel = 0
    minBtn.Text = ""
    minBtn.Active = true
    minBtn.Selectable = true
    minBtn.AutoButtonColor = false
    minBtn.ZIndex = 20
    minBtn.Parent = topBar
    addCorner(minBtn, 6)

    local minIconSlot = Instance.new("Frame")
    minIconSlot.Size = UDim2.new(0, 16, 0, 16)
    minIconSlot.AnchorPoint = Vector2.new(0.5, 0.5)
    minIconSlot.Position = UDim2.fromScale(0.5, 0.5)
    minIconSlot.BackgroundTransparency = 1
    minIconSlot.ZIndex = 21
    minIconSlot.Parent = minBtn
    local setMinColor = drawIcon(minIconSlot, "Minimize", THEME.TextDim)

    minBtn.MouseEnter:Connect(function()
        TweenService:Create(minBtn, TweenInfo.new(0.14), { BackgroundTransparency = 0 }):Play()
        setMinColor(THEME.White)
    end)
    minBtn.MouseLeave:Connect(function()
        TweenService:Create(minBtn, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
        setMinColor(THEME.TextDim)
    end)
    bindReliableClick(minBtn, toggleMainMenuAnimated)

    local sidebar = Instance.new("Frame")
    sidebar.Name = "LeftSidebar"
    sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -TOP_H)
    sidebar.Position = UDim2.new(0, 0, 0, TOP_H)
    sidebar.BackgroundColor3 = THEME.SidebarBg
    sidebar.BackgroundTransparency = 0.25
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 6
    sidebar.Parent = mainFrame

    local sideDivider = Instance.new("Frame")
    sideDivider.Size = UDim2.new(0, 1, 1, 0)
    sideDivider.Position = UDim2.new(1, -1, 0, 0)
    sideDivider.BackgroundColor3 = THEME.Border
    sideDivider.BackgroundTransparency = 0.45
    sideDivider.BorderSizePixel = 0
    sideDivider.ZIndex = 7
    sideDivider.Parent = sidebar

    local BTN_W = SIDEBAR_W - 22
    local BTN_H = 38
    local BTN_GAP = 8
    local TOP_PAD = 12

    local activeBarIndicator = Instance.new("Frame")
    activeBarIndicator.Size = UDim2.new(0, 3, 0, 20)
    activeBarIndicator.Position = UDim2.new(0, 5, 0, TOP_PAD + 9)
    activeBarIndicator.BackgroundColor3 = THEME.White
    activeBarIndicator.BorderSizePixel = 0
    activeBarIndicator.ZIndex = 10
    activeBarIndicator.Parent = sidebar
    addPillCorner(activeBarIndicator)

    local activeBoxBg = Instance.new("Frame")
    activeBoxBg.Size = UDim2.new(0, BTN_W, 0, BTN_H)
    activeBoxBg.Position = UDim2.new(0, 12, 0, TOP_PAD)
    activeBoxBg.BackgroundColor3 = THEME.ControlBg
    activeBoxBg.BorderSizePixel = 0
    activeBoxBg.ZIndex = 7
    activeBoxBg.Parent = sidebar
    addCorner(activeBoxBg, 8)
    addStroke(activeBoxBg, THEME.BorderLight, 1, 0.35)

    local pagesHolder = Instance.new("Frame")
    pagesHolder.Size = UDim2.new(1, -SIDEBAR_W, 1, -TOP_H)
    pagesHolder.Position = UDim2.new(0, SIDEBAR_W, 0, TOP_H)
    pagesHolder.BackgroundTransparency = 1
    pagesHolder.ClipsDescendants = true
    pagesHolder.ZIndex = 4
    pagesHolder.Parent = mainFrame

    local tabBtns, tabPages, tabIndexMap, tabCount = {}, {}, {}, 0

    local function selectTab(key, instant)
        activeTabKey = key

        local idx = tabIndexMap[key] or 1
        local targetY = TOP_PAD + (idx - 1) * (BTN_H + BTN_GAP)
        if instant then
            activeBoxBg.Position = UDim2.new(0, 12, 0, targetY)
            activeBarIndicator.Position = UDim2.new(0, 5, 0, targetY + 9)
        else
            TweenService:Create(activeBoxBg, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 12, 0, targetY)
            }):Play()
            TweenService:Create(activeBarIndicator, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 5, 0, targetY + 9)
            }):Play()
        end

        for k, v in pairs(tabBtns) do
            local sel = (k == key)
            v.SetIcon(sel and THEME.White or THEME.TextDim)
            TweenService:Create(v.Label, TweenInfo.new(0.16), {
                TextColor3 = sel and THEME.White or THEME.TextDim
            }):Play()
            v.Label.Font = sel and FONT_BOLD or FONT_MED
        end

        for k, p in pairs(tabPages) do
            if k == key then
                p.Visible = true
                if not instant then
                    p.Position = UDim2.new(0, 0, 0, 6)
                    TweenService:Create(p, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 0, 0, 0)
                    }):Play()
                else
                    p.Position = UDim2.new(0, 0, 0, 0)
                end
            else
                p.Visible = false
            end
        end
    end

    local function createTab(key)
        tabCount = tabCount + 1
        tabIndexMap[key] = tabCount

        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, BTN_W, 0, BTN_H)
        b.Position = UDim2.new(0, 12, 0, TOP_PAD + (tabCount - 1) * (BTN_H + BTN_GAP))
        b.BackgroundColor3 = THEME.RowHover
        b.BackgroundTransparency = 1
        b.BorderSizePixel = 0
        b.Text = ""
        b.AutoButtonColor = false
        b.ZIndex = 8
        b.Parent = sidebar
        addCorner(b, 8)

        local icSlot = Instance.new("Frame")
        icSlot.Size = UDim2.new(0, 20, 0, 20)
        icSlot.AnchorPoint = Vector2.new(0, 0.5)
        icSlot.Position = UDim2.new(0, 10, 0.5, 0)
        icSlot.BackgroundTransparency = 1
        icSlot.ZIndex = 9
        icSlot.Parent = b
        local setIcon = drawIcon(icSlot, key, THEME.TextDim)

        local tLbl = Instance.new("TextLabel")
        tLbl.Size = UDim2.new(1, -40, 1, 0)
        tLbl.Position = UDim2.new(0, 36, 0, 0)
        tLbl.BackgroundTransparency = 1
        tLbl.Text = tr("tab_" .. key)
        tLbl.TextColor3 = THEME.TextDim
        tLbl.TextSize = 12
        tLbl.Font = FONT_MED
        tLbl.TextTruncate = Enum.TextTruncate.AtEnd
        tLbl.TextXAlignment = Enum.TextXAlignment.Left
        tLbl.ZIndex = 9
        tLbl.Parent = b

        b.MouseEnter:Connect(function()
            if activeTabKey ~= key then
                TweenService:Create(b, TweenInfo.new(0.14), { BackgroundTransparency = 0.45 }):Play()
                setIcon(THEME.White)
                TweenService:Create(tLbl, TweenInfo.new(0.14), { TextColor3 = THEME.White }):Play()
            end
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
            if activeTabKey ~= key then
                setIcon(THEME.TextDim)
                TweenService:Create(tLbl, TweenInfo.new(0.14), { TextColor3 = THEME.TextDim }):Play()
            end
        end)

        local pg = Instance.new("ScrollingFrame")
        pg.Size = UDim2.fromScale(1, 1)
        pg.BackgroundTransparency = 1
        pg.BorderSizePixel = 0
        pg.ScrollingDirection = Enum.ScrollingDirection.Y
        pg.ScrollBarThickness = 3
        pg.ScrollBarImageColor3 = THEME.ScrollBar
        pg.ScrollBarImageTransparency = 0.25
        pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
        pg.CanvasSize = UDim2.new(0, 0, 0, 0)
        pg.Visible = false
        pg.ZIndex = 5
        pg.Parent = pagesHolder

        local contentCol = Instance.new("Frame")
        contentCol.Size = UDim2.new(1, 0, 0, 0)
        contentCol.AutomaticSize = Enum.AutomaticSize.Y
        contentCol.BackgroundTransparency = 1
        contentCol.ZIndex = 5
        contentCol.Parent = pg

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 12)
        pad.PaddingBottom = UDim.new(0, 20)
        pad.PaddingLeft = UDim.new(0, 16)
        pad.PaddingRight = UDim.new(0, 18)
        pad.Parent = contentCol

        local colLayout = Instance.new("UIListLayout")
        colLayout.Padding = UDim.new(0, 5)
        colLayout.SortOrder = Enum.SortOrder.LayoutOrder
        colLayout.Parent = contentCol

        local pageHeader = Instance.new("TextLabel")
        pageHeader.Size = UDim2.new(1, 0, 0, 34)
        pageHeader.BackgroundTransparency = 1
        pageHeader.Text = tr("tab_" .. key)
        pageHeader.TextColor3 = THEME.White
        pageHeader.TextSize = 19
        pageHeader.Font = FONT_BOLD
        pageHeader.TextXAlignment = Enum.TextXAlignment.Left
        pageHeader.LayoutOrder = 0
        pageHeader.ZIndex = 6
        pageHeader.Parent = contentCol

        tabBtns[key] = { Btn = b, SetIcon = setIcon, Label = tLbl }
        tabPages[key] = pg
        b.Activated:Connect(function() selectTab(key, false) end)
        return pg, contentCol
    end

    local orderCounter = 0
    local function nextOrder()
        orderCounter = orderCounter + 1
        return orderCounter
    end

    local function addSectionHeader(parentCol, titleKey)
        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, 0, 0, 26)
        wrap.BackgroundTransparency = 1
        wrap.LayoutOrder = nextOrder()
        wrap.ZIndex = 6
        wrap.Parent = parentCol

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.Position = UDim2.new(0, 0, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = tr(titleKey)
        lbl.TextColor3 = THEME.TextSubHdr
        lbl.TextSize = 11
        lbl.Font = FONT_BOLD
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 7
        lbl.Parent = wrap
    end

    local function addPillToggle(parentCol, titleKey, def, cb)
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 52)
        row.BackgroundColor3 = THEME.RowHover
        row.BackgroundTransparency = 1
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false
        row.LayoutOrder = nextOrder()
        row.ZIndex = 6
        row.Parent = parentCol
        addCorner(row, 8)

        row.MouseEnter:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.14), { BackgroundTransparency = 0.45 }):Play()
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
        end)

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -56, 0, 18)
        titleLbl.Position = UDim2.new(0, 4, 0, 7)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = tr(titleKey)
        titleLbl.TextColor3 = THEME.White
        titleLbl.TextSize = 13
        titleLbl.Font = FONT_MED
        titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex = 7
        titleLbl.Parent = row

        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -56, 0, 16)
        descLbl.Position = UDim2.new(0, 4, 0, 27)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = tr(titleKey .. "_desc")
        descLbl.TextColor3 = THEME.TextDim
        descLbl.TextSize = 11
        descLbl.Font = FONT_REG
        descLbl.TextTruncate = Enum.TextTruncate.AtEnd
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 7
        descLbl.Parent = row

        local switchTrack = Instance.new("Frame")
        switchTrack.AnchorPoint = Vector2.new(1, 0.5)
        switchTrack.Position = UDim2.new(1, -4, 0.5, 0)
        switchTrack.Size = UDim2.new(0, 40, 0, 22)
        switchTrack.BackgroundColor3 = def and THEME.ToggleOn or THEME.ToggleOff
        switchTrack.BorderSizePixel = 0
        switchTrack.ZIndex = 7
        switchTrack.Parent = row
        addPillCorner(switchTrack)

        local thumb = Instance.new("Frame")
        thumb.AnchorPoint = Vector2.new(0, 0.5)
        thumb.Position = def and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        thumb.Size = UDim2.new(0, 16, 0, 16)
        thumb.BackgroundColor3 = def and THEME.ThumbOn or THEME.ThumbOff
        thumb.BorderSizePixel = 0
        thumb.ZIndex = 8
        thumb.Parent = switchTrack
        addPillCorner(thumb)

        local st = def
        local function setSt(v, silent)
            st = (v == true)
            TweenService:Create(switchTrack, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                BackgroundColor3 = st and THEME.ToggleOn or THEME.ToggleOff
            }):Play()
            TweenService:Create(thumb, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = st and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                BackgroundColor3 = st and THEME.ThumbOn or THEME.ThumbOff
            }):Play()
            if not silent then cb(st) end
        end

        row.Activated:Connect(function() setSt(not st, false) end)
        return setSt
    end

    local function addMonoSlider(parentCol, pg, titleKey, minV, maxV, defV, step, suf, cb)
        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, 0, 0, 60)
        wrap.BackgroundTransparency = 1
        wrap.LayoutOrder = nextOrder()
        wrap.ZIndex = 6
        wrap.Parent = parentCol

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -78, 0, 18)
        titleLbl.Position = UDim2.new(0, 4, 0, 5)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = tr(titleKey)
        titleLbl.TextColor3 = THEME.White
        titleLbl.TextSize = 13
        titleLbl.Font = FONT_MED
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex = 7
        titleLbl.Parent = wrap

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0, 72, 0, 18)
        valLbl.AnchorPoint = Vector2.new(1, 0)
        valLbl.Position = UDim2.new(1, -4, 0, 5)
        valLbl.BackgroundTransparency = 1
        valLbl.TextColor3 = THEME.White
        valLbl.TextSize = 11
        valLbl.Font = FONT_BOLD
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.ZIndex = 7
        valLbl.Parent = wrap

        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -8, 0, 15)
        descLbl.Position = UDim2.new(0, 4, 0, 24)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = tr(titleKey .. "_desc")
        descLbl.TextColor3 = THEME.TextDim
        descLbl.TextSize = 10
        descLbl.Font = FONT_REG
        descLbl.TextTruncate = Enum.TextTruncate.AtEnd
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 7
        descLbl.Parent = wrap

        local hitBtn = Instance.new("TextButton")
        hitBtn.Size = UDim2.new(1, -8, 0, 16)
        hitBtn.Position = UDim2.new(0, 4, 0, 41)
        hitBtn.BackgroundTransparency = 1
        hitBtn.Text = ""
        hitBtn.AutoButtonColor = false
        hitBtn.ZIndex = 9
        hitBtn.Parent = wrap

        local track = Instance.new("Frame")
        track.AnchorPoint = Vector2.new(0, 0.5)
        track.Position = UDim2.new(0, 0, 0.5, 0)
        track.Size = UDim2.new(1, 0, 0, 4)
        track.BackgroundColor3 = THEME.TrackBg
        track.BorderSizePixel = 0
        track.ZIndex = 7
        track.Parent = hitBtn
        addPillCorner(track)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = THEME.White
        fill.BorderSizePixel = 0
        fill.ZIndex = 8
        fill.Parent = track
        addPillCorner(fill)

        local knob = Instance.new("Frame")
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.BackgroundColor3 = THEME.White
        knob.BorderSizePixel = 0
        knob.ZIndex = 9
        knob.Parent = track
        addPillCorner(knob)

        local function formatVal(v)
            local suffixStr = (suf ~= "" and (" " .. suf) or "")
            return (step < 1) and string.format("%.2f%s", v, suffixStr) or string.format("%d%s", math.floor(v + 0.5), suffixStr)
        end

        local function setV(raw, fire)
            local c = math.clamp(raw, minV, maxV)
            local s = math.clamp(math.floor((c - minV) / step + 0.5) * step + minV, minV, maxV)
            local ratio = (s - minV) / (maxV - minV)
            TweenService:Create(fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(ratio, 0, 1, 0)
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(ratio, 0, 0.5, 0)
            }):Play()
            valLbl.Text = formatVal(s)
            if fire then cb(s) end
        end
        setV(defV, false)

        local sl = false
        local function upd(inp)
            if track.AbsoluteSize.X > 0 then
                setV(minV + (maxV - minV) * math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1), true)
            end
        end
        hitBtn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                sl = true; pg.ScrollingEnabled = false
                TweenService:Create(knob, TweenInfo.new(0.12), { Size = UDim2.new(0, 15, 0, 15) }):Play()
                upd(i)
            end
        end)
        table.insert(Connections, UserInputService.InputChanged:Connect(function(i)
            if sl and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                upd(i)
            end
        end))
        table.insert(Connections, UserInputService.InputEnded:Connect(function(i)
            if sl and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
                sl = false; pg.ScrollingEnabled = true
                TweenService:Create(knob, TweenInfo.new(0.14), { Size = UDim2.new(0, 12, 0, 12) }):Play()
            end
        end))

        return setV
    end

    local function addMonoDropdown(parentCol, titleKey, options, currentVal, onSelect)
        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, 0, 0, 0)
        wrap.AutomaticSize = Enum.AutomaticSize.Y
        wrap.BackgroundTransparency = 1
        wrap.LayoutOrder = nextOrder()
        wrap.ZIndex = 7
        wrap.Parent = parentCol

        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, 0, 0, 52)
        topRow.BackgroundTransparency = 1
        topRow.ZIndex = 7
        topRow.Parent = wrap

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -168, 0, 18)
        titleLbl.Position = UDim2.new(0, 4, 0, 7)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = tr(titleKey)
        titleLbl.TextColor3 = THEME.White
        titleLbl.TextSize = 13
        titleLbl.Font = FONT_MED
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex = 8
        titleLbl.Parent = topRow

        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -168, 0, 16)
        descLbl.Position = UDim2.new(0, 4, 0, 27)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = tr(titleKey .. "_desc")
        descLbl.TextColor3 = THEME.TextDim
        descLbl.TextSize = 11
        descLbl.Font = FONT_REG
        descLbl.TextTruncate = Enum.TextTruncate.AtEnd
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 8
        descLbl.Parent = topRow

        local boxBtn = Instance.new("TextButton")
        boxBtn.Size = UDim2.new(0, 150, 0, 32)
        boxBtn.AnchorPoint = Vector2.new(1, 0.5)
        boxBtn.Position = UDim2.new(1, -4, 0.5, 0)
        boxBtn.BackgroundColor3 = THEME.ControlBg
        boxBtn.BorderSizePixel = 0
        boxBtn.Text = ""
        boxBtn.AutoButtonColor = false
        boxBtn.ZIndex = 8
        boxBtn.Parent = topRow
        addCorner(boxBtn, 6)
        addStroke(boxBtn, THEME.BorderLight, 1, 0.35)
        attachButtonAnim(boxBtn, THEME.ControlBg, THEME.ControlHover)

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(1, -28, 1, 0)
        valLbl.Position = UDim2.new(0, 12, 0, 0)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = currentVal
        valLbl.TextColor3 = THEME.White
        valLbl.TextSize = 11
        valLbl.Font = FONT_MED
        valLbl.TextXAlignment = Enum.TextXAlignment.Left
        valLbl.ZIndex = 9
        valLbl.Parent = boxBtn

        local setDiamond = createDropdownDiamond(boxBtn, -10)

        local listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(0, 150, 0, 0)
        listFrame.AnchorPoint = Vector2.new(1, 0)
        listFrame.Position = UDim2.new(1, -4, 0, 44)
        listFrame.AutomaticSize = Enum.AutomaticSize.Y
        listFrame.BackgroundColor3 = THEME.ControlBg
        listFrame.BorderSizePixel = 0
        listFrame.Visible = false
        listFrame.ZIndex = 12
        listFrame.Parent = wrap
        addCorner(listFrame, 6)
        addStroke(listFrame, THEME.BorderLight, 1, 0.3)

        local lp = Instance.new("UIPadding"); lp.PaddingTop = UDim.new(0, 4); lp.PaddingBottom = UDim.new(0, 4); lp.PaddingLeft = UDim.new(0, 4); lp.PaddingRight = UDim.new(0, 4); lp.Parent = listFrame
        local ll = Instance.new("UIListLayout"); ll.Padding = UDim.new(0, 2); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.Parent = listFrame

        local open = false
        for idx, opt in ipairs(options) do
            local ob = Instance.new("TextButton")
            ob.Size = UDim2.new(1, 0, 0, 26)
            ob.BackgroundColor3 = THEME.White
            ob.BackgroundTransparency = (opt == currentVal) and 0.88 or 1
            ob.BorderSizePixel = 0
            ob.Text = "  " .. opt
            ob.TextColor3 = (opt == currentVal) and THEME.White or THEME.TextDim
            ob.TextSize = 11
            ob.Font = (opt == currentVal) and FONT_BOLD or FONT_MED
            ob.TextXAlignment = Enum.TextXAlignment.Left
            ob.AutoButtonColor = false
            ob.LayoutOrder = idx
            ob.ZIndex = 13
            ob.Parent = listFrame
            addCorner(ob, 5)

            ob.Activated:Connect(function()
                valLbl.Text = opt
                open = false
                listFrame.Visible = false
                setDiamond(false)
                for _, ch in ipairs(listFrame:GetChildren()) do
                    if ch:IsA("TextButton") then
                        local active = (ch.Text == "  " .. opt)
                        TweenService:Create(ch, TweenInfo.new(0.14), {
                            BackgroundTransparency = active and 0.88 or 1,
                            TextColor3 = active and THEME.White or THEME.TextDim
                        }):Play()
                        ch.Font = active and FONT_BOLD or FONT_MED
                    end
                end
                onSelect(opt)
            end)
        end

        boxBtn.Activated:Connect(function()
            open = not open
            listFrame.Visible = open
            setDiamond(open)
        end)
    end

    local function addMonoAction(parentCol, titleKey, btnTextKey, cb)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 52)
        row.BackgroundTransparency = 1
        row.LayoutOrder = nextOrder()
        row.ZIndex = 6
        row.Parent = parentCol

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -124, 0, 18)
        titleLbl.Position = UDim2.new(0, 4, 0, 7)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = tr(titleKey)
        titleLbl.TextColor3 = THEME.White
        titleLbl.TextSize = 13
        titleLbl.Font = FONT_MED
        titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex = 7
        titleLbl.Parent = row

        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -124, 0, 16)
        descLbl.Position = UDim2.new(0, 4, 0, 27)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = tr(titleKey .. "_desc")
        descLbl.TextColor3 = THEME.TextDim
        descLbl.TextSize = 11
        descLbl.Font = FONT_REG
        descLbl.TextTruncate = Enum.TextTruncate.AtEnd
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 7
        descLbl.Parent = row

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 108, 0, 30)
        btn.AnchorPoint = Vector2.new(1, 0.5)
        btn.Position = UDim2.new(1, -4, 0.5, 0)
        btn.BackgroundColor3 = THEME.ControlBg
        btn.BorderSizePixel = 0
        btn.Text = tr(btnTextKey)
        btn.TextColor3 = THEME.White
        btn.TextSize = 11
        btn.Font = FONT_MED
        btn.AutoButtonColor = false
        btn.ZIndex = 7
        btn.Parent = row
        addCorner(btn, 6)
        local bs = addStroke(btn, THEME.BorderLight, 1, 0.35)
        attachButtonAnim(btn, THEME.ControlBg, THEME.ControlHover)

        btn.Activated:Connect(function()
            TweenService:Create(bs, TweenInfo.new(0.10), { Color = THEME.White, Transparency = 0.1 }):Play()
            task.delay(0.16, function()
                if bs and bs.Parent then
                    TweenService:Create(bs, TweenInfo.new(0.16), { Color = THEME.BorderLight, Transparency = 0.35 }):Play()
                end
            end)
            cb(btn)
        end)
        return btn
    end

    local cPg, cCol = createTab("Combat")
    local fPg, fCol = createTab("Farm")
    local pPg, pCol = createTab("Player")
    local _, sCol = createTab("Settings")

    do
        addSectionHeader(cCol, "sec_AutoM1")
        syncAutoM1UI = addPillToggle(cCol, "en_AutoM1", State.AutoM1, function(v)
            State.AutoM1 = v
            syncAllCombatVisuals()
            autoSaveImmediate()
        end)
        addPillToggle(cCol, "wall_Chk", State.AutoM1WallCheck, function(v) State.AutoM1WallCheck = v; autoSaveImmediate() end)
        addMonoSlider(cCol, cPg, "atk_Delay", 0.05, 1.00, State.M1Interval, 0.01, "s", function(v) State.M1Interval = v; autoSaveDebounced() end)
        addMonoSlider(cCol, cPg, "dist", 5, 40, State.AutoM1Range, 1, "", function(v) State.AutoM1Range = v; autoSaveDebounced() end)
        addMonoSlider(cCol, cPg, "fov", 30, 180, State.AutoM1FOV, 5, "°", function(v) State.AutoM1FOV = v; autoSaveDebounced() end)

        addSectionHeader(cCol, "sec_KillAura")
        syncKillAuraUI = addPillToggle(cCol, "en_KA", State.KillAura, function(v)
            State.KillAura = v
            syncAllCombatVisuals()
            autoSaveImmediate()
        end)
        addPillToggle(cCol, "auto_Face", State.KillAuraAutoFace, function(v) State.KillAuraAutoFace = v; autoSaveImmediate() end)
        addMonoSlider(cCol, cPg, "ka_Delay", 0.05, 1.00, State.KillAuraInterval, 0.01, "s", function(v) State.KillAuraInterval = v; autoSaveDebounced() end)
        addMonoSlider(cCol, cPg, "ka_Range", 5, 50, State.KillAuraRange, 1, "", function(v) State.KillAuraRange = v; autoSaveDebounced() end)

        addSectionHeader(cCol, "sec_InfPunch")
        addPillToggle(cCol, "en_Inf", State.InfinitePunch, function(v)
            State.InfinitePunch = v
            if v then applyInfinitePunch() else restoreCooldowns() end
            autoSaveImmediate()
        end)
        addMonoSlider(cCol, cPg, "punch_Cd", 0.00, 0.30, State.PunchCooldown, 0.01, "s", function(v)
            State.PunchCooldown = v
            if State.InfinitePunch then applyInfinitePunch() end
            autoSaveDebounced()
        end)
    end

    do
        addSectionHeader(fCol, "sec_FarmMain")
        syncAutoFarmUI = addPillToggle(fCol, "en_Farm", State.AutoFarm, function(v)
            setAutoFarmEnabled(v)
            syncAllCombatVisuals()
            autoSaveImmediate()
        end)

        local setSkillsToggle, setSearchSlider, setBehindSlider, setSpeedSlider
        addMonoDropdown(fCol, "farm_Mode", FARM_MODES, State.FarmMode, function(selectedMode)
            State.FarmMode = selectedMode
            local preset = FARM_PRESETS[selectedMode]
            if preset then
                State.FarmSearchRange = preset.SearchRange
                State.FarmBehindDist = preset.BehindDist
                State.FarmMoveSpeed = preset.MoveSpeed
                State.FarmUseSkills = preset.UseSkills

                if setSkillsToggle then setSkillsToggle(preset.UseSkills, true) end
                if setSearchSlider then setSearchSlider(preset.SearchRange, false) end
                if setBehindSlider then setBehindSlider(preset.BehindDist, false) end
                if setSpeedSlider then setSpeedSlider(preset.MoveSpeed, false) end
            end
            autoSaveImmediate()
        end)
        setBehindSlider = addMonoSlider(fCol, fPg, "farm_Behind", 2.0, 8.0, State.FarmBehindDist, 0.2, "", function(v) State.FarmBehindDist = v; autoSaveDebounced() end)
        setSearchSlider = addMonoSlider(fCol, fPg, "farm_Search", 30, 500, State.FarmSearchRange, 10, "", function(v) State.FarmSearchRange = v; autoSaveDebounced() end)

        addSectionHeader(fCol, "sec_FarmOpt")
        addPillToggle(fCol, "farm_LowHP", State.FarmTargetLowHP, function(v) State.FarmTargetLowHP = v; autoSaveImmediate() end)
        setSkillsToggle = addPillToggle(fCol, "farm_Skills", State.FarmUseSkills, function(v) State.FarmUseSkills = v; autoSaveImmediate() end)
        addPillToggle(fCol, "farm_Return", State.FarmAutoReturn, function(v) State.FarmAutoReturn = v; autoSaveImmediate() end)
        addPillToggle(fCol, "farm_AntiRagdoll", State.FarmAntiRagdoll, function(v) State.FarmAntiRagdoll = v; autoSaveImmediate() end)
        setSpeedSlider = addMonoSlider(fCol, fPg, "farm_Spd", 20, 150, State.FarmMoveSpeed, 5, "", function(v) State.FarmMoveSpeed = v; autoSaveDebounced() end)
    end

    do
        addSectionHeader(pCol, "sec_Movement")
        addPillToggle(pCol, "en_Speed", State.SpeedBoost, function(v)
            State.SpeedBoost = v
            if not v then
                local _, h = getCharacterParts(localPlayer)
                if h then h.WalkSpeed = State.DefaultWalkSpeed end
            end
            autoSaveImmediate()
        end)
        addMonoSlider(pCol, pPg, "walk_Spd", 16, 120, State.WalkSpeedValue, 1, "", function(v) State.WalkSpeedValue = v; autoSaveDebounced() end)
        addPillToggle(pCol, "en_InfDash", State.InfiniteDash, function(v)
            State.InfiniteDash = v
            if v then applyInfiniteDash() else restoreDashCooldowns() end
            autoSaveImmediate()
        end)

        addSectionHeader(pCol, "sec_EspTypes")
        addPillToggle(pCol, "en_Esp", State.EspEnabled, function(v) State.EspEnabled = v; autoSaveImmediate() end)
        addPillToggle(pCol, "esp_Box", State.EspBox, function(v) State.EspBox = v; autoSaveImmediate() end)
        addPillToggle(pCol, "esp_Skel", State.EspSkeleton, function(v) State.EspSkeleton = v; autoSaveImmediate() end)
        addPillToggle(pCol, "esp_Tracers", State.EspTracers, function(v) State.EspTracers = v; autoSaveImmediate() end)
        addPillToggle(pCol, "esp_Info", State.EspInfo, function(v) State.EspInfo = v; autoSaveImmediate() end)
        addPillToggle(pCol, "esp_Highlight", State.EspHighlight, function(v) State.EspHighlight = v; autoSaveImmediate() end)
        addPillToggle(pCol, "esp_TargetCol", State.EspTargetAccent, function(v) State.EspTargetAccent = v; autoSaveImmediate() end)

        addSectionHeader(pCol, "sec_EspColor")

        local presetRow = Instance.new("Frame")
        presetRow.Size = UDim2.new(1, 0, 0, 54)
        presetRow.BackgroundTransparency = 1
        presetRow.LayoutOrder = nextOrder()
        presetRow.ZIndex = 6
        presetRow.Parent = pCol

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -166, 0, 18)
        titleLbl.Position = UDim2.new(0, 4, 0, 7)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = tr("esp_Presets")
        titleLbl.TextColor3 = THEME.White
        titleLbl.TextSize = 13
        titleLbl.Font = FONT_MED
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex = 7
        titleLbl.Parent = presetRow

        local descLbl = Instance.new("TextLabel")
        descLbl.Size = UDim2.new(1, -166, 0, 16)
        descLbl.Position = UDim2.new(0, 4, 0, 27)
        descLbl.BackgroundTransparency = 1
        descLbl.Text = tr("esp_Presets_desc")
        descLbl.TextColor3 = THEME.TextDim
        descLbl.TextSize = 11
        descLbl.Font = FONT_REG
        descLbl.TextTruncate = Enum.TextTruncate.AtEnd
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.ZIndex = 7
        descLbl.Parent = presetRow

        local swatchGrid = Instance.new("Frame")
        swatchGrid.AnchorPoint = Vector2.new(1, 0.5)
        swatchGrid.Position = UDim2.new(1, -4, 0.5, 0)
        swatchGrid.Size = UDim2.new(0, 156, 0, 20)
        swatchGrid.BackgroundTransparency = 1
        swatchGrid.ZIndex = 7
        swatchGrid.Parent = presetRow

        local sgLayout = Instance.new("UIListLayout")
        sgLayout.FillDirection = Enum.FillDirection.Horizontal
        sgLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        sgLayout.Padding = UDim.new(0, 5)
        sgLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sgLayout.Parent = swatchGrid

        local setRSlider, setGSlider, setBSlider
        local PRESET_COLORS = {
            { 255, 255, 255 },
            { 255, 75, 95 },
            { 60, 210, 255 },
            { 80, 235, 140 },
            { 255, 205, 65 },
            { 165, 105, 255 },
        }

        for idx, rgb in ipairs(PRESET_COLORS) do
            local sw = Instance.new("TextButton")
            sw.Size = UDim2.new(0, 20, 0, 20)
            sw.BackgroundColor3 = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
            sw.BorderSizePixel = 0
            sw.Text = ""
            sw.AutoButtonColor = false
            sw.LayoutOrder = idx
            sw.ZIndex = 8
            sw.Parent = swatchGrid
            addCorner(sw, 5)
            addStroke(sw, THEME.BorderLight, 1, 0.35)

            sw.Activated:Connect(function()
                State.EspColorR = rgb[1]
                State.EspColorG = rgb[2]
                State.EspColorB = rgb[3]
                if setRSlider then setRSlider(rgb[1], false) end
                if setGSlider then setGSlider(rgb[2], false) end
                if setBSlider then setBSlider(rgb[3], false) end
                autoSaveImmediate()
            end)
        end

        setRSlider = addMonoSlider(pCol, pPg, "esp_R", 0, 255, State.EspColorR, 1, "", function(v)
            State.EspColorR = v; autoSaveDebounced()
        end)
        setGSlider = addMonoSlider(pCol, pPg, "esp_G", 0, 255, State.EspColorG, 1, "", function(v)
            State.EspColorG = v; autoSaveDebounced()
        end)
        setBSlider = addMonoSlider(pCol, pPg, "esp_B", 0, 255, State.EspColorB, 1, "", function(v)
            State.EspColorB = v; autoSaveDebounced()
        end)
    end

    do
        addSectionHeader(sCol, "sec_Account")

        local accCard = Instance.new("Frame")
        accCard.Size = UDim2.new(1, 0, 0, 62)
        accCard.BackgroundColor3 = THEME.ControlBg
        accCard.BorderSizePixel = 0
        accCard.LayoutOrder = nextOrder()
        accCard.ZIndex = 6
        accCard.Parent = sCol
        addCorner(accCard, 8)
        addStroke(accCard, THEME.BorderLight, 1, 0.35)

        local avatarHolder = Instance.new("Frame")
        avatarHolder.Size = UDim2.new(0, 42, 0, 42)
        avatarHolder.Position = UDim2.new(0, 12, 0.5, 0)
        avatarHolder.AnchorPoint = Vector2.new(0, 0.5)
        avatarHolder.BackgroundColor3 = THEME.WindowBg
        avatarHolder.BorderSizePixel = 0
        avatarHolder.ZIndex = 7
        avatarHolder.Parent = accCard
        addPillCorner(avatarHolder)
        addStroke(avatarHolder, THEME.BorderLight, 1.2, 0.2)

        local fallbackAvIcon = Instance.new("Frame")
        fallbackAvIcon.Size = UDim2.new(0, 22, 0, 22)
        fallbackAvIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        fallbackAvIcon.Position = UDim2.fromScale(0.5, 0.5)
        fallbackAvIcon.BackgroundTransparency = 1
        fallbackAvIcon.ZIndex = 8
        fallbackAvIcon.Parent = avatarHolder
        drawIcon(fallbackAvIcon, "Player", THEME.TextDim)

        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Size = UDim2.fromScale(1, 1)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Image = ""
        avatarImg.ScaleType = Enum.ScaleType.Crop
        avatarImg.ZIndex = 9
        avatarImg.Parent = avatarHolder
        addPillCorner(avatarImg)

        task.spawn(function()
            local okThumb, content, isReady = pcall(
                Players.GetUserThumbnailAsync,
                Players,
                localPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
            if okThumb and isReady and type(content) == "string" and content ~= "" and avatarImg and avatarImg.Parent then
                avatarImg.Image = content
                fallbackAvIcon.Visible = false
            end
        end)

        local onlineDot = Instance.new("Frame")
        onlineDot.Size = UDim2.new(0, 11, 0, 11)
        onlineDot.AnchorPoint = Vector2.new(1, 1)
        onlineDot.Position = UDim2.new(1, 1, 1, 1)
        onlineDot.BackgroundColor3 = THEME.OnlineDot
        onlineDot.BorderSizePixel = 0
        onlineDot.ZIndex = 10
        onlineDot.Parent = avatarHolder
        addPillCorner(onlineDot)
        addStroke(onlineDot, THEME.ControlBg, 2, 0)

        local accPipe = Instance.new("Frame")
        accPipe.Size = UDim2.new(0, 1, 0, 34)
        accPipe.Position = UDim2.new(0, 66, 0.5, 0)
        accPipe.AnchorPoint = Vector2.new(0, 0.5)
        accPipe.BackgroundColor3 = THEME.BorderLight
        accPipe.BackgroundTransparency = 0.25
        accPipe.BorderSizePixel = 0
        accPipe.ZIndex = 7
        accPipe.Parent = accCard

        local dispNameLbl = Instance.new("TextLabel")
        dispNameLbl.Size = UDim2.new(1, -90, 0, 20)
        dispNameLbl.Position = UDim2.new(0, 78, 0, 12)
        dispNameLbl.BackgroundTransparency = 1
        dispNameLbl.Text = localPlayer.DisplayName
        dispNameLbl.TextColor3 = THEME.White
        dispNameLbl.TextSize = 14
        dispNameLbl.Font = FONT_BOLD
        dispNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        dispNameLbl.TextXAlignment = Enum.TextXAlignment.Left
        dispNameLbl.ZIndex = 8
        dispNameLbl.Parent = accCard

        local userSubLbl = Instance.new("TextLabel")
        userSubLbl.Size = UDim2.new(1, -90, 0, 16)
        userSubLbl.Position = UDim2.new(0, 78, 0, 33)
        userSubLbl.BackgroundTransparency = 1
        userSubLbl.Text = "@" .. localPlayer.Name .. "  |  ID: " .. tostring(localPlayer.UserId)
        userSubLbl.TextColor3 = THEME.TextDim
        userSubLbl.TextSize = 11
        userSubLbl.Font = FONT_REG
        userSubLbl.TextTruncate = Enum.TextTruncate.AtEnd
        userSubLbl.TextXAlignment = Enum.TextXAlignment.Left
        userSubLbl.ZIndex = 8
        userSubLbl.Parent = accCard

        local tgBannerBtn = Instance.new("TextButton")
        tgBannerBtn.Size = UDim2.new(1, 0, 0, 48)
        tgBannerBtn.BackgroundColor3 = THEME.ControlBg
        tgBannerBtn.BorderSizePixel = 0
        tgBannerBtn.Text = ""
        tgBannerBtn.AutoButtonColor = false
        tgBannerBtn.LayoutOrder = nextOrder()
        tgBannerBtn.ZIndex = 6
        tgBannerBtn.Parent = sCol
        addCorner(tgBannerBtn, 8)
        local tgBannerStroke = addStroke(tgBannerBtn, THEME.BorderLight, 1, 0.35)
        attachButtonAnim(tgBannerBtn, THEME.ControlBg, THEME.ControlHover)

        local arrowWrap = Instance.new("Frame")
        arrowWrap.Size = UDim2.new(0, 22, 0, 22)
        arrowWrap.Position = UDim2.new(0, 10, 0.5, 0)
        arrowWrap.AnchorPoint = Vector2.new(0, 0.5)
        arrowWrap.BackgroundTransparency = 1
        arrowWrap.ZIndex = 8
        arrowWrap.Parent = tgBannerBtn

        local arrowMover = Instance.new("Frame")
        arrowMover.Size = UDim2.fromScale(1, 1)
        arrowMover.Position = UDim2.new(0, 0, 0, 0)
        arrowMover.BackgroundTransparency = 1
        arrowMover.ZIndex = 8
        arrowMover.Parent = arrowWrap

        local arrTop = Instance.new("Frame")
        arrTop.AnchorPoint = Vector2.new(0.5, 0.5)
        arrTop.Position = UDim2.new(0, 11, 0, 8)
        arrTop.Size = UDim2.new(0, 8, 0, 2)
        arrTop.Rotation = 42
        arrTop.BackgroundColor3 = THEME.White
        arrTop.BorderSizePixel = 0
        arrTop.ZIndex = 9
        arrTop.Parent = arrowMover
        addPillCorner(arrTop)

        local arrBot = Instance.new("Frame")
        arrBot.AnchorPoint = Vector2.new(0.5, 0.5)
        arrBot.Position = UDim2.new(0, 11, 0, 14)
        arrBot.Size = UDim2.new(0, 8, 0, 2)
        arrBot.Rotation = -42
        arrBot.BackgroundColor3 = THEME.White
        arrBot.BorderSizePixel = 0
        arrBot.ZIndex = 9
        arrBot.Parent = arrowMover
        addPillCorner(arrBot)

        local arrTrail = Instance.new("Frame")
        arrTrail.AnchorPoint = Vector2.new(0.5, 0.5)
        arrTrail.Position = UDim2.new(0, 5, 0, 11)
        arrTrail.Size = UDim2.new(0, 3, 0, 3)
        arrTrail.BackgroundColor3 = THEME.TextDim
        arrTrail.BorderSizePixel = 0
        arrTrail.ZIndex = 9
        arrTrail.Parent = arrowMover
        addPillCorner(arrTrail)

        TweenService:Create(
            arrowMover,
            TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Position = UDim2.new(0, 4, 0, 0) }
        ):Play()

        local tgLogoSlot = Instance.new("Frame")
        tgLogoSlot.Size = UDim2.new(0, 22, 0, 22)
        tgLogoSlot.Position = UDim2.new(0, 36, 0.5, 0)
        tgLogoSlot.AnchorPoint = Vector2.new(0, 0.5)
        tgLogoSlot.BackgroundTransparency = 1
        tgLogoSlot.ZIndex = 8
        tgLogoSlot.Parent = tgBannerBtn
        drawIcon(tgLogoSlot, "Telegram", THEME.White)

        local tgTitleLbl = Instance.new("TextLabel")
        tgTitleLbl.Size = UDim2.new(1, -156, 0, 18)
        tgTitleLbl.Position = UDim2.new(0, 66, 0, 7)
        tgTitleLbl.BackgroundTransparency = 1
        tgTitleLbl.Text = tr("tg_ChannelBtn")
        tgTitleLbl.TextColor3 = THEME.White
        tgTitleLbl.TextSize = 12
        tgTitleLbl.Font = FONT_BOLD
        tgTitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
        tgTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        tgTitleLbl.ZIndex = 8
        tgTitleLbl.Parent = tgBannerBtn

        local tgSubLbl = Instance.new("TextLabel")
        tgSubLbl.Size = UDim2.new(1, -156, 0, 14)
        tgSubLbl.Position = UDim2.new(0, 66, 0, 26)
        tgSubLbl.BackgroundTransparency = 1
        tgSubLbl.Text = tr("tg_ChannelSub")
        tgSubLbl.TextColor3 = THEME.TextDim
        tgSubLbl.TextSize = 10
        tgSubLbl.Font = FONT_REG
        tgSubLbl.TextTruncate = Enum.TextTruncate.AtEnd
        tgSubLbl.TextXAlignment = Enum.TextXAlignment.Left
        tgSubLbl.ZIndex = 8
        tgSubLbl.Parent = tgBannerBtn

        local tgPill = Instance.new("Frame")
        tgPill.Size = UDim2.new(0, 82, 0, 24)
        tgPill.AnchorPoint = Vector2.new(1, 0.5)
        tgPill.Position = UDim2.new(1, -10, 0.5, 0)
        tgPill.BackgroundColor3 = THEME.WindowBg
        tgPill.BorderSizePixel = 0
        tgPill.ZIndex = 8
        tgPill.Parent = tgBannerBtn
        addCorner(tgPill, 6)
        addStroke(tgPill, THEME.BorderLight, 1, 0.4)

        local tgPillLbl = Instance.new("TextLabel")
        tgPillLbl.Size = UDim2.fromScale(1, 1)
        tgPillLbl.BackgroundTransparency = 1
        tgPillLbl.Text = tr("tg_CopyAct")
        tgPillLbl.TextColor3 = THEME.White
        tgPillLbl.TextSize = 10
        tgPillLbl.Font = FONT_BOLD
        tgPillLbl.ZIndex = 9
        tgPillLbl.Parent = tgPill

        tgBannerBtn.Activated:Connect(function()
            copyToClipboard(TELEGRAM_INVITE)
            tgPill.BackgroundColor3 = THEME.White
            tgPillLbl.TextColor3 = THEME.WindowBg
            tgPillLbl.Text = tr("tg_Copied")
            TweenService:Create(tgBannerStroke, TweenInfo.new(0.12), { Color = THEME.White, Transparency = 0.1 }):Play()
            task.delay(1.1, function()
                if tgPill and tgPill.Parent then
                    TweenService:Create(tgPill, TweenInfo.new(0.18), { BackgroundColor3 = THEME.WindowBg }):Play()
                    tgPillLbl.TextColor3 = THEME.White
                    tgPillLbl.Text = tr("tg_CopyAct")
                    TweenService:Create(tgBannerStroke, TweenInfo.new(0.18), { Color = THEME.BorderLight, Transparency = 0.35 }):Play()
                end
            end)
        end)

        addSectionHeader(sCol, "sec_Settings")
        addPillToggle(sCol, "en_Save", State.AutoSave, function(v)
            State.AutoSave = v
            saveConfigNow(true)
        end)
        addMonoAction(sCol, "lang_Btn", "lang_Val", function()
            State.Lang = (State.Lang == "RU") and "EN" or "RU"
            saveConfigNow(true)
            buildMainUI(false)
        end)
        addMonoAction(sCol, "reset_Pos", "reset_PosBtn", function()
            State.OrbPos = { DEFAULT_ORB_POS[1], DEFAULT_ORB_POS[2], DEFAULT_ORB_POS[3], DEFAULT_ORB_POS[4] }
            State.HudPos = { 0.015, 0, 0.25, 0 }
            State.AutoM1BtnPos = { 0.86, 0, 0.22, 0 }
            State.KillAuraBtnPos = { 0.86, 0, 0.31, 0 }
            State.AutoFarmBtnPos = { 0.86, 0, 0.40, 0 }
            TweenService:Create(pillBtn, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(DEFAULT_ORB_POS[1], DEFAULT_ORB_POS[2], DEFAULT_ORB_POS[3], DEFAULT_ORB_POS[4])
            }):Play()
            TweenService:Create(farmHudFrame, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.015, 0, 0.25, 0) }):Play()
            TweenService:Create(autoM1Float, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.86, 0, 0.22, 0) }):Play()
            TweenService:Create(killAuraFloat, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.86, 0, 0.31, 0) }):Play()
            TweenService:Create(autoFarmFloat, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.86, 0, 0.40, 0) }):Play()
            autoSaveImmediate()
        end)

        addSectionHeader(sCol, "sec_Buttons")
        addPillToggle(sCol, "btn_M1", State.ShowAutoM1FloatingBtn, function(v)
            State.ShowAutoM1FloatingBtn = v; autoM1Float.Visible = v; syncAllCombatVisuals(); autoSaveImmediate()
        end)
        addPillToggle(sCol, "btn_KA", State.ShowKillAuraFloatingBtn, function(v)
            State.ShowKillAuraFloatingBtn = v; killAuraFloat.Visible = v; syncAllCombatVisuals(); autoSaveImmediate()
        end)
        addPillToggle(sCol, "btn_Farm", State.ShowAutoFarmFloatingBtn, function(v)
            State.ShowAutoFarmFloatingBtn = v; autoFarmFloat.Visible = v; syncAllCombatVisuals(); autoSaveImmediate()
        end)

        addSectionHeader(sCol, "sec_System")
        addMonoAction(sCol, "srv_HopBtn", "srv_HopAct", function(btnRef)
            performPopulatedServerHop(function(msg)
                if btnRef and btnRef.Parent then
                    btnRef.Text = msg
                    task.delay(3.0, function()
                        if btnRef and btnRef.Parent and not isServerHopping then
                            btnRef.Text = tr("srv_HopAct")
                        end
                    end)
                end
            end)
        end)
        addMonoAction(sCol, "reset_Save", "reset_SaveBtn", function()
            resetAllSavedData()
        end)

        local stLbl = Instance.new("TextLabel")
        stLbl.Size = UDim2.new(1, 0, 0, 22)
        stLbl.Position = UDim2.new(0, 4, 0, 0)
        stLbl.BackgroundTransparency = 1
        stLbl.Text = State.Lang == "RU" and "Статус: Готов" or "Status: Ready"
        stLbl.TextColor3 = THEME.TextMuted
        stLbl.TextSize = 10
        stLbl.Font = FONT_MED
        stLbl.TextXAlignment = Enum.TextXAlignment.Left
        stLbl.LayoutOrder = nextOrder()
        stLbl.ZIndex = 7
        stLbl.Parent = sCol

        updateSaveStatusLabel = function(m)
            if stLbl and stLbl.Parent then
                stLbl.Text = "  " .. m
                stLbl.TextColor3 = THEME.White
            end
        end
    end

    local resizeGrip = Instance.new("TextButton")
    resizeGrip.Size = UDim2.new(0, 18, 0, 18)
    resizeGrip.AnchorPoint = Vector2.new(1, 1)
    resizeGrip.Position = UDim2.new(1, -4, 1, -4)
    resizeGrip.BackgroundTransparency = 1
    resizeGrip.Text = ""
    resizeGrip.AutoButtonColor = false
    resizeGrip.ZIndex = 14
    resizeGrip.Parent = mainFrame
    local setResizeIcon = drawIcon(resizeGrip, "Resize", THEME.TextMuted)
    resizeGrip.MouseEnter:Connect(function() setResizeIcon(THEME.White) end)
    resizeGrip.MouseLeave:Connect(function() setResizeIcon(THEME.TextMuted) end)

    local dragW, startW, origW = false, Vector3.zero, mainFrame.Position
    topBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local relX = i.Position.X - topBar.AbsolutePosition.X
            if relX >= (topBar.AbsoluteSize.X - 82) then
                return
            end
            dragW = true; startW = i.Position; origW = mainFrame.Position
        end
    end)

    local resizingW, startR, origSize = false, Vector3.zero, windowSize
    resizeGrip.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            resizingW = true; startR = i.Position; origSize = windowSize
        end
    end)

    table.insert(Connections, UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local sc = currentAdaptiveScale > 0 and currentAdaptiveScale or 1
        if dragW then
            local d = i.Position - startW
            mainFrame.Position = UDim2.new(origW.X.Scale, origW.X.Offset + d.X, origW.Y.Scale, origW.Y.Offset + d.Y)
        elseif resizingW then
            local d = (i.Position - startR) / sc
            local newW = math.clamp(math.floor(origSize.X + d.X), 480, 880)
            local newH = math.clamp(math.floor(origSize.Y + d.Y), 340, 660)
            windowSize = Vector2.new(newW, newH)
            mainFrame.Size = UDim2.new(0, newW, 0, newH)
        end
    end))

    table.insert(Connections, UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragW = false
            resizingW = false
        end
    end))

    selectTab(activeTabKey, true)
    syncAllCombatVisuals()
end

showCloseConfirmPopup = function()
    if not screenGui or not screenGui.Parent then
        if unload then unload() end
        return
    end
    if screenGui:FindFirstChild("ReACKCloseConfirmOverlay") then return end

    local overlay = Instance.new("TextButton")
    overlay.Name = "ReACKCloseConfirmOverlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Text = ""
    overlay.AutoButtonColor = false
    overlay.Active = true
    overlay.ZIndex = 70
    overlay.Parent = screenGui

    TweenService:Create(overlay, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.52
    }):Play()

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Size = UDim2.new(0, 348, 0, 150)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    card.BackgroundColor3 = THEME.WindowBg
    card.BackgroundTransparency = 0.02
    card.BorderSizePixel = 0
    card.ZIndex = 72
    card.Parent = overlay

    addCorner(card, 10)
    addStroke(card, THEME.BorderLight, 1, 0.3)

    local targetScale = computeAdaptiveScale()
    closeScaleObj = Instance.new("UIScale")
    closeScaleObj.Scale = targetScale * 0.85
    closeScaleObj.Parent = card

    TweenService:Create(closeScaleObj, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = targetScale
    }):Play()

    createReackLogo(card, 16, 14, 20)

    local hdrTitle = Instance.new("TextLabel")
    hdrTitle.Size = UDim2.new(1, -48, 0, 20)
    hdrTitle.Position = UDim2.new(0, 44, 0, 14)
    hdrTitle.BackgroundTransparency = 1
    hdrTitle.Text = BRAND_NAME .. "  |  " .. tr("close_PopupTitle")
    hdrTitle.TextColor3 = THEME.White
    hdrTitle.TextSize = 12
    hdrTitle.Font = FONT_BOLD
    hdrTitle.TextXAlignment = Enum.TextXAlignment.Left
    hdrTitle.ZIndex = 74
    hdrTitle.Parent = card

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -32, 0, 20)
    msgLbl.Position = UDim2.new(0, 16, 0, 46)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = tr("close_PopupMsg")
    msgLbl.TextColor3 = THEME.White
    msgLbl.TextSize = 13
    msgLbl.Font = FONT_BOLD
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.ZIndex = 74
    msgLbl.Parent = card

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1, -32, 0, 16)
    subLbl.Position = UDim2.new(0, 16, 0, 68)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = tr("close_PopupSub")
    subLbl.TextColor3 = THEME.TextDim
    subLbl.TextSize = 11
    subLbl.Font = FONT_REG
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.ZIndex = 74
    subLbl.Parent = card

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 142, 0, 32)
    cancelBtn.Position = UDim2.new(0, 16, 1, -46)
    cancelBtn.BackgroundColor3 = THEME.ControlBg
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Text = tr("close_Cancel")
    cancelBtn.TextColor3 = THEME.White
    cancelBtn.TextSize = 11
    cancelBtn.Font = FONT_MED
    cancelBtn.Active = true
    cancelBtn.AutoButtonColor = false
    cancelBtn.ZIndex = 75
    cancelBtn.Parent = card
    addCorner(cancelBtn, 6)
    addStroke(cancelBtn, THEME.BorderLight, 1, 0.35)
    attachButtonAnim(cancelBtn, THEME.ControlBg, THEME.ControlHover)

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0, 164, 0, 32)
    confirmBtn.Position = UDim2.new(1, -180, 1, -46)
    confirmBtn.BackgroundColor3 = THEME.Danger
    confirmBtn.BorderSizePixel = 0
    confirmBtn.Text = ""
    confirmBtn.Active = true
    confirmBtn.AutoButtonColor = false
    confirmBtn.ZIndex = 75
    confirmBtn.Parent = card
    addCorner(confirmBtn, 6)
    attachButtonAnim(confirmBtn, THEME.Danger, THEME.DangerHover)

    local confContent = Instance.new("Frame")
    confContent.Size = UDim2.fromScale(1, 1)
    confContent.BackgroundTransparency = 1
    confContent.ZIndex = 76
    confContent.Parent = confirmBtn

    local confLayout = Instance.new("UIListLayout")
    confLayout.FillDirection = Enum.FillDirection.Horizontal
    confLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    confLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    confLayout.Padding = UDim.new(0, 6)
    confLayout.SortOrder = Enum.SortOrder.LayoutOrder
    confLayout.Parent = confContent

    local confIconSlot = Instance.new("Frame")
    confIconSlot.Size = UDim2.new(0, 14, 0, 14)
    confIconSlot.BackgroundTransparency = 1
    confIconSlot.LayoutOrder = 1
    confIconSlot.ZIndex = 77
    confIconSlot.Parent = confContent
    drawIcon(confIconSlot, "Close", THEME.White)

    local confTextLbl = Instance.new("TextLabel")
    confTextLbl.Size = UDim2.new(0, 0, 1, 0)
    confTextLbl.AutomaticSize = Enum.AutomaticSize.X
    confTextLbl.BackgroundTransparency = 1
    confTextLbl.Text = tr("close_Confirm")
    confTextLbl.TextColor3 = THEME.White
    confTextLbl.TextSize = 11
    confTextLbl.Font = FONT_BOLD
    confTextLbl.LayoutOrder = 2
    confTextLbl.ZIndex = 77
    confTextLbl.Parent = confContent

    local closing = false
    local function dismissDialog()
        if closing then return end
        closing = true
        TweenService:Create(overlay, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1
        }):Play()
        if closeScaleObj then
            TweenService:Create(closeScaleObj, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Scale = computeAdaptiveScale() * 0.85
            }):Play()
        end
        task.delay(0.17, function()
            if overlay then overlay:Destroy() end
            closeScaleObj = nil
        end)
    end

    bindReliableClick(cancelBtn, dismissDialog)
    bindReliableClick(confirmBtn, function()
        if closing then return end
        closing = true
        if unload then
            unload()
        elseif screenGui then
            screenGui:Destroy()
        end
    end)
end

showLanguagePopup = function(onChosen)
    if State.SeenLanguagePopup or not screenGui or not screenGui.Parent then
        if onChosen then onChosen() end
        return
    end

    local old = screenGui:FindFirstChild("ReACKLanguagePopupOverlay")
    if old then old:Destroy() end

    local overlay = Instance.new("Frame")
    overlay.Name = "ReACKLanguagePopupOverlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 55
    overlay.Parent = screenGui

    TweenService:Create(overlay, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.48
    }):Play()

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Size = UDim2.new(0, 368, 0, 186)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    card.BackgroundColor3 = THEME.WindowBg
    card.BackgroundTransparency = 0.02
    card.BorderSizePixel = 0
    card.ZIndex = 57
    card.Parent = overlay

    addCorner(card, 10)
    addStroke(card, THEME.BorderLight, 1, 0.25)

    local targetScale = computeAdaptiveScale()
    langScaleObj = Instance.new("UIScale")
    langScaleObj.Scale = targetScale * 0.86
    langScaleObj.Parent = card

    TweenService:Create(langScaleObj, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = targetScale
    }):Play()

    createReackLogo(card, 16, 14, 20)

    local topTitle = Instance.new("TextLabel")
    topTitle.Size = UDim2.new(1, -52, 0, 20)
    topTitle.Position = UDim2.new(0, 44, 0, 14)
    topTitle.BackgroundTransparency = 1
    topTitle.Text = BRAND_NAME .. "  |  Language"
    topTitle.TextColor3 = THEME.White
    topTitle.TextSize = 12
    topTitle.Font = FONT_BOLD
    topTitle.TextXAlignment = Enum.TextXAlignment.Left
    topTitle.ZIndex = 59
    topTitle.Parent = card

    local mainPrompt = Instance.new("TextLabel")
    mainPrompt.Size = UDim2.new(1, -32, 0, 20)
    mainPrompt.Position = UDim2.new(0, 16, 0, 46)
    mainPrompt.BackgroundTransparency = 1
    mainPrompt.Text = "Выберите язык  |  Choose Language"
    mainPrompt.TextColor3 = THEME.White
    mainPrompt.TextSize = 14
    mainPrompt.Font = FONT_BOLD
    mainPrompt.TextXAlignment = Enum.TextXAlignment.Left
    mainPrompt.ZIndex = 59
    mainPrompt.Parent = card

    local subPrompt = Instance.new("TextLabel")
    subPrompt.Size = UDim2.new(1, -32, 0, 16)
    subPrompt.Position = UDim2.new(0, 16, 0, 68)
    subPrompt.BackgroundTransparency = 1
    subPrompt.Text = "Изменить можно позже в настройках  |  Change anytime in Settings"
    subPrompt.TextColor3 = THEME.TextDim
    subPrompt.TextSize = 10
    subPrompt.Font = FONT_REG
    subPrompt.TextXAlignment = Enum.TextXAlignment.Left
    subPrompt.ZIndex = 59
    subPrompt.Parent = card

    local picked = false
    local function buildLangChoice(xPos, code, titleText, subText)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 162, 0, 74)
        btn.Position = UDim2.new(0, xPos, 0, 96)
        btn.BackgroundColor3 = THEME.ControlBg
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 59
        btn.Parent = card
        addCorner(btn, 8)
        local st = addStroke(btn, THEME.BorderLight, 1, 0.35)
        attachButtonAnim(btn, THEME.ControlBg, THEME.ControlHover)

        local badge = Instance.new("Frame")
        badge.Size = UDim2.new(0, 32, 0, 20)
        badge.Position = UDim2.new(0, 12, 0, 12)
        badge.BackgroundColor3 = THEME.White
        badge.BorderSizePixel = 0
        badge.ZIndex = 60
        badge.Parent = btn
        addCorner(badge, 5)

        local badgeLbl = Instance.new("TextLabel")
        badgeLbl.Size = UDim2.fromScale(1, 1)
        badgeLbl.BackgroundTransparency = 1
        badgeLbl.Text = code
        badgeLbl.TextColor3 = THEME.WindowBg
        badgeLbl.TextSize = 10
        badgeLbl.Font = FONT_BOLD
        badgeLbl.ZIndex = 61
        badgeLbl.Parent = badge

        local cTitle = Instance.new("TextLabel")
        cTitle.Size = UDim2.new(1, -24, 0, 18)
        cTitle.Position = UDim2.new(0, 12, 0, 36)
        cTitle.BackgroundTransparency = 1
        cTitle.Text = titleText
        cTitle.TextColor3 = THEME.White
        cTitle.TextSize = 13
        cTitle.Font = FONT_BOLD
        cTitle.TextXAlignment = Enum.TextXAlignment.Left
        cTitle.ZIndex = 60
        cTitle.Parent = btn

        local cSub = Instance.new("TextLabel")
        cSub.Size = UDim2.new(1, -24, 0, 14)
        cSub.Position = UDim2.new(0, 12, 0, 54)
        cSub.BackgroundTransparency = 1
        cSub.Text = subText
        cSub.TextColor3 = THEME.TextDim
        cSub.TextSize = 10
        cSub.Font = FONT_REG
        cSub.TextXAlignment = Enum.TextXAlignment.Left
        cSub.ZIndex = 60
        cSub.Parent = btn

        btn.Activated:Connect(function()
            if picked then return end
            picked = true
            State.Lang = code
            State.SeenLanguagePopup = true
            saveConfigNow(true)

            TweenService:Create(st, TweenInfo.new(0.12), { Color = THEME.White, Thickness = 1.6, Transparency = 0 }):Play()
            TweenService:Create(overlay, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 1
            }):Play()
            if langScaleObj then
                TweenService:Create(langScaleObj, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Scale = computeAdaptiveScale() * 0.86
                }):Play()
            end
            task.delay(0.19, function()
                if overlay then overlay:Destroy() end
                langScaleObj = nil
                if onChosen then onChosen() end
            end)
        end)
    end

    buildLangChoice(16, "RU", "Русский", "Интерфейс на русском")
    buildLangChoice(190, "EN", "English", "English interface")
end

showTelegramPopup = function(forceShow)
    if (not forceShow and State.SeenTelegramPopup) or not screenGui or not screenGui.Parent then
        return
    end

    local old = screenGui:FindFirstChild("ReACKTelegramPopupOverlay")
    if old then old:Destroy() end

    local overlay = Instance.new("Frame")
    overlay.Name = "ReACKTelegramPopupOverlay"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 60
    overlay.Parent = screenGui

    TweenService:Create(overlay, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.52
    }):Play()

    local card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Size = UDim2.new(0, 348, 0, 150)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    card.BackgroundColor3 = THEME.WindowBg
    card.BackgroundTransparency = 0.02
    card.BorderSizePixel = 0
    card.ZIndex = 62
    card.Parent = overlay

    addCorner(card, 10)
    addStroke(card, THEME.BorderLight, 1, 0.3)

    local targetScale = computeAdaptiveScale()
    popupScaleObj = Instance.new("UIScale")
    popupScaleObj.Scale = targetScale * 0.85
    popupScaleObj.Parent = card

    TweenService:Create(popupScaleObj, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = targetScale
    }):Play()

    createReackLogo(card, 16, 14, 20)

    local hdrTitle = Instance.new("TextLabel")
    hdrTitle.Size = UDim2.new(1, -48, 0, 20)
    hdrTitle.Position = UDim2.new(0, 44, 0, 14)
    hdrTitle.BackgroundTransparency = 1
    hdrTitle.Text = BRAND_NAME .. "  |  " .. tr("tg_PopupTitle")
    hdrTitle.TextColor3 = THEME.White
    hdrTitle.TextSize = 12
    hdrTitle.Font = FONT_BOLD
    hdrTitle.TextXAlignment = Enum.TextXAlignment.Left
    hdrTitle.ZIndex = 64
    hdrTitle.Parent = card

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -32, 0, 20)
    msgLbl.Position = UDim2.new(0, 16, 0, 46)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = tr("tg_PopupMsg")
    msgLbl.TextColor3 = THEME.White
    msgLbl.TextSize = 13
    msgLbl.Font = FONT_BOLD
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.ZIndex = 64
    msgLbl.Parent = card

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1, -32, 0, 16)
    subLbl.Position = UDim2.new(0, 16, 0, 68)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = tr("tg_PopupSub")
    subLbl.TextColor3 = THEME.TextDim
    subLbl.TextSize = 11
    subLbl.Font = FONT_REG
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.ZIndex = 64
    subLbl.Parent = card

    local noBtn = Instance.new("TextButton")
    noBtn.Size = UDim2.new(0, 130, 0, 32)
    noBtn.Position = UDim2.new(0, 16, 1, -46)
    noBtn.BackgroundColor3 = THEME.ControlBg
    noBtn.BorderSizePixel = 0
    noBtn.Text = tr("tg_NoThanks")
    noBtn.TextColor3 = THEME.TextDim
    noBtn.TextSize = 11
    noBtn.Font = FONT_MED
    noBtn.AutoButtonColor = false
    noBtn.ZIndex = 64
    noBtn.Parent = card
    addCorner(noBtn, 6)
    addStroke(noBtn, THEME.BorderLight, 1, 0.4)
    attachButtonAnim(noBtn, THEME.ControlBg, THEME.ControlHover)

    local subBtn = Instance.new("TextButton")
    subBtn.Size = UDim2.new(0, 176, 0, 32)
    subBtn.Position = UDim2.new(1, -192, 1, -46)
    subBtn.BackgroundColor3 = THEME.White
    subBtn.BorderSizePixel = 0
    subBtn.Text = ""
    subBtn.AutoButtonColor = false
    subBtn.ZIndex = 64
    subBtn.Parent = card
    addCorner(subBtn, 6)
    attachButtonAnim(subBtn, THEME.White, Color3.fromRGB(220, 220, 224))

    local subContent = Instance.new("Frame")
    subContent.Size = UDim2.fromScale(1, 1)
    subContent.BackgroundTransparency = 1
    subContent.ZIndex = 65
    subContent.Parent = subBtn

    local subLayout = Instance.new("UIListLayout")
    subLayout.FillDirection = Enum.FillDirection.Horizontal
    subLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    subLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    subLayout.Padding = UDim.new(0, 6)
    subLayout.SortOrder = Enum.SortOrder.LayoutOrder
    subLayout.Parent = subContent

    local tgIconSlot = Instance.new("Frame")
    tgIconSlot.Size = UDim2.new(0, 18, 0, 18)
    tgIconSlot.BackgroundTransparency = 1
    tgIconSlot.LayoutOrder = 1
    tgIconSlot.ZIndex = 66
    tgIconSlot.Parent = subContent
    drawIcon(tgIconSlot, "Telegram", THEME.WindowBg)

    local subTextLbl = Instance.new("TextLabel")
    subTextLbl.Size = UDim2.new(0, 0, 1, 0)
    subTextLbl.AutomaticSize = Enum.AutomaticSize.X
    subTextLbl.BackgroundTransparency = 1
    subTextLbl.Text = tr("tg_Subscribe")
    subTextLbl.TextColor3 = THEME.WindowBg
    subTextLbl.TextSize = 11
    subTextLbl.Font = FONT_BOLD
    subTextLbl.LayoutOrder = 2
    subTextLbl.ZIndex = 66
    subTextLbl.Parent = subContent

    local closing = false
    local function closePopup()
        if closing then return end
        closing = true
        State.SeenTelegramPopup = true
        saveConfigNow(true)

        TweenService:Create(overlay, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1
        }):Play()
        if popupScaleObj then
            TweenService:Create(popupScaleObj, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Scale = computeAdaptiveScale() * 0.85
            }):Play()
        end
        task.delay(0.19, function()
            if overlay then overlay:Destroy() end
            popupScaleObj = nil
        end)
    end

    noBtn.Activated:Connect(function()
        closePopup()
    end)

    subBtn.Activated:Connect(function()
        if closing then return end
        copyToClipboard(TELEGRAM_INVITE)
        tgIconSlot.Visible = false
        subTextLbl.Text = tr("tg_Copied")
        task.delay(0.85, closePopup)
    end)
end

showSimpleLoader = function(onFinished)
    local old = screenGui:FindFirstChild("ReACKLoaderFrame")
    if old then old:Destroy() end

    local ldr = Instance.new("Frame")
    ldr.Name = "ReACKLoaderFrame"
    ldr.AnchorPoint = Vector2.new(0.5, 0.5)
    ldr.Size = UDim2.new(0, 356, 0, 126)
    ldr.Position = UDim2.new(0.5, 0, 0.5, 0)
    ldr.BackgroundColor3 = THEME.WindowBg
    ldr.BackgroundTransparency = 0.02
    ldr.BorderSizePixel = 0
    ldr.ZIndex = 45
    ldr.Parent = screenGui

    addCorner(ldr, 10)
    addStroke(ldr, THEME.BorderLight, 1, 0.3)

    local targetScale = computeAdaptiveScale()
    loaderScaleObj = Instance.new("UIScale")
    loaderScaleObj.Scale = targetScale * 0.88
    loaderScaleObj.Parent = ldr

    TweenService:Create(loaderScaleObj, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = targetScale
    }):Play()

    createReackLogo(ldr, 16, 14, 24)

    local lTitle = Instance.new("TextLabel")
    lTitle.Size = UDim2.new(0, 140, 0, 24)
    lTitle.Position = UDim2.new(0, 48, 0, 14)
    lTitle.BackgroundTransparency = 1
    lTitle.Text = BRAND_NAME
    lTitle.TextColor3 = THEME.White
    lTitle.TextSize = 15
    lTitle.Font = FONT_BOLD
    lTitle.TextXAlignment = Enum.TextXAlignment.Left
    lTitle.ZIndex = 47
    lTitle.Parent = ldr

    local pctLbl = Instance.new("TextLabel")
    pctLbl.Size = UDim2.new(0, 60, 0, 24)
    pctLbl.AnchorPoint = Vector2.new(1, 0)
    pctLbl.Position = UDim2.new(1, -16, 0, 14)
    pctLbl.BackgroundTransparency = 1
    pctLbl.Text = "0%"
    pctLbl.TextColor3 = THEME.White
    pctLbl.TextSize = 12
    pctLbl.Font = FONT_BOLD
    pctLbl.TextXAlignment = Enum.TextXAlignment.Right
    pctLbl.ZIndex = 47
    pctLbl.Parent = ldr

    local function makeDualLangRow(yPos, code, textVal)
        local badge = Instance.new("Frame")
        badge.Size = UDim2.new(0, 26, 0, 17)
        badge.Position = UDim2.new(0, 16, 0, yPos)
        badge.BackgroundColor3 = THEME.ControlBg
        badge.BorderSizePixel = 0
        badge.ZIndex = 47
        badge.Parent = ldr
        addCorner(badge, 4)
        addStroke(badge, THEME.BorderLight, 1, 0.35)

        local bTxt = Instance.new("TextLabel")
        bTxt.Size = UDim2.fromScale(1, 1)
        bTxt.BackgroundTransparency = 1
        bTxt.Text = code
        bTxt.TextColor3 = THEME.White
        bTxt.TextSize = 9
        bTxt.Font = FONT_BOLD
        bTxt.ZIndex = 48
        bTxt.Parent = badge

        local lineLbl = Instance.new("TextLabel")
        lineLbl.Size = UDim2.new(1, -66, 0, 17)
        lineLbl.Position = UDim2.new(0, 48, 0, yPos)
        lineLbl.BackgroundTransparency = 1
        lineLbl.Text = textVal
        lineLbl.TextColor3 = THEME.TextDim
        lineLbl.TextSize = 11
        lineLbl.Font = FONT_MED
        lineLbl.TextXAlignment = Enum.TextXAlignment.Left
        lineLbl.ZIndex = 47
        lineLbl.Parent = ldr
        return lineLbl
    end

    local ruLoadLbl = makeDualLangRow(48, "RU", "Загрузка модулей...")
    local enLoadLbl = makeDualLangRow(70, "EN", "Loading modules...")

    local progTrack = Instance.new("Frame")
    progTrack.Size = UDim2.new(1, -32, 0, 5)
    progTrack.Position = UDim2.new(0, 16, 0, 100)
    progTrack.BackgroundColor3 = THEME.TrackBg
    progTrack.BorderSizePixel = 0
    progTrack.ZIndex = 47
    progTrack.Parent = ldr
    addPillCorner(progTrack)

    local progFill = Instance.new("Frame")
    progFill.Size = UDim2.new(0, 0, 1, 0)
    progFill.BackgroundColor3 = THEME.White
    progFill.BorderSizePixel = 0
    progFill.ZIndex = 48
    progFill.Parent = progTrack
    addPillCorner(progFill)

    task.spawn(tryResolveModules)

    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not ldr or not ldr.Parent then
            if conn then conn:Disconnect() end
            return
        end
        local ratio = math.clamp((os.clock() - startTime) / LOADER_DURATION, 0, 1)
        progFill.Size = UDim2.new(ratio, 0, 1, 0)
        pctLbl.Text = string.format("%d%%", math.floor(ratio * 100 + 0.5))

        if ratio < 0.45 then
            ruLoadLbl.Text = "Загрузка модулей..."
            enLoadLbl.Text = "Loading modules..."
        elseif ratio < 0.85 then
            ruLoadLbl.Text = "Подготовка интерфейса..."
            enLoadLbl.Text = "Preparing interface..."
        else
            ruLoadLbl.Text = "Загрузка завершена"
            enLoadLbl.Text = "Loading complete"
            ruLoadLbl.TextColor3 = THEME.White
            enLoadLbl.TextColor3 = THEME.White
        end

        if ratio >= 1 then
            if conn then conn:Disconnect() end
            if loaderScaleObj then
                TweenService:Create(loaderScaleObj, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Scale = computeAdaptiveScale() * 0.85
                }):Play()
            end
            task.delay(0.17, function()
                if ldr then ldr:Destroy() end
                loaderScaleObj = nil
                onFinished()
            end)
        end
    end)
end

showSimpleLoader(function()
    if not State.SeenLanguagePopup then
        showLanguagePopup(function()
            buildMainUI(true)
            if not State.SeenTelegramPopup then
                task.delay(0.25, function()
                    showTelegramPopup(false)
                end)
            end
        end)
    else
        saveConfigNow(true)
        buildMainUI(true)
        if not State.SeenTelegramPopup then
            task.delay(0.25, function()
                showTelegramPopup(false)
            end)
        end
    end
end)


unload = function()
    if not State.Active then return end
    State.Active = false
    State.AutoM1 = false
    State.KillAura = false
    State.InfinitePunch = false
    State.SpeedBoost = false
    State.InfiniteDash = false
    State.EspEnabled = false
    State.AutoFarm = false

    currentFarmTarget, currentFarmPlr, currentFarmHum = nil, nil, nil
    currentKillAuraTarget = nil

    for i = #Connections, 1, -1 do
        local c = Connections[i]
        Connections[i] = nil
        if c then
            pcall(function() c:Disconnect() end)
        end
    end

    if screenGui then
        pcall(function() screenGui.Enabled = false end)
    end

    task.defer(function()
        pcall(clearAllEsp)
        pcall(restoreCooldowns)
        pcall(restoreDashCooldowns)
        pcall(restoreNoclip)

        local _, h, r = getCharacterParts(localPlayer)
        if h then
            pcall(function()
                h.WalkSpeed = State.DefaultWalkSpeed
                h.AutoRotate = true
                h.PlatformStand = false
            end)
        end
        if r then
            pcall(function()
                r.AssemblyLinearVelocity = Vector3.zero
            end)
        end

        if screenGui then
            pcall(function() screenGui:Destroy() end)
            screenGui = nil
        end
        env.ReACK = nil
    end)
end

env.ReACK = {
    Unload = unload,
    State = State,
    SaveConfig = function() return saveConfigNow(true) end,
    ResetSave = resetAllSavedData,
    ServerHop = performPopulatedServerHop,
}
