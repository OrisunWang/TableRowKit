# TableRowKit

TableRowKit 用 Row 和 Section 模型管理 UIKit 表格。一个 DataSource 按顺序持有 Section，每个 Section 按顺序持有 Row；Row 负责创建和配置 Cell，也可以处理选中事件。业务代码可用 Swift 或 Objective-C 编写。

## 功能

- 有序的 DataSource → Section → Row 模型，支持插入、移除和移动节点。
- 固定高度、UIKit 自动高度，以及 Section Header/Footer 配置。
- Row 选中和显示回调可与业务侧 `UITableViewDelegate` 同时工作。
- 支持 CocoaPods 集成；最低系统版本为 iOS 15。

## 安装

在 App 的 `Podfile` 中添加：

```ruby
platform :ios, '15.0'

target 'YourApp' do
  pod 'TableRowKit', :modular_headers => true
end
```

运行 `pod install`，打开生成的 `.xcworkspace`。`modular_headers` 让 Swift 代码可以直接 `import TableRowKit`。Objective-C 文件使用 `#import <TableRowKit/TableRowKit.h>`。此安装方式需要先将 `TableRowKit` 发布到 CocoaPods 公共源；仓库中的 Demo 仍通过本地 `:path` 引用当前源码。

## Swift 示例

Swift 导入的公开类型保留 `TRK` 前缀，避免与其他库的类型重名。默认按 Row 的 Objective-C 运行时类名追加 `Cell` 查找 Cell 子类。Swift 类型可能使用经过编码的运行时名称，因此用 `@objc` 显式指定一对相应的名称：

```swift
import UIKit
import TableRowKit

@objc(TRKMessageRow)
final class MessageRow: TRKTableRow {
    // 控制器设置内容，configure(_:at:) 在每次配置 Cell 时读取。
    var message = ""

    // 让 UIKit 根据多行文本与布局计算行高。
    override var usesAutomaticHeight: Bool { true }

    // 使用当前模型内容配置可复用 Cell。
    override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.textLabel?.text = message
    }

    // 可选：需要自行创建 Cell 时，取消注释并覆写默认的类名查找。
    // override func makeCell() -> UITableViewCell {
    //     MessageRowCell(style: .default, reuseIdentifier: reuseIdentifier)
    // }
}

// 默认命名约定：TRKMessageRow + Cell；Cell 创建后设置多行标签。
@objc(TRKMessageRowCell)
final class MessageRowCell: TRKTableViewCell {
    // 基类在创建 Cell 时调用此入口；复用时由 Row 更新文本。
    override func cellDidCreate() {
        super.cellDidCreate()
        textLabel?.numberOfLines = 0
    }
}

final class MessagesViewController: UIViewController, UITableViewDelegate {
    // UITableView 对 dataSource 使用弱引用，因此由控制器持有模型。
    private let tableSource = TRKTableDataSource()

    // 建立模型和表格，并让控制器保留 DataSource 与 delegate。
    override func loadView() {
        let table = TRKTableView(frame: .zero, style: .plain)
        let section = TRKTableSection()
        let row = MessageRow()
        row.message = "Hello, TableRowKit"
        row.selectionHandler = { _, _ in print("Selected") }

        section.add(row)
        tableSource.add(section)
        table.dataSource = tableSource
        table.delegate = self
        view = table
    }
}
```

[可编译的 Swift 示例](Example/TableRowKitExample/TRKSwiftExampleViewController.swift)也包含在示例工程中。若不使用匹配的 Objective-C 运行时名称，或需要其他初始化方式，可按注释覆写 `makeCell()`。

## Objective-C 示例

Objective-C API 使用相同的 `TRK` 前缀和动作词。下面同样使用默认类名约定：

```objective-c
#import <TableRowKit/TableRowKit.h>

@interface MessageRow : TRKTableRow
/// 控制器写入文本；configureCell:atIndexPath: 每次配置 Cell 时读取。
@property (nonatomic, copy) NSString *message;
@end

@implementation MessageRow
/// 将 Row 的当前内容写入可复用 Cell。
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = self.message;
}
// 可选：需要自行创建 Cell 时，取消注释并覆写默认的类名查找。
// - (UITableViewCell *)makeCell {
//     return [[MessageRowCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                reuseIdentifier:self.reuseIdentifier];
// }
@end

/// 默认命名约定：MessageRow + Cell。
@interface MessageRowCell : TRKTableViewCell
@end

@implementation MessageRowCell
@end

@interface MessagesViewController : UIViewController <UITableViewDelegate>
/// 强持有模型；UITableView 的 dataSource 引用是弱引用。
@property (nonatomic, strong) TRKTableDataSource *tableSource;
@end

@implementation MessagesViewController
/// 建立模型、表格和选中回调。
- (void)loadView {
    TRKTableDataSource *dataSource = [TRKTableDataSource new];
    TRKTableSection *section = [TRKTableSection new];
    MessageRow *row = [MessageRow new];
    row.message = @"Hello, TableRowKit";
    row.selectionHandler = ^(UITableView *tableView, NSIndexPath *indexPath) {
        NSLog(@"Selected");
    };
    [section addRow:row];
    [dataSource addSection:section];

    TRKTableView *tableView = [[TRKTableView alloc] initWithFrame:CGRectZero
                                                             style:UITableViewStylePlain];
    self.tableSource = dataSource;
    tableView.dataSource = dataSource;
    tableView.delegate = self;
    self.view = tableView;
}
@end
```

Objective-C Row 和 Cell 也可按示例省略 `makeCell`；需要自定义创建过程时使用注释中的覆写方式。

## 高度与更新

Row 默认使用 44 pt 固定高度，两种语言都通过 `fixedHeight` 设置。需要根据内容自适应时，两种语言都覆写 `usesAutomaticHeight` 并返回 `YES` / `true`；布局交给 UIKit，`estimatedHeight` 默认返回 44 pt。Section 可用 `headerHeight`、`footerHeight` 和 `usesAutomaticHeaderFooterHeight` 配置 Header/Footer。

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
