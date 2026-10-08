#import <UIKit/UIKit.h>
#import "TRKNode.h"

NS_ASSUME_NONNULL_BEGIN
@class TRKTableSection, TRKTableRow;

/// An ordered UITableViewDataSource backed by sections and rows.
@interface TRKTableDataSource : TRKNode <UITableViewDataSource>
/// The row at a valid index path, or nil when either index is out of range.
- (nullable __kindof TRKTableRow *)rowAtIndexPath:(NSIndexPath *)indexPath NS_SWIFT_NAME(row(at:));
/// The section at index, or nil when out of range.
- (nullable __kindof TRKTableSection *)sectionAtIndex:(NSUInteger)index NS_SWIFT_NAME(section(at:));
/// Appends a section.
- (void)addSection:(TRKTableSection *)section NS_SWIFT_NAME(add(_:));
/// Appends sections in array order.
- (void)addSectionsFromArray:(NSArray<TRKTableSection *> *)array NS_SWIFT_NAME(add(contentsOf:));
/// A snapshot computed from child sections on each read; tree edits change later reads.
@property (nonatomic, readonly) NSArray<TRKTableSection *> *sections;
/// A flattened snapshot computed from current section rows on each read.
@property (nonatomic, readonly) NSArray<TRKTableRow *> *rows;
/// An ordered snapshot of sections.
- (NSArray<TRKTableSection *> *)allSections NS_SWIFT_UNAVAILABLE("Use sections");
/// A flattened snapshot of rows, in section order.
- (NSArray<TRKTableRow *> *)allRows NS_SWIFT_UNAVAILABLE("Use rows");
@end
NS_ASSUME_NONNULL_END
