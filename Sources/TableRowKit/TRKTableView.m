#import "TRKTableView.h"
#import "TRKTableViewDelegateProxy.h"

@interface TRKTableView ()
/// Retains the adapter because UITableView's delegate reference is weak.
@property (nonatomic, strong, nullable) TRKTableViewDelegateProxy *delegateProxy;
@end

@implementation TRKTableView

/// Applies table defaults for programmatically created instances.
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) { [self trk_configureDefaults]; }
    return self;
}

/// Applies the same defaults to nib/storyboard instances.
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) { [self trk_configureDefaults]; }
    return self;
}

/// Keeps iOS 15 section padding aligned with the original table behavior.
- (void)trk_configureDefaults {
    if (@available(iOS 15.0, *)) { self.sectionHeaderTopPadding = 0; }
}

/// Retains one proxy and swaps its weak external target when the delegate changes.
- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    if (delegate == nil) {
        [super setDelegate:nil];
        self.delegateProxy.target = nil;
        self.delegateProxy = nil;
        return;
    }
    if (self.delegateProxy == nil) { self.delegateProxy = [TRKTableViewDelegateProxy new]; }
    self.delegateProxy.target = delegate;
    [super setDelegate:self.delegateProxy];
}

@end
