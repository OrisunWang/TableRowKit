#import <XCTest/XCTest.h>
#import <TableRowKit/TableRowKit.h>

/// Records the section lifecycle without requiring a visible table view.
@interface TRKRecordingRow : TRKTableRow
/// The ordered callbacks received by this row; lifecycle methods update it.
@property (nonatomic, strong) NSMutableArray<NSString *> *events;
@end

@implementation TRKRecordingRow
/// Creates empty storage before lifecycle callbacks can occur.
- (instancetype)init {
    self = [super init];
    if (self) { _events = [NSMutableArray array]; }
    return self;
}
/// Records the pre-insertion event.
- (void)rowWillAddToSection:(TRKTableSection *)section nodeIndex:(NSInteger)index { [self.events addObject:@"willAdd"]; }
/// Records the post-insertion event.
- (void)rowDidAddToSection:(TRKTableSection *)section nodeIndex:(NSInteger)index { [self.events addObject:@"didAdd"]; }
/// Records the pre-removal event.
- (void)rowWillRemoveFromSection:(TRKTableSection *)section nodeIndex:(NSInteger)index { [self.events addObject:@"willRemove"]; }
/// Records the post-removal event.
- (void)rowDidRemoveFromSection:(TRKTableSection *)section nodeIndex:(NSInteger)index { [self.events addObject:@"didRemove"]; }
@end

/// Exercises the current Objective-C row hooks and default Cell naming rule.
@interface TRKConfiguredRow : TRKTableRow
/// Counts configuration calls; configureCell:atIndexPath: increments it for the test.
@property (nonatomic, assign) NSUInteger configurationCount;
@end

@implementation TRKConfiguredRow
/// Records configuration through the current row override point.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    self.configurationCount++;
    cell.textLabel.text = @"configured";
}
/// Requests UIKit automatic height through the current override point.
- (BOOL)usesAutomaticHeight { return YES; }
@end

/// Matches TRKConfiguredRow + Cell for the default makeCell implementation.
@interface TRKConfiguredRowCell : TRKTableViewCell
@end

@implementation TRKConfiguredRowCell
@end

/// Observes external delegate delivery when no row model is available.
@interface TRKRecordingDelegate : NSObject <UITableViewDelegate>
/// Number of display callbacks; UIKit or the test's proxy call updates it.
@property (nonatomic, assign) NSUInteger displayCount;
/// Number of scroll callbacks; proxy forwarding updates it.
@property (nonatomic, assign) NSUInteger scrollCount;
@end

@implementation TRKRecordingDelegate
/// Confirms that a missing row does not suppress an external callback.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.displayCount++;
}
/// Confirms that an optional method not implemented by the adapter forwards.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView { self.scrollCount++; }
@end

/// Regression tests for the current tree, row, and delegate behavior.
@interface TableRowKitTests : XCTestCase
@end

@implementation TableRowKitTests

/// Moving nodes updates both parents and invalid operations preserve the tree.
- (void)testNodeOwnershipAndInvalidInsertion {
    TRKNode *first = [TRKNode new];
    TRKNode *second = [TRKNode new];
    TRKNode *child = [TRKNode new];
    [first addChild:child];
    [second addChild:child];
    XCTAssertEqual(first.count, 0u);
    XCTAssertEqual(second.count, 1u);
    XCTAssertEqual(child.parent, second);
    [second insertChild:first atIndex:3];
    XCTAssertNil(first.parent);
    XCTAssertEqual(second.count, 1u);
    [child addChild:second]; // An ancestor cannot become its descendant.
    XCTAssertNil(second.parent);
    XCTAssertEqual(child.count, 0u);
}

/// Bulk removal uses the same lifecycle path as a single row removal.
- (void)testSectionRemovalCallbacks {
    TRKTableSection *section = [TRKTableSection new];
    TRKRecordingRow *row = [TRKRecordingRow new];
    [section addRow:row];
    [section removeAllChildren];
    XCTAssertEqualObjects(row.events, (@[@"willAdd", @"didAdd", @"willRemove", @"didRemove"]));
    XCTAssertNil(row.parent);
}

/// Reparenting reports old-section removal before new-section insertion.
- (void)testRowMoveCallbackOrder {
    TRKTableSection *first = [TRKTableSection new];
    TRKTableSection *second = [TRKTableSection new];
    TRKRecordingRow *row = [TRKRecordingRow new];
    [first addRow:row];
    [row.events removeAllObjects];
    [second addRow:row];
    XCTAssertEqualObjects(row.events, (@[@"willRemove", @"didRemove", @"willAdd", @"didAdd"]));
    XCTAssertEqual(row.parent, second);
}

/// Safe lookups and a useful fixed height are important for a new data source.
- (void)testDataSourceLookupAndDefaultHeight {
    TRKTableDataSource *source = [TRKTableDataSource new];
    TRKTableSection *section = [TRKTableSection new];
    TRKTableRow *row = [TRKTableRow new];
    [section addRow:row];
    [source addSection:section];
    XCTAssertEqual([source rowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], row);
    XCTAssertNil([source rowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]);
    XCTAssertEqual(row.fixedHeight, 44);
    XCTAssertEqualObjects(row.indexPath, [NSIndexPath indexPathForRow:0 inSection:0]);
}

/// Current Objective-C hooks create and configure the conventionally named Cell.
- (void)testRowCreationConfigurationAndHeight {
    TRKConfiguredRow *row = [TRKConfiguredRow new];
    UITableViewCell *cell = [row makeCell];
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [row configureCell:cell atIndexPath:path];
    XCTAssertTrue([cell isKindOfClass:[TRKConfiguredRowCell class]]);
    XCTAssertEqual(row.configurationCount, 1u);
    XCTAssertEqualObjects(cell.textLabel.text, @"configured");
    XCTAssertTrue(row.usesAutomaticHeight);
}

/// The adapter must deliver external callbacks even without a matching row.
- (void)testDelegateForwarding {
    TRKRecordingDelegate *target = [TRKRecordingDelegate new];
    TRKTableView *table = [[TRKTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.delegate = target;
    id<UITableViewDelegate> proxy = (id<UITableViewDelegate>)table.delegate;
    UITableViewCell *cell = [UITableViewCell new];
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [proxy tableView:table willDisplayCell:cell forRowAtIndexPath:path];
    XCTAssertEqual(target.displayCount, 1u);
    XCTAssertTrue([proxy respondsToSelector:@selector(scrollViewDidScroll:)]);
    [(id<UIScrollViewDelegate>)proxy scrollViewDidScroll:table];
    XCTAssertEqual(target.scrollCount, 1u);
}

@end
