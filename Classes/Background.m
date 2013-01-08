//
//  Background.m
//  AppScaffold
//
//  Created by Sakib Shaikh on 12/25/11.
//  Copyright 2011 UCLA. All rights reserved.
//

#import "Background.h"


@implementation Background

-(id)init
{
    base = [SPImage imageWithContentsOfFile:@"bubble.png"];
    [self addChild:base];
    
    return self;
}

@end
