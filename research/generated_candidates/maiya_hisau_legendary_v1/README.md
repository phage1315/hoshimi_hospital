# 久宇舞弥（Maiya Hisau）传奇术式候选美术包（`maiya_hisau_legendary_v1`）

- 对应术式预留 ID：`surgery_master_whipple_vascular_reconstruction`（阿尔托莉雅·潘德拉贡／Saber 传奇术式）
- 状态：已完成候选生成与本地 `BiRefNet-ToonOut` 离线透明抠图，等待用户确认候选图并提供完整三日双语 VN 剧本后再复制入正式 `assets/` 与运行数据。
- 目录结构：
  - `author_supplied/saber_whipple_vascular_field.jpg`：用户上传的开腹 Whipple＋PV/SMV 门肠静脉吻合主术野图，逐字节原样归档（未发往任何云端生成服务）。
  - `raw/`：基于 `_staging/maiya_hisau_patient_seed_v1/{maiya_ward_seed,maiya_operating_head_seed}.png` 衍生生成的 8 张原始非透明候选图。
  - `prepared/`：8 张经本地 `tools/portrait_matting.py`（`birefnet-toonout-fp16.onnx`）抠图完成的 `RGBA` 透明立绘（`ward/{neutral,serious,relieved}`、`postop/{neutral,tired,relieved}`、`casual/neutral`、`or_cap/calm`）＋ 2 张保留完整场景的 `RGB` 图（`transfer.png` `1536×1024`、`anesthesia.png` `1448×1086`）。
  - `qa/`：8 张深色／医院青／浅色三底合成及 `2×` 边缘放大质检图。
  - `manifest.json`：全部 11 项文件的尺寸、模式、顶角透明度与 SHA-256 记录。
