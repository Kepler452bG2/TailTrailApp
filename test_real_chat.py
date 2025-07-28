#!/usr/bin/env python3

import asyncio
import websockets
import json
import base64
import requests

# Твой токен
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQxZjQ5ZTktYjZiYS00MjcyLThmMTAtNmIxZThkZDhlY2I4IiwiZXhwIjoxNzUzNDc1NDkwfQ.ulqgqu2fNZBakxr4zvpwj-HZaY-ONeeRF72jm-TTKns"
BASE_URL = "http://209.38.237.102:8080"

# Декодируем токен
payload = base64.b64decode(TOKEN.split('.')[1] + '==')
user_data = json.loads(payload)
MY_USER_ID = user_data['user_id']

print("🚀 Тест создания реального чата")
print(f"Мой User ID: {MY_USER_ID}")
print("="*60)

# Шаг 1: Получаем свой профиль
print("\n1️⃣ Получаем профиль...")
headers = {"Authorization": f"Bearer {TOKEN}"}

profile_response = requests.get(f"{BASE_URL}/api/v1/users/me", headers=headers)
if profile_response.status_code == 200:
    my_profile = profile_response.json()
    print(f"✅ Мой профиль: {json.dumps(my_profile, ensure_ascii=False)}")
else:
    print(f"❌ Ошибка получения профиля: {profile_response.text}")

# Шаг 2: Создаем тестового пользователя для чата
print("\n2️⃣ Создаем второго пользователя для теста...")
test_user_email = f"chat_test_{int(asyncio.get_event_loop().time())}@example.com"
register_response = requests.post(
    f"{BASE_URL}/api/v1/auth/signup",
    json={"email": test_user_email, "password": "password123"}
)

if register_response.status_code == 200 or "created" in register_response.text.lower():
    print(f"✅ Создан пользователь: {test_user_email}")
    
    # Логинимся за него чтобы получить его ID
    login_response = requests.post(
        f"{BASE_URL}/api/v1/auth/login",
        json={"email": test_user_email, "password": "password123"}
    )
    
    if login_response.status_code == 200:
        other_token = login_response.json().get("token")
        other_payload = base64.b64decode(other_token.split('.')[1] + '==')
        other_user_data = json.loads(other_payload)
        OTHER_USER_ID = other_user_data['user_id']
        print(f"✅ ID второго пользователя: {OTHER_USER_ID}")
    else:
        print("❌ Не удалось залогиниться за второго пользователя")
        OTHER_USER_ID = None
else:
    print(f"❌ Не удалось создать пользователя: {register_response.text}")
    OTHER_USER_ID = None

# Шаг 3: Ищем endpoint для создания чата
print("\n3️⃣ Пробуем создать чат через API...")
if OTHER_USER_ID:
    # Пробуем разные варианты endpoints
    chat_endpoints = [
        f"/api/v1/chats",
        f"/api/v1/chats/create",
        f"/api/v1/chat",
        f"/api/v1/messages/chat"
    ]
    
    created_chat_id = None
    
    for endpoint in chat_endpoints:
        print(f"\n   Пробуем POST {endpoint}")
        try:
            # Пробуем создать чат с другим пользователем
            chat_response = requests.post(
                f"{BASE_URL}{endpoint}",
                headers=headers,
                json={"user_id": OTHER_USER_ID}  # или recipient_id, other_user_id
            )
            
            if chat_response.status_code in [200, 201]:
                chat_data = chat_response.json()
                print(f"   ✅ Успех! Ответ: {json.dumps(chat_data, ensure_ascii=False)}")
                
                # Пытаемся найти chat_id в ответе
                if "id" in chat_data:
                    created_chat_id = chat_data["id"]
                elif "chat_id" in chat_data:
                    created_chat_id = chat_data["chat_id"]
                elif "chat" in chat_data and isinstance(chat_data["chat"], dict):
                    created_chat_id = chat_data["chat"].get("id")
                    
                if created_chat_id:
                    print(f"   📝 ID созданного чата: {created_chat_id}")
                break
            else:
                print(f"   ❌ {chat_response.status_code}: {chat_response.text[:100]}")
        except Exception as e:
            print(f"   ❌ Ошибка: {e}")

# Шаг 4: Тестируем WebSocket с реальным chat_id
async def test_websocket(chat_id=None):
    print("\n4️⃣ Тестируем WebSocket...")
    
    url = f"ws://209.38.237.102:8080/api/v1/websocket/ws/{MY_USER_ID}"
    ws_headers = {"Authorization": f"Bearer {TOKEN}"}
    
    async with websockets.connect(url, additional_headers=ws_headers) as ws:
        print("✅ WebSocket подключен!")
        
        if chat_id:
            print(f"\n📤 Отправляем сообщение в чат {chat_id}")
            
            message = {
                "type": "send_message",
                "data": {
                    "chat_id": chat_id,
                    "content": "Привет! Это тестовое сообщение из iOS приложения 🎉"
                }
            }
            
            await ws.send(json.dumps(message))
            print(f"   Отправлено: {json.dumps(message, ensure_ascii=False)}")
            
            try:
                response = await asyncio.wait_for(ws.recv(), timeout=5)
                data = json.loads(response)
                print(f"   Получен ответ: {json.dumps(data, ensure_ascii=False)}")
            except asyncio.TimeoutError:
                print("   ⏱️ Timeout")
        else:
            print("❌ Нет chat_id для теста")

# Запускаем WebSocket тест
if OTHER_USER_ID:
    asyncio.run(test_websocket(created_chat_id))
else:
    print("\n❌ Не удалось создать второго пользователя для теста") 