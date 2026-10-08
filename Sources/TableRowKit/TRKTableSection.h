#import <UIKit/UIKit.h>
#import "TRKNode.h"

NS_ASSUME_NONNULL_BEGIN
@class TRKTableView, TRKTableRow;

/// Owns a section's ordered rows and provides header/footer override points.
@interface TRKTableSection : TRKNode
/// Fixed header height; callers update it. Defaults to CGFLOAT_MIN to suppress UIKit's default gap.
@property (nonatomic, assign) CGFloat headerHeight;
/// Fixed footer height; callers update it. Defaults to CGFLOAT_MIN.
@property (nonatomic, assign) CGFloat footerHeight;
/// Whether the proxy returns automatic dimensions for header and footer; callers update it.
@property (nonatomic, assign) BOOL usesAutomaticHeaderFooterHeight;

/// Returns the header height when automatic sizing is disabled.
- (CGFloat)heightForHeaderInTableView:(UITableView *)tableView inSection:(NSInteger)section;
/// Returns the footer height when automatic sizing is disabled.
- (CGFloat)heightForFooterInTableView:(UITableView *)tableView inSection:(NSInteger)section;
/// A snapshot computed from child rows on each read; tree edits change later reads.
@property (nonatomic, readonly) NSArray<__kindof TRKTableRow *> *rows;
/// Legacy Objective-C row snapshot accessor.
- (NSArray<__kindof TRKTableRow *> *)allRows NS_SWIFT_UNAVAILABLE("Use rows");
/// Replaces rows and preserves lifecycle callbacks.
- (void)setAllRows:(nullable NSArray<__kindof TRKTableRow *> *)rows NS_SWIFT_UNAVAILABLE("Use children or add(_:)");
/// Returns a row, or nil when the index is out of range.
- (nullable __kindof TRKTableRow *)rowAtIndex:(NSUInteger)index NS_SWIFT_NAME(row(at:));
/// Appends a row.
- (void)addRow:(TRKTableRow *)row NS_SWIFT_NAME(add(_:));
/// Appends rows in array order.
- (void)addRowsFromArray:(NSArray<TRKTableRow *> *)array NS_SWIFT_NAME(add(contentsOf:));
/// The section index in a data source, or NSNotFound when detached.
- (NSUInteger)section;
/// Supplies an optional header view.
- (nullable UIView *)viewForHeaderInTableView:(UITableView *)tableView section:(NSInteger)section;
/// Supplies an optional footer view.
- (nullable UIView *)viewForFooterInTableView:(UITableView *)tableView section:(NSInteger)section;
/// Called before a header becomes visible.
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section;
/// Called before a footer becomes visible.
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section;
@end
NS_ASSUME_NONNULL_END
