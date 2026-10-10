#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// A reusable cell base class with a setup hook for explicit or inferred Row cells.
@interface TRKTableViewCell : UITableViewCell
/// Runs after programmatic creation or nib loading; subclasses may configure static views here.
/// The base implementation disables selection highlighting and clears the cell and contentView backgrounds.
- (void)cellDidCreate;
@end
NS_ASSUME_NONNULL_END
