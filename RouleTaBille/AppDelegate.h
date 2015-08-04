//
//  AppDelegate.h
//  RouleTaBille
//
//  Created by Thibault Le Cornec on 27/06/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouleTaBilleViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    RouleTaBilleViewController *rootViewController;
}

@property (strong, nonatomic) UIWindow *window;

@end
