//
//  ImportContactsSourceViewController.h
//  Owncloud iOs Client
//
//  Created by Bilal on 06/07/2015.
//
//

#import <UIKit/UIKit.h>

@interface ImportContactsSourceViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate> {
    
    UIBarButtonItem *nextButton;
}

@property(nonatomic, retain) NSArray *sources;
@property(nonatomic, retain) NSMutableArray *filteredSources;

@end
