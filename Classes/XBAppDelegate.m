- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
	[self postValueChangedNotification];
    
	if (error.description) {
		NSLog(@"Location error while ranging. Description: %@", error.description);
	}
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
	[self postValueChangedNotification];
	if (error.description) {
		NSLog(@"Location error while monitoring. Description: %@", error.description);
	}
}
