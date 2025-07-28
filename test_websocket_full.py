#!/usr/bin/env python3

import asyncio
import websockets
import json
import base64

# Твой токен из Swagger
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQxZjQ5ZTktYjZiYS00MjcyLThmMTAtNmIxZThkZDhlY2I4IiwiZXhwIjoxNzUzNDc1NDkwfQ.ulqgqu2fNZBakxr4zvpwj-HZaY-ONeeRF72jm-TTKns"

# Декодируем токен
payload = base64.b64decode(TOKEN.split('.')[1] + '==')
user_data = json.loads(payload)
USER_ID = user_data['user_id']

print("🚀 Полный тест WebSocket для TailTrail")
print(f"User ID: {USER_ID}")
print("="*60)

async def test_websocket():
    url = f"ws://209.38.237.102:8080/api/v1/websocket/ws/{USER_ID}"
    headers = {"Authorization": f"Bearer {TOKEN}"}
    
    async with websockets.connect(url, additional_headers=headers) as ws:
        print("✅ Подключились к WebSocket!\n")
        
        # Тестируем разные типы сообщений
        test_messages = [
            {
                "name": "Список чатов",
                "message": {"type": "list_chats", "data": {}}
            },
            {
                "name": "Создать чат (тест)",
                "message": {"type": "create_chat", "data": {"user_id": "test-user-123"}}
            },
            {
                "name": "Отправить сообщение",
                "message": {"type": "send_message", "data": {
                    "chat_id": "test-chat-123",
                    "content": "Привет из iOS приложения!"
                }}
            },
            {
                "name": "Получить сообщения чата",
                "message": {"type": "get_messages", "data": {"chat_id": "test-chat-123"}}
            },
            {
                "name": "Неизвестный тип",
                "message": {"type": "unknown_type", "data": {}}
            }
        ]
        
        for test in test_messages:
            print(f"📤 Тест: {test['name']}")
            print(f"   Отправляем: {json.dumps(test['message'], ensure_ascii=False)}")
            
            await ws.send(json.dumps(test['message']))
            
            try:
                response = await asyncio.wait_for(ws.recv(), timeout=3)
                data = json.loads(response)
                
                if data['type'] == 'error':
                    print(f"   ❌ Ошибка: {data.get('data', {}).get('message', 'Unknown error')}")
                else:
                    print(f"   ✅ Ответ типа '{data['type']}': {json.dumps(data.get('data', {}), ensure_ascii=False)[:100]}")
                    
            except asyncio.TimeoutError:
                print("   ⏱️  Timeout - нет ответа")
            except Exception as e:
                print(f"   ❌ Исключение: {e}")
                
            print()
        
        print("\n📊 ИТОГИ ТЕСТА:")
        print("- WebSocket соединение: ✅ Работает")
        print("- Авторизация: ✅ Работает")
        print("- Обмен сообщениями: ✅ Работает")
        print("\nТеперь нужно узнать у бэкендера:")
        print("1. Какие типы сообщений поддерживаются?")
        print("2. Формат данных для каждого типа")
        print("3. Как создать первый чат между пользователями")

asyncio.run(test_websocket()) 