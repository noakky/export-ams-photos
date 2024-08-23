# ������ ����������� ����� � �������������� ���������� ��������� (UTF-16LE)
$content = Get-Content -Path Clients.data -Encoding Unicode

# ���������� ��������� ��� ������ ������ � ��������
$pattern = '<User_.*?>.*?<ClientID>(.*?)<\/ClientID>.*?<UserFIO>(.*?)<\/UserFIO>.*?<SrcPhoto>(.*?)<\/SrcPhoto>'

# ������� ������ ��� �������� ������
$clients = @()

# ���� � ����� output.csv
$outputCsvPath = Join-Path -Path $PSScriptRoot -ChildPath "output.csv"

# ��������, ���������� �� ���� output.csv, � �������� ��� ������������ ������
$existingClients = @{}
if (Test-Path -Path $outputCsvPath) {
    $existingClients = Import-Csv -Path $outputCsvPath | Group-Object -AsHashTable -Property ClientID
    Write-Host "������ ������������ ���� output.csv, ��������� ��� ������������ �������."
}

# ��������� ����� ����������
foreach ($match in [regex]::Matches($content, $pattern, "Singleline")) {
    # ���������� ������
    $clientID = $match.Groups[1].Value
    $userFIO = $match.Groups[2].Value
    $photo = $match.Groups[3].Value

    # ��������, ��� �� ���� ������ ��� ���������
    if ($existingClients.ContainsKey($clientID)) {
        Write-Host "������ '$userFIO' ��� ��� ���������, ����������."
        continue
    }

    # ������������ ���� � ������� � ������ �����
    $oldPhotoPath = Join-Path -Path $PSScriptRoot -ChildPath $photo
    $newPhotoName = $userFIO + ".jpg"
    
    # �������� ����� ./result, ���� ��� �� ����������
    $resultDirectory = Join-Path -Path $PSScriptRoot -ChildPath "result"
    if (-not (Test-Path -Path $resultDirectory)) {
        New-Item -Path $resultDirectory -ItemType Directory | Out-Null
        Write-Host "����� '$resultDirectory' �������."
    }
    $newPhotoPath = Join-Path -Path $resultDirectory -ChildPath $newPhotoName

    # ����������� ����������, ���� ��� ����������
    if (Test-Path -Path $oldPhotoPath) {
        Copy-Item -Path $oldPhotoPath -Destination $newPhotoPath
        Write-Host "���������� '$photo' ����������� ��� '$newPhotoName'"
    } else {
        Write-Host "���������� '$photo' �� �������"
    }

    # ��������� ������ � ������
    $clients += [pscustomobject]@{
        ClientID = $clientID
        UserFIO  = $userFIO
        Photo    = $newPhotoName
    }
}

# ������������ ����� ������ � CSV, ��������� � ������������� �����
$clients | Export-Csv -Path $outputCsvPath -NoTypeInformation -Encoding UTF8 -Append

Write-Host "������ ������� �������������� � output.csv"
