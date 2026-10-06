# 人物岗位 CG 必需资源清单

新增人物在进入可玩状态、能够被编入手术团队以前，必须完成并登记对应岗位 CG。角色资料、立绘和事件完成但岗位 CG 缺失时，人物资源仍视为未完成。

## 女性医生

- 必须提供 `assistant_surgeon` 首次担当 CG。
- 路径：`assets/events/staff_surgery_v1/<staff_id>/assistant_confirmation.png`
- 必须在 `data/events/staff_role_cg_rewards.json` 登记。
- 构图要体现助手医的实际工作，可以协助暴露术野、吸引、缝合、核对用药或完成主刀要求的操作；避免统一画成器械护士递器械。

## 女性护士

每名可进入手术相关岗位的护士必须同时提供三张 CG：

1. `scrub_nurse`：器械护士首次担当，完整无菌手术衣、口罩、帽子和手套，在无菌台内工作。
2. `circulating_nurse`：巡回护士首次担当，在术野外处理监护、记录、物资和协调。
3. `ward_nurse`：病房术前介护首次担当，负责病床、衣物、转运和术前用品准备。

统一路径：

- `assets/events/staff_surgery_v1/<staff_id>/scrub_nurse_confirmation.png`
- `assets/events/staff_surgery_v1/<staff_id>/circulating_nurse_confirmation.png`
- `assets/events/staff_surgery_v1/<staff_id>/preop_care_confirmation.png`

三张图都必须在 `data/events/staff_role_cg_rewards.json` 登记后，角色资源才算完整。CG 应表现岗位差异，不能只更换标题复用同一构图。

## 验收

- 人物五官、发色、体型与正式立绘一致。
- 手术帽必须正确收纳长发；无菌岗位服装符合岗位范围。
- 图片文件存在，岗位与人物资格一致，员工／岗位组合不重复。
- 首次担当时能够播放，之后收入事件与 CG 鉴赏，重复担当不再次打断流程。
- 运行 `python3 tools/validate_data.py` 和岗位奖励测试确认数据、路径与解锁流程。

校验器会拒绝缺少上述资源的新人物。现有历史欠账仅可列在校验器的 `legacy_role_cg_backlog` 中，不能把新人物加入该名单来绕过验收；历史名单中的角色补齐素材后应立即移出。
