#!/bin/bash

# 將本機資料夾傳輸到遠端樹莓派
# 使用方式: bash transfer_to_pi.sh
# 或在 Linux/WSL 中: ./transfer_to_pi.sh

# ===== 設定區 =====
# 請修改以下設定以符合您的環境

# 樹莓派 IP 地址或主機名稱
PI_HOST="172.20.10.3"  # 或使用 "raspberrypi.local" 或實際 IP

# 樹莓派使用者名稱（通常是 pi）
PI_USER="pi"

# 本機要傳輸的資料夾路徑
LOCAL_FOLDER="./__2025_10_26_chihlee_pi_pico__-main"

# 遠端目標路徑
REMOTE_PATH="/home/pi/Documents/GitHub/2025_10_26_chihlee_pi_pico"

# SSH 連接埠（預設為 22）
SSH_PORT=22

# ===== 執行區 =====

echo "================================================"
echo "  將本機資料夾傳輸到遠端樹莓派"
echo "================================================"
echo ""

# 檢查本機資料夾是否存在
if [ ! -d "$LOCAL_FOLDER" ]; then
    echo "❌ 錯誤: 找不到本機資料夾: $LOCAL_FOLDER"
    exit 1
fi

echo "📁 本機資料夾: $LOCAL_FOLDER"
echo "🖥️  遠端主機: $PI_USER@$PI_HOST"
echo "📂 遠端路徑: $REMOTE_PATH"
echo ""

# 檢查是否安裝了 rsync
if command -v rsync &> /dev/null; then
    echo "✅ 使用 rsync 進行傳輸（推薦，支援增量同步）"
    echo ""
    
    # 使用 rsync（推薦，因為支援增量同步）
    rsync -avz --progress --delete \
        -e "ssh -p $SSH_PORT" \
        "$LOCAL_FOLDER/" \
        "${PI_USER}@${PI_HOST}:${REMOTE_PATH}/"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ 傳輸完成！"
    else
        echo ""
        echo "❌ 傳輸失敗"
        exit 1
    fi
    
# 檢查是否安裝了 scp
elif command -v scp &> /dev/null; then
    echo "✅ 使用 scp 進行傳輸"
    echo ""
    
    # 使用 scp 遞迴複製
    scp -r -P $SSH_PORT "$LOCAL_FOLDER" "${PI_USER}@${PI_HOST}:${REMOTE_PATH}"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ 傳輸完成！"
    else
        echo ""
        echo "❌ 傳輸失敗"
        exit 1
    fi
    
else
    echo "❌ 錯誤: 未找到 scp 或 rsync 命令"
    echo ""
    echo "請安裝 rsync 或 scp："
    echo "  Ubuntu/Debian: sudo apt-get install rsync openssh-client"
    echo "  macOS: 通常已內建"
    exit 1
fi

echo ""
echo "================================================"
echo "  傳輸作業完成"
echo "================================================"

