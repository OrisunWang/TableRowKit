# TableRowKit

TableRowKit 是一个用于 UIKit 表格页面的 iOS 库，通过 DataSource → Section → Row 模型组织内容。每种 Row 可以独立管理数据、创建和配置 Cell、处理点击事件，适合设置页、信息列表和包含多种 Cell 的表格页面。

- 支持 iOS 15 及以上版本，支持 Swift 和 Objective-C。
- 按顺序管理 Section 和 Row，支持插入、移除与移动。
- 支持自动高度、固定行高和自定义 Section Header/Footer。
- Row 的选中、显示回调可以与业务侧 `UITableViewDelegate` 同时工作。
- 使用 UIKit，无第三方运行时依赖。

## 安装

在 App 的 `Podfile` 中添加：

```ruby
platform :ios, '15.0'

target 'YourApp' do
  pod 'TableRowKit', '~> 0.1.1', :modular_headers => true
end
```

执行：

```sh
pod install --repo-update
```

打开生成的 `.xcworkspace`。Swift 使用 `import TableRowKit`，Objective-C 使用 `#import <TableRowKit/TableRowKit.h>`。上面的 `modular_headers` 配置用于让 Swift 导入库模块。

## 接入

创建 `TRKTableView` 和 `TRKTableDataSource`，将 Row 加入 Section，再将 Section 加入 DataSource。控制器需要强持有 DataSource，并设置非空的 `tableView.delegate`，以启用库提供的高度、选中和显示回调。所有模型与表格操作都在主线程执行。

### Swift / UIKit

下面是一个可放入项目的最小页面：显示一行多行文本，点击后切换业务状态并刷新。

```swift
import UIKit
import TableRowKit

/// 库直接适配 UITableView，因此接入页面使用 UIKit。
final class TRKExampleViewController: UIViewController, UITableViewDelegate {
    /// 控制器持有模型；loadView 填充它，避免表格的弱引用导致模型释放。
    private let tableSource = TRKTableDataSource()

    /// 组装行树，并连接表格的数据源与事件代理。
    override func loadView() {
        let table = TRKTableView(frame: .zero, style: .plain)
        let section = TRKTableSection()
        let row = TRKExampleTitleRow()

        // Row 持有回调；弱捕获避免 Row 与闭包循环引用。
        row.selectionHandler = { [weak row] tableView, _ in
            guard let row else { return }
            // 系统选中状态已由库取消；此处更新独立的业务状态。
            row.isSelected.toggle()
            // 模型变更不会自动刷新表格。
            tableView.reloadData()
        }
        section.add(row)
        tableSource.add(section)
        table.dataSource = tableSource
        // 即使不实现额外的 delegate 方法，也需要设置非空 delegate。
        table.delegate = self
        view = table
    }
}

/// 保存行的业务状态；默认使用自动高度。
final class TRKExampleTitleRow: TRKTableRow {
    /// 点击回调更新状态；configure 读取它并更新显示文本。
    var isSelected = false

    /// 每次显示或刷新时应用当前数据，避免复用 Cell 残留旧内容。
    override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        super.configure(cell, at: indexPath)
        cell.textLabel?.text = "点击此行切换状态。当前状态：\(isSelected ? "已选中" : "未选中")。"
    }
}

/// 同模块内按 Row 类名追加 Cell 命名，供默认 makeCell() 查找。
final class TRKExampleTitleRowCell: TRKTableViewCell {
    /// 创建时设置静态外观；具体文本由 Row 在每次配置时提供。
    override func cellDidCreate() {
        super.cellDidCreate()
        textLabel?.numberOfLines = 0
    }
}
```

### Objective-C

使用相同的模型结构。下面的 Row 显式创建系统 Cell，无需额外定义匹配类名的 Cell：

```objc
#import <TableRowKit/TableRowKit.h>

/// 提供一行固定文案，展示 Objective-C 的创建与配置入口。
@interface GreetingRow : TRKTableRow
@end

@implementation GreetingRow
/// 显式创建 Cell，保留 Row 提供的复用标识。
- (UITableViewCell *)makeCell {
    return [[TRKTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:self.reuseIdentifier];
}
/// 每次请求显示时写入文案，并启用多行文本以支持自动高度。
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [super configureCell:cell atIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = @"Hello, TableRowKit";
}
@end

/// 宿主控制器持有数据源，并作为库内代理的业务 delegate。
@interface GreetingViewController : UIViewController <UITableViewDelegate>
/// loadView 创建并保存模型，表格通过弱引用读取它。
@property (nonatomic, strong) TRKTableDataSource *tableSource;
@end

@implementation GreetingViewController
/// 组装模型并连接表格；非空 delegate 启用高度与事件回调。
- (void)loadView {
    TRKTableView *table = [[TRKTableView alloc] initWithFrame:CGRectZero
                                                      style:UITableViewStylePlain];
    self.tableSource = [TRKTableDataSource new];
    TRKTableSection *section = [TRKTableSection new];
    [section addRow:[GreetingRow new]];
    [self.tableSource addSection:section];
    table.dataSource = self.tableSource;
    table.delegate = self;
    self.view = table;
}
@end
```

## 使用说明

### Cell 创建与复用

Row 的 `makeCell()` 默认按“Row 的 Objective-C 运行时类名 + Cell”查找 Cell 类型。例如，上面同模块内的 `TRKExampleTitleRow` 对应 `TRKExampleTitleRowCell`。找不到匹配的 `UITableViewCell` 子类时会抛出异常。

Swift 私有类型的运行时名称经过编译器编码，可使用匹配的 `@objc` 名称，或覆写 `makeCell()` 显式创建 Cell：

```swift
// 在 TRKTableRow 子类中显式创建 Cell，不依赖运行时类名匹配。
/// 使用当前 Row 的复用标识创建自定义 Cell。
override func makeCell() -> UITableViewCell {
    TRKExampleMessageRowCell(style: .default, reuseIdentifier: reuseIdentifier)
}
```

`TRKExampleMessageRowCell` 的完整实现见 [Swift Example](Example/TableRowKitExample/TRKSwiftExampleViewController.swift)。库会先按 `reuseIdentifier` 尝试复用，再调用 `makeCell()`；默认标识是 Row 类名。自定义复用标识时，使用同一标识的 Row 应创建兼容的 Cell 类型。

在 `configure(_:at:)` / `configureCell:atIndexPath:` 中更新每次显示所需的数据；在 `TRKTableViewCell.cellDidCreate()` 中设置静态子视图和布局。该创建入口在代码创建后或 nib 加载完成后调用。

### 自动高度与固定高度

Row 默认使用 `UITableView.automaticDimension`，估算高度为 44 pt。自定义 Cell 使用 Auto Layout 时，需要提供完整的垂直约束，让 UIKit 能计算高度。

固定高度需要同时设置 `fixedHeight` 并覆写 `usesAutomaticHeight`：

```swift
/// 在 Row 子类中设置固定行高。
override init() {
    super.init()
    fixedHeight = 44
}

/// 关闭自动高度后，库内代理才会读取 fixedHeight。
override var usesAutomaticHeight: Bool { false }
```

Objective-C 对应覆写 `- (BOOL)usesAutomaticHeight` 并返回 `NO`。仅修改 `fixedHeight` 不会关闭自动高度。

### 点击与业务 delegate

通过 `selectionHandler` 处理 Row 点击。库会先取消系统选中状态，再调用 Row 回调，最后通知业务 delegate；无需在回调中重复调用 `deselectRow`。示例中的 `isSelected` 是业务状态。

Row / Section 的显示回调同样先执行库内逻辑，再通知业务 delegate。业务 delegate 实现的行高、估算高度、Header/Footer 高度与视图方法优先于 Row / Section 配置，其余 delegate 方法会转发给业务对象。

`UITableView` 和库内代理弱引用 DataSource / 业务 delegate，调用方需要持有这些对象。设置 `delegate = nil` 会移除代理。

### 更新内容与调整行顺序

修改 Row 的数据后，调用 `reloadData()` 或 `reloadRows(at:with:)` 刷新。增删、移动 Row / Section 后，也需要调用相应的 UIKit 更新方法；库不会自动计算差异或同步界面。批量更新时，模型变化与表格的插入、删除、移动操作必须一致。

常用模型接口如下：

| 操作 | Swift | Objective-C |
| --- | --- | --- |
| 添加 Section | `source.add(section)` | `[source addSection:section]` |
| 添加 Row | `section.add(row)` | `[section addRow:row]` |
| 批量添加 Row | `section.add(contentsOf: rows)` | `[section addRowsFromArray:rows]` |
| 按位置插入或移动 Row | `section.insertChild(row, at: index)` | `[section insertChild:row atIndex:index]` |
| 移除 Row | `row.removeFromParent()` | `[row removeFromParent]` |
| 查询 Row | `source.row(at: indexPath)` | `[source rowAtIndexPath:indexPath]` |

同一个节点只能属于一个父节点；加入新父节点时会先从原父节点移除。查询越界返回 `nil`，越界插入不改变模型。`sections`、`rows` 是有序快照，修改快照不会改变行树。

### Section Header / Footer

通过 `headerHeight`、`footerHeight` 设置固定高度；默认均为 `CGFLOAT_MIN`。设置 `usesAutomaticHeaderFooterHeight = true` 可启用自动高度，并在 `TRKTableSection` 子类中覆写 `viewForHeaderInTableView:section:` / `viewForFooterInTableView:section:` 提供视图。自适应视图需要可计算高度的布局约束。

`TRKTableView` 在 iOS 15 及以上将 `sectionHeaderTopPadding` 默认设为 0。

## Example

仓库包含 Swift + UIKit 示例，使用本地源码接入，需要 Xcode、[XcodeGen](https://github.com/yonaskolb/XcodeGen) 和 CocoaPods。

```sh
git clone https://github.com/OrisunWang/TableRowKit.git
cd TableRowKit/Example
xcodegen generate
pod install
open TableRowKitExample.xcworkspace
```

选择 `TableRowKitExample` scheme，在 iOS 模拟器或设备上运行：

1. 标题行展示多行文本，使用自动高度。
2. 点击标题行，业务选中状态切换，文本随刷新更新。
3. 消息行并排显示标题与消息，使用 44 pt 固定高度，并显式创建自定义 Cell。
4. 旋转设备或调整窗口宽度，消息行按 Cell 的实际宽度重新布局。

完整代码见 [Swift Example](Example/TableRowKitExample/TRKSwiftExampleViewController.swift)。库负责表格模型、Cell 配置和事件分发；网络请求、数据持久化及业务操作由应用自行实现。

## License

MIT License，详见 [LICENSE](LICENSE)。
