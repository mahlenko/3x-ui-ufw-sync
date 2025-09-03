# 3x-ui-ufw-sync

Автоматическая синхронизация портов **3x-ui** с UFW. Скрипт добавляет TCP-порты активных inbound-ов и удаляет неиспользуемые, с возможностью настройки комментария для правил.

## ⚡ Возможности

- Добавление TCP-портов активных inbound-ов 3x-ui в UFW.  
- Удаление старых или неиспользуемых правил.  
- Настраиваемый комментарий для правил.  
- Вывод информативных сообщений в консоль.

## 📦 Требования

На сервере должны быть установлены:  
- `curl` — для запросов к API 3x-ui.  
- `jq` — для парсинга JSON из API.  
- `ufw` — для управления брандмауэром.

Установка на Ubuntu/Debian:
```bash
sudo apt update
sudo apt install curl jq ufw -y
```

## 💾 Установка скрипта

1. Скачайте скрипт:
```bash
sudo wget -O /usr/local/bin/3x-ui-ufw-sync.sh https://github.com/mahlenko/3x-ui-ufw-sync/raw/main/3x-ui-ufw-sync.sh
```

2. Сделайте его исполняемым:
```bash
sudo chmod +x /usr/local/bin/3x-ui-ufw-sync.sh
```

3. Настройте переменные в начале скрипта:
```bash
PANEL_URL="http://127.0.0.1:60414/"    # полный адрес панели 3x-ui с webBasePath
USERNAME="your_username"               # логин
PASSWORD="your_password"               # пароль
COMMENT="3x-ui-inbound"                # комментарий для правил ufw (tag)
```

## ▶️ Использование

Запуск вручную:
```bash
sudo /usr/local/bin/3x-ui-ufw-sync.sh
```

Пример вывода:
```
=== Синхронизация портов 3x-ui с ufw ===
[+] Добавляю правило 47890/tcp
[-] Удаляю правило 47891/tcp (нет в inbound)
=== Синхронизация завершена ===
```

## ⏰ Автоматизация через cron

Чтобы синхронизировать порты регулярно, добавьте cron:
```bash
sudo crontab -e
```
И добавьте строку для запуска каждые 5 минут:
```cron
*/5 * * * * /usr/local/bin/3x-ui-ufw-sync.sh
```
- Скрипт будет запускаться каждые 5 минут.

Если хотите логировать:
```cron
*/5 * * * * /usr/local/bin/3x-ui-ufw-sync.sh >> /var/log/3x-ui-ufw-sync.log 2>&1
``` 
- Логирование идёт в `/var/log/3x-ui-ufw-sync.log`.

## 📝 Лицензия

MIT License — свободно используйте, изменяйте и распространяйте скрипт.
