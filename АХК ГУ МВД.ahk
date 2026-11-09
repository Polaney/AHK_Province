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
if (!FileExist(A_ScriptDir . "\assets\articles.json")) {
    try {
        FileInstall, assets\articles.json, %A_ScriptDir%\assets\articles.json, 1
    }
}
if (!FileExist(A_ScriptDir . "\radio_start.wav")) {
    try {
        FileInstall, radio_start.wav, %A_ScriptDir%\radio_start.wav, 1
    }
}
if (!FileExist(A_ScriptDir . "\radio_stop.wav")) {
    try {
        FileInstall, radio_stop.wav, %A_ScriptDir%\radio_stop.wav, 1
    }
}

; =================================================================================================
; СИСТЕМНАЯ ИНИЦИАЛИЗАЦИЯ И РЕЖИМЫ WINDOWS 11 23H2 / 24H2+
; =================================================================================================
global WinVer := DetectWindowsVersion()
InitDpiAwareness()
ApplySendEngineMode()
SetBrowserEmulationIE11()
DetectProvincePaths()

; Трей-меню
Menu, Tray, NoStandard
Menu, Tray, Icon, %A_ScriptDir%\gumvd.ico,, 1
Menu, Tray, Tip, ГУ МВД РОССИИ — Fluent Police Glass 2.0
Menu, Tray, Add, Открыть панель управления, ShowFluentUi
Menu, Tray, Add, Скрыть / Показать, ToggleFluentUi
Menu, Tray, Add
Menu, Tray, Add, Калькулятор штрафов (Alt+F1), OpenCalc
Menu, Tray, Add, HUD службы и погони (Alt+H), ToggleDutyHud
Menu, Tray, Add, Сброс погони (Alt+BS), ResetChaseState
Menu, Tray, Add
Menu, Tray, Add, Перезагрузить (Alt+R), ReloadScript
Menu, Tray, Add, Выход, ExitScriptLabel
Menu, Tray, Default, Открыть панель управления

; Инициализация профиля ГУ МВД
global ProfilePath := A_ScriptDir . "\gumvd_profile.ini"
global CustomBindsPath := A_ScriptDir . "\gumvd_custom_binds.ini"
global JournalPath := A_ScriptDir . "\gumvd_journal.ini"
EnsureDefaultGumvdProfile()
LoadGumvdProfile()

; Переменные состояния телеметрии
global ChaseStage := 0
global ChaseLastTime := 0
global DutyTimerActive := 0
global DutyTimerStart := 0
global DutyTimerDuration := 0
global DutyPostName := "Патруль"
global TotalArrests := 0
global TotalProtocols := 0
global TotalFines := 0
global RadioSoundEnabled := 1
global FluentGuiHwnd := 0
global FluentWB := 0

; Инициализация менеджера горячих клавиш
InitHotkeysManager()
RegisterAllHotkeys()

; Запуск интерфейса Fluent Glass
InitAndShowFluentGlassUI()

; Таймеры телеметрии
SetTimer, TelemetryHeartbeat, 1000
Return

; =================================================================================================
; ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ И ДВИЖОК СИСТЕМЫ
; =================================================================================================
CheckAdmin() {
    global 0
    if (!A_IsAdmin && 0 == 0) {
        try {
            if (A_IsCompiled)
                Run *RunAs "%A_ScriptFullPath%" /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
        ExitApp
    }
}

DetectWindowsVersion() {
    v := DllCall("GetVersion", "UInt")
    build := (v >> 16) & 0xFFFF
    if (build >= 26100)
        return "Win11_24H2"
    if (build >= 22631)
        return "Win11_23H2"
    if (build >= 22000)
        return "Win11"
    return "Win10"
}

InitDpiAwareness() {
    try {
        DllCall("SetProcessDpiAwarenessContext", "Ptr", -4, "UInt") ; DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
    } catch {
        try {
            DllCall("SetProcessDPIAware")
        }
    }
}

ApplySendEngineMode() {
    SendMode, Event
    SetKeyDelay, 25, 25
}

SetBrowserEmulationIE11() {
    exeName := A_IsCompiled ? A_ScriptName : "AutoHotkeyU64.exe"
    regKey := "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION"
    try {
        RegWrite, REG_DWORD, HKCU, %regKey%, %exeName%, 11001
    }
}

DetectProvincePaths() {
    global ProvLogPath
    ProvLogPath := ""
    regDirs := ["SOFTWARE\MTA Province", "SOFTWARE\WOW6432Node\MTA Province"]
    for idx, rk in regDirs {
        RegRead, pDir, HKLM, %rk%, InstallPath
        if (pDir != "" && FileExist(pDir . "\MTA\logs\console.log")) {
            ProvLogPath := pDir . "\MTA\logs"
            break
        }
    }
    if (ProvLogPath = "") {
        possible := ["C:\Games\MTA Province\MTA\logs", "D:\Games\MTA Province\MTA\logs", "C:\Program Files\MTA Province\MTA\logs"]
        for idx, pd in possible {
            if (FileExist(pd . "\console.log")) {
                ProvLogPath := pd
                break
            }
        }
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

Encoded(Target) {
    Target := StrReplace(Target, "#", "{#}")
    Target := StrReplace(Target, "!", "{!}")
    Target := StrReplace(Target, "^", "{^}")
    Target := StrReplace(Target, "+", "{+}")
    Target := StrReplace(Target, "&", "{&}")
    Return Target
}

SendChat(TextBind, SleepBind := 400) {
    SetLocaleRu()
    SetCapsOff()
    TextBind := Encoded(TextBind)
    SendInput, {F8}^A{Delete}%TextBind%{Enter}{F8}
    Sleep, %SleepBind%
}

PlayRadioSfx(sfxFile) {
    global RadioSoundEnabled
    if (!RadioSoundEnabled)
        Return
    filePath := A_ScriptDir . "\" . sfxFile
    if (!FileExist(filePath))
        filePath := A_ScriptDir . "\assets\" . sfxFile
    if (FileExist(filePath)) {
        DllCall("winmm\PlaySoundW", "WStr", filePath, "Ptr", 0, "UInt", 0x20001) ; SND_ASYNC | SND_FILENAME
    }
}

GetTryRes() {
    global ProvLogPath
    Sleep, 100
    if (ProvLogPath != "" && FileExist(ProvLogPath . "\console.log")) {
        Loop, read, %ProvLogPath%\console.log
            LastLine := A_LoopReadLine
        IfInString, LastLine, РќРµСѓРґР°С‡РЅРѕ
            Return False
        IfInString, LastLine, РЈРґР°С‡РЅРѕ
            Return True
    }
    InputBox, TryRes, Результат действия, Введите результат (1 = Удачно / 0 = Неудачно):,, 280, 130
    if (ErrorLevel || TryRes = "0" || TryRes = "нет" || TryRes = "ytn")
        Return False
    Return True
}

; =================================================================================================
; ПРОФИЛЬ СОТРУДНИКА ГУ МВД
; =================================================================================================
EnsureDefaultGumvdProfile() {
    global ProfilePath
    if (!FileExist(ProfilePath)) {
        IniWrite, ГУ МВД г.Невский, %ProfilePath%, User, Frak
        IniWrite, Голдчерри Максим Сергеевич, %ProfilePath%, User, Fio1
        IniWrite, Старшина, %ProfilePath%, User, Rank
        IniWrite, 51, %ProfilePath%, User, Teg
        IniWrite, 001, %ProfilePath%, User, Prop2
        IniWrite, Сотрудник роты ППС, %ProfilePath%, User, Otdel
        IniWrite, Тень, %ProfilePath%, User, Prop1
        IniWrite, ОСпН, %ProfilePath%, User, Osnxxx
        IniWrite, ЦСН "БАРС", %ProfilePath%, User, Osn
        IniWrite, Н, %ProfilePath%, User, Bukv
        IniWrite, Я мужык, %ProfilePath%, User, Gender
    }
}

LoadGumvdProfile() {
    global ProfilePath, Frak, Fio1, Rank, Teg, Prop2, Otdel, Prop1, Osnxxx, Osn, Bukv, Gender
    global Ok1, Ok2, Ok3, Ok4, Ok5, Ok6, Ok7, Ok8, Ok9, Ok10
    
    ; Читаем сначала из ini, затем если есть - из temp/data.egl
    IniRead, Frak, %ProfilePath%, User, Frak, ГУ МВД г.Невский
    IniRead, Fio1, %ProfilePath%, User, Fio1, Голдчерри Максим Сергеевич
    IniRead, Rank, %ProfilePath%, User, Rank, Старшина
    IniRead, Teg, %ProfilePath%, User, Teg, 51
    IniRead, Prop2, %ProfilePath%, User, Prop2, 001
    IniRead, Otdel, %ProfilePath%, User, Otdel, Сотрудник роты ППС
    IniRead, Prop1, %ProfilePath%, User, Prop1, Тень
    IniRead, Osnxxx, %ProfilePath%, User, Osnxxx, ОСпН
    IniRead, Osn, %ProfilePath%, User, Osn, ЦСН "БАРС"
    IniRead, Bukv, %ProfilePath%, User, Bukv, Н
    IniRead, Gender, %ProfilePath%, User, Gender, Я мужык
    
    ; Синхронизация с A_Temp\data.egl и gumvd.egl для совместимости с оригинальными скриптами
    tempData := A_Temp . "\data.egl"
    IniWrite, %Frak%, %tempData%, User, Frak
    IniWrite, %Fio1%, %tempData%, User, Fio1
    IniWrite, %Rank%, %tempData%, User, Rank
    IniWrite, %Teg%, %tempData%, User, Teg
    IniWrite, %Prop2%, %tempData%, User, Prop2
    IniWrite, %Otdel%, %tempData%, User, Otdel
    IniWrite, %Prop1%, %tempData%, User, Prop1
    IniWrite, %Osnxxx%, %tempData%, User, Osnxxx
    IniWrite, %Osn%, %tempData%, User, Osn
    IniWrite, %Bukv%, %tempData%, User, Bukv
    IniWrite, %Gender%, %tempData%, User, Gender
    
    ; Настройка окончаний по полу
    if (Gender = "Я девочка") {
        Ok1 := "а"
        Ok2 := "ла"
        Ok3 := "ась"
        Ok4 := "цы"
        Ok5 := "ца"
        Ok6 := "це"
        Ok7 := "ла"
        Ok8 := "ела"
        Ok9 := "есла"
        Ok10 := "цей"
    } else {
        Ok1 := ""
        Ok2 := ""
        Ok3 := "ся"
        Ok4 := "ка"
        Ok5 := "к"
        Ok6 := "ке"
        Ok7 := "ёл"
        Ok8 := "ёл"
        Ok9 := "ёс"
        Ok10 := "ком"
    }
}

SaveGumvdProfileJson(jsonStr) {
    global ProfilePath
    ; Простое извлечение полей из JSON
    fields := ["Frak", "Fio1", "Rank", "Teg", "Prop2", "Otdel", "Prop1", "Osnxxx", "Osn", "Bukv", "Gender"]
    for idx, f in fields {
        pattern := """" . f . """:""([^""]+)"""
        if (RegExMatch(jsonStr, pattern, m)) {
            val := m1
            IniWrite, %val%, %ProfilePath%, User, %f%
        }
    }
    LoadGumvdProfile()
    InitAndShowFluentGlassUI()
}

; =================================================================================================
; МЕНЕДЖЕР ГОРЯЧИХ КЛАВИШ
; =================================================================================================
global HotkeyDefs := []
global HotkeyById := {}

AddHkDef(id, title, cat, defaultKey, labelName) {
    global HotkeyDefs, HotkeyById, ProfilePath
    IniRead, savedKey, %ProfilePath%, Hotkeys, %id%, %defaultKey%
    hk := { id: id, title: title, cat: cat, key: savedKey, defaultKey: defaultKey, label: labelName }
    HotkeyDefs.Push(hk)
    HotkeyById[id] := hk
}

InitHotkeysManager() {
    global HotkeyDefs, HotkeyById
    HotkeyDefs := []
    HotkeyById := {}
    
    AddHkDef("HK_Greeting",      "Приветствие с погонами",                     "ППС", "!1",            "Bind_Greeting")
    AddHkDef("HK_Udo",           "Показать УДО (/ud)",                         "ППС", "^1",            "Bind_Udo")
    AddHkDef("HK_AskDocs",       "Попросить паспорт (/pass)",                  "ППС", "^2",            "Bind_AskDocs")
    AddHkDef("HK_TakeDocs",      "Взять документы в руки",                     "ППС", "^3",            "Bind_TakeDocs")
    AddHkDef("HK_ReturnDocs",    "Изучить и вернуть документы",                "ППС", "^4",            "Bind_ReturnDocs")
    AddHkDef("HK_Cuffs",         "Надеть наручники БР-С (/cuff)",              "ППС", "^5",            "Bind_CuffsOn")
    AddHkDef("HK_Uncuffs",       "Снять наручники (/uncuff)",                  "ППС", "^6",            "Bind_CuffsOff")
    AddHkDef("HK_Escort",        "Заломать и вести конвоем (/arr)",            "ППС", "^7",            "Bind_EscortOn")
    AddHkDef("HK_ReleaseHands",  "Отпустить руки задержанного (/dearr)",       "ППС", "^8",            "Bind_EscortOff")
    AddHkDef("HK_ProtocolSign",  "Протокол задержания у авто",                 "ППС", "^9",            "Bind_DetainProt")
    AddHkDef("HK_TransferKpz",   "Передача конвоиру в КПЗ (/arrest)",          "ППС", "^0",            "Bind_Arrest")
    AddHkDef("HK_SuFast",        "Выдача розыска нарушителю (/su)",            "ППС", "^-",            "Bind_SuFast")
    AddHkDef("HK_Putpl",         "Посадить в служебный автомобиль (/putpl)",   "ППС", "!6",            "Bind_Putpl")
    AddHkDef("HK_Pullout",       "Вытащить гражданина из авто",                "ППС", "^r",            "Bind_PullOutSimple")
    AddHkDef("HK_ColleagueGreet","Воинское приветствие коллегам",              "ППС", "^E",            "Bind_GreetColleague")
    AddHkDef("HK_KnockWindow",   "Постучать в окно автомобиля",                "ППС", "^sc29",         "Bind_KnockWindow")
    
    AddHkDef("HK_KpkOpen",       "КПК: достать из кармана (MIG LT11i)",        "КПК", "!3",            "Bind_KpkOpen")
    AddHkDef("HK_KpkPhoto",      "КПК: фоторобот лица (/wanted)",              "КПК", "!4",            "Bind_KpkPhoto")
    AddHkDef("HK_KpkSearchDb",   "КПК: проверка по базе нарушителей",          "КПК", "!7",            "Bind_KpkSearchDb")
    AddHkDef("HK_KpkClose",      "КПК: выключить и убрать в разгрузку",        "КПК", "!5",            "Bind_KpkClose")
    AddHkDef("HK_Wanted",        "КПК: видеокамеры города (/wanted)",          "КПК", "^F10",          "Bind_Wanted")
    AddHkDef("HK_FindEmp",       "База сотрудников управления (/find)",        "КПК", "^F9",           "Bind_FindEmp")
    
    AddHkDef("HK_OsnPatch",      "Нашивка спецназа ОСН на бронежилете",        "ОСН", "!2",            "Bind_OsnBadge")
    AddHkDef("HK_ShoutHands",    "Руки на капот!",                             "ОСН", "!x",            "Bind_ShoutHands")
    AddHkDef("HK_TryDoor",       "Дёрнуть ручку двери авто (/try)",            "ОСН", "!F12",          "Bind_TryDoor")
    AddHkDef("HK_TryGlass",      "Разбить стекло дубинкой (/try)",             "ОСН", "!printscreen",  "Bind_TryGlass")
    AddHkDef("HK_UnlockIn",      "Открыть замок двери изнутри",                "ОСН", "!scrolllock",   "Bind_UnlockIn")
    
    AddHkDef("HK_VoiceOn",       "Рация: включить микрофон (/fracvoice 1)",    "Рация", "^insert",     "Bind_VoiceOn")
    AddHkDef("HK_VoiceOff",      "Рация: режим прослушивания (/fracvoice 2)",  "Рация", "^home",       "Bind_VoiceOff")
    AddHkDef("HK_Megaphone1",    "СГУ: Пред 1 (Прижмитесь к обочине)",         "СГУ", "!0",            "Bind_Megaphone1")
    AddHkDef("HK_Megaphone2",    "СГУ: Пред 2 (Повторное требование)",         "СГУ", "!-",            "Bind_Megaphone2")
    AddHkDef("HK_Megaphone3",    "СГУ: Пред 3 (Огонь на поражение!)",          "СГУ", "!=",            "Bind_Megaphone3")
    AddHkDef("HK_MegaphoneWay",  "СГУ: Уступите проезд спецколонне",           "СГУ", "!9",            "Bind_MegaphoneWay")
    AddHkDef("HK_FootChase",     "Пешая погоня: Стой, стрелять буду!",         "СГУ", "!8",            "Bind_FootChase")
    
    AddHkDef("HK_SmartMegaphone","Умный мегафон (Авто-стадии 1-2-3)",          "Служба", "^Space",     "Bind_SmartMegaphone")
    AddHkDef("HK_ChaseStop",     "Сброс погони и таймера",                     "Служба", "!BS",        "ResetChaseState")
    AddHkDef("HK_ToggleHud",     "Вкл/Выкл HUD смены и погони",                "Служба", "!h",         "ToggleDutyHud")
    AddHkDef("HK_OpenCalc",      "Калькулятор штрафов",                        "Служба", "!F1",        "OpenCalc")
}

RegisterAllHotkeys() {
    global HotkeyDefs
    for idx, hk in HotkeyDefs {
        key := hk.key
        lbl := hk.label
        if (key != "" && IsLabel(lbl)) {
            try {
                Hotkey, %key%, %lbl%, On
            }
        }
    }
}

RemapHotkey(hkId, newKey) {
    global HotkeyById, ProfilePath
    hk := HotkeyById[hkId]
    if (!hk)
        Return
    oldKey := hk.key
    if (oldKey != "") {
        try {
            Hotkey, %oldKey%, Off
        }
    }
    hk.key := newKey
    IniWrite, %newKey%, %ProfilePath%, Hotkeys, %hkId%
    lbl := hk.label
    if (newKey != "" && IsLabel(lbl)) {
        try {
            Hotkey, %newKey%, %lbl%, On
        }
    }
    InitAndShowFluentGlassUI()
}

; =================================================================================================
; ДВИЖОК FLUENT POLICE GLASS 2.0 (HTML/CSS/JS INTERFACE)
; =================================================================================================
BuildFluentInitialJson() {
    global Frak, Fio1, Rank, Teg, Prop2, Otdel, Prop1, Osnxxx, Osn, Bukv, Gender
    global HotkeyDefs, TotalArrests, TotalProtocols, TotalFines
    
    json := "{"
    json .= """profile"":{"
    json .= """Frak"":""" . Frak . ""","
    json .= """Fio1"":""" . Fio1 . ""","
    json .= """Rank"":""" . Rank . ""","
    json .= """Teg"":""" . Teg . ""","
    json .= """Prop2"":""" . Prop2 . ""","
    json .= """Otdel"":""" . Otdel . ""","
    json .= """Prop1"":""" . Prop1 . ""","
    json .= """Osnxxx"":""" . Osnxxx . ""","
    json .= """Osn"":""" . Osn . ""","
    json .= """Bukv"":""" . Bukv . ""","
    json .= """Gender"":""" . Gender . """"
    json .= "},"
    
    json .= """hotkeys"":["
    for idx, hk in HotkeyDefs {
        if (idx > 1)
            json .= ","
        json .= "{"
        json .= """id"":""" . hk.id . ""","
        json .= """title"":""" . hk.title . ""","
        json .= """cat"":""" . hk.cat . ""","
        json .= """key"":""" . hk.key . ""","
        json .= """label"":""" . hk.label . """"
        json .= "}"
    }
    json .= "],"
    json .= """kpi"":{""arrests"":" . TotalArrests . ",""protocols"":" . TotalProtocols . ",""patrolMin"":0}"
    json .= "}"
    Return json
}

InitAndShowFluentGlassUI() {
    global FluentGuiHwnd, FluentWB
    htmlTemplatePath := A_ScriptDir . "\assets\fluent_gumvd.html"
    if (!FileExist(htmlTemplatePath))
        Return
    
    FileRead, htmlTpl, %htmlTemplatePath%
    initialData := BuildFluentInitialJson()
    runtimeHtml := StrReplace(htmlTpl, "/*__AHK_INITIAL_DATA__*/ {}", initialData)
    
    runtimePath := A_Temp . "\gumvd_fluent_runtime.html"
    if (FileExist(runtimePath))
        FileDelete, %runtimePath%
    FileAppend, %runtimeHtml%, %runtimePath%, UTF-8
    
    winW := 1060
    winH := 700
    
    Gui, 8:Destroy
    Gui, 8:+HWNDFluentGuiHwnd +Resize -Caption +MinSize800x550
    Gui, 8:Margin, 0, 0
    Gui, 8:Add, ActiveX, x0 y0 w%winW% h%winH% vFluentWB, % "about:blank"
    
    FluentWB.Silent := True
    FluentWB.Navigate("file:///" . StrReplace(runtimePath, "\", "/"))
    
    startWait := A_TickCount
    while (FluentWB.ReadyState != 4 && (A_TickCount - startWait < 2000))
        Sleep, 15
        
    try {
        FluentWB.document.parentWindow.ahk_call := Func("OnFluentWebAction")
    }
    
    OnMessage(0x0100, "Gui_KeyDown")
    OnMessage(0x0101, "Gui_KeyDown")
    
    Gui, 8:Show, Center w%winW% h%winH%, ГУ МВД РОССИИ — Fluent Police Glass
}

Gui_KeyDown(wParam, lParam, nMsg, hWnd) {
    global FluentGuiHwnd, FluentWB
    static IID_IOleInPlaceActiveObject := "{00000117-0000-0000-C000-000000000046}"
    if (!FluentWB || !FluentGuiHwnd)
        Return
    if (hWnd != FluentGuiHwnd && DllCall("GetAncestor", "Ptr", hWnd, "UInt", 2, "Ptr") != FluentGuiHwnd)
        Return
    pipa := ComObjQuery(FluentWB, IID_IOleInPlaceActiveObject)
    if (!pipa)
        Return
    VarSetCapacity(msg, 48, 0)
    NumPut(hWnd,   msg, 0,  "Ptr")
    NumPut(nMsg,   msg, A_PtrSize, "UInt")
    NumPut(wParam, msg, A_PtrSize * 2, "UPtr")
    NumPut(lParam, msg, A_PtrSize * 3, "Ptr")
    NumPut(DllCall("GetMessageTime", "UInt"), msg, A_PtrSize * 4, "UInt")
    DllCall("GetCursorPos", "Ptr", &msg + (A_PtrSize * 4 + 4))
    hr := DllCall(NumGet(NumGet(pipa+0)+5*A_PtrSize), "Ptr", pipa, "Ptr", &msg)
    ObjRelease(pipa)
    if (hr == 0)
        Return 0
}

OnFluentWebAction(action, arg1 := "", arg2 := "") {
    if (action = "trigger_bind") {
        if (IsLabel(arg1))
            Gosub, %arg1%
        Return
    }
    if (action = "trigger_hotstring") {
        SendChat(arg1)
        Return
    }
    if (action = "copy_cmd") {
        Clipboard := arg1
        TrayTip, ГУ МВД, Скопировано в буфер: %arg1%, 1, 1
        Return
    }
    if (action = "save_profile") {
        SaveGumvdProfileJson(arg1)
        Return
    }
    if (action = "open_calc") {
        Gosub, OpenCalc
        Return
    }
    if (action = "toggle_hud") {
        Gosub, ToggleDutyHud
        Return
    }
    if (action = "reset_chase") {
        Gosub, ResetChaseState
        Return
    }
    if (action = "emergency_stop") {
        Gosub, EmergencyStopCurrentBind
        Return
    }
    if (action = "open_remap") {
        OpenQuickHotkeyRemapModal(arg1)
        Return
    }
    if (action = "win_minimize") {
        Gui, 8:Minimize
        Return
    }
    if (action = "win_close") {
        Gui, 8:Hide
        Return
    }
}

ShowFluentUi:
InitAndShowFluentGlassUI()
Return

ToggleFluentUi:
Gui, 8:+LastFound
if (DllCall("IsWindowVisible", "Ptr", WinExist()))
    Gui, 8:Hide
else
    Gui, 8:Show
Return

ReloadScript:
Reload
Return

ExitScriptLabel:
ExitApp
Return

TelemetryHeartbeat:
FormatTime, curClock,, HH:mm:ss
hudText := "00:00"
if (DutyTimerActive) {
    elapsed := (A_TickCount - DutyTimerStart) // 1000
    m := elapsed // 60
    s := Mod(elapsed, 60)
    hudText := Format("{:02}:{:02}", m, s)
}
try {
    if (FluentWB) {
        jsCall := "updateLiveState({ clock: '" . curClock . "', hudTimer: '" . hudText . "' });"
        FluentWB.document.parentWindow.eval(jsCall)
    }
}
Return

OpenQuickHotkeyRemapModal(hkId) {
    InputBox, newKey, Назначить клавишу, Введите новую клавишу или комбинацию:,, 300, 140
    if (!ErrorLevel && newKey != "") {
        RemapHotkey(hkId, newKey)
    }
}

EmergencyStopCurrentBind:
Reload
Return

OpenCalc:
Run, calc.exe
Return

ToggleDutyHud:
DutyTimerActive := !DutyTimerActive
if (DutyTimerActive) {
    DutyTimerStart := A_TickCount
    TrayTip, ГУ МВД, Таймер смены запущен!, 1, 1
} else {
    TrayTip, ГУ МВД, Таймер смены остановлен., 1, 1
}
Return

ResetChaseState:
ChaseStage := 0
TrayTip, ГУ МВД, Режим погони сброшен!, 1, 1
Return

; =================================================================================================
; БОЕВЫЕ ХОТКЕИ ГУ МВД РОССИИ (ВСЕ 31+ МЕТОК)
; =================================================================================================

Bind_Greeting:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F8}animarmy 3{ENTER}{F8}
Sleep 250
SendInput, {F8}say Здравия желаю, %Otdel% %Frak%, %Rank% полиции, %Fio1%.{Enter}{F8}
Sleep 450
PogonDesc := ""
if (Rank = "Рядовой")
    PogonDesc := "пустые погоны"
else if (Rank = "Сержант")
    PogonDesc := "погоны с тремя лычками поперек погон"
else if (Rank = "Старшина")
    PogonDesc := "погоны с одной лычкой вдоль погон"
else if (Rank = "Прапорщик")
    PogonDesc := "погоны с двумя звездами вдоль погон"
else if (Rank = "Лейтенант")
    PogonDesc := "погоны с двумя звездами и просветом"
else if (Rank = "Старший лейтенант")
    PogonDesc := "погоны с тремя звездами и просветом"
else if (Rank = "Капитан")
    PogonDesc := "погоны с четырьмя звездами и просветом"
else if (Rank = "Майор")
    PogonDesc := "погоны с одной звездой и двумя просветами"
else if (Rank = "Подполковник")
    PogonDesc := "погоны с двумя звездами и двумя просветами"
else if (Rank = "Полковник")
    PogonDesc := "погоны с тремя звездами и двумя просветами"
else if (Rank = "Генерал-майор")
    PogonDesc := "погоны с одной большой звездой"
else if (Rank = "Генерал-лейтенант")
    PogonDesc := "погоны с двумя большими звездами"
else if (Rank = "Генерал-полковник")
    PogonDesc := "погоны с тремя большими звездами"
else if (Rank = "Генерал МВД")
    PogonDesc := "погоны с одной большой звездой и гербом МВД"

if (PogonDesc != "") {
    Sleep 450
    SendInput, {F8}do На плечах %PogonDesc%.{Enter}{F8}
}
Return

Bind_Udo:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200
SendInput, /Кому показать удо? ID ->{Space}
Input, id, V, {Enter}
SendInput, {bs 17}
SendInput, {enter}
Sleep 400
SendInput, {F8}ud %id%{Enter}{F8}
Return

Bind_AskDocs:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F8}say Передайте ваш паспорт для установления личности.{Enter}{F8}
Sleep 400
SendInput, {F8}b /me передал(-а) паспорт{Enter}{F8}
Sleep 400
SendInput, {F8}b /pass id (id = цифры после ника){Enter}{F8}
Return

Bind_TakeDocs:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F8}me протянул%ok1% правую руку и взял%ok1% документы гражданина{Enter}{F8}
Sleep 400
SendInput, {F8}me детально изучил%ok1% документы гражданина{Enter}{F8}
Sleep 400
SendInput, {F8}do Документы изучены сотрудни%ok10%.{Enter}{F8}
Return

Bind_ReturnDocs:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F8}me протянул%ok1% гражданину документы{Enter}{F8}
Sleep 400
SendInput, {F8}say Уважаемый, держите ваши документы.{Enter}{F8}
Sleep 400
SendInput, {F8}b /me забрал(-а) документы{Enter}{F8}
Return

Bind_CuffsOn:
SendMessage, 0x50,, 0x4190419,, A
Sleep 100
SendInput, {5}
Sleep 200
SendInput, {F8}say Гражданин, Вы имеете право хранить молчание{!}{Enter}{F8}
Sleep 400
SendInput, {F6}
Sleep 100
SendInput, /cuff{Space}
TotalArrests++
Return

Bind_CuffsOff:
SendMessage, 0x50,, 0x4190419,, A
Sleep 300
SendInput, {F6}
Sleep 100
SendInput, /uncuff{Space}
Return

Bind_EscortOn:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F8}me заломал%ok1% гражданина и повел%ok1% за собой{Enter}{F8}
Sleep 100
SendInput, {F6}
Sleep 100
SendInput, /arr{Space}
Return

Bind_EscortOff:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F8}me отпустил%ok1% руки задержанного{Enter}{F8}
Sleep 100
SendInput, {F6}
Sleep 100
SendInput, /dearr{Space}
Return

Bind_DetainProt:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200
SendInput, Гражданин, сейчас мы составим протокол Вашего задержания.{Enter}{F6}
Sleep 1500
SendInput, /do Бланки протокола с ручкой лежат в сумке на плече сотрудника.{Enter}{F6}
Sleep 1500
SendInput, /me открыл%ok1% сумку и достал%ok1% бланк протокола с ручкой{Enter}{F6}
Sleep 1500
SendInput, /me взял%ok1% ручку и начал%ok1% заполнять протокол{Enter}{F6}
Sleep 1500
SendInput, /me заполнил%ok1% личные данные{Enter}{F6}
Sleep 1500
SendInput, /me заполнил%ok1% статью нарушенную гражданином{Enter}{F6}
Sleep 1500
SendInput, /me поставил%ok1% дату и подпись{Enter}{F6}
Sleep 1500
SendInput, /me отстегнул%ok1% одну руку задержанного и пристегнул%ok1% браслет наручников к ручке автомобиля{Enter}{F6}
Sleep 1500
SendInput, /todo Подписывать будете?*передавая протокол с ручкой задержанному{Enter}{F6}
Sleep 1500
SendInput, /b Если да, то отыграйте /me расписался в протоколе{Enter}
TotalProtocols++
Return

Bind_Arrest:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200
SendInput, /Введите ID гражданина которого хотите посадить ->{Space}
Input, Var1, V, {Enter}
SendInput, {bs 17}
Sleep 200
SendInput, {F6}
Sleep 200
SendInput, Пора Вас конвоиру передавать. Свои вещи заберете у конвоира.{Enter}{F6}
Sleep 450
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 450
PlayRadioSfx("radio_start.wav")
SendInput, /me сняв рацию, поднёс%ok2% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 450
SendInput, /me вызвал%ok1% конвоира{Enter}{F6}
Sleep 450
PlayRadioSfx("radio_stop.wav")
SendInput, /do Конвоир вызван.{Enter}{F6}
Sleep 450
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}{F6}
Sleep 450
SendInput, /me открыл%ok1% дверь и передал%ok1% задержанного конвоиру{Enter}{F6}
Sleep 450
SendInput, /say Уведите задержанного.{Enter}{F6}
Sleep 450
SendInput, /do Конвоир увел задержанного.{Enter}{F6}
Sleep 450
SendInput, /r Задержанный был передан конвоиру. Протокол задержания передан в канцелярию.{Enter}{F6}
Sleep 450
SendInput, /arrest %Var1%{Enter}
TotalArrests++
Return

Bind_SuFast:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F8}do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F8} 
Sleep 50
PlayRadioSfx("radio_start.wav")
SendInput, {F8}me снял%ok1% рацию, затем связался с диспетчером и передал%ok1% ориентировку на гражданина{Enter}{F8} 
Sleep 50
PlayRadioSfx("radio_stop.wav")
SendInput, {F6}
Sleep 100
SendInput, /su{Space}
Return

Bind_Putpl:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200
SendInput, Берегите голову при посадке в автомобиль{!}{Enter}{F6}
Sleep 400
SendInput, /me взял%ok1% нарушителя за руки и посадил%ok1% в служебный автомобиль{Enter}{F6}
Sleep 200
SendInput, /putpl{Space}
Return

Bind_PullOutSimple:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200
SendInput, /me вытащил%ok1% гражданина из автомобиля{Enter}
Return

Bind_GreetColleague:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200
SendInput, Здравия желаю{!}{Enter}{F6}
Sleep 200
SendInput, /animarmy 3{Enter}
Return

Bind_KnockWindow:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F8}me постучал%ok1% в окно{Enter}{F8}
Return

Bind_KpkOpen:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F6}
Sleep 300
SendInput, /do Служебный планшет марки “MIG LT11i” в кармане.{Enter}{F6}
Sleep 300
SendInput, /me достав служебный планшет из кармана, запустил%ok1% его{Enter}
Return

Bind_KpkPhoto:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F6}
Sleep 400
SendInput, Сейчас определим вашу личность.{Enter}{F6}
Sleep 400
SendInput, /me сделал%ok1% фотографию гражданина и запросил%ok1% данные{Enter}{F6}
Sleep 400
SendInput, /do Данные гражданина выведены на экран служебного планшета.{Enter}{F6}
Sleep 400
SendInput, Ваша личность установлена.{Enter}{F6}
Sleep 400
SendMessage, 0x50,, 0x4090409,, A
SendInput, /wanted {Enter}{F6}
Sleep 400
SendInput, /crimrec{Space}
Return

Bind_KpkSearchDb:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200
SendInput, /me открыл%ok1% базу данных нарушителей{Enter}{F6}
Sleep 250
SendInput, /me ввел%ok1% данные гражданина в базу и нажал%ok1% кнопку "Запросить"{Enter}{F6}
Sleep 250
SendInput, /do Информация о гражданине высветилась на экране.{Enter}{F6}
Sleep 400
SendMessage, 0x50,, 0x4090409,, A
SendInput, /wanted {Enter}{F6}
Sleep 400
SendInput, /crimrec{Space}
Return

Bind_KpkClose:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 150
SendInput, /me выключил%ok1% служебный планшет и убрал%ok1% в карман{Enter}{F6}
Sleep 150
SendInput, /do Служебный планшет марки MIG LT11i в кармане.{Enter}
Return

Bind_Wanted:
SendMessage, 0x50,, 0x4190419,, A
Sleep 300
SendInput, {F8}do Служебный планшет марки “MIG LT11i” в кармане.{Enter}{F8}
Sleep 200
SendInput, {F8}me достав служебный планшет из кармана, запустил%ok1% его{Enter}{F8}
Sleep 150
SendInput, {F8}me открыл%ok1% базу данных видеонаблюдения{Enter}{F8}
Sleep 150
SendInput, {F8}do Изображение с камер транслируются в реальном времени на служебный планшет.{Enter}{F8}
Sleep 200
SendInput, {F8}me выключил%ok1% служебный планшет и убрал%ok1% в карман{Enter}{F8}
Sleep 200
SendInput, {F8}do Служебный планшет марки “MIG LT11i” в кармане.{Enter}{F8}
Sleep 150
SendMessage, 0x50,, 0x4090409,, A
SendInput, {F8}wanted{Enter}{F8}
Return

Bind_FindEmp:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F8}me открыл%ok1% базу данных сотрудников управления{Enter}{F8}
Sleep 100
SendInput, {F8}do База данных сотрудников управления открыта.{Enter}{F8}
Sleep 100
SendInput, {F8}find{Enter}{F8}
Return

Bind_OsnBadge:
SendMessage, 0x50,, 0x4190419,, A
Sleep 200
SendInput, {F8}do На бронежилете нашивка: || [%Osnxxx%-%Prop2%] || Позывной: %Prop1%. [%Frak%].{Enter}{F8}
Return

Bind_ShoutHands:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200
SendInput, /s Из машины, руки на капот{!}{Enter}
Return

Bind_TryDoor:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200
SendInput, /me дёрнул%ok1% за ручку двери{Enter}{F6}
Sleep 100
SendInput, /do Сотрудни%ok5% пытается открыть дверь.{Enter}{F6}
Sleep 100
SendInput, /try открыл%ok1% дверь{Enter}
Return

Bind_TryGlass:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200
SendInput, /me замахнул%ok3% дубинкой и ударил%ok1% по стеклу{Enter}{F6}
Sleep 100
SendInput, /try разбил%ok1% стекло дубинкой{Enter}
Return

Bind_UnlockIn:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F6}
Sleep 200
SendInput, /me потянул%ok3% рукой до замка и открыл%ok1% его изнутри{Enter}{F6}
Sleep 100
SendInput, /do Замок открыт.{Enter}{F6}
Sleep 100
SendInput, /me открыл%ok1% дверь и вытащил%ok1% гражданина из машины{Enter}
Return

Bind_VoiceOn:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F8}do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F8}
Sleep 10
SendInput, {F8}me сняв рацию, поднес%ok2% её ко рту и нажал%ok1% кнопку для переговоров{Enter}{F8}
PlayRadioSfx("radio_start.wav")
Sleep 50
SendInput, {F8}fracvoice 1{Enter}{F8}
Return

Bind_VoiceOff:
SendMessage, 0x50,, 0x4190419,, A
SendInput, {F8}me перевел%ok1% рацию в режим прослушивания и закрепил%ok1% на нагрудном кармане{Enter}{F8}
PlayRadioSfx("radio_stop.wav")
Sleep 50
SendInput, {F8}do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F8}
Sleep 50
SendInput, {F8}fracvoice 2{Enter}{F8}
Return

Bind_Megaphone1:
SendMessage, 0x50,, 0x4190419,, A
Sleep 150
SendInput, {F8}do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
Sleep 10
SendInput, {F8}me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
Sleep 10
SendInput, {F8}m {#}7ae70dВодитель, принимаем крайнее правое положение и останавливаемся{!}{Enter}{F8}
Sleep 10
SendInput, {F8}me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return

Bind_Megaphone2:
SendMessage, 0x50,, 0x4190419,, A
Sleep 150
SendInput, {F8}do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
Sleep 10
SendInput, {F8}me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
Sleep 10
SendInput, {F8}m {#}e7950dПовторяю, водитель, примите вправо и остановитесь{!}{Enter}{F8}
Sleep 10
SendInput, {F8}me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return

Bind_Megaphone3:
SendMessage, 0x50,, 0x4190419,, A
Sleep 150
SendInput, {F8}do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
Sleep 10
SendInput, {F8}me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
Sleep 10
SendInput, {F8}m {#}e74c3cОстанавливайтесь{!} В случае отказа откроем огонь{!}{Enter}{F8}
Sleep 10
SendInput, {F8}me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return

Bind_MegaphoneWay:
SendMessage, 0x50,, 0x4190419,, A
Sleep 150
SendInput, {F8}do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
Sleep 10
SendInput, {F8}me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
Sleep 10
SendInput, {F8}m {#}e7950dУступите проезд спец. транспорту{!}{Enter}{F8}
Sleep 10
SendInput, {F8}me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return

Bind_FootChase:
SendMessage, 0x50,, 0x4190419,, A
Sleep 150
SendInput, {F8}s Гражданин останавливаемся, в противном случае к вам будет применена физическая сила{!}{Enter}{F8}
Return

Bind_SmartMegaphone:
ChaseStage++
if (ChaseStage = 1) {
    Gosub, Bind_Megaphone1
} else if (ChaseStage = 2) {
    Gosub, Bind_Megaphone2
} else {
    Gosub, Bind_Megaphone3
    ChaseStage := 0
}
Return

; =================================================================================================
; ВСЕ 255 АУТЕНТИЧНЫХ ХОТСТРИНГОВ ГУ МВД РОССИИ
; =================================================================================================

:?:/протоколдч::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/протокол1::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/протокол2::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/протоколдч1::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/протоколдч2::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
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
PlayRadioSfx("radio_start.wav")
SendInput, {F6}
Sleep 250
SendInput, /me вытащил%ok1% задержанного из служебного автомобиля{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/п1::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-0-1 Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/п2::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-0-2 Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/п3::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-0-3 Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/п1н::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
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
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-0-1 Код-3 Напарник: %Var1% %Var2%{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/п2н::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
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
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-0-2 Код-3 Напарник: %Var1% %Var2%{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/п3н::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
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
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-0-3 Код-3 Напарник: %Var1% %Var2%{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/кпп1::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-1-1 КПП Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/кпп2::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-1-2 КПП Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/кпп3::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-1-3 КПП Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/дч1::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-1-1 Дежурная часть Код-3{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/дч2::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput,  /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput,  /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-1-2 Дежурная часть Код-3{Enter}{F6}
Sleep 200 ;
SendInput,  /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter} 
PlayRadioSfx("radio_stop.wav")
Return

:?:/дч3::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput,  /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput,  /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /r %Teg%-%Prop2% 10-1-3 Дежурная часть Код-3{Enter}{F6}
Sleep 200 ;
SendInput,  /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/в1::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 200 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 200 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-24{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/в2::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 200 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 200 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-25{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/в+::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 200 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 200 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-26{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/в-::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 200 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 200 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput, /r %Teg%-%Prop2% 10-26ЛВ{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
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
PlayRadioSfx("radio_start.wav")
SendInput, {Enter}
Sleep 2000
SendInput, {F8}s Мордой в пол, работает %Osn%{!}{Enter}{F8}
PlayRadioSfx("radio_stop.wav")
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
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/взрыв2::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
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
SoundPlay, %A_Scriptdir%\1.mp3, wait
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
SoundPlay, %A_Scriptdir%\1.mp3, wait
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
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
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
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/протдоп2::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
SendInput, {F6}
Sleep 250
SendInput, /me взяв ручку со стола, внес%ok2% в протокол данные о наличии запрещенных предметов{Enter}{F6}
Sleep 250
SendInput, /do В протокол внесены данные о наличии запрещенных предметов.{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/протдоп3::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/перчатки::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
SendInput, {F6}
Sleep 250
SendInput, /do На столе лежит упаковка с нитриловыми перчатками и зип-пакеты.{Enter}{F6}
Sleep 250
SendInput, /me достал%ok1% пару перчаток из упаковки и надел%ok1% на руки{Enter}{F6}
Sleep 250
SendInput, /do Перчатки на руках.{Enter}
PlayRadioSfx("radio_stop.wav")
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
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
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
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
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
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
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
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/выдформу::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
SendInput, {F6}
Sleep 250
SendInput, /do В шкафчике находится форма сотрудника.{Enter}{F6}
Sleep 500 ;
SendInput, /do Шкаф закрыт.{Enter}{F6}
Sleep 500 ;
SendInput, /do Ключ лежит на скамейке.{Enter}{F6}
Sleep 500 ;
SendInput, Берите ключ, открывайте шкаф, переодевайтесь.{Enter}
PlayRadioSfx("radio_stop.wav")
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
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput, /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput, /ro [ГУ МВД-%Bukv%][МВД]{Space}
PlayRadioSfx("radio_stop.wav")
Return

:?:/гибдд::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][УГИБДД]{Space}
PlayRadioSfx("radio_stop.wav")
Return

:?:/ржд::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][ОАО «РЖД»]{Space}
Return

:?:/мз::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][МЗ]{Space}
Return

:?:/армия::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][МО]{Space}
Return

:?:/гибддп::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][УГИБДД-П]{Space}
PlayRadioSfx("radio_stop.wav")
Return

:?:/гибддм::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][УГИБДД-М]{Space}
PlayRadioSfx("radio_stop.wav")
Return

:?:/гибддн::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][УГИБДД-Н]{Space}
PlayRadioSfx("radio_stop.wav")
Return

:?:/гувдп::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SendInput,  /me снял%ok1% рацию с нагрудного кармана и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][ГУ МВД-П]{Space}
PlayRadioSfx("radio_stop.wav")
Return

:?:/гувдм::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /ro [Г УМВД-%Bukv%][ГУ МВД-М]{Space}
PlayRadioSfx("radio_stop.wav")
Return

:?:/гувдн::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /ro [ГУ МВД-%Bukv%][ГУ МВД-Н]{Space}
PlayRadioSfx("radio_stop.wav")
Return

:?:/цгбп::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][ЦГБ-П]{Space}
Return

:?:/окбм::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][ОКБ-М]{Space}
Return

:?:/цгбн::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /d [ГУ МВД-%Bukv%][ЦГБ-Н]{Space}
Return

:?:/осндокл::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /d [%Osn%]{Space}
Return

:?:/оснвыз::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput,  /ro [%Osn%]{Space}
Return

:?:/помощьсобес::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 250
SendInput, {F6}
Sleep 500 
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 
SoundPlay, %A_Scriptdir%\1.mp3, wait
sleep 160
SendInput, /d [ГУ МВД-%Bukv%][МВД|МЗ|МО] Требуются сотрудники для помощи в проведении собеседования...{Enter}{F6}
Sleep 500
SendInput, /d [ГУ МВД-%Bukv%][МВД|МЗ|МО] ...Ожидаем на парковке ДЧ г. Невский.{Enter}{F6}
sleep 160
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 1000
SendInput,  /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Sleep 1000
PlayRadioSfx("radio_stop.wav")
Return

:?:/проверкасобес::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
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
SoundPlay, %A_Scriptdir%\1.mp3, wait
sleep 500
SendInput, /d [ГУ МВД-%Bukv%][УГИБДД] Проверьте гражданина с серией паспорта %Pass%...{Enter}{F6}
sleep 500
SendInput, /d [ГУ МВД-%Bukv%][УГИБДД] ...на штрафы.{Enter}{F6}
sleep 160
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 1000
SendInput,  /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Sleep 1000
PlayRadioSfx("radio_stop.wav")
Return

:?:/стук::
SendMessage, 0x50,, 0x4190419,, A
Sleep 100
SendInput, {Enter}
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
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
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
IniRead, Osn, %A_Temp%\data.egl, User, Osn
SendInput, {F6}
Sleep 250
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% её ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput, /ro [%Osn%][МВД] Начали спец. операцию по отлову ООП по Республике Провинции.{Enter}{F6}
Sleep 200 ;
SendInput, /me перевел%ok1% рацию в режим прослушивания и закрепил%ok1% на нагрудном кармане{Enter}
Return

:?:/ооп2::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Osn, %A_Temp%\data.egl, User, Osn
SendInput, {F6}
Sleep 250
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% её ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput, /ro [%Osn%][МВД] Продолжаем спец. операцию по отлову ООП по Республике Провинции.{Enter}{F6}
Sleep 200 ;
SendInput, /me перевел%ok1% рацию в режим прослушивания и закрепил%ok1% на нагрудном кармане{Enter}
Return

:?:/ооп3::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Osn, %A_Temp%\data.egl, User, Osn
SendInput, {F6}
Sleep 250
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% её ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 500 ;
SendInput, /ro [%Osn%][МВД] Закончили спец. операцию по отлову ООП по Республике Провинции.{Enter}{F6}
Sleep 200 ;
SendInput, /me перевел%ok1% рацию в режим прослушивания и закрепил%ok1% на нагрудном кармане{Enter}
Return

:?:/пмп1::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
SendInput, {F6}
Sleep 250
SendInput, /do Аптечка ПМП "ФЭСТ" находится в багажнике автомобиля.{Enter}{F6}
Sleep 500 ;
SendInput, /me взя%ok2% аптечку из багажника{Enter}{F6}
Sleep 500 ;
SendInput, /do Аптечка ПМП "ФЭСТ" в руке.{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/пмп2::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
SendInput, {F6}
Sleep 500
SendInput, /do Что случилось с пострадавшим?{Enter}{F6}
Sleep 500
SendInput, /b Напишите в чат через команду /do, что с вами случилось{Enter}{F6}
Sleep 500
SendInput, /b Пример: /do Пострадавшего сбила машина.{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/пмп3::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/пмп4::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
SendInput, {F6}
Sleep 250
SendInput, /do Аптечка ПМП "ФЭСТ" в руке.{Enter}{F6}
Sleep 500 ;
SendInput, /me поставил%ok1% аптечку на землю, открыл%ok1% её{Enter}{F6}
Sleep 500 ;
SendInput, /do Аптечка ПМП "ФЭСТ" открыта.{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/пмп5::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/пмп6::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
SendInput, {F6}
Sleep 250
SendInput, /do Аптечка ПМП "ФЭСТ" в руке.{Enter}{F6}
Sleep 500 ;
SendInput, /me положи%ok2% аптечку в багажник{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/оранения::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/пулевое::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/переломз::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/переломо::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
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
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/вступление::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
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
PlayRadioSfx("radio_stop.wav")
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
PlayRadioSfx("radio_start.wav")
SendInput, {F6}
Sleep 250
SendInput,Согласно 2.1.1 ПДД,вы обязаны предоставить ВУ или паспорт транспортного средства по требованию сотрудника полиции.{Enter}{F6}
PlayRadioSfx("radio_stop.wav")
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

:?:/наказание::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
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
PlayRadioSfx("radio_start.wav")
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
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
PlayRadioSfx("radio_stop.wav")
Return

:?:/трудоустройство::
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
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
IniRead, Teg, %A_Temp%\data.egl, User, Teg
IniRead, Prop2, %A_Temp%\data.egl, User, Prop2
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
SendInput, Благодарим за обращение, обработаем в кратчайшие сроки.{Enter}
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
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /d [ГУ МВД-%Bukv% ВП] Вылетел в воздушное патрулирование.{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/воздух2::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /d [ГУ МВД-%Bukv% ВП] Продолжаю воздушное патрулирование.{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

:?:/воздух3::
SendMessage, 0x50,, 0x4190419,, A
PlayRadioSfx("radio_start.wav")
IniRead, Bukv, %A_Temp%\data.egl, User, Bukv
Sleep 200
SendInput, {F6}
Sleep 200 ;
SendInput, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
Sleep 500 ;
SendInput, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
Sleep 500 ;
SoundPlay, %A_Scriptdir%\1.mp3, wait
Sleep 200 ;
SendInput,  /d [ГУ МВД-%Bukv% ВП] Закончил воздушное патрулирование.{Enter}{F6}
Sleep 200 ;
SendInput, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
PlayRadioSfx("radio_stop.wav")
Return

