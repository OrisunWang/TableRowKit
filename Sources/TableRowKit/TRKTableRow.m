#import "TRKTableRow.h"
#import "TRKTableSection.h"
#import "TRKTableDataSource.h"

@implementation TRKTableRow

/// Fixed rows display at a useful default height without requiring configuration.
- (instancetype)init {
    self = [super init];
    if (self) { _fixedHeight = 44; }
    return self;
}

/// Reads the canonical fixed height for Objective-C callers using the older property.
- (CGFloat)cellHeight { return self.fixedHeight; }
/// Writes the canonical fixed height for Objective-C callers using the older property.
- (void)setCellHeight:(CGFloat)height { self.fixedHeight = height; }
/// Reads the canonical selection callback for Objective-C callers using the older property.
- (TRKTableRowSelectedBlock)selectedBlock { return self.selectionHandler; }
/// Writes the canonical selection callback for Objective-C callers using the older property.
- (void)setSelectedBlock:(TRKTableRowSelectedBlock)block { self.selectionHandler = block; }

/// Class names provide a stable default reuse key.
- (NSString *)reuseIdentifier { return NSStringFromClass(self.class); }

/// Keeps older creation overrides active while new subclasses override makeCell directly.
- (UITableViewCell *)makeCell { return [self createNewTableViewCellForRow]; }

/// Infers a conventional Cell subclass and fails clearly if it is unavailable.
- (UITableViewCell *)createNewTableViewCellForRow {
    NSString *name = [NSStringFromClass(self.class) stringByAppendingString:@"Cell"];
    Class cellClass = NSClassFromString(name);
    if (cellClass == Nil || ![cellClass isSubclassOfClass:[UITableViewCell class]]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%@ requires a %@ UITableViewCell subclass or makeCell override",
                           NSStringFromClass(self.class), name];
    }
    return [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.reuseIdentifier];
}

/// Stores the requesting table weakly, then participates in normal UITableView reuse.
- (UITableViewCell *)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    self.tableView = tableView;
    return [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier] ?: [self makeCell];
}

/// Keeps older configuration overrides active while new subclasses use configureCell:atIndexPath:.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [self updateCell:cell indexPath:indexPath];
}
/// Compatibility subclass hook to apply current model values to a cell.
- (void)updateCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {}
/// Preserves older automatic-height overrides through the new property.
- (BOOL)usesAutomaticHeight { return [self autoAdjustCellHeight]; }
/// Fixed height is the default unless a subclass opts into automatic sizing.
- (BOOL)autoAdjustCellHeight { return NO; }
/// Returns a stable estimate for UITableViewAutomaticDimension.
- (CGFloat)estimatedHeight { return 44; }

/// Requires both a section and a data source before forming an index path.
- (NSIndexPath *)indexPath {
    if (![self.parent isKindOfClass:[TRKTableSection class]] ||
        ![self.parent.parent isKindOfClass:[TRKTableDataSource class]]) { return nil; }
    NSUInteger row = self.nodeIndex;
    NSUInteger section = self.parent.nodeIndex;
    if (row == NSNotFound || section == NSNotFound) { return nil; }
    return [NSIndexPath indexPathForRow:(NSInteger)row inSection:(NSInteger)section];
}

/// Optional display lifecycle hook.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {}
/// Optional display lifecycle hook.
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {}
/// Optional section lifecycle hook.
- (void)rowWillAddToSection:(TRKTableSection *)section nodeIndex:(NSInteger)index {}
/// Optional section lifecycle hook.
- (void)rowDidAddToSection:(TRKTableSection *)section nodeIndex:(NSInteger)index {}
/// Optional section lifecycle hook.
- (void)rowWillRemoveFromSection:(TRKTableSection *)section nodeIndex:(NSInteger)index {}
/// Optional section lifecycle hook.
- (void)rowDidRemoveFromSection:(TRKTableSection *)section nodeIndex:(NSInteger)index {}

@end
