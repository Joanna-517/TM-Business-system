# TAIMA WorkBuddy 技能包

教同事的 WorkBuddy 用的两套业务技能，含一键同步更新机制。

## 包含技能
| 技能 | 用途 |
|---|---|
| `taima-partner-lib` | 合作方库录入（名片/资料→查重→新增或更新人员） |
| `taima-crm-pipeline` | 商机拓展 CRM 管线（新增/推进/成交/流失） |

## 维护者（你 = 台马）
- 改技能：直接编辑对应 `SKILL.md`，`git commit` + `git push` 到本仓库。
- 同事侧会自动/手动同步到最新。

## 同事一次性安装
选一种终端（Git Bash 或 PowerShell），把仓库克隆到固定路径 `~/taima-workbuddy-skills`：

```bash
# Git Bash
git clone https://github.com/Joanna-517/TM-Business-system.git "$HOME/taima-workbuddy-skills"
bash "$HOME/taima-workbuddy-skills/sync.sh"
```
```powershell
# PowerShell
git clone https://github.com/Joanna-517/TM-Business-system.git "$env:USERPROFILE\taima-workbuddy-skills"
& "$env:USERPROFILE\taima-workbuddy-skills\sync.ps1"
```
安装后**重启 WorkBuddy**，技能即出现在技能列表。

## 以后更新（一句话同步）
同事在 WorkBuddy 里说「更新合作方库技能 / 更新技能包」，WorkBuddy 调用上面的 sync 脚本：
- `git pull` 拉你最新改动
- 复制到 `~/.workbuddy/skills/` 覆盖旧版
- 重启 WorkBuddy 生效

> 若克隆路径不是 `~/taima-workbuddy-skills`，把技能 SKILL.md「更新技能包」段和上面的路径换成实际路径即可。

## 前置条件
- 同事 WorkBuddy 已连**钉钉 connector** 且有「业务管理系统」Base 权限。
- 同事机器装了 git。

## 备注
- 技能内 Base / 表 / 字段 ID 已硬编码（台马机构内固定）。
- 单选/多选选项 ID 同样硬编码；新增选项时系统会自动建，无需手动维护 ID。
