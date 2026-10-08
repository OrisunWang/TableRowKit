#import "TRKTableSection.h"
#import "TRKTableRow.h"

@implementation TRKTableSection

/// Small positive defaults suppress UIKit's implicit grouped header/footer gaps.
- (instancetype)init {
    self = [super init];
    if (self) {
        _headerHeight = CGFLOAT_MIN;
        _footerHeight = CGFLOAT_MIN;
    }
    return self;
}

/// Only rows belong in a section; lifecycle hooks run around actual insertion.
- (void)insertChild:(TRKNode *)node atIndex:(NSUInteger)index {
    if (![node isKindOfClass:[TRKTableRow class]] || index > self.count || node == self) { return; }
    for (TRKNode *ancestor = self; ancestor != nil; ancestor = ancestor.parent) {
        if (ancestor == node) { return; }
    }
    TRKTableRow *row = (TRKTableRow *)node;
    // Complete old-section removal before announcing insertion into this section.
    [row removeFromParent];
    NSUInteger insertionIndex = MIN(index, self.count);
    [row rowWillAddToSection:self nodeIndex:(NSInteger)insertionIndex];
    [super insertChild:node atIndex:insertionIndex];
    if (row.parent == self) { [row rowDidAddToSection:self nodeIndex:(NSInteger)row.nodeIndex]; }
}

/// Fires removal callbacks only when this section actually owns the row.
- (void)removeChild:(TRKNode *)node {
    if (![node isKindOfClass:[TRKTableRow class]] || node.parent != self) { return; }
    TRKTableRow *row = (TRKTableRow *)node;
    NSInteger index = (NSInteger)row.nodeIndex;
    [row rowWillRemoveFromSection:self nodeIndex:index];
    [super removeChild:node];
    [row rowDidRemoveFromSection:self nodeIndex:index];
}

/// Returns typed children.
- (NSArray<TRKTableRow *> *)allRows { return (NSArray<TRKTableRow *> *)self.children; }
/// Exposes the same row snapshot as a Swift-friendly property.
- (NSArray<TRKTableRow *> *)rows { return self.allRows; }
/// Routes replacement through removal and insertion callbacks.
- (void)setAllRows:(NSArray<TRKTableRow *> *)rows { self.children = rows; }
/// Safely accesses an index.
- (TRKTableRow *)rowAtIndex:(NSUInteger)index {
    NSArray<TRKTableRow *> *rows = self.allRows;
    return index < rows.count ? rows[index] : nil;
}
/// Appends a row through the validated tree method.
- (void)addRow:(TRKTableRow *)row { [self addChild:row]; }
/// Appends rows in order.
- (void)addRowsFromArray:(NSArray<TRKTableRow *> *)array { [self addChildrenFromArray:array]; }
/// Uses the node index rather than storing redundant section state.
- (NSUInteger)section { return self.nodeIndex; }
/// Allows subclasses to compute context dependent header height.
- (CGFloat)heightForHeaderInTableView:(UITableView *)tableView inSection:(NSInteger)section { return self.headerHeight; }
/// Allows subclasses to compute context dependent footer height.
- (CGFloat)heightForFooterInTableView:(UITableView *)tableView inSection:(NSInteger)section { return self.footerHeight; }
/// Default sections do not supply a custom header.
- (UIView *)viewForHeaderInTableView:(UITableView *)tableView section:(NSInteger)section { return nil; }
/// Default sections do not supply a custom footer.
- (UIView *)viewForFooterInTableView:(UITableView *)tableView section:(NSInteger)section { return nil; }
/// Optional subclass hook after UIKit obtains a header view.
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {}
/// Optional subclass hook after UIKit obtains a footer view.
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {}

@end
