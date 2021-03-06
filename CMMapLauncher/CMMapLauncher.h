// CMMapLauncher.h
// Last updated 2013-08-26
//
// Copyright (c) 2013 Citymapper Ltd. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// README
//
// This pair of classes simplifies the process of launching various mapping
// applications to display directions.  Here's the simplest use case:
//
// CLLocationCoordinate2D bigBen =
//     CLCLLocationCoordinate2DMake(51.500755, -0.124626);
// [CMMapLauncher launchMapApp:CMMapAppAppleMaps
//             forDirectionsTo:[CMMapPoint mapPointWithName:@"Big Ben"
//                                               coordinate:bigBen]];

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class CMMapPoint;

///---------------------------
/// CMMapLauncher (main class)
///---------------------------

// This enumeration identifies the mapping apps
// that this launcher knows how to support.
typedef NS_ENUM(NSUInteger, CMMapApp) {
    CMMapAppAppleMaps = 0,  // Preinstalled Apple Maps
    // Navigation apps (by ranking)
    CMMapAppGoogleMaps,     // Standalone Google Maps App
    CMMapAppWaze,           // Waze
    CMMapAppHereMaps,       // HERE Maps
    CMMapAppSygic,          // Sygic
    CMMapAppYandex,         // Yandex Navigator
    CMMapAppNavigon,        // Navigon
    // Taxi apps (by ranking)
    CMMapAppUber,           // Uber
    // Transit apps (by ranking)
    CMMapAppMoovit,         // Moovit
    CMMapAppCitymapper,     // Citymapper
    CMMapAppTheTransitApp,  // The Transit App
    
    CMMapAppLast            // Must be always last
};

NSString *const CMDirectionsModeDriving = @"driving";
NSString *const CMDirectionsModeWalking = @"walking";
NSString *const CMDirectionsModeTransit = @"transit";

@interface CMMapLauncher : NSObject

/**
 Enables debug logging which logs resulting URL scheme to console
 */
+ (void)enableDebugLogging;

/**
 Determines whether the given mapping app is installed.

 @param mapApp An enumeration value identifying a mapping application.

 @return YES if the specified app is installed, NO otherwise.
 */
+ (BOOL)isMapAppInstalled:(CMMapApp)mapApp;

/**
 Shows the action sheet with all available mapping apps as options
 to where show the desired point.
 
 @param controller A view controller that will present the action sheet.
 @param position The position of the desired point to show.
 */
+ (void)showActionSheetWithMapAppOptionsInViewController:(UIViewController *)controller fromBarButtonItem:(UIBarButtonItem *)aBarButtonItem forPosition:(CMMapPoint *)position;

/**
 Launches the specified mapping application with position
 of the specific specified point.
 
 @param mapApp An enumeration value identifying a mapping application.
 @param position The position of the desired point to show.
 
 @return YES if the mapping app could be launched, NO otherwise.
 */
+ (BOOL)launchMapApp:(CMMapApp)mapApp forPosition:(CMMapPoint *)position;

/**
 Launches the specified mapping application with directions
 from the user's current location to the specified endpoint.

 @param mapApp An enumeration value identifying a mapping application.
 @param end The destination of the desired directions.

 @return YES if the mapping app could be launched, NO otherwise.
 */
+ (BOOL)launchMapApp:(CMMapApp)mapApp forDirectionsTo:(CMMapPoint *)end;

/**
 Launches the specified mapping application with directions
 from the user's current location to the specified endpoint
 and using the specified transport mode.
 
 @param mapApp An enumeration value identifying a mapping application.
 @param end The destination of the desired directions.
 @param directionsMode transport mode to use when getting directions.
 
 @return YES if the mapping app could be launched, NO otherwise.
 */
+ (BOOL)launchMapApp:(CMMapApp)mapApp forDirectionsTo:(CMMapPoint *)end directionsMode:(NSString *)directionsMode;

/**
 Launches the specified mapping application with directions
 between the two specified endpoints.

 @param mapApp An enumeration value identifying a mapping application.
 @param start The starting point of the desired directions.
 @param end The destination of the desired directions.

 @return YES if the mapping app could be launched, NO otherwise.
 */
+ (BOOL)launchMapApp:(CMMapApp)mapApp forDirectionsFrom:(CMMapPoint *)start to:(CMMapPoint *)end;

/**
 Launches the specified mapping application with directions
 between the two specified endpoints
 and using the specified transport mode.
 
 @param mapApp An enumeration value identifying a mapping application.
 @param start The starting point of the desired directions.
 @param end The destination of the desired directions.
 @param directionsMode transport mode to use when getting directions.

 @return YES if the mapping app could be launched, NO otherwise.
 */
+ (BOOL)launchMapApp:(CMMapApp)mapApp forDirectionsFrom:(CMMapPoint *)start to:(CMMapPoint *)end directionsMode:(NSString *)directionsMode;

/**
 Launches the specified mapping application with directions
 between the two specified endpoints
 and using the specified transport mode
 and including app-specific extra parameters

 @param mapApp An enumeration value identifying a mapping application.
 @param start The starting point of the desired directions.
 @param end The destination of the desired directions.
 @param directionsMode transport mode to use when getting directions.
 @param extras key/value map of app-specific extra parameters to pass to launched app

 @return YES if the mapping app could be launched, NO otherwise.
 */
+ (BOOL)launchMapApp:(CMMapApp)mapApp forDirectionsFrom:(CMMapPoint *)start to:(CMMapPoint *)end directionsMode:(NSString *)directionsMode extras:(NSDictionary *)extras;

@end


///--------------------------
/// CMMapPoint (helper class)
///--------------------------

@interface CMMapPoint : NSObject

/**
 Determines whether this map point represents the user's current location.
 */
@property (nonatomic, assign) BOOL isCurrentLocation;

/**
 The geographical coordinate of the map point.
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 The user-visible name of the given map point (optional, may be nil).
 */
@property (nonatomic, copy) NSString *name;

/**
 The address of the given map point (optional, may be nil).
 */
@property (nonatomic, copy) NSString *address;

/**
 Gives an MKMapItem corresponding to this map point object.
 */
@property (nonatomic, retain) MKMapItem *MKMapItem;

/**
 Creates a new CMMapPoint that signifies the current location.
 */
+ (CMMapPoint *)currentLocation;

/**
 Creates a new CMMapPoint with the given geographical coordinate.

 @param coordinate The geographical coordinate of the new map point.
 */
+ (CMMapPoint *)mapPointWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 Creates a new CMMapPoint with the given name and coordinate.

 @param name The user-visible name of the new map point.
 @param coordinate The geographical coordinate of the new map point.
 */
+ (CMMapPoint *)mapPointWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate;

/**
 Creates a new CMMapPoint with the given name, address, and coordinate.

 @param name The user-visible name of the new map point.
 @param address The address string of the new map point.
 @param coordinate The geographical coordinate of the new map point.
 */
+ (CMMapPoint *)mapPointWithName:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate;

/**
 Creates a new CMMapPoint with the given name, address, and coordinate.

 @param address The address string of the new map point.
 @param coordinate The geographical coordinate of the new map point.
 */
+ (CMMapPoint *)mapPointWithAddress:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate;


+ (CMMapPoint *)mapPointWithMapItem:(MKMapItem *)mapItem name:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate;

/**
 Creates a new NSString from coordinates
 
 @return String in format longitude,latitude
 */
- (NSString *)coordinateString;

@end
