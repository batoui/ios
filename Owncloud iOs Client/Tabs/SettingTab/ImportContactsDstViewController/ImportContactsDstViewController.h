//
//  ImportContactsDstViewController.h
//  Owncloud iOs Client
//
//  Created by Bilal on 07/07/2015.
//
//

#import <UIKit/UIKit.h>

@interface ImportContactsDstViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    UIBarButtonItem *doneButton;
}

@property(nonatomic, retain) NSArray *sources;
@property(nonatomic, retain) NSArray *choosedSources;
@property(nonatomic, retain) NSMutableArray *filteredDestinations;

@end
