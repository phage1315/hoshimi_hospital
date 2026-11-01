# 高级术式术野素材复用约定

当前运行引用由 `data/advanced_surgery/field_windows.json` 控制。图片保持原比例显示。

| 类别 | 切皮 | 缝合 | 授权用途 |
| --- | --- | --- | --- |
| 普通腹部 | whipple_incision.png | whipple_closure.png | 普通腹部高级手术可复用 |
| 盆腔 | pelvic_incision.png | pelvic_closure.png | 盆腔手术可复用 |
| 开胸（Ebstein提供版本） | thoracic_incision.png | thoracic_closure.png | 开胸手术可复用，按具体入路选用 |
| 侧卧位开胸 | sleeve_lobectomy_incision.png | sleeve_lobectomy_closure.png | 侧卧位开胸手术可复用 |

Whipple术野使用whipple.png；盆壁肿瘤切除（髂血管重建）术野使用pelvic_sidewall_iliac_field.png。术野图片按术式指定，不按患者重复制作。不自动给胸部／心脏术式使用腹部或盆腔图片。新增术式直接在field_windows.json引用合适的现有文件，无需复制一份。

2026-10-31作者明确授权以上四组切皮／缝合素材复用。来源与校验和见docs/asset_sources.md。

Ebstein Cone重建术野使用ebstein_cone_field.png。开胸切皮／缝合文件来自作者本轮附件1／2；本轮先接入Ebstein，复用时通过术式映射明确指定。

开胸袖式肺叶切除采用作者专门提供的sleeve_lobectomy_incision.png、sleeve_lobectomy_closure.png与sleeve_lobectomy_field.png。保留Ebstein已登记的开胸通用素材，不覆盖。当前四台术式的12个切皮／术野／缝合引用均为正式素材。

作者追加确认：袖式肺叶切除附件1／2同时登记为侧卧位开胸通用切皮／缝合素材。沿用现有文件名和运行引用；新术式可直接引用这两个文件。术野sleeve_lobectomy_field.png仍按术式单独指定。
