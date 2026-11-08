; <COMPILER: v1.1.37.02>
; =================================================================================================
; 🚔 АХК ГУ МВД РОССИИ — ЭЛИТНЫЙ БОЕВОЙ RP-БИНДЕР ДЛЯ MTA PROVINCE
; 💎 СОВРЕМЕННЫЙ ДИЗАЙН FLUENT 2.0 (HTML5/CSS3/JS), ТАКТИЧЕСКИЕ ЗВУКИ РАЦИИ & МОБИЛЬНЫЙ ПЛАНШЕТ
; ⚡ ПОЛНАЯ ПОДДЕРЖКА WINDOWS 11 (23H2 / 24H2+), PER-MONITOR DPI V2 И АВТОМАТИЧЕСКАЯ ТЕЛЕМЕТРИЯ
; =================================================================================================
#SingleInstance Force
SetTitleMatchMode, 2
SetTitleMatchMode, Fast
CheckAdmin()
#NoEnv
#MaxThreadsPerHotkey 2
Process, Priority,, High
#InstallKeybdHook
#UseHook, On
SetStoreCapsLockMode, Off
SetWorkingDir %A_ScriptDir%
FileEncoding UTF-8

; Группа окон игры MTA Province / GTA San Andreas
GroupAdd, ProvinceGameGroup, ahk_exe Multi Theft Auto.exe
GroupAdd, ProvinceGameGroup, ahk_exe gta_sa.exe
GroupAdd, ProvinceGameGroup, ahk_exe proxy_sa.exe
GroupAdd, ProvinceGameGroup, ahk_class Grand theft auto San Andreas
GroupAdd, ProvinceGameGroup, ahk_exe MTA.exe
GroupAdd, ProvinceGameGroup, ahk_class GTA:SA:MP
GroupAdd, ProvinceGameGroup, MTA: Province
GroupAdd, ProvinceGameGroup, GTA:SA

; Автораспаковка ресурсов при первом запуске (Standalone EXE режим)
if (!FileExist(A_ScriptDir . "\1.mp3")) {
    try {
        FileInstall, 1.mp3, %A_ScriptDir%\1.mp3, 1
    }
}
if (!FileExist(A_ScriptDir . "\gumvd.ico")) {
    try {
        FileInstall, gumvd.ico, %A_ScriptDir%\gumvd.ico, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets"))
    FileCreateDir, %A_ScriptDir%\assets

if (!FileExist(A_ScriptDir . "\assets\fluent_gumvd_hero.jpg")) {
    try {
        FileInstall, assets\fluent_gumvd_hero.jpg, %A_ScriptDir%\assets\fluent_gumvd_hero.jpg, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets\fluent_gumvd_crest.jpg")) {
    try {
        FileInstall, assets\fluent_gumvd_crest.jpg, %A_ScriptDir%\assets\fluent_gumvd_crest.jpg, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets\fluent_gumvd_patrol_card.jpg")) {
    try {
        FileInstall, assets\fluent_gumvd_patrol_card.jpg, %A_ScriptDir%\assets\fluent_gumvd_patrol_card.jpg, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets\fluent_gumvd.html")) {
    try {
        FileInstall, assets\fluent_gumvd.html, %A_ScriptDir%\assets\fluent_gumvd.html, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets\mobile_tablet.html")) {
    try {
        FileInstall, assets\mobile_tablet.html, %A_ScriptDir%\assets\mobile_tablet.html, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets\radio_start.wav")) {
    try {
        FileInstall, assets\radio_start.wav, %A_ScriptDir%\assets\radio_start.wav, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets\radio_stop.wav")) {
    try {
        FileInstall, assets\radio_stop.wav, %A_ScriptDir%\assets\radio_stop.wav, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets\articles.json")) {
    try {
        FileInstall, assets\articles.json, %A_ScriptDir%\assets\articles.json, 1
    }
}

AbortBindFlag := 0
RefreshTray()
Gosub, AHK
Return

; =================================================================================================
; СИСТЕМНЫЕ ФУНКЦИИ И WINDOWS 11 DPI / COMPATIBILITY
; =================================================================================================
InitDpiAwareness() {
    try {
        DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
    }
}

DetectWindowsVersion() {
    global OSBuildNumber, IsWin11_24H2_OrNewer, WinVerDescription
    RegRead, OSBuildNumber, HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentBuild
    if (OSBuildNumber = "" || ErrorLevel)
        RegRead, OSBuildNumber, HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentBuildNumber
    OSBuildNumber += 0
    if (OSBuildNumber >= 26100) {
        IsWin11_24H2_OrNewer := 1
        WinVerDescription := "Win 11 (24H2+ Build " . OSBuildNumber . ")"
    } else if (OSBuildNumber >= 22621) {
        IsWin11_24H2_OrNewer := 0
        WinVerDescription := "Win 11 (22H2/23H2 Build " . OSBuildNumber . ")"
    } else if (OSBuildNumber >= 22000) {
        IsWin11_24H2_OrNewer := 0
        WinVerDescription := "Win 11 (21H2 Build " . OSBuildNumber . ")"
    } else {
        IsWin11_24H2_OrNewer := 0
        WinVerDescription := "Win 10 / Legacy (Build " . OSBuildNumber . ")" 
    }
}

ApplySendEngineMode(ModeStr := "AUTO") {
    global IsWin11_24H2_OrNewer, ActiveSendEngine
    if (ModeStr = "SendPlay") {
        SendMode, Play
        ActiveSendEngine := "SendPlay (Классика)"
    } else if (ModeStr = "SendEvent") {
        SendMode, Event
        SetKeyDelay, -1, 0
        ActiveSendEngine := "SendEvent (DirectX)"
    } else {
        SendMode, Input
        ActiveSendEngine := "SendInput (Быстрый)"
    }
}

CheckAdmin() {
    if (!A_IsAdmin) {
        try {
            if (A_IsCompiled)
                Run *RunAs "%A_ScriptFullPath%" /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
        ExitApp
    }
}

CheckUIA() {
    if (!A_IsCompiled && !InStr(A_AhkPath, "_UIA")) {
        Run % "*uiAccess """ . A_ScriptFullPath . """"
        ExitApp
    }
}

SetLocaleRu() {
    SendMessage, 0x50,, 0x4190419,, A
}

SetLocaleEn() {
    SendMessage, 0x50,, 0x4090409,, A
}

SetCapsOff() {
    SetCapsLockState, Off
}

SmartSleep(delayMs) {
    global AbortBindFlag
    if (AbortBindFlag)
        return
    if (delayMs <= 50) {
        Sleep, %delayMs%
        return
    }
    steps := delayMs // 50
    rem := Mod(delayMs, 50)
    Loop, %steps% {
        if (AbortBindFlag)
            return
        Sleep, 50
    }
    if (rem > 0 && !AbortBindFlag)
        Sleep, %rem%
}

; =================================================================================================
; ИНИЦИАЛИЗАЦИЯ И ЗАПУСК (AHK:)
; =================================================================================================
AHK:
InitDpiAwareness()
DetectWindowsVersion()
EnsureDefaultConfig()
LoadUserConfig()
ApplySendEngineMode(SendMethodConfig)

if (Gender = "Я девочка") {
    Vers = 2.5.0ж
    Ok1 = а
    Ok2 = ла
    Ok3 = ась
    Ok4 = цы
    Ok5 = ца
    Ok6 = це
    Ok7 = ла
    Ok8 = ела
    Ok9 = есла
    Ok10 = цей
    Ok11 = екла
    Pol = 👩‍✈️
    Gend = женский
} else {
    Vers = 2.5.0м
    Ok1 =
    Ok2 =
    Ok3 = ся
    Ok4 = ка
    Ok5 = к
    Ok6 = ке
    Ok7 = ёл
    Ok8 = ёл
    Ok9 = ёс
    Ok10 = ком
    Ok11 = ёк
    Pol = 👨‍✈️
    Gend = мужской
}

CheckUIA()
Menu, Tray, Icon, %A_ScriptDir%\gumvd.ico

InitHotkeysManager()
InitArticlesDB()
InitTimersAndLogReader()
TabletRelay_Init()
InitClientHeartbeat()
SetBrowserEmulationIE11()
ShowFluentGUI()
Return

; =================================================================================================
; МЕНЕДЖЕР ГОРЯЧИХ КЛАВИШ (ИНТЕРАКТИВНОЕ ПЕРЕНАЗНАЧЕНИЕ В GUI)
; =================================================================================================
global HotkeyDefs := []

AddHkDef(id, name, cat, defKey, targetLabel) {
    global HotkeyDefs
    iniPath := A_Temp . "\gumvd.egl"
    IniRead, savedKey, %iniPath%, Hotkeys, %id%, %defKey%
    if (savedKey = "" || savedKey = "ERROR")
        savedKey := defKey
    curKey := savedKey

    hkObj := { Id: id, Name: name, Cat: cat, DefaultKey: defKey, CurrentKey: curKey, Target: targetLabel }
    HotkeyDefs.Push(hkObj)

    if (curKey != "" && curKey != "None" && curKey != "OFF") {
        try {
            Hotkey, %curKey%, %targetLabel%, On
        }
    }
}

InitHotkeysManager() {
    global HotkeyDefs
    HotkeyDefs := []

    ; Категория: 🛡️ Основное
    AddHkDef("HK_Greeting",      "Приветствие гражданина",                     "Основное",      "!1",          "Bind_Greeting")
    AddHkDef("HK_Udo",           "Показать удостоверение сотрудника ГУ МВД",   "Основное",      "^1",          "Bind_Udo")
    AddHkDef("HK_AskDocs",       "Запросить документы у гражданина",           "Основное",      "^2",          "Bind_AskDocs")
    AddHkDef("HK_TakeDocs",      "Взять документы из рук",                     "Основное",      "^3",          "Bind_TakeDocs")
    AddHkDef("HK_ReturnDocs",    "Изучить и вернуть документы",                "Основное",      "^4",          "Bind_ReturnDocs")
    AddHkDef("HK_Cuffs",         "Надеть наручники БР-С",                      "Основное",      "^5",          "Bind_Cuffs")
    AddHkDef("HK_Uncuffs",       "Снять наручники",                            "Основное",      "^6",          "Bind_Uncuffs")
    AddHkDef("HK_Escort",        "Заломать руку и вести конвоем",              "Основное",      "^7",          "Bind_Escort")
    AddHkDef("HK_ReleaseHands",  "Отпустить руки задержанного",                "Основное",      "^8",          "Bind_ReleaseHands")
    AddHkDef("HK_ProtocolSign",  "Зачитать права и составить протокол",        "Основное",      "^9",          "Bind_ProtocolSign")
    AddHkDef("HK_TransferKpz",   "Передача задержанного конвоиру / КПЗ",       "Основное",      "^0",          "Bind_TransferKpz")
    AddHkDef("HK_SuFast",        "Выдача розыска нарушителю (/su)",            "Основное",      "^-",          "Bind_SuFast")
    AddHkDef("HK_Wanted",        "База данных разыскиваемых (Wanted)",         "Основное",      "^F10",        "Bind_Wanted")
    AddHkDef("HK_KpkOpen",       "КПК: достать из кармана",                    "Основное",      "!3",          "Bind_KpkOpen")
    AddHkDef("HK_KpkPhoto",      "КПК: фоторобот / снимок лица",               "Основное",      "!4",          "Bind_KpkPhoto")
    AddHkDef("HK_KpkClose",      "КПК: убрать в карман",                       "Основное",      "!5",          "Bind_KpkClose")
    AddHkDef("HK_Putpl",         "Посадить задержанного в авто (/putpl)",      "Основное",      "!6",          "Bind_Putpl")
    AddHkDef("HK_KpkPassport",   "КПК: проверка по паспортным данным",         "Основное",      "!7",          "Bind_KpkPassport")

    ; Категория: ⚡ ОСН / СОБР / ГРОМ
    AddHkDef("HK_OsnPatch",      "Нашивка спецназа ОСН / СОБР",                "ОСН / Спецназ", "!2",          "Bind_OsnPatch")
    AddHkDef("HK_Pullout",       "Вытащить нарушителя из авто (/pullout)",     "ОСН / Спецназ", "^r",          "Bind_Pullout")
    AddHkDef("HK_TryDoor",       "Попытка выбить дверь автомобиля",            "ОСН / Спецназ", "!F12",        "Bind_TryDoor")
    AddHkDef("HK_TryGlass",      "Попытка разбить стекло автомобиля",          "ОСН / Спецназ", "!PrintScreen","Bind_TryGlass")
    AddHkDef("HK_UnlockIn",      "Разблокировать замок изнутри авто",          "ОСН / Спецназ", "!ScrollLock", "Bind_UnlockIn")

    ; Категория: 🔫 Спецсредства и Оружие
    AddHkDef("HK_Baton",         "Достать / убрать резиновую дубинку ПР-73",   "Спецсредства",  "^F9",         "Bind_Baton")
    AddHkDef("HK_Tazer",         "Достать / убрать электрошокер (Тайзер)",     "Спецсредства",  "^F8",         "Bind_Tazer")
    AddHkDef("HK_ColleagueGreet","Воинское приветствие коллеге",               "Спецсредства",  "^E",          "Bind_ColleagueGreet")

    ; Категория: 📢 Мегафон и Рация
    AddHkDef("HK_Megaphone1",    "Мегафон СГУ: Требование об остановке",       "Рация",         "!0",          "Bind_Megaphone1")
    AddHkDef("HK_MegaphoneWay",  "Мегафон СГУ: Уступите проезд спецколонне",   "Рация",         "!9",          "Bind_MegaphoneWay")
    AddHkDef("HK_MegaphoneStop", "Мегафон СГУ: Срочно остановитесь!",          "Рация",         "!8",          "Bind_MegaphoneStop")
    AddHkDef("HK_VoiceOn",       "Включить голосовую рацию (/fracvoice 1)",    "Рация",         "^insert",     "Bind_VoiceOn")
    AddHkDef("HK_VoiceOff",      "Рация в режим прослушивания (/fracvoice 2)", "Рация",         "^home",       "Bind_VoiceOff")

    ; Категория: ⚙️ Системные
    AddHkDef("HK_ToggleHud",     "Переключение тактического HUD таймеров",     "Система",       "!h",          "Bind_ToggleHud")
    AddHkDef("HK_OpenCalc",      "Калькулятор статей УК РП / КоАП",            "Система",       "!F1",         "Bind_OpenCalc")
    AddHkDef("HK_Reload",        "Быстрая перезагрузка биндера",               "Система",       "!r",          "Bind_Reload")
    AddHkDef("HK_Pause",         "Экстренная остановка текущей отыгровки",     "Система",       "end",         "Bind_Pause")
}

ApplyHotkeyRebind(hkId, newKey) {
    global HotkeyDefs
    iniPath := A_Temp . "\gumvd.egl"
    for idx, hk in HotkeyDefs {
        if (hk.Id = hkId) {
            oldKey := hk.CurrentKey
            if (oldKey != "" && oldKey != "None") {
                try {
                    Hotkey, %oldKey%, Off
                }
            }
            hk.CurrentKey := newKey
            IniWrite, %newKey%, %iniPath%, Hotkeys, %hkId%
            if (newKey != "" && newKey != "None") {
                try {
                    target := hk.Target
                    Hotkey, %newKey%, %target%, On
                }
            }
            return true
        }
    }
    return false
}

FormatHotkeyReadable(rawKey) {
    if (rawKey = "" || rawKey = "None")
        return "Не назначено"
    r := rawKey
    r := StrReplace(r, "!", "Alt + ")
    r := StrReplace(r, "^", "Ctrl + ")
    r := StrReplace(r, "+", "Shift + ")
    r := StrReplace(r, "#", "Win + ")
    StringUpper, r, r
    return r
}

; =================================================================================================
; КОНФИГУРАЦИЯ И ПРОФИЛЬ СОТРУДНИКА (GUMVD.EGL)
; =================================================================================================
EnsureDefaultConfig() {
    IniPath := A_Temp . "\gumvd.egl"
    IniRead, chkFio, %IniPath%, User, Fio1, ERROR
    if (chkFio = "ERROR" || chkFio = "") {
        IniWrite, Поланейчик Данил Сергеевич, %IniPath%, User, Fio1
        IniWrite, 1, %IniPath%, User, Prop1
        IniWrite, 51, %IniPath%, User, Prop2
        IniWrite, Сержант, %IniPath%, User, Rank
        IniWrite, 51, %IniPath%, User, Teg
        IniWrite, ППСП, %IniPath%, User, Otdel
        IniWrite, ОСпН Гром, %IniPath%, User, Osn
        IniWrite, Боец, %IniPath%, User, Dolznosn
        IniWrite, ГУ МВД г.Невский, %IniPath%, User, Frak
        IniWrite, Я мужык, %IniPath%, User, Gender
        IniWrite, ГУ МВД-Н, %IniPath%, User, Gibdd
        IniWrite, 1, %IniPath%, User, AutoScreenMode
        IniWrite, 1, %IniPath%, User, RadioSfx
        IniWrite, AUTO, %IniPath%, Settings, SendMethod
    }
}

LoadUserConfig() {
    global Fio1, Rank, Prop1, Prop2, Otdel, Frak, Gender, Teg, Gibdd, Osn, Dolznosn
    global SendMethodConfig, OnlyInGameMode, AutoScreenMode, RadioSfxEnabled
    IniPath := A_Temp . "\gumvd.egl"
    IniRead, Fio1, %IniPath%, User, Fio1, Поланейчик Данил Сергеевич
    IniRead, Rank, %IniPath%, User, Rank, Сержант
    IniRead, Prop1, %IniPath%, User, Prop1, 1
    IniRead, Prop2, %IniPath%, User, Prop2, 51
    IniRead, Otdel, %IniPath%, User, Otdel, ППСП
    IniRead, Osn, %IniPath%, User, Osn, ОСпН Гром
    IniRead, Dolznosn, %IniPath%, User, Dolznosn, Боец
    IniRead, Frak, %IniPath%, User, Frak, ГУ МВД г.Невский
    IniRead, Gender, %IniPath%, User, Gender, Я мужык
    IniRead, Teg, %IniPath%, User, Teg, 51
    IniRead, SendMethodConfig, %IniPath%, Settings, SendMethod, AUTO
    IniRead, OnlyInGameMode, %IniPath%, Settings, OnlyInGame, 0
    IniRead, AutoScreenMode, %IniPath%, User, AutoScreenMode, 1
    IniRead, RadioSfxEnabled, %IniPath%, User, RadioSfx, 1

    if (RadioSfxEnabled = "ERROR" || RadioSfxEnabled = "")
        RadioSfxEnabled := 1
    if (OnlyInGameMode = "ERROR" || OnlyInGameMode = "")
        OnlyInGameMode := 0
}

SaveUserProfileData(fio, rankVal, otdelVal, frakVal, tegVal, prop2Val, genderVal) {
    global Fio1, Rank, Otdel, Frak, Teg, Prop2, Gender, Vers, Ok1, Ok2, Ok3, Ok4, Ok5, Ok6, Ok7, Ok8, Ok9, Ok10, Ok11, Pol, Gend
    IniPath := A_Temp . "\gumvd.egl"
    Fio1 := fio
    Rank := rankVal
    Otdel := otdelVal
    Frak := frakVal
    Teg := tegVal
    Prop2 := prop2Val
    Gender := genderVal

    IniWrite, %fio%, %IniPath%, User, Fio1
    IniWrite, %rankVal%, %IniPath%, User, Rank
    IniWrite, %otdelVal%, %IniPath%, User, Otdel
    IniWrite, %frakVal%, %IniPath%, User, Frak
    IniWrite, %tegVal%, %IniPath%, User, Teg
    IniWrite, %prop2Val%, %IniPath%, User, Prop2
    IniWrite, %genderVal%, %IniPath%, User, Gender

    if (Gender = "Я девочка") {
        Vers = 2.5.0ж
        Ok1 = а
        Ok2 = ла
        Ok3 = ась
        Ok4 = цы
        Ok5 = ца
        Ok6 = це
        Ok7 = ла
        Ok8 = ела
        Ok9 = есла
        Ok10 = цей
        Ok11 = екла
        Pol = 👩‍✈️
        Gend = женский
    } else {
        Vers = 2.5.0м
        Ok1 =
        Ok2 =
        Ok3 = ся
        Ok4 = ка
        Ok5 = к
        Ok6 = ке
        Ok7 = ёл
        Ok8 = ёл
        Ok9 = ёс
        Ok10 = ком
        Ok11 = ёк
        Pol = 👨‍✈️
        Gend = мужской
    }
}

; =================================================================================================
; БАЗА ДАННЫХ СТАТЕЙ (УК РП / ФЗоП / КоАП)
; =================================================================================================
global ArticlesDB := []

InitArticlesDB() {
    global ArticlesDB
    ArticlesDB := []
    jsonPath := A_ScriptDir . "\assets\articles.json"
    if (!FileExist(jsonPath))
        return

    FileRead, jsonRaw, %jsonPath%
    if (jsonRaw = "")
        return

    ; Парсинг легковесным регулярным выражением
    Pos := 1
    While (Pos := RegExMatch(jsonRaw, "O)\{\s*""code""\s*:\s*""([^""]*)""\s*,\s*""num""\s*:\s*""([^""]*)""\s*,\s*""cmd""\s*:\s*""([^""]*)""\s*,\s*""fine""\s*:\s*([0-9]+)\s*,\s*""sanction""\s*:\s*""([^""]*)""\s*,\s*""desc""\s*:\s*""([^""]*)""\s*\}", m, Pos)) {
        Pos += m.Len
        c := m.1, n := m.2, cmd := m.3, f := m.4 + 0, s := m.5, d := m.6
        rawLines := ""
        if (InStr(d, "||"))
            rawLines := d
        else
            rawLines := "/me зачитал статью " . n . " " . c . "||/do " . SubStr(d, 1, 95)
        ArticlesDB.Push({ Code: c, Num: n, Cmd: cmd, Fine: f, Sanction: s, Desc: d, RawLines: rawLines })
    }
}

; =================================================================================================
; ТАЙМЕРЫ СМЕНЫ И ЧТЕНИЕ ЛОГА (DUTY & HUD)
; =================================================================================================
global ShiftStartTime := 0
global ShiftTimerActive := 0
global LiveShiftDuration := "00:00"
global LiveFinesCount := 0
global LiveArrestsCount := 0
global LiveForumPoints := 0
global DutyHudVisible := 0

InitTimersAndLogReader() {
    ShiftStartTime := A_TickCount
    ShiftTimerActive := 1
    SetTimer, UpdateDutyTimerTick, 1000
}

UpdateDutyTimerTick:
if (ShiftTimerActive) {
    elapsedSec := (A_TickCount - ShiftStartTime) // 1000
    m := elapsedSec // 60
    s := Mod(elapsedSec, 60)
    mStr := (m < 10) ? "0" . m : "" . m
    sStr := (s < 10) ? "0" . s : "" . s
    LiveShiftDuration := mStr . ":" . sStr
    if (DutyHudVisible)
        UpdateDutyHud()
}
Return

ToggleDutyHud() {
    global DutyHudVisible
    DutyHudVisible := !DutyHudVisible
    if (DutyHudVisible)
        ShowDutyHud()
    else
        Gui, 99:Hide
}

ShowDutyHud() {
    Gui, 99:Destroy
    Gui, 99:+AlwaysOnTop -Caption +ToolWindow +E0x20
    Gui, 99:Color, 0A0E17
    Gui, 99:Font, S10 C388BFD Bold, Segoe UI
    Gui, 99:Add, Text, x10 y6 w200 h20 vHudDutyText, ⏱ На смене: 00:00
    Gui, 99:Font, S9 CE6EDF3 Norm, Segoe UI
    Gui, 99:Add, Text, x10 y28 w200 h18 vHudStatsText, Аресты: 0 | Протоколы: 0
    WinSet, Transparent, 220, ahk_class AutoHotkeyGUI
    Gui, 99:Show, x20 y20 NoActivate, DutyHud
}

UpdateDutyHud() {
    global LiveShiftDuration, LiveArrestsCount, LiveFinesCount
    GuiControl, 99:Text, HudDutyText, % "⏱ На смене: " . LiveShiftDuration
    GuiControl, 99:Text, HudStatsText, % "Аресты: " . LiveArrestsCount . " | Протоколы: " . LiveFinesCount
}

; =================================================================================================
; ТАКТИЧЕСКИЕ ЗВУКИ РАЦИИ (RADIO SFX)
; =================================================================================================
global RadioSfxEnabled := 1
global LastBroadcastMessageId := ""

PlayRadioSfx(soundName) {
    global RadioSfxEnabled
    if (RadioSfxEnabled = 0)
        return
    soundPath := A_ScriptDir . "\assets\" . soundName
    if (!FileExist(soundPath))
        soundPath := A_ScriptDir . "\" . soundName
    if (!FileExist(soundPath))
        return
    ; 0x00020001 = SND_ASYNC (0x1) | SND_FILENAME (0x20000)
    res := DllCall("winmm\PlaySoundW", "WStr", soundPath, "Ptr", 0, "UInt", 0x00020001)
    if (!res) {
        SoundPlay, %soundPath%
    }
}

#If (OnlyInGameMode = 0 || WinActive("ahk_group ProvinceGameGroup"))
~*z::
if (RadioSfxEnabled) {
    PlayRadioSfx("radio_start.wav")
}
return

~*z Up::
if (RadioSfxEnabled) {
    PlayRadioSfx("radio_stop.wav")
}
return

~*b::
if (RadioSfxEnabled) {
    PlayRadioSfx("radio_start.wav")
}
return

~*b Up::
if (RadioSfxEnabled) {
    PlayRadioSfx("radio_stop.wav")
}
return

; Тестовый хоткей проверки звука рации (Ctrl + Alt + S)
^!s::
PlayRadioSfx("radio_start.wav")
Sleep, 300
PlayRadioSfx("radio_stop.wav")
TrayTip, 📻 Проверка рации ГУ МВД, Щелчок тангенты и Roger Beep работают исправно!, 3, 1
return
#If

; =================================================================================================
; КЛИЕНТСКИЙ ТЕЛЕМЕТРИЧЕСКИЙ ПУЛЬС В КОМАНДНЫЙ ЦЕНТР (ADMIN DASHBOARD)
; =================================================================================================
global TabletRelayHost := "http://152.234.229.245:3000"
global TabletRelayPin := "51"
global TabletRelayOnline := 0

InitClientHeartbeat() {
    SetTimer, SendClientHeartbeatTick, -2500
    SetTimer, SendClientHeartbeatTick, 60000
}

SendClientHeartbeatTick:
SendClientHeartbeat()
Return

GetClientHwid() {
    RegRead, guid, HKLM\SOFTWARE\Microsoft\Cryptography, MachineGuid
    if (guid = "" || ErrorLevel)
        guid := A_ComputerName . "-" . A_UserName
    return guid
}

SendClientHeartbeat() {
    global TabletRelayHost, Fio1, Rank, Teg, Prop2, Frak, Vers
    global LiveShiftDuration, LiveFinesCount, LiveArrestsCount, LiveForumPoints, LastBroadcastMessageId

    if (TabletRelayHost = "")
        TabletRelayHost := "http://152.234.229.245:3000"

    hwid := GetClientHwid()
    dutyStr := (LiveShiftDuration != "") ? LiveShiftDuration : "00:00"
    finesVal := (LiveFinesCount + 0)
    arrVal := (LiveArrestsCount + 0)
    ptsVal := (LiveForumPoints + 0)

    url := TabletRelayHost . "/api/client/heartbeat"

    payload := "{"
    payload .= """hwid"":""" . JsonEscapeStr(hwid) . ""","
    payload .= """rank"":""" . JsonEscapeStr(Rank) . ""","
    payload .= """fio"":""" . JsonEscapeStr(Fio1) . ""","
    payload .= """teg"":""" . JsonEscapeStr(Teg) . ""","
    payload .= """prop2"":""" . JsonEscapeStr(Prop2) . ""","
    payload .= """city"":""" . JsonEscapeStr(Frak) . ""","
    payload .= """service"":""ГУ МВД"","
    payload .= """version"":""" . JsonEscapeStr(Vers) . ""","
    payload .= """dutyClock"":""" . JsonEscapeStr(dutyStr) . ""","
    payload .= """finesCnt"":" . finesVal . ","
    payload .= """arrestsCnt"":" . arrVal . ","
    payload .= """forumPts"":" . ptsVal . ","
    payload .= """status"":""10-8"""
    payload .= "}"

    try {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", url, true) ; Асинхронно, без задержек и фризов игры
        whr.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
        whr.SetRequestHeader("User-Agent", "AHK-GUMVD/" . Vers)
        whr.Send(payload)
        if (whr.WaitForResponse(1.5)) {
            resp := whr.ResponseText
            if (InStr(resp, """broadcast"":{")) {
                RegExMatch(resp, "O)""id"":""([^""]+)"".*?""message"":""([^""]+)""", match)
                if (match && match.1 != LastBroadcastMessageId) {
                    LastBroadcastMessageId := match.1
                    msgText := StrReplace(match.2, "\n", "`n")
                    SoundPlay, %A_ScriptDir%\1.mp3
                    TrayTip, 📢 ОПОВЕЩЕНИЕ РУКОВОДСТВА ГУ МВД!, %msgText%, 8, 2
                }
            }
        }
    } catch e {
    }
}

TabletRelay_Init() {
    global TabletRelayHost, TabletRelayPin, Teg
    iniPath := A_Temp . "\gumvd.egl"
    IniRead, savedHost, %iniPath%, Tablet, RelayHost, http://152.234.229.245:3000
    if (savedHost != "" && savedHost != "ERROR")
        TabletRelayHost := savedHost
    IniRead, savedPin, %iniPath%, Tablet, Pin, ERROR
    if (savedPin = "" || savedPin = "ERROR") {
        TabletRelayPin := (Teg != "" && Teg != "ERROR") ? Teg : "51"
        IniWrite, %TabletRelayPin%, %iniPath%, Tablet, Pin
    } else {
        TabletRelayPin := savedPin
    }
}

; =================================================================================================
; FLUENT GLASS GUI (HTML5/CSS3/JS ACTIVEX INTERFACE)
; =================================================================================================
global FluentWB := ""
global FluentGuiHwnd := 0

SetBrowserEmulationIE11() {
    exeName := A_IsCompiled ? A_ScriptName : "AutoHotkeyU64.exe"
    try {
        RegWrite, REG_DWORD, HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION, %exeName%, 11001
        RegWrite, REG_DWORD, HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION, AutoHotkeyU64.exe, 11001
        RegWrite, REG_DWORD, HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION, AutoHotkeyU64_UIA.exe, 11001
    }
}

ShowFluentGUI() {
    global FluentWB, FluentGuiHwnd
    htmlPath := A_ScriptDir . "\assets\fluent_gumvd.html"
    if (!FileExist(htmlPath)) {
        MsgBox, 16, Ошибка, Файл интерфейса assets\fluent_gumvd.html не найден!
        Return
    }

    Gui, 1:Destroy
    Gui, 1:+Resize +MinSize980x640 +HWNDFluentGuiHwnd
    Gui, 1:Margin, 0, 0
    Gui, 1:Color, 0A0E17

    Gui, 1:Add, ActiveX, x0 y0 w1200 h750 vFluentWB, Shell.Explorer
    FluentWB.silent := true

    fileUrl := "file:///" . StrReplace(htmlPath, "\", "/")
    FluentWB.Navigate(fileUrl)

    while (FluentWB.readyState != 4 || FluentWB.busy)
        Sleep, 50

    try {
        doc := FluentWB.document
        doc.parentWindow.AhkBridge := new FluentBridgeClass()
        initDataJson := BuildFluentInitialJson()
        doc.parentWindow.receiveInitialData(initDataJson)
    }

    Gui, 1:Show, w1200 h750, 🚔 ГУ МВД РОССИИ — Fluent Police Command Center
}

class FluentBridgeClass {
    SaveProfile(fio, rankVal, otdelVal, frakVal, tegVal, prop2Val, genderVal) {
        SaveUserProfileData(fio, rankVal, otdelVal, frakVal, tegVal, prop2Val, genderVal)
        TrayTip, 📋 Личное дело сохранено, % "Сотрудник: " . fio . "`nЗвание: " . rankVal, 2, 1
    }

    RebindKey(hkId, newKey) {
        res := ApplyHotkeyRebind(hkId, newKey)
        if (res)
            TrayTip, ⌨️ Клавиша обновлена, % "Новое назначение: " . newKey, 2, 1
        return res
    }

    TriggerAction(act) {
        if (act = "test_radio") {
            PlayRadioSfx("radio_start.wav")
            Sleep, 300
            PlayRadioSfx("radio_stop.wav")
            TrayTip, 📻 Проверка рации, Сигнал Motorola APX и Roger Beep активны!, 2, 1
        } else if (act = "reload") {
            Reload
        } else if (act = "toggle_hud") {
            ToggleDutyHud()
        }
    }

    SpeakArticle(code) {
        global ArticlesDB
        for idx, art in ArticlesDB {
            if (art.Cmd = code || art.Num = code) {
                SetLocaleRu()
                SetCapsOff()
                Send, {F6}
                SmartSleep(250)
                Send, % art.RawLines
                SmartSleep(200)
                Send, {Enter}
                break
            }
        }
    }
}

BuildFluentInitialJson() {
    global Fio1, Rank, Otdel, Frak, Gender, Teg, Prop2, Vers, WinVerDescription, ActiveSendEngine
    global OnlyInGameMode, AutoScreenMode, HotkeyDefs, ArticlesDB, TabletRelayHost, TabletRelayPin, TabletRelayOnline

    heroPath := StrReplace(A_ScriptDir . "\assets\fluent_gumvd_hero.jpg", "\", "/")
    crestPath := StrReplace(A_ScriptDir . "\assets\fluent_gumvd_crest.jpg", "\", "/")
    telPath := StrReplace(A_ScriptDir . "\assets\fluent_gumvd_patrol_card.jpg", "\", "/")

    j := "{"
    j .= """assets"":{"
    j .= """hero"":""file:///" . JsonEscapeStr(heroPath) . ""","
    j .= """crest"":""file:///" . JsonEscapeStr(crestPath) . ""","
    j .= """telemetry"":""file:///" . JsonEscapeStr(telPath) . """"
    j .= "},"
    j .= """profile"":{"
    j .= """fio"":""" . JsonEscapeStr(Fio1) . ""","
    j .= """rank"":""" . JsonEscapeStr(Rank) . ""","
    j .= """otdel"":""" . JsonEscapeStr(Otdel) . ""","
    j .= """frak"":""" . JsonEscapeStr(Frak) . ""","
    j .= """teg"":""" . JsonEscapeStr(Teg) . ""","
    j .= """prop2"":""" . JsonEscapeStr(Prop2) . ""","
    j .= """gender"":""" . JsonEscapeStr(Gender) . ""","
    j .= """vers"":""" . JsonEscapeStr(Vers) . ""","
    j .= """winVer"":""" . JsonEscapeStr(WinVerDescription) . ""","
    j .= """sendEngine"":""" . JsonEscapeStr(ActiveSendEngine) . ""","
    j .= """onlyInGame"":" . (OnlyInGameMode ? 1 : 0) . ","
    j .= """autoScreen"":" . (AutoScreenMode ? 1 : 0) . ","
    j .= """relayUrl"":""" . JsonEscapeStr(TabletRelayHost) . ""","
    j .= """tabletPin"":""" . JsonEscapeStr(TabletRelayPin) . """"
    j .= "},"
    j .= """hotkeys"":["
    for idx, hk in HotkeyDefs {
        if (idx > 1)
            j .= ","
        curD := FormatHotkeyReadable(hk.CurrentKey)
        defD := FormatHotkeyReadable(hk.DefaultKey)
        j .= "{""id"":""" . JsonEscapeStr(hk.Id) . """,""name"":""" . JsonEscapeStr(hk.Name) . """,""cat"":""" . JsonEscapeStr(hk.Cat) . """,""rawKey"":""" . JsonEscapeStr(hk.CurrentKey) . """,""keyDisp"":""" . JsonEscapeStr(curD) . """,""defDisp"":""" . JsonEscapeStr(defD) . """}"
    }
    j .= "],"
    j .= """articles"":["
    for idx, art in ArticlesDB {
        if (idx > 1)
            j .= ","
        j .= "{""code"":""" . JsonEscapeStr(art.Code) . """,""num"":""" . JsonEscapeStr(art.Num) . """,""cmd"":""" . JsonEscapeStr(art.Cmd) . """,""fine"":" . art.Fine . ",""sanction"":""" . JsonEscapeStr(art.Sanction) . """,""desc"":""" . JsonEscapeStr(art.Desc) . """}"
    }
    j .= "]}"
    return j
}

JsonEscapeStr(str) {
    s := str
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, """", "\""")
    s := StrReplace(s, "`r", "")
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`t", " ")
    return s
}

GuiSize:
if (A_EventInfo != 1 && FluentWB) {
    GuiControl, Move, FluentWB, x0 y0 w%A_GuiWidth% h%A_GuiHeight%
}
Return

GuiClose:
Gui, 1:Hide
Return

RefreshTray() {
    Menu, Tray, NoStandard
    Menu, Tray, DeleteAll
    Menu, Tray, Add, 🚔 Открыть меню ГУ МВД, ShowFluentGUI
    Menu, Tray, Add, ⏱ Тактический HUD (Alt+H), ToggleDutyHud
    Menu, Tray, Add, 📻 Проверить звук рации (Ctrl+Alt+S), SfxTestMenu
    Menu, Tray, Add
    Menu, Tray, Add, 🔄 Перезагрузить биндер (Alt+R), Bind_Reload
    Menu, Tray, Add, ❌ Выход, ExitMenuHandler
    Menu, Tray, Default, 🚔 Открыть меню ГУ МВД
}

SfxTestMenu:
PlayRadioSfx("radio_start.wav")
Sleep, 300
PlayRadioSfx("radio_stop.wav")
Return

ExitMenuHandler:
ExitApp
Return

; =================================================================================================
; БОЕВЫЕ БИНДЫ, ОТЫГРОВКИ И ХОТКЕИ ГУ МВД
; =================================================================================================
Bind_Greeting:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Fio1, %A_Temp%\gumvd.egl, User, Fio1
IniRead, Rank, %A_Temp%\gumvd.egl, User, Rank
IniRead, Otdel, %A_Temp%\gumvd.egl, User, Otdel
IniRead, Frak, %A_Temp%\gumvd.egl, User, Frak
SmartSleep(250)
Send, {F8} say Здравия желаю, %Rank% полиции %Fio1%. {Enter}{F8}
SmartSleep(400)
Send, {F8} do На левом нагрудном кармане висит жетон «%Frak% | %Otdel%».{Enter}{F8}
Return

Bind_Udo:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} do Служебное удостоверение сотрудника ГУ МВД во внутреннем кармане куртки.{Enter}{F8}
SmartSleep(350)
Send, {F8} me достал%ok1% удостоверение из кармана и раскрыл%ok1% его в развернутом виде{Enter}{F8}
SmartSleep(350)
Send, {F8} do В удостоверении написано: %Frak%, %Rank% %Fio1%.{Enter}{F8}
SmartSleep(350)
Send, {F8} me показал%ok1% удостоверение гражданину в развернутом виде, затем убрал%ok1% обратно{Enter}{F8}
Return

Bind_AskDocs:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8} say Будьте добры, предъявите документ, удостоверяющий вашу личность.{Enter}{F8}
Return

Bind_TakeDocs:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8} me протянул%ok1% руку, затем взял%ok1% документы у гражданина{Enter}{F8}
SmartSleep(350)
Send, {F8} do Документы находятся в руках сотрудника полиции.{Enter}{F8}
Return

Bind_ReturnDocs:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8} me протянул%ok1% руку и вернул%ok1% документы гражданину напротив{Enter}{F8}
SmartSleep(350)
Send, {F8} say Спасибо за сотрудничество, держите ваши документы обратно.{Enter}{F8}
Return

Bind_Cuffs:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me резким движением снял%ok1% наручники БР-С с тактического пояса{Enter}{F8}
SmartSleep(300)
Send, {F8} me завел%ok1% руки подозреваемого за спину и защелкнул%ok1% наручники на запястьях{Enter}{F8}
SmartSleep(300)
Send, {F8} do Наручники плотно сомкнуты на запястьях задержанного.{Enter}{F8}
Return

Bind_Uncuffs:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me достал%ok1% ключ из кармана и вставил%ok1% в замок наручников{Enter}{F8}
SmartSleep(300)
Send, {F8} me повернул%ok1% ключ, снял%ok1% наручники и повесил%ok1% их обратно на пояс{Enter}{F8}
Return

Bind_Escort:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me заломил%ok1% руку нарушителя за спину и зафиксировал%ok1% болевым приемом{Enter}{F8}
SmartSleep(300)
Send, {F8} say Спокойно, без резких движений, следуйте впереди меня.{Enter}{F8}
Return

Bind_ReleaseHands:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me ослабил%ok1% захват и отпустил%ok1% руки гражданина{Enter}{F8}
Return

Bind_ProtocolSign:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8} say Вы задержаны по подозрению в совершении правонарушения.{Enter}{F8}
SmartSleep(350)
Send, {F8} say Разъясняю ваши права: Вы имеете право хранить молчание, право на один телефонный звонок и адвоката.{Enter}{F8}
SmartSleep(350)
Send, {F8} say Всё, что вы скажете, может быть использовано против вас в суде. Вам понятны ваши права?{Enter}{F8}
Return

Bind_TransferKpz:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8} me передал%ok1% задержанного конвоиру дежурной части для помещения в камеру{Enter}{F8}
SmartSleep(350)
Send, {F8} do Задержанный принят конвоем и препровожден в изолятор временного содержания.{Enter}{F8}
Return

Bind_SuFast:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}/su{Space}
Return

Bind_Wanted:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}/wanted{Enter}
Return

Bind_KpkOpen:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me достал%ok1% служебный планшетный компьютер МВД из чехла на поясе{Enter}{F8}
SmartSleep(300)
Send, {F8} do Планшет включен и подключен к единой защищенной базе МВД.{Enter}{F8}
Return

Bind_KpkPhoto:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me навел%ok1% объектив камеры планшета на лицо гражданина напротив{Enter}{F8}
SmartSleep(300)
Send, {F8} do Происходит сопоставление биометрии лица с федеральной базой розыска...{Enter}{F8}
SmartSleep(400)
Send, {F8} do Результат сопоставления выведен на экран планшета.{Enter}{F8}
Return

Bind_KpkClose:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me заблокировал%ok1% экран планшета и убрал%ok1% его в чехол на поясе{Enter}{F8}
Return

Bind_Putpl:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me открыл%ok1% дверь патрульного автомобиля и придерживая гражданина за голову посадил%ok1% в салон{Enter}{F8}
SmartSleep(300)
Send, {F8} me захлопнул%ok1% дверь автомобиля и заблокировал%ok1% замок{Enter}{F8}
Return

Bind_KpkPassport:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me вбил%ok1% серию и номер паспорта гражданина в базу данных МВД{Enter}{F8}
SmartSleep(300)
Send, {F8} do Идет получение информации о гражданине из центрального реестра...{Enter}{F8}
Return

Bind_OsnPatch:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Osn, %A_Temp%\gumvd.egl, User, Osn, ОСпН Гром
SmartSleep(200)
Send, {F8} do На тактическом бронежилете закреплена шеврон-нашивка «%Osn% ГУ МВД».{Enter}{F8}
Return

Bind_Pullout:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me резким движением распахнул%ok1% дверь автомобиля и вытащил%ok1% нарушителя наружу{Enter}{F8}
Return

Bind_TryDoor:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} try рывком дернул%ok1% ручку двери, пытаясь открыть автомобиль{Enter}{F8}
Return

Bind_TryGlass:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} try ударил%ok1% рукоятью оружия по боковому стеклу, пытаясь разбить его{Enter}{F8}
Return

Bind_UnlockIn:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} try просунул%ok1% руку через разбитое стекло и разблокировал%ok1% замок изнутри{Enter}{F8}
Return

Bind_Baton:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me резким движением выхватил%ok1% резиновую дубинку ПР-73 из поясного фиксатора{Enter}{F8}
SmartSleep(300)
Send, {F8} do Дубинка в боевом положении в правой руке сотрудника полиции.{Enter}{F8}
Return

Bind_Tazer:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me снял%ok1% электрошокер с предохранителя и извлек%ok1% из кобуры{Enter}{F8}
SmartSleep(300)
Send, {F8} do Электрошокер в боевой готовности в руке сотрудника.{Enter}{F8}
Return

Bind_ColleagueGreet:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me приложил%ok1% правую руку к головному убору и поприветствовал%ok1% коллегу{Enter}{F8}
SmartSleep(300)
Send, {F8} say Здравия желаю, товарищ полицейский!{Enter}{F8}
Return

Bind_Megaphone1:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, {F8} do Тангента СГУ закреплена на приборной панели патрульного автомобиля.{Enter}{F8}
SmartSleep(300)
Send, {F8} me снял%ok1% тангенту СГУ и нажал%ok1% кнопку вещания{Enter}{F8}
SmartSleep(300)
Send, {F8} m Водитель транспортного средства! Прижмитесь к обочине и остановитесь!{Enter}{F8}
SmartSleep(200)
PlayRadioSfx("radio_stop.wav")
Return

Bind_MegaphoneWay:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, {F8} m Водители! Примите вправо и уступите дорогу патрульному автомобилю со спецсигналами!{Enter}{F8}
SmartSleep(200)
PlayRadioSfx("radio_stop.wav")
Return

Bind_MegaphoneStop:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, {F8} s Гражданин, немедленно оставайтесь на месте! Работает полиция ГУ МВД!{Enter}{F8}
SmartSleep(200)
PlayRadioSfx("radio_stop.wav")
Return

Bind_VoiceOn:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} do Портативная рация ТАКТ-363 П45 закреплена на разгрузочном жилете.{Enter}{F8}
SmartSleep(300)
Send, {F8} me снял%ok1% рацию, поднес%ok2% ко рту и зажал%ok1% тангенту передачи{Enter}{F8}
SmartSleep(150)
PlayRadioSfx("radio_start.wav")
SmartSleep(150)
Send, {F8} fracvoice 1{Enter}{F8}
Return

Bind_VoiceOff:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F8} me отпустил%ok1% тангенту, перевел%ok1% рацию в режим приема и закрепил%ok1% на разгрузке{Enter}{F8}
SmartSleep(150)
PlayRadioSfx("radio_stop.wav")
SmartSleep(150)
Send, {F8} fracvoice 2{Enter}{F8}
Return

Bind_ToggleHud:
ToggleDutyHud()
Return

Bind_OpenCalc:
ShowFluentGUI()
Return

Bind_Reload:
TrayTip, 🔄 Перезагрузка, АХК ГУ МВД перезагружается..., 1, 1
Sleep, 500
Reload
Return

Bind_Pause:
AbortBindFlag := 1
SoundBeep, 650, 150
TrayTip, ⛔ Остановка биндера, Текущая отыгровка экстренно остановлена!, 2, 2
Return

; =================================================================================================
; ПОЛНАЯ БАЗА РОЛЕВЫХ ХОТСТРИНГОВ И СПЕЦИАЛЬНЫХ ОТЫГРОВОК ГУ МВД
; =================================================================================================
!1::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Fio1, %A_Temp%\gumvd.egl, User, Fio1
IniRead, Rank, %A_Temp%\gumvd.egl, User, Rank
IniRead, Frak, %A_Temp%\gumvd.egl, User, Frak
IniRead, Otdel, %A_Temp%\gumvd.egl, User, Otdel
Sleep 250
SendInput, {F8}animarmy 3{ENTER}{F8}
Sleep 250
SendInput, {F8} say Здравия желаю, %Otdel% %Frak%, %Rank% полиции, %Fio1%.{Enter}{F8}
Sleep 500
if (Rank = "Рядовой") {
    PogonDescription := "пустые погоны"
    RankDescription := "На плечах закреплены пустые погоны."
} else if (Rank = "Сержант") {
    PogonDescription := "погоны с тремя лычками поперек погон"
    RankDescription := "На плечах закреплены погоны с тремя лычками поперек погон."
} else if (Rank = "Старшина") {
    PogonDescription := "погоны с одной лычкой вдоль погон"
    RankDescription := "На плечах погоны с одной лычкой вдоль погон."
} else if (Rank = "Прапорщик") {
    PogonDescription := "погоны с двумя звездами вдоль погон"
    RankDescription := "На плечах погоны с двумя звездами вдоль по он."
} else if (Rank = "Лейтенант") {
    PogonDescription := "погоны с двумя звездами и просветом"
    RankDescription := "На плечах погоны с двумя звездами и просветом."
} else if (Rank = "Старший лейтенант") {
    PogonDescription := "погоны с тремя звездами и просветом"
    RankDescription := "На плечах погоны с тремя звездами и просветом."
} else if (Rank = "Капитан") {
    PogonDescription := "погоны с четырьмя звездами и просветом"
    RankDescription := "На плечах погоны с четырьмя звездами и просветом."
} else if (Rank = "Майор") {
    PogonDescription := "погоны с одной звездой и двумя просветами"
    RankDescription := "На плечах погоны с одной звездой и двумя просветами."
} else if (Rank = "Подполковник") {
    PogonDescription := "погоны с двумя звездами и двумя просветами"
    RankDescription := "На плечах погоны с двумя звездами и двумя просветами."
} else if (Rank = "Полковник") {
    PogonDescription := "погоны с тремя звездами и двумя просветами"
    RankDescription := "На плечах погоны с тремя звездами и двумя просветами."
} else if (Rank = "Генерал-майор") {
    PogonDescription := "погоны с одной большой звездой"
    RankDescription := "На плечах погоны с одной большой звездой."
} else if (Rank = "Генерал-лейтенант") {
    PogonDescription := "погоны с двумя большими звездами"
    RankDescription := "На плечах погоны с двумя большими звездами."
} else if (Rank = "Генерал-полковник") {
    PogonDescription := "погоны с тремя большими звездами"
    RankDescription := "На плечах погоны с тремя большими звездами."
} else if (Rank = "Генерал МВД") {
    PogonDescription := "погоны с одной большой звездой и гербом МВД"
    RankDescription := "На плечах погоны с одной большой звездой и гербом МВД."
}
if PogonDescription
{
Sleep 500
SendInput, {F8}do На плечах %PogonDescription%.{Enter}{F8}
}
Sleep 500
Return
^1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /Кому показать удо? ID ->{Space}
Input, id, V, {Enter}
SendInput, {bs 17}
SendInput, {enter}
Sleep 500
SendInput, {F8}ud %id%{Enter}{F8}
Return
^2::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput,{F8} say Передайте ваш паспорт для установления личности.{Enter}{F8}
Sleep 500
SendInput,{F8} b /me передал(-а) паспорт{Enter}{F8}
Sleep 500
SendInput,{F8}b /pass id (id = цифры после ника){Enter}{F8}
Return
^3::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput,{F8}me протянул%ok1% правую руку и взял%ok1% документы гражданина{Enter}{F8}
Sleep 500
SendInput,{F8}me детально изучил%ok1% документы гражданина{Enter}{F8}
Sleep 500
SendInput,{F8}do Документы изучены сотрудни%ok10%.{Enter}{F8}
Return
^4::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput,{F8} me протянул%ok1% гражданину документы{Enter}{F8}
Sleep 500
SendInput,{F8} say Уважаемый, держите ваши документы.{Enter}{F8}
Sleep 500
SendInput,{F8} b /me забрал(-а) документы{Enter}{F8}
Return
^5::
SendMessage, 0x50,, 0x4190419,, A
Sleep 100
SendInput,{5}
Sleep 250
SendInput,{F8}say Гражданин, Вы имеете право хранить молчание{!}{Enter}{F8}
Sleep 500
SendInput,{F6}
Sleep 100
SendInput,/cuff{Space}
Return
^6::
SendMessage, 0x50,, 0x4190419,, A
Sleep 500
SendInput,{F6}
Sleep 100
SendInput,/uncuff{Space}
Return
^7::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput,{F8}me заломал%ok1% гражданина и повел%ok1% за собой{Enter}{F8}
Sleep 50
Sleep 100
SendInput,{F6}
Sleep 100
SendInput,/arr{Space}
Return
^8::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput,{F8}me отпустил%ok1% руки задержанного{Enter}{F8}
Sleep 50
SendInput,{F6}
Sleep 100
SendInput,/dearr{Space}
Return
^9::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Гражданин, сейчас мы составим протокол Вашего задержания.{Enter}{F6}
Sleep 2000
SendInput, /do Бланки протокола с ручкой лежат в сумке на плече сотрудника.{Enter}{F6}
Sleep 2000
SendInput, /me открыл%ok1% сумку и достал%ok1% бланк протокола с ручкой{Enter}{F6}
Sleep 2000
SendInput, /me взял%ok1% ручку и начал%ok1% заполнять протокол{Enter}{F6}
Sleep 2000
SendInput, /me заполнил%ok1% личные данные{Enter}{F6}
Sleep 2000
SendInput, /me заполнил%ok1% статью нарушенную гражданином{Enter}{F6}
Sleep 2000
SendInput, /me поставил%ok1% дату и подпись{Enter}{F6}
Sleep 2000
SendInput, /me отстегнул%ok1% одну руку задержанного и пристегнул%ok1% браслет наручников к ручке автомобиля{Enter}{F6}
Sleep 2000
SendInput, /todo Подписывать будете?*передавая протокол с ручкой задержанному{Enter}{F6}
Sleep 2000
SendInput, /b Если да, то отыграйте /me расписался в протоколе{Enter}
Return

:?:/протоколдч::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Гражданин, сейчас мы составим протокол Вашего задержания.{Enter}{F6}
Sleep 2000
SendInput, /do Бланки протокола с ручкой лежат в сумке на плече сотрудника.{Enter}{F6}
Sleep 2000
SendInput, /me открыл%ok1% сумку и достал%ok1% бланк протокола с ручкой{Enter}{F6}
Sleep 2000
SendInput, /me взял%ok1% ручку и начал%ok1% заполнять протокол{Enter}{F6}
Sleep 2000
SendInput, /me заполнил%ok1% личные данные{Enter}{F6}
Sleep 2000
SendInput, /me заполнил%ok1% статью нарушенную гражданином{Enter}{F6}
Sleep 2000
SendInput, /me поставил%ok1% дату и подпись{Enter}{F6}
Sleep 2000
SendInput, /do На стене рядом с сотрудником установлен фиксатор для наручников.{Enter}{F6}
Sleep 2000
SendInput, /me отстегнул%ok1% одну руку задержанного и пристегнул%ok1% её к фиксатору на стене{Enter}{F6}
Sleep 2000
SendInput, /todo Подписывать будете?*передавая протокол с ручкой задержанному{Enter}{F6}
Sleep 2000
SendInput, /b Если да, то отыграйте /me расписался в протоколе{Enter}
Return

:?:/протокол1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me забрал%ok1% и ручку протокол у задержанного{Enter}{F6}
Sleep 2000
SendInput, /do Протокол составлен.{Enter}{F6}
Sleep 2000
SendInput, /me отстегнул%ok1% наручники от ручки и снова пристегнул%ok1% их на запястье задержанного{Enter}{F6}
Sleep 2000
SendInput, /me вырвал%ok1% копию протокола{Enter}{F6}
Sleep 2000
SendInput, /me положил%ok1% копию в карман гражданина{Enter}{F6}
Sleep 2000
SendInput, /do Копия лежит в кармане.{Enter}
Return
:?:/протокол2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me забрал%ok1% и ручку протокол у задержанного{Enter}{F6}
Sleep 2000
SendInput, /me поставил%ok1% метку об отказе в подписании{Enter}{F6}
Sleep 2000
SendInput, /do Протокол составлен.{Enter}{F6}
Sleep 2000
SendInput, /me отстегнул%ok1% наручники от ручки и снова пристегнул%ok1% их на запястье задержанного{Enter}{F6}
Sleep 2000
SendInput, /me вырвал%ok1% копию протокола{Enter}{F6}
Sleep 2000
SendInput, /me положил%ok1% копию в карман гражданина{Enter}{F6}
Sleep 2000
SendInput, /do Копия лежит в кармане.{Enter}
Return
:?:/протоколдч1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me забрал%ok1% и ручку протокол у задержанного{Enter}{F6}
Sleep 2000
SendInput, /do Протокол составлен.{Enter}{F6}
Sleep 2000
SendInput, /me отстегнул%ok1% наручники от фиксатора и снова пристегнул%ok1% их на запястье задержанного{Enter}{F6}
Sleep 2000
SendInput, /me вырвал%ok1% копию протокола{Enter}{F6}
Sleep 2000
SendInput, /me положил%ok1% копию в карман гражданина{Enter}{F6}
Sleep 2000
SendInput, /do Копия лежит в кармане.{Enter}
Return
:?:/протоколдч2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me забрал%ok1% и ручку протокол у задержанного{Enter}{F6}
Sleep 2000
SendInput, /me поставил%ok1% метку об отказе в подписании{Enter}{F6}
Sleep 2000
SendInput, /do Протокол составлен.{Enter}{F6}
Sleep 2000
SendInput, /me отстегнул%ok1% наручники от фиксатора и снова пристегнул%ok1% их на запястье задержанного{Enter}{F6}
Sleep 2000
SendInput, /me вырвал%ok1% копию протокола{Enter}{F6}
Sleep 2000
SendInput, /me положил%ok1% копию в карман гражданина{Enter}{F6}
Sleep 2000
SendInput, /do Копия лежит в кармане.{Enter}
Return

^0::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /Введите ID гражданина которого хотите посадить ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, Пора Вас конвоиру передавать. Свои вещи заберете у конвоира. {Enter}{F6}
Sleep 500
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500
SendInput, /me сняв рацию, поднёс%ok2% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
SendInput, /me вызвал%ok1% конвоира{Enter}{F6}
Sleep 500
SendInput, /do Конвоир вызван.{Enter}{F6}
Sleep 500
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}{F6}
Sleep 550
SendInput, /me открыл%ok1% дверь и передал%ok1% задержанного конвоиру{Enter}{F6}
Sleep 550
SendInput, /say Уведите задержанного.{Enter}{F6}
Sleep 550
SendInput, /do Конвоир увел задержанного.{Enter}{F6}
Sleep 500
SendInput, /r Задержанный был передан конвоиру. Протокол задержания передан в канцелярию.{Enter}{F6}
Sleep 500
SendInput, /arrest %Var1% {Enter}
Return
^-::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput,{F8} do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F8} 
Sleep 50
SendInput,{F8} me снял%ok1% рацию, затем связался с диспетчером и передал%ok1% ориентировку на гражданина{Enter}{F8} 
Sleep 50
SendInput,{F6}
Sleep 100
SendInput,/su{Space}
Return
^F9::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput,{F8}me открыл%ok1% базу данных сотрудников управления{Enter}{F8}
Sleep 100
SendInput,{F8}do База данных сотрудников управления открыта.{Enter}{F8}
Sleep 100
SendInput,{F8}find{Enter}{F8}
Return
^F10::
SendMessage, 0x50,, 0x4190419,, A
Sleep 500
SendInput,{F8} do Служебный планшет марки “MIG LT11i” в кармане.{Enter}{F8}
Sleep 250
SendInput,{F8} me достав служебный планшет из кармана, запустил%ok1% его{Enter}{F8}
Sleep 150
SendInput,{F8} me открыл%ok1% базу данных видеонаблюдения{Enter}{F8}
Sleep 150
SendInput,{F8} do Изображение с камер транслируются в реальном времени на служебный планшет.{Enter}{F8}
Sleep 250
SendInput,{F8} me выключил%ok1% служебный планшет и убрал%ok1% в карман{Enter}{F8}
Sleep 250
SendInput,{F8} do Служебный планшет марки “MIG LT11i” в кармане.{Enter}{F8}
Sleep 150
SendMessage, 0x50,, 0x4090409,, A
SendInput,{F8}wanted{Enter}{F8}
Return
^insert::
SendMessage, 0x50,, 0x4190419,, A
SendInput,{F8} do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F8}
Sleep 10
SendInput,{F8} me сняв рацию, поднес%ok2% её ко рту и нажал%ok1% кнопку для переговоров{Enter}{F8}
sleep 100
PlayRadioSfx("radio_start.wav")
Sleep 10
SendInput,{F8} fracvoice 1{Enter}{F8}
Return
^home::
SendMessage, 0x50,, 0x4190419,, A
SendInput,{F8} me перевел%ok1% рацию в режим прослушивания и закрепил%ok1% на нагрудном кармане{Enter}{F8}
sleep 100
PlayRadioSfx("radio_start.wav")
Sleep 100
SendInput,{F8} do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F8}
Sleep 100
SendInput,{F8} fracvoice 2{Enter}{F8}
Return
!0::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput, {F8} do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
Sleep 10
SendInput, {F8} me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
Sleep 10
SendInput, {F8} m {#}7ae70dВодитель, принимаем крайнее правое положение и останавливаемся{!}{Enter}{F8}
Sleep 10
SendInput, {F8} me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return
!-::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput, {F8} do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
Sleep 10
SendInput, {F8} me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
Sleep 10
SendInput, {F8} m {#}e7950dПовторяю, водитель, примите вправо и остановитесь{!}{Enter}{F8}
Sleep 10
SendInput, {F8} me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return
!=::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput, {F8} do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
Sleep 10
SendInput, {F8} me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
Sleep 10
SendInput, {F8} m {#}e74c3cОстанавливайтесь{!} В случае отказа откроем огонь{!}{Enter}{F8}
Sleep 10
SendInput, {F8} me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return
!9::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput, {F8}do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
Sleep 10
SendInput, {F8}me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
Sleep 10
SendInput, {F8}m {#}e7950dУступите проезд спец. транспорту{!}{Enter}{F8}
Sleep 10
SendInput, {F8}me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return
!8::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput, {F8}s Гражданин останавливаемся, в противном случае к вам будет применена физическая сила{!}{Enter}{F8}
Return
!2::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
IniRead, Otdel, %A_Temp%\gumvd.egl, User, Otdel
IniRead, Prop1, %A_Temp%\gumvd.egl, User, Prop1
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
IniRead, Frak, %A_Temp%\gumvd.egl, User, Frak
IniRead, Osnxxx, %A_Temp%\gumvd.egl, User, Osnxxx
IniRead, Dolznosn, %A_Temp%\gumvd.egl, User, Dolznosn
SendInput, {F8}do На бронежилете нашивка: || [%Osnxxx%-%Prop2%] || Позывной: %Prop1%. [%Frak%].{Enter}{F8}
Return
!3::
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F6}
Sleep 400
SendInput, /do Служебный планшет марки “MIG LT11i” в кармане. {Enter}{F6}
Sleep 400
SendInput, /me достав служебный планшет из кармана, запустил%ok1% его {Enter}
Sleep 400
Return
:?:/sos::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /Введите местоположение ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 150 ;
SendInput, /do Тревожная кнопка с GPS маячком в нагрудном кармане.{Enter}{F6}
Sleep 150 ;
SendInput, /me нажал%ok1% тревожную кнопку{Enter}{F6}
Sleep 150 ;
SendInput, /do Тревожная кнопка активирована. GPS маячок передает местоположение сотрудника.{Enter}{F6}
Sleep 150 ;
SendInput, /ro [Кнопка SOS][МВД] Местонахождение:%var1%{Enter}
Return
:?:/маска::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me сняв маску с гражданина, положил%ok1% её в карман задержанного{Enter}{F6}
Sleep 250
SendInput, /do Маска снята.{Enter}
Return
:?:/убор::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me снял%ok1% головной убор с гражданина{Enter}{F6}
Sleep 250
SendInput, /do Головной убор снят.{Enter}
Return
:?:/очки::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me сняв очки с гражданина, положил%ok1% их в карман задержанного{Enter}{F6}
Sleep 250
SendInput, /do Очки сняты.{Enter}
Return
:?:/шлем::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me сняв шлем с гражданина, положил%ok1% его на колени гражданина{Enter}{F6}
Sleep 250
SendInput, /do Шлем снят.{Enter}
Return
:?:/вытащить::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me вытащил%ok1% задержанного из служебного автомобиля{Enter}
Return
^r::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me вытащил%ok1% гражданина из автомобиля{Enter}
Return
^E::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200 ;
SendInput, Здравия желаю{!}{Enter}{F6}
Sleep 200 ;
SendInput, /animarmy 3{Enter}
Return
:?:/п1::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-0-1 Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/п2::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-0-2 Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/п3::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-0-3 Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/п1н::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
SendInput, {F6}
Sleep 250
SendInput, /Введите звание напарника ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /Введите фамилию напарника ->{Space}
Input, Var2, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-0-1 Код-3 Напарник: %Var1% %Var2%{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/п2н::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
SendInput, {F6}
Sleep 250
SendInput, /Введите звание напарника ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /Введите фамилию напарника ->{Space}
Input, Var2, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-0-2 Код-3 Напарник: %Var1% %Var2%{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/п3н::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
SendInput, {F6}
Sleep 250
SendInput, /Введите звание напарника ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /Введите фамилию напарника ->{Space}
Input, Var2, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-0-3 Код-3 Напарник: %Var1% %Var2%{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/кпп1::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-1-1 КПП Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/кпп2::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-1-2 КПП Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/кпп3::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-1-3 КПП Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/дч1::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-1-1 Дежурная часть Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/дч2::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput,  /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput,  /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-1-2 Дежурная часть Код-3{Enter}{F6}
Sleep 200 ;
SendInput,  /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter} 
Return
:?:/дч3::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput,  /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput,  /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-1-3 Дежурная часть Код-3{Enter}{F6}
Sleep 200 ;
SendInput,  /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
!4::
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F6}
Sleep 500
SendInput, Сейчас определим вашу личность.{Enter}{F6}
Sleep 500
SendInput, /me сделал%ok1% фотографию гражданина и запросил%ok1% данные{Enter}{F6}
Sleep 500
SendInput, /do Данные гражданина выведены на экран служебного планшета.{Enter}{F6}
Sleep 500
SendInput, Ваша личность установлена.{Enter}{F6}
Sleep 500
SendMessage, 0x50,, 0x4090409,, A
SendInput, /wanted {Enter}{F6}
Sleep 500
SendInput, /crimrec{Space}
Return
!5::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 150
SendInput, /me выключил%ok1% служебный планшет и убрал%ok1% в карман{Enter}{F6}
Sleep 150
SendInput, /do Служебный планшет марки MIG LT11i в кармане.{Enter}
Return
:?:/в1::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 200 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 200 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-24{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/в2::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 200 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 200 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-25{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/в+::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 200 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 200 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-26{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/в-::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 200 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 200 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-26ЛВ{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/метка1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200 ;
SendInput, /me поставил метку о несогласии{Enter}
Return
:?:/метка2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200 ;
SendInput, /me поставил метку о невозможности подписать протокол{Enter}
Return
:?:/копия::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me вырвал копию протокола и положил на колени гражданина{Enter}
RETURN
!x::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /s Из машины, руки на капот{!}{Enter}
Return
:?:/чист1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 500
SendInput, /do На столе лежит стопка пустых бланков.{Enter}{F6}
Sleep 500
SendInput, /me взяв бланк, закрепил%ok1% его в планшетке{Enter}{F6}
Sleep 500
SendInput, /do Ручка на столе.{Enter}{F6}
Sleep 500
SendInput, /me взяв ручку, начал%ok1% записывать случившееся{Enter}{F6}
Sleep 500
SendInput, Гражданин, рассказывайте, что произошло.{Enter}
Return
:?:/чист2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 500
SendInput, Передайте документ удостоверяющий вашу личность.{Enter}
Return
:?:/чист3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 500
SendInput, /me записал%ok1% данные гражданина{Enter}{F6}
Sleep 500
SendInput, /me записал%ok1% дату и поставил%ok1% подпись{Enter}{F6}
Sleep 500
SendInput, /do Бланк заполнен.{Enter}{F6}
Sleep 500
SendInput, /do Ручка лежит на столе.{Enter}{F6}
Sleep 500 
SendInput, /me взяв ручку со стола, протянул%ok1% ее вместе с бланком{Enter}{F6}
Sleep 500
SendInput, Распишитесь в нижнем углу.{Enter}{F6}
Sleep 500
SendInput, /b /me расписался в бланке{Enter}
Return
:?:/чист4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 500
SendInput, /me взял%ok1% ручку с бланком{Enter}{F6}
Sleep 500
SendInput, /do Ручка с бланком в руке.{Enter}{F6}
Sleep 500
SendInput, /me вытащив бланк из планшетки, положил%ok1% его в стопку с бланками{Enter}{F6}
Sleep 500
SendInput, /do Бланк лежит в стопке бланков.{Enter}
Return
:?:/чист5::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 500
SendInput, Гражданин, ваше чистосердечное заявление принято, далее отправим вас в КПЗ.{Enter}
Sleep 500
SendInput,{5}
Return
:?:/чист6::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 500
SendInput, /Введите ID гражданина которого хотите посадить ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 500
SendInput, {F6}
Sleep 500
SendInput, Пора Вас посадить в КПЗ. Свои вещи заберете у дежурного.{Enter}{F6}
Sleep 500
SendInput, /do Ключи от двери КПЗ в кармане.{Enter}{F6}
Sleep 500
SendInput, /me достав ключи, открыл%ok1% дверь КПЗ{Enter}{F6}
Sleep 500
SendInput, /me завел задержанного в клетку, затем закрыл%ok1% дверь КПЗ{Enter}{F6}
Sleep 500
SendInput, /me убрал%ok1% ключи в карман{Enter}{F6}
Sleep 500
SendInput, /r Задержанный был отправлен в КПЗ. Протокол задержания передан в канцелярию.{Enter}{F6}
Sleep 500
SendInput, /arrest %Var1% {Enter}
Return
:?:/предосн::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {Enter}
Sleep 2000
SendInput, {F8}s Мордой в пол, работает %Osn%{!}{Enter}{F8}
Return
:?:/фзоп912::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, По статье 3.9.1.2 ФЗоП сотрудник МВД имеет право:проверять документы граждан,{Enter}{F6}
Sleep 1000  ;
SendInput, если имеются данные, дающие основания подозревать их в совершении{Enter}{F6}
Sleep 1000 ;
SendInput, преступления или полагать, что они находятся в розыске.{Enter}
Sleep 1000 ;
Return
:?:/кейс::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {Enter}
Sleep 1400
SendInput, {F8}do В багажнике лежит кейс.{Enter}{F8}
Sleep 600
SendInput, {F8}do Правый подсумок висит на поясе.{Enter}{F8}
Sleep 600
SendInput, {F8}me потянул%ok3% к правому подсумку, затем открыл%ok1% его и достал%ok1% GPS чип{Enter}{F8}
Sleep 600
SendInput, {F8}me аккуратным движением вшил%ok1% чип в верхней части кейса, затем достал%ok1% ещё один и вшил%ok1% в нижнюю часть кейса{Enter}{F8}
Sleep 600
SendInput, {F8}do GPS чипы вшиты в кейс.{Enter}{F8}
Sleep 600
SendInput, {F8}me открыл%ok1% кейс{Enter}{F8}
Sleep 600
SendInput, {F8}do В правом углу багажника лежат купюры по 5 тысяч в сумме 100.000 рублей. {Enter}{F8}
Sleep 600
SendInput, {F8}do В правом углу багажника лежат фальшивые купюры по 5 тысяч.{Enter}{F8}
Sleep 600
SendInput, {F8}me положил%ok1% сперва 30 процентов фальшивых купюр, а затем 70 процентов настоящих{Enter}{F8}
Sleep 600
SendInput, {F8}me закрыл%ok1% кейс и взял%ok1% его в руки{Enter}{F8}
Sleep 600
SendInput, {F8}do Кейс в руке.{Enter}{F8}
Return

:?:/взрыв1::
SendMessage, 0x50,, 0x4190419,, A
Sleep 100
SendInput, {Enter}
Sleep 1400
SendInput, {F8}do Набор сапёра находится в левом подсумке закреплённого на поясе.{Enter}{F8}
Sleep 100
SendInput, {F8}me открыл%ok1% левый подсумок и достал%ok1% отвёртку{Enter}{F8}
Sleep 100
SendInput, {F8}me на корпусе взрывного устройства наш%ok7% болты удерживающие крышку{Enter}{F8}
Sleep 100
SendInput, {F8}me начал%ok1% откручивать болты и аккуратно снял%ok1% крышку с устройства{Enter}{F8}
Sleep 100
SendInput, {F8}me наш%ok7% 3 провода ведущие к таймеру, детонатору и к устройству{Enter}{F8}
Sleep 100
SendInput, {F8}me достал%ok1% с подсумка щипцы{Enter}{F8}
Sleep 100
SendInput, {F8}do Щипцы в правой руке.{Enter}{F8}
Sleep 100
SendInput, {F8}me аккуратным движением левой руки взял%ok3% за провод ведущий к таймеру{Enter}{F8}
Sleep 100
SendInput, {F8}me перерезал%ok1% провод ведущий к таймеру{Enter}{F8}
Sleep 100
SendInput, {F8}me левой рукой приподнял%ok1% провода ведущие к детонатору и устройству{Enter}{F8}
Sleep 100
SendInput, {F8}me перерезал%ok1% провод ведущий к детонатору и устройству{Enter}{F8}
Return

:?:/взрыв2::
SendMessage, 0x50,, 0x4190419,, A
Sleep 100
SendInput, {Enter}
Sleep 1400
SendInput, {F8}do В багажнике автомобиля лежит специальный кейс для перевозки взрывных устройств. {Enter}{F8}
Sleep 100
SendInput, {F8}me достал%ok1% кейс и положил%ok1% его на пол, затем открыл%ok1% его{Enter}{F8}
Sleep 100
SendInput, {F8}me аккуратными движениями рук взял%ok1% взрывное устройство и положил%ok1% его в кейс{Enter}{F8}
Sleep 100
SendInput, {F8}me закрыл%ok1% кейс и положил%ok1% в багажник{Enter}{F8}
Sleep 100
SendInput, {F8}do Кейс лежит в багажнике.{Enter}{F8}
Return

!F12::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me дёрнул%ok1% за ручку двери{Enter}{F6}
Sleep 100
SendInput, /do Сотрудни%ok5% пытается открыть дверь.{Enter}{F6}
Sleep 100 ;
SendInput, /try открыл%ok1% дверь{Enter}
Return
!printscreen::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me замахнул%ok3% дубинкой и ударил%ok1% по стеклу{Enter}{F6}
Sleep 100 ;
SendInput, /try разбил%ok1% стекло дубинкой{Enter}
Return 
!scrolllock::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me потянул%ok3% рукой до замка и открыл%ok1% его изнутри{Enter}{F6}
Sleep 100
SendInput, /do Замок открыт.{Enter}{F6}
Sleep 100
SendInput, /me открыл%ok1% дверь и вытащил%ok1% гражданина из машины{Enter}
Return
!6::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Берегите голову при посадке в автомобиль{!}{Enter}{F6}
Sleep 500
SendInput, /me взял%ok1% нарушителя за руки и посадил%ok1% в служебный автомобиль{Enter}
Sleep 500
Return
!7::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me открыл%ok1% базу данных нарушителей{Enter}{F6}
Sleep 250
SendInput, /me ввел%ok1% данные гражданина в базу и нажал%ok1% кнопку "Запросить"{Enter}{F6}
Sleep 250
SendInput, /do Информация о гражданине высветилась на экране.{Enter}{F6}
Sleep 500
SendMessage, 0x50,, 0x4090409,, A
SendInput, /wanted {Enter}{F6}
Sleep 500
SendInput, /crimrec{Space}
Return
:?:/код1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /Введите местоположение ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 200 ;
SendInput,  /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput,  /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][МВД] Код-1 Местоположение:%var1%{Enter}{F6}
Sleep 500 ;
SendInput,  /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}{F6}
Return
:?:/код0::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /Введите местоположение ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput, /d [ГУ МВД-%Bukv%][МВД][МО] Код-0 Местоположение:%var1%{Enter}{F6}
Sleep 500 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/рег1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do Видеорегистратор закреплен на лобовом стекле.{Enter}{F6}
Sleep 250
SendInput, /me снял%ok1% видеорегистратор с крепления{Enter}
Return
:?:/рег2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me открыл%ok1% нужный файл и подготовил%ok1% его к просмотру{Enter}{F6}
Sleep 250
SendInput, /me повернув видеорегистратор в сторону гражданина, запустил%ok1% запись{Enter}
Return
:?:/рег3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me выключил%ok1% воспроизведение видеофайла{Enter}
Return
:?:/рег4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me закрепил%ok1% видеорегистратор на крепление{Enter}
Return
:?:/ор1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /Введите Имя Фамилию человека в розыске ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /do Служебный планшет марки “MIG LT11i” в сумке.{Enter}{F6}
Sleep 250
SendInput, /me достав служебный планшет из сумки, запустил%ok1% его{Enter}{F6}
Sleep 250
SendInput, /me открыл%ok1% базу данных нарушителей{Enter}{F6}
Sleep 250
SendInput, /do База данных нарушителей открыта.{Enter}{F6}
Sleep 500
SendInput, /me ввел%ok1% данные в базу и нажал%ok1% кнопку "Запросить"{Enter}{F6}
Sleep 500
SendInput, /do На экране высветилась ориентировка.{Enter}{F6}
Sleep 500
SendInput, /me повернул%ok1% служебный планшет экраном к гражданину{Enter}{F6}
Sleep 500
SendInput, /do На экране ориентировка на гражданина "%Var1%".{Enter}
sleep 500
Return
:?:/лекция1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Рация".{Enter}{F6}
Sleep 2000 ;
SendInput, Рация это источник связи с коллегами полиции,{Enter}{F6}
Sleep 2000 ;
SendInput, Для передачи важной информации.{Enter}{F6}
Sleep 2000 ;
SendInput, В рации звучит такая информация, как доклады с патруля и тому подобное.{Enter}{F6}
Sleep 2000 ;
SendInput, В рации запрещены всякие оскорбления, мат, угрозы.{Enter}{F6}
Sleep 2000 ;
SendInput, В рацию запрещено сообщать бессмысленные сообщения.{Enter}{F6}
Sleep 2000 ;
SendInput, /b Запросы по форме [От-кого] [К кому] *Суть запроса".{Enter}{F6}
Sleep 2000 ;
SendInput,  /b Пример запроса [ГУ МВД-Н] [УГИБДД] Требуется экипаж к стройке Приволжска.{Enter}{F6}
Sleep 2000
SendInput, Для передачи важной информации.{Enter}{F6}
Sleep 2000 ;
SendInput, За нарушение данных правил вы будете наказаны.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, У кого есть вопросы по этой лекции? {Enter}
Return
:?:/лекция2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00«Субординация».{Enter}{F6}
Sleep 2000 ;
SendInput, Субординация это следование правил взаимоотношений между лицами.{Enter}{F6}
Sleep 2000 ;
SendInput, Она предусматривает уважительные отношения между начальником и подчиненным.{Enter}{F6}
Sleep 2000 ;
SendInput, В организациях правила субординации устанавливают порядок соблюдения определенных традиций.{Enter}{F6}
Sleep 2000 ;
SendInput, Например, традиции воинского приветствия, выполнение воинского приветствия.{Enter}{F6}
Sleep 2000 ;
SendInput, Также к старшим по должности необходимо обращаться на "Вы".{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, У кого есть вопросы по этой лекции? {Enter}
Return
:?:/лекция3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Патрулирование".{Enter}{F6}
Sleep 2000 ;
SendInput, Прежде чем выехать в патруль вы должны быть сытым и при одетым в форму работника.{Enter}{F6}
Sleep 2000 ;
SendInput, В городе вы должны соблюдать ПДД и ехать не больше 60 км/ч.{Enter}{F6}
Sleep 2000 ;
SendInput, Для патруля вам запрещено использовать мигалку и сигнальные маячки.{Enter}{F6}
Sleep 2000 ;
SendInput, В патруле вы следите за порядком в городе.{Enter}{F6}
Sleep 2000 ;
SendInput, Если вы увидели нарушение, вы должны немедленно принять меры.{Enter}{F6}
Sleep 2000 ;
SendInput, В патруль допускается не более трех сотрудников.{Enter}{F6}
Sleep 2000 ;
SendInput, Патрулировать разрешено во всех города и их окрестностях.{Enter}{F6}
Sleep 2000 ;
SendInput, И делать доклады каждые 15 минут.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
SendInput, {F6}
Sleep 2000 ;
SendInput, У кого есть вопросы по этой лекции? {Enter}
Return
:?:/лекция4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Сирена и маячок".{Enter}{F6}
Sleep 2000 ;
SendInput, Сирена и маячок есть только в специально оборудованном ТС.{Enter}{F6}
Sleep 2000 ;
SendInput, Маячок и сирена одновременно работают, что-то раздельно не работает.{Enter}{F6}
Sleep 2000 ;
SendInput, Сирена с проблесковые маячки включается исключительно в служебных целях{!}{Enter}{F6}
Sleep 2000 ;
SendInput, Сирена с проблесковыми маячками включается, чтобы Вам уступили дорогу,{Enter}{F6}
Sleep 2000 ;
SendInput,  Обратили на Вас внимание и тому подобное.{Enter}{F6}
Sleep 2000 ;
SendInput,  Сирена с проблесковыми маячками даёт вам право на несоблюдение ПДД.{Enter}{F6}
Sleep 2000 ;
SendInput, Не соблюдать ПДД можно тогда, когда это никому ничем не угрожает.{Enter}{F6}
Sleep 2000 ;
SendInput, За нарушение правил использования сирен и проблесковых маячков выдается наказание.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, У кого есть вопросы по этой лекции?{Enter}
Return
:?:/лекция5::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Построение".{Enter}{F6}
Sleep 2000 ;
SendInput, Командование строем осуществляется его инициатором.{Enter}{F6}
Sleep 2000 ;
SendInput, Исключение: Генерал, Заместитель Генерала.{Enter}{F6}
Sleep 2000 ;
SendInput, После команды строиться, весь Департамент должен быть в строю.{Enter}{F6}
Sleep 2000 ;
SendInput, На организацию строя дается три минуты.{Enter}{F6}
Sleep 2000 ;
SendInput, В строю следует молчать, не кричать.{Enter}{F6}
Sleep 2000 ;
SendInput, Исключение: Если к вам обратится тот, кто командует строем.{Enter}{F6}
Sleep 2000 ;
SendInput, Следует стоять смирно, не двигаясь, не кашляя и подобное.{Enter}{F6}
Sleep 2000 ;
SendInput, Исключение: Если на это последует приказ того{Enter}{F6}
Sleep 2000 ;
SendInput, кто организовал строй и двигаться чтобы не замерзнуть.{Enter}{F6}
Sleep 2000 ;
SendInput, Строиться только на отведенном месте.{Enter}{F6}
Sleep 2000 ;
SendInput, При проведении переклички отвечать только «Я»{Enter}{F6}
Sleep 2000 ;
SendInput, Теперь перейдём к запретам:{Enter}{F6}
Sleep 2000 ;
SendInput, Запрещено засыпать в строю, доставать мобильные телефоны{Enter}{F6}
Sleep 2000 ;
SendInput, а также смотреть на часы.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, У кого есть вопросы по этой лекции?{Enter}
Return
:?:/лекция6::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00«Тен-коды».{Enter}{F6}
Sleep 2000 ;
SendInput, Каждый сотрудник обязан хорошо знать тен-коды.{Enter}{F6}
Sleep 2000 ;
SendInput, Доклады в рацию делаются обязательно со встпулением в виде кода вашего отдела{Enter}{F6}
Sleep 2000 ;
SendInput, И номера удостоверения.{Enter}{F6}
Sleep 2000 ;
SendInput, Например: 56-01, где 56 - номер отдела, а 01 - номер удостоверения.{Enter}{F6}
Sleep 2000 ;
SendInput, Далее идет информация, которую вы хотите доложить.{Enter}{F6}
Sleep 2000 ;
SendInput, Например: 56-01 10-0-1, где 10-0-1 - выезд в патруль.{Enter}{F6}
Sleep 2000 ;
SendInput, Доклады делаются строго по форме с использованием тен-кодов.{Enter}{F6}
Sleep 2000 ;
SendInput, Исключение - погоня, когда нужно доложить метоположение. После кода отдела,{Enter}{F6}
Sleep 2000 ;
SendInput, Номера удостоверения и обозначения кода состояния вы сообщаете местоположение погони.{Enter}{F6}
Sleep 2000 ;
SendInput, Например: 56-01 Код-1 Веду преследование нарушителя, находимся у ЖД Вокзала.{Enter}{F6}
Sleep 2000 ;
SendInput, Также не забывайте про остальные коды подачи информации,{Enter}{F6}
Sleep 2000 ;
SendInput, Которые вы обязаны докладывать во время оформления и так далее.{Enter}{F6}
Sleep 2000 ;
SendInput, Присутствует команда "контроль", на которую нужно отвечать так же по опреденной форме{Enter}{F6}
Sleep 2000 ;
SendInput, В зависимости от того, что именно у вас запрашивают.{Enter}{F6}
Sleep 2000 ;
SendInput, Например, Генерал-Майор хочет узнать, кто сейчас в патруле: 56-01 Контроль 52-30 ваше 10-20.{Enter}{F6}
Sleep 2000 ;
SendInput, Тот к кому обращаются должен ответить 52-30 Контроль 56-01 и ваше местоположение.{Enter}{F6}
Sleep 2000 ;
SendInput, У кого-нибудь есть вопросы по этой лекции?{Enter}{F6}
Sleep 2000 ;
SendInput, Отлично, тогда на этом лекция окончена.{Enter}
Return
:?:/лекция7::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00«Погоня».{Enter}{F6}
Sleep 2000 ;
SendInput, Бывают такие случаи, когда нарушитель не собирается останавливаться{Enter}{F6}
Sleep 2000 ;
SendInput, По первому требованию сотрудника полиции и пытается скрыться.{Enter}{F6}
Sleep 2000 ;
SendInput, Тогда вы обязаны начать за ним погоню.{Enter}{F6}
Sleep 2000 ;
SendInput, Во время погони вы обязаны использовать звуковые и световые спецсигналы.{Enter}{F6}
Sleep 2000 ;
SendInput, Для предупреждения других участников дорожного движения, чтобы вам уступили дорогу.{Enter}{F6}
Sleep 2000 ;
SendInput, Сирена с проблесковыми маячками даёт вам право на несоблюдение ПДД.{Enter}{F6}
Sleep 2000 ;
SendInput, Не соблюдать ПДД можно тогда, когда это никому ничем не угрожает.{Enter}{F6}
Sleep 2000 ;
SendInput, Когда вы находитесь на расстоянии, при котором нарушитель будет слышать вас{Enter}{F6}
Sleep 2000 ;
SendInput, Вы предупреждаете его об остановке, после трёх предупреждений вы в праве{Enter}{F6}
Sleep 2000 ;
SendInput, Открыть огонь по колесам нарушителя, строго при отсутствии опасности для{Enter}{F6}
Sleep 2000 ;
SendInput, Гражданских лиц и вне общественных мест.{Enter}{F6}
Sleep 2000 ;
SendInput, Также вы имеете право открывать огонь по двигателю, если автомобиль угрожает жизням окружающих.{Enter}{F6}
Sleep 2000 ;
SendInput, Открывать огонь по самому нарушителю можно лишь в случаях угрозы безопасности сотрудника{Enter}{F6}
Sleep 2000 ;
SendInput, Или же гражданских лиц, находящихся поблизости.{Enter}{F6}
Sleep 2000 ;
SendInput, После задержания нарушителя вы должны найти у него документы, удостоверяющие личность.{Enter}{F6}
Sleep 2000 ;
SendInput, Оформить протокол, и посадить за решетку.{Enter}{F6}
Sleep 2000 ;
SendInput, У кого-нибудь есть вопросы по этой лекции?{Enter}
Return
:?:/лекция8::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00«Составление протокола о нарушении УК».{Enter}{F6}
Sleep 2000 ;
SendInput, Если вы заметели, как гражданин нарушает УК, вы должны попросить прижаться его к обочине.{Enter}{F6}
Sleep 2000 ;
SendInput, При остановке представляемся гражданину, просим его документы, говорим за что его остановили.{Enter}{F6}
Sleep 2000 ;
SendInput, Когда гражданин даёт вам документы, вы тщательно изучаете их.{Enter}{F6}
Sleep 2000 ;
SendInput, Также пробиваете документы гражданина через КПК, чтобы узнать наличие розыска.{Enter}{F6}
Sleep 2000 ;
SendInput, Называете гражданину срок задеражания, и говорите, что сейчас он будет задержан.{Enter}{F6}
Sleep 2000 ;
SendInput, После чего достовляете его в дежурную часть после чего составляете протокол о нарушении УК.{Enter}{F6}
Sleep 2000 ;
SendInput, Далее гражданин несёт наказание за своё правонарушение, после чего вы отдаёте его конвоиру.{Enter}{F6}
Sleep 2000 ;
SendInput, У кого-нибудь есть вопросы по этой лекции?{Enter}
Return
:?:/лекция9::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,  Сейчас пройдет лекция {#}ffff00«Взаимодействие с гражданскими лицами».{Enter}{F6}
Sleep 2000 ;
SendInput, Согласно 2.4.4.1 ФЗоП - сотрудник полиции, при обращении к гражданину обязан:{Enter}{F6}
Sleep 2000 ;
SendInput, назвать свои должность, звание, фамилию, предъявить по требованию гражданина{Enter}{F6}
Sleep 500 ;
SendInput, служебное удостоверение,{Enter}{F6}
Sleep 2000 ;
SendInput,  после чего сообщить причину и цель обращения.{Enter}{F6}
Sleep 2000 ;
SendInput,  Сотрудникам гос.структур категорически запрещено переходить на “Ты” с гражданскими лицами.{Enter}{F6}
Sleep 2000 ;
SendInput, Также сотрудникам гос. структур запрещено использовать нецензурную лексику.{Enter}{F6}
Sleep 2000 ;
SendInput, Во время взаимодействия с гражданскими соблюдайте субординацию, общайтесь вежливо{Enter}{F6}
Sleep 500 ;
SendInput,  и без каких-либо насмешек, угроз, шуток.{Enter}{F6}
Sleep 2000 ;
SendInput,  Субординация разрешено не соблюдать если Вам дано разрешение на это.{Enter}{F6}
Sleep 2000 ;
SendInput, Дружеские отношения в составе МВД не запрещены, а даже наоборот, поощряются.{Enter}{F6}
Sleep 2000 ;
SendInput, Но, если рядом с Вами гражданские, рекомендуется всё таки соблюдать субординацию.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция {#}ffff00«Взаимодействие с гражданскими лицами» окончена.{Enter}{F6}
Return

:?:/лекция10::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00«Табельное оружие».{Enter}{F6}
Sleep 2000 ;
SendInput, Всё наше оружие хранится в оружейной комнате.{Enter}{F6}
Sleep 2000 ;
SendInput, Пистолет разрешено брать со звания старшины.{Enter}{F6}
Sleep 2000 ;
SendInput, АК-47 разрешено брать со звания Лейтенант.{Enter}{F6}
Sleep 2000 ;
SendInput, Дробовик разрешено брать со звания Полковник.{Enter}{F6}
Sleep 2000 ;
SendInput, За нарушение этого правила следует строгое наказание{!}{Enter}{F6}
Sleep 2000 ;
SendInput, Табельным оружием разрешено пользоваться:{Enter}{F6}
Sleep 2000 ;
SendInput, Если вы хотите остановить транспортное средство,{Enter}{F6}
Sleep 2000 ;
SendInput, Которое отказывается останавливаться по требованиям Полиции.{Enter}{F6}
Sleep 2000 ;
SendInput, Сначала стрелять по колёсам. Потом по двигателю.{Enter}{F6}
Sleep 2000 ;
SendInput, Стрельба на поражение по гражданскому лицу разрешена лишь в случае{Enter}{F6}
Sleep 2000 ;
SendInput, Угрозы жизни сотрудника или других гражданских лиц.{Enter}{F6}
Sleep 2000 ;
SendInput, При пешей погоне разрешается открывать огонь сначала в воздух, потом по ногам.{Enter}{F6}
Sleep 2000 ;
SendInput, Табельным оружием запрещено пользоваться:{Enter}{F6}
Sleep 2000 ;
SendInput, В общественных местах, в местах массового скопления людей,{Enter}{F6}
Sleep 2000 ;
SendInput, Если гражданин не имеет огнестрельное оружие и не создает угрозы обществу.{Enter}{F6}
Sleep 2000 ;
SendInput, У кого-нибудь есть вопросы по этой лекции?{Enter}
Return
:?:/лекция11::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Обработка вызова".{Enter}{F6}
Sleep 2000 ;
SendInput, Обработка вызова - это важный этап в работе любого сотрудника ГУ МВД.{Enter}{F6}
Sleep 2000 ;
SendInput, От оперативности и качества обработки зависит своевременность реагирования на происшествия,{Enter}{F6}
Sleep 2000 ;
SendInput, эффективность работы правоохранительных органов и, в конечном итоге, жизнь и безопасность людей.{Enter}{F6}
Sleep 2000 ;
SendInput, Прием вызова: "ХХ-ХХ 10-24" - это стандартный тен-код, используемый для подтверждения приема вызова в рацию.{Enter}{F6}
Sleep 2000 ;
SendInput, Прибытие на место: "ХХ-ХХ 10-25" - этот тен-код подтверждает прибытие на место вызова.{Enter}{F6}
Sleep 2000 ;
SendInput, По прибытию, в случае если гражданское лицо находится на месте вызова{Enter}{F6} 
Sleep 2000 ;
SendInput, Вы должны подойти к нему, представиться и узнать цель вызова.{Enter}{F6}
Sleep 2000 ;
SendInput, Соблюдайте этику общения, не переходите на "Ты" с заявителем, будьте вежливы и тактичны.{Enter}{F6}
Sleep 2000 ;
SendInput, Каждая деталь может быть важной для установления всех обстоятельств происшествия.{Enter}{F6}
Sleep 2000 ;
SendInput, Не разглашайте информацию о заявителе или происшествии третьим лицам.{Enter}{F6}
Sleep 2000 ;
SendInput, Вы должны внимательно выслушать заявителя, чтобы получить максимально полную информацию о происшествии.{Enter}{F6}
Sleep 2000 ;
SendInput, Важно фиксировать ключевые моменты разговора, записывая необходимые данные:{Enter}{F6}
Sleep 2000 ;
SendInput, место происшествия, время, описание ситуации, контактные данные заявителя.{Enter}{F6}
Sleep 2000 ;
SendInput, Основные действия на вызове:{Enter}{F6}
Sleep 2000 ;
SendInput, Оказать первую помощь пострадавшим, если это необходимо, до приезда скорой помощи.{Enter}{F6}
Sleep 2000 ;
SendInput, В случае необходимости задержать подозреваемых.{Enter}{F6}
Sleep 2000 ;
SendInput, Охранять место происшествия до прибытия следственно-оперативной группы.{Enter}{F6}
Sleep 2000 ;
SendInput, О конечной обработке вызова вы докладываете “ХХ-ХХ 10-26”, что говорит о том{Enter}{F6}
Sleep 2000 ;
SendInput, что вызов от гражданского лица обработан и закрыт.{Enter}{F6}
Sleep 2000 ;
SendInput, В том случае, если по приезду на вызов, на нем не оказалось человека, сделавшего вызов, вызов считается “Ложным”,{Enter}{F6}
Sleep 2000 ;
SendInput, в таком случае вы докладываете “ХХ-ХХ 10-26ЛВ”.{Enter}{F6}
Sleep 2000 ;
SendInput, Обработка вызова - это ответственная задача, требующая от сотрудника ГУ МВД высокого 
Sleep 2000 ;
SendInput, уровня профессионализма, стрессоустойчивости,{Enter}{F6}
Sleep 2000 ;
SendInput, знания своих обязанностей и умения действовать в сложных ситуациях.{Enter}{F6}
Sleep 2000 ;
SendInput, Соблюдение этих правил поможет обеспечить оперативность и эффективность реагирования правоохранительных органов на происшествия,{Enter}{F6}
Sleep 2000 ;
SendInput, что, в конечном итоге, спасет жизнь и обеспечит безопасность людей.{Enter}{F6}
Sleep 2000 ;
SendInput, Вопросы по лекции остались?{Enter}{F6}
Sleep 2000 ;
SendInput, Лекция окончена.{Enter}
Return
:?:/лекция12::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Заступление в патруль".{Enter}{F6}
Sleep 2000 ;
SendInput, Каждый сотрудник, прежде чем заступить в патруль должен быть сыт.{Enter}{F6}
Sleep 2000 ;
SendInput, У него должно быть оружие. Поправлен быть значок.{Enter}{F6}
Sleep 2000 ;
SendInput, А также быть исправна машина.{Enter}{F6}
Sleep 2000 ;
SendInput, Прежде чем выехать из гаража, сотрудник должен доложить в рацию о выезде.{Enter}{F6}
Sleep 2000 ;
SendInput,  /b номер серия удостоверения 10-0-1{Enter}{F6}
Sleep 2000 ;
SendInput,  /b Пример: 51-17 10-0-1{Enter}{F6}
Sleep 2000 ;
SendInput, Во время патруля у него должна происходить съемка с видеорегистратора.{Enter}{F6}
Sleep 2000 ;
SendInput, Если этого нету, устраните все недочеты и вступаете в патруль.{Enter}{F6}
Sleep 2000 ;
SendInput,  На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput,  Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция13::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Заступление на пост".{Enter}{F6}
Sleep 2000 ;
SendInput, Каждый сотрудник, прежде чем заступить на пост должен быть сыт.{Enter}{F6}
Sleep 2000 ;
SendInput, У него должно быть оружие. Поправлен быть значок.{Enter}{F6}
Sleep 2000 ;
SendInput, Он должен включить съемку на нагрудной камере.{Enter}{F6}
Sleep 2000 ;
SendInput, Прежде чем заступить на пост, сотрудник должен доложить в рацию о заступлении.{Enter}{F6}
Sleep 2000 ;
SendInput,  /b номер серия удостоверения 10-1-1{Enter}{F6}
Sleep 2000 ;
SendInput,  /b Пример: 51-17 10-1-1 КПП{Enter}{F6}
Sleep 2000 ;
SendInput, Если этого нет, устраните все недочеты и заступить на пост.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция14::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Правила поведения после окончания рабочего дня".{Enter}{F6}
Sleep 2000 ;
SendInput, После 20:00 у вас заканчивается рабочий день в будние дни, после 19:00 по субботам,{Enter}{F6}
Sleep 2000 ;
SendInput, а в воскресенье выходной.{Enter}{F6}
Sleep 2000 ;
SendInput, Вы можете снять форму и пойти по своим делам.{Enter}{F6}
Sleep 2000 ;
SendInput, Однако существуют правила поведения на гражданке.{Enter}{F6}
Sleep 2000 ;
SendInput, Вы все также являетесь сотрудником ГУМВД и не должны это забывать.{Enter}{F6}
Sleep 2000 ;
SendInput, Вы должны соблюдать УКРП и КоАП Республики Провинция.{Enter}{F6}
Sleep 2000 ;
SendInput, Также должны соблюдать Конституцию Провинции.{Enter}{F6}
Sleep 2000 ;
SendInput, То есть, вы не должны лезть в драку.{Enter}{F6}
Sleep 2000 ;
SendInput, Нецензурно выражаться, грубить и оскорблять других жителей республики Провинция.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return

:?:/лекция15::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Объявление в розыск".{Enter}{F6}
Sleep 2000 ;
SendInput, И так, выдавать розыск разрешено только лицам, которые нарушили закон.{Enter}{F6}
Sleep 2000 ;
SendInput, Выдавать розыск нужно согласно статье, которое соответствует нарушению.{Enter}{F6}
Sleep 2000 ;
SendInput, Категорически запрещено:{Enter}{F6}
Sleep 2000 ;
SendInput, Придумывать новые статьи.{Enter}{F6}
Sleep 2000 ;
SendInput, Давать розыск, если Вы сами не видели нарушения или не провели расследование.{Enter}{F6}
Sleep 2000 ;
SendInput, В розыск объявляем по описанию статьи.{Enter}{F6}
Sleep 2000 ;
SendInput, Например гражданин Вас оскорбил.{Enter}{F6}
Sleep 2000 ;
SendInput, Вы его задерживайте по 5.6 УК РП.{Enter}{F6}
Sleep 2000 ;
SendInput, Выдаете розыск.{Enter}{F6}
Sleep 2000 ;
SendInput,  /b /su ID игрока / кол-во лет / номер статьи{Enter}{F6}
Sleep 2000 ;
SendInput,  /b /su 111 1 5.5 УКРП{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return

:?:/лекция16::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Конвоирование".{Enter}{F6}
Sleep 2000 ;
SendInput, После того, как вы надели наручники на задержанного{Enter}{F6}
Sleep 2000 ;
SendInput, И обыскали его, а затем зачитали ему его права вы должны:{Enter}{F6}
Sleep 2000 ;
SendInput, Произвести действие, такое как как: конвоирование.{Enter}{F6}
Sleep 2000 ;
SendInput, Оно включает в себя охрану задержанного, а именно:{Enter}{F6}
Sleep 2000 ;
SendInput, Чтобы он не смог сбежать. Задержанного сажать на заднее место{Enter}{F6}
Sleep 2000 ;
SendInput, Служебного транспорта, так как между передними и задними местами есть{Enter}{F6}
Sleep 2000 ;
SendInput, Металлическая сетка, с помощью который задержанный не сможет совершить побег.{Enter}{F6}
Sleep 2000 ;
SendInput, Произвести нападение, даже находясь в наручниках.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return

:?:/лекция17::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Обыск".{Enter}{F6}
Sleep 2000 ;
SendInput, Производить обыск может любой сотрудник, хоть даже Рядовой.{Enter}{F6}
Sleep 2000 ;
SendInput, Обычные места для проведения обыска:{Enter}{F6}
Sleep 2000 ;
SendInput, Задержание гражданина, Приём, Блок-пост, Спецоперация.{Enter}{F6}
Sleep 2000 ;
SendInput, И тому подобное.{Enter}{F6}
Sleep 2000 ;
SendInput, Также обыск проводится после того, как вы надели наручники.{Enter}{F6}
Sleep 2000 ;
SendInput, На преступника при задержании. Обыск проводить вне участка Полиции.{Enter}{F6}
Sleep 2000 ;
SendInput, Так как задержанный может с собой привезти огнестрельное оружие и так далее.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return

:?:/лекция18::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Вытаскивание подозреваемого из транспорта".{Enter}
Sleep 2000 ;
SendInput, Высадка подозреваемого очень серьёзное действие.{Enter}{F6}
Sleep 2000 ;
SendInput, Но прежде, чем это сделать надо попросить подозреваемого выйти из транспортного средства.{Enter}{F6}
Sleep 2000 ;
SendInput, Если он отказывается, то вы сначала объявляете его в розыск{Enter}{F6}
Sleep 2000 ;
SendInput, а потом начинаете ломать стекло двери{Enter}{F6}
Sleep 2000 ;
SendInput, чтобы открыть замок транспортного средства.{Enter}{F6}
Sleep 2000 ;
SendInput,  /b Стрелять не нужно{!}{Enter}{F6}
Sleep 2000 ;
SendInput,  /b В движении не вытаскивать преступника{!}{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return

:?:/лекция19::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Оформление нарушителей".{Enter}{F6}
Sleep 2000 ;
SendInput, Задержание нарушителей - это одна из самых ответственных задач сотрудника ГУ МВД.{Enter}{F6}
Sleep 2000 ;
SendInput, От правильности оформления и проведения задержания зависит дальнейший ход расследования{Enter}{F6}
Sleep 2000 ;
SendInput, а также правовые гарантии как для задержанного, так и для сотрудников полиции.{Enter}{F6} 
Sleep 2000 ;
SendInput, Разберем степень тяжести деяния.{Enter}{F6} 
Sleep 2000 ;
SendInput, Преступление: Сотрудник полиции может задержать лицо, совершившее преступление или подозреваемого в его совершении.{Enter}{F6} 
Sleep 2000 ;
SendInput, Административное правонарушение:{Enter}{F6} 
Sleep 2000 ;
SendInput, Задержание возможно при наличии оснований, предусмотренных Кодексом об административных правонарушениях.{Enter}{F6}
Sleep 2000 ;
SendInput, Процедура задержания:{Enter}{F6}
Sleep 2000 ;
SendInput, Сотрудник полиции обязан представиться задерживаемому, назвав свое звание, должность, подразделение{Enter}{F6}
Sleep 2000 ;
SendInput, и предъявить служебное удостоверение.{Enter}{F6} 
Sleep 2000 ;
SendInput, Необходимо четко и ясно объяснить задерживаемому причину задержания, сославшись на конкретные статьи законодательства.{Enter}{F6} 
Sleep 2000 ;
SendInput, При дальнейшем задержании и доставлении в Дежурную часть или прилегающую территорию - парковку.{Enter}{F6}
Sleep 2000 ;
SendInput, Сотрудник полиции обязан составить протокол о нарушении гражданина. Составить протокол задержания с указанием: Даты, времени и места задержания.{Enter}{F6}  
Sleep 2000 ;
SendInput, Фамилии, имени, отчества, даты рождения, и других данных задержанного, причина задержания - нарушенная статья гражданином.{Enter}{F6}
Sleep 2000 ;
SendInput, После составления протокола Вы обязаны поставить отметку о невозможности подписания протокола и положить задержанному копию протокола в карман.{Enter}{F6} 
Sleep 2000 ;
SendInput, Далее Вы должны связаться с диспетчером, сообщить ему серию паспорта гражданина, нарушенную статью или статьи,{Enter}{F6}
Sleep 2000 ;
SendInput, а также указать уровень выдаваемого федерального розыска.{Enter}{F6}
Sleep 2000 ;
SendInput, После того, как все действия были сделаны, вы должны вызвать конвоира и передать задержанного ему.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция20::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Оформление нарушителей №2".{Enter}{F6}
Sleep 2000 ;
SendInput, При обращении к гражданину, сотрудник должен четко представиться{Enter}{F6}
Sleep 2000 ;
SendInput,  назвав свою фамилию, имя, отчество{Enter}{F6}
Sleep 2000 ;
SendInput, должность и подразделение в котором трудоустроен.{Enter}{F6}
Sleep 2000 ;
SendInput, Одновременно с представлением необходимо предъявить служебное удостоверение для проверки,{Enter}{F6}
Sleep 2000 ;
SendInput, держа его таким образом{Enter}{F6}
Sleep 2000 ;
SendInput, чтобы гражданин мог свободно ознакомиться с информацией.{Enter}{F6}
Sleep 2000 ;
SendInput, Не забывайте при общении с гражданином соблюдать вежливость, уважительность и корректность.{Enter}{F6}
Sleep 2000 ;
SendInput, Сотрудник обязан четко и ясно сформулировать причину обращения к гражданину{Enter}{F6}
Sleep 2000 ;
SendInput, или остановки транспортного средства.{Enter}{F6}
Sleep 2000 ;
SendInput, Причина должна быть конкретной и обоснованной, например:{Enter}{F6}
Sleep 2000 ;
SendInput, "Вас остановили за нарушение ПДД - превышение скорости",{Enter}{F6}
Sleep 2000 ;
SendInput, "Вас остановили для проверки документов",{Enter}{F6}
Sleep 2000 ;
SendInput, "Мы получили ориентировку о том, что вы находитесь в розыске".{Enter}{F6}
Sleep 2000 ;
SendInput, Следует избегать двусмысленных формулировок и использования профессиональных терминов,{Enter}{F6}
Sleep 2000 ;
SendInput, которые могут быть непонятны гражданину.{Enter}{F6}
Sleep 2000 ;
SendInput, После представления сотрудник обязан проверить документы, удостоверяющие личность гражданина,{Enter}{F6}
Sleep 2000 ;
SendInput, а также регистрационные документы на транспортное средство, если требуется.{Enter}{F6}
Sleep 2000 ;
SendInput, В случае отсутствия или недействительности документов, необходимо определить личность гражданина{Enter}{F6}
Sleep 2000 ;
SendInput, при помощи фото-робота.{Enter}{F6}
Sleep 2000 ;
SendInput, Сотрудник должен проверить, не находится ли гражданин в розыске.{Enter}{F6}
Sleep 2000 ;
SendInput, Проверка производится через соответствующие базы данных, используя служебные средства.{Enter}{F6}
Sleep 2000 ;
SendInput, Задержание гражданина производится только в случаях, предусмотренных законодательством,{Enter}{F6}
Sleep 2000 ;
SendInput, например, при совершении преступления{Enter}{F6}
Sleep 2000 ;
SendInput, или административного правонарушения, при наличии оснований полагать,{Enter}{F6}
Sleep 2000 ;
SendInput, что гражданин может скрыться от сотрудников МВД.{Enter}{F6}
Sleep 2000 ;
SendInput, После задержания гражданина, его необходимо доставить в дежурную часть{Enter}{F6}
Sleep 2000 ;
SendInput, или на прилегающую территорию - парковку.{Enter}{F6}
Sleep 2000 ;
SendInput, В ДЧ или на парковке необходимо составить протокол задержания, отражая в нем все{Enter}{F6}
Sleep 2000 ;
SendInput, необходимые сведения о задержании.{Enter}{F6}
Sleep 2000 ;
SendInput, Протокол должен быть подписан как задержанным, так и сотрудниками полиции.{Enter}{F6}
Sleep 2000 ;
SendInput, В случае невозможности подписания протокола гражданином, ставится метка{Enter}{F6}
Sleep 2000 ;
SendInput, о невозможности подписания.{Enter}{F6}
Sleep 2000 ;
SendInput, Копия протокола должна быть передана задержанному.{Enter}{F6}
Sleep 2000 ;
SendInput, После составления протокола, задержанный передается конвоиру,{Enter}{F6}
Sleep 2000 ;
SendInput, а протокол задержания передается в канцелярию.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция21::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Оформление чистосердечного".{Enter}{F6}
Sleep 2000 ;
SendInput, Чистосердечное признание - это заявление лица, подозреваемого или обвиняемого{Enter}{F6}
Sleep 2000 ;
SendInput, в совершении преступления, о признании своей вины.{Enter}{F6}
Sleep 2000 ;
SendInput, Оно может стать важным элементом доказательной базы в уголовном процессе{Enter}{F6}
Sleep 2000 ;
SendInput, ускорить расследование и облегчить работу правоохранительных органов.{Enter}{F6}
Sleep 2000 ;
SendInput, Условия признания:{Enter}{F6}
Sleep 2000 ;
SendInput, Добровольное волеизъявление: Признание должно быть дано добровольно, без принуждения{Enter}{F6}
Sleep 2000 ;
SendInput, угроз, шантажа или обещаний каких-либо преимуществ.{Enter}{F6}
Sleep 2000 ;
SendInput, Оформлять чистосердечное признание необходимо в спокойной обстановке, без давления.{Enter}{F6}
Sleep 2000 ;
SendInput, Зафиксировать признание в письменной форме,{Enter}{F6}
Sleep 2000 ;
SendInput, составление протокола признания, который должен содержать:{Enter}{F6}
Sleep 2000 ;
SendInput, Дату и время составления протокола{Enter}{F6}
Sleep 2000 ;
SendInput, Данные о лице, дающем признание ФИО и прочие данные.{Enter}{F6}
Sleep 2000 ;
SendInput, Подробное описание преступления, признание вины в его совершении{Enter}{F6}
Sleep 2000 ;
SendInput, Описание обстоятельств совершения преступления.{Enter}{F6}
Sleep 2000 ;
SendInput, Подписи лица, дающего признание а также сотрудника полиции, принимающий чистосердечное признание.{Enter}{F6}
Sleep 2000 ;
SendInput, Далее необходимо связаться с диспетчером и сократить розыск гражданина (-1 звезда).{Enter}{F6}
Sleep 2000 ;
SendInput, После всех проделанных действий, вы заводите гражданина в КПЗ.{Enter}{F6}
Sleep 2000 ;
SendInput, Чистосердечное признание - это важный инструмент в уголовном процессе,{Enter}{F6}
Sleep 2000 ;
SendInput, способный ускорить расследование и облегчить работу правоохранительных органов.{Enter}{F6}
Sleep 2000 ;
SendInput, Однако, при оформлении признания необходимо соблюдать все правила и требования закона.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция22::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Оформление чистосердечного №2".{Enter}{F6}
Sleep 2000 ;
SendInput, При общении с подозреваемым, сотрудник должен представиться, назвав свою фамилию{Enter}{F6}
Sleep 2000 ;
SendInput, имя, отчество, должность и подразделение.{Enter}{F6}
Sleep 2000 ;
SendInput, Далее сотрудник должен взять бланк для оформления чистосердечного признания.{Enter}{F6}
Sleep 2000 ; 
SendInput, После представления, сотрудник должен спросить подозреваемого о случившемся.{Enter}{F6}
Sleep 2000 ;
SendInput, Важно задавать вопросы четко и понятно, избегать наводящих вопросов{Enter}{F6}
Sleep 2000 ;
SendInput, способных повлиять на показания.{Enter}{F6}
Sleep 2000 ;
SendInput, Сотрудник должен записывать показания подозреваемого, избегая искажения информации.{Enter}{F6}
Sleep 2000 ;
SendInput, После получения информации от подозреваемого, сотрудник должен попросить{Enter}{F6}
Sleep 2000 ;
SendInput, его предъявить паспорт или иной документ, удостоверяющий личность.{Enter}{F6}
Sleep 2000 ;
SendInput, Проверка личности необходима для определения личности подозреваемого и его сведения.{Enter}{F6}
Sleep 2000 ;
SendInput, Далее необходимо пробить по базе данных.{Enter}{F6}
Sleep 2000 ;
SendInput, После проверки документа, сотрудник должен проверить данные подозреваемого в базе данных{Enter}{F6}
Sleep 2000 ;
SendInput, для установления его личности, наличия Федерального розыска и других важных сведений.{Enter}{F6}
Sleep 2000 ;
SendInput, Сотрудник должен заполнить бланк чистосердечного признания{Enter}{F6}
Sleep 2000 ;
SendInput, основываясь на полученных показаниях от подозреваемого, его личности и прочих собранных данных.{Enter}{F6}
Sleep 2000 ;
SendInput, Бланк должен быть заполнен четко, разборчиво, без ошибок и исправлений.{Enter}{F6}
Sleep 2000 ;
SendInput, Сотрудник должен дать подозреваемому прочитать и подписать бланк чистосердечного признания.{Enter}{F6}
Sleep 2000 ;
SendInput, После оформления чистосердечного признания, сотрудник должен отвести задержанного в КПЗ.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return

:?:/ОСН1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Ведение переговоров".{Enter}{F6}
Sleep 2000 ;
SendInput,  Ведение переговоров с преступниками требует особых навыков и подходов.{Enter}{F6}
Sleep 2000 ;
SendInput, Эти переговоры могут быть напряженными,опасными и важными для решения критических ситуаций.{Enter}{F6}
Sleep 2000 ;
SendInput, Правильное ведение переговоров может не только спасти жизни{Enter}{F6}
Sleep 2000 ;
SendInput, но и помочь в расследовании и предотвращении преступлений.{Enter}{F6}
Sleep 2000 ;
SendInput, Первоначальным шагом в ведении переговоров с преступниками является подготовка.{Enter}{F6}
Sleep 2000 ;
SendInput, Необходимо тщательно изучить характеристики ситуации, предмет переговоров,{Enter}{F6}
Sleep 2000 ;
SendInput, цели и задачи сторон{Enter}{F6}
Sleep 2000 ;
SendInput,  Также важно оценить психологические особенности собеседников, их мотивы и стратегии поведения.{Enter}{F6}
Sleep 2000 ;
SendInput,  Вторым шагом является установление контакта с противоположной стороной{Enter}{F6}
Sleep 2000 ;
SendInput, Важно проявить доверие, эмпатию и понимание к собеседнику, даже если он считается преступником.{Enter}{F6}
Sleep 2000 ;
SendInput,  Необходимо использовать некоторые техники активного слушания{Enter}{F6}
Sleep 2000 ;
SendInput, чтобы лучше понять позицию и мотивацию собеседника.{Enter}{F6}
Sleep 2000 ;
SendInput, Третьим шагом является установление цели переговоров.{Enter}{F6}
Sleep 2000 ;
SendInput,  Необходимо ясно сформулировать свои интересы и позицию, а также установить границы{Enter}{F6}
Sleep 500 ;
SendInput, и условия дальнейших действий.{Enter}{F6}
Sleep 2000 ;
SendInput, Важно быть гибким и готовым к компромиссам, если это поможет достичь цели переговоров.{Enter}{F6}
Sleep 2000 ;
SendInput,  Четвертым шагом является выбор стратегии переговоров.{Enter}{F6}
Sleep 2000 ;
SendInput, Существует несколько основных стратегий переговоров, таких как конкурентная, кооперативная,{Enter}{F6}
Sleep 300 ;
SendInput,  компромиссная и избирательная.{Enter}{F6}
Sleep 2000 ;
SendInput,  В зависимости от ситуации и характера собеседника необходимо выбрать{Enter}{F6}
Sleep 500 ;
SendInput, наиболее эффективную стратегию.{Enter}{F6}
Sleep 2000 ;
SendInput,  Наконец, после завершения переговоров необходимо оценить результаты и{Enter}{F6}
Sleep 500 ;
SendInput, извлечь уроки для будущих ситуаций.{Enter}{F6}
Sleep 2000 ;
SendInput,  переговоров и повысить свою профессиональную компетенцию.{Enter}{F6}
Sleep 2000 ;
SendInput,  В заключение, ведение переговоров с преступниками требует особых навыков,{Enter}{F6}
Sleep 500 ;
SendInput,  терпения и профессионализма.{Enter}{F6}
Sleep 500 ;
SendInput, Важно быть готовым к любым ситуациям, быть гибким и стратегическим в своих действиях.{Enter}{F6}
Sleep 2000 ;
SendInput,  Только так можно добиться успешного и эффективного исхода переговоров.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return

:?:/ОСН2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Обезвреживание взрывчатых устройств".{Enter}{F6}
Sleep 2000 ;
SendInput, Обезвреживание взрывчатых устройств – это сложное и опасное дело{Enter}{F6}
Sleep 2000 ;
SendInput, требующее профессионализма, знаний и специальной подготовки.{Enter}{F6}
Sleep 2000 ;
SendInput, Специалисты по обезвреживанию взрывчатых устройств работают в условиях повышенного риска{Enter}{F6}
Sleep 2000 ;
SendInput, где каждая деталь и каждое действие могут иметь критическое значение.{Enter}{F6}
Sleep 2000 ;
SendInput, Перед началом процедуры обезвреживания специалисты должны провести тщательную оценку ситуации{Enter}{F6}
Sleep 2000 ;
SendInput,  Необходимо определить тип и мощность взрывчатого устройства, его местоположение,{Enter}{F6}
Sleep 2000 ;
SendInput,  возможные последствия взрыва,{Enter}{F6}
Sleep 2000 ;
SendInput,  а также принять необходимые меры для обеспечения безопасности окружающих.{Enter}{F6}
Sleep 2000 ;
SendInput,  Одним из основных методов обезвреживания взрывчатых устройств является их деактивация.{Enter}{F6}
Sleep 2000 ;
SendInput,  Это процесс, при котором специалисты используют специальные инструменты и технику{Enter}{F6}
Sleep 2000 ;
SendInput,  для удаления и изъятия взрывчатого вещества{Enter}{F6}
Sleep 2000 ;
SendInput,  или детонатора из устройства. Деактивация требует точности,аккуратности и профессионализма,{Enter}{F6}
Sleep 2000 ;
SendInput,  чтобы предотвратить случайный взрыв.{Enter}{F6}
Sleep 2000 ;
SendInput,   Другим методом обезвреживания является контролируемый взрыв.{Enter}{F6}
Sleep 2000 ;
SendInput,  В некоторых случаях невозможно безопасно удалить взрывчатое устройство,{Enter}{F6}
Sleep 2000 ;
SendInput, поэтому специалисты могут решить провести контролируемый взрыв{Enter}{F6}
Sleep 300 ;
SendInput, с целью минимизации ущерба и рисков.{Enter}{F6}
Sleep 2000 ;
SendInput, Этот метод требует высокого уровня координации, предвидения и стратегического мышления.{Enter}{F6}
Sleep 300 ;
SendInput, Важным аспектом при обезвреживании взрывчатых устройств является{Enter}{F6}
Sleep 300 ;
SendInput, обучение и тренировка специалистов.{Enter}{F6}
Sleep 2000 ;
SendInput, Они должны постоянно совершенствовать свои навыки, участвовать в тренировочных учениях{Enter}{F6}
Sleep 2000 ;
SendInput, и изучать новейшие технологии и методики. Только так можно обеспечить успешное{Enter}{F6}
Sleep 500 ;
SendInput,  и безопасное обезвреживание взрывчатых устройств.{Enter}{F6}
Sleep 2000 ;
SendInput, В заключение, обезвреживание взрывчатых устройств – это ответственная и опасная работа,{Enter}{F6}
Sleep 2000 ;
SendInput,  требующая профессионализма, знаний и опыта.{Enter}{F6}
Sleep 500 ;
SendInput, Специалисты по обезвреживанию должны быть готовы к любым ситуациям,{Enter}{F6}
Sleep 500 ;
SendInput, действовать быстро, точно и решительно.{Enter}{F6}
Sleep 2000 ;
SendInput,  Их работа спасает жизни и обеспечивает безопасность окружающих,поэтому она требует{Enter}{F6}
Sleep 200 ;
SendInput, высокого уровня подготовки и профессионализма.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return

:?:/ОСН3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Штурм зданий, оцепление и прочее".{Enter}{F6}
Sleep 2000 ;
SendInput, Штурм зданий и оцепление – это серьезные и сложные операции,{Enter}{F6}
Sleep 2000 ;
SendInput, которые проводят специальные подразделения правоохранительных органов{Enter}{F6}
Sleep 2000 ;
SendInput,Эти операции могут быть необходимы при террористических атаках,{Enter}{F6}
Sleep 2000 ;
SendInput,заложении заложников, банковских ограблениях или других ситуациях{Enter}{F6}
Sleep 300 ;
SendInput, требующих быстрого и эффективного реагирования.{Enter}{F6}
Sleep 2000 ;
SendInput,  Перед началом штурма здания или его оцепления специалисты должны{Enter}{F6}
Sleep 2000 ;
SendInput, провести подробное разведывательное изучение объекта и обстановки.{Enter}{F6}
Sleep 2000 ;
SendInput, Необходимо определить количество и структуру захватчиков,{Enter}{F6}
Sleep 2000 ;
SendInput, наличие оружия и взрывчатых веществ{Enter}{F6}
Sleep 2000 ;
SendInput,  а также план здания, пути эвакуации и возможные укрытия.{Enter}{F6}
Sleep 2000 ;
SendInput, Оцепление здания – это процесс, при котором спец.подразделения правоохранительных органов{Enter}{F6}
Sleep 2000 ;
SendInput, блокируют доступ к объекту, предотвращая утечку информации о планах операции{Enter}{F6}
Sleep 2000 ;
SendInput, и предупреждая попытки скрыться захватчиков.{Enter}{F6}
Sleep 2000 ;
SendInput,  Они также обеспечивают безопасность окружающей территории и граждан,{Enter}{F6}
Sleep 2000 ;
SendInput, предотвращая возможные попытки покидания здания захватчиками.{Enter}{F6}
Sleep 500 ;
SendInput, Штурм здания – это крайний и опасный этап операции, который проводят специально подготовленные{Enter}{F6}
Sleep 2000 ;
SendInput, подразделения со специализированным снаряжением и техникой.{Enter}{F6}
Sleep 2000 ;
SendInput, Цель штурма - ликвидировать захватчиков, освободить заложников и восстановить порядок.{Enter}{F6}
Sleep 2000 ;
SendInput, Штурм здания требует высокой координации, мастерства и боевой готовности от участников.{Enter}{F6}
Sleep 300 ;
SendInput, Важными аспектами при оцеплении и штурме здания являются специализированное{Enter}{F6}
Sleep 2000 ;
SendInput,  обучение и тренировки специалистов, {Enter}{F6}
Sleep 2000 ;
SendInput,  использование современного оборудования и техники, а также поддержка со стороны других{Enter}{F6}
Sleep 2000 ;
SendInput,  правоохранительных органов и служб. Только так можно обеспечить успешное{Enter}{F6}
Sleep 500 ;
SendInput, и безопасное проведение операции.{Enter}{F6}
Sleep 2000 ;
SendInput,  В заключение, штурм здания и оцепление – это сложные и опасные операции,{Enter}{F6}
Sleep 2000 ;
SendInput, требующие высокой профессиональной подготовки, мастерства и координации.{Enter}{F6}
Sleep 2000 ;
SendInput,  Специалисты, участвующие в таких операциях, должны быть готовы к любым ситуациям,{Enter}{F6}
Sleep 500 ;
SendInput, действовать решительно и эффективно.{Enter}{F6}
Sleep 2000 ;
SendInput,  Их работа спасает жизни и обеспечивает безопасность граждан,{Enter}{F6}
Sleep 2000 ;
SendInput, поэтому она требует высокого уровня профессионализма и ответственности.{Enter}{F6}
Sleep 2000 ;
SendInput, Лекция окончена{!}{Enter}
Return

:?:/ОСН4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Передача информации в рацию и необходимые запросы".{Enter}{F6}
Sleep 2000 ;
SendInput,  Передача информации в рацию о чрезвычайных ситуациях – это один из самых важных аспектов{Enter}{F6}
Sleep 2000 ;
SendInput, работы специальных служб и правоохранительных органов при реагировании{Enter}{F6}
Sleep 2000 ;
SendInput, на чрезвычайные ситуации, такие как пожары, землетрясения, теракты и другие происшествия{Enter}{F6}
Sleep 2000 ;
SendInput, требующие оперативного реагирования и координации.{Enter}{F6}
Sleep 2000 ;
SendInput,  Рация – это радиостанция, которая позволяет оперативно передавать информацию{Enter}{F6}
Sleep 2000 ;
SendInput, и связывать между собой участников операции или службы.{Enter}{F6}
Sleep 2000 ;
SendInput, Она является неотъемлемым инструментом для оперативного управления и координации в чрезвычайных ситуациях.{Enter}{F6}
Sleep 2000 ;
SendInput,  При передаче информации в рацию о чрезвычайных ситуациях необходимо соблюдать ряд правил и принципов.{Enter}{F6}
Sleep 2000 ;
SendInput,  1. Четкость и ясность. Информация должна быть передана четко и ясно, без лишних деталей или эмоций.{Enter}{F6}
Sleep 2000 ;
SendInput, Необходимо использовать специальную терминологию и кодовые слова для более эффективной передачи информации.{Enter}{F6}
Sleep 2000 ;
SendInput,  2. Краткость. Информация должна быть передана максимально кратко и точно, чтобы избежать недопониманий.{Enter}{F6}
Sleep 2000 ;
SendInput,  3. Следование протоколу. При передаче информации в рацию нужно следовать установленным протоколам и стандартам,{Enter}{F6}
Sleep 2000 ;
SendInput, чтобы обеспечить ее правильное восприятие и интерпретацию.{Enter}{F6}
Sleep 2000 ;
SendInput,  4. Профессионализм. Передачу информации в рацию должны осуществлять только{Enter}{F6}
Sleep 500 ;
SendInput, подготовленные и профессиональные сотрудники, обладающие необходимыми навыками и опытом.{Enter}{F6}
Sleep 2000 ;
SendInput, Правильная передача информации в рацию о чрезвычайных ситуациях играет решающую роль{Enter}{F6}
Sleep 2000 ;
SendInput,  в эффективном реагировании на происшествия и обеспечении безопасности граждан.{Enter}{F6}
Sleep 2000 ;
SendInput, Оперативное и точное информирование позволяет быстро принимать решения,{Enter}{F6}
Sleep 500 ;
SendInput,  координировать действия и предотвращать угрозы.{Enter}{F6}
Sleep 2000 ;
SendInput,  Важно не только уметь передавать информацию в рацию, но и правильно ее воспринимать и реагировать на нее.{Enter}{F6}
Sleep 2000 ;
SendInput, Поэтому обучение сотрудников правила передачи информации и правильной работы с радиостанциями{Enter}{F6}
Sleep 2000 ;
SendInput,  имеет большое значение для эффективного управления в чрезвычайных ситуациях.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return

:?:/ОСН5::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Оказание первой медицинской помощи".{Enter}{F6}
Sleep 2000 ;
SendInput,  При огнестрельных ранениях наша задача оттащить пострадавшего с места боевых{Enter}{F6}
Sleep 2000 ;
SendInput, действий и положить пострадавшего на спину и проверить пульс.{Enter}{F6}
Sleep 2000 ;
SendInput, Если пульс раненного отсутствует или крайне низкий,{Enter}{F6}
Sleep 2000 ;
SendInput, то нужно немедленно начать сердечно-легочную реанимацию.{Enter}{F6}
Sleep 2000 ;
SendInput,  Обычно, частота нажатий при непрямом массаже сердца составляет 100—120 в минуту{Enter}{F6}
Sleep 2000 ;
SendInput, Если пострадавший потерял сознание, но есть пульс и дыхание,{Enter}{F6}
Sleep 2000 ;
SendInput, то следует приложить к носу ватку, смоченную нашатырным спиртом.{Enter}{F6}
Sleep 2000 ;
SendInput,  Далее, нужно осмотреть тело пострадавшего и найти, в каком месте пулевое ранение,{Enter}{F6}
Sleep 2000 ;
SendInput,  после нужно найти острый предмет чтобы разрезать одежду в области ранения.{Enter}{F6}
Sleep 2000 ;
SendInput,  После того как разрезали одежду в области ранения, следует наложить давящую повязку{Enter}{F6}
Sleep 2000 ;
SendInput,  или жгут и продезинфицировать{Enter}{F6}
Sleep 2000 ;
SendInput,  область вокруг раны, после того как обработали нужно вколоть в бедро обезболивающий препарат.{Enter}{F6}
Sleep 2000 ;
SendInput,  После нужно забинтовать всю область, предварительно смочив водой, если она есть.{Enter}{F6}
Sleep 2000 ;
SendInput,  Когда пациент приходит в сознание, следует проверить его на наличие других травм.{Enter}{F6}
Sleep 500 ;
SendInput,  После проведенных действий его следует немедленно отвезти в больницу{Enter}{F6}
Sleep 2000 ;
SendInput,  или отправить запрос на ближайшую к месту боевых действий больницу{Enter}{F6}
Sleep 2000 ;
SendInput,  для скорей госпитализации сотрудника и проведения операции.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return


:?:/лекция23::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Использование таб. оружия и спец. средств".{Enter}{F6}
Sleep 2000 ;
SendInput, Применение табельного оружия и специальных средств - это крайняя мера{Enter}{F6}
Sleep 2000 ;
SendInput, к которой прибегают сотрудники ГУ МВД только в случаях, предусмотренных законом{Enter}{F6}
Sleep 2000 ;
SendInput, для предотвращения преступлений, задержания преступников{Enter}{F6}
Sleep 2000 ;
SendInput, защиты себя и других людей от опасности.{Enter}{F6}
Sleep 2000 ;
SendInput, порядок использования оружия и специальных средств сотрудниками полиции{Enter}{F6}
Sleep 2000 ;
SendInput, определяет Федеральный закон “О полиции”.{Enter}{F6}
Sleep 2000 ;
SendInput, Применение оружия и спецсредств допускается только в случае необходимости{Enter}{F6}
Sleep 2000 ;
SendInput, для предотвращения преступления или задержания преступника{Enter}{F6}
Sleep 2000 ;
SendInput, защиты от опасности для себя или других лиц.{Enter}{F6}
Sleep 2000 ;
SendInput, Перед применением оружия или спецсредств необходимо предупредить нарушителя{Enter}{F6}
Sleep 2000 ;
SendInput, о намерении их применить, за исключением случаев{Enter}{F6}
Sleep 2000 ;
SendInput, когда промедление опасно для жизни и здоровья людей.{Enter}{F6}
Sleep 2000 ;
SendInput, Алгоритм действий при применении табельного оружия и специальных средств:{Enter}{F6}
Sleep 2000 ;
SendInput, Определить характер угрозы и степень опасности.{Enter}{F6}
Sleep 2000 ;
SendInput, Предупредить нарушителя о намерении применить оружие или спец. средства.{Enter}{F6}
Sleep 2000 ;
SendInput, Выбрать оружие или спецсредство, пропорциональное степени опасности и характеру угрозы.{Enter}{F6}
Sleep 2000 ;
SendInput, Применить оружие или спецсредства с максимальной точностью и эффективностью,{Enter}{F6}
Sleep 2000 ;
SendInput, стараясь минимизировать потенциальный ущерб.{Enter}{F6}
Sleep 2000 ;
SendInput, Оказать необходимую помощь пострадавшим, вызвать скорую помощь{Enter}{F6}
Sleep 2000 ;
SendInput, или другие службы, если это необходимо.{Enter}{F6}
Sleep 2000 ;
SendInput, Применение табельного оружия и специальных средств - это крайняя мера{Enter}{F6}
Sleep 2000 ;
SendInput, к которой сотрудники ГУ МВД прибегают только в случаях крайней необходимости.{Enter}{F6}
Sleep 2000 ;
SendInput, Соблюдение правовых норм и алгоритма действий, а также высокая профессиональная{Enter}{F6}
Sleep 2000 ;
SendInput, подготовка являются гарантией правомерности и безопасности использования оружия и спецсредств.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return

:?:/об::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Проведение первичного обыска".{Enter}{F6}
Sleep 2000 ;
SendInput, Первичный обыск – это неотложное следственное действие, направленное на обнаружение{Enter}{F6}
Sleep 2000 ;
SendInput,  и фиксацию доказательств, орудий преступления, а также предметов и документов, имеющих значение для дела.{Enter}{F6}
Sleep 2000 ; 
SendInput, Его проводят непосредственно после задержания подозреваемого или на месте происшествия.{Enter}{F6}
Sleep 2000 ;
SendInput, Цель первичного обыска – предотвратить уничтожение или сокрытие важных улик.{Enter}{F6}
Sleep 2000 ;
SendInput,  Основные правила проведения первичного обыска:{Enter}{F6}
Sleep 2000 ;
SendInput,  Обыск проводится только на основании закона и при наличии достаточных оснований.{Enter}{F6}
Sleep 2000 ;
SendInput, Необходимо учитывать потенциальную опасность со стороны подозреваемого и окружающей обстановки.{Enter}{F6}
Sleep 2000 ;
SendInput, Тщательное и подробное протоколирование всех действий, фото- и видеофиксация.{Enter}{F6}
Sleep 2000 ;
SendInput, Систематический и последовательный подход к осмотру, фиксации и изъятию предметов.{Enter}{F6}
Sleep 2000 ;
SendInput, Рассмотрим этапы проведения обыска.{Enter}{F6}
Sleep 2000 ;
SendInput, Осмотр места проведения обыска: Визуальный осмотр, определение границ обыска.{Enter}{F6}
Sleep 2000 ;
SendInput,  Непосредственный обыск: Систематический осмотр одежды задержанного, его личных вещей, транспортного средства.{Enter}{F6}
Sleep 2000 ;
SendInput,  Фотографирование и описание обнаруженных предметов в протоколе, их упаковка и маркировка.{Enter}{F6}
Sleep 2000 ;
SendInput,  Обнаруженные предметы должны быть убраны в специальный зип-пакет.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом наша лекция окончена{!}{Enter}
Return

:?:/протдоп1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do На столе лежит стопка пустых бланков.{Enter}{F6}
Sleep 250
SendInput, /me взяв бланк, закрепил%ok1% его в планшетке{Enter}{F6}
Sleep 250
SendInput, /do Ручка на столе.{Enter}{F6}
Sleep 250
SendInput, /me взяв ручку, начал%ok1% записывать данные гражданина{Enter}{F6}
Sleep 250
SendInput, /do Данные внесены в протокол.{Enter}
Return

:?:/протдоп2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me взяв ручку со стола, внес%ok2% в протокол данные о наличии запрещенных предметов{Enter}{F6}
Sleep 250
SendInput, /do В протокол внесены данные о наличии запрещенных предметов.{Enter}
Return

:?:/протдоп3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me заполнил%ok1% статью, нарушенную гражданином{Enter}{F6}
Sleep 250
SendInput, /me поставил%ok1% метку о невозможности подписания{Enter}{F6}
Sleep 250
SendInput, /do Метка о невозможности подписания поставлена.{Enter}{F6}
Sleep 250
SendInput, /me поставил%ok1% дату и подпись{Enter}{F6}
Sleep 250
SendInput, /do Дата и подпись поставлена.{Enter}{F6}
Sleep 250
SendInput, /do Протокол допроса составлен.{Enter}
Return

:?:/перчатки::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do На столе лежит упаковка с нитриловыми перчатками и зип-пакеты.{Enter}{F6}
Sleep 250
SendInput, /me достал%ok1% пару перчаток из упаковки и надел%ok1% на руки{Enter}{F6}
Sleep 250
SendInput, /do Перчатки на руках.{Enter}
Return

:?:/гарн1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me осмотрел%ok1% уши гражданина{Enter}{F6}
Sleep 250
SendInput, /do Сотрудник увидел ушную гарнитуру?{Enter}{F6}
Sleep 250
SendInput, /b Ответьте отыгровкой в /do Да. или /do Нет.{Enter}
Return

:?:/гарн2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me взял%ok1% пустой зип-пакет и открыл%ok1% его{Enter}{F6}
Sleep 250
SendInput, /do Зип-пакет открыт.{Enter}{F6}
Sleep 250
SendInput, /me достал%ok1% ушную гарнитуру и положил%ok1% в зип-пакет{Enter}{F6}
Sleep 250
SendInput, /do Гарнитура в зип-пакете.{Enter}{F6}
Sleep 250
SendInput, /me положил%ok1% зип-пакет на стол{Enter}{F6}
Sleep 250
SendInput, /do Зип-пакет с ушной гарнитурой на столе.{Enter}
Return

:?:/куртка1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me похлопал%ok1% гражданина по карману куртки{Enter}{F6}
Sleep 250
SendInput, /do Что лежит в кармане?{Enter}{F6}
Sleep 250
SendInput, /b Ответьте отыгровкой в /do о найденных предметах в кармане.{Enter}
Return

:?:/штаны1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me похлопал%ok1% гражданина по карману штанов{Enter}{F6}
Sleep 250
SendInput, /do Что лежит в кармане?{Enter}{F6}
Sleep 250
SendInput, /b Ответьте отыгровкой в /do о найденных предметах в кармане.{Enter}
Return

:?:/штаны2::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput, /Введите предмет ->{Space}
Input, Var1, V, {Enter} 
SendInput, {bs 17} 
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /me засунул%ok1% руку в карман и достал%ok1% %var1%{Enter}{F6}
Sleep 250
SendInput, /do Содержимое кармана в руках.{Enter}{F6}
Sleep 250
SendInput, /me взял%ok1% пустой зип-пакет со стола и открыл%ok1% его{Enter}{F6}
Sleep 250
SendInput, /do Зип-пакет открыт.{Enter}{F6}
Sleep 250
SendInput, /me положил%ok1% в зип-пакет содержимое кармана и закрыл%ok1% его{Enter}{F6}
Sleep 250
SendInput, /do Зип-пакет закрыт.{Enter}
Return

:?:/куртка2::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput, /Введите предмет ->{Space}
Input, Var1, V, {Enter} 
SendInput, {bs 17} 
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /me засунул%ok1% руку в карман и достал%ok1% %var1%{Enter}{F6}
Sleep 250
SendInput, /do Содержимое кармана в руках.{Enter}{F6}
Sleep 250
SendInput, /me взял%ok1% пустой зип-пакет со стола и открыл%ok1% его{Enter}{F6}
Sleep 250
SendInput, /do Зип-пакет открыт.{Enter}{F6}
Sleep 250
SendInput, /me положил%ok1% в зип-пакет содержимое кармана и закрыл%ok1% его{Enter}{F6}
Sleep 250
SendInput, /do Зип-пакет закрыт.{Enter}
Return

:?:/сумка1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me снял%ok1% с гражданина сумку и открыл%ok1% её{Enter}{F6}
Sleep 250
SendInput, /do Сумка открыта.{Enter}{F6}
Sleep 250
SendInput, /me засунув руку в сумку, начал%ok1% доставать содержимое{Enter}{F6}
Sleep 250
SendInput, /do Что сотрудник достал из сумки?{Enter}{F6}
Sleep 250
SendInput, /b Ответьте отыгровкой в /do о найденных предметах в сумке{Enter}
Return

:?:/сумка2::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput, /Введите предмет ->{Space}
Input, Var1, V, {Enter} 
SendInput, {bs 17} 
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /me достал%ok1% из сумки %var1%{Enter}{F6}
Sleep 250
SendInput, /do Содержимое сумки в руках.{Enter}{F6}
Sleep 250
SendInput, /me взял%ok1% пустой зип-пакет со стола и открыл%ok1% его{Enter}{F6}
Sleep 250
SendInput, /do Зип-пакет открыт.{Enter}{F6}
Sleep 250
SendInput, /me положил%ok1% в зип-пакет содержимое сумки и закрыл%ok1% его{Enter}{F6}
Sleep 250
SendInput, /do Зип-пакет закрыт.{Enter}
Return

:?:/багажник::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do В багажнике патрульного авто лежит упаковка с нитриловыми перчатками и зип-пакеты.{Enter}{F6}
Sleep 250
SendInput, /me достал%ok1% пару перчаток из упаковки и надел%ok1% на руки{Enter}{F6}
Sleep 250
SendInput, /do Перчатки на руках.{Enter}{F6}
Sleep 250
SendInput, /me начал%ok1% досматривать багажник авто гражданина{Enter}{F6}
Sleep 250
SendInput, /do Что лежит в багажнике?{Enter}{F6}
Sleep 250
SendInput, /b Ответьте отыгровкой в /do о найденных предметах в багажнике{Enter}
Return

:?:/патроны::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do В сумке лежат пакетики зип-лок.{Enter}{F6}
Sleep 250
SendInput, /me взял%ok1% пакетик зип-лок из сумки{Enter}{F6}
Sleep 250
SendInput, /me взял%ok1% патрон и упаковал%ok1% его в пакет{Enter}{F6}
Sleep 250
SendInput, /do Патрон упакован в пакет зип-лок.{Enter}{F6}
Sleep 250
SendInput, /me убрал%ok1% пакет с патроном в сумку{Enter}
Return

:?:/собес1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Здравствуйте{!} В целях Вашей и моей безопасности. {Enter}{F6}
Sleep 1000
SendInput, Все собеседование будет записываться на нагрудную камеру. {Enter}{F6}
Sleep 1000
SendInput, /do На нагрудном кармане закреплена камера.{Enter}
Return
:?:/собес2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Скажите Ваше ФИО, ваш возраст, сколько лет Вы проживаете в республике?{Enter}{F6}
Sleep 250
SendInput, И какое у вас образование?{Enter}
Return
:?:/собес3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Можно пожалуйста Ваш паспорт?{Enter}
Return
:?:/собес4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Отлично, дайте мне Вашу трудовую книгу.{Enter}
Return
:?:/собес5::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Отлично, дайте мне Ваш диплом.{Enter}
Return
:?:/собес6::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Отлично, дайте мне Ваше водительское удостоверение.{Enter}
Return
:?:/собес7::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Отлично, дайте мне Вашу медицинскую карту.{Enter}
Return
:?:/собес8::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Отлично, дайте мне Ваш военный билет.{Enter}
Return
:?:/собес9::
SendMessage, 0x50,, 0x4190419,, A
Random, Var, 1, 3
TextArray := ["Что такое ДМ?"
, "Что такое СК?"
, "Что такое ТК?"]
SendInput, {F6}
sleep 150
SendInput, % TextArray[Var]
SendInput, {Enter}
Return
:?:/собес10::
SendMessage, 0x50,, 0x4190419,, A
Random, Var, 1, 3
TextArray := ["Что такое РП?"
, "Что такое МГ?"
, "Что такое ПГ?"]
SendInput, {F6}
sleep 150
SendInput, % TextArray[Var]
SendInput, {Enter}
Return
:?:/собес11::
SendMessage, 0x50,, 0x4190419,, A
Random, Var, 1, 3
TextArray := ["Что такое ВХ?"
, "Что такое ДБ?"
, "Что такое БХ?"]
SendInput, {F6}
sleep 150
SendInput, % TextArray[Var]
SendInput, {Enter}
Return
:?:/собес12::
SendMessage, 0x50,, 0x4190419,, A
Random, Var, 1, 3
TextArray := ["Что такое МК?"
, "Что такое ВК?"
, "Что такое Дискорд?"]
SendInput, {F6}
sleep 150
SendInput, % TextArray[Var]
SendInput, {Enter}
Return
:?:/собес13::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Отлично, подождите минуточку.{Enter}
Return
:?:/собес14::
SendMessage, 0x50,, 0x4190419,, A
Random, Var, 1, 5
TextArray := ["/b ДБ МГ РП РПК ТК с расшифровкой и что означает"
, "/b БХ ДМ РП СК ТК с расшифровкой и что означает"
, "/b ДБ МГ ПГ ТЛ РП с расшифровкой и что означает"
, "/b ДБ РК ООС ПГ ТК с расшифровкой и что означает"
, "/b ДМ РП РПК СК ТК с расшифровкой и что означает"]
SendInput, {F6}
sleep 150
SendInput, % TextArray[Var]
SendInput, {Enter}
Return
:?:/собес15::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Присядьте на корточки{Enter}
Return
:?:/собес16::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
Random, Var, 1, 4
TextArray := ["/b Вставайте или не приму!"
, "/b Вставайте!"
, "/b Вставайте дам 5 ранг!"
, "/b Вставайте, дам 10к"]
SendInput, {F6}
sleep 150
SendInput, % TextArray[Var]
SendInput, {Enter}
Return
:?:/собес17::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Вставайте{Enter}
Return
:?:/собес18::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Что у меня в руке?{Enter}
Return
:?:/отказ::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, К сожалению вам отказано в трудоустройстве.{Enter}{F6}
Sleep 250
SendInput, /b У вас были некоторые ошибки при отыгрывании команд me, do. Поэтому стоит немного подучить их{Enter}{F6}
Sleep 1000
SendInput, /b https://vk.cc/c3UAyw(Скопировать в F8) Там есть вся информация по поводу отыгровок.{Enter}
Return
:?:/пасс1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me взял%ok1% паспорт у человека напротив{Enter}{F6}
sleep 1000
SendInput, /do Паспорт в руке.{Enter}{F6}
sleep 1000
SendInput, /me открыл%ok1% нужную страницу в паспорте и начал%ok1% его изучать{Enter}{F6}
sleep 1000
SendInput, /do Паспорт изучен.{Enter}{F6}
sleep 1000
SendInput, /me закрыл%ok1% паспорт и передал%ok1% его человеку напротив{Enter}{F6}
sleep 1000
SendInput, /do Рука протянута.{Enter}{F6}
Sleep 1000  
SendInput, Держите ваш паспорт.{Enter}
Return
:?:/диплом1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me взял%ok1% диплом у человека напротив{Enter}{F6}
sleep 1000
SendInput, /do Диплом в руке.{Enter}{F6}
sleep 1000
SendInput, /me начал%ok1% изучать диплом{Enter}{F6}
sleep 1000
SendInput, /do Диплом изучен.{Enter}{F6}
sleep 1000
SendInput, /me передал%ok1% диплом человеку напротив{Enter}{F6}
sleep 1000
SendInput, /do Рука протянута.{Enter}{F6}
Sleep 1000  
SendInput, Держите ваш диплом.{Enter}
Return
:?:/труд1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me взял%ok1% трудовую книгу{Enter}{F6}
sleep 1000
SendInput, /do Трудовая книга в руке.{Enter}{F6}
sleep 1000
SendInput, /me открыл%ok1% нужную страницу и изучил%ok1% информацию{Enter}{F6}
sleep 1000
SendInput, /do Трудовая изучена.{Enter}{F6}
sleep 1000
SendInput, /me закрыл%ok1% трудовую книгу и передал%ok1% человеку{Enter}{F6}
sleep 1000
SendInput, /do Рука протянута.{Enter}{F6}
Sleep 1000  
SendInput, Держите вашу трудовую книгу.{Enter}
Return
:?:/ву1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me взял%ok1% водительское удостоверение у человека напротив{Enter}{F6}
sleep 1000
SendInput, /do Водительское удостоверение в руке.{Enter}{F6}
sleep 1000
SendInput, /me открыл%ok1% нужную страницу в водительском удостоверении и начал%ok1% его изучать{Enter}{F6}
sleep 1000
SendInput, /do Водительское удостоверение изучено.{Enter}{F6}
sleep 1000
SendInput, /me закрыл%ok1% водительское удостоверение и передал%ok1% его человеку напротив{Enter}{F6}
sleep 1000
SendInput, /do Рука протянута.{Enter}{F6}
Sleep 1000  
SendInput, Держите ваше водительское удостоверение.{Enter}
Return
:?:/карта1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me взял%ok1% медицинскую карту у человека напротив{Enter}{F6}
sleep 1000
SendInput, /do Медицинская карта в руке.{Enter}{F6}
sleep 1000
SendInput, /me открыл%ok1% нужную страницу в медицинской карте и начал%ok1% ее изучать{Enter}{F6}
sleep 1000
SendInput, /do Медицинская карта изучена.{Enter}{F6}
sleep 1000
SendInput, /me закрыл%ok1% медицинскую карту и передал%ok1% его человеку напротив{Enter}{F6}
sleep 1000
SendInput, /do Рука протянута.{Enter}{F6}
Sleep 1000  
SendInput, Держите вашу медицинскую карту.{Enter}
Return
:?:/вб1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me взял%ok1% военный билет у человека напротив{Enter}{F6}
sleep 1000
SendInput, /do Военный билет в руке.{Enter}{F6}
sleep 1000
SendInput, /me открыл%ok1% нужную страницу в военном билете и начал%ok1% его изучать{Enter}{F6}
sleep 1000
SendInput, /do Военный билет изучен.{Enter}{F6}
sleep 1000
SendInput, /me закрыл%ok1% военный билет и передал%ok1% его человеку напротив{Enter}{F6}
sleep 1000
SendInput, /do Рука протянута.{Enter}{F6}
Sleep 1000  
SendInput, Держите ваш военный билет.{Enter}
Return
:?:/выдформу::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do В шкафчике находится форма сотрудника.{Enter}{F6}
Sleep 500 ;
SendInput, /do Шкаф закрыт.{Enter}{F6}
Sleep 500 ;
SendInput, /do Ключ лежит на скамейке.{Enter}{F6}
Sleep 500 ;
SendInput, Берите ключ, открывайте шкаф, переодевайтесь.{Enter}
Return
:?:/штраф::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me достав служебный планшет из сумки, запустил%ok1% его{Enter}{F6}
Sleep 500 ;
SendInput, /me внес%ok2% данные о нарушении гражданина в базу{Enter}{F6}
Sleep 500 ;
SendInput, /do Данные введены.{Enter}
Sleep 50
SendInput,{F6}
Sleep 100
SendInput,/tsu{Space}
Return
:?:/мвд::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput, /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput, /ro [ГУ МВД-%Bukv%][МВД]{Space}
Return
:?:/гибдд::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][УГИБДД]{Space}
Return
:?:/ржд::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][ОАО «РЖД»]{Space}
Return
:?:/мз::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][МЗ]{Space}
Return
:?:/армия::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][МО]{Space}
Return
:?:/гибддп::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][УГИБДД-П]{Space}
Return
:?:/гибддм::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][УГИБДД-М]{Space}
Return
:?:/гибддн::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][УГИБДД-Н]{Space}
Return
:?:/гувдп::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][ГУ МВД-П]{Space}
Return
:?:/гувдм::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /ro [Г УМВД-%Bukv%][ГУ МВД-М]{Space}
Return
:?:/гувдн::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][ГУ МВД-Н]{Space}
Return
:?:/цгбп::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][ЦГБ-П]{Space}
Return
:?:/окбм::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][ОКБ-М]{Space}
Return
:?:/цгбн::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][ЦГБ-Н]{Space}
Return

:?:/осндокл::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /d [%Osn%]{Space}
Return
:?:/оснвыз::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput,  /ro [%Osn%]{Space}
Return
:?:/помощьсобес::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
PlayRadioSfx("radio_start.wav")
sleep 160
SendInput, /d [ГУ МВД-%Bukv%][МВД|МЗ|МО] Требуются сотрудники для помощи в проведении собеседования...{Enter}{F6}
Sleep 500
SendInput, /d [ГУ МВД-%Bukv%][МВД|МЗ|МО] ...Ожидаем на парковке ДЧ г. Невский.{Enter}{F6}
sleep 160
PlayRadioSfx("radio_start.wav")
Sleep 1000
SendInput,  /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Sleep 1000
Return
:?:/проверкасобес::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
SendInput, {F6}
Sleep 250
SendInput, /Введите серию паспорта (через дефис) ->{Space}
Input, Pass, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput,  /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput,  /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
PlayRadioSfx("radio_start.wav")
sleep 500
SendInput, /d [ГУ МВД-%Bukv%][УГИБДД] Проверьте гражданина с серией паспорта %Pass%...{Enter}{F6}
sleep 500
SendInput, /d [ГУ МВД-%Bukv%][УГИБДД] ...на штрафы.{Enter}{F6}
sleep 160
PlayRadioSfx("radio_start.wav")
Sleep 1000
SendInput,  /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Sleep 1000
Return
:?:/стук::
SendMessage, 0x50,, 0x4190419,, A
Sleep 100
SendInput, {Enter}
Sleep 250
SendInput, {F8}me постучал%ok1% в окно{Enter}{F8}
Return
^sc29::
SendMessage, 0x50,, 0x4190419,, A
Sleep 250
SendInput, {F8}me постучал%ok1% в окно{Enter}{F8}
Return
:?:/окно?::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,  /do Водительское окно открыто?{Enter}
Return
:?:/ударкалаш::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,  /me замахнул%ok3% прикладом АК-74м{Enter}{F6}
Sleep 200 ;
SendInput,  /try разбил%ok1% окно{Enter}
Return
:?:/ударпистолет::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,  /me замахнул%ok3% рукоятью пистолета{Enter}{F6}
Sleep 200 ;
SendInput,  /try разбил%ok1% окно{Enter}
Return
:?:/удардробовик::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,  /me замахнул%ok3% прикладом дробовика{Enter}{F6}
Sleep 200 ;
SendInput,  /try разбил%ok1% окно{Enter}
Return
:?:/выдпогоны::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /Введите погоны должности ->{Space}
Input, Var1, V, {Enter} 
SendInput, {bs 17} 
Sleep 250
SendInput, {F6}
Sleep 1700
SendInput, /do В багажнике лежат погоны "%var1%". {Enter}{F6}
Sleep 1700
SendInput, Берите из багажника новые погоны, и прикрепите их на плечи{!}{Enter}
Return
:?:/кпкповышение::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /Введите ID сотрудника которого хотите повысить ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /Введите номер должности ->{Space}
Input, Var2, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /do Служебный планшет марки “MIG LT11i” в сумке.{Enter}{F6}
Sleep 800
SendInput, /me достав служебный планшет из сумки, запустил%ok1% его{Enter}{F6}
sleep 1700
SendInput, /me вв%ok8% данные об повышении сотрудника {Enter}{F6}
sleep 1700
SendInput, /me выключил%ok1% служебный планшет и убрал%ok1% в сумку{Enter}{F6}
Sleep 250
SendInput, /giverank %Var1% %Var2%{Enter}{F6}
Sleep 250
SendInput, /timestamp {Enter}
sleep 500
Return
:?:/кпкпонижение::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /Введите ID сотрудника которого хотите понизить ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /Введите номер должности ->{Space}
Input, Var2, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /do Служебный планшет марки “MIG LT11i” в сумке.{Enter}{F6}
Sleep 800
SendInput, /me достав служебный планшет из сумки, запустил%ok1% его{Enter}{F6}
sleep 1700
SendInput, /me вв%ok8% данные об понижении сотрудника {Enter}{F6}
sleep 1700
SendInput, /me выключил%ok1% служебный планшет и убрал%ok1% в сумку{Enter}{F6}
Sleep 250
SendInput, /giverank %Var1% %Var2%{Enter}
Sleep 250
Return
:?:/кпкувал::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /Введите ID сотрудника которого хотите уволить ->{Space}
Input, Var, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /do Служебный планшет марки “MIG LT11i” в сумке.{Enter}{F6}
Sleep 800
SendInput, /me достав служебный планшет из сумки, запустил%ok1% его{Enter}{F6}
Sleep 800
SendInput, /me запустил%ok1% приложение БД{Enter}{F6}
Sleep 800
SendInput, /do Приложение "База Данных" включено.{Enter}{F6}
Sleep 800
SendInput, /me удалил%ok1% всю информацию о сотруднике и перенес%ok2% его в лист "Уволенные"{Enter}{F6}
Sleep 800
SendInput, /do Информация о сотруднике удалена.{Enter}{F6}
Sleep 800
SendInput, /me выключил%ok1% служебный планшет и убрал%ok1% в сумку{Enter}
Sleep 800
Return
:?:/кпкпринятие::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /Введите ID сотрудника которого хотите принять ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /do Служебный планшет марки “MIG LT11i” в сумке. {Enter}{F6}
Sleep 800
SendInput, /me достав служебный планшет из сумки, запустил%ok1% его {Enter}{F6}
Sleep 800
SendInput, /me запустил%ok1% приложение БД {Enter}{F6}
Sleep 800
SendInput, /do Приложение "База Данных" включено. {Enter}{F6}
Sleep 800
SendInput, /me занес%ok2% информацию о сотруднике и перенес%ok2% его в лист "Принятые" {Enter}{F6}
Sleep 800
SendInput, /do Информация о сотруднике занесена. {Enter}{F6}
Sleep 800
SendInput, /me выключил%ok1% служебный планшет и убрал%ok1% в сумку {Enter}{F6}
Sleep 800
SendInput, /invite %Var1% {Enter}
Return
:?:/ооп1::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Osn, %A_Temp%\gumvd.egl, User, Osn
SendInput, {F6}
Sleep 250
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% её ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput, /ro [%Osn%][МВД] Начали спец. операцию по отлову ООП по Республике Провинции.{Enter}{F6}
Sleep 200 ;
SendInput, /me перевел%ok1% рацию в режим прослушивания и закрепил%ok1% на нагрудном кармане{Enter}
Return
:?:/ооп2::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Osn, %A_Temp%\gumvd.egl, User, Osn
SendInput, {F6}
Sleep 250
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% её ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput, /ro [%Osn%][МВД] Продолжаем спец. операцию по отлову ООП по Республике Провинции.{Enter}{F6}
Sleep 200 ;
SendInput, /me перевел%ok1% рацию в режим прослушивания и закрепил%ok1% на нагрудном кармане{Enter}
Return
:?:/ооп3::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Osn, %A_Temp%\gumvd.egl, User, Osn
SendInput, {F6}
Sleep 250
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% её ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 500 ;
SendInput, /ro [%Osn%][МВД] Закончили спец. операцию по отлову ООП по Республике Провинции.{Enter}{F6}
Sleep 200 ;
SendInput, /me перевел%ok1% рацию в режим прослушивания и закрепил%ok1% на нагрудном кармане{Enter}
Return
:?:/пмп1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do Аптечка ПМП "ФЭСТ" находится в багажнике автомобиля.{Enter}{F6}
Sleep 500 ;
SendInput, /me взя%ok2% аптечку из багажника{Enter}{F6}
Sleep 500 ;
SendInput, /do Аптечка ПМП "ФЭСТ" в руке.{Enter}
Return
:?:/пмп2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 500
SendInput, /do Что случилось с пострадавшим?{Enter}{F6}
Sleep 500
SendInput, /b Напишите в чат через команду /do, что с вами случилось{Enter}{F6}
Sleep 500
SendInput, /b Пример: /do Пострадавшего сбила машина.{Enter}
Return
:?:/пмп3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me поднес%ok2% руку к сонной артерии гражданина{Enter}{F6}
Sleep 500 ;
SendInput, /do Рука поднесена к сонной артерии пациента.{Enter}{F6}
Sleep 500 ;
SendInput, /do Пульс обнаружен?{Enter}{F6}
Sleep 500 ;
SendInput, /b Ответьте РП отыгровкой в чат: /do Да. или /do Нет.{Enter}{F6}
Sleep 500 ;
SendInput, /b Чат открывается на клавишу F6 и туда прописываются эти команды.{Enter}
Return
:?:/пмп4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do Аптечка ПМП "ФЭСТ" в руке.{Enter}{F6}
Sleep 500 ;
SendInput, /me поставил%ok1% аптечку на землю, открыл%ok1% её{Enter}{F6}
Sleep 500 ;
SendInput, /do Аптечка ПМП "ФЭСТ" открыта.{Enter}
Return
:?:/пмп5::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 500 ;
SendInput, /me доста%ok2% спирт и вату из аптечки{Enter}{F6}
Sleep 500 ;
SendInput, /do Спирт и кусочек ваты в руках.{Enter}{F6}
Sleep 250
SendInput, /me смочив вату нашатырным спиртом, прове%ok7% ею около носа пострадавшего{Enter}{F6}
Sleep 500 ;
SendInput, /me откинув использованный кусочек ваты на землю, постави%ok2% спирт в аптечку{Enter}{F6}
Sleep 500 ;
SendInput, /do Нашатырный спирт в Аптечке ПМП "ФЭСТ".{Enter}{F6}
Sleep 500 ;
SendInput, /me закрыв аптечку, взял%ok1% её в руку{Enter}{F6}
Sleep 500 ;
SendInput, /do Аптечке ПМП "ФЭСТ" в руке.{Enter}{F6}
Sleep 500 ;
SendInput, /do Пострадавший пришёл в сознание?{Enter}{F6}
Sleep 500 ;
SendInput, /b Ответьте РП отыгровкой в чат: /do Да. или /do Нет.{Enter}{F6}
Sleep 500 ;
SendInput, /b Чат открывается на клавишу F6 и туда прописываются эти команды.{Enter}
Return
:?:/пмп6::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do Аптечка ПМП "ФЭСТ" в руке.{Enter}{F6}
Sleep 500 ;
SendInput, /me положи%ok2% аптечку в багажник{Enter}
Return
:?:/оранения::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
sleep 250
SendInput, /me начал%ok1% осматривать тело пострадавшего{Enter}{F6}
sleep 1700
SendInput, /do Сотрудни%ok5% осматривает всё тело пострадавшего.{Enter}{F6}
sleep 1700
SendInput, /do Какие ранения и травмы имеются на теле?{Enter}{F6}
sleep 1000
SendInput, /b Ответьте РП отыгровкой /do в чат. Можете написать про ссадины, порезы, ушибы. {Enter}{F6}
sleep 1000
SendInput, /b Пример: /do На теле пострадавшего ножевое ранение; /do На теле пострадавшего кровотечение.{Enter}
Return
:?:/пулевое::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do В аптечке лежат жгут, шприц с обезболивающим, ватка и медицинский спирт.{Enter}{F6}
Sleep 500
SendInput, /me открыл%ok1% аптечку и достал%ok1% из нее жгут{Enter}{F6}
Sleep 500
SendInput, /me развязав жгут, надел%ok1% его чуть выше пулевого отверстия{Enter}{F6}
Sleep 500
SendInput, /me затянул%ok1% ремешок жгута{Enter}{F6}
Sleep 500
SendInput, /do Жгут затянут.{Enter}
Return
:?:/переломз::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do В аптечке лежат шина, бинт и холодный компресс.{Enter}{F6}
Sleep 500
SendInput, /me вытащил%ok1% из аптечки шину и бинт{Enter}{F6}
Sleep 500
SendInput, /me застегнул%ok1% шину на поврежденной конечности пострадавшего{Enter}{F6}
Sleep 500
SendInput, /do Шина застегнута.{Enter}{F6}
Sleep 500
SendInput, /me достал%ok1% из медицинской сумки холодный компресс{Enter}{F6}
Sleep 500
SendInput, /me приложил%ok1% компресс к поврежденной конечности пострадавшего{Enter}{F6}
Sleep 500
SendInput, /do Компрессор наложен.{Enter}
Return
:?:/переломо::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do В аптечке лежат жгут, вата, спиртовой раствор йода и шина.{Enter}{F6}
Sleep 500
SendInput, /me открыл%ok1% аптечку и достал%ok1% из нее жгут{Enter}{F6}
Sleep 500
SendInput, /me наложил%ok1% жгут выше раны пострадавшего{Enter}{F6}
Sleep 500
SendInput, /me достал%ok1% из медицинской сумки вату и спиртовой раствор йода{Enter}{F6}
Sleep 500
SendInput, /me смочил%ok1% ватку йодом{Enter}{F6}
Sleep 500
SendInput, /do Ватка смоченная йодом.{Enter}{F6}
Sleep 500
SendInput, /me обработал%ok1% рану ватой{Enter}{F6}
Sleep 500
SendInput, /do Рана обработана.{Enter}{F6}
Sleep 500
SendInput, /me вытащил%ok1% из аптечки шину и бинт{Enter}{F6}
Sleep 500
SendInput, /me застегнул%ok1% шину на поврежденной конечности пострадавшего.{Enter}{F6}
Sleep 500
SendInput, /do Шина застегнута.{Enter}
Return
:?:/ушиб::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do В аптечке лежат холодный компресс, гепариновая мазь и бинт.{Enter}{F6}
Sleep 500
SendInput, /me открыл%ok1% аптечку и достал%ok1% из нее холодный компресс{Enter}{F6}
Sleep 500
SendInput, /me приложил%ok1% компресс к месту ушиба пострадавшего{Enter}{F6}
Sleep 500
SendInput, /me достал%ok1% из аптечки гепариновую мазь{Enter}{F6}
Sleep 500
SendInput, /me намазал%ok1% место ушиба гепариновой мазью{Enter}{F6}
Sleep 500
SendInput, /me достал%ok1% из аптечки бинт{Enter}{F6}
Sleep 500
SendInput, /me наложил%ok1% повязку на место ушиба{Enter}{F6}
Sleep 500
SendInput, /do Повязка наложена.{Enter}
Return
:?:/кровь::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do В аптечке лежат бинты.{Enter}{F6}
Sleep 500
SendInput, /me достал%ok1% две упаковки бинтов{Enter}{F6}
Sleep 500
SendInput, /me открыв бинты, отбросил%ok1% упаковку на землю{Enter}{F6}
Sleep 500
SendInput, /me приложил%ok1% один валик к месту ранения{Enter}{F6}
Sleep 500
SendInput, /me размотав второй валик бинта, наложил%ok1% его на место ранения{Enter}{F6}
Sleep 500
SendInput, /do Давящая повязка наложена.{Enter}
Return
:?:/пульс-::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me проводит непрямой массаж сердца пострадавшему, надавливая на грудную клетку {Enter}{F6}
sleep 1000
SendInput, /do Сотрудни%ok5% выполняет непрямой массаж сердца. {Enter}{F6}
sleep 1000
SendInput, /me прислонил%ok1% руку к сонной артерии гражданина {Enter}{F6}
sleep 1000
SendInput, /do Пульс обнаружен? {Enter}{F6}
sleep 1000
SendInput, /b Ответьте РП отыгровкой в чат: /do Да. или /do Нет. {Enter}
Return
:?:/вступление::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Сейчас я проведу вам вступительную лекцию.{Enter}{F6}
Sleep 2000
SendInput, Поздравляем вас с поступлением в ГУ МВД по г.Приволжск, соответственно {Enter}{F6}
Sleep 2000
SendInput, Вы должны забыть о таких словах как - "Хорошо", "Да", "Нет", "Можно". Такие слова неприемлемы.{Enter}{F6}
Sleep 2000
SendInput, Вы обязаны говорить по форме - "Есть{!}", "Так точно{!}", "Никак нет{!}", "Разрешите{!}".{Enter}{F6}
Sleep 2000
SendInput, А так же вы должны знать КоАП, УК, ФЗоП и ПДД.{Enter}{F6}
Sleep 2000
SendInput, Соответственно "Рядовой" служит в отделе УЦ.{Enter}{F6}
Sleep 2000
SendInput, Вы находитесь в звании "Рядовой", на должности "Курсант УЦ".{Enter}{F6}
Sleep 2000
SendInput, Начальник управления ГУ МВД-П: Десайз Алиса.{Enter}{F6}
Sleep 2000
SendInput, Первый Заместитель Начальника управления ГУ МВД-Н: Стапстов Равшан Ашотович.{Enter}{F6}
Sleep 2000
SendInput, Второй Заместитель Начальника управления ГУ МВД-Н: Отсутствует.{Enter}{F6}
Sleep 2000
SendInput, Начальник Учебного Центра сейчас: Отсутствует.{Enter}{F6}
Sleep 2000
SendInput, Заместитель начальника Учебного Центра: Отсутствует.{Enter}{F6}
Sleep 2000
SendInput, В звании "Рядовой" вам разрешено брать только дубинку, бронежилет и электрошокер, наручники.{Enter}{F6}
Sleep 2000
SendInput, Рядовым строго запрещено ездить за рулём патрульного авто{!} {Enter}{F6}
Sleep 2000
SendInput, Для того, чтобы повыситься до звания "Сержант"{Enter}{F6}
Sleep 2000
SendInput, Вам необходимо выполнить опеределенную норму.{Enter}{F6}
Sleep 2000
SendInput, /b Критерии есть на форуме.{Enter}{F6}
Sleep 2000 ;
SendInput, После поступления, вам в срочном порядке,{Enter}{F6}
Sleep 2000
SendInput, Требуется установить удостоверение{!}{Enter}{F6}
Sleep 2000
SendInput, Далее Вы проходите экзамен у начальства отдела Учебного Центра.{Enter}{F6}
Sleep 2000
SendInput, Если Вы не прошли экзамен с первого раза, Вы должны будете сдать его повторно.{Enter}{F6}
Sleep 2000
SendInput, Исключения:{Enter}{F6}
Sleep 2000
SendInput, Если вы отписали причину в спец. связи.{Enter}{F6}
Sleep 2000
SendInput, Сейчас я расскажу про автомобили:{Enter}{F6}
Sleep 2000
SendInput, Со звания "Старшина" Вы можете брать служебный автомобиль - Lada Priora,УАЗ Патриот,Chevrolet Cruze.{Enter}{F6}
Sleep 2000
SendInput, Со звания "Прапорщик" Вы имеете право брать служебный автомобиль - Toyota Camry.{Enter}{F6}
Sleep 2000
SendInput, Со звания "Лейтенант-Майор" Вы имеете право брать служебный автомобиль-Audi S8 Plus, Audi Q7TDI.{Enter}{F6}
Sleep 2000
SendInput, Audi S8 Plus [при наличии напарника].{Enter}{F6}
Sleep 2000
SendInput, Теперь я расскажу про оружие{Enter}{F6}
Sleep 2000
SendInput, Со звания "Рядовой" Вы имеете право брать дубинку.{Enter}{F6}
Sleep 2000
SendInput, Со звания "Рядовой" Вы имеете право брать электрошокер.{Enter}{F6}
Sleep 2000
SendInput, Со звания "Старшина" Вы имеете право брать пистолет.{Enter}{F6}
Sleep 2000
SendInput, Со звания "Лейтенант" вам разрешено брать Автомат АК-47.{Enter}{F6}
Sleep 2000
SendInput, Дробовик разрешено использовать только со звания "Полковник".{Enter}{F6}
Sleep 2000
SendInput, Каждый сотрудник Учебного Центра обязан составить отчет на повышение по мере выполнения нормы.{Enter}{F6}
Sleep 2000
SendInput, После сдачи отчета и его одобрения, сотрудник Учебного Центра повышается.{Enter}{F6}
Sleep 3000
SendInput, Рядовому дается 5 дней для повышения на Сержанта.{Enter}{F6}
Sleep 2000
SendInput, Сержанту дается 7 дней для повышения на Старшину.{Enter}{F6}
Sleep 2000
SendInput, Если по каким-то причинам вы не успеваете{Enter}{F6}
Sleep 2000
SendInput, Вы должны сообщить об этом начальнику Учебного Центра или вышестоящему руководству.{Enter}{F6}
Sleep 2000
SendInput, /b В случае если вы чего-то не поняли, задавайте ваши вопросы в беседу УЦ ВКонтакте.{Enter}{F6}
Sleep 2000
SendInput, /b В закрепленном сообщении "Флудилки" вы можете найти все нужные вам ссылки.{Enter}{F6}
Sleep 2000
SendInput, В гараже запрещено спать более 15 минут, на улице или в ДЧ больше 5 минут.{Enter}{F6}
Sleep 2000
SendInput, И больше 2-х минут при взаимодействии с гражданскими.{Enter}{F6}
Sleep 2000
SendInput, О том когда пройдет мероприятие, тренировка и другая важная информация{Enter}{F6}
Sleep 2000
SendInput, Вы можете узнать в Доске Объявлений.{Enter}{F6}
Sleep 2000
SendInput, Есть вопросы по этой лекции?{Enter}
Sleep 2000
Return

:?:/Аоформление::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Сейчас пройдет лекция "Процедура оформления".{Enter}{F6}
Sleep 2000
SendInput, Данная лекция расскажет Вам о том, как правильно производить составление протоколов.{Enter}{F6}
Sleep 2000
SendInput, Протокол - документ, фиксирующий какое либо событие или действие.{Enter}{F6}
Sleep 2000
SendInput, Протокол оформляется в таких ситуациях, как например произведение ареста{Enter}{F6}
Sleep 500
SendInput, или выписка административного штрафа.{Enter}{F6}
Sleep 2000
SendInput, Мы рассмотрим две ситуации, при которых составляется протокол, в нашем случае - протокол ареста.{Enter}{F6}
Sleep 2000
SendInput, Этот протокол составляется перед тем, как гражданин передается конвоиру для передачи в КПЗ.{Enter}{F6}
Sleep 2000
SendInput, Или же при оформлении в ДЧ, в которой Вы самостоятельно отправляется гражданина в КПЗ.{Enter}{F6}
Sleep 2000
SendInput, Перед тем, как составить протокол, необходимо опознать личность задержанного,{Enter}{F6}
Sleep 500
SendInput, если это не известно{Enter}{F6}
Sleep 2000
SendInput, После того, как Вы опознали личность гражданина, вы озвучиваете ему статьи.{Enter}{F6}
Sleep 2000
SendInput, Согласно которым, он будет лишен свободы на определенное время.{Enter}{F6}
Sleep 2000
SendInput, Также, вы должны называть гражданину, на сколько лет он будет лишен свободы.{Enter}{F6}
Sleep 2000
SendInput, В протокол вносятся следующие данные:{Enter}{F6}
Sleep 2000
SendInput,  личность, нарушенная статья гражданином, дата и время составления протокола.{Enter}{F6}
Sleep 2000
SendInput, После составления протокола гражданину дается право подписать его.{Enter}{F6}
Sleep 500
SendInput, Если он отказывается или не отвечает{Enter}{F6}
Sleep 500
SendInput, делаете пометку об отказе.{Enter}{F6}
Sleep 2000
SendInput, В случае, если гражданин находится в наручниках, Вы должны спросить, согласен ли он{Enter}{F6}
Sleep 500
SendInput,  Со своими нарушениями.{Enter}{F6}
Sleep 2000 ;
SendInput, В случае согласия/несогласия, ставится определенная метка в протоколе.{Enter}{F6}
Sleep 2000
SendInput, /b me поставил метку о несогласии/согласии c нарушением{Enter}{F6}
Sleep 2000
SendInput,  Если гражданин в наручниках, в протокол также заносится метка о невозможности подписания.{Enter}{F6}
Sleep 2000
SendInput, /b me поставил метку о невозможности подписания{Enter}{F6}
Sleep 2000
SendInput,  Важно помнить, что протокол составляется не 3 секунды.{Enter}{F6}
Sleep 2000
SendInput, Вы должны составить протокол не менее, чем за 15 секунд.{Enter}{F6}
Sleep 2000
SendInput, /b вы пишите отыгровки вручную, либо задерживаете клавишу с биндом на 15 секунд.{Enter}{F6}
Sleep 2000
SendInput, После составления протокола, вам нужно выдать розыск гражданину, если он не состоит в ФР.{Enter}{F6}
Sleep 2000
SendInput, /b /su [ID] [кол-во звезд] [причина]{Enter}{F6}
Sleep 2000
SendInput, После выдачи розыска, гражданский передается конвоиру или его заводят в КПЗ.{Enter}{F6}
Sleep 2000
SendInput, На этом лекция «Процедура оформления» окончена.{Enter}{F6}
Sleep 2000
Return

:?:/4.1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 4.1 УК РП - Умышленное причинение вреда здоровью человека.{Enter}{F6}
Sleep 250 
SendInput, без летального исхода. 1 год заключения.{Enter}{F6}
Return

:?:/4.2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 4.2 УК РП - Доведение до предсметного состояния.{Enter}{F6}
Sleep 250 
SendInput, 2 год заключения.{Enter}{F6}
Return

:?:/421::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 4.2.1 УК РП - Умышленное избиение двум или более лицам.{Enter}{F6}
Sleep 250 
SendInput, от 4 до 6 лет заключения.{Enter}{F6}
Return

:?:/4.3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Угроза нанесения или причинения вреда здоровью человека.{Enter}{F6}
Sleep 250 
SendInput,1 год заключения.{Enter}{F6}
Return

:?:/4.4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 4.4 УК РП - Похищение человека,незаконное лишение свободы.{Enter}{F6}
Sleep 250 
SendInput,от 4 до 6 лет заключения.{Enter}{F6}
Return

:?:/4.5::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 4.5 УК РП - Домогательство.{Enter}{F6}
Sleep 250 
SendInput,от 3 до 6 лет заключения.{Enter}{F6}
Return

:?:/4.6::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 4.6 УК РП - Незаконный сбор или распространение личных или семейных{Enter}{F6}
Sleep 250 
SendInput,тайн без согласия лица. 1 год заключения.{Enter}{F6}
Return

:?:/5.1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.1 УК РП - Получение должностным лицом взятки.{Enter}{F6}
Sleep 250 
SendInput,3 года заключения.{Enter}{F6}
Return

:?:/5.2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.2 УК РП - Дача взятки/Попытка дачи взятки должностному лицу.{Enter}{F6}
Sleep 250 
SendInput,3 года заключения.{Enter}{F6}
Return

:?:/5.3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.3 УК РП - Посягательство на жизнь/здоровье сотрудника.{Enter}{F6}
Sleep 250 
SendInput,от 3 до 6 лет заключения.{Enter}{F6}
Return

:?:/5.4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.4 УК РП - Насилие/Угроза жизни сотруднику/Близким.{Enter}{F6}
Sleep 250 
SendInput,до 3 лет заключения.{Enter}{F6}
Return

:?:/5.5::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.5 УК РП - Хамство/борзость/дерзость в сторону сотрудника МВД.{Enter}{F6}
Sleep 250 
SendInput,1 год заключения.{Enter}{F6}
Return

:?:/5.6::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.6 УК РП - Публичное оскорбление сотрудника полиции.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/5.7::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.7 УК РП - Провокация сотрудников полиции.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/571::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.7.1 УК РП - Преследование экипажа сотрудников полиции/Создание помех сотрудникам.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/5.8::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.8 УК РП - Неподчинение сотрудникам МВД.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/581::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.8.1 УК РП - Уход от МВД с нанесением ущерба имуществу гражданским.{Enter}{F6}
Sleep 250 
SendInput,3 года заключения.{Enter}{F6}
Return

:?:/582::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.8.2 УК РП - Уход от МВД с причинением телесного вреда гражданскому.{Enter}{F6}
Sleep 250 
SendInput,4 года заключения.{Enter}{F6}
Return

:?:/5.9::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.9 УК РП - Порча гос. имущества.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/510::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.10 УК РП - Дача ложных показаний.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/512::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.12 УК РП - Представление себя в качестве сотрудника гос.службы.{Enter}{F6}
Sleep 250 
SendInput,1 год заключения.{Enter}{F6}
Return

:?:/513::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 5.13 УК РП - Ненадлежащее исполнение должностным лицом своих обязанностей.{Enter}{F6}
Sleep 250 
SendInput,3 года заключения.{Enter}{F6}
Return


:?:/6.1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.1 УК РП - Терроризм.{Enter}{F6}
Sleep 250 
SendInput,до 6 лет заключения.{Enter}{F6}
Return

:?:/6.3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.3 УК РП - Захват или удержание человека в заложниках.{Enter}{F6}
Sleep 250 
SendInput,3 года заключения.{Enter}{F6}
Return

:?:/6.4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.4 УК РП - Организация массовых беспорядков.{Enter}{F6}
Sleep 250 
SendInput,до 6 лет заключения.{Enter}{F6}
Return

:?:/6.6::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.6 УК РП - Вандализм, порча имущества общества.{Enter}{F6}
Sleep 250 
SendInput,1 год заключения.{Enter}{F6}
Return

:?:/6.7::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.7 УК РП - Проникновение в жилище, частную территорию либо иной объект.{Enter}{F6}
Sleep 250 
SendInput,не принадлежащий проникшему лицу, совершенное против воли проживающего в нем лица.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/6.8::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.8 УК РП - Проникновение на закрытую территорию.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/6.9::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.9 УК РП - Хранение, использование, оружие.{Enter}{F6}
Sleep 250 
SendInput,3 года заключения.{Enter}{F6}
Return

:?:/610::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.10 УК РП - Хранение, изготовление, продажа наркотиков.{Enter}{F6}
Sleep 250 
SendInput,3 года заключения.{Enter}{F6}
Return


:?:/611::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.11 УК РП - Неоказание пмп.{Enter}{F6}
Sleep 250 
SendInput,1 год заключения.{Enter}{F6}
Return

:?:/612::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.12 УК РП - Попытка срыва мероприятия/Помеха в проведении МП{Enter}{F6}
Sleep 250 
SendInput,3 года заключения.{Enter}{F6}
Return

:?:/613::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.13 УК РП - Использование поддельных документов.{Enter}{F6}
Sleep 250 
SendInput,3 года заключения.{Enter}{F6}
Return

:?:/614::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 6.14 УК РП - Превышение должностных полномочий.{Enter}{F6}
Sleep 250 
SendInput,3 года заключения.{Enter}{F6}
Return


:?:/7.1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 7.1 УК РП - Хищение чужого имущества.{Enter}{F6}
Sleep 250 
SendInput,3 года заключения.{Enter}{F6}
Return

:?:/7.2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 7.2 УК РП - Грабеж или кража чужого имущества.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/7.3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 7.3 УК РП - Вымогательство - требование передачи чужого имущества.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/7.4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 7.4 УК РП - Повреждение или уничтожение чужого имущества.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/7.5::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 7.5 УК РП - Организация/проведение азартных игр в общ местах.{Enter}{F6}
Sleep 250 
SendInput,2 года заключения.{Enter}{F6}
Return

:?:/191::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 19.1 КоАП - Мелкое хулиганство.{Enter}{F6}
Sleep 250 
SendInput,Административный арест 10 суток.{Enter}{F6}
Return

:?:/192::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 19.2 КоАП - Оскорбление, унижение чести и достоинства другого лица.{Enter}{F6}
Sleep 250 
SendInput,Административный арест 10 суток.{Enter}{F6}
Return

:?:/193::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 19.3 КоАП - Нанесение побоев или совершение иных насильственных действий.{Enter}{F6}
Sleep 250 
SendInput,Административный арест 10 суток.{Enter}{F6}
Return

:?:/194::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 19.4 КоАП - Распитие алкогольной продукции в общественных местах.{Enter}{F6}
Sleep 250 
SendInput,Штраф 5000 рублей.{Enter}{F6}
Return

:?:/195::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 19.5 КоАП - Занятие попрошайничеством в общественных местах.{Enter}{F6}
Sleep 250 
SendInput,Административный арест 10 суток.{Enter}{F6}
Return

:?:/196::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 19.6 КоАП - Осуществление предпринимательской деятельности без регистрации или без лицензии.{Enter}{F6}
Sleep 250 
SendInput,Штраф 100000 рублей.{Enter}{F6}
Return

:?:/197::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 19.7 КоАП - Заведомо ложный вызов сотрудников гос. структур.{Enter}{F6}
Sleep 250 
SendInput,Штраф 20000 рублей.{Enter}{F6}
Return

:?:/199::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Вы задержаны по статье 19.9 КоАП - Неповиновение законному распоряжению сотрудника полиции или военнослужащего.{Enter}{F6}
Sleep 250 
SendInput,Административный арест 20 суток.{Enter}{F6}
Return

:?:/пдд211::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput,Согласно 2.1.1 ПДД,вы обязаны предоставить ВУ или паспорт транспортного средства по требованию сотрудника полиции.{Enter}{F6}
Return


:?:/дверь+::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F8}
Sleep 50 
SendInput,  /do Дверь открыта.{Enter}
Return

:?:/дверь-::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F8}
Sleep 50 
SendInput,  /do Дверь заперта.{Enter}
Return

:?:/окно+::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F8}
Sleep 50 
SendInput,  /do Окно разбито.{Enter}
Return

:?:/окно-::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F8}
Sleep 50 
SendInput,  /do Окно цело.{Enter}
Return


:?:/фзоп912::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, По статье 3.9.1.2 ФЗоП сотрудник МВД имеет право:проверять документы граждан,{Enter}{F6}
Sleep 1000 ;
SendInput, если имеются данные, дающие основания подозревать их в совершении{Enter}{F6}
Sleep 1000 ;
SendInput, преступления или полагать, что они находятся в розыске.{Enter}
Sleep 1000 ;
Return

:?:/Апогоня::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции Правила ведения погони.{Enter}{F6}
Sleep 2000 ;
SendInput, Погоня - это физическое преследование с целью настигнуть кого-то или что-то.{Enter}{F6}
Sleep 2000 ;
SendInput, Погоня делится на два типа: пешая и автомобильная.{Enter}{F6}
Sleep 2000 ;
SendInput, При автомобильной погоне разрешено:{Enter}{F6}
Sleep 2000 ;
SendInput, использовать специальные маневры для остановки нарушителя{Enter}{F6}
Sleep 2000 ;
SendInput, использовать спец.средства и табельное оружие организовывать блок-посты,перекрытия{Enter}{F6}
Sleep 2000 ;
SendInput, привлекать другие экипажи/структуры МВД для остановки нарушителя{Enter}{F6}
Sleep 2000 ;
SendInput, При автомобильной погоне запрещено:использовать прямой таран для остановки т/с.{Enter}{F6}
Sleep 2000 ;
SendInput, уезжать с места ДТП при столкновении с гражданским автомобилем, не относящийся к погоне.{Enter}{F6}
Sleep 2000 ;
SendInput, Также продолжать погоню после подобного ДТП.{Enter}{F6}
Sleep 2000 ;
SendInput,  ЕПП/ЕПР на автомобилях не предназначенных для этого{Enter}{F6}
Sleep 2000 ;
SendInput, ЕПТ на любом ТС.{Enter}{F6}
Sleep 2000 ;
SendInput, При пешей погоне разрешается:{Enter}{F6}
Sleep 2000 ;
SendInput,  использовать специальные средства для задержания нарушителя{Enter}{F6}
Sleep 2000 ;
SendInput, привлекать другие экипажи/структуры МВД для остановки нарушителя.{Enter}{F6}
Sleep 2000 ;
SendInput, в случае, если гражданин далеко убежал в поле, то сотрудник может попросить гражданина.{Enter}{F6}
Sleep 2000 ;
SendInput, на ЕПП авто и чтобы гражданин помог в участии погони.{Enter}{F6}
Sleep 2000 ;
SendInput, При пешей погоне запрещено использовать без предупреждений табельное оружие{Enter}{F6}
Sleep 2000 ;
SendInput, и прыгать в ответ за гражданином.{Enter}{F6}
Sleep 2000 ;
SendInput, Во время погони присваиваются следующие статусы:{Enter}{F6}
Sleep 2000 ;
SendInput, Зеленый - Данный статус присваивается сразу после начала погони{Enter}{F6}
Sleep 2000 ;
SendInput, Основной задачей сотрудник является преследование нарушителя и выдача предупреждений об остановке,{Enter}{F6}
Sleep 2000 ;
SendInput, передача ориентировки другим экипажам,{Enter}{F6}
Sleep 2000 ;
SendInput, применение специальных маневров при возможности.{Enter}{F6}
Sleep 2000 ;
SendInput, При специальном маневре стоит учитывать скорость автомобиля, рельеф, населенность.{Enter}{F6}
Sleep 2000 ;
SendInput, Желтый - данный статус присваивается после того, как прошло более 3-ех минут с начала погони.{Enter}{F6}
Sleep 2000 ;
SendInput, Основной задачей сотрудника является намеренная остановка транспортного средства{Enter}{F6}
Sleep 2000 ;
SendInput, при этом не стоит забывать про предупредительный выстрел в воздух и стрельбу по колесам.{Enter}{F6}
Sleep 2000 ;
SendInput, Только после этого, выполняется стрельба по двигателю.{Enter}{F6}
Sleep 2000 ;
SendInput, Красный-данный статус присваивается в случае реальной угрозы сотруднику полиции, гражданским лицам.{Enter}{F6}
Sleep 2000 ;
SendInput, Интервал между предупреждениями - не меньше 15 секунд.{Enter}{F6}
Sleep 2000 ;
SendInput, В роте ППС сотрудник должен откинуть минимум 5 предупреждений,{Enter}{F6}
Sleep 2000 ;
SendInput, Из которых 4 - об остановке, и 1 перед открытием огня.{Enter}{F6}
Sleep 2000 ;
SendInput,На этом лекция «Правила ведения погони» окончена.{Enter}
Return

:?:/экз1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Сейчас пройдет теоритический экзамен{!}{Enter}{F6}
Sleep 200 ;
SendInput, Сколько по времени должен составляться протокол задержания?{Enter}
Return
:?:/экз2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Когда сотрудник полиции должен представиться/показать удостоверение?{Enter}
Return
:?:/экз3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Нужно ли снимать головные уборы с гражданского перед опознанием личности?{Enter}
Return
:?:/экз4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, В каких местах разрешено оформлять задержанного?{Enter}
Return
:?:/экз5::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Что нужно сделать, если нарушителя задержали за 5.8 УК РП...{Enter}{F6}
Sleep 200 ;
SendInput, ...но на моменте оформления выяснилось что он состоит в ФР 2 уровня?{Enter}
Return
:?:/экз6::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Что вы будете делать, если гражданин закроется в авто в момент задержания?{Enter}
Return
:?:/экз7::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Вы видите как перед дежурной частью лежит при смерти гражданин, ваши действия?{Enter}
Return
:?:/экз8::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Расскажите мне весь алгоритм оформления задержания.{Enter}
Return
:?:/экз9::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Какие специальные средства имеются в ГУ МВД?{Enter}
Return
:?:/экз10::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, В каких случаях разрешено применять специальные средства без предупреждения?{Enter}
Return
:?:/экз11::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Обязаны ли вы предупреждать о намерении применить табельное оружие? {Enter}
Return
:?:/экз12::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Какие есть два вида погони?{Enter}
Return
:?:/экз13::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Что нарушил гражданин, если он проехал на красный сигнал светофора?{Enter}
Return
:?:/экз14::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Какой интервал между предупреждениями при погоне?{Enter}
Return
:?:/экз15::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Сколько предупреждений должно откидываться при погоне у сотрудников РППС?{Enter}
Return
:?:/экз16::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200 ;
SendInput, Разрешено ли применять АК-74М во время погони?{Enter}
Return
:?:/экз17::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Что вы будете делать если на вас побежит человек с пистолетом и откроет по вам огонь?{Enter}
Return
:?:/экз18::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Можете ли вы начать расстреливать автомобиль гражданского, который ранее при вас ударил сотрудника Полиции?{Enter}
Return
:?:/экз19::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Что вы будете делать если вас начнут давить машиной?{Enter}
Return
:?:/экз20::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Что нарушает гражданин, если он не подчиняется законным требованиям сотрудника полиции?{Enter}
Return
:?:/экз21::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Что попадает под категорию место массового скопления людей?{Enter}
Return
:?:/экз+::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Поздравляю, вы успешно прошли теоритический экзамен{!}{Enter}
Return
:?:/экз-::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, На этом теоритический экзамен окончен, к сожалению вы его не прошли.{Enter}{F6}
Sleep 200 ;
SendInput, Подготовьтесь и в следующий раз у вас обязательно все получится{!}{Enter}
Return
24:
MsgBox, 0, Патруль, Без напарника:`n/п1 - выехать в патруль`n/п2 - продолжить патруль`n/п3 - закончить патруль`n`nС напарником:`n/п1н - выехать в патруль (ввести Звание и Фамилию напарника)`n/п2н - продолжить патруль (ввести Звание и Фамилию напарника)`n/п3н - закончить патруль (ввести Звание и Фамилию напарника)
return
25:
MsgBox, 0, Воздушный патруль, Патруль:`n/воздух1 - вылететь в патруль`n/воздух2 - продолжить патруль`n/воздух3 - закончить патруль
return
39:
MsgBox, 0, I этап, (/собес1)`nЗапись на камеру`n`n(/собес2)`nНазовите ФИО, возраст и образование`n`n(/собес3)`nДайте паспорт`n`n(/собес4)`nДайте трудовую книгу`n`n(/собес5)`nДайте диплом`n`n(/собес6)`nДайте водительское`n`n(/собес7)`nДайте медицинскую карту`n`n(/собес8)`nДайте военный билет
return
40:
MsgBox, 0, II этап, (/собес9)`nРП термин в чат`n`n(/собес10)`nРП термин в чат`n`n(/собес11)`nРП термин в чат`n`n(/собес12)`nРП термин в чат`n`n(/собес13)`nОбождите минутку`n`n(/собес14)`nРП термины в НонРП чат`n`n(/собес15)`nПрисядьте на корточки`n`n(/собес16)`nВставайте в НонРП чат`n`n(/собес17)`nВставайте в РП чат`n`n(/собес18)`nЧто у меня в руке?`n`n
return

52:
MsgBox, 0, Протокол, (/протоколдч)`nСоставление протокола в ДЧ`n`n(/протокол1)`nЕсли согласен подписывать протокол`n`n(/протокол2)`nЕсли отказывается подписывать`n
return

:?:/наказание::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
SendInput, {F6}
Sleep 250
SendInput, /Введите звание сотрудника->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /Введите никнейм сотрудника->{Space}
Input, Var2, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, /Введите нарушенный пункт->{Space}
Input, Var3, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, /Введите меру наказания->{Space}
Input, Var4, V, {Enter}
SendInput, {bs 17}
SendInput, {F6}
Sleep 200 ;
SendInput, %Var1% полиции %Var2% получает дисциплинарное взыскание в виде "%Var4%" за нарушение пункта %Var3%.{Enter}{F6}
Return

:?:/повышение::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
SendInput, {F6}
Sleep 250
SendInput, /Введите нынешнее звание сотрудника->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /Введите никнейм сотрудника->{Space}
Input, Var2, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, /Введите новое звание->{Space}
Input, Var3, V, {Enter}
SendInput, {bs 17}
Sleep 200 ;
SendInput, %Var1% полиции %Var2% в связи с одобренным рапортом на повышение, был повышен до звания %Var3%.{Enter}{F6}
Return

:?:/трудоустройство::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
SendInput, {F6}
Sleep 250
SendInput, /Введите никнейм сотрудника->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /Введите должность сотрудника->{Space}
Input, Var2, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, /Введите звание сотрудника->{Space}
Input, Var3, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, /Введите номер УДО сотрудника->{Space}
Input, Var4, V, {Enter}
SendInput, {bs 17}
Sleep 200 ;
SendInput, %Var1% - принят на службу в ГУ МВД по городу Приволжск по факту прохождения индивидуального собеседования. Должность - %Var2%, звание - %Var3%. {Enter}{F6}
Sleep 200 ;
SendInput, Номер удостоверения:%Var4%. Тен-код:  {Enter}{F6}
Return

:?:/увольнение::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gumvd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gumvd.egl, User, Prop2
SendInput, {F6}
Sleep 250
SendInput, /Введите звание сотрудника->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, {F6}
Sleep 250
SendInput, /Введите никнейм сотрудника->{Space}
Input, Var2, V, {Enter}
SendInput, {bs 17}
Sleep 250
SendInput, /Введите причину->{Space}
Input, Var3, V, {Enter}
SendInput, {bs 17}
Sleep 200 ;
SendInput, %Var1% полиции %Var2% был уволен в связи с %Var3%.{Enter}{F6}
Return

:?:/обр1::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /do На столе лежит стопка пустых бланков.{Enter}{F6}
Sleep 250
SendInput, /me взяв бланк, закрепил%ok1% его в планшетке{Enter}{F6}
Sleep 250
SendInput, /do Ручка на столе.{Enter}{F6}
Sleep 250
SendInput, /me взяв ручку, начал%ok1% записывать сведения о происшествии{Enter}{F6}
Sleep 250
SendInput, Гражданин, рассказывайте, что произошло.{Enter}
Return

:?:/обр2::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me внес%ok2% в бланк показания заявителя{Enter}{F6}
Sleep 250
SendInput, /me внес%ok2% данные заявителя{Enter}{F6}
Sleep 250
SendInput, /do Данные внесены.{Enter}
Return

:?:/флешка::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me взял%ok1% флешку у гражданина{Enter}{F6}
Sleep 250
SendInput, /do Флешка в руках.{Enter}{F6}
Sleep 250
SendInput, /do Ноутбук лежит в сумке.{Enter}{F6}
Sleep 250
SendInput, /me вставил%ok1% флешку в ноутбук и открыл%ok1% видеозаписи{Enter}{F6}
Sleep 250
SendInput, /do Видеозаписи открыты.{Enter}{F6}
Sleep 250
SendInput, /me скопировал%ok1% видеозапись на ноутбук и извлек%ok2% флешку{Enter}{F6}
Sleep 250
SendInput, /do Флешка в руках.{Enter}{F6}
Sleep 250
SendInput, /me протянул%ok1% флешку гражданину{Enter}
Return

:?:/фото::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me взял%ok1% карту памяти у гражданина{Enter}{F6}
Sleep 250
SendInput, /do Карта памяти в руках.{Enter}{F6}
Sleep 250
SendInput, /do Ноутбук лежит в сумке.{Enter}{F6}
Sleep 250
SendInput, /me вставил%ok1% карту памяти в ноутбук и открыл%ok1% фотографии{Enter}{F6}
Sleep 250
SendInput, /do Фотографии открыты.{Enter}{F6}
Sleep 250
SendInput, /me скопировал%ok1% фотографии на ноутбук и извлек%ok2% карту памяти{Enter}{F6}
Sleep 250
SendInput, /do Карта памяти в руках.{Enter}{F6}
Sleep 250
SendInput, /me протянул%ok1% карту памяти гражданину{Enter}
Return

:?:/обр3::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me поставил дату и подпись в бланке протокола{Enter}{F6}
Sleep 250
SendInput, /me протянул ручку и бланк гражданину{Enter}{F6}
Sleep 250
SendInput, Распишитесь в бланке протокола{Enter}{F6}
Sleep 250
SendInput, /b /me расписался в бланке{Enter}
Return


:?:/обр4::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, /me взял ручку и бланк протокола у гражданина{Enter}{F6}
Sleep 250
SendInput, /do Ручка и бланк протокола в руке.{Enter}{F6}
Sleep 250
SendInput, /me положил бланк протокола в стопку бланков{Enter}{F6}
Sleep 250
SendInput, /do Бланк в стопке.{Enter}{F6}
Sleep 250
SendInput, Благодарим за обращение, обработаем в кратчайшие сроки.Enter}
Return

:?:/камера::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 50 
SendInput,  /do Нагрудная камера "DOZOR" весит на груди сотрудника.{Enter}{F6}
Sleep 50 
SendInput,  /me протянувшись к камере, зажал%ok1% кнопку и запустил%ok1% запись{Enter}{F6}
Sleep 50 
SendInput,  /do Умная камера "DOZOR" проиграла звук "Запись идет".{Enter}
Return

:?:/леквз::
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 250
SendInput, Тема лекции {#}ffff00"Как правильно брать взятки".{Enter}{F6}
Sleep 2000 ;
SendInput, Сотрудники ГУ МВД, так же как и сотрудники ГИБДД,{Enter}{F6}
Sleep 2000 ;
SendInput, очень любят брать взятки.{Enter}{F6}
Sleep 2000 ;
SendInput, В данной лекции мы рассмотрим как правильно их брать и не отлететь на форум.{Enter}{F6}
Sleep 2000 ;
SendInput, Первое и основное, оценка финансового состояния лоха, которого вы задержали.{Enter}{F6}
Sleep 2000 ;
SendInput, Если видно, что он при бабле, можно действовать.{Enter}{F6}
Sleep 2000 ;
SendInput, Вы должны жестко спросить в /do ведется ли запись у этого лоха и если да, отключить эту хрень.{Enter}{F6}
Sleep 2000 ;
SendInput, Важно убедится, что по рп этот бомж никак не фиксанет ваше обогащение.{Enter}{F6}
Sleep 2000 ;
SendInput, Дальше везете его в лес или за гаражи.{Enter}{F6}
Sleep 2000 ;
SendInput, Когда вы скрылись от люботной нищеты можете смело брать взятку.{Enter}{F6}
Sleep 2000 ;
SendInput, На этом лекция окончена.{Enter}{F6}
Sleep 2000 ;
SendInput, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/воздух1::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /d [ГУ МВД-%Bukv% ВП] Вылетел в воздушное патрулирование.{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/воздух2::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /d [ГУ МВД-%Bukv% ВП] Продолжаю воздушное патрулирование.{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/воздух3::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\gumvd.egl, User, Bukv
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
PlayRadioSfx("radio_start.wav")
Sleep 200 ;
SendInput,  /d [ГУ МВД-%Bukv% ВП] Закончил воздушное патрулирование.{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return