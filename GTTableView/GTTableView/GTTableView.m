//
//  GTTableView.m
//  GTTableView
//
//  Created by Andrew Mackenzie-Ross on 2/05/11.
//  Copyright 2011 mackross.net. All rights reserved.
//

#import "GTTableView.h"
#import "GTTableViewItem.h"
#import "GTTableViewCell.h"
#import "GTTableViewHeaderFooterItem_.h"

@interface GTTableViewCell (Link)
@property (nonatomic, assign) GTTableView *tableView;
@end
@implementation GTTableViewCell (Link)
@dynamic tableView;
@end

@interface GTTableViewItem (Link)
@property (nonatomic, assign) GTTableView *tableView;
@end
@implementation GTTableViewItem (Link)
@dynamic tableView;
@end

@interface GTTableViewHeaderFooterItem_ (Link)
@property (nonatomic, assign) GTTableView *tableView;
@end
@implementation GTTableViewHeaderFooterItem_ (Link)
@dynamic tableView;
@end


@interface GTTableView ()
- (void)setup_;
- (void)updateCachedIndexPaths_;
- (void)tearDownItems_;
- (void)tearDownHeaderItems_;
- (void)teardownFooterItems_;
- (void)tearDownCells_;
@end

@implementation GTTableView
#pragma mark - Accesssors -
@synthesize GTTableViewDelegate = GTTableViewDelegate_;
@synthesize defaultCellCanEdit = defaultCellCanEdit_;
@synthesize defaultCellCanMove = defaultCellCanMove_;
@synthesize defaultItemIsVisible = defaultItemIsVisible_;
@synthesize defaultCellHeight = defaultCellHeight_;
@synthesize defaultCellIndentationWidth = defaultCellIndentationWidth_;
@synthesize defaultCellShouldIndentWhileEditing = defaultCellShouldIndentWhileEditing_;
@synthesize defaultCellShouldShowReorderControl = defaultCellShouldShowReorderControl_;
@synthesize defaultCellDeleteConfirmationButtonTitle = defaultCellDeleteConfirmationButtonTitle_;
@synthesize defaultCellStyle = defaultCellStyle_;
@synthesize defaultCellEditingStyle = defaultCellEditingStyle_;
@synthesize defaultCellAccessoryType = defaultCellAccessoryType_;
@synthesize defaultCellEditingAccessoryType = defaultCellEditingAccessoryType_;
@synthesize defaultCellSelectionStyle = defaultCellSelectionStyle_;
@synthesize defaultCellIndentationLevel = defaultCellIndentationLevel_;
@synthesize defaultCellLabel = defaultCellLabel_;
@synthesize defaultCellSubtitleLabel = defaultCellSubtitleLabel_;
@synthesize defaultCellBackgroundColor = defaultCellBackgroundColor_;
@synthesize defaultCellSelectionBackgroundColor = defaultCellSelectionBackgroundColor_;
@synthesize defaultHeaderItemHeight = defaultHeaderItemHeight_;
@synthesize defaultFooterItemHeight = defaultFooterItemHeight_;
@synthesize sectionIndexTitlesForTableView = sectionIndexTitlesForTableView_;
@synthesize finishedLoading = finishLoading_;

- (UIColor *)backgroundColor {
    return [super backgroundColor];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

#pragma mark - Object Lifecycle -
- (void)awakeFromNib 
{
    [self setup_];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style 
{
    self = [super init];
    if (self) {
        [self setup_];
    }
    return self;
}

- (void)setup_ 
{
    self.delegate = self;
    self.dataSource = self;
    defaultCellCanEdit_ = YES;
    defaultCellCanMove_ = YES;
    defaultItemIsVisible_ = YES;
    defaultCellHeight_ = 44.0;
    defaultCellIndentationWidth_ = 10.0;
    defaultCellShouldIndentWhileEditing_ = YES;
    defaultCellShouldShowReorderControl_ = NO;
    defaultCellBackgroundColor_ = [UIColor whiteColor];
    defaultCellStyle_ = UITableViewCellStyleDefault;
    defaultCellEditingStyle_ = UITableViewCellEditingStyleDelete;
    defaultCellAccessoryType_ = UITableViewCellAccessoryNone;
    defaultCellEditingAccessoryType_ = UITableViewCellAccessoryNone;
    defaultCellSelectionStyle_ = UITableViewCellSelectionStyleBlue;
    defaultCellIndentationLevel_ = 0;
    defaultHeaderItemHeight_ = self.sectionHeaderHeight;
    defaultFooterItemHeight_ = self.sectionFooterHeight;
    items_ = [[NSMutableArray alloc] init];
    cachedIndexPaths_ = [[NSMutableArray alloc] init];
    cachedVisibleIndexPaths_ = [[NSMutableArray alloc] init];
    cachedIndexPathsAndItems_ = [[NSMutableDictionary alloc] init];
    cachedVisibleIndexPathsAndItems_ = [[NSMutableDictionary alloc] init];
    itemsAndCachedIndexPaths_ = [[NSMutableDictionary alloc] init];
    itemsAndCachedVisibleIndexPaths_ = [[NSMutableDictionary alloc] init];
    headerItems_ = [[NSMutableArray alloc] init];
    footerItems_ = [[NSMutableArray alloc] init];
    cells_ = [[NSMutableSet alloc] init];
}

- (void)dealloc 
{
    GTTableViewDelegate_ = nil;
    self.delegate = nil;
    self.dataSource = nil;
    
    [self tearDownHeaderItems_];
    [self teardownFooterItems_];
    [self tearDownItems_];
    [self tearDownCells_];
    
    [defaultCellDeleteConfirmationButtonTitle_ release];
    [defaultCellLabel_ release];
    [defaultCellSubtitleLabel_ release];
    [defaultCellBackgroundColor_ release];
    [defaultCellSelectionBackgroundColor_  release];
    [sectionIndexTitlesForTableView_ release];
    
    [items_ release];
    [itemsAndCachedIndexPaths_ release];
    [itemsAndCachedVisibleIndexPaths_ release];
    [cachedIndexPathsAndItems_ release];
    [cachedVisibleIndexPathsAndItems_ release];
    
    [headerItems_ release];
    [footerItems_ release];
    [cachedIndexPaths_ release];
    [cachedVisibleIndexPaths_ release];

    [cells_ release];
    [super dealloc];
    
    
}

- (void)tearDownItems_
{
    for (NSArray *sectionItems in items_) 
    {
        for (GTTableViewItem *item in sectionItems)
        {
            [item setTableView:nil];
        }
    }
    
}
- (void)tearDownHeaderItems_
{
    for (GTTableViewHeaderItem *headerItem in headerItems_) 
    {
        [headerItem setTableView:nil];
    }
}

- (void)teardownFooterItems_
{
    for (GTTableViewFooterItem *footerItem in footerItems_) 
    {
        [footerItem setTableView:nil];
    }
}

- (void)tearDownCells_
{
    for (GTTableViewCell *cell in cells_)
    {
        [cell setTableView:nil];
    }
}

#pragma mark - Keyboard Handling -

- (void)viewDidAppear:(BOOL)animated 
{
    [self flashScrollIndicators];

}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

#pragma mark - GTTableView Methods -
#pragma mark Internal
- (void)updateCachedIndexPaths_ 
{
    [cachedIndexPaths_ removeAllObjects];
    [cachedVisibleIndexPaths_ removeAllObjects];
    [cachedIndexPathsAndItems_ removeAllObjects];
    [cachedVisibleIndexPathsAndItems_ removeAllObjects];
    [itemsAndCachedIndexPaths_ removeAllObjects];
    [itemsAndCachedVisibleIndexPaths_ removeAllObjects];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSInteger section = 0;
    for (NSArray *sectionItems in items_) 
    {
        NSMutableArray *visibleRows = [NSMutableArray array];
        NSMutableArray *rows = [NSMutableArray array];
        NSInteger row = 0;
        NSInteger visibleRow = 0;
        for (GTTableViewItem *item in sectionItems)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [rows addObject:indexPath];
            [cachedIndexPathsAndItems_ setObject:item forKey:indexPath];
            [itemsAndCachedIndexPaths_ setObject:indexPath forKey:item];

            if ([item isVisible]) 
            {
                NSIndexPath *visibleIndexPath = [NSIndexPath indexPathForRow:visibleRow inSection:section];
                [visibleRows addObject:visibleIndexPath]; 
                [cachedVisibleIndexPathsAndItems_ setObject:item forKey:visibleIndexPath];
                [itemsAndCachedVisibleIndexPaths_ setObject:visibleIndexPath forKey:item];
                visibleRow++;
            }
            row++;
        }
        [cachedIndexPaths_ addObject:rows];
        [cachedVisibleIndexPaths_ addObject:visibleRows];
        section++;
    }
    
    [pool drain];
}

- (void)reloadData {
    [self updateCachedIndexPaths_];
    [super reloadData];
}
#pragma mark Retrieving Information About the Tableview

- (NSInteger)numberOfItemSections
{
    return [cachedVisibleIndexPaths_ count];
    
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section onlyVisible:(BOOL)visible {
    NSInteger numberOfItems = 0;
    if (visible) {
        if (section  < [cachedVisibleIndexPaths_ count]) 
        {
            numberOfItems = [(NSMutableArray*)[cachedVisibleIndexPaths_ objectAtIndex:section] count];
        }
    }
    else {
        if (section < [cachedIndexPaths_ count]) 
        {
            numberOfItems = [(NSMutableArray*)[cachedIndexPaths_ objectAtIndex:section] count];
        }
        
    }
    return numberOfItems;
}
- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section onlyVisible:YES];
}

- (NSArray*)items
{
    return [self itemsOnlyVisible:YES];
}

- (NSArray*)itemsOnlyVisible:(BOOL)visible
{
    NSMutableArray *items = [NSMutableArray array];
    for (int section = 0; section < [items_ count]; section++) 
    {
        [items addObjectsFromArray:[self itemsInSection:section onlyVisible:visible]];
    }
    return [[items copy] autorelease];
}

- (NSArray*)itemsInSection:(NSInteger)section
{
    return [self itemsInSection:section onlyVisible:YES];
}

- (NSArray*)itemsInSection:(NSInteger)section onlyVisible:(BOOL)onlyVisible
{
    NSMutableArray *items = [NSMutableArray array];
    for (GTTableViewItem *item in (NSMutableArray*)[items_ objectAtIndex:section])
    {
        if (!onlyVisible || item.visible) [items addObject:item];
    }
    return [[items copy] autorelease];
}

- (GTTableViewItem*)itemForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [self itemForRowAtIndexPath:indexPath onlyVisible:YES];
}

- (GTTableViewItem*)itemForRowAtIndexPath:(NSIndexPath*)indexPath onlyVisible:(BOOL)visible
{
    return (visible) ? [cachedVisibleIndexPathsAndItems_ objectForKey:indexPath] : [cachedIndexPathsAndItems_ objectForKey:indexPath];
}


- (NSIndexPath*) indexPathForItem:(GTTableViewItem*)item
{
    return [self indexPathForItem:item onlyVisible:YES];
}

- (NSIndexPath*) indexPathForItem:(GTTableViewItem*)item onlyVisible:(BOOL)visible
{
    return (visible) ? [itemsAndCachedVisibleIndexPaths_ objectForKey:item] : [itemsAndCachedIndexPaths_ objectForKey:item];
}

#pragma mark Changing the data within the tableview.

- (void)insertSectionAtIndex:(NSInteger)index animation:(UITableViewRowAnimation)animation
{
    NSMutableArray *movedItems = nil;
    if (finishLoading_)
    {
        movedItems = [NSMutableArray array];
        for (int i = index; i < [items_ count]; i++)  [movedItems addObjectsFromArray:[self itemsInSection:i onlyVisible:NO]];
        for (GTTableViewItem *item in movedItems) [item sectionWillMove];
        [self insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:animation];
    }
    
    [items_ insertObject:[NSMutableArray array] atIndex:index];
    [self updateCachedIndexPaths_];
    
     if (finishLoading_) for (GTTableViewItem *item in movedItems) [item sectionDidMove];
}

- (void)removeSectionAtIndex:(NSInteger)index animation:(UITableViewRowAnimation)animation
{
    NSMutableArray * movedItems = nil;
    if (finishLoading_) 
    {
        movedItems = [NSMutableArray array];
        for (int i = index + 1; i < [items_ count]; i++) [movedItems addObjectsFromArray:[self itemsInSection:i onlyVisible:NO]];
        for (GTTableViewItem *item in movedItems) [item sectionWillMove];
        [self deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:animation];
        for (GTTableViewItem *item in [self itemsInSection:index onlyVisible:NO]) [item commitDelete];
    }
    
    [items_ removeObjectAtIndex:index];
    [self updateCachedIndexPaths_];
    
    if (finishLoading_) for (GTTableViewItem *item in movedItems) [item sectionDidMove];
}

- (void)appendItem:(GTTableViewItem*)item toSection:(NSInteger)section animation:(UITableViewRowAnimation)animation
{
    
    [self insertItem:item atIndexPath:[NSIndexPath indexPathForRow:[[items_ objectAtIndex:section] count] inSection:section] animation:animation onlyVisible:NO];
}

- (void)insertItem:(GTTableViewItem*)item atIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation
{
    [self insertItem:item atIndexPath:indexPath animation:animation onlyVisible:YES];
}

- (void)insertItem:(GTTableViewItem*)item atIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation onlyVisible:(BOOL)visible
{
    [item setTableView:self];
    /** Convert visible to invisible. */
    if (visible)
    {
        /** Find the correct row to go to. */
        GTTableViewItem *itemForCellAboveNewLocation = [self itemForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section] onlyVisible:YES];
        GTTableViewItem *itemForCellAtNewLocation = [self itemForRowAtIndexPath:indexPath onlyVisible:YES];    
        NSMutableSet *possibleIndexPaths = [NSMutableSet set];
        NSInteger realRowAboveNewLocationRow = (itemForCellAboveNewLocation) ? [self indexPathForItem:itemForCellAboveNewLocation onlyVisible:NO].row : -1;
        NSInteger realRowAtNewLocationRow = (itemForCellAtNewLocation) ? [self indexPathForItem:itemForCellAtNewLocation onlyVisible:NO].row : [[items_ objectAtIndex:indexPath.section] count];
        for (int i = realRowAboveNewLocationRow + 1; i <= realRowAtNewLocationRow; i++) {
            [possibleIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        }
        NSLog(@"%@",possibleIndexPaths);
        if ([possibleIndexPaths count] > 1)
        {
            indexPath = [item selectNewIndexPathFromIndexPaths:possibleIndexPaths];
            NSAssert(indexPath,@"selectNewIndexPathFromIndexPaths: must not return nil"); 
        }
        else 
        {
            indexPath = [possibleIndexPaths anyObject];
        }
        
        NSAssert([possibleIndexPaths count] != 0,@"GTTableView error");
    }
    /** Insert items and notify items that moved. */
    NSMutableArray *destinationSection = (NSMutableArray*)[items_ objectAtIndex:indexPath.section];
    NSMutableSet *itemsToNotifyOfMove = [NSMutableSet set];
    
    if (finishLoading_) for (int i = indexPath.row; i < [destinationSection count]; i++)  [itemsToNotifyOfMove addObject:[destinationSection objectAtIndex:i]];
       
    if (finishLoading_) for (GTTableViewItem *item in itemsToNotifyOfMove) [item rowWillMove];
    
    [destinationSection insertObject:item atIndex:indexPath.row];    
    [self updateCachedIndexPaths_];
    if (finishLoading_&&[item isVisible]) [self insertRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForItem:item]] withRowAnimation:animation];

    
    if (finishLoading_) for (GTTableViewItem *item in itemsToNotifyOfMove) [item rowDidMove];

}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation
{
    [self removeItemAtIndexPath:indexPath animation:animation onlyVisible:YES];
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation onlyVisible:(BOOL)visible
{
    /** Convert visible to invisible. */
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    if (visible)
        indexPath = [self indexPathForItem:item onlyVisible:NO];
    
    /** Remove items and notify items that moved. */
    NSMutableArray *sourceSection = [items_ objectAtIndex:indexPath.section];
    NSMutableSet *itemsToNotifyOfMove = [NSMutableSet set];
    if (finishLoading_) 
    {
        for (int i = indexPath.row + 1; i < [sourceSection count]; i++) [itemsToNotifyOfMove addObject:[sourceSection objectAtIndex:i]];
        for (GTTableViewItem *item in itemsToNotifyOfMove) [item rowWillMove];
    }
    
    [[item retain] autorelease];
    
    [sourceSection removeObjectAtIndex:indexPath.row];
    if (finishLoading_&&[item isVisible]) [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForItem:item]] withRowAnimation:animation];

    [self updateCachedIndexPaths_];

    if (finishLoading_) for (GTTableViewItem *item in itemsToNotifyOfMove) [item rowDidMove];
}

#pragma mark Header & Footer Items
/**
 For the header items we are using NSNull as place holders. This allows these items to be set at any time.
 Nonetheless, the following methods work just like normal accessors.
 */
- (GTTableViewHeaderItem*)tableViewHeaderItemForSection:(NSInteger)section
{
    GTTableViewHeaderItem * headerItem =  (section < [headerItems_ count]) ? [headerItems_ objectAtIndex:section] : nil;
    return ((id<NSObject>)headerItem != [NSNull null]) ? headerItem : nil;
}

- (GTTableViewFooterItem*)tableViewFooterItemForSection:(NSInteger)section
{
    GTTableViewFooterItem *footerItem = (section < [footerItems_ count]) ? [footerItems_ objectAtIndex:section] : nil;
    return ((id<NSObject>)footerItem != [NSNull null]) ? footerItem : nil;
}

- (void)setTableViewHeaderItem:(GTTableViewHeaderItem *)item forSection:(NSInteger)section
{
    [item setTableView:self];
    for (int i = [headerItems_ count]; i <= section; i++)
    {
        [headerItems_ addObject:[NSNull null]];
    }
    if (item) {
        [headerItems_ removeObjectAtIndex:section];
        [headerItems_ insertObject:item atIndex:section];
    }
    else {
        [headerItems_ removeObjectAtIndex:section];
        [headerItems_ insertObject:[NSNull null] atIndex:section];
    }
}

- (void)setTableViewFooterItem:(GTTableViewFooterItem *)item forSection:(NSInteger)section
{
    [item setTableView:self];
    for (int i = [footerItems_ count]; i <= section; i++)
    {
        [footerItems_ addObject:[NSNull null]];
    }
    if (item) {
        [footerItems_ removeObjectAtIndex:section];
        [footerItems_ insertObject:item atIndex:section];
    }
    else {
        [footerItems_ removeObjectAtIndex:section];
        [footerItems_ insertObject:[NSNull null] atIndex:section];
    }
}

#pragma mark - TableView Datasource -
#pragma mark Configuring a TableView

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    NSAssert(item,@"Has to return an item...");
    GTTableViewCell *cell = (GTTableViewCell*)[self dequeueReusableCellWithIdentifier:[[item class] reuseIdentifier]];
    if (!cell)
    {
        cell = [[item newTableViewCell] autorelease];
        [cell setTableView:self];
    }
    [cell prepareCellForReuseForItem_:item];
    [item configureCell:cell];
    NSAssert(cell,@"Has to return a cell...");
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self numberOfItemSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfItemsInSection:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    if (sectionIndexTitlesForTableView_)
        return sectionIndexTitlesForTableView_;
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [[self tableViewHeaderItemForSection:section] text];
    if (section < [sectionIndexTitlesForTableView_ count])
        title = (title) ? title : [sectionIndexTitlesForTableView_ objectAtIndex:section];
    return title;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = [[self tableViewFooterItemForSection:section] text];
    return title;
}

#pragma mark Inserting or Deleting Table Rows
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [[self itemForRowAtIndexPath:indexPath] commitDelete]; //**< The item is responsible for making itself invislbe or removing itself or its section. */
            break;
        case UITableViewCellEditingStyleInsert:
            [[self itemForRowAtIndexPath:indexPath] commitInsert]; //**< The item is responsible for inserting a new item or section or making something visible. */
            break;
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item canEdit];
}

#pragma mark Reordering Table Rows
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item canMove];  
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceVisibleIndexPath toIndexPath:(NSIndexPath *)destinationVisibleIndexPath
{
    if ([sourceVisibleIndexPath compare:destinationVisibleIndexPath] == NSOrderedSame) return;
    
    /**
     Calculate possible invisible indexes if they exist and ask the item its preferred destination if more than one exits.
     */
    GTTableViewItem *movingItem = [self itemForRowAtIndexPath:sourceVisibleIndexPath onlyVisible:YES];
    NSIndexPath *sourceIndexPath = [self indexPathForItem:movingItem onlyVisible:NO];
    NSIndexPath *destinationIndexPath = nil;
    GTTableViewItem *itemForCellAboveNewLocation = [self itemForRowAtIndexPath:[NSIndexPath indexPathForRow:(destinationVisibleIndexPath.row - 1) inSection:destinationVisibleIndexPath.section] onlyVisible:YES];
    GTTableViewItem *itemForCellAtNewLocation = [self itemForRowAtIndexPath:destinationVisibleIndexPath onlyVisible:YES];    
    
    NSMutableSet *possibleIndexPaths = [NSMutableSet set];
    NSInteger realRowAboveNewLocationRow = (itemForCellAboveNewLocation) ? [self indexPathForItem:itemForCellAboveNewLocation onlyVisible:NO].row  + 1 : 0;
    NSInteger realRowAtNewLocationRow = (itemForCellAtNewLocation) ? [self indexPathForItem:itemForCellAtNewLocation onlyVisible:NO].row : [[items_ objectAtIndex:destinationVisibleIndexPath.section] count] + 1;
    for (int i = realRowAboveNewLocationRow; i < realRowAtNewLocationRow; i++) {
        [possibleIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:destinationVisibleIndexPath.section]];
    }
    if ([possibleIndexPaths count] > 1)
    {
        destinationIndexPath = [movingItem selectNewIndexPathFromIndexPaths:possibleIndexPaths];
        NSAssert(destinationIndexPath,@"selectNewIndexPathFromIndexPaths: must not return nil"); 
    }
    else 
    {
        destinationIndexPath = [possibleIndexPaths anyObject];
    }
    
    NSAssert([possibleIndexPaths count] > 0,@"GTTableView error");
    
    NSMutableArray *sourceSection = (NSMutableArray*)[items_ objectAtIndex:sourceIndexPath.section];
    NSMutableArray *destinationSection = (NSMutableArray*)[items_ objectAtIndex:destinationIndexPath.section];
    
    /**
     Remove object at source index path, insert at new index path, notify items whoms index paths changed and and update cached index paths
     */
    NSMutableSet *itemsToNotifyOfMove = [NSMutableSet set];
    if (sourceSection != destinationSection) 
    {
        for (int i = sourceIndexPath.row; i < [sourceSection count]; i++) [itemsToNotifyOfMove addObject:[sourceSection objectAtIndex:i]];
        for (int i = destinationIndexPath.row; i < [destinationSection count]; i++)  [itemsToNotifyOfMove addObject:[destinationSection objectAtIndex:i]];
    }
    else
    {
        NSInteger lowest = MIN(sourceIndexPath.row, destinationIndexPath.row);
        NSInteger highest = MAX(sourceIndexPath.row, destinationIndexPath.row);
        for (int i = lowest; i <= highest; i++) [itemsToNotifyOfMove addObject:[sourceSection objectAtIndex:i]];
    }
    
    if (sourceSection != destinationSection) [movingItem sectionWillMove];
    for (GTTableViewItem *item in itemsToNotifyOfMove) [item rowWillMove];
    
    [sourceSection removeObjectAtIndex:sourceIndexPath.row];
    [destinationSection insertObject:movingItem atIndex:destinationIndexPath.row];
    [self updateCachedIndexPaths_];

    if (sourceSection != destinationSection) [movingItem sectionDidMove];
    for (GTTableViewItem *item in itemsToNotifyOfMove) [item rowDidMove];
    
    
}

#pragma mark - TableView Delegate -

#pragma mark Configuring Rows for the TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item height];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item indentationLevel];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /**< do nothing - because of the GTTableView design all cell setup will be done in tableView:cellForRowAtIndexPath:. */
}

#pragma mark Managing Accessory Views

- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    [item accessoryButtonTapped];
}

/**< tableView:accessoryTypeForRowWithIndexPath: deprecated in iOS 3.0. */

#pragma mark Managing Selections

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item willBecomeSelected];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    if (item.target && item.action)
    {
        [item.target performSelector:item.action withObject:item];
    }
    [item didBecomeSelecected];
}

- (NSIndexPath*)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item willBecomeDeselected];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    [item didBecomeDeselected];
}

#pragma mark Modifying the Header and Footer of Sections

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    GTTableViewHeaderItem *headerItem = [self tableViewHeaderItemForSection:section];
    return [headerItem view];
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    GTTableViewFooterItem *footerItem = [self tableViewFooterItemForSection:section];
    return [footerItem view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    GTTableViewHeaderItem *headerItem = [self tableViewHeaderItemForSection:section];
    NSString *sectionHeader = [[self sectionIndexTitlesForTableView:tableView] objectAtIndex:section];
    if (sectionHeader) return 32;
    return [headerItem height];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    GTTableViewFooterItem *footerItem = [self tableViewFooterItemForSection:section];
    return [footerItem height];
    
}

#pragma mark Editing Table Rows

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath 
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    [item willBeginEditing];
}

- (void)tableView:(UITableView *)tableView didBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    [item didEndEditing];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item editingStyle];
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item deleteConfirmationTitle];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item shouldIndentWhileEditing];
}

#pragma mark Reodering Table Rows

- (NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    GTTableViewItem *item = [self itemForRowAtIndexPath:sourceIndexPath];
    return [item shouldMoveFromVisibleIndexPath:sourceIndexPath toVisibleIndexPath:proposedDestinationIndexPath];
}

@end
