//
//  LookForDevServersViewController.m
//  Pods
//
//  Created by Tomek Kopczuk on 28.11.2014.
//
//

#import <arpa/inet.h>

#import <Tweaks/FBTweak.h>
#import <Tweaks/FBTweakInline.h>
#import <Tweaks/_FBTweakTableViewCell.h>

#import "BonjourDevAPIFinder.h"

#import "LookForDevServersViewController.h"

@interface LookForDevServersViewController () <NSNetServiceDelegate, NSNetServiceBrowserDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;

@property (readwrite, nonatomic, getter=isResolving) BOOL resolving;

@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;

@property (readonly, nonatomic) NSString *apiName;
@property (readonly, nonatomic) NSString *apiIdentifier;

@end

@implementation LookForDevServersViewController

- (instancetype)initWithApiName:(NSString *)apiName andAPIIdentifier:(NSString *)apiIdentifier
{
    self = [super init];
    if (self) {
        _apiName       = [apiName copy];
        _apiIdentifier = [apiIdentifier copy];
    }
    return self;
}

-(void)viewDidLoad
{
    self.tableView = [[UITableView alloc] init];
    [self tableView].delegate = self;
    [self tableView].dataSource = self;
    [self tableView].translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]
                              ]];
    
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self spinnerView].color = UIColor.blackColor;
    [self spinnerView].translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_spinnerView];
    
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_spinnerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_spinnerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                                ]];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self startBrowsing];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self stopBrowsing];
}

#pragma mark - Browsing
//
// Considerable parts come from: http://code.tutsplus.com/tutorials/creating-a-game-with-bonjour-client-and-server-setup--mobile-16233
//
- (void)startBrowsing
{
    if (self.services) {
        [self.services removeAllObjects];
    } else {
        self.services = [[NSMutableArray alloc] init];
    }
    
    // Initialize Service Browser
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    
    // Configure Service Browser
    NSString *advertisedName = self.apiIdentifier;
    if (advertisedName.length > 15) {
        advertisedName = [advertisedName substringToIndex:15];
    }
    
    NSString *serviceType = [NSString stringWithFormat:@"_%@._tcp", advertisedName.lowercaseString];
    
    [self.serviceBrowser setDelegate:self];
    [self.serviceBrowser searchForServicesOfType:serviceType inDomain:@""];
}

- (void)stopBrowsing {
    if (self.serviceBrowser) {
        [self.serviceBrowser stop];
        [self.serviceBrowser setDelegate:nil];
        [self setServiceBrowser:nil];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services addObject:service];
    
    if(!moreComing) {
        // Sort Services
        [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        
        // Update Table View
        [self.tableView reloadData];
    }
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services removeObject:service];
    
    if(!moreComing) {
        // Update Table View
        [self.tableView reloadData];
    }
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)serviceBrowser {
    [self stopBrowsing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didNotSearch:(NSDictionary *)userInfo {
    [self stopBrowsing];
}

#pragma mark - Spinner
- (void)setResolving:(BOOL)resolving
{
    _resolving = resolving;
    
    if (self.isResolving) {
        [self.spinnerView startAnimating];
    } else {
        [self.spinnerView stopAnimating];
    }
}

#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.services ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
    
    if (!cell) {
        // Initialize Table View Cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ServiceCell"];
    }
    
    // Fetch Service
    NSNetService *service = [self.services objectAtIndex:[indexPath row]];
    
    // Configure Cell
    [cell.textLabel setText:[service name]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isResolving)
        return;
    
    self.resolving = YES;

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Fetch Service
    NSNetService *service = [self.services objectAtIndex:[indexPath row]];
    
    // Resolve Service
    [service setDelegate:self];
    [service resolveWithTimeout:5.0];
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    [service setDelegate:nil];
    
    self.resolving = NO;
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    self.resolving = NO;
    
    // Following code was created by http://ericscouten.com/ and http://deeperdesign.com/.
    // http://stackoverflow.com/a/4976808/124090
    
    char addressBuffer[INET6_ADDRSTRLEN];
    
    for (NSData *data in service.addresses)
    {
        memset(addressBuffer, 0, INET6_ADDRSTRLEN);
        
        typedef union {
            struct sockaddr sa;
            struct sockaddr_in ipv4;
            struct sockaddr_in6 ipv6;
        } ip_socket_address;
        
        ip_socket_address *socketAddress = (ip_socket_address *)[data bytes];
        
        if (socketAddress && socketAddress->sa.sa_family == AF_INET) {
            const char *addressStr = inet_ntop(
                                               socketAddress->sa.sa_family,
                                               (socketAddress->sa.sa_family == AF_INET ? (void *)&(socketAddress->ipv4.sin_addr) : (void *)&(socketAddress->ipv6.sin6_addr)),
                                               addressBuffer,
                                               sizeof(addressBuffer));
            
            int port = ntohs(socketAddress->sa.sa_family == AF_INET ? socketAddress->ipv4.sin_port : socketAddress->ipv6.sin6_port);
            
            if (addressStr && port) {
                NSString *newDevAPIAddress = [NSString stringWithFormat:@"%s:%i", addressStr, port];
                [self didSelectDevAPIAddress:newDevAPIAddress];
                
                break;
            }
        }
    }
}

- (void)didSelectDevAPIAddress:(NSString *)devAPIAddress
{
    FBTweak *apiUseDevTweak = [BonjourDevAPIFinder.sharedInstance useDevTweakForIdentifier:self.apiIdentifier];
    FBTweak *apiUrlTweak    = [BonjourDevAPIFinder.sharedInstance devUrlTweakForIdentifier:self.apiIdentifier];
    
    [apiUseDevTweak setCurrentValue:@(YES)];
    [apiUrlTweak setCurrentValue:devAPIAddress];
    
    //    Force refreshing of this goddamn FBTweak VC.
    for (UIViewController *viewController in [self navigationController].viewControllers) {
        UIView *firstView = [[viewController view].subviews firstObject];
        
        if ([firstView isKindOfClass:[UITableView class]]) {
            UITableView *tableView = ((UITableView *) firstView);
            
            for (UITableViewCell *cell in tableView.visibleCells) {
                if ([cell isKindOfClass:[_FBTweakTableViewCell class]]) {
                    [(_FBTweakTableViewCell*)cell setTweak:nil];
                }
            }

            [tableView reloadData];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
