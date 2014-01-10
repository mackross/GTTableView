//
//  GTTableViewHeaderFooterItem_.h
//  GTTableView
//
//  Created by Andrew Mackenzie-Ross on 3/05/11.
//  Copyright 2011 mackross.net. All rights reserved.
//

#import <Foundation/Foundation.h>
static const CGFloat GTTableViewHeaderFooterDefaultHeight = CGFLOAT_MIN;
#pragma mark Abstract Parent Class -
@class GTTableView;

@interface GTTableViewHeaderFooterItem_ : NSObject {
    GTTableView *__weak tableView;
}
@property (nonatomic, retain) UIView *view;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) CGFloat height;
+ (GTTableViewHeaderFooterItem_*)itemWithView:(UIView*)view;
+ (GTTableViewHeaderFooterItem_*)itemWithText:(NSString*)text;
@end

#pragma mark - Subclasses -
@interface GTTableViewHeaderItem : GTTableViewHeaderFooterItem_ {
}
+ (GTTableViewHeaderItem*)itemWithView:(UIView*)view;
+ (GTTableViewHeaderItem*)itemWithText:(NSString*)text;

@end

@interface GTTableViewFooterItem : GTTableViewHeaderFooterItem_ {
}
+ (GTTableViewFooterItem*)itemWithView:(UIView*)view;
+ (GTTableViewFooterItem*)itemWithText:(NSString*)text;
@end