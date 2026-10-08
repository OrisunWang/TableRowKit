# TableRowKit

TableRowKit 用 DataSource → Section → Row 模型管理 UIKit 表格。一个 DataSource 按顺序持有 Section，每个 Section 按顺序持有 Row；Row 负责创建和配置 Cell，也可以处理选中事件和其他自定义业务事件。

## 功能

- 有序的 DataSource → Section → Row 模型，支持插入、移除和移动节点。
- 固定高度或自适应高度，以及 Section Header/Footer 配置。
- Row 选中和显示回调可与业务侧 `UITableViewDelegate` 同时工作。

## 安装

在 App 的 `Podfile` 中添加：

```ruby
platform :ios, '15.0'

target 'YourApp' do
  pod 'TableRowKit', :modular_headers => true
end
```

运行 `pod install`，然后打开生成的 `.xcworkspace`。仓库中的 Demo 使用本地 `:path` 引用当前源码；`0.1.1` 尚未发布到 CocoaPods Trunk，发布完成前请通过本地 `:path` 集成当前源码。

> `modular_headers` 让 Swift 代码可以直接 `import TableRowKit`。Objective-C 文件使用 `#import <TableRowKit/TableRowKit.h>`。

## Swift 示例

下面展示默认自动高度、自定义业务选中状态，以及固定高度的双标签行。同一模块内的非私有 Swift Row 与 Cell 可按“Row 运行时类名 + Cell”匹配；私有类型需要用匹配的 `@objc` 名称，或覆写 `makeCell()` 显式创建 Cell。

```swift
import UIKit
import TableRowKit

/// 展示自动高度、固定高度和选中回调；库直接适配 UITableView，因此示例使用 UIKit。
final class TRKExampleViewController: UIViewController, UITableViewDelegate {
    /// 由控制器创建并持有的行树；loadView 填充它，避免 UITableView 的弱引用导致模型释放。
    private let tableSource = TRKTableDataSource()

    /// 创建示例行并连接表格的 DataSource 与 delegate，启用库内的高度和事件代理。
    override func loadView() {
        title = "TableRowKit"
        let table = TRKTableView(frame: .zero, style: .plain)
        let section = TRKTableSection()

        let titleRow = TRKExampleTitleRow()
        // Row 持有回调；弱捕获避免循环引用，模型释放后回调也可安全退出。
        titleRow.selectionHandler = { [weak titleRow] tableView, _ in
            guard let titleRow else { return }
            // proxy 已取消系统选中状态；这里仅切换业务状态。
            titleRow.isSelected.toggle()
            // 模型变更不会自动刷新表格，重新配置 Cell 以显示新的选中状态。
            tableView.reloadData()
        }
        section.add(titleRow)

        let messageRow = TRKExampleMessageRow()
        messageRow.title = "Message Row"
        messageRow.message = "This is a message row."
        section.add(messageRow)

        tableSource.add(section)
        table.dataSource = tableSource
        table.delegate = self
        view = table
    }
}

// MARK: - TRKExampleTitleRow

/// 使用默认自动高度；同模块内的非私有 Row 与 Cell 遵循类名追加 Cell 的查找约定。
final class TRKExampleTitleRow: TRKTableRow {
    /// 保存业务选中状态；控制器的选中回调切换它，configure 读取它来更新标题。
    var isSelected = false

    /// 每次显示或刷新时，将当前业务选中状态写入可复用 Cell。
    override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        super.configure(cell, at: indexPath)
        cell.textLabel?.text = "This is a title row with a long title. The row is \(isSelected ? "selected" : "not selected")."
    }
}

/// 与 TRKExampleTitleRow 匹配的 Cell，使用系统多行标签支持自动高度。
final class TRKExampleTitleRowCell: TRKTableViewCell {
    /// Cell 创建时设置静态外观；每次复用的文本由 Row 配置。
    override func cellDidCreate() {
        super.cellDidCreate()
        textLabel?.numberOfLines = 0
    }
}

// MARK: - TRKExampleMessageRow

/// 展示固定高度、自定义标签和显式创建 Cell 的方式。
final class TRKExampleMessageRow: TRKTableRow {
    /// 保存标题；控制器在加入 Section 前赋值，configure 将它写入左侧标签。
    var title = ""
    /// 保存消息；控制器在加入 Section 前赋值，configure 将它写入右侧标签。
    var message = ""

    /// 明确设置固定行高；usesAutomaticHeight 返回 false 后代理才会使用该值。
    override init() {
        super.init()
        fixedHeight = 44
    }

    /// 显式创建自定义 Cell，展示不依赖运行时类名查找的替代方式。
    override func makeCell() -> UITableViewCell {
        TRKExampleMessageRowCell(style: .default, reuseIdentifier: reuseIdentifier)
    }

    /// 将两段模型文本写入自定义标签；类型不匹配时不配置，避免错误类型访问。
    override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        super.configure(cell, at: indexPath)
        guard let cell = cell as? TRKExampleMessageRowCell else { return }
        cell.titleLabel.text = title
        cell.messageLabel.text = message
    }

    /// 由子类固定返回 false，让 delegate 使用 fixedHeight 而非自动高度。
    override var usesAutomaticHeight: Bool { false }
}

/// 在固定高度行中并排显示标题与消息，按 Cell 的实际宽度布局。
final class TRKExampleMessageRowCell: TRKTableViewCell {
    /// 保存左侧标题标签；cellDidCreate 添加它，Row 更新文本，layoutSubviews 更新位置。
    let titleLabel = UILabel()
    /// 保存右侧消息标签；cellDidCreate 添加它，Row 更新文本，layoutSubviews 更新位置。
    let messageLabel = UILabel()

    /// 只在创建时安装标签，避免复用时重复添加子视图。
    override func cellDidCreate() {
        super.cellDidCreate()
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
    }

    /// 使用 contentView 当前尺寸而非屏幕宽度，支持旋转、分屏及不同容器宽度。
    override func layoutSubviews() {
        super.layoutSubviews()
        // 两侧各留 16 pt，标签间留 8 pt；极窄容器中宽度不小于零。
        let width = max(0, (contentView.bounds.width - 40) / 2)
        titleLabel.frame = CGRect(x: 16, y: 0, width: width, height: contentView.bounds.height)
        messageLabel.frame = CGRect(x: width + 24, y: 0, width: width, height: contentView.bounds.height)
    }
}
```

完整代码见 [Swift 示例](Example/TableRowKitExample/TRKSwiftExampleViewController.swift)。Objective-C 使用相同的模型结构，配置入口为 `configureCell:atIndexPath:`，创建入口为 `makeCell`，添加入口为 `addRow:` 和 `addSection:`；可参照 [Objective-C 测试](Tests/TableRowKitTests.m)。

## 高度与更新

Row 默认使用 `UITableViewAutomaticDimension` 自适应高度，需要确保子视图约束正确。可以通过设置 `fixedHeight` 并覆写只读属性 `usesAutomaticHeight`，返回 `NO` / `false` 来使用固定高度。Section 可用 `headerHeight`、`footerHeight` 和 `usesAutomaticHeaderFooterHeight` 设置高度，并覆写 `viewForHeaderInTableView:section:` 或 `viewForFooterInTableView:section:` 提供 Header/Footer 视图。

代理在执行 Row 选中回调前会取消系统选中状态，业务回调无需重复调用 `deselectRow`。示例的 `isSelected` 是独立的业务状态。

模型变更不会自动刷新表格。请在主线程修改 Row/Section，并按 UIKit 规则调用 `reloadData`、`reloadRows` 或批量更新。设置非空的 `tableView.delegate` 后，TableRowKit 才会安装代理并触发 Row 选中、显示及高度回调；业务 delegate 的高度和 Header/Footer 视图实现优先于库的默认值。

## 开发

示例工程使用 XcodeGen 和 CocoaPods：

```sh
cd Example
xcodegen generate
pod install
open TableRowKitExample.xcworkspace
```

在 Xcode 中选择 `TableRowKitExample` scheme 构建或运行。项目行为与验收标准见 [PROJECT.md](PROJECT.md)。

## 许可

TableRowKit 使用 [MIT License](LICENSE)。
