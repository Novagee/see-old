//
//  NavigationBar.h
//  Protime
//
//  Created by Norayr Harutyunyan on 1/13/11.
//  Copyright 2011 Be-Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NavigationBar : UINavigationBar {

	UIImage* backgroundImage;
	UIImage* titleImage;
}

@property (nonatomic, strong) UIImage* backgroundImage;
@property (nonatomic, strong) UIImage* titleImage;

@end
