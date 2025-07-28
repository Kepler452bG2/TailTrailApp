#!/usr/bin/env python3

import requests
import json

# Токен который мы использовали в тестах
OLD_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNDQxZjQ5ZTktYjZiYS00MjcyLThmMTAtNmIxZThkZDhlY2I4IiwiZXhwIjoxNzUzNDc1NDkwfQ.ulqgqu2fNZBakxr4zvpwj-HZaY-ONeeRF72jm-TTKns"

print("🔍 Проверяем какой пользователь использует токен")
print("="*60)

# Проверяем профиль со старым токеном
headers = {"Authorization": f"Bearer {OLD_TOKEN}"}
response = requests.get("http://209.38.237.102:8080/api/v1/users/profile", headers=headers)

if response.status_code == 200:
    profile = response.json()
    print(f"✅ Профиль по старому токену:")
    print(f"   Email: {profile.get('email')}")
    print(f"   ID: {profile.get('id')}")
elif response.status_code == 401:
    print("❌ Старый токен истек или недействителен")
else:
    print(f"❌ Ошибка: {response.status_code} - {response.text}")

print("\n💡 Если ты использовала НОВЫЙ логин в приложении:")
print("   1. Зайди в Xcode консоль")
print("   2. Найди строку с токеном после логина") 
print("   3. Или добавь в AuthenticationManager вывод токена:")
print("      print(\"🔑 Token: \\(token)\")")
print("\n   Потом используй НОВЫЙ токен для тестов!") 