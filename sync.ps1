# TAIMA WorkBuddy 技能同步脚本（Windows PowerShell）
# 用法: & ".\sync.ps1"
# 作用: 拉取最新技能并复制到 $env:USERPROFILE\.workbuddy\skills\
$ErrorActionPreference = "Stop"

$REPO = Split-Path -Parent $MyInvocation.MyCommand.Path
$SKILLS = "$env:USERPROFILE\.workbuddy\skills"

Write-Host "[sync] repo: $REPO"
Write-Host "[sync] pull latest..."
git -C $REPO pull --ff-only

Write-Host "[sync] install to $SKILLS ..."
New-Item -ItemType Directory -Force -Path $SKILLS | Out-Null
foreach ($d in @('taima-partner-lib','taima-crm-pipeline')) {
  if (Test-Path "$REPO\$d") {
    Remove-Item -Recurse -Force "$SKILLS\$d" -ErrorAction SilentlyContinue
    Copy-Item -Recurse "$REPO\$d" "$SKILLS\$d"
    Write-Host "[sync]   + $d"
  }
}

Write-Host "[sync] done. 重启 WorkBuddy 以加载新技能。"
