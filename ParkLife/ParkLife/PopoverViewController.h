//
//  PopoverViewController.h
//  ParkLife
//
//  Created by Phil Greenway on 12/07/2014.
//  Copyright (c) 2014 Team UQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopoverDelegate <NSObject>
@required
-(void)selectedItem:(NSString *)string;
@end

@interface PopoverViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, weak) id<PopoverDelegate> delegate;
@end

