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
