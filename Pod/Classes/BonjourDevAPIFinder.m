//
//  BonjourDevAPIFinder.m
//  Pods
//
//  Created by Tomek Kopczuk on 28.11.2014.
//
//

#import <Tweaks/FBTweakInline.h>

#import "LookForDevServersViewController.h"
#import "BonjourDevAPIFinder.h"

@interface BonjourDevAPIFinder ()

@property (strong, nonatomic) NSMutableDictionary *apis;

@end

@implementation BonjourDevAPIFinder

+ (id)sharedInstance
{
    static BonjourDevAPIFinder *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _apis = [@{} mutableCopy];
    }
    return self;
}

#pragma mark - Helpers
- (FBTweakCategory *)tweakCategory
{
    FBTweakStore *store = [FBTweakStore sharedInstance];
    
    FBTweakCategory *category = [store tweakCategoryWithName:@"Environment"];
    if (!category) {
        category = [[FBTweakCategory alloc] initWithName:@"Environment"];
        [store addTweakCategory:category];
    }

    return category;
}

- (FBTweakCollection *)tweakCollectionForName:(NSString *)name
{
    FBTweakCategory *category = [self tweakCategory];
    
    FBTweakCollection *collection = [category tweakCollectionWithName:name];
    if (!collection) {
        collection = [[FBTweakCollection alloc] initWithName:name];
        [category addTweakCollection:collection];
    }
    
    return collection;
}

#pragma mark - Tweaks access
- (FBTweak *)useDevTweakForIdentifier:(NSString*)identifier
{
    NSString *tweakIdentifier = self.apis[identifier][@"useDevId"];
    
    FBTweakCollection *collection = [self tweakCollectionForName:self.apis[identifier][@"collectionName"]];
    return [collection tweakWithIdentifier:tweakIdentifier];
}
- (FBTweak *)devUrlTweakForIdentifier:(NSString*)identifier
{
    NSString *tweakIdentifier = self.apis[identifier][@"devApiId"];
    
    FBTweakCollection *collection = [self tweakCollectionForName:self.apis[identifier][@"collectionName"]];
    return [collection tweakWithIdentifier:tweakIdentifier];
}

#pragma mark - API registration
- (void)addApiService:(NSString *)name identifier:(NSString *)identifier
{
    NSString *tweakIdentifierPrefix = @"com.tweaks.bonjourdevapifinder";

    FBTweak *browseActionTweak = [[FBTweak alloc] initWithIdentifier:[@[tweakIdentifierPrefix, identifier, @"browse"] componentsJoinedByString:@"."]];
    browseActionTweak.name = @"Browse";
    browseActionTweak.defaultValue = ^{
        NSString *advPrefix = [[_advertisedPrefix substringToIndex:15] lowercaseString];
        LookForDevServersViewController *browseViewController = [[LookForDevServersViewController alloc] initWithApiName:name
                                                                                                        andAPIIdentifier:identifier];

        UIWindow *window = [UIApplication.sharedApplication delegate].window;
        UIViewController *visibleViewController = window.rootViewController;
        while (visibleViewController.presentedViewController != nil) {
            visibleViewController = visibleViewController.presentedViewController;
        }
       
        if ([visibleViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *visibleNavigationController = (UINavigationController*) visibleViewController;
            [visibleNavigationController pushViewController:browseViewController
                                                   animated:YES];
        }
    };

    FBTweak *useDevTweak = [[FBTweak alloc] initWithIdentifier:[@[tweakIdentifierPrefix, identifier, @"useDev"] componentsJoinedByString:@"."]];
    useDevTweak.name = @"Use dev";
    useDevTweak.defaultValue = @NO;

    FBTweak *devApiTweak = [[FBTweak alloc] initWithIdentifier:[@[tweakIdentifierPrefix, identifier, @"devApi"] componentsJoinedByString:@"."]];
    devApiTweak.name = @"dev api url";
    devApiTweak.defaultValue = @"";
    
    FBTweakCollection *collection = [self tweakCollectionForName:name];
    [collection addTweak:browseActionTweak];
    [collection addTweak:useDevTweak];
    [collection addTweak:devApiTweak];
    
    self.apis[identifier] = @{
                              @"collectionName": collection.name,
                              @"browseActionId": browseActionTweak.identifier,
                              @"useDevId": useDevTweak.identifier,
                              @"devApiId": devApiTweak.identifier,
                              };
}

#pragma mark - API address retrieval
- (NSString *)apiAddressForIdentifier:(NSString *)identifier defaultAPIAddress:(NSString*)defaultAddress
{
    BOOL useDevelopmentServer   = [[self useDevTweakForIdentifier:identifier].currentValue boolValue];
    NSString *developmentApiURL = [self devUrlTweakForIdentifier:identifier].currentValue;
    
    if (useDevelopmentServer && developmentApiURL) {
        return developmentApiURL;
    }
    
    return defaultAddress;
}

@end
