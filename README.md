# project-advance

一个用 GitHub Issue 和 Pull Request 管理正式开发的 Codex Skill。你只需要说想推进什么，它先核对项目的实际状态，再决定从哪一步开始，并在每一步划清“可以直接做”和“必须先问你”的边界。

> 本 Skill 按 Codex 编写，指令为中文。用于其他 Agent 前需要自行调整。

## 它做什么

| 阶段 | 做法 |
| --- | --- |
| 开始 | 核对工作环境、仓库、分支和 GitHub 状态，再用三句话复述项目背景、当前进度和本次任务。 |
| 定位任务 | 用任务名、当前分支和 PR 找到对应 Issue。有多个候选时列出标题让你选。 |
| 开发与验收 | 先有 Issue 再开工，逐条记录验收结果（通过、失败、未验证）和证据。 |
| 提交 | PR 写明范围和验收结果。指向默认分支时，用 `Closes #编号` 关联同仓库 Issue。 |
| 收口 | 合并前按授权勾选 Issue 的验收清单，合并后核实 PR 与 Issue 的实际状态。 |
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
| [LICENSE](LICENSE) | MIT 许可证 |

## 安装

把两份文件放到 Codex 的用户 Skill 目录，保持 `references/` 的相对路径。以下命令用于首次安装。 [Codex Skill 目录说明](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills)

```bash
git clone https://github.com/cai11133/project-advance.git
mkdir -p "$HOME/.agents/skills/project-advance/references"
cp project-advance/SKILL.md "$HOME/.agents/skills/project-advance/SKILL.md"
cp project-advance/references/release-and-deploy.md "$HOME/.agents/skills/project-advance/references/release-and-deploy.md"
```

之后在新的 Codex 会话里说“继续做 XX 项目”或“推进这个项目的 Issue”。Codex 可以按描述选择该 Skill。在 Codex CLI 中也可用 `$project-advance` 显式调用。

## 前提与适用范围

- 操作 GitHub 时，需要 GitHub 账号和已登录的 `gh` 命令行（`gh auth status` 能通过）。
- 正式开发流程以 GitHub Issue、Milestone 和 PR 为核心。项目尚未接入 GitHub 时，可以先做只读盘点和拟定任务草稿。
- `references/release-and-deploy.md` 为 macOS 新项目提供默认方案，使用 `launchd` 管理服务，默认监听 `127.0.0.1`。其他环境按项目约定安排。
- 分支名未约定时使用 `codex/<Issue编号>-<英文短名>`，可在项目的 `AGENTS.md` 里指定其他前缀。

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
