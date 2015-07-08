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
    
    NSArray * theSelectedSources = [self getContactsImportSources];
    NSDictionary * theSelectedDestination = [self getContactsImportDestination];
    
    NSLog(@"theSelectedSources:%@", theSelectedSources);
    NSLog(@"theSelectedDestination:%@", theSelectedDestination);
    
    [self importContactTo:theSelectedDestination from:theSelectedSources];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)importContactTo:(NSDictionary *)theSelectedDestination from:(NSArray * )theSelectedSources{
    
    // Get the addressBook
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (error != NULL) {
        NSLog(@"iPhoneAddressBook not created");
        return;
    }
    
    //Get the DestinationSourceRef
    CFArrayRef AllSourcesRef = ABAddressBookCopyArrayOfAllSources(addressBook);
    ABRecordRef destinationSourceRef = [self getDestinationSourceFromSources:AllSourcesRef identifiedWith:theSelectedDestination];
    
    if(destinationSourceRef == NULL) {
        
        NSLog(@"destinationSourceRef not found");
        CFRelease(AllSourcesRef);
        CFRelease(addressBook);
        return;
    }
    
    //Get The SourcesSourceRef
    for(int i = 0; i < [theSelectedSources count]; i++) {
        
        NSDictionary *aSelectedSource = [theSelectedSources objectAtIndex:i];
        
        CFIndex countSourcesRef = CFArrayGetCount(AllSourcesRef);
        for(CFIndex idx=0; idx < countSourcesRef; ++idx) {
            
            ABRecordRef aSourceRef = CFArrayGetValueAtIndex(AllSourcesRef, idx);
            NSNumber *type = (NSNumber *)CFBridgingRelease(ABRecordCopyValue(aSourceRef, kABSourceTypeProperty));
            NSString *name = (NSString *)CFBridgingRelease(ABRecordCopyValue(aSourceRef, kABSourceNameProperty));
            NSNumber *selectedType = [aSelectedSource objectForKey:@"type"];
            NSString *selectedName = [aSelectedSource objectForKey:@"name"];
            
            NSLog(@"Is selectedType:%@ selectedName:%@",selectedType, selectedName);
            NSLog(@"A match for type:%@ name:%@",type, name);
            
            if( ([type intValue] == [selectedType intValue]) && ([name isEqualToString:selectedName]) ){
                
                [self copyAddressBookContacts:addressBook
                                   fromSource:aSourceRef toSource:destinationSourceRef];
            }
            
            if( ([type intValue] == [selectedType intValue]) && ([type intValue] == 0) ){
                
                [self copyAddressBookContacts:addressBook
                                   fromSource:aSourceRef toSource:destinationSourceRef];
            }
        }
    }
    
    CFRelease(AllSourcesRef);
    CFRelease(addressBook);
}

-(ABRecordRef)getDestinationSourceFromSources:(CFArrayRef)AllSourcesRef identifiedWith:(NSDictionary *)theSelectedDestination {
    
    ABRecordRef destinationSourceRef = NULL;
    
    CFIndex countSourcesRef = CFArrayGetCount(AllSourcesRef);
    
    for(CFIndex idx=0; idx < countSourcesRef; ++idx) {
        
        ABRecordRef aSourceRef = CFArrayGetValueAtIndex(AllSourcesRef, idx);
        NSNumber *type = (NSNumber *)CFBridgingRelease(ABRecordCopyValue(aSourceRef, kABSourceTypeProperty));
        NSString *name = (NSString *)CFBridgingRelease(ABRecordCopyValue(aSourceRef, kABSourceNameProperty));
        NSNumber *selectedType = [theSelectedDestination objectForKey:@"type"];
        NSString *selectedName = [theSelectedDestination objectForKey:@"name"];
        
        if( ([type intValue] == [selectedType intValue]) && ([name isEqualToString:selectedName]) ){
            
            NSLog(@"destinationSourceRef found");
            destinationSourceRef = aSourceRef;
            break;
        }
    }
    
    return destinationSourceRef;
}

-(void) copyAddressBookContacts:(ABAddressBookRef)addressBook
                     fromSource:(ABRecordRef)fromSourceRef toSource:(ABRecordRef)toSourceRef {
    
    NSString *fromSourceRefName = (NSString *)CFBridgingRelease(ABRecordCopyValue(fromSourceRef, kABSourceNameProperty));
    NSString *toSourceRefName = (NSString *)CFBridgingRelease(ABRecordCopyValue(toSourceRef, kABSourceNameProperty));
    
    NSLog(@"Importing contacts from %@ to %@",fromSourceRefName, toSourceRefName);
    
    CFArrayRef personsToImport = ABAddressBookCopyArrayOfAllPeopleInSource (addressBook, fromSourceRef);
    CFDataRef vCardDataRef = ABPersonCreateVCardRepresentationWithPeople(personsToImport);
    CFArrayRef createdPersons = ABPersonCreatePeopleInSourceWithVCardRepresentation (toSourceRef, vCardDataRef);
    
    
    CFIndex createdPersonsCount = CFArrayGetCount(createdPersons);
    for(CFIndex idx=0; idx < createdPersonsCount; ++idx) {
        
        ABRecordRef newPerson = CFArrayGetValueAtIndex(createdPersons, idx);
        ABAddressBookAddRecord(addressBook, newPerson, nil);
        ABAddressBookSave(addressBook, nil);
    }
}

-(NSDictionary *) getContactsImportDestination {
    
    NSMutableDictionary *theSelectedDestination = [NSMutableDictionary dictionaryWithCapacity:10];
    
    for(int i = 0; i < [self.filteredDestinations count]; i++) {
        
        NSMutableArray *aDst = [self.filteredDestinations objectAtIndex:i];
        NSNumber *isSelected = [aDst objectAtIndex:2];
        if([isSelected intValue] == 1) {
            
            NSNumber *type = [aDst objectAtIndex:0];
            NSString *name = [aDst objectAtIndex:1];
            [theSelectedDestination setObject:type forKey:@"type"];
            [theSelectedDestination setObject:name forKey:@"name"];
            
            break;
        }
    }
    
    return theSelectedDestination;
}

-(NSArray *) getContactsImportSources {
    
    NSMutableArray *theSelectedSources = [NSMutableArray arrayWithCapacity:10];
    
    for(int i = 0; i < [self.choosedSources count]; i++) {
        
        NSArray *aSource = [self.choosedSources objectAtIndex:i];
        NSNumber *isSelected = [aSource objectAtIndex:2];
        if([isSelected intValue] == 1) {
            
            NSNumber *type = [aSource objectAtIndex:0];
            NSString *name = [aSource objectAtIndex:1];
            NSMutableDictionary * aSourceDico = [NSMutableDictionary dictionaryWithCapacity:10];
            [aSourceDico setObject:type forKey:@"type"];
            [aSourceDico setObject:name forKey:@"name"];
            [theSelectedSources addObject:aSourceDico];
        }
    }
    
    return theSelectedSources;
}



@end
