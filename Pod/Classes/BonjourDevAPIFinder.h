//
//  BonjourDevAPIFinder.h
//  Pods
//
//  Created by Tomek Kopczuk on 28.11.2014.
//
//

#import <Foundation/Foundation.h>

@class FBTweak;

@interface BonjourDevAPIFinder : NSObject

@property (strong, nonatomic) NSString *advertisedPrefix;

+ (id)sharedInstance;

- (void)addApiService:(NSString *)name
           identifier:(NSString *)identifier;

- (NSString *)apiAddressForIdentifier:(NSString *)identifier
                    defaultAPIAddress:(NSString *)defaultAddress;

- (FBTweak *)useDevTweakForIdentifier:(NSString *)identifier;
- (FBTweak *)devUrlTweakForIdentifier:(NSString *)identifier;

@end
