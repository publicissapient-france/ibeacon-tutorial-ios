//
// Created by Simone Civetta on 16/03/14.
// Copyright (c) 2014 Xebia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const XBBeaconLocationManagerValueChangedNotification;

@interface XBBeaconLocationManager : NSObject <CLLocationManagerDelegate>

+ (XBBeaconLocationManager *)sharedManager;

@property (nonatomic, readonly) NSArray *allBeacons;

@end