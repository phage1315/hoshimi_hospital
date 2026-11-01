# 2026-10-30 导出体积只读核查

当前 main/83859092 加已有未提交工作区；未修改导出预设、导入参数或素材，未删除文件、重导出或读取存档正文。

实际检查 `v0.2_20261030/HoshimiHospital.zip`：ZIP 约 3758.7 MB；其中 EXE 原大小 94.4 MB，压缩后32.1 MB；PCK 原大小3802.6 MB，压缩后3726.6 MB。单位均为十进制 MB。

依据 Godot 4.5 官方 PCK 读取实现解析包的 V3 目录（https://github.com/godotengine/godot/blob/4.5/core/io/file_access_pack.cpp），读取13683条文件元数据，再由现有 .import 描述把导入缓存映射回原路径。没有解压/读取存档内容，没有打开图像做内容分析。

## 包内主要构成

| 来源 | 实际包内有效载荷 MB |
|---|---:|
| docs/qa | 1650.38 |
| assets/characters | 877.37 |
| research 全部 | 689.82 |
| assets/events | 361.20 |
| assets/candidates | 67.33 |
| assets/backgrounds | 44.01 |
| assets/surgeries | 40.56 |
| assets/examinations | 17.59 |
| data | 17.00 |

完整分组见 pack_sizes.json。QA导入图像3080张（3077 PNG、3 JPG），另有其导入描述、JSON及少量工具资源。大头包括后20组测试350.2 MB、前20行测试250.5 MB、显示修复测试232.1 MB、剩余事件测试155.4 MB。

还确认包含 tools、test_saves、local_save_backups、recovered_saves。后3者合计约1.12 MB，不是体积主因，但发布包不应无意带入开发存档。

## 原因及增长证据

三个导出预设均是 `export_filter="all_resources"`，include_filter 与 exclude_filter 为空。多数 docs/qa、research 目录没有 .gdignore，所以已导入的截图和参考素材进入运行包。仅有少数子目录设置 .gdignore。Git 的忽略配置没有阻止实际包中出现 test_saves 等内容。

与2026-10-23之前最近提交86a3da07的路径清单相比，当前包新增路径对应的载荷：docs约1430.6 MB、assets约793.1 MB、research约305.4 MB。此处只比较Git中路径是否存在；不是旧导出包的二进制差分，不能覆盖当时未提交素材或同路径内容更改。正式素材确有增长，但测试截图是主要可避免增量。

工程 .godot/imported 约3.78 GB属于整个工程的导入缓存；包内统计已按来源映射，不能把缓存目录与实际导出PCK相加，也不能推断所有原PNG又重复装入一次。抽查立绘是无损导入、无mipmap；现有证据不支持先通过有损压缩或缩图解决。

## 建议（未执行）

1. 对开发目录配置导出排除：docs、research、tools、测试/恢复/备份存档、历史构建目录。候选素材 assets/candidates 在核对运行时引用后排除。
2. 对不参与运行的开发资料目录添加 .gdignore，防止以后继续产生导入缓存；不删除原始资料或QA截图。
3. 保留正式 assets 与 data。数据驱动路径需检查，不能直接改成“仅导出选中场景依赖”而漏掉动态加载资源。
4. 重导出到新位置后审计包目录，并以导出包启动验证中英文、事件、CG及诊疗资源。

上述开发目录与候选素材合计约2412.85 MB，占包载荷约63.5%。若这些均经引用核查后排除，其余载荷约1387.99 MB；加引擎后仍为1GB多量级。此为目录减法估算，不是已重新构建的成品大小。尚未找到上周实际1GB多导出包，不能承诺与旧包完全相同。

## 实际重导出复验

用户反馈新包仍为3.7GB后，发现磁盘三个exclude_filter和打开的Godot导出窗口均为空。此前修改未保留，可能被编辑器内存旧配置回写；没有证据确定具体回写动作。本次直接通过Godot导出窗口设置三平台 `docs/qa/*,research/*`，并核对磁盘文件一致。

独立生成 `v0.2_20261030/HoshimiHospital_filtered.zip`，原包保留。旧包3,771,023,428字节，新包1,463,164,181字节（约1.46GB），减少约61.2%。导出进程退出0；新PCK目录5565条，映射后docs/qa和research条目均为0。未执行Windows二进制，不宣称Windows运行时已验收。其他开发目录未在本次授权排除范围内。详细结果见filtered_export_verification.json。
