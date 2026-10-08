#import "TRKTableViewDelegateProxy.h"
#import "TRKTableDataSource.h"
#import "TRKTableSection.h"
#import "TRKTableRow.h"

@implementation TRKTableViewDelegateProxy

/// Advertises any optional delegate method implemented only by the external target.
- (BOOL)respondsToSelector:(SEL)selector {
    return [super respondsToSelector:selector] || [self.target respondsToSelector:selector];
}

/// Forwards optional UIKit delegate methods that this adapter does not handle itself.
- (id)forwardingTargetForSelector:(SEL)selector {
    return [self.target respondsToSelector:selector] ? self.target : [super forwardingTargetForSelector:selector];
}

/// The library behavior is active only with its matching data source type.
- (TRKTableDataSource *)trk_dataSourceForTableView:(UITableView *)tableView {
    return [tableView.dataSource isKindOfClass:[TRKTableDataSource class]]
        ? (TRKTableDataSource *)tableView.dataSource : nil;
}

/// Clears selection, runs the row handler, then informs the external delegate.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TRKTableRow *row = [[self trk_dataSourceForTableView:tableView] rowAtIndexPath:indexPath];
    if (row.selectionHandler) { row.selectionHandler(tableView, indexPath); }
    if ([self.target respondsToSelector:_cmd]) {
        [self.target tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

/// Fixed height is used unless the row requests UIKit automatic dimensions.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.target respondsToSelector:_cmd]) {
        return [self.target tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    TRKTableRow *row = [[self trk_dataSourceForTableView:tableView] rowAtIndexPath:indexPath];
    return row == nil ? 44 : (row.usesAutomaticHeight ? UITableViewAutomaticDimension : row.fixedHeight);
}

/// External estimates take precedence; row estimates support automatic sizing.
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.target respondsToSelector:_cmd]) {
        return [self.target tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    TRKTableRow *row = [[self trk_dataSourceForTableView:tableView] rowAtIndexPath:indexPath];
    return row == nil ? 44 : row.estimatedHeight;
}

/// External header views override the section's default view.
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.target respondsToSelector:_cmd]) {
        return [self.target tableView:tableView viewForHeaderInSection:section];
    }
    return [[[self trk_dataSourceForTableView:tableView] sectionAtIndex:(NSUInteger)section]
            viewForHeaderInTableView:tableView section:section];
}

/// External footer views override the section's default view.
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.target respondsToSelector:_cmd]) {
        return [self.target tableView:tableView viewForFooterInSection:section];
    }
    return [[[self trk_dataSourceForTableView:tableView] sectionAtIndex:(NSUInteger)section]
            viewForFooterInTableView:tableView section:section];
}

/// External header height overrides section configuration.
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.target respondsToSelector:_cmd]) {
        return [self.target tableView:tableView heightForHeaderInSection:section];
    }
    TRKTableSection *model = [[self trk_dataSourceForTableView:tableView] sectionAtIndex:(NSUInteger)section];
    if (model == nil) { return CGFLOAT_MIN; }
    return model.usesAutomaticHeaderFooterHeight ? UITableViewAutomaticDimension
        : [model heightForHeaderInTableView:tableView inSection:section];
}

/// External footer height overrides section configuration.
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.target respondsToSelector:_cmd]) {
        return [self.target tableView:tableView heightForFooterInSection:section];
    }
    TRKTableSection *model = [[self trk_dataSourceForTableView:tableView] sectionAtIndex:(NSUInteger)section];
    if (model == nil) { return CGFLOAT_MIN; }
    return model.usesAutomaticHeaderFooterHeight ? UITableViewAutomaticDimension
        : [model heightForFooterInTableView:tableView inSection:section];
}

/// Both the row and external delegate can observe display.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    TRKTableRow *row = [[self trk_dataSourceForTableView:tableView] rowAtIndexPath:indexPath];
    [row tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    if ([self.target respondsToSelector:_cmd]) {
        [self.target tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

/// Both the row and external delegate can observe end of display.
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    TRKTableRow *row = [[self trk_dataSourceForTableView:tableView] rowAtIndexPath:indexPath];
    [row tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    if ([self.target respondsToSelector:_cmd]) {
        [self.target tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

/// Section and external delegate both receive header display events.
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    TRKTableSection *model = [[self trk_dataSourceForTableView:tableView] sectionAtIndex:(NSUInteger)section];
    [model tableView:tableView willDisplayHeaderView:view forSection:section];
    if ([self.target respondsToSelector:_cmd]) {
        [self.target tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

/// Section and external delegate both receive footer display events.
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    TRKTableSection *model = [[self trk_dataSourceForTableView:tableView] sectionAtIndex:(NSUInteger)section];
    [model tableView:tableView willDisplayFooterView:view forSection:section];
    if ([self.target respondsToSelector:_cmd]) {
        [self.target tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

@end
