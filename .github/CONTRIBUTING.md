# 🤝 Руководство по внесению вклада (Contributing Guide)

Мы приветствуем любые идеи, исправления багов и добавления новых полезных биндов для сотрудников УГИБДД MTA Province!

---

## 📋 Основные правила разработки

### 1. Кодировка UTF-8 with BOM
Любой файл `.ahk` с кириллицей **обязан** быть сохранён со спецификацией **UTF-8 with BOM (`0xEF 0xBB 0xBF`)**. Без BOM интерпретатор AutoHotkey v1 некорректно отобразит русский текст в игре.
Для автоматического исправления используйте:
```powershell
powershell -ExecutionPolicy Bypass -File ".agents\skills\ahk-expert\scripts\ahk-tools.ps1" -Action fix-bom
```

### 2. Проверка синтаксиса
Перед созданием Pull Request обязательно проверьте синтаксис:
```powershell
powershell -ExecutionPolicy Bypass -File ".agents\skills\ahk-expert\scripts\ahk-tools.ps1" -Action check
```

### 3. Компиляция в Standalone EXE
Для проверки компиляции используйте:
```powershell
powershell -ExecutionPolicy Bypass -File ".agents\skills\ahk-expert\scripts\ahk-tools.ps1" -Action compile
```

---

## 🔀 Процесс отправки изменений

1. Сделайте **Fork** этого репозитория.
2. Создайте свою ветку функций: `git checkout -b feature/awesome-feature`
3. Зафиксируйте изменения: `git commit -m "Добавлена отыгровка алкотестера"`
4. Отправьте ветку в ваш форк: `git push origin feature/awesome-feature`
5. Создайте **Pull Request** с подробным описанием изменений.
