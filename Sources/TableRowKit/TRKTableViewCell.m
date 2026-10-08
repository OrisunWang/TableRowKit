#import "TRKTableViewCell.h"

@implementation TRKTableViewCell

/// Programmatic cells receive the setup hook once after UITableViewCell initialization.
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) { [self cellDidCreate]; }
    return self;
}

/// Nib-backed cells receive the same hook when outlets are available.
- (void)awakeFromNib {
    [super awakeFromNib];
    [self cellDidCreate];
}

/// Subclasses may configure static cell appearance here.
- (void)cellDidCreate {}

@end
