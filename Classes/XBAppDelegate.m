//
//  AppDelegate.m
//  XebiaBeacons
//
//  Created by Alexis Kinsella on 10/06/12.
//  Copyright (c) 2012 Xebia France. All rights reserved.
//

#import "XBAppDelegate.h"
#import "XBBeaconLocationManager.h"

@implementation XBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self initBeaconTracking];
    
    return YES;
}
#pragma iBeacon notifications

- (void)initBeaconTracking {
    [XBBeaconLocationManager sharedManager];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iBeacon event"
                                                    message:notification.alertBody
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                          otherButtonTitles:nil];
    
    [alert show];
}

@end
