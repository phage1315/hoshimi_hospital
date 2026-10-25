# 已注册医护常服表情覆盖核对（2026-10-23）

范围：data/staff/index.json 中的26人，读取各 bundle 指定的 profile.visuals.portraits；按文件 SHA-256 去重。统计实际注册引用，不包括磁盘上未注册的候选图。芹香尚未注册，不计入26人。

结论：24/26人的春夏常服只有一张实际图片；26/26人的秋冬常服只有一张。春夏已有真实差分的仅南条小夜香（3张）与遥凑（4张）。阿尔托莉雅、藤崎詩織的 smile 是 neutral 别名。

| 人物 | ID | 春夏独立图片数 | 秋冬独立图片数 | 说明 |
| --- | --- | ---: | ---: | --- |
| 神宮寺 成美 | doc_aoi | 1 | 1 | 仅 neutral |
| 深山 佳織 | doc_rei | 1 | 1 | 仅 neutral |
| 七瀬 恋 | nurse_haru | 1 | 1 | 仅 neutral |
| 中井 美佳 | nurse_rin | 1 | 1 | 仅 neutral |
| 朝倉 美幸 | nurse_yui | 1 | 1 | 仅 neutral |
| 飯村 真奈美 | pharmacist_manami | 1 | 1 | 仅 neutral |
| 利根川 安琪 | nurse_ange | 1 | 1 | 仅 neutral |
| 杉村 弘子 | nurse_hiroko | 1 | 1 | 仅 neutral |
| 本庄 萌惠 | nurse_moe | 1 | 1 | 仅 neutral |
| 御堂 江美子 | doc_emiko | 1 | 1 | 仅 neutral |
| 城宮 明日香 | doc_asuka | 1 | 1 | 仅 neutral |
| 阿尔托莉雅·潘德拉贡 | doc_artoria | 1 | 1 | casual 的 smile 与 neutral 共用图片 |
| 藤崎 詩織 | doc_shiori | 1 | 1 | casual 的 smile 与 neutral 共用图片 |
| 水城 阿库娅 | doc_aqua | 1 | 1 | 仅 neutral |
| 南条 小夜香 | doc_sayaka | 3 | 1 | casual: neutral, smile, shy, happy |
| 遥凑 | doc_minato | 4 | 1 | casual: neutral, smile, amused, thoughtful |
| 伊吹 摩耶 | visiting_maya | 1 | 1 | 仅 neutral |
| 佐仓 双叶 | visiting_futaba | 1 | 1 | 仅 neutral |
| 石神 千鹤 | nurse_ishigami | 1 | 1 | 仅 neutral |
| 樱花 | doc_sakura_anesthesiology | 1 | 1 | 仅 neutral |
| 折川 皐月 | nurse_satsuki | 1 | 1 | 仅 neutral |
| 岩崎留美 | nurse_iwasaki_rumi | 1 | 1 | 仅 neutral |
| 米田栞 | nurse_yoneda_shiori | 1 | 1 | 仅 neutral |
| 薗田愛実 | nurse_sonoda_itsumi | 1 | 1 | 仅 neutral |
| 狩谷惠 | nurse_kariya_megumi | 1 | 1 | 仅 neutral |
| 氷上冴子 | nurse_hikami_saeko | 1 | 1 | 仅 neutral |

## 对约会事件的影响

godot/ui/app.gd 的 add_portrait（约1697行）在缺少 outfit/expression 时回退同服装 neutral；因此事件可继续播放，但情绪演出丢失。季节自动选用 casual_winter 时，已有春夏差分不能替代冬装差分。当前不是剧情文本缺口，应继续按人物与情节编写表情指示，再针对所需键补图，不能为了现有图片删改剧本。

优先为准备编写或实装约会事件的人物补齐两季常服。建议基础语义包括说话、微笑、害羞、惊讶、认真、低落或担忧；表情强度按人物设定调整。特殊非约会角色无需机械套用完整约会表情集。资源别名不算真实差分，接入时应检查缺键与复用图片。

## 本轮芹香补图

新增20张：春夏6、秋冬6、刷手服4、戴口罩无菌服4。保存于 research/character_references/misono_serika_2026-10-23/art/expressions/；wardrobe_prompts.json 保留参考图、生成来源与提示词，wardrobe_manifest.json 保留尺寸及校验和。全部为1024×1536、8位 RGBA PNG，20张哈希各不相同。仅生成归档，尚未注册到运行时人物数据；透明通道预览不作为背景光晕问题判断。

引用路径检查：全部存在。
