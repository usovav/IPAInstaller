//
//  MainViewController.h
//  IPAInstaller
//
//  Created by Антон Титков on 24.08.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"
#import "defines.h"
@interface MainViewController : UIViewController <FlipsideViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,UIActionSheetDelegate>{
    UITableView *tableView;
	NSMutableArray *fileArray;
	NSString *fullPath;
	UITextField *newFileName;
	UIActionSheet *actionSheet;
	NSMutableArray *_lists;
    IBOutlet UITextView *noFiles;
    NSString *fullPlistPath;
    NSTimer *timer;
    IBOutlet UIBarButtonItem *refreshButton;
    int currIPAs;
    MBProgressHUD *HUD;
    NSData *ipaData;
    NSString *lastToBeInstalledIPA;
}

@property (assign, nonatomic) UIPopoverController *flipsidePopoverController;
-(void)updateArray;
- (IBAction)showInfo:(id)sender;
@property (nonatomic, retain) NSMutableArray *fileArray;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *lists;
- (void) updateArray;
-(BOOL)isUpdateNeeded;
-(IBAction)refresh:(id)sender;
@end


@interface NSDictionary (Helpers)

+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data;

@end