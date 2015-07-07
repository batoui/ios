//
//  ImportContactsDstViewController.m
//  Owncloud iOs Client
//
//  Created by Bilal on 07/07/2015.
//
//

#import "ImportContactsDstViewController.h"

#include <AddressBook/AddressBook.h>

@interface ImportContactsDstViewController ()

@end

@implementation ImportContactsDstViewController

@synthesize sources, choosedSources, filteredDestinations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                               target:self
                                                               action:@selector(beginContactsCopy)];
    [doneButton setEnabled:NO];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.filteredDestinations = [self filterCardDavSources:self.sources];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredDestinations count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return NSLocalizedString(@"chooseContactDest", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactDstCell";
    UITableViewCell *cell;
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    NSArray *aDst = [self.filteredDestinations objectAtIndex:indexPath.row];
    
    NSString *type = [self getSourceStringType:[aDst objectAtIndex:0]];
    NSString *name = [aDst objectAtIndex:1];
    NSNumber *isDstChoosed = [aDst objectAtIndex:2];
    
    cell.textLabel.text = name;
    cell.detailTextLabel.text = type;
    if([isDstChoosed intValue] == 1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for(int i = 0; i < [self.filteredDestinations count]; i++) {
        
        NSMutableArray *aDst = [self.filteredDestinations objectAtIndex:i];
        [aDst replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:0]];
    }
    
    NSMutableArray *aDst = [self.filteredDestinations objectAtIndex:indexPath.row];
    [aDst replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:1]];
    
    [tableView reloadData];
    
    [doneButton setEnabled:YES];
    
}


-(NSMutableArray *) filterCardDavSources:(NSArray *) fromSources {
    
    NSMutableArray *choosedDst = [NSMutableArray arrayWithCapacity:10];
    
    for(int i = 0; i < [fromSources count]; i++) {
        
        NSArray *aSource = [fromSources objectAtIndex:i];
        NSNumber *sourceType = [aSource objectAtIndex:0];
        int type = [sourceType intValue];
        NSString *sourceName = [aSource objectAtIndex:1];
        
        if(type == kABSourceTypeCardDAV) {
            
            NSNumber *notInSelection = [NSNumber numberWithInt:0];
            NSMutableArray *aChoosedDst = [NSMutableArray arrayWithObjects:sourceType, sourceName, notInSelection, nil];
            [choosedDst addObject:aChoosedDst];
        }
    }
    
    return choosedDst;
}

-(NSString *) getSourceStringType:(NSNumber *)type {
    
    NSString *stringType = @"";
    int intType = [type intValue];
    
    switch (intType) {
            
        case kABSourceTypeLocal:
            stringType = @"Local AddressBook";
            break;
            
        case kABSourceTypeExchange:
            stringType = @"Exchange Account";
            break;
            
        case kABSourceTypeExchangeGAL:
            stringType = @"Exchange Account";
            break;
            
        case kABSourceTypeMobileMe:
            stringType = @"MobileMe Account";
            break;
            
        case kABSourceTypeLDAP:
            stringType = @"LDAP Account";
            break;
            
        case kABSourceTypeCardDAV:
            stringType = @"CardDAV Account";
            break;
            
        case kABSourceTypeCardDAVSearch:
            stringType = @"Searchable CardDAV Account";
            break;
            
            
        default:
            break;
    }
    
    return stringType;
}

-(void) beginContactsCopy {
    
    NSLog(@"choosedSources:%@", choosedSources);
    NSLog(@"filteredDestinations:%@", filteredDestinations);
    
}



@end
