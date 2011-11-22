//
//  defines.h
//  IPAInstaller
//
//  Created by Антон Титков on 25.08.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ZipFile.h"
#import "ZipException.h"
#import "ZipReadStream.h"
#import "ZipWriteStream.h"
#import "FileInZipInfo.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import <QuartzCore/QuartzCore.h>
#define CURRENT_VERSION 1.2
#define versLab @"1.2"
#define ipaIcon [[NSBundle mainBundle]pathForResource:@"icon@2x" ofType:@"png"]
#define MyLocalizedString(key, comment) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:(comment) table:nil]
#define docDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]
