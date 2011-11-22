//
//  MainViewController.m
//  IPAInstaller
//
//  Created by Антон Титков on 24.08.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
@implementation MainViewController

@synthesize flipsidePopoverController = _flipsidePopoverController;
@synthesize fileArray;
@synthesize tableView;
@synthesize lists=_lists;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (NSString *)generateUuidString
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // transfer ownership of the string
    // to the autorelease pool
    [uuidString autorelease];
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}


#pragma mark - View lifecycle

-(void)checkFiles
{
    NSArray *arr = [[NSArray alloc] initWithArray:[[[NSFileManager defaultManager] directoryContentsAtPath:docDir] pathsMatchingExtensions:[NSArray arrayWithObjects:@"ipa", nil]]];
    if ([arr count]==0) {
        [refreshButton setEnabled:NO];
    }else{
        if (currIPAs==[arr count]) {
            [refreshButton setEnabled:NO];
        }else{
            [refreshButton setEnabled:YES];
        }
    }
}

- (void)viewDidLoad
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        [tableView setBackgroundView:nil];
        UIView *view=[[[UIView alloc] init] autorelease];
        [view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
        [tableView setBackgroundView:view];
    }
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{    [timer invalidate];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)dealloc
{
    [_flipsidePopoverController release];
    [super dealloc];
}

- (IBAction)showInfo:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        FlipsideViewController *controller = [[[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil] autorelease];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    } else {
        FlipsideViewController *controller = [[[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController_iPad" bundle:nil] autorelease];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
        
    }
}

//other stuff
-(NSMutableDictionary*)dict
{
    NSMutableDictionary *plist=[[NSMutableDictionary alloc]init];
    [plist setObject:[[NSMutableArray alloc]init] forKey:@"items"];
    [(NSMutableArray*)[plist objectForKey:@"items"] addObject:[[NSMutableDictionary alloc]init]];
    [[[plist objectForKey:@"items"]objectAtIndex:0]setObject:[[NSMutableArray alloc]init] forKey:@"assets"];
    [[[plist objectForKey:@"items"]objectAtIndex:0]setObject:[[NSMutableDictionary alloc]init] forKey:@"metadata"];
    [[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"assets"]addObject:[[NSMutableDictionary alloc]init]];
    [[[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"assets"]objectAtIndex:0]setObject:@"software-package" forKey:@"kind"];
    [[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"assets"]addObject:[[NSMutableDictionary alloc]init]];
    [[[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"assets"]objectAtIndex:1]setObject:@"display-image" forKey:@"kind"];
    [[[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"assets"]objectAtIndex:1]setObject:[NSNumber numberWithBool:NO] forKey:@"needs-shine"];
    [[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"metadata"]setObject:@"1.0" forKey:@"bundle-version"];
    [[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"metadata"]setObject:@"software" forKey:@"kind"];
    return plist;
}

-(BOOL)isAlreadyHaveMetaFileAtPath:(NSString*)path
{
    if ([[[NSFileManager alloc]init]fileExistsAtPath:[path stringByReplacingOccurrencesOfString:@".ipa" withString:@".plist"]])
    {
        return YES;
    }else{
        return NO;
    }
}

-(void)genPlists
{
    BOOL yrn=YES;
    if (![[[NSFileManager alloc]init]fileExistsAtPath:[NSString stringWithFormat:@"%@/metas",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]] isDirectory:&yrn]){
        [[[NSFileManager alloc]init]createDirectoryAtPath:[NSString stringWithFormat:@"%@/metas",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDictionary *infodict;
    fileArray = [[NSMutableArray alloc] initWithArray:[[[NSFileManager defaultManager] directoryContentsAtPath:docDir] pathsMatchingExtensions:[NSArray arrayWithObjects:@"ipa", nil]]];
    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"deleteIPAAfterInstall"]){
        if ([fileArray containsObject:lastToBeInstalledIPA]) {
            ipaData=nil;
            lastToBeInstalledIPA=nil;
        }else{
            [ipaData writeToFile:[NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],lastToBeInstalledIPA] atomically:YES];
            ipaData=nil;
        }
    }
    for (int i=0; i<[fileArray count]; i++) {   
        [[[NSFileManager alloc]init]moveItemAtPath:[docDir stringByAppendingPathComponent:[fileArray objectAtIndex:i]] toPath:[docDir stringByAppendingPathComponent:[[[[[[[fileArray objectAtIndex:i] stringByReplacingOccurrencesOfString:@" " withString:@"_"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]stringByReplacingOccurrencesOfString:@"%" withString:@"_"]stringByReplacingOccurrencesOfString:@"." withString:@"_"]stringByReplacingOccurrencesOfString:@"_ipa" withString:@".ipa"]stringByReplacingOccurrencesOfString:@"+" withString:@"_"]] error:nil];
    }
    fileArray = [[NSMutableArray alloc] initWithArray:[[[NSFileManager defaultManager] directoryContentsAtPath:docDir] pathsMatchingExtensions:[NSArray arrayWithObjects:@"ipa", nil]]];
    [tableView reloadData];
    
    
    
    for (int i=0; i<[fileArray count]; i++) {   
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[[NSString alloc] initWithFormat:@"%@/%@", docDir, [fileArray objectAtIndex:i]] error:nil];
        NSString *fileSize;
        if(fileAttributes != nil)
        {
            fileSize = [fileAttributes objectForKey:NSFileSize];
        }else{
            continue;
        }
        if (fileSize.intValue==0) {
            continue;
        }
        
        if (unzOpen([[docDir stringByAppendingPathComponent:[fileArray objectAtIndex:i]] cStringUsingEncoding:NSUTF8StringEncoding])==NULL) {
            NSLog(@"corrupt");
            continue;
        }else{
            NSLog(@"normal");
        }
        if ([self isAlreadyHaveMetaFileAtPath:[[docDir stringByAppendingPathComponent:@"metas"]stringByAppendingPathComponent:[fileArray objectAtIndex:i]]]) {
            continue;
        }else{
            sleep(2);
            HUD.labelText = [NSString stringWithFormat:@"%@%@",MyLocalizedString(@"procc", @"Proccessing..."),[fileArray objectAtIndex:i]];
            
            ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:[docDir stringByAppendingPathComponent:[fileArray objectAtIndex:i]] mode:ZipFileModeUnzip];
            NSArray *infos= [unzipFile listFileInZipInfos];
            for (FileInZipInfo *info in infos) {
                if ([[info.name lastPathComponent]hasPrefix:@"Info.plist"]) {
                    // Locate the file in the zip
                    [unzipFile locateFileInZip:info.name];
                    
                    // Expand the file in memory
                    ZipReadStream *read= [unzipFile readCurrentFileInZip];
                    NSMutableData *data= [[NSMutableData alloc] initWithLength:info.length];
                    [read readDataWithBuffer:data];
                    infodict=[NSDictionary dictionaryWithContentsOfData:data];
                    //NSData *datas=[NSData dataWithBytes:bytesRead length:4000];
                    [data release];
                    [read finishedReading];
                    break;
                }
            }
            [unzipFile close];
            NSMutableDictionary *plist=[[NSMutableDictionary alloc]initWithDictionary:[self dict]];
            [[[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"assets"]objectAtIndex:0]setObject:[[NSString stringWithFormat:@"file://localhost%@/%@",docDir,[fileArray objectAtIndex:i]]stringByReplacingOccurrencesOfString:@" " withString:@"\%20"] forKey:@"url"];
            ////начало нового движка
            NSString *iconName=[[NSString alloc]init];
            if ([[infodict allKeys]containsObject:@"CFBundleIconFiles"]) {
                if ([[infodict objectForKey:@"CFBundleIconFiles"]count]!=0) {
                    for (int i=0; i<[[infodict objectForKey:@"CFBundleIconFiles"]count]; i++) {
                        NSLog([[infodict objectForKey:@"CFBundleIconFiles"]objectAtIndex:i]);
                        if ([[[[infodict objectForKey:@"CFBundleIconFiles"]objectAtIndex:i]stringByDeletingPathExtension]hasSuffix:@"@2x"]) {
                            iconName=[[NSString alloc]initWithString:[[infodict objectForKey:@"CFBundleIconFiles"]objectAtIndex:i]];
                            break;
                        }else{
                            iconName=[[NSString alloc]initWithString:[[infodict objectForKey:@"CFBundleIconFiles"]objectAtIndex:i]];
                        }
                    }
                }
            }else{
                iconName=nil;
            }
            
            if (iconName!=nil) {
                unzipFile=[[ZipFile alloc] initWithFileName:[docDir stringByAppendingPathComponent:[fileArray objectAtIndex:i]] mode:ZipFileModeUnzip];
                infos=[unzipFile listFileInZipInfos];
                for (FileInZipInfo *info in infos) {
                    if ([[info.name lastPathComponent]hasPrefix:iconName]) {
                        // Locate the file in the zip
                        [unzipFile locateFileInZip:info.name];
                        
                        // Expand the file in memory
                        ZipReadStream *read= [unzipFile readCurrentFileInZip];
                        NSMutableData *data= [[NSMutableData alloc] initWithLength:info.length];
                        [read readDataWithBuffer:data];
                        iconName=[self generateUuidString];
                        [data writeToFile:[NSString stringWithFormat:@"%@/metas/%@.png",docDir,iconName] atomically:YES];
                        //NSData *datas=[NSData dataWithBytes:bytesRead length:4000];
                        [data release];
                        [read finishedReading];
                        break;
                    }
                }
                [unzipFile close];
                [[[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"assets"]objectAtIndex:1]setValue:[NSString stringWithFormat:@"file://localhost%@",[NSString stringWithFormat:@"%@/metas/%@.png",docDir,iconName]] forKey:@"url"];
                ////конец для нового движка
            }else{
                [[[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"assets"]objectAtIndex:1]setValue:[NSString stringWithFormat:@"file://localhost%@",ipaIcon] forKey:@"url"];
            }
            [[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"metadata"]setObject:[infodict objectForKey:@"CFBundleIdentifier"] forKey:@"bundle-identifier"];
            [[[[plist objectForKey:@"items"]objectAtIndex:0]objectForKey:@"metadata"]setObject:[infodict objectForKey:@"CFBundleDisplayName"] forKey:@"title"];
            [plist writeToFile:[NSString stringWithFormat:@"%@/metas/%@",docDir,[[fileArray objectAtIndex:i]stringByReplacingOccurrencesOfString:@"ipa" withString:@"plist"]] atomically:YES];
            [plist release];
    }
    HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
    HUD.mode=MBProgressHUDModeCustomView;
    HUD.labelText = MyLocalizedString(@"done", @"Done");
    HUD.detailsLabelText = @"";
    sleep(2);
    [refreshButton setEnabled:NO];
}
}
    
- (void)updateArray
{
        fileArray = [[NSMutableArray alloc] initWithArray:[[[NSFileManager defaultManager] directoryContentsAtPath:docDir] pathsMatchingExtensions:[NSArray arrayWithObjects:@"ipa", nil]]];
        
        if(![[NSUserDefaults standardUserDefaults]boolForKey:@"deleteIPAAfterInstall"]){
            if ([fileArray containsObject:lastToBeInstalledIPA]) {
                ipaData=nil;
                lastToBeInstalledIPA=nil;
            }else{
                [noFiles setHidden:YES];
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                HUD.delegate = self;
                HUD.detailsLabelText = MyLocalizedString(@"plzwait", @"Please wait");
                HUD.labelText = MyLocalizedString(@"upddata", @"Updating data...");
                [HUD showWhileExecuting:@selector(genPlists) onTarget:self withObject:nil animated:YES];
                [tableView setScrollEnabled:YES];
                currIPAs=[fileArray count];
            }
        }else{
            
            [tableView reloadData];
            if ([fileArray count]==0) {
                [noFiles setHidden:NO];
                [tableView setScrollEnabled:NO];
            }else{
                [noFiles setHidden:YES];
                if ([self isUpdateNeeded]) {
                    HUD = [[MBProgressHUD alloc] initWithView:self.view];
                    [self.view addSubview:HUD];
                    HUD.delegate = self;
                    HUD.detailsLabelText = MyLocalizedString(@"plzwait", @"Please wait");
                    HUD.labelText = MyLocalizedString(@"upddata", @"Updating data...");
                    [HUD showWhileExecuting:@selector(genPlists) onTarget:self withObject:nil animated:YES];
                }       
                [tableView setScrollEnabled:YES];
                currIPAs=[fileArray count];
            }
        }
}
    
-(IBAction)refresh:(id)sender
{
        [self updateArray];
    }
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return 1;
    }
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return [fileArray count];
    }
    
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            
            cell =
            [[[UITableViewCell alloc]
              initWithFrame:CGRectZero
              reuseIdentifier:CellIdentifier]
             autorelease];
            
        }
        
        cell.text = [[NSString stringWithFormat:@"%@", [fileArray objectAtIndex:indexPath.row]] stringByDeletingPathExtension];	
        return cell;        
    }
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
        return 44.0;
    }
    
-(void)dataaa
{
        ipaData=[[NSData alloc]initWithContentsOfFile:fullPath];
        NSLog(@"Done");
    }
    
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        fullPath = [[NSString alloc] initWithFormat:@"%@/%@", docDir, [fileArray objectAtIndex:indexPath.row]];
        if(![[NSUserDefaults standardUserDefaults]boolForKey:@"deleteIPAAfterInstall"]){
            [self performSelectorInBackground:@selector(dataaa) withObject:nil];
            lastToBeInstalledIPA=[[NSString alloc]initWithString:[fullPath lastPathComponent]];
            NSLog(lastToBeInstalledIPA);
        }
        fullPlistPath= [[NSString alloc] initWithFormat:@"%@/metas/%@", docDir, [fileArray objectAtIndex:indexPath.row]];
        NSLog(fullPath);
        //NSMutableDictionary *filesAttr=[NSMutableDictionary dictionaryWithDictionary:[[[NSFileManager alloc]init]attributesOfItemAtPath:fullPath error:nil]];
        //[filesAttr setValue:[NSNumber numberWithInt:444] forKey:NSFilePosixPermissions];
        //[[[NSFileManager alloc]init]setAttributes:filesAttr ofItemAtPath:fullPath error:nil];
        //NSLog(@"%@",[[[NSFileManager alloc]init]attributesOfItemAtPath:fullPath error:nil]);
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[[NSString alloc] initWithFormat:@"%@/%@", docDir, [fileArray objectAtIndex:indexPath.row]] error:nil];
        NSString *fileSize;
        if(fileAttributes != nil)
        {
            fileSize = [fileAttributes objectForKey:NSFileSize];
            if (fileSize.intValue!=0) {
                if (unzOpen([[docDir stringByAppendingPathComponent:[fileArray objectAtIndex:indexPath.row]] cStringUsingEncoding:NSUTF8StringEncoding])==NULL) {
                    //[[downDict objectForKey:[[downDict allKeys] objectAtIndex:indexPath.row]]setObject:@"error" forKey:@"state"]; 
                    actionSheet = [[UIActionSheet alloc]
                                   initWithTitle:MyLocalizedString(@"dmged", @"File damaged")
                                   delegate:self
                                   cancelButtonTitle:MyLocalizedString(@"cancel", @"Cancel")
                                   destructiveButtonTitle:MyLocalizedString(@"delete", @"Delete")
                                   otherButtonTitles:nil];
                    
                }else{
                    actionSheet = [[UIActionSheet alloc]
                                   initWithTitle:MyLocalizedString(@"choose_action", @"Choose action")
                                   delegate:self
                                   cancelButtonTitle:MyLocalizedString(@"cancel", @"Cancel")
                                   destructiveButtonTitle:MyLocalizedString(@"install", @"Install")
                                   otherButtonTitles:MyLocalizedString(@"delete", @"Delete"),nil];           
                }        
            }else{
                actionSheet = [[UIActionSheet alloc]
                               initWithTitle:MyLocalizedString(@"dmged", @"File damaged")
                               delegate:self
                               cancelButtonTitle:MyLocalizedString(@"cancel", @"Cancel")
                               destructiveButtonTitle:MyLocalizedString(@"delete", @"Delete")
                               otherButtonTitles:nil];
            }
        }else{
            actionSheet = [[UIActionSheet alloc]
                           initWithTitle:MyLocalizedString(@"dmged", @"File damaged")
                           delegate:self
                           cancelButtonTitle:MyLocalizedString(@"cancel", @"Cancel")
                           destructiveButtonTitle:MyLocalizedString(@"delete", @"Delete")
                           otherButtonTitles:nil];
        }
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
        [actionSheet release];
    }
    
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath 
{
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            
            [[NSFileManager defaultManager] removeItemAtPath:[[NSString alloc] initWithFormat:@"%@/%@", docDir, [fileArray objectAtIndex:indexPath.row]] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[[NSString alloc] initWithFormat:@"%@/metas/%@", docDir, [[fileArray objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@".ipa" withString:@".plist"]] error:nil];
            
            [self updateArray];
        }
        
    }
    
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return UITableViewCellEditingStyleNone;
    }
    
-(BOOL)isUpdateNeeded
{
        fileArray = [[NSMutableArray alloc] initWithArray:[[[NSFileManager defaultManager] directoryContentsAtPath:docDir] pathsMatchingExtensions:[NSArray arrayWithObjects:@"ipa", nil]]];
        int count=0;
        for(int i=0;i<[fileArray count];i++){
            if([[[NSFileManager alloc]init]fileExistsAtPath:[[docDir stringByAppendingPathComponent:@"metas"]stringByAppendingPathComponent:[(NSString*)[fileArray objectAtIndex:i]stringByReplacingOccurrencesOfString:@".ipa" withString:@".plist"]]]){
                count++;
            }
        }
        if ((count==[fileArray count])||(count>[fileArray count])) {
            return NO;
        }else{
            return YES;
        }
    }
    
-(void)rew
{
        [[NSFileManager defaultManager] removeItemAtPath:[fullPlistPath stringByReplacingOccurrencesOfString:@".ipa" withString:@".plist"] error:nil];
    }
    
- (void)actionSheet:(UIActionSheet *)aActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if ([aActionSheet.title isEqualToString:MyLocalizedString(@"choose_action", @"Choose action")]) {
            if ([[actionSheet buttonTitleAtIndex:buttonIndex]isEqualToString:MyLocalizedString(@"delete", @"Delete")]) {
                ipaData=nil;
                lastToBeInstalledIPA=nil;
                [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[fullPlistPath stringByReplacingOccurrencesOfString:@".ipa" withString:@".plist"] error:nil];
                [self updateArray];
            }else if([[aActionSheet buttonTitleAtIndex:buttonIndex]isEqualToString:MyLocalizedString(@"install", @"Install")])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"itms-services://?action=download-manifest&url=file://localhost%@",[fullPlistPath stringByReplacingOccurrencesOfString:@".ipa" withString:@".plist"]]stringByReplacingOccurrencesOfString:@" " withString:@"\%20"]]];
                [self performSelector:@selector(rew) withObject:nil afterDelay:2.0];
                
            }else if([[aActionSheet buttonTitleAtIndex:buttonIndex]isEqualToString:MyLocalizedString(@"cancel", @"Cancel")]){
                ipaData=nil;
                lastToBeInstalledIPA=nil;
            }
            
        }else if([aActionSheet.title isEqualToString:MyLocalizedString(@"dmged", @"File damaged")]){
            if ([[actionSheet buttonTitleAtIndex:buttonIndex]isEqualToString:MyLocalizedString(@"delete", @"Delete")]) {
                ipaData=nil;
                lastToBeInstalledIPA=nil;
                [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:[fullPlistPath stringByReplacingOccurrencesOfString:@".ipa" withString:@".plist"] error:nil];
                [self updateArray];
            }else if([[aActionSheet buttonTitleAtIndex:buttonIndex]isEqualToString:MyLocalizedString(@"cancel", @"Cancel")]){
                ipaData=nil;
                lastToBeInstalledIPA=nil;
            }
        }
    }
    
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
        [self setEditing:editing animated:animated];
    }
    
- (void)viewDidAppear:(BOOL)animated
{    
        timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkFiles) userInfo:nil repeats:YES];
        [timer fire];
        
        [self updateArray];
        [super viewDidAppear:animated];
    }

@end

@implementation NSDictionary (Helpers)

+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data
{
	// uses toll-free bridging for data into CFDataRef and CFPropertyList into NSDictionary
	CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)data,
															   kCFPropertyListImmutable,
															   NULL);
	// we check if it is the correct type and only return it if it is
	if ([(id)plist isKindOfClass:[NSDictionary class]])
	{
		return [(NSDictionary *)plist autorelease];
	}
	else
	{
		// clean up ref
		CFRelease(plist);
		return nil;
	}
}

@end
