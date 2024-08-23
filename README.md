# AMS Passport Photo Maker Processing Script

Этот скрипт на PowerShell предназначен для обработки данных о клиентах из файла `Clients.data` создаваемых программами `AMS Passport Photo Maker` или ее копии `Фото на документы`. Он выполняет следующие задачи:

1. Извлекает информацию о клиентах, такую как их идентификаторы, имена и связанные фотографии.
2. Копирует и переименовывает фотографии в новую папку `./result` в соответствии с именами клиентов.
3. Проверяет существующий файл `output.csv`, чтобы избежать дублирования обработанных данных, и копирует только новые фотографии.

## Как использовать

### 1. Подготовка

- Убедитесь, что у вас есть файл `Clients.data` в корневой директории скрипта. По умолчанию это %appdata%\AMS Software\AMS Software\PhotoDoc\Data\Clients
- Убедитесь, что фотографии, упомянутые в `Clients.data`, находятся в той же директории, что и скрипт.

### 2. Запуск скрипта

- Откройте PowerShell.
- Перейдите в директорию, где находится ваш скрипт.
- Выполните скрипт:

```powershell
.\your_script_name.ps1
