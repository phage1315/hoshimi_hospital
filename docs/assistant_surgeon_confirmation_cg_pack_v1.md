# 助手医岗位确认 CG 包 v1

本包收录手术团队的 SFW 助手医岗位奖励 CG。画面采用统一的现代手术室色温、细致赛璐璐上色和视觉小说事件 CG 构图，同时保留每名角色的脸型、眼睛、发色与既有无菌服设计。

| 人物 | 文件 | 表现方向 |
| --- | --- | --- |
| 神宮寺成美 | `assets/events/staff_surgery_v1/doc_aoi/assistant_confirmation.png` | 冷静、温和、带教学感的助手确认 |
| 深山佳織 | `assets/events/staff_surgery_v1/doc_rei/assistant_confirmation.png` | 果断、敏捷、进入术野前的动态确认 |
| 御堂江美子 | `assets/events/staff_surgery_v1/doc_emiko/assistant_confirmation.png` | 权威、克制、外科医长接受助手位 |
| 飯村真奈美 | `assets/events/staff_surgery_v1/pharmacist_manami/assistant_confirmation.png` | 努力镇定却明显慌乱的轻喜剧确认 |
| 南条小夜香 | `assets/events/staff_surgery_v1/doc_sayaka/assistant_confirmation.png` | 用户提供；在术野旁专注接取器械 |
| 藤崎詩織 | `assets/events/staff_surgery_v1/doc_shiori/assistant_confirmation.png` | 国民女神般端庄，在助手位谨慎准备注射器，略带初次上台的紧张 |
| 水城阿库娅 | `assets/events/staff_surgery_v1/doc_aqua/assistant_confirmation.png` | 头发完整收进手术帽，以兴奋而专业的目光检查宫腔镜并进入助手位 |

运行时已经接入统一岗位奖励系统：第一次成功选择该角色担任助手医时播放一次，随后永久解锁到事件鉴赏；以后再编入同一岗位不会重复打断术前流程。解锁 ID 保存在对应关系状态的 `unlocked_benefits` 中，沿用现有存档结构。

后续素材分工采用同一原则：SFW 岗位 CG 与流程 splash 使用 ImageGen 统一制作；NSFW CG 由用户提供，项目侧负责规格整理、命名、登记、触发和鉴赏接入。

生成依据、参考图、哈希与未来触发约定见 `research/imports/assistant_surgeon_confirmation_cgs_2026-09-27.json`。
