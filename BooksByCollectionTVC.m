//
//  BooksByCollectionTVC.m
//  Books
//
//  Created by Misato Tina Alexandre on 8/23/13.
//  Copyright (c) 2013 Misato Tina Alexandre. All rights reserved.
//

#import "BooksByCollectionTVC.h"
#import "Book.h"

@interface BooksByCollectionTVC ()
{
    unsigned int count;
}

@end

@implementation BooksByCollectionTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Perform fetch
    NSError *error=nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error %@", error);
        abort() ;
    }
    
    //testing NSSet.
    //Next: declare delegate protocol that CollectionListTVC will implement to pass the value....
    unsigned int count=[self.selectedFavorite.favoriteBooks count];
    NSString *displayCount=[NSString stringWithFormat:@"%d books in this collection", count];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Book count" message:displayCount delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    // Return the number of rows in the section.
    id<NSFetchedResultsSectionInfo> secInfo=[[self.fetchedResultsController sections]objectAtIndex:section];
    return [secInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Book *book=[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=book.title;
    cell.detailTextLabel.text=book.author;
    
    return cell;
    
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [[[self.fetchedResultsController sections]objectAtIndex:section]name];
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSManagedObjectContext *context=self.managedObjectContext;
        Book *book=[self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:book];
        
        NSError *error=nil;
        if (![context save:&error]) {
            NSLog(@"Error %@", error);
        }
        
    }
    
}


#pragma mark-Fetched Results Controller Section
-(NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController!=nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Book"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSString *currentFavorite=self.selectedFavorite.favorite;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite.favorite== %@", currentFavorite];
    
    [fetchRequest setPredicate:predicate];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title"
                                                                   ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _fetchedResultsController=[[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate=self;
    return _fetchedResultsController;
    
}
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}
-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}
-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:{
            Book *changedBook=[self.fetchedResultsController objectAtIndexPath:indexPath];
            UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.text=changedBook.title;
            cell.detailTextLabel.text=changedBook.author;
        }
            
    }
}
-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            
        default:
            break;
    }
}






@end