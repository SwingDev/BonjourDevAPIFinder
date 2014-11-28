# BonjourDevAPIFinder

[![Version](https://img.shields.io/cocoapods/v/BonjourDevAPIFinder.svg?style=flat)](http://cocoadocs.org/docsets/BonjourDevAPIFinder)
[![License](https://img.shields.io/cocoapods/l/BonjourDevAPIFinder.svg?style=flat)](http://cocoadocs.org/docsets/BonjourDevAPIFinder)
[![Platform](https://img.shields.io/cocoapods/p/BonjourDevAPIFinder.svg?style=flat)](http://cocoadocs.org/docsets/BonjourDevAPIFinder)

## Demo

### Switch to local network development server, discovered by Bonjour

![Production to Development](https://cloud.githubusercontent.com/assets/101632/5231656/4d293416-773c-11e4-9b08-06cbb289fe11.gif)

### Switch back to using the original API address

![Development to Production](https://cloud.githubusercontent.com/assets/101632/5231655/4cf337ee-773c-11e4-90e1-a22ab76b69f0.gif)

## Installation

BonjourDevAPIFinder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "BonjourDevAPIFinder"

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Enabling Tweaks

BonjourDevAPIFinder uses Tweaks.

You need to make sure Tweaks have a way to be opened (see [Tweaks docs](https://github.com/facebook/Tweaks)).

### Adding APIs

Anywhere in your project, before using an api address execute:

    [BonjourDevAPIFinder.sharedInstance addApiService:@"API server"
                                           identifier:@"example"];

`identifier` is the Bonjour advertised name for your service.

To retrieve currently chosen API address use:

    [BonjourDevAPIFinder.sharedInstance apiAddressForIdentifier:@"example"
                                              defaultAPIAddress:@"api.example.com"];


That's it!

Tip: you can add more than just one address. 

### Enabling the server to advertise it's existence

#### Node.js®

    var mdns = require("mdns");
    var ad = mdns.createAdvertisement(mdns.tcp(advertisedName), port);
    ad.start();

Sample Bonjour-enabled node server project attached in the `Server Example` folder.

## Author

Tomek Kopczuk, tkopczuk@gmail.com

[Swing Development](http://swingdev.io)

## License

BonjourDevAPIFinder is available under the MIT license. See the LICENSE file for more info.

