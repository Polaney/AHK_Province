---
name: ahk-expert
description: >-
  Профессиональная разработка, настройка, отладка, оптимизация и компиляция скриптов AutoHotkey (AHK v1.1 и v2), включая RP-биндеры (MTA Province, SAMP, CRMP, RAGE MP), кастомные GUI, хоткеи/хотстринги, работу с логами игр, WinAPI/DllCall и UIAccess. Активируй этот навык при любых задачах, связанных с файлами .ahk или настройкой AutoHotkey.
---

# Навык AHK-Эксперта (150%)

Этот навык предоставляет готовые инструменты и проверенные паттерны для создания, настройки, проверки и компиляции скриптов AutoHotkey в рабочей папке `c:\Users\Arch\Desktop\AHK`.

## 1. Инструментарий (`scripts/ahk-tools.ps1`)

Все операции проверки, восстановления кодировки UTF-8 with BOM, компиляции в `.exe` и запуска выполняются через скрипт [ahk-tools.ps1](./scripts/ahk-tools.ps1):

```powershell
# 1. Проверить кодировку (UTF-8 BOM) и синтаксис скрипта без его полного запуска:
powershell -ExecutionPolicy Bypass -File "c:\Users\Arch\Desktop\AHK\.agents\skills\ahk-expert\scripts\ahk-tools.ps1" -Action check -File "c:\Users\Arch\Desktop\AHK\АХК УГИБДД.ahk"

# 2. Гарантировать кодировку UTF-8 with BOM (ОБЯЗАТЕЛЬНО после правок файла!):
powershell -ExecutionPolicy Bypass -File "c:\Users\Arch\Desktop\AHK\.agents\skills\ahk-expert\scripts\ahk-tools.ps1" -Action fix-bom -File "c:\Users\Arch\Desktop\AHK\АХК УГИБДД.ahk"

# 3. Скомпилировать .ahk в .exe с иконкой ahkgibdd.ico (Unicode 64-bit):
powershell -ExecutionPolicy Bypass -File "c:\Users\Arch\Desktop\AHK\.agents\skills\ahk-expert\scripts\ahk-tools.ps1" -Action compile -File "c:\Users\Arch\Desktop\AHK\АХК УГИБДД.ahk"

# 4. Запустить или перезапустить скрипт (с правами UIAccess / обычными):
powershell -ExecutionPolicy Bypass -File "c:\Users\Arch\Desktop\AHK\.agents\skills\ahk-expert\scripts\ahk-tools.ps1" -Action run -File "c:\Users\Arch\Desktop\AHK\АХК УГИБДД.ahk"

# 5. Открыть Window Spy для поиска ahk_class / ahk_exe / координат:
powershell -ExecutionPolicy Bypass -File "c:\Users\Arch\Desktop\AHK\.agents\skills\ahk-expert\scripts\ahk-tools.ps1" -Action spy
```

## 2. Порядок работы при изменении `.ahk` скриптов

1. **Анализ контекста**:
   - Определи версию AHK (`v1.1` или `v2`). Скрипт `АХК УГИБДД.ahk` использует **AHK v1.1.37+**.
   - Если редактируется `АХК УГИБДД.ahk`, учитывай систему гендерных окончаний (`Ok1`..`Ok11`), хранение настроек в `%A_Temp%\gibdd.egl` (`IniRead`/`IniWrite`) и переменные задержек (`SleepBind`, `ComFileDelay`).
2. **Внесение изменений**:
   - При добавлении новых биндов/отыгровок используй `SendChat(TextBind, SleepBind)` вместо сырого `Send`, чтобы автоматически выставлялась русская раскладка, выключался CapsLock и экранировались спецсимволы.
   - При создании или изменении вкладок GUI (`Gui, Add, ...`) проверяй отсутствие конфликтов `vVariable` и `gLabel` (дублирование переменной контрола в AHK v1 вызывает фатальную ошибку при запуске).
3. **Пост-обработка (Обязательно)**:
   - После любого вызова `edit_file` или `write_file` на `.ahk` файле запусти `-Action fix-bom`, а затем `-Action check`, чтобы убедиться, что UTF-8 BOM сохранён и синтаксических ошибок нет.

## 3. Справочник и продвинутые паттерны

Подробные рецепты по оптимизации задержек, работе с `SendMessage`/`PostMessage`, чтению игровых логов, обходу зависаний модификаторов и дизайну GUI описаны в [ahk-master-reference.md](./references/ahk-master-reference.md).
