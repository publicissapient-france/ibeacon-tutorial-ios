//
// Created by Simone Civetta on 12/08/14.
// Copyright (c) 2014 Xebia IT Architects. All rights reserved.
//

#import "XBBeaconViewController.h"
#import "XBBeaconLocationManager.h"

@interface XBBeaconViewController()

@property (nonatomic, strong) id locationManagerObserver;

@end

@implementation XBBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
    [self initObservers];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.locationManagerObserver];
}

- (void)initObservers {
    __weak typeof(self) weakSelf = self;
    self.locationManagerObserver = [[NSNotificationCenter defaultCenter] addObserverForName:XBBeaconLocationManagerValueChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *NoVisibleBeaconCellIdentifier = @"NoVisibleBeaconCell";
    static NSString *BeaconCellIdentifier = @"BeaconCell";
    NSArray *allBeacons = [XBBeaconLocationManager sharedManager].allBeacons;
    
    UITableViewCell *cell;
    if ([allBeacons count] > 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:BeaconCellIdentifier];
        CLBeacon *beacon = allBeacons[indexPath.row];
        cell.textLabel.text = [[beacon proximityUUID] UUIDString];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"maj: %@, min: %@, dist: %.2fm", [beacon.major stringValue], [beacon.minor stringValue], beacon.accuracy];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:NoVisibleBeaconCellIdentifier];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger allBeacons = [[XBBeaconLocationManager sharedManager].allBeacons count];
    return allBeacons ? allBeacons : 1;
}

@end