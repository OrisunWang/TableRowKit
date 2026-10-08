#import <UIKit/UIKit.h>
#import "TRKNode.h"

NS_ASSUME_NONNULL_BEGIN
@class TRKTableSection;
/// Runs when the row is selected, before the external table delegate.
typedef void (^TRKTableRowSelectedBlock)(UITableView *tableView, NSIndexPath *indexPath);

/// A row model that creates and configures a reusable UITableViewCell.
@interface TRKTableRow : TRKNode
/// The table that most recently requested this row's cell; cellForTableView: updates this weak reference.
@property (nonatomic, weak, nullable) UITableView *tableView;
/// Fixed row height; callers update it and the delegate reads it when automatic sizing is disabled. Defaults to 44 points.
@property (nonatomic, assign) CGFloat fixedHeight;
/// Optional selection callback; callers install it and the delegate proxy invokes it.
@property (nonatomic, copy, nullable) TRKTableRowSelectedBlock selectionHandler;
/// Whether UIKit computes row height; defaults to YES. Subclasses return NO to use fixedHeight.
@property (nonatomic, readonly) BOOL usesAutomaticHeight;
/// The reuse identifier; subclasses may override its getter, and it defaults to the row class name.
@property (nonatomic, readonly) NSString *reuseIdentifier;
/// Creates a cell; the default finds RowClassName + Cell, and subclasses may override it.
- (__kindof UITableViewCell *)makeCell;
/// Dequeues or creates the display cell and records tableView.
- (__kindof UITableViewCell *)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath NS_SWIFT_NAME(cell(for:at:));
/// Configures a display cell; subclasses override it to apply current model values.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath NS_SWIFT_NAME(configure(_:at:));
/// Current index path derived from parents, or nil if detached from a data source.
@property (nonatomic, readonly, nullable) NSIndexPath *indexPath;
/// Estimated height for automatic sizing; subclasses may override its getter; defaults to 44 points.
@property (nonatomic, readonly) CGFloat estimatedHeight;
/// Called before the row's cell becomes visible.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
/// Called after the row's cell leaves the display.
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
/// Called immediately before insertion into a section.
- (void)rowWillAddToSection:(TRKTableSection *)section nodeIndex:(NSInteger)index;
/// Called after insertion into a section.
- (void)rowDidAddToSection:(TRKTableSection *)section nodeIndex:(NSInteger)index;
/// Called immediately before removal from a section.
- (void)rowWillRemoveFromSection:(TRKTableSection *)section nodeIndex:(NSInteger)index;
/// Called after removal from a section.
- (void)rowDidRemoveFromSection:(TRKTableSection *)section nodeIndex:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END
