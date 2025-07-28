#!/usr/bin/env python3

import asyncio
import websockets
import json

TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQxZjQ5ZTktYjZiYS00MjcyLThmMTAtNmIxZThkZDhlY2I4IiwiZXhwIjoxNzUzNDc1NDkwfQ.ulqgqu2fNZBakxr4zvpwj-HZaY-ONeeRF72jm-TTKns"
USER_ID = "441f49e9-b6ba-4272-8f10-6b1e8dd8ecb8"

async def test_websocket():
    url = f"ws://209.38.237.102:8080/api/v1/websocket/ws/{USER_ID}"
    headers = {"Authorization": f"Bearer {TOKEN}"}
    
    print(f"🔌 Connecting to: {url}")
    
    try:
        async with websockets.connect(url, additional_headers=headers) as websocket:
            print("✅ WebSocket connected!")
            
            # Send a ping message
            ping_message = {"type": "ping"}
            await websocket.send(json.dumps(ping_message))
            print("📤 Sent ping")
            
            # Listen for messages
            try:
                while True:
                    message = await asyncio.wait_for(websocket.recv(), timeout=5)
                    print(f"📨 Received: {message}")
            except asyncio.TimeoutError:
                print("⏱️ No messages received (timeout)")
                
    except Exception as e:
        print(f"❌ WebSocket error: {e}")

asyncio.run(test_websocket()) 