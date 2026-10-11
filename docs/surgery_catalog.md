# 开放式躯干术式目录

## 当前病例池清单（2026-10-11）

以 `data/surgeries/surgeries.json`、`data/cases/surgery_case_templates.json` 与 `data/cases/advanced_referral_cases.json` 为准：普通池 31 项，均为 `ready`；高级转诊目前仅注册 1 项固定教学术式，也是 `ready`。现有数据没有 `status: placeholder` 的术式记录。

普通池可以包含高难术式。设计稿 `HOSHIMI_SURGERY_UNLOCK_CASE_POOLS_AND_ADVANCED_REFERRAL_SYSTEM_V0_1.md` 明确把全胃切除、肺叶切除、肝叶切除、肾切除以及复杂直肠/主动脉瘤等放在普通池的低频段；技术难度档不能代替病例池分类。

以下为无软上限衰减、无质量加成、无处置惩罚时的基础声望。按难度 32→95 映射到 +2→+15 并四舍五入；普通池单台在质量加成后仍封顶 +15。

| 普通池术式 | 难度 | 基础声望 |
| --- | ---: | ---: |
| 开腹阑尾切除 | 32 | +2 |
| 腹股沟疝修补 | 35 | +3 |
| 乳房肿瘤切除 | 38 | +3 |
| 开腹胆囊切除 | 42 | +4 |
| 腹壁疝修补 | 45 | +5 |
| 开腹卵巢囊肿切除 | 48 | +5 |
| 开腹子宫肌瘤剔除 | 55 | +7 |
| 开腹脾切除 | 58 | +7 |
| 全乳房切除 | 58 | +7 |
| 开腹部分胃切除 | 62 | +8 |
| 开腹子宫全切除 | 68 | +9 |
| 开腹右半结肠切除 | 68 | +9 |
| 开腹乙状结肠切除 | 70 | +10 |
| 经阴道子宫全切除 | 70 | +10 |
| 开腹肾切除 | 72 | +10 |
| 开腹左半结肠切除 | 72 | +10 |
| 开腹肾上腺切除 | 74 | +11 |
| 开腹胰体尾切除 | 76 | +11 |
| 开腹全胃切除 | 78 | +11 |
| 开胸肺叶切除 | 78 | +11 |
| 开腹部分肾切除 | 80 | +12 |
| 大开腹探查 | 82 | +12 |
| 开腹低位直肠前切除 | 82 | +12 |
| 开腹直肠切除（含肛门） | 84 | +13 |
| 开腹膀胱全切除 | 87 | +13 |
| 开胸全肺切除 | 88 | +14 |
| 开腹肝叶切除 | 90 | +14 |
| 开胸心脏搭桥 | 92 | +14 |
| 开腹主动脉瘤修补 | 93 | +15 |
| 开胸食管切除 | 94 | +15 |
| 开腹胰十二指肠切除 | 95 | +15 |

### 高级转诊及规划占位

| 术式 | 当前状态 |
| --- | --- |
| 开胸人工心脏系统置换 | `ready`；千束《本人就在这里》三日固定教学已实装。教学事件固定奖励 +30，独立于普通池公式。 |
| 开腹复杂腹膜后肿瘤切除 | 设计稿示例，未注册运行时术式/病例；规划占位。 |
| 开胸纵隔肿瘤切除 | 设计稿示例，未注册运行时术式/病例；规划占位。 |
| 开腹巨大盆腔肿瘤切除 | 设计稿示例，未注册运行时术式/病例；规划占位。 |
| 开腹复杂肝胆联合切除 | 设计稿示例，未注册运行时术式/病例；规划占位。 |
| 开腹肾癌大血管切除 | 设计稿示例，未注册运行时术式/病例；规划占位。 |

后五项来自该设计稿第 12 节的“例如未来可以设计”，不能当成已经存在的 `status: placeholder` 记录。此次仅调整普通池声望并核对目录，不创建新术式或撤销已完成的千束教学。Master/Legendary 为独立内容，不并入这份高级转诊规划清单。

## 原始目录记录（历史）

本轮在原有 5 种基础上新增 20 种，合计 25 种。新增项目限于胸部、腹部、乳房和盆腔的开放式手术，排除脑部、四肢及腹腔镜项目。小时数是游戏排班估值，统一取整到 30 分钟，不用于现实医疗判断。

| 新增术式 | 游戏耗时 |
| --- | ---: |
| 开放式腹股沟疝修补术 | 1小时30分钟 |
| 开腹胆囊切除术、开腹脾切除术、开腹卵巢囊肿切除术、全乳房切除术、开放式肾切除术 | 各2小时 |
| 开放式腹壁疝修补术、开腹子宫肌瘤剔除术 | 各2小时30分钟 |
| 开腹远端胃切除术、开腹右半结肠切除术、开腹乙状结肠切除术、开胸肺叶切除术 | 各3小时 |
| 开腹全胃切除术、开胸全肺切除术、开放式腹主动脉瘤修复术 | 各4小时 |
| 开放式腹会阴联合直肠切除术、开腹肝叶切除术、开放式根治性膀胱切除术 | 各5小时 |
| 开放式胰十二指肠切除术、开放式食管切除术 | 各6小时 |

用于确认术式及开放入路的主要公开资料：

- [American College of Surgeons：Colectomy](https://www.facs.org/for-patients/the-day-of-your-surgery/colectomy/) 与 [Ventral Hernia Repair](https://www.facs.org/for-patients/the-day-of-your-surgery/ventral-hernia-repair/)
- [NHS：Open Abdominal Procedures](https://www.kingstonandrichmond.nhs.uk/patients-and-families/patient-leaflets/open-abdominal-procedures-after-care/submit/37072) 与 [Ovarian Cyst Treatment](https://www.nhs.uk/conditions/ovarian-cyst/treatment/)
- [Johns Hopkins Medicine：Methods of Surgery](https://www.hopkinsmedicine.org/health/treatment-tests-and-therapies/methods-of-surgery) 与 [Whipple Procedure](https://www.hopkinsmedicine.org/health/conditions-and-diseases/pancreatic-cancer/whipple-procedure)
- [NCI：Gastrectomy](https://www.cancer.gov/types/stomach/hp/stomach-treatment-pdq) 与 [Mastectomy](https://www.cancer.gov/types/breast/treatment/surgery/mastectomy)
- [MedlinePlus：Open Splenectomy](https://www.medlineplus.gov/ency/article/002944.htm)
- [NHS：Open Nephrectomy](https://www.hey.nhs.uk/patient-leaflet/open-nephrectomy/) 与 [Open AAA Repair](https://www.gloshospitals.nhs.uk/your-visit/patient-information-leaflets/open-repair-abdominal-aortic-aneurysm-aaa-ghpi0205/)

当前团队岗位仍使用原型的统一四岗位模板。复杂的胸外、血管、泌尿及胰胆手术以后需要各自的专业资格、团队人数与病例限制，不能沿用本目录的简化成功判定作为最终设计。

## 体位数据分类

术式数据采用游戏化的二分体位，并直接对应 `standard_torso` 与 `lithotomy` 两套展示组。

| 临床主位 | 当前术式 |
| --- | --- |
| 截石位 | 子宫切除术、开腹卵巢囊肿切除术、开腹子宫肌瘤剔除术、开放式腹会阴联合直肠切除术、开放式根治性膀胱切除术 |
| 仰卧位 | 其余20项术式，包括开胸肺手术、食管手术与开放式肾切除术 |

为保持医疗题材成人游戏的画面语言一致，现有三项妇科盆腔术式统一使用截石位。子宫切除术额外记录经阴道辅助和子宫操纵器条件；卵巢囊肿切除与腹式子宫肌瘤剔除仍保留腹部入路标签，但采用同一截石位展示。腹会阴联合直肠切除术因会阴入路使用改良截石位。现有患者均为女性，开放式根治性膀胱切除术也按可提供会阴／阴道通路的低位背侧截石位记录。其余术式统一按仰卧位表现，不再扩展侧卧或分阶段换位画面。
