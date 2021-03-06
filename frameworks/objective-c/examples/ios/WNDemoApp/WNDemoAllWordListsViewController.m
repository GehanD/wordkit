/*
 * Copyright Wordnik, Inc. 2010. All rights reserved.
 */

#import "WNDemoAllWordListsViewController.h"
#import "WNDemoModifyWordListViewController.h"
#import <Wordnik/WNAdditions.h>

@interface WNDemoAllWordListsViewController () <UITableViewDelegate, UITableViewDataSource>
@end

/**
 * Displays the user's word lists.
 */
@implementation WNDemoAllWordListsViewController

/**
 * Initialize a new demo catalog view controller.
 */
- (id) initWithWordnikClient: (WNClient *) client {
    if ((self = [super initWithNibName: nil bundle: nil]) == nil)
        return nil;
    
    self.navigationItem.title = @"Wordnik Lists";
    _client = [client retain];
    
    return self;
}

/**
 * @internal
 * Discard any references to retained subviews. This is called from both -dealloc and -viewDidUnload, and ensures
 * that references to subviews are not held after the primary view is discarded.
 */
- (void) discardSubviews {
    WNNilRelease(_tableView);
} 

- (void) dealloc {
    [self discardSubviews];    
    [_client release];
    [_wordListInfo release];
    
    [super dealloc];
}

// from UIViewController
- (void) viewDidAppear: (BOOL) animated {
    [super viewDidAppear: animated];

    [_client requestAllWordListInfoWithCompletionBlock: ^(NSArray *wordListInfo, NSError *error) {
        if (error != nil) {
            NSLog(@"Fetching word lists failed: %@", error);
            return;
        }

        [_wordListInfo release];
        _wordListInfo = [wordListInfo retain];
        
        
        [_tableView reloadData];
    }];
}

// from UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];

    _tableView.dataSource = self;
    _tableView.delegate = self;
}

// from UIViewController
- (void) viewDidUnload {
    [super viewDidUnload];
    
    /* The primary view has been unloaded, so discard any subview references */
    [self discardSubviews];
}

// from UIViewController
- (void) didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// from UIViewController
- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation {
    return YES;
}

// from UITableViewDelegate
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];

    /* Push a list management view */
    WNWordListInfo *info = [_wordListInfo objectAtIndex: indexPath.row];
    WNDemoModifyWordListViewController *vc = [[[WNDemoModifyWordListViewController alloc] initWithWordnikClient: _client 
                                                                                                 listIdentifier: info.identifier] autorelease];
    [self.navigationController pushViewController: vc animated: YES];
}

// from UITableViewDataSource
- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
    NSString *identifier = @"ListCell";
    
    /* Dequeue (or create) a cell */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: identifier] autorelease];
    }
    
    /* Configure the cell */
    WNWordListInfo *info = [_wordListInfo objectAtIndex: indexPath.row];
    cell.textLabel.text = info.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

// from UITableViewDataSource
- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
    return [_wordListInfo count];
}

@end
