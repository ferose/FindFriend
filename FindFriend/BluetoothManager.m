//
//  BluetoothManager.m
//  BTLE Transfer
//
//  Created by Ferose Babu on 4/24/16.
//  Copyright © 2016 Apple. All rights reserved.
//

@import CoreBluetooth;

#import "BluetoothManager.h"

@interface BluetoothManager()<CBCentralManagerDelegate, CBPeripheralManagerDelegate>

@property (nonatomic) CBCentralManager *centralManager;
@property (nonatomic) CBPeripheralManager *peripheralManager;

@property (nonatomic) CBUUID *serviceUUID;;
@property (nonatomic) CBUUID *locationCharacteristicUUID;

@end

@implementation BluetoothManager

+ (instancetype)shared
{
    static BluetoothManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit
{
    self.serviceUUID = [CBUUID UUIDWithString:@"3CF044DF-24D7-4165-8E94-F9C9788A040D"];
    self.locationCharacteristicUUID = [CBUUID UUIDWithString:@"0316515B-FC60-4B0D-99BE-F72B243232FA"];

    [self setupCentral];
    [self setupPeripheral];
}

- (void) setupCentral
{
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    [self.centralManager scanForPeripheralsWithServices:@[self.serviceUUID] options:nil];
}

- (void) setupPeripheral
{
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

#pragma mark CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...
    
    // ... so start scanning
    [self scan];
}


/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[self.serviceUUID]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}


- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    [self.delegate updateRSSI:RSSI];
}

/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
}

- (NSData *)dataFromDictionary:(NSDictionary *)dictionary
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:nil];
    return jsonData;
}

- (NSDictionary *)dictionaryFromData:(NSData *)data
{
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return jsonDict;
}

#pragma mark CBPeripheralManagerDelegate

/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    CBMutableService *service = [[CBMutableService alloc] initWithType:self.serviceUUID primary:YES];
    
    NSData *location = [self dataFromDictionary: @{@"lat": @(0), @"lon": @(0)}];
    
    CBMutableCharacteristic *locationCharacteristics =
    [[CBMutableCharacteristic alloc] initWithType:self.locationCharacteristicUUID
                                       properties:CBCharacteristicPropertyRead
                                            value:location
                                      permissions:CBAttributePermissionsReadable];
    service.characteristics = @[locationCharacteristics];
    [self.peripheralManager addService:service];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error
{
    if (error) {
        NSLog(@"Error publishing service: %@", [error localizedDescription]);
        return;
    }
    [peripheral startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[self.serviceUUID]}];
}
@end
