//
//  ImportContactsSourceViewController.m
//  Owncloud iOs Client
//
//  Created by Bilal on 06/07/2015.
//
//

#import "ImportContactsSourceViewController.h"

#include <AddressBook/AddressBook.h>
#import "ImportContactsDstViewController.h"

@interface ImportContactsSourceViewController ()

@end

@implementation ImportContactsSourceViewController

@synthesize sources, filteredSources;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                        target:self
                                                                        action:@selector(displayNextViewController)];
    [nextButton setEnabled:NO];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    self.filteredSources = [self filterCardDavSources:self.sources];
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredSources count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return NSLocalizedString(@"chooseContactSource", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactSourceCell";
    UITableViewCell *cell;
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    NSArray *aSource = [self.filteredSources objectAtIndex:indexPath.row];
    
        NSString *type = [self getSourceStringType:[aSource objectAtIndex:0]];
        NSString *name = [aSource objectAtIndex:1];
        
        cell.textLabel.text = name;
        cell.detailTextLabel.text = type;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSMutableArray *aSource = [self.filteredSources objectAtIndex:indexPath.row];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [aSource replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:0]];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [aSource replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:1]];
    }
    
    if([self isAtLeastOneSourceSelected]) {
        [nextButton setEnabled:YES];
    }
    else {
        [nextButton setEnabled:NO];
    }
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

-(NSMutableArray *) filterCardDavSources:(NSArray *) fromSources {
    
    NSMutableArray *choosedSources = [NSMutableArray arrayWithCapacity:10];
    
    for(int i = 0; i < [fromSources count]; i++) {
        
        NSArray *aSource = [fromSources objectAtIndex:i];
        NSNumber *sourceType = [aSource objectAtIndex:0];
        int type = [sourceType intValue];
        NSString *sourceName = [aSource objectAtIndex:1];
        
        if(type != kABSourceTypeCardDAV) {
            
            NSNumber *notInSelection = [NSNumber numberWithInt:0];
            NSMutableArray *aChoosedSource = [NSMutableArray arrayWithObjects:sourceType, sourceName, notInSelection, nil];
            [choosedSources addObject:aChoosedSource];
        }
    }
    
    return choosedSources;
}

-(BOOL) isAtLeastOneSourceSelected {
    
    BOOL isAtLeastOneSourceSelected = NO;
    
    for(int i = 0; i < [self.filteredSources count]; i++) {
        
        NSMutableArray *aSource = [self.filteredSources objectAtIndex:i];
        NSNumber *isSourceSelected = [aSource objectAtIndex:2];
        if([isSourceSelected intValue] == 1) {
            
            isAtLeastOneSourceSelected = YES;
            break;
        }
    }
    
    return isAtLeastOneSourceSelected;
}

-(void) displayNextViewController {
    
    ImportContactsDstViewController *importContactsDstViewController = [[ImportContactsDstViewController alloc] initWithNibName:@"ImportContactsDstViewController" bundle:nil];
    importContactsDstViewController.sources = sources;
    importContactsDstViewController.choosedSources = filteredSources;
    
    [self.navigationController pushViewController:importContactsDstViewController animated:YES];
}

@end
