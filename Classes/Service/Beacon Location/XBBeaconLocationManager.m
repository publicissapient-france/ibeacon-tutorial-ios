//
// Created by Simone Civetta on 16/03/14.
// Copyright (c) 2014 Xebia. All rights reserved.
//

#import "XBBeaconLocationManager.h"
#import "XBBeaconRegionDataSource.h"

NSString * const XBBeaconLocationManagerValueChangedNotification = @"XBBeaconLocationManagerValueChangedNotification";

@interface XBBeaconLocationManager () <UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) XBBeaconRegionDataSource *regionDataSource;
@property (nonatomic, strong) NSMutableArray *currentBeacons;

@end

@implementation XBBeaconLocationManager

#pragma mark - Initialization

+ (XBBeaconLocationManager *)sharedManager {
    static XBBeaconLocationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
	if (self = [super init]) {
		[self initAccordingToAuthorizationStatus];
	}
	return self;
}

- (void)initAccordingToAuthorizationStatus {
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Activer iBeacon ?", @"Activer iBeacon ?")
                                                            message:NSLocalizedString(@"Cette application permet de tester les iBeacons. Pour ce faire, il est nécessaire d'authoriser l'accès à vos donnés de localisation. Voulez-vous continuer ?", @"Cette application permet de tester les iBeacons. Pour ce faire, il est nécessaire d'authoriser l'accès à vos donnés de localisation. Voulez-vous continuer ?")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Non", @"Non")
                                                  otherButtonTitles:NSLocalizedString(@"Oui, continuer", @"Oui, continuer"), nil];
        [alertView show];
    } else if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted) {
        [self initialize];
        return;
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self initialize];
    }
}

- (void)initialize {
    [self initializeLocationManager];
    [self initBeaconRegions];
}

- (void)initBeaconRegions {
    self.regionDataSource = [XBBeaconRegionDataSource new];
    for (CLBeaconRegion *region in self.regionDataSource.allRegions) {
        [self.locationManager startMonitoringForRegion:region];
        [self.locationManager requestStateForRegion:region];
    }
}

- (void)initializeLocationManager {
	// Initialise un nouveau Location Manager
	if (!self.locationManager) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
	}
}

#pragma mark - CLLocationManagerDelegate

/* Le location manager appelle cette méthode lorsqu'une région est attraversée.
 * Cette méthode est appellée au même temps que locationManager:didEnterRegion: et locationManager:didExitRegion:.
 * Également, le location manager appelle cette méthode en réponse à l'invocation de requestStateForRegion:.
 */
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
	if (manager != self.locationManager) {
		return;
	}

	if (state == CLRegionStateInside) {
		[self startBeaconRangingInRegion:region];
	}
	else if (state == CLRegionStateOutside) {
		[self stopBeaconRangingInRegion:region];
	}
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
	if (manager != self.locationManager) {
		return;
	}

	[self postValueChangedNotification];

	[self startBeaconRangingInRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
	if (manager != self.locationManager) {
		return;
	}

	[self postValueChangedNotification];

	[self stopBeaconRangingInRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {

    self.currentBeacons = [NSMutableArray array];

    // Trouve le beacon le plus proche
	if ([beacons count] > 0) {
		CLBeacon *closestBeacon = beacons[0];

		if (closestBeacon.proximity == CLProximityImmediate) {
            [self.currentBeacons addObject:closestBeacon];
			[self postValueChangedNotification];
        }

        // Trouve les autres beacons
		else if (closestBeacon.proximity == CLProximityNear) {
            [self.currentBeacons addObject:closestBeacon];
			[self postValueChangedNotification];
		}
		else {
            [self.currentBeacons addObject:closestBeacon];
			[self postValueChangedNotification];
		}
	}

    // Aucun beacon n'a été trouvé - le signal a été perdu
	else {
		[self postValueChangedNotification];
		return;
	}
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
	[self postValueChangedNotification];

	if (error.description) {
		NSLog(@"Location error while ranging. Description: %@", error.description);
	}
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
	[self postValueChangedNotification];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	[self postValueChangedNotification];

	if (error.description) {
        NSLog(@"Location error while monitoring. Description: %@", error.description);
	}
}

#pragma mark - Ranging

- (void)startBeaconRangingInRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
}

- (void)stopBeaconRangingInRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
}

#pragma mark - Authorization status

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	if (status == kCLAuthorizationStatusAuthorized) {
		[self initialize];
	} else if (status == kCLAuthorizationStatusDenied) {
		[[[UIAlertView alloc] initWithTitle:nil
		                            message:NSLocalizedString(@"Merci d'activer les services de localisation.", @"Merci d'activer les services de localisation.")
		                           delegate:nil
		                  cancelButtonTitle:nil
		                  otherButtonTitles:@"OK", nil] show];
	}
}

#pragma mark -

- (void)postValueChangedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:XBBeaconLocationManagerValueChangedNotification object:nil userInfo:nil];
}

- (NSArray *)allBeacons {
    return _currentBeacons;
}

@end
