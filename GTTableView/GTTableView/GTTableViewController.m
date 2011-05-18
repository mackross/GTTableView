//
//  GTTableViewController.m
//  GTTableView
//
//  Created by Andrew Mackenzie-Ross on 18/05/11.
//  Copyright 2011 mackross.net. All rights reserved.
//



#import "GTTableViewController.h"

@interface GTTableViewController ()
@end

@implementation GTTableViewController
@synthesize tableView=tableView_;
- (void)viewDidUnload
{
    self.tableView = nil;
    [super viewDidUnload];
}
- (void)dealloc {
    [tableView_ setGTTableViewDelegate:nil];
    [tableView_ release];
    [super dealloc];
}
- (void) loadView
{
    [super loadView];
    if (!self.tableView)
    {
        self.tableView = [[[GTTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
        self.view = self.tableView;
    }
    if (!self.tableView.delegate)
    {
        [self.tableView setGTTableViewDelegate:self];   
    }
    
}
- (void)viewDidAppear:(BOOL)animated {
    [self.tableView viewDidAppear:animated];
    [super viewDidAppear:animated];
}
- (UINavigationController *)navigationControllerForTableView:(GTTableView *)tableView
{
    return [self navigationController];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.tableView viewWillDisappear:animated];
    [super viewWillDisappear:animated];
}
@end
