# TableRowKit 项目说明

## 产品目标与范围

TableRowKit 是一个基于 UIKit 的 iOS 表格模型库。它用 DataSource → Section → Row 的有序树组织表格内容，负责创建和配置 Cell，并将 Row、Section 的回调与业务侧的 `UITableViewDelegate` 组合起来。业务侧可使用 Swift 或 Objective-C。库不负责网络、持久化、业务页面或自动同步模型变更与表格更新。

## 用户流程与模块

1. 创建 `TRKTableDataSource`、`TRKTableSection`、`TRKTableRow` 子类及 `TRKTableView`；Swift 和 Objective-C 均使用带 `TRK` 前缀的公开类型。
2. 将 Row 加入 Section、Section 加入 DataSource，并让控制器强持有 DataSource。
3. 将 DataSource 和业务 delegate 赋给 TableView。设置非空 delegate 后，TableView 安装内部代理，保留库提供的高度、选中和显示回调。
4. 模型内容变化时，在主线程修改模型，并调用合适的 UIKit 表格更新 API。

`TRKNode` 管理父子关系；`TRKTableDataSource` 实现 `UITableViewDataSource`；`TRKTableSection` 管理行和 Header/Footer；`TRKTableRow` 管理 Cell 和选中回调；`TRKTableView` 与内部 delegate 代理分发 UIKit 回调；`TRKTableViewCell` 提供 Cell 创建后的设置入口。

## 模型与业务规则

- 节点至多有一个父节点；移动到新父节点前会先从原父节点移除。禁止节点加入自身或其后代，避免循环。越界插入无效；脱离父节点的索引是 `NSNotFound`。
- DataSource 只接受 Section，Section 只接受 Row。Row 插入、移除和移动时调用对应生命周期方法。`children`、`sections` 和 `rows` 返回有序快照，外部修改快照不会改变模型。
- Row 默认固定高度为 44 pt。子类启用自动高度后，delegate 返回 `UITableViewAutomaticDimension`，并提供默认 44 pt 的估算高度；Cell 高度由 UIKit 计算。库不维护 Cell 测量缓存。
- Row 默认按“Row Objective-C 运行时类名 + Cell”寻找 Cell 类型。Swift 私有类型的名称经过编译器编码，不能直接拼接；示例中的 Swift Row 与 Cell 分别用匹配的 `@objc` 名称注册。若需要自定义初始化方式，可覆写 `makeCell()`。
- Section 默认 Header/Footer 高度为 `CGFLOAT_MIN`，可设置固定高度、启用自动高度或由子类提供视图和高度。
- 外部 delegate 对有返回值的高度与 Header/Footer 视图方法有优先权；选中和显示事件先运行库内逻辑，再通知外部 delegate；其余方法转发给外部 delegate。
- UIKit 和模型树在主线程使用。库不承诺模型跨线程并发读写安全。TableView 和代理对业务对象使用弱引用；业务侧必须持有 DataSource 和 delegate。

## API 与技术约束

- 两种语言中的公开类型都保留 `TRK` 前缀。常用操作在 Objective-C 和 Swift 中分别为 `makeCell` / `makeCell()`、`configureCell:atIndexPath:` / `configure(_:at:)`、`addRow:` / `add(_:)`；两端保持相同动作词。
- 旧的 Objective-C Cell 创建、配置、高度和选中入口保留兼容转发；新代码使用 `makeCell`、`configureCell:atIndexPath:`、`fixedHeight`、`selectionHandler` 和 `usesAutomaticHeight`。
- Swift 通过 CocoaPods modular headers 导入 `TableRowKit` 模块；Objective-C 通过 `<TableRowKit/TableRowKit.h>` 导入。
- 支持 iOS 15 及以上、ARC、UIKit。库直接适配 `UITableView`、其 DataSource/Delegate 和 Cell，因此使用 UIKit；`TRKTableView` 在 iOS 15 及以上将 `sectionHeaderTopPadding` 设为 0。
- 许可证为 MIT，文本见 `LICENSE`。podspec 的 homepage 和 source 指向公开 GitHub 仓库，版本源码对应 `v<version>` 标签。README 以 CocoaPods 公共源中的 `pod 'TableRowKit'` 为安装方式；该方式需要先把 podspec 发布到 CocoaPods Trunk。示例工程继续使用本地 `:path` 集成，以便验证工作区代码。

## 验收标准

- Swift 与 Objective-C 示例代码均可编译并使用相同的 Row/Section/DataSource 行为。
- 节点移动、越界、循环、Row 生命周期、delegate 分发和 Cell 创建行为可由测试或示例验证。
- podspec 可本地校验；示例工程能针对 iOS Simulator SDK 构建。
- README 提供 Swift 优先的安装说明、两种语言的使用示例、主要行为和许可信息。

## 示例工程

`Example/project.yml` 定义 XcodeGen 工程。`Example/Podfile` 通过本地 `:path` 和 modular headers 集成 pod。执行 `cd Example && xcodegen generate && pod install`，然后打开 `TableRowKitExample.xcworkspace`。Objective-C 示例是启动页面；同一 App Target 还包含 Swift 示例控制器，用于验证 Swift 导入与按类名创建 Cell。`Tests/TableRowKitTests.m` 和 `Tests/TableRowKitSwiftTests.swift` 分别验证 Objective-C 行为与 Swift API。
