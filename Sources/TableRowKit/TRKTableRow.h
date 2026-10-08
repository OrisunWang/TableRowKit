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
/// Fixed row height; callers update it and the delegate reads it. Defaults to 44 points.
@property (nonatomic, assign) CGFloat fixedHeight;
/// Compatibility alias for fixedHeight; callers update it and the delegate reads fixedHeight.
@property (nonatomic, assign) CGFloat cellHeight NS_SWIFT_UNAVAILABLE("Use fixedHeight");
/// Optional selection callback; callers install it and the delegate proxy invokes it.
@property (nonatomic, copy, nullable) TRKTableRowSelectedBlock selectionHandler;
/// Compatibility alias for selectionHandler; callers install it and the proxy reads selectionHandler.
@property (nonatomic, copy, nullable) TRKTableRowSelectedBlock selectedBlock NS_SWIFT_UNAVAILABLE("Use selectionHandler");
/// Whether UIKit computes row height; subclasses override it when they need automatic sizing.
@property (nonatomic, readonly) BOOL usesAutomaticHeight;
/// Compatibility override point used by the default usesAutomaticHeight implementation.
- (BOOL)autoAdjustCellHeight NS_SWIFT_UNAVAILABLE("Override usesAutomaticHeight");
/// The reuse identifier; subclasses may override its getter, and it defaults to the row class name.
@property (nonatomic, readonly) NSString *reuseIdentifier;
/// Creates a cell; subclasses override it, and the default delegates to the older creation hook.
- (__kindof UITableViewCell *)makeCell;
/// Compatibility creation hook; its default instantiates RowClassName + Cell.
- (__kindof UITableViewCell *)createNewTableViewCellForRow NS_SWIFT_UNAVAILABLE("Override makeCell");
/// Dequeues or creates the display cell and records tableView.
- (__kindof UITableViewCell *)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath NS_SWIFT_NAME(cell(for:at:));
/// Configures a display cell; subclasses override it to apply current model values.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath NS_SWIFT_NAME(configure(_:at:));
/// Compatibility configuration hook called by the default configureCell:atIndexPath:.
- (void)updateCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath NS_SWIFT_UNAVAILABLE("Override configure(_:at:)");
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
