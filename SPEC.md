# 功能與需求規格書 (SPEC.md)

## 1. 專案概述
本專案為一個支援跨平台行動裝置（Android / iOS）的 **TodoList 待辦事項管理應用程式**。使用者透過 Google 帳號登入後，即可管理個人專屬的待辦事項，包含新增、檢視、依到期日排序、編輯與刪除功能。

---

## 2. 使用者角色與身分驗證流程 (Authentication)

### 2.1 登入與登出
* **登入方式**：僅支援 **Google Sign-In**（整合 Firebase Authentication）。
* **未登入狀態**：App 啟動時若未登入（或 Token 已失效），導向「登入頁面（Login Screen）」，提供「使用 Google 帳號登入」按鈕。
* **已登入狀態**：登入成功後自動導向「待辦事項主頁面（Todo List Screen）」，頂部 AppBar 顯示使用者名稱/頭像與「登出」按鈕。
* **多使用者資料隔離**：每位使用者僅能讀取、新增、修改、刪除屬於自己 Google 帳號（Firebase `uid`）下的待辦事項。

---

## 3. 待辦事項 (Todo Item) 資料欄位定義

每個 Todo 項目包含以下核心欄位：

| 欄位名稱 | 型別 | 必填 | 格式 / 允許值 | UI 輸入控制項 |
| :--- | :--- | :---: | :--- | :--- |
| **`title`** | String | 是 | 非空白字串 | 文字輸入框 (`TextField`) |
| **`dueDate`** | String | 是 | `yyyy-mm-dd`（例：`2026-11-15`） | 日期選擇器 (`DatePicker`) |
| **`state`** | String (Enum) | 是 | `todo`、`in progress`、`done` | 下拉選單或狀態切換按鈕 |
| **`category`** | String (Enum) | 是 | `company`、`personal`、`other` | 下拉選單 (`DropdownButtonFormField`) |

---

## 4. 前端介面與互動流程 (UI / UX)

### 4.1 主畫面：待辦事項列表 (Todo List Screen)
1. **清單呈現**：
   * 直接呈現目前使用者的所有 Todo 卡片列表，**不設置分類或狀態篩選器（No Filter Bar）**。
   * 每張卡片顯示：`title`、`dueDate`（`yyyy-mm-dd`）、`state` 標籤（`todo` / `in progress` / `done`）、`category` 標籤（`company` / `personal` / `other`）。
2. **排序功能（Sorting）**：
   * 頂部提供排序切換控制項（依 `dueDate` 排序）：
     * **由新到舊（Newest to Oldest / Descending）**：日期較遠（大）的排在前面。
     * **由舊到新（Oldest to Newest / Ascending）**：日期較近（小）的排在前面。
   * 排序由前端透過 GetX 響應式狀態即時重排，無須重新請求後端 API。
3. **快速操作与刪除**：
   * 支援在卡片上快速切換 `state`（或點擊卡片開啟底部彈窗編輯）。
   * 支援**左滑刪除（Dismissible）**或點擊刪除圖示刪除該筆待辦事項。

### 4.2 新增與編輯：底部彈窗 (BottomSheet)
* 點擊主畫面右下角懸浮按鈕（FAB `+`）開啟 **BottomSheet（新增模式）**；點擊現有卡片開啟 **BottomSheet（編輯模式）**。
* 表單欄位驗證：
  1. `title`：必填，不可為空字串。
  2. `dueDate`：必填，點擊喚起 Flutter `showDatePicker`，格式化為 `yyyy-mm-dd`。
  3. `state`：預設為 `todo`，可選 `todo`、`in progress`、`done`。
  4. `category`：透過下拉選單（Dropdown List）選擇 `company`、`personal` 或 `other`（預設為 `personal`）。
* 點擊「儲存」後呼叫後端 API，成功後關閉 BottomSheet 並同步更新前端列表。

---

## 5. 邊界條件與例外處理 (Edge Cases)
1. **空狀態（Empty State）**：當使用者尚無任何待辦事項時，畫面中央顯示友善提示（「目前沒有待辦事項，點擊右下角 + 新增第一筆吧！」）。
2. **表單防呆**：未填寫 `title` 或 `dueDate` 時阻擋送出並顯示欄位錯誤提示；API 請求進行中時鎖定送出按鈕避免重複點擊。
3. **授權失效（401 Unauthorized）**：若後端回傳 `401`，前端自動清除登入狀態並導回 Google 登入頁。
4. **網路或伺服器錯誤**：透過 `Get.snackbar` 顯示清楚的錯誤訊息。
