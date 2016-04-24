//
//  ViewController.m
//  FindFriend
//
//  Created by Ferose Babu on 4/24/16.
//  Copyright © 2016 WWI. All rights reserved.
//

@import CoreLocation;
@import GLKit;

#import "ViewController.h"
#import "BluetoothManager.h"
#import "UIView+LayoutExtension.h"

@interface ViewController ()<BluetoothManagerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *signalStrengthLabel;
@property (weak, nonatomic) IBOutlet UIView *circularView;
@property (weak, nonatomic) IBOutlet UIView *arrowView;
@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCompass];
    
    [BluetoothManager shared].delegate = self;
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    self.circularView.layer.cornerRadius = self.circularView.width/2;
}

- (void) setupCompass
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BluetoothManagerDelegate

- (void)updateRSSI:(NSNumber *)rssi
{
    self.signalStrengthLabel.text = rssi.stringValue;
}

#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    [UIView animateWithDuration:0.25 animations:^{
        self.arrowView.transform = CGAffineTransformMakeRotation(-GLKMathDegreesToRadians(newHeading.trueHeading));

    }];
}
@end
