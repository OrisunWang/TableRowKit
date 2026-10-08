#import "TRKTableDataSource.h"
#import "TRKTableSection.h"
#import "TRKTableRow.h"

@implementation TRKTableDataSource

/// Only sections belong directly to a data source.
- (void)insertChild:(TRKNode *)node atIndex:(NSUInteger)index {
    if ([node isKindOfClass:[TRKTableSection class]]) { [super insertChild:node atIndex:index]; }
}

/// Adds a section through the validated tree method.
- (void)addSection:(TRKTableSection *)section { [self addChild:section]; }
/// Adds each section in order.
- (void)addSectionsFromArray:(NSArray<TRKTableSection *> *)array { [self addChildrenFromArray:array]; }
/// Returns typed, immutable child sections.
- (NSArray<TRKTableSection *> *)sections { return (NSArray<TRKTableSection *> *)self.children; }

/// Bounds checks avoid reliance on an external foundation category.
- (TRKTableSection *)sectionAtIndex:(NSUInteger)index {
    NSArray<TRKTableSection *> *sections = self.sections;
    return index < sections.count ? sections[index] : nil;
}

/// A section must exist before its row index is read.
- (TRKTableRow *)rowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self sectionAtIndex:(NSUInteger)indexPath.section] rowAtIndex:(NSUInteger)indexPath.row];
}

/// Flattens the current section order into an immutable snapshot.
- (NSArray<TRKTableRow *> *)rows {
    NSMutableArray<TRKTableRow *> *rows = [NSMutableArray array];
    for (TRKTableSection *section in self.sections) { [rows addObjectsFromArray:section.rows]; }
    return [rows copy];
}

/// UIKit requests the number of current sections.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return (NSInteger)self.sections.count; }
/// UIKit requests the number of rows in a section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)[self sectionAtIndex:(NSUInteger)section].rows.count;
}

/// Gives each row the chance to create and configure its cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRKTableRow *row = [self rowAtIndexPath:indexPath];
    if (row == nil) {
        [NSException raise:NSInvalidArgumentException format:@"No row exists at %@", indexPath];
    }
    UITableViewCell *cell = [row cellForTableView:tableView indexPath:indexPath];
    if (cell == nil) {
        [NSException raise:NSInternalInconsistencyException format:@"%@ returned no cell", row];
    }
    [row configureCell:cell atIndexPath:indexPath];
    return cell;
}

@end
