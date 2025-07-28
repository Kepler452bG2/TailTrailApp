#!/usr/bin/env python3

import requests
import json

# Твой токен
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQxZjQ5ZTktYjZiYS00MjcyLThmMTAtNmIxZThkZDhlY2I4IiwiZXhwIjoxNzUzNDc1NDkwfQ.ulqgqu2fNZBakxr4zvpwj-HZaY-ONeeRF72jm-TTKns"
BASE_URL = "http://209.38.237.102:8080"
headers = {"Authorization": f"Bearer {TOKEN}"}

print("🔍 Исследуем Chat API")
print("="*60)

# 1. Получаем список чатов
print("\n1️⃣ GET /api/v1/chat/chats - Список чатов")
response = requests.get(f"{BASE_URL}/api/v1/chat/chats", headers=headers)
print(f"Статус: {response.status_code}")
if response.status_code == 200:
    chats = response.json()
    print(f"✅ Чатов найдено: {len(chats) if isinstance(chats, list) else 'не список'}")
    print(f"Ответ: {json.dumps(chats, ensure_ascii=False)[:200]}")
else:
    print(f"❌ Ошибка: {response.text}")

# 2. Пробуем создать чат (POST)
print("\n2️⃣ POST /api/v1/chat/chats - Создание чата")

# Сначала создадим второго пользователя
test_email = f"test_chat_{int(requests.get('http://worldtimeapi.org/api/timezone/Etc/UTC').json()['unixtime'])}@example.com"
register = requests.post(f"{BASE_URL}/api/v1/auth/signup", json={"email": test_email, "password": "password123"})
if register.status_code == 200 or "created" in register.text.lower():
    login = requests.post(f"{BASE_URL}/api/v1/auth/login", json={"email": test_email, "password": "password123"})
    if login.status_code == 200:
        import base64
        other_token = login.json().get("token")
        other_payload = base64.b64decode(other_token.split('.')[1] + '==')
        other_user_id = json.loads(other_payload)['user_id']
        print(f"✅ Второй пользователь создан: {other_user_id}")
        
        # Пробуем разные форматы для создания чата
        test_payloads = [
            {"user_id": other_user_id},
            {"recipient_id": other_user_id},
            {"other_user_id": other_user_id},
            {"participant_id": other_user_id},
            {"participants": [other_user_id]},
            {"users": [other_user_id]}
        ]
        
        for payload in test_payloads:
            print(f"\n   Пробуем: {payload}")
            response = requests.post(f"{BASE_URL}/api/v1/chat/chats", headers=headers, json=payload)
            print(f"   Статус: {response.status_code}")
            if response.status_code in [200, 201]:
                print(f"   ✅ Успех! Ответ: {json.dumps(response.json(), ensure_ascii=False)}")
                chat_id = response.json().get("id") or response.json().get("chat_id")
                if chat_id:
                    print(f"\n🎉 CHAT ID: {chat_id}")
                    print("Теперь можно использовать этот chat_id для отправки сообщений через WebSocket!")
                break
            else:
                print(f"   ❌ {response.text[:100]}")
    else:
        print(f"❌ Не удалось залогиниться: {login.text}")
else:
    print(f"❌ Не удалось создать пользователя: {register.text}") 