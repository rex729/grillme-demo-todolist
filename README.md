# GrillMe Demo TodoList — `/grill-me` 深度設計訪談 × TDD 實戰練習專案

本專案是一個為了練習與驗證 **`/grill-me`（Relentless Interview 深度設計訪談技能）**、**跨模型記憶持久化架構** 以及 **TDD（測試驅動開發）** 所建立的全端待辦事項（TodoList）應用程式。

---

## 💡 專案核心理念：為什麼要用 `grill-me`？

在 AI 輔助開發中，最常見的問題不是 AI 不夠聰明，而是**在需求與邊界條件還很模糊時就急著讓 AI 寫程式（Vibe Coding）**，導致後續無止盡的修改與重工。

本專案展示了如何透過 `.agents/skills/grill-me/SKILL.md` 建立一套嚴謹的 AI 協作流程：

1. **決策樹靈魂拷問（Walk the Design Tree）**：
   * 啟動 `/grill-me` 後，AI 在達成共識前**禁止直接寫 Code**。
   * 沿著產品與架構決策樹，**每次只問 1 個關鍵問題**，並附上 AI 的推薦選項 `(Recommended)`。
   * 能夠從現有專案檔案（如設定檔或既有程式碼）查到的資訊，AI 必須先自行查閱，不重複詢問。
2. **跨視窗 / 跨模型永久記憶（Memory Persistence）**：
   * 透過專案根目錄的開放標準入口檔 **[AGENTS.md](./AGENTS.md)**，規定所有 AI 模型進入專案時必須先閱讀 **[SPEC.md](./SPEC.md)** 與 **[DESIGN.md](./DESIGN.md)**。
   * 當 `/grill-me` 訪談達成共識時，AI 自動將「功能需求與邊界條件」寫入 **[SPEC.md](./SPEC.md)**，將「系統架構與技術決策」寫入 **[DESIGN.md](./DESIGN.md)**。即使關閉視窗、開新對話或切換不同底層模型（Gemini、Claude、GPT），都能 100% 無縫接手。
3. **強制測試驅動開發（TDD: Red ➔ Green ➔ Refactor）**：
   * 先根據 `SPEC.md` 與 `DESIGN.md` 撰寫失敗測試（**Red**），再撰寫最小可行實作通過測試（**Green**），最後進行重構（**Refactor**）。

---

## 🛠️ 技術選型與系統架構

透過 `/grill-me` 訪談定案的系統架構如下：

* **前端 (`frontend/`)**：
  * **Flutter**（專注支援 **Android & iOS** 雙行動平台）
  * **GetX** 狀態管理、路由管理與依賴注入
  * **Firebase Authentication + Google Sign-In** 登入並取得 Firebase ID Token
  * 主畫面呈現無篩選器的純列表，支援依到期日（`dueDate: yyyy-mm-dd`）切換 **由舊到新 / 由新到舊** 即時排序、底部彈窗（BottomSheet）新增與編輯、狀態快速切換與左滑刪除。
* **後端 (`backend/`)**：
  * **Node.js + Express** RESTful API
  * **Firebase Admin SDK (`firebase-admin`)**：驗證前端 `Authorization: Bearer <Firebase_ID_Token>`，並以 `users/{uid}/todos/{todoId}` 子集合結構讀寫 **Cloud Firestore**，實現天然的多使用者資料隔離。

---

## 📂 目錄結構

```text
.
├── AGENTS.md                        # 【跨模型入口】AI 代理協作與 TDD 強制規範
├── SPEC.md                          # 【規格記憶】由 grill-me 產出的功能與需求規格書
├── DESIGN.md                        # 【設計記憶】由 grill-me 產出的系統架構與技術設計書
├── .agents/
│   └── skills/
│       └── grill-me/
│           └── SKILL.md             # 自訂 grill-me 深度設計訪談技能定義
├── backend/                         # Node.js + Express + Firebase Admin 後端
│   ├── src/                         # 應用程式、Auth 中介軟體、欄位驗證與路由
│   ├── test/                        # 後端 TDD 單元與 API 整合測試套件 (19 tests)
│   └── server.js                    # 伺服器啟動入口 (:8080)
└── frontend/                        # Flutter + GetX 行動端專案 (Android & iOS)
    ├── android/                     # Android 原生配置
    ├── ios/                         # iOS 原生配置
    ├── lib/                         # GetX 模組 (auth, todo, routes, providers, models)
    └── test/                        # 前端 TDD 測試套件 (flutter_test)
```

---

## 🚀 快速開始與執行測試

### 1. 後端 (Node.js + Express)

1. 前往 Firebase Console > 專案設定 > 服務帳戶，產生新的私密金鑰並存放於 `backend/serviceAccountKey.json`（已被 `.gitignore` 排除）。
2. 安裝依賴並執行 TDD 測試：
   ```bash
   cd backend
   npm install
   npm test
   ```
3. 啟動後端伺服器（預設監聽 `:8080`）：
   ```bash
   npm start
   ```

### 2. 前端 (Flutter + GetX)

1. 確認已於 Firebase Console 的 Android 應用程式設定中填入本機 `debug.keystore` 的 `SHA-1` 與 `SHA-256` 指紋（可使用根目錄的 `sh get_sha1.sh` 查詢）。
2. 安裝套件並執行前端 TDD 測試：
   ```bash
   cd frontend
   flutter pub get
   flutter test test/todo_test.dart
   ```
3. 啟動模擬器或實機執行：
   ```bash
   flutter run
   ```
