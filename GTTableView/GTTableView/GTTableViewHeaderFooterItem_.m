//
//  GTTableViewHeaderFooterItem_.m
//  GTTableView
//
//  Created by Andrew Mackenzie-Ross on 3/05/11.
//  Copyright 2011 mackross.net. All rights reserved.
//

#import "GTTableViewHeaderFooterItem_.h"
#import "GTTableView.h"
@interface GTTableViewHeaderFooterItem_ ()
- (void) setup_;
@property (nonatomic, weak) GTTableView *tableView;
@end

@implementation GTTableViewHeaderFooterItem_
@synthesize tableView;
#pragma mark - Accessors -
@synthesize view = view_;
@synthesize text = text_;
@synthesize height = height_;
+ (GTTableViewHeaderFooterItem_*)itemWithView:(UIView*)view
{
    GTTableViewHeaderFooterItem_* item = [[GTTableViewHeaderFooterItem_ alloc] init];
    item.view = view;
    item.height = view.frame.size.height;
    return item;
}
+ (GTTableViewHeaderFooterItem_*)itemWithText:(NSString*)text
{
    GTTableViewHeaderFooterItem_* item = [[GTTableViewHeaderFooterItem_ alloc] init];
    item.text = text;
    return item;
}
- (CGFloat)height {
    if (height_ != GTTableViewHeaderFooterDefaultHeight)
        return height_;
    if (view_)
        return view_.frame.size.height;
    return GTTableViewHeaderFooterDefaultHeight;
}
#pragma mark - Object Lifecylce -

- (void)awakeFromNib
{
    [self setup_];   
}
- (id)init
{
    self = [super init];
    if (self)
    {
        [self setup_];
    }
    return self;
}

- (void)setup_
{
    height_ = GTTableViewHeaderFooterDefaultHeight;
}

@end

@implementation GTTableViewHeaderItem

+ (GTTableViewHeaderItem*)itemWithView:(UIView*)view { return (GTTableViewHeaderItem*)[super itemWithView:view]; }
+ (GTTableViewHeaderItem*)itemWithText:(NSString*)text { return (GTTableViewHeaderItem*)[super itemWithText:text]; }

@end

@implementation GTTableViewFooterItem

+ (GTTableViewFooterItem*)itemWithView:(UIView*)view { return (GTTableViewFooterItem*)[super itemWithView:view]; }
+ (GTTableViewFooterItem*)itemWithText:(NSString*)text { return (GTTableViewFooterItem*)[super itemWithText:text]; }

@end