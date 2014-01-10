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
#import "NSMutableArray+PositionCompare.h"
#import "GradientLayer.h"

@interface GTGradientView_ : UIView 
@property (nonatomic, readonly, retain) CAGradientLayer *layer;
@end
@implementation GTGradientView_
@dynamic layer;
+(Class)layerClass
{
    return [CAGradientLayer class];
}
@end

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

- (void)commitUpdates_;
- (void)updateInternalCachedIndexPaths_;
- (void)updateGradientFrames_;

- (void)hideItem_:(GTTableViewItem*)item;
- (void)showItem_:(GTTableViewItem*)item;

- (void)setup_;
- (void)tearDownItems_;
- (void)tearDownHeaderItems_;
- (void)teardownFooterItems_;
- (void)tearDownCells_;

- (void)beginKeyboardMonitoring_;
- (void)endKeyboardMonitoring_;
- (void)keyboardWillShow_:(NSNotification*)notification;
- (void)keyboardWillHide_:(NSNotification*)notification;
- (UIView*)findFirstResponderWithinView_:(UIView*)view;
- (void)hideKeyboard_:(UIGestureRecognizer*)gestureRecognizer;
- (void)addGestureRecognizers_;
- (void)removeGestureRecognizers_;

@property (nonatomic, assign, getter = isResizedForKeyboard) BOOL resizedForKeyboard;
@property (nonatomic, assign) CGFloat frameChangeOffset;
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
@synthesize updating = updating_;
@synthesize insertAnimation = insertAnimation_;
@synthesize deleteAnimation = deleteAnimation_;
@synthesize resizedForKeyboard=resizedForKeyboard_;
@synthesize frameChangeOffset=frameChangeOffset_;
@synthesize autoFocusScrollPosition=autoFocusScrollPosition_;
@synthesize dismissKeyboardOnTouchOutside=dismissKeyboardOnTouchOutside_;
@synthesize dismissKeyboardOnScroll=dismissKeyboardOnScroll_;
@synthesize monitoringKeyboard=monitoringKeyboard_;
@synthesize bottomGradientShouldStartOnLastCell;
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
    self = [super initWithFrame:frame style:style];
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
    defaultCellStyle_ = UITableViewCellStyleDefault;
    defaultCellEditingStyle_ = UITableViewCellEditingStyleDelete;
    defaultCellAccessoryType_ = UITableViewCellAccessoryNone;
    defaultCellEditingAccessoryType_ = UITableViewCellAccessoryNone;
    defaultCellSelectionStyle_ = UITableViewCellSelectionStyleBlue;
    insertAnimation_ = UITableViewRowAnimationRight;
    deleteAnimation_ = UITableViewRowAnimationRight;
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
    updating_ = NO;
}

- (void)dealloc 
{
    if (monitoringKeyboard_) [self endKeyboardMonitoring_];
    GTTableViewDelegate_ = nil;
    self.delegate = nil;
    self.dataSource = nil;
    
    [self tearDownHeaderItems_];
    [self teardownFooterItems_];
    [self tearDownItems_];
    [self tearDownCells_];
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
       if ((id)headerItem != [NSNull null]) [headerItem setTableView:nil];
    }
}

- (void)teardownFooterItems_
{
    for (GTTableViewFooterItem *footerItem in footerItems_) 
    {
       if ((id)footerItem != [NSNull null]) [footerItem setTableView:nil];
    }
}

- (void)tearDownCells_
{
    for (GTTableViewCell *cell in cells_)
    {
        [cell setTableView:nil];
    }
}

- (void) layoutSubviews 
{
    [super layoutSubviews];
    [self updateGradientFrames_];
}

#pragma mark - Keyboard Handling -
#define PADDING 5

- (void)viewDidAppear:(BOOL)animated 
{
    if ([self indexPathForSelectedRow])
    {
        [self deselectRowAtIndexPath:[self indexPathForSelectedRow] animated:animated];
    }
    [self flashScrollIndicators];

}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)setDismissKeyboardOnScroll:(BOOL)dismissKeyboardOnScroll 
{
    dismissKeyboardOnScroll_ = dismissKeyboardOnScroll;
    [self removeGestureRecognizers_];
    [self addGestureRecognizers_];
}
- (void)setDismissKeyboardOnTouchOutside:(BOOL)dismissKeyboardOnTouchOutside
{
    dismissKeyboardOnTouchOutside_=dismissKeyboardOnTouchOutside;
    [self removeGestureRecognizers_];
    [self addGestureRecognizers_];
}

///
// monitoring keyboard property

- (BOOL)isMonitoringKeyboard 
{
    return monitoringKeyboard_;
}

- (void)setMonitoringKeyboard:(BOOL)monitoringKeyboard 
{
    if (monitoringKeyboard && !monitoringKeyboard_)
    {
        [self beginKeyboardMonitoring_];
    }
    else if (!monitoringKeyboard && monitoringKeyboard_)
    {
        [self endKeyboardMonitoring_];
        
        if (self.frameChangeOffset != 0)
        {
            // reverse any frame changes if monitoring is turned off
            CGRect myFrame = [self convertRect:self.bounds toView:self.superview];
            CGRect oldFrame = myFrame;
            oldFrame.size.height += self.frameChangeOffset;
            self.frame = oldFrame;
            
        }
    }
    monitoringKeyboard_ = monitoringKeyboard;
}

///
// notification setup

- (void)beginKeyboardMonitoring_ 
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow_:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide_:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)endKeyboardMonitoring_ 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

///
// notification handling

- (void)keyboardWillShow_:(NSNotification *)notification 
{
    UIView *firstResponder = [self findFirstResponderWithinView_:self];
    
    if (firstResponder == nil) 
    {
        // do nothing if no first responder in the scroll view.
        return;
    }
    
    // these are adjusted with converRect:toView: which makes origin 0,0 of the superview the reference point
    CGRect keyboardFrame = [self.window convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.superview];
    CGRect myFrame = [self convertRect:self.bounds toView:self.superview];
    CGRect newFrame = myFrame;
    self.frameChangeOffset = (myFrame.size.height + myFrame.origin.y) - keyboardFrame.origin.y;
    
    if (self.frameChangeOffset <= 0) 
    {
        // do nothing except set the frameChangeOffset to 0 otherwise it will make frame smaller when the keyboardWillHide: method is called later.
        self.frameChangeOffset = 0;
        return;
    }
    
    // change the frame size (height) of the scroll view so that the keyboard is not covering any of the frame.
    // we then save this value in the private property frameChangeOffset so that later we can reverse the change in the keyboardWillHide: method.
    // we animate this change using the same settings as used by the keyboard animation. this will make everything work nicely.
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    newFrame.size.height -= self.frameChangeOffset;
    self.frame = newFrame;
    
    // auto focus on first responder
    [self autoFocusOnView:firstResponder WithAutoScrollPosition:self.autoFocusScrollPosition];
    
    
    [UIView commitAnimations];
    
    [self addGestureRecognizers_];
    
}

- (void)keyboardWillHide_:(NSNotification *)notification 
{
    
    CGRect myFrame = [self convertRect:self.bounds toView:self.superview];
    CGRect newFrame = myFrame;
    
    // we reverse the frame change that occured in the keyboardWillShow: method. 
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    newFrame.size.height += self.frameChangeOffset;
    self.frame = newFrame;
    
    // if contentSize is same size or smaller as newFrame lets put it in the top left
    if (self.contentSize.height <= newFrame.size.height) 
    {
        [self setContentOffset:CGPointMake(self.contentOffset.x, 0) animated:YES];
    }
    
    [UIView commitAnimations];
    
    // set frameChangeOffset to 0 to reset the state of the monitor.
    self.frameChangeOffset = 0;
    
}

///
// auto focus

- (void)autoFocusOnView:(UIView*)view WithAutoScrollPosition:(GTTableViewAutoFocusScrollPosition)scrollPosition
{
    // we now position the first responder in the location specified by AutoFocusScrollPosition
    CGRect firstResponderFrame = [view convertRect:view.bounds toView:self];
    CGRect myFrame = self.frame;
    
    if (firstResponderFrame.size.height + (PADDING*2) < myFrame.size.height) 
    {
        // we will only move the content offset if the first responder is smaller than the new scrollview. otherwise the user experience feels jared.
        if (scrollPosition == GTTableViewAutoFocusScrollPositionNone) {
            // do nothing
        }
        if (scrollPosition == GTTableViewAutoFocusScrollPositionTop) 
        {
            [self setContentOffset:CGPointMake(self.contentOffset.x, firstResponderFrame.origin.y - PADDING) animated:YES];
        }
        if (scrollPosition == GTTableViewAutoFocusScrollPositionBottom) 
        {
            CGFloat currentLocation = firstResponderFrame.origin.y + firstResponderFrame.size.height;
            if (currentLocation > myFrame.size.height + self.contentOffset.y) {
                CGFloat proposedLocation = firstResponderFrame.origin.y + firstResponderFrame.size.height + PADDING - myFrame.size.height;
                [self setContentOffset:CGPointMake(self.contentOffset.x, proposedLocation) animated:YES];
            }
        }
        if (scrollPosition == GTTableViewAutoFocusScrollPositionProportional)
        {
            // this is the default mode and it uses a factor to move the scroller to a height
            CGFloat verticalCenterFirstResponder = firstResponderFrame.origin.y + (firstResponderFrame.size.height / 2.0);
            CGFloat positionRatio = verticalCenterFirstResponder / self.contentSize.height;
            
            CGFloat flip = floor(positionRatio * 2 - 1);
            CGFloat proposedLocation = verticalCenterFirstResponder - (myFrame.size.height * positionRatio) + (flip * PADDING) + (flip * firstResponderFrame.size.height);
            
            proposedLocation = floor(proposedLocation);
            
            // 3.0 means that anything in the top third of the new frame doesn't move.
            CGFloat noMovePoint = myFrame.size.height / 3.0;
            
            if (verticalCenterFirstResponder - proposedLocation < noMovePoint)
            {
                proposedLocation = 0.0;
            }
            
            // now we check if the content offset will push the scrollview further up than it should go.
            if (proposedLocation < 0)
            {
                proposedLocation = 0.0;
            }
            if (proposedLocation > self.contentSize.height - myFrame.size.height)
            {
                proposedLocation = self.contentSize.height - myFrame.size.height;
            }
            
            // commit the product of these calculations
            [self setContentOffset:CGPointMake(self.contentOffset.x, proposedLocation) animated:YES];
            
        }
    }
}

- (UIView*)findFirstResponderWithinView_:(UIView*)view 
{
    // search recursively for first responder
    for ( UIView *childView in view.subviews ) 
    {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderWithinView_:childView];
        if ( result ) return result;
    }
    return nil;
}

///
// keyboard hiding

- (void) addGestureRecognizers_
{
    if (self.frameChangeOffset == 0) return;
    if (!tapGestureRecognizer_&&dismissKeyboardOnTouchOutside_)
    {
        tapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard_:)];
        tapGestureRecognizer_.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapGestureRecognizer_];
    }

    
}

- (void)removeGestureRecognizers_
{
    [self removeGestureRecognizer:tapGestureRecognizer_];
    tapGestureRecognizer_ = nil;
}
- (void)hideKeyboard_:(UIGestureRecognizer*)gestureRecognizer
{
    [self removeGestureRecognizers_];
    [[self findFirstResponderWithinView_:self] resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (dismissKeyboardOnScroll_)
        [self hideKeyboard_:nil];
}

#pragma mark - GTTableView Methods -
#pragma mark Internal
- (void)beginItemUpdates {
    [super beginUpdates];

    updating_ = YES;
    
    updates_ = nil;
    updates_ = [[NSMutableArray alloc] init];
    for (NSMutableArray *sectionItems in items_)
    {
        NSMutableArray *copyOfSectionItems = [sectionItems mutableCopy];
        [updates_ addObject:copyOfSectionItems];
    }
    
    insertedSections_ = nil;
    deletedSections_ = nil;
    insertedSections_ = [[NSMutableIndexSet alloc] init];
    deletedSections_ = [[NSMutableIndexSet alloc] init];
    
    itemsMadeVisible_ = nil;
    itemsMadeHidden_ = nil;
    itemsMadeVisible_ = [[NSMutableSet alloc] init];
    itemsMadeHidden_ = [[NSMutableSet alloc] init];
    
}
- (void)endItemUpdates {
    [self commitUpdates_];
    [super endUpdates];

    updating_ = NO;
    
    insertedSections_ = nil;
    deletedSections_ = nil;
    
    itemsMadeVisible_ = nil;
    itemsMadeHidden_ = nil;
    
    [self updateGradientFrames_];
}
- (void)commitUpdates_;
{
    if (!updating_)
    {
        return;
    }
 //   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    /* Update Sections. */

    [self deleteSections:deletedSections_ withRowAnimation:self.deleteAnimation];
    [self insertSections:insertedSections_ withRowAnimation:self.insertAnimation];

    /* Find out what items have been moved, inserted, or deleted. */

    NSMutableArray *orderedItemsBefore = [NSMutableArray array];
    NSMutableArray *orderedItemsAfter = [NSMutableArray array];
    
    for (NSArray *sectionItems in items_) [orderedItemsBefore addObjectsFromArray:sectionItems];
    for (NSArray *sectionItems in updates_) [orderedItemsAfter addObjectsFromArray:sectionItems];
   // for (NSArray *sectionItems in items_) //NSLog(@"%@",sectionItems);
   // for (NSArray *sectionItems in updates_) //NSLog(@"%@",sectionItems);

    NSSet *itemsBefore = [NSSet setWithArray:orderedItemsBefore];
    NSSet *itemsAfter = [NSSet setWithArray:orderedItemsAfter];
    
    
    NSMutableSet *insertedItems = [itemsAfter mutableCopy];
    [insertedItems minusSet:itemsBefore];
    
    NSMutableSet *deletedItems = [itemsBefore mutableCopy];
    [deletedItems minusSet:itemsAfter];

    
    NSMutableArray *unmovedItems = [NSMutableArray array];
    
    NSInteger beforeCount = [items_ count];
    NSInteger afterCount = [updates_ count];
    NSInteger minNumberOfSections = MIN(beforeCount,afterCount);

    
    for (int section = 0; section < minNumberOfSections; section++)
    {
        NSArray *array1 = [items_ objectAtIndex:section];
        NSArray *array2 = [updates_ objectAtIndex:section];
        [unmovedItems addObjectsFromArray:array1 withIdenticalObjectsAtIdenticalIndexesInArray:array2];
    }
    
    NSMutableSet *movedItems = [itemsAfter mutableCopy];
    [movedItems minusSet:[NSSet setWithArray:unmovedItems]];
    [movedItems minusSet:insertedItems];
    [movedItems minusSet:deletedItems];
    
    /* Notify those objects and commit changes. */
    for (GTTableViewItem *movedItem in movedItems) [movedItem itemWillMove];
    for (GTTableViewItem *insertedItem in insertedItems) [insertedItem itemWillInsert];
    for (GTTableViewItem *deletedItem in deletedItems) [deletedItem itemWillRemove];
    
    

    
    NSMutableArray *insertIndexPaths = [NSMutableArray array];
    NSMutableArray *deleteIndexPaths = [NSMutableArray array];
    
    for (GTTableViewItem *deletedItem in deletedItems)  if (deletedItem.visible) [deleteIndexPaths addObject:[self indexPathForItem:deletedItem]];
    
    
    /* The move animation is handled by the user moving the cell. */
    items_ = nil;
    items_ = [updates_ mutableCopy];
    items_ = (items_) ? items_ :  [NSMutableArray array];
    
    NSMutableArray *indexPathsToHide = [NSMutableArray array]; /* Must be done before udpating cached index paths. */
    for (GTTableViewItem *itemToHide in itemsMadeHidden_) [indexPathsToHide addObject:[self indexPathForItem:itemToHide]];


    [self updateInternalCachedIndexPaths_]; /* This will update values for numberOfItems, numberOfRowsInSection, etc. */
    
    

    
    /* Update visible items. */
    NSMutableArray *indexPathsToUnhide = [NSMutableArray array];
    for (GTTableViewItem *itemToUnhide in itemsMadeVisible_) [indexPathsToUnhide addObject:[self indexPathForItem:itemToUnhide]];
    for (GTTableViewItem *insertedItem in insertedItems) if (insertedItem.visible) [insertIndexPaths addObject:[self indexPathForItem:insertedItem]];

    [self deleteRowsAtIndexPaths:indexPathsToHide withRowAnimation:self.deleteAnimation];
    [self insertRowsAtIndexPaths:indexPathsToUnhide withRowAnimation:self.insertAnimation]; 
    
    [self insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:self.insertAnimation];
    [self deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:self.deleteAnimation];


    for (GTTableViewItem *movedItem in movedItems) [movedItem itemDidMove];
    for (GTTableViewItem *insertedItem in insertedItems) [insertedItem itemDidInsert];
    for (GTTableViewItem *deletedItem in deletedItems) [deletedItem itemDidRemove];

 //   [pool drain];
    
}

- (void)showItem_:(GTTableViewItem *)item
{
    if (!item.visible)
        [itemsMadeVisible_ addObject:item];
}

- (void)hideItem_:(GTTableViewItem *)item
{
    if (item.visible)
        [itemsMadeHidden_ addObject:item];
}

- (void)updateInternalCachedIndexPaths_ 
{
    [cachedIndexPaths_ removeAllObjects];
    [cachedVisibleIndexPaths_ removeAllObjects];
    [cachedIndexPathsAndItems_ removeAllObjects];
    [cachedVisibleIndexPathsAndItems_ removeAllObjects];
    [itemsAndCachedIndexPaths_ removeAllObjects];
    [itemsAndCachedVisibleIndexPaths_ removeAllObjects];
    
    @autoreleasepool {
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
    }
}

- (void)updateGradientFrames_
{
    CGFloat topOfTopFooterGradient =  (bottomGradientShouldStartOnLastCell) ? self.contentSize.height : MAX(self.contentSize.height,self.bounds.size.height);
    headerGradientBottom_.frame = CGRectMake(0, -headerGradientBottom_.frame.size.height - headerPadding_,  self.bounds.size.width, headerGradientBottom_.frame.size.height);
    headerGradientTop_.frame = CGRectMake(0,  self.contentOffset.y , self.bounds.size.width, MAX(MIN(-self.contentOffset.y-headerPadding_,headerGap_), 0.0));
    footerGradientTop_.frame = CGRectMake(0, topOfTopFooterGradient + footerPadding_, self.bounds.size.width, footerGradientTop_.frame.size.height);
    footerGradientBottom_.frame = CGRectZero;

    CGFloat bottomOfPlate = MAX(self.contentSize.height,self.bounds.size.height) + footerPadding_;
    CGFloat bottomOfContainer =  MAX(self.contentSize.height,self.bounds.size.height+ self.contentOffset.y) ;
 
    CGFloat heightOfBottom = MAX(MIN(footerGap_, bottomOfContainer-bottomOfPlate),0.0);
    footerGradientBottom_.frame = CGRectMake(0, bottomOfContainer-heightOfBottom,self.bounds.size.width, heightOfBottom);
    headerGradientTop_.alpha = 1.0;
    headerGradientBottom_.alpha = 1.0;
    footerGradientTop_.alpha = 1.0;
    footerGradientBottom_.alpha = 1.0;
    
}

- (void)reloadData {
    [self updateInternalCachedIndexPaths_];
    [super reloadData];
    [self updateGradientFrames_];
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
- (void) refreshVisibleCells
{
    for (GTTableViewItem *item in [self items])
    {
        [item configureCell:item.cell];
    }
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
    return [items copy];
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
    return [items copy];
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

- (void)insertSectionAtIndex:(NSInteger)index
{
    NSMutableArray *data = (updating_) ? updates_ : items_;
    [data insertObject:[NSMutableArray array] atIndex:index];
    [insertedSections_ addIndex:index];
    if ([self isUpdating])
    [headerItems_ insertObject:[NSNull null] atIndex:index];
}

- (void)removeSectionAtIndex:(NSInteger)index
{
    NSMutableArray *data = (updating_) ? updates_ : items_;
    [data removeObjectAtIndex:index];
    [deletedSections_ addIndex:index];
    if ([self isUpdating])
    [headerItems_ removeObjectAtIndex:index];
}

- (void)removeAllSections
{
    if (updating_) 
    {
        for (int i = 0; i < [self numberOfItemSections]; i++) [deletedSections_ addIndex:i];
        [updates_ removeAllObjects];
    }
    else
    {
        [items_ removeAllObjects];
    }
}
- (void)appendItem:(GTTableViewItem*)item section:(NSInteger)section
{
    
    [self insertItem:item atIndexPath:[NSIndexPath indexPathForRow:[[items_ objectAtIndex:section] count] inSection:section] onlyVisible:NO];
}
- (void)appendItems:(NSArray *)items section:(NSInteger)section
{
    for (GTTableViewItem *item in items) [self appendItem:item section:section];
}
- (void)insertItem:(GTTableViewItem*)item atIndexPath:(NSIndexPath *)indexPath
{
    [self insertItem:item atIndexPath:indexPath  onlyVisible:YES];
}

- (void)insertItem:(GTTableViewItem*)item atIndexPath:(NSIndexPath *)indexPath onlyVisible:(BOOL)visible
{
    [item setTableView:self];
    /* Convert visible to invisible. */
    if (visible)
    {
        /* Find the correct row to go to. */
        GTTableViewItem *itemForCellAboveNewLocation = [self itemForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section] onlyVisible:YES];
        GTTableViewItem *itemForCellAtNewLocation = [self itemForRowAtIndexPath:indexPath onlyVisible:YES];    
        NSMutableSet *possibleIndexPaths = [NSMutableSet set];
        NSInteger realRowAboveNewLocationRow = (itemForCellAboveNewLocation) ? [self indexPathForItem:itemForCellAboveNewLocation onlyVisible:NO].row : -1;
        NSInteger realRowAtNewLocationRow = (itemForCellAtNewLocation) ? [self indexPathForItem:itemForCellAtNewLocation onlyVisible:NO].row : [[items_ objectAtIndex:indexPath.section] count];
        for (int i = realRowAboveNewLocationRow + 1; i <= realRowAtNewLocationRow; i++) {
            [possibleIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        }
        //NSLog(@"%@",possibleIndexPaths);
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
    /* Insert items and notify items that moved. */
    NSMutableArray *data = (updating_) ? updates_ : items_;

    NSMutableArray *destinationSection = (NSMutableArray*)[data objectAtIndex:indexPath.section];    
    
    [destinationSection insertObject:item atIndex:indexPath.row];
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeItemAtIndexPath:indexPath onlyVisible:YES];
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath onlyVisible:(BOOL)visible
{
    /* Convert visible to invisible. */
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    if (visible)
        indexPath = [self indexPathForItem:item onlyVisible:NO];
    
    /* Remove items. */
    NSMutableArray *data = (updating_) ? updates_ : items_;

    NSMutableArray *sourceSection = [data objectAtIndex:indexPath.section];
    [sourceSection removeObjectAtIndex:indexPath.row];
}

#pragma mark Header & Footer Items
/*
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

#pragma mark Customising
- (void) setBottomGradientHeaderViewWithHeight:(CGFloat)height colors:(NSArray *)colors locations:(NSArray *)locations padding:(CGFloat)padding
{
    if (!height)
    {
        [headerGradientBottom_ removeFromSuperview];
        headerGradientBottom_ = nil;
        headerPadding_ = 0;
        return;
    }
    colors = (colors) ? colors : [NSArray arrayWithObjects:[UIColor colorWithWhite:0.0 alpha:0.6],[UIColor colorWithWhite:0.0 alpha:0.2],[UIColor colorWithWhite:0.0 alpha:0.0], nil];
    locations = (locations) ? locations : [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.1],[NSNumber numberWithFloat:1.0], nil];
    CGRect newFrame = CGRectMake(0, 0, self.bounds.size.width, height);
    headerGradientBottom_ = (headerGradientBottom_) ? headerGradientBottom_ : [[GTGradientView_ alloc] initWithFrame:newFrame];
    headerGradientBottom_.opaque = NO;
    headerGradientBottom_.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *layer = headerGradientBottom_.layer;
    NSMutableArray *array = [NSMutableArray array];
    for (UIColor *color in colors) [array addObject:(id)[color CGColor]];
    layer.colors = array;
    layer.locations = locations;
    layer.endPoint = CGPointMake(0.5,0.0);
    layer.startPoint = CGPointMake(0.5, 1.0);
    [self insertSubview:headerGradientBottom_ belowSubview:self];
    [self updateGradientFrames_];
    headerPadding_ = padding;
}

- (void) setTopGradientFooterViewWithHeight:(CGFloat)height colors:(NSArray *)colors locations:(NSArray *)locations padding:(CGFloat)padding
{
    if (!height)
    {
        [footerGradientTop_ removeFromSuperview];
        footerGradientTop_ = nil;
        footerPadding_ = 0;
    }
    colors = (colors) ? colors : [NSArray arrayWithObjects:[UIColor colorWithWhite:0.0 alpha:0.7],[UIColor colorWithWhite:0.0 alpha:0.3],[UIColor colorWithWhite:0.0 alpha:0.0], nil];
    locations = (locations) ? locations : [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.1],[NSNumber numberWithFloat:1.0], nil];
    CGRect newFrame = CGRectMake(0, 0, self.bounds.size.width, height);
    footerGradientTop_ = (footerGradientTop_) ? footerGradientTop_ : [[GTGradientView_ alloc] initWithFrame:newFrame];
    footerGradientTop_.opaque = NO;
    footerGradientTop_.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *layer = footerGradientTop_.layer;
    NSMutableArray *array = [NSMutableArray array];
    for (UIColor *color in colors) [array addObject:(id)[color CGColor]];
    layer.colors = array;
    layer.locations = locations;
    layer.startPoint = CGPointMake(0.5,0.0);
    layer.endPoint = CGPointMake(0.5, 1.0);

    [self insertSubview:footerGradientTop_ belowSubview:self];
    [self updateGradientFrames_];
    footerPadding_ = padding;
}
- (void) setTopGradientHeaderViewWithHeight:(CGFloat)height colors:(NSArray *)colors locations:(NSArray *)locations
{
    if (!height)
    {
        [headerGradientTop_ removeFromSuperview];
        footerGradientTop_ = nil;
        headerGap_ = 0;
    }
    colors = (colors) ? colors : [NSArray arrayWithObjects:[UIColor colorWithWhite:0.0 alpha:0.7],[UIColor colorWithWhite:0.0 alpha:0.4],[UIColor colorWithWhite:0.0 alpha:0.0], nil];
    locations = (locations) ? locations : [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.1],[NSNumber numberWithFloat:1.0], nil];
    CGRect newFrame = CGRectMake(0, 0, self.bounds.size.width, height);
    headerGradientTop_ = (headerGradientTop_) ? headerGradientTop_ : [[GTGradientView_ alloc] initWithFrame:newFrame];
    headerGradientTop_.opaque = NO;
    headerGradientTop_.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *layer = headerGradientTop_.layer;
    NSMutableArray *array = [NSMutableArray array];
    for (UIColor *color in colors) [array addObject:(id)[color CGColor]];
    layer.colors = array;
    layer.locations = locations;
    layer.startPoint = CGPointMake(0.5,0.0);
    layer.endPoint = CGPointMake(0.5, 1.0);
    
    [self insertSubview:headerGradientTop_ belowSubview:self];
    [self updateGradientFrames_];
    headerGap_ = height;
}
- (void) setBottomGradientFooterViewWithHeight:(CGFloat)height colors:(NSArray*)colors locations:(NSArray*)locations
{
    if (!height)
    {
        [footerGradientBottom_ removeFromSuperview];
        footerGradientTop_ = nil;
        footerGap_ = 0;
    }
    colors = (colors) ? colors : [NSArray arrayWithObjects:[UIColor colorWithWhite:0.0 alpha:0.4],[UIColor colorWithWhite:0.0 alpha:0.08],[UIColor colorWithWhite:0.0 alpha:0.0], nil];
    locations = (locations) ? locations : [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.1],[NSNumber numberWithFloat:1.0], nil];
    CGRect newFrame = CGRectMake(0, 0, self.bounds.size.width, height);
    footerGradientBottom_ = (footerGradientBottom_) ? footerGradientBottom_ : [[GTGradientView_ alloc] initWithFrame:newFrame];
    footerGradientBottom_.opaque = NO;
    footerGradientBottom_.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *layer = footerGradientBottom_.layer;
    NSMutableArray *array = [NSMutableArray array];
    for (UIColor *color in colors) [array addObject:(id)[color CGColor]];
    layer.colors = array;
    layer.locations = locations;
    layer.endPoint = CGPointMake(0.5,0.0);
    layer.startPoint = CGPointMake(0.5, 1.0);
    
    [self insertSubview:footerGradientBottom_ belowSubview:self];
    [self updateGradientFrames_];
    footerGap_ = height;
}
#pragma mark - TableView Datasource -
#pragma mark Configuring a TableView

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    NSAssert(item,@"Has to return an item...");
    GTTableViewCell *cell = (GTTableViewCell*)[self dequeueReusableCellWithIdentifier:[[item class] reuseIdentifier]];
    if (!cell)
    {
        cell = [item newTableViewCell];
        [cell setTableView:self];
    }
    [cell prepareCellForReuseForItem_:item];
    [item configureCell:cell];
    NSAssert(cell,@"Has to return a cell...");
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    //NSLog(@"%i sections in tableview",[self numberOfItemSections]);
    return [self numberOfItemSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%i rows in section %i",[self numberOfItemsInSection:section],section);
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
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            if ([[self itemForRowAtIndexPath:indexPath] commitDelete])
            {
                [self beginItemUpdates];
                [self removeItemAtIndexPath:indexPath];
                [self endItemUpdates];
            }
            break;
        case UITableViewCellEditingStyleInsert:
            [[self itemForRowAtIndexPath:indexPath] commitInsert]; /* The item is responsible for inserting a new item or section or making something visible. */
            break;
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item canEdit];
}

#pragma mark Reordering Table Rows
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item canMove];  
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceVisibleIndexPath toIndexPath:(NSIndexPath *)destinationVisibleIndexPath
{
	sourceVisibleIndexPath = [NSIndexPath indexPathForRow:sourceVisibleIndexPath.row inSection:sourceVisibleIndexPath.section];
	destinationVisibleIndexPath = [NSIndexPath indexPathForRow:destinationVisibleIndexPath.row inSection:destinationVisibleIndexPath.section];

    if ([sourceVisibleIndexPath compare:destinationVisibleIndexPath] == NSOrderedSame) return;
    
    /*
     Calculate possible invisible indexes if they exist and ask the item its preferred destination if more than one exits.
     */
    GTTableViewItem *movingItem = [self itemForRowAtIndexPath:sourceVisibleIndexPath onlyVisible:YES];
    NSIndexPath *sourceIndexPath = [self indexPathForItem:movingItem onlyVisible:NO];
    NSIndexPath *destinationIndexPath = nil;
    GTTableViewItem *itemForCellAboveNewLocation = [self itemForRowAtIndexPath:[NSIndexPath indexPathForRow:(destinationVisibleIndexPath.row - 1) inSection:destinationVisibleIndexPath.section] onlyVisible:YES];
    GTTableViewItem *itemForCellAtNewLocation = [self itemForRowAtIndexPath:destinationVisibleIndexPath onlyVisible:YES];    
    
    NSMutableSet *possibleIndexPaths = [NSMutableSet set];
    NSInteger realRowAboveNewLocationRow = (itemForCellAboveNewLocation) ? [self indexPathForItem:itemForCellAboveNewLocation onlyVisible:NO].row  : 0;
    NSInteger realRowAtNewLocationRow = (itemForCellAtNewLocation) ? [self indexPathForItem:itemForCellAtNewLocation onlyVisible:NO].row : [[items_ objectAtIndex:destinationVisibleIndexPath.section] count] + 1;
    for (int i = realRowAboveNewLocationRow + 1 ; i < realRowAtNewLocationRow + 1 ; i++) {
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
    
    NSMutableArray *sourceSection = (NSMutableArray*)[items_ objectAtIndex:sourceIndexPath.section];
    NSMutableArray *destinationSection = (NSMutableArray*)[items_ objectAtIndex:destinationIndexPath.section];
    
    /*
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
    
    [itemsToNotifyOfMove addObject:movingItem];
    for (GTTableViewItem *item in itemsToNotifyOfMove) [item itemWillMove];
    
    [sourceSection removeObjectAtIndex:sourceIndexPath.row];
    [destinationSection insertObject:movingItem atIndex:destinationIndexPath.row];
    if (!updating_)
    {
        [self updateInternalCachedIndexPaths_];
    }


    if (sourceSection != destinationSection) [movingItem itemDidMove];
    for (GTTableViewItem *item in itemsToNotifyOfMove) [item itemDidMove];
    
    
}

#pragma mark - TableView Delegate -

#pragma mark Configuring Rows for the TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item height];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item indentationLevel];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* do nothing - because of the GTTableView design all cell setup will be done in tableView:cellForRowAtIndexPath:. */
}

#pragma mark Managing Accessory Views

- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    [item accessoryButtonTapped];
    if (item.target && item.accessoryAction)
    {
        if ([item.target respondsToSelector:item.accessoryAction])
            [item.target performSelector:item.accessoryAction withObject:item];
    }
    
}

/* tableView:accessoryTypeForRowWithIndexPath: deprecated in iOS 3.0. */

#pragma mark Managing Selections

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item itemWillBecomeSelected];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    [item itemDidBecomeSelected];
    if (item.target && item.action)
    {
        if ([item.target respondsToSelector:item.action])
            [item.target performSelector:item.action withObject:item];
    }
}

- (NSIndexPath*)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item itemWillBecomeDeselected];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    [item itemDidBecomeDeselected];
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
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    [item willBeginEditing];
}

- (void)tableView:(UITableView *)tableView didBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    [item didEndEditing];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item editingStyle];
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item deleteConfirmationTitle];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    GTTableViewItem *item = [self itemForRowAtIndexPath:indexPath];
    return [item shouldIndentWhileEditing];
}

#pragma mark Reodering Table Rows

- (NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	sourceIndexPath = [NSIndexPath indexPathForRow:sourceIndexPath.row inSection:sourceIndexPath.section];
	proposedDestinationIndexPath = [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row inSection:proposedDestinationIndexPath.section];

	GTTableViewItem *item = [self itemForRowAtIndexPath:sourceIndexPath];
    return [item shouldMoveFromVisibleIndexPath:sourceIndexPath toVisibleIndexPath:proposedDestinationIndexPath];
}

@end
