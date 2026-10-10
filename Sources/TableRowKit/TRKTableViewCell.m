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

/// Disables selection highlighting and uses transparent backgrounds so the table's background remains visible.
/// Subclasses may call super and then override the default static appearance.
- (void)cellDidCreate {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Clear both layers so contentView does not cover the table's background when the cell is transparent.
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
}

@end
