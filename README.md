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
| [SKILL.md](SKILL.md) | 触发范围、授权规则、开工、验收、收口和汇报的主流程 |
| [references/release-and-deploy.md](references/release-and-deploy.md) | 发布版本和部署的详细流程，主文件按需引用 |
| [references/project-templates.md](references/project-templates.md) | 项目文件标准、模板、GitHub 转接和规划工具 |
| [LICENSE](LICENSE) | MIT 许可证 |

## 安装

首次安装时选择一个 Codex 用户 Skill 目录。以下示例使用官方默认位置；已有运行副本时，先确认 Codex 使用的目录，再按版本同步。 [Codex Skill 目录说明](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills)

```bash
git clone https://github.com/cai11133/project-advance.git &&
skill_install="${SKILL_INSTALL_DIR:-$HOME/.agents/skills/project-advance}" &&
test ! -e "$skill_install" && test ! -L "$skill_install" &&
mkdir -p "$skill_install" &&
cp -R project-advance/SKILL.md project-advance/references "$skill_install/"
```

新会话可以说「我想做个证照到期提醒」「把这个旧项目接进来」或「继续」。Skill 会先定位资料和任务，说明这次交付、验收与预计停点。Codex CLI 也可用 `$project-advance` 显式调用。

## 前提与适用范围

- 操作 GitHub 时，需要 GitHub 账号和已登录的 `gh` 命令行（`gh auth status` 能通过）。
- 新项目可按获批任务单在本地开工，默认记录在 `tasks/`；使用 GitHub 时以 Issue 跟踪任务。转接后继续维护一份主记录。
- `references/release-and-deploy.md` 为 macOS 新项目提供默认方案，使用 `launchd` 管理服务，默认监听 `127.0.0.1`。其他环境按项目约定安排。
- GitHub 路径的分支名未约定时使用 `codex/<Issue编号>-<英文短名>`，可在项目的 `AGENTS.md` 里指定其他前缀。

## 验证状态

| 已验证 | 未验证 |
| --- | --- |
| 在 macOS 上，用 Codex CLI 完成了从 Issue、分支、PR 到合并、发布 `v0.1.0` 的一次小型项目交付。 | Codex 桌面入口的全部场景。 |
| 本地无远程的项目中，新 CLI 会话只说“继续”时，能读项目文件、核对分支、列出候选并等用户选择。 | 配有 GitHub 远程时，只说“继续”后列出候选 Issue 和 PR 的完整路径。 |
| 必需验收项失败时，Issue 对应项留空、写明失败原因并停在合并前。修复后更新清单，合并后 Issue 自动关闭。 | Windows 上的浏览器和脚本表现。 |
| 实际合并中，Issue 清单写入未获批时停下来确认，获批后才更新清单并继续合并。 | 新会话中的同一授权边界专项复测。 |
| 从已发布版本取出文件，在本机临时部署并通过 HTTP 验证。 | 长期运行、开机自启、定时备份和故障回滚。 |

## 贡献

欢迎提 Issue 和 PR。修改“授权”和“必须暂停”两处规则时，请在 PR 里单独说明理由，这两处决定了 Agent 的操作边界。

## 许可证

MIT，详见 [LICENSE](LICENSE)。Copyright (c) 2026 cai11133
