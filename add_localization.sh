#!/bin/bash

# Генерируем уникальные ID для файлов локализации
EN_ID=$(uuidgen | tr '[:lower:]' '[:upper:]' | sed 's/-//g' | cut -c1-24)
RU_ID=$(uuidgen | tr '[:lower:]' '[:upper:]' | sed 's/-//g' | cut -c1-24)
KK_ID=$(uuidgen | tr '[:lower:]' '[:upper:]' | sed 's/-//g' | cut -c1-24)

echo "Generated IDs:"
echo "EN: $EN_ID"
echo "RU: $RU_ID"
echo "KK: $KK_ID"

# Создаем временный файл с обновленным проектом
cp TailTrail.xcodeproj/project.pbxproj TailTrail.xcodeproj/project.pbxproj.tmp

# Добавляем файлы в PBXFileReference секцию
sed -i '' "s|/* End PBXFileReference section */|		$EN_ID /* en.lproj */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = en.lproj; path = en.lproj; sourceTree = \"<group>\"; };\n		$RU_ID /* ru.lproj */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = ru.lproj; path = ru.lproj; sourceTree = \"<group>\"; };\n		$KK_ID /* kk.lproj */ = {isa = PBXFileReference; lastKnownFileType = text.plist.strings; name = kk.lproj; path = kk.lproj; sourceTree = \"<group>\"; };\n/* End PBXFileReference section */|" TailTrail.xcodeproj/project.pbxproj.tmp

# Добавляем файлы в membershipExceptions
sed -i '' "s|membershipExceptions = (|membershipExceptions = (\n				$EN_ID /* en.lproj */,\n				$RU_ID /* ru.lproj */,\n				$KK_ID /* kk.lproj */,|" TailTrail.xcodeproj/project.pbxproj.tmp

echo "Localization files added to project.pbxproj.tmp"
echo "Please review the changes and then run: mv TailTrail.xcodeproj/project.pbxproj.tmp TailTrail.xcodeproj/project.pbxproj" 