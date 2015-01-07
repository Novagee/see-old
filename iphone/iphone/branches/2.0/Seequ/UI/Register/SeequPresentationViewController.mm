//
//  SeequPresentationViewController.m
//  ProTime
//
//  Created by Karen on 10/17/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "Common.h"
#import "SeequPresentationViewController.h"
#import "SignUpViewController.h"
#import "NavigationBar.h"
#import "RegisteringViewController.h"

@interface SeequPresentationViewController ()

@end

@implementation SeequPresentationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height);

    if (IS_IOS_7) {
        self.presentationView.frame=CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height);
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ((NavigationBar*) self.navigationController.navigationBar).hidden = YES;
    ((NavigationBar*) self.navigationController.navigationBar).backgroundImage = [UIImage imageNamed:@"seequNavigationDefaultBG.png"];
	((NavigationBar*) self.navigationController.navigationBar).titleImage = [UIImage imageNamed:@"seequNavigationTitleSignUp.png"];
    [(NavigationBar*) self.navigationController.navigationBar setNeedsDisplay];
}

- (IBAction)onClickSignUp:(id)sender{
    SignUpViewController *controller = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onClickLogIn:(id)sender{
    RegisteringViewController *controller = [[RegisteringViewController alloc] initWithNibName:@"RegisteringViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
