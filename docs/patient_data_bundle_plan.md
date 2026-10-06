# 患者专属数据包整理方案

> 实施状态：第一、二和四阶段已于 2026-09-27 完成。六名患者已迁移到独立数据包，门诊与术前流程已改为共用模板，旧重复 JSON 已删除。第三阶段的美术目录统一将与裸体立绘修订一起进行。

## 目标

普通随机患者应采用“一名患者一个目录”的组织方式。新增、修改或删除患者时，只需要处理该患者目录及患者索引；门诊、术前和手术的共用流程不再为每名患者复制一份。

疾病、检查和术式继续由全局 `case_templates` 随机分配。患者包只描述人物本身，以及确实只属于该人物的对白和美术。

## 当前情况

项目现有 6 名普通随机患者，每人均有：

- 17 个标准图片槽位；
- 27 条关键反应对白；
- 13 组反应差分，共 26 条差分对白；
- 1 份门诊 encounter 蓝图；
- 1 份术前 preop 蓝图。

目前相关数据分散在：

- `data/patients/patients.json`：6 名患者的身份、性格、数值、图片路径和专属对白，约 72 KB；
- `data/encounters/encounters.json`：6 份门诊蓝图，约 104 KB；
- `data/preop/preop.json`：6 份术前蓝图，约 260 KB；
- `data/examination_cg_pools.json`：患者专属检查 CG 与全局检查 CG 混合；
- `data/ward_preparation_cg_pools.json`：患者专属准备 CG 与通用 CG 混合；
- 多个 `assets/characters/*_v1`、`portrait_pack_v*`、`assets/events/*` 目录。

六份 preop 蓝图结构完全相同。六份 encounter 的阶段和动作结构也相同；现存差异仅是旧患者的三个检查动作预先写有 `visual_pool_id`，运行时本来就会按随机病例重新生成这些映射。因此这两类蓝图适合提取为共用模板。

## 推荐目录

```text
data/patients/
├── index.json
├── templates/
│   ├── encounter.json
│   └── preop.json
├── patient_sora/
│   └── patient.json
├── patient_emi/
│   └── patient.json
├── patient_ann/
│   └── patient.json
├── patient_miki/
│   └── patient.json
├── patient_gigi/
│   └── patient.json
└── patient_rie/
    └── patient.json

assets/patients/
└── <patient_id>/
    ├── portraits/
    │   ├── outpatient/
    │   ├── ward/
    │   ├── operating_table/
    │   ├── intraoperative/
    │   └── examination/
    └── cg/
        ├── anesthesia/
        ├── examination/
        └── ward_preparation/
```

原始参考图继续放在 `research/character_references/<patient_id>/`，不由运行时加载。

## 患者索引

`data/patients/index.json` 只列出启用的数据包：

```json
[
  "patient_sora/patient.json",
  "patient_emi/patient.json",
  "patient_ann/patient.json",
  "patient_miki/patient.json",
  "patient_gigi/patient.json",
  "patient_rie/patient.json"
]
```

删除患者时从索引移除一行即可停用；患者目录可以保留以便恢复。新增患者时复制一个目录、修改 `patient.json`、加入索引即可。

## 单个患者包 schema

```json
{
  "schema_version": 1,
  "id": "patient_rie",
  "name": "柳原理惠",
  "age": 26,
  "fallback_case_id": "case_abdomen",
  "voice_style": "gentle",
  "personality": {},
  "traits": {},
  "fear_profile": {},
  "assets": {
    "root": "assets/patients/patient_rie",
    "portraits": {
      "outpatient/neutral": "portraits/outpatient/neutral.png",
      "ward/neutral": "portraits/ward/neutral.png",
      "intraoperative/pain": "portraits/intraoperative/pain.png",
      "splash/general_anesthesia": "cg/anesthesia/general.png"
    }
  },
  "reaction_lines": {},
  "reaction_variants": {},
  "outpatient_lines": {},
  "diagnosis_reactions": [],
  "exclusive_cg_pools": []
}
```

运行时 loader 将 `assets.root` 和相对路径组合成现有的 `visuals.portraits` 结构，因此 UI 和手术系统无需理解新目录结构。

`exclusive_cg_pools` 只保存该患者独有的检查、灌肠、导尿、消毒等 CG。没有专属 CG 时使用空数组并回退到全局通用池。

## 不属于患者包的数据

以下内容继续保持全局定义：

- 疾病、症状、检查结果和鉴别诊断；
- 疾病对应的术式；
- 手术步骤和患者交互规则；
- 通用检查 CG、通用术前准备 CG；
- 下刀动画池；
- 医护人员和人物关系事件。

新游戏仍从 `case_templates` 为每名患者随机分配病例，再由病例的 `surgery_id` 选择术式。患者包中的 `fallback_case_id` 仅供缺少随机病例数据时回退，不会把患者固定到某种疾病。

## 共用模板生成

loader 读取一名患者后，应从两个模板生成现有系统需要的定义：

- encounter ID：`visit_<患者短 ID>`；
- preop ID：`preop_<患者短 ID>`；
- 所有 speaker、patient_id 和 encounter_id 自动替换；
- 显示名和标题自动由患者资料生成；
- 随机病例继续在 `GameState.rebuild_patient_content()` 中覆盖症状、检查和术式；
- 患者专属门诊口吻、首次手术反应、病房和术中对白分别使用 `outpatient_lines`、`diagnosis_reactions`、`reaction_lines` 和 `reaction_variants`，全部保存在同一个 `patient.json`。

这样不会再复制约 60 KB 的 encounter/preop 内容来增加一名患者。

## 迁移顺序

### 第一阶段：数据包 loader

1. 让 manifest 指向 `patients/index.json`；
2. loader 读取并合并多个患者包；
3. 从共用模板生成 encounter 和 preop 集合；
4. 合并患者专属 CG 池与全局通用 CG 池；
5. 保持输出给现有系统的集合结构不变。

完成后先运行全套门诊、术前、随机病例和手术测试，确认行为完全一致。

### 第二阶段：迁移 6 名现有患者

逐名迁移资料，不同时修改对白或图片。每迁移一人都检查：

- 随机疾病和术式仍正确绑定；
- 门诊、收住院、术前与手术可完整进行；
- 17 个图片槽位全部可加载；
- 专属 CG 优先于通用 CG；
- 患者队列和防连续重复逻辑正常。

### 第三阶段：统一美术目录

数据行为稳定后，再把历史 `portrait_pack_v*` 等路径移动到 `assets/patients/<patient_id>/`。这一阶段可以和裸体立绘规格统一一起进行，避免同一批图片移动两次。

### 第四阶段：删除旧重复数据

确认新 loader 和所有患者包稳定后，删除旧的：

- `patients/patients.json`；
- 按患者复制的 `encounters/encounters.json`；
- 按患者复制的 `preop/preop.json`；
- 已迁移的患者专属 CG 池条目；
- 无运行时引用的历史图片目录。

## 验收标准

- 新增患者无需修改 `encounters.json` 或 `preop.json`；
- 停用患者只需移出 `patients/index.json`；
- 任何患者专属运行数据都能从该患者目录或资源目录找到；
- 通用医疗内容没有被复制进患者包；
- 现有 6 名患者在同一随机种子下得到与迁移前相同的疾病分配；
- 数据验证器能报告缺少的图片槽位、对白键、CG 文件和重复 ID；
- 游戏系统继续接收原有 `patients`、`encounters`、`preops` 和 CG pool 集合，不需要大范围重写 UI。
