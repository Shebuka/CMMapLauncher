// CMMapLauncher.m
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

#import "CMMapLauncher.h"

@interface CMMapLauncher ()

+ (NSString *)urlPrefixForMapApp:(CMMapApp)mapApp;
+ (NSString *)nameForMapApp:(CMMapApp)mapApp;
+ (NSString *)urlEncode:(NSString *)queryParam;
+ (BOOL)openMapURL:(NSURL *)url;

@end

static NSString *const LOG_TAG = @"CMMapLauncher";
static BOOL debugEnabled;


@implementation CMMapLauncher

+ (void)initialize {
#ifdef DEBUG
    debugEnabled = TRUE;
#else
    debugEnabled = FALSE;
#endif
}

+ (void)enableDebugLogging {
    debugEnabled = TRUE;
    [self logDebug:@"Debug logging enabled"];
}

+ (void)logDebug:(NSString *)msg {
    if (debugEnabled) {
        NSLog(@"%@: %@", LOG_TAG, msg);
    }
}

+ (void)logDebugURI:(NSString *)msg {
    [self logDebug:[NSString stringWithFormat:@"Launching URI: %@", msg]];
}

+ (NSString *)urlPrefixForMapApp:(CMMapApp)mapApp {
    switch (mapApp) {
        case CMMapAppCitymapper:
            return @"citymapper";
            
        case CMMapAppGoogleMaps:
            return @"comgooglemaps";
            
        case CMMapAppNavigon:
            return @"navigon";
            
        case CMMapAppTheTransitApp:
            return @"transit";
            
        case CMMapAppWaze:
            return @"waze";
            
        case CMMapAppYandex:
            return @"yandexnavi";
            
        case CMMapAppUber:
            return @"uber";
            
        case CMMapAppSygic:
            return @"com.sygic.aura";
            
        case CMMapAppHereMaps:
            return @"here-route";
            
        case CMMapAppMoovit:
            return @"moovit";
            
        default:
            return nil;
    }
}

+ (NSString *)nameForMapApp:(CMMapApp)mapApp {
    switch (mapApp) {
        case CMMapAppAppleMaps:
            return @"Apple Maps";   //ok
            
        case CMMapAppCitymapper:
            return @"Citymapper";   //ok
            
        case CMMapAppGoogleMaps:
            return @"Google Maps";  //ok
            
        case CMMapAppNavigon:
            return @"Navigon";      //?
            
        case CMMapAppTheTransitApp:
            return @"Transit";      //ok
            
        case CMMapAppWaze:
            return @"Waze";         //ok
            
        case CMMapAppYandex:
            return @"Yandex.Navi";  //ok
            
        case CMMapAppUber:
            return @"Uber";         //ok
            
        case CMMapAppSygic:
            return @"Sygic GPS";    //ok
            
        case CMMapAppHereMaps:
            return @"HERE WeGo";    //ok
            
        case CMMapAppMoovit:
            return @"Moovit";       //ok
            
        default:
            return nil;
    }
}

//case .lyft: return "Lyft"
//case .dbnavigator: return "DB Navigator"

+ (NSString *)urlEncode:(NSString *)queryParam {
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSString *newString = [queryParam stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    if (newString) {
        return newString;
    }
    
    return @"";
}

+ (BOOL)openMapURL:(NSURL *)url {
    UIApplication *application = [UIApplication sharedApplication];
    
    if (@available(iOS 10.0, *)) {
        [application openURL:url options:@{}
           completionHandler:^(BOOL success) {
               [self logDebug:[NSString stringWithFormat:@"CMMapLauncher::openMapUrl: %@: %d", url, success]];
           }];
        return YES;
    }
    else {
        BOOL success = [application openURL:url];
        [self logDebug:[NSString stringWithFormat:@"CMMapLauncher::openMapUrl: %@: %d", url, success]];
        return success;
    }
}

+ (NSString *)extrasToQueryParams:(NSDictionary *)extras {
    NSString *queryParams = @"";
    NSEnumerator *keyEnum = [extras keyEnumerator];
    id key;
    while ((key = [keyEnum nextObject])) {
        id value = [extras objectForKey:key];
        queryParams = [NSString stringWithFormat:@"%@&%@=%@)", queryParams, key, [self urlEncode:value]];
    }
    return queryParams;
}

+ (BOOL)isMapAppInstalled:(CMMapApp)mapApp {
    if (mapApp == CMMapAppAppleMaps) {
        return YES;
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = [CMMapLauncher urlPrefixForMapApp:mapApp];
    if (!components.URL) {
        return NO;
    }
    
    return [[UIApplication sharedApplication] canOpenURL:components.URL];
}

+ (void)showActionSheetWithMapAppOptionsInViewController:(UIViewController *)aController forPosition:(CMMapPoint *)aPosition {
    
    // Create new alert controller
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Add cancel action
    UIAlertAction *alertCancelAction = [UIAlertAction actionWithTitle:@"✕" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self logDebug:@"CMMapLauncher::showActionSheetWithMapAppOptionsForPosition: Cancel action"];
    }];
    [alertController addAction:alertCancelAction];
    
    for (NSUInteger x = 0; x < CMMapAppLast; x++) {
        if ([self isMapAppInstalled:x]) {
            NSString *mapAppName = [self nameForMapApp:x];
            
            UIAlertAction *alertMemberInfoAction = [UIAlertAction actionWithTitle:mapAppName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *log = [NSString stringWithFormat:@"CMMapLauncher::showActionSheetWithMapAppOptionsForPosition: %@ action", mapAppName];
                [self logDebug:log];
                
                [self launchMapApp:x forPosition:aPosition];
            }];
            [alertController addAction:alertMemberInfoAction];
        }
    }
    
    // Present the alert controller
    [aController presentViewController:alertController animated:YES completion:nil];
}

+ (BOOL)launchMapApp:(CMMapApp)mapApp forPosition:(CMMapPoint *)position {
    return [CMMapLauncher launchMapApp:mapApp forDirectionsFrom:nil to:position directionsMode:nil];
}

+ (BOOL)launchMapApp:(CMMapApp)mapApp forDirectionsTo:(CMMapPoint *)end {
    return [CMMapLauncher launchMapApp:mapApp forDirectionsTo:end directionsMode:CMDirectionsModeDriving];
}

+ (BOOL)launchMapApp:(CMMapApp)mapApp forDirectionsTo:(CMMapPoint *)end directionsMode:(NSString *)directionsMode {
    return [CMMapLauncher launchMapApp:mapApp forDirectionsFrom:[CMMapPoint currentLocation] to:end directionsMode:directionsMode];
}

+ (BOOL)launchMapApp:(CMMapApp)mapApp forDirectionsFrom:(CMMapPoint *)start to:(CMMapPoint *)end {
    return [CMMapLauncher launchMapApp:mapApp forDirectionsFrom:start to:end directionsMode:CMDirectionsModeDriving];
}

+ (BOOL)launchMapApp:(CMMapApp)mapApp forDirectionsFrom:(CMMapPoint *)start to:(CMMapPoint *)end directionsMode:(NSString *)directionsMode {
    return [CMMapLauncher launchMapApp:mapApp forDirectionsFrom:start to:end directionsMode:directionsMode extras:nil];
}

// Main method
+ (BOOL)launchMapApp:(CMMapApp)mapApp forDirectionsFrom:(CMMapPoint *)start to:(CMMapPoint *)end directionsMode:(NSString *)directionsMode extras:(NSDictionary*)extras {
    if (![CMMapLauncher isMapAppInstalled:mapApp]) {
        return NO;
    }
    
    if (end == nil)
        return NO;
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:@""];
    NSMutableArray *queryItems = [NSMutableArray array];
    
    if (mapApp == CMMapAppAppleMaps) {
        NSMutableDictionary *launchOptions = [NSMutableDictionary dictionary];
        
        if ([directionsMode isEqual:CMDirectionsModeDriving]) {
            directionsMode = MKLaunchOptionsDirectionsModeDriving;
        }
        else if ([directionsMode isEqual:CMDirectionsModeWalking]) {
            directionsMode = MKLaunchOptionsDirectionsModeWalking;
        }
        else if ([directionsMode isEqual:CMDirectionsModeTransit]) {
            directionsMode = MKLaunchOptionsDirectionsModeTransit;
        }
        
        if (directionsMode)
            [launchOptions addEntriesFromDictionary:@{ MKLaunchOptionsDirectionsModeKey: directionsMode }];
        
        for (id key in extras) {
            id value = extras[key];
            [launchOptions addEntriesFromDictionary:@{ key: value }];
        }
        
        [self logDebug:[NSString stringWithFormat:@"Launching Apple Maps: destAddress=%@; destLatLon=%f,%f; destName=%@; startAddress=%@; startLatLon=%f,%f; startName=%@; directionsMode=%@; extras=%@",
                        end.address, end.coordinate.latitude, end.coordinate.longitude, end.name, start.address, start.coordinate.latitude, start.coordinate.longitude, start.name, directionsMode, extras]];
        
        NSMutableArray *array = [NSMutableArray array];
        if (start)
            [array addObject:start.MKMapItem];
        if (end)
            [array addObject:end.MKMapItem];
        
        return [MKMapItem openMapsWithItems:array launchOptions:launchOptions];
    }
    else if (mapApp == CMMapAppGoogleMaps) {
        // https://developers.google.com/maps/documentation/urls/ios-urlscheme#search
        
        urlComponents.scheme = [CMMapLauncher urlPrefixForMapApp:mapApp];
        urlComponents.host = @"maps";
        
        if (directionsMode == nil || start == nil) {
            if (end.name)
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"q" value:end.name] ];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"center" value:[end coordinateString]] ];
        }
        else {
            if (!start.isCurrentLocation)
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"saddr" value:[start coordinateString]] ];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"daddr" value:[end coordinateString]] ];
            if (directionsMode)
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"directionsmode" value:directionsMode] ];
        }
        
        // extras can be: zoom=<zoom_level>
        for (NSString *key in extras) {
            NSString *value = extras[key];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value] ];
        }
        
        urlComponents.queryItems = queryItems;
        
        [self logDebugURI:urlComponents.string];
        return [CMMapLauncher openMapURL:urlComponents.URL];
    }
    else if (mapApp == CMMapAppCitymapper) {
        // https://citymapper.com/tools/1053/launch-citymapper-for-directions
        
        urlComponents.scheme = [CMMapLauncher urlPrefixForMapApp:mapApp];
        urlComponents.host = @"directions";
        
        if (start && !start.isCurrentLocation) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"startcoord" value:[start coordinateString]] ];
            if (start.name)
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"startname" value:start.name] ];
            if (start.address)
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"startaddress" value:start.address] ];
        }
        if (!end.isCurrentLocation) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"endcoord" value:[end coordinateString]] ];
            if (end.name)
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"endname" value:end.name] ];
            if (end.address)
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"endaddress" value:end.address] ];
        }
        
        // extras can be: arriveby=<ISO-8601 (yyyy-MM-ddTHH:mm:ssZ)>
        for (NSString *key in extras) {
            NSString *value = extras[key];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value] ];
        }
        
        urlComponents.queryItems = queryItems;
        
        [self logDebugURI:urlComponents.string];
        return [CMMapLauncher openMapURL:urlComponents.URL];
    }
    else if (mapApp == CMMapAppTheTransitApp) {
        // http://thetransitapp.com/developers
        
        urlComponents.scheme = [CMMapLauncher urlPrefixForMapApp:mapApp];
        
        if (directionsMode == nil || start == nil) {
            urlComponents.host = @"routes";
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"q" value:[end coordinateString]] ];
        }
        else {
            urlComponents.host = @"directions";
            if (!start.isCurrentLocation)
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"from" value:[start coordinateString]] ];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"to" value:[end coordinateString]] ];
        }
        
        // extras can be: none
        
        urlComponents.queryItems = queryItems;
        
        [self logDebugURI:urlComponents.string];
        return [CMMapLauncher openMapURL:urlComponents.URL];
    }
    else if (mapApp == CMMapAppNavigon) {
        // http://www.navigon.com/portal/common/faq/files/NAVIGON_AppInteract.pdf
        
        urlComponents.scheme = [CMMapLauncher urlPrefixForMapApp:mapApp];
        urlComponents.host = @"coordinate";
        
        if (end.name == nil)
            end.name = end.coordinateString;
        
        NSString *destination = @"/";
        destination = [destination stringByAppendingString:end.name];
        destination = [destination stringByAppendingPathComponent:end.coordinateString];
        
        urlComponents.path = destination;
        
        // extras can be: none
        
        [self logDebugURI:urlComponents.string];
        return [CMMapLauncher openMapURL:urlComponents.URL];
    }
    else if (mapApp == CMMapAppWaze) {
        // https://developers.google.com/waze/deeplinks/#urls
        
        urlComponents.scheme = [CMMapLauncher urlPrefixForMapApp:mapApp];
        urlComponents.host = @"";
        
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"ll" value:[end coordinateString]] ];
        
        if (directionsMode)
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"navigate" value:@"yes"] ];
        
        // extras can be: z=magnification_level
        for (NSString *key in extras) {
            NSString *value = extras[key];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value] ];
        }
        
        urlComponents.queryItems = queryItems;
        
        [self logDebugURI:urlComponents.string];
        return [CMMapLauncher openMapURL:urlComponents.URL];
    }
    else if (mapApp == CMMapAppYandex) {
        // https://tech.yandex.ru/yandex-apps-launch/navigator/doc/concepts/navigator-url-params-docpage/
        
        urlComponents.scheme = [CMMapLauncher urlPrefixForMapApp:mapApp];
        
        if (directionsMode == nil || start == nil) {
            urlComponents.host = @"show_point_on_map";
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"lat" value:[@(end.coordinate.latitude) stringValue]] ];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"lon" value:[@(end.coordinate.longitude) stringValue]] ];
            if (end.name)
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"desc" value:end.name] ];
            
            // extras can be: zoom=<int>, no-balloon=<int>
            for (NSString *key in extras) {
                NSString *value = extras[key];
                [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value] ];
            }
        }
        else {
            urlComponents.host = @"build_route_on_map";
            if (start && !start.isCurrentLocation) {
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"lat_from" value:[@(start.coordinate.latitude) stringValue]] ];
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"lon_from" value:[@(start.coordinate.longitude) stringValue]] ];
            }
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"lat_to" value:[@(end.coordinate.latitude) stringValue]] ];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"lon_to" value:[@(end.coordinate.longitude) stringValue]] ];
            
            // extras can be: none
        }
        
        urlComponents.queryItems = queryItems;
        
        [self logDebugURI:urlComponents.string];
        return [CMMapLauncher openMapURL:urlComponents.URL];
    }
    else if (mapApp == CMMapAppUber) {
        // https://developer.uber.com/docs/riders/ride-requests/tutorials/deep-links/introduction
        
        urlComponents.scheme = [CMMapLauncher urlPrefixForMapApp:mapApp];
        //urlComponents.host = @"uber";

        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"action" value:@"setPickup"] ];
        
        if (start == nil || start.isCurrentLocation) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"pickup" value:@"my_location"] ];
        }
        else {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"pickup[latitude]" value:[@(start.coordinate.latitude) stringValue]] ];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"pickup[longitude]" value:[@(start.coordinate.longitude) stringValue]] ];
            if (start.name == nil)
                start.name = @"PickUp";
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"pickup[nickname]" value:start.name] ];
        }
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"dropoff[latitude]" value:[@(end.coordinate.latitude) stringValue]] ];
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"dropoff[longitude]" value:[@(end.coordinate.longitude) stringValue]] ];
        if (end.name == nil)
            end.name = @"DropOff";
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"dropoff[nickname]" value:end.name] ];
        
        // extras can be: client_id=<client_id>, pickup[formatted_address]=<formatted_address>, dropoff[formatted_address]=<formatted_address>, product_id=<product_id>, link_text=<link_text>, partner_deeplink=<partner_deeplink>
        for (NSString *key in extras) {
            NSString *value = extras[key];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value] ];
        }
        
        urlComponents.queryItems = queryItems;
        
        [self logDebugURI:urlComponents.string];
        return [CMMapLauncher openMapURL:urlComponents.URL];
    }
    else if (mapApp == CMMapAppSygic) {
        // https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url/
        
        urlComponents.scheme = [CMMapLauncher urlPrefixForMapApp:mapApp];
        urlComponents.host = @"";
        
        NSMutableArray *query = [NSMutableArray array];
        
        if (directionsMode != nil && directionsMode == CMDirectionsModeWalking && end.name)
            [query addObject:@"coordinateaddr"];
        else
            [query addObject:@"coordinate"];
        
        [query addObject:[@(end.coordinate.longitude) stringValue]];
        [query addObject:[@(end.coordinate.latitude) stringValue]];
        
        if (directionsMode != nil && directionsMode == CMDirectionsModeWalking && end.name)
            [query addObject:end.name];
        
        if (directionsMode == nil) {
            [query addObject:@"show"];
        }
        else if (directionsMode == CMDirectionsModeWalking) {
            [query addObject:@"walk"];
        }
        else {
            [query addObject:@"drive"];
        }
        
        urlComponents.host = [query componentsJoinedByString:@"|"];
        
        // extras can be: none
        
        [self logDebugURI:urlComponents.string];
        return [CMMapLauncher openMapURL:urlComponents.URL];
    }
    else if (mapApp == CMMapAppHereMaps) {
        // https://developer.here.com/documentation/mobility-on-demand-toolkit/topics/navigation.html
        
        urlComponents.scheme = [CMMapLauncher urlPrefixForMapApp:mapApp];
        
        urlComponents.host = @"mylocation";
        
        NSString *destination = @"/";
        destination = [destination stringByAppendingString:[end coordinateString]];
        if (end.name)
            destination = [destination stringByAppendingFormat:@",%@", [end.name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        
        urlComponents.path = destination;
        
        if (directionsMode != nil) {
            if (directionsMode == CMDirectionsModeWalking)
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"m" value:@"w"] ];
            else
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"m" value:@"d"] ];
        }
        
        // extras can be: ref=<Referrer>
        for (NSString *key in extras) {
            NSString *value = extras[key];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value] ];
        }
        
        urlComponents.queryItems = queryItems;
        
        [self logDebugURI:urlComponents.string];
        return [CMMapLauncher openMapURL:urlComponents.URL];
    }
    else if (mapApp == CMMapAppMoovit) {
        // https://www.developers.moovit.com/deeplinking-your-app
        
        urlComponents.scheme = [CMMapLauncher urlPrefixForMapApp:mapApp];
        
        if (directionsMode == nil) {
            urlComponents.host = @"nearby";
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"lat" value:[@(end.coordinate.latitude) stringValue]] ];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"lon" value:[@(end.coordinate.longitude) stringValue]] ];
            
            // extras can be: partner_id=<YOUR_APP_NAME>
            for (NSString *key in extras) {
                NSString *value = extras[key];
                [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value] ];
            }
        }
        else {
            urlComponents.host = @"directions";
            if (start && !start.isCurrentLocation) {
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"orig_lat" value:[@(start.coordinate.latitude) stringValue]] ];
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"orig_lon" value:[@(start.coordinate.longitude) stringValue]] ];
                if (start.name)
                    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"orig_name" value:start.name] ];
            }
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"dest_lat" value:[@(end.coordinate.latitude) stringValue]] ];
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"dest_lon" value:[@(end.coordinate.longitude) stringValue]] ];
            if (end.name)
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"dest_name" value:end.name] ];
            
            // extras can be: auto_run=<true|false>, date=<ISO-8601 (yyyy-MM-ddTHH:mm:ssZ)>, partner_id=<YOUR_APP_NAME>
            for (NSString *key in extras) {
                NSString *value = extras[key];
                [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value] ];
            }
        }
        
        urlComponents.queryItems = queryItems;
        
        [self logDebugURI:urlComponents.string];
        return [CMMapLauncher openMapURL:urlComponents.URL];
    }
    return NO;
}

@end


///--------------------------
/// CMMapPoint (helper class)
///--------------------------

@implementation CMMapPoint

+ (CMMapPoint *)currentLocation {
    CMMapPoint *mapPoint = [[CMMapPoint alloc] init];
    mapPoint.isCurrentLocation = YES;
    return mapPoint;
}

+ (CMMapPoint *)mapPointWithCoordinate:(CLLocationCoordinate2D)coordinate {
    CMMapPoint *mapPoint = [[CMMapPoint alloc] init];
    mapPoint.coordinate = coordinate;
    return mapPoint;
}

+ (CMMapPoint *)mapPointWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate {
    CMMapPoint *mapPoint = [[CMMapPoint alloc] init];
    mapPoint.name = name;
    mapPoint.coordinate = coordinate;
    return mapPoint;
}

+ (CMMapPoint *)mapPointWithName:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate {
    CMMapPoint *mapPoint = [[CMMapPoint alloc] init];
    mapPoint.name = name;
    mapPoint.address = address;
    mapPoint.coordinate = coordinate;
    return mapPoint;
}

+ (CMMapPoint *)mapPointWithAddress:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate {
    CMMapPoint *mapPoint = [[CMMapPoint alloc] init];
    mapPoint.address = address;
    mapPoint.coordinate = coordinate;
    return mapPoint;
}

- (NSString *)name {
    if (_isCurrentLocation) {
        return @"Current Location";
    }
    
    return _name;
}

- (MKMapItem *)MKMapItem {
    if (_isCurrentLocation) {
        return [MKMapItem mapItemForCurrentLocation];
    }
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:_coordinate addressDictionary:nil];
    
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = self.name;
    return item;
}

+ (CMMapPoint *)mapPointWithMapItem:(MKMapItem *)mapItem name:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate {
    CMMapPoint *mapPoint = [[CMMapPoint alloc] init];
    mapPoint.MKMapItem = mapItem;
    mapPoint.name = name;
    mapPoint.address = address;
    mapPoint.coordinate = coordinate;
    return mapPoint;
}

- (NSString *)coordinateString {
//    return [NSString stringWithFormat:@"%f,%f", self.coordinate.latitude, self.coordinate.longitude];
    return [NSString stringWithFormat:@"%@,%@", [@(self.coordinate.latitude) stringValue], [@(self.coordinate.longitude) stringValue]];
}

@end

