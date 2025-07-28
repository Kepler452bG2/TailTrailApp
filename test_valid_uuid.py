#!/usr/bin/env python3

import asyncio
import websockets
import json
import base64
import uuid

# Твой токен
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQxZjQ5ZTktYjZiYS00MjcyLThmMTAtNmIxZThkZDhlY2I4IiwiZXhwIjoxNzUzNDc1NDkwfQ.ulqgqu2fNZBakxr4zvpwj-HZaY-ONeeRF72jm-TTKns"

# Декодируем токен
payload = base64.b64decode(TOKEN.split('.')[1] + '==')
user_data = json.loads(payload)
USER_ID = user_data['user_id']

print("🚀 Тест с валидными UUID")
print(f"User ID: {USER_ID}")
print("="*60)

async def test_websocket():
    url = f"ws://209.38.237.102:8080/api/v1/websocket/ws/{USER_ID}"
    headers = {"Authorization": f"Bearer {TOKEN}"}
    
    async with websockets.connect(url, additional_headers=headers) as ws:
        print("✅ Подключились!\n")
        
        # Генерируем валидные UUID
        test_chat_id = str(uuid.uuid4())
        test_user_id = str(uuid.uuid4())
        
        print(f"📝 Используем валидные UUID:")
        print(f"   chat_id: {test_chat_id}")
        print(f"   user_id: {test_user_id}")
        print()
        
        # Тесты с валидными UUID
        tests = [
            {
                "name": "send_message с валидным UUID",
                "msg": {
                    "type": "send_message",
                    "data": {
                        "chat_id": test_chat_id,
                        "content": "Тест с валидным UUID!"
                    }
                }
            },
            {
                "name": "send_message с существующим chat_id (твой user_id как тест)",
                "msg": {
                    "type": "send_message", 
                    "data": {
                        "chat_id": USER_ID,  # Пробуем твой user_id как chat_id
                        "content": "Тест сообщения"
                    }
                }
            },
            {
                "name": "create_chat с валидным user_id",
                "msg": {
                    "type": "create_chat",
                    "data": {
                        "user_id": test_user_id
                    }
                }
            },
            {
                "name": "get_messages с валидным UUID",
                "msg": {
                    "type": "get_messages",
                    "data": {
                        "chat_id": test_chat_id
                    }
                }
            }
        ]
        
        for test in tests:
            print(f"📤 {test['name']}")
            print(f"   Отправляем: {json.dumps(test['msg'], ensure_ascii=False)}")
            
            await ws.send(json.dumps(test['msg']))
            
            try:
                response = await asyncio.wait_for(ws.recv(), timeout=3)
                data = json.loads(response)
                
                if data['type'] == 'error':
                    error_msg = data.get('data', {}).get('message', 'Unknown error')
                    print(f"   ❌ Ошибка: {error_msg}")
                    
                    # Анализируем ошибку
                    if "not found" in error_msg.lower():
                        print("      💡 Подсказка: Чат не существует, нужно сначала создать")
                    elif "unknown message type" in error_msg.lower():
                        print(f"      💡 Подсказка: Тип '{test['msg']['type']}' не поддерживается")
                else:
                    print(f"   ✅ Успех! Тип ответа: {data['type']}")
                    print(f"      Данные: {json.dumps(data.get('data', {}), ensure_ascii=False)[:100]}")
                    
            except asyncio.TimeoutError:
                print("   ⏱️  Timeout")
            
            print()

asyncio.run(test_websocket()) 