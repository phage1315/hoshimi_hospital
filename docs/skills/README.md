# 项目工作流索引

这些文件供全新代理按任务读取，不依赖个人目录自动注入技能。先遵守 [根规则](../../AGENTS.md) 与 [项目上下文](../CONTEXT.md)。这里只保存工作方法，不触发生成、上传、清理或测试。

## 通用工作流

- [剧情、双语和已有素材接入](narrative-integration.md)：原稿版本、逐句审计、素材映射、测试与交付。
- [存档边界修改](save-boundary.md)：事实设计、迁移、隔离验证与时间／奖励稳定性。
- [原生窗口测试](hoshimi-native-playtest/SKILL.md)：独立存档、实际 GUI 输入、中英演出、日志与证据分级。

## 按角色推进

- [H Profile 技术接入](hoshimi-h-profile/SKILL.md)，附 `references/` 契约／作者交付／QA，`scripts/inventory.py` 只读技术盘点和 `assets/` 模板。
- [Lv4 自由 H 开通核验](hoshimi-lv4-free-h-readiness/SKILL.md)：固定剧情、真实完成、注册、预约、九区、六头像与最终流程。
- [Lv5 医护作为患者](hoshimi-lv5-staff-patient-readiness/SKILL.md)：独立患者对白、普通／高级流程、必需素材与正式资格。

上述本地技能快照中的版本号、素材数量和具体路径属于归档时基线，执行时先对照当前接口。用户当前明确指令优先于技能默认流程；不要对已授权的本地集成重复索取许可。只请求缺口清单不等于授权生成／发布，纯素材导入不包含图像内容审查。

## 已有患者技能（单一来源，不重复复制）

仓库 `skills/` 已自带可移植说明及相对引用，继续以它为权威入口：

| 请求 | 技能 |
|---|---|
| 确定患者任务范围 | [add-patient](../../skills/add-patient/SKILL.md) |
| 建立／更新数据包 | [import-patient-data](../../skills/import-patient-data/SKILL.md) |
| 制作所需 SFW 立绘 | [generate-patient-portraits](../../skills/generate-patient-portraits/SKILL.md) |
| 接入用户指定图片／CG | [import-patient-assets](../../skills/import-patient-assets/SKILL.md) |

数据、生成、用户素材导入各有验收条件；以用户实际授权为准，不把一个阶段的完成宣称为整位患者全部可用。

## Git LFS 工作流

[上传后缓存清理](git-lfs-cache-cleanup/SKILL.md) 记录既有项目偏好和核验步骤：仅在获授权 push 成功且远端对象、工作文件和保留条件均核实后清理缓存。它不授权本次提交、推送、上传新远端或删除素材；文档归档不执行清理。

## 来源、携带范围与更新

五份个人技能及依赖于 2026-11-07 从本机 `/Users/ningye/.codex/skills/` 同名目录原样归档。附带模板、盘点脚本和技能元数据用于保留相对依赖，不是业务代码变更；归档副本不会自动安装到新代理的个人 Skills。

`narrative-integration.md` 与 `save-boundary.md` 是本次根据根规则和仓库契约整理的工作流。它们不新增创作授权或产品功能。个人路径、Godot 路径、工具名称、日期和旧测试驱动在新环境需核实，不能直接照抄。以后修改技能，明确更新仓库说明及对应依赖，避免个人副本与仓库悄然分叉。
