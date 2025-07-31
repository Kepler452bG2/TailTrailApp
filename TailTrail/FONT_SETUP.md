# Настройка шрифта Poppins

## Шаг 1: Скачать шрифт Poppins

1. Перейдите на [Google Fonts - Poppins](https://fonts.google.com/specimen/Poppins)
2. Скачайте шрифт (нажмите "Download family")
3. Распакуйте архив

## Шаг 2: Добавить шрифты в проект

1. Откройте Xcode проект
2. В навигаторе проекта найдите папку `TailTrail`
3. Правой кнопкой мыши → "Add Files to TailTrail"
4. Выберите следующие файлы из папки Poppins:
   - `Poppins-Regular.ttf`
   - `Poppins-SemiBold.ttf`
   - `Poppins-Bold.ttf`
5. Убедитесь, что отмечена галочка "Add to target: TailTrail"
6. Создайте папку `Fonts` в проекте и поместите туда шрифты для лучшей организации

## Шаг 3: Добавить в Info.plist

1. Откройте файл `Info.plist`
2. Добавьте новый ключ: `Fonts provided by application` (UIAppFonts)
3. Добавьте следующие значения:
   ```
   Poppins-Regular.ttf
   Poppins-SemiBold.ttf
   Poppins-Bold.ttf
   ```

## Шаг 4: Проверить настройки

После добавления шрифтов в проект:

1. **Запустите приложение** и проверьте, что шрифты загрузились
2. **Используйте FontTestView** для проверки - добавьте его в любое место в приложении
3. **Проверьте консоль** - там должны появиться доступные шрифты

Шрифты будут доступны через:

```swift
// В коде уже настроено:
TypographyStyles.h1 // Poppins-Bold, 42pt
TypographyStyles.subhead1 // Poppins-SemiBold, 16pt
TypographyStyles.body1 // Poppins-Regular, 16pt
```

## Шаг 5: Добавить FontTestView в приложение

Временно добавьте FontTestView в любое место приложения для проверки:

```swift
NavigationLink(destination: FontTestView()) {
    Text("Test Fonts")
}
```

## Альтернативный способ (если шрифт не загружается)

Если шрифт не загружается, можно использовать системные шрифты:

```swift
// Вместо Font.custom("Poppins-Bold", size: 42)
// Используйте:
Font.system(size: 42, weight: .bold, design: .default)
```

## Проверка доступности шрифта

Добавьте этот код для проверки:

```swift
for family in UIFont.familyNames.sorted() {
    let names = UIFont.fontNames(forFamilyName: family)
    print("Family: \(family) Font names: \(names)")
}
```

Это выведет все доступные шрифты в консоль. 