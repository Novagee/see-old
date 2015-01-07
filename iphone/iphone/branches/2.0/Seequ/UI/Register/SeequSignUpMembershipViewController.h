//
//  SeequCreateMembership_2ViewController.h
//  ProTime
//
//  Created by Karen on 10/18/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SeequSignUpMembershipViewController : UIViewController <CLLocationManagerDelegate,UIAlertViewDelegate>{
    CLLocationManager *locationManager;
	CLLocation *curLocation;
    NSDictionary *dictPersonData;
    NSDictionary *dictIntroduction;
}

@property (nonatomic, strong) NSDictionary *dictPersonData;
@property (nonatomic, strong) NSDictionary *dictIntroduction;

- (IBAction)onClickCreateMemberShip:(id)sender;
- (IBAction)onClickTermsOfService:(id)sender;
- (IBAction)onClickPrivaciPolicy:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonCreateMembership;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogIn;
- (IBAction)onButtonLogIn:(id)sender;

- (void) GoBack;
//- (void) GoNext;

@end
