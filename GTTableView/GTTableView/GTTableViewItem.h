//
//  GTTableViewItem.h
//  GTTableView
//
//  Created by Andrew Mackenzie-Ross on 3/05/11.
//  Copyright 2011 mackross.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTTableView;
@class GTTableViewCell;
@interface GTTableViewItem : NSObject <NSCopying> {
@protected
    GTTableView *__weak tableView; /**< Subclasses should use this to access the current GTTableView. */
@private
    
    /**
     All other properties when set will be saved to this dictionary to save memory.
     If properties are not set the default from the tableview will be used.
     */
     NSMutableDictionary *properties_;
    
    /**
     visible property will be set with iVars as it'll be hit often when calculating index paths.
     */
    BOOL visible_;
    BOOL visibleSet_;
}
@property (nonatomic, readonly) GTTableViewCell *cell;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;


+ (NSString*)reuseIdentifier; /**< Subclasses should override this, will automatically use this reuse identifier to try load nibs of the same name. */
@property (nonatomic, copy) NSString* reuseIdentifier; /**< Use this to customize the reuse identifer per cell. */
- (GTTableViewCell*)newTableViewCell; /**< If this isn't overriden will try load nib with same name as reuseIdentifier. If this fails will init cell with style. */



- (NSIndexPath*)shouldMoveFromVisibleIndexPath:(NSIndexPath*)sourceIndexPath toVisibleIndexPath:(NSIndexPath*)destinationIndexPath; /**< Return the index path that item should move to. Most common implementation is to return sourceIndexPath if out of bounds and proposedIndexPath if the move should occur. */

- (NSIndexPath*)selectNewIndexPathFromIndexPaths:(NSSet*)indexPaths; /**< Use this when invisible items are present in the tableview. This method should return the chosen index path from within a group of invisible index paths that the item should move to. If invisible items are not used just return the only index path */
- (void)configureCell:(GTTableViewCell*)tableViewCell;

/** The following are only called after finishedLoading is set to YES. */
- (void)itemWillInsert; 
- (void)itemDidInsert;
- (void)itemWillRemove;
- (void)itemDidRemove; 
- (void)itemWillMove;
- (void)itemDidMove;

- (BOOL)commitDelete; /**< Any custom behaviour after the user has pushed the delete button can be put here. If this returns NO the delete will not continue. */
- (void)commitInsert; /**< This should be overriden to provide the insert behaviour. Usually this is implemented with insertItem:inSection:atRow:animation:. */

- (NSIndexPath*)itemWillBecomeSelected; /**< Returns an index-path object that confirms or alters the selected row. Return an NSIndexPath object other than indexPath if you want another cell to be selected. Return nil if you don't want the row selected. This method is not called until users touch a row and then lift their finger; the row isn't selected until then, although it is highlighted on touch-down. You can use UITableViewCellSelectionStyleNone to disable the appearance of the cell highlight on touch-down. This method isn’t called when the editing property of the table is set to YES (that is, the table view is in editing mode). Default returns the visible index path of self */
- (void)itemDidBecomeSelected; /**< This method isn't called when a tableview is editing. This should be overriden to provide any custom behaviour expected when the cell is selected. */

- (NSIndexPath*)itemWillBecomeDeselected; /**< Works in the same way as itemWillBecomeSelected but for deselection. */
- (void)itemDidBecomeDeselected;

- (void)accessoryButtonTapped;

- (void)willBeginEditing;
- (void)didEndEditing;

/**
 Setting properteis overrides the default value set by the GTTableView.
 Resetting properties makes them take on the default value set by the GTTableView.
 */
@property (nonatomic, assign, getter = isSelected) BOOL selected;
- (void)resetSelected;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
- (void)resetSelectedAnimated:(BOOL)animated;
@property (nonatomic, assign) BOOL canEdit;
- (void)resetCanEdit;
/**
 Whether a cell is able to move when the cell is in edit mode.
 Default value is `YES`.
 */
@property (nonatomic, assign) BOOL canMove;
- (void)resetCanMove;
@property (nonatomic, assign, getter = isVisible) BOOL visible; /**< Be sure to call beginUpdates and endUpdates on the tableView when chaning this value. */
- (void)resetVisible;
@property (nonatomic, assign) CGFloat height; /**< Be sure to call beginUpdates and endUpdates to get tableview to updatde height. */
- (void)resetHeight;
@property (nonatomic, assign) CGFloat indentationWidth; 
- (void)resetIndentationWidth;
@property (nonatomic, assign) BOOL shouldIndentWhileEditing; /**< Be sure to call beginUpdates and endUpdates to get tableview to updatde height. */
- (void)resetShouldIndentWhileEditing;
@property (nonatomic, assign) BOOL shouldShowReorderControl; 
- (void)resetShouldShowReorderControl;
@property (nonatomic, copy) NSString *deleteConfirmationTitle; /**< Be sure to call beginUpdates and endUpdates to get tableview to updatde height. */
- (void)resetDeleteConfirmationTitle;
@property (nonatomic, assign) UITableViewCellStyle style; /**< Be sure to call reloadData as all cells have to be regenerated. */
- (void)resetStyle;
@property (nonatomic, assign) UITableViewCellEditingStyle editingStyle; /**< Be sure to call beginUpdates and endUpdates to get tableview to updatde height. */
- (void)resetEditingStyle;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;
- (void)resetAccessoryType;
@property (nonatomic, assign) UITableViewCellAccessoryType editingAccessoryType;
- (void)resetEditingAccessoryType;
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;
- (void)resetSelectionStyle;
@property (nonatomic, assign) NSInteger indentationLevel; /**< Be sure to call beginUpdates and endUpdates to get tableview to updatde height. */
- (void)resetIndentationLevel;
@property (nonatomic, retain) UILabel *labelStyle;
- (void)resetLabelStyle;
@property (nonatomic, retain) UILabel *subtitleLabelStyle;
- (void)resetSubtitleLabelStyle;
@property (nonatomic, retain) UIColor *backgroundColor;
- (void)resetBackgroundColor;
@property (nonatomic, retain) UIColor *selectionBackgroundColor;
- (void)resetSelectionBackgroundColor;

@property (nonatomic, assign) id<NSObject> target;
@property (nonatomic, assign) SEL action; /**< Called on target when cell is tapped. */
@property (nonatomic, assign) SEL accessoryAction; /**< Called on target when accessory is tapped. */
@property (nonatomic, readonly) UINavigationController *navigationController;
+ (id)item;
@end