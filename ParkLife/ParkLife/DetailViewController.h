//
//  DetailViewController.h
//  ParkLife
//
//  Created by Phil Greenway on 12/07/2014.
//  Copyright (c) 2014 Team UQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface DetailViewController : UIViewController <UISplitViewControllerDelegate,MKMapViewDelegate,CLLocationManagerDelegate> {
    IBOutlet MKMapView *mapView;
    MKPointAnnotation *point;
    
}

//-(IBAction)zoomIn:(id)sender;
//-(IBAction)changeMapType:(id)sender;


@property (strong, nonatomic) id detailItem;


@property (nonatomic) CLLocationCoordinate2D eventCoord;
@property (nonatomic) NSString *eventAddress;


@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

//@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
