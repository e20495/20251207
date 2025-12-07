# 將本機資料夾傳輸到遠端樹莓派
# 使用方式: .\transfer_to_pi.ps1

# ===== 設定區 =====
# 請修改以下設定以符合您的環境

# 樹莓派 IP 地址或主機名稱
$PI_HOST = "172.20.10.3"  # 或使用 "raspberrypi.local" 或實際 IP

# 樹莓派使用者名稱（通常是 pi）
$PI_USER = "pi"

# 本機要傳輸的資料夾路徑
$LOCAL_FOLDER = ".\__2025_10_26_chihlee_pi_pico__-main"

# 遠端目標路徑
$REMOTE_PATH = "/home/pi/Documents/GitHub/2025_10_26_chihlee_pi_pico"

# SSH 連接埠（預設為 22）
$SSH_PORT = 22

# ===== 執行區 =====

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  將本機資料夾傳輸到遠端樹莓派" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 檢查本機資料夾是否存在
if (-Not (Test-Path $LOCAL_FOLDER)) {
    Write-Host "❌ 錯誤: 找不到本機資料夾: $LOCAL_FOLDER" -ForegroundColor Red
    exit 1
}

Write-Host "📁 本機資料夾: $LOCAL_FOLDER" -ForegroundColor Green
Write-Host "🖥️  遠端主機: $PI_USER@$PI_HOST" -ForegroundColor Green
Write-Host "📂 遠端路徑: $REMOTE_PATH" -ForegroundColor Green
Write-Host ""

# 檢查是否安裝了 scp（Windows 10/11 通常內建）
$scpAvailable = $false
try {
    $null = Get-Command scp -ErrorAction Stop
    $scpAvailable = $true
} catch {
    Write-Host "⚠️  未找到 scp 命令" -ForegroundColor Yellow
}

# 檢查是否安裝了 rsync（需要額外安裝）
$rsyncAvailable = $false
try {
    $null = Get-Command rsync -ErrorAction Stop
    $rsyncAvailable = $true
} catch {
    Write-Host "⚠️  未找到 rsync 命令" -ForegroundColor Yellow
}

# 選擇傳輸方式
if ($rsyncAvailable) {
    Write-Host "✅ 使用 rsync 進行傳輸（推薦，支援增量同步）" -ForegroundColor Green
    Write-Host ""
    
    # 使用 rsync（推薦，因為支援增量同步）
    $rsyncArgs = @(
        "-avz",
        "--progress",
        "--delete",
        "-e", "ssh -p $SSH_PORT",
        "$LOCAL_FOLDER/",
        "${PI_USER}@${PI_HOST}:$REMOTE_PATH/"
    )
    
    Write-Host "執行命令: rsync $($rsyncArgs -join ' ')" -ForegroundColor Gray
    Write-Host ""
    
    $rsyncResult = & rsync $rsyncArgs 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host ""
        Write-Host "✅ 傳輸完成！" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ 傳輸失敗，錯誤代碼: $exitCode" -ForegroundColor Red
        if ($rsyncResult) {
            Write-Host "錯誤訊息: $rsyncResult" -ForegroundColor Red
        }
        exit 1
    }
    
} elseif ($scpAvailable) {
    Write-Host "✅ 使用 scp 進行傳輸" -ForegroundColor Green
    Write-Host ""
    
    # 使用 scp 遞迴複製
    # 注意：Windows 的 scp 可能使用小寫 -p，Linux 使用大寫 -P
    # 先嘗試大寫 -P（Linux 風格），如果失敗再嘗試小寫 -p
    Write-Host "執行命令: scp -r -P $SSH_PORT `"$LOCAL_FOLDER`" ${PI_USER}@${PI_HOST}:$REMOTE_PATH" -ForegroundColor Gray
    Write-Host ""
    
    $scpResult = & scp -r -P $SSH_PORT "$LOCAL_FOLDER" "${PI_USER}@${PI_HOST}:$REMOTE_PATH" 2>&1
    $exitCode = $LASTEXITCODE
    
    # 如果使用 -P 失敗，嘗試使用 -p（Windows Git Bash 可能使用小寫）
    if ($exitCode -ne 0) {
        Write-Host "嘗試使用小寫 -p 參數..." -ForegroundColor Yellow
        $scpResult = & scp -r -p $SSH_PORT "$LOCAL_FOLDER" "${PI_USER}@${PI_HOST}:$REMOTE_PATH" 2>&1
        $exitCode = $LASTEXITCODE
    }
    
    if ($exitCode -eq 0) {
        Write-Host ""
        Write-Host "✅ 傳輸完成！" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ 傳輸失敗，錯誤代碼: $exitCode" -ForegroundColor Red
        if ($scpResult) {
            Write-Host "錯誤訊息: $scpResult" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "💡 提示：" -ForegroundColor Yellow
        Write-Host "   1. 確認樹莓派 IP 地址正確" -ForegroundColor Yellow
        Write-Host "   2. 確認 SSH 服務已啟動" -ForegroundColor Yellow
        Write-Host "   3. 確認使用者名稱和密碼正確" -ForegroundColor Yellow
        Write-Host "   4. 確認遠端路徑存在且有寫入權限" -ForegroundColor Yellow
        exit 1
    }
    
} else {
    Write-Host "❌ 錯誤: 未找到 scp 或 rsync 命令" -ForegroundColor Red
    Write-Host ""
    Write-Host "請選擇以下方式之一：" -ForegroundColor Yellow
    Write-Host "1. 安裝 Git for Windows（包含 scp）" -ForegroundColor Yellow
    Write-Host "2. 安裝 WSL（Windows Subsystem for Linux）" -ForegroundColor Yellow
    Write-Host "3. 使用 WinSCP 等 GUI 工具" -ForegroundColor Yellow
    Write-Host "4. 使用 PowerShell 的 SSH 模組" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  傳輸作業完成" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

