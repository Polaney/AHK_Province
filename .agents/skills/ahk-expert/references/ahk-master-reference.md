# Полный справочник AHK-Эксперта (AHK v1.1 & v2, RP-Биндеры, WinAPI, GUI)

## 1. Оптимальный шаблон заголовка для боевых скриптов и биндеров (AHK v1.1)

```autohotkey
#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 200
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
SetWorkingDir %A_ScriptDir%
FileEncoding, UTF-8
```
> **Примечание для MTA Province**: если отправка в консоль `F8` выполняется через `SendPlay`, глобальный `SendMode Input` не мешает прямому вызову `SendPlay`, но ускоряет все остальные действия.

---

## 2. Работа с раскладкой, CapsLock и залипанием модификаторов

### Принудительное переключение языка активного окна
```autohotkey
SetLocaleRu() {
    SendMessage, 0x50,, 0x4190419,, A ; WM_INPUTLANGCHANGEREQUEST -> RU (0x0419)
}

SetLocaleEn() {
    SendMessage, 0x50,, 0x4090409,, A ; WM_INPUTLANGCHANGEREQUEST -> EN (0x0409)
}
```

### Защита от «залипания» клавиш Alt / Ctrl / Shift при срабатывании бинда
Когда пользователь нажимает комбинацию вроде `!1` (`Alt+1`) или `^2` (`Ctrl+2`), а скрипт начинает отправлять текст через `SendPlay`/`SendInput`, модификатор может «залипнуть» или исказить отправляемый текст.
- Используй префикс `$` (хук клавиатуры): `$!1::`
- При необходимости дожидайся отпускания модификаторов перед отправкой:
```autohotkey
ReleaseModifiers() {
    KeyWait, Alt, T0.5
    KeyWait, Ctrl, T0.5
    KeyWait, Shift, T0.5
    SendInput {Alt Up}{Ctrl Up}{Shift Up}
}
```

---

## 3. Паттерны MTA Province / SAMP / CRMP

### Отправка текста через консоль `F8` (MTA Province)
- В MTA Province команды (`say`, `me`, `do`, `try`, `b`, `f`, `r`, `d`, `m`, `wanted` и т.д.) надежнее всего отправляются через консоль `F8`:
  `SendPlay {F8}^A{Delete}%TextBind%{Enter}{F8}`
- Почему `^A{Delete}` перед текстом: очищает случайный незавершённый ввод в строке консоли, чтобы бинд не склеился со старым текстом.
- Экранирование спецсимволов (`#`, `!`, `^`, `+`, `&`) обязательно через `Encoded(Target)`, иначе `!` превратится в нажатие `Alt`, а `+` — в `Shift`.

### Чтение `console.log` без перечитывания всего файла с нуля
Чтение `Loop, read, %ProvLogPath%\console.log` на больших файлах может вызывать микрофризы. Для мгновенного чтения последних строк используй `FileOpen`:
```autohotkey
GetLastLogLines(LogPath, BytesToRead := 4096) {
    file := FileOpen(LogPath, "r-d", "UTF-8-RAW")
    if !IsObject(file)
        return ""
    if (file.Length > BytesToRead)
        file.Seek(-BytesToRead, 2) ; 2 = с конца файла
    text := file.Read()
    file.Close()
    return text
}
```

---

## 4. GUI в AutoHotkey v1.1 — частые ловушки и решения

1. **Ошибка `The same variable cannot be used for more than one control`**:
   - Каждое поле с `vMyVar` должно иметь уникальное имя переменной во всём скрипте (если только предыдущий GUI не был уничтожен через `Gui, Destroy`).
2. **Считывание значений из GUI**:
   - Не забывай вызывать `Gui, Submit, NoHide` в начале `gLabel`-обработчика кнопки сохранения, иначе переменные `vVar` останутся пустыми или со старыми значениями.
3. **Защита от случайного закрытия**:
   - Метка `GuiClose:` в резидентных биндерах обычно должна сворачивать окно в трей (`Gui, Hide`), а не завершать процесс (`ExitApp`), чтобы бинды продолжали работать в игре.
