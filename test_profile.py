#!/usr/bin/env python3

import requests
import json

# Твой токен
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQxZjQ5ZTktYjZiYS00MjcyLThmMTAtNmIxZThkZDhlY2I4IiwiZXhwIjoxNzUzNDc1NDkwfQ.ulqgqu2fNZBakxr4zvpwj-HZaY-ONeeRF72jm-TTKns"
BASE_URL = "http://209.38.237.102:8080"

print("🔍 Тестируем endpoints профиля")
print("="*60)

# Пробуем разные варианты
endpoints = [
    "/api/v1/users/profile",
    "/api/v1/users/me", 
    "/api/v1/profile",
    f"/api/v1/users/441f49e9-b6ba-4272-8f10-6b1e8dd8ecb8"  # Твой user_id напрямую
]

for endpoint in endpoints:
    print(f"\n📍 Пробуем GET {endpoint}")
    
    # С токеном
    headers = {"Authorization": f"Bearer {TOKEN}"}
    response = requests.get(f"{BASE_URL}{endpoint}", headers=headers)
    print(f"   С токеном: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"   ✅ Успех! Данные профиля:")
        print(f"      ID: {data.get('id')}")
        print(f"      Email: {data.get('email')}")
        print(f"      Phone: {data.get('phone')}")
        print(f"      Полный ответ: {json.dumps(data, ensure_ascii=False, indent=2)}")
        break
    else:
        print(f"   ❌ Ошибка: {response.text[:100]}")

print("\n💡 Если все endpoints возвращают 403:")
print("   - Проверь что токен не истек")
print("   - Попробуй получить новый токен через Swagger") 