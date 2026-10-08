#import "TRKTableRow.h"
#import "TRKTableSection.h"
#import "TRKTableDataSource.h"

@implementation TRKTableRow

/// Initializes the height used when a subclass disables automatic sizing.
- (instancetype)init {
    self = [super init];
    if (self) { _fixedHeight = 44; }
    return self;
}

/// Class names provide a stable default reuse key.
- (NSString *)reuseIdentifier { return NSStringFromClass(self.class); }

/// Infers a conventional Cell subclass and fails clearly if it is unavailable.
- (UITableViewCell *)makeCell {
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

/// Automatic sizing is the default; subclasses return NO to use fixedHeight.
- (BOOL)usesAutomaticHeight { return YES; }
/// Subclasses may apply model values when a cell is requested for display.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {}
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
