# 台马业务技能包 · 同事上手文档

教你的 WorkBuddy 做两件事：录合作方、管商机。

## 包含技能
| 技能 | 干嘛用 |
|---|---|
| 合作方库录入 | 发名片/资料图 → 自动查重 → 新增或更新人员 |
| 商机拓展 CRM | 新增/推进/成交/流失一条商机 |

## 一次性安装
选 Git Bash 或 PowerShell 一种，跑完重启 WorkBuddy：

```bash
# Git Bash
git clone https://github.com/Joanna-517/TM-Business-system.git "$HOME/taima-workbuddy-skills"
bash "$HOME/taima-workbuddy-skills/sync.sh"
```
```powershell
# PowerShell
git clone https://github.com/Joanna-517/TM-Business-system.git "$env:USERPROFILE\taima-workbuddy-skills"
& "$env:USERPROFILE\taima-workbuddy-skills/sync.ps1"
```

## 前提
- 机器装了 git。
- WorkBuddy 已连**钉钉**，且你有「业务管理系统」多维表权限。

## 怎么用
- 合作方：直接发名片图，说「录入这张名片」。
- 商机：说「记个商机 / 推进某商机 / 商机成交了」。
- 写入前 WorkBuddy 会先给你看预览并确认，不会直接乱填。

## 以后更新
台马改完技能会推上来。你只需在 WorkBuddy 说「**更新技能包**」，自动拉最新并覆盖，重启生效。
