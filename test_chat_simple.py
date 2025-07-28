#!/usr/bin/env python3

import requests
import json
import time
import base64

# Твой токен
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQxZjQ5ZTktYjZiYS00MjcyLThmMTAtNmIxZThkZDhlY2I4IiwiZXhwIjoxNzUzNDc1NDkwfQ.ulqgqu2fNZBakxr4zvpwj-HZaY-ONeeRF72jm-TTKns"
BASE_URL = "http://209.38.237.102:8080"
headers = {"Authorization": f"Bearer {TOKEN}"}

print("🚀 Создаем чат!")
print("="*60)

# Создаем второго пользователя
test_email = f"chat_test_{int(time.time())}@example.com"
print(f"\n1️⃣ Создаем пользователя: {test_email}")

register = requests.post(f"{BASE_URL}/api/v1/auth/signup", json={"email": test_email, "password": "password123"})
if register.status_code != 200 and "created" not in register.text.lower():
    print(f"❌ Ошибка регистрации: {register.text}")
    exit(1)

print("✅ Пользователь создан")

# Логинимся
login = requests.post(f"{BASE_URL}/api/v1/auth/login", json={"email": test_email, "password": "password123"})
if login.status_code != 200:
    print(f"❌ Ошибка входа: {login.text}")
    exit(1)

other_token = login.json().get("token")
other_payload = base64.b64decode(other_token.split('.')[1] + '==')
other_user_id = json.loads(other_payload)['user_id']
print(f"✅ ID второго пользователя: {other_user_id}")

# Создаем чат
print(f"\n2️⃣ Создаем чат между пользователями")
print(f"   Мой ID: 441f49e9-b6ba-4272-8f10-6b1e8dd8ecb8")
print(f"   Другой ID: {other_user_id}")

# Пробуем создать чат
response = requests.post(
    f"{BASE_URL}/api/v1/chat/chats",
    headers=headers,
    json={"participant_ids": [other_user_id]}
)

print(f"\nСтатус: {response.status_code}")
print(f"Ответ: {response.text}")

if response.status_code in [200, 201]:
    chat_data = response.json()
    chat_id = chat_data.get("id") or chat_data.get("chat_id")
    
    if chat_id:
        print(f"\n🎉 УСПЕХ! Chat ID: {chat_id}")
        print("\nТеперь можешь использовать этот chat_id для:")
        print(f"- Отправки сообщений через WebSocket")
        print(f"- Получения сообщений через GET /api/v1/messages/chats/{chat_id}/messages")
        
        # Сохраняем для удобства
        with open("last_chat_id.txt", "w") as f:
            f.write(chat_id)
        print(f"\n💾 Chat ID сохранен в файл last_chat_id.txt") 