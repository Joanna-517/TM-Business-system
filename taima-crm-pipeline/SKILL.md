---
name: taima-crm-pipeline
description: |
  台马（TAIMA）商机拓展 CRM 管线技能。在钉钉「业务管理系统」多维表格的「商机拓展」中新增商机、推进销售阶段、关联报价/订单/拜访、标记成交或流失。
  触发词：记个商机 / 推进某商机 / 商机成交了 / 商机流失 / 更新商机状态。
  纪律红线：所有写入必须先 dry-run 预览并等用户确认，禁止跳过确认直接执行。客户名称直接选合作方库已有的企业简称，不重复建客户。
allowed-tools: Bash, Read
license: Internal
disable: false
---

# 商机拓展 CRM 管线（TAIMA CRM Pipeline）

管理钉钉「业务管理系统 → 商机拓展」多维表格的全生命周期。

## 前置条件（必须确认）

- WorkBuddy 已连接 **钉钉 connector**（dws 命令可用）。
- 当前账号对该 Base 有读写权限。
- Base 与表（机构内固定，已硬编码）：
  - `BASE_ID = yQod3RxJKGoKOeGpu46K53o0Jkb4Mw9r`（业务管理系统）
  - `TABLE_ID = yldkqXl`（商机拓展）

## 字段映射（fieldId → 字段）

| fieldId | 字段 | 类型 / 取值 |
|---|---|---|
| `ab1bssf` | 项目名称/需求详情 | 主键（文本） |
| `WlQVkBb` | 客户名称 | 单选，选项=合作方库「企业简称」列表（如 `南宝树脂/NANPAO`、`鑫巨氟/XJF`、`理文化工/LeeMan`）；**直接选已有项**，不要新建 |
| `XJHKVQc` | 商机来源 | 单选：展会 / 老客户转介绍 / 主动开发 / 股东 / 持续业务 |
| `doPbyiO` | 商机状态 | 单选：初步接触 → 需求分析 → 方案报价 → 送样 → 商务谈判 → 成交 / 未成交 |
| `5QVaMWH` | 负责人 | 多用户 |
| `jaNBpA3` | 项目启动时间 | 日期 |
| `8h1LnTc` | 预计成交时间 | 日期 |
| `HiiSyAY` | 预期收入/CNY | 数字 |
| `xU35ORX` | 采购成本/CNY | 数字 |
| `LzBLOPs` | 拓客/物流成本/CNY | 数字 |
| `JV3LTkV` | 预估净利率 | 公式（自动，勿手填） |
| `p9rgK6w` | 沟通进展 | 富文本（按 `日期 + 摘要` 追加） |
| `UhNTuPk` | 流失原因 | 单选：利润少、需求量少/不明确 / 规格信息不足/客户需求变更 / 技术不达标/资质不符 / 竞争对手抢夺 |
| `QW2vbgm` | 风险描述/应对措施 | 文本 |
| `xgYf1hJ` | 供方名称 | 多选（同企业简称列表） |
| `jt3laif` | 成交订单号 | 关联「业绩明细」 |
| `Wcd4MzE` | 报价测算 | 关联「报价测算」 |
| `Chs98y3` | 交流记录 | 关联「拜访会议」 |
| `f9msxdK` | 父记录 | 关联自身（子商机） |
| `qW1uWqP` | 年度 | 公式（自动） |
| `tSzrmrs` | 预估业绩 | 文本 |

> 单选/多选/关联写入格式：`{"id":"<id>","name":"<显示名>"}`；多选为数组。

## 标准流程

### Step 1 新增商机
必填：项目名称(`ab1bssf`)、客户名称(`WlQVkBb` 选企业简称)、商机来源(`XJHKVQc`)、商机状态=`初步接触`、负责人(`5QVaMWH`)、项目启动时间(`jaNBpA3`)，并写首条 `p9rgK6w` 沟通进展。
```bash
dws aitable record create \
  --base-id yQod3RxJKGoKOeGpu46K53o0Jkb4Mw9r --table-id yldkqXl \
  --dry-run --records '[ <cells JSON> ]' --format json
```
预览给用户，**确认后**去掉 `--dry-run` 执行。

### Step 2 推进商机
更新 `doPbyiO` 沿管线前移；每次追加 `p9rgK6w`（新行写最前：`日期 + 摘要`）；补 `8h1LnTc` 预计成交时间、`HiiSyAY`/`xU35ORX`/`LzBLOPs` 金额（净利率自动算）。
```bash
dws aitable record update \
  --base-id yQod3RxJKGoKOeGpu46K53o0Jkb4Mw9r --table-id yldkqXl \
  --dry-run --records '[{"recordId":"<RID>","cells":{...}}]' --format json
```
确认后再执行。

### Step 3 成交
`doPbyiO`=成交；关联 `jt3laif`(成交订单号)、`Wcd4MzE`(报价测算)、`xgYf1hJ`(供方名称)。

### Step 4 流失
`doPbyiO`=未成交；必填 `UhNTuPk`(流失原因)。

### Step 5 关联扩展（按需）
- 报价测算：`Wcd4MzE` → 关联「报价测算」表（`mkH5auW`）。
- 拜访/交流：`Chs98y3` → 关联「拜访会议」表（`X3BzJDV`）。
- 子商机：`f9msxdK` → 关联本表其它记录。

### Step 6 验证
执行后用 `dws aitable record get --table-id yldkqXl --record-ids <RID>` 核对。

## 🔴 纪律红线
- **任何写入（create / update / 关联）前必须 dry-run 预览 + 用户确认**，禁止跳过确认直接 execute。
- 客户名称(`WlQVkBb`)必须选合作方库已有企业简称；若客户不在合作方库，先提醒用户去「合作方库」录入（见 taima-partner-lib 技能），不要在此新建客户。
- 公式字段（`JV3LTkV` 预估净利率、`qW1uWqP` 年度）由系统计算，勿手填。

## 更新技能包（同事侧）
当用户说「更新商机拓展技能 / 更新技能包」时，运行同步脚本（默认克隆路径 `~/taima-workbuddy-skills`）：
```bash
bash "$HOME/taima-workbuddy-skills/sync.sh"
```
（Windows PowerShell 用 `& "$env:USERPROFILE\taima-workbuddy-skills\sync.ps1"`）
脚本会 `git pull` 最新并复制到 `~/.workbuddy/skills/`。若克隆路径不同，替换为实际路径。
