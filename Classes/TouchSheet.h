//
//  TouchSheet.h
//  AppScaffold
//
//  Created by Sakib Shaikh on 12/19/11.
//  Copyright 2011 UCLA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sparrow.h"

@interface TouchSheet : SPSprite {
    @private
        SPQuad *mQuad;
}

- (id)initWithQuad:(SPQuad*)quad; // designated initializer


@end
