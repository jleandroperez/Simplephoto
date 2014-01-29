//
//  STShowcaseViewCell.m
//  SimplePhoto
//
//  Created by Jorge Leandro Perez on 1/29/14.
//  Copyright (c) 2014 Automattic. All rights reserved.
//

#import "STShowcaseViewCell.h"



#pragma mark ================================================================================================
#pragma mark Private!
#pragma mark ================================================================================================

@interface STShowcaseViewCell ()
@property (nonatomic, weak, readwrite) IBOutlet UIImageView *imageView;
@end


#pragma mark ================================================================================================
#pragma mark STShowcaseViewCell
#pragma mark ================================================================================================

@implementation STShowcaseViewCell

- (id)initWithFrame:(CGRect)frame
{
    
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
	
    return self;
}

@end
