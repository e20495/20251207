# 簡化版：將本機資料夾傳輸到遠端樹莓派
# 使用 PowerShell 內建功能，無需額外工具
# 使用方式: .\transfer_to_pi_simple.ps1

# ===== 設定區 =====
$PI_HOST = "172.20.10.3"      # 樹莓派 IP
$PI_USER = "pi"                # 樹莓派使用者名稱
$LOCAL_FOLDER = ".\__2025_10_26_chihlee_pi_pico__-main"
$REMOTE_PATH = "/home/pi/Documents/GitHub/2025_10_26_chihlee_pi_pico"

# ===== 執行區 =====

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  將本機資料夾傳輸到遠端樹莓派（簡化版）" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 檢查本機資料夾
if (-Not (Test-Path $LOCAL_FOLDER)) {
    Write-Host "❌ 錯誤: 找不到本機資料夾: $LOCAL_FOLDER" -ForegroundColor Red
    Write-Host "   請確認資料夾路徑正確" -ForegroundColor Yellow
    exit 1
}

# 計算資料夾大小
$folderSize = (Get-ChildItem $LOCAL_FOLDER -Recurse -File | Measure-Object -Property Length -Sum).Sum
$folderSizeMB = [math]::Round($folderSize / 1MB, 2)
$fileCount = (Get-ChildItem $LOCAL_FOLDER -Recurse -File).Count

Write-Host "📁 本機資料夾: $LOCAL_FOLDER" -ForegroundColor Green
Write-Host "📊 資料夾大小: $folderSizeMB MB ($fileCount 個檔案)" -ForegroundColor Cyan
Write-Host "🖥️  遠端主機: $PI_USER@$PI_HOST" -ForegroundColor Green
Write-Host "📂 遠端路徑: $REMOTE_PATH" -ForegroundColor Green
Write-Host ""

# 方法 1: 嘗試使用 scp（Windows 10/11 內建）
Write-Host "🔍 檢查可用的傳輸工具..." -ForegroundColor Yellow
Write-Host ""

$useScp = $false
$useRsync = $false

# 檢查 scp
try {
    $null = Get-Command scp -ErrorAction Stop
    $useScp = $true
    Write-Host "✅ 找到 scp 命令" -ForegroundColor Green
} catch {
    Write-Host "⚠️  未找到 scp 命令" -ForegroundColor Yellow
}

# 檢查 rsync
try {
    $null = Get-Command rsync -ErrorAction Stop
    $useRsync = $true
    Write-Host "✅ 找到 rsync 命令" -ForegroundColor Green
} catch {
    Write-Host "⚠️  未找到 rsync 命令" -ForegroundColor Yellow
}

Write-Host ""

if (-Not $useScp -And -Not $useRsync) {
    Write-Host "❌ 錯誤: 未找到 scp 或 rsync 命令" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 解決方案：" -ForegroundColor Yellow
    Write-Host "   1. 安裝 Git for Windows（包含 scp）" -ForegroundColor Cyan
    Write-Host "      下載: https://git-scm.com/download/win" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   2. 或使用以下手動命令（需要先安裝 Git for Windows）：" -ForegroundColor Cyan
    Write-Host "      scp -r `"$LOCAL_FOLDER`" ${PI_USER}@${PI_HOST}:$REMOTE_PATH" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   3. 或使用 WinSCP GUI 工具" -ForegroundColor Cyan
    Write-Host "      下載: https://winscp.net/" -ForegroundColor Gray
    exit 1
}

# 執行傳輸
if ($useRsync) {
    Write-Host "🚀 使用 rsync 進行傳輸（推薦）..." -ForegroundColor Green
    Write-Host ""
    
    Write-Host "執行命令: rsync -avz --progress -e `"ssh -p 22`" `"$LOCAL_FOLDER/`" ${PI_USER}@${PI_HOST}:${REMOTE_PATH}/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "⚠️  請輸入樹莓派密碼（輸入時不會顯示，輸入完按 Enter）" -ForegroundColor Yellow
    Write-Host ""
    
    # 使用 & 運算符直接執行命令（更安全）
    & rsync -avz --progress -e "ssh -p 22" "$LOCAL_FOLDER/" "${PI_USER}@${PI_HOST}:${REMOTE_PATH}/" 2>&1 | Tee-Object -Variable rsyncOutput
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host ""
        Write-Host "✅ 傳輸完成！" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ 傳輸失敗，錯誤代碼: $exitCode" -ForegroundColor Red
        if ($rsyncOutput) {
            Write-Host "錯誤訊息: $rsyncOutput" -ForegroundColor Red
        }
        exit 1
    }
    
} elseif ($useScp) {
    Write-Host "🚀 使用 scp 進行傳輸..." -ForegroundColor Green
    Write-Host ""
    
    # 先嘗試建立遠端目錄（如果不存在）
    Write-Host "📋 檢查並建立遠端目錄..." -ForegroundColor Yellow
    ssh "${PI_USER}@${PI_HOST}" "mkdir -p `"$REMOTE_PATH`"" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 遠端目錄已準備就緒" -ForegroundColor Green
    } else {
        Write-Host "⚠️  無法建立遠端目錄，將繼續嘗試傳輸..." -ForegroundColor Yellow
    }
    Write-Host ""
    
    # Windows OpenSSH 使用大寫 -P，但某些版本可能使用小寫 -p
    # 先嘗試大寫 -P（Windows OpenSSH 標準）
    Write-Host "執行命令: scp -r -P 22 `"$LOCAL_FOLDER`" ${PI_USER}@${PI_HOST}:$REMOTE_PATH" -ForegroundColor Gray
    Write-Host ""
    Write-Host "⚠️  請輸入樹莓派密碼（輸入時不會顯示，輸入完按 Enter）" -ForegroundColor Yellow
    Write-Host "   注意：scp 不會顯示進度條，請耐心等待..." -ForegroundColor Gray
    Write-Host ""
    
    # 使用 & 運算符直接執行命令，而不是 Invoke-Expression（更安全）
    # 注意：scp 預設不顯示進度，如果需要進度可以使用 -v 參數（但會很冗長）
    & scp -r -P 22 "$LOCAL_FOLDER" "${PI_USER}@${PI_HOST}:${REMOTE_PATH}" 2>&1 | Tee-Object -Variable scpOutput
    $exitCode = $LASTEXITCODE
    
    # 如果失敗，嘗試小寫 -p（某些 Git Bash 版本）
    if ($exitCode -ne 0) {
        Write-Host ""
        Write-Host "⚠️  使用 -P 失敗，嘗試使用小寫 -p 參數..." -ForegroundColor Yellow
        Write-Host ""
        & scp -r -p 22 "$LOCAL_FOLDER" "${PI_USER}@${PI_HOST}:${REMOTE_PATH}" 2>&1 | Tee-Object -Variable scpOutput
        $exitCode = $LASTEXITCODE
    }
    
    if ($exitCode -eq 0) {
        Write-Host ""
        Write-Host "✅ 傳輸完成！" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ 傳輸失敗，錯誤代碼: $exitCode" -ForegroundColor Red
        if ($scpOutput) {
            Write-Host "錯誤訊息: $scpOutput" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "💡 故障排除：" -ForegroundColor Yellow
        Write-Host "   1. 確認樹莓派 IP: $PI_HOST" -ForegroundColor Cyan
        Write-Host "   2. 確認使用者名稱: $PI_USER" -ForegroundColor Cyan
        Write-Host "   3. 確認密碼正確" -ForegroundColor Cyan
        Write-Host "   4. 確認遠端路徑存在: $REMOTE_PATH" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   可以在樹莓派上執行以下命令建立目錄：" -ForegroundColor Yellow
        Write-Host "   ssh $PI_USER@$PI_HOST `"mkdir -p $REMOTE_PATH`"" -ForegroundColor Gray
        Write-Host ""
        Write-Host "   或手動測試連線：" -ForegroundColor Yellow
        Write-Host "   ssh $PI_USER@$PI_HOST" -ForegroundColor Gray
        exit 1
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  傳輸作業完成" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 驗證傳輸結果：" -ForegroundColor Green
Write-Host "   可以在樹莓派上執行以下命令查看：" -ForegroundColor Yellow
Write-Host "   ssh $PI_USER@$PI_HOST `"ls -la $REMOTE_PATH`"" -ForegroundColor Gray

