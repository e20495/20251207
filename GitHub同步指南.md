# GitHub 同步指南

## 📋 目前狀態

✅ 本地已有 Git 倉庫  
❌ 尚未設定 GitHub 遠端倉庫  
✅ 工作目錄乾淨（無未提交變更）

## 🚀 方法一：連接到現有的 GitHub 倉庫

如果您已經在 GitHub 上建立了倉庫：

### 步驟 1：在 GitHub 建立新倉庫

1. 前往 https://github.com/new
2. 輸入倉庫名稱（例如：`chihlee_pi_pico`）
3. 選擇公開或私有
4. **不要**勾選「Initialize this repository with a README」
5. 點擊「Create repository」

### 步驟 2：連接本地倉庫到 GitHub

在 PowerShell 中執行：

```powershell
# 設定遠端倉庫（將 YOUR_USERNAME 和 REPO_NAME 替換為您的資訊）
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git

# 例如：
# git remote add origin https://github.com/yourname/chihlee_pi_pico.git
```

### 步驟 3：推送本地代碼到 GitHub

```powershell
# 推送 main 分支到 GitHub
git push -u origin main
```

如果使用 SSH（需要先設定 SSH 金鑰）：

```powershell
git remote add origin git@github.com:YOUR_USERNAME/REPO_NAME.git
git push -u origin main
```

## 🔄 方法二：使用 GitHub CLI（推薦）

如果您已安裝 GitHub CLI：

```powershell
# 建立並推送倉庫
gh repo create chihlee_pi_pico --public --source=. --remote=origin --push
```

## 📝 日常同步流程

### 將本地變更推送到 GitHub

```powershell
# 1. 查看變更狀態
git status

# 2. 加入變更的檔案
git add .

# 3. 提交變更
git commit -m "描述您的變更"

# 4. 推送到 GitHub
git push
```

### 從 GitHub 拉取最新變更

```powershell
# 拉取並合併遠端變更
git pull
```

## 🔍 檢查同步狀態

### 查看遠端倉庫設定

```powershell
git remote -v
```

應該會顯示：
```
origin  https://github.com/YOUR_USERNAME/REPO_NAME.git (fetch)
origin  https://github.com/YOUR_USERNAME/REPO_NAME.git (push)
```

### 查看本地與遠端的差異

```powershell
# 查看本地領先遠端多少提交
git log origin/main..HEAD

# 查看遠端領先本地多少提交
git log HEAD..origin/main
```

### 查看所有分支

```powershell
git branch -a
```

## ⚠️ 常見問題

### Q1: 推送時要求輸入帳號密碼

**解決方法**：
1. 使用 Personal Access Token（PAT）代替密碼
   - 前往：https://github.com/settings/tokens
   - 建立新 token（選擇 `repo` 權限）
   - 使用 token 作為密碼

2. 或使用 SSH 金鑰（推薦）
   ```powershell
   # 檢查是否已有 SSH 金鑰
   ls ~/.ssh
   
   # 如果沒有，生成新的 SSH 金鑰
   ssh-keygen -t ed25519 -C "your_email@example.com"
   
   # 複製公鑰到剪貼簿
   cat ~/.ssh/id_ed25519.pub | clip
   
   # 然後到 GitHub Settings > SSH and GPG keys 添加
   ```

### Q2: 推送被拒絕（rejected）

**可能原因**：
- 遠端倉庫有本地沒有的提交

**解決方法**：
```powershell
# 先拉取遠端變更
git pull --rebase

# 然後再推送
git push
```

### Q3: 想要忽略某些檔案

建立或編輯 `.gitignore` 檔案：

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/

# Jupyter Notebook
.ipynb_checkpoints

# 資料檔案
*.csv
*.xlsx
*.db
*.sqlite

# 系統檔案
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# 日誌
*.log
```

然後執行：
```powershell
git add .gitignore
git commit -m "Add .gitignore"
git push
```

## 🎯 快速檢查清單

- [ ] 在 GitHub 建立新倉庫
- [ ] 執行 `git remote add origin <URL>`
- [ ] 執行 `git push -u origin main`
- [ ] 確認 GitHub 上可以看到檔案
- [ ] 設定 `.gitignore`（如需要）

## 📚 常用 Git 命令參考

```powershell
# 查看狀態
git status

# 查看提交歷史
git log --oneline

# 查看變更內容
git diff

# 加入所有變更
git add .

# 加入特定檔案
git add filename

# 提交變更
git commit -m "提交訊息"

# 推送到遠端
git push

# 拉取遠端變更
git pull

# 查看遠端倉庫
git remote -v

# 移除遠端倉庫
git remote remove origin

# 重新命名遠端倉庫
git remote rename old-name new-name
```

---

**提示**：如果這是第一次使用 Git，建議先閱讀 [Git 官方文件](https://git-scm.com/doc) 或 [GitHub 指南](https://guides.github.com/)。

