//
//  DetailViewController.h
//  ParkLife
//
//  Created by Phil Greenway on 12/07/2014.
//  Copyright (c) 2014 Team UQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
