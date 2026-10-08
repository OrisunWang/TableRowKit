#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Owns the example window and installs the table demonstration as the root screen.
@interface TRKExampleAppDelegate : UIResponder <UIApplicationDelegate>
/// Holds the example's visible window for the application lifetime; launch setup updates it.
@property (nonatomic, strong, nullable) UIWindow *window;
@end

NS_ASSUME_NONNULL_END
