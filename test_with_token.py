#!/usr/bin/env python3

import asyncio
import websockets
import json
import base64

# Твой токен из Swagger
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQxZjQ5ZTktYjZiYS00MjcyLThmMTAtNmIxZThkZDhlY2I4IiwiZXhwIjoxNzUzNDc1NDkwfQ.ulqgqu2fNZBakxr4zvpwj-HZaY-ONeeRF72jm-TTKns"

# Декодируем токен чтобы получить user_id
payload = base64.b64decode(TOKEN.split('.')[1] + '==')
user_data = json.loads(payload)
USER_ID = user_data['user_id']

print(f"🚀 Тестируем WebSocket с твоим токеном!")
print(f"User ID: {USER_ID}")
print("="*50)

async def test_websocket():
    # Пробуем разные варианты подключения
    urls = [
        f"ws://209.38.237.102:8080/api/v1/websocket/ws/{USER_ID}",
        f"ws://209.38.237.102:8080/api/v1/websocket/ws/{USER_ID}?token={TOKEN}",
        f"ws://209.38.237.102:8080/ws/{USER_ID}",
    ]
    
    for url in urls:
        print(f"\n🔄 Пробуем: {url[:60]}...")
        try:
            # Пробуем с заголовком Authorization
            headers = {"Authorization": f"Bearer {TOKEN}"}
            async with websockets.connect(url, additional_headers=headers) as websocket:
                print("✅ ПОДКЛЮЧИЛИСЬ!")
                
                # Отправляем запрос списка чатов
                await websocket.send(json.dumps({
                    "type": "list_chats",
                    "data": {}
                }))
                print("📤 Отправили: list_chats")
                
                # Ждем ответ
                try:
                    response = await asyncio.wait_for(websocket.recv(), timeout=5)
                    data = json.loads(response)
                    print(f"📨 Получили: {data['type']}")
                    
                    if data['type'] == 'chat_list':
                        print(f"✅ Чатов найдено: {len(data.get('data', []))}")
                        
                    # Отправим еще ping для теста
                    await websocket.send(json.dumps({
                        "type": "ping",
                        "data": {"message": "Hello from iOS app!"}
                    }))
                    print("📤 Отправили: ping")
                    
                    # Ждем pong
                    response = await asyncio.wait_for(websocket.recv(), timeout=5)
                    print(f"📨 Получили: {response}")
                    
                    print("\n✅ WebSocket работает! Скажи бэкендеру что все ОК!")
                    return True
                except asyncio.TimeoutError:
                    print("⏱️ Timeout - нет ответа от сервера")
                
        except Exception as e:
            print(f"❌ Ошибка: {type(e).__name__}: {e}")
    
    return False

# Запускаем тест
success = asyncio.run(test_websocket())

if not success:
    print("\n❌ Не удалось подключиться. Попроси бэкендера проверить:")
    print(f"   - User ID: {USER_ID}")
    print(f"   - Токен валидный (из Swagger)")
    print("   - WebSocket endpoint и авторизация") 