#!/bin/bash

# Данные доступа к 3x-ui
PANEL_URL="http://127.0.0.1:60414/I3aLe23Dei3"
USERNAME="your_username"
PASSWORD="your_password"

# Комментарий для правил ufw (можно изменить)
# ВНИМАНИЕ! Если скрипт запускался ранее:
# - Сначала удалите правила со старым комментарием, после синхронизируйте с новым.
# - Для удаления правил, отключите все Inbounds в панели, запустите скрипт
# - Включите нужные Inbounds в панели 3x-ui, обновите комментарий, запустите синхронизацию
COMMENT="3x-ui-inbound"

# Временный файл для куки
COOKIE_FILE="/tmp/3x-ui-cookies.txt"

# Логинимся и получаем куки
curl -s -c $COOKIE_FILE -X POST "$PANEL_URL/login" \
  -d "username=$USERNAME&password=$PASSWORD" > /dev/null

# Запрашиваем список inbound-ов
PORTS=$(curl -s -b $COOKIE_FILE "$PANEL_URL/panel/api/inbounds/list" \
  | jq -r '.obj[] | select(.enable==true) | .port')

# Сначала собираем все правила ufw с комментарием "3x-ui"
EXISTING_RULES=$(ufw status | grep "# $COMMENT" | awk '{print $1}')

echo "=== Синхронизация портов 3x-ui с ufw ==="

# Удаляем правила с комментарием 3x-ui, которых нет в актуальных inbound-ах
for rule in $EXISTING_RULES; do
    port=$(echo "$rule" | cut -d'/' -f1)
    proto=$(echo "$rule" | cut -d'/' -f2)

    # Проверяем, что порт отсутствует в PORTS
    if ! echo "$PORTS" | grep -q "^$port$"; then
        # Проверяем, что правило реально существует
        if ufw status | grep -q "^$port/$proto.*# $COMMENT"; then
            echo "[-] Удаляю правило $rule (нет в inbound)"
            ufw delete allow "$rule" comment "$COMMENT"
        fi
    fi
done

# Добавляем недостающие порты
for port in $PORTS; do
    for proto in tcp; do
        if ! echo "$EXISTING_RULES" | grep -q "^${port}/${proto}$"; then
            echo "[+] Добавляю правило $port/$proto"
            ufw allow $port/$proto comment "$COMMENT"
        fi
    done
done

echo "=== Синхронизация завершена ==="
