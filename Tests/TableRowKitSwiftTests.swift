import XCTest
import TableRowKit

/// Verifies that a Swift client can assemble and inspect the public row tree.
final class TableRowKitSwiftTests: XCTestCase {
    /// Exercises imported names and the same model ownership used by Objective-C clients.
    func testSwiftModelAPI() {
        let source = TRKTableDataSource()
        let section = TRKTableSection()
        let row = SwiftTestRow()
        row.fixedHeight = 52
        section.add(row)
        source.add(section)

        XCTAssertEqual(source.sections.count, 1)
        XCTAssertEqual(section.rows.count, 1)
        XCTAssertEqual(source.rows.count, 1)
        XCTAssertTrue(source.section(at: 0) === section)
        XCTAssertTrue(source.row(at: IndexPath(row: 0, section: 0)) === row)
        XCTAssertEqual(row.fixedHeight, 52)
        XCTAssertTrue(row.makeCell() is SwiftTestRowCell)
    }
}

/// Uses an explicit Objective-C runtime name for default RowClassName + Cell lookup.
@objc(TRKSwiftTestRow)
private final class SwiftTestRow: TRKTableRow {
    /// Test rows need no content; this override verifies the Swift configuration hook.
    override func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {}
}

/// Matches TRKSwiftTestRow + Cell in the Objective-C runtime.
@objc(TRKSwiftTestRowCell)
private final class SwiftTestRowCell: TRKTableViewCell {}
