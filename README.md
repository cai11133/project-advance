# project-advance

一个用本地任务单或 GitHub Issue 推进项目的 Codex Skill。你只需要说想推进什么，它先核对项目的实际状态，再决定从哪一步开始，并在每一步划清“可以直接做”和“必须先问你”的边界。

> 本 Skill 按 Codex 编写，指令为中文。用于其他 Agent 前需要自行调整。

## 它做什么

| 阶段 | 做法 |
| --- | --- |
| 开始 | 核对工作环境、仓库、分支和 GitHub 状态，再用三句话复述项目背景、当前进度和本次任务。 |
| 定位任务 | 用项目文件、任务单、分支或 PR 定位当前任务。有多个候选时列出标题让你选。 |
| 开发与验收 | 新需求先确认任务单和验收；按选定路径使用本地记录或 Issue。 |
| 提交 | PR 写明范围和验收结果。指向默认分支时，用 `Closes #编号` 关联同仓库 Issue。 |
| 收口 | 先同步 Checklist、验收证据和四行交接；合并前按授权更新 Issue 验收清单。 |
| 发布与部署 | 发版和部署分别确认、分别验证，部署前核对备份和回滚方案。 |
| 汇报 | 常规汇报给出改动、验证、未验证项和下一步。需要你决定时，一次给齐背景、进度、卡点、方案、推荐和待决事项。 |

## 授权规则一览

授权只对本次任务有效，不跨对话继承。新对话只说“继续”时，先做只读检查和拟方案。当前对话已经明确授权的操作可接续执行。

| 操作 | 需要的确认 |
| --- | --- |
| 只读检查、拟计划、Issue 草稿 | 按本次请求，在已有访问范围内直接进行。 |
| 改文件、建分支、本地提交 | 已授权的单步改动且少于 3 个文件时直接做。多步骤或改动 3 个及以上文件时，先列计划等你确认。 |
| GitHub 写入（建仓、建 Issue、推送、更新 PR） | 你对目标仓库和操作清单的明确授权。 |
| 合并 PR | 针对该 PR 的明确授权，是否更新 Issue 验收清单一并列明。 |
| 发布（tag、Release） | 对仓库、版本、提交和范围的明确授权。 |
| 部署 | 对本次部署方案的明确批准。 |

删除已有文件、force push、覆盖已有 tag 等不可逆操作须单独确认。本次任务自建的临时文件和获批计划内的删除按原授权执行。

## 文件

| 文件 | 内容 |
| --- | --- |
| [scripts/install.sh](scripts/install.sh) | 首次安装、升级和完整性校验 |
| [SKILL.md](SKILL.md) | 触发范围、授权规则、开工、验收、收口和汇报的主流程 |
| [references/release-and-deploy.md](references/release-and-deploy.md) | 发布版本和部署的详细流程，主文件按需引用 |
| [references/project-templates.md](references/project-templates.md) | 项目文件标准、模板、GitHub 转接和规划工具 |
| [references/examples.md](references/examples.md) | 三句话说明、决策说明和任务单片段的填好样例 |
| [LICENSE](LICENSE) | MIT 许可证 |

## 安装

安装脚本使用 Bash、Git 和 `shasum`。首次安装默认放在 `~/.agents/skills/project-advance`。脚本会同时检查这个位置和 `~/.codex/skills/project-advance`，只有一份就沿用原路径。两处都存在时，先用 Codex 确认可用副本，把另一份移出技能目录再重试。[Codex Skill 目录说明](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills)

```bash
git clone https://github.com/cai11133/project-advance.git &&
cd project-advance &&
bash scripts/install.sh
```

新会话可以说「我想做个证照到期提醒」「把这个旧项目接进来」或「继续」。Skill 会先定位资料和任务，说明这次交付、验收与预计停点。Codex CLI 也可用 `$project-advance` 显式调用。

## 升级

在已克隆的仓库目录运行。脚本默认安装当前 Git 提交，也可以运行 `bash scripts/install.sh <提交>` 安装指定版本。

```bash
git pull --ff-only &&
bash scripts/install.sh
```

脚本在 Codex 技能扫描目录外组装文件，并根据 Git 原文逐一校验 SHA-256。校验通过后才切换目录，旧版保存在脚本显示的备份位置。备份含原目录中的本地文件，按需取回。升级后可在新 Codex 会话确认只发现一份 Skill。

切换使用同一文件系统内的两次目录移动。普通错误或可捕获的中断会触发自动恢复。若中断后重试提示安装锁不可用，先确认原来的安装进程已停止。锁内的恢复记录会在重试时显示，即使原终端已经关闭。

如果目标缺失，运行下面的命令恢复旧版。存在目标目录、文件或符号链接时，命令会停下并保留备份和锁。

```bash
(
  set -e
  lock="$HOME/.agents/.project-advance-install.lock"
  record="$lock/recovery"
  {
    IFS= read -r commit
    IFS= read -r target
    IFS= read -r backup
  } < "$record"
  if [ -e "$target" ] || [ -L "$target" ]; then
    printf '目标已存在，已保留备份：%s\n' "$backup" >&2
    exit 1
  fi
  [ -d "$backup" ] && [ -f "$backup/SKILL.md" ] || {
    printf '没有找到可恢复的备份：%s\n' "$backup" >&2
    exit 1
  }
  mv "$backup" "$target"
  rm "$record"
  rmdir "$lock"
  printf '已恢复至 %s\n' "$target"
)
```

目标已存在时，先确认那里是完整可用的 Skill，保留扫描目录外的旧版备份。确认后删除锁内的 `recovery` 文件，再用 `rmdir ~/.agents/.project-advance-install.lock` 移除空锁。若锁内没有恢复记录且尚未开始移动旧版，确认安装进程已停止后可直接移除空锁。目标缺失且找不到恢复记录时，先查原终端输出中的备份位置，确认旧版位置后再继续。

## 前提与适用范围

- 操作 GitHub 时，需要 GitHub 账号和已登录的 `gh` 命令行（`gh auth status` 能通过）。
- 新项目可按获批任务单在本地开工，默认记录在 `tasks/`；使用 GitHub 时以 Issue 跟踪任务。转接后继续维护一份主记录。
- `references/release-and-deploy.md` 为新项目提供面向用户本机的默认部署方案，按操作系统选择服务管理方式（macOS 用 `launchd`，Linux 用 `systemd` 用户服务，Windows 用任务计划程序或 Windows 服务），默认监听 `127.0.0.1`。其他环境按项目约定安排。
- GitHub 路径的分支名未约定时使用 `<所用Agent>/<Issue编号>-<英文短名>`，可在项目的 `AGENTS.md` 里指定其他前缀。

## 验证状态

| 验证内容 | 版本 | 平台 | 有记录的次数 |
| --- | --- | --- | --- |
| 新需求先读模板，出任务单草稿并等待开工 | `367f3d2` | macOS Codex CLI | 2 |
| 新会话说“继续”，找到已有本地任务单 | `367f3d2` | macOS Codex CLI | 1 |
| 一次性单词纠错只修改指定文件 | `367f3d2` | macOS Codex CLI | 1 |
| 首装、升级、两处同时存在、故障注入和恢复 | `0.2.0` | macOS 隔离目录 | 13 个场景各 1 次 |
| 新装和两种原路径升级后，Codex 各发现一份完整 Skill | `0.2.0` | macOS Codex CLI | 3 |
| 旧项目接入的环境与任务记录选择卡片。桌面端收到实际答复后继续，Codex Cloud 显式加载试改版后收到实际答复并展示 Issue 草稿 | `0.2.0` 试改版 | macOS Codex 桌面端、Codex Cloud | 各 1 次 |

待验证：Codex 桌面与云端的完整流程、Linux 与 Windows 上的实际安装和部署、远程仓库里只说“继续”后的候选定位，以及长期运行、开机自启、定时备份和故障回滚。

## 贡献

欢迎提 Issue 和 PR。修改“授权”和“必须暂停”两处规则时，请在 PR 里单独说明理由，这两处决定了 Agent 的操作边界。

## 许可证

MIT，详见 [LICENSE](LICENSE)。Copyright (c) 2026 cai11133
