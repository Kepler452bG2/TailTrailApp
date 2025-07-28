#!/usr/bin/env python3

import asyncio
import websockets
import json
import base64

# Твой токен
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQxZjQ5ZTktYjZiYS00MjcyLThmMTAtNmIxZThkZDhlY2I4IiwiZXhwIjoxNzUzNDc1NDkwfQ.ulqgqu2fNZBakxr4zvpwj-HZaY-ONeeRF72jm-TTKns"

# Читаем chat_id из файла
try:
    with open("last_chat_id.txt", "r") as f:
        CHAT_ID = f.read().strip()
except:
    CHAT_ID = "ea659252-e497-45f2-a09d-a984c9ceecb2"  # Используем последний созданный

# Декодируем токен
payload = base64.b64decode(TOKEN.split('.')[1] + '==')
user_data = json.loads(payload)
MY_USER_ID = user_data['user_id']

print("🚀 Тестируем отправку сообщения!")
print(f"Chat ID: {CHAT_ID}")
print(f"User ID: {MY_USER_ID}")
print("="*60)

async def test_send_message():
    url = f"ws://209.38.237.102:8080/api/v1/websocket/ws/{MY_USER_ID}"
    headers = {"Authorization": f"Bearer {TOKEN}"}
    
    async with websockets.connect(url, additional_headers=headers) as ws:
        print("✅ WebSocket подключен!")
        
        # Отправляем сообщение
        message = {
            "type": "send_message",
            "data": {
                "chat_id": CHAT_ID,
                "content": "🎉 Привет! Это первое сообщение через WebSocket! Работает!"
            }
        }
        
        print(f"\n📤 Отправляем: {json.dumps(message, ensure_ascii=False)}")
        await ws.send(json.dumps(message))
        
        # Ждем ответ
        try:
            response = await asyncio.wait_for(ws.recv(), timeout=5)
            data = json.loads(response)
            
            print(f"\n📨 Получен ответ:")
            print(f"   Тип: {data.get('type')}")
            print(f"   Данные: {json.dumps(data.get('data', {}), ensure_ascii=False, indent=2)}")
            
            if data['type'] == 'message_sent':
                print("\n✅ СООБЩЕНИЕ УСПЕШНО ОТПРАВЛЕНО!")
            elif data['type'] == 'error':
                print(f"\n❌ Ошибка: {data.get('data', {}).get('message', 'Unknown error')}")
            
        except asyncio.TimeoutError:
            print("\n⏱️ Timeout - нет ответа")
        
        # Попробуем получить список сообщений
        print("\n📋 Запрашиваем список сообщений...")
        get_messages = {
            "type": "get_messages",
            "data": {"chat_id": CHAT_ID}
        }
        await ws.send(json.dumps(get_messages))
        
        try:
            response = await asyncio.wait_for(ws.recv(), timeout=3)
            data = json.loads(response)
            print(f"Ответ: {data['type']}")
        except:
            pass

asyncio.run(test_send_message())

print("\n💡 Скажи бэкендеру:")
print("1. WebSocket работает ✅")
print("2. Чаты создаются ✅")
print("3. Сообщения отправляются (проверь логи)")
print(f"4. Chat ID для проверки: {CHAT_ID}") 