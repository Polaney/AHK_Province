; <COMPILER: v1.1.37.02>
#SingleInstance Force
SetTitleMatchMode, 2
SetTitleMatchMode, Fast
CheckAdmin()
#NoEnv
#MaxThreadsPerHotkey 2
Process, Priority,, Normal
#InstallKeybdHook
#UseHook, On
SetStoreCapsLockMode, Off
SetWorkingDir %A_ScriptDir%
FileEncoding UTF-8

; Группа окон игры MTA Province / GTA San Andreas для изоляции боевых биндов
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
if (!FileExist(A_ScriptDir . "\ahkgibdd.ico")) {
    try {
        FileInstall, ahkgibdd.ico, %A_ScriptDir%\ahkgibdd.ico, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets"))
    FileCreateDir, %A_ScriptDir%\assets
if (!FileExist(A_ScriptDir . "\assets\fluent_hero.jpg")) {
    try {
        FileInstall, assets\fluent_hero.jpg, %A_ScriptDir%\assets\fluent_hero.jpg, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets\fluent_crest.jpg")) {
    try {
        FileInstall, assets\fluent_crest.jpg, %A_ScriptDir%\assets\fluent_crest.jpg, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets\fluent_patrol_card.jpg")) {
    try {
        FileInstall, assets\fluent_patrol_card.jpg, %A_ScriptDir%\assets\fluent_patrol_card.jpg, 1
    }
}
if (!FileExist(A_ScriptDir . "\assets\fluent_template.html")) {
    try {
        FileInstall, assets\fluent_template.html, %A_ScriptDir%\assets\fluent_template.html, 1
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

AbortBindFlag := 0
RefreshTray()
Gosub, AHK
Return

InitDpiAwareness() {
    try {
        DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
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
        ; По умолчанию: SendInput (Мгновенный аппаратный ввод без видимой печати по буквам и без хука Journal Playback)
        ; Исключает детекты античита MTA 1.6 (AC #4) и отправляет команды мгновенно
        SendMode, Input
        ActiveSendEngine := "SendInput (Мгновенный)"
    }
}

ChangeSendEngine:
Gui, 1:Submit, NoHide
if InStr(SendEngineDDL, "SendPlay")
    chosenEngine := "SendPlay"
else if InStr(SendEngineDDL, "SendEvent")
    chosenEngine := "SendEvent"
else if InStr(SendEngineDDL, "SendInput")
    chosenEngine := "SendInput"
else
    chosenEngine := "AUTO"
ApplySendEngineMode(chosenEngine)
for idx, targetIni in [A_Temp . "\gibdd.egl", A_ScriptDir . "\gibdd_profile.ini"] {
    IniWrite, %chosenEngine%, %targetIni%, Settings, SendMethod
}
TrayTip, Движок ввода обновлён, % "Активен режим: " . ActiveSendEngine, 2, 1
Return

CheckAdmin()
{
    if (!A_IsAdmin)
    {
        try
        {
            if (A_IsCompiled)
                Run *RunAs "%A_ScriptFullPath%" /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
        ExitApp
    }
}

CheckUIA()
{
    if (!A_IsCompiled && !InStr(A_AhkPath, "_UIA")) {
        Run % "*uiAccess """ . A_ScriptFullPath . """"
        ExitApp
    }
}

SetLocaleRu()
{
    SendMessage, 0x50,, 0x4190419,, A
}

SetLocaleEn()
{
    SendMessage, 0x50,, 0x4090409,, A
}

CheckLocaleAndSet(String) {
    if (RegExMatch(String, "[А-Яа-яЁё]")) {
        SetLocaleRu()
    } else {
        SetLocaleEn()
    }
}

SetCapsOff()
{
    SetCapsLockState Off
}

Encoded(Target)
{
    Target := StrReplace(Target, "#", "{#}")
    Target := StrReplace(Target, "!", "{!}")
    Target := StrReplace(Target, "^", "{^}")
    Target := StrReplace(Target, "+", "{+}")
    Target := StrReplace(Target, "&", "{&}")
    Return Target
}

; Умная задержка с мгновенным прерыванием по клавише отмены отыгровки (по умолчанию F12)
SmartSleep(DurationMs)
{
    global AbortBindFlag
    if (AbortBindFlag) {
        AbortBindFlag := 0
        Exit
    }
    rem := DurationMs + 0
    while (rem > 0) {
        step := (rem > 50) ? 50 : rem
        Sleep, %step%
        rem -= step
        if (AbortBindFlag) {
            AbortBindFlag := 0
            Exit
        }
    }
}

Bind_StopAction:
AbortBindFlag := 1
SetTimer, ClearAbortBindFlag, -450
SoundBeep, 750, 120
TrayTip, УГИБДД АХК, ⛔ Текущая отыгровка / лекция остановлена!, 2, 2
Return

ClearAbortBindFlag:
AbortBindFlag := 0
Return

RefreshTray()
{
    global HIDDEN_NOW
    HIDDEN_NOW := 0
    TrayTip, AHK УГИБДД МВД, Биндер успешно запущен!, 2, 1
    IM = %A_ScriptDir%\ahkgibdd.ico
    IfExist, %IM%
        Menu, Tray, Icon, %IM%
    Menu, Tray, NoStandard
    Menu, Tray, Add, HideShowMenu
    Menu, Tray, Rename, HideShowMenu, Свернуть
    Menu, Tray, Default, Свернуть
    Menu, Tray, Add
    Menu, Tray, Add, ⚖️ Калькулятор КоАП / УК, OpenCalc
    Menu, Tray, Add, ⌨️ Настройка клавиш, SwitchToHotkeysTab
    Menu, Tray, Add, ⏱️ Показать / скрыть HUD, ToggleHud
    Menu, Tray, Add, 🎯 Переместить HUD (Drag&Drop), ToggleHudEditMode
    Menu, Tray, Add
    Menu, Tray, Add, VKowner
    Menu, Tray, Rename, VKowner, Goldcherry (ВК)
    Menu, Tray, Add, VKmemo
    Menu, Tray, Rename, VKmemo, Памятка
    Menu, Tray, Add
    Menu, Tray, Add, 🚀 Проверить обновления, ManualCheckUpdates
    Menu, Tray, Add, ReloadMenu
    Menu, Tray, Rename, ReloadMenu, Перезапуск
    Menu, Tray, Add, ExitMenu
    Menu, Tray, Rename, ExitMenu, Закрыть
    Menu, Tray, Tip, АХК УГИБДД МВД Провинции
}

VKowner:
Run, https://vk.com/id218945813
Return

VKmemo:
Run, https://vk.cc/d2XUNg
Return

ReloadMenu:
Reload
Return

HideShowMenu:
If HIDDEN_NOW
{
    Menu, Tray, Rename, Развернуть, Свернуть
    if (FluentUiMode)
        Gui, 8:Show
    else
        Gui, 1:Show
}
Else
{
    Menu, Tray, Rename, Свернуть, Развернуть
    Gui, 8:Hide
    Gui, 1:Hide
}
HIDDEN_NOW := !HIDDEN_NOW
Return

ExitMenu:
ExitApp
Return

YesUpdate:
Return

EncodeDelete(Target)
{
    for Key, Value in ["#", "!", "^", "+", "&", "`", ",", ".", ";", "'", "/", "\", "-", "="]
        Target := StrReplace(Target, Value, "")
    Return Target
}

SendChat(TextBind, SleepBind)
{
    SetLocaleRu()
    SetCapsOff()
    TextBind := Encoded(TextBind)
    Send {F8}^A{Delete}%TextBind%{Enter}{F8}
    SmartSleep(SleepBind)
}

GetInput(Target, GUIText, ConsoleText)
{
    SetLocaleRu()
    SetCapsOff()
    if(InputType){
        InputBox %Target%, TechnoAHK:Input, % GUIText
        if ErrorLevel
            Return
        else if %Target% =
            Return
    } else {
        Send {F8}%ConsoleText%{Space}
        Input %Target%, V, {Enter} 
        Send {F8}
    }
}

GetTryRes()
{
    global ProvLogPath, LastTryResult, LastTryTime, InputType
    Sleep 150
    if (LastTryResult != "" && (A_TickCount - LastTryTime < 5000)) {
        return (InStr(LastTryResult, "УДАЧНО") > 0)
    }
    LogFile := ResolveConsoleLogPath()
    if (LogFile != "" && FileExist(LogFile)) {
        TailText := ReadLogTailString(LogFile, 4096)
        if (TailText != "") {
            Loop, Parse, TailText, `n, `r
            {
                if (A_LoopField != "")
                    LastLine := A_LoopField
            }
            if (InStr(LastLine, "Неудачно") || InStr(LastLine, "РќРµСѓРґР°С‡РЅРѕ"))
                return False
            if (InStr(LastLine, "Удачно") || InStr(LastLine, "РЈРґР°С‡РЅРѕ"))
                return True
        }
    }
    if(InputType){
        MsgBox, 36, Результат, Удачно?
        IfMsgBox, Yes
            Return True
        IfMsgBox, No
            Return False
    } else {
        Send {F8}Удачно? введите "да" или "нет" (в любой раскладке):{Space}
        Input TryRes, V, {Enter} 
        Send {F8}
        if(TryRes=="да")||(TryRes=="lf")||(TryRes=="ДА")||(TryRes=="LF")
            Return True
        if(TryRes=="нет")||(TryRes=="ytn")||(TryRes=="НЕТ")||(TryRes=="YTN")
            Return False
        else
            Return False
    }
}

ReadComFile(FileName){
    Loop, read, %FileName%
        SendChat(Encoded(A_LoopReadLine), ComFileDelay)
}

GetArgsForHotstring(Hotstring, Target)
{
    Send ^A{Delete}/%Hotstring%{Space}
    Input %Target%, V, {Enter}
}

; =================================================================================================
; ИНИЦИАЛИЗАЦИЯ ДАННЫХ, МЕНЕДЖЕРА КЛАВИШ, БАЗЫ СТАТЕЙ, КАТАЛОГА БИНДОВ, ТАЙМЕРОВ И GUI
; =================================================================================================
AHK:
InitDpiAwareness()
DetectWindowsVersion()
EnsureDefaultConfig()
LoadUserConfig()
ApplySendEngineMode(SendMethodConfig)

if (Gender = "Я девочка")
{
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
    Pol = 👩‍⚕️
    Gend = женский
}
else
{
    Vers = 2.5.0м
    Ok1 =
    Ok2 =
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
    Pol = 👨‍⚕️
    Gend = мужской
}

Random, Var, 1, 5
TextArray := ["УГИБДД МВД Провинции — Служба, Честь и Безопасность на дорогах!"
, "Контроль за соблюдением ПДД — обязанность каждого сотрудника!"
, "Сотрудник обязан знать и соблюдать ПСФ, ФЗоП, КоАП и УК РП!"
, "Кликните по любой клавише в GUI или откройте вкладку «⌨️ Клавиши» для переназначения биндов!"
, "Используйте Alt+F1 для Калькулятора КоАП/УК и Alt+H для HUD таймеров!"]

CheckUIA()
Menu, Tray, Icon, %A_ScriptDir%\ahkgibdd.ico

InitHotkeysManager()
InitArticlesDB()
InitBindsCatalog()
InitTimersAndLogReader()
InitAutoUpdater()
TabletRelay_Init()
InitClientHeartbeat()

; -------------------------------------------------------------------------------------------------
; ГЛАВНОЕ ОКНО (GUI 1) — ТЁМНАЯ ТЕМА МВД / УГИБДД + ПОИСК + НАСТРОЙКА КЛАВИШ
; -------------------------------------------------------------------------------------------------
Gui, 1:Destroy
Gui, 1:Color, 121622, 1B2234

; =================================================================================================
; ЛЕВЫЙ БОКОВОЙ САЙДБАР (СОВРЕМЕННОЕ БОКОВОЕ МЕНЮ)
; =================================================================================================
Gui, 1:Font, S11 C58A6FF Bold, Segoe UI
Gui, 1:Add, Text, x10 y8 w188 h22, 🚔 УГИБДД МВД
Gui, 1:Font, S8 C8B949E Bold, Segoe UI
Gui, 1:Add, Text, x10 y30 w188 h16, MTA PROVINCE • RP BINDER

; Виджет профиля офицера
Gui, 1:Font, S8 C58A6FF Bold, Segoe UI
Gui, 1:Add, GroupBox, x8 y48 w192 h90, [ 👤 Мой профиль ]
Gui, 1:Font, S9 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Text, x14 y65 w180 h17 vSidebarOfficerFio, % Rank . " " . Fio1
Gui, 1:Font, S8 C8B949E Norm, Segoe UI
Gui, 1:Add, Text, x14 y82 w180 h15 vSidebarOfficerDetails, % "Отдел: " . Otdel . " | Знак: " . Znak
Gui, 1:Add, Text, x14 y97 w180 h15 vSidebarOfficerCallsign, % "Позывной: " . Teg . "-" . Prop2
Gui, 1:Font, S8 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Button, x14 y113 w180 h22 gData, ⚙️ Изменить анкету

; Кнопки навигации по разделам
Gui, 1:Font, S9 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Button, x8 y144 w192 h30 vNavBtn1 gSelectTab1, 🚔 Патруль и СГУ
Gui, 1:Add, Button, x8 yp+32 w192 h30 vNavBtn2 gSelectTab2, 📻 Доклады в рацию
Gui, 1:Add, Button, x8 yp+32 w192 h30 vNavBtn3 gSelectTab3, ⛓️ Задержание и КПЗ
Gui, 1:Add, Button, x8 yp+32 w192 h30 vNavBtn4 gSelectTab4, 📚 Лекции и Устав
Gui, 1:Add, Button, x8 yp+32 w192 h30 vNavBtn5 gSelectTab5, 🩹 Первая помощь
Gui, 1:Add, Button, x8 yp+32 w192 h30 vNavBtn6 gSelectTab6, 🔍 Поиск биндов
Gui, 1:Add, Button, x8 yp+32 w192 h30 vNavBtn7 gSelectTab7, ⌨️ Клавиши и ОС
Gui, 1:Add, Button, x8 yp+32 w192 h30 vNavBtn8 gSelectTab8, 📊 Журнал нормы
Gui, 1:Add, Button, x8 yp+32 w192 h30 vNavBtn9 gSelectTab9, ➕ Свои бинды

; Быстрые действия внизу сайдбара
Gui, 1:Font, S8 C58A6FF Bold, Segoe UI
Gui, 1:Add, Text, x12 y438 w184 h16, 🛠️ БЫСТРЫЕ ДЕЙСТВИЯ:
Gui, 1:Font, S8 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Button, x8 y444 w192 h22 gOpenCalc, ⚖️ Калькулятор (Alt+F1)
Gui, 1:Add, Button, x8 yp+24 w192 h22 gOpenFzopGuide, 📘 Статьи ФЗоП (/фзоп)
Gui, 1:Add, Button, x8 yp+24 w192 h22 gOpenKoapGuide, 📕 Статьи КоАП (/коап)
Gui, 1:Add, Button, x8 yp+24 w192 h22 gOpenUkGuide, 📙 Статьи УК РП (/ук)
Gui, 1:Add, Button, x8 yp+24 w192 h22 gToggleHud, ⏱️ HUD таймеров (Alt+H)
Gui, 1:Add, Button, x8 yp+27 w192 h25 gToggleHudEditMode, 🎯 Двигать HUD (Alt+Shift+H)
Gui, 1:Add, Button, x8 yp+27 w192 h25 gManualCheckUpdates, 🚀 Проверить обновления
Gui, 1:Add, Button, x8 yp+27 w192 h25 gReload, 🔄 Перезапуск (F11)
Gui, 1:Add, Button, x8 yp+27 w192 h25 gGuiClose, ❌ Свернуть в трей
Gui, 1:Font, S8 C8B949E Norm, Segoe UI
Gui, 1:Add, Text, x10 y654 w188 h18, % "Версия v" . Vers

; =================================================================================================
; ШАПКА ОСНОВНОЙ РАБОЧЕЙ ОБЛАСТИ
; =================================================================================================
Gui, 1:Font, S11 C58A6FF Bold, Segoe UI
Gui, 1:Add, Text, x218 y8 w510 h24 vMainSectionTitle, 🚔 ПАТРУЛЬ И ОПЕРАТИВНЫЕ ДЕЙСТВИЯ
Gui, 1:Font, S9 C8B949E Norm, Segoe UI
Gui, 1:Add, Text, x730 y8 w396 h24 +Right vMainRightStatus, % "🎯 ID: " . (LastTargetID != "" ? LastTargetID : "ожидание...") . "  |  🛡️ " . WinVerDescription . " • " . ActiveSendEngine

; БЕСШОВНЫЙ TAB-КОНТРОЛ (кнопки вкладок вынесены за пределы экрана вверх)
Gui, 1:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Tab2, x208 y-28 w930 h675 -Wrap vMainTabControl, 1|2|3|4|5|6|7|8|9

; ======================= ВКЛАДКА 1: ПАТРУЛЬ И СГУ =======================
Gui, 1:Tab, 1
Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x214 y44 w302 h285, [ Основное (клик по клавише = изменить) ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x222 y64 h20 w155, Приветствие гражд
Gui, 1:Add, Text, x222 yp+20 h20 w155, Просить документы
Gui, 1:Add, Text, x222 yp+20 h20 w155, Взять документы
Gui, 1:Add, Text, x222 yp+20 h20 w155, Вернуть документы
Gui, 1:Add, Text, x222 yp+20 h20 w155, Передача конвоиру
Gui, 1:Add, Text, x222 yp+20 h20 w155, Выд.розыск (быстро)
Gui, 1:Add, Text, x222 yp+20 h20 w155, Fines (штрафы)
Gui, 1:Add, Text, x222 yp+20 h20 w155, Wanted (розыск)
Gui, 1:Add, Text, x222 yp+20 h20 w155, КПК достать
Gui, 1:Add, Text, x222 yp+20 h20 w155, КПК (ВУ)
Gui, 1:Add, Text, x222 yp+20 h20 w155, КПК убрать
Gui, 1:Add, Text, x222 yp+20 h20 w155, Посадить в авто
Gui, 1:Add, Text, x222 yp+20 h20 w155, Вытащ из патрульки
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x382 y64 h20 w125 vDisp_HK_Greeting gQuickClickKey, % GetKeyDisp("HK_Greeting")
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_AskDocs gQuickClickKey, % GetKeyDisp("HK_AskDocs")
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_TakeDocs gQuickClickKey, % GetKeyDisp("HK_TakeDocs")
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_ReturnDocs gQuickClickKey, % GetKeyDisp("HK_ReturnDocs")
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_Arrest gQuickClickKey, % GetKeyDisp("HK_Arrest")
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_SuFast gQuickClickKey, % GetKeyDisp("HK_SuFast")
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_Fines gQuickClickKey, % GetKeyDisp("HK_Fines")
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_Wanted gQuickClickKey, % GetKeyDisp("HK_Wanted")
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_KpkOpen gQuickClickKey, % GetKeyDisp("HK_KpkOpen")
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_KpkVu gQuickClickKey, % GetKeyDisp("HK_KpkVu")
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_KpkClose gQuickClickKey, % GetKeyDisp("HK_KpkClose")
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_Putpl gQuickClickKey, % GetKeyDisp("HK_Putpl")
Gui, 1:Add, Text, x382 yp+20 h20 w125, /вытащить

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x214 y334 w302 h85, [ Автомобиль ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x222 y354 h20 w155, Выдать розыск авто
Gui, 1:Add, Text, x222 yp+20 h20 w155, База розыска авто
Gui, 1:Add, Text, x222 yp+20 h20 w155, Пробить авто
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x382 y354 h20 w125 vDisp_HK_Wcar1 gQuickClickKey, % GetKeyDisp("HK_Wcar") . " (1)"
Gui, 1:Add, Text, x382 yp+20 h20 w125 vDisp_HK_Wcar2 gQuickClickKey, % GetKeyDisp("HK_Wcar") . " (2)"
Gui, 1:Add, Text, x382 yp+20 h20 w125, /фкар

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x214 y424 w302 h85, [ Удары (/try) и Оружие ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x222 y444 h20 w155, Приклад АК-74М
Gui, 1:Add, Text, x222 yp+20 h20 w155, Рукоять Пистолета
Gui, 1:Add, Text, x222 yp+20 h20 w155, Сборка/Разб АК-74М
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x382 y444 h20 w125, /ударкалаш
Gui, 1:Add, Text, x382 yp+20 h20 w125, /ударпистолет
Gui, 1:Add, Text, x382 yp+20 h20 w125, /разбор(1-2)

Gui, 1:Font, S9 C79C0FF Bold, Segoe UI
Gui, 1:Add, Text, x220 y516 w290 h18 g43, ℹ️ Нажмите сюда (подробности по * и нажатиям)
Gui, 1:Add, Text, x220 y536 w140 h18 g41, * Одно нажатие (1)
Gui, 1:Add, Text, x367 y536 w140 h18 g42, * Два нажатия (2)

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x522 y44 w302 h185, [ Оформление ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x530 y64 h20 w165, Составить протокол
Gui, 1:Add, Text, x530 yp+20 h20 w165, Перед на подпись
Gui, 1:Add, Text, x530 yp+20 h20 w165, Забрать протокол
Gui, 1:Add, Text, x530 yp+20 h20 w165, Выд.розыск (с РП)
Gui, 1:Add, Text, x530 yp+20 h20 w165, Вып.штраф (/tsu)
Gui, 1:Add, Text, x530 yp+20 h20 w165, Лишить ВУ
Gui, 1:Add, Text, x530 yp+20 h20 w165, Открыть наручники
Gui, 1:Add, Text, x530 yp+20 h20 w165, Закрыть наручники
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x697 y64 h20 w120 vDisp_HK_AdminProt gQuickClickKey, % GetKeyDisp("HK_AdminProt")
Gui, 1:Add, Text, x697 yp+20 h20 w120 vDisp_HK_ProtSign1 gQuickClickKey, % GetKeyDisp("HK_ProtocolSign") . " (1)"
Gui, 1:Add, Text, x697 yp+20 h20 w120 vDisp_HK_ProtSign2 gQuickClickKey, % GetKeyDisp("HK_ProtocolSign") . " (2)"
Gui, 1:Add, Text, x697 yp+20 h20 w120 vDisp_HK_SuSound gQuickClickKey, % GetKeyDisp("HK_SuSound")
Gui, 1:Add, Text, x697 yp+20 h20 w120 vDisp_HK_Tsu gQuickClickKey, % GetKeyDisp("HK_Tsu")
Gui, 1:Add, Text, x697 yp+20 h20 w120 vDisp_HK_TakeLic gQuickClickKey, % GetKeyDisp("HK_TakeLic")
Gui, 1:Add, Text, x697 yp+20 h20 w120 vDisp_HK_CuffsOpen gQuickClickKey, % GetKeyDisp("HK_CuffsOpen")
Gui, 1:Add, Text, x697 yp+20 h20 w120 vDisp_HK_CuffsClose gQuickClickKey, % GetKeyDisp("HK_CuffsClose")

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x522 y232 w302 h342, [ Дополнения ]
Gui, 1:Font, S9 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x530 y250 h18 w165, Часы (timestamp)
Gui, 1:Add, Text, x530 yp+17 h18 w165, Дернуть ручку авто
Gui, 1:Add, Text, x530 yp+17 h18 w165, Удар по стеклу
Gui, 1:Add, Text, x530 yp+17 h18 w165, Откр дверь изнутри
Gui, 1:Add, Text, x530 yp+17 h18 w165, Достать из авто
Gui, 1:Add, Text, x530 yp+17 h18 w165, Рация вкл (голос)
Gui, 1:Add, Text, x530 yp+17 h18 w165, Рация прослуш
Gui, 1:Add, Text, x530 yp+17 h18 w165, Приветствие коллег
Gui, 1:Add, Text, x530 yp+17 h18 w165, База сотрудников
Gui, 1:Add, Text, x530 yp+17 h18 w165, Дверь открыта
Gui, 1:Add, Text, x530 yp+17 h18 w165, Дверь заперта
Gui, 1:Add, Text, x530 yp+17 h18 w165, Кнопка SOS
Gui, 1:Add, Text, x530 yp+17 h18 w165, Оформление ДТП
Gui, 1:Add, Text, x530 yp+17 h18 w165, Камеры ДТП
Gui, 1:Add, Text, x530 yp+17 h18 w165, Метка о несогласии
Gui, 1:Add, Text, x530 yp+17 h18 w165, Метка о невозможн.
Gui, 1:Add, Text, x530 yp+17 h18 w165, Вырвать копию
Gui, 1:Add, Text, x530 yp+17 h18 w165, Боди-камера DOZOR
Gui, 1:Font, S9 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x697 y250 h18 w120 vDisp_HK_Clock gQuickClickKey, % GetKeyDisp("HK_Clock")
Gui, 1:Add, Text, x697 yp+17 h18 w120 vDisp_HK_TryDoor gQuickClickKey, % GetKeyDisp("HK_TryDoor")
Gui, 1:Add, Text, x697 yp+17 h18 w120 vDisp_HK_TryGlass gQuickClickKey, % GetKeyDisp("HK_TryGlass")
Gui, 1:Add, Text, x697 yp+17 h18 w120 vDisp_HK_UnlockIn gQuickClickKey, % GetKeyDisp("HK_UnlockIn")
Gui, 1:Add, Text, x697 yp+17 h18 w120 vDisp_HK_PullOutTry gQuickClickKey, % GetKeyDisp("HK_PullOutTry")
Gui, 1:Add, Text, x697 yp+17 h18 w120 vDisp_HK_VoiceOn gQuickClickKey, % GetKeyDisp("HK_VoiceOn")
Gui, 1:Add, Text, x697 yp+17 h18 w120 vDisp_HK_VoiceOff gQuickClickKey, % GetKeyDisp("HK_VoiceOff")
Gui, 1:Add, Text, x697 yp+17 h18 w120 vDisp_HK_GreetColleague gQuickClickKey, % GetKeyDisp("HK_GreetColleague")
Gui, 1:Add, Text, x697 yp+17 h18 w120 vDisp_HK_FindEmp gQuickClickKey, % GetKeyDisp("HK_FindEmp")
Gui, 1:Add, Text, x697 yp+17 h18 w120, /дверь+
Gui, 1:Add, Text, x697 yp+17 h18 w120, /дверь-
Gui, 1:Add, Text, x697 yp+17 h18 w120, /sos
Gui, 1:Add, Text, x697 yp+17 h18 w120, /дтп(1-3)
Gui, 1:Add, Text, x697 yp+17 h18 w120, /дтпкам
Gui, 1:Add, Text, x697 yp+17 h18 w120, /метка1
Gui, 1:Add, Text, x697 yp+17 h18 w120, /метка2
Gui, 1:Add, Text, x697 yp+17 h18 w120, /копия
Gui, 1:Add, Text, x697 yp+17 h18 w120, /камера

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x830 y44 w298 h165, [ СГУ и Умная Погоня (15с) ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x838 y64 h20 w160, 🚨 Умный мегафон (1-3)
Gui, 1:Add, Text, x838 yp+20 h20 w160, 🛑 Сброс погони
Gui, 1:Add, Text, x838 yp+20 h20 w160, Пред 1 (Зелёный)
Gui, 1:Add, Text, x838 yp+20 h20 w160, Пред 2 (Жёлтый)
Gui, 1:Add, Text, x838 yp+20 h20 w160, Пред 3 (Огонь!)
Gui, 1:Add, Text, x838 yp+20 h20 w160, Уступите дорогу
Gui, 1:Add, Text, x838 yp+20 h20 w160, Пешая погоня
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x1002 y64 h20 w120 vDisp_HK_SmartMegaphone gQuickClickKey, % GetKeyDisp("HK_SmartMegaphone")
Gui, 1:Add, Text, x1002 yp+20 h20 w120 vDisp_HK_ChaseStop gQuickClickKey, % GetKeyDisp("HK_ChaseStop")
Gui, 1:Add, Text, x1002 yp+20 h20 w120 vDisp_HK_Megaphone1 gQuickClickKey, % GetKeyDisp("HK_Megaphone1")
Gui, 1:Add, Text, x1002 yp+20 h20 w120 vDisp_HK_Megaphone2 gQuickClickKey, % GetKeyDisp("HK_Megaphone2")
Gui, 1:Add, Text, x1002 yp+20 h20 w120 vDisp_HK_Megaphone3 gQuickClickKey, % GetKeyDisp("HK_Megaphone3")
Gui, 1:Add, Text, x1002 yp+20 h20 w120 vDisp_HK_MegaphoneWay gQuickClickKey, % GetKeyDisp("HK_MegaphoneWay")
Gui, 1:Add, Text, x1002 yp+20 h20 w120 vDisp_HK_FootChase gQuickClickKey, % GetKeyDisp("HK_FootChase")

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x830 y215 w298 h102, [ Окно автомобиля ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x838 y233 h20 w160, Окно разбито
Gui, 1:Add, Text, x838 yp+19 h20 w160, Окно цело
Gui, 1:Add, Text, x838 yp+19 h20 w160, Постучать в окно
Gui, 1:Add, Text, x838 yp+19 h20 w160, Окно открыто?
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x1002 y233 h20 w120, /окно+
Gui, 1:Add, Text, x1002 yp+19 h20 w120, /окно-
Gui, 1:Add, Text, x1002 yp+19 h20 w120 vDisp_HK_KnockWindow gQuickClickKey, % "/стук|" . GetKeyDisp("HK_KnockWindow")
Gui, 1:Add, Text, x1002 yp+19 h20 w120, /окно?

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x830 y323 w298 h120, [ Приборы: Тауметр / Рег / Алко ]
Gui, 1:Font, S10 C79C0FF Bold, Consolas
Gui, 1:Add, Text, x838 y341 h20 w160 g44, * Тауметр (инфо)
Gui, 1:Add, Text, x838 yp+19 h20 w160 g44, * Доки тауметр
Gui, 1:Add, Text, x838 yp+19 h20 w160 g45, * Видеорегистратор
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x838 yp+19 h20 w160, Алкотестер
Gui, 1:Font, S10 C79C0FF Bold, Consolas
Gui, 1:Add, Text, x838 yp+19 h20 w160 g46, * Доки алкотестер
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x1002 y341 h20 w120, /таум(1-6)
Gui, 1:Add, Text, x1002 yp+19 h20 w120, /доктаум(1-4)
Gui, 1:Add, Text, x1002 yp+19 h20 w120, /рег(1-4)
Gui, 1:Add, Text, x1002 yp+19 h20 w120, /алко(1-5,+,-)
Gui, 1:Add, Text, x1002 yp+19 h20 w120, /докалко(1-4)

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x830 y449 w298 h127, [ Статьи КоАП / УК / ПДД ]
Gui, 1:Font, S9 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, Text, x840 y466 w280 h32, Откройте чат [T] и введите /коап, /укрп, /пдд или /фзоп:
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x840 y500 w280 h18, Пример: /коап5.2, /пдд211, /укрп5.8
Gui, 1:Font, S9 C8B949E Norm, Segoe UI
Gui, 1:Add, Text, x840 y520 w280 h18, Статьи выше x.9 без точки: 1711, 1712, 1715
Gui, 1:Font, S9 C58A6FF Bold, Segoe UI
Gui, 1:Add, Text, x840 y542 w280 h28 gOpenCalc, 👉 Или нажмите Alt+F1 для Умного Калькулятора!


; ======================= ВКЛАДКА 2: ДОКЛАДЫ =======================
Gui, 1:Tab, 2
Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x214 y44 w302 h150, [ Патруль (Таймер 15 мин) ]
Gui, 1:Font, S10 C79C0FF Bold, Consolas
Gui, 1:Add, Text, x222 y64 h20 w165 g24, * Выехал в патруль
Gui, 1:Add, Text, x222 yp+20 h20 w165 g24, * Продолжаю патруль
Gui, 1:Add, Text, x222 yp+20 h20 w165 g24, * Закончил патруль
Gui, 1:Add, Text, x222 yp+20 h20 w165 g25, * Вылетел в патруль
Gui, 1:Add, Text, x222 yp+20 h20 w165 g25, * Продолжаю воздушн.
Gui, 1:Add, Text, x222 yp+20 h20 w165 g25, * Закончил воздушн.
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x392 y64 h20 w115, /п1
Gui, 1:Add, Text, x392 yp+20 h20 w115, /п2
Gui, 1:Add, Text, x392 yp+20 h20 w115, /п3
Gui, 1:Add, Text, x392 yp+20 h20 w115, /вп1
Gui, 1:Add, Text, x392 yp+20 h20 w115, /вп2
Gui, 1:Add, Text, x392 yp+20 h20 w115, /вп3

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x214 y200 w302 h90, [ Стационарный пост (20 мин) ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x222 y220 h20 w165, Заступил на пост
Gui, 1:Add, Text, x222 yp+20 h20 w165, Продолжаю пост
Gui, 1:Add, Text, x222 yp+20 h20 w165, Сдал пост
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x392 y220 h20 w115, /пост1
Gui, 1:Add, Text, x392 yp+20 h20 w115, /пост2
Gui, 1:Add, Text, x392 yp+20 h20 w115, /пост3

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x214 y296 w302 h110, [ Доклады оформления ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x222 y316 h20 w165, Оформляю ДТП
Gui, 1:Add, Text, x222 yp+20 h20 w165, Закончил оформ ДТП
Gui, 1:Add, Text, x222 yp+20 h20 w165, Оформляю наруш
Gui, 1:Add, Text, x222 yp+20 h20 w165, Законч оформ наруш
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x392 y316 h20 w115, /дттп1
Gui, 1:Add, Text, x392 yp+20 h20 w115, /дттп2
Gui, 1:Add, Text, x392 yp+20 h20 w115, /он1
Gui, 1:Add, Text, x392 yp+20 h20 w115, /он2

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x522 y44 w302 h110, [ Вызов ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x530 y64 h20 w165, Выехал на вызов
Gui, 1:Add, Text, x530 yp+20 h20 w165, Прибыл на вызов
Gui, 1:Add, Text, x530 yp+20 h20 w165, Вызов обработан
Gui, 1:Add, Text, x530 yp+20 h20 w165, Вызов ложный
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x697 y64 h20 w115, /в1
Gui, 1:Add, Text, x697 yp+20 h20 w115, /в2
Gui, 1:Add, Text, x697 yp+20 h20 w115, /в+
Gui, 1:Add, Text, x697 yp+20 h20 w115, /в-

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x522 y160 w302 h90, [ Проведение рейда ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x530 y180 h20 w165, Начало рейда
Gui, 1:Add, Text, x530 yp+20 h20 w165, Продолжаем рейд
Gui, 1:Add, Text, x530 yp+20 h20 w165, Закончили рейд
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x697 y180 h20 w115, /рейд1
Gui, 1:Add, Text, x697 yp+20 h20 w115, /рейд2
Gui, 1:Add, Text, x697 yp+20 h20 w115, /рейд3

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x522 y256 w302 h170, [ Запросы МВД ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x530 y276 h20 w165, Кто примет наруш
Gui, 1:Add, Text, x530 yp+20 h20 w165, 10-13 ГУМВД-П
Gui, 1:Add, Text, x530 yp+20 h20 w165, 10-13 ГУМВД-М
Gui, 1:Add, Text, x530 yp+20 h20 w165, 10-13 ГУМВД-Н
Gui, 1:Add, Text, x530 yp+20 h20 w165, 10-13 УГИБДД-П
Gui, 1:Add, Text, x530 yp+20 h20 w165, 10-13 УГИБДД-М
Gui, 1:Add, Text, x530 yp+20 h20 w165, 10-13 УГИБДД-Н
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x697 y276 h20 w115, /гун
Gui, 1:Add, Text, x697 yp+20 h20 w115, /13п
Gui, 1:Add, Text, x697 yp+20 h20 w115, /13м
Gui, 1:Add, Text, x697 yp+20 h20 w115, /13н
Gui, 1:Add, Text, x697 yp+20 h20 w115, /13уп
Gui, 1:Add, Text, x697 yp+20 h20 w115, /13ум
Gui, 1:Add, Text, x697 yp+20 h20 w115, /13ун

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x522 y432 w302 h90, [ Областной патруль ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x530 y452 h20 w165, Выехал в обл
Gui, 1:Add, Text, x530 yp+20 h20 w165, Продолжаю обл
Gui, 1:Add, Text, x530 yp+20 h20 w165, Закончил обл
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x697 y452 h20 w115, /обл1
Gui, 1:Add, Text, x697 yp+20 h20 w115, /обл2
Gui, 1:Add, Text, x697 yp+20 h20 w115, /обл3

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x830 y44 w298 h435, [ Вызов гос. структур (/ro) ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x838 y64 h20 w160, Код-0
Gui, 1:Add, Text, x838 yp+20 h20 w160, Код-1
Gui, 1:Add, Text, x838 yp+20 h20 w160, Принял
Gui, 1:Add, Text, x838 yp+20 h20 w160, МВД
Gui, 1:Add, Text, x838 yp+20 h20 w160, УГИБДД
Gui, 1:Add, Text, x838 yp+20 h20 w160, РЖД
Gui, 1:Add, Text, x838 yp+20 h20 w160, МЗ
Gui, 1:Add, Text, x838 yp+20 h20 w160, Армия
Gui, 1:Add, Text, x838 yp+20 h20 w160, УГИБДД-П
Gui, 1:Add, Text, x838 yp+20 h20 w160, УГИБДД-М
Gui, 1:Add, Text, x838 yp+20 h20 w160, УГИБДД-Н
Gui, 1:Add, Text, x838 yp+20 h20 w160, ГУМВД-П
Gui, 1:Add, Text, x838 yp+20 h20 w160, ГУМВД-М
Gui, 1:Add, Text, x838 yp+20 h20 w160, ГУМВД-Н
Gui, 1:Add, Text, x838 yp+20 h20 w160, ЦГБ-П
Gui, 1:Add, Text, x838 yp+20 h20 w160, ОКБ-М
Gui, 1:Add, Text, x838 yp+20 h20 w160, ЦГБ-Н
Gui, 1:Add, Text, x838 yp+20 h20 w160, Запрос от ОСН
Gui, 1:Font, S10 C79C0FF Bold, Consolas
Gui, 1:Add, Text, x838 yp+20 h20 w160 g47, * Проверка розыск
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x838 yp+20 h20 w160, Запрос на медкарту
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x1002 y64 h20 w115, /код0
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /код1
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /пр1
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /мвд
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /угибдд
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /ржд
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /мз
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /мо
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /угибддп
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /угибддм
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /угибддн
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /гумвдп
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /гумвдм
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /гумвдн
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /цгбп
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /окбм
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /цгбн
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /зосн
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /прозыск
Gui, 1:Add, Text, x1002 yp+20 h20 w115, /пмедкарта

; ======================= ВКЛАДКА 3: ЗАДЕРЖАНИЕ =======================
Gui, 1:Tab, 3
Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x214 y44 w302 h330, [ Задержание — Основное ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x222 y64 h20 w165, Приветствие гражд
Gui, 1:Add, Text, x222 yp+20 h20 w165, Просить документы
Gui, 1:Add, Text, x222 yp+20 h20 w165, Взять документы
Gui, 1:Add, Text, x222 yp+20 h20 w165, Вернуть документы
Gui, 1:Add, Text, x222 yp+20 h20 w165, Протокол задержания
Gui, 1:Add, Text, x222 yp+20 h20 w165, Передача конвоиру
Gui, 1:Add, Text, x222 yp+20 h20 w165, Выд.розыск
Gui, 1:Add, Text, x222 yp+20 h20 w165, Fines (штрафы)
Gui, 1:Add, Text, x222 yp+20 h20 w165, Wanted (розыск)
Gui, 1:Add, Text, x222 yp+20 h20 w165, КПК достать
Gui, 1:Add, Text, x222 yp+20 h20 w165, КПК (ВУ)
Gui, 1:Add, Text, x222 yp+20 h20 w165, КПК убрать
Gui, 1:Add, Text, x222 yp+20 h20 w165, КПК (фоторобот)
Gui, 1:Add, Text, x222 yp+20 h20 w165, Посадить в авто
Gui, 1:Add, Text, x222 yp+20 h20 w165, Вытащ из патрульки
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x392 y64 h20 w115 vDisp3_HK_Greeting gQuickClickKey, % GetKeyDisp("HK_Greeting")
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp3_HK_AskDocs gQuickClickKey, % GetKeyDisp("HK_AskDocs")
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp3_HK_TakeDocs gQuickClickKey, % GetKeyDisp("HK_TakeDocs")
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp3_HK_ReturnDocs gQuickClickKey, % GetKeyDisp("HK_ReturnDocs")
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp_HK_DetainProt gQuickClickKey, % GetKeyDisp("HK_DetainProt")
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp3_HK_Arrest gQuickClickKey, % GetKeyDisp("HK_Arrest")
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp3_HK_SuFast gQuickClickKey, % GetKeyDisp("HK_SuFast")
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp3_HK_Fines gQuickClickKey, % GetKeyDisp("HK_Fines")
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp3_HK_Wanted gQuickClickKey, % GetKeyDisp("HK_Wanted")
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp3_HK_KpkOpen gQuickClickKey, % GetKeyDisp("HK_KpkOpen")
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp3_HK_KpkVu gQuickClickKey, % GetKeyDisp("HK_KpkVu")
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp3_HK_KpkClose gQuickClickKey, % GetKeyDisp("HK_KpkClose")
Gui, 1:Add, Text, x392 yp+20 h20 w115, /кпкфото
Gui, 1:Add, Text, x392 yp+20 h20 w115 vDisp3_HK_Putpl gQuickClickKey, % GetKeyDisp("HK_Putpl")
Gui, 1:Add, Text, x392 yp+20 h20 w115, /вытащить

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x214 y381 w302 h110, [ Аксессуары задержанного ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x222 y401 h20 w165, Снять маску
Gui, 1:Add, Text, x222 yp+20 h20 w165, Снять голов. убор
Gui, 1:Add, Text, x222 yp+20 h20 w165, Снять очки
Gui, 1:Add, Text, x222 yp+20 h20 w165, Снять шлем
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x392 y401 h20 w115, /маска
Gui, 1:Add, Text, x392 yp+20 h20 w115, /убор
Gui, 1:Add, Text, x392 yp+20 h20 w115, /очки
Gui, 1:Add, Text, x392 yp+20 h20 w115, /шлем

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x522 y44 w302 h130, [ Оформление задержанного ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x530 y64 h20 w165, Открыть наручники
Gui, 1:Add, Text, x530 yp+20 h20 w165, Закрыть наручники
Gui, 1:Add, Text, x530 yp+20 h20 w165, Метка о несогласии
Gui, 1:Add, Text, x530 yp+20 h20 w165, Вырвать копию
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x697 y64 h20 w115 vDisp3_HK_CuffsOpen gQuickClickKey, % GetKeyDisp("HK_CuffsOpen")
Gui, 1:Add, Text, x697 yp+20 h20 w115 vDisp3_HK_CuffsClose gQuickClickKey, % GetKeyDisp("HK_CuffsClose")
Gui, 1:Add, Text, x697 yp+20 h20 w115, /метка1
Gui, 1:Add, Text, x697 yp+20 h20 w115, /зкопия

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x522 y182 w302 h170, [ Статьи УК РП ]
Gui, 1:Font, S9 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, Text, x532 y204 w280 h36, Чтобы статья автоматически появилась в чате, откройте чат [T] и напишите /укрп + номер статьи:
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x532 y244 w280 h20, Например: /укрп5.8 (или 581, 582, 610)
Gui, 1:Font, S9 C58A6FF Bold, Segoe UI
Gui, 1:Add, Text, x532 y276 w280 h40 gOpenCalc, 👉 Нажмите здесь или Alt+F1 для поиска статей УК РП и КоАП по ключевым словам!

; ======================= ВКЛАДКА 4: СС И ЛЕКЦИИ =======================
Gui, 1:Tab, 4
Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x214 y44 w302 h495, [ Лекции (1–23) ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x222 y64 h20 w180, 1. Рация
Gui, 1:Add, Text, x222 yp+20 h20 w180, 2. Субординация
Gui, 1:Add, Text, x222 yp+20 h20 w180, 3. Патрулирование
Gui, 1:Add, Text, x222 yp+20 h20 w180, 4. Сирена и маячок
Gui, 1:Add, Text, x222 yp+20 h20 w180, 5. Построение
Gui, 1:Add, Text, x222 yp+20 h20 w180, 6. Тен-коды
Gui, 1:Add, Text, x222 yp+20 h20 w180, 7. Погоня
Gui, 1:Add, Text, x222 yp+20 h20 w180, 8. Протокол
Gui, 1:Add, Text, x222 yp+20 h20 w180, 9. Общение
Gui, 1:Add, Text, x222 yp+20 h20 w180, 10. Табельное оружие
Gui, 1:Add, Text, x222 yp+20 h20 w180, 11. Обработка вызова
Gui, 1:Add, Text, x222 yp+20 h20 w180, 12. Заступление в патруль
Gui, 1:Add, Text, x222 yp+20 h20 w180, 13. Заступление на пост
Gui, 1:Add, Text, x222 yp+20 h20 w180, 14. Правила после РД
Gui, 1:Add, Text, x222 yp+20 h20 w180, 15. Выписка штрафа
Gui, 1:Add, Text, x222 yp+20 h20 w180, 16. Конвоирование
Gui, 1:Add, Text, x222 yp+20 h20 w180, 17. Обыск
Gui, 1:Add, Text, x222 yp+20 h20 w180, 18. Вытаскивание из ТС
Gui, 1:Add, Text, x222 yp+20 h20 w180, 19. Оружие/Средства
Gui, 1:Add, Text, x222 yp+20 h20 w180, 20. Терроризм угроза
Gui, 1:Add, Text, x222 yp+20 h20 w180, 21. Если вы заложник
Gui, 1:Add, Text, x222 yp+20 h20 w180, 22. Оформление ДТП
Gui, 1:Add, Text, x222 yp+20 h20 w180, 23. Основания
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x407 y64 h20 w100, /лекция1
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция2
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция3
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция4
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция5
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция6
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция7
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция8
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция9
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция10
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция11
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция12
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция13
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция14
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция15
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция16
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция17
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция18
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция19
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция20
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция21
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция22
Gui, 1:Add, Text, x407 yp+20 h20 w100, /лекция23

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x522 y44 w302 h150, [ Проверка документов (РП) ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x530 y64 h20 w165, Паспорт
Gui, 1:Add, Text, x530 yp+20 h20 w165, Трудовая книга
Gui, 1:Add, Text, x530 yp+20 h20 w165, Диплом
Gui, 1:Add, Text, x530 yp+20 h20 w165, Водительское удост.
Gui, 1:Add, Text, x530 yp+20 h20 w165, Мед. карта
Gui, 1:Add, Text, x530 yp+20 h20 w165, Военный билет
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x697 y64 h20 w115, /пасс1
Gui, 1:Add, Text, x697 yp+20 h20 w115, /труд1
Gui, 1:Add, Text, x697 yp+20 h20 w115, /диплом1
Gui, 1:Add, Text, x697 yp+20 h20 w115, /ву1
Gui, 1:Add, Text, x697 yp+20 h20 w115, /карта1
Gui, 1:Add, Text, x697 yp+20 h20 w115, /вб1

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x522 y200 w302 h110, [ Собеседование ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x530 y220 h20 w165, Помощь на собесе
Gui, 1:Font, S10 C79C0FF Bold, Consolas
Gui, 1:Add, Text, x530 yp+20 h20 w165 g39, * I этап (инфо):
Gui, 1:Add, Text, x530 yp+20 h20 w165 g40, * II этап (инфо):
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x530 yp+20 h20 w165, Отказано:
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x697 y220 h20 w115, /помощьсобес
Gui, 1:Add, Text, x697 yp+20 h20 w115, /собес(1-8)
Gui, 1:Add, Text, x697 yp+20 h20 w115, /собес(9-18)
Gui, 1:Add, Text, x697 yp+20 h20 w115, /отказ

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x522 y316 w302 h70, [ Папка ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x530 y336 h20 w165, Взять папку
Gui, 1:Add, Text, x530 yp+20 h20 w165, Вернуть папку
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x697 y336 h20 w115, /папка1
Gui, 1:Add, Text, x697 yp+20 h20 w115, /папка2

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x830 y44 w298 h150, [ Старший Состав ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x838 y64 h20 w155, Выдать форму
Gui, 1:Add, Text, x838 yp+20 h20 w155, Выдать погоны
Gui, 1:Add, Text, x838 yp+20 h20 w155, Принятие (КПК)
Gui, 1:Add, Text, x838 yp+20 h20 w155, Повышение (КПК)
Gui, 1:Add, Text, x838 yp+20 h20 w155, Понижение (КПК)
Gui, 1:Add, Text, x838 yp+20 h20 w155, Увольнение (КПК)
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x997 y64 h20 w125, /выдформу
Gui, 1:Add, Text, x997 yp+20 h20 w125, /выдпогоны
Gui, 1:Add, Text, x997 yp+20 h20 w125, /кпкпринятие
Gui, 1:Add, Text, x997 yp+20 h20 w125, /кпкповышение
Gui, 1:Add, Text, x997 yp+20 h20 w125, /кпкпонижение
Gui, 1:Add, Text, x997 yp+20 h20 w125, /кпкувал

; ======================= ВКЛАДКА 5: ПМП =======================
Gui, 1:Tab, 5
Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x214 y44 w350 h335, [ Первая Медицинская Помощь ]
Gui, 1:Font, S10 CE6EDF3 Bold, Consolas
Gui, 1:Add, Text, x222 y64 h20 w195, Достать аптечку
Gui, 1:Add, Text, x222 yp+20 h20 w195, Осмотр пострадавшего
Gui, 1:Add, Text, x222 yp+20 h20 w195, Проверка пульса
Gui, 1:Add, Text, x222 yp+20 h20 w195, Открыть аптечку
Gui, 1:Add, Text, x222 yp+20 h20 w195, Достать нашатырь
Gui, 1:Add, Text, x222 yp+20 h20 w195, Убрать аптечку
Gui, 1:Add, Text, x222 yp+20 h20 w195, Непрямой массаж сердца
Gui, 1:Add, Text, x222 yp+20 h20 w195, Проверка на травмы
Gui, 1:Add, Text, x222 yp+20 h20 w195, Пулевое ранение
Gui, 1:Add, Text, x222 yp+20 h20 w195, Закрытый перелом
Gui, 1:Add, Text, x222 yp+20 h20 w195, Открытый перелом
Gui, 1:Add, Text, x222 yp+20 h20 w195, Ушиб
Gui, 1:Add, Text, x222 yp+20 h20 w195, Кровотечение
Gui, 1:Add, Text, x222 yp+20 h20 w195, Нет пульса (реанимация)
Gui, 1:Add, Text, x222 yp+20 h20 w195, Ожоги
Gui, 1:Font, S10 CFFB84D Bold, Consolas
Gui, 1:Add, Text, x427 y64 h20 w125, /пмп1
Gui, 1:Add, Text, x427 yp+20 h20 w125, /пмп2
Gui, 1:Add, Text, x427 yp+20 h20 w125, /пмп3
Gui, 1:Add, Text, x427 yp+20 h20 w125, /пмп4
Gui, 1:Add, Text, x427 yp+20 h20 w125, /пмп5
Gui, 1:Add, Text, x427 yp+20 h20 w125, /пмп6
Gui, 1:Add, Text, x427 yp+20 h20 w125, /массаж
Gui, 1:Add, Text, x427 yp+20 h20 w125, /оранения
Gui, 1:Add, Text, x427 yp+20 h20 w125, /пулевое
Gui, 1:Add, Text, x427 yp+20 h20 w125, /переломз
Gui, 1:Add, Text, x427 yp+20 h20 w125, /переломо
Gui, 1:Add, Text, x427 yp+20 h20 w125, /ушиб
Gui, 1:Add, Text, x427 yp+20 h20 w125, /кровь
Gui, 1:Add, Text, x427 yp+20 h20 w125, /пульс-
Gui, 1:Add, Text, x427 yp+20 h20 w125, /ожог

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x580 y44 w546 h335, [ Памятка оказания ПМП сотрудником УГИБДД ]
Gui, 1:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Text, x596 y70 w514 h22, ⚠️ Первоочередные действия при вызове / ранении / ДТП:
Gui, 1:Font, S9 CFFB84D Bold, Segoe UI
Gui, 1:Add, Text, x596 y98 w514 h20, 1. Оценить обстановку и безопасность вокруг (/me, /do).
Gui, 1:Add, Text, x596 yp+22 w514 h20, 2. Проверить сознание и пульс на сонной артерии (/пульс- или /пмп3).
Gui, 1:Add, Text, x596 yp+22 w514 h20, 3. При кровотечении — немедленно наложить жгут/повязку (/кровь).
Gui, 1:Add, Text, x596 yp+22 w514 h20, 4. При переломе — зафиксировать шиной конечность (/переломз, /переломо).
Gui, 1:Add, Text, x596 yp+22 w514 h20, 5. При отсутствии пульса — СЛР (непрямой массаж сердца 30:2) (/массаж).
Gui, 1:Font, S9 C58A6FF Bold, Segoe UI
Gui, 1:Add, Text, x596 y224 w514 h24 gToggleHud, 👉 Подсказка: отслеживать время докладов можно через игровой HUD (Alt+H)

; ======================= ВКЛАДКА 6: 🔍 ПОИСК БИНДОВ =======================
Gui, 1:Tab, 6
Gui, 1:Font, S10 C58A6FF Bold, Segoe UI
Gui, 1:Add, Text, x218 y48 w70 h24 +0x200, 🔎 Поиск:
Gui, 1:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, Edit, x290 y48 w430 h26 vBindSearchQuery gFilterBindsList
Gui, 1:Font, S10 C58A6FF Bold, Segoe UI
Gui, 1:Add, Text, x732 y48 w85 h24 +0x200, Категория:
Gui, 1:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, DropDownList, x820 y48 w300 r8 vBindCatFilter gFilterBindsList Choose1, Все категории|Основное|Доклады и Рация|Задержание и Розыск|СС, Лекции и Собес|ПМП|Статьи КоАП/УКРП/ПДД/ФЗоП
Gui, 1:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, ListView, x218 y82 w904 h458 +Grid -Multi Background1B2234 cE6EDF3 vBindsLV gBindsLVAction, Команда / Хоткей|Категория|Описание и назначение
Gui, 1:Font, S9 C8B949E Norm, Segoe UI
Gui, 1:Add, Text, x218 y546 w904 h22 vBindsSearchStatus, 💡 Введите любое слово (например: «протокол», «тонировка», «пост», «кпк», «аптечка», «5.2») — двойной клик копирует команду!

; ======================= ВКЛАДКА 7: ⌨️ КЛАВИШИ БИНДОВ (РЕДАКТОР ХОТКЕЕВ) =======================
Gui, 1:Tab, 7
Gui, 1:Font, S10 C58A6FF Bold, Segoe UI
Gui, 1:Add, Text, x218 y48 w110 h24 +0x200, 🔎 Фильтр:
Gui, 1:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, Edit, x332 y48 w165 h26 vHkFilterQuery gFilterHotkeysLV
Gui, 1:Font, S9 CFFB84D Bold, Segoe UI
Gui, 1:Add, CheckBox, x507 y49 w170 h24 vOnlyInGameChk gToggleOnlyInGameMode Checked%OnlyInGameMode%, 🛡️ Только в игре
Gui, 1:Add, CheckBox, x682 y49 w185 h24 vAutoScreenChk gToggleAutoScreenMode Checked%AutoScreenMode%, 📸 Автоскрин (/timestamp)
Gui, 1:Font, S9 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, DropDownList, x872 y48 w250 r4 vSendEngineDDL gChangeSendEngine, Авто (SendInput: Мгновенный)|SendInput (Мгновенный)|SendEvent (DirectX)|SendPlay (Классика)

Gui, 1:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, ListView, x218 y80 w904 h335 +Grid -Multi Background1B2234 cE6EDF3 vHotkeysLV gHotkeysLVSelect AltSubmit, Код|Действие / Отыгровка|Текущая клавиша|По умолчанию|Категория

Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x218 y420 w904 h152, [ ⌨️ Назначение новой клавиши для выбранного бинда ]
Gui, 1:Font, S10 CFFB84D Bold, Segoe UI
Gui, 1:Add, Text, x230 y442 w880 h22 vSelectedHkTitle, 👉 Выберите любую строку в таблице выше (или кликните по клавише на вкладке «Основное»)...

Gui, 1:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Text, x230 y472 w190 h24 +0x200, Способ 1 (нажать клавишу):
Gui, 1:Font, S10 C000000 Norm, Segoe UI
Gui, 1:Add, Hotkey, x424 y472 w195 h26 vHkBoxCtrl

Gui, 1:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Text, x637 y472 w165 h24 +0x200, Способ 2 (спецклавиша):
Gui, 1:Font, S9 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, CheckBox, x804 y474 w48 h22 vHkModCtrl, Ctrl
Gui, 1:Add, CheckBox, x856 y474 w45 h22 vHkModAlt, Alt
Gui, 1:Add, CheckBox, x904 y474 w55 h22 vHkModShift, Shift
Gui, 1:Add, DropDownList, x964 y471 w145 r12 vHkSpecialDDL Choose1, (Не выбрано)|PrintScreen|ScrollLock|Delete|Insert|Home|End|Backspace|sc29 (Ё/~)|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|Space|Tab|=|-|1|2|3|4|5|6|7|8|9|0

Gui, 1:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Button, x230 y510 w240 h34 gApplyNewHotkeyBtn, ✅ Применить новую клавишу
Gui, 1:Add, Button, x482 y510 w225 h34 gResetSingleHotkeyBtn, 🔄 Сбросить выбранную
Gui, 1:Add, Button, x719 y510 w235 h34 gResetAllHotkeysBtn, ⚠️ Сбросить ВСЕ по умолчанию
Gui, 1:Font, S9 C8B949E Norm, Segoe UI
Gui, 1:Add, Text, x230 y549 w880 h18, 💡 Кнопка экстренной отмены длинной отыгровки/лекции по умолчанию: [F12] (можно изменить в списке выше).

; ======================= ВКЛАДКА 8: 📊 ЖУРНАЛ НОРМЫ И ОНЛАЙН-ПРОТОКОЛ =======================
Gui, 1:Tab, 8
Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x218 y44 w904 h74, [ 📊 Статистика смены и нормы сотрудника (ст. 20 ФЗоП) ]
Gui, 1:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Text, x230 y68 w200 h22 vJournalStatFines, Штрафы: 0 шт. (0 руб.)
Gui, 1:Add, Text, x442 y68 w160 h22 vJournalStatArrests, Аресты (КПЗ): 0 чел.
Gui, 1:Add, Text, x612 y68 w170 h22 vJournalStatLic, Лишения ВУ: 0 шт.
Gui, 1:Add, Text, x792 y68 w150 h22 vJournalStatReports, Доклады: 0 шт.
Gui, 1:Font, S9 C8B949E Norm, Segoe UI
Gui, 1:Add, Text, x230 y92 w880 h18, 💡 Все штрафы, аресты, лишения прав и доклады фиксируются автоматически с /timestamp.

Gui, 1:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, ListView, x218 y124 w904 h398 +Grid -Multi Background1B2234 cE6EDF3 vJournalLV, Время|Тип фиксации|Нарушитель / Цель|Детали / Статьи / Срок|Сумма (руб)
Gui, 1:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Button, x218 y530 w240 h38 gCopyJournalReportBtn, 📋 Скопировать отчёт для форума
Gui, 1:Add, Button, x468 y530 w200 h38 gExportJournalCsvBtn, 📁 Экспорт журнала (CSV)
Gui, 1:Add, Button, x678 y530 w180 h38 gAddManualJournalBtn, ➕ Добавить запись
Gui, 1:Add, Button, x868 y530 w150 h38 gClearJournalDataBtn, 🗑️ Очистить смену
Gui, 1:Add, Button, x1028 y530 w94 h38 gRefreshJournalBtn, 🔄 Обновить

; ======================= ВКЛАДКА 9: ➕ СВОИ БИНДЫ (КОНСТРУКТОР БИНДОВ) =======================
Gui, 1:Tab, 9
Gui, 1:Font, S10 C58A6FF Bold, Consolas
Gui, 1:Add, GroupBox, x218 y44 w904 h74, [ ➕ Конструктор персональных отыгровок и команд ]
Gui, 1:Font, S9 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, Text, x230 y68 w880 h42, Создавайте собственные уникальные команды и отыгровки прямо в GUI!`nПеременные: {Fio} — ФИО, {Rank} — Звание, {Znak} — Жетон, {Otdel} — Отдел, {Id} — ID нарушителя.

Gui, 1:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 1:Add, ListView, x218 y124 w904 h398 +Grid -Multi Background1B2234 cE6EDF3 vCustomBindsLV gCustomBindsLVAction, #|Название бинда|Триггер (Команда / Хоткей)|Строк|Задержка|Статус
Gui, 1:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 1:Add, Button, x218 y530 w190 h38 gOpenAddCustomBindDialog, ➕ Создать новый бинд
Gui, 1:Add, Button, x418 y530 w170 h38 gEditCustomBindBtn, ✏️ Редактировать
Gui, 1:Add, Button, x598 y530 w180 h38 gTestCustomBindBtn, ▶️ Проверить бинд (Тест)
Gui, 1:Add, Button, x788 y530 w150 h38 gToggleCustomBindBtn, ⚡ Вкл / Выкл
Gui, 1:Add, Button, x948 y530 w174 h38 gDeleteCustomBindBtn, 🗑️ Удалить бинд


Gui, 1:Tab

; =================================================================================================
; ПОДВАЛ (ФУТЕР ОСНОВНОЙ ОБЛАСТИ)
; =================================================================================================
Gui, 1:Tab
Gui, 1:Font, S9 C8B949E Norm, Segoe UI
Gui, 1:Add, Text, x218 y652 w908 h20 vBottomFooterKeys, % "Пауза: [" . GetKeyDisp("HK_Pause") . "]  |  Отмена лекции: [F12]  |  Клик по клавише в таблице = изменить"

PopulateBindsListView()
PopulateHotkeysListView()
LoadJournalFromIni()
PopulateJournalLV()
LoadCustomBindsFromIni()
PopulateCustomBindsLV()
RegisterAllCustomBinds()

if (SendMethodConfig = "SendPlay")
    GuiControl, 1:Choose, SendEngineDDL, 2
else if (SendMethodConfig = "SendEvent")
    GuiControl, 1:Choose, SendEngineDDL, 3
else if (SendMethodConfig = "SendInput")
    GuiControl, 1:Choose, SendEngineDDL, 4
else
    GuiControl, 1:Choose, SendEngineDDL, 1

Gui, 1:Font, S8 C58A6FF Bold, Segoe UI
Gui, 1:Add, Button, x605 y6 w122 h24 gSwitchToFluentUI, ✨ Fluent Glass UI
Gui, 1:Show, Hide h678 w1145, % TextArray[Var]
InitAndShowFluentGlassUI()
Return

; =================================================================================================
; НАВИГАЦИЯ БОКОВОГО МЕНЮ (САЙДБАРА)
; =================================================================================================
SelectTab1:
SetSidebarActive(1, "🚔 ПАТРУЛЬ И ОПЕРАТИВНЫЕ ДЕЙСТВИЯ")
Return

SelectTab2:
SetSidebarActive(2, "📻 СЛУЖЕБНЫЕ ДОКЛАДЫ И РАЦИЯ")
Return

SelectTab3:
SetSidebarActive(3, "⛓️ ЗАДЕРЖАНИЕ И ДОСТАВЛЕНИЕ В КПЗ")
Return

SelectTab4:
SetSidebarActive(4, "📚 ЛЕКЦИИ, УСТАВ И СОБЕСЕДОВАНИЯ")
Return

SelectTab5:
SetSidebarActive(5, "🩹 ПЕРВАЯ МЕДИЦИНСКАЯ ПОМОЩЬ (ПМП)")
Return

SelectTab6:
SetSidebarActive(6, "🔍 УМНЫЙ ПОИСК БИНДОВ И СТАТЕЙ")
Return

SelectTab7:
SetSidebarActive(7, "⌨️ НАСТРОЙКА КЛАВИШ И ДВИЖОК ВВОДА")
Return

SelectTab8:
SetSidebarActive(8, "📊 ЖУРНАЛ СМЕНЫ И НОРМА ОФИЦЕРА")
PopulateJournalLV()
Return

SelectTab9:
SetSidebarActive(9, "➕ КОНСТРУКТОР ПЕРСОНАЛЬНЫХ БИНДОВ")
PopulateCustomBindsLV()
Return

SetSidebarActive(TabNum, TitleText) {
    global CurrentActiveNavTab
    CurrentActiveNavTab := TabNum
    GuiControl, 1:, MainSectionTitle, %TitleText%
    GuiControl, 1:Choose, MainTabControl, %TabNum%
}

UpdateSidebarOfficerCard() {
    global Rank, Fio1, Otdel, Znak, Teg, Prop2
    GuiControl, 1:, SidebarOfficerFio, % Rank . " " . Fio1
    GuiControl, 1:, SidebarOfficerDetails, % "Отдел: " . Otdel . " | Знак: " . Znak
    GuiControl, 1:, SidebarOfficerCallsign, % "Позывной: " . Teg . "-" . Prop2
}

GuiClose:
Gui, 1:Hide
HIDDEN_NOW := 1
Menu, Tray, Rename, Свернуть, Развернуть
Return

SwitchToHotkeysTab:
if (HIDDEN_NOW) {
    Menu, Tray, Rename, Развернуть, Свернуть
    Gui, 1:Show
    HIDDEN_NOW := 0
}
SetSidebarActive(7, "⌨️ НАСТРОЙКА КЛАВИШ И ДВИЖОК ВВОДА")
Return

; =================================================================================================
; НАВИГАЦИЯ МЕЖДУ НОВЫМИ ВКЛАДКАМИ GUI 1
; =================================================================================================
SwitchToJournalTab:
if (HIDDEN_NOW) {
    Menu, Tray, Rename, Развернуть, Свернуть
    Gui, 1:Show
    HIDDEN_NOW := 0
}
SetSidebarActive(8, "📊 ЖУРНАЛ СМЕНЫ И НОРМА ОФИЦЕРА")
PopulateJournalLV()
Return

SwitchToCustomBindsTab:
if (HIDDEN_NOW) {
    Menu, Tray, Rename, Развернуть, Свернуть
    Gui, 1:Show
    HIDDEN_NOW := 0
}
SetSidebarActive(9, "➕ КОНСТРУКТОР ПЕРСОНАЛЬНЫХ БИНДОВ")
PopulateCustomBindsLV()
Return

; =================================================================================================
; ДИСПЕТЧЕР ПОГОНИ И МЕГАФОНОВ (PURSUIT WATCHDOG & SMART MEGAPHONE)
; =================================================================================================
ExecuteSmartMegaphoneStep:
ExecuteSmartMegaphoneStep()
Return

StopChaseModeLabel:
StopChaseMode()
Return

ExecuteSmartMegaphoneStep() {
    global ChaseActive, ChaseStage, ChaseCooldownSec, ChaseTotalSec, ok1, ok2, OnlyInGameMode
    if (OnlyInGameMode && !WinActive("ahk_exe gta_sa.exe") && !WinActive("ahk_class Grand Theft Auto San Andreas") && !WinActive("ahk_exe Multi Theft Auto.exe"))
        Return

    if (!ChaseActive || ChaseStage = 0) {
        StartChaseTimer(1)
        SetCapsOff()
        SetLocaleRu()
        SmartSleep(100)
        Send, {F8} do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
        SmartSleep(600)
        Send, {F8} me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
        SmartSleep(600)
        Send, {F8}{Space}{Backspace} m {#}7ae70dВодитель, принимаем крайнее правое положение и останавливаемся{!}{Enter}{F8}
        SmartSleep(600)
        Send, {F8} me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
        SoundBeep, 800, 150
        TrayTip, 🚔 Мегафон 1/3 отправлен, До 2-го мегафона: 15 секунд по ст. 15 ФЗоП., 3, 1
        LogJournalAction("Погоня", "Мегафон №1", "Требование об остановке ТС (1/3)", 0)
        TriggerSmartScreenshot("Мегафон 1/3")
        Return
    }

    if (ChaseStage = 1) {
        if (ChaseCooldownSec > 0) {
            SoundBeep, 450, 120
            TrayTip, ⏳ КД мегафона (ст. 15 ФЗоП), Подождите ещё %ChaseCooldownSec% сек. перед 2-м мегафоном!, 2, 2
            Return
        }
        StartChaseTimer(2)
        SetCapsOff()
        SetLocaleRu()
        SmartSleep(100)
        Send, {F8} do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
        SmartSleep(600)
        Send, {F8} me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
        SmartSleep(600)
        Send, {F8}{Space}{Backspace} m {#}e7950dПовторяю, водитель, примите вправо и остановитесь{!}{Enter}{F8}
        SmartSleep(600)
        Send, {F8} me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
        SoundBeep, 950, 150
        TrayTip, 🚔 Мегафон 2/3 отправлен, До финального предупреждения: 15 сек., 3, 1
        LogJournalAction("Погоня", "Мегафон №2", "Повторное требование об остановке (2/3)", 0)
        TriggerSmartScreenshot("Мегафон 2/3")
        Return
    }

    if (ChaseStage = 2) {
        if (ChaseCooldownSec > 0) {
            SoundBeep, 450, 120
            TrayTip, ⏳ КД мегафона (ст. 15 ФЗоП), Подождите ещё %ChaseCooldownSec% сек. перед 3-м мегафоном!, 2, 2
            Return
        }
        StartChaseTimer(3)
        SetCapsOff()
        SetLocaleRu()
        SmartSleep(100)
        Send, {F8} do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
        SmartSleep(600)
        Send, {F8} me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
        SmartSleep(600)
        Send, {F8}{Space}{Backspace} m {#}e74c3cОстанавливайтесь{!} В случае отказа откроем огонь{!}{Enter}{F8}
        SmartSleep(600)
        Send, {F8} me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
        SoundBeep, 1100, 200
        TrayTip, ⚠️ Мегафон 3/3 отправлен!, ТРЕБОВАНИЯ ВЫПОЛНЕНЫ! ОГОНЬ ПО КОЛЕСАМ РАЗРЕШЁН (ст. 15 ФЗоП)!, 4, 2
        LogJournalAction("Погоня", "Мегафон №3", "Финальное требование (3/3) - Огонь санкционирован", 0)
        TriggerSmartScreenshot("Мегафон 3/3 (Огонь)")
        Return
    }

    if (ChaseStage >= 3) {
        SoundBeep, 1200, 100
        Sleep, 50
        SoundBeep, 1200, 150
        TrayTip, ⚠️ ОГОНЬ ПО КОЛЕСАМ РАЗРЕШЁН (ст. 15 ФЗоП), Все 3 мегафона выданы! Применяйте таран и огонь по колесам!, 3, 2
    }
}

StopChaseMode() {
    global ChaseActive, ChaseStage, ChaseCooldownSec, ChaseTotalSec
    if (!ChaseActive && ChaseStage = 0) {
        TrayTip, 🚔 Погоня, Режим погони не активен., 2, 1
        Return
    }
    ChaseActive := 0
    ChaseStage := 0
    ChaseCooldownSec := 0
    ChaseTotalSec := 0
    SoundBeep, 650, 150
    TrayTip, 🏁 Погоня сброшена, Таймеры погони и мегафонов отключены., 2, 1
    Gosub, UpdateHudTick
}

; =================================================================================================
; АВТОСКРИНШОТЫ С /TIMESTAMP (AUTO-SCREEN)
; =================================================================================================
ToggleAutoScreenMode:
Gui, 1:Submit, NoHide
AutoScreenMode := AutoScreenChk ? 1 : 0
for idx, targetIni in [A_Temp . "\gibdd.egl", A_ScriptDir . "\gibdd_profile.ini"] {
    IniWrite, %AutoScreenMode%, %targetIni%, User, AutoScreenMode
}
TrayTip, 📸 Автоскриншоты (/timestamp + F12), % (AutoScreenMode ? "ВКЛЮЧЕНЫ! Скриншот делается при каждом штрафе, аресте, лишении и докладе." : "ВЫКЛЮЧЕНЫ."), 2, 1
Return

TriggerSmartScreenshot(ReasonStr) {
    global AutoScreenMode, HK_StopBind, OnlyInGameMode
    if (!AutoScreenMode)
        Return
    if (OnlyInGameMode && !WinActive("ahk_exe gta_sa.exe") && !WinActive("ahk_class Grand Theft Auto San Andreas") && !WinActive("ahk_exe Multi Theft Auto.exe"))
        Return

    SetCapsOff()
    Send, {F8}^A{Delete}timestamp{Enter}{F8}
    Sleep, 150

    stopKey := (HK_StopBind != "") ? HK_StopBind : "F12"
    Hotkey, %stopKey%, Off, UseErrorLevel
    SendInput, {F12}
    Sleep, 100
    Hotkey, %stopKey%, On, UseErrorLevel

    TrayTip, 📸 Автоскриншот сделан!, % "Фиксация с /timestamp: " . ReasonStr, 2, 1
}

; =================================================================================================
; АВТО-ЖУРНАЛ НОРМЫ И ОНЛАЙН-ПРОТОКОЛОВ (ст. 20 ФЗоП)
; =================================================================================================
global JournalEntries := []

LogJournalAction(ActionType, TargetPlayer, ActionDetails, Amount := 0) {
    global JournalEntries
    FormatTime, nowStr,, dd.MM.yyyy HH:mm:ss
    entry := {Time: nowStr, Type: ActionType, Target: TargetPlayer, Details: ActionDetails, Amount: Amount}
    JournalEntries.Push(entry)

    jIni := A_Temp . "\gibdd_journal.ini"
    bIni := A_ScriptDir . "\gibdd_journal.ini"
    idx := JournalEntries.MaxIndex()
    line := nowStr . "|" . ActionType . "|" . TargetPlayer . "|" . ActionDetails . "|" . Amount
    for k, iniPath in [jIni, bIni] {
        IniWrite, %idx%, %iniPath%, Meta, Count
        IniWrite, %line%, %iniPath%, Entries, %idx%
    }

    Gui, 1:Default
    Gui, 1:ListView, JournalLV
    LV_Insert(1, "", nowStr, ActionType, TargetPlayer, ActionDetails, (Amount > 0 ? Amount : "—"))
    UpdateJournalStats()
}

UpdateJournalStats() {
    global JournalEntries
    finesCount := 0
    finesSum := 0
    arrestCount := 0
    licCount := 0
    reportCount := 0

    for idx, item in JournalEntries {
        if (InStr(item.Type, "Штраф")) {
            finesCount++
            finesSum += item.Amount
        } else if (InStr(item.Type, "Арест")) {
            arrestCount++
        } else if (InStr(item.Type, "Лишение")) {
            licCount++
        } else if (InStr(item.Type, "Доклад") || InStr(item.Type, "Рация") || InStr(item.Type, "Пост") || InStr(item.Type, "Патруль")) {
            reportCount++
        }
    }

    finesSumFmt := Format("{:d}", finesSum)
    GuiControl, 1:, JournalStatFines, % "Штрафы: " . finesCount . " шт. (" . finesSumFmt . " руб.)"
    GuiControl, 1:, JournalStatArrests, % "Аресты (КПЗ): " . arrestCount . " чел."
    GuiControl, 1:, JournalStatLic, % "Лишения ВУ: " . licCount . " шт."
    GuiControl, 1:, JournalStatReports, % "Доклады: " . reportCount . " шт."
}

LoadJournalFromIni() {
    global JournalEntries
    JournalEntries := []
    jIni := A_Temp . "\gibdd_journal.ini"
    bIni := A_ScriptDir . "\gibdd_journal.ini"
    activeIni := FileExist(jIni) ? jIni : (FileExist(bIni) ? bIni : "")
    if (activeIni = "")
        Return

    IniRead, cnt, %activeIni%, Meta, Count, 0
    Loop, %cnt% {
        IniRead, line, %activeIni%, Entries, %A_Index%, ERROR
        if (line != "ERROR" && line != "") {
            parts := StrSplit(line, "|")
            if (parts.MaxIndex() >= 4) {
                entry := {Time: parts[1], Type: parts[2], Target: parts[3], Details: parts[4], Amount: parts[5]}
                JournalEntries.Push(entry)
            }
        }
    }
}

PopulateJournalLV() {
    global JournalEntries
    Gui, 1:Default
    Gui, 1:ListView, JournalLV
    LV_Delete()
    GuiControl, 1:-Redraw, JournalLV
    Loop, % JournalEntries.MaxIndex() {
        revIdx := JournalEntries.MaxIndex() - A_Index + 1
        item := JournalEntries[revIdx]
        amtDisp := (item.Amount > 0) ? item.Amount : "—"
        LV_Add("", item.Time, item.Type, item.Target, item.Details, amtDisp)
    }
    LV_ModifyCol(1, 140)
    LV_ModifyCol(2, 130)
    LV_ModifyCol(3, 130)
    LV_ModifyCol(4, 380)
    LV_ModifyCol(5, 100)
    GuiControl, 1:+Redraw, JournalLV
    UpdateJournalStats()
}

CopyJournalReportBtn:
FormatTime, todayStr,, dd.MM.yyyy
finesCount := 0
finesSum := 0
arrestCount := 0
licCount := 0
reportCount := 0
for idx, item in JournalEntries {
    if (InStr(item.Type, "Штраф")) {
        finesCount++
        finesSum += item.Amount
    } else if (InStr(item.Type, "Арест")) {
        arrestCount++
    } else if (InStr(item.Type, "Лишение")) {
        licCount++
    } else if (InStr(item.Type, "Доклад") || InStr(item.Type, "Рация") || InStr(item.Type, "Пост") || InStr(item.Type, "Патруль")) {
        reportCount++
    }
}
finesSumFmt := Format("{:d}", finesSum)

reportText := "[b]ОТЧЁТ О ПРОДЕЛАННОЙ РАБОТЕ В УГИБДД (ст. 20 ФЗоП)[/b]`n"
reportText .= "Сотрудник: [b]" . Rank . " " . Fio1 . "[/b]`n"
reportText .= "Подразделение: [b]" . Gibdd . " (" . Frak . ")[/b] | Отдел: [b]" . Otdel . "[/b]`n"
reportText .= "Нагрудный знак / Позывной: [b]" . Znak . " / " . Teg . "-" . Prop2 . "[/b]`n"
reportText .= "Дата формирования отчёта: [b]" . todayStr . "[/b]`n"
reportText .= "--------------------------------------------------`n"
reportText .= "📊 [b]ИТОГИ ДЕЖУРСТВА / НОРМЫ:[/b]`n"
reportText .= "1. Выписано штрафов по КоАП: [b]" . finesCount . " шт.[/b] на общую сумму [b]" . finesSumFmt . " руб.[/b]`n"
reportText .= "2. Задержано и передано в КПЗ: [b]" . arrestCount . " чел.[/b]`n"
reportText .= "3. Аннулировано водительских удостоверений (ст. 12 ФЗоП): [b]" . licCount . " шт.[/b]`n"
reportText .= "4. Докладов о посте/патруле в рацию: [b]" . reportCount . " шт.[/b]`n"
reportText .= "--------------------------------------------------`n"
reportText .= "📋 [b]ДЕТАЛЬНЫЙ СПИСОК ФИКСАЦИЙ (ИЗ АХК ЖУРНАЛА):[/b]`n"
Loop, % JournalEntries.MaxIndex() {
    item := JournalEntries[A_Index]
    amtStr := (item.Amount > 0) ? (" (" . item.Amount . " руб.)") : ""
    reportText .= A_Index . ". [" . item.Time . "] " . item.Type . " | Цель: " . item.Target . " | " . item.Details . amtStr . "`n"
}
reportText .= "--------------------------------------------------`n"
reportText .= "Все фиксации сохранены с /timestamp. Отчёт сгенерирован автоматически скриптом «АХК УГИБДД»."

Clipboard := reportText
SoundBeep, 900, 150
TrayTip, 📋 Отчёт скопирован!, Готовый текст отчёта с нормой скопирован в буфер обмена для форума!, 3, 1
MsgBox, 64, Готовый отчёт для форума, Текст отчёта успешно сформирован и скопирован в буфер обмена!`nВставьте его на форуме в тему онлайн-протокола (Ctrl+V).
Return

ExportJournalCsvBtn:
FileSelectFile, csvPath, S16, %A_Desktop%\gibdd_journal_%A_YYYY%-%A_MM%-%A_DD%.csv, Сохранить журнал в CSV, Таблица CSV (*.csv)
if (csvPath = "")
    Return
if (!InStr(csvPath, ".csv"))
    csvPath .= ".csv"
csvContent := "Время,Тип фиксации,Нарушитель / Цель,Детали / Статьи,Сумма (руб)`r`n"
for idx, item in JournalEntries {
    csvContent .= """" . item.Time . """,""" . item.Type . """,""" . item.Target . """,""" . item.Details . """,""" . item.Amount . """`r`n"
}
utf8Bom := FileOpen(csvPath, "w", "UTF-8")
if (IsObject(utf8Bom)) {
    utf8Bom.Write(csvContent)
    utf8Bom.Close()
    SoundBeep, 850, 120
    TrayTip, 📁 Экспорт CSV завершён, Журнал сохранён в файл: %csvPath%, 3, 1
}
Return

AddManualJournalBtn:
InputBox, mType, Ручная запись в журнал, Введите тип действия (например: Штраф КоАП / Арест / Лишение / Доклад / Осмотр):,, 400, 150,,,,, Штраф КоАП
if (ErrorLevel || mType = "")
    Return
InputBox, mTarget, Нарушитель / Цель, Введите никнейм или ID нарушителя (например: 142 или Ivan_Ivanov):,, 400, 150,,,,, %LastTargetID%
if (ErrorLevel)
    Return
InputBox, mDetails, Детали фиксации, Описание / статьи (например: ст. 12.5 ч.3 КоАП тонировка):,, 400, 150
if (ErrorLevel)
    Return
InputBox, mAmount, Сумма (если штраф), Введите сумму штрафа цифрами (или 0):,, 400, 150,,,,, 0
if (ErrorLevel)
    mAmount := 0
LogJournalAction(mType, mTarget, mDetails, mAmount + 0)
TrayTip, ✅ Запись добавлена, Запись успешно внесена в журнал нормы!, 2, 1
Return

ClearJournalDataBtn:
MsgBox, 260, Очистка журнала нормы, Вы уверены, что хотите очистить журнал смены?`nВсе текущие записи будут удалены (рекомендуется сначала скопировать отчёт!).
IfMsgBox, Yes
{
    JournalEntries := []
    IniDelete, %A_Temp%\gibdd_journal.ini, Entries
    IniDelete, %A_Temp%\gibdd_journal.ini, Meta
    IniDelete, %A_ScriptDir%\gibdd_journal.ini, Entries
    IniDelete, %A_ScriptDir%\gibdd_journal.ini, Meta
    PopulateJournalLV()
    TrayTip, 🗑️ Журнал очищен, Данные смены успешно сброшены., 2, 1
}
Return

RefreshJournalBtn:
PopulateJournalLV()
TrayTip, 🔄 Журнал обновлён, Записи и статистика актуализированы., 2, 1
Return

; =================================================================================================
; ВСТРОЕННЫЙ КОНСТРУКТОР БИНДОВ (CUSTOM BINDS MODULE)
; =================================================================================================
global CustomBindsDB := []

LoadCustomBindsFromIni() {
    global CustomBindsDB
    CustomBindsDB := []
    iniFile := A_Temp . "\gibdd_custom_binds.ini"
    bIni := A_ScriptDir . "\gibdd_custom_binds.ini"
    activeIni := FileExist(iniFile) ? iniFile : (FileExist(bIni) ? bIni : "")

    if (activeIni = "") {
        exampleBind := {Id: 1, Name: "Предупреждение о светофоре", Trigger: "/светофор", Delay: 1200, Active: 1, Lines: "Водитель, напоминаю: проезд на запрещающий сигнал светофора наказывается по КоАП!|Соблюдайте правила дорожного движения!"}
        CustomBindsDB.Push(exampleBind)
        SaveCustomBindsToIni()
        Return
    }

    IniRead, cnt, %activeIni%, Meta, Count, 0
    Loop, %cnt% {
        bId := A_Index
        IniRead, bName, %activeIni%, Bind_%bId%, Name, ERROR
        if (bName = "ERROR" || bName = "")
            Continue
        IniRead, bTrig, %activeIni%, Bind_%bId%, Trigger, /bind%bId%
        IniRead, bDelay, %activeIni%, Bind_%bId%, Delay, 1200
        IniRead, bAct, %activeIni%, Bind_%bId%, Active, 1
        IniRead, bLines, %activeIni%, Bind_%bId%, Lines, %A_Space%
        CustomBindsDB.Push({Id: bId, Name: bName, Trigger: bTrig, Delay: bDelay, Active: bAct, Lines: bLines})
    }
}

SaveCustomBindsToIni() {
    global CustomBindsDB
    iniFile := A_Temp . "\gibdd_custom_binds.ini"
    bIni := A_ScriptDir . "\gibdd_custom_binds.ini"
    for k, p in [iniFile, bIni] {
        if (FileExist(p))
            FileDelete, %p%
        IniWrite, % CustomBindsDB.MaxIndex(), %p%, Meta, Count
        for idx, b in CustomBindsDB {
            IniWrite, % b.Name, %p%, Bind_%idx%, Name
            IniWrite, % b.Trigger, %p%, Bind_%idx%, Trigger
            IniWrite, % b.Delay, %p%, Bind_%idx%, Delay
            IniWrite, % b.Active, %p%, Bind_%idx%, Active
            IniWrite, % b.Lines, %p%, Bind_%idx%, Lines
        }
    }
}

PopulateCustomBindsLV() {
    global CustomBindsDB
    Gui, 1:Default
    Gui, 1:ListView, CustomBindsLV
    LV_Delete()
    GuiControl, 1:-Redraw, CustomBindsLV
    for idx, b in CustomBindsDB {
        linesList := StrSplit(b.Lines, "|")
        lineCount := linesList.MaxIndex() ? linesList.MaxIndex() : 1
        statusStr := b.Active ? "✅ Активен" : "⏸️ Отключен"
        LV_Add("", idx, b.Name, b.Trigger, lineCount, b.Delay . " мс", statusStr)
    }
    LV_ModifyCol(1, 40)
    LV_ModifyCol(2, 280)
    LV_ModifyCol(3, 200)
    LV_ModifyCol(4, 70)
    LV_ModifyCol(5, 110)
    LV_ModifyCol(6, 150)
    GuiControl, 1:+Redraw, CustomBindsLV
}

RegisterAllCustomBinds() {
    global CustomBindsDB
    for idx, b in CustomBindsDB {
        if (!b.Active)
            Continue
        trig := Trim(b.Trigger)
        if (SubStr(trig, 1, 1) = "/") {
            try {
                Hotstring(":*:" . trig, "ExecuteCustomBindFromHotstring", "On")
            }
        } else if (trig != "") {
            try {
                fn := Func("ExecuteCustomBind").Bind(idx)
                Hotkey, %trig%, %fn%, On
            }
        }
    }
}

ExecuteCustomBindFromHotstring:
matchTrigger := Trim(A_ThisHotkey)
matchTrigger := StrReplace(matchTrigger, ":*:", "")
for idx, b in CustomBindsDB {
    if (b.Active && b.Trigger = matchTrigger) {
        ExecuteCustomBind(idx)
        Break
    }
}
Return

FormatCustomBindLine(rawLine) {
    global Fio1, Rank, Znak, Otdel, Teg, Prop2, LastTargetID
    formatted := rawLine
    formatted := StrReplace(formatted, "{Fio}", Fio1)
    formatted := StrReplace(formatted, "{Rank}", Rank)
    formatted := StrReplace(formatted, "{Znak}", Znak)
    formatted := StrReplace(formatted, "{Otdel}", Otdel)
    formatted := StrReplace(formatted, "{Teg}", Teg)
    formatted := StrReplace(formatted, "{Callsign}", Teg . "-" . Prop2)
    formatted := StrReplace(formatted, "{Id}", (LastTargetID != "" ? LastTargetID : "0"))
    formatted := StrReplace(formatted, "{TargetID}", (LastTargetID != "" ? LastTargetID : "0"))
    return formatted
}

ExecuteCustomBind(BindIdx) {
    global CustomBindsDB, AbortBindFlag, OnlyInGameMode
    if (OnlyInGameMode && !WinActive("ahk_exe gta_sa.exe") && !WinActive("ahk_class Grand Theft Auto San Andreas") && !WinActive("ahk_exe Multi Theft Auto.exe"))
        Return

    b := CustomBindsDB[BindIdx]
    if (!IsObject(b) || !b.Active)
        Return

    AbortBindFlag := 0
    SetCapsOff()
    SetLocaleRu()
    lines := StrSplit(b.Lines, "|")
    delayMs := (b.Delay > 100) ? b.Delay : 1200

    for idx, singleLine in lines {
        if (AbortBindFlag) {
            AbortBindFlag := 0
            TrayTip, ⛔ Отыгровка отменена, Пользовательский бинд прерван по F12., 2, 2
            Return
        }
        textToSend := FormatCustomBindLine(Trim(singleLine))
        if (textToSend = "")
            Continue

        if (idx = 1) {
            Send, {F6}
            SmartSleep(350)
            Send, %textToSend%{Enter}
        } else {
            SmartSleep(delayMs)
            if (AbortBindFlag)
                Return
            Send, {F6}
            SmartSleep(350)
            Send, %textToSend%{Enter}
        }
    }
    TriggerSmartScreenshot("Свой бинд: " . b.Name)
    LogJournalAction("Свой бинд", (LastTargetID != "" ? LastTargetID : "Общий"), b.Name, 0)
}

CustomBindsLVAction:
if (A_GuiEvent = "DoubleClick") {
    Gosub, EditCustomBindBtn
}
Return

OpenAddCustomBindDialog:
EditingCustomBindId := 0
CustomBindDialogTitle := "➕ Создание нового пользовательского бинда"
CustomBindNameVal := "Мой бинд"
CustomBindTriggerVal := "/мойбинд"
CustomBindDelayVal := 1200
CustomBindLinesVal := "Здравия желаю, я сотрудник УГИБДД {Rank} {Fio}!|Предъявите ваше водительское удостоверение."
ShowCustomBindEditor()
Return

EditCustomBindBtn:
Gui, 1:Default
Gui, 1:ListView, CustomBindsLV
selRow := LV_GetNext(0)
if (!selRow) {
    MsgBox, 48, Свои бинды, Выберите бинд из таблицы для редактирования!
    Return
}
LV_GetText(selId, selRow, 1)
EditingCustomBindId := selId + 0
b := CustomBindsDB[EditingCustomBindId]
if (!IsObject(b))
    Return

CustomBindDialogTitle := "✏️ Редактирование бинда #" . EditingCustomBindId
CustomBindNameVal := b.Name
CustomBindTriggerVal := b.Trigger
CustomBindDelayVal := b.Delay
CustomBindLinesVal := StrReplace(b.Lines, "|", "`n")
ShowCustomBindEditor()
Return

ShowCustomBindEditor() {
    global EditingCustomBindId, CustomBindDialogTitle, CustomBindNameVal, CustomBindTriggerVal, CustomBindDelayVal, CustomBindLinesVal
    Gui, 9:Destroy
    Gui, 9:Color, 121622, 1B2234
    Gui, 9:Font, S13 C58A6FF Bold, Segoe UI
    Gui, 9:Add, Text, x16 y12 w560 h26, %CustomBindDialogTitle%

    Gui, 9:Font, S10 CE6EDF3 Bold, Segoe UI
    Gui, 9:Add, Text, x16 y48 w150 h22, Название бинда:
    Gui, 9:Font, S10 CE6EDF3 Norm, Segoe UI
    Gui, 9:Add, Edit, x170 y46 w405 h26 vCBEditName, %CustomBindNameVal%

    Gui, 9:Font, S10 CE6EDF3 Bold, Segoe UI
    Gui, 9:Add, Text, x16 y82 w150 h22, Триггер (команда):
    Gui, 9:Font, S10 CE6EDF3 Norm, Segoe UI
    Gui, 9:Add, Edit, x170 y80 w220 h26 vCBEditTrigger, %CustomBindTriggerVal%
    Gui, 9:Font, S9 C8B949E Norm, Segoe UI
    Gui, 9:Add, Text, x400 y84 w175 h22, (например /пост или !Numpad1)

    Gui, 9:Font, S10 CE6EDF3 Bold, Segoe UI
    Gui, 9:Add, Text, x16 y116 w150 h22, Задержка между строк:
    Gui, 9:Font, S10 CE6EDF3 Norm, Segoe UI
    Gui, 9:Add, Edit, x170 y114 w120 h26 vCBEditDelay, %CustomBindDelayVal%
    Gui, 9:Font, S9 C8B949E Norm, Segoe UI
    Gui, 9:Add, Text, x300 y118 w275 h22, мс (рекомендуется 1200-1800 мс)

    Gui, 9:Font, S10 CE6EDF3 Bold, Segoe UI
    Gui, 9:Add, Text, x16 y150 w560 h22, Текст отыгровки (каждая строка с новой строки):
    Gui, 9:Font, S10 CE6EDF3 Norm, Consolas
    Gui, 9:Add, Edit, x16 y174 w560 h170 vCBEditLines +Multi +WantReturn, %CustomBindLinesVal%

    Gui, 9:Font, S9 CFFB84D Bold, Segoe UI
    Gui, 9:Add, Text, x16 y352 w160 h22, Вставить переменную:
    Gui, 9:Font, S9 CE6EDF3 Norm, Segoe UI
    Gui, 9:Add, Button, x180 y350 w85 h24 gInsertVarFio, + {Fio}
    Gui, 9:Add, Button, x270 y350 w85 h24 gInsertVarRank, + {Rank}
    Gui, 9:Add, Button, x360 y350 w85 h24 gInsertVarZnak, + {Znak}
    Gui, 9:Add, Button, x450 y350 w85 h24 gInsertVarId, + {Id}

    Gui, 9:Font, S10 CE6EDF3 Bold, Segoe UI
    Gui, 9:Add, Button, x16 y390 w270 h36 gSaveCustomBindDialogBtn, 💾 Сохранить бинд
    Gui, 9:Add, Button, x306 y390 w270 h36 gCancelCustomBindDialogBtn, ❌ Отмена

    Gui, 9:Show, w592 h440, Конструктор бинда | АХК УГИБДД
}

InsertVarFio:
GuiControlGet, curTxt, 9:, CBEditLines
GuiControl, 9:, CBEditLines, % curTxt . " {Fio}"
Return

InsertVarRank:
GuiControlGet, curTxt, 9:, CBEditLines
GuiControl, 9:, CBEditLines, % curTxt . " {Rank}"
Return

InsertVarZnak:
GuiControlGet, curTxt, 9:, CBEditLines
GuiControl, 9:, CBEditLines, % curTxt . " {Znak}"
Return

InsertVarId:
GuiControlGet, curTxt, 9:, CBEditLines
GuiControl, 9:, CBEditLines, % curTxt . " {Id}"
Return

SaveCustomBindDialogBtn:
Gui, 9:Submit, NoHide
if (Trim(CBEditName) = "") {
    MsgBox, 48, Ошибка, Введите название бинда!
    Return
}
if (Trim(CBEditTrigger) = "") {
    MsgBox, 48, Ошибка, Введите команду запуска или хоткей!
    Return
}
cleanLines := StrReplace(Trim(CBEditLines), "`r`n", "|")
cleanLines := StrReplace(cleanLines, "`n", "|")
cleanLines := StrReplace(cleanLines, "`r", "|")

if (EditingCustomBindId > 0 && EditingCustomBindId <= CustomBindsDB.MaxIndex()) {
    CustomBindsDB[EditingCustomBindId].Name := Trim(CBEditName)
    CustomBindsDB[EditingCustomBindId].Trigger := Trim(CBEditTrigger)
    CustomBindsDB[EditingCustomBindId].Delay := CBEditDelay + 0
    CustomBindsDB[EditingCustomBindId].Lines := cleanLines
} else {
    newId := CustomBindsDB.MaxIndex() + 1
    CustomBindsDB.Push({Id: newId, Name: Trim(CBEditName), Trigger: Trim(CBEditTrigger), Delay: (CBEditDelay + 0), Active: 1, Lines: cleanLines})
}

SaveCustomBindsToIni()
PopulateCustomBindsLV()
RegisterAllCustomBinds()
Gui, 9:Destroy
TrayTip, ✅ Бинд сохранен!, Пользовательский бинд успешно зарегистрирован и готов к использованию!, 2, 1
Return

CancelCustomBindDialogBtn:
Gui, 9:Destroy
Return

TestCustomBindBtn:
Gui, 1:Default
Gui, 1:ListView, CustomBindsLV
selRow := LV_GetNext(0)
if (!selRow) {
    MsgBox, 48, Проверка бинда, Выберите бинд из таблицы для проверки!
    Return
}
LV_GetText(selId, selRow, 1)
selId += 0
ExecuteCustomBind(selId)
Return

ToggleCustomBindBtn:
Gui, 1:Default
Gui, 1:ListView, CustomBindsLV
selRow := LV_GetNext(0)
if (!selRow) {
    MsgBox, 48, Переключение статуса, Выберите бинд из таблицы!
    Return
}
LV_GetText(selId, selRow, 1)
selId += 0
CustomBindsDB[selId].Active := !CustomBindsDB[selId].Active
SaveCustomBindsToIni()
PopulateCustomBindsLV()
TrayTip, Статус бинда изменен, % "Бинд #" . selId . " теперь: " . (CustomBindsDB[selId].Active ? "АКТИВЕН" : "ОТКЛЮЧЕН"), 2, 1
Return

DeleteCustomBindBtn:
Gui, 1:Default
Gui, 1:ListView, CustomBindsLV
selRow := LV_GetNext(0)
if (!selRow) {
    MsgBox, 48, Удаление бинда, Выберите бинд из таблицы для удаления!
    Return
}
LV_GetText(selId, selRow, 1)
selId += 0
MsgBox, 260, Удаление бинда, % "Удалить бинд #" . selId . " (" . CustomBindsDB[selId].Name . ")?"
IfMsgBox, Yes
{
    CustomBindsDB.RemoveAt(selId)
    SaveCustomBindsToIni()
    PopulateCustomBindsLV()
    TrayTip, 🗑️ Бинд удален, Пользовательский бинд удален из списка., 2, 1
}
Return

; =================================================================================================
; ЭКСПОРТ И ИМПОРТ ПРОФИЛЯ И НАСТРОЕК (BACKUP & RESTORE)
; =================================================================================================
ExportProfileBackup:
FormatTime, dateStamp,, yyyy-MM-dd
FileSelectFile, backupFile, S16, %A_Desktop%\gibdd_profile_backup_%dateStamp%.ini, Экспорт резервной копии профиля УГИБДД, Конфигурация (*.ini)
if (backupFile = "")
    Return
if (!InStr(backupFile, ".ini"))
    backupFile .= ".ini"

srcIni := A_Temp . "\gibdd.egl"
if (!FileExist(srcIni))
    srcIni := A_ScriptDir . "\gibdd_profile.ini"

FileCopy, %srcIni%, %backupFile%, 1

cbIni := A_Temp . "\gibdd_custom_binds.ini"
if (FileExist(cbIni)) {
    IniRead, cbCount, %cbIni%, Meta, Count, 0
    IniWrite, %cbCount%, %backupFile%, CustomBinds_Meta, Count
    Loop, %cbCount% {
        IniRead, bN, %cbIni%, Bind_%A_Index%, Name, %A_Space%
        IniRead, bT, %cbIni%, Bind_%A_Index%, Trigger, %A_Space%
        IniRead, bD, %cbIni%, Bind_%A_Index%, Delay, 1200
        IniRead, bA, %cbIni%, Bind_%A_Index%, Active, 1
        IniRead, bL, %cbIni%, Bind_%A_Index%, Lines, %A_Space%
        IniWrite, %bN%, %backupFile%, CustomBinds_%A_Index%, Name
        IniWrite, %bT%, %backupFile%, CustomBinds_%A_Index%, Trigger
        IniWrite, %bD%, %backupFile%, CustomBinds_%A_Index%, Delay
        IniWrite, %bA%, %backupFile%, CustomBinds_%A_Index%, Active
        IniWrite, %bL%, %backupFile%, CustomBinds_%A_Index%, Lines
    }
}

SoundBeep, 850, 150
TrayTip, 📤 Бэкап создан!, % "Файл резервной копии сохранён: " . backupFile, 3, 1
MsgBox, 64, Резервная копия создана, % "Все данные профиля, горячие клавиши и созданные бинды успешно экспортированы в файл:`n" . backupFile
Return

ImportProfileBackup:
FileSelectFile, importFile, 3, %A_Desktop%, Выберите файл резервной копии УГИБДД (*.ini), Конфигурация (*.ini)
if (importFile = "" || !FileExist(importFile))
    Return

IniRead, testFio, %importFile%, User, Fio1, ERROR
if (testFio = "ERROR") {
    MsgBox, 16, Ошибка импорта, Выбранный файл не содержит корректных данных профиля УГИБДД!
    Return
}

MsgBox, 260, Подтверждение импорта, Все текущие настройки профиля, клавиши и бинды будут заменены данными из выбранного файла бэкапа!`nПродолжить?
IfMsgBox, No
    Return

targetIni1 := A_Temp . "\gibdd.egl"
targetIni2 := A_ScriptDir . "\gibdd_profile.ini"
FileCopy, %importFile%, %targetIni1%, 1
FileCopy, %importFile%, %targetIni2%, 1

IniRead, cbCount, %importFile%, CustomBinds_Meta, Count, 0
if (cbCount > 0) {
    cbIni1 := A_Temp . "\gibdd_custom_binds.ini"
    cbIni2 := A_ScriptDir . "\gibdd_custom_binds.ini"
    for k, p in [cbIni1, cbIni2] {
        if (FileExist(p))
            FileDelete, %p%
        IniWrite, %cbCount%, %p%, Meta, Count
        Loop, %cbCount% {
            IniRead, bN, %importFile%, CustomBinds_%A_Index%, Name, %A_Space%
            IniRead, bT, %importFile%, CustomBinds_%A_Index%, Trigger, %A_Space%
            IniRead, bD, %importFile%, CustomBinds_%A_Index%, Delay, 1200
            IniRead, bA, %importFile%, CustomBinds_%A_Index%, Active, 1
            IniRead, bL, %importFile%, CustomBinds_%A_Index%, Lines, %A_Space%
            IniWrite, %bN%, %p%, Bind_%A_Index%, Name
            IniWrite, %bT%, %p%, Bind_%A_Index%, Trigger
            IniWrite, %bD%, %p%, Bind_%A_Index%, Delay
            IniWrite, %bA%, %p%, Bind_%A_Index%, Active
            IniWrite, %bL%, %p%, Bind_%A_Index%, Lines
        }
    }
}

SoundBeep, 950, 200
MsgBox, 64, Импорт завершен, Профиль и настройки успешно восстановлены из резервной копии!`nСкрипт будет перезапущен для применения изменений.
Reload
Return


ToggleOnlyInGameMode:
Gui, 1:Submit, NoHide
OnlyInGameMode := OnlyInGameChk ? 1 : 0
for idx, targetIni in [A_Temp . "\gibdd.egl", A_ScriptDir . "\gibdd_profile.ini"] {
    IniWrite, %OnlyInGameMode%, %targetIni%, User, OnlyInGameMode
}
for idx, hk in HotkeyDefs {
    UnregisterDynamicHotkey(hk)
    RegisterDynamicHotkey(hk)
}
TrayTip, Режим активности биндов, % (OnlyInGameMode ? "Бинды активны ТОЛЬКО в окне MTA / GTA SA!" : "Бинды активны во всех окнах Windows!"), 2, 1
Return

; =================================================================================================
; МЕНЕДЖЕР ГОРЯЧИХ КЛАВИШ (ДИНАМИЧЕСКАЯ ПРИВЯЗКА И ПЕРЕНАЗНАЧЕНИЕ В GUI)
; =================================================================================================
AddHkDef(IdStr, NameStr, CatStr, DefKey, TargetLabel, IsDoubleFlag := 0, GuiCtrl1 := "", GuiCtrl2 := "") {
    global HotkeyDefs, HotkeyById
    obj := {Id: IdStr, Name: NameStr, Cat: CatStr, DefaultKey: DefKey, CurrentKey: DefKey, Label: TargetLabel, IsDouble: IsDoubleFlag, Ctrl1: GuiCtrl1, Ctrl2: GuiCtrl2}
    HotkeyDefs.Push(obj)
    HotkeyById[IdStr] := obj
}

InitHotkeysManager() {
    global HotkeyDefs, HotkeyById, DoublePressMap, SelectedHkId
    HotkeyDefs := []
    HotkeyById := {}
    DoublePressMap := {}
    SelectedHkId := ""

    AddHkDef("HK_StopBind",       "⛔ Экстренно остановить текущую отыгровку/лекцию", "Система", "F12",      "Bind_StopAction",     0, "",                   "")
    AddHkDef("HK_Greeting",       "Приветствие гражданина",                     "Основное",     "!1",           "Bind_Greeting",       0, "Disp_HK_Greeting",   "Disp3_HK_Greeting")
    AddHkDef("HK_AskDocs",        "Просить предъявить документы (ВУ)",          "Основное",     "^2",           "Bind_AskDocs",        0, "Disp_HK_AskDocs",    "Disp3_HK_AskDocs")
    AddHkDef("HK_TakeDocs",       "Взять и изучить документы",                  "Основное",     "^3",           "Bind_TakeDocs",       0, "Disp_HK_TakeDocs",   "Disp3_HK_TakeDocs")
    AddHkDef("HK_ReturnDocs",     "Вернуть документы гражданину",               "Основное",     "^4",           "Bind_ReturnDocs",     0, "Disp_HK_ReturnDocs", "Disp3_HK_ReturnDocs")
    AddHkDef("HK_AdminProt",      "Составить адм. протокол",                    "Оформление",   "^6",           "Bind_AdminProt",      0, "Disp_HK_AdminProt",  "")
    AddHkDef("HK_ProtocolSign",   "Протокол: на подпись (1) / забрать (2)",     "Оформление",   "!6",           "PressCount",          1, "Disp_HK_ProtSign1",  "Disp_HK_ProtSign2")
    AddHkDef("HK_DetainProt",     "Составить протокол задержания",              "Задержание",   "^5",           "Bind_DetainProt",     0, "Disp_HK_DetainProt", "")
    AddHkDef("HK_Arrest",         "Передача задержанного конвоиру (/arrest)",   "Задержание",   "^0",           "Bind_Arrest",         0, "Disp_HK_Arrest",     "Disp3_HK_Arrest")
    AddHkDef("HK_SuFast",         "Выдать розыск быстро (/su)",                 "Оформление",   "^-",           "Bind_SuFast",         0, "Disp_HK_SuFast",     "Disp3_HK_SuFast")
    AddHkDef("HK_SuSound",        "Выдать розыск со звуком рации (/su)",        "Оформление",   "^7",           "Bind_SuSound",        0, "Disp_HK_SuSound",    "")
    AddHkDef("HK_Tsu",            "Выписать штраф (/tsu)",                      "Оформление",   "!7",           "Bind_Tsu",            0, "Disp_HK_Tsu",        "")
    AddHkDef("HK_TakeLic",        "Аннулировать и лишить ВУ (/takecarlic)",     "Оформление",   "!F7",          "Bind_TakeLic",        0, "Disp_HK_TakeLic",    "")
    AddHkDef("HK_Wcar",           "Розыск авто: выдать (1) / база (2) (/wcar)", "Автомобиль",   "^F8",          "PressCount",          1, "Disp_HK_Wcar1",      "Disp_HK_Wcar2")
    AddHkDef("HK_FindEmp",        "База сотрудников управления (/find)",        "Дополнения",   "^F9",          "Bind_FindEmp",        0, "Disp_HK_FindEmp",    "")
    AddHkDef("HK_Wanted",         "База розыска (/wanted)",                     "Основное",     "^F10",         "Bind_Wanted",         0, "Disp_HK_Wanted",     "Disp3_HK_Wanted")
    AddHkDef("HK_Fines",          "База неоплаченных штрафов (/fines)",         "Основное",     "!F10",         "Bind_Fines",          0, "Disp_HK_Fines",      "Disp3_HK_Fines")
    AddHkDef("HK_CuffsOpen",      "Открыть наручники (пристегнуть к двери)",    "Оформление",   "^=",           "Bind_CuffsOpen",      0, "Disp_HK_CuffsOpen",  "Disp3_HK_CuffsOpen")
    AddHkDef("HK_CuffsClose",     "Закрыть наручники и вручить копию",          "Оформление",   "^delete",      "Bind_CuffsClose",     0, "Disp_HK_CuffsClose", "Disp3_HK_CuffsClose")
    AddHkDef("HK_VoiceOn",        "Включить голосовую рацию (/fracvoice 1)",    "Рация",        "^Insert",      "Bind_VoiceOn",        0, "Disp_HK_VoiceOn",    "")
    AddHkDef("HK_VoiceOff",       "Рация в режим прослушивания (/fracvoice 2)", "Рация",        "^Home",        "Bind_VoiceOff",       0, "Disp_HK_VoiceOff",   "")
    AddHkDef("HK_Megaphone1",     "Мегафон СГУ: Пред 1 (Зелёный)",              "СГУ и Погоня", "!0",           "Bind_Megaphone1",     0, "Disp_HK_Megaphone1", "")
    AddHkDef("HK_Megaphone2",     "Мегафон СГУ: Пред 2 (Жёлтый)",               "СГУ и Погоня", "!-",           "Bind_Megaphone2",     0, "Disp_HK_Megaphone2", "")
    AddHkDef("HK_Megaphone3",     "Мегафон СГУ: Пред 3 (Огонь!)",               "СГУ и Погоня", "!=",           "Bind_Megaphone3",     0, "Disp_HK_Megaphone3", "")
    AddHkDef("HK_MegaphoneWay",   "Мегафон СГУ: Уступите проезд",               "СГУ и Погоня", "!9",           "Bind_MegaphoneWay",   0, "Disp_HK_MegaphoneWay","")
    AddHkDef("HK_FootChase",      "Пешая погоня (/s Останавливаемся!)",         "СГУ и Погоня", "!8",           "Bind_FootChase",      0, "Disp_HK_FootChase",  "")
    AddHkDef("HK_KpkOpen",        "Достать служебный планшет КПК",              "КПК",          "!3",           "Bind_KpkOpen",        0, "Disp_HK_KpkOpen",    "Disp3_HK_KpkOpen")
    AddHkDef("HK_KpkVu",          "Пробить гражданина по базе КПК (/skan)",     "КПК",          "!4",           "Bind_KpkVu",          0, "Disp_HK_KpkVu",      "Disp3_HK_KpkVu")
    AddHkDef("HK_KpkClose",       "Убрать служебный планшет КПК",               "КПК",          "!5",           "Bind_KpkClose",       0, "Disp_HK_KpkClose",   "Disp3_HK_KpkClose")
    AddHkDef("HK_PullOutSimple",  "Вытащить гражданина из автомобиля (кратко)", "Дополнения",   "^r",           "Bind_PullOutSimple",  0, "",                   "")
    AddHkDef("HK_GreetColleague", "Приветствие коллег (Здравия желаю + честь)", "Дополнения",   "^E",           "Bind_GreetColleague", 0, "Disp_HK_GreetColleague","")
    AddHkDef("HK_ShoutHands",     "Крикнуть: Из машины, руки на капот!",        "Задержание",   "!x",           "Bind_ShoutHands",     0, "",                   "")
    AddHkDef("HK_Clock",          "Часы с гравировкой (/timestamp + /time)",    "Дополнения",   "^END",         "Bind_Clock",          0, "Disp_HK_Clock",      "")
    AddHkDef("HK_TryDoor",        "Дёрнуть ручку двери авто (/try)",            "Дополнения",   "!F12",         "Bind_TryDoor",        0, "Disp_HK_TryDoor",    "")
    AddHkDef("HK_TryGlass",       "Ударить дубинкой по стеклу (/try)",          "Дополнения",   "!printscreen", "Bind_TryGlass",       0, "Disp_HK_TryGlass",   "")
    AddHkDef("HK_UnlockIn",       "Открыть замок двери изнутри и достать",      "Дополнения",   "!scrolllock",  "Bind_UnlockIn",       0, "Disp_HK_UnlockIn",   "")
    AddHkDef("HK_PullOutTry",     "Вытащить гражданина из авто (/try)",         "Дополнения",   "^printscreen", "Bind_PullOutTry",     0, "Disp_HK_PullOutTry", "")
    AddHkDef("HK_Putpl",          "Посадить задержанного в авто (/putpl)",      "Задержание",   "^F6",          "Bind_Putpl",          0, "Disp_HK_Putpl",      "Disp3_HK_Putpl")
    AddHkDef("HK_KnockWindow",    "Постучать в окно автомобиля",                "Дополнения",   "^sc29",        "Bind_KnockWindow",    0, "Disp_HK_KnockWindow","")
    AddHkDef("HK_OpenCalc",       "Открыть Калькулятор КоАП / УКРП",            "Утилиты АХК",  "!F1",          "OpenCalc",            0, "",                   "")
    AddHkDef("HK_ToggleHud",      "Показать / скрыть игровой HUD таймеров",     "Утилиты АХК",  "!h",           "ToggleHud",           0, "",                   "")
    AddHkDef("HK_HudDrag",        "Режим перемещения HUD мышкой (Drag&Drop)",   "Утилиты АХК",  "!+h",          "ToggleHudEditMode",   0, "",                   "")
    AddHkDef("HK_ResetChase",     "Сбросить таймер погони СГУ",                 "Утилиты АХК",  "!BS",          "Bind_ResetChase",     0, "",                   "")
    AddHkDef("HK_Pause",          "Поставить АХК на паузу",                     "Система",      "end",          "Bind_Pause",          0, "",                   "")
    AddHkDef("HK_Reload",         "Перезапустить АХК",                          "Система",      "!R",           "Bind_Reload",         0, "",                   "")
    AddHkDef("HK_SmartMegaphone", "Умный мегафон погони (1->2->3->Огонь)", "СГУ и Погоня", "^Space", "ExecuteSmartMegaphoneStep", 0, "Disp_HK_SmartMegaphone", "")
    AddHkDef("HK_ChaseStop",      "Сбросить статус погони / мегафонов",   "СГУ и Погоня", "!Space", "StopChaseModeLabel",          0, "Disp_HK_ChaseStop", "")

    IniPath := A_Temp . "\gibdd.egl"
    for idx, hk in HotkeyDefs {
        IniRead, savedKey, %IniPath%, Hotkeys, % hk.Id, % hk.DefaultKey
        if (savedKey = "ERROR" || savedKey = "")
            savedKey := hk.DefaultKey
        hk.CurrentKey := savedKey
        RegisterDynamicHotkey(hk)
    }
}

IsGlobalUtilityHotkey(hkObj) {
    return (hkObj.Cat = "Система" || hkObj.Cat = "Утилиты АХК")
}

RegisterDynamicHotkey(hkObj) {
    global DoublePressMap, OnlyInGameMode
    k := hkObj.CurrentKey
    if (k = "")
        return
    if (hkObj.IsDouble) {
        DoublePressMap[k] := hkObj.Id
    }
    if (OnlyInGameMode && !IsGlobalUtilityHotkey(hkObj)) {
        Hotkey, IfWinActive, ahk_group ProvinceGameGroup
        Hotkey, %k%, % hkObj.Label, On UseErrorLevel
        Hotkey, IfWinActive
    } else {
        Hotkey, IfWinActive
        Hotkey, %k%, % hkObj.Label, On UseErrorLevel
    }
}

UnregisterDynamicHotkey(hkObj) {
    global DoublePressMap
    k := hkObj.CurrentKey
    if (k = "")
        return
    if (hkObj.IsDouble && DoublePressMap.HasKey(k)) {
        DoublePressMap.Delete(k)
    }
    Hotkey, IfWinActive, ahk_group ProvinceGameGroup
    Hotkey, %k%, Off, UseErrorLevel
    Hotkey, IfWinActive
    Hotkey, %k%, Off, UseErrorLevel
}

FormatHotkeyReadable(AhkKey) {
    if (AhkKey = "")
        return "Не назначено"
    s := AhkKey
    outMod := ""
    if (InStr(s, "^")) {
        outMod .= "Ctrl+"
        s := StrReplace(s, "^", "")
    }
    if (InStr(s, "!")) {
        outMod .= "Alt+"
        s := StrReplace(s, "!", "")
    }
    if (InStr(s, "+")) {
        outMod .= "Shift+"
        s := StrReplace(s, "+", "")
    }
    if (InStr(s, "#")) {
        outMod .= "Win+"
        s := StrReplace(s, "#", "")
    }
    low := Format("{:L}", s)
    if (low = "printscreen")
        s := "PS"
    else if (low = "scrolllock")
        s := "SL"
    else if (low = "delete")
        s := "Delete"
    else if (low = "insert")
        s := "INS"
    else if (low = "home")
        s := "HOME"
    else if (low = "end")
        s := "END"
    else if (low = "bs" || low = "backspace")
        s := "BS"
    else if (low = "sc29" || low = "``")
        s := "Ё"
    else if (StrLen(s) = 1)
        s := Format("{:U}", s)
    return outMod . s
}

GetKeyDisp(IdStr) {
    global HotkeyById
    if (HotkeyById.HasKey(IdStr))
        return FormatHotkeyReadable(HotkeyById[IdStr].CurrentKey)
    return "—"
}

RefreshAllHotkeyGuiLabels() {
    global HotkeyDefs, Vers
    for idx, hk in HotkeyDefs {
        disp := FormatHotkeyReadable(hk.CurrentKey)
        if (hk.Id = "HK_Wcar" || hk.Id = "HK_ProtocolSign") {
            if (hk.Ctrl1 != "")
                GuiControl, 1:, % hk.Ctrl1, % disp . " (1)"
            if (hk.Ctrl2 != "")
                GuiControl, 1:, % hk.Ctrl2, % disp . " (2)"
        } else if (hk.Id = "HK_KnockWindow") {
            if (hk.Ctrl1 != "")
                GuiControl, 1:, % hk.Ctrl1, % "/стук|" . disp
        } else {
            if (hk.Ctrl1 != "")
                GuiControl, 1:, % hk.Ctrl1, % disp
            if (hk.Ctrl2 != "")
                GuiControl, 1:, % hk.Ctrl2, % disp
        }
    }
    GuiControl, 1:, BottomFooterKeys, % "Версия v" . Vers . " (" . WinVerDescription . ")  |  Пауза: [" . GetKeyDisp("HK_Pause") . "]  |  Клик по клавише в таблице = изменить"
}

QuickClickKey:
ctrlVar := A_GuiControl
targetId := ""
for idx, hk in HotkeyDefs {
    if (hk.Ctrl1 = ctrlVar || hk.Ctrl2 = ctrlVar) {
        targetId := hk.Id
        break
    }
}
SetSidebarActive(7, "⌨️ НАСТРОЙКА КЛАВИШ И ДВИЖОК ВВОДА")
if (targetId != "") {
    SelectHotkeyInLV(targetId)
}
Return

SelectHotkeyInLV(TargetId) {
    global SelectedHkId, HotkeyById
    Gui, 1:Default
    Gui, 1:ListView, HotkeysLV
    cnt := LV_GetCount()
    Loop, %cnt% {
        LV_GetText(rowId, A_Index, 1)
        if (rowId = TargetId) {
            LV_Modify(0, "-Select -Focus")
            LV_Modify(A_Index, "Select Focus Vis")
            SelectedHkId := TargetId
            LoadHotkeyIntoEditor(HotkeyById[TargetId])
            break
        }
    }
}

FilterHotkeysLV:
Gui, 1:Submit, NoHide
PopulateHotkeysListView(HkFilterQuery)
Return

PopulateHotkeysListView(Query := "") {
    global HotkeyDefs
    Gui, 1:Default
    Gui, 1:ListView, HotkeysLV
    LV_Delete()
    GuiControl, 1:-Redraw, HotkeysLV
    q := Format("{:L}", Trim(Query))
    for idx, hk in HotkeyDefs {
        curDisp := FormatHotkeyReadable(hk.CurrentKey)
        defDisp := FormatHotkeyReadable(hk.DefaultKey)
        if (q != "") {
            hay := Format("{:L}", hk.Name . " " . curDisp . " " . defDisp . " " . hk.Cat)
            if (!InStr(hay, q))
                continue
        }
        LV_Add("", hk.Id, hk.Name, curDisp, defDisp, hk.Cat)
    }
    LV_ModifyCol(1, 0)
    LV_ModifyCol(2, 370)
    LV_ModifyCol(3, 165)
    LV_ModifyCol(4, 165)
    LV_ModifyCol(5, 180)
    GuiControl, 1:+Redraw, HotkeysLV
}

HotkeysLVSelect:
Gui, 1:Default
Gui, 1:ListView, HotkeysLV
if ((A_GuiEvent = "Normal" || A_GuiEvent = "DoubleClick" || A_GuiEvent = "I") && A_EventInfo > 0) {
    selRow := LV_GetNext(0)
    if (selRow > 0) {
        LV_GetText(rowId, selRow, 1)
        if (rowId != "" && HotkeyById.HasKey(rowId)) {
            SelectedHkId := rowId
            LoadHotkeyIntoEditor(HotkeyById[rowId])
        }
    }
}
Return

LoadHotkeyIntoEditor(hkObj) {
    dispCur := FormatHotkeyReadable(hkObj.CurrentKey)
    dispDef := FormatHotkeyReadable(hkObj.DefaultKey)
    GuiControl, 1:, SelectedHkTitle, % "✏️ Редактируется: «" . hkObj.Name . "»   |   Сейчас: [" . dispCur . "]   |   По умолчанию: [" . dispDef . "]"
    GuiControl, 1:, HkBoxCtrl, % hkObj.CurrentKey
    GuiControl, 1:, HkModCtrl, 0
    GuiControl, 1:, HkModAlt, 0
    GuiControl, 1:, HkModShift, 0
    GuiControl, 1:Choose, HkSpecialDDL, 1
}

BuildSpecialKeyString(ModC, ModA, ModS, SpecChoice) {
    prefix := ""
    if (ModC)
        prefix .= "^"
    if (ModA)
        prefix .= "!"
    if (ModS)
        prefix .= "+"
    keyName := SpecChoice
    if (SpecChoice = "sc29 (Ё/~)")
        keyName := "sc29"
    return prefix . keyName
}

NormalizeAhkHotkey(rawKey) {
    k := Trim(rawKey)
    if (k = "")
        return ""
    
    hasCtrl := 0, hasAlt := 0, hasShift := 0
    if (RegExMatch(k, "i)(ctrl|\^)"))
        hasCtrl := 1
    if (RegExMatch(k, "i)(alt|!)"))
        hasAlt := 1
    if (RegExMatch(k, "i)(shift|\+)"))
        hasShift := 1
    
    cleanBase := RegExReplace(k, "i)(ctrl\s*\+?|alt\s*\+?|shift\s*\+?|[\^!+])", "")
    cleanBase := Trim(cleanBase)
    
    if (cleanBase != "") {
        prefix := ""
        if (hasCtrl)
            prefix .= "^"
        if (hasAlt)
            prefix .= "!"
        if (hasShift)
            prefix .= "+"
        return prefix . cleanBase
    }
    
    return k
}

ApplyNewHotkeyBtn:
Gui, 1:Submit, NoHide
if (SelectedHkId = "" || !HotkeyById.HasKey(SelectedHkId)) {
    MsgBox, 48, Настройка клавиш, Сначала выберите действие в таблице выше!
    Return
}
newKey := ""
if (HkSpecialDDL != "" && HkSpecialDDL != "(Не выбрано)") {
    newKey := BuildSpecialKeyString(HkModCtrl, HkModAlt, HkModShift, HkSpecialDDL)
} else if (HkBoxCtrl != "") {
    newKey := HkBoxCtrl
}
if (newKey = "") {
    MsgBox, 48, Настройка клавиш, Нажмите желаемую клавишу в поле «Способ 1» или выберите спецклавишу в списке «Способ 2»!
    Return
}

; Проверка на конфликт с другими биндами
for idx, otherHk in HotkeyDefs {
    if (otherHk.Id != SelectedHkId && Format("{:L}", otherHk.CurrentKey) = Format("{:L}", newKey)) {
        MsgBox, 52, Конфликт клавиш, % "Клавиша [" . FormatHotkeyReadable(newKey) . "] уже используется для бинда:`n«" . otherHk.Name . "»!`n`nВсё равно назначить её сюда?"
        IfMsgBox, No
            Return
        break
    }
}

targetObj := HotkeyById[SelectedHkId]
UnregisterDynamicHotkey(targetObj)
targetObj.CurrentKey := newKey
RegisterDynamicHotkey(targetObj)

for idx, targetIni in [A_Temp . "\gibdd.egl", A_ScriptDir . "\gibdd_profile.ini"] {
    IniWrite, %newKey%, %targetIni%, Hotkeys, %SelectedHkId%
}

PopulateHotkeysListView(HkFilterQuery)
SelectHotkeyInLV(SelectedHkId)
RefreshAllHotkeyGuiLabels()
InitBindsCatalog()
PopulateBindsListView(BindSearchQuery, BindCatFilter)
TrayTip, Клавиша обновлена!, % targetObj.Name . " -> [" . FormatHotkeyReadable(newKey) . "]", 2, 1
Return

ResetSingleHotkeyBtn:
Gui, 1:Submit, NoHide
if (SelectedHkId = "" || !HotkeyById.HasKey(SelectedHkId)) {
    MsgBox, 48, Настройка клавиш, Сначала выберите действие в таблице выше!
    Return
}
targetObj := HotkeyById[SelectedHkId]
UnregisterDynamicHotkey(targetObj)
targetObj.CurrentKey := targetObj.DefaultKey
RegisterDynamicHotkey(targetObj)

for idx, targetIni in [A_Temp . "\gibdd.egl", A_ScriptDir . "\gibdd_profile.ini"] {
    IniWrite, % targetObj.DefaultKey, %targetIni%, Hotkeys, %SelectedHkId%
}

PopulateHotkeysListView(HkFilterQuery)
SelectHotkeyInLV(SelectedHkId)
RefreshAllHotkeyGuiLabels()
InitBindsCatalog()
PopulateBindsListView(BindSearchQuery, BindCatFilter)
TrayTip, Сброс клавиши, % targetObj.Name . " -> [" . FormatHotkeyReadable(targetObj.DefaultKey) . "]", 2, 1
Return

ResetAllHotkeysBtn:
MsgBox, 52, Сброс всех клавиш, Вы уверены, что хотите вернуть ВСЕ 43 горячие клавиши к стандартным значениям по умолчанию?
IfMsgBox, No
    Return
for idx, hk in HotkeyDefs {
    UnregisterDynamicHotkey(hk)
    hk.CurrentKey := hk.DefaultKey
    RegisterDynamicHotkey(hk)
    for i2, targetIni in [A_Temp . "\gibdd.egl", A_ScriptDir . "\gibdd_profile.ini"] {
        IniWrite, % hk.DefaultKey, %targetIni%, Hotkeys, % hk.Id
    }
}
PopulateHotkeysListView(HkFilterQuery)
RefreshAllHotkeyGuiLabels()
InitBindsCatalog()
PopulateBindsListView(BindSearchQuery, BindCatFilter)
MsgBox, 64, Настройка клавиш, Все горячие клавиши успешно восстановлены по умолчанию!
Return

; =================================================================================================
; ФУНКЦИИ КОНФИГУРАЦИИ И БЕЗОПАСНОЙ ИНИЦИАЛИЗАЦИИ
; =================================================================================================
EnsureDefaultConfig() {
    IniPath := A_Temp . "\gibdd.egl"
    BackupIni := A_ScriptDir . "\gibdd_profile.ini"
    if (!FileExist(IniPath) && FileExist(BackupIni)) {
        FileCopy, %BackupIni%, %IniPath%, 1
    }
    IniRead, chkFio, %IniPath%, User, Fio1, ERROR
    if (chkFio = "ERROR" || chkFio = "") {
        IniWrite, Имя Фамилия Отчество, %IniPath%, User, Fio1
        IniWrite, 1, %IniPath%, User, Prop1
        IniWrite, 000, %IniPath%, User, Prop2
        IniWrite, Рядовой, %IniPath%, User, Rank
        IniWrite, 61, %IniPath%, User, Teg
        IniWrite, Инспектор ОР, %IniPath%, User, Otdel
        IniWrite, 77-000000, %IniPath%, User, Znak
        IniWrite, Невский, %IniPath%, User, Frak
        IniWrite, Я мужык, %IniPath%, User, Gender
        IniWrite, УГИБДД-Н, %IniPath%, User, Gibdd
        IniWrite, ОР/СР, %IniPath%, User, CheckMB
        IniWrite, 1, %IniPath%, User, Post
        IniWrite, 1, %IniPath%, User, AutoScreenMode
        IniWrite, 1, %IniPath%, User, RadioSfx
        IniWrite, ТС нарушителя, %IniPath%, User, ChaseTargetText
    }
}

LoadUserConfig() {
    global Fio1, Rank, Prop1, Prop2, Otdel, Frak, Gender, Teg, Gibdd, Znak, CheckMB, Post, ProvLogPath, OnlyInGameMode, RadioSfxEnabled
    IniPath := A_Temp . "\gibdd.egl"
    IniRead, Fio1, %IniPath%, User, Fio1, Имя Фамилия
    IniRead, Rank, %IniPath%, User, Rank, Рядовой
    IniRead, Prop1, %IniPath%, User, Prop1, 1
    IniRead, Prop2, %IniPath%, User, Prop2, 000
    IniRead, Otdel, %IniPath%, User, Otdel, Инспектор ОР
    IniRead, Frak, %IniPath%, User, Frak, Невский
    IniRead, Gender, %IniPath%, User, Gender, Я мужык
    IniRead, Teg, %IniPath%, User, Teg, 61
    IniRead, Gibdd, %IniPath%, User, Gibdd, УГИБДД-Н
    IniRead, Znak, %IniPath%, User, Znak, 77-000000
    IniRead, CheckMB, %IniPath%, User, CheckMB, ОР/СР
    IniRead, Post, %IniPath%, User, Post, 1
    IniRead, ProvLogPath, %IniPath%, User, ProvLogPath, AUTO
    IniRead, OnlyInGameMode, %IniPath%, User, OnlyInGameMode, 0
    IniRead, AutoScreenMode, %IniPath%, User, AutoScreenMode, 1
    IniRead, RadioSfxEnabled, %IniPath%, User, RadioSfx, 1
    IniRead, ChaseTargetText, %IniPath%, User, ChaseTargetText, ТС нарушителя
    if (Prop1 = "ERROR" || Prop1 = "")
        Prop1 := "1"
    if (Post = "ERROR" || Post = "")
        Post := "1"
    if (OnlyInGameMode = "ERROR" || OnlyInGameMode = "")
        OnlyInGameMode := 0
    if (RadioSfxEnabled = "ERROR" || RadioSfxEnabled = "")
        RadioSfxEnabled := 1
}

; =================================================================================================
; ОКНО 2: АНКЕТА СОТРУДНИКА (С ПРЕДПРОСМОТРОМ И АВТОСИНХРОНИЗАЦИЕЙ)
; =================================================================================================
Data:
Gui, 2:Destroy
LoadUserConfig()
Gui, 2:Color, 121622, 1B2234
Gui, 2:Font, S15 C58A6FF Bold, Segoe UI
Gui, 2:Add, Text, x16 y10 w640 h30, 📋 Личная анкета сотрудника УГИБДД

Gui, 2:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 2:Add, Text, x16 y48 w250 h22, Город трудоустройства:
Gui, 2:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 2:Add, DropDownList, x270 y45 w380 r4 vFrak gSyncCityAndPreview, Приволжск|Мирный|Невский
GuiControl, 2:ChooseString, Frak, %Frak%

Gui, 2:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 2:Add, Text, x16 y84 w250 h22, ФИО (Иванов Иван Иванович):
Gui, 2:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 2:Add, Edit, x270 y81 w380 h26 vFio1 gUpdateProfilePreview, %Fio1%

Gui, 2:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 2:Add, Text, x16 y120 w250 h22, Специальное звание:
Gui, 2:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 2:Add, DropDownList, x270 y117 w380 r14 vRank gUpdateProfilePreview, Рядовой|Сержант|Старшина|Прапорщик|Лейтенант|Старший лейтенант|Капитан|Майор|Подполковник|Полковник|Генерал-майор|Генерал-лейтенант|Генерал-полковник|Генерал МВД
GuiControl, 2:ChooseString, Rank, %Rank%

Gui, 2:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 2:Add, Text, x16 y156 w250 h22, Код отдела (1-я часть, напр. 61):
Gui, 2:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 2:Add, Edit, x270 y153 w130 h26 vTeg gUpdateProfilePreview, %Teg%

Gui, 2:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 2:Add, Text, x415 y156 w105 h22, Тен-код (ID):
Gui, 2:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 2:Add, Edit, x520 y153 w130 h26 vProp2 gUpdateProfilePreview, %Prop2%

Gui, 2:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 2:Add, Text, x16 y192 w250 h22, Нагрудный знак (77-079753):
Gui, 2:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 2:Add, Edit, x270 y189 w380 h26 vZnak gUpdateProfilePreview, %Znak%

Gui, 2:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 2:Add, Text, x16 y228 w250 h22, Должность (Инспектор ОР):
Gui, 2:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 2:Add, Edit, x270 y225 w380 h26 vOtdel gUpdateProfilePreview, %Otdel%

Gui, 2:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 2:Add, Text, x16 y264 w250 h22, Подразделение / Пол:
Gui, 2:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 2:Add, DropDownList, x270 y261 w135 r4 vGibdd gUpdateProfilePreview, УГИБДД-П|УГИБДД-М|УГИБДД-Н
GuiControl, 2:ChooseString, Gibdd, %Gibdd%
Gui, 2:Add, DropDownList, x415 y261 w130 r2 vGender gUpdateProfilePreview, Я мужык|Я девочка
GuiControl, 2:ChooseString, Gender, %Gender%
Gui, 2:Add, DropDownList, x555 y261 w95 r3 vCheckMB gUpdateProfilePreview, ОР/СР|МР
GuiControl, 2:ChooseString, CheckMB, %CheckMB%

Gui, 2:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 2:Add, Text, x16 y300 w250 h22, Папка лога MTA (console.log):
Gui, 2:Font, S9 CE6EDF3 Norm, Segoe UI
Gui, 2:Add, Edit, x270 y298 w280 h25 vProvLogPath, %ProvLogPath%
Gui, 2:Add, Button, x556 y297 w94 h27 gBrowseLogFolder, Обзор...

Gui, 2:Font, S10 C58A6FF Bold, Consolas
Gui, 2:Add, GroupBox, x16 y334 w634 h105, [ Живой предпросмотр приветствия и рации (/п1) ]
Gui, 2:Font, S9 CFFB84D Norm, Consolas
Gui, 2:Add, Text, x26 y354 w614 h76 vProfilePreviewText, Загрузка предпросмотра...

Gui, 2:Font, S11 CE6EDF3 Bold, Segoe UI
Gui, 2:Add, Button, x16 y450 w160 h38 gSave, 💾 Сохранить
Gui, 2:Add, Button, x184 y450 w155 h38 gExportProfileBackup, 📤 Экспорт (бэкап)
Gui, 2:Add, Button, x347 y450 w155 h38 gImportProfileBackup, 📥 Импорт профиля
Gui, 2:Add, Button, x510 y450 w140 h38 gClose, Закрыть
Gui, 2:Font, S9 C8B949E Norm, Segoe UI
Gui, 2:Add, Text, x395 y458 w255 h24 +Right, % "Профиль дублируется в gibdd_profile.ini"

Gosub, UpdateProfilePreview
Gui, 2:Show, w666 h502, Анкета сотрудника | АХК УГИБДД
Return

SyncCityAndPreview:
Gui, 2:Submit, NoHide
if (Frak = "Приволжск")
    GuiControl, 2:ChooseString, Gibdd, УГИБДД-П
else if (Frak = "Мирный")
    GuiControl, 2:ChooseString, Gibdd, УГИБДД-М
else if (Frak = "Невский")
    GuiControl, 2:ChooseString, Gibdd, УГИБДД-Н
Gosub, UpdateProfilePreview
Return

UpdateProfilePreview:
Gui, 2:Submit, NoHide
PrevPat := (Frak = "Невский") ? "10-0" : (Frak = "Мирный") ? "10-1" : "10-2"
PrevOkr := (Frak = "Невский") ? "УГИБДД по г. Невский и Невской обл." : (Frak = "Мирный") ? "УГИБДД по г. Мирный и Мирнинской обл." : "УГИБДД по г. Приволжск и Приволжской обл."
PrevText := GetKeyDisp("HK_Greeting") . " -> Здравия желаю, " . Otdel . " " . PrevOkr . "`n"
PrevText .= "         " . Rank . " полиции, " . Fio1 . ". [Знак: " . Znak . "]`n"
PrevText .= "/п1   -> /r " . Teg . "-" . Prop2 . " " . PrevPat . "   |   Отдел: " . Gibdd . " (" . CheckMB . ")"
GuiControl, 2:, ProfilePreviewText, %PrevText%
Return

BrowseLogFolder:
FileSelectFolder, SelectedLogDir, , 3, Выберите папку MTA\logs (где лежит console.log)
if (SelectedLogDir != "") {
    GuiControl, 2:, ProvLogPath, %SelectedLogDir%
}
Return

Save:
Gui, 2:Submit, NoHide
if (Prop1 = "" || Prop1 = "ERROR")
    Prop1 := "1"
for idx, targetIni in [A_Temp . "\gibdd.egl", A_ScriptDir . "\gibdd_profile.ini"] {
    IniWrite, %Fio1%, %targetIni%, User, Fio1
    IniWrite, %Prop1%, %targetIni%, User, Prop1
    IniWrite, %Prop2%, %targetIni%, User, Prop2
    IniWrite, %Rank%, %targetIni%, User, Rank
    IniWrite, %Teg%, %targetIni%, User, Teg
    IniWrite, %Otdel%, %targetIni%, User, Otdel
    IniWrite, %Znak%, %targetIni%, User, Znak
    IniWrite, %Frak%, %targetIni%, User, Frak
    IniWrite, %Gender%, %targetIni%, User, Gender
    IniWrite, %Gibdd%, %targetIni%, User, Gibdd
    IniWrite, %CheckMB%, %targetIni%, User, CheckMB
    IniWrite, %ProvLogPath%, %targetIni%, User, ProvLogPath
}
MsgBox, 64, Анкета сохранена (%Vers%), Личные данные сотрудника успешно сохранены!
Reload
Return

#UseHook, Off
#UseHook, On

; =================================================================================================
; ОКНО 3: ПОЛЕЗНЫЕ ССЫЛКИ И ОКНО 4: ПРОБЛЕСКОВЫЕ МАЯЧКИ
; =================================================================================================
Help:
Gui, 3:Destroy
Gui, 3:Color, 121622, 1B2234
Gui, 3:Font, S15 C58A6FF Bold, Segoe UI
Gui, 3:Add, Text, x15 y10 w470 h30 +Center, 🔗 Полезные ссылки и материалы МВД / УГИБДД

Gui, 3:Font, S11 CE6EDF3 Bold, Segoe UI
Gui, 3:Add, Button, x15 y48 w195 h32 gButtonURLForumMVD, МВД (Общий раздел)
Gui, 3:Add, Button, x15 y86 w195 h32 gButtonURLForumGIBDDP, УГИБДД-П (Приволжск)
Gui, 3:Add, Button, x15 y124 w195 h32 gButtonURLForumGIBDDM, УГИБДД-М (Мирный)
Gui, 3:Add, Button, x15 y162 w195 h32 gButtonURLFORUMGIBDDN, УГИБДД-Н (Невский)
Gui, 3:Add, Button, x15 y200 w195 h32 gButtonURLForumFZoP, ФЗ «О полиции»
Gui, 3:Add, Button, x15 y238 w195 h32 gButtonURLForumPDD, Камеры радаров РП
Gui, 3:Add, Button, x15 y276 w195 h32 gButtonURLForumUPK, УПК РП
Gui, 3:Add, Button, x15 y314 w195 h32 gButtonURLForumKoAP, КоАП РП
Gui, 3:Add, Button, x15 y352 w195 h32 gButtonURLMetodPDDD, ПДД РП
Gui, 3:Add, Button, x15 y390 w195 h32 gButtonURLMetodGIBDD, Методичка УГИБДД
Gui, 3:Add, Button, x15 y428 w195 h32 gButtonURLMoyak, 🚨 Памятка по маячкам
Gui, 3:Add, Button, x15 y466 w195 h32 gButtonURLVKRaz, ВК разработчика АХК

Gui, 3:Font, S10 CFFB84D Bold, Segoe UI
Gui, 3:Add, Text, x225 y54 w270 h24, Форумный раздел МВД
Gui, 3:Add, Text, x225 y92 w270 h24, Форумный раздел Приволжска
Gui, 3:Add, Text, x225 y130 w270 h24, Форумный раздел Мирного
Gui, 3:Add, Text, x225 y168 w270 h24, Форумный раздел Невского
Gui, 3:Add, Text, x225 y206 w270 h24, Федеральный закон «О полиции»
Gui, 3:Add, Text, x225 y244 w270 h24, Карта камер Республики Провинция
Gui, 3:Add, Text, x225 y282 w270 h24, Уголовно-процессуальный кодекс
Gui, 3:Add, Text, x225 y320 w270 h24, Кодекс об адм. правонарушениях
Gui, 3:Add, Text, x225 y358 w270 h24, Правила дорожного движения
Gui, 3:Add, Text, x225 y396 w270 h24, Методичка сотрудника УГИБДД
Gui, 3:Add, Text, x225 y434 w270 h24, Режимы проблесковых маячков (1–6)
Gui, 3:Add, Text, x225 y472 w270 h24, Связь с автором сборки

Gui, 3:Font, S9 C8B949E Norm, Segoe UI
Gui, 3:Add, Text, x15 y512 w200 h18, v%Vers%
Gui, 3:Show, w510 h540, Полезные ссылки | АХК УГИБДД
Return

ButtonURLVkGroup:
if (URLVkGroup != "")
    Run % URLVkGroup
Return
ButtonURLForumMVD:
Run https://vk.cc/cg2aYR
Return
ButtonURLForumGIBDDM:
Run https://vk.cc/cg2b9H
Return
ButtonURLForumGIBDDP:
Run https://vk.cc/cg2b82
Return
ButtonURLFORUMGIBDDN:
Run https://vk.cc/ceDIz5
Return
ButtonURLForumFZoP:
Run https://vk.cc/czQG8U
Return
ButtonURLForumPDD:
Run https://vk.cc/cO3BPY
Return
ButtonURLForumUPK:
Run https://vk.cc/cn94mS
Return
ButtonURLForumKoAP:
Run https://vk.cc/cn94q1
Return
ButtonURLMetodGIBDD:
Run https://vk.cc/cAsupD
Return
ButtonURLMetodPDDD:
Run https://vk.cc/cn94ui
Return
ButtonURLVKRaz:
Run https://vk.com/id218945813
Return

ButtonURLMoyak:
Gui, 4:Destroy
Gui, 4:Color, 121622, 1B2234
Gui, 4:Font, S13 C58A6FF Bold, Segoe UI
Gui, 4:Add, Text, x15 y10 w820 h26, 🚨 Режимы проблесковых маячков и СГУ УГИБДД
Gui, 4:Font, S11 CE6EDF3 Bold, Segoe UI
Gui, 4:Add, Text, x15 y45 w830 r1, • Маячки №1 + СГУ — при ведении погони за нарушителем / рейда / спецоперации
Gui, 4:Add, Text, x15 y80 w830 r1, • Маячки №2 + СГУ — при сопровождении (СГУ для первой и последней машины в колонне)
Gui, 4:Add, Text, x15 y115 w830 r1, • Маячки №3 без СГУ — при проведении блокпоста
Gui, 4:Add, Text, x15 y150 w830 r1, • Маячки №4 без СГУ — для стационарных постов ДПС
Gui, 4:Add, Text, x15 y185 w830 r1, • Маячки №5 без СГУ — при оформлении ДТП / нарушителей / патруле (и СГУ при погоне)
Gui, 4:Add, Text, x15 y220 w830 r1, • Маячки №6 без СГУ — для перекрытия движения
Gui, 4:Font, S9 C8B949E Norm, Segoe UI
Gui, 4:Add, Text, x15 y255 w200 h18, v%Vers%
Gui, 4:Show, w855 h285, Проблесковые маячки | АХК УГИБДД
Return

Reload:
Reload
Return

Close:
Gui, 2:Hide
Return

; =================================================================================================
; ПУНКТ 2: ИНТЕРАКТИВНЫЙ КАЛЬКУЛЯТОР И СПРАВОЧНИК КоАП / УКРП / ПДД / ФЗоП (GUI 5, Alt+F1, /штраф)
; =================================================================================================
:?:/штраф::
:?:/калькулятор::
Gosub, OpenCalc
Return

:?:/фзоп::
Gosub, OpenFzopGuide
Return

:?:/коап::
Gosub, OpenKoapGuide
Return

OpenKoapGuide:
Gosub, OpenCalc
GuiControl, 5:ChooseString, CalcCodeFilter, КоАП
Gosub, FilterCalcList
Return

:?:/ук::
Gosub, OpenUkGuide
Return

:?:/укрп::
Gosub, OpenUkGuide
Return

OpenUkGuide:
Gosub, OpenCalc
GuiControl, 5:ChooseString, CalcCodeFilter, УКРП
Gosub, FilterCalcList
Return

:?:/пдд::
Gosub, OpenPddGuide
Return

OpenPddGuide:
Gosub, OpenCalc
GuiControl, 5:ChooseString, CalcCodeFilter, ПДД
Gosub, FilterCalcList
Return


OpenFzopGuide:
Gosub, OpenCalc
GuiControl, 5:ChooseString, CalcCodeFilter, ФЗоП
Gosub, FilterCalcList
Return

OpenCalc:
Gui, 5:Destroy
Gui, 5:+AlwaysOnTop
Gui, 5:Color, 121622, 1B2234
Gui, 5:Font, S13 C58A6FF Bold, Segoe UI
Gui, 5:Add, Text, x14 y10 w550 h26, ⚖️ Интерактивный Калькулятор и Поиск: КоАП / УК РП / ПДД / ФЗоП

Gui, 5:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 5:Add, Text, x14 y44 w65 h24 +0x200, Поиск:
Gui, 5:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 5:Add, Edit, x80 y44 w360 h26 vCalcSearchQuery gFilterCalcList
Gui, 5:Font, S10 CE6EDF3 Bold, Segoe UI
Gui, 5:Add, Text, x452 y44 w65 h24 +0x200, Кодекс:
Gui, 5:Font, S10 CE6EDF3 Norm, Segoe UI
Gui, 5:Add, DropDownList, x520 y44 w160 r6 vCalcCodeFilter gFilterCalcList Choose1, Все кодексы|КоАП|УКРП|ПДД|ФЗоП
Gui, 5:Add, Text, x695 y44 w105 h24 +0x200, ID гражданина:
Gui, 5:Add, Edit, x802 y44 w80 h26 vCalcTargetID gRecalcSelectedArticles, % (LastTargetID != "" ? LastTargetID : "")

Gui, 5:Font, S9 CE6EDF3 Norm, Segoe UI
Gui, 5:Add, ListView, x14 y78 w868 h330 +Checked +Grid -Multi Background1B2234 cE6EDF3 vCalcLV gCalcLVEvent AltSubmit, № Статьи|Кодекс|Команда|Штраф (руб)|Санкция / Наказание|Описание правонарушения

Gui, 5:Font, S10 CFFB84D Bold, Consolas
Gui, 5:Add, Text, x14 y412 w868 h20 vCalcSummaryText, Отметьте галочками статьи (лимит одного штрафа в /tsu — 100.000 руб.)...

Gui, 5:Font, S9 CE6EDF3 Bold, Segoe UI
Gui, 5:Add, Text, x14 y436 w115 h24 +0x200, Штраф (до 100к):
Gui, 5:Font, S10 C58A6FF Bold, Consolas
Gui, 5:Add, Edit, x132 y436 w430 h24 vCalcReadyCmd, /tsu ID Сумма Статьи

Gui, 5:Font, S9 CE6EDF3 Bold, Segoe UI
Gui, 5:Add, Text, x574 y436 w90 h24 +0x200, Лишение ВУ:
Gui, 5:Font, S10 CFF7B72 Bold, Consolas
Gui, 5:Add, Edit, x666 y436 w216 h24 vCalcReadyLicCmd, /takecarlic ID Срок

Gui, 5:Font, S9 CFFB84D Bold, Segoe UI
Gui, 5:Add, Text, x14 y466 w115 h24 +0x200, Остаток (>100к):
Gui, 5:Font, S10 CFFB84D Bold, Consolas
Gui, 5:Add, Edit, x132 y466 w430 h24 vCalcReadyOverflowCmd, [Сумма не превышает 100.000 руб.]
Gui, 5:Font, S9 CE6EDF3 Bold, Segoe UI
Gui, 5:Add, Button, x574 y465 w150 h26 gCalcCopyOverflow, 📋 Скопировать остаток
Gui, 5:Add, Button, x730 y465 w152 h26 gCalcSendOverflow, 📝 Ввести остаток в чат

Gui, 5:Font, S9 CE6EDF3 Bold, Segoe UI
Gui, 5:Add, Button, x14 y498 w165 h32 gCalcSpeakArticles, 📢 Зачитать статьи
Gui, 5:Add, Button, x185 y498 w190 h32 gCalcPlayAndTsu, 📝 Отыграть и /tsu
Gui, 5:Add, Button, x381 y498 w135 h32 gCalcCopyTsu, 📋 Копировать /tsu
Gui, 5:Add, Button, x522 y498 w195 h32 gCalcPlayAndLic, 🪪 Отыграть /takecarlic
Gui, 5:Add, Button, x723 y498 w68 h32 gCalcCopyLic, 📋 ВУ
Gui, 5:Add, Button, x797 y498 w85 h32 gCalcClearChecks, 🧹 Сброс

PopulateCalcListView()
Gui, 5:Show, w896 h542, Калькулятор КоАП / УКРП / ПДД / ФЗоП | АХК УГИБДД
Return

FilterCalcList:
Gui, 5:Submit, NoHide
PopulateCalcListView(CalcSearchQuery, CalcCodeFilter)
Return

PopulateCalcListView(Query := "", CodeFilter := "Все кодексы") {
    global ArticlesDB, SelectedArticlesMap
    Gui, 5:Default
    Gui, 5:ListView, CalcLV
    LV_Delete()
    GuiControl, 5:-Redraw, CalcLV
    q := Format("{:L}", Trim(Query))
    for idx, item in ArticlesDB {
        if (CodeFilter != "" && CodeFilter != "Все кодексы" && item.Code != CodeFilter)
            continue
        if (q != "") {
            hay := Format("{:L}", item.Code . " " . item.Num . " " . item.Cmd . " " . item.Sanction . " " . item.Desc)
            if (!InStr(hay, q))
                continue
        }
        chkOpt := SelectedArticlesMap.HasKey(item.Cmd) ? "Check" : ""
        LV_Add(chkOpt, item.Num, item.Code, item.Cmd, item.Fine, item.Sanction, item.Desc)
    }
    LV_ModifyCol(1, 75)
    LV_ModifyCol(2, 65)
    LV_ModifyCol(3, 95)
    LV_ModifyCol(4, 90)
    LV_ModifyCol(5, 220)
    LV_ModifyCol(6, 300)
    GuiControl, 5:+Redraw, CalcLV
    Gosub, RecalcSelectedArticles
}

CalcLVEvent:
Gui, 5:Default
Gui, 5:ListView, CalcLV
if (A_GuiEvent = "I") {
    if (InStr(ErrorLevel, "C", true)) {
        LV_GetText(rowCmd, A_EventInfo, 3)
        if (rowCmd != "") {
            SelectedArticlesMap[rowCmd] := 1
            Gosub, RecalcSelectedArticles
        }
    } else if (InStr(ErrorLevel, "c", true)) {
        LV_GetText(rowCmd, A_EventInfo, 3)
        if (rowCmd != "") {
            SelectedArticlesMap.Delete(rowCmd)
            Gosub, RecalcSelectedArticles
        }
    }
} else if (A_GuiEvent = "DoubleClick" && A_EventInfo > 0) {
    LV_GetText(rowCmd, A_EventInfo, 3)
    isChecked := (LV_GetNext(A_EventInfo - 1, "C") = A_EventInfo)
    if (isChecked) {
        LV_Modify(A_EventInfo, "-Check")
        SelectedArticlesMap.Delete(rowCmd)
    } else {
        LV_Modify(A_EventInfo, "Check")
        SelectedArticlesMap[rowCmd] := 1
    }
    Gosub, RecalcSelectedArticles
}
Return

GetArticleLicTerm(item) {
    if (item.Code != "КоАП")
        return -1
    if (item.Num = "5.2")
        return 0
    if (item.Num = "9.1" || item.Num = "17.2" || item.Num = "17.6")
        return 2
    if (item.Num = "16.1")
        return 4
    if (item.Num = "17.1.4" || item.Num = "17.1.5" || item.Num = "17.5" || item.Num = "18.5" || item.Num = "19.9")
        return 1
    return -1
}

RecalcSelectedArticles:
Gui, 5:Submit, NoHide
totalFine := 0
koapNums := ""
ukNums := ""
pddNums := ""
fzopNums := ""
overKoapNums := ""
overUkNums := ""
extraNotes := ""
countSel := 0
hasLic := 0
licYears := 0
for idx, item in ArticlesDB {
    if (SelectedArticlesMap.HasKey(item.Cmd)) {
        countSel++
        totalFine += item.Fine
        if (item.Code = "КоАП") {
            koapNums .= (koapNums = "" ? "" : "+") . item.Num
            if (totalFine > 100000 && item.Fine > 0)
                overKoapNums .= (overKoapNums = "" ? "" : "+") . item.Num
        } else if (item.Code = "УКРП" || item.Code = "УК") {
            ukNums .= (ukNums = "" ? "" : "+") . item.Num
            if (totalFine > 100000 && item.Fine > 0)
                overUkNums .= (overUkNums = "" ? "" : "+") . item.Num
        } else if (item.Code = "ПДД") {
            pddNums .= (pddNums = "" ? "" : "+") . item.Num
        } else if (item.Code = "ФЗоП") {
            fzopNums .= (fzopNums = "" ? "" : "+") . item.Num
        }

        term := GetArticleLicTerm(item)
        if (term >= 0) {
            hasLic := 1
            licYears += term
        }
        if (InStr(item.Sanction, "Арест") || InStr(item.Sanction, "арест")) {
            if (!InStr(extraNotes, "Арест"))
                extraNotes .= (extraNotes = "" ? "" : " + ") . "Арест"
        }
    }
}
artList := ""
if (koapNums != "")
    artList .= (artList = "" ? "" : " ") . koapNums . " КоАП"
if (ukNums != "")
    artList .= (artList = "" ? "" : " ") . ukNums . " УК"
if (pddNums != "")
    artList .= (artList = "" ? "" : " ") . pddNums . " ПДД"
if (fzopNums != "")
    artList .= (artList = "" ? "" : " ") . fzopNums . " ФЗоП"

overArtList := ""
if (overKoapNums != "")
    overArtList .= (overArtList = "" ? "" : " ") . overKoapNums . " КоАП"
if (overUkNums != "")
    overArtList .= (overArtList = "" ? "" : " ") . overUkNums . " УК"
if (overArtList = "")
    overArtList := artList

; Лимит штрафа ГИБДД на MTA Province — 100.000 рублей
cappedFine := (totalFine > 100000) ? 100000 : totalFine
overflowFine := (totalFine > 100000) ? (totalFine - 100000) : 0
if (overflowFine > 100000)
    overflowFine := 100000

if (licYears > 5)
    licYears := 5

if (hasLic) {
    licNote := (licYears = 0) ? "Лишение ВУ (0 — переобучение)" : ("Лишение ВУ: " . licYears . " г.")
    extraNotes := licNote . (extraNotes != "" ? " + " . extraNotes : "")
}

tid := (CalcTargetID != "") ? CalcTargetID : (LastTargetID != "" ? LastTargetID : "ID")
if (countSel = 0) {
    GuiControl, 5:, CalcSummaryText, Выбрано статей: 0  |  Итого штраф: 0 руб. (лимит /tsu — 100.000 руб.)
    GuiControl, 5:, CalcReadyCmd, /tsu %tid% 0 [Статьи не выбраны]
    GuiControl, 5:, CalcReadyOverflowCmd, [Сумма не превышает 100.000 руб.]
    GuiControl, 5:, CalcReadyLicCmd, /takecarlic %tid% [Нет лишения]
} else {
    fineInfo := (totalFine > 100000) ? ("100000 + " . (totalFine - 100000) . " руб. (всего " . totalFine . ")") : (cappedFine . " руб.")
    noteStr := (extraNotes != "") ? "  |  ⚠️ " . extraNotes : ""
    GuiControl, 5:, CalcSummaryText, % "Выбрано: " . countSel . " (" . artList . ")  |  💰 ШТРАФ: " . fineInfo . noteStr
    GuiControl, 5:, CalcReadyCmd, % "/tsu " . tid . " " . cappedFine . " " . artList
    if (totalFine > 100000)
        GuiControl, 5:, CalcReadyOverflowCmd, % "/tsu " . tid . " " . overflowFine . " " . overArtList
    else
        GuiControl, 5:, CalcReadyOverflowCmd, [Сумма не превышает 100.000 руб.]

    if (hasLic)
        GuiControl, 5:, CalcReadyLicCmd, % "/takecarlic " . tid . " " . licYears
    else
        GuiControl, 5:, CalcReadyLicCmd, /takecarlic %tid% [Нет лишения]
}
Return

CalcCopyOverflow:
Gui, 5:Submit, NoHide
if (InStr(CalcReadyOverflowCmd, "[Сумма не превышает")) {
    MsgBox, 48, Калькулятор УГИБДД, Сумма выбранных статей не превышает 100.000 рублей — весь штраф помещается в первую команду /tsu!
    Return
}
Clipboard := CalcReadyOverflowCmd
TrayTip, Калькулятор УГИБДД, Остаток штрафа скопирован:`n%CalcReadyOverflowCmd%, 2, 1
Return

CalcSendOverflow:
Gui, 5:Submit, NoHide
if (InStr(CalcReadyOverflowCmd, "[Сумма не превышает")) {
    MsgBox, 48, Калькулятор УГИБДД, Сумма выбранных статей не превышает 100.000 рублей!
    Return
}
Gui, 5:Hide
Sleep 250
SendMessage, 0x50,, 0x4190419,, A
SetCapsOff()
Send, {F6}
SmartSleep(200)
Send, %CalcReadyOverflowCmd%{Space}
Return

CalcClearChecks:
SelectedArticlesMap := {}
Gui, 5:Submit, NoHide
PopulateCalcListView(CalcSearchQuery, CalcCodeFilter)
Return

CalcCopyTsu:
Gui, 5:Submit, NoHide
Clipboard := CalcReadyCmd
TrayTip, Калькулятор УГИБДД, Скопировано в буфер обмена:`n%CalcReadyCmd%, 2, 1
Return

CalcCopyLic:
Gui, 5:Submit, NoHide
Clipboard := CalcReadyLicCmd
TrayTip, Калькулятор УГИБДД, Скопировано в буфер обмена:`n%CalcReadyLicCmd%, 2, 1
Return

CalcPlayAndLic:
Gui, 5:Submit, NoHide
if (InStr(CalcReadyLicCmd, "[Нет лишения]")) {
    MsgBox, 48, Калькулятор УГИБДД, В выбранных статьях нет лишения ВУ (либо впишите срок вручную в поле «Лишение ВУ»)!
    Return
}
Gui, 5:Hide
Sleep 250
SendMessage, 0x50,, 0x4190419,, A
SetCapsOff()
Send, {F6}
SmartSleep(250)
Send, /me открыл%ok1% базу данных и зашёл во вкладку "Аннулирование ВУ"{Enter}{F6}
SmartSleep(500)
Send, /me вн%ok9% данные гражданина и срок лишения, после чего нажал%ok1% "Аннулировать"{Enter}{F6}
SmartSleep(500)
Send, /do Информация о недействительности ВУ внесена в базу данных.{Enter}{F6}
SmartSleep(500)
Send, Ваши права больше недействительны. Идите на пересдачу в автошколу{!}{Enter}{F6}
SmartSleep(350)
Send, %CalcReadyLicCmd%{Space}
LogJournalAction("Лишение ВУ", tid, "Срок: " . licYears . " г.", 0)
TriggerSmartScreenshot("Аннулирование ВУ")
Return

CalcSpeakArticles:
Gui, 5:Submit, NoHide
toSpeak := []
for idx, item in ArticlesDB {
    if (SelectedArticlesMap.HasKey(item.Cmd))
        toSpeak.Push(item)
}
if (toSpeak.MaxIndex() = "" || toSpeak.MaxIndex() = 0) {
    Gui, 5:Default
    Gui, 5:ListView, CalcLV
    selRow := LV_GetNext(0)
    if (selRow > 0) {
        LV_GetText(selCmd, selRow, 3)
        for idx, item in ArticlesDB {
            if (item.Cmd = selCmd)
                toSpeak.Push(item)
        }
    }
}
if (toSpeak.MaxIndex() = "" || toSpeak.MaxIndex() = 0) {
    MsgBox, 48, Калькулятор УГИБДД, Отметьте галочкой или выделите хотя бы одну статью!
    Return
}
Gui, 5:Hide
Sleep 350
SendMessage, 0x50,, 0x4190419,, A
SetCapsOff()
for idx, art in toSpeak {
    parts := StrSplit(art.RawLines, "||")
    for pIdx, lineText in parts {
        Send, {F6}
        SmartSleep(350)
        Send, %lineText%{Enter}
        SmartSleep(1800)
    }
}
Return

CalcPlayAndTsu:
Gui, 5:Submit, NoHide
if (InStr(CalcReadyCmd, "[Статьи не выбраны]")) {
    MsgBox, 48, Калькулятор УГИБДД, Сначала отметьте галочками статьи КоАП для расчёта штрафа!
    Return
}
Gui, 5:Hide
Sleep 250
SendMessage, 0x50,, 0x4190419,, A
SetCapsOff()
Send, {F6}
Sleep 250
Send, /me открыл%ok1% базу данных и зашёл во вкладку "Фиксация нарушений"{Enter}{F6}
Sleep 500
Send, /me вн%ok9% данные о нарушении водителя в базу, затем нажал "Внести"{Enter}{F6}
Sleep 300
Send, /do Информация о штрафах введена в базу данных.{Enter}{F6}
Sleep 250
Send, %CalcReadyCmd%{Space}
LogJournalAction("Штраф", tid, artList, cappedFine)
TriggerSmartScreenshot("Выписка штрафа")
Return

; =================================================================================================
; ПУНКТ 3: ТАКТИЧЕСКИЙ HUD-ОВЕРЛЕЙ (ТАЙМЕРЫ ПОГОНИ/МЕГАФОНОВ, ДОКЛАДЫ, СМЕНА/БАЛЛЫ, DRAG&DROP) (GUI 6)
; =================================================================================================
global HudHwnd          := 0
global HudVisible       := 0
global HudEditMode      := 0
global HudPosX          := 0
global HudPosY          := 0
global DutyTotalSec     := 900
global ShiftStartTick   := 0

Bind_ResetChase:
StopChaseTimer()
Return


; =================================================================================================
; РАЗЪЯСНЕНИЯ СТАТЕЙ КОАП И УК РП (ОБЩИЕ ПОЛОЖЕНИЯ И ПРАВИЛА)
; =================================================================================================
:?:/коап1.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 1.1 КоАП, Задачами законодательства об административных правонарушениях{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, (далее – настоящий Кодекс) являются защита личности, охрана прав и{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, свобод человека и гражданина, охрана здоровья граждан,{Enter}
Return

:?:/коап1.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 1.2 КоАП, Лица, совершившие административное правонарушение, равны перед{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, законом. Они подлежат ответственности независимо от пола, расы,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, национальности, языка, происхождения, имущественного и должностного{Enter}
Return

:?:/коап1.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 1.3 КоАП, Лицо подлежит ответственности только за те административные{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, правонарушения, в отношении которых установлена его вина.{Enter}
Return

:?:/коап1.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 1.4 КоАП, Лицо, совершившее административное правонарушение, подлежит{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, ответственности на основании закона, действовавшего во время{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, совершения административного правонарушения.{Enter}
Return

:?:/коап2.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.1 КоАП, Административным правонарушением признается противоправное,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, виновное действие (бездействие) физического или юридического лица,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, за которое настоящим Кодексом установлена ответственность, также{Enter}
Return

:?:/коап2.1.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.1.1 КоАП, Рецидив преступлений влечет более строгое наказание на основании и{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, в пределах, предусмотренных настоящим Кодексом.{Enter}
Return

:?:/коап2.1.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.1.2 КоАП, Рецидивом преступления признается совершение преступления лицом{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, настоящего Кодекса, наказание за которое он уже получал, и оно{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, истекло менее, чем две недели назад.{Enter}
Return

:?:/коап2.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.2 КоАП, Существующие формы вины.{Enter}
Return

:?:/коап2.2.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.2.1 КоАП, Административное правонарушение признается совершенным умышленно,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, если лицо, его совершившее, сознавало противоправный характер своего{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, действия (бездействия), предвидело его вредные последствия и желало{Enter}
Return

:?:/коап2.2.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.2.2 КоАП, Административное правонарушение признается совершенным по{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, неосторожности, если лицо, его совершившее, предвидело возможность{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, наступления вредных последствий своего действия (бездействия), но{Enter}
Return

:?:/коап2.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.3 КоАП, При малозначительности совершенного административного{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, правонарушения сотрудник полиции может освободить лицо, совершившее{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, административное правонарушение, от административной ответственности{Enter}
Return

:?:/коап3.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 3.1 КоАП, Предупреждение – мера, выраженная в пресечении правонарушения лицом{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, без применения иных видов административных наказаний. После, если{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, результатов оно не повлекло, то есть лицо не направило свои действия{Enter}
Return

:?:/коап3.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 3.2 КоАП, Штраф является денежным взысканием, выражается в рублях и{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, устанавливается для граждан в размере, указанном в соответствующей{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, статье настоящего Кодекса.{Enter}
Return

:?:/коап3.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 3.3 КоАП, Лишение права на управление транспортным средством устанавливается{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, за грубое или систематическое нарушение порядка пользования этим{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, правом в случаях, предусмотренных статьями настоящего Кодекса.{Enter}
Return

:?:/коап3.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 3.4 КоАП, Административный арест заключается в содержании нарушителя в{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, условиях изоляции от общества и устанавливается и назначается лишь в{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, исключительных случаях за отдельные виды административных{Enter}
Return

:?:/коап4.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 4.1 КоАП, Наказание за совершение административного правонарушения{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, назначается в пределах, установленных законом, предусматривающим{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, ответственность за данное административное правонарушение, в{Enter}
Return

:?:/коап4.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 4.2 КоАП, При назначении наказания физическому лицу учитываются характер{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, совершенного им административного правонарушения, личность{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, виновного, его имущественное положение, обстоятельства, смягчающие{Enter}
Return

:?:/коап4.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 4.3 КоАП, Никто не может нести ответственность дважды за одно и то же{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, административное правонарушение подряд. Скрыть контент Служащий не{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, вправе суммировать штраф за нарушения одного и того же пункта{Enter}
Return

:?:/коап4.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 4.4 КоАП, Возмещение имущественного ущерба и морального вреда, причиненных{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, административным правонарушением.{Enter}
Return

:?:/коап4.4.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 4.4.1 КоАП, Уполномоченное лицо, рассматривая дело об административном{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, правонарушении, вправе при отсутствии спора о возмещении{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, имущественного ущерба одновременно с назначением наказания решить{Enter}
Return

:?:/коап4.4.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 4.4.2 КоАП, Споры о возмещении морального вреда, причиненного административным{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, правонарушением, рассматриваются на городском портале Республики{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, Провинция.{Enter}
Return

:?:/коап4.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 4.5 КоАП, Срок давности привлечения к административной ответственности{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, составляет 14 месяцев.{Enter}
Return

:?:/коап17.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 17.1 КоАП, Отстранение от управления транспортным средством,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, освидетельствование на состояние алкогольного опьянения и{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, медицинское освидетельствование на состояние опьянения.{Enter}
Return

:?:/укрп1.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 1.1 УКРП, Задачами законодательства об уголовных преступлениях (далее –{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, настоящий Кодекс) являются защита личности, охрана прав и свобод{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, человека и гражданина, охрана здоровья граждан,{Enter}
Return

:?:/укрп1.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 1.2 УКРП, Лица, совершившие уголовное преступление, равны перед законом. Они{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, подлежат ответственности независимо от пола, расы, национальности,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, языка, происхождения, имущественного и должностного положения, места{Enter}
Return

:?:/укрп1.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 1.3 УКРП, Лицо подлежит ответственности только за те уголовные преступления,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, в отношении которых установлена его вина.{Enter}
Return

:?:/укрп1.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 1.4 УКРП, Лицо, совершившее уголовное преступление, подлежит ответственности{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, на основании закона, действовавшего во время совершения данного{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, деяния.{Enter}
Return

:?:/укрп1.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 1.5 УКРП, Если имеется возможность выбора наказания за определенное нарушение{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, - сотрудник имеет право самостоятельно вынести решение.{Enter}
Return

:?:/укрп1.6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 1.6 УКРП, При совокупности преступлений лицо несет уголовную ответственность{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, за каждое совершенное преступление по соответствующей статье или{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, части статьи настоящего Кодекса.{Enter}
Return

:?:/укрп2.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.1 УКРП, Уголовным преступлением признается противоправное, виновное{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, действие (бездействие) физического лица, за которое настоящим{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, Кодексом следует ответственность.{Enter}
Return

:?:/укрп2.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.2 УКРП, Существующие формы вины:{Enter}
Return

:?:/укрп2.2.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.2.1 УКРП, Уголовное преступление признается совершенным умышленно, если лицо,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, его совершившее, сознавало противоправный характер своего действия{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, (бездействия), предвидело его вредные последствия и желало{Enter}
Return

:?:/укрп2.2.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.2.2 УКРП, Уголовное преступление признается совершенным по неосторожности,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, если лицо, его совершившее, предвидело возможность наступления{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, вредных последствий своего действия (бездействия), но без{Enter}
Return

:?:/укрп2.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.3 УКРП, Соучастие в совершении уголовного преступления, предусмотренного{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, настоящим Кодексом, прикрывательство, укрывательство преступника,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, является наказуемым и влечет такую же ответственность, которая бы{Enter}
Return

:?:/укрп2.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.4 УКРП, Срок давности привлечения к уголовной ответственности составляет 14{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, месяцев.{Enter}
Return

:?:/укрп2.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 2.5 УКРП, Нелегальные предметы, обнаруженные у задержанного, подлежат{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, конфискации.{Enter}
Return

:?:/укрп3.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 3.1 УКРП, Штраф является денежным взысканием, выражается в рублях и{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, устанавливается для граждан в размере, указанном в соответствующей{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, статье.{Enter}
Return

:?:/укрп3.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 3.2 УКРП, Арест – мера уголовного наказания, заключающаяся в содержании{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, нарушителя в условиях изоляции от общества, и устанавливается на{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, срок, предусмотренный статьями уголовного кодекса.{Enter}
Return


InitTimersAndLogReader() {
    global HudVisible, DutyType, DutyRemainSec, DutyTotalSec, ChaseActive, ChaseTotalSec, ChaseCooldownSec
    global LastTargetID, LastTryResult, LastTryTime, LastRadioAlert, LogLastSize
    global ShiftStartTick, HudEditMode
    HudVisible := 0
    HudEditMode := 0
    DutyType := "Нет"
    DutyRemainSec := 0
    DutyTotalSec := 900
    ChaseActive := 0
    ChaseStage := 0
    ChaseCooldownSec := 0
    ChaseTotalSec := 0
    LastTargetID := ""
    LastTryResult := "—"
    LastTryTime := 0
    LastRadioAlert := "Рация: ОК"
    LogLastSize := -1
    ShiftStartTick := A_TickCount

    ; Регистрация перемещения мыши для редактора HUD (Drag & Drop)
    OnMessage(0x0201, "WM_LBUTTONDOWN_HudDrag")

    CreateHudGui()
    SetTimer, UpdateHudTick, 1000
    SetTimer, ReadConsoleLogTail, 750
}

CreateHudGui() {
    global HudHwnd, HudPosX, HudPosY, HudEditMode
    global HudTitle, HudDutyTxt, HudDutyBar, HudChaseTxt, HudChaseBar, HudStatsTxt, HudLogTxt
    global Teg, Prop2

    iniPath := A_Temp . "\gibdd.egl"
    if (!FileExist(iniPath))
        iniPath := A_ScriptDir . "\gibdd_profile.ini"
    IniRead, savedX, %iniPath%, Settings, HudPosX, ERROR
    IniRead, savedY, %iniPath%, Settings, HudPosY, ERROR
    if (savedX = "ERROR" || savedX = "" || savedX < 0 || savedX > A_ScreenWidth - 50)
        HudPosX := A_ScreenWidth - 395
    else
        HudPosX := savedX + 0
    if (savedY = "ERROR" || savedY = "" || savedY < 0 || savedY > A_ScreenHeight - 50)
        HudPosY := 25
    else
        HudPosY := savedY + 0

    Gui, 6:Destroy
    Gui, 6:+AlwaysOnTop -Caption +ToolWindow +LastFound +HwndHudHwnd +E0x20
    Gui, 6:Color, 0E131F
    WinSet, Transparent, 225

    ; 1. Шапка HUD и позывной
    Gui, 6:Font, S9 C58A6FF Bold, Consolas
    callsignDisp := (Teg != "" ? Teg : "ДПС") . "-" . (Prop2 != "" ? Prop2 : "01")
    Gui, 6:Add, Text, x10 y6 w360 h16 vHudTitle, % "🚔 УГИБДД HUD [" . callsignDisp . "] | Alt+Shift+H: Двигать"

    ; 2. Шкала погони и мегафонов (Pursuit Tactical Bar)
    Gui, 6:Font, S8 CFFB84D Bold, Consolas
    Gui, 6:Add, Text, x10 y24 w360 h15 vHudChaseTxt, 🚨 Погоня: нет | Мегафон готов (^Space)
    Gui, 6:Add, Progress, x10 y41 w360 h6 Background161D2E c3FB950 Range0-15 vHudChaseBar, 15

    ; 3. Прогресс-бар дежурства / поста (Duty Progress HUD)
    Gui, 6:Font, S8 CE6EDF3 Bold, Consolas
    Gui, 6:Add, Text, x10 y50 w360 h15 vHudDutyTxt, ⏱ Дежурство: не активно (/п1 | /пост1)
    Gui, 6:Add, Progress, x10 y67 w360 h6 Background161D2E c58A6FF Range0-100 vHudDutyBar, 0

    ; 4. Смена и баллы нормы на форум (Shift & Forum Points OSD)
    Gui, 6:Font, S8 C7EE787 Bold, Consolas
    Gui, 6:Add, Text, x10 y76 w360 h15 vHudStatsTxt, ⭐ Смена: 00:00 | Штр: 0 | КПЗ: 0 | Лиш: 0 | Баллы: 0 / 20

    ; 5. Оперлог и захват цели
    Gui, 6:Font, S8 C79C0FF Norm, Consolas
    Gui, 6:Add, Text, x10 y93 w360 h15 vHudLogTxt, 📡 ID: [—] | TRY: [—] | Рация: ОК
}

ToggleHud:
if (HudVisible) {
    Gui, 6:Hide
    HudVisible := 0
} else {
    EnsureHudShown()
}
Return

EnsureHudShown() {
    global HudVisible, HudPosX, HudPosY, HudHwnd
    HudVisible := 1
    if (HudPosX = "" || HudPosX <= 0)
        HudPosX := A_ScreenWidth - 395
    if (HudPosY = "" || HudPosY <= 0)
        HudPosY := 25
    Gui, 6:Show, x%HudPosX% y%HudPosY% w380 h118 NoActivate, UGIBDD_HUD_OVERLAY
    Gosub, UpdateHudTick
}

ToggleHudEditMode:
HudEditMode := !HudEditMode
EnsureHudShown()
if (HudEditMode) {
    ; В режиме редактирования снимаем сквозной клик и меняем фон
    Gui, 6:-E0x20
    Gui, 6:Color, 182642
    WinSet, Transparent, 245, ahk_id %HudHwnd%
    GuiControl, 6:, HudTitle, 🎯 [РЕДАКТОР] Зажмите ЛКМ и перетащите HUD
    SoundBeep, 850, 120
    TrayTip, 🎯 Режим перемещения HUD, Зажмите ЛКМ на панели HUD и перетащите её мышкой.`nПовторите Alt+Shift+H для сохранения., 4, 1
} else {
    ; Сохраняем координаты и возвращаем сквозной клик (+E0x20)
    Gui, 6:+E0x20
    Gui, 6:Color, 0E131F
    WinSet, Transparent, 225, ahk_id %HudHwnd%
    WinGetPos, curX, curY,,, ahk_id %HudHwnd%
    if (curX != "" && curY != "") {
        HudPosX := curX
        HudPosY := curY
        for idx, iniPath in [A_Temp . "\gibdd.egl", A_ScriptDir . "\gibdd_profile.ini"] {
            IniWrite, %HudPosX%, %iniPath%, Settings, HudPosX
            IniWrite, %HudPosY%, %iniPath%, Settings, HudPosY
        }
    }
    callsignDisp := (Teg != "" ? Teg : "ДПС") . "-" . (Prop2 != "" ? Prop2 : "01")
    GuiControl, 6:, HudTitle, % "🚔 УГИБДД HUD [" . callsignDisp . "] | Alt+Shift+H: Двигать"
    SoundBeep, 1200, 150
    TrayTip, 📍 Положение HUD сохранено, % "Координаты: X=" . HudPosX . ", Y=" . HudPosY, 3, 1
}
Return

WM_LBUTTONDOWN_HudDrag(wParam, lParam, msg, hwnd) {
    global HudHwnd, HudEditMode
    if (HudEditMode && hwnd = HudHwnd) {
        PostMessage, 0xA1, 2,,, ahk_id %hwnd% ; WM_NCLBUTTONDOWN, HTCAPTION
    }
}

StartDutyTimer(ModeName, DurationSec) {
    global DutyType, DutyRemainSec, DutyTotalSec
    DutyType := ModeName
    DutyRemainSec := DurationSec
    DutyTotalSec := (DurationSec > 0) ? DurationSec : 900
    EnsureHudShown()
    Gosub, UpdateHudTick
}

StopDutyTimer() {
    global DutyType, DutyRemainSec, DutyTotalSec
    DutyType := "Нет"
    DutyRemainSec := 0
    DutyTotalSec := 900
    Gosub, UpdateHudTick
}

StartChaseTimer(StageNum) {
    global ChaseActive, ChaseStage, ChaseCooldownSec, ChaseTotalSec
    ChaseStage := StageNum
    ChaseCooldownSec := 15
    if (!ChaseActive) {
        ChaseActive := 1
        ChaseTotalSec := 180
    }
    EnsureHudShown()
    Gosub, UpdateHudTick
}

StopChaseTimer() {
    global ChaseActive, ChaseCooldownSec, ChaseTotalSec
    ChaseActive := 0
    ChaseCooldownSec := 0
    ChaseTotalSec := 0
    Gosub, UpdateHudTick
}

FormatMMSS(Seconds) {
    if (Seconds < 0)
        Seconds := 0
    m := Floor(Seconds / 60)
    s := Mod(Seconds, 60)
    return Format("{:02}:{:02}", m, s)
}

UpdateHudTick:
; 1. Доклад / Патруль
if (DutyType != "Нет") {
    if (DutyRemainSec > 0) {
        DutyRemainSec--
        if (DutyRemainSec = 120) {
            SoundBeep, 800, 120
            TrayTip, ⏱️ Доклад через 2 минуты, % "Внимание: пора подготовиться к докладу (" . DutyType . ")!", 2, 1
        } else if (DutyRemainSec = 60) {
            SoundBeep, 900, 150
        } else if (DutyRemainSec = 0) {
            SoundBeep, 1200, 250
            SoundBeep, 1400, 250
            TrayTip, ⚠️ ВРЕМЯ ДОКЛАДА!, % "Пора сделать доклад в рацию (/п2 или /пост2)!", 4, 2
        }
    }
    if (DutyRemainSec > 0) {
        dutyTxt := "⏱ " . DutyType . ": доклад через " . FormatMMSS(DutyRemainSec)
    } else {
        dutyTxt := "⚠️ " . DutyType . ": ПОРА ДОЛОЖИТЬ (/п2 | /пост2)!"
    }
    if (DutyTotalSec > 0) {
        elapsedSec := DutyTotalSec - DutyRemainSec
        dutyPct := Floor((elapsedSec / DutyTotalSec) * 100)
        if (dutyPct < 0)
            dutyPct := 0
        if (dutyPct > 100)
            dutyPct := 100
        GuiControl, 6:, HudDutyBar, %dutyPct%
        if (DutyRemainSec <= 120 && DutyRemainSec > 0)
            GuiControl, 6:+cFFB84D, HudDutyBar
        else if (DutyRemainSec = 0)
            GuiControl, 6:+cE74C3C, HudDutyBar
        else
            GuiControl, 6:+c58A6FF, HudDutyBar
    }
} else {
    dutyTxt := "⏱ Дежурство: не активно (/п1 | /пост1)"
    GuiControl, 6:, HudDutyBar, 0
}

; 2. Погоня и Мегафоны
if (ChaseActive) {
    if (ChaseCooldownSec > 0) {
        ChaseCooldownSec--
        if (ChaseCooldownSec = 0)
            SoundBeep, 1000, 180
    }
    if (ChaseTotalSec > 0) {
        ChaseTotalSec--
        if (ChaseTotalSec = 0) {
            SoundBeep, 1500, 300
            TrayTip, 🔥 ЖЁЛТЫЙ СТАТУС ПОГОНИ!, % "3 минуты погони истекли! Разрешён огонь по колёсам ТС (ст. 15 ФЗоП)!", 4, 2
        }
    }
    cdStr := (ChaseCooldownSec > 0) ? ("КД: " . ChaseCooldownSec . "с [ЖДИ]") : "ГОТОВ К ВЫДАЧЕ!"
    stStr := (ChaseTotalSec > 0) ? ("Белый " . FormatMMSS(ChaseTotalSec)) : "🔥 ЖЁЛТЫЙ (ОГОНЬ)!"
    chaseTxt := "🚨 Пред " . ChaseStage . "/3 | " . cdStr . " | " . stStr

    if (ChaseCooldownSec > 0) {
        GuiControl, 6:+cE74C3C, HudChaseBar
        GuiControl, 6:, HudChaseBar, % 15 - ChaseCooldownSec
    } else {
        GuiControl, 6:+c3FB950, HudChaseBar
        GuiControl, 6:, HudChaseBar, 15
    }
} else {
    chaseTxt := "🚨 Погоня: нет | Мегафон готов (^Space | Alt+0)"
    GuiControl, 6:+c3FB950, HudChaseBar
    GuiControl, 6:, HudChaseBar, 15
}

; 3. Смена и баллы нормы OSD
shiftElapsed := Floor((A_TickCount - ShiftStartTick) / 1000)
shiftHours := Floor(shiftElapsed / 3600)
shiftMins := Floor(Mod(shiftElapsed, 3600) / 60)
shiftFmt := Format("{:02}:{:02}", shiftHours, shiftMins)

fCount := 0
aCount := 0
lCount := 0
rCount := 0
for idx, item in JournalEntries {
    if (InStr(item.Type, "Штраф"))
        fCount++
    else if (InStr(item.Type, "Арест"))
        aCount++
    else if (InStr(item.Type, "Лишение"))
        lCount++
    else if (InStr(item.Type, "Доклад") || InStr(item.Type, "Рация") || InStr(item.Type, "Пост") || InStr(item.Type, "Патруль"))
        rCount++
}
forumPoints := (fCount * 1) + (aCount * 3) + (lCount * 2) + (rCount * 1)
statsTxt := "⭐ Смена: " . shiftFmt . " | Штр: " . fCount . " | КПЗ: " . aCount . " | Лиш: " . lCount . " | Баллы: " . forumPoints . " / 20"

; 4. Оперлог и цель
idDisp := (LastTargetID != "") ? LastTargetID : "—"
logTxt := "📡 ID: [" . idDisp . "] | TRY: " . LastTryResult . " | " . LastRadioAlert

if (HudVisible) {
    GuiControl, 6:, HudDutyTxt, %dutyTxt%
    GuiControl, 6:, HudChaseTxt, %chaseTxt%
    GuiControl, 6:, HudStatsTxt, %statsTxt%
    GuiControl, 6:, HudLogTxt, %logTxt%
    LiveShiftDuration := shiftFmt
    LiveForumPoints := forumPoints
    LiveFinesCount := fCount
    LiveArrestsCount := aCount
    LiveTargetId := idDisp
}
SyncFluentLiveTelemetry(idDisp, DutyType, FormatMMSS(DutyRemainSec), (DutyType != "Нет" && DutyTotalSec > 0) ? dutyPct : 0, ChaseActive ? ("Пред " . ChaseStage . "/3 (" . (ChaseCooldownSec > 0 ? ChaseCooldownSec . "с" : "ГОТОВ") . ")") : "Готов (^Space)", ChaseActive ? Floor(((15 - ChaseCooldownSec) / 15) * 100) : 100, shiftFmt, forumPoints, fCount, aCount, lCount, rCount)
Return

ResolveConsoleLogPath() {
    global ProvLogPath
    if (ProvLogPath != "" && ProvLogPath != "AUTO" && ProvLogPath != "ERROR") {
        if (InStr(ProvLogPath, "console.log") && FileExist(ProvLogPath))
            return ProvLogPath
        cand := RTrim(ProvLogPath, "\/") . "\console.log"
        if (FileExist(cand))
            return cand
    }
    candidates := ["C:\Program Files (x86)\MTA San Andreas 1.6\MTA\logs\console.log"
        , "D:\MTA San Andreas 1.6\MTA\logs\console.log"
        , "C:\MTA Province\MTA\logs\console.log"
        , "D:\MTA Province\MTA\logs\console.log"
        , "E:\MTA Province\MTA\logs\console.log"
        , "C:\Games\MTA Province\MTA\logs\console.log"
        , "D:\Games\MTA Province\MTA\logs\console.log"]
    for idx, path in candidates {
        if (FileExist(path))
            return path
    }
    return ""
}

ReadLogTailString(LogFilePath, MaxBytes := 4096) {
    file := FileOpen(LogFilePath, "r-d", "UTF-8-RAW")
    if !IsObject(file)
        return ""
    len := file.Length
    if (len > MaxBytes)
        file.Seek(-MaxBytes, 2)
    else
        file.Seek(0, 0)
    txt := file.Read()
    file.Close()
    return txt
}

ReadConsoleLogTail:
LogFile := ResolveConsoleLogPath()
if (LogFile = "" || !FileExist(LogFile))
    Return
try {
    ; Открываем файл строго для совместного чтения (без флага -d), чтобы исключить sharing violation у MTA
    fileObj := FileOpen(LogFile, "r", "UTF-8-RAW")
if !IsObject(fileObj)
    Return
curSize := fileObj.Length
if (LogLastSize < 0) {
    startPos := (curSize > 2048) ? (curSize - 2048) : 0
    fileObj.Seek(startPos, 0)
    newChunk := fileObj.Read()
    LogLastSize := curSize
    fileObj.Close()
} else if (curSize > LogLastSize) {
    readBytes := curSize - LogLastSize
    if (readBytes > 8192)
        readBytes := 8192
    fileObj.Seek(-readBytes, 2)
    newChunk := fileObj.Read()
    LogLastSize := curSize
    fileObj.Close()
} else {
    if (curSize < LogLastSize)
        LogLastSize := curSize
    fileObj.Close()
    Return
}

if (newChunk != "") {
    Loop, Parse, newChunk, `n, `r
    {
        line := A_LoopField
        if (line = "")
            continue
        if (RegExMatch(line, "[\[\(]([0-9]{1,4})[\]\)]", mId)) {
            LastTargetID := mId1
        }
        if (InStr(line, "Удачно") || InStr(line, "[Удачно]")) {
            LastTryResult := "УДАЧНО ✅"
            LastTryTime := A_TickCount
        } else if (InStr(line, "Неудачно") || InStr(line, "[Неудачно]")) {
            LastTryResult := "НЕУДАЧНО ❌"
            LastTryTime := A_TickCount
        }
        callSign := Teg . "-" . Prop2
        if ((InStr(line, "[R]") || InStr(line, "[F]") || InStr(line, "раци")) && (InStr(line, "Контроль") || InStr(line, "контроль") || (Prop2 != "000" && InStr(line, callSign)))) {
            LastRadioAlert := "📻 ВЫЗОВ!"
            SoundBeep, 1300, 180
        }
    }
    Gosub, UpdateHudTick
}
} catch {
    Return
}
Return

; =================================================================================================
; ФУНКЦИИ ПОИСКА БИНДОВ (ВКЛАДКА 6 GUI 1) И БАЗЫ ДАННЫХ
; =================================================================================================
FilterBindsList:
Gui, 1:Submit, NoHide
PopulateBindsListView(BindSearchQuery, BindCatFilter)
Return

PopulateBindsListView(Query := "", CatFilter := "Все категории") {
    global BindsDB
    Gui, 1:Default
    Gui, 1:ListView, BindsLV
    LV_Delete()
    GuiControl, 1:-Redraw, BindsLV
    q := Format("{:L}", Trim(Query))
    shown := 0
    for idx, b in BindsDB {
        if (CatFilter != "" && CatFilter != "Все категории" && b.Cat != CatFilter)
            continue
        if (q != "") {
            hay := Format("{:L}", b.Key . " " . b.Cat . " " . b.Desc)
            if (!InStr(hay, q))
                continue
        }
        LV_Add("", b.Key, b.Cat, b.Desc)
        shown++
    }
    LV_ModifyCol(1, 165)
    LV_ModifyCol(2, 195)
    LV_ModifyCol(3, 515)
    GuiControl, 1:+Redraw, BindsLV
    GuiControl, 1:, BindsSearchStatus, % "🔎 Найдено команд и статей: " . shown . "  |  Двойной клик по строке копирует команду в буфер обмена!"
}

BindsLVAction:
Gui, 1:Default
Gui, 1:ListView, BindsLV
if (A_GuiEvent = "DoubleClick" && A_EventInfo > 0) {
    LV_GetText(selKey, A_EventInfo, 1)
    LV_GetText(selCat, A_EventInfo, 2)
    LV_GetText(selDesc, A_EventInfo, 3)
    Clipboard := selKey
    TrayTip, Скопировано: %selKey%, %selCat%`n%selDesc%, 2, 1
}
Return

AddBindCatalog(KeyStr, CatStr, DescStr) {
    global BindsDB
    BindsDB.Push({Key: KeyStr, Cat: CatStr, Desc: DescStr})
}

AddArticleDB(CodeStr, NumStr, CmdStr, FineNum, SanctionStr, DescStr, RawLinesStr) {
    global ArticlesDB
    ArticlesDB.Push({Code: CodeStr, Num: NumStr, Cmd: CmdStr, Fine: FineNum, Sanction: SanctionStr, Desc: DescStr, RawLines: RawLinesStr})
}

InitBindsCatalog() {
    global BindsDB, ArticlesDB, HotkeyDefs
    BindsDB := []
    ; Все настраиваемые горячие клавиши с актуальными значениями пользователя
    for idx, hk in HotkeyDefs {
        catName := (hk.Cat = "Задержание" || hk.Cat = "КПК") ? "Задержание и Розыск" : "Основное"
        AddBindCatalog(FormatHotkeyReadable(hk.CurrentKey), catName, hk.Name . " (настраиваемая клавиша)")
    }

    ; Текстовые команды — Основное
    AddBindCatalog("/фкар", "Основное", "Пробить владельца автомобиля по гос. номеру (/findcar)")
    AddBindCatalog("/ударкалаш", "Основное", "Разбить окно автомобиля прикладом АК-74М (/try)")
    AddBindCatalog("/ударпистолет", "Основное", "Разбить окно автомобиля рукоятью пистолета (/try)")
    AddBindCatalog("/удардробовик", "Основное", "Разбить окно автомобиля прикладом дробовика (/try)")
    AddBindCatalog("/разбор1 | /разбор2", "Основное", "Неполная разборка (/разбор1) и сборка (/разбор2) автомата АК-74М")
    AddBindCatalog("/таум1 .. /таум6", "Основное", "Измерение светопропускаемости стёкол (тонировки) прибором «Тауметр»")
    AddBindCatalog("/доктаум1 .. /доктаум4", "Основное", "Предоставление сертификата и документов на прибор «Тауметр»")
    AddBindCatalog("/рег1 .. /рег4", "Основное", "Показ записи нарушения с видеорегистратора гражданину")
    AddBindCatalog("/алко1..5, /алко+, /алко-", "Основное", "Проверка водителя на состояние опьянения алкотестером")
    AddBindCatalog("/докалко1 .. /докалко4", "Основное", "Предоставление документов на алкотестер")
    AddBindCatalog("/дтп1 .. /дтп3, /дтпкам", "Основное", "Фотофиксация места ДТП, замер тормозного пути рулеткой, составление схемы, камеры")
    AddBindCatalog("/камера", "Основное", "Отыгровка нагрудного видеорегистратора DOZOR")
    AddBindCatalog("/окно+, /окно-, /окно?, /стук", "Основное", "Отыгровки состояния окна автомобиля и стука в стекло")
    AddBindCatalog("/дверь+, /дверь-", "Основное", "Отыгровки открытой и запертой двери автомобиля")

    ; Доклады и Рация
    AddBindCatalog("/п1, /п2, /п3", "Доклады и Рация", "Выезд, продолжение и окончание патруля (автозапуск таймера 15 минут)")
    AddBindCatalog("/вп1, /вп2, /вп3", "Доклады и Рация", "Воздушное патрулирование в /d (автозапуск таймера 15 минут)")
    AddBindCatalog("/пост1, /пост2, /пост3", "Доклады и Рация", "Заступление, продолжение и сдача стационарного поста (автозапуск таймера 20 минут)")
    AddBindCatalog("/обл1, /обл2, /обл3", "Доклады и Рация", "Областное патрулирование в /ro (автозапуск таймера 15 минут)")
    AddBindCatalog("/рейд1, /рейд2, /рейд3", "Доклады и Рация", "Доклады о начале, продолжении и окончании рейда в /d")
    AddBindCatalog("/в1, /в2, /в+, /в-", "Доклады и Рация", "Доклады по обработке вызова (выехал, прибыл, обработан, ложный)")
    AddBindCatalog("/дттп1, /дттп2", "Доклады и Рация", "Доклады в рацию об оформлении ДТП")
    AddBindCatalog("/он1, /он2", "Доклады и Рация", "Доклады в рацию об оформлении правонарушения")
    AddBindCatalog("/sos", "Доклады и Рация", "Активация тревожной кнопки SOS с GPS-маячком в /ro")
    AddBindCatalog("/гун, /13п, /13м, /13н, /13уп, /13ум, /13ун", "Доклады и Рация", "Запросы МВД (кто примет задержанного) и ответы 10-13 по городам")
    AddBindCatalog("/код0, /код1, /пр1", "Доклады и Рация", "Экстренные коды и подтверждение принятия в /ro")
    AddBindCatalog("/мвд, /угибдд, /ржд, /мз, /мо, /цгбп, /окбм, /цгбн", "Доклады и Рация", "Вызов государственных структур на связь в общий канал /ro")
    AddBindCatalog("/прозыск, /пмедкарта, /зосн", "Доклады и Рация", "Запросы по базе розыска, медкарте и ОСН")

    ; Задержание и Розыск
    AddBindCatalog("/вытащить", "Задержание и Розыск", "Вытащить задержанного из патрульного автомобиля")
    AddBindCatalog("/кпкфото", "Задержание и Розыск", "Сфотографировать гражданина и пробить по базе розыска (/wanted + /crimrec)")
    AddBindCatalog("/маска, /убор, /очки, /шлем", "Задержание и Розыск", "Снятие аксессуаров с задержанного для опознания личности")
    AddBindCatalog("/метка1, /метка2, /копия, /зкопия", "Задержание и Розыск", "Пометки об отказе от подписи и вручение копии протокола")

    ; СС, Лекции и Собес
    AddBindCatalog("/лекция1 .. /лекция23", "СС, Лекции и Собес", "Проведение всех 23 лекций для личного состава УГИБДД")
    AddBindCatalog("/собес1 .. /собес18, /помощьсобес, /отказ", "СС, Лекции и Собес", "Проведение I и II этапов собеседования, проверка документов и РП-терминов")
    AddBindCatalog("/пасс1, /труд1, /диплом1, /ву1, /карта1, /вб1", "СС, Лекции и Собес", "Отыгровки проверки документов на собеседовании")
    AddBindCatalog("/выдформу, /выдпогоны, /кпкпринятие, /кпкповышение, /кпкпонижение, /кпкувал", "СС, Лекции и Собес", "Команды Старшего Состава (выдача формы, погон, принятие, повышение, увольнение)")

    ; ПМП
    AddBindCatalog("/пмп1 .. /пмп6", "ПМП", "Базовый комплекс Первой Медицинская Помощи (аптечка, осмотр, пульс, нашатырь)")
    AddBindCatalog("/массаж, /пульс-", "ПМП", "Непрямой массаж сердца и сердечно-лёгочная реанимация")
    AddBindCatalog("/оранения, /пулевое, /переломз, /переломо, /ушиб, /кровь, /ожог", "ПМП", "Оказание ПМП при переломах, кровотечениях, пулевых ранениях, ушибах и ожогах")

    ; Все 127 статей КоАП / УКРП / ПДД / ФЗоП
    for idx, art in ArticlesDB {
        AddBindCatalog(art.Cmd, "Статьи КоАП/УКРП/ПДД/ФЗоП", "[" . art.Code . " " . art.Num . " | " . art.Sanction . "] " . art.Desc)
    }
}


InitArticlesDB() {
    global ArticlesDB, SelectedArticlesMap
    ArticlesDB := []
    SelectedArticlesMap := {}
    AddArticleDB("КоАП", "1.1", "/коап1.1", 0, "Разъяснение нормы", "Задачами законодательства об административных правонарушениях (далее – настоящий Кодекс) являются защита личности, охрана прав и свобод человека и гражданина, охрана здоровья граждан, санитарно-эпидемиологического благополучия населения, защита общественной нравственности, охрана окружающей среды, установленного порядка осуществления государственной власти, общественного порядка и общественной безопасности, собственности, защита законных экономических интересов физических и юридических лиц, общества и государства от административных правонарушений, а также предупреждение административных правонарушений. За соблюдением кодекса следят все служащие Министерства внутренних дел.", "Согласно ст. 1.1 КоАП, Задачами законодательства об административных правонарушениях (далее – настоящий Кодекс) являются защита личности, охрана прав и свобод человека и гражданина, о")
    AddArticleDB("КоАП", "1.2", "/коап1.2", 0, "Разъяснение нормы", "Лица, совершившие административное правонарушение, равны перед законом. Они подлежат ответственности независимо от пола, расы, национальности, языка, происхождения, имущественного и должностного положения, места жительства, отношения к религии, убеждений, принадлежности к общественным объединениям, а также других обстоятельств. Незнание закона не освобождает лицо от ответственности.", "Согласно ст. 1.2 КоАП, Лица, совершившие административное правонарушение, равны перед законом. Они подлежат ответственности независимо от пола, расы, национальности, языка, происхожде")
    AddArticleDB("КоАП", "1.3", "/коап1.3", 0, "Разъяснение нормы", "Лицо подлежит ответственности только за те административные правонарушения, в отношении которых установлена его вина.", "Согласно ст. 1.3 КоАП, Лицо подлежит ответственности только за те административные правонарушения, в отношении которых установлена его вина")
    AddArticleDB("КоАП", "1.4", "/коап1.4", 0, "Разъяснение нормы", "Лицо, совершившее административное правонарушение, подлежит ответственности на основании закона, действовавшего во время совершения административного правонарушения.", "Согласно ст. 1.4 КоАП, Лицо, совершившее административное правонарушение, подлежит ответственности на основании закона, действовавшего во время совершения административного правонаруш")
    AddArticleDB("КоАП", "2.1", "/коап2.1", 0, "Разъяснение нормы", "Административным правонарушением признается противоправное, виновное действие (бездействие) физического или юридического лица, за которое настоящим Кодексом установлена ответственность, также почти везде описанная и в Правилах дорожного движения.", "Согласно ст. 2.1 КоАП, Административным правонарушением признается противоправное, виновное действие (бездействие) физического или юридического лица, за которое настоящим Кодексом уст")
    AddArticleDB("КоАП", "2.1.1", "/коап2.1.1", 0, "Разъяснение нормы", "Рецидив преступлений влечет более строгое наказание на основании и в пределах, предусмотренных настоящим Кодексом.", "Согласно ст. 2.1.1 КоАП, Рецидив преступлений влечет более строгое наказание на основании и в пределах, предусмотренных настоящим Кодексом")
    AddArticleDB("КоАП", "2.1.2", "/коап2.1.2", 0, "Разъяснение нормы", "Рецидивом преступления признается совершение преступления лицом настоящего Кодекса, наказание за которое он уже получал, и оно истекло менее, чем две недели назад.", "Согласно ст. 2.1.2 КоАП, Рецидивом преступления признается совершение преступления лицом настоящего Кодекса, наказание за которое он уже получал, и оно истекло менее, чем две недели наз")
    AddArticleDB("КоАП", "2.2", "/коап2.2", 0, "Разъяснение нормы", "Существующие формы вины.", "Согласно ст. 2.2 КоАП, Существующие формы вины")
    AddArticleDB("КоАП", "2.2.1", "/коап2.2.1", 0, "Разъяснение нормы", "Административное правонарушение признается совершенным умышленно, если лицо, его совершившее, сознавало противоправный характер своего действия (бездействия), предвидело его вредные последствия и желало наступления таких последствий или сознательно их допускало, либо относилось к ним безразлично.", "Согласно ст. 2.2.1 КоАП, Административное правонарушение признается совершенным умышленно, если лицо, его совершившее, сознавало противоправный характер своего действия (бездействия), п")
    AddArticleDB("КоАП", "2.2.2", "/коап2.2.2", 0, "Разъяснение нормы", "Административное правонарушение признается совершенным по неосторожности, если лицо, его совершившее, предвидело возможность наступления вредных последствий своего действия (бездействия), но без достаточных к тому оснований самонадеянно рассчитывало на предотвращение таких последствий, либо не предвидело возможности наступления таких последствий, хотя должно было и могло их предвидеть.", "Согласно ст. 2.2.2 КоАП, Административное правонарушение признается совершенным по неосторожности, если лицо, его совершившее, предвидело возможность наступления вредных последствий сво")
    AddArticleDB("КоАП", "2.3", "/коап2.3", 0, "Разъяснение нормы", "При малозначительности совершенного административного правонарушения сотрудник полиции может освободить лицо, совершившее административное правонарушение, от административной ответственности и ограничиться устным замечанием.", "Согласно ст. 2.3 КоАП, При малозначительности совершенного административного правонарушения сотрудник полиции может освободить лицо, совершившее административное правонарушение, от ад")
    AddArticleDB("КоАП", "3.1", "/коап3.1", 0, "Разъяснение нормы", "Предупреждение – мера, выраженная в пресечении правонарушения лицом без применения иных видов административных наказаний. После, если результатов оно не повлекло, то есть лицо не направило свои действия на устранение нарушения или отказалось в их пресечении со своей стороны, применяются иные виды административных наказаний. Предупреждение выносится в устной или письменной форме с просьбой лицу прекратить совершать тот или иной проступок, за который будет положена иная мера административной ответственности. Неисполнение требований, оговоренных в предупреждении, лицом могут приравниваться к неподчинению, на усмотрение служащего Министерства внутренних дел, и наказывается соответствующей статьей Уголовного Кодекса.", "Согласно ст. 3.1 КоАП, Предупреждение – мера, выраженная в пресечении правонарушения лицом без применения иных видов административных наказаний. После, если результатов оно не повлекл")
    AddArticleDB("КоАП", "3.2", "/коап3.2", 0, "Разъяснение нормы", "Штраф является денежным взысканием, выражается в рублях и устанавливается для граждан в размере, указанном в соответствующей статье настоящего Кодекса.", "Согласно ст. 3.2 КоАП, Штраф является денежным взысканием, выражается в рублях и устанавливается для граждан в размере, указанном в соответствующей статье настоящего Кодекса")
    AddArticleDB("КоАП", "3.3", "/коап3.3", 0, "Разъяснение нормы", "Лишение права на управление транспортным средством устанавливается за грубое или систематическое нарушение порядка пользования этим правом в случаях, предусмотренных статьями настоящего Кодекса.", "Согласно ст. 3.3 КоАП, Лишение права на управление транспортным средством устанавливается за грубое или систематическое нарушение порядка пользования этим правом в случаях, предусмотр")
    AddArticleDB("КоАП", "3.4", "/коап3.4", 0, "Разъяснение нормы", "Административный арест заключается в содержании нарушителя в условиях изоляции от общества и устанавливается и назначается лишь в исключительных случаях за отдельные виды административных правонарушений.", "Согласно ст. 3.4 КоАП, Административный арест заключается в содержании нарушителя в условиях изоляции от общества и устанавливается и назначается лишь в исключительных случаях за отде")
    AddArticleDB("КоАП", "4.1", "/коап4.1", 0, "Разъяснение нормы", "Наказание за совершение административного правонарушения назначается в пределах, установленных законом, предусматривающим ответственность за данное административное правонарушение, в соответствии с настоящим Кодексом.", "Согласно ст. 4.1 КоАП, Наказание за совершение административного правонарушения назначается в пределах, установленных законом, предусматривающим ответственность за данное администрати")
    AddArticleDB("КоАП", "4.2", "/коап4.2", 0, "Разъяснение нормы", "При назначении наказания физическому лицу учитываются характер совершенного им административного правонарушения, личность виновного, его имущественное положение, обстоятельства, смягчающие ответственность, и обстоятельства, отягчающие ответственность.", "Согласно ст. 4.2 КоАП, При назначении наказания физическому лицу учитываются характер совершенного им административного правонарушения, личность виновного, его имущественное положение")
    AddArticleDB("КоАП", "4.3", "/коап4.3", 0, "Разъяснение нормы", "Никто не может нести ответственность дважды за одно и то же административное правонарушение подряд. Скрыть контент Служащий не вправе суммировать штраф за нарушения одного и того же пункта настоящего Кодекса. Если после оформления протокола лицо повторно совершает нарушение пункта, по которому уже было наказано, то оно может быть повторно привлечено к ответственности. Системный штраф не равен наказанию от сотрудника.", "Согласно ст. 4.3 КоАП, Никто не может нести ответственность дважды за одно и то же административное правонарушение подряд. Скрыть контент Служащий не вправе суммировать штраф за наруш")
    AddArticleDB("КоАП", "4.4", "/коап4.4", 0, "Разъяснение нормы", "Возмещение имущественного ущерба и морального вреда, причиненных административным правонарушением.", "Согласно ст. 4.4 КоАП, Возмещение имущественного ущерба и морального вреда, причиненных административным правонарушением")
    AddArticleDB("КоАП", "4.4.1", "/коап4.4.1", 0, "Разъяснение нормы", "Уполномоченное лицо, рассматривая дело об административном правонарушении, вправе при отсутствии спора о возмещении имущественного ущерба одновременно с назначением наказания решить вопрос о возмещении имущественного ущерба.", "Согласно ст. 4.4.1 КоАП, Уполномоченное лицо, рассматривая дело об административном правонарушении, вправе при отсутствии спора о возмещении имущественного ущерба одновременно с назначе")
    AddArticleDB("КоАП", "4.4.2", "/коап4.4.2", 0, "Разъяснение нормы", "Споры о возмещении морального вреда, причиненного административным правонарушением, рассматриваются на городском портале Республики Провинция.", "Согласно ст. 4.4.2 КоАП, Споры о возмещении морального вреда, причиненного административным правонарушением, рассматриваются на городском портале Республики Провинция")
    AddArticleDB("КоАП", "4.5", "/коап4.5", 0, "Разъяснение нормы", "Срок давности привлечения к административной ответственности составляет 14 месяцев.", "Согласно ст. 4.5 КоАП, Срок давности привлечения к административной ответственности составляет 14 месяцев")
    AddArticleDB("КоАП", "17.1", "/коап17.1", 0, "Разъяснение нормы", "Отстранение от управления транспортным средством, освидетельствование на состояние алкогольного опьянения и медицинское освидетельствование на состояние опьянения.", "Согласно ст. 17.1 КоАП, Отстранение от управления транспортным средством, освидетельствование на состояние алкогольного опьянения и медицинское освидетельствование на состояние опьянен")
    AddArticleDB("УКРП", "1.1", "/укрп1.1", 0, "Разъяснение нормы", "Задачами законодательства об уголовных преступлениях (далее – настоящий Кодекс) являются защита личности, охрана прав и свобод человека и гражданина, охрана здоровья граждан, санитарно-эпидемиологического благополучия населения, защита общественной нравственности, охрана окружающей среды, установленного порядка осуществления государственной власти, общественного порядка и общественной безопасности, собственности, защита законных экономических интересов физических и юридических лиц, общества и государства от административных правонарушений, а также предупреждение уголовных правонарушений. За соблюдением настоящего Кодекса следят все служащие Министерства внутренних дел.", "Согласно ст. 1.1 УКРП, Задачами законодательства об уголовных преступлениях (далее – настоящий Кодекс) являются защита личности, охрана прав и свобод человека и гражданина, охрана здо")
    AddArticleDB("УКРП", "1.2", "/укрп1.2", 0, "Разъяснение нормы", "Лица, совершившие уголовное преступление, равны перед законом. Они подлежат ответственности независимо от пола, расы, национальности, языка, происхождения, имущественного и должностного положения, места жительства, отношения к религии, убеждений, принадлежности к общественным объединениям, а также других обстоятельств. Незнание закона не освобождает лицо от ответственности.", "Согласно ст. 1.2 УКРП, Лица, совершившие уголовное преступление, равны перед законом. Они подлежат ответственности независимо от пола, расы, национальности, языка, происхождения, имущ")
    AddArticleDB("УКРП", "1.3", "/укрп1.3", 0, "Разъяснение нормы", "Лицо подлежит ответственности только за те уголовные преступления, в отношении которых установлена его вина.", "Согласно ст. 1.3 УКРП, Лицо подлежит ответственности только за те уголовные преступления, в отношении которых установлена его вина")
    AddArticleDB("УКРП", "1.4", "/укрп1.4", 0, "Разъяснение нормы", "Лицо, совершившее уголовное преступление, подлежит ответственности на основании закона, действовавшего во время совершения данного деяния.", "Согласно ст. 1.4 УКРП, Лицо, совершившее уголовное преступление, подлежит ответственности на основании закона, действовавшего во время совершения данного деяния")
    AddArticleDB("УКРП", "1.5", "/укрп1.5", 0, "Разъяснение нормы", "Если имеется возможность выбора наказания за определенное нарушение - сотрудник имеет право самостоятельно вынести решение.", "Согласно ст. 1.5 УКРП, Если имеется возможность выбора наказания за определенное нарушение - сотрудник имеет право самостоятельно вынести решение")
    AddArticleDB("УКРП", "1.6", "/укрп1.6", 0, "Разъяснение нормы", "При совокупности преступлений лицо несет уголовную ответственность за каждое совершенное преступление по соответствующей статье или части статьи настоящего Кодекса.", "Согласно ст. 1.6 УКРП, При совокупности преступлений лицо несет уголовную ответственность за каждое совершенное преступление по соответствующей статье или части статьи настоящего Коде")
    AddArticleDB("УКРП", "2.1", "/укрп2.1", 0, "Разъяснение нормы", "Уголовным преступлением признается противоправное, виновное действие (бездействие) физического лица, за которое настоящим Кодексом следует ответственность.", "Согласно ст. 2.1 УКРП, Уголовным преступлением признается противоправное, виновное действие (бездействие) физического лица, за которое настоящим Кодексом следует ответственность")
    AddArticleDB("УКРП", "2.2", "/укрп2.2", 0, "Разъяснение нормы", "Существующие формы вины:", "Согласно ст. 2.2 УКРП, Существующие формы вины:")
    AddArticleDB("УКРП", "2.2.1", "/укрп2.2.1", 0, "Разъяснение нормы", "Уголовное преступление признается совершенным умышленно, если лицо, его совершившее, сознавало противоправный характер своего действия (бездействия), предвидело его вредные последствия и желало наступления таких последствий или сознательно их допускало, либо относилось к ним безразлично.", "Согласно ст. 2.2.1 УКРП, Уголовное преступление признается совершенным умышленно, если лицо, его совершившее, сознавало противоправный характер своего действия (бездействия), предвидело")
    AddArticleDB("УКРП", "2.2.2", "/укрп2.2.2", 0, "Разъяснение нормы", "Уголовное преступление признается совершенным по неосторожности, если лицо, его совершившее, предвидело возможность наступления вредных последствий своего действия (бездействия), но без достаточных к тому оснований самонадеянно рассчитывало на предотвращение таких последствий, либо не предвидело возможности наступления таких последствий, хотя должно было и могло их предвидеть.", "Согласно ст. 2.2.2 УКРП, Уголовное преступление признается совершенным по неосторожности, если лицо, его совершившее, предвидело возможность наступления вредных последствий своего дейст")
    AddArticleDB("УКРП", "2.3", "/укрп2.3", 0, "Разъяснение нормы", "Соучастие в совершении уголовного преступления, предусмотренного настоящим Кодексом, прикрывательство, укрывательство преступника, является наказуемым и влечет такую же ответственность, которая бы наступала в случае самостоятельного совершения преступления.", "Согласно ст. 2.3 УКРП, Соучастие в совершении уголовного преступления, предусмотренного настоящим Кодексом, прикрывательство, укрывательство преступника, является наказуемым и влечет ")
    AddArticleDB("УКРП", "2.4", "/укрп2.4", 0, "Разъяснение нормы", "Срок давности привлечения к уголовной ответственности составляет 14 месяцев.", "Согласно ст. 2.4 УКРП, Срок давности привлечения к уголовной ответственности составляет 14 месяцев")
    AddArticleDB("УКРП", "2.5", "/укрп2.5", 0, "Разъяснение нормы", "Нелегальные предметы, обнаруженные у задержанного, подлежат конфискации.", "Согласно ст. 2.5 УКРП, Нелегальные предметы, обнаруженные у задержанного, подлежат конфискации")
    AddArticleDB("УКРП", "3.1", "/укрп3.1", 0, "Разъяснение нормы", "Штраф является денежным взысканием, выражается в рублях и устанавливается для граждан в размере, указанном в соответствующей статье.", "Согласно ст. 3.1 УКРП, Штраф является денежным взысканием, выражается в рублях и устанавливается для граждан в размере, указанном в соответствующей статье")
    AddArticleDB("УКРП", "3.2", "/укрп3.2", 0, "Разъяснение нормы", "Арест – мера уголовного наказания, заключающаяся в содержании нарушителя в условиях изоляции от общества, и устанавливается на срок, предусмотренный статьями уголовного кодекса.", "Согласно ст. 3.2 УКРП, Арест – мера уголовного наказания, заключающаяся в содержании нарушителя в условиях изоляции от общества, и устанавливается на срок, предусмотренный статьями уг")

    AddArticleDB("ПДД", "211", "/пдд211", 0, "Разъяснение нормы", "Иметь при себе и по требованию служащих полиции передавать им, для проверки водительское удостоверение на право управления транспортным средством соответствующей категории или подкатегории, паспорт транспортного средства, на котором осуществляется передвижение.", "Иметь при себе и по требованию служащих полиции передавать им, для проверки||водительское удостоверение на право управления транспортным средством соответствующей категории||или подкатегории, паспорт транспортного средства, на котором осуществляется передвижение.")
    AddArticleDB("КоАП", "5.1", "/коап5.1", 20000, "Штраф 20.000 рублей.", "вождение без документов, предусмотренных пунктом 2.1.1 ПДД", "5.1 КоАП вождение без документов, предусмотренных пунктом 2.1.1 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "5.2", "/коап5.2", 30000, "Штраф 30.000 рублей или лишение права на управление ТС с возможностью моментального переобучения.", "непредоставление по требованию сотрудника полиции документов предусмотренных пунктом 2.1.1 ПДД", "5.2 КоАП непредоставление по требованию сотрудника полиции документов||предусмотренных пунктом 2.1.1 ПДД||Штраф 30.000 рублей или лишение права на управление ТС с возможностью моментального переобучения.")
    AddArticleDB("КоАП", "5.3", "/коап5.3", 10000, "Штраф 10.000 рублей.", "управление ТС, не зарегистрированным в установленном порядке либо без гос. номеров, либо с изменёнными или закрытыми регистрационными знаками если прошло более 3 суток с момента покупки", "5.3 КоАП управление ТС, не зарегистрированным в установленном порядке||либо без гос. номеров, либо с изменёнными или закрытыми регистрационными знаками||если прошло более 3 суток с момента покупки||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "5.4", "/коап5.4", 20000, "Штраф 20.000 рублей.", "управление ТС с тонировкой, светопропускаемость которой менее 70 процентов на боковых передних и лобовом стеклах включая запрещённые цветные пленки", "5.4 КоАП управление ТС с тонировкой, светопропускаемость которой менее 70 процентов||на боковых передних и лобовом стеклах включая запрещённые цветные пленки||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "5.5", "/коап5.5", 30000, "Предупреждение или штраф от 10.000 до 30.000 рублей.", "управление ТС при технической неисправности или в условиях, когда управление запрещено согласно пунктом 2.4 ПДД", "5.5 КоАП управление ТС при технической неисправности или в условиях, когда управление запрещено||согласно пунктом 2.4 ПДД||Предупреждение или штраф от 10.000 до 30.000 рублей.")
    AddArticleDB("КоАП", "5.6", "/коап5.6", 5000, "Предупреждение или штраф 5.000 рублей.", "управление мотоциклом или мопедом, либо перевозка пассажиров без мотошлемов согласно пунктом 2.1.3 ПДД", "5.6 КоАП управление мотоциклом или мопедом, либо перевозка пассажиров без мотошлемов||согласно пунктом 2.1.3 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "5.7", "/коап5.7", 15000, "Предупреждение или штраф от 5.000 до 15.000 рублей.", "нарушение ПДД пешеходами и велосипедистами согласно главе 4 ПДД", "5.7 КоАП нарушение ПДД пешеходами и велосипедистами||согласно главе 4 ПДД||Предупреждение или штраф от 5.000 до 15.000 рублей.")
    AddArticleDB("КоАП", "5.8", "/коап5.8", 5000, "Предупреждение или штраф 5.000 рублей.", "посадка или высадка пассажиров со стороны проезжей части в нарушение правил дорожного движения", "5.8 КоАП посадка или высадка пассажиров со стороны проезжей части||в нарушение правил дорожного движения||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "5.9", "/коап5.9", 20000, "Штраф 20.000 рублей.", "игнорирование водителем требования об остановке с помощью жезла", "5.9 КоАП игнорирование водителем требования об остановке с помощью жезла||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "5.10", "/коап5.10", 5000, "Штраф 5.000 рублей.", "несоблюдение требований дорожных знаков или разметки согласно приложению 1 и 2 ПДД", "5.10 КоАП несоблюдение требований дорожных знаков или разметки||согласно приложению 1 и 2 ПДД||Штраф 5.000 рублей.")
    AddArticleDB("КоАП", "6.1", "/коап6.1", 10000, "Штраф 10.000 рублей.", "использование приоритета с включёнными маячками и звуковым сигналом без убедительности в безопасности манёвра согласно пунктом 3.1 ПДД", "6.1 КоАП использование приоритета с включёнными маячками и звуковым сигналом||без убедительности в безопасности манёвра согласно пунктом 3.1 ПДД||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "6.2", "/коап6.2", 10000, "Предупреждение или штраф 10.000 рублей.", "нарушение правил использования аварийных сигналов согласно пунктом 7.1 ПДД", "6.2 КоАП нарушение правил использования аварийных сигналов||согласно пунктом 7.1 ПДД||Предупреждение или штраф 10.000 рублей.")
    AddArticleDB("КоАП", "6.3", "/коап6.3", 10000, "Предупреждение или штраф 10.000 рублей.", "нарушение правил использования знака аварийной остановки согласно пунктом 7.2 ПДД", "6.3 КоАП нарушение правил использования знака аварийной остановки||согласно пунктом 7.2 ПДД||Предупреждение или штраф 10.000 рублей.")
    AddArticleDB("КоАП", "6.4", "/коап6.4", 5000, "Предупреждение или штраф 5.000 рублей.", "управление ТС с выключенными фарами согласно пунктом 8.1 ПДД", "6.4 КоАП управление ТС с выключенными фарами||согласно пунктом 8.1 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "6.5", "/коап6.5", 5000, "Предупреждение или штраф 5.000 рублей.", "использование звукового сигнала с нарушением ПДД согласно пунктом 8.3 ПДД", "6.5 КоАП использование звукового сигнала с нарушением ПДД||согласно пунктом 8.3 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "7.1", "/коап7.1", 20000, "Штраф 20.000 рублей.", "проезд на красный сигнал светофора, запрещающий жест регулировщика, или на жёлтый при возможности остановки без создания опасности согласно пунктом 6.1 ПДД", "7.1 КоАП проезд на красный сигнал светофора, запрещающий жест регулировщика, или на жёлтый||при возможности остановки без создания опасности согласно пунктом 6.1 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "7.2", "/коап7.2", 10000, "Штраф 10.000 рублей.", "невыполнение требования остановки перед стоп-линией при запрещающем сигнале светофора или жесте регулировщика согласно пунктом 6.2 ПДД", "7.2 КоАП невыполнение требования остановки перед стоп-линией при запрещающем сигнале светофора||или жесте регулировщика согласно пунктом 6.2 ПДД||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "8.1", "/коап8.1", 5000, "Предупреждение или штраф 5.000 рублей.", "начало движения, перестроение, поворот или остановка без использования сигнала поворота согласно пунктом 9.1 ПДД", "8.1 КоАП начало движения, перестроение, поворот или остановка без использования сигнала поворота||согласно пунктом 9.1 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "8.2", "/коап8.2", 20000, "Штраф 20.000 рублей.", "непредоставление при перестроении преимущества транспортному средству попутного направления или справа согласно пунктом 9.4 ПДД", "8.2 КоАП непредоставление при перестроении преимущества транспортному средству||попутного направления или справа согласно пунктом 9.4 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "8.3", "/коап8.3", 20000, "Штраф 20.000 рублей.", "поворот направо, налево или разворот из полосы, не предназначенной для данного манёвра согласно пунктом 9.4 ПДД", "8.3 КоАП поворот направо, налево или разворот из полосы, не предназначенной для данного манёвра||согласно пунктом 9.4 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "8.4", "/коап8.4", 20000, "Штраф 20.000 рублей.", "поворот направо, налево, разворот или движение задним ходом с нарушением ПДД знаков или разметки согласно пунктам 9.4, 9.4.1, 9.6, 9.7 ПДД", "8.4 КоАП поворот направо, налево, разворот или движение задним ходом с нарушением ПДД||знаков или разметки согласно пунктам 9.4, 9.4.1, 9.6, 9.7 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "9.1", "/коап9.1", 50000, "Штраф 50.000 рублей с лишением права управления до 2 лет.", "движение по полосе, предназначенной для встречного движения, с нарушением ПДД согласно пунктом 10.1 ПДД", "9.1 КоАП движение по полосе, предназначенной для встречного движения, с нарушением ПДД||согласно пунктом 10.1 ПДД||Штраф 50.000 рублей с лишением права управления до 2 лет.")
    AddArticleDB("КоАП", "9.2", "/коап9.2", 50000, "Штраф 50.000 рублей.", "выезд на полосу, предназначенную для встречного движения, с нарушением ПДД согласно пунктом 10.1 ПДД", "9.2 КоАП выезд на полосу, предназначенную для встречного движения, с нарушением ПДД||согласно пунктом 10.1 ПДД||Штраф 50.000 рублей.")
    AddArticleDB("КоАП", "9.3", "/коап9.3", 5000, "Предупреждение или штраф 5.000 рублей.", "движение вне населённых пунктов по левым полосам при свободных правых согласно пунктом 10.2 ПДД", "9.3 КоАП движение вне населённых пунктов по левым полосам при свободных правых||согласно пунктом 10.2 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "9.4", "/коап9.4", 10000, "Предупреждение или штраф 10.000 рублей.", "движение по прерывистым линиям разметки с нарушением ПДД согласно пунктом 10.4 ПДД", "9.4 КоАП движение по прерывистым линиям разметки с нарушением ПДД||согласно пунктом 10.4 ПДД||Предупреждение или штраф 10.000 рублей.")
    AddArticleDB("КоАП", "9.5", "/коап9.5", 30000, "Штраф 30.000 рублей.", "движение по разделительным полосам, обочинам, тротуарам, пешеходным дорожкам и газону согласно пунктом 10.6 ПДД", "9.5 КоАП движение по разделительным полосам, обочинам, тротуарам, пешеходным дорожкам и газону||согласно пунктом 10.6 ПДД||Штраф 30.000 рублей.")
    AddArticleDB("КоАП", "9.6", "/коап9.6", 10000, "Предупреждение или штраф 10.000 рублей.", "несоблюдение дистанции до впереди идущего ТС и бокового интервала между движущимися ТС согласно пунктом 10.8 ПДД", "9.6 КоАП несоблюдение дистанции до впереди идущего ТС и бокового интервала между движущимися ТС||согласно пунктом 10.8 ПДД||Предупреждение или штраф 10.000 рублей.")
    AddArticleDB("КоАП", "10.1", "/коап10.1", 20000, "Штраф 20.000 рублей.", "обгон ТС с нанесёнными спец. цветографическими схемами с включённым синим проблесковым маячком и спец. звуковым сигналом согласно пунктом 3.2 ПДД", "10.1 КоАП обгон ТС с нанесёнными спец. цветографическими схемами||с включённым синим проблесковым маячком и спец. звуковым сигналом согласно пунктом 3.2 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "10.2", "/коап10.2", 20000, "Штраф 20.000 рублей.", "обгон ТС с спец. цветографическими схемами, с включёнными проблесковыми маячками синего и/или красного цветов, а также сопровождаемого ТС согласно пунктом 3.2 ПДД", "10.2 КоАП обгон ТС с спец. цветографическими схемами, с включёнными проблесковыми маячками синего||и/или красного цветов, а также сопровождаемого ТС согласно пунктом 3.2 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "10.3", "/коап10.3", 20000, "Штраф 20.000 рублей.", "обгон ТС в случаях, когда манёвр запрещён согласно пунктом 12.2 ПДД", "10.3 КоАП обгон ТС в случаях, когда манёвр запрещён||согласно пунктом 12.2 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "10.4", "/коап10.4", 20000, "Штраф 20.000 рублей.", "препятствование обгону согласно пунктом 12.3 ПДД", "10.4 КоАП препятствование обгону согласно пунктом 12.3 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "11.1", "/коап11.1", 10000, "Штраф 10.000 рублей.", "остановка или стоянка ТС на пешеходном переходе, ближе 5 м перед ним или на тротуаре согласно пунктом 13.3 ПДД", "11.1 КоАП остановка или стоянка ТС на пешеходном переходе, ближе 5 м перед ним||или на тротуаре согласно пунктом 13.3 ПДД||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "11.2", "/коап11.2", 10000, "Штраф 10.000 рублей.", "остановка или стоянка ТС в местах остановки маршрутных ТС или ближе 15 м от них кроме посадки/высадки или вынужденной остановки согласно пунктом 13.3 ПДД", "11.2 КоАП остановка или стоянка ТС в местах остановки маршрутных ТС или ближе 15 м от них||кроме посадки/высадки или вынужденной остановки согласно пунктом 13.3 ПДД||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "11.3", "/коап11.3", 10000, "Штраф 10.000 рублей.", "остановка или стоянка ТС на трамвайных путях газоне или далее первого ряда от края проезжей части согласно пунктом 13.3 ПДД", "11.3 КоАП остановка или стоянка ТС на трамвайных путях||газоне или далее первого ряда от края проезжей части согласно пунктом 13.3 ПДД||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "11.4", "/коап11.4", 10000, "Штраф 10.000 рублей.", "нарушение правил остановки или стоянки ТС на проезжей части или в тоннелях с созданием препятствий для движения других ТС согласно пунктом 13.3 ПДД", "11.4 КоАП нарушение правил остановки или стоянки ТС на проезжей части||или в тоннелях с созданием препятствий для движения других ТС согласно пунктом 13.3 ПДД||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "11.5", "/коап11.5", 10000, "Штраф 10.000 рублей.", "нарушение правил остановки или стоянки ТС, за исключением случаев частей 1-4 настоящей статьи согласно главе 13 ПДД", "11.5 КоАП нарушение правил остановки или стоянки ТС, за исключением случаев частей 1-4||настоящей статьи согласно главе 13 ПДД||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "12.1", "/коап12.1", 5000, "Предупреждение или штраф 5.000 рублей.", "нарушения правил проезда перекрёстков, не повлекшие опасности другим участникам движения согласно главе 14 ПДД", "12.1 КоАП нарушения правил проезда перекрёстков, не повлекшие опасности||другим участникам движения согласно главе 14 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "12.2", "/коап12.2", 10000, "Штраф 10.000 рублей.", "нарушения правил проезда перекрёстков, повлекшие опасность другим участникам движения согласно главе 14 ПДД", "12.2 КоАП нарушения правил проезда перекрёстков, повлекшие опасность||другим участникам движения согласно главе 14 ПДД||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "13.1", "/коап13.1", 5000, "Предупреждение или штраф 5.000 рублей.", "пересечение железнодорожных путей в местах, не оборудованных для этого согласно пунктом 16.1 ПДД", "13.1 КоАП пересечение железнодорожных путей в местах, не оборудованных для этого||согласно пунктом 16.1 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "13.2", "/коап13.2", 20000, "Штраф 20.000 рублей.", "выезд на железнодорожный переезд в случаях, когда это запрещено согласно пунктом 16.3 ПДД", "13.2 КоАП выезд на железнодорожный переезд в случаях, когда это запрещено||согласно пунктом 16.3 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "13.3", "/коап13.3", 5000, "Предупреждение или штраф 5.000 рублей.", "остановка ТС ближе 5 м от шлагбаума, или при его отсутствии ближе 10м до ближайшего рельса согласно пунктом 16.4 ПДД", "13.3 КоАП остановка ТС ближе 5 м от шлагбаума, или при его отсутствии ближе 10м||до ближайшего рельса согласно пунктом 16.4 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "14.1", "/коап14.1", 10000, "Штраф 10.000 рублей.", "движение по автомагистрали ТС, скорость которых по характеристикам или состоянию менее 40 км/ч согласно пунктом 17.1 ПДД", "14.1 КоАП движение по автомагистрали ТС, скорость которых по характеристикам||или состоянию менее 40 км/ч согласно пунктом 17.1 ПДД||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "14.2", "/коап14.2", 5000, "Предупреждение или штраф 5.000 рублей.", "движение по автомагистрали грузовых автомобилей далее второй полосы согласно пунктом 17.1 ПДД", "14.2 КоАП движение по автомагистрали грузовых автомобилей далее второй полосы||согласно пунктом 17.1 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "14.3", "/коап14.3", 10000, "Штраф 10.000 рублей.", "движение по автомагистрали задним ходом согласно пунктом 17.1 ПДД", "14.3 КоАП движение по автомагистрали задним ходом согласно пунктом 17.1 ПДД||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "14.4", "/коап14.4", 5000, "Предупреждение или штраф 5.000 рублей.", "создание пешеходом помех для автомобилей при движении в жилых зонах согласно пунктом 18.1 ПДД", "14.4 КоАП создание пешеходом помех для автомобилей при движении в жилых зонах||согласно пунктом 18.1 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "14.5", "/коап14.5", 5000, "Предупреждение или штраф 5.000 рублей.", "сквозное движение, учебная езда, стоянка с работающим двигателем а также стоянка грузовых ТС свыше 3,5 тонн вне спец выделенных мест согласно пунктом 18.2 ПДД", "14.5 КоАП сквозное движение, учебная езда, стоянка с работающим двигателем||а также стоянка грузовых ТС свыше 3,5 тонн вне спец выделенных мест согласно пунктом 18.2 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "14.6", "/коап14.6", 10000, "Предупреждение или штраф 10.000 рублей.", "движение в колонне с нарушением правил дорожного движения согласно главе 19 ПДД", "14.6 КоАП движение в колонне с нарушением правил дорожного движения||согласно главе 19 ПДД||Предупреждение или штраф 10.000 рублей.")
    AddArticleDB("КоАП", "15.1", "/коап15.1", 20000, "Штраф 20.000 рублей.", "непредоставление преимущества ТС с включенным проблесковым маячком синего и/или красного цвета и спец. звуковым сигналом согласно пунктом 3.2 ПДД", "15.1 КоАП непредоставление преимущества ТС с включенным проблесковым маячком синего||и/или красного цвета и спец. звуковым сигналом согласно пунктом 3.2 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "15.2", "/коап15.2", 5000, "Штраф 5.000 рублей.", "непредоставление преимущества троллейбусам и автобусам начинающим движение от места остановки согласно пунктом 20.2 ПДД", "15.2 КоАП непредоставление преимущества троллейбусам и автобусам||начинающим движение от места остановки согласно пунктом 20.2 ПДД||Штраф 5.000 рублей.")
    AddArticleDB("КоАП", "15.3", "/коап15.3", 10000, "Штраф 10.000 рублей.", "непредоставление преимущества ТС, движущимся по главной дороге или при выезде с прилегающей территории согласно пунктом 9.3 ПДД", "15.3 КоАП непредоставление преимущества ТС, движущимся по главной дороге||или при выезде с прилегающей территории согласно пунктом 9.3 ПДД||Штраф 10.000 рублей.")
    AddArticleDB("КоАП", "15.4", "/коап15.4", 5000, "Предупреждение или штраф 5.000 рублей.", "непредоставление преимущества пешеходам и/или велосипедистам при пересечении проезжей части согласно пунктом 15.1 ПДД", "15.4 КоАП непредоставление преимущества пешеходам||и/или велосипедистам при пересечении проезжей части согласно пунктом 15.1 ПДД||Предупреждение или штраф 5.000 рублей.")
    AddArticleDB("КоАП", "16.1", "/коап16.1", 30000, "Штраф 30.000 рублей с лишением права управления на 3-4 года и административный арест 20 суток.", "оставление водителем места ДТП, участником которого он являлся, с нарушением ПДД согласно пунктом 2.4 ПДД", "16.1 КоАП оставление водителем места ДТП, участником которого он являлся, с нарушением ПДД||согласно пунктом 2.4 ПДД||Штраф 30.000 рублей с лишением права управления на 3-4 года и административный арест 20 суток.")
    AddArticleDB("КоАП", "16.2", "/коап16.2", 20000, "Штраф 20.000 рублей.", "неоказание первой помощи при ДТП, если она необходима согласно пунктом 2.3 ПДД", "16.2 КоАП неоказание первой помощи при ДТП, если она необходима||согласно пунктом 2.3 ПДД||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "16.3", "/коап16.3", 35000, "Штраф от 10.000 до 35.000 рублей.", "невыполнение водителем обязанностей при ДТП, участником которого он является кроме случаев статьи 16.1 согласно пунктом 2.3 ПДД", "16.3 КоАП невыполнение водителем обязанностей при ДТП, участником которого он является||кроме случаев статьи 16.1 согласно пунктом 2.3 ПДД||Штраф от 10.000 до 35.000 рублей.")
    AddArticleDB("КоАП", "17.1.1", "/коап1711", 0, "Разъяснение нормы", "лицо, управляющее ТС и имеющее признаки опьянения или совершившее правонарушения по ст. 19.1 и 19.4 подлежит отстранению от управления до устранения причины", "17.1.1 КоАП лицо, управляющее ТС и имеющее признаки опьянения||или совершившее правонарушения по ст. 19.1 и 19.4 подлежит отстранению от управления до устранения причины")
    AddArticleDB("КоАП", "17.1.2", "/коап1712", 0, "Разъяснение нормы", "составляется протокол об отстранении от управления и направлении на медицинское освидетельствование копия вручается лицу", "17.1.2 КоАП составляется протокол об отстранении от управления и направлении||на медицинское освидетельствование копия вручается лицу")
    AddArticleDB("КоАП", "17.1.3", "/коап1713", 0, "Разъяснение нормы", "лицо с признаками опьянения подлежит освидетельствованию при отказе или несогласии направляется на медицинское освидетельствование", "17.1.3 КоАП лицо с признаками опьянения подлежит освидетельствованию при отказе||или несогласии направляется на медицинское освидетельствование")
    AddArticleDB("КоАП", "17.1.4", "/коап1714", 30000, "Штраф 30.000 рублей с лишением права управления до 1 года.", "управление ТС в состоянии опьянения или передача управления лицу в состоянии опьянения согласно п. 2.4 ПДД", "17.1.4 КоАП управление ТС в состоянии опьянения или передача управления лицу в состоянии опьянения||согласно п. 2.4 ПДД||Штраф 30.000 рублей с лишением права управления до 1 года.")
    AddArticleDB("КоАП", "17.1.5", "/коап1715", 30000, "Штраф 30.000 рублей с лишением права управления до 1 года.", "невыполнение законного требования о прохождении медицинского освидетельствования на состояние опьянения", "17.1.5 КоАП невыполнение законного требования о прохождении медицинского освидетельствования||на состояние опьянения||Штраф 30.000 рублей с лишением права управления до 1 года.")
    AddArticleDB("КоАП", "17.2", "/коап17.2", 30000, "Штраф до 30.000 рублей с лишением права управления до 2 лет.", "опасное вождение согласно пунктом 2.4 ПДД", "17.2 КоАП опасное вождение согласно пунктом 2.4 ПДД||Штраф до 30.000 рублей с лишением права управления до 2 лет.")
    AddArticleDB("КоАП", "17.3", "/коап17.3", 0, "Предупреждение.", "управление ТС при неуплате штрафов до 10.000 рублей", "17.3 КоАП управление ТС при неуплате штрафов до 10.000 рублей||Предупреждение.")
    AddArticleDB("КоАП", "17.4", "/коап17.4", 30000, "Штраф 30.000 рублей.", "управление ТС при неуплате штрафов от 10.000 до 50.000 рублей", "17.4 КоАП управление ТС при неуплате штрафов от 10.000 до 50.000 рублей||Штраф 30.000 рублей.")
    AddArticleDB("КоАП", "17.5", "/коап17.5", 50000, "Штраф 50.000 рублей с лишением права управления на 1 год.", "управление ТС при неуплате штрафов от 50.000 до 100.000 рублей", "17.5 КоАП управление ТС при неуплате штрафов от 50.000 до 100.000 рублей||Штраф 50.000 рублей с лишением права управления на 1 год.")
    AddArticleDB("КоАП", "17.6", "/коап17.6", 100000, "Штраф 100.000 рублей с лишением права управления на 2 года.", "управление ТС при неуплате штрафов свыше 100.000 рублей", "17.6 КоАП управление ТС при неуплате штрафов свыше 100.000 рублей||Штраф 100.000 рублей с лишением права управления на 2 года.")
    AddArticleDB("КоАП", "18.1", "/коап18.1", 0, "Предупреждение.", "превышение скорости на 10-20 км/ч, зафиксированное сотрудниками полиции", "18.1 КоАП превышение скорости на 10-20 км/ч, зафиксированное сотрудниками полиции||Предупреждение.")
    AddArticleDB("КоАП", "18.2", "/коап18.2", 2000, "Штраф 2.000 рублей.", "превышение скорости на 20-40 км/ч, зафиксированное сотрудниками полиции", "18.2 КоАП превышение скорости на 20-40 км/ч, зафиксированное сотрудниками полиции||Штраф 2.000 рублей.")
    AddArticleDB("КоАП", "18.3", "/коап18.3", 5000, "Штраф 5.000 рублей.", "превышение скорости на 40-60 км/ч, зафиксированное сотрудниками полиции", "18.3 КоАП превышение скорости на 40-60 км/ч, зафиксированное сотрудниками полиции||Штраф 5.000 рублей.")
    AddArticleDB("КоАП", "18.4", "/коап18.4", 7000, "Штраф 7.000 рублей.", "превышение скорости на 60-80 км/ч, зафиксированное сотрудниками полиции", "18.4 КоАП превышение скорости на 60-80 км/ч, зафиксированное сотрудниками полиции||Штраф 7.000 рублей.")
    AddArticleDB("КоАП", "18.5", "/коап18.5", 10000, "Штраф 10.000 рублей с лишением права управления на 1 год.", "превышение скорости на 80+ км/ч, зафиксированное сотрудниками полиции", "18.5 КоАП превышение скорости на 80+ км/ч, зафиксированное сотрудниками полиции||Штраф 10.000 рублей с лишением права управления на 1 год.")
    AddArticleDB("КоАП", "19.1", "/коап19.1", 10000, "Штраф до 10.000 рублей или административный арест 10 суток.", "мелкое хулиганство, нарушение общественного порядка с нецензурной лексикой оскорбительным поведением или повреждением чужого имущества а так же нахождение в нижнем белье вне водоёмов, бассейнов, спортзалов", "19.1 КоАП мелкое хулиганство, нарушение общественного порядка с нецензурной лексикой||оскорбительным поведением или повреждением чужого имущества||а так же нахождение в нижнем белье вне водоёмов, бассейнов, спортзалов||Штраф до 10.000 рублей или административный арест 10 суток.")
    AddArticleDB("КоАП", "19.2", "/коап19.2", 10000, "Штраф до 10.000 рублей или административный арест 10 суток.", "оскорбление, унижение чести и достоинства другого лица неприличной или аморальной формой", "19.2 КоАП оскорбление, унижение чести и достоинства другого лица неприличной или аморальной формой||Штраф до 10.000 рублей или административный арест 10 суток.")
    AddArticleDB("КоАП", "19.3", "/коап19.3", 20000, "Штраф до 20.000 рублей или административный арест 10 суток.", "нанесение побоев или иных насильственных действий, причиняющих физическую боль, не содержащих уголовно наказуемое деяние", "19.3 КоАП нанесение побоев или иных насильственных действий, причиняющих физическую боль,||не содержащих уголовно наказуемое деяние||Штраф до 20.000 рублей или административный арест 10 суток.")
    AddArticleDB("КоАП", "19.4", "/коап19.4", 5000, "Штраф 5.000 рублей.", "распитие алкоголя в общественных местах или появление в состоянии опьянения оскорбляющем человеческое достоинство и общественную нравственность", "19.4 КоАП распитие алкоголя в общественных местах или появление в состоянии опьянения||оскорбляющем человеческое достоинство и общественную нравственность||Штраф 5.000 рублей.")
    AddArticleDB("КоАП", "19.5", "/коап19.5", 0, "Предупреждение или административный арест 10 суток.", "занятие попрошайничеством в общественных местах", "19.5 КоАП занятие попрошайничеством в общественных местах||Предупреждение или административный арест 10 суток.")
    AddArticleDB("КоАП", "19.6", "/коап19.6", 100000, "Штраф 100.000 рублей.", "предпринимательская деятельность без регистрации или лицензии, если она обязательна", "19.6 КоАП предпринимательская деятельность без регистрации или лицензии, если она обязательна||Штраф 100.000 рублей.")
    AddArticleDB("КоАП", "19.7", "/коап19.7", 20000, "Штраф 20.000 рублей.", "заведомо ложный вызов пожарной охраны, полиции, скорой или иных служб", "19.7 КоАП заведомо ложный вызов пожарной охраны, полиции, скорой или иных служб||Штраф 20.000 рублей.")
    AddArticleDB("КоАП", "19.8", "/коап19.8", 20000, "Штраф до 20.000 рублей или административный арест 10 суток.", "организация, участие или призыв к несогласованному митингу с нарушением порядка и созданием помех движению", "19.8 КоАП организация, участие или призыв к несогласованному митингу с нарушением порядка||и созданием помех движению||Штраф до 20.000 рублей или административный арест 10 суток.")
    AddArticleDB("КоАП", "19.9", "/коап19.9", 20000, "Штраф 20.000 рублей, или лишение права управления на 1 год, или административный арест до 20 суток.", "неповиновение законному распоряжению сотрудника полиции или военнослужащего", "19.9 КоАП неповиновение законному распоряжению сотрудника полиции или военнослужащего||Штраф 20.000 рублей, или лишение права управления на 1 год, или административный арест до 20 суток.")
    AddArticleDB("КоАП", "19.10", "/коап19.10", 20000, "Штраф 20.000 рублей.", "клевета, распространение заведомо ложных сведений порочащих честь и достоинство или репутацию другого лица", "19.10 КоАП клевета, распространение заведомо ложных сведений||порочащих честь и достоинство или репутацию другого лица||Штраф 20.000 рублей.")
    AddArticleDB("УКРП", "4.1", "/укрп4.1", 0, "Арест сроком на 1 год.", "умышленное причинение вреда здоровью человека без летального исхода", "4.1 УКРП умышленное причинение вреда здоровью человека без летального исхода||Арест сроком на 1 год.")
    AddArticleDB("УКРП", "4.2", "/укрп4.2", 0, "Арест сроком на 2 года.", "умышленное нанесение особо тяжких телесных повреждений по итогу которых человек был доведен до предсмертного положения", "4.2 УКРП умышленное нанесение особо тяжких телесных повреждений||по итогу которых человек был доведен до предсмертного положения||Арест сроком на 2 года.")
    AddArticleDB("УКРП", "4.2.1", "/укрп421", 0, "Арест сроком от 4 до 6 лет.", "умышленное нанесение особо тяжких телесных повреждений двум или более лицам", "4.2.1 УКРП умышленное нанесение особо тяжких телесных повреждений двум или более лицам||Арест сроком от 4 до 6 лет.")
    AddArticleDB("УКРП", "4.2.2", "/укрп422", 0, "Арест сроком до 2 лет.", "нанесение особо тяжких телесных повреждений по неосторожности или в состоянии аффекта вызванного насилием, издевательством или тяжким оскорблением со стороны потерпевшего либо иными противоправными или аморальными действиями потерпевшего", "4.2.2 УКРП нанесение особо тяжких телесных повреждений по неосторожности или в состоянии аффекта||вызванного насилием, издевательством или тяжким оскорблением со стороны потерпевшего||либо иными противоправными или аморальными действиями потерпевшего||Арест сроком до 2 лет.")
    AddArticleDB("УКРП", "4.3", "/укрп4.3", 0, "Арест сроком на 1 год.", "угроза нанесения особо тяжких телесных повреждений или причинения вреда здоровью человека", "4.3 УКРП угроза нанесения особо тяжких телесных повреждений или причинения вреда здоровью человека||Арест сроком на 1 год.")
    AddArticleDB("УКРП", "4.4", "/укрп4.4", 0, "Арест сроком от 4 до 6 лет.", "похищение гражданина или незаконное лишение человека свободы, не связанное с похищением", "4.4 УКРП похищение гражданина или незаконное лишение человека свободы, не связанное с похищением||Арест сроком от 4 до 6 лет.")
    AddArticleDB("УКРП", "4.5", "/укрп4.5", 0, "Арест сроком от 3 до 6 лет.", "действия, направленные против половой неприкосновенности и половой свободы личности", "4.5 УКРП действия, направленные против половой неприкосновенности и половой свободы личности||Арест сроком от 3 до 6 лет.")
    AddArticleDB("УКРП", "4.6", "/укрп4.6", 0, "Арест сроком на 1 год.", "незаконный сбор или распространение сведений о частной жизни лица без его согласия", "4.6 УКРП незаконный сбор или распространение сведений о частной жизни лица без его согласия||Арест сроком на 1 год.")
    AddArticleDB("УКРП", "5.1", "/укрп5.1", 50000, "или 50.000 рублей, а также арест сроком на 3 года.", "получение должностным лицом взятки за осуществление очевидно незаконных действий Штраф в полуторакратном размере от полученной взятки", "5.1 УКРП получение должностным лицом взятки за осуществление очевидно незаконных действий||Штраф в полуторакратном размере от полученной взятки||или 50.000 рублей, а также арест сроком на 3 года.")
    AddArticleDB("УКРП", "5.2", "/укрп5.2", 0, "Арест сроком на 3 года.", "дача взятки должностному лицу лично или через посредника", "5.2 УКРП дача взятки должностному лицу лично или через посредника||Арест сроком на 3 года.")
    AddArticleDB("УКРП", "5.3", "/укрп5.3", 0, "Арест сроком от 3 до 6 лет.", "посягательство на жизнь и здоровье сотрудника полиции военнослужащего или работника инкассации", "5.3 УКРП посягательство на жизнь и здоровье сотрудника полиции||военнослужащего или работника инкассации||Арест сроком от 3 до 6 лет.")
    AddArticleDB("УКРП", "5.4", "/укрп5.4", 0, "Арест сроком до 3 лет.", "применение насилия или угроза применения насилия в отношении представителя власти", "5.4 УКРП применение насилия или угроза применения насилия в отношении представителя власти||Арест сроком до 3 лет.")
    AddArticleDB("УКРП", "5.5", "/укрп5.5", 0, "Арест сроком на 1 год.", "хамство или дерзость по отношению к сотруднику правоохранительных органов", "5.5 УКРП хамство или дерзость по отношению к сотруднику правоохранительных органов||Арест сроком на 1 год.")
    AddArticleDB("УКРП", "5.6", "/укрп5.6", 0, "Арест сроком на 2 года.", "публичное оскорбление или неоднократное неуважение к представителям власти", "5.6 УКРП публичное оскорбление или неоднократное неуважение к представителям власти||Арест сроком на 2 года.")
    AddArticleDB("УКРП", "5.7", "/укрп5.7", 0, "Арест сроком до 2 лет.", "провокационные действия в отношении сотрудников государственных структур", "5.7 УКРП провокационные действия в отношении сотрудников государственных структур||Арест сроком до 2 лет.")
    AddArticleDB("УКРП", "5.7.1", "/укрп571", 0, "Арест сроком до 2 лет.", "длительное преследование экипажа сотрудников правоохранительных органов или создание помех их работе", "5.7.1 УКРП длительное преследование экипажа сотрудников правоохранительных органов||или создание помех их работе||Арест сроком до 2 лет.")
    AddArticleDB("УКРП", "5.8", "/укрп5.8", 0, "Арест сроком на 2 года.", "неоднократное неповиновение законным требованиям служащего полиции", "5.8 УКРП неоднократное неповиновение законным требованиям служащего полиции||Арест сроком на 2 года.")
    AddArticleDB("УКРП", "5.8.1", "/укрп581", 0, "Арест сроком на 3 года.", "уход от правоохранительных органов с нанесением ущерба имуществу", "5.8.1 УКРП уход от правоохранительных органов с нанесением ущерба имуществу||Арест сроком на 3 года.")
    AddArticleDB("УКРП", "5.8.2", "/укрп582", 0, "Арест сроком на 4 года.", "уход от правоохранительных органов с причинением телесных повреждений средней тяжести и выше", "5.8.2 УКРП уход от правоохранительных органов с причинением||телесных повреждений средней тяжести и выше||Арест сроком на 4 года.")
    AddArticleDB("УКРП", "5.9", "/укрп5.9", 0, "Арест сроком на 2 года.", "умышленное уничтожение или повреждение имущества государственных организаций", "5.9 УКРП умышленное уничтожение или повреждение имущества государственных организаций||Арест сроком на 2 года.")
    AddArticleDB("УКРП", "5.10", "/укрп5.10", 0, "Арест сроком на 2 года.", "заведомо ложный донос или ложные показания по уголовному, административному делу", "5.10 УКРП заведомо ложный донос или ложные показания по уголовному, административному делу||Арест сроком на 2 года.")
    AddArticleDB("УКРП", "5.11", "/укрп5.11", 0, "Арест сроком до 3 лет.", "разглашение секретных данных или сведений о предстоящих операциях", "5.11 УКРП разглашение секретных данных или сведений о предстоящих операциях||Арест сроком до 3 лет.")
    AddArticleDB("УКРП", "5.12", "/укрп5.12", 0, "Арест сроком на 1 год.", "представление себя служащим государственной организации если это не соответствует действительности", "5.12 УКРП представление себя служащим государственной организации||если это не соответствует действительности||Арест сроком на 1 год.")
    AddArticleDB("УКРП", "5.13", "/укрп5.13", 0, "Арест сроком до 3 лет.", "халатность, повлекшая крупный ущерб или нарушение прав граждан", "5.13 УКРП халатность, повлекшая крупный ущерб или нарушение прав граждан||Арест сроком до 3 лет.")
    AddArticleDB("УКРП", "6.1", "/укрп6.1", 0, "Арест сроком до 6 лет.", "терроризм, совершение взрыва, поджога или иных действий создающих опасность гибели людей или тяжкие последствия", "6.1 УКРП терроризм, совершение взрыва, поджога или иных действий||создающих опасность гибели людей или тяжкие последствия||Арест сроком до 6 лет.")
    AddArticleDB("УКРП", "6.2", "/укрп6.2", 0, "Арест на 3 года.", "ложное сообщение о готовящихся взрыве, поджоге или иных опасных действиях", "6.2 УКРП ложное сообщение о готовящихся взрыве, поджоге или иных опасных действиях||Арест на 3 года.")
    AddArticleDB("УКРП", "6.3", "/укрп6.3", 0, "Арест сроком до 3 лет.", "захват или удержание лица в качестве заложника", "6.3 УКРП захват или удержание лица в качестве заложника||Арест сроком до 3 лет.")
    AddArticleDB("УКРП", "6.4", "/укрп6.4", 0, "Арест сроком до 6 лет.", "организация массовых беспорядков, сопровождающихся насилием и разрушениями", "6.4 УКРП организация массовых беспорядков, сопровождающихся насилием и разрушениями||Арест сроком до 6 лет.")
    AddArticleDB("УКРП", "6.5", "/укрп6.5", 0, "Арест сроком до 6 лет.", "создание банды, руководство ею или участие в её деятельности", "6.5 УКРП создание банды, руководство ею или участие в её деятельности||Арест сроком до 6 лет.")
    AddArticleDB("УКРП", "6.6", "/укрп6.6", 0, "Арест на 1 год.", "вандализм, порча имущества или осквернение сооружений", "6.6 УКРП вандализм, порча имущества или осквернение сооружений||Арест на 1 год.")
    AddArticleDB("УКРП", "6.7", "/укрп6.7", 0, "Арест сроком на 2 года.", "незаконное проникновение в жилище или частную территорию", "6.7 УКРП незаконное проникновение в жилище или частную территорию||Арест сроком на 2 года.")
    AddArticleDB("УКРП", "6.8", "/укрп6.8", 0, "Арест на 2 года.", "проникновение на охраняемый объект", "6.8 УКРП проникновение на охраняемый объект||Арест на 2 года.")
    AddArticleDB("УКРП", "6.9", "/укрп6.9", 0, "Арест на 3 года.", "незаконное обращение с огнестрельным оружием или боеприпасами", "6.9 УКРП незаконное обращение с огнестрельным оружием или боеприпасами||Арест на 3 года.")
    AddArticleDB("УКРП", "6.10", "/укрп6.10", 0, "Арест на 3 года.", "незаконный оборот наркотических средств или психотропных веществ", "6.10 УКРП незаконный оборот наркотических средств или психотропных веществ||Арест на 3 года.")
    AddArticleDB("УКРП", "6.11", "/укрп6.11", 0, "Арест на 1 год.", "неоказание первой или медицинской помощи без уважительных причин", "6.11 УКРП неоказание первой или медицинской помощи без уважительных причин||Арест на 1 год.")
    AddArticleDB("УКРП", "6.12", "/укрп6.12", 0, "Арест сроком на 3 года.", "попытка срыва мероприятий или помеха их проведению", "6.12 УКРП попытка срыва мероприятий или помеха их проведению||Арест сроком на 3 года.")
    AddArticleDB("УКРП", "6.13", "/укрп6.13", 0, "Арест на 3 года.", "подделка или использование поддельных лицензий или удостоверений", "6.13 УКРП подделка или использование поддельных лицензий или удостоверений||Арест на 3 года.")
    AddArticleDB("УКРП", "6.14", "/укрп6.14", 0, "Арест до 3 лет.", "превышение должностных полномочий, повлекшее существенные нарушения", "6.14 УКРП превышение должностных полномочий, повлекшее существенные нарушения||Арест до 3 лет.")
    AddArticleDB("УКРП", "7.1", "/укрп7.1", 50000, "Штраф 50.000 рублей и возмещение ущерба или арест на 3 года.", "мошенничество, хищение имущества путем обмана или злоупотребления доверием", "7.1 УКРП мошенничество, хищение имущества путем обмана или злоупотребления доверием||Штраф 50.000 рублей и возмещение ущерба или арест на 3 года.")
    AddArticleDB("УКРП", "7.2", "/укрп7.2", 0, "Арест на 2 года.", "грабеж или кража чужого имущества", "7.2 УКРП грабеж или кража чужого имущества||Арест на 2 года.")
    AddArticleDB("УКРП", "7.3", "/укрп7.3", 0, "Арест на 3 года.", "вымогательство, требование передачи имущества под угрозами", "7.3 УКРП вымогательство, требование передачи имущества под угрозами||Арест на 3 года.")
    AddArticleDB("УКРП", "7.4", "/укрп7.4", 50000, "Штраф 50.000 рублей и возмещение ущерба или арест на 2 года.", "умышленное уничтожение или повреждение имущества, повлекшее значительный ущерб", "7.4 УКРП умышленное уничтожение или повреждение имущества, повлекшее значительный ущерб||Штраф 50.000 рублей и возмещение ущерба или арест на 2 года.")
    AddArticleDB("УКРП", "7.5", "/укрп7.5", 0, "Арест на 2 года.", "организация или проведение азартных игр в общественных местах", "7.5 УКРП организация или проведение азартных игр в общественных местах||Арест на 2 года.")
    AddArticleDB("ПДД", "2.2.1", "/пдд221", 0, "Разъяснение нормы", "Перед выездом и в пути обеспечивать исправное техническое состояние ТС. Запрещено движение при неисправности тормозной системы, рулевого управления, сцепного устройства фар и задних габаритных огней в тёмное время суток а также стеклоочистителя во время дождя или снегопада. При прочих неисправностях нужно устранить их либо следовать к месту ремонта с соблюдением мер предосторожности.", "2.2.1. ПДД Перед выездом и в пути обеспечивать исправное техническое состояние ТС.||Запрещено движение при неисправности тормозной системы, рулевого управления, сцепного устройства||фар и задних габаритных огней в тёмное время суток||а также стеклоочистителя во время дождя или снегопада.||При прочих неисправностях нужно устранить их||либо следовать к месту ремонта с соблюдением мер предосторожности.")
    AddArticleDB("ПДД", "2.3.5", "/пдд235", 0, "Разъяснение нормы", "Если установлена вина одного из участников ДТП, виновник обязан выплатить пострадавшему компенсацию в размере, не превышающем полной стоимости ремонта ТС.", "2.3.5 ПДД Если установлена вина одного из участников ДТП, виновник обязан||выплатить пострадавшему компенсацию в размере, не превышающем полной стоимости ремонта ТС.")
    AddArticleDB("ПДД", "2.4", "/пдд2.4", 0, "Разъяснение нормы", "Водителю запрещается Управлять ТС в состоянии опьянения, под воздействием препаратов, ухудшающих реакцию а также в болезненном или утомлённом состоянии. Передавать управление ТС лицу, находящемуся в состоянии опьянения. Управлять ТС при наличии неисправностей, при которых эксплуатация запрещена. Пересекать организованные колонны и занимать место в них. Допускать опасное вождение: опасные перестроения, несоблюдение дистанции или бокового интервала, управляемые заносы, резкое торможение без необходимости, препятствование обгону и другие действия создающие угрозу ДТП, жизни, здоровью или имуществу.", "2.4 ПДД Водителю запрещается||Управлять ТС в состоянии опьянения, под воздействием препаратов, ухудшающих реакцию||а также в болезненном или утомлённом состоянии.||Передавать управление ТС лицу, находящемуся в состоянии опьянения.||Управлять ТС при наличии неисправностей, при которых эксплуатация запрещена.||Пересекать организованные колонны и занимать место в них.||Допускать опасное вождение: опасные перестроения, несоблюдение дистанции или бокового интервала,||управляемые заносы, резкое торможение без необходимости, препятствование обгону||и другие действия создающие угрозу ДТП, жизни, здоровью или имуществу.")
    AddArticleDB("ФЗоП", "2.4.4.1", "/фзопобр", 0, "Обязанность при обращении", "При обращении к гражданину сотрудник обязан: назвать должность, звание, фамилию, предъявить по обоснованному требованию удостоверение, сообщить причину и цель обращения.", "Согласно п. 2.4.4.1 ФЗ «О полиции», при обращении к гражданину сотрудник обязан||назвать свои должность, звание, фамилию, по обоснованному требованию предъявить удостоверение,||после чего сообщить причину и цель обращения.")
    AddArticleDB("ФЗоП", "2.4.4.2", "/фзопправа", 0, "Разъяснение причины и прав", "При ограничении прав и свобод разъяснить причину и основания таких мер после задержания, а также права и обязанности гражданина.", "Согласно п. 2.4.4.2 ФЗ «О полиции», при применении мер, ограничивающих права и свободы,||сотрудник разъясняет причину и основания применения таких мер после задержания,||а также возникающие в связи с этим права и обязанности гражданина.")
    AddArticleDB("ФЗоП", "2.4.6", "/фзопмат", 0, "Ознакомление с материалами", "Полиция обязана обеспечить гражданину возможность ознакомления с документами и материалами, непосредственно затрагивающими его права и свободы.", "Согласно п. 2.4.6 ФЗ «О полиции», полиция обязана обеспечить гражданину возможность||ознакомления с документами и материалами, непосредственно затрагивающими его права и свободы.")
    AddArticleDB("ФЗоП", "3.8.1.11", "/фзопнадзор", 0, "Надзор за БДД", "Обязанность полиции осуществлять государственный контроль (надзор) в области обеспечения безопасности дорожного движения и пресекать АПН.", "Согласно п. 3.8.1.11 ФЗ «О полиции», на полицию возложена обязанность||осуществлять государственный контроль и надзор в области безопасности дорожного движения.")
    AddArticleDB("ФЗоП", "3.8.1.13", "/фзопконф", 0, "Конфискация нелегала", "Обязанность конфисковывать нелегальные предметы, обнаруженные у задержанного (согласно ст. 2.5 УК РП), и изымать поддельные документы (п. 3.8.1.12).", "Согласно п. 3.8.1.13 ФЗ «О полиции», сотрудник полиции обязан конфисковывать||нелегальные предметы, обнаруженные у задержанного, согласно ст. 2.5 УК РП.")
    AddArticleDB("ФЗоП", "3.9.1.1", "/фзоптреб", 0, "Прекращение нарушений", "Право требовать от граждан и должностных лиц прекращения противоправных действий.", "Согласно п. 3.9.1.1 ФЗ «О полиции», сотрудник полиции имеет право||требовать от граждан и должностных лиц прекращения противоправных действий.")
    AddArticleDB("ФЗоП", "3.9.1.2", "/фзоп912", 0, "Проверка документов и штрафов", "Право проверять документы (паспорт, ВУ, ПТС) при подозрении в преступлении/розыске/АПН, при признаках нарушения п. 2.4 ПДД, а также проверять наличие неоплаченных штрафов.", "Согласно п. 3.9.1.2 ФЗ «О полиции», сотрудник МВД имеет право проверять документы граждан,||если имеются основания подозревать их в преступлении, розыске или административном правонарушении,||а также проверять ВУ, ПТС и наличие неоплаченных штрафов.")
    AddArticleDB("ФЗоП", "3.9.1.4", "/фзопотойти", 0, "Покинуть место проц. действий", "Право требовать от граждан покинуть место процессуальных действий (оформление, допрос, опрос). Сотрудник имеет право НЕ разглашать, какие именно процессуальные действия он проводит.", "Согласно п. 3.9.1.4 ФЗ «О полиции», сотрудник полиции вправе требовать от граждан||покинуть место и прилегающую территорию проведения процессуальных действий (оформление, допрос и пр.),||при этом сотрудник имеет право не разглашать, какие процессуальные действия он проводит.")
    AddArticleDB("ФЗоП", "3.9.1.7", "/фзопдост", 0, "Доставление в отдел МВД", "Право доставлять граждан в служебное помещение полиции для решения вопроса о задержании или установления личности, если есть основания полагать, что он в розыске.", "Согласно п. 3.9.1.7 ФЗ «О полиции», сотрудник вправе доставлять граждан в отдел полиции||для решения вопроса о задержании или установления личности гражданина.")
    AddArticleDB("ФЗоП", "3.9.1.8", "/фзопдосмотр", 0, "Личный досмотр и досмотр ТС", "Право осуществлять личный досмотр граждан, досмотр их вещей и ТС при наличии данных о запрещенных предметах/веществах, а также при задержании (п. 4.10.5).", "Согласно п. 3.9.1.8 и п. 4.10.5 ФЗ «О полиции», сотрудник полиции имеет право||осуществлять личный досмотр граждан, досмотр находящихся при них вещей и транспортных средств||при наличии данных о запрещенных предметах, а также при задержании лица.")
    AddArticleDB("ФЗоП", "3.9.1.9", "/фзопост", 0, "Остановка ТС и проверка ВУ/ПТС", "Право останавливать ТС для обеспечения безопасности дорожного движения, проверять ВУ и ПТС, задерживать ТС в розыске и временно ограничивать движение.", "Согласно п. 3.9.1.9 и ст. 3.9.2 ФЗ «О полиции», сотрудник полиции имеет право||останавливать транспортные средства для обеспечения безопасности дорожного движения,||проверять водительское удостоверение, ПТС и документы на перевозимые грузы.")
    AddArticleDB("ФЗоП", "3.9.1.11", "/фзопотстр", 0, "Отстранение от управления ТС", "Право задерживать ТС и отстранять водителей от управления ТС в случаях, предусмотренных законодательством (опьянение, отсутствие прав и др.).", "Согласно п. 3.9.1.11 ФЗ «О полиции», сотрудник полиции имеет право||задерживать транспортные средства и отстранять водителей от управления ТС.")
    AddArticleDB("ФЗоП", "3.9.1.12", "/фзопкамера", 0, "Видеофиксация и спецприборы", "Право использовать информационные базы, видео- и аудиотехнику, фотоаппаратуру, а также технические и специальные средства (регистратор, тауметр, алкотестер).", "Согласно п. 3.9.1.12 ФЗ «О полиции», сотрудник полиции имеет право использовать||информационные системы, видео- и фотоаппаратуру, а также технические и специальные средства.")
    AddArticleDB("ФЗоП", "3.9.1.14", "/фзопдоступтс", 0, "Доступ к ТС для проверки", "Право требовать от водителя предоставить доступ к ТС для проведения проверок (например, замер тонировки), если есть основания полагать, что ТС неисправно или совершается АПН.", "Согласно п. 3.9.1.14 ФЗ «О полиции», сотрудник имеет право требовать от водителя||предоставить доступ к транспортному средству для проведения проверки,||если есть основания полагать, что ТС неисправно или на нем совершается правонарушение.")
    AddArticleDB("ФЗоП", "3.9.1.17", "/фзопмаяк", 0, "Маячки и СГУ (п. 17–18)", "Маячки + СГУ: погоня, срочный вызов, колонна (ведущий/замыкающий), раненый, спецмероприятие. Маячки без СГУ: патруль/пост, стоянка в нарушение ПДД, ДТП/оцепление.", "Согласно п. 3.9.1.17–18 ФЗ «О полиции», проблесковые маячки включаются при патрулировании,||на посту, при оформлении ДТП и стоянке с отступлением от ПДД,||а совместно с СГУ — при ведении погони, срочном вызове и сопровождении колонн.")
    AddArticleDB("ФЗоП", "3.9.2", "/фзопост9", 0, "9 оснований остановки ТС", "1) Признаки нарушения БДД; 2) Причастность к ДТП/АПН/преступлению; 3) ТС в розыске; 4) Опрос очевидцев; 5) Ограничение ДД; 6–7) Пропуск спецтранспорта; 8) Помощь; 9) Проверка документов.", "Согласно ч. 2 ст. 9 (п. 3.9.2) ФЗ «О полиции», сотрудник вправе остановить ТС при обнаружении||признаков нарушения БДД, причастности водителя к правонарушению или ДТП, нахождении ТС в розыске,||а также для проверки документов при наличии повода к возбуждению дела об АПН.")
    AddArticleDB("ФЗоП", "4.10.2", "/фзопзадерж", 0, "10 оснований задержания", "Подозреваемые в преступлении; побег; в розыске; дело об АПН; проникновение на охраняемый объект; до выяснения обстоятельств; невыполнение законных требований сотрудника (ст. 9).", "Согласно ч. 2 ст. 10 (п. 4.10.2) ФЗ «О полиции», полиция имеет право задерживать лиц,||подозреваемых в совершении преступления, находящихся в розыске, лиц, в отношении которых||ведется производство по делу об АПН, а также не выполнивших законные требования сотрудника.")
    AddArticleDB("ФЗоП", "4.10.7", "/фзопзвонок", 0, "Право на 1 телефонный звонок", "Задержанный перед допросом имеет право на 1 телефонный разговор в присутствии сотрудника (не предоставляется, если может сообщить информацию преступнику — п. 4.10.8).", "Согласно п. 4.10.7–8 ФЗ «О полиции», задержанный перед допросом имеет право на один||телефонный разговор в присутствии сотрудника, если это не создаст угрозу сообщения информации сообщникам.")
    AddArticleDB("ФЗоП", "4.11.2", "/фзопоцеп", 0, "Оцепление и блокирование", "Право проводить оцепление/блокирование при авариях, массовых беспорядках, розыске беглецов, преследовании преступников и КТО с ограничением движения ТС и пешеходов.", "Согласно ст. 11 (п. 4.11.2–3) ФЗ «О полиции», полиция имеет право проводить оцепление||участков местности и временно ограничивать движение транспорта и пешеходов.")
    AddArticleDB("ФЗоП", "5.13.2", "/фзопбезпред", 0, "Сила/оружие БЕЗ предупреждения", "Без предупреждения: 1) Провокация; 2) Проникновение на охраняемый объект после предупреждения; 3) Непосредственная угроза жизни/здоровью; 4) Застигнут в момент преступления/арестного АПН.", "Согласно п. 5.13.2 ФЗ «О полиции», сотрудник имеет право не предупреждать перед применением||силы, спецсредств или оружия при непосредственной угрозе жизни и здоровью, провокации,||а также если лицо застигнуто в момент совершения преступления или арестного правонарушения.")
    AddArticleDB("ФЗоП", "5.14.1", "/фзопсила", 0, "Применение физической силы", "Право применять физ. силу и боевые приемы борьбы для пресечения преступлений/АПН, доставления и задержания лиц, а также преодоления противодействия законным требованиям.", "Согласно ст. 14 (п. 5.14.1) ФЗ «О полиции», сотрудник имеет право применять физическую силу||для пресечения правонарушений, задержания лиц и преодоления противодействия законным требованиям.")
    AddArticleDB("ФЗоП", "5.15.1", "/фзопспец", 0, "Применение спецсредств", "Наручники (п. 3,4,6): сопротивление, застигнут при преступлении/попытка скрыться, конвоирование/побег. Дубинка и тайзер (п. 1–5,7,8): нападение, пресечение АПН/преступления, сопротивление.", "Согласно ст. 15 (п. 5.15.1–2) ФЗ «О полиции», сотрудник имеет право применять спецсредства||(наручники, дубинку, тайзер) для пресечения преступления или АПН, преодоления сопротивления,||задержания лица, пытающегося скрыться, а также для доставления и конвоирования задержанных.")
    AddArticleDB("ФЗоП", "5.17.1", "/фзопоружие", 0, "Применение огнестрельного оружия", "Защита жизни/здоровья, пресечение захвата оружия/патрульки, вооруженное сопротивление, встраивание в колонну, остановка ТС путем повреждения при отказе остановиться и угрозе гражданам (п. 5.17.3.1).", "Согласно ст. 17 (п. 5.17.1 и 5.17.3) ФЗ «О полиции», сотрудник имеет право применять||огнестрельное оружие для защиты жизни и здоровья, задержания при вооруженном сопротивлении,||а также для остановки ТС путем его повреждения при неоднократном отказе остановиться.")
    AddArticleDB("ФЗоП", "5.17.8", "/фзопзапретор", 0, "Запреты по оружию (п. 5–9)", "Запрещено: 1) Стрелять с водительского места при наличии вооруженного напарника (п. 8); 2) Останавливать ТС тяжелым/автоматическим/гладкоствольным оружием (п. 9); 3) При скоплении людей (п. 6).", "Согласно п. 5.17.6–9 ФЗ «О полиции», запрещено применять оружие при скоплении людей,||с водительского места при наличии вооруженного напарника, а также применять тяжелое||автоматическое и гладкоствольное оружие для остановки ТС путем повреждения.")
    AddArticleDB("ФЗоП", "6.19.7", "/фзопстрой", 0, "Правила в строю и Онлайн-протокол", "В строю запрещено: разговаривать, доставать телефон/оружие, вставать/покидать без разрешения, спать (AFK) > 60 сек. Ст. 20: каждую субботу до 23:59 МСК сдавать онлайн-протокол.", "Согласно ст. 19–20 (п. 6.19.7 и 6.20.1) ФЗ «О полиции», в строю запрещено разговаривать,||доставать телефон или оружие, спать более 60 секунд и покидать строй без разрешения.||Каждую субботу до 23:59 МСК сотрудник обязан сдать отчёт в онлайн-протоколе.")
}

Bind_Pause:
Pause, Toggle
Return

Bind_Reload:
Reload
Return

PressCount:
Pause_ := 500
LastDoubleBase := DoublePressMap.HasKey(A_ThisHotkey) ? DoublePressMap[A_ThisHotkey] : "HK_ProtocolSign"
If not Second
{
    Second := 1
    SetTimer, DoublePress, -%Pause_%
}
Else
{
    Second := 0
    targetLbl2 := LastDoubleBase . "(2)"
    if IsLabel(targetLbl2)
        SetTimer, %targetLbl2%, -1
}
Return

DoublePress:
If not Second
    Return
Second := 0
targetLbl1 := LastDoubleBase . "(1)"
if IsLabel(targetLbl1)
    SetTimer, %targetLbl1%, -1
Return

; Изоляция хотстрингов: срабатывают только в окне игры (если включена опция OnlyInGameMode)
#If (OnlyInGameMode = 0 || WinActive("ahk_group ProvinceGameGroup"))
Bind_Greeting:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
    IniRead, Fio1, %A_Temp%\gibdd.egl, User, Fio1
    IniRead, Rank, %A_Temp%\gibdd.egl, User, Rank
    IniRead, Frak, %A_Temp%\gibdd.egl, User, Frak
    IniRead, Znak, %A_Temp%\gibdd.egl, User, Znak
    IniRead, Otdel, %A_Temp%\gibdd.egl, User, Otdel
    ; Определяем название по городу
    if (Frak = "Невский")
        Okr := "УГИБДД по городу Невский и Невской области Республики Провинция"
    else if (Frak = "Мирный")
        Okr := "УГИБДД по городу Мирный и Мирнинской области Республики Провинция"
    else if (Frak = "Приволжск")
        Okr := "УГИБДД по городу Приволжск и Приволжской области Республики Провинция"
    else
        Badge := "Данные" ; Значение по умолчанию, если город не совпадает с известными
    ; Отправляем приветственное сообщение
SmartSleep(500)
Send, {F8}animarmy 3{ENTER}{F8}
SmartSleep(500)
Send, {F8} say Здравия желаю, %Otdel% %Okr%.{Enter}{F8}
SmartSleep(500)
Send, {F8} say %Rank% полиции, %Fio1%.{Enter}{F8}
SmartSleep(500)
Send, {F8} do На груди закреплен полицейский знак с личным номером: %Znak%.{Enter}{F8}
SmartSleep(500)
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
SmartSleep(500)
Send, {F8}do На плечах %PogonDescription%.{Enter}{F8}
}
SmartSleep(500)
Return
Bind_AskDocs:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send,{F8} say Уважаемый(ая), будьте добры предоставить Ваши документы{Enter}{F8}
SmartSleep(500)
Send,{F8} b /me передал(-а) ВУ{Enter}{F8}
SmartSleep(500)
Send,{F8} b /lic id (id = цифры после ника){Enter}{F8}
Return
Bind_TakeDocs:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send,{F8}me протянул%ok1% правую руку и взял%ok1% документы гражданина{Enter}{F8}
SmartSleep(500)
Send,{F8}me детально изучил%ok1% документы гражданина, затем убрал%ok1% их в нагрудный карман{Enter}{F8}
SmartSleep(500)
Send,{F8}do Документы в нагрудном кармане.{Enter}{F8}
Return
Bind_ReturnDocs:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send,{F8} do Документы в нагрудном кармане.{Enter}{F8}
SmartSleep(500)
Send,{F8} me достал%ok1% документы из нагрудного кармана, затем протянул%ok1% гражданину {Enter}{F8}
SmartSleep(500)
Send,{F8} say Уважаемый(ая), держите ваши документы.{Enter}{F8}
SmartSleep(500)
Send,{F8} b /me забрал(-а) документы{Enter}{F8}
Return
Bind_AdminProt:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do Бланки протокола с ручкой лежат в сумке на плече сотрудника.{Enter}{F6}
SmartSleep(2500)
Send, /me открыл%ok1% сумку и достал%ok1% бланк протокола с ручкой{Enter}{F6}
SmartSleep(2500)
Send, /e взял%ok1% ручку и начал%ok1% оформлять протокол{Enter}{F6}
SmartSleep(2500)
Send, /me заполнил%ok1% личные данные водителя{Enter}{F6}
SmartSleep(2500)
Send, /me заполнил%ok1% статью нарушенную водителем{Enter}{F6}
SmartSleep(2500)
Send, /me поставил%ok1% дату и подпись{Enter}{F6}
SmartSleep(2500)
Send, /do Протокол составлен.{Enter}{F6}
SmartSleep(2500)
Send, Гражданин, с нарушением согласны? Подписывать протокол будете?{Enter}
Return
#UseHook, Off
#UseHook, On
HK_ProtocolSign(1):
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me передал%ok1% протокол и ручку гражданину{Enter}{F6}
SmartSleep(1000)
Send, /todo Уважаемый(ая), вот здесь подпись поставьте*указав пальцем на место подписи{Enter}{F6}
SmartSleep(1000)
Send, /b /me расписался(ась) в протоколе{Enter}
Return
HK_ProtocolSign(2):
AbortBindFlag := 0
KeyWait, Alt
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(500)
Send, /me взял%ok1% протокол и ручку у гражданина{Enter}
Return
Bind_Arrest:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /Введите ID гражданина которого хотите посадить ->{Space}
Input, Var1, V, {Enter}
Send, {bs 17}
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, Пора Вас конвоиру передавать. Свои вещи заберете у конвоира. {Enter}{F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, поднёс%ok2% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
Send, /me вызвал%ok1% конвоира{Enter}{F6}
SmartSleep(500)
Send, /do Конвоир вызван.{Enter}{F6}
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}{F6}
SmartSleep(500)
Send, /me открыл%ok1% дверь и передал%ok1% задержанного конвоиру{Enter}{F6}
SmartSleep(500)
Send, /say Уведите задержанного.{Enter}{F6}
SmartSleep(500)
Send, /do Конвоир увел задержанного.{Enter}{F6}
SmartSleep(500)
Send, /r Задержанный был передан конвоиру. Протокол задержания передан в канцелярию.{Enter}{F6}
SmartSleep(500)
Send, /arrest %Var1% {Enter}
LogJournalAction("Арест", Var1, "Передача задержанного конвоиру")
TriggerSmartScreenshot("Арест гражданина")
Return
Bind_SuFast:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send,{F8} do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F8} 
SmartSleep(50)
Send,{F8} me снял%ok1% рацию, затем связался с диспетчером и передал%ok1% ориентировку на гражданина{Enter}{F8} 
SmartSleep(50)
Send,{F6}
SmartSleep(100)
Send,/su{Space}
Return
Bind_SuSound:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send,{F8} do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F8} 
SmartSleep(250)
Send,{F8} me снял%ok1% рацию, затем связался с диспетчером и передал%ok1% ориентировку на гражданина{Enter}{F8} 
SmartSleep(200)
PlayRadioSfx("radio_start.wav")
SmartSleep(50)
Send,{F6}
SmartSleep(100)
Send, /su{Space}
Return
Bind_Tsu:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send,{F6}
SmartSleep(500)
Send, /me отрыл%ok1% базу данных и зашёл во вкладку "Фиксация нарушений" {Enter}{F6}
SmartSleep(500)
Send, /me вн%ok9% данные о нарушении водителя в базу, затем нажал "Внести"{Enter}{F6}
SmartSleep(200)
Send, /do Информация о штрафах введена в базу данных.{Enter}{F6} 
SmartSleep(100)
Send, /tsu{Space}
Return
Bind_TakeLic:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send,{F6}
SmartSleep(250)
Send, /me отрыл%ok1% базу данных и зашёл во вкладку "Аннулирование ВУ" {Enter}{F6}
SmartSleep(500)
Send, /me вн%ok9% данные гражданина и срок лишения, после чего нажал%ok1% "Аннулировать"{Enter}{F6}
SmartSleep(500)
Send, /do Информация о недействительности ВУ внесена в базу данных. {Enter}{F6} 
SmartSleep(500)
Send, Ваши права больше недействительны. Идите на пересдачу в автошколу{!}{Enter}{F6}
SmartSleep(500)
Send, /takecarlic{Space}
Return
#UseHook, Off
#UseHook, On
HK_Wcar(1):
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send,{F6}
SmartSleep(300)
Send, /me внес%ok2% данные о транспорте в базу розыска{Enter}{F6}
SmartSleep(300)
Send, /do Данные введены.{Enter}{F6} 
SmartSleep(300)
SendMessage, 0x50,, 0x4090409,, A
Send, /wcar{Enter}
Return
HK_Wcar(2):
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send,{F6}
SmartSleep(300)
Send, /me подключил%ok3% к базе данных{Enter}{F6}
SmartSleep(300)
Send, /me запросил%ok2% данные транспорта, находящегося в розыске{Enter}{F6}
SmartSleep(300)
Send, /do Данные получены в реальном времени.{Enter}{F6}
SmartSleep(300)
Send, /wcar{Enter}
Return
:?:/фкар::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send,{F6}
SmartSleep(300)
Send, /me открыл%ok2% базу данных автомобильных номеров{Enter}{F6}
SmartSleep(500)
Send, /me ввел%ok2% номер автомобиля в базу данных и узнал%ok2% данные владельца автомобиля{Enter}{F6}
SmartSleep(500)
Send, /do Информация о владельце автомобиля высветилась на экране.{Enter}{F6}
SmartSleep(500)
Send, /findcar{Space}
Return
Bind_FindEmp:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send,{F8}me открыл%ok1% базу данных сотрудников управления{Enter}{F8}
SmartSleep(100)
Send,{F8}do База данных сотрудников управления открыта.{Enter}{F8}
SmartSleep(100)
Send,{F8}find{Enter}{F8}
Return
Bind_Wanted:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send,{F8} me открыл%ok1% базу данных видеонаблюдения{Enter}{F8}
SmartSleep(100)
Send,{F8} do Изображение с камер транслируются в реальном времени на служебный планшет.{Enter}{F8}
SmartSleep(100)
Send,{F8}wanted{Enter}{F8}
Return
Bind_Fines:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send,{F8} me открыл%ok1% базу данных видеонаблюдения{Enter}{F8}
SmartSleep(100)
Send,{F8} me подключил%ok3% к базе данных{ENTER}{F8}
SmartSleep(300)
Send,{F8} me запросил%ok1% данные гражданских с неоплаченными штрафами в реальном времени{ENTER}{F8}
SmartSleep(300)
Send,{F8} do Данные получены в реальном времени. {ENTER}{F8}
SmartSleep(300)
Send,{F8}fines{Enter}{F8}
Return
Bind_CuffsOpen:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send,{F8} do Ключи от наручников висят на поясном креплении.{Enter}{F8}
SmartSleep(1000)
Send,{F8} me взял%ok1% ключи и освободил%ok1% одну руку задержанного от наручников{Enter}{F8}
SmartSleep(1000)
Send,{F8} me закрепил%ok1% наручники с рукой задержанного на двери патрульного автомобиля{Enter}{F8}
SmartSleep(1000)
Send,{F8} me протянул%ok1% протокол с ручкой задержанному{Enter}{F8}
SmartSleep(1000)
Send,{F8} todo Вот здесь подпись поставьте*указав пальцем место подписи{Enter}{F8}
SmartSleep(1000)
Send,{F8} b /me расписался в протоколе{Enter}{F8}
Return
Bind_CuffsClose:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(500)
Send,{F8} me открепил%ok1% руку с наручниками задержанного от двери патрульного автомобиля{Enter}{F8}
SmartSleep(1000)
Send,{F8} me закрепил%ok1% наручники на обеих руках задержанного{Enter}{F8}
SmartSleep(1000)
Send,{F8} me вырвал%ok1% копию протокола и положил%ok1% в карман гражданина{Enter}{F8}
SmartSleep(1000)
Send,{F8} do Копия протокола в кармане.{Enter}{F8}
Return
:?:/метка1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(200)
Send, /me поставил%ok1% метку о несогласии{Enter}
Return
:?:/метка2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(200)
Send, /me поставил%ok1% метку о невозможности подписать протокол{Enter}
Return
Bind_VoiceOn:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8} do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F8}
SmartSleep(350)
Send, {F8} me сняв рацию, поднес%ok2% её ко рту и нажал%ok1% кнопку для переговоров{Enter}{F8}
SmartSleep(150)
PlayRadioSfx("radio_start.wav")
SmartSleep(150)
Send, {F8} fracvoice 1{Enter}{F8}
Return
Bind_VoiceOff:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8} me перевел%ok1% рацию в режим прослушивания и закрепил%ok1% на нагрудном кармане{Enter}{F8}
SmartSleep(150)
PlayRadioSfx("radio_stop.wav")
SmartSleep(150)
Send, {F8} do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F8}
SmartSleep(350)
Send, {F8} fracvoice 2{Enter}{F8}
Return
Bind_Megaphone1:
AbortBindFlag := 0
StartChaseTimer(1)
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8} do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
SmartSleep(600)
Send, {F8} me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
SmartSleep(600)
Send, {F8}{Space}{Backspace} m {#}7ae70dВодитель, принимаем крайнее правое положение и останавливаемся{!}{Enter}{F8}
SmartSleep(600)
Send, {F8} me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return
Bind_Megaphone2:
AbortBindFlag := 0
StartChaseTimer(2)
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8} do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
SmartSleep(600)
Send, {F8} me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
SmartSleep(600)
Send, {F8}{Space}{Backspace} m {#}e7950dПовторяю, водитель, примите вправо и остановитесь{!}{Enter}{F8}
SmartSleep(600)
Send, {F8} me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return
Bind_Megaphone3:
AbortBindFlag := 0
StartChaseTimer(3)
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8} do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
SmartSleep(600)
Send, {F8} me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
SmartSleep(600)
Send, {F8}{Space}{Backspace} m {#}e74c3cОстанавливайтесь{!} В случае отказа откроем огонь{!}{Enter}{F8}
SmartSleep(600)
Send, {F8} me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return
Bind_MegaphoneWay:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8}do Тангента СГУ "Ермак" закреплена на торпеде.{Enter}{F8}
SmartSleep(600)
Send, {F8}me сняв тангенту с крепления, поднес%ok2% её ко рту и зажал%ok1% кнопку звукоусиления{Enter}{F8}
SmartSleep(600)
Send, {F8}{Space}{Backspace} m {#}e7950dУступите проезд спец. транспорту{!}{Enter}{F8}
SmartSleep(600)
Send, {F8}me отпустил%ok1% кнопку и повесил%ok1% тангенту обратно на торпеду{Enter}{F8}
Return
Bind_FootChase:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8}{Space}{Backspace}s Гражданин останавливаемся, в противном случае к вам будет применена физическая сила{!}{Enter}{F8}
Return

Bind_KpkOpen:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F6}
SmartSleep(500)
Send, /do Служебный планшет марки “MIG LT11i” в кармане. {Enter}{F6}
SmartSleep(500)
Send, /me достав служебный планшет из кармана, запустил%ok1% его {Enter}
Return
:?:/sos::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(200)
Send, /do Тревожная кнопка с GPS маячком в нагрудном кармане.{Enter}{F6}
SmartSleep(200)
Send, /me нажал%ok1% тревожную кнопку{Enter}{F6}
SmartSleep(200)
Send, /do Тревожная кнопка активирована. GPS маячок передает местоположение сотрудника.{Enter}{F6}
SmartSleep(200)
Send, /ro [Кнопка SOS][МВД] Активирована кнопка SOS, местонахождение:{Space}
Return
:?:/маска::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me сняв маску с гражданина, положил%ok1% её в карман задержанного{Enter}{F6}
SmartSleep(250)
Send, /do Маска снята.{Enter}
Return
:?:/убор::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me сняв головной убор с гражданина, положил%ok1% его в карман задержанного{Enter}{F6}
SmartSleep(250)
Send, /do Головной убор снят.{Enter}
Return
:?:/очки::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me сняв очки с гражданина, положил%ok1% их в карман задержанного{Enter}{F6}
SmartSleep(250)
Send, /do Очки сняты.{Enter}
Return
:?:/шлем::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me сняв шлем с гражданина, поставил%ok1% его на землю{Enter}{F6}
SmartSleep(250)
Send, /do Шлем снят.{Enter}
Return
:?:/дтп1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do Фотоаппарат лежит в сумке на плече сотрудника.{Enter}{F6}
SmartSleep(500)
Send, /me открыл%ok1% сумку и достал%ok1% фотоаппарат, затем зафиксировал%ok1% места ДТП{Enter}{F6} 
SmartSleep(500)
Send, /me выключив фотоаппарат, убрал%ok1% его в сумку{Enter}
Return
:?:/дтп2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do Рулетка лежит в сумке на плече сотрудника.{Enter}{F6}
SmartSleep(500)
Send, /me открыл%ok1% сумку и достал%ok1% рулетку, затем начал%ok1% измерения тормозных путей{Enter}{F6} 
SmartSleep(500)
Send, /me собрав рулетку, убрал%ok1% ее в сумку{Enter}
Return
:?:/дтп3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do Бланки с ручкой лежат в сумке на плече сотрудника.{Enter}{F6}
SmartSleep(500)
Send, /me достал%ok1% бланк осмотра места ДТП с ручкой, затем зарисовал%ok1% схему ДТП{Enter}{F6} 
SmartSleep(500)
Send, /me сделал%ok1% на схеме пометки со слов граждан{Enter}{F6}
SmartSleep(500)
Send, /me нан%ok9% на схему значения, измеренные рулеткой {Enter}{F6} 
SmartSleep(500)
Send, /do Значения нанесены.{Enter}{F6}
SmartSleep(500)
Send, /me положил%ok1% бланк с ручкой в сумку{Enter}{F6} 
SmartSleep(500)
Send, /me закончил%ok1% заполнять схему ДТП, затем убрал%ok1% схему в сумку{Enter}
Return
:?:/дтпкам::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me подключил%ok3% к базе данных {Enter}{F6}
SmartSleep(500)
Send, /do Подключение завершено. {Enter}{F6}
SmartSleep(500)
Send, /me запросил%ok1% запись с камер видеонаблюдения {Enter}{F6}
SmartSleep(500)
Send, /do Экран транслирует запись, полученную с камер видеонаблюдения. {Enter}
Return

:?:/вытащить::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me вытащил%ok1% задержанного из служебного автомобиля{Enter}
Return
Bind_PullOutSimple:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me вытащил%ok1% гражданина из автомобиля{Enter}
Return
Bind_GreetColleague:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(200)
Send, Здравия желаю{!}{Enter}{F6}
SmartSleep(200)
Send, /animarmy 3{Enter}
Return
:?:/п1::
AbortBindFlag := 0
StartDutyTimer("Патруль", 900)
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
IniRead, Frak, %A_Temp%\gibdd.egl, User, Frak
    ; Определяем название по городу
    if (Frak = "Невский")
        Pat := "10-0"
    else if (Frak = "Мирный")
        Pat := "10-1"
    else if (Frak = "Приволжск")
        Pat := "10-2"
    else
        Badge := "Данные" ; Значение по умолчанию, если город не совпадает с известными
    ; Отправляем приветственное сообщение
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send,  /r %Teg%-%Prop2% %Pat% {Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
TriggerSmartScreenshot("Доклад в патруле")
Return
:?:/п2::
AbortBindFlag := 0
StartDutyTimer("Патруль", 900)
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
IniRead, Frak, %A_Temp%\gibdd.egl, User, Frak
    ; Определяем название по городу
    if (Frak = "Невский")
        Pat := "10-0-1"
    else if (Frak = "Мирный")
        Pat := "10-1-1"
    else if (Frak = "Приволжск")
        Pat := "10-2-2"
    else
        Badge := "Данные" ; Значение по умолчанию, если город не совпадает с известными
    ; Отправляем приветственное сообщение
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send,  /r %Teg%-%Prop2% %Pat% {Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
TriggerSmartScreenshot("Доклад в патруле")
Return
:?:/п3::
AbortBindFlag := 0
StopDutyTimer()
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
IniRead, Frak, %A_Temp%\gibdd.egl, User, Frak
    ; Определяем название по городу
    if (Frak = "Невский")
        Pat := "10-21"
    else if (Frak = "Мирный")
        Pat := "10-21"
    else if (Frak = "Приволжск")
        Pat := "10-21"
    else
        Badge := "Данные" ; Значение по умолчанию, если город не совпадает с известными
    ; Отправляем приветственное сообщение
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send,  /r %Teg%-%Prop2% %Pat% {Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
TriggerSmartScreenshot("Доклад в патруле")
Return
:?:/обл1::
AbortBindFlag := 0
StartDutyTimer("Патруль", 900)
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /ro [%Gibdd%][МВД] Выехал в областное патрулирование. {Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/обл2::
AbortBindFlag := 0
StartDutyTimer("Патруль", 900)
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(250)
Send, /Введите букву города(П, М или Н) ->{Space}
Input, choice, V, {Enter}
if (choice = "П" or choice = "п" or choice = "G" or choice = "g")
    Gorod := "П"
else if (choice = "М" or choice = "м" or choice = "V" or choice = "v")
    Gorod := "М"
else if (choice = "Н" or choice = "н" or choice = "Y" or choice = "y")
    Gorod := "Н"
else
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /ro [%Gibdd%][МВД] Контролирую город %Gorod%. {Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/обл3::
AbortBindFlag := 0
StopDutyTimer()
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /ro [%Gibdd%][МВД] Закончил областное патрулирование. {Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return

:?:/рейд1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
IniRead, CheckMB, %A_Temp%\gibdd.egl, User, CheckMB
    ; Определяем название по городу
    if (CheckMB = "ОР/СР")
        MB := "СР"
    else if (CheckMB = "МР")
        MB := "МР"
    else
        Badge := "Данные" ; Значение по умолчанию, если город не совпадает с известными
    ; Отправляем приветственное сообщение
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send,  /ro [%Gibdd% %MB%][МВД] Начали рейд по отлову граждан с неоплаченными штрафами.{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/рейд2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
IniRead, CheckMB, %A_Temp%\gibdd.egl, User, CheckMB
    ; Определяем название по городу
    if (CheckMB = "ОР/СР")
        MB := "СР"
    else if (CheckMB = "МР")
        MB := "МР"
    else
        Badge := "Данные" ; Значение по умолчанию, если город не совпадает с известными
    ; Отправляем приветственное сообщение
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send,  /ro [%Gibdd% %MB%][МВД] Продолжаем рейд по отлову граждан с неоплаченными штрафами.{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/рейд3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
IniRead, CheckMB, %A_Temp%\gibdd.egl, User, CheckMB
    ; Определяем название по городу
    if (CheckMB = "ОР/СР")
        MB := "СР"
    else if (CheckMB = "МР")
        MB := "МР"
    else
        Badge := "Данные" ; Значение по умолчанию, если город не совпадает с известными
    ; Отправляем приветственное сообщение
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send,  /ro [%Gibdd% %MB%][МВД] Закончили рейд по отлову граждан с неоплаченными штрафами.{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/гун::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(400)
Send, /Введите какое ГУВД или МВД к кому идет вопрос (Пример: ГУ МВД-Н или МВД) ->{Space}
Input, GorodVizova, V, {Enter}
Send, {bs 17}
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][%GorodVizova%] Кто примет нарушителя{?}{Enter}{F6}
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/13п::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][ГУ МВД-П] Принял%ok1%{!}{Enter}{F6}
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/13м::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][ГУ МВД-М] Принял%ok1%{!}{Enter}{F6}
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/13н::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][ГУ МВД-Н] Принял%ok1%{!}{Enter}{F6}
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/13уп::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][УГИБДД-П] Принял%ok1%{!}{Enter}{F6}
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/13ум::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][УГИБДД-М] Принял%ok1%{!}{Enter}{F6}
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/13ун::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][УГИБДД-Н] Принял%ok1%{!}{Enter}{F6}
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/вп1::
AbortBindFlag := 0
StartDutyTimer("Патруль", 900)
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send,  /d [%Gibdd% ВП] Начал%ok1% воздушное патрулирование.{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/вп2::
AbortBindFlag := 0
StartDutyTimer("Патруль", 900)
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send,  /d [%Gibdd% ВП] Продолжаю воздушное патрулирование.{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/вп3::
AbortBindFlag := 0
StopDutyTimer()
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /d [%Gibdd% ВП] Закончил%ok1% воздушное патрулирование.{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/пост1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
    ; Определяем название по городу
    if (Frak = "Невский")
        Posst := "Н"
    else if (Frak = "Мирный")
        Posst := "М"
    else if (Frak = "Приволжск")
        Posst := "П"
    else
        Badge := "Данные" ; Значение по умолчанию, если город не совпадает с известными
    ; Отправляем приветственное сообщение
Send, {F6}
SmartSleep(150)
Send, /Введите номер поста ->{Space}
Input, Post, V, {Enter}
IniWrite, %Post%, %A_Temp%\gibdd.egl, User, Post
StartDutyTimer("Пост №" . Post, 1200)
Send, {bs 17}
SmartSleep(150)
Send, {F6}
SmartSleep(150)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-4 %Posst%-%Post%{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
TriggerSmartScreenshot("Доклад на посту")
Return
:?:/пост2::
AbortBindFlag := 0
IniRead, Frak, %A_Temp%\gibdd.egl, User, Frak
if (Post = "")
    IniRead, Post, %A_Temp%\gibdd.egl, User, Post, 1
StartDutyTimer("Пост №" . Post, 1200)
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
    ; Определяем название по городу
    if (Frak = "Невский")
        Posst := "Н"
    else if (Frak = "Мирный")
        Posst := "М"
    else if (Frak = "Приволжск")
        Posst := "П"
    else
        Badge := "Данные" ; Значение по умолчанию, если город не совпадает с известными
    ; Отправляем приветственное сообщение
Send, {F6}
SmartSleep(150)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-4-4 %Posst%-%Post%{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/пост3::
AbortBindFlag := 0
IniRead, Frak, %A_Temp%\gibdd.egl, User, Frak
if (Post = "")
    IniRead, Post, %A_Temp%\gibdd.egl, User, Post, 1
StopDutyTimer()
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
    ; Определяем название по городу
    if (Frak = "Невский")
        Posst := "Н"
    else if (Frak = "Мирный")
        Posst := "М"
    else if (Frak = "Приволжск")
        Posst := "П"
    else
        Badge := "Данные" ; Значение по умолчанию, если город не совпадает с известными
    ; Отправляем приветственное сообщение
Send, {F6}
SmartSleep(150)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-4-1 %Posst%-%Post%{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/он1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
Send, {F6}
SmartSleep(150)
Send, /Введите местонахождение ->{Space}
Input, Mesto, V, {Enter}
Send, {bs 17}
SmartSleep(150)
Send, {F6}
SmartSleep(150)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-11 %Mesto%{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/он2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-11-1 {Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/дттп1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
Send, {F6}
SmartSleep(150)
Send, /Введите местонахождение ->{Space}
Input, Mesto, V, {Enter}
Send, {bs 17}
SmartSleep(150)
Send, {F6}
SmartSleep(150)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-10 %Mesto%{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/дттп2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-10-1 {Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
Bind_KpkClose:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me выключил%ok1% служебный планшет и убрал%ok1% в карман{Enter}
Return
:?:/в1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(200)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(200)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-24{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/в2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(200)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(200)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-25{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/в+::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(200)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(200)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-26{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/в-::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(200)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(200)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-26ЛВ{Enter}{F6}
SmartSleep(200)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/копия::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me вырвал%ok1% копию протокола и передал%ok1% ее гражданину{Enter}{F6}
SmartSleep(1000)
Send, Уважаемый(ая), возьмите копию протокола.{Enter}{F6}
SmartSleep(1000)
Send, /b /me взял(а) копию протокола{Enter}
Return
:?:/зкопия::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me вырвал%ok1% копию протокола и положил%ok1% на карман гражданина{Enter}
Return
Bind_ShoutHands:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /s Из машины, руки на капот{!}{Enter}
Return


Bind_Clock:
AbortBindFlag := 0
{
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {Enter}
SmartSleep(250)
Send,{F8}do На запястье часы с гравировкой %Gibdd%.{Enter}{F8}
SmartSleep(250)
Send,{F8}me посмотрел%Ok1% на часы{Enter}{F8}
SmartSleep(250)
Send,{F8}do Время на часах: %A_DD%.%A_MM%.%A_YYYY%, %A_Hour%:%A_Min%:%A_Sec%.{Enter}{F8}
SmartSleep(250)
Send,{F8}timestamp{Enter}{F8}
SmartSleep(250)
Send,{F8}time{Enter}{F8}
SmartSleep(150)
Send,{F8}paytime{Enter}{F8}
SmartSleep(150)
Send,{F8}exptime{Enter}{F8}
}
return

Bind_TryDoor:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me дёрнул%ok1% за ручку двери{Enter}{F6}
SmartSleep(100)
Send, /do Сотрудни%ok5% пытается открыть дверь.{Enter}{F6}
SmartSleep(100)
Send, /try открыл%ok1% дверь{Enter}
Return
Bind_TryGlass:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me замахнул%ok3% дубинкой и ударил%ok1% по стеклу{Enter}{F6}
SmartSleep(100)
Send, /try разбил%ok1% стекло дубинкой{Enter}
Return 
Bind_UnlockIn:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me потянул%ok3% рукой до замка и открыл%ok1% его изнутри{Enter}{F6}
SmartSleep(100)
Send, /do Замок открыт.{Enter}{F6}
SmartSleep(100)
Send, /me открыл%ok1% дверь и вытащил%ok1% гражданина из машины{Enter}
Return
Bind_PullOutTry:
AbortBindFlag := 0
KeyWait, Control
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /try вытащил%ok1% гражданина напротив из автомобиля{Enter}
Return
Bind_Putpl:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Берегите голову при посадке в автомобиль{!}{Enter}{F6}
SmartSleep(500)
Send, /me взял%ok1% нарушителя за руки и посадил%ok1% в служебный автомобиль{Enter}{F6}
SmartSleep(500)
Send, /putpl{Space}
Return
Bind_KpkVu:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me открыл%ok1% базу данных нарушителей{Enter}{F6}
SmartSleep(500)
Send, /me ввел%ok1% данные гражданина в базу и нажал%ok1% кнопку "Запросить"{Enter}{F6}
SmartSleep(500)
Send, /do Информация о гражданине высветилась на экране.{Enter}{F6}
SmartSleep(500)
Send, /skan{Space}
Return
:?:/кпкфото::
AbortBindFlag := 0
KeyWait, Alt
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(200)
Send, {F6}
SmartSleep(200)
Send, Сейчас определим вашу личность.{Enter}{F6}
SmartSleep(500)
Send, /me сделал%ok1% фотографию гражданина и запросил%ok1% данные{Enter}{F6}
SmartSleep(500)
Send, /do Данные гражданина выведены на экран служебного планшета.{Enter}{F6}
SmartSleep(500)
Send, Ваша личность установлена.{Enter}{F6}
SmartSleep(500)
SendMessage, 0x50,, 0x4090409,, A
Send, /wanted {Enter}{F6}
SmartSleep(200)
Send, /crimrec{Space}
Return
Bind_DetainProt:
AbortBindFlag := 0
KeyWait, Control
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send,{F8} say Гражданин, сейчас мы составим протокол Вашего задержания.{Enter}{F8} 
SmartSleep(2000)
Send,{F8} do Бланки протокола с ручкой лежат в сумке на плече сотрудника.{Enter}{F8} 
SmartSleep(2000)
Send,{F8} me открыл%ok1% сумку и достал%ok1% бланк протокола с ручкой{Enter}{F8} 
SmartSleep(2000)
Send,{F8} me взял%ok1% ручку и начал%ok1% заполнять протокол{Enter}{F8} 
SmartSleep(2000)
Send,{F8} me заполнил%ok1% личные данные{Enter}{F8} 
SmartSleep(2000)
Send,{F8} me заполнил%ok1% статью нарушенную гражданином{Enter}{F8} 
SmartSleep(2000)
Send,{F8} me поставил%ok1% дату и подпись{Enter}{F8} 
SmartSleep(2000)
Send,{F8} do Протокол составлен.{Enter}{F8} 
SmartSleep(2000)
Send,{F8} say Гражданин, с нарушением согласны? Подписывать протокол будете?{Enter}{F8}
Return
:?:/код1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}{F6}
SmartSleep(500)
Send, /ro [%Gibdd%][МВД] Код-1 Местоположение:{Space}
Return
:?:/код0::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(200)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}{F6}
SmartSleep(500)
Send, /ro [%Gibdd%][МВД] Код-0 Местоположение:{Space}
Return
:?:/пр1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
IniRead, Prop2, %A_Temp%\gibdd.egl, User, Prop2
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /r %Teg%-%Prop2% 10-13{Enter}{F6} 
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return

:?:/рег1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do Видеорегистратор закреплен на лобовом стекле.{Enter}{F6}
SmartSleep(250)
Send, /me снял%ok1% видеорегистратор с крепления{Enter}
Return
:?:/рег2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me открыл%ok1% нужный файл и подготовил%ok1% его к просмотру{Enter}{F6}
SmartSleep(250)
Send, /me повернув видеорегистратор в сторону гражданина, запустил%ok1% запись{Enter}
Return
:?:/рег3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me выключил%ok1% воспроизведение видеофайла{Enter}
Return
:?:/рег4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me закрепил%ok1% видеорегистратор на крепление{Enter}
Return
:?:/алко1::
AbortBindFlag := 0
{
Sendmessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(500)
Send, {F8}do Алкотестер лежит в сумке на плече сотрудника.{enter}{F8}
SmartSleep(500)
Send, {F8}me достал%ok1% из сумки опломбированный электронный алкотестер с клеймом {enter}{F8}
SmartSleep(500)
Send, {F8}me показал опломбированный электронный алкотестер человеку напротив {enter}{F8}
}
return
:?:/алко2::
AbortBindFlag := 0
{
Sendmessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(500)
Send, {F8}say Сейчас пройдёте медицинское освидетельствование на состояние алкогольного опьянения{enter}{F8}
SmartSleep(500)
Send, {F8}me достал%ok1% из сумки запечатанную трубочку {enter}{F8}
SmartSleep(500)
Send, {F8}me передал%ok1% запечатанную трубочку гражданину {enter}{F8}
SmartSleep(500)
Send, {F8}b /me взял(a) трубочку {enter}{F8}
SmartSleep(500)
Send, {F8}say Распечатайте трубочку и убедитесь, что с ней всё в порядке. {enter}{F8}
}
return
:?:/алко3::
AbortBindFlag := 0
{
Sendmessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(500)
Send, {F8}say Сейчас сделаем тестовое включение и проверим работу прибора.{enter}{F8}
SmartSleep(500)
Send, {F8}me забрал%ok1% распечатанную трубочку из рук гражданина {enter}{F8}
SmartSleep(500)
Send, {F8}do Трубочка в руке. {enter}{F8}
SmartSleep(500)
Send, {F8}me вставил%ok1% трубочку в алкотестер {enter}{F8}
SmartSleep(500)
Send, {F8}do Трубочка в алкотестере. {enter}{F8}
SmartSleep(500)
Send, {F8}me включил%ok1% алкотестер и сделал%ok1% тестовую проверку {enter}{F8}
SmartSleep(500)
Send, {F8}do Прибор забирает воздух из окружающей среды. {enter}{F8}
SmartSleep(500)
Send, {F8}do Прибор показал: Алкоголь не обнаружен. {enter}{F8}
}
return
:?:/алко4::
AbortBindFlag := 0
{
Sendmessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(500)
Send, {F8}say Сейчас вам нужно будет дуть в трубочку. Дуйте как в шарик до звукового сигнала прибора.{enter}{F8}
SmartSleep(500)
Send, {F8}me подн%ok9% прибор к рту гражданина {enter}{F8}
SmartSleep(500)
Send, {F8}b /me дунул(а) в трубочку {enter}{F8}
}
return
:?:/алко5::
AbortBindFlag := 0
{
Sendmessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(500)
Send, {F8}say Сейчас посмотрим что показал прибор.{enter}{F8}
}
return
:?:/алко+::
AbortBindFlag := 0
{
Sendmessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(500)
Send, {F8}do На приборе высветилась надпись: Алкоголь обнаружен.{enter}{F8}
SmartSleep(500)
Send, {F8}me распечатал%ok1% результат{enter}{F8}
SmartSleep(500)
Send, {F8}me выбрав трубочку из алкотестера, убрал%ok1% ее в отсек сумки{enter}{F8}
SmartSleep(500)
Send, {F8}me выключив алкотестер, убрал%ok1% его в сумку{enter}{F8}
SmartSleep(500)
Send, {F8}do Алкотестер в сумке на плече сотрудника.{enter}{F8}
SmartSleep(500)
Send, {F8}me начал%ok1% составлять акт освидетельствования{enter}{F8}
SmartSleep(500)
Send, {F8}do В графе «Результат освидетельствования» написано: «Установлено состояние алкогольного опьянения».{enter}{F8}
SmartSleep(500)
Send, {F8}me передал%ok1% бланк с актом гражданину{enter}{F8}
SmartSleep(500)
Send, {F8}say Поставьте подпись в графе, если согласны с результатом.{enter}{F8}
SmartSleep(500)
Send, {F8}b /me поставил(а) подпись {enter}{F8}
}
return
:?:/алко-::
AbortBindFlag := 0
{
Sendmessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(500)
Send, {F8}do На приборе высветилась надпись: Алкоголь не обнаружен.{enter}{F8}
SmartSleep(500)
Send, {F8}me распечатал%ok1% результат{enter}{F8}
SmartSleep(500)
Send, {F8}me выбрав трубочку из алкотестера, убрал%ok1% ее в отсек сумки{enter}{F8}
SmartSleep(500)
Send, {F8}me выключив алкотестер, убрал%ok1% его в сумку{enter}{F8}
SmartSleep(500)
Send, {F8}do Алкотестер в сумке на плече сотрудника.{enter}{F8}
SmartSleep(500)
Send, {F8}me начал%ok1% составлять акт освидетельствования{enter}{F8}
SmartSleep(500)
Send, {F8}do В графе «Результат освидетельствования» написано: «Не установлено состояние алкогольного опьянения».{enter}{F8}
SmartSleep(500)
Send, {F8}me передал%ok1% бланк с актом гражданину{enter}{F8}
SmartSleep(500)
Send, {F8}say Поставьте подпись в графе, если согласны с результатом.{enter}{F8}
SmartSleep(500)
Send, {F8}b /me поставил(а) подпись {enter}{F8}
}
return

:?:/таум1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, CheckMB, %A_Temp%\gibdd.egl, User, CheckMB
Send, {F6}
SmartSleep(250)
if (CheckMB = "ОР/СР") {
Send, /do В бардачке патрульного автомобиля находится кейс с тауметром и чистая тряпочка.{Enter}{F6}
SmartSleep(500)
Send, /me открыл%ok1% бардачок патрульного автомобиля и достал%ok1% кейс с тауметром и тряпочку{Enter}{F6}
SmartSleep(500)
Send, /me открыл%ok1% кейс и извл%ok11% из него тауметр{Enter}
}
else if (CheckMB = "МР") {
Send, /do В кофре патрульного мотоцикла находится кейс с тауметром и чистая тряпочка.{Enter}{F6}
SmartSleep(500)
Send, /me открыл%ok1% кофр патрульного мотоцикла и достал%ok1% кейс с тауметром и тряпочку{Enter}{F6}
SmartSleep(500)
Send, /me открыл%ok1% кейс и извл%ok11% из него тауметр{Enter}
}
Return
:?:/таум2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me включил%ok1% тауметр и переш%ok7% в режим калибровки{Enter}{F6}
SmartSleep(500)
Send, /me совместил%ok1% измерительные датчики прибора и запустил%ok1% калибровку{Enter}{F6} 
SmartSleep(500)
Send, /do На дисплее тауметра отобразился результат калибровки.{Enter}{F6}
SmartSleep(500)
Send, /me убедил%ok3% в успешной калибровке и подготовил%ok1% прибор к замеру{Enter} 
Return
:?:/таум3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /Проверка тонировки, Гражданин открыл полностью окно?{Space}
Input, choice, V, {Enter}
if (choice = "Да")
    Ton := "Гражданин, приподнимите водительское стекло и откройте дверь для проверки светопропускаемости."
else if (choice = "Нет")
    Ton := "Откройте водительскую дверь для измерения светопропускаемости."
else
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, %Ton%{Enter}
Return
:?:/таум4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me тщательно протёр%ok2% лобовое и передние боковые стёкла тряпочкой{Enter}{F6}
SmartSleep(500)
Send, /do Поверхности стёкол очищены от загрязнений.{Enter}
Return
:?:/таум5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me установил%ok1% измерительные датчики тауметра на стёкла автомобиля{Enter}{F6}
SmartSleep(500)
Send, /me произв%ok8% замер светопропускаемости лобового и передних боковых стёкол{Enter}{F6}
SmartSleep(500)
Send, /do На дисплее тауметра отобразились результаты измерений.{Enter}{F6}
SmartSleep(500)
Send, /me зафиксировал%ok1% полученные показания и снял%ok1% датчики со стекла{Enter}
Return
:?:/таум6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, CheckMB, %A_Temp%\gibdd.egl, User, CheckMB
Send, {F6}
SmartSleep(250)
if (CheckMB = "ОР/СР") {
Send, /me выключил%ok1% тауметр и аккуратно уложил%ok1% его в кейс{Enter}{F6}
SmartSleep(500)
Send, /me закрыл%ok1% кейс, затем убрал%ok1% кейс и тряпочку в бордачок патрульного автомобиля{Enter}{F6}
SmartSleep(500)
Send, /me закрыл%ok1% бордачок{Enter}{F6}
SmartSleep(500)
Send, /do Бордачок закрыт.{Enter}
}
else if (CheckMB = "МР") {
Send, /me выключил%ok1% тауметр и аккуратно уложил%ok1% его в кейс{Enter}{F6}
SmartSleep(500)
Send, /me закрыл%ok1% кейс, затем убрал%ok1% кейс и тряпочку в кофр патрульного мотоцикла{Enter}{F6}
SmartSleep(500)
Send, /me закрыл%ok1% кофр{Enter}{F6}
SmartSleep(500)
Send, /do Кофр закрыт.{Enter}
}
Return
:?:/доктаум1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, CheckMB, %A_Temp%\gibdd.egl, User, CheckMB
Send, {F6}
SmartSleep(250)
if (CheckMB = "ОР/СР") {
Send, /do Бардачок открыт. {Enter}{F6}
SmartSleep(500)
Send, /do Папка с документами на тауметр лежит в бардачке патрульного автомобиля. {Enter}{F6}
SmartSleep(500)
Send, /me достал%ok1% из бардачка папку с документами на тауметр {Enter}{F6}
SmartSleep(500)
Send, /do В папке находятся официальные документы, подтверждающие исправность прибора и его законность в использовании. {Enter}
}
else if (CheckMB = "МР") {
Send, /do Папка с документами на тауметр лежит в сумке на плече сотрудника. {Enter}{F6}
SmartSleep(500)
Send, /me отрыл%ok1% сумку, затем достал%ok1% папку с документами на тауметр {Enter}{F6}
SmartSleep(500)
Send, /do В папке находятся официальные документы, подтверждающие исправность прибора и его законность в использовании. {Enter}
}
Return
:?:/доктаум2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me раскрыл%ok1% папку и достал%ok1% нужные бумаги {Enter}{F6}
SmartSleep(500)
Send, /do На документах указана отметка о поверке, прибор исправен, годен до 31.12.2026. {Enter}{F6}
SmartSleep(500)
Send, /me показал%ok1% документы гражданину для ознакомления {Enter}
Return
:?:/доктаум3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me положил%ok1% нужные бумаги обратно в папку, затем закрыл%ok1% ее {Enter}{F6}
SmartSleep(500)
Send, /do Папка закрыта. {Enter}{F6}
Return
:?:/доктаум4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, CheckMB, %A_Temp%\gibdd.egl, User, CheckMB
Send, {F6}
SmartSleep(250)
if (CheckMB = "ОР/СР") {
Send, /me положил%ok1% папку обратно в бардачок патрульного автомобиля {Enter}{F6}
}
else if (CheckMB = "МР") {
Send, /me положил%ok1% папку обратно в сумку {Enter}{F6}
}
Return
:?:/докалко1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, CheckMB, %A_Temp%\gibdd.egl, User, CheckMB
Send, {F6}
SmartSleep(250)
if (CheckMB = "ОР/СР") {
Send, /do Бардачок открыт. {Enter}{F6}
SmartSleep(500)
Send, /do Папка с документами на алкотестер лежит в бардачке патрульного автомобиля. {Enter}{F6}
SmartSleep(500)
Send, /me достал%ok1% из бардачка папку с документами на алкотестер {Enter}{F6}
SmartSleep(500)
Send, /do В папке находятся официальные документы, подтверждающие исправность прибора и его законность в использовании. {Enter}
}
else if (CheckMB = "МР") {
Send, /do Папка с документами на алкотестер лежит в сумке на плече сотрудника. {Enter}{F6}
SmartSleep(500)
Send, /me отрыл%ok1% сумку, затем достал%ok1% папку с документами на алкотестер {Enter}{F6}
SmartSleep(500)
Send, /do В папке находятся официальные документы, подтверждающие исправность прибора и его законность в использовании. {Enter}
}
Return
:?:/докалко2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me раскрыл%ok1% папку и достал%ok1% нужные бумаги {Enter}{F6}
SmartSleep(500)
Send, /do На документах указана отметка о поверке, прибор исправен, годен до 31.12.2026. {Enter}{F6}
SmartSleep(500)
Send, /me показал%ok1% документы гражданину для ознакомления {Enter}
Return
:?:/докалко3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me положил%ok1% нужные бумаги обратно в папку, затем закрыл%ok1% ее {Enter}{F6}
SmartSleep(500)
Send, /do Папка закрыта. {Enter}{F6}
Return
:?:/докалко4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, CheckMB, %A_Temp%\gibdd.egl, User, CheckMB
Send, {F6}
SmartSleep(250)
if (CheckMB = "ОР/СР") {
Send, /me положил%ok1% папку обратно в бардачок патрульного автомобиля {Enter}{F6}
}
else if (CheckMB = "МР") {
Send, /me положил%ok1% папку обратно в сумку {Enter}{F6}
}
Return
:?:/ор1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /Введите Имя Фамилию человека в розыске ->{Space}
Input, Var1, V, {Enter}
Send, {bs 17}
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, /do Служебный планшет марки “MIG LT11i” в сумке.{Enter}{F6}
SmartSleep(500)
Send, /me достав служебный планшет из сумки, запустил%ok1% его{Enter}{F6}
SmartSleep(500)
Send, /me открыл%ok1% базу данных нарушителей{Enter}{F6}
SmartSleep(500)
Send, /do База данных нарушителей открыта.{Enter}{F6}
SmartSleep(500)
Send, /me ввел%ok1% данные в базу и нажал%ok1% кнопку "Запросить"{Enter}{F6}
SmartSleep(500)
Send, /do На экране высветилась ориентировка.{Enter}{F6}
SmartSleep(500)
Send, /me повернул%ok1% служебный планшет экраном к гражданину{Enter}{F6}
SmartSleep(500)
Send, /do На экране ориентировка на гражданина "%Var1%".{Enter}
Return
:?:/лекция1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции: {#}ffff00"Правила пользования рацией".{Enter}{F6}
SmartSleep(2000)
Send, Рация - одно из средств взаимодействия между сотрудниками полиции и других структур.{Enter}{F6}
SmartSleep(2000)
Send, Рация даёт возможность быстро связаться с сотрудниками, оперативно передавать информацию...{Enter}{F6}
SmartSleep(2000)
Send, ..вызывать подкрепление и докладывать о своём состоянии.{Enter}{F6}
SmartSleep(2000)
Send, Рация закреплена на поясе или на нагрудном кармане у сотрудника.{Enter}{F6}
SmartSleep(2000)
Send, Рация "ТАКТ" позволяет быстро переключить частоту и связываться не только...{Enter}{F6}
SmartSleep(2000)
Send, ..с сотрудниками своего отдела, но и с сотрудниками других отделов или структур в целом.{Enter}{F6}
SmartSleep(2000)
Send, Так, есть 3 частоты: Локальная рация - связь с сотрудниками одного отдела{Enter}{F6}
SmartSleep(2000)
Send, Используется для докладов, передачи информации экипажам или составу{Enter}{F6}
SmartSleep(2000)
Send, Доклады о патруле делаются раз в 15 минут{Enter}{F6}
SmartSleep(2000)
Send, Доклады на стационарном посту делаются раз в 20 минут{Enter}{F6}
SmartSleep(2000)
Send, /b Использование: "/r XX-XX 10-0-1", "/r XX-XX 10-4 Н-2" или...{Enter}{F6}
SmartSleep(2000)
Send, /b .."/r XX-XX Контроль XX-XX, доложите о местоположении."{Enter}{F6}
SmartSleep(2000)
Send, Рация МВД - общая частота полицейской рации, используемая для передачи информации...{Enter}{F6}
SmartSleep(2000)
Send, ..или подачи запросов в другие отделы и структуры МВД.{Enter}{F6}
SmartSleep(2000)
Send, Используется при запросе сотрудников из другой структуры или при...{Enter}{F6}
SmartSleep(2000)
Send, ..докладах об областном патрулировании или рейдах.{Enter}{F6}
SmartSleep(2000)
Send, /b Использование: "/ro [От кого][Кому] Суть запроса".{Enter}{F6}
SmartSleep(2000)
Send, /b Пример: "/ro [УГИБДД-Н][ГУ МВД] Требуется сотрудник для оформления задержанного.{Enter}{F6}
SmartSleep(2000)
Send, Рация департамента - общая частота между всеми фракциями, включая РЖД, МЗ и МО.{Enter}{F6}
SmartSleep(2000)
Send, Рация департамента в основном нужна для вызова сотрудников отдельных фракций.{Enter}{F6}
SmartSleep(2000)
Send, К примеру для вызова врачей.{Enter}{F6}
SmartSleep(2000)
Send, Так же сотрудники ОАО РЖД, МЗ и МО могут вызывать сотрудников МВД по этой рации.{Enter}{F6}
SmartSleep(2000)
Send, /b Пример: /d [УГИБДД-Н][МЗ] Требуется АСМП к *место*, произошло ДТП.{Enter}{F6}
SmartSleep(2000)
Send, В рацию запрещено нести бред, засорять эфир, общаться, материться или угрожать.{Enter}{F6}
SmartSleep(2000)
Send, /b в НонРП рацию так же запрещено материться, конфликтовать и угрожать.{Enter}{F6}
SmartSleep(2000)
Send, За нарушение правил пользования рацией вы будете наказаны.{Enter}{F6}
SmartSleep(2000)
Send, Вопросы по лекции есть?{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}
Return
:?:/лекция2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции: {#}ffff00"Субординация".{Enter}{F6}
SmartSleep(2000)
Send, Субординация в полиции - это система служебных отношений, основанная на...{Enter}{F6}
SmartSleep(2000)
Send, ...подчинении младших сотрудников старшим по должности...{Enter}{F6}
SmartSleep(2000)
Send, ...а также чёткая иерархия полномочий и ответственности.{Enter}{F6}
SmartSleep(2000)
Send, Она проявляется в необходимости следовать приказам руководства, выполнять обязанности...{Enter}{F6}
SmartSleep(2000)
Send, ...в соответствии со своим званием и должностью...{Enter}{F6}
SmartSleep(2000)
Send, ...а также в запрете "идти через голову" непосредственного начальника по служебным вопросам.{Enter}{F6}
SmartSleep(2000)
Send, При общении на службе запрещено использовать слова "Да", "нет", "наверное", "не знаю", "можно".{Enter}{F6}
SmartSleep(2000)
Send, При встрече с коллегами, а также с вышестоящими по званию и должности, сотрудник обязан выполнить традиционное воинское приветствие...{Enter}{F6}
SmartSleep(2000)
Send,  ...и обратиться со словами "Здравия желаю{!}"{Enter}{F6}
SmartSleep(2000)
Send, Обращение к старшим с целью задать вопрос, поинтересоваться должно выглядеть так:{Enter}{F6}
SmartSleep(2000)
Send, "Здравия желаю, товарищ (звание). Разрешите обратиться{!} Обращается (звание) (фамилия)."{Enter}{F6}
SmartSleep(2000)
Send, После положительного ответа разрешено задать интересующий вас вопрос.{Enter}{F6}
SmartSleep(2000)
Send, Также обращаться к старшим по званию вы всегда должны на "Вы".{Enter}{F6}
SmartSleep(2000)
Send, Чтобы попросить разрешения встать в строй, после обращения необходимо...{Enter}{F6}
SmartSleep(2000)
Send, ...сказать: "Разрешите встать в строй".{Enter}{F6}
SmartSleep(2000)
Send, Для положительного ответа используется словосочетание "Так точно".{Enter}{F6}
SmartSleep(2000)
Send, Для негативного - "Никак нет".{Enter}{F6}
SmartSleep(2000)
Send, При получении приказа или указания к действию, необходимо сказать "Есть{!}" и беспрекословно...{Enter}{F6}
SmartSleep(2000)
Send, ...выполнять приказ вышестоящего.{Enter}{F6}
SmartSleep(2000)
Send, При незнании ответа на вопрос, следует отвечать "Не могу знать, товарищ (звание)".{Enter}{F6}
SmartSleep(2000)
Send, Субординация помогает поддерживать порядок, исключать панибратство и...{Enter}{F6}
SmartSleep(2000)
Send, ...неформальные отношения, которые могут помешать...{Enter}{F6}
SmartSleep(2000)
Send, ...служебной деятельности.{Enter}{F6}
SmartSleep(2000)
Send, Вопросы по лекции остались?{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена. {Enter}
Return
:?:/лекция3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00"Патрулирование".{Enter}{F6}
SmartSleep(2000)
Send, Прежде чем выехать в патруль вы должны быть сытым и при одетым в форму работника.{Enter}{F6}
SmartSleep(2000)
Send, В городе вы должны соблюдать ПДД и ехать не больше 60 км/ч.{Enter}{F6}
SmartSleep(2000)
Send, Для патруля вам запрещено использовать мигалку и сигнальные маячки.{Enter}{F6}
SmartSleep(2000)
Send, В патруле вы следите за порядком в городе.{Enter}{F6}
SmartSleep(2000)
Send, Если вы увидели нарушение, вы должны немедленно принять меры.{Enter}{F6}
SmartSleep(2000)
Send, В патруль допускается не более трех сотрудников.{Enter}{F6}
SmartSleep(2000)
Send, Патрулировать разрешено во всех города и их окрестностях.{Enter}{F6}
SmartSleep(2000)
Send, И делать доклады каждые 15 минут.{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}{F6}
SmartSleep(2000)
Send, У кого есть вопросы по этой лекции? {Enter}
Return
:?:/лекция4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00"Сирена и маячок".{Enter}{F6}
SmartSleep(2000)
Send, Сирена и маячок есть только в специально оборудованном ТС.{Enter}{F6}
SmartSleep(2000)
Send, Маячок и сирена одновременно работают, что-то раздельно не работает.{Enter}{F6}
SmartSleep(2000)
Send, Сирена с проблесковые маячки включается исключительно в служебных целях{!}{Enter}{F6}
SmartSleep(2000)
Send, Сирена с проблесковыми маячками включается, чтобы Вам уступили дорогу,{Enter}{F6}
SmartSleep(2000)
Send,  Обратили на Вас внимание и тому подобное.{Enter}{F6}
SmartSleep(2000)
Send,  Сирена с проблесковыми маячками даёт вам право на несоблюдение ПДД.{Enter}{F6}
SmartSleep(2000)
Send, Не соблюдать ПДД можно тогда, когда это никому ничем не угрожает.{Enter}{F6}
SmartSleep(2000)
Send, За нарушение правил использования сирен и проблесковых маячков выдается наказание.{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}{F6}
SmartSleep(2000)
Send, У кого есть вопросы по этой лекции?{Enter}
Return
:?:/лекция5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции: {#}ffff00"Правила поведения в строю".{Enter}{F6}
SmartSleep(2000)
Send, Строевой устав определяет строевые приемы и движение без оружия и с оружием,{Enter}{F6}
SmartSleep(2000)
Send, строй подразделений в пешем порядке и на машинах; порядок выполнения воинского приветствия,...{Enter}{F6}
SmartSleep(2000)
Send, ...проведения строевого смотра.{Enter}{F6}
SmartSleep(2000)
Send, обязанности сотрудников полиции перед построением и в строю и требования к их строевому обучению.{Enter}{F6}
SmartSleep(2000)
Send, Каждый сотрудник полиции обязан знать соответствующую основную терминологию:{Enter}{F6}
SmartSleep(2000)
Send, Строй - установленное уставом размещение сотрудников, отделов для их совместных действий...{Enter}{F6}
SmartSleep(2000)
Send, ...в пешем порядке и на машинах.{Enter}{F6}
SmartSleep(2000)
Send, Шеренга - строй, в котором сотрудники размещены один возле другого на одной линии...{Enter}{F6}
SmartSleep(2000)
Send, ...на установленных интервалах.{Enter}{F6}
SmartSleep(2000)
Send, Интервал - расстояние между сотрудниками (машинами) и отделами.{Enter}{F6}
SmartSleep(2000)
Send, Дистанция - расстояние в глубину между сотрудниками (машинами) и отделами.{Enter}{F6}
SmartSleep(2000)
Send, Колонна - строй, в котором сотрудники расположены в затылок друг другу,...{Enter}{F6}
SmartSleep(2000)
Send, ... а отделы (машины) - одно за другим на дистанциях установленных уставом...{Enter}{F6}
SmartSleep(2000)
Send, ...или командиром. Колонны могут быть по одному, по два, по три, по четыре и более.{Enter}{F6}
SmartSleep(2000)
Send, Направляющий - сотрудник (отдел, машина), движущийся головным в указанном направлении.{Enter}{F6}
SmartSleep(2000)
Send, По направляющему сообразуют свое движение остальные сотрудники (отделы, машины).{Enter}{F6}
SmartSleep(2000)
Send, Замыкающий - сотрудник (подразделение, машина), движущийся последним в колонне.{Enter}{F6}
SmartSleep(2000)
Send, Управление строем осуществляется четкими командами и приказаниями, которые подаются командиром...{Enter}{F6}
SmartSleep(2000)
Send, ...голосом, сигналами и личным примером, а также передаются с помощью...{Enter}{F6}
SmartSleep(2000)
Send, ...технических и подвижных средств.{Enter}{F6}
SmartSleep(2000)
Send, Строй выстраивается в определённом порядке: от направляющего в одну из сторон,...{Enter}{F6}
SmartSleep(2000)
Send, ...которая устанавливается в момент формирования строя.{Enter}{F6}
SmartSleep(2000)
Send, Руководящий состав выстраивается перпендикулярно строю, начиная от направляющего, образуя угол.{Enter}{F6}
SmartSleep(2000)
Send, Командующий строем стоит лицом к строю.{Enter}{F6}
SmartSleep(2000)
Send, О построении может объявить только руководство подразделения полиции. Исключение: приказ.{Enter}{F6}
SmartSleep(2000)
Send, В строю строго запрещено:{Enter}{F6}
SmartSleep(2000)
Send, Разговаривать в строю без разрешения командующего строем{Enter}{F6}
SmartSleep(2000)
Send, Пользоваться мобильными телефонами{Enter}{F6}
SmartSleep(2000)
Send, Доставать оружие и открывать огонь без приказа командующего строем{Enter}{F6}
SmartSleep(2000)
Send, Вставать в строй без разрешения командующего строем{Enter}{F6}
SmartSleep(2000)
Send, Засыпать в строю более чем на 60 секунд{Enter}{F6}
SmartSleep(2000)
Send, Самовольно покидать строй, двигаться, жестикулировать и прочее{Enter}{F6}
SmartSleep(2000)
Send, Перебивать командующего строем{Enter}{F6}
SmartSleep(2000)
Send, Отсутствовать на построении без предупреждения командующего строем{Enter}{F6}
SmartSleep(2000)
Send, За нарушение запретов и правил поведения в строю вы будете наказаны.{Enter}{F6}
SmartSleep(2000)
Send, Вопросы по лекции есть?{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция подошла к концу.{Enter}
Return
:?:/лекция6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00«Тен-коды».{Enter}{F6}
SmartSleep(2000)
Send, Каждый сотрудник обязан хорошо знать тен-коды.{Enter}{F6}
SmartSleep(2000)
Send, Доклады в рацию делаются обязательно со встпулением в виде кода вашего отдела{Enter}{F6}
SmartSleep(2000)
Send, И номера удостоверения.{Enter}{F6}
SmartSleep(2000)
Send, Например: 62-17, где 62 - номер отдела, а 17 - номер удостоверения.{Enter}{F6}
SmartSleep(2000)
Send, Далее идет информация, которую вы хотите доложить.{Enter}{F6}
SmartSleep(2000)
Send, Например: 62-17 10-1, где 10-1 - выезд в патруль.{Enter}{F6}
SmartSleep(2000)
Send, Доклады делаются строго по форме с использованием тен-кодов.{Enter}{F6}
SmartSleep(2000)
Send, Исключение - погоня, когда нужно доложить метоположение. После кода отдела,{Enter}{F6}
SmartSleep(2000)
Send, Номера удостоверения и обозначения кода состояния вы сообщаете местоположение погони.{Enter}{F6}
SmartSleep(2000)
Send, Например: 62-17 Код-1 Веду преследование нарушителя, находимся у ЖД Вокзала.{Enter}{F6}
SmartSleep(2000)
Send, Также не забывайте про остальные коды подачи информации,{Enter}{F6}
SmartSleep(2000)
Send, Которые вы обязаны докладывать во время оформления и так далее.{Enter}{F6}
SmartSleep(2000)
Send, Присутствует команда "контроль", на которую нужно отвечать так же по опреденной форме{Enter}{F6}
SmartSleep(2000)
Send, В зависимости от того, что именно у вас запрашивают.{Enter}{F6}
SmartSleep(2000)
Send, Например, Генерал-Майор хочет узнать, кто сейчас в патруле: 62-17 Контроль 62-30 ваше 10-20.{Enter}{F6}
SmartSleep(2000)
Send, Тот к кому обращаются должен ответить 62-30 Контроль 66-01 и ваше местоположение.{Enter}{F6}
SmartSleep(2000)
Send, У кого-нибудь есть вопросы по этой лекции?{Enter}{F6}
SmartSleep(2000)
Send, Отлично, тогда на этом лекция окончена.{Enter}
Return
:?:/лекция7::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00«Погоня».{Enter}{F6}
SmartSleep(2000)
Send, Погоня - это физическое преследование с целью настигнуть кого-то или что-то.{Enter}{F6}
SmartSleep(2000)
Send, Погоня делится на два типа: пешая и автомобильная.{Enter}{F6}
SmartSleep(2000)
Send, При автомобильной погоне разрешено:{Enter}{F6}
SmartSleep(2000)
Send, использовать специальные маневры для остановки нарушителя{Enter}{F6}
SmartSleep(2000)
Send, использовать спец.средства и табельное оружие организовывать блок-посты,перекрытия{Enter}{F6}
SmartSleep(2000)
Send, привлекать другие экипажи/структуры МВД для остановки нарушителя{Enter}{F6}
SmartSleep(2000)
Send, При автомобильной погоне запрещено:использовать прямой таран для остановки т/с.{Enter}{F6}
SmartSleep(2000)
Send, уезжать с места ДТП при столкновении с гражданским автомобилем, не относящийся к погоне.{Enter}{F6}
SmartSleep(2000)
Send, Также продолжать погоню после подобного ДТП.{Enter}{F6}
SmartSleep(2000)
Send,  ЕПП/ЕПР на автомобилях не предназначенных для этого{Enter}{F6}
SmartSleep(2000)
Send, ЕПТ на любом ТС.{Enter}{F6}
SmartSleep(2000)
Send, При пешей погоне разрешается:{Enter}{F6}
SmartSleep(2000)
Send,  использовать специальные средства для задержания нарушителя{Enter}{F6}
SmartSleep(2000)
Send, привлекать другие экипажи/структуры МВД для остановки нарушителя.{Enter}{F6}
SmartSleep(2000)
Send, в случае, если гражданин далеко убежал в поле, то сотрудник может попросить гражданина.{Enter}{F6}
SmartSleep(2000)
Send, на ЕПП авто и чтобы гражданин помог в участии погони.{Enter}{F6}
SmartSleep(2000)
Send, При пешей погоне запрещено использовать без предупреждений табельное оружие{Enter}{F6}
SmartSleep(2000)
Send, и прыгать в ответ за гражданином.{Enter}{F6}
SmartSleep(2000)
Send, Во время погони присваиваются следующие статусы:{Enter}{F6}
SmartSleep(2000)
Send, Зеленый - Данный статус присваивается сразу после начала погони{Enter}{F6}
SmartSleep(2000)
Send, Основной задачей сотрудник является преследование нарушителя и выдача предупреждений об остановке,{Enter}{F6}
SmartSleep(2000)
Send, передача ориентировки другим экипажам,{Enter}{F6}
SmartSleep(2000)
Send, применение специальных маневров при возможности.{Enter}{F6}
SmartSleep(2000)
Send, При специальном маневре стоит учитывать скорость автомобиля, рельеф, населенность.{Enter}{F6}
SmartSleep(2000)
Send, Желтый - данный статус присваивается после того, как прошло более 3-ех минут с начала погони.{Enter}{F6}
SmartSleep(2000)
Send, Основной задачей сотрудника является намеренная остановка транспортного средства{Enter}{F6}
SmartSleep(2000)
Send, при этом не стоит забывать про предупредительный выстрел в воздух и стрельбу по колесам.{Enter}{F6}
SmartSleep(2000)
Send, Только после этого, выполняется стрельба по двигателю.{Enter}{F6}
SmartSleep(2000)
Send, Красный-данный статус присваивается в случае реальной угрозы сотруднику полиции, гражданским лицам.{Enter}{F6}
SmartSleep(2000)
Send, Интервал между предупреждениями - не меньше 15 секунд.{Enter}{F6}
SmartSleep(2000)
Send, В отдельной роте сотрудник должен откинуть минимум 5 предупреждений,{Enter}{F6}
SmartSleep(2000)
Send, Из которых 4 - об остановке, и 1 перед открытием огня.{Enter}{F6}
SmartSleep(2000)
Send,На этом лекция «Правила ведения погони» окончена.{Enter}
Return
:?:/лекция8::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00«Составление протокола о нарушении ПДД».{Enter}{F6}
SmartSleep(2000)
Send, Если вы заметели, как гражданин нарушает ПДД, вы должны попросить прижаться его к обочине.{Enter}{F6}
SmartSleep(2000)
Send, При остановке представляемся гражданину, просим его ВУ, говорим за что его остановили.{Enter}{F6}
SmartSleep(2000)
Send, Когда гражданин даёт вам документы, вы тщательно изучаете их.{Enter}{F6}
SmartSleep(2000)
Send, Также пробиваете документы гражданина через КПК, чтобы узнать наличие штрафов.{Enter}{F6}
SmartSleep(2000)
Send, Называете гражданину пункт КоАП и сумму штрафа.{Enter}{F6}
SmartSleep(2000)
Send, После чего составляете протокол о нарушении КоАП, и далее передаем его на подпись гражданину.{Enter}{F6}
SmartSleep(2000)
Send, Если гражданин не согласен, то ставим метку об несогласии.{Enter}{F6}
SmartSleep(2000)
Send, Далее вырываем копию и передаем гражданину.{Enter}{F6}
SmartSleep(2000)
Send, Далее выдает штраф уже сам через КПК.{Enter}{F6}
SmartSleep(2000)
Send, У кого-нибудь есть вопросы по этой лекции?{Enter}
Return
:?:/лекция9::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Сейчас пройдет лекция {#}ffff00«Взаимодействие с гражданскими лицами».{Enter}{F6}
SmartSleep(2000)
Send, Согласно 2.4.4.1 ФЗоП - сотрудник полиции, при обращении к гражданину обязан:{Enter}{F6}
SmartSleep(2000)
Send, назвать свои должность, звание, фамилию, предъявить по обосновоннаму требованию гражданина{Enter}{F6}
SmartSleep(500)
Send, служебное удостоверение,{Enter}{F6}
SmartSleep(2000)
Send, после чего сообщить причину и цель обращения.{Enter}{F6}
SmartSleep(2000)
Send,  Сотрудникам гос.структур категорически запрещено переходить на “Ты” с гражданскими лицами.{Enter}{F6}
SmartSleep(2000)
Send, Также сотрудникам гос. структур запрещено использовать нецензурную лексику.{Enter}{F6}
SmartSleep(2000)
Send, Во время взаимодействия с гражданскими соблюдайте субординацию, общайтесь вежливо{Enter}{F6}
SmartSleep(500)
Send, и без каких-либо насмешек, угроз, шуток.{Enter}{F6}
SmartSleep(2000)
Send, Субординация разрешено не соблюдать если Вам дано разрешение на это.{Enter}{F6}
SmartSleep(2000)
Send, Дружеские отношения в составе МВД не запрещены, а даже наоборот, поощряются.{Enter}{F6}
SmartSleep(2000)
Send, Но, если рядом с Вами гражданские, рекомендуется всё таки соблюдать субординацию.{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция «Взаимодействие с гражданскими лицами» окончена.{Enter}
Return
:?:/лекция10::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции: {#}ffff00"Табельное оружие".{Enter}{F6}
SmartSleep(2000)
Send, Табельное оружие выдаётся сотруднику полиции, начиная со звания Старшина.{Enter}{F6}
SmartSleep(2000)
Send, Существуют правила пользования табельным оружием.{Enter}{F6}
SmartSleep(2000)
Send, Запрещено просто так доставать табельное оружие, махать им...{Enter}{F6}
SmartSleep(2000)
Send, ..показывать и стрелять просто так.{Enter}{F6}
SmartSleep(2000)
Send, Табельное оружие используется для выполнения сотрудником...{Enter}{F6}
SmartSleep(2000)
Send, ..служебных обязанностей, а так же для самообороны.{Enter}{F6}
SmartSleep(2000)
Send, Сотрудникам полиции доступно три вида оружия:{Enter}{F6}
SmartSleep(2000)
Send, Пистолет МР-443 Грач, Автомат АК-74М и Дробовик МР-133.{Enter}{F6}
SmartSleep(2000)
Send, Пистолет МР-443 Грач доступен сотрудникам со звания Старшины.{Enter}{F6}
SmartSleep(2000)
Send, Автомат АК-74М доступен сотрудникам со звания Майор в ОР, или со звания Лейтенант в СР.{Enter}{F6}
SmartSleep(2000)
Send, Дробовик МР-443 доступен только сотрудникам Управляющего и Руководящего состава.{Enter}{F6}
SmartSleep(2000)
Send, Пистолет применяется для остановки транспортных средств,...{Enter}{F6}
SmartSleep(2000)
Send, ..при нападении на сотрудника трёх и более гражданских лиц без оружия..{Enter}{F6}
SmartSleep(2000)
Send, При вооруженном сопротивлении или вооруженном нападении на сотрудника и/или гражданских лиц,..{Enter}{F6}
SmartSleep(2000)
Send, Автомат можно применять за пределами городской местности в тех же целях,...{Enter}{F6}
SmartSleep(2000)
Send, ..или же в городской местности с условием отсутствия патронов на пистолет, или если пистолет...{Enter}{F6}
SmartSleep(2000)
Send, .. малоэффективен и промедление может повлечь последствия.{Enter}{F6}
SmartSleep(2000)
Send, Из автомата запрещено стрелять с пассажирского места в городе и за городом...{Enter}{F6}
SmartSleep(2000)
Send, ..на скорости более 200 км/ч.{Enter}{F6}
SmartSleep(2000)
Send, Так же запрещено стрелять из автомата с водительского места.{Enter}{F6}
SmartSleep(2000)
Send, Дробовик можно применять за городом при вооруженном конфликте или при...{Enter}{F6}
SmartSleep(2000)
Send, ..малой эффективности автомата.{Enter}{F6}
SmartSleep(2000)
Send, В городской местности дробовик можно применять при отсутствии иного вооружения или...{Enter}{F6}
SmartSleep(2000)
Send, ..патронов к нему.{Enter}{F6}
SmartSleep(2000)
Send, Из дробовика запрещено стрелять, находясь в машине.{Enter}{F6}
SmartSleep(2000)
Send, В случае отсутствия патронов к табельному оружию сотрудник придерживается постепенного правила:{Enter}{F6}
SmartSleep(2000)
Send, ...пистолет-автомат-дробовик.{Enter}{F6}
SmartSleep(2000)
Send, Водителю запрещено использовать табельное оружие, если есть вооруженный напарник.{Enter}{F6}
SmartSleep(2000)
Send, Если все вооруженные напарники истратили свой боезапас, водитель имеет право...{Enter}{F6}
SmartSleep(2000)
Send, ..открыть огонь из пистолета.{Enter}{F6}
SmartSleep(2000)
Send, При применении табельного оружия сотрудник действует на основаниях ФЗ «О полиции».{Enter}{F6}
SmartSleep(2000)
Send, В случаях, предусмотренных ФЗ «О полиции», сотрудник вправе предупреждать или не предупреждать...{Enter}{F6}
SmartSleep(2000)
Send, ..граждан о применении в отношении них огнестрельного оружия.{Enter}{F6}
SmartSleep(2000)
Send, За нарушения правил пользования табельным оружием вы будете сурово наказаны.{Enter}{F6}
SmartSleep(2000)
Send, Вопросы по лекции имеются?{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}
Return
:?:/лекция11::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00"Обработка вызова".{Enter}{F6}
SmartSleep(2000)
Send, Обработка вызова - это важный этап в работе любого сотрудника УГИБДД.{Enter}{F6}
SmartSleep(2000)
Send, От оперативности и качества обработки зависит своевременность реагирования на происшествия,{Enter}{F6}
SmartSleep(2000)
Send, эффективность работы правоохранительных органов и, в конечном итоге, жизнь и безопасность людей.{Enter}{F6}
SmartSleep(2000)
Send, Прием вызова: "ХХ-ХХ 10-24" - это стандартный тен-код, используемый для подтверждения приема вызова в рацию.{Enter}{F6}
SmartSleep(2000)
Send, Прибытие на место: "ХХ-ХХ 10-25" - этот тен-код подтверждает прибытие на место вызова.{Enter}{F6}
SmartSleep(2000)
Send, По прибытию, в случае если гражданское лицо находится на месте вызова{Enter}{F6} 
SmartSleep(2000)
Send, Вы должны подойти к нему, представиться и узнать цель вызова.{Enter}{F6}
SmartSleep(2000)
Send, Соблюдайте этику общения, не переходите на "Ты" с заявителем, будьте вежливы и тактичны.{Enter}{F6}
SmartSleep(2000)
Send, Каждая деталь может быть важной для установления всех обстоятельств происшествия.{Enter}{F6}
SmartSleep(2000)
Send, Не разглашайте информацию о заявителе или происшествии третьим лицам.{Enter}{F6}
SmartSleep(2000)
Send, Вы должны внимательно выслушать заявителя, чтобы получить максимально полную информацию о происшествии.{Enter}{F6}
SmartSleep(2000)
Send, Важно фиксировать ключевые моменты разговора, записывая необходимые данные:{Enter}{F6}
SmartSleep(2000)
Send, место происшествия, время, описание ситуации, контактные данные заявителя.{Enter}{F6}
SmartSleep(2000)
Send, Основные действия на вызове:{Enter}{F6}
SmartSleep(2000)
Send, Оказать первую помощь пострадавшим, если это необходимо, до приезда скорой помощи.{Enter}{F6}
SmartSleep(2000)
Send, В случае необходимости задержать подозреваемых.{Enter}{F6}
SmartSleep(2000)
Send, О конечной обработке вызова вы докладываете “ХХ-ХХ 10-26”, что говорит о том{Enter}{F6}
SmartSleep(2000)
Send, что вызов от гражданского лица обработан и закрыт.{Enter}{F6}
SmartSleep(2000)
Send, В том случае, если по приезду на вызов, на нем не оказалось человека, сделавшего вызов, вызов считается “Ложным”,{Enter}{F6}
SmartSleep(2000)
Send, в таком случае вы докладываете “ХХ-ХХ 10-26ЛВ”.{Enter}{F6}
SmartSleep(2000)
Send, Обработка вызова - это ответственная задача, требующая от сотрудника УГИБДД высокого {Enter}{F6}
SmartSleep(2000)
Send, уровня профессионализма, стрессоустойчивости,{Enter}{F6}
SmartSleep(2000)
Send, знания своих обязанностей и умения действовать в сложных ситуациях.{Enter}{F6}
SmartSleep(2000)
Send, Соблюдение этих правил поможет обеспечить оперативность и эффективность реагирования правоохранительных органов на происшествия,{Enter}{F6}
SmartSleep(2000)
Send, что, в конечном итоге, спасет жизнь и обеспечит безопасность людей.{Enter}{F6}
SmartSleep(2000)
Send, Вопросы по лекции остались?{Enter}{F6}
SmartSleep(2000)
Send, Лекция окончена.{Enter}
Return
:?:/лекция12::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00"Заступление в патруль".{Enter}{F6}
SmartSleep(2000)
Send, Каждый сотрудник, прежде чем заступить в патруль должен быть сыт.{Enter}{F6}
SmartSleep(2000)
Send, У него должно быть оружие. Поправлен быть значок.{Enter}{F6}
SmartSleep(2000)
Send, А также быть исправна машина.{Enter}{F6}
SmartSleep(2000)
Send, Прежде чем выехать из гаража, сотрудник должен доложить в рацию о выезде.{Enter}{F6}
SmartSleep(2000)
Send,  /b тен-код 10-1{Enter}{F6}
SmartSleep(2000)
Send,  /b Пример: 62-17 10-1{Enter}{F6}
SmartSleep(2000)
Send, Во время патруля у него должна происходить съемка с видеорегистратора.{Enter}{F6}
SmartSleep(2000)
Send, Если этого нету, устраните все недочеты и вступаете в патруль.{Enter}{F6}
SmartSleep(2000)
Send,  На этом лекция окончена.{Enter}{F6}
SmartSleep(2000)
Send,  Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция13::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00"Заступление на пост".{Enter}{F6}
SmartSleep(2000)
Send, Каждый сотрудник, прежде чем заступить на пост должен быть сыт.{Enter}{F6}
SmartSleep(2000)
Send, У него должно быть оружие. Поправлен быть значок.{Enter}{F6}
SmartSleep(2000)
Send, Он должен включить съемку на нагрудной камере.{Enter}{F6}
SmartSleep(2000)
Send, Прежде чем заступить на пост, сотрудник должен доложить в рацию о заступлении.{Enter}{F6}
SmartSleep(2000)
Send,  /b тен-код 10-4 Номер поста{Enter}{F6}
SmartSleep(2000)
Send,  /b Пример: 62-17 10-4 Н-3{Enter}{F6}
SmartSleep(2000)
Send, Если этого нет, устраните все недочеты и заступить на пост.{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}{F6}
SmartSleep(2000)
Send, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция14::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00"Правила поведения после окончания рабочего дня".{Enter}{F6}
SmartSleep(2000)
Send, После 20:00 у вас заканчивается рабочий день в будние дни, после 19:00 по субботам,{Enter}{F6}
SmartSleep(2000)
Send, а в воскресенье выходной.{Enter}{F6}
SmartSleep(2000)
Send, Вы можете снять форму и пойти по своим делам.{Enter}{F6}
SmartSleep(2000)
Send, Однако существуют правила поведения на гражданке.{Enter}{F6}
SmartSleep(2000)
Send, Вы все также являетесь сотрудником УГИБДД и не должны это забывать.{Enter}{F6}
SmartSleep(2000)
Send, Вы должны соблюдать УКРП и КоАП Республики Провинция.{Enter}{F6}
SmartSleep(2000)
Send, Также должны соблюдать Конституцию Провинции.{Enter}{F6}
SmartSleep(2000)
Send, То есть, вы не должны лезть в драку.{Enter}{F6}
SmartSleep(2000)
Send, Нецензурно выражаться, грубить и оскорблять других жителей республики Провинция.{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}{F6}
SmartSleep(2000)
Send, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция15::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00"Выписка штрафа".{Enter}{F6}
SmartSleep(2000)
Send, И так, писывать штраф разрешено только лицам, которые нарушили закон.{Enter}{F6}
SmartSleep(2000)
Send, Выписывать штраф нужно согласно статье, которое соответствует нарушению.{Enter}{F6}
SmartSleep(2000)
Send, Категорически запрещено:{Enter}{F6}
SmartSleep(2000)
Send, Придумывать новые статьи.{Enter}{F6}
SmartSleep(2000)
Send, Выписывать штраф, если Вы сами не видели нарушения или не провели расследование.{Enter}{F6}
SmartSleep(2000)
Send, Штраф выдаем по описанию статьи.{Enter}{F6}
SmartSleep(2000)
Send, Например гражданин выполнил опасный занос.{Enter}{F6}
SmartSleep(2000)
Send, Вы его останавливаете по 17.2 КоАП.{Enter}{F6}
SmartSleep(2000)
Send, Выписываете штраф.{Enter}{F6}
SmartSleep(2000)
Send,  /b /tsu ID игрока / сумма / объяснение{Enter}{F6}
SmartSleep(2000)
Send,  /b /tsu 111 30000 17.2 КоАП{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}{F6}
SmartSleep(2000)
Send, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция16::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00"Конвоирование".{Enter}{F6}
SmartSleep(2000)
Send, После того, как вы надели наручники на задержанного{Enter}{F6}
SmartSleep(2000)
Send, И обыскали его, а затем зачитали ему его права вы должны:{Enter}{F6}
SmartSleep(2000)
Send, Произвести действие, такое как как: конвоирование.{Enter}{F6}
SmartSleep(2000)
Send, Оно включает в себя охрану задержанного, а именно:{Enter}{F6}
SmartSleep(2000)
Send, Чтобы он не смог сбежать. Задержанного сажать на заднее место{Enter}{F6}
SmartSleep(2000)
Send, Служебного транспорта, так как между передними и задними местами есть{Enter}{F6}
SmartSleep(2000)
Send, Металлическая сетка, с помощью который задержанный не сможет совершить побег.{Enter}{F6}
SmartSleep(2000)
Send, Произвести нападение, даже находясь в наручниках.{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}{F6}
SmartSleep(2000)
Send, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция17::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00"Обыск".{Enter}{F6}
SmartSleep(2000)
Send, Производить обыск может любой сотрудник, хоть даже Рядовой.{Enter}{F6}
SmartSleep(2000)
Send, Обычные места для проведения обыска:{Enter}{F6}
SmartSleep(2000)
Send, Задержание гражданина, Приём, Блок-пост, Спецоперация.{Enter}{F6}
SmartSleep(2000)
Send, И тому подобное.{Enter}{F6}
SmartSleep(2000)
Send, Также обыск проводится после того, как вы надели наручники.{Enter}{F6}
SmartSleep(2000)
Send, На преступника при задержании. Обыск проводить вне участка Полиции.{Enter}{F6}
SmartSleep(2000)
Send, Так как задержанный может с собой привезти огнестрельное оружие и так далее.{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}{F6}
SmartSleep(2000)
Send, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция18::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00"Вытаскивание подозреваемого из транспорта".{Enter}{F6}
SmartSleep(2000)
Send, Высадка подозреваемого очень серьёзное действие.{Enter}{F6}
SmartSleep(2000)
Send, Но прежде, чем это сделать надо попросить подозреваемого выйти из транспортного средства.{Enter}{F6}
SmartSleep(2000)
Send, Если он отказывается, то вы сначала объявляете его в розыск{Enter}{F6}
SmartSleep(2000)
Send, а потом начинаете ломать стекло двери{Enter}{F6}
SmartSleep(2000)
Send, чтобы открыть замок транспортного средства.{Enter}{F6}
SmartSleep(2000)
Send,  /b Стрелять не нужно{!}{Enter}{F6}
SmartSleep(2000)
Send,  /b В движении не вытаскивать преступника{!}{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}{F6}
SmartSleep(2000)
Send, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция19::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции {#}ffff00"Использование таб. оружия и спец. средств".{Enter}{F6}
SmartSleep(2000)
Send, Применение табельного оружия и специальных средств - это крайняя мера{Enter}{F6}
SmartSleep(2000)
Send, к которой прибегают сотрудники УГИБДД только в случаях, предусмотренных законом{Enter}{F6}
SmartSleep(2000)
Send, для предотвращения преступлений, задержания преступников{Enter}{F6}
SmartSleep(2000)
Send, защиты себя и других людей от опасности.{Enter}{F6}
SmartSleep(2000)
Send, порядок использования оружия и специальных средств сотрудниками полиции{Enter}{F6}
SmartSleep(2000)
Send, определяет Федеральный закон “О полиции”.{Enter}{F6}
SmartSleep(2000)
Send, Применение оружия и спецсредств допускается только в случае необходимости{Enter}{F6}
SmartSleep(2000)
Send, для предотвращения преступления или задержания преступника{Enter}{F6}
SmartSleep(2000)
Send, защиты от опасности для себя или других лиц.{Enter}{F6}
SmartSleep(2000)
Send, Перед применением оружия или спецсредств необходимо предупредить нарушителя{Enter}{F6}
SmartSleep(2000)
Send, о намерении их применить, за исключением случаев{Enter}{F6}
SmartSleep(2000)
Send, когда промедление опасно для жизни и здоровья людей.{Enter}{F6}
SmartSleep(2000)
Send, Алгоритм действий при применении табельного оружия и специальных средств:{Enter}{F6}
SmartSleep(2000)
Send, Определить характер угрозы и степень опасности.{Enter}{F6}
SmartSleep(2000)
Send, Предупредить нарушителя о намерении применить оружие или спец. средства.{Enter}{F6}
SmartSleep(2000)
Send, Выбрать оружие или спецсредство, пропорциональное степени опасности и характеру угрозы.{Enter}{F6}
SmartSleep(2000)
Send, Применить оружие или спецсредства с максимальной точностью и эффективностью,{Enter}{F6}
SmartSleep(2000)
Send, стараясь минимизировать потенциальный ущерб.{Enter}{F6}
SmartSleep(2000)
Send, Оказать необходимую помощь пострадавшим, вызвать скорую помощь{Enter}{F6}
SmartSleep(2000)
Send, или другие службы, если это необходимо.{Enter}{F6}
SmartSleep(2000)
Send, Применение табельного оружия и специальных средств - это крайняя мера{Enter}{F6}
SmartSleep(2000)
Send, к которой сотрудники УГИБДД прибегают только в случаях крайней необходимости.{Enter}{F6}
SmartSleep(2000)
Send, Соблюдение правовых норм и алгоритма действий, а также высокая профессиональная{Enter}{F6}
SmartSleep(2000)
Send, подготовка являются гарантией правомерности и безопасности использования оружия и спецсредств.{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}{F6}
SmartSleep(2000)
Send, Если есть вопросы, задавайте{!}{Enter}
Return
:?:/лекция20:: 
AbortBindFlag := 0
Sendmessage, 0x50,, 0x4190419,, A
Send, {enter}
SmartSleep(50)
Send, {F8}say Лекция на тему {#}ffff00"Терроризм - угроза обществу". {enter}{F8}
SmartSleep(1500)
Send, {F8}say В современном мире эти слова - обыденное. Вот вам пару советов, дабы спасти вашу жизнь. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Обращайте внимание на подозрительных людей, предметы, на любые подозрительные мелочи. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Обо всем подозрительном сообщать сотрудникам правоохранительных органов. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Особенно остерегайтесь людей, одетых явно не по сезону. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Остерегайтесь людей с большими сумками и чемоданами, особенно, если они находятся в месте, не подходящем для такой поклажи. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Будьте внимательны, постарайтесь запомнить приметы подозрительных людей, отличительные черты их лиц... {enter}{F8}
SmartSleep(1500)
Send, {F8}say одежду, имена, клички, возможные шрамы и татуировки, особенности речи и манеры поведения {enter}{F8}
SmartSleep(1500)
Send, {F8}say Старайтесь удалиться на максимальное расстояние от тех, кто ведет себя неадекватно {enter}{F8} 
SmartSleep(1500)
Send, {F8}say нервозно, испуганно, оглядываясь, проверяя что-то в одежде или в багаже. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Если вы не можете удалиться от подозрительного человека, следите за мимикой его лица {enter}{F8}
SmartSleep(1500)
Send, {F8}say Никогда не принимайте от незнакомцев пакеты и сумки, не оставляйте свои сумки без присмотра. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Ознакомьтесь с планом эвакуации, узнайте, где находятся резервные выходы из здания. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Если произошел взрыв, пожар, вы слышите сильный шум и крики – немедленно приступайте к эвакуации. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Возвращайтесь в покинутое помещение только после разрешения ответственных лиц. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Получив сообщение от руководства или правоохранительных органов о начале эвакуации. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Соблюдайте спокойствие и четко выполняйте их команды. Старайтесь не поддаваться панике, что бы ни произошло. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Человеческая жизнь - высшая ценность. Берегите себя{!}{enter}{F8}
SmartSleep(1500)
Send, {F8}say На этом лекция окончена. {enter}{F8}
return
:?:/лекция21:: 
AbortBindFlag := 0
Sendmessage, 0x50,, 0x4190419,, A
Send, {enter}
SmartSleep(50)
Send, {F8}say Лекция на тему {#}ffff00"Дейтсвия при захвате в заложники". {enter}{F8}
SmartSleep(1500)
Send, {F8}say Если ты оказался в заложниках, знай - ты не один. Помни: опытные люди уже спешат к тебе на помощь. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Не пытайся убежать, вырваться самостоятельно - террористы могут отреагировать агрессивно... {enter}{F8}
SmartSleep(1500)
Send, {F8}say Постарайся успокоиться и жди освобождения. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Настройся на долгое ожидание. Специалистам требуется время, чтобы освободить тебя {enter}{F8}
SmartSleep(1500)
Send, {F8}say Постарайся мысленно отвлечься от происходящего: вспоминай содержание книг, художественных фильмов, мультфильмов, решай в уме задачи {enter}{F8}
SmartSleep(1500)
Send, {F8}say Старайся не раздражать террористов: не кричи, не плачь, не возмущайся {enter}{F8}
SmartSleep(1500)
Send, {F8}say Не вступай в споры с террористами, выполняй все их требования {enter}{F8}
SmartSleep(1500)
Send, {F8}say Помни, что, возможно, тебе придётся долгое время провести без воды и пищи - экономь свои силы {enter}{F8}
SmartSleep(1500)
Send, {F8}say Если в помещении душно, постарайся меньше двигаться, чтобы экономнее расходовать кислород. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Помни: если заложник проводит много времени с террористами, ему может показаться, что они вместе, а весь мир - против них {enter}{F8}
SmartSleep(1500)
Send, {F8}say Это очень опасная ошибка! Знай: в любой ситуации террорист - это преступник, а заложник - его жертва{!}{enter}{F8}
SmartSleep(1500)
Send, {F8}say Не всегда переговоры с террористами заканчиваются успешно. {enter}{F8}
SmartSleep(1500)
Send, {F8}say После начала штурма старайся держаться подальше от террористов. {enter}{F8}
SmartSleep(1500)
Send, {F8}say По возможности, спрячься подальше от окон и дверных проёмов {enter}{F8}
SmartSleep(1500)
Send, {F8}say При штурме могут использоваться свето-шумовые гранаты {enter}{F8}
SmartSleep(1500)
Send, {F8}say После освобождения не спеши сразу уйти домой. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Сначала надо связаться с сотрудниками специальных служб и врачами. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Врачи помогут тебе выйти из шока и, если нужно, по их совету ты получишь необходимое лечение. {enter}{F8}
SmartSleep(1500)
Send, {F8}say Помни: после того, как тебя спасли, тебе необходима медицинская помощь. {enter}{F8}
SmartSleep(1500)
Send, {F8}say На этом лекция окончена. {enter}{F8}
return
:?:/лекция22::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции: {#}ffff00"Порядок оформления ДТП".{Enter}{F6}
SmartSleep(2000)
Send, Первоочерёдно сотрудник обязан известить о том, что выехал на вызов{Enter}{F6}
SmartSleep(2000)
Send, Доклад об этом делается в рацию: "XX-XX 10-24"{Enter}{F6}
SmartSleep(2000)
Send, По прибытии на место, сотрудник докладывает в рацию: "XX-XX 10-25"{Enter}{F6}
SmartSleep(2000)
Send, Следующая задача сотрудника - определить участников ДТП и опросить их. Первоочерёдно - выяснить...{Enter}{F6}
SmartSleep(2000)
Send, ...состояние граждан и по необходимости вызвать скорую помощь.{Enter}{F6}
SmartSleep(2000)
Send, Сотрудник обязан доложить о том, что он оформляет ДТП: "XX-XX 10-10 Место"{Enter}{F6}
SmartSleep(2000)
Send, После установления участников ДТП необходимо взять их ВУ и опросить о случившемся.{Enter}{F6}
SmartSleep(2000)
Send, Получив версии произошедшего, убедитесь, что транспортные средства граждан остались нетронутыми.{Enter}{F6}
SmartSleep(2000)
Send, Следом задача сотрудника - установить аварийный знак, если таковой...{Enter}{F6}
SmartSleep(2000)
Send, ...не был установлен участниками ДТП.{Enter}{F6}
SmartSleep(2000)
Send, Если у участников не было знаков или они его не установили,...{Enter}{F6}
SmartSleep(2000)
Send, ...разрешено выписать штраф за нарушение 6.3 КоАП.{Enter}{F6}
SmartSleep(2000)
Send, Если автомобили сдвинули - попросите граждан поставить автомобили так,...{Enter}{F6}
SmartSleep(2000)
Send, ...как они стояли во время ДТП.{Enter}{F6}
SmartSleep(2000)
Send, Если их вернули на место, либо не трогали, сотрудник должен взять фотоаппарат...{Enter}{F6}
SmartSleep(2000)
Send, ...и зафиксировать место ДТП.{Enter}{F6}
SmartSleep(2000)
Send, После фиксации ДТП, сотрудник должен измерить тормозные пути рулеткой...{Enter}{F6}
SmartSleep(2000)
Send, ...и составить схему ДТП на бланке.{Enter}{F6}
SmartSleep(2000)
Send, Фотоаппарат, бланки, рулетка и аварийный знак всегда должны быть у сотрудника.{Enter}{F6}
SmartSleep(2000)
Send, Со слов граждан сотрудник делает пометки на схеме. На этом схема ДТП завершена.{Enter}{F6}
SmartSleep(2000)
Send, Необходимо опросить участников ДТП на предмет наличия видеорегистратора и видеофиксации.{Enter}{F6}
SmartSleep(2000)
Send, Если у кого-то есть видеофиксация, сотрудник должен просмотреть запись и...{Enter}{F6}
SmartSleep(2000)
Send, ...вынести вердикт о нарушениях.{Enter}{F6}
SmartSleep(2000)
Send, Если ни у кого нет видеофиксации, нет видеорегистратора, то необходимо установить...{Enter}{F6}
SmartSleep(2000)
Send, ... виновника ДТП, основываясь на запись с камер.{Enter}{F6}
SmartSleep(2000)
Send, /b Для этого спрашиваете /b Согласны на /try?{Enter}{F6}
SmartSleep(2000)
Send, /b Если обе стороны согласны, то отыгрываете просмотр записей с камер видеонаблюдения.{Enter}{F6}
SmartSleep(2000)
Send, /b УЧТИТЕ{!} Если ДТП произошло в месте, где камер нет (глушь, деревни)...{Enter}{F6}
SmartSleep(2000)
Send, /b ...то установить виновника ДТП вы не сможете.{Enter}{F6}
SmartSleep(2000)
Send, После установки виновника ДТП, сотрудник обязан составить протоколы...{Enter}{F6}
SmartSleep(2000)
Send, ...для каждого из водителей, со всеми их нарушениями.{Enter}{F6}
SmartSleep(2000)
Send, После подписания протоколов гражданами, сотрудник выписывает штрафы и аннулирует ВУ,...{Enter}{F6}
SmartSleep(2000)
Send, ...если того требует закон.{Enter}{F6}
SmartSleep(2000)
Send, В конце сотрудник обязан указать виновнику ДТП, что он обязан...{Enter}{F6}
SmartSleep(2000)
Send, ...оплатить ремонт пострадавшей стороне согласно 2.3.5 ПДД.{Enter}{F6}
SmartSleep(2000)
Send, Если гражданин не может оплатить компенсацию ввиду отсутствия денег,...{Enter}{F6}
SmartSleep(2000)
Send, ...сотрудник должен выплатить из своего кармана.{Enter}{F6}
SmartSleep(2000)
Send, Оформление ДТП завершается возвратом ВУ водителям и докладами в рацию "XX-XX 10-10-1"...{Enter}{F6}
SmartSleep(2000)
Send, ...и "XX-XX 10-26 ДТП".{Enter}{F6}
SmartSleep(2000)
Send, Остались вопросы по лекции?{Enter}{F6}
SmartSleep(2000)
Send, На этом лекция окончена.{Enter}
Return
:?:/лекция23::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Тема лекции: {#}ffff00"Основания".{Enter}{F6}
SmartSleep(2000)
Send, В Республике Провинция зачастую можно встретить граждан, которые не знают законов.{Enter}{F6}
SmartSleep(2000)
Send, Либо же тех, кому нравится заставлять сотрудников ломаться и...{Enter}{F6}
SmartSleep(2000)
Send, ...судорожно лезть в подсказки в поисках ответа на вопрос...{Enter}{F6}
SmartSleep(2000)
Send, .."А на каком основании?"{Enter}{F6}
SmartSleep(2000)
Send, Права и обязанности сотрудников полиции прописаны в...{Enter}{F6}
SmartSleep(2000)
Send, ..Федеральном Законе о Полиции, далее ФЗоП.{Enter}{F6}
SmartSleep(2000)
Send, Вы должны знать, что обязаны делать и на что имеете право в пределах своих полномочий.{Enter}{F6}
SmartSleep(2000)
Send, ФЗоП создан, чтобы регулировать права и обязанности сотрудников.{Enter}{F6}
SmartSleep(2000)
Send, Однако если же вы встретили гражданина, который на каждое ваше слово...{Enter}{F6}
SmartSleep(2000)
Send, ..или действие спрашивает "На каком основании?"{Enter}{F6}
SmartSleep(2000)
Send, Вы должны отвечать грамотно и чётко излагать свои мысли. Пример:{Enter}{F6}
SmartSleep(2000)
Send, Гражданин спрашивает: "На каком основании вы проверяете документы?"{Enter}{F6}
SmartSleep(2000)
Send, Вы должны ответить не просто цифрами.{Enter}{F6}
SmartSleep(2000)
Send, "На основании 3.9.1.2 ФЗоП" - НЕ правильно.{Enter}{F6}
SmartSleep(2000)
Send, Следует отвечать вот так: "Согласно 3.9.1.2 Федерального закона о полиции...{Enter}{F6}
SmartSleep(2000)
Send, ..я, как сотрудник полиции, имею правопроверять документы у граждан...{Enter}{F6}
SmartSleep(2000)
Send, ..если имеются данные, дающие основания подозревать их в совершении преступления,..{Enter}{F6}
SmartSleep(2000)
Send, ..или полагать что они находятся в розыске, либо имеется повод к...{Enter}{F6}
SmartSleep(2000)
Send, ..возбуждению дела об административном правонарушении, а также...{Enter}{F6}
SmartSleep(2000)
Send, ..проверять наличие неоплаченных штрафов, если есть основания подозревать их наличие.{Enter}{F6}
SmartSleep(2000)
Send, Можно и покороче. Главное донести основную суть и правоту ваших действий.{Enter}{F6}
SmartSleep(2000)
Send, Однако сотрудник в принципе не обязан объяснять гражданам...{Enter}{F6}
SmartSleep(2000)
Send, ..свои права и обязанности, так как ФЗоП находится в открытом доступе.{Enter}{F6}
SmartSleep(2000)
Send, И ничто не ограничивает граждан в ознакомлении с правами и обязанностями сотрудников полиции.{Enter}{F6}
SmartSleep(2000)
Send, К тому же, процедура проверки документов водителей не затрагивает...{Enter}{F6}
SmartSleep(2000)
Send, ..их права и свободы, т.к. передача документов сотрудникам...{Enter}{F6}
SmartSleep(2000)
Send, ..является их обязанностью, согласно 2.1.1 ПДД.{Enter}{F6}
SmartSleep(2000)
Send, С правами и обязанностями сотрудников полиции вы можете...{Enter}{F6}
SmartSleep(2000)
Send, ..ознакомиться на государственном портале в разделе МВД.{Enter}{F6}
SmartSleep(2000)
Send, Вопросы по лекции остались?{Enter}{F6}
SmartSleep(2000)
Send, Лекция окончена.{Enter}
Return


:?:/собес1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Здравствуйте{!} В целях Вашей и моей безопасности. {Enter}{F6}
SmartSleep(1000)
Send, Все собеседование будет записываться на нагрудную камеру. {Enter}{F6}
SmartSleep(1000)
Send, /do На нагрудном кармане закреплена камера. {Enter}
Return
:?:/собес2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Скажите Ваше ФИО, ваш возраст, сколько лет Вы проживаете в республике?{Enter}{F6}
SmartSleep(250)
Send, И какое у вас образование?{Enter}
Return
:?:/собес3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Можно пожалуйста Ваш паспорт?{Enter}
Return
:?:/собес4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Отлично, дайте мне Вашу трудовую книгу.{Enter}
Return
:?:/собес5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Отлично, дайте мне Ваш диплом.{Enter}
Return
:?:/собес6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Отлично, дайте мне Ваше водительское удостоверение.{Enter}
Return
:?:/собес7::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Отлично, дайте мне Вашу медицинскую карту.{Enter}
Return
:?:/собес8::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Отлично, дайте мне Ваш военный билет.{Enter}
Return
:?:/собес9::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Random, Var, 1, 3
TextArray := ["Что такое ДМ?"
, "Что такое СК?"
, "Что такое ТК?"]
Send, {F6}
SmartSleep(250)
Send, % TextArray[Var]
Send, {Enter}
Return
:?:/собес10::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Random, Var, 1, 3
TextArray := ["Что такое РП?"
, "Что такое МГ?"
, "Что такое ПГ?"]
Send, {F6}
SmartSleep(250)
Send, % TextArray[Var]
Send, {Enter}
Return
:?:/собес11::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Random, Var, 1, 3
TextArray := ["Что такое ВХ?"
, "Что такое ДБ?"
, "Что такое БХ?"]
Send, {F6}
SmartSleep(250)
Send, % TextArray[Var]
Send, {Enter}
Return
:?:/собес12::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Random, Var, 1, 3
TextArray := ["Что такое МК?"
, "Что такое ВК?"
, "Что такое Дискорд?"]
Send, {F6}
SmartSleep(250)
Send, % TextArray[Var]
Send, {Enter}
Return
:?:/собес13::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Отлично, подождите минуточку.{Enter}
Return
:?:/собес14::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Random, Var, 1, 4
TextArray := ["/b ДБ МГ РП РПК ТК с расшифровкой и что означает"
, "/b БХ ДМ РП СК ТК с расшифровкой и что означает"
, "/b ДБ МГ ПГ ТЛ РП с расшифровкой и что означает"
, "/b ДМ РП РПК СК ТК с расшифровкой и что означает"]
Send, {F6}
SmartSleep(250)
Send, % TextArray[Var]
Send, {Enter}
Return
:?:/собес15::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Присядьте на корточки{Enter}
Return
:?:/собес16::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Random, Var, 1, 4
TextArray := ["/b Вставайте или не приму!"
, "/b Вставайте!"
, "/b Вставайте дам 5 ранг!"
, "/b Вставайте, дам 10к"]
Send, {F6}
SmartSleep(150)
Send, % TextArray[Var]
Send, {Enter}
Return
:?:/собес17::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Вставайте{Enter}
Return
:?:/собес18::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Что у меня в руке?{Enter}
Return
:?:/отказ::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, К сожалению вам отказано в трудоустройстве.{Enter}{F6}
SmartSleep(250)
Send, /b У вас были некоторые ошибки при отыгрывании команд me, do. Поэтому стоит немного подучить их{Enter}{F6}
SmartSleep(1000)
Send, /b https://vk.cc/c3UAyw(Скопировать в F8) Там есть вся информация по поводу отыгровок.{Enter}
Return
:?:/папка1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, /me взяв папку, начал%ok1% изучать документы{Enter}
Return
:?:/папка2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, /do Документы изучены.{Enter}{F6}
SmartSleep(250)
Send, /me изучив документы, сложил%ok1% их обратно, затем передал%ok1% гражданину напротив{Enter}{F6}
SmartSleep(250)
Send, Держите вашу папку.{Enter}
Return
:?:/пасс1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me взял%ok1% паспорт у человека напротив{Enter}{F6}
SmartSleep(1000)
Send, /do Паспорт в руке.{Enter}{F6}
SmartSleep(1000)
Send, /me открыл%ok1% нужную страницу в паспорте и начал%ok1% его изучать{Enter}{F6}
SmartSleep(1000)
Send, /do Паспорт изучен.{Enter}{F6}
SmartSleep(1000)
Send, /me закрыл%ok1% паспорт и передал%ok1% его человеку напротив{Enter}{F6}
SmartSleep(1000)
Send, /do Рука протянута.{Enter}{F6}
SmartSleep(1000)
Send, Держите ваш паспорт.{Enter}
Return
:?:/диплом1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me взял%ok1% диплом у человека напротив{Enter}{F6}
SmartSleep(1000)
Send, /do Диплом в руке.{Enter}{F6}
SmartSleep(1000)
Send, /me начал%ok1% изучать диплом{Enter}{F6}
SmartSleep(1000)
Send, /do Диплом изучен.{Enter}{F6}
SmartSleep(1000)
Send, /me передал%ok1% диплом человеку напротив{Enter}{F6}
SmartSleep(1000)
Send, /do Рука протянута.{Enter}{F6}
SmartSleep(1000)
Send, Держите ваш диплом.{Enter}
Return
:?:/труд1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me взял%ok1% трудовую книгу{Enter}{F6}
SmartSleep(1000)
Send, /do Трудовая книга в руке.{Enter}{F6}
SmartSleep(1000)
Send, /me открыл%ok1% нужную страницу и изучил%ok1% информацию{Enter}{F6}
SmartSleep(1000)
Send, /do Трудовая изучена.{Enter}{F6}
SmartSleep(1000)
Send, /me закрыл%ok1% трудовую книгу и передал%ok1% человеку{Enter}{F6}
SmartSleep(1000)
Send, /do Рука протянута.{Enter}{F6}
SmartSleep(1000)
Send, Держите вашу трудовую книгу.{Enter}
Return
:?:/ву1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me взял%ok1% водительское удостоверение у человека напротив{Enter}{F6}
SmartSleep(1000)
Send, /do Водительское удостоверение в руке.{Enter}{F6}
SmartSleep(1000)
Send, /me открыл%ok1% нужную страницу в водительском удостоверении и начал%ok1% его изучать{Enter}{F6}
SmartSleep(1000)
Send, /do Водительское удостоверение изучено.{Enter}{F6}
SmartSleep(1000)
Send, /me закрыл%ok1% водительское удостоверение и передал%ok1% его человеку напротив{Enter}{F6}
SmartSleep(1000)
Send, /do Рука протянута.{Enter}{F6}
SmartSleep(1000)
Send, Держите ваше водительское удостоверение.{Enter}
Return
:?:/карта1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me взял%ok1% медицинскую карту у человека напротив{Enter}{F6}
SmartSleep(1000)
Send, /do Медицинская карта в руке.{Enter}{F6}
SmartSleep(1000)
Send, /me открыл%ok1% нужную страницу в медицинской карте и начал%ok1% ее изучать{Enter}{F6}
SmartSleep(1000)
Send, /do Медицинская карта изучена.{Enter}{F6}
SmartSleep(1000)
Send, /me закрыл%ok1% медицинскую карту и передал%ok1% его человеку напротив{Enter}{F6}
SmartSleep(1000)
Send, /do Рука протянута.{Enter}{F6}
SmartSleep(1000)
Send, Держите вашу медицинскую карту.{Enter}
Return
:?:/вб1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me взял%ok1% военный билет у человека напротив{Enter}{F6}
SmartSleep(1000)
Send, /do Военный билет в руке.{Enter}{F6}
SmartSleep(1000)
Send, /me открыл%ok1% нужную страницу в военном билете и начал%ok1% его изучать{Enter}{F6}
SmartSleep(1000)
Send, /do Военный билет изучен.{Enter}{F6}
SmartSleep(1000)
Send, /me закрыл%ok1% военный билет и передал%ok1% его человеку напротив{Enter}{F6}
SmartSleep(1000)
Send, /do Рука протянута.{Enter}{F6}
SmartSleep(1000)
Send, Держите ваш военный билет.{Enter}
Return
:?:/выдформу::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do В шкафчике находится форма сотрудника.{Enter}{F6}
SmartSleep(500)
Send, /do Шкаф закрыт.{Enter}{F6}
SmartSleep(500)
Send, /do Ключ лежит на столе.{Enter}{F6}
SmartSleep(500)
Send, Берите ключ, открывайте шкаф, переодевайтесь.{Enter}
Return
:?:/мвд::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][МВД]{Space}
Return
:?:/угибдд::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][УГИБДД]{Space}
Return
:?:/ржд::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /d [%Gibdd%][ОАО «РЖД»]{Space}
Return
:?:/мз::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /d [%Gibdd%][МЗ]{Space}
Return
:?:/мо::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /d [%Gibdd%][МО]{Space}
Return
:?:/угибддп::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][УГИБДД-П]{Space}
Return
:?:/угибддм::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][УГИБДД-М]{Space}
Return
:?:/угибддн::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][УГИБДД-Н]{Space}
Return
:?:/гумвдп::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][ГУ МВД-П]{Space}
Return
:?:/гумвдм::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][ГУ МВД-М]{Space}
Return
:?:/гумвдн::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][ГУ МВД-Н]{Space}
Return
:?:/цгбп::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /d [%Gibdd%][ЦГБ-П]{Space}
Return
:?:/окбм::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /d [%Gibdd%][ОКБ-М]{Space}
Return
:?:/цгбн::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /d [%Gibdd%][ЦГБ-Н]{Space}
Return
:?:/помощьсобес::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
IniRead, Frak, %A_Temp%\gibdd.egl, User, Frak
    ; Определяем название по городу
    if (Frak = "Невский")
        Park := "Н"
    else if (Frak = "Мирный")
        Park := "М"
    else if (Frak = "Приволжск")
        Park := "П"
    else
        Badge := "Данные" ; Значение по умолчанию, если город не совпадает с известными
    ; Отправляем приветственное сообщение
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(160)
Send, /d [%Gibdd%][МВД|МЗ|МО] Требуются сотрудники для помощи в проведении собеседования...{Enter}{F6}
SmartSleep(500)
Send, /d [%Gibdd%][МВД|МЗ|МО] ...Ожидаем на парковке ДЧ-%Park%.{Enter}{F6}
SmartSleep(160)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/зосн::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(250)
Send, /Введите букву города(П, М или Н) ->{Space}
Input, choice, V, {Enter}
if (choice = "П" or choice = "п" or choice = "G" or choice = "g")
    Gorod := "СОБР"
else if (choice = "М" or choice = "м" or choice = "V" or choice = "v")
    Gorod := "ОСпН {""}Гром{""}"
else if (choice = "Н" or choice = "н" or choice = "Y" or choice = "y")
    Gorod := "ЦСН {""}Барс{""}"
else
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(200)
Send, /ro [%Gibdd%][%Gorod%] {Space}
Return
:?:/прозыск::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
Send, {F6}
SmartSleep(250)
Send, /Введите серию паспорта (через дефис) ->{Space}
Input, Pass, V, {Enter}
Send, {bs 17}
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send,  /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send,  /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
Send, /ro [%Gibdd%][МВД] Проверьте гражданина с серией паспорта %Pass%...{Enter}{F6}
SmartSleep(500)
Send, /ro [%Gibdd%][МВД] ...на наличие в базе розыска.{Enter}{F6}
SmartSleep(160)
PlayRadioSfx("radio_start.wav")
SmartSleep(1000)
Send, /me отпустил%ok1% кнопку и закрепил%ok1% рацию на нагрудном кармане{Enter}
Return
:?:/стук::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(100)
Send, {Enter}
SmartSleep(250)
Send, {F8}me постучал%ok1% в окно{Enter}{F8}
Return
Bind_KnockWindow:
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
SmartSleep(250)
Send, {F8}me постучал%ok1% в окно{Enter}{F8}
Return
:?:/окно?::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send,  /do Водительское окно открыто?{Enter}
Return
:?:/ударкалаш::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send,  /me замахнул%ok3% прикладом АК-74м{Enter}{F6}
SmartSleep(200)
Send,  /try разбил%ok1% окно{Enter}
Return
:?:/ударпистолет::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send,  /me замахнул%ok3% рукоятью пистолета{Enter}{F6}
SmartSleep(200)
Send,  /try разбил%ok1% окно{Enter}
Return
:?:/удардробовик::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send,  /me замахнул%ok3% прикладом дробовика{Enter}{F6}
SmartSleep(200)
Send,  /try разбил%ok1% окно{Enter}
Return

:?:/разбор1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Fio1, %A_Temp%\gibdd.egl, User, Fio1
IniRead, Rank, %A_Temp%\gibdd.egl, User, Rank
StringSplit, FioParts, Fio1, %A_Space% 
Surname := FioParts1
Send, {Enter}
SmartSleep(50)
Send,{F8}say Я, %Rank% %Surname%, приступаю к разборке автомата Калашникова.{Enter}{F8}
SmartSleep(1000)
Send,{F8}me отделил%ok2% магазин{Enter}{F8}
SmartSleep(1000)
Send,{F8}me проверил%ok2% на наличие патрона в патроннике{Enter}{F8}
SmartSleep(1000)
Send,{F8}me вынул%ok2% пенал с принадлежностями из гнезда приклада{Enter}{F8}
SmartSleep(1000)
Send,{F8}me отделил%ok2% шомпол{Enter}{F8}
SmartSleep(1000)
Send,{F8}me отделил%ok2% у автомата дульный тормоз-компенсатор{Enter}{F8}
SmartSleep(1000)
Send,{F8}me отделил%ok2% крышку ствольной коробки{Enter}{F8}
SmartSleep(1000)
Send,{F8}me отделил%ok2% возвратный механизм{Enter}{F8}
SmartSleep(1000)
Send,{F8}me отделил%ok2% затворную раму с затвором{Enter}{F8}
SmartSleep(1000)
Send,{F8}me отделил%ok2% затвор от затворной рамы{Enter}{F8}
SmartSleep(1000)
Send,{F8}me отделил%ok2% газовую трубку со ствольной накладкой{Enter}{F8}
SmartSleep(1000)
Send,{F8}say Я, %Rank% %Surname% разборку автомата Калашникова закончил%ok2%.{Enter}{F8}
Return

:?:/разбор2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Fio1, %A_Temp%\gibdd.egl, User, Fio1
IniRead, Rank, %A_Temp%\gibdd.egl, User, Rank
StringSplit, FioParts, Fio1, %A_Space% 
Surname := FioParts1
Send, {Enter}
SmartSleep(50)
Send,{F8}say Я, %Rank% %Surname% приступаю к сборке автомата Калашникова.{Enter}{F8}
SmartSleep(1000)
Send,{F8}me присоединил%ok2% газовую трубку со ствольной накладкой{Enter}{F8}
SmartSleep(1000)
Send,{F8}me присоединил%ok2% затвор к затворной раме{Enter}{F8}
SmartSleep(1000)
Send,{F8}me присоединил%ok2% затворную раму с затвором к ствольной коробке{Enter}{F8}
SmartSleep(1000)
Send,{F8}me присоединил%ok2% возвратный механизм{Enter}{F8}
SmartSleep(1000)
Send,{F8}me присоединил%ok2% крышку ствольной коробки{Enter}{F8}
SmartSleep(1000)
Send,{F8}me спустил%ok2% курок с боевого взвода, после поставил%ok2% на предохранитель{Enter}{F8}
SmartSleep(1000)
Send,{F8}me присоединил%ok2% к автомату дульный тормоз-компенсатор{Enter}{F8}
SmartSleep(1000)
Send,{F8}me присоединил%ok2% шомпол{Enter}{F8}
SmartSleep(1000)
Send,{F8}me вложил%ok2% пенал с принадлежностями в гнездо приклада{Enter}{F8}
SmartSleep(1000)
Send,{F8}me присоединил%ok2% магазин к автомату{Enter}{F8}
SmartSleep(1000)
Send,{F8}say Я %Rank% %Surname% закончил%ok2% сборку автомата Калашникова.{Enter}{F8}
Return

:?:/выдпогоны::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /Введите погоны должности ->{Space}
Input, Var1, V, {Enter} 
Send, {bs 17} 
SmartSleep(250)
Send, {F6}
SmartSleep(1000)
Send, /do В багажнике лежат погоны "%var1%". {Enter}{F6}
SmartSleep(1000)
Send, Берите из багажника новые погоны, и прикрепите их на плечи{!}{Enter}
Return

:?:/пмедкарта::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
IniRead, Gibdd, %A_Temp%\gibdd.egl, User, Gibdd
SmartSleep(250)
Send, {F6}
SmartSleep(500)
Send, /Кому продлить медкарту?(ид пишете 0-0-0) ID ->{Space}
Input, id, V, {Enter}
Send, {bs 17}
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, /do Рация ТАКТ-363 П45 закреплена на нагрудном кармане.{Enter}{F6}
SmartSleep(500)
Send, /me сняв рацию, подн%ok9% ко рту и нажал%ok1% кнопку для переговоров{Enter}{F6}
SmartSleep(500)
PlayRadioSfx("radio_start.wav")
SmartSleep(500)
IniRead, Teg, %A_Temp%\gibdd.egl, User, Teg
Send, /d [%Gibdd%][МЗ] Требуется продление медкарты для сотрудника с серией паспорта %id%.{Enter}
Return

:?:/кпкповышение::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /Введите ID сотрудника которого хотите повысить ->{Space}
Input, Var1, V, {Enter}
Send, {bs 17}
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, /Введите номер должности ->{Space}
Input, Var2, V, {Enter}
Send, {bs 17}
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, /do Служебный планшет марки “MIG LT11i” в сумке.{Enter}{F6}
SmartSleep(800)
Send, /me достав служебный планшет из сумки, запустил%ok1% его{Enter}{F6}
SmartSleep(1700)
Send, /me вв%ok8% данные об повышении сотрудника {Enter}{F6}
SmartSleep(1700)
Send, /me выключил%ok1% служебный планшет и убрал%ok1% в сумку{Enter}{F6}
SmartSleep(250)
Send, /giverank %Var1% %Var2%{Enter}{F6}
SmartSleep(250)
Send, /timestamp {Enter}
SmartSleep(500)
Return
:?:/кпкпонижение::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /Введите ID сотрудника которого хотите понизить ->{Space}
Input, Var1, V, {Enter}
Send, {bs 17}
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, /Введите номер должности ->{Space}
Input, Var2, V, {Enter}
Send, {bs 17}
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, /do Служебный планшет марки “MIG LT11i” в сумке.{Enter}{F6}
SmartSleep(800)
Send, /me достав служебный планшет из сумки, запустил%ok1% его{Enter}{F6}
SmartSleep(1700)
Send, /me вв%ok8% данные об понижении сотрудника {Enter}{F6}
SmartSleep(1700)
Send, /me выключил%ok1% служебный планшет и убрал%ok1% в сумку{Enter}{F6}
SmartSleep(250)
Send, /giverank %Var1% %Var2%{Enter}
SmartSleep(250)
Return
:?:/кпкувал::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /Введите ID сотрудника которого хотите уволить ->{Space}
Input, Var, V, {Enter}
Send, {bs 17}
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, /do Служебный планшет марки “MIG LT11i” в сумке.{Enter}{F6}
SmartSleep(800)
Send, /me достав служебный планшет из сумки, запустил%ok1% его{Enter}{F6}
SmartSleep(800)
Send, /me запустил%ok1% приложение БД{Enter}{F6}
SmartSleep(800)
Send, /do Приложение "База Данных" включено.{Enter}{F6}
SmartSleep(800)
Send, /me удалил%ok1% всю информацию о сотруднике и перенес%ok2% его в лист "Уволенные"{Enter}{F6}
SmartSleep(800)
Send, /do Информация о сотруднике удалена.{Enter}{F6}
SmartSleep(800)
Send, /me выключил%ok1% служебный планшет и убрал%ok1% в сумку{Enter}
SmartSleep(800)
Return
:?:/кпкпринятие::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /Введите ID сотрудника которого хотите принять ->{Space}
Input, Var1, V, {Enter}
Send, {bs 17}
SmartSleep(250)
Send, {F6}
SmartSleep(250)
Send, /do Служебный планшет марки “MIG LT11i” в сумке. {Enter}{F6}
SmartSleep(800)
Send, /me достав служебный планшет из сумки, запустил%ok1% его {Enter}{F6}
SmartSleep(800)
Send, /me запустил%ok1% приложение БД {Enter}{F6}
SmartSleep(800)
Send, /do Приложение "База Данных" включено. {Enter}{F6}
SmartSleep(800)
Send, /me занес%ok2% информацию о сотруднике и перенес%ok2% его в лист "Принятые" {Enter}{F6}
SmartSleep(800)
Send, /do Информация о сотруднике занесена. {Enter}{F6}
SmartSleep(800)
Send, /me выключил%ok1% служебный планшет и убрал%ok1% в сумку {Enter}{F6}
SmartSleep(800)
Send, /invite %Var1% {Enter}
Return
:?:/пмп1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(250)
Send, {F8} do Аптечка ПМП "ФЭСТ" находится в багажнике автомобиля.{Enter}{F8}
SmartSleep(500)
Send, {F8} me взял%ok2% аптечку из багажника{Enter}{F8}
SmartSleep(500)
Send, {F8} do Аптечка ПМП "ФЭСТ" в руке.{Enter}{F8}
Return
:?:/пмп2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(250)
Send, {F8} do Что случилось с пострадавшим?{Enter}{F8}
SmartSleep(500)
Send, {F8} b Напишите в чат через команду /do, что с вами случилось{Enter}{F8}
SmartSleep(500)
Send, {F8} b Пример: /do Пострадавшего сбила машина.{Enter}{F8}
Return
:?:/пмп3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(250)
Send, {F8} me поднес%ok2% руку к сонной артерии гражданина{Enter}{F8}
SmartSleep(500)
Send, {F8} do Рука поднесена к сонной артерии пациента.{Enter}{F8}
SmartSleep(500)
Send, {F8} do Пульс обнаружен?{Enter}{F8}
SmartSleep(500)
Send, {F8} b Ответьте РП отыгровкой в чат: /do Да. или /do Нет.{Enter}{F8}
SmartSleep(500)
Send, {F8} b Чат открывается на клавишу T и туда прописываются эти команды.{Enter}{F8}
Return
:?:/пмп4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(250)
Send, {F8} do Аптечка ПМП "ФЭСТ" в руке.{Enter}{F8}
SmartSleep(500)
Send, {F8} me поставил%ok1% аптечку на землю, открыл%ok1% её{Enter}{F8}
SmartSleep(500)
Send, {F8} do Аптечка ПМП "ФЭСТ" открыта.{Enter}{F8}
Return
:?:/пмп5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(250)
Send, {F8} me достал%ok2% спирт и вату из аптечки{Enter}{F8}
SmartSleep(500)
Send, {F8} do Спирт и кусочек ваты в руках.{Enter}{F8}
SmartSleep(500)
Send, {F8} me смочив вату нашатырным спиртом, пров%ok7% ею около носа пострадавшего{Enter}{F8}
SmartSleep(500)
Send, {F8} me откинув использованный кусочек ваты на землю, поставил%ok2% спирт в аптечку{Enter}{F8}
SmartSleep(500)
Send, {F8} do Нашатырный спирт в Аптечке ПМП "ФЭСТ".{Enter}{F8}
SmartSleep(500)
Send, {F8} me закрыв аптечку, взял%ok1% её в руку{Enter}{F8}
SmartSleep(500)
Send, {F8} do Аптечке ПМП "ФЭСТ" в руке.{Enter}{F8}
SmartSleep(500)
Send, {F8} do Пострадавший пришёл в сознание?{Enter}{F8}
SmartSleep(500)
Send, {F8} b Ответьте РП отыгровкой в чат: /do Да. или /do Нет.{Enter}{F8}
SmartSleep(500)
Send, {F8} b Чат открывается на клавишу T и туда прописываются эти команды.{Enter}{F8}
Return
:?:/пмп6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {Enter}
SmartSleep(250)
Send, {F8} do Аптечка ПМП "ФЭСТ" в руке.{Enter}{F8}
SmartSleep(500)
Send, {F8} me положил%ok2% аптечку в багажник{Enter}{F8}
Return
:?:/оранения::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me начал%ok1% осматривать тело пострадавшего{Enter}{F6}
SmartSleep(1700)
Send, /do Сотрудни%ok5% осматривает всё тело пострадавшего.{Enter}{F6}
SmartSleep(1700)
Send, /do Какие ранения и травмы имеются на теле?{Enter}{F6}
SmartSleep(1000)
Send, /b Ответьте РП отыгровкой /do в чат. Можете написать про ссадины, порезы, ушибы. {Enter}{F6}
SmartSleep(1000)
Send, /b Пример: /do На теле пострадавшего ножевое ранение; /do На теле пострадавшего кровотечение.{Enter}
Return
:?:/массаж::
AbortBindFlag := 0
Send, {F6}
SmartSleep(250)
Send, /me проводит непрямой массаж сердца пострадавшему, надавливая на грудную клетку {Enter}{F6}
SmartSleep(1000)
Send, /do Сотрудни%ok5% выполняет непрямой массаж сердца. {Enter}
Return
:?:/пулевое::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do В аптечке лежат жгут, шприц с обезболивающим, ватка и медицинский спирт.{Enter}{F6}
SmartSleep(500)
Send, /me открыл%ok1% аптечку и достал%ok1% из нее жгут{Enter}{F6}
SmartSleep(500)
Send, /me развязав жгут, надел%ok1% его чуть выше пулевого отверстия{Enter}{F6}
SmartSleep(500)
Send, /me затянул%ok1% ремешок жгута{Enter}{F6}
SmartSleep(500)
Send, /do Жгут затянут.{Enter}
Return
:?:/переломз::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do В аптечке лежат шина, бинт и холодный компресс.{Enter}{F6}
SmartSleep(500)
Send, /me вытащил%ok1% из аптечки шину и бинт{Enter}{F6}
SmartSleep(500)
Send, /me застегнул%ok1% шину на поврежденной конечности пострадавшего{Enter}{F6}
SmartSleep(500)
Send, /do Шина застегнута.{Enter}{F6}
SmartSleep(500)
Send, /me достал%ok1% из медицинской сумки холодный компресс{Enter}{F6}
SmartSleep(500)
Send, /me приложил%ok1% компресс к поврежденной конечности пострадавшего{Enter}{F6}
SmartSleep(500)
Send, /do Компрессор наложен.{Enter}
Return
:?:/переломо::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do В аптечке лежат жгут, вата, спиртовой раствор йода и шина.{Enter}{F6}
SmartSleep(500)
Send, /me открыл%ok1% аптечку и достал%ok1% из нее жгут{Enter}{F6}
SmartSleep(500)
Send, /me наложил%ok1% жгут выше раны пострадавшего{Enter}{F6}
SmartSleep(500)
Send, /me достал%ok1% из медицинской сумки вату и спиртовой раствор йода{Enter}{F6}
SmartSleep(500)
Send, /me смочил%ok1% ватку йодом{Enter}{F6}
SmartSleep(500)
Send, /do Ватка смоченная йодом.{Enter}{F6}
SmartSleep(500)
Send, /me обработал%ok1% рану ватой{Enter}{F6}
SmartSleep(500)
Send, /do Рана обработана.{Enter}{F6}
SmartSleep(500)
Send, /me вытащил%ok1% из аптечки шину и бинт{Enter}{F6}
SmartSleep(500)
Send, /me застегнул%ok1% шину на поврежденной конечности пострадавшего.{Enter}{F6}
SmartSleep(500)
Send, /do Шина застегнута.{Enter}
Return
:?:/ушиб::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do В аптечке лежат холодный компресс, гепариновая мазь и бинт.{Enter}{F6}
SmartSleep(500)
Send, /me открыл%ok1% аптечку и достал%ok1% из нее холодный компресс{Enter}{F6}
SmartSleep(500)
Send, /me приложил%ok1% компресс к месту ушиба пострадавшего{Enter}{F6}
SmartSleep(500)
Send, /me достал%ok1% из аптечки гепариновую мазь{Enter}{F6}
SmartSleep(500)
Send, /me намазал%ok1% место ушиба гепариновой мазью{Enter}{F6}
SmartSleep(500)
Send, /me достал%ok1% из аптечки бинт{Enter}{F6}
SmartSleep(500)
Send, /me наложил%ok1% повязку на место ушиба{Enter}{F6}
SmartSleep(500)
Send, /do Повязка наложена.{Enter}
Return
:?:/кровь::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do В аптечке лежат бинты.{Enter}{F6}
SmartSleep(500)
Send, /me достал%ok1% две упаковки бинтов{Enter}{F6}
SmartSleep(500)
Send, /me открыв бинты, отбросил%ok1% упаковку на землю{Enter}{F6}
SmartSleep(500)
Send, /me приложил%ok1% один валик к месту ранения{Enter}{F6}
SmartSleep(500)
Send, /me размотав второй валик бинта, наложил%ok1% его на место ранения{Enter}{F6}
SmartSleep(500)
Send, /do Давящая повязка наложена.{Enter}
Return
:?:/пульс-::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me проводит непрямой массаж сердца пострадавшему, надавливая на грудную клетку {Enter}{F6}
SmartSleep(1000)
Send, /do Сотрудни%ok5% выполняет непрямой массаж сердца. {Enter}{F6}
SmartSleep(1000)
Send, /me прислонил%ok1% руку к сонной артерии гражданина {Enter}{F6}
SmartSleep(1000)
Send, /do Пульс обнаружен? {Enter}{F6}
SmartSleep(1000)
Send, /b Ответьте РП отыгровкой в чат: /do Да. или /do Нет. {Enter}
Return
:?:/ожог::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /me достал%ok1% из сумки мед.ножницы {Enter}{F6}
SmartSleep(1000)
Send, /me используя ножницы, освободил%ok1% обожжённый участок кожи от одежды {Enter}{F6}
SmartSleep(1000)
Send, /me достав из сумки спрей "Олазоль", открыл%ok1% его колпачок {Enter}{F6}
SmartSleep(1000)
Send, /me сбрызнул%ok1% спреем обгоревшие участки кожи, закрыл%ok1% спрей {Enter}{F6}
SmartSleep(1000)
Send, /me убрав его в сумку, достал%ok1% из неё бинты {Enter}{F6}
SmartSleep(1000)
Send, /me наложил%ok1% повязку из бинтов на ожог {Enter}{F6}
SmartSleep(1000)
Send, /do Повязка крепко сидит на ожоге.​ {Enter}
Return

:?:/камера::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, /do Видеорегистратор "DOZOR" весит на груди сотрудни%ok4%.{Enter}{F6}
SmartSleep(250)
Send, /me протянувшись к камере, нажал%ok1% кнопку и запустил%ok1% видеозапись{Enter}{F6}
SmartSleep(250)
Send, /do Видеорегистратор "DOZOR" издал короткий сигнал.{Enter}{F6}
SmartSleep(250)
Send, /do Индикатор сменился с красного на мигающий зелёный.{Enter}
Return

:?:/пдд211::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, Иметь при себе и по требованию служащих полиции передавать им, для проверки{Enter}{F6}
SmartSleep(250)
Send, водительское удостоверение на право управления транспортным средством соответствующей категории{Enter}{F6}
SmartSleep(250)
Send, или подкатегории, паспорт транспортного средства, на котором осуществляется передвижение.{Enter}
Return

:?:/коап5.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.1 КоАП вождение без документов, предусмотренных пунктом 2.1.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап5.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.2 КоАП непредоставление по требованию сотрудника полиции документов{Enter}{F6}
SmartSleep(250)
Send, предусмотренных пунктом 2.1.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 30.000 рублей или лишение права на управление ТС с возможностью моментального переобучения.{Enter}
Return

:?:/коап5.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.3 КоАП управление ТС, не зарегистрированным в установленном порядке {Enter}{F6}
SmartSleep(250)
Send, либо без гос. номеров, либо с изменёнными или закрытыми регистрационными знаками {Enter}{F6}
SmartSleep(250)
Send, если прошло более 3 суток с момента покупки {Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей. {Enter}
Return

:?:/коап5.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.4 КоАП управление ТС с тонировкой, светопропускаемость которой менее 70 процентов {Enter}{F6}
SmartSleep(250)
Send, на боковых передних и лобовом стеклах включая запрещённые цветные пленки {Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей. {Enter}
Return

:?:/коап5.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.5 КоАП управление ТС при технической неисправности или в условиях, когда управление запрещено{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 2.4 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф от 10.000 до 30.000 рублей.{Enter}
Return

:?:/коап5.6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.6 КоАП управление мотоциклом или мопедом, либо перевозка пассажиров без мотошлемов{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 2.1.3 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап5.7::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.7 КоАП нарушение ПДД пешеходами и велосипедистами{Enter}{F6}
SmartSleep(250)
Send, согласно главе 4 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф от 5.000 до 15.000 рублей.{Enter}
Return

:?:/коап5.8::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.8 КоАП посадка или высадка пассажиров со стороны проезжей части{Enter}{F6}
SmartSleep(250)
Send, в нарушение правил дорожного движения {Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап5.9::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.9 КоАП игнорирование водителем требования об остановке с помощью жезла{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап5.10::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.10 КоАП несоблюдение требований дорожных знаков или разметки{Enter}{F6}
SmartSleep(250)
Send, согласно приложению 1 и 2 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 5.000 рублей.{Enter}
Return

:?:/коап6.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.1 КоАП использование приоритета с включёнными маячками и звуковым сигналом{Enter}{F6}
SmartSleep(250)
Send, без убедительности в безопасности манёвра согласно пунктом 3.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей.{Enter}
Return

:?:/коап6.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.2 КоАП нарушение правил использования аварийных сигналов{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 7.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 10.000 рублей.{Enter}
Return

:?:/коап6.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.3 КоАП нарушение правил использования знака аварийной остановки{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 7.2 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 10.000 рублей.{Enter}
Return

:?:/коап6.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.4 КоАП управление ТС с выключенными фарами{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 8.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап6.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.5 КоАП использование звукового сигнала с нарушением ПДД{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 8.3 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап7.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 7.1 КоАП проезд на красный сигнал светофора, запрещающий жест регулировщика, или на жёлтый{Enter}{F6}
SmartSleep(250)
Send, при возможности остановки без создания опасности согласно пунктом 6.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап7.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 7.2 КоАП невыполнение требования остановки перед стоп-линией при запрещающем сигнале светофора{Enter}{F6}
SmartSleep(250)
Send, или жесте регулировщика согласно пунктом 6.2 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей.{Enter}
Return

:?:/коап8.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 8.1 КоАП начало движения, перестроение, поворот или остановка без использования сигнала поворота{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 9.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап8.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 8.2 КоАП непредоставление при перестроении преимущества транспортному средству {Enter}{F6}
SmartSleep(250)
Send, попутного направления или справа согласно пунктом 9.4 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап8.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 8.3 КоАП поворот направо, налево или разворот из полосы, не предназначенной для данного манёвра{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 9.4 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап8.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 8.4 КоАП поворот направо, налево, разворот или движение задним ходом с нарушением ПДД{Enter}{F6}
SmartSleep(250)
Send, знаков или разметки согласно пунктам 9.4, 9.4.1, 9.6, 9.7 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап9.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 9.1 КоАП движение по полосе, предназначенной для встречного движения, с нарушением ПДД{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 10.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 50.000 рублей с лишением права управления до 2 лет.{Enter}
Return

:?:/коап9.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 9.2 КоАП выезд на полосу, предназначенную для встречного движения, с нарушением ПДД{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 10.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 50.000 рублей.{Enter}
Return

:?:/коап9.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 9.3 КоАП движение вне населённых пунктов по левым полосам при свободных правых{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 10.2 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап9.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 9.4 КоАП движение по прерывистым линиям разметки с нарушением ПДД{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 10.4 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 10.000 рублей.{Enter}
Return

:?:/коап9.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 9.5 КоАП движение по разделительным полосам, обочинам, тротуарам, пешеходным дорожкам и газону{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 10.6 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 30.000 рублей.{Enter}
Return

:?:/коап9.6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 9.6 КоАП несоблюдение дистанции до впереди идущего ТС и бокового интервала между движущимися ТС{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 10.8 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 10.000 рублей.{Enter}
Return

:?:/коап10.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 10.1 КоАП обгон ТС с нанесёнными спец. цветографическими схемами{Enter}{F6}
SmartSleep(250)
Send, с включённым синим проблесковым маячком и спец. звуковым сигналом согласно пунктом 3.2 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап10.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 10.2 КоАП обгон ТС с спец. цветографическими схемами, с включёнными проблесковыми маячками синего{Enter}{F6}
SmartSleep(250)
Send, и/или красного цветов, а также сопровождаемого ТС согласно пунктом 3.2 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап10.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 10.3 КоАП обгон ТС в случаях, когда манёвр запрещён{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 12.2 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап10.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 10.4 КоАП препятствование обгону согласно пунктом 12.3 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап11.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 11.1 КоАП остановка или стоянка ТС на пешеходном переходе, ближе 5 м перед ним{Enter}{F6}
SmartSleep(250)
Send, или на тротуаре согласно пунктом 13.3 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей.{Enter}
Return

:?:/коап11.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 11.2 КоАП остановка или стоянка ТС в местах остановки маршрутных ТС или ближе 15 м от них{Enter}{F6}
SmartSleep(250)
Send, кроме посадки/высадки или вынужденной остановки согласно пунктом 13.3 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей.{Enter}
Return

:?:/коап11.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 11.3 КоАП остановка или стоянка ТС на трамвайных путях{Enter}{F6}
SmartSleep(250)
Send, газоне или далее первого ряда от края проезжей части согласно пунктом 13.3 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей.{Enter}
Return

:?:/коап11.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 11.4 КоАП нарушение правил остановки или стоянки ТС на проезжей части{Enter}{F6}
SmartSleep(250)
Send, или в тоннелях с созданием препятствий для движения других ТС согласно пунктом 13.3 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей.{Enter}
Return

:?:/коап11.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 11.5 КоАП нарушение правил остановки или стоянки ТС, за исключением случаев частей 1-4 {Enter}{F6}
SmartSleep(250)
Send, настоящей статьи согласно главе 13 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей.{Enter}
Return

:?:/коап12.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 12.1 КоАП нарушения правил проезда перекрёстков, не повлекшие опасности {Enter}{F6}
SmartSleep(250)
Send, другим участникам движения согласно главе 14 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап12.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 12.2 КоАП нарушения правил проезда перекрёстков, повлекшие опасность {Enter}{F6}
SmartSleep(250)
Send, другим участникам движения согласно главе 14 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей.{Enter}
Return

:?:/коап13.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 13.1 КоАП пересечение железнодорожных путей в местах, не оборудованных для этого{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 16.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап13.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 13.2 КоАП выезд на железнодорожный переезд в случаях, когда это запрещено{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 16.3 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап13.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 13.3 КоАП остановка ТС ближе 5 м от шлагбаума, или при его отсутствии ближе 10м {Enter}{F6}
SmartSleep(250)
Send, до ближайшего рельса согласно пунктом 16.4 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап14.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 14.1 КоАП движение по автомагистрали ТС, скорость которых по характеристикам {Enter}{F6}
SmartSleep(250)
Send, или состоянию менее 40 км/ч согласно пунктом 17.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей.{Enter}
Return

:?:/коап14.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 14.2 КоАП движение по автомагистрали грузовых автомобилей далее второй полосы{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 17.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап14.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 14.3 КоАП движение по автомагистрали задним ходом согласно пунктом 17.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей.{Enter}
Return

:?:/коап14.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 14.4 КоАП создание пешеходом помех для автомобилей при движении в жилых зонах{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 18.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап14.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 14.5 КоАП сквозное движение, учебная езда, стоянка с работающим двигателем {Enter}{F6}
SmartSleep(250)
Send, а также стоянка грузовых ТС свыше 3,5 тонн вне спец выделенных мест согласно пунктом 18.2 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап14.6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 14.6 КоАП движение в колонне с нарушением правил дорожного движения{Enter}{F6}
SmartSleep(250)
Send, согласно главе 19 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 10.000 рублей.{Enter}
Return

:?:/коап15.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 15.1 КоАП непредоставление преимущества ТС с включенным проблесковым маячком синего {Enter}{F6}
SmartSleep(250)
Send, и/или красного цвета и спец. звуковым сигналом согласно пунктом 3.2 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап15.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 15.2 КоАП непредоставление преимущества троллейбусам и автобусам {Enter}{F6}
SmartSleep(250)
Send, начинающим движение от места остановки согласно пунктом 20.2 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 5.000 рублей.{Enter}
Return

:?:/коап15.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 15.3 КоАП непредоставление преимущества ТС, движущимся по главной дороге{Enter}{F6}
SmartSleep(250)
Send, или при выезде с прилегающей территории согласно пунктом 9.3 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей.{Enter}
Return

:?:/коап15.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 15.4 КоАП непредоставление преимущества пешеходам {Enter}{F6}
SmartSleep(250)
Send, и/или велосипедистам при пересечении проезжей части согласно пунктом 15.1 ПДД{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или штраф 5.000 рублей.{Enter}
Return

:?:/коап16.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 16.1 КоАП оставление водителем места ДТП, участником которого он являлся, с нарушением ПДД{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 2.4 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 30.000 рублей с лишением права управления на 3-4 года и административный арест 20 суток.{Enter}
Return

:?:/коап16.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 16.2 КоАП неоказание первой помощи при ДТП, если она необходима{Enter}{F6}
SmartSleep(250)
Send, согласно пунктом 2.3 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап16.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 16.3 КоАП невыполнение водителем обязанностей при ДТП, участником которого он является{Enter}{F6}
SmartSleep(250)
Send, кроме случаев статьи 16.1 согласно пунктом 2.3 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф от 10.000 до 35.000 рублей.{Enter}
Return

:?:/коап1711::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 17.1.1 КоАП лицо, управляющее ТС и имеющее признаки опьянения {Enter}{F6}
SmartSleep(250)
Send, или совершившее правонарушения по ст. 19.1 и 19.4 подлежит отстранению от управления до устранения причины{Enter}
Return

:?:/коап1712::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 17.1.2 КоАП составляется протокол об отстранении от управления и направлении {Enter}{F6}
SmartSleep(250)
Send, на медицинское освидетельствование копия вручается лицу{Enter}
Return

:?:/коап1713::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 17.1.3 КоАП лицо с признаками опьянения подлежит освидетельствованию при отказе {Enter}{F6}
SmartSleep(250)
Send, или несогласии направляется на медицинское освидетельствование {Enter}
Return

:?:/коап1714::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 17.1.4 КоАП управление ТС в состоянии опьянения или передача управления лицу в состоянии опьянения{Enter}{F6}
SmartSleep(250)
Send, согласно п. 2.4 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф 30.000 рублей с лишением права управления до 1 года.{Enter}
Return

:?:/коап1715::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 17.1.5 КоАП невыполнение законного требования о прохождении медицинского освидетельствования{Enter}{F6}
SmartSleep(250)
Send, на состояние опьянения {Enter}{F6}
SmartSleep(250)
Send, Штраф 30.000 рублей с лишением права управления до 1 года.{Enter}
Return

:?:/коап17.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 17.2 КоАП опасное вождение согласно пунктом 2.4 ПДД{Enter}{F6}
SmartSleep(250)
Send, Штраф до 30.000 рублей с лишением права управления до 2 лет.{Enter}
Return

:?:/коап17.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 17.3 КоАП управление ТС при неуплате штрафов до 10.000 рублей{Enter}{F6}
SmartSleep(250)
Send, Предупреждение.{Enter}
Return

:?:/коап17.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 17.4 КоАП управление ТС при неуплате штрафов от 10.000 до 50.000 рублей{Enter}{F6}
SmartSleep(250)
Send, Штраф 30.000 рублей.{Enter}
Return

:?:/коап17.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 17.5 КоАП управление ТС при неуплате штрафов от 50.000 до 100.000 рублей{Enter}{F6}
SmartSleep(250)
Send, Штраф 50.000 рублей с лишением права управления на 1 год.{Enter}
Return

:?:/коап17.6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 17.6 КоАП управление ТС при неуплате штрафов свыше 100.000 рублей{Enter}{F6}
SmartSleep(250)
Send, Штраф 100.000 рублей с лишением права управления на 2 года.{Enter}
Return

:?:/коап18.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 18.1 КоАП превышение скорости на 10-20 км/ч, зафиксированное сотрудниками полиции{Enter}{F6}
SmartSleep(250)
Send, Предупреждение.{Enter}
Return

:?:/коап18.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 18.2 КоАП превышение скорости на 20-40 км/ч, зафиксированное сотрудниками полиции{Enter}{F6}
SmartSleep(250)
Send, Штраф 2.000 рублей.{Enter}
Return

:?:/коап18.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 18.3 КоАП превышение скорости на 40-60 км/ч, зафиксированное сотрудниками полиции{Enter}{F6}
SmartSleep(250)
Send, Штраф 5.000 рублей.{Enter}
Return

:?:/коап18.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 18.4 КоАП превышение скорости на 60-80 км/ч, зафиксированное сотрудниками полиции{Enter}{F6}
SmartSleep(250)
Send, Штраф 7.000 рублей.{Enter}
Return

:?:/коап18.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 18.5 КоАП превышение скорости на 80+ км/ч, зафиксированное сотрудниками полиции{Enter}{F6}
SmartSleep(250)
Send, Штраф 10.000 рублей с лишением права управления на 1 год.{Enter}
Return

:?:/коап19.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 19.1 КоАП мелкое хулиганство, нарушение общественного порядка с нецензурной лексикой {Enter}{F6}
SmartSleep(250)
Send, оскорбительным поведением или повреждением чужого имущества {Enter}{F6}
SmartSleep(250)
Send, а так же нахождение в нижнем белье вне водоёмов, бассейнов, спортзалов {Enter}{F6}
SmartSleep(250)
Send, Штраф до 10.000 рублей или административный арест 10 суток.{Enter}
Return

:?:/коап19.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 19.2 КоАП оскорбление, унижение чести и достоинства другого лица неприличной или аморальной формой{Enter}{F6}
SmartSleep(250)
Send, Штраф до 10.000 рублей или административный арест 10 суток.{Enter}
Return

:?:/коап19.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 19.3 КоАП нанесение побоев или иных насильственных действий, причиняющих физическую боль, {Enter}{F6}
SmartSleep(250)
Send, не содержащих уголовно наказуемое деяние{Enter}{F6}
SmartSleep(250)
Send, Штраф до 20.000 рублей или административный арест 10 суток.{Enter}
Return

:?:/коап19.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 19.4 КоАП распитие алкоголя в общественных местах или появление в состоянии опьянения {Enter}{F6}
SmartSleep(250)
Send, оскорбляющем человеческое достоинство и общественную нравственность{Enter}
SmartSleep(250)
Send, Штраф 5.000 рублей.{Enter}{F6}
Return

:?:/коап19.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 19.5 КоАП занятие попрошайничеством в общественных местах{Enter}{F6}
SmartSleep(250)
Send, Предупреждение или административный арест 10 суток.{Enter}
Return

:?:/коап19.6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 19.6 КоАП предпринимательская деятельность без регистрации или лицензии, если она обязательна{Enter}{F6}
SmartSleep(250)
Send, Штраф 100.000 рублей.{Enter}
Return

:?:/коап19.7::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 19.7 КоАП заведомо ложный вызов пожарной охраны, полиции, скорой или иных служб{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/коап19.8::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 19.8 КоАП организация, участие или призыв к несогласованному митингу с нарушением порядка {Enter}{F6}
SmartSleep(250)
Send, и созданием помех движению{Enter}{F6}
SmartSleep(250)
Send, Штраф до 20.000 рублей или административный арест 10 суток.{Enter}
Return

:?:/коап19.9::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 19.9 КоАП неповиновение законному распоряжению сотрудника полиции или военнослужащего{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей, или лишение права управления на 1 год, или административный арест до 20 суток.{Enter}
Return

:?:/коап19.10::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 19.10 КоАП клевета, распространение заведомо ложных сведений {Enter}{F6}
SmartSleep(250)
Send, порочащих честь и достоинство или репутацию другого лица{Enter}{F6}
SmartSleep(250)
Send, Штраф 20.000 рублей.{Enter}
Return

:?:/укрп4.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 4.1 УКРП умышленное причинение вреда здоровью человека без летального исхода{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 1 год.{Enter}
Return

:?:/укрп4.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 4.2 УКРП умышленное нанесение особо тяжких телесных повреждений{Enter}{F6}
SmartSleep(250)
Send, по итогу которых человек был доведен до предсмертного положения{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 2 года.{Enter}
Return

:?:/укрп421::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 4.2.1 УКРП умышленное нанесение особо тяжких телесных повреждений двум или более лицам{Enter}{F6}
SmartSleep(250)
Send, Арест сроком от 4 до 6 лет.{Enter}
Return

:?:/укрп422::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 4.2.2 УКРП нанесение особо тяжких телесных повреждений по неосторожности или в состоянии аффекта {Enter}{F6}
SmartSleep(250)
Send, вызванного насилием, издевательством или тяжким оскорблением со стороны потерпевшего{Enter}{F6}
SmartSleep(250)
Send, либо иными противоправными или аморальными действиями потерпевшего{Enter}{F6}
SmartSleep(250)
Send, Арест сроком до 2 лет.{Enter}
Return

:?:/укрп4.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 4.3 УКРП угроза нанесения особо тяжких телесных повреждений или причинения вреда здоровью человека{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 1 год.{Enter}
Return

:?:/укрп4.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 4.4 УКРП похищение гражданина или незаконное лишение человека свободы, не связанное с похищением{Enter}{F6}
SmartSleep(250)
Send, Арест сроком от 4 до 6 лет.{Enter}
Return

:?:/укрп4.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 4.5 УКРП действия, направленные против половой неприкосновенности и половой свободы личности{Enter}{F6}
SmartSleep(250)
Send, Арест сроком от 3 до 6 лет.{Enter}
Return

:?:/укрп4.6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 4.6 УКРП незаконный сбор или распространение сведений о частной жизни лица без его согласия{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 1 год.{Enter}
Return

:?:/укрп5.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.1 УКРП получение должностным лицом взятки за осуществление очевидно незаконных действий{Enter}{F6}
SmartSleep(250)
Send, Штраф в полуторакратном размере от полученной взятки {Enter}{F6}
SmartSleep(250)
Send, или 50.000 рублей, а также арест сроком на 3 года.{Enter}
Return

:?:/укрп5.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.2 УКРП дача взятки должностному лицу лично или через посредника{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 3 года.{Enter}
Return

:?:/укрп5.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.3 УКРП посягательство на жизнь и здоровье сотрудника полиции {Enter}{F6}
SmartSleep(250)
Send, военнослужащего или работника инкассации{Enter}{F6}
SmartSleep(250)
Send, Арест сроком от 3 до 6 лет.{Enter}
Return

:?:/укрп5.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.4 УКРП применение насилия или угроза применения насилия в отношении представителя власти{Enter}{F6}
SmartSleep(250)
Send, Арест сроком до 3 лет.{Enter}
Return

:?:/укрп5.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.5 УКРП хамство или дерзость по отношению к сотруднику правоохранительных органов{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 1 год.{Enter}
Return

:?:/укрп5.6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.6 УКРП публичное оскорбление или неоднократное неуважение к представителям власти{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 2 года.{Enter}
Return

:?:/укрп5.7::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.7 УКРП провокационные действия в отношении сотрудников государственных структур{Enter}{F6}
SmartSleep(250)
Send, Арест сроком до 2 лет.{Enter}
Return

:?:/укрп571::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.7.1 УКРП длительное преследование экипажа сотрудников правоохранительных органов {Enter}{F6}
SmartSleep(250)
Send, или создание помех их работе{Enter}{F6}
SmartSleep(250)
Send, Арест сроком до 2 лет.{Enter}
Return

:?:/укрп5.8::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.8 УКРП неоднократное неповиновение законным требованиям служащего полиции{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 2 года.{Enter}
Return

:?:/укрп581::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.8.1 УКРП уход от правоохранительных органов с нанесением ущерба имуществу{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 3 года.{Enter}
Return

:?:/укрп582::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.8.2 УКРП уход от правоохранительных органов с причинением {Enter}{F6}
SmartSleep(250)
Send, телесных повреждений средней тяжести и выше{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 4 года.{Enter}
Return

:?:/укрп5.9::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.9 УКРП умышленное уничтожение или повреждение имущества государственных организаций{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 2 года.{Enter}
Return

:?:/укрп5.10::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.10 УКРП заведомо ложный донос или ложные показания по уголовному, административному делу{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 2 года.{Enter}
Return

:?:/укрп5.11::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.11 УКРП разглашение секретных данных или сведений о предстоящих операциях{Enter}{F6}
SmartSleep(250)
Send, Арест сроком до 3 лет.{Enter}
Return

:?:/укрп5.12::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.12 УКРП представление себя служащим государственной организации{Enter}{F6} 
SmartSleep(250)
Send, если это не соответствует действительности{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 1 год.{Enter}
Return

:?:/укрп5.13::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 5.13 УКРП халатность, повлекшая крупный ущерб или нарушение прав граждан{Enter}{F6}
SmartSleep(250)
Send, Арест сроком до 3 лет.{Enter}
Return

:?:/укрп6.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.1 УКРП терроризм, совершение взрыва, поджога или иных действий {Enter}{F6}
SmartSleep(250)
Send, создающих опасность гибели людей или тяжкие последствия{Enter}{F6}
SmartSleep(250)
Send, Арест сроком до 6 лет.{Enter}
Return

:?:/укрп6.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.2 УКРП ложное сообщение о готовящихся взрыве, поджоге или иных опасных действиях{Enter}{F6}
SmartSleep(250)
Send, Арест на 3 года.{Enter}
Return

:?:/укрп6.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.3 УКРП захват или удержание лица в качестве заложника{Enter}{F6}
SmartSleep(250)
Send, Арест сроком до 3 лет.{Enter}
Return

:?:/укрп6.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.4 УКРП организация массовых беспорядков, сопровождающихся насилием и разрушениями{Enter}{F6}
SmartSleep(250)
Send, Арест сроком до 6 лет.{Enter}
Return

:?:/укрп6.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.5 УКРП создание банды, руководство ею или участие в её деятельности{Enter}{F6}
SmartSleep(250)
Send, Арест сроком до 6 лет.{Enter}
Return

:?:/укрп6.6::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.6 УКРП вандализм, порча имущества или осквернение сооружений{Enter}{F6}
SmartSleep(250)
Send, Арест на 1 год.{Enter}
Return

:?:/укрп6.7::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.7 УКРП незаконное проникновение в жилище или частную территорию{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 2 года.{Enter}
Return

:?:/укрп6.8::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.8 УКРП проникновение на охраняемый объект{Enter}{F6}
SmartSleep(250)
Send, Арест на 2 года.{Enter}
Return

:?:/укрп6.9::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.9 УКРП незаконное обращение с огнестрельным оружием или боеприпасами{Enter}{F6}
SmartSleep(250)
Send, Арест на 3 года.{Enter}
Return

:?:/укрп6.10::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.10 УКРП незаконный оборот наркотических средств или психотропных веществ{Enter}{F6}
SmartSleep(250)
Send, Арест на 3 года.{Enter}
Return

:?:/укрп6.11::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.11 УКРП неоказание первой или медицинской помощи без уважительных причин{Enter}{F6}
SmartSleep(250)
Send, Арест на 1 год.{Enter}
Return

:?:/укрп6.12::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.12 УКРП попытка срыва мероприятий или помеха их проведению{Enter}{F6}
SmartSleep(250)
Send, Арест сроком на 3 года.{Enter}
Return

:?:/укрп6.13::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.13 УКРП подделка или использование поддельных лицензий или удостоверений{Enter}{F6}
SmartSleep(250)
Send, Арест на 3 года.{Enter}
Return

:?:/укрп6.14::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 6.14 УКРП превышение должностных полномочий, повлекшее существенные нарушения{Enter}{F6}
SmartSleep(250)
Send, Арест до 3 лет.{Enter}
Return

:?:/укрп7.1::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 7.1 УКРП мошенничество, хищение имущества путем обмана или злоупотребления доверием{Enter}{F6}
SmartSleep(250)
Send, Штраф 50.000 рублей и возмещение ущерба или арест на 3 года.{Enter}
Return

:?:/укрп7.2::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 7.2 УКРП грабеж или кража чужого имущества{Enter}{F6}
SmartSleep(250)
Send, Арест на 2 года.{Enter}
Return

:?:/укрп7.3::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 7.3 УКРП вымогательство, требование передачи имущества под угрозами{Enter}{F6}
SmartSleep(250)
Send, Арест на 3 года.{Enter}
Return

:?:/укрп7.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 7.4 УКРП умышленное уничтожение или повреждение имущества, повлекшее значительный ущерб{Enter}{F6}
SmartSleep(250)
Send, Штраф 50.000 рублей и возмещение ущерба или арест на 2 года.{Enter}
Return

:?:/укрп7.5::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 7.5 УКРП организация или проведение азартных игр в общественных местах{Enter}{F6}
SmartSleep(250)
Send, Арест на 2 года.{Enter}
Return

:?:/пдд211::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 2.1.1 ПДД Иметь при себе и по требованию полиции предъявлять водительское удостоверение {Enter}{F6}
SmartSleep(250)
Send, и паспорт транспортного средства.{Enter}
Return

:?:/пдд221::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 2.2.1. ПДД Перед выездом и в пути обеспечивать исправное техническое состояние ТС. {Enter}{F6}
SmartSleep(250)
Send, Запрещено движение при неисправности тормозной системы, рулевого управления, сцепного устройства {Enter}{F6}
SmartSleep(250)
Send, фар и задних габаритных огней в тёмное время суток {Enter}{F6}
SmartSleep(250)
Send, а также стеклоочистителя во время дождя или снегопада.{Enter}{F6}
SmartSleep(250)
Send, При прочих неисправностях нужно устранить их {Enter}{F6}
SmartSleep(250)
Send, либо следовать к месту ремонта с соблюдением мер предосторожности.{Enter}
Return

:?:/пдд235::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 2.3.5 ПДД Если установлена вина одного из участников ДТП, виновник обязан {Enter}{F6}
SmartSleep(250)
Send, выплатить пострадавшему компенсацию в размере, не превышающем полной стоимости ремонта ТС. {Enter}
Return

:?:/пдд2.4::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(250)
Send, 2.4 ПДД Водителю запрещается {Enter}{F6}
SmartSleep(250)
Send, Управлять ТС в состоянии опьянения, под воздействием препаратов, ухудшающих реакцию {Enter}{F6}
SmartSleep(250)
Send, а также в болезненном или утомлённом состоянии. {Enter}{F6}
SmartSleep(250)
Send, Передавать управление ТС лицу, находящемуся в состоянии опьянения. {Enter}{F6}
SmartSleep(250)
Send, Управлять ТС при наличии неисправностей, при которых эксплуатация запрещена. {Enter}{F6}
SmartSleep(250)
Send, Пересекать организованные колонны и занимать место в них. {Enter}{F6}
SmartSleep(250)
Send, Допускать опасное вождение: опасные перестроения, несоблюдение дистанции или бокового интервала, {Enter}{F6}
SmartSleep(250)
Send, управляемые заносы, резкое торможение без необходимости, препятствование обгону {Enter}{F6}
SmartSleep(250)
Send, и другие действия создающие угрозу ДТП, жизни, здоровью или имуществу. {Enter}
Return

:?:/дверь+::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F8}
SmartSleep(50)
Send, /do Дверь открыта.{Enter}
Return

:?:/дверь-::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F8}
SmartSleep(50)
Send, /do Дверь заперта.{Enter}
Return

:?:/окно+::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F8}
SmartSleep(50)
Send, /do Окно разбито.{Enter}
Return

:?:/окно-::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F8}
SmartSleep(50)
Send, /do Окно цело.{Enter}
Return


24:
MsgBox, 0, Патруль, Патрулирование:`n/п1 - выехать в патруль`n/п2 - продолжить патруль`n/п3 - закончить патруль
return
25:
MsgBox, 0, Воздушный патруль, Патруль:`n/вп1 - вылететь в патруль`n/вп2 - продолжить патруль`n/вп3 - закончить патруль
return
39:
MsgBox, 0, I этап, (/собес1)`nЗапись на камеру`n`n(/собес2)`nНазовите ФИО, возраст и образование`n`n(/собес3)`nДайте паспорт`n`n(/собес4)`nДайте трудовую книгу`n`n(/собес5)`nДайте диплом`n`n(/собес6)`nДайте водительское`n`n(/собес7)`nДайте медицинскую карту`n`n(/собес8)`nДайте военный билет
return
40:
MsgBox, 0, II этап, (/собес9)`nРП термин в чат`n`n(/собес10)`nРП термин в чат`n`n(/собес11)`nРП термин в чат`n`n(/собес12)`nРП термин в чат`n`n(/собес13)`nОбождите минутку`n`n(/собес14)`nРП термины в НонРП чат`n`n(/собес15)`nПрисядьте на корточки`n`n(/собес16)`nВставайте в НонРП чат`n`n(/собес17)`nВставайте в РП чат`n`n(/собес18)`nЧто у меня в руке?`n`n
return
41:
MsgBox, 0,  Одно нажатие, Обычное нажатие сочетания клавиш`n`nПример: нажать Alt и потом один раз клавишу "1".
return
42:
MsgBox, 0,  Два нажатия, Двойное нажатие второй клавиши в сочетании`n`nПример: нажать Alt и потом два раза клавишу "1".
return
43:
MsgBox, 0, Подробности, Кликабельные названия отыгровок помечены символом "*", нажмите на них, чтобы посмотреть дополнительную информацию о какой-либо команде`n`nДОПОЛНИТЕЛЬНО:`nВ АХК МОГУТ ОТОБРАЖАТЬСЯ НЕ ВСЕ ВКЛАДКИ С КОМАНДАМИ, ПРОБУЙТЕ НАЖИМАТЬ НА ВКЛАДКУ НЕСКОЛЬКО РАЗ (ПО ДВОЙНОМУ НАЖАТИЮ НА ВКЛАДКУ "ОПЕРАЦИИ" МОЖЕТ ОТКРЫТЬСЯ ВКЛАДКА "ДОКЛАДЫ" И НАОБОРОТ)
return
44:
MsgBox, 0,  Тауметр, Взаимодействие с тауметром`n/таум1 - достать тауметр`n/таум2 - включить и сделать колибровку устройства`n/таум3 - попросить приподнять стекло`n/таум4 - протирание стёкл`n/таум5 - установка и измерение тонировки`n/таум5 - выключить и убрать тауметр`n`nДокументы на тауметр`n/доктаум1 - достать документы на тауметр`n/доктаум2 - показать гражданину, но не передавая их`n/доктаум3 - убрать в папку документы`n/доктаум4 - убрать документ на тауметр`n`nP.s Бывают попадаются такие граждане, которые слишком любять докапаться. И бывает спрашивают документы на подтверждение роботоспособности тауметра.
return
45:
MsgBox, 0,  Видеорегистратор, /рег1 - снять видеорегистратор с крепления`n/рег2 - включить и паказать запись гражданину`n/рег3 - выключить запись`n/рег4 - повесить видеорегистратор на крепление
return
46:
MsgBox, 0,  Алкотестер, Документы на алкотестер`n/докалко1 - достать документы на алкотестер`n/докалко2 - показать гражданину, но не передавая их`n/докалко3 - убрать в папку документы`n/докалко4 - убрать документ на алкотестер`n`nP.s Бывают попадаются такие граждане, которые слишком любять докапаться. И бывает спрашивают документы на подтверждение роботоспособности.
return
47:
MsgBox, 0,  Проверка на штрафы, Может пользоваться как обычный сотрудник, так и сотрудник УС или РС.
return

:?:/фзопобр::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 2.4.4.1 ФЗ «О полиции», при обращении к гражданину сотрудник обязан{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, назвать свои должность, звание, фамилию, по обоснованному требованию предъявить удостоверение,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, после чего сообщить причину и цель обращения.{Enter}
Return


:?:/фзопправа::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 2.4.4.2 ФЗ «О полиции», при применении мер, ограничивающих права и свободы,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, сотрудник разъясняет причину и основания применения таких мер после задержания,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, а также возникающие в связи с этим права и обязанности гражданина.{Enter}
Return


:?:/фзопмат::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 2.4.6 ФЗ «О полиции», полиция обязана обеспечить гражданину возможность{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, ознакомления с документами и материалами, непосредственно затрагивающими его права и свободы.{Enter}
Return


:?:/фзопнадзор::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.8.1.11 ФЗ «О полиции», на полицию возложена обязанность{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, осуществлять государственный контроль и надзор в области безопасности дорожного движения.{Enter}
Return


:?:/фзопконф::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.8.1.13 ФЗ «О полиции», сотрудник полиции обязан конфисковывать{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, нелегальные предметы, обнаруженные у задержанного, согласно ст. 2.5 УК РП.{Enter}
Return


:?:/фзоптреб::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.9.1.1 ФЗ «О полиции», сотрудник полиции имеет право{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, требовать от граждан и должностных лиц прекращения противоправных действий.{Enter}
Return


:?:/фзоп912::
:?:/фзопдок::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.9.1.2 ФЗ «О полиции», сотрудник МВД имеет право проверять документы граждан,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, если имеются основания подозревать их в преступлении, розыске или административном правонарушении,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, а также проверять ВУ, ПТС и наличие неоплаченных штрафов.{Enter}
Return


:?:/фзопотойти::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.9.1.4 ФЗ «О полиции», сотрудник полиции вправе требовать от граждан{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, покинуть место и прилегающую территорию проведения процессуальных действий (оформление, допрос и пр.),{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, при этом сотрудник имеет право не разглашать, какие процессуальные действия он проводит.{Enter}
Return


:?:/фзопдост::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.9.1.7 ФЗ «О полиции», сотрудник вправе доставлять граждан в отдел полиции{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, для решения вопроса о задержании или установления личности гражданина.{Enter}
Return


:?:/фзопдосмотр::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.9.1.8 и п. 4.10.5 ФЗ «О полиции», сотрудник полиции имеет право{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, осуществлять личный досмотр граждан, досмотр находящихся при них вещей и транспортных средств{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, при наличии данных о запрещенных предметах, а также при задержании лица.{Enter}
Return


:?:/фзопост::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.9.1.9 и ст. 3.9.2 ФЗ «О полиции», сотрудник полиции имеет право{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, останавливать транспортные средства для обеспечения безопасности дорожного движения,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, проверять водительское удостоверение, ПТС и документы на перевозимые грузы.{Enter}
Return


:?:/фзопотстр::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.9.1.11 ФЗ «О полиции», сотрудник полиции имеет право{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, задерживать транспортные средства и отстранять водителей от управления ТС.{Enter}
Return


:?:/фзопкамера::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.9.1.12 ФЗ «О полиции», сотрудник полиции имеет право использовать{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, информационные системы, видео- и фотоаппаратуру, а также технические и специальные средства.{Enter}
Return


:?:/фзопдоступтс::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.9.1.14 ФЗ «О полиции», сотрудник имеет право требовать от водителя{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, предоставить доступ к транспортному средству для проведения проверки,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, если есть основания полагать, что ТС неисправно или на нем совершается правонарушение.{Enter}
Return


:?:/фзопмаяк::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 3.9.1.17–18 ФЗ «О полиции», проблесковые маячки включаются при патрулировании,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, на посту, при оформлении ДТП и стоянке с отступлением от ПДД,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, а совместно с СГУ — при ведении погони, срочном вызове и сопровождении колонн.{Enter}
Return


:?:/фзопост9::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ч. 2 ст. 9 (п. 3.9.2) ФЗ «О полиции», сотрудник вправе остановить ТС при обнаружении{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, признаков нарушения БДД, причастности водителя к правонарушению или ДТП, нахождении ТС в розыске,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, а также для проверки документов при наличии повода к возбуждению дела об АПН.{Enter}
Return


:?:/фзопзадерж::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ч. 2 ст. 10 (п. 4.10.2) ФЗ «О полиции», полиция имеет право задерживать лиц,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, подозреваемых в совершении преступления, находящихся в розыске, лиц, в отношении которых{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, ведется производство по делу об АПН, а также не выполнивших законные требования сотрудника.{Enter}
Return


:?:/фзопзвонок::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 4.10.7–8 ФЗ «О полиции», задержанный перед допросом имеет право на один{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, телефонный разговор в присутствии сотрудника, если это не создаст угрозу сообщения информации сообщникам.{Enter}
Return


:?:/фзопоцеп::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 11 (п. 4.11.2–3) ФЗ «О полиции», полиция имеет право проводить оцепление{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, участков местности и временно ограничивать движение транспорта и пешеходов.{Enter}
Return


:?:/фзопбезпред::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 5.13.2 ФЗ «О полиции», сотрудник имеет право не предупреждать перед применением{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, силы, спецсредств или оружия при непосредственной угрозе жизни и здоровью, провокации,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, а также если лицо застигнуто в момент совершения преступления или арестного правонарушения.{Enter}
Return


:?:/фзопсила::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 14 (п. 5.14.1) ФЗ «О полиции», сотрудник имеет право применять физическую силу{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, для пресечения правонарушений, задержания лиц и преодоления противодействия законным требованиям.{Enter}
Return


:?:/фзопспец::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 15 (п. 5.15.1–2) ФЗ «О полиции», сотрудник имеет право применять спецсредства{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, (наручники, дубинку, тайзер) для пресечения преступления или АПН, преодоления сопротивления,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, задержания лица, пытающегося скрыться, а также для доставления и конвоирования задержанных.{Enter}
Return


:?:/фзопоружие::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 17 (п. 5.17.1 и 5.17.3) ФЗ «О полиции», сотрудник имеет право применять{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, огнестрельное оружие для защиты жизни и здоровья, задержания при вооруженном сопротивлении,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, а также для остановки ТС путем его повреждения при неоднократном отказе остановиться.{Enter}
Return


:?:/фзопзапретор::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно п. 5.17.6–9 ФЗ «О полиции», запрещено применять оружие при скоплении людей,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, с водительского места при наличии вооруженного напарника, а также применять тяжелое{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, автоматическое и гладкоствольное оружие для остановки ТС путем повреждения.{Enter}
Return


:?:/фзопстрой::
AbortBindFlag := 0
SendMessage, 0x50,, 0x4190419,, A
Send, {F6}
SmartSleep(350)
Send, Согласно ст. 19–20 (п. 6.19.7 и 6.20.1) ФЗ «О полиции», в строю запрещено разговаривать,{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, доставать телефон или оружие, спать более 60 секунд и покидать строй без разрешения.{Enter}
SmartSleep(1800)
Send, {F6}
SmartSleep(350)
Send, Каждую субботу до 23:59 МСК сотрудник обязан сдать отчёт в онлайн-протоколе.{Enter}
Return

:*:/погоня::
ExecuteSmartMegaphoneStep()
Return

:*:/мегафон::
ExecuteSmartMegaphoneStep()
Return

:*:/погонястоп::
StopChaseMode()
Return
#If


; =================================================================================================
; СИСТЕМА АВТООБНОВЛЕНИЯ (CLOUD VPS RELAY + GITHUB RAW & RELEASES)
; =================================================================================================
global AppNumericVersion    := "2.5.0"
global AppVersionCode       := 250
global UpdatePrimaryUrl     := "http://152.234.229.245:3000/api/version"
global UpdateGithubRawUrl   := "https://raw.githubusercontent.com/Polaney/AHK_Province/main/version.json"
global UpdateCdnUrl         := "https://cdn.jsdelivr.net/gh/Polaney/AHK_Province@main/version.json"
global PendingUpdateUrl     := ""
global PendingUpdateMirror  := ""
global PendingUpdateVer     := ""

InitAutoUpdater() {
    ; Отложенная фоновая проверка через 5 секунд после старта (не блокирует загрузку GUI)
    SetTimer, BackgroundUpdateCheckTimer, -5000
}

BackgroundUpdateCheckTimer:
CheckForUpdates(1) ; 1 = Тихий фоновый режим
Return

ManualCheckUpdates:
CheckForUpdates(0) ; 0 = Интерактивный режим по кнопке
Return

CheckForUpdates(IsSilent := 1) {
    global UpdatePrimaryUrl, UpdateGithubRawUrl, UpdateCdnUrl, AppVersionCode, AppNumericVersion
    global PendingUpdateUrl, PendingUpdateMirror, PendingUpdateVer

    if (!IsSilent)
        TrayTip, AHK УГИБДД, Проверка наличия обновлений на сервере..., 2, 1

    ; Шаг 1: Пробуем быстрый Cloud VPS релей (без замедлений и блокировок)
    jsonStr := FetchUrlText(UpdatePrimaryUrl, 4)

    ; Шаг 2: Если VPS недоступен, пробуем GitHub Raw
    if (jsonStr = "")
        jsonStr := FetchUrlText(UpdateGithubRawUrl, 5)

    ; Шаг 3: Если GitHub замедлен, пробуем CDN-зеркало jsDelivr
    if (jsonStr = "")
        jsonStr := FetchUrlText(UpdateCdnUrl, 5)

    ; Шаг 4: Fallback через UrlDownloadToFile во временный файл
    if (jsonStr = "") {
        tmpJson := A_Temp . "\ahk_ver_" . A_TickCount . ".json"
        try {
            UrlDownloadToFile, %UpdatePrimaryUrl%, %tmpJson%
            if (!FileExist(tmpJson) || FileOpen(tmpJson, "r").Length < 50)
                UrlDownloadToFile, %UpdateGithubRawUrl%, %tmpJson%
            if (!FileExist(tmpJson) || FileOpen(tmpJson, "r").Length < 50)
                UrlDownloadToFile, %UpdateCdnUrl%, %tmpJson%

            if (FileExist(tmpJson)) {
                FileRead, jsonStr, %tmpJson%
                FileDelete, %tmpJson%
            }
        }
    }

    if (jsonStr = "") {
        if (!IsSilent)
            MsgBox, 48, AHK УГИБДД, Не удалось связаться с сервером обновлений.`nПроверьте подключение к интернету или доступность сервера.
        Return
    }

    ; Парсинг JSON параметров
    RegExMatch(jsonStr, """version"":\s*""([^""]+)""", mVer)
    RegExMatch(jsonStr, """version_code"":\s*(\d+)", mCode)
    RegExMatch(jsonStr, """title"":\s*""([^""]+)""", mTitle)
    RegExMatch(jsonStr, """download_url"":\s*""([^""]+)""", mDown)
    RegExMatch(jsonStr, """download_mirror"":\s*""([^""]+)""", mDownMirror)
    RegExMatch(jsonStr, """ahk_url"":\s*""([^""]+)""", mAhk)
    RegExMatch(jsonStr, """ahk_mirror"":\s*""([^""]+)""", mAhkMirror)
    RegExMatch(jsonStr, """changelog"":\s*""((?:[^""\\]|\\.)*)""", mLog)

    newVer := mVer1
    newCode := mCode1 + 0
    newTitle := mTitle1 ? mTitle1 : "Новая версия программы"
    newChangelog := StrReplace(StrReplace(mLog1, "\n", "`n"), "\""", """")

    if (A_IsCompiled) {
        PendingUpdateUrl := mDown1
        PendingUpdateMirror := mDownMirror1 ? mDownMirror1 : "https://raw.githubusercontent.com/Polaney/AHK_Province/main/%D0%90%D0%A5%D0%9A%20%D0%A3%D0%93%D0%98%D0%91%D0%94%D0%94.exe"
    } else {
        PendingUpdateUrl := mAhk1
        PendingUpdateMirror := mAhkMirror1 ? mAhkMirror1 : "https://raw.githubusercontent.com/Polaney/AHK_Province/main/%D0%90%D0%A5%D0%9A%20%D0%A3%D0%93%D0%98%D0%91%D0%94%D0%94.ahk"
    }

    PendingUpdateVer := newVer

    if (newCode > AppVersionCode) {
        ShowUpdateDialog(newVer, newTitle, newChangelog, PendingUpdateUrl)
    } else {
        if (!IsSilent)
            MsgBox, 64, AHK УГИБДД, У вас установлена актуальная версия биндера (v%AppNumericVersion%)!
    }
}

ShowUpdateDialog(NewVer, NewTitle, NewChangelog, DownUrl) {
    global AppNumericVersion
    Gui, 7:Destroy
    Gui, 7:Color, 121622, 1B2234
    Gui, 7:Font, S11 C58A6FF Bold, Segoe UI
    Gui, 7:Add, Text, x16 y12 w568 h26, 🚀 Доступно обновление: v%NewVer% (текущая: v%AppNumericVersion%)
    Gui, 7:Font, S10 CFFB84D Bold, Segoe UI
    Gui, 7:Add, Text, x16 y40 w568 h20, % NewTitle
    Gui, 7:Font, S9 CE6EDF3 Norm, Segoe UI
    Gui, 7:Add, Edit, x16 y66 w568 h175 ReadOnly Background161D2E cE6EDF3, % NewChangelog
    Gui, 7:Font, S9 C8B949E Norm, Segoe UI
    Gui, 7:Add, Text, x16 y248 w568 h20 vUpdateStatusTxt, Обновление будет загружено и установлено автоматически.
    Gui, 7:Font, S10 CE6EDF3 Bold, Segoe UI
    Gui, 7:Add, Button, x16 y274 w276 h38 gStartUpdateInstallation, ⚡ Обновить сейчас
    Gui, 7:Add, Button, x308 y274 w276 h38 gCloseUpdateDialog, ⏱️ Напомнить позже
    Gui, 7:Show, w600 h324, AHK УГИБДД — Доступно обновление
}

CloseUpdateDialog:
Gui, 7:Destroy
Return

StartUpdateInstallation:
GuiControl, 7:Disable, StartUpdateInstallation
GuiControl, 7:, UpdateStatusTxt, ⏳ Загрузка файлов обновления...
SetTimer, PerformUpdateAction, -100
Return

PerformUpdateAction:
PerformDownloadAndUpdate()
Return

PerformDownloadAndUpdate() {
    global PendingUpdateUrl, PendingUpdateMirror, PendingUpdateVer

    if (PendingUpdateUrl = "" && PendingUpdateMirror = "") {
        MsgBox, 48, Ошибка, Ссылка для загрузки не определена.
        Return
    }

    ext := A_IsCompiled ? ".exe" : ".ahk"
    tempFile := A_Temp . "\ahk_update_" . A_TickCount . ext

    ; Скачивание через отказоустойчивую функцию
    success := DownloadBinaryFile(PendingUpdateUrl, PendingUpdateMirror, tempFile)

    if (!success) {
        FileDelete, %tempFile%
        MsgBox, 16, Ошибка загрузки, Не удалось скачать файл обновления.`nПроверьте подключение к сети или скачайте архив вручную.
        Return
    }

    currentPath := A_ScriptFullPath

    if (A_IsCompiled) {
        ; Создаём bat-скрипт с принудительной UTF-8 кодировкой для поддержки кириллицы в путях
        batScript := A_Temp . "\replace_gibdd_" . A_TickCount . ".bat"
        batContent := "@echo off`r`n"
        batContent .= "chcp 65001 > nul`r`n"
        batContent .= "ping 127.0.0.1 -n 3 > nul`r`n"
        batContent .= ":retry`r`n"
        batContent .= "move /y """ . tempFile . """ """ . currentPath . """ > nul 2>&1`r`n"
        batContent .= "if exist """ . tempFile . """ (`r`n"
        batContent .= "    ping 127.0.0.1 -n 1 > nul`r`n"
        batContent .= "    goto retry`r`n"
        batContent .= ")`r`n"
        batContent .= "start """" """ . currentPath . """`r`n"
        batContent .= "del ""%~f0""`r`n"

        FileDelete, %batScript%
        FileAppend, %batContent%, %batScript%, UTF-8
        Run, "%batScript%",, Hide
        ExitApp
    } else {
        FileCopy, %tempFile%, %currentPath%, 1
        FileDelete, %tempFile%
        TrayTip, AHK УГИБДД, Биндер успешно обновлён до v%PendingUpdateVer%!, 3, 1
        Sleep, 500
        Reload
    }
}

DownloadBinaryFile(Url1, Url2, OutPath) {
    FileDelete, %OutPath%

    ; Попытка 1: Скачивание через WinHttp (наиболее надежно)
    for idx, targetUrl in [Url1, Url2] {
        if (targetUrl = "")
            continue
        try {
            whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            whr.SetTimeouts(5000, 5000, 30000, 30000)
            whr.Open("GET", targetUrl, false)
            whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AHK-GIBDD-Updater")
            whr.Send()
            if (whr.Status = 200) {
                ado := ComObjCreate("ADODB.Stream")
                ado.Type := 1 ; Binary
                ado.Open()
                ado.Write(whr.ResponseBody)
                ado.SaveToFile(OutPath, 2) ; Overwrite
                ado.Close()

                FileGetSize, sz, %OutPath%
                if (sz > 5000)
                    return true
            }
        }
    }

    ; Попытка 2: UrlDownloadToFile
    for idx, targetUrl in [Url1, Url2] {
        if (targetUrl = "")
            continue
        UrlDownloadToFile, %targetUrl%, %OutPath%
        FileGetSize, sz, %OutPath%
        if (sz > 5000)
            return true
    }

    ; Попытка 3: PowerShell WebClient (штатный fallback Windows)
    activeUrl := Url1 ? Url1 : Url2
    if (activeUrl != "") {
        psCmd := "powershell -WindowStyle Hidden -Command ""[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('" . activeUrl . "', '" . OutPath . "')"""
        RunWait, %psCmd%,, Hide
        FileGetSize, sz, %OutPath%
        if (sz > 5000)
            return true
    }

    return false
}

FetchUrlText(Url, TimeoutSec := 5) {
    ComObjError(false)
    try {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.SetTimeouts(2000, 2000, TimeoutSec * 1000, TimeoutSec * 1000)
        whr.Open("GET", Url . (InStr(Url, "?") ? "&" : "?") . "t=" . A_TickCount, false)
        whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AHK-GIBDD-Updater")
        whr.Send()
        if (whr.Status = 200)
            return whr.ResponseText
    }
    return ""
}


; =================================================================================================
; FLUENT POLICE GLASS ENGINE (HTML5 / CSS3 / JS ACTIVEX DASHBOARD - GUI 8)
; =================================================================================================
global FluentWB := ""
global FluentGuiHwnd := 0
global FluentUiMode := 1
global QuickRemapTargetId := ""

SetBrowserEmulationIE11() {
    exeName := A_IsCompiled ? A_ScriptName : "AutoHotkeyU64.exe"
    try {
        RegWrite, REG_DWORD, HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION, %exeName%, 11001
        RegWrite, REG_DWORD, HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION, AutoHotkeyU64.exe, 11001
        RegWrite, REG_DWORD, HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION, AutoHotkeyU64_UIA.exe, 11001
    }
}

JsonEscapeStr(s) {
    bs := Chr(92)
    qt := Chr(34)
    s := StrReplace(s, bs, bs . bs)
    s := StrReplace(s, qt, bs . qt)
    s := StrReplace(s, "'", bs . "'")
    s := StrReplace(s, "`r", "")
    s := StrReplace(s, "`n", " ")
    s := StrReplace(s, "`t", " ")
    return s
}

GetBestLocalIP() {
    Loop, 4 {
        ip := A_IPAddress%A_Index%
        if (InStr(ip, "192.168.") = 1)
            return ip
    }
    Loop, 4 {
        ip := A_IPAddress%A_Index%
        if (InStr(ip, "10.") = 1 && ip != "10.8.1.1")
            return ip
    }
    return (A_IPAddress1 != "" && A_IPAddress1 != "0.0.0.0") ? A_IPAddress1 : "127.0.0.1"
}

BuildFluentInitialJson() {
    global Fio1, Rank, Otdel, Znak, Teg, Prop2, Frak, Gibdd, Gender, CheckMB, Vers, WinVerDescription, ActiveSendEngine
    global OnlyInGameMode, AutoScreenMode, HotkeyDefs, ArticlesDB, JournalEntries
    global TabletRelayHost, TabletRelayPin, TabletRelayOnline

    heroPath := StrReplace(A_ScriptDir . "\assets\fluent_hero.jpg", "\", "/")
    crestPath := StrReplace(A_ScriptDir . "\assets\fluent_crest.jpg", "\", "/")
    telPath := StrReplace(A_ScriptDir . "\assets\fluent_patrol_card.jpg", "\", "/")

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
    j .= """znak"":""" . JsonEscapeStr(Znak) . ""","
    j .= """teg"":""" . JsonEscapeStr(Teg) . ""","
    j .= """prop2"":""" . JsonEscapeStr(Prop2) . ""","
    j .= """frak"":""" . JsonEscapeStr(Frak) . ""","
    j .= """gibdd"":""" . JsonEscapeStr(Gibdd) . ""","
    j .= """gender"":""" . JsonEscapeStr(Gender) . ""","
    j .= """checkMB"":" . (CheckMB ? 1 : 0) . ","
    j .= """vers"":""" . JsonEscapeStr(Vers) . ""","
    j .= """winVer"":""" . JsonEscapeStr(WinVerDescription) . ""","
    j .= """sendEngine"":""" . JsonEscapeStr(ActiveSendEngine) . ""","
    j .= """onlyInGame"":" . (OnlyInGameMode ? 1 : 0) . ","
    j .= """autoScreen"":" . (AutoScreenMode ? 1 : 0) . ","
    j .= """localIp"":""" . JsonEscapeStr(GetBestLocalIP()) . ""","
    j .= """tabletPort"":" . (MobileServerPort ? MobileServerPort : 8088) . ","
    j .= """relayUrl"":""" . JsonEscapeStr(TabletRelayHost) . ""","
    j .= """tabletPin"":""" . JsonEscapeStr(TabletRelayPin) . ""","
    j .= """relayOnline"":" . (TabletRelayOnline ? 1 : 0)
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
        j .= "{""code"":""" . JsonEscapeStr(art.Code) . """,""num"":""" . JsonEscapeStr(art.Num) . """,""cmd"":""" . JsonEscapeStr(art.Cmd) . """,""fine"":" . (art.Fine + 0) . ",""sanction"":""" . JsonEscapeStr(art.Sanction) . """,""desc"":""" . JsonEscapeStr(art.Desc) . """}"
    }
    j .= "],"

    j .= """journal"":["
    for idx, item in JournalEntries {
        if (idx > 1)
            j .= ","
        j .= "{""time"":""" . JsonEscapeStr(item.Time) . """,""type"":""" . JsonEscapeStr(item.Type) . """,""target"":""" . JsonEscapeStr(item.Target) . """,""details"":""" . JsonEscapeStr(item.Details) . """,""amount"":""" . JsonEscapeStr(item.Amount) . """}"
    }
    j .= "]}"
    return j
}

InitAndShowFluentGlassUI() {
    global FluentWB, FluentGuiHwnd, FluentUiMode
    SetBrowserEmulationIE11()

    tplPath := A_ScriptDir . "\assets\fluent_template.html"
    if (!FileExist(tplPath)) {
        FluentUiMode := 0
        Gui, 1:Show
        Return
    }

    FileRead, htmlTpl, *P65001 %tplPath%
    jsonPayload := BuildFluentInitialJson()
    htmlFinal := StrReplace(htmlTpl, "/*__AHK_INITIAL_DATA__*/ {}", jsonPayload)

    runtimeHtml := A_Temp . "\gibdd_fluent_runtime.html"
    fileObj := FileOpen(runtimeHtml, "w", "UTF-8")
    if IsObject(fileObj) {
        fileObj.Write(htmlFinal)
        fileObj.Close()
    }

    FluentUiMode := 1
    winW := (A_ScreenWidth <= 1366) ? (A_ScreenWidth - 60) : 1240
    if (winW > 1240)
        winW := 1240
    if (winW < 1024)
        winW := 1024

    winH := (A_ScreenHeight <= 800) ? (A_ScreenHeight - 90) : 760
    if (winH > 760)
        winH := 760
    if (winH < 620)
        winH := 620

    Gui, 8:Destroy
    Gui, 8:+HwndFluentGuiHwnd -Caption +Border
    Gui, 8:Color, 070B14
    Gui, 8:Margin, 0, 0
    Gui, 8:Add, ActiveX, x0 y0 w%winW% h%winH% vFluentWB, Shell.Explorer
    FluentWB.Silent := true
    navUrl := "file:///" . StrReplace(runtimeHtml, "\", "/")
    FluentWB.Navigate(navUrl)

    ; Перехват сообщений ввода с клавиатуры для ActiveX WebBrowser (Backspace, Delete, ввод текста в поиск)
    OnMessage(0x0100, "Gui_KeyDown")
    OnMessage(0x0101, "Gui_KeyDown")

    startWait := A_TickCount
    while (FluentWB.ReadyState != 4 && (A_TickCount - startWait < 2500))
        Sleep, 15

    try {
        FluentWB.document.parentWindow.ahk_call := Func("OnFluentWebAction")
    }

    Gui, 8:Show, Center w%winW% h%winH%, АХК УГИБДД МВД — Fluent Police Glass
    MobileServer_Start(8088)
    Gosub, UpdateHudTick
}

Gui_KeyDown(wParam, lParam, nMsg, hWnd) {
    global FluentGuiHwnd, FluentWB
    static IID_IOleInPlaceActiveObject := "{00000117-0000-0000-C000-000000000046}"
    if (!FluentWB || !FluentGuiHwnd)
        return
    if (hWnd != FluentGuiHwnd && DllCall("GetAncestor", "Ptr", hWnd, "UInt", 2, "Ptr") != FluentGuiHwnd)
        return
    pipa := ComObjQuery(FluentWB, IID_IOleInPlaceActiveObject)
    if (!pipa)
        return
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
        return 0
}

RefreshFluentWebData() {
    global FluentWB, FluentUiMode
    if (!FluentUiMode || !IsObject(FluentWB))
        Return
    try {
        jsonPayload := BuildFluentInitialJson()
        jsCode := "window.APP_DATA = " . jsonPayload . "; initDashboard();"
        FluentWB.document.parentWindow.execScript(jsCode)
    }
}

SyncFluentLiveTelemetry(tId, dMode, dClock, dPct, cTxt, cPct, sTime, fPts, fCnt, aCnt, lCnt, rCnt) {
    global FluentWB, FluentUiMode
    if (!FluentUiMode || !IsObject(FluentWB))
        Return
    try {
        jsCall := "updateLiveState('" . JsonEscapeStr(tId) . "','" . JsonEscapeStr(dMode) . "','" . JsonEscapeStr(dClock) . "'," . (dPct + 0) . ",'" . JsonEscapeStr(cTxt) . "'," . (cPct + 0) . ",'" . JsonEscapeStr(sTime) . "'," . (fPts + 0) . "," . (fCnt + 0) . "," . (aCnt + 0) . "," . (lCnt + 0) . "," . (rCnt + 0) . ");"
        FluentWB.document.parentWindow.execScript(jsCall)
    }
}

SwitchToFluentUI:
Gui, 1:Hide
if (FluentGuiHwnd && WinExist("ahk_id " . FluentGuiHwnd)) {
    FluentUiMode := 1
    RefreshFluentWebData()
    Gui, 8:Show
} else {
    InitAndShowFluentGlassUI()
}
Return

OnFluentWebAction(action, arg1 := "", arg2 := "") {
    global FluentGuiHwnd, FluentUiMode, HIDDEN_NOW, OnlyInGameMode, AutoScreenMode, HotkeyById
    if (action = "mobile_action") {
        if (arg1 != "")
            ExecuteMobilePatrolCommand(arg1)
        Return
    }
    if (action = "drag_window") {
        DllCall("ReleaseCapture")
        PostMessage, 0xA1, 2,,, ahk_id %FluentGuiHwnd%
        Return
    }
    if (action = "win_minimize") {
        Gui, 8:Minimize
        Return
    }
    if (action = "win_close") {
        Suspend, Off
        Gui, 8:Hide
        HIDDEN_NOW := 1
        Menu, Tray, Rename, Свернуть, Развернуть
        Return
    }
    if (action = "switch_classic") {
        FluentUiMode := 0
        Gui, 8:Hide
        Gui, 1:Show
        Return
    }
    if (action = "copy_cmd") {
        Clipboard := arg1
        Return
    }
    if (action = "toggle_hud") {
        Gosub, ToggleHud
        Return
    }
    if (action = "drag_hud") {
        Gosub, ToggleHudEditMode
        Return
    }
    if (action = "open_calc") {
        if (FluentUiMode && IsObject(FluentWB)) {
            try {
                FluentWB.document.parentWindow.openCalcModal()
                Return
            }
        }
        Gosub, OpenCalc
        Return
    }
    if (action = "open_tablet_modal") {
        if (FluentUiMode && IsObject(FluentWB)) {
            try {
                FluentWB.document.parentWindow.openTabletModal()
                Return
            }
        }
        Return
    }
    if (action = "restart_mobile_server") {
        MobileServer_Stop()
        MobileServer_Start(8088)
        RefreshFluentWebData()
        SoundBeep, 900, 100
        bestIp := GetBestLocalIP()
        TrayTip, 📱 Мобильный планшет, Сервер перезапущен на порту 8088! IP: %bestIp%, 2, 1
        Return
    }
    if (action = "allow_firewall") {
        try {
            Run *RunAs "%A_ComSpec%" /c netsh advfirewall firewall add rule name="AHK Mobile Tablet" dir=in action=allow protocol=TCP localport=8088 profile=any,, Hide
            SoundBeep, 900, 120
            TrayTip, 🛡️ Брандмауэр Windows, Порт 8088 успешно открыт в брандмауэре!, 3, 1
        } catch {
            MsgBox, 48, Брандмауэр Windows, Требуются права администратора для разрешения входящего порта 8088!
        }
        Return
    }
    if (action = "open_web_url") {
        if (arg1 != "")
            Run, %arg1%
        Return
    }
    if (action = "open_moyak_memo") {
        Gosub, ButtonURLMoyak
        Return
    }
    if (action = "calc_send_overflow") {
        if (arg1 != "") {
            Gui, 8:Hide
            Sleep 250
            SendMessage, 0x50,, 0x4190419,, A
            SetCapsOff()
            Send, {F6}
            SmartSleep(200)
            Send, %arg1%{Space}
        }
        Return
    }
    if (action = "calc_play_tsu") {
        parts := StrSplit(arg1, "|")
        cmdToSend := parts[1]
        targetPlayer := (parts.MaxIndex() >= 2 && parts[2] != "") ? parts[2] : "ID"
        Gui, 8:Hide
        Sleep 250
        SendMessage, 0x50,, 0x4190419,, A
        SetCapsOff()
        Send, {F6}
        Sleep 250
        Send, /me открыл%ok1% базу данных и зашёл во вкладку "Фиксация нарушений"{Enter}{F6}
        Sleep 500
        Send, /me вн%ok9% данные о нарушении водителя в базу, затем нажал "Внести"{Enter}{F6}
        Sleep 300
        Send, /do Информация о штрафах введена в базу данных.{Enter}{F6}
        Sleep 250
        Send, %cmdToSend%{Space}
        LogJournalAction("Штраф", targetPlayer, cmdToSend, 0)
        TriggerSmartScreenshot("Выписка штрафа")
        Return
    }
    if (action = "calc_play_lic") {
        parts := StrSplit(arg1, "|")
        cmdToSend := parts[1]
        targetPlayer := (parts.MaxIndex() >= 2 && parts[2] != "") ? parts[2] : "ID"
        Gui, 8:Hide
        Sleep 250
        SendMessage, 0x50,, 0x4190419,, A
        SetCapsOff()
        Send, {F6}
        SmartSleep(250)
        Send, /me открыл%ok1% базу данных и зашёл во вкладку "Аннулирование ВУ"{Enter}{F6}
        SmartSleep(500)
        Send, /me вн%ok9% данные гражданина и срок лишения, после чего нажал%ok1% "Аннулировать"{Enter}{F6}
        SmartSleep(500)
        Send, /do Информация о недействительности ВУ внесена в базу данных.{Enter}{F6}
        SmartSleep(500)
        Send, Ваши права больше недействительны. Идите на пересдачу в автошколу{!}{Enter}{F6}
        SmartSleep(350)
        Send, %cmdToSend%{Space}
        LogJournalAction("Лишение ВУ", targetPlayer, cmdToSend, 0)
        TriggerSmartScreenshot("Аннулирование ВУ")
        Return
    }
    if (action = "calc_speak_articles") {
        artCmds := StrSplit(arg1, "|")
        if (artCmds.MaxIndex() > 0) {
            Gui, 8:Hide
            Sleep 350
            SendMessage, 0x50,, 0x4190419,, A
            SetCapsOff()
            for idx, cmdName in artCmds {
                for aIdx, art in ArticlesDB {
                    if (art.Cmd = cmdName) {
                        parts := StrSplit(art.RawLines, "||")
                        for pIdx, lineText in parts {
                            Send, {F6}
                            SmartSleep(350)
                            Send, %lineText%{Enter}
                            SmartSleep(1800)
                        }
                        break
                    }
                }
            }
        }
        Return
    }
    if (action = "open_profile") {
        Gosub, Data
        Return
    }
    if (action = "export_backup") {
        Gosub, ExportProfileBackup
        Return
    }
    if (action = "import_backup") {
        Gosub, ImportProfileBackup
        Return
    }
    if (action = "check_updates") {
        Gosub, ManualCheckUpdates
        Return
    }
    if (action = "open_links") {
        Gosub, Help
        Return
    }
    if (action = "reload_app") {
        Reload
        Return
    }
    if (action = "open_fzop") {
        Gosub, OpenFzopGuide
        Return
    }
    if (action = "open_koap") {
        Gosub, OpenKoapGuide
        Return
    }
    if (action = "open_uk") {
        Gosub, OpenUkGuide
        Return
    }
    if (action = "toggle_only_ingame") {
        OnlyInGameMode := !OnlyInGameMode
        GuiControl, 1:, OnlyInGameChk, %OnlyInGameMode%
        Gosub, ToggleOnlyInGameMode
        RefreshFluentWebData()
        Return
    }
    if (action = "toggle_autoscreen") {
        AutoScreenMode := !AutoScreenMode
        GuiControl, 1:, AutoScreenChk, %AutoScreenMode%
        Gosub, ToggleAutoScreenMode
        RefreshFluentWebData()
        Return
    }
    if (action = "suspend_hotkeys") {
        if (arg1 = "1")
            Suspend, On
        else
            Suspend, Off
        Return
    }
    if (action = "remap_hotkey") {
        if (arg1 != "" && HotkeyById.HasKey(arg1)) {
            OpenQuickHotkeyRemapModal(arg1)
        }
        Return
    }
    if (action = "save_hotkey_web") {
        parts := StrSplit(arg1, "|")
        targetHk := parts[1]
        rawKey := parts[2]
        if (targetHk != "" && HotkeyById.HasKey(targetHk) && rawKey != "") {
            SelectedHkId := targetHk
            ApplySingleHotkeyUpdate(targetHk, rawKey)
            RefreshFluentWebData()
            SoundBeep, 900, 120
            TrayTip, ⌨️ Клавиша обновлена!, % HotkeyById[targetHk].Name . ": [" . FormatHotkeyReadable(rawKey) . "]", 2, 1
        }
        Return
    }
    if (action = "reset_hotkey_web") {
        targetHk := arg1
        if (targetHk != "" && HotkeyById.HasKey(targetHk)) {
            SelectedHkId := targetHk
            ApplySingleHotkeyUpdate(targetHk, HotkeyById[targetHk].DefaultKey)
            RefreshFluentWebData()
            SoundBeep, 800, 100
            TrayTip, 🔄 Клавиша сброшена, % HotkeyById[targetHk].Name . " возвращена по умолчанию", 2, 1
        }
        Return
    }
    if (action = "reset_all_hotkeys") {
        Gosub, ResetAllHotkeysBtn
        RefreshFluentWebData()
        Return
    }
    if (action = "open_custom_binds") {
        Gosub, OpenAddCustomBindDialog
        RefreshFluentWebData()
        Return
    }
    if (action = "journal_copy_report") {
        Gosub, CopyJournalReportBtn
        Return
    }
    if (action = "journal_export_csv") {
        Gosub, ExportJournalCsvBtn
        Return
    }
    if (action = "journal_add_manual") {
        Gosub, AddManualJournalBtn
        RefreshFluentWebData()
        Return
    }
    if (action = "journal_clear") {
        Gosub, ClearJournalDataBtn
        RefreshFluentWebData()
        Return
    }
    if (action = "save_profile_web") {
        global Frak, Fio1, Rank, Teg, Prop2, Znak, Otdel, Gibdd, Gender, CheckMB, Vers
        parts := StrSplit(arg1, "|")
        if (parts.MaxIndex() >= 9) {
            Frak := Trim(parts[1])
            Fio1 := Trim(parts[2])
            Rank := Trim(parts[3])
            Teg := Trim(parts[4])
            Prop2 := Trim(parts[5])
            Znak := Trim(parts[6])
            Otdel := Trim(parts[7])
            Gibdd := Trim(parts[8])
            Gender := Trim(parts[9])
            CheckMB := (parts.MaxIndex() >= 10 && parts[10] = "1") ? 1 : 0

            for idx, iniPath in [A_Temp . "\gibdd.egl", A_ScriptDir . "\gibdd_profile.ini"] {
                IniWrite, %Fio1%, %iniPath%, Save, FIO1
                IniWrite, %Frak%, %iniPath%, Save, FRAK
                IniWrite, %Gibdd%, %iniPath%, Save, GIBDD
                IniWrite, %Otdel%, %iniPath%, Save, OTDEL
                IniWrite, %Znak%, %iniPath%, Save, ZNAK
                IniWrite, %Teg%, %iniPath%, Save, TEG
                IniWrite, %Prop2%, %iniPath%, Save, PROP2
                IniWrite, %Rank%, %iniPath%, Save, RANK
                IniWrite, %Gender%, %iniPath%, Save, GENDER
                IniWrite, %CheckMB%, %iniPath%, Save, CHECKMB
            }

            if (Gender = "Я девочка") {
                Vers := "2.4.0ж"
                Ok1 := "а", Ok2 := "ла", Ok3 := "ась", Ok4 := "цы", Ok5 := "ца", Ok6 := "це", Ok7 := "ла", Ok8 := "ела", Ok9 := "есла", Ok10 := "цей", Ok11 := "екла"
                Pol := "👩‍⚕️", Gend := "женский"
            } else {
                Vers := "2.4.0м"
                Ok1 := "", Ok2 := "", Ok3 := "ся", Ok4 := "ка", Ok5 := "к", Ok6 := "ке", Ok7 := "ёл", Ok8 := "ёл", Ok9 := "ёс", Ok10 := "ком", Ok11 := "ёк"
                Pol := "👨‍⚕️", Gend := "мужской"
            }

            UpdateSidebarOfficerCard()
            RefreshFluentWebData()
            SoundBeep, 900, 120
            TrayTip, ✅ Профиль сохранён, % Rank . " " . Fio1 . " (" . Teg . "-" . Prop2 . ")", 3, 1
        }
        Return
    }
}

OpenQuickHotkeyRemapModal(hkId) {
    global QuickRemapTargetId, HotkeyById, QuickHkBox, QuickModCtrl, QuickModAlt, QuickModShift, QuickSpecDDL
    if (!HotkeyById.HasKey(hkId))
        Return
    QuickRemapTargetId := hkId
    hkObj := HotkeyById[hkId]
    curD := FormatHotkeyReadable(hkObj.CurrentKey)
    defD := FormatHotkeyReadable(hkObj.DefaultKey)

    curKey := hkObj.CurrentKey
    hasCtrl := InStr(curKey, "^") ? 1 : 0
    hasAlt := InStr(curKey, "!") ? 1 : 0
    hasShift := InStr(curKey, "+") ? 1 : 0
    baseKey := RegExReplace(curKey, "[\^!+]", "")

    Suspend, On

    Gui, 10:Destroy
    Gui, 10:+AlwaysOnTop +Owner8
    Gui, 10:Color, 0E1422, 162238
    Gui, 10:Font, S11 C58A6FF Bold, Segoe UI
    Gui, 10:Add, Text, x16 y12 w488 h24, ⌨️ Переназначение горячей клавиши
    Gui, 10:Font, S9 CFFB84D Bold, Segoe UI
    Gui, 10:Add, Text, x16 y38 w488 h20, % hkObj.Name
    Gui, 10:Font, S9 C8B949E Norm, Segoe UI
    Gui, 10:Add, Text, x16 y58 w488 h18, % "Текущая: [" . curD . "]   |   По умолчанию: [" . defD . "]"

    Gui, 10:Font, S9 CE6EDF3 Bold, Segoe UI
    Gui, 10:Add, Text, x16 y88 w210 h22, Способ 1 (нажмите клавишу):
    Gui, 10:Font, S9 C000000 Norm, Segoe UI
    Gui, 10:Add, Hotkey, x230 y86 w260 h24 vQuickHkBox, % hkObj.CurrentKey

    Gui, 10:Font, S9 CE6EDF3 Bold, Segoe UI
    Gui, 10:Add, Text, x16 y122 w210 h22, Способ 2 (спецклавиша):
    Gui, 10:Add, CheckBox, x230 y122 w52 h22 vQuickModCtrl Checked%hasCtrl%, Ctrl
    Gui, 10:Add, CheckBox, x284 y122 w48 h22 vQuickModAlt Checked%hasAlt%, Alt
    Gui, 10:Add, CheckBox, x334 y122 w56 h22 vQuickModShift Checked%hasShift%, Shift

    specList := "(Нет)|PrintScreen|ScrollLock|Delete|Insert|Home|End|Backspace|sc29 (Ё/~)|Space|Tab|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|1|2|3|4|5|6|7|8|9|0|-|=|Q|W|E|R|T|Y|U|I|O|P|A|S|D|F|G|H|J|K|L|Z|X|C|V|B|N|M|Numpad0|Numpad1|Numpad2|Numpad3|Numpad4|Numpad5|Numpad6|Numpad7|Numpad8|Numpad9|NumpadAdd|NumpadSub|NumpadMult|NumpadDiv"
    Gui, 10:Add, DropDownList, x392 y120 w98 r14 vQuickSpecDDL Choose1, %specList%

    Gui, 10:Font, S9 CE6EDF3 Bold, Segoe UI
    Gui, 10:Add, Button, x16 y162 w175 h34 gSaveQuickRemapBtn, ✅ Сохранить клавишу
    Gui, 10:Add, Button, x200 y162 w165 h34 gResetQuickRemapBtn, 🔄 По умолчанию
    Gui, 10:Add, Button, x374 y162 w116 h34 gCloseQuickRemapBtn, Отмена

    if (baseKey != "") {
        if (baseKey = "sc29")
            GuiControl, 10:ChooseString, QuickSpecDDL, sc29 (Ё/~)
        else
            GuiControl, 10:ChooseString, QuickSpecDDL, %baseKey%
    }

    Gui, 10:Show, w510 h212, Настройка клавиши — Fluent Glass
}

SaveQuickRemapBtn:
Gui, 10:Submit, NoHide
if (QuickRemapTargetId = "" || !HotkeyById.HasKey(QuickRemapTargetId)) {
    Suspend, Off
    Gui, 10:Destroy
    Return
}
targetObj := HotkeyById[QuickRemapTargetId]

newKey := ""
specChosen := (QuickSpecDDL != "" && QuickSpecDDL != "(Нет)" && QuickSpecDDL != "(Не выбрано)")

normHkBox := NormalizeAhkHotkey(QuickHkBox)
builtSpecKey := specChosen ? BuildSpecialKeyString(QuickModCtrl, QuickModAlt, QuickModShift, QuickSpecDDL) : ""

; Если выбрана спецклавиша в Способе 2 и она отличается от текущей комбинации:
if (specChosen && builtSpecKey != "" && NormalizeAhkHotkey(builtSpecKey) != NormalizeAhkHotkey(targetObj.CurrentKey)) {
    newKey := builtSpecKey
} else if (normHkBox != "" && normHkBox != NormalizeAhkHotkey(targetObj.CurrentKey)) {
    newKey := normHkBox
} else if (builtSpecKey != "") {
    newKey := builtSpecKey
} else if (normHkBox != "") {
    newKey := normHkBox
}

newKey := NormalizeAhkHotkey(newKey)
if (newKey = "") {
    MsgBox, 48, Настройка клавиши, Пожалуйста, нажмите нужную комбинацию в поле «Способ 1» или выберите спецклавишу в списке «Способ 2»!
    Return
}

; Если клавиша не изменилась
if (Format("{:L}", newKey) = Format("{:L}", targetObj.CurrentKey)) {
    Suspend, Off
    Gui, 10:Destroy
    TrayTip, ⌨️ Горячая клавиша осталась прежней, % targetObj.Name . ": [" . FormatHotkeyReadable(newKey) . "]", 2, 1
    Return
}

; Проверка на конфликт с другими биндами
for idx, otherHk in HotkeyDefs {
    if (otherHk.Id != QuickRemapTargetId && Format("{:L}", otherHk.CurrentKey) = Format("{:L}", newKey)) {
        MsgBox, 52, Конфликт клавиш, % "Клавиша [" . FormatHotkeyReadable(newKey) . "] уже используется для бинда:`n«" . otherHk.Name . "»!`n`nВсё равно назначить её сюда?"
        IfMsgBox, No
            Return
        break
    }
}

Suspend, Off
Gui, 10:Destroy
ApplySingleHotkeyUpdate(QuickRemapTargetId, newKey)
RefreshFluentWebData()
SoundBeep, 900, 100
TrayTip, ✅ Горячая клавиша обновлена!, % targetObj.Name . " -> [" . FormatHotkeyReadable(newKey) . "]", 3, 1
Return

ResetQuickRemapBtn:
if (QuickRemapTargetId = "" || !HotkeyById.HasKey(QuickRemapTargetId)) {
    Suspend, Off
    Gui, 10:Destroy
    Return
}
targetObj := HotkeyById[QuickRemapTargetId]
defKey := targetObj.DefaultKey
Suspend, Off
Gui, 10:Destroy
ApplySingleHotkeyUpdate(QuickRemapTargetId, defKey)
RefreshFluentWebData()
SoundBeep, 800, 100
TrayTip, 🔄 Сброс горячей клавиши, % targetObj.Name . " -> [" . FormatHotkeyReadable(defKey) . "]", 3, 1
Return

CloseQuickRemapBtn:
10GuiClose:
10GuiEscape:
Suspend, Off
Gui, 10:Destroy
Return

ApplySingleHotkeyUpdate(hkId, newKey) {
    global HotkeyById, HotkeyDefs, HkFilterQuery, BindSearchQuery, BindCatFilter
    if (!HotkeyById.HasKey(hkId))
        Return

    newKey := NormalizeAhkHotkey(newKey)
    if (newKey = "")
        Return

    targetObj := HotkeyById[hkId]
    UnregisterDynamicHotkey(targetObj)
    targetObj.CurrentKey := newKey
    for idx, hk in HotkeyDefs {
        if (hk.Id = hkId) {
            HotkeyDefs[idx].CurrentKey := newKey
            break
        }
    }
    RegisterDynamicHotkey(targetObj)
    for idx, iniPath in [A_Temp . "\gibdd.egl", A_ScriptDir . "\gibdd_profile.ini"] {
        IniWrite, %newKey%, %iniPath%, Hotkeys, %hkId%
    }
    RefreshAllHotkeyGuiLabels()
    InitBindsCatalog()
    try {
        PopulateHotkeysListView(HkFilterQuery)
        SelectHotkeyInLV(hkId)
        PopulateBindsListView(BindSearchQuery, BindCatFilter)
    }
}

; =================================================================================================
; МОБИЛЬНЫЙ БОРТОВОЙ ПЛАНШЕТ МВД (ОБЛАЧНЫЙ РЕЛЕЙ + ЛОКАЛЬНЫЙ WINSOCK)
; =================================================================================================
global MobileServerSock := -1
global MobileServerPort := 8088
global LiveShiftDuration := "00:00"
global LiveForumPoints := 0
global LiveFinesCount := 0
global LiveArrestsCount := 0
global LiveTargetId := "—"

global TabletRelayHost := "http://152.234.229.245:3000"
global TabletRelayPin := "51"
global TabletRelayOnline := 0

TabletRelay_Init() {
    global TabletRelayHost, TabletRelayPin, Teg
    iniPath := A_Temp . "\gibdd.egl"
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

MobileServer_Start(Port := 8088) {
    global MobileServerSock, MobileServerPort
    if (MobileServerSock != -1)
        return true
    MobileServerPort := Port

    VarSetCapacity(wsaData, 400, 0)
    if DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", &wsaData)
        return false

    MobileServerSock := DllCall("ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "Ptr")
    if (MobileServerSock = -1)
        return false

    VarSetCapacity(addr, 16, 0)
    NumPut(2, addr, 0, "UShort")
    NumPut(DllCall("ws2_32\htons", "UShort", Port, "UShort"), addr, 2, "UShort")
    NumPut(0, addr, 4, "UInt")

    if DllCall("ws2_32\bind", "Ptr", MobileServerSock, "Ptr", &addr, "Int", 16) {
        MobileServer_Stop()
        return false
    }

    if DllCall("ws2_32\listen", "Ptr", MobileServerSock, "Int", 16) {
        MobileServer_Stop()
        return false
    }

    OnMessage(0x8055, "MobileServer_OnSocketMsg")
    DllCall("ws2_32\WSAAsyncSelect", "Ptr", MobileServerSock, "Ptr", A_ScriptHwnd, "UInt", 0x8055, "Int", 8)
    return true
}

MobileServer_Stop() {
    global MobileServerSock
    if (MobileServerSock != -1) {
        DllCall("ws2_32\closesocket", "Ptr", MobileServerSock)
        DllCall("ws2_32\WSACleanup")
        MobileServerSock := -1
    }
}

MobileServer_SendResponse(clientSock, cType, ByRef body) {
    bodyLen := StrPut(body, "UTF-8") - 1
    resp := "HTTP/1.1 200 OK`r`n"
    resp .= "Content-Type: " . cType . "`r`n"
    resp .= "Access-Control-Allow-Origin: *`r`n"
    resp .= "Access-Control-Allow-Methods: GET, POST, OPTIONS`r`n"
    resp .= "Access-Control-Allow-Headers: *`r`n"
    resp .= "Connection: close`r`n"
    resp .= "Content-Length: " . bodyLen . "`r`n`r`n"
    resp .= body

    totalLen := StrPut(resp, "UTF-8") - 1
    VarSetCapacity(sendData, totalLen + 1, 0)
    StrPut(resp, &sendData, "UTF-8")

    totalSent := 0
    p := &sendData
    loopCount := 0
    while (totalSent < totalLen && loopCount < 100) {
        loopCount++
        sent := DllCall("ws2_32\send", "Ptr", clientSock, "Ptr", p + totalSent, "Int", totalLen - totalSent, "Int", 0)
        if (sent > 0) {
            totalSent += sent
        } else {
            err := DllCall("ws2_32\WSAGetLastError")
            if (err = 10035) { ; WSAEWOULDBLOCK
                Sleep, 10
                continue
            }
            break
        }
    }
    DllCall("ws2_32\shutdown", "Ptr", clientSock, "Int", 1) ; SD_SEND
    Sleep, 15
    DllCall("ws2_32\closesocket", "Ptr", clientSock)
}

MobileServer_OnSocketMsg(wParam, lParam, msg, hwnd) {
    global MobileServerSock, Fio1, Rank, Teg, Prop2, Gibdd, ArticlesDB
    global LiveShiftDuration, LiveForumPoints, LiveFinesCount, LiveArrestsCount, LiveTargetId

    event := lParam & 0xFFFF
    clientSock := wParam

    if (clientSock = MobileServerSock) {
        if (event = 8) { ; FD_ACCEPT
            VarSetCapacity(clientAddr, 16, 0)
            addrLen := 16
            newClient := DllCall("ws2_32\accept", "Ptr", MobileServerSock, "Ptr", &clientAddr, "IntP", addrLen, "Ptr")
            if (newClient != -1) {
                DllCall("ws2_32\WSAAsyncSelect", "Ptr", newClient, "Ptr", A_ScriptHwnd, "UInt", 0x8055, "Int", 33)
            }
        }
        return
    }

    if (event = 1) { ; FD_READ
        VarSetCapacity(recvBuf, 4096, 0)
        bytesRead := DllCall("ws2_32\recv", "Ptr", clientSock, "Ptr", &recvBuf, "Int", 4095, "Int", 0)
        if (bytesRead > 0) {
            reqStr := StrGet(&recvBuf, bytesRead, "UTF-8")
            line1 := StrSplit(reqStr, "`n")[1]
            parts := StrSplit(line1, " ")
            method := parts[1]
            urlPath := parts[2]

            ; CORS Preflight
            if (method = "OPTIONS") {
                optResp := "HTTP/1.1 204 No Content`r`nAccess-Control-Allow-Origin: *`r`nAccess-Control-Allow-Methods: GET, POST, OPTIONS`r`nAccess-Control-Allow-Headers: *`r`nConnection: close`r`n`r`n"
                VarSetCapacity(optData, StrPut(optResp, "UTF-8"), 0)
                optLen := StrPut(optResp, &optData, "UTF-8") - 1
                DllCall("ws2_32\send", "Ptr", clientSock, "Ptr", &optData, "Int", optLen, "Int", 0)
                DllCall("ws2_32\shutdown", "Ptr", clientSock, "Int", 1)
                Sleep, 10
                DllCall("ws2_32\closesocket", "Ptr", clientSock)
                return
            }

            body := ""
            cType := "text/plain; charset=utf-8"

            if (InStr(urlPath, "/api/state")) {
                cType := "application/json; charset=utf-8"
                body := "{"
                body .= """profile"":{"
                body .= """fio"":""" . JsonEscapeStr(Fio1) . ""","
                body .= """rank"":""" . JsonEscapeStr(Rank) . ""","
                body .= """teg"":""" . JsonEscapeStr(Teg) . ""","
                body .= """prop2"":""" . JsonEscapeStr(Prop2) . ""","
                body .= """gibdd"":""" . JsonEscapeStr(Gibdd) . """"
                body .= "},"
                body .= """live"":{"
                body .= """dutyClock"":""" . JsonEscapeStr(LiveShiftDuration) . ""","
                body .= """finesCnt"":" . (LiveFinesCount + 0) . ","
                body .= """arrestsCnt"":" . (LiveArrestsCount + 0) . ","
                body .= """forumPts"":" . (LiveForumPoints + 0) . ","
                body .= """targetId"":""" . JsonEscapeStr(LiveTargetId) . """"
                body .= "}"
                body .= "}"
            } else if (InStr(urlPath, "/api/articles")) {
                cType := "application/json; charset=utf-8"
                body := "["
                for idx, art in ArticlesDB {
                    if (idx > 1)
                        body .= ","
                    body .= "{""code"":""" . JsonEscapeStr(art.Code) . """,""num"":""" . JsonEscapeStr(art.Num) . """,""sanction"":""" . JsonEscapeStr(art.Sanction) . """,""desc"":""" . JsonEscapeStr(art.Desc) . """}"
                }
                body .= "]"
            } else if (InStr(urlPath, "/api/action")) {
                cType := "application/json; charset=utf-8"
                cmdName := ""
                if RegExMatch(urlPath, "cmd=([^& ]+)", m)
                    cmdName := m1
                ExecuteMobilePatrolCommand(cmdName)
                body := "{""ok"":true,""cmd"":""" . cmdName . """}"
            } else {
                cType := "text/html; charset=utf-8"
                tabletFile := A_ScriptDir . "\assets\mobile_tablet.html"
                if (FileExist(tabletFile)) {
                    FileRead, body, *P65001 %tabletFile%
                } else {
                    body := "<h1>Mobile Tablet File Not Found</h1>"
                }
            }

            MobileServer_SendResponse(clientSock, cType, body)
            return
        }
        DllCall("ws2_32\closesocket", "Ptr", clientSock)
    } else if (event = 32) { ; FD_CLOSE
        DllCall("ws2_32\closesocket", "Ptr", clientSock)
    }
}

ExecuteMobilePatrolCommand(cmd, arg := "") {
    global Fio1, Rank, Teg, Prop2, Vers, AbortBindFlag, ArticlesDB, TargetId, IdMan

    if (InStr(cmd, "set_target_id|") = 1) {
        newT := SubStr(cmd, 15)
        TargetId := newT
        IdMan := newT
        SoundBeep, 850, 80
        TrayTip, 🎯 Цель обновлена, Установлен ID: %newT%, 2, 1
        return
    }

    if (cmd = "target_info") {
        tid := (TargetId != "") ? TargetId : IdMan
        if (tid != "") {
            SetLocaleRu()
            SetCapsOff()
            SendPlay {F8}^A{Delete}/id %tid%{Enter}{F8}
        } else {
            TrayTip, ⚠️ Планшет, Сначала укажите ID цели в поле сверху!, 2, 2
        }
        return
    }

    if (InStr(cmd, "speak_art|") = 1) {
        artCmd := SubStr(cmd, 11)
        for aIdx, art in ArticlesDB {
            if (art.Cmd = artCmd || art.Num = artCmd || art.Cmd = "/" . artCmd) {
                SetLocaleRu()
                SetCapsOff()
                parts := StrSplit(art.RawLines, "||")
                for pIdx, lineText in parts {
                    Send, {F6}
                    SmartSleep(350)
                    Send, %lineText%{Enter}
                    SmartSleep(1800)
                }
                break
            }
        }
        return
    }

    if (InStr(cmd, "speak_arts|") = 1) {
        artsList := StrSplit(SubStr(cmd, 12), ",")
        SetLocaleRu()
        SetCapsOff()
        for cIdx, cName in artsList {
            for aIdx, art in ArticlesDB {
                if (art.Cmd = cName || art.Num = cName || art.Cmd = "/" . cName) {
                    parts := StrSplit(art.RawLines, "||")
                    for pIdx, lineText in parts {
                        Send, {F6}
                        SmartSleep(350)
                        Send, %lineText%{Enter}
                        SmartSleep(1800)
                    }
                    break
                }
            }
        }
        return
    }

    if (InStr(cmd, "fine_calc|") = 1) {
        payload := SubStr(cmd, 11)
        pipeIdx := InStr(payload, "|")
        if (pipeIdx > 0) {
            sumVal := SubStr(payload, 1, pipeIdx - 1)
            artsVal := SubStr(payload, pipeIdx + 1)
        } else {
            sumVal := payload
            artsVal := ""
        }
        tid := (TargetId != "") ? TargetId : IdMan
        if (tid = "") {
            TrayTip, ⚠️ Калькулятор штрафов, Сначала укажите ID нарушителя в поле Цель ID!, 3, 2
            return
        }
        SetLocaleRu()
        SetCapsOff()
        SendPlay {F8}^A{Delete}/ticket %tid% %sumVal% %artsVal%{Enter}{F8}
        SoundBeep, 750, 150
        return
    }

    if (cmd = "stop_bind") {
        AbortBindFlag := 1
        SoundBeep, 600, 150
        TrayTip, ⛔ Остановка биндера, Текущая отыгровка экстренно остановлена!, 2, 2
        return
    }

    if (cmd = "meg1") {
        Gosub, Bind_Megaphone1
    } else if (cmd = "meg2") {
        Gosub, Bind_Megaphone2
    } else if (cmd = "meg3") {
        Gosub, Bind_Megaphone3
    } else if (cmd = "meg_way") {
        Gosub, Bind_MegaphoneWay
    } else if (cmd = "foot_chase") {
        Gosub, Bind_FootChase
    } else if (cmd = "wcar") {
        Gosub, PressCount
    } else if (cmd = "greeting") {
        Gosub, Bind_Greeting
    } else if (cmd = "ask_docs") {
        Gosub, Bind_AskDocs
    } else if (cmd = "take_docs") {
        Gosub, Bind_TakeDocs
    } else if (cmd = "return_docs") {
        Gosub, Bind_ReturnDocs
    } else if (cmd = "kpk_open") {
        Gosub, Bind_KpkOpen
    } else if (cmd = "kpk_vu") {
        Gosub, Bind_KpkVu
    } else if (cmd = "kpk_close") {
        Gosub, Bind_KpkClose
    } else if (cmd = "cuffs_open") {
        Gosub, Bind_CuffsOpen
    } else if (cmd = "cuffs_close") {
        Gosub, Bind_CuffsClose
    } else if (cmd = "putpl") {
        Gosub, Bind_Putpl
    } else if (cmd = "pullout") {
        Gosub, Bind_PullOutTry
    } else if (cmd = "try_door") {
        Gosub, Bind_TryDoor
    } else if (cmd = "try_glass") {
        Gosub, Bind_TryGlass
    } else if (cmd = "unlock_in") {
        Gosub, Bind_UnlockIn
    } else if (cmd = "detain_prot") {
        Gosub, Bind_DetainProt
    } else if (cmd = "admin_prot") {
        Gosub, Bind_AdminProt
    } else if (cmd = "arrest") {
        Gosub, Bind_Arrest
    } else if (cmd = "tsu") {
        Gosub, Bind_Tsu
    } else if (cmd = "su_fast") {
        Gosub, Bind_SuFast
    } else if (cmd = "su_sound") {
        Gosub, Bind_SuSound
    } else if (cmd = "clock") {
        Gosub, Bind_Clock
    } else if (cmd = "voice_on") {
        PlayRadioSfx("radio_start.wav")
        Gosub, Bind_VoiceOn
    } else if (cmd = "voice_off") {
        PlayRadioSfx("radio_stop.wav")
        Gosub, Bind_VoiceOff
    } else if (cmd = "shout_hands") {
        Gosub, Bind_ShoutHands
    } else if (cmd = "report_patrol") {
        PlayRadioSfx("radio_start.wav")
        SetLocaleRu()
        SetCapsOff()
        SendPlay {F8}^A{Delete}/r [%Teg%-%Prop2%] Докладывает %Rank% %Fio1%. Веду патрулирование города. Код: 10-4.{Enter}{F8}
        Sleep, 250
        PlayRadioSfx("radio_stop.wav")
    } else if (cmd = "report_chase") {
        PlayRadioSfx("radio_start.wav")
        SetLocaleRu()
        SetCapsOff()
        SendPlay {F8}^A{Delete}/r [%Teg%-%Prop2%] Докладывает %Rank% %Fio1%. Веду преследование нарушителя! Код: 10-57.{Enter}{F8}
        Sleep, 250
        PlayRadioSfx("radio_stop.wav")
    } else if (cmd = "report_help") {
        PlayRadioSfx("radio_start.wav")
        SetLocaleRu()
        SetCapsOff()
        SendPlay {F8}^A{Delete}/r [%Teg%-%Prop2%] Докладывает %Rank% %Fio1%. Срочно требуется поддержка экипажа! Код: 10-33.{Enter}{F8}
        Sleep, 250
        PlayRadioSfx("radio_stop.wav")
    } else if (cmd = "report_start") {
        PlayRadioSfx("radio_start.wav")
        SetLocaleRu()
        SetCapsOff()
        SendPlay {F8}^A{Delete}/r [%Teg%-%Prop2%] Докладывает %Rank% %Fio1%. Выехал в патруль. Код: 10-8.{Enter}{F8}
        Sleep, 250
        PlayRadioSfx("radio_stop.wav")
    } else if (cmd = "report_end") {
        PlayRadioSfx("radio_start.wav")
        SetLocaleRu()
        SetCapsOff()
        SendPlay {F8}^A{Delete}/r [%Teg%-%Prop2%] Докладывает %Rank% %Fio1%. Окончил патрулирование, перерыв. Код: 10-7.{Enter}{F8}
        Sleep, 250
        PlayRadioSfx("radio_stop.wav")
    }
}

; =================================================================================================
; ТАКТИЧЕСКИЕ ЗВУКИ РАЦИИ (RADIO SFX) ДЛЯ ГОЛОСА И БИНДОВ В МТА ПРОВИНЦИИ
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
TrayTip, 📻 Проверка рации УГИБДД, Щелчок тангенты и Roger Beep работают исправно!, 3, 1
return
#If

; =================================================================================================
; КЛИЕНТСКИЙ ТЕЛЕМЕТРИЧЕСКИЙ ПУЛЬС В КОМАНДНЫЙ ЦЕНТР (ADMIN DASHBOARD)
; =================================================================================================
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
    global TabletRelayHost, Fio1, Rank, Teg, Prop2, Gibdd, Vers
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
    payload .= """city"":""" . JsonEscapeStr(Gibdd) . ""","
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
        whr.SetRequestHeader("User-Agent", "AHK-GIBDD/" . Vers)
        whr.Send(payload)
        if (whr.WaitForResponse(1.5)) {
            resp := whr.ResponseText
            if (InStr(resp, """broadcast"":{")) {
                RegExMatch(resp, "O)""id"":""([^""]+)"".*?""message"":""([^""]+)""", match)
                if (match && match.1 != LastBroadcastMessageId) {
                    LastBroadcastMessageId := match.1
                    msgText := StrReplace(match.2, "\n", "`n")
                    SoundPlay, %A_ScriptDir%\1.mp3
                    TrayTip, 📢 ОПОВЕЩЕНИЕ РУКОВОДСТВА УГИБДД!, %msgText%, 8, 2
                }
            }
        }
    } catch e {
        ; Игнорируем сетевые сбои в оффлайне
    }
}
