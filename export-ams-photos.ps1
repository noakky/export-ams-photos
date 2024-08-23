# Чтение содержимого файла с использованием правильной кодировки (UTF-16LE)
$content = Get-Content -Path Clients.data -Encoding Unicode

# Регулярное выражение для поиска данных о клиентах
$pattern = '<User_.*?>.*?<ClientID>(.*?)<\/ClientID>.*?<UserFIO>(.*?)<\/UserFIO>.*?<SrcPhoto>(.*?)<\/SrcPhoto>'

# Создаем массив для хранения данных
$clients = @()

# Путь к файлу output.csv
$outputCsvPath = Join-Path -Path $PSScriptRoot -ChildPath "output.csv"

# Проверка, существует ли файл output.csv, и загрузка уже обработанных данных
$existingClients = @{}
if (Test-Path -Path $outputCsvPath) {
    $existingClients = Import-Csv -Path $outputCsvPath | Group-Object -AsHashTable -Property ClientID
    Write-Host "Найден существующий файл output.csv, загружены уже обработанные клиенты."
}

# Выполняем поиск совпадений
foreach ($match in [regex]::Matches($content, $pattern, "Singleline")) {
    # Извлечение данных
    $clientID = $match.Groups[1].Value
    $userFIO = $match.Groups[2].Value
    $photo = $match.Groups[3].Value

    # Проверка, был ли этот клиент уже обработан
    if ($existingClients.ContainsKey($clientID)) {
        Write-Host "Клиент '$userFIO' уже был обработан, пропускаем."
        continue
    }

    # Формирование пути к старому и новому файлу
    $oldPhotoPath = Join-Path -Path $PSScriptRoot -ChildPath $photo
    $newPhotoName = $userFIO + ".jpg"
    
    # Создание папки ./result, если она не существует
    $resultDirectory = Join-Path -Path $PSScriptRoot -ChildPath "result"
    if (-not (Test-Path -Path $resultDirectory)) {
        New-Item -Path $resultDirectory -ItemType Directory | Out-Null
        Write-Host "Папка '$resultDirectory' создана."
    }
    $newPhotoPath = Join-Path -Path $resultDirectory -ChildPath $newPhotoName

    # Копирование фотографии, если она существует
    if (Test-Path -Path $oldPhotoPath) {
        Copy-Item -Path $oldPhotoPath -Destination $newPhotoPath
        Write-Host "Фотография '$photo' скопирована как '$newPhotoName'"
    } else {
        Write-Host "Фотография '$photo' не найдена"
    }

    # Добавляем данные в массив
    $clients += [pscustomobject]@{
        ClientID = $clientID
        UserFIO  = $userFIO
        Photo    = $newPhotoName
    }
}

# Экспортируем новые данные в CSV, дописывая к существующему файлу
$clients | Export-Csv -Path $outputCsvPath -NoTypeInformation -Encoding UTF8 -Append

Write-Host "Данные успешно экспортированы в output.csv"
