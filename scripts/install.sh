#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf '安装停止：%s\n' "$*" >&2
  exit 1
}

exists() {
  [[ -e "$1" || -L "$1" ]]
}

device() {
  stat -c '%d' "$1" 2>/dev/null || stat -f '%d' "$1"
}

[[ $# -le 1 ]] || fail "用法：bash scripts/install.sh [提交]"
command -v shasum >/dev/null || fail "请先准备 shasum（SHA-256 校验工具）。"
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
commit=$(git -C "$repo" rev-parse --verify --end-of-options "${1:-HEAD}^{commit}")
agents="$HOME/.agents/skills/project-advance"
codex="$HOME/.codex/skills/project-advance"
lock="$HOME/.agents/.project-advance-install.lock"
recovery="$lock/recovery"
work=
target=

cleanup() {
  local status=$?
  trap - EXIT HUP INT TERM
  if [[ -n "$work" ]]; then
    if [[ -d "$work/previous" ]] && ! exists "$target"; then
      if ! mv "$work/previous" "$target"; then
        printf '自动恢复失败，旧版仍在 %s\n' "$work/previous" >&2
        exit 1
      fi
    fi
    if [[ ! -d "$work/previous" ]]; then
      rm -rf "$work"
    fi
  fi
  rm -f "$recovery"
  rmdir "$lock"
  exit "$status"
}

mkdir -p "$HOME/.agents"
if ! mkdir "$lock" 2>/dev/null; then
  if [[ -f "$recovery" ]]; then
    printf '本次切换的恢复记录（提交、目标、备份）：\n' >&2
    cat "$recovery" >&2
  fi
  fail "安装锁不可用：${lock}。确认安装已停止后，按 README 的恢复步骤处理。"
fi
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

if exists "$agents" && exists "$codex"; then
  fail "找到两份安装：$agents 和 ${codex}。请先确认 Codex 使用哪份，将另一份移出技能目录。"
fi
target="$agents"
if exists "$codex"; then
  target="$codex"
fi
if [[ -n "${SKILL_INSTALL_DIR:-}" ]]; then
  case "$SKILL_INSTALL_DIR" in
    "$agents"|"$codex") ;;
    *) fail "SKILL_INSTALL_DIR 须为 $agents 或 ${codex}。" ;;
  esac
  if exists "$target" && [[ "$SKILL_INSTALL_DIR" != "$target" ]]; then
    fail "已有安装 $target，请在原路径升级。"
  fi
  target="$SKILL_INSTALL_DIR"
fi
if exists "$target" && [[ ! -d "$target" || -L "$target" || ! -f "$target/SKILL.md" ]]; then
  fail "目标已存在但不是普通 Skill 目录：$target。请先检查或按 README 恢复。"
fi

skills_dir=$(dirname "$target")
mkdir -p "$skills_dir"
# 同一文件系统上的目录移动是重命名，避免 mv 跨盘回退到复制。
work=$(mktemp -d "$(dirname "$skills_dir")/.project-advance-install.XXXXXXXX")
[[ "$(device "$work")" == "$(device "$skills_dir")" ]] ||
  fail "暂存区和技能目录不在同一文件系统。"
if exists "$target"; then
  [[ "$(device "$target")" == "$(device "$skills_dir")" ]] ||
    fail "当前安装与其父目录不在同一文件系统。"
fi

mkdir "$work/next"
git -C "$repo" archive "$commit" SKILL.md GLOSSARY.md references > "$work/skill.tar"
tar -xf "$work/skill.tar" -C "$work/next"
# 根据 Git 中的原始文件独立生成摘要，再逐项检查暂存副本。
git -C "$repo" ls-tree -r --name-only "$commit" -- SKILL.md GLOSSARY.md references > "$work/files"
while IFS= read -r file; do
  checksum=$(git -C "$repo" show "$commit:$file" | shasum -a 256)
  printf '%s  %s\n' "${checksum%% *}" "$file"
done < "$work/files" > "$work/sha256"
[[ -z "$(find "$work/next" -type l -print)" ]] || fail "安装源含符号链接。"
for required in SKILL.md GLOSSARY.md references/examples.md references/project-templates.md references/release-and-deploy.md; do
  [[ -f "$work/next/$required" ]] || fail "安装源缺少 $required。"
done
(cd "$work/next" && shasum -a 256 -c "$work/sha256")

if exists "$target"; then
  # 保留在本次锁内，先写全路径，再移动旧版。
  printf '%s\n' "$commit" "$target" "$work/previous" > "$recovery"
  printf '旧版备份位置：%s\n' "$work/previous"
  mv "$target" "$work/previous"
fi
mv "$work/next" "$target"
printf '已安装 %s 至 %s\n' "$commit" "$target"
