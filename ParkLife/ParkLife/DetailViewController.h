//
//  DetailViewController.h
//  ParkLife
//
//  Created by Phil Greenway on 12/07/2014.
//  Copyright (c) 2014 Team UQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PopoverViewController.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate,MKMapViewDelegate,CLLocationManagerDelegate,PopoverDelegate> {
    IBOutlet MKMapView *mapView;
    MKPointAnnotation *point;
    
    UIBarButtonItem *filterButton;
}

-(IBAction)btnFilter:(id)sender;


@property (nonatomic) CLLocationCoordinate2D eventCoord;
@property (nonatomic) NSString *eventAddress;

@property (nonatomic, strong) PopoverViewController *popoverPicker;
@property (nonatomic, strong) UIPopoverController *filterPopover;


//@property (strong, nonatomic) IBOutlet MKMapView *mapView;

// these arent used
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
