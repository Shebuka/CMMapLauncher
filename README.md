# CMMapLauncher

CMMapLauncher is a mini-library for iOS written in Objective-C that makes it quick and easy to show directions in various mapping applications. 

## Requirements

* Objective-C
* iOS 9+
* MapKit Framework

## Installation

To use it, just add `CMMapLauncher.h` and `CMMapLauncher.m` to your project.

Since iOS 9 to query schemes of installed apps you need to add these entries into your `plist` :

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>comgooglemaps</string>
    <string>waze</string>
    <string>here-route</string>
    <string>com.sygic.aura</string>
    <string>yandexnavi</string>
    <string>navigon</string>
    <string>uber</string>
    <string>moovit</string>
    <string>citymapper</string>
    <string>transit</string>
</array>
```

## Usage

While the source *from/start* `CMMapPoint` is optional and is used only in **directions mode**, the destination *to/end* `CMMapPoint` is always required in both **show point** and **directions modes**.

To check whether one of the supported mapping apps is present on the user's device:

```objective-c
BOOL installed = [CMMapLauncher isMapAppInstalled:CMMapAppCitymapper];
```

Then, to launch into directions in that app:

```objective-c
CLLocationCoordinate2D bigBen = CLLocationCoordinate2DMake(51.500755, -0.124626);

CMMapPoint *mapPoint = [CMMapPoint mapPointWithName:@"Big Ben" coordinate:bigBen];

[CMMapLauncher launchMapApp:CMMapAppCitymapper forDirectionsTo:mapPoint];
```

Instead of checking all the available apps yourself, you can present an actionSheet with all currently available apps by calling:

```objective-c
[CMMapLauncher showActionSheetWithMapAppOptionsInViewController:self fromBarButtonItem:self.navigationItem.rightBarButtonItem forPosition:mapPoint];
```

Enable debug logging to log the launch URI/parameters:

```objective-c
[CMMapLauncher enableDebugLogging];
```

## Supported apps

CMMapLauncher currently knows how to show directions in the following mapping apps:

### Navigation

* Apple Maps &mdash; `CMMapAppAppleMaps`
* Google Maps &mdash; `CMMapAppGoogleMaps`
* Waze &mdash; `CMMapAppWaze`
* HERE Maps &mdash; `CMMapAppHereMaps`
* Sygic &mdash; `CMMapAppSygic`
* Yandex Navigator &mdash; `CMMapAppYandex`
* Navigon &mdash; `CMMapAppNavigon`

### Taxi

* Uber &mdash; `CMMapAppUber`

### Transit

* Moovit &mdash; `CMMapAppMoovit`
* Citymapper &mdash; `CMMapAppCitymapper`
* The Transit App &mdash; `CMMapAppTheTransitApp`

## Contributing

If you know of other direction-providing apps that expose a URL scheme for launching from other apps, this project wants to incorporate them! 

Pull requests and issues providing URL schemes are encouraged. For major changes, please open an issue first to discuss what you would like to change.

## Credits

CMMapLauncher was originally created by [Citymapper](http://citymapper.com), but is released under the MIT License for the benefit of the iOS developer community.

## License
[MIT](https://choosealicense.com/licenses/mit/)
