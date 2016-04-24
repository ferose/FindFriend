//
//  ViewController.m
//  FindFriend
//
//  Created by Ferose Babu on 4/24/16.
//  Copyright © 2016 WWI. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothManager.h"

@interface ViewController ()<BluetoothManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *signalStrengthLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [BluetoothManager shared].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateRSSI:(NSNumber *)rssi
{
    self.signalStrengthLabel.text = rssi.stringValue;
}
@end
