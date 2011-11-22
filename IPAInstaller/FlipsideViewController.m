//
//  FlipsideViewController.m
//  IPAInstaller
//
//  Created by Антон Титков on 24.08.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"

//
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "localhostAddresses.h"
//
@implementation FlipsideViewController

@synthesize webServSwitcher;
@synthesize delegate = _delegate;
@synthesize theData, urlString, watchString, file1;

//

- (void)displayInfoUpdate:(NSNotification *) notification
{
	NSLog(@"displayInfoUpdate:");
    
	if(notification)
	{
		[addresses release];
		addresses = [[notification object] copy];
		NSLog(@"addresses: %@", addresses);
	}
    
	if(addresses == nil)
	{
		return;
	}
	
	NSString *info;
	UInt16 port = [httpServer port];
	
	NSString *localIP = nil;
	
	localIP = [addresses objectForKey:@"en0"];
	
	if (!localIP)
	{
		localIP = [addresses objectForKey:@"en1"];
	}
    
	if (!localIP)
		info = @"Wifi: No Connection!\n";
	else
        info = [NSString stringWithFormat:@"http://%@:%d\n",localIP, port];

        //info = [NSString stringWithFormat:@"http://iphone.local:%d \n http://%@:%d\n", port, localIP, port];
    
	/*NSString *wwwIP = [addresses objectForKey:@"www"];
    
	if (wwwIP)
		info = [info stringByAppendingFormat:@"Web: %@:%d\n", wwwIP, port];
	else
		info = [info stringByAppendingString:@"Web: Unable to determine external IP\n"];*/
    
	displayInfo.text = info;
}


- (IBAction)startStopServer:(id)sender
{
	if ([sender isOn])
	{
        [doneBut setEnabled:NO];
        [servdis setHidden:YES];
        [displayInfo setHidden:NO];
		// You may OPTIONALLY set a port for the server to run on.
		// 
		// If you don't set a port, the HTTP server will allow the OS to automatically pick an available port,
		// which avoids the potential problem of port conflicts. Allowing the OS server to automatically pick
		// an available port is probably the best way to do it if using Bonjour, since with Bonjour you can
		// automatically discover services, and the ports they are running on.
        //	[httpServer setPort:8080];
		
		NSError *error;
		if(![httpServer start:&error])
		{
			NSLog(@"Error starting HTTP Server: %@", error);
		}
        
		[self displayInfoUpdate:nil];
	}
	else
        
	{   [doneBut setEnabled:YES];
        [servdis setHidden:NO];
        [displayInfo setHidden:YES];
		[httpServer stop];
	}
}

//


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    NSString *root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
	
	httpServer = [HTTPServer new];
	[httpServer setType:@"_http._tcp."];
	[httpServer setConnectionClass:[MyHTTPConnection class]];
	[httpServer setDocumentRoot:[NSURL fileURLWithPath:root]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInfoUpdate:) name:@"LocalhostAdressesResolved" object:nil];
	[localhostAddresses performSelectorInBackground:@selector(list) withObject:nil];
    [vers setText:[NSString stringWithFormat:@"%@: %@",MyLocalizedString(@"version", @"Version"),versLab]];
 [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidUnload
{
    [self setWebServSwitcher:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{  
    if ([[Reachability reachabilityForLocalWiFi]currentReachabilityStatus]==ReachableViaWiFi) {
        [webServSwitcher setEnabled:YES];
    }else{
        [webServSwitcher setEnabled:NO];
    }
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
     }*/return NO;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (void)dealloc {
    [webServSwitcher release];
    [super dealloc];
}
@end
