---
name: taima-partner-lib
description: |
  台马（TAIMA）合作方库录入技能。从名片/企业资料提取信息，在钉钉「业务管理系统」多维表格的「合作方库」中做查重、新增抬头或更新人员。
  触发词：录入合作方 / 新增抬头 / 这张名片入库 / 更新某行人员 / 把这家公司加进合作方库。
  纪律红线：所有写入必须先 dry-run 预览并等用户确认，禁止跳过确认直接执行；同集团不同法人并入母行、不新增抬头；人员字段新增置顶并加序号。
allowed-tools: Bash, Read
license: Internal
disable: false
---

# 合作方库录入（TAIMA Partner Library）

把名片 / 企业资料录入钉钉「业务管理系统 → 合作方库」多维表格。

## 前置条件（必须确认）

- WorkBuddy 已连接 **钉钉 connector**（dws 命令可用）。
- 当前账号对该 Base 有读写权限。
- Base 与表（机构内固定，已硬编码）：
  - `BASE_ID = yQod3RxJKGoKOeGpu46K53o0Jkb4Mw9r`（业务管理系统）
  - `TABLE_ID = PZVtaHb`（合作方库）

## 字段映射（fieldId → 字段）

| fieldId | 字段 | 类型 / 取值 |
|---|---|---|
| `ho5wgen` | 企业简称 | 文本（如 `南宝树脂/NANPAO`、`鑫巨氟/XJF`、`理文化工/LeeMan`） |
| `djN4CTG` | 企业名称 | 文本（全称） |
| `zCJNyKh` | Company | 文本（英文名） |
| `8XiwR8w` | 公司地址 | 文本（含地址/电话/传真/网址/邮编，多行） |
| `hBWqmxl` | 关系 | 单选：`供应商`(id `YDB7fi4war`) / `客户`(其他待补) |
| `ZvUi4ar` | 一级分类 | 单选：`原材料类`(id `FijRg3MWI8`) |
| `if7k6lG` | 二级分类 | 单选：`氟化工原料`(id `uXgnS856De`) 等 |
| `2516Rsu` | 三级分类 | 多选：如 `PTFE 树脂`(id `7AuRzQjw41`)、`含氟单体`(id `cw9aX82Tjx`) |
| `PH8KAdr` | 序号/姓名/职位/联系方式/邮箱 | 文本，多人员按 `1. / 2.` 排列 |
| `qVxwyVm` | 企查查背调 | URL（检索后填入） |
| `ZPnyqR8` | 父公司 | 关联合作方库（集团并入时可选填） |

> 单选/多选写入格式：`{"id":"<id>","name":"<显示名>"}`；新增选项可直接传字符串（如 `"ho5wgen":"鑫巨氟/XJF"`），系统自动建选项。

## 标准流程

### Step 1 提取
- 若用户发图片：用 Read 工具识别文字，列出 姓名 / 职位 / 手机 / 邮箱 / 公司中英文 / 地址 / 电话传真 / 网址。
- 若用户发文本：直接解析。

### Step 2 查重（必须）
按企业名称 contain 查询：
```bash
dws aitable record query \
  --base-id yQod3RxJKGoKOeGpu46K53o0Jkb4Mw9r \
  --table-id PZVtaHb \
  --filters '{"operator":"and","operands":[{"operator":"contain","operands":["djN4CTG","<企业名称关键词>"]}]}' \
  --all --page-limit 0 --format json
```
判定：
- **有匹配且为同一集团体系**（如母公司已存在、本次为同集团不同法人）→ **不新增抬头，更新到现有母行**。
- **无匹配** → 新增抬头。

> 同集团并入母行：更新母行人员字段即可，通常不必填 `ZPnyqR8` 父公司；如需显式关联再填。

### Step 3 预填 + 选择题确认（必须）
AI 自行检索企业信息（WebSearch / WebFetch）预填分类与企查查链接，然后用 **选择题**让用户确认（不要替用户拍板）：
- 关系：供应商 / 客户
- 一/二/三级分类：预填后让用户确认或改
- 企查查背调：检索企业页；沙箱海外 IP 拿不到国内 `firm/` 详情页时，用搜索链接兜底 `https://www.qcc.com/web/search?key=<公司名>`
- 企业简称：按规则推断（如 `鑫巨氟/XJF`），让用户确认

### Step 4 🔴 dry-run 预览 + 等确认（红线）
写入**任何**记录前，先 dry-run 打印待填内容：
```bash
dws aitable record create \
  --base-id yQod3RxJKGoKOeGpu46K53o0Jkb4Mw9r --table-id PZVtaHb \
  --dry-run --records '[ <完整 cells JSON> ]' --format json
```
把预览内容（字段→值表格）展示给用户，**明确等其确认**后再去掉 `--dry-run` 执行。

### Step 5 执行 + 验证
确认后执行 create / update，再用 `dws aitable record get` 拉回该记录核对全部字段落库无误。

## 人员字段规则（PH8KAdr）
- 格式：`序号. 姓名，职位，联系方式，邮箱`，多人员每行一条。
- **新增人员写在该字段最上面（置顶）**，原有人整体下移；每人前加阿拉伯数字序号 `1. / 2. / …`。
- 例（新增张伯成到南宝行）：
  ```
  1. 张伯成，185 0157 8928，Johnson.chang@nanpao.com
  2. 谢立航，大陆区协理，189 6263 7819，+886‑972059232（台湾）
  ```

## 更新人员（已有记录）
```bash
dws aitable record update \
  --base-id yQod3RxJKGoKOeGpu46K53o0Jkb4Mw9r --table-id PZVtaHb \
  --dry-run --records '[{"recordId":"<RID>","cells":{"PH8KAdr":"<置顶+序号后的内容>"}}]' --format json
```
确认后再去掉 `--dry-run`。

## 更新技能包（同事侧）
当用户说「更新合作方库技能 / 更新技能包」时，运行同步脚本（默认克隆路径 `~/taima-workbuddy-skills`）：
```bash
bash "$HOME/taima-workbuddy-skills/sync.sh"
```
（Windows PowerShell 用 `& "$env:USERPROFILE\taima-workbuddy-skills\sync.ps1"`）
脚本会 `git pull` 最新并复制到 `~/.workbuddy/skills/`。若克隆路径不同，替换为实际路径。
