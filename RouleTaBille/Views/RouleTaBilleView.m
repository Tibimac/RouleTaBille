//
//  RouleTaBilleView.m
//  RouleTaBille
//
//  Created by Thibault Le Cornec on 27/06/2014.
//  Copyright (c) 2014 Tibimac. All rights reserved.
//

#import "RouleTaBilleView.h"
#import "RouleTaBilleViewController.h"

@implementation RouleTaBilleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        _backgroundView = [[UIImageView alloc] init];
        [_backgroundView setFrame:frame];
        
        _ball = [[UIImageView alloc] init];
        [_ball setFrame:CGRectMake((frame.size.width/2)-25, (frame.size.height/2)-25, 50, 50)];
        [_ball setImage:[UIImage imageNamed:@"ball"]];
        
        [self addSubview:_backgroundView];
        [_backgroundView release];
        [self addSubview:_ball];
        [_ball release];
    }
    
    return self;
}

@end
