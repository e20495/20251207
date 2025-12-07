# 設定 GitHub 遠端倉庫的輔助腳本
# 使用方式: .\setup_github.ps1

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  GitHub 遠端倉庫設定助手" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 檢查是否已有遠端倉庫
$remotes = git remote -v
if ($remotes) {
    Write-Host "⚠️  已存在遠端倉庫：" -ForegroundColor Yellow
    Write-Host $remotes -ForegroundColor Gray
    Write-Host ""
    $continue = Read-Host "是否要移除現有遠端並重新設定？(y/N)"
    if ($continue -eq "y" -or $continue -eq "Y") {
        git remote remove origin
        Write-Host "✅ 已移除現有遠端倉庫" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "取消操作" -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "請選擇連線方式：" -ForegroundColor Yellow
Write-Host "1. HTTPS（需要 Personal Access Token）" -ForegroundColor Cyan
Write-Host "2. SSH（需要設定 SSH 金鑰）" -ForegroundColor Cyan
Write-Host ""
$choice = Read-Host "請輸入選項 (1 或 2)"

if ($choice -eq "1") {
    Write-Host ""
    Write-Host "請輸入您的 GitHub 倉庫 URL：" -ForegroundColor Yellow
    Write-Host "格式：https://github.com/使用者名稱/倉庫名稱.git" -ForegroundColor Gray
    Write-Host "範例：https://github.com/yourname/chihlee_pi_pico.git" -ForegroundColor Gray
    Write-Host ""
    $repoUrl = Read-Host "GitHub 倉庫 URL"
    
    if ($repoUrl) {
        git remote add origin $repoUrl
        Write-Host ""
        Write-Host "✅ 已設定遠端倉庫：$repoUrl" -ForegroundColor Green
    } else {
        Write-Host "❌ 未輸入 URL，取消操作" -ForegroundColor Red
        exit 1
    }
    
} elseif ($choice -eq "2") {
    Write-Host ""
    Write-Host "請輸入您的 GitHub 倉庫 SSH URL：" -ForegroundColor Yellow
    Write-Host "格式：git@github.com:使用者名稱/倉庫名稱.git" -ForegroundColor Gray
    Write-Host "範例：git@github.com:yourname/chihlee_pi_pico.git" -ForegroundColor Gray
    Write-Host ""
    $repoUrl = Read-Host "GitHub 倉庫 SSH URL"
    
    if ($repoUrl) {
        git remote add origin $repoUrl
        Write-Host ""
        Write-Host "✅ 已設定遠端倉庫：$repoUrl" -ForegroundColor Green
    } else {
        Write-Host "❌ 未輸入 URL，取消操作" -ForegroundColor Red
        exit 1
    }
    
} else {
    Write-Host "❌ 無效的選項" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  驗證設定" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# 顯示遠端倉庫設定
$remotes = git remote -v
Write-Host "遠端倉庫設定：" -ForegroundColor Green
Write-Host $remotes -ForegroundColor Gray
Write-Host ""

# 檢查是否可以連線
Write-Host "測試連線..." -ForegroundColor Yellow
$testResult = git ls-remote origin 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 成功連接到 GitHub 倉庫！" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步：" -ForegroundColor Cyan
    Write-Host "   執行以下命令推送代碼：" -ForegroundColor Yellow
    Write-Host "   git push -u origin main" -ForegroundColor Gray
} else {
    Write-Host "⚠️  無法連接到遠端倉庫" -ForegroundColor Yellow
    Write-Host "錯誤訊息：$testResult" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因：" -ForegroundColor Yellow
    Write-Host "   1. 倉庫 URL 錯誤" -ForegroundColor Cyan
    Write-Host "   2. 需要認證（SSH 金鑰或 Personal Access Token）" -ForegroundColor Cyan
    Write-Host "   3. 倉庫不存在或沒有權限" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "請確認：" -ForegroundColor Yellow
    Write-Host "   - 倉庫是否已在 GitHub 建立" -ForegroundColor Gray
    Write-Host "   - 是否已設定 SSH 金鑰或 Personal Access Token" -ForegroundColor Gray
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan

