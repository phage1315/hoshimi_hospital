# 截石位手术台界面立绘

截石位界面素材属于患者 `operating_table` 状态的体位差分，不属于事件 CG，也不进入 CG 鉴赏。

## 资源键

每名患者必须提供以下四个键：

- `operating_table_lithotomy/awake`
- `operating_table_lithotomy/tense`
- `operating_table_lithotomy/afraid`
- `operating_table_lithotomy/anesthetized`

文件放在患者现有素材包旁的 `operating_table_lithotomy/` 目录。登记到患者包的 `visuals.portraits` 后，截石位术式会自动读取相应表情；兼容逻辑仍允许旧患者缺图时回退到 `operating_table/<expression>`，但当前六名患者均已提供完整四态，不会发生回退。

## 构图约定

- 使用 1448×1086（4:3）画幅，与现有手术台界面保持相同俯视角度和角色身份。
- 主床完整承托头部至骨盆，在臀部后方结束；移除中央床尾腿板，为术者保留站位。
- 双腿屈髋屈膝；大型软垫腿架承托膝后至近端小腿，膝下、小腿远端、脚踝与双脚自然悬空。
- 从胸口到骨盆及双腿保持完整不透明遮盖。两腿之间使用一整块连续帘式无菌单，不出现裤装式分叉或 V 形裆部接缝。
- 无菌单下缘以下显示开放的手术室地面，不补回床板、床垫或连接平台。
- `awake / tense / afraid / anesthetized` 只改变面部和意识状态，不改变镜头、体位、布单、床或设备位置。
- 不在这组界面图中表现导尿、消毒、器械操作或人物专属情节；这些内容继续使用独立全屏 CG 池。

## 运行规则

术式的 `positioning.primary_position` 为 `lithotomy` 时，术前手术室界面尝试使用本组素材；`supine` 继续使用原手术台素材。体位固定阶段的说明和按钮也会同步切换为截石位或仰卧位文案。

手术台图片区为 450×310，并使用 `STRETCH_KEEP_ASPECT_CENTERED`。4:3 素材会完整显示为约 413×310，左右各留约 18 像素，不需要预裁切左右边缘。

## 当前覆盖

- 音羽响子（`patient_sora`）
- 二ノ宫纱智子（`patient_emi`）
- 高卷杏（`patient_ann`）
- 奥寺美纪（`patient_miki`）
- 琪琪·安达露西亚（`patient_gigi`）
- 柳原理惠（`patient_rie`）

以上患者均已配置 `awake / tense / afraid / anesthetized` 四态。
