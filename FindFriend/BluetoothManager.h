//
//  BluetoothManager.h
//  BTLE Transfer
//
//  Created by Ferose Babu on 4/24/16.
//  Copyright © 2016 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BluetoothManagerDelegate <NSObject>
- (void)updateRSSI:(NSNumber *)rssi;
@end

@interface BluetoothManager : NSObject
+ (instancetype)shared;

@property (nonatomic, weak) id<BluetoothManagerDelegate> delegate;
@end
