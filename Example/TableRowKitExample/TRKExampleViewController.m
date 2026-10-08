#import "TRKExampleViewController.h"
#import <TableRowKit/TableRowKit.h>

/// Example row state; the controller sets the title and configureCell:atIndexPath: renders it.
@interface TRKExampleRow : TRKTableRow
/// Stores the row label assigned by the controller and read when configuring a cell.
@property (nonatomic, copy) NSString *title;
@end

@implementation TRKExampleRow

/// Applies the current row title whenever UIKit requests a display cell.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = self.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
// Optional: override the default class-name lookup for custom cell creation.
// - (UITableViewCell *)makeCell {
//     return [[TRKExampleRowCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                    reuseIdentifier:self.reuseIdentifier];
// }

@end

/// Follows TableRowKit's RowClassName + Cell convention for default cell creation.
@interface TRKExampleRowCell : TRKTableViewCell
@end

@implementation TRKExampleRowCell
@end

@interface TRKExampleViewController () <UITableViewDelegate>
/// Retains the model because UITableView keeps its dataSource weakly; viewDidLoad assigns it.
@property (nonatomic, strong) TRKTableDataSource *tableDataSource;
@end

@implementation TRKExampleViewController

/// Builds a section with two rows and connects it to the visible table.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TableRowKit";

    TRKTableView *tableView = [[TRKTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.view = tableView;

    TRKTableDataSource *dataSource = [TRKTableDataSource new];
    TRKTableSection *section = [TRKTableSection new];
    [section addRow:[self rowWithTitle:@"First row"]];
    [section addRow:[self rowWithTitle:@"Second row"]];
    [dataSource addSection:section];
    self.tableDataSource = dataSource;
    tableView.dataSource = dataSource;
    // Installing an external delegate activates TableRowKit's proxy and row selection hook.
    tableView.delegate = self;
}

/// Connects the selection handler while avoiding a row-to-controller retain cycle.
- (TRKExampleRow *)rowWithTitle:(NSString *)title {
    TRKExampleRow *row = [TRKExampleRow new];
    row.title = title;
    __weak typeof(self) weakSelf = self;
    row.selectionHandler = ^(UITableView *tableView, NSIndexPath *indexPath) {
        weakSelf.title = title;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    };
    return row;
}

@end
