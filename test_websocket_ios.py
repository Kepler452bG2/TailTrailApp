#!/usr/bin/env python3

import asyncio
import websockets
import json
import requests
import sys
import time
import base64

print("🚀 Testing WebSocket connection to: ws://209.38.237.102:8080")
print("=====================================")

# Test credentials
base_url = "http://209.38.237.102:8080"
test_email = f"test_ws_{int(time.time())}@example.com"
test_password = "password123"

# Helper function to decode JWT
def decode_jwt(token):
    try:
        # JWT has 3 parts separated by dots
        parts = token.split('.')
        if len(parts) != 3:
            return None
        
        # Decode the payload (second part)
        payload = parts[1]
        # Add padding if needed
        payload += '=' * (4 - len(payload) % 4)
        decoded = base64.b64decode(payload)
        return json.loads(decoded)
    except:
        return None

# Step 1: Login
print("\n1️⃣ Logging in...")
login_response = requests.post(
    f"{base_url}/api/v1/auth/login",
    json={"email": test_email, "password": test_password}
)

if login_response.status_code != 200:
    print(f"❌ Login failed: {login_response.text}")
    # Try to register first
    print("\n🔄 Trying to register new user...")
    register_response = requests.post(
        f"{base_url}/api/v1/auth/signup",
        json={"email": test_email, "password": test_password}
    )
    if register_response.status_code == 200 or "User created successfully" in register_response.text:
        print("✅ Registration successful!")
        # Try login again
        login_response = requests.post(
            f"{base_url}/api/v1/auth/login",
            json={"email": test_email, "password": test_password}
        )
        print(f"Login response status: {login_response.status_code}")
        print(f"Login response: {login_response.text[:200]}")
    else:
        print(f"❌ Registration failed: {register_response.text}")
        sys.exit(1)

if login_response.status_code == 200:
    try:
        login_data = login_response.json()
        print(f"Login data keys: {list(login_data.keys())}")
        token = login_data.get("access_token") or login_data.get("token")
        
        # Decode JWT to get real user_id
        jwt_payload = decode_jwt(token)
        if jwt_payload:
            print(f"JWT payload: {jwt_payload}")
            user_id = jwt_payload.get("user_id")
        else:
            # Check different possible user data structures
            if "user" in login_data and isinstance(login_data["user"], dict):
                user_id = login_data["user"].get("id")
            elif "id" in login_data:
                user_id = login_data.get("id")
            else:
                user_id = 1  # Default to 1
        
        print(f"✅ Login successful! User ID: {user_id}, Token: {token[:20] if token else 'None'}...")
    except Exception as e:
        print(f"❌ Error parsing login response: {e}")
        print(f"Response: {login_response.text}")
        sys.exit(1)
else:
    print(f"❌ Login failed: {login_response.text}")
    sys.exit(1)

# Step 2: Test WebSocket
async def test_websocket():
    if not token:
        print("❌ No token available, cannot connect to WebSocket")
        return
        
    uri = f"ws://209.38.237.102:8080/api/v1/websocket/ws/{user_id}"
    
    print(f"\n2️⃣ Connecting to WebSocket...")
    print(f"URL: {uri}")
    print(f"Token: {token[:20]}...")
    
    try:
        # Method 1: Try with auth header
        print("🔄 Trying with Authorization header...")
        try:
            headers = {"Authorization": f"Bearer {token}"}
            async with websockets.connect(uri, additional_headers=headers) as websocket:
                print("✅ Connected to WebSocket!")
                await handle_websocket(websocket)
        except Exception as e:
            print(f"❌ Method 1 failed: {e}")
            
            # Method 2: Try with token in URL
            print("\n🔄 Trying with token in URL...")
            uri_with_token = f"{uri}?token={token}"
            try:
                async with websockets.connect(uri_with_token) as websocket:
                    print("✅ Connected to WebSocket!")
                    await handle_websocket(websocket)
            except Exception as e2:
                print(f"❌ Method 2 failed: {e2}")
                
                # Method 3: Try without user ID in path
                print("\n🔄 Trying base WebSocket URL...")
                base_ws_uri = "ws://209.38.237.102:8080/api/v1/websocket/ws"
                try:
                    async with websockets.connect(base_ws_uri, additional_headers=headers) as websocket:
                        print("✅ Connected to WebSocket!")
                        await handle_websocket(websocket)
                except Exception as e3:
                    print(f"❌ Method 3 failed: {e3}")
                    
    except Exception as e:
        print(f"\n❌ WebSocket error: {type(e).__name__}: {e}")

async def handle_websocket(websocket):
    # Send list_chats request
    await websocket.send(json.dumps({
        "type": "list_chats",
        "data": {}
    }))
    print("📤 Sent: list_chats request")
    
    # Listen for messages
    print("\n📥 Waiting for messages (10 seconds)...")
    try:
        while True:
            message = await asyncio.wait_for(websocket.recv(), timeout=10.0)
            data = json.loads(message)
            print(f"\n📨 Received message type: {data['type']}")
            
            if data['type'] == 'chat_list':
                chats = data.get('data', [])
                print(f"   Found {len(chats)} chats")
                for chat in chats[:3]:  # Show first 3 chats
                    print(f"   - Chat ID: {chat.get('id')}, Last message: {chat.get('lastMessage', 'None')}")
            
            elif data['type'] == 'error':
                print(f"   ❌ Error: {data.get('data')}")
            
            else:
                print(f"   Data: {data.get('data')}")
                
    except asyncio.TimeoutError:
        print("\n⏱️  No more messages (timeout)")

# Run the test
print("\n" + "="*50)
asyncio.run(test_websocket())

print("\n✅ Test completed!")
print("\n📝 Tell your backend friend to check logs for:")
print(f"   - User ID: {user_id}")
print(f"   - WebSocket connection from this test")
print(f"   - list_chats request") 