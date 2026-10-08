#import "TRKExampleAppDelegate.h"
#import "TRKExampleViewController.h"

@implementation TRKExampleAppDelegate

/// Creates a navigation container so row selection can update the visible title.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    TRKExampleViewController *controller = [TRKExampleViewController new];
    window.rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window = window;
    [window makeKeyAndVisible];
    return YES;
}

@end
