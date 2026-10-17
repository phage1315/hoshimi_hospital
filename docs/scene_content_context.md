# 通用场景内容覆盖接口

实现：`godot/systems/scene_content_context.gd`。这是可复用的内容解析器，已由 H profile session 调用；当前 Sayaka 测试入口默认使用 `hotel`，也可用 `begin_sayaka_h_profile_test(location_id, event_id)` 指定上下文。没有新增事件台词或地点 CG，稀疏 sidecar 当前为空，因而仍显示已配置的酒店素材和原 profile 台词。

## 调用契约

```gdscript
var context = preload("res://godot/systems/scene_content_context.gd").new(
    bundle, location_id, event_id, locale
)
var greeting = context.dialogue(["greeting.special", "greeting"])
var background = context.asset("background")
```

每个角色可持有自己的 bundle，由调用方选择；解析器不依赖角色 ID。地点建议沿用稳定 ID：`hotel`、`ward`、`operating_room`、`gyne_exam`、`clinic`、`home`。解析器接受任意地点 ID，未知 ID 表示没有对应覆盖。

Bundle 格式：

```json
{
  "base": {
    "dialogue": {"zh_CN": {"greeting": ["你好。"]}},
    "assets": {"background": {"path": "res://assets/example.png"}}
  },
  "locations": {},
  "events": {}
}
```

`locations[location_id]` 和 `events[event_id]` 使用同样的 dialogue 结构。地点可另有 assets；事件只覆盖对白，不参与素材选择。当前随工程提供的空模板是 `data/staff/doc_sayaka/h_context_overrides_v1.json`。例子路径仅说明格式，不是已经存在的素材。

## 回退与边界

- 对白优先级：事件 → 地点 → 基础。每一层先按候选 key 顺序查找，再进入下一层，因此事件的通用对白可以覆盖基础的细分对白。
- session 已接入对白池：触碰反应、地点入口、MAX 提示、两种风格开场/中段、H 阶段 start/middle/finish 池、手动完成按钮与回应、完成后的自由对白都可按 key 覆盖。没有对应 override 时，session 使用当前 profile/flow 数据。
- 每个 key 表示完整台词池或序列；数组整体替换，不拼接、不改写、不重新排序。说话人、表情等对象可原样放在数组中，消费者负责验证其结构。
- 缺失 key 才回退；显式空数组或错误类型返回错误，避免掩盖数据遗漏。尚不支持“空数组表示故意静音”。
- 语言必须使用调用方传入的准确 locale。没有自动跨语言回退；英文缺失不能偷偷显示中文。调用方应在加载前完成本地化审计。
- 图片优先级：地点 → 基础，按槽位独立解析。槽位名由消费者定义，不限制数量。单个槽位缺失不影响其他槽位。
- 返回 `ok`、`found`；成功时另有 `value`、`source`（对白另有 `key`）。调用方必须处理错误和完全缺失，不能直接读取 value。
- 构造时深复制数据，返回值也深复制；不污染基础档案或其他会话。事件 ID 必须由事件调用方明确传入，日常场景使用空字符串。
- 本接口不决定播放节奏、阶段转换、完成回调或事件解锁，也不读取存档和全局语言状态。

## 图片换背景与热点复用

需要共享热点的图片槽位调用 `asset(slot, shared_layout)`，其中 shared_layout 包含 `layout_id`、`width`、`height`。该槽位的素材声明必须含有相同三个字段，才允许复用坐标。其他纯展示图片不需要传 layout。

相同尺寸只是必要条件：人物的画布位置、缩放、姿势、轮廓和裁切也必须保持不变。仅改变背景最可靠；重新绘制人物即使画布尺寸相同，也需要人工复核热点。解析器检查声明，不分析人物像素；资源加载方仍须核实文件存在、可加载及实际像素尺寸与声明一致。

热点仍由原有独立数据维护，不在各地点重复。显示采用 KEEP_ASPECT_CENTERED 时，使用 `image_rect(container_rect, actual_image_size)` 求出排除留白后的图片矩形，再调用 `point_to_uv`。点在留白外或矩形无效时返回 `(-1, -1)`，不得触发热点。

## 验证与后续接入

`tools/scene_content_context_test.gd` 使用无关剧情的中性测试数据验证层级、稀疏回退、语言缺失、错误输入、会话隔离和留白坐标。该测试不代表现有 UI 已接线，也不代表任何新的角色事件或地点素材已经完成。

接入普通叙事场景时，由入口传入上下文；播放前解析对白和图片并验证结构/资源，处理缺失后交给现有播放器。不得通过接口自动补写缺失剧情。
