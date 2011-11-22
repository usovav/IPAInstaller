//
//  FlipsideViewController.h
//  IPAInstaller
//
//  Created by Антон Титков on 24.08.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "defines.h"
@class FlipsideViewController,HTTPServer;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController
{
    //
    HTTPServer *httpServer;
	NSDictionary *addresses;
	
	IBOutlet UILabel *displayInfo;
    IBOutlet UILabel *servdis;
    //
    
    IBOutlet UILabel *vers;
    IBOutlet UIButton *but;
    IBOutlet UIBarButtonItem *doneBut;
}

@property (retain, nonatomic) IBOutlet UISwitch *webServSwitcher;
@property (assign, nonatomic) IBOutlet id <FlipsideViewControllerDelegate> delegate;

-(IBAction) startStopServer:(id)sender;

- (IBAction)done:(id)sender;
@property (nonatomic, retain) NSMutableData *theData;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *watchString;
@property (nonatomic, retain) NSFileHandle *file1;
- (void)saveFileAtURL:(NSURL *)theUrl;
-(IBAction)later;
-(IBAction)downloadAndInstall:(id)sender;
-(IBAction)checkForUpdate;
- (void)downloadCheck;
- (NSString *)stringWithBytes:(int)theBytes;
@end
