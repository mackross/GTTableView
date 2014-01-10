//
//  GTTableViewCell.h
//  GTTableView
//
//  Created by Andrew Mackenzie-Ross on 3/05/11.
//  Copyright 2011 mackross.net. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTTableViewItem;
@class GTTableView;
@interface GTTableViewCell : UITableViewCell {
    GTTableView *__weak tableView; /**< Use this in subclasses to access the tableview. */
}

@property (nonatomic, retain) UIColor *selectionBackgroundColor;
@property (nonatomic, readonly) GTTableViewItem *item;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailTextLabel;
- (void) prepareCellForReuseForItem_:(GTTableViewItem*)item;
@end
