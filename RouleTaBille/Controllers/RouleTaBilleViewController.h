//
//  RouleTaBilleViewController.h
//  RouleTaBille
//
//  Created by Thibault Le Cornec on 27/06/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouleTaBilleView.h"
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

@interface RouleTaBilleViewController : UIViewController <AVAudioPlayerDelegate>
{
    NSInteger indexImageToShow;
    NSArray *backgroundImagesURL;
    CMMotionManager *coreMotionManager;
    AVAudioPlayer *soundPlayer;
}

//  Accès pour le AppDelegate qui invalide le timer lorsqu'on sort de l'appli
@property (retain) NSTimer *theTimer;

- (void)updateBallPosition:(NSTimer *)timer;

@end
