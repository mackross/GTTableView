//
//  GTTableViewCell.m
//  GTTableView
//
//  Created by Andrew Mackenzie-Ross on 3/05/11.
//  Copyright 2011 mackross.net. All rights reserved.
//

#import "GTTableViewCell.h"
#import "GTTableViewItem.h"
#import "GTTableView.h"
#import "UILabel+CopyStyle.h"
@interface GTTableViewCell ()
@property (nonatomic, weak) GTTableView *tableView;
@end

@implementation GTTableViewCell
@synthesize tableView;
@dynamic textLabel;
@dynamic detailTextLabel;
#pragma mark - Accessors -
- (GTTableViewItem *)item {
    return [tableView itemForRowAtIndexPath:[tableView indexPathForCell:self]];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) prepareCellForReuseForItem_:(GTTableViewItem*)item 
{
    /* We use this instead of prepare for reuse because the item is not known until this point. */
    [self.textLabel copyStyleFromLabel:item.labelStyle];
    [self.detailTextLabel copyStyleFromLabel:item.subtitleLabelStyle];
    self.accessoryType = item.accessoryType;
    self.editingAccessoryType = item.editingAccessoryType;
    if (item.backgroundColor) {
        if (tableView.style == UITableViewStylePlain)
            self.contentView.backgroundColor = item.backgroundColor;
        else if (tableView.style == UITableViewStyleGrouped)
            self.backgroundColor = item.backgroundColor;
    }
    self.indentationLevel = item.indentationLevel;
    self.indentationWidth = item.indentationWidth;
    self.selectionStyle = item.selectionStyle;
    self.selectionBackgroundColor = item.selectionBackgroundColor;
    self.shouldIndentWhileEditing = item.shouldIndentWhileEditing;
    self.showsReorderControl = item.shouldShowReorderControl;
}

- (UIColor *)selectionBackgroundColor {
    return [[self selectedBackgroundView] backgroundColor];
}

- (void)setSelectionBackgroundColor:(UIColor *)selectionBackgroundColor {
//    if (![self selectedBackgroundView])
//    {
//        self.selectedBackgroundView =  [[[UIView alloc] initWithFrame:self.backgroundView.frame] autorelease];
//    }
//    self.selectedBackgroundView.backgroundColor = selectionBackgroundColor;
}

@end
