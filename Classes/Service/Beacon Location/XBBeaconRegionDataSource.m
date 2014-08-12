//
// Created by Simone Civetta on 12/08/14.
// Copyright (c) 2014 Xebia IT Architects. All rights reserved.
//

#import "XBBeaconRegionDataSource.h"

@interface XBBeaconRegionDataSource()

@property (nonatomic, strong) NSArray *allRegions;

@end

@implementation XBBeaconRegionDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        CLBeaconRegion *beacon = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"] identifier:@"Xebia Beacon Region"];
        // Ajouter plus de beacons si nécessaire
        self.allRegions = @[beacon];
    }

    return self;
}


@end