//
//  BookGenreDetailTVC.h
//  Books
//
//  Created by Misato Tina Alexandre on 8/20/13.
//  Copyright (c) 2013 Misato Tina Alexandre. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Genre.h"

@protocol BookGenreDetailTVCDelegate;

@interface BookGenreDetailTVC : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *genreField;

@property (strong, nonatomic) Genre *currentGenre;
@property (weak, nonatomic) id<BookGenreDetailTVCDelegate> delegate;

- (IBAction)save:(id)sender;
@end

@protocol BookGenreDetailTVCDelegate
-(void)bookGenreDetailTVCDelegateSave:(BookGenreDetailTVC *)controller;
@end
