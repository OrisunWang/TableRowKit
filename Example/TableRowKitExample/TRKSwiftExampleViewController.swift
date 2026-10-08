import UIKit
import TableRowKit

/// Exercises the public Swift names while keeping the Objective-C example as the launched screen.
final class TRKSwiftExampleViewController: UIViewController, UITableViewDelegate {
    /// Retains the row tree because UITableView keeps its data source weakly.
    private let tableSource = TRKTableDataSource()

    /// Builds the same table connection a Swift application would use.
    override func loadView() {
        let table = TRKTableView(frame: .zero, style: .plain)
        let section = TRKTableSection()
        let row = TRKSwiftExampleRow()
        row.title = "Swift row"
        row.selectionHandler = { tableView, indexPath in
            tableView.deselectRow(at: indexPath, animated: true)
        }
        section.add(row)
        tableSource.add(section)
        table.dataSource = tableSource
        table.delegate = self
        view = table
    }
}

/// Supplies row content under an explicit Objective-C runtime name for default cell lookup.
@objc(TRKSwiftExampleRow)
private final class TRKSwiftExampleRow: TRKTableRow {
    /// Stores the label rendered by configure(_:at:); loadView assigns it before display.
    var title = ""

    /// Lets UIKit calculate height from the multiline label and its layout.
    override var usesAutomaticHeight: Bool { true }

    /// Applies the current title each time the table requests the row's cell.
    override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.textLabel?.text = title
    }

    // Optional: override default class-name lookup when cell creation needs customization.
    // override func makeCell() -> UITableViewCell {
    //     TRKSwiftExampleRowCell(style: .default, reuseIdentifier: reuseIdentifier)
    // }
}

/// Matches TRKSwiftExampleRow + Cell in the Objective-C runtime.
@objc(TRKSwiftExampleRowCell)
private final class TRKSwiftExampleRowCell: TRKTableViewCell {
    /// Applies static label setup when the base cell finishes creation.
    override func cellDidCreate() {
        super.cellDidCreate()
        textLabel?.numberOfLines = 0
    }
}
