//
//  PreparForCallAnswerViewController.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 2/7/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "PreparForCallAnswerViewController.h"

#define TIME_OUT 40


@implementation PreparForCallAnswerViewController


@synthesize indicatorView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self setIndicatorView:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.indicatorView startAnimating];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:TIME_OUT
                                             target:self
                                           selector:@selector(closeView)
                                           userInfo:nil
                                            repeats:NO];
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 568) {
        indicatorView.center = CGPointMake(indicatorView.center.x, 263);
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.indicatorView stopAnimating];
    
    if (timer && [timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
}

- (void) closeView {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end