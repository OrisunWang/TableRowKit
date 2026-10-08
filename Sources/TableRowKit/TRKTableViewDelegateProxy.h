#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// Internal delegate adapter; TRKTableView retains it while it weakly references the client.
@interface TRKTableViewDelegateProxy : NSObject <UITableViewDelegate>
/// External delegate; TRKTableView updates it in setDelegate:.
@property (nonatomic, weak, nullable) id<UITableViewDelegate> target;
@end
NS_ASSUME_NONNULL_END
