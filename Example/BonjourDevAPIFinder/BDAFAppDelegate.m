//
//  BDAFAppDelegate.m
//  BonjourDevAPIFinder
//
//  Created by CocoaPods on 11/28/2014.
//  Copyright (c) 2014 Tomek Kopczuk. All rights reserved.
//

#import <Tweaks/FBTweakShakeWindow.h>

#import "BDAFAppDelegate.h"

@implementation BDAFAppDelegate

#ifdef DEBUG
- (UIWindow *)window {
    if (!_window) {
        _window = [[FBTweakShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    return _window;
}
#endif

@end
