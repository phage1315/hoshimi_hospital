# 伊兹米／美纱高级手术患者素材接入

用户确认候选预览后，八张 PNG 原样复制至 `assets/characters/advanced_izumi_v1/` 与 `assets/characters/advanced_misa_v1/`，未裁剪、重绘或转换。候选目录和生成记录保留，SHA-256 与已确认版本一致。

每人四张：`ward.png`、`postop.png`、`anesthesia.png`、`team_confirmation.png`。全麻图片同时映射至 `intraoperative/anesthetized` 与 `splash/general_anesthesia`。

最初登记在 `data/advanced_surgery/pending_first_patients.json`。后续按用户确认完成内容接入，现已将 visuals 合并进对应 `stories/*.json` 的 `patient`，并移除重复 pending 条目。美纱诊断中的来源待核制作备注依用户授权移出玩家界面，原始文件仍归档保留。两台专属术野现已按作者附件原样接入，release manifest 更新为 `runtime_ready=true`；DEV 可试玩，正式入口继续遵守发布顺序与进度门槛。

## 最初患者素材接入验证（历史记录）

- 八张生产资源与候选逐字节一致。
- Godot 4.5.1 已导入纹理；通过真实 Presentation.patient 出口验证中英文共 20 个纹理引用成功加载、患者 ID 与名称一致。
- 返场模式不返回首通专属患者映射。
- 未执行两台新术式的完整实机流程：术式尚未正式开放。
- 环境日志存在 macOS 证书读取警告，以及编辑器配置目录不可写提示；未影响项目内纹理导入与上述运行时加载验证。

## 后续边界

以上验证记录对应最初的美术接入。后续已补回原稿遗漏的 11 条旁白及英文，并落实美纱 M08 的返场亚型限制；完整内容与内部运行测试见 [内容接入记录](advanced_izumi_misa_integration_2026-11-01.md)。专属术野现已补齐，并完成中英文原生窗口自动流程测试（831 项检查，0 失败）；资源校验和、阶段映射及测试范围见内容接入记录。
