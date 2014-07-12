//
//  DetailViewController.m
//  ParkLife
//
//  Created by Phil Greenway on 12/07/2014.
//  Copyright (c) 2014 Team UQ. All rights reserved.
//

#import "DetailViewController.h"
#import "URLConnect.h"


@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}


-(void)setEventCoord:(CLLocationCoordinate2D)eventCoord {
    // Clear Annotations
//    for (id annotation in mapView.annotations) {
//        [mapView removeAnnotation:annotation];
//    }

    // Zoom to region
    MKCoordinateRegion region;
    region.center = eventCoord;
    region.span = MKCoordinateSpanMake(0.02, 0.02); //Zoom distance
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
    
    
    // Pin on map -- in the wrong #$&^#&*( place !!!
    
//    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//    [annotation setCoordinate:eventCoord];
//    [annotation setTitle:title];
//    [mapView addAnnotation:annotation];

    
    // should we then pull in other datasets at this point ?!?!?
    
    // 53,366 rows ... uggh, proly shouldn't access this directly
    // perhaps we could have a custom reduced set
    
    /*
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.brisbane.qld.gov.au/sites/default/files/dataset_park_facilties_part_1.csv"]];

    URLConnect *connection = [[URLConnect alloc]initWithRequest:urlRequest];
    
    [connection setCompletionBlock:^(id obj, NSError *err) {
        if (!err) {
            NSString *block = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
            NSArray *lines = [block componentsSeparatedByString:@"\n"];
            NSLog(@"%@",lines);
            
        } else {
            NSLog(@"Something went wrong :(");
        }
        
    }];
    
    [connection start];
     
     */
}


-(void)setEventAddress:(NSString *)eventAddress {
   // NSLog(@"%@",eventAddress);
    
    // grab the suburb and then put pins for everything around it ?!?!
    
    
    
    
    
}


#pragma mark - PopoverDelegate method
-(void)selectedItem:(NSString *)string
{
    NSLog(@"Blah stuff happens");
    
    // Dismiss the popover
    if (_popoverPicker) {
        [_filterPopover dismissPopoverAnimated:YES];
        _filterPopover = nil;
    }
}


#pragma mark - configureView

- (void)configureView
{
    // Update the user interface for the detail item.

//    if (self.detailItem) {
//        self.detailDescriptionLabel.text = [self.detailItem description];
//    }
    
    mapView.showsUserLocation = YES;
    
    //    mapView.mapType = MKMapTypeSatellite;
    mapView.mapType = MKMapTypeStandard;
    
    [self zoomToUserLocation:mapView.userLocation];
    
    
    
}


- (void)zoomToUserLocation:(MKUserLocation *)userLocation {
    if (!userLocation)
        return;
    
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(0.02, 0.02); //Zoom distance
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}


-(void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    filterButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Filter"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                     action:@selector(btnFilter:)];
    self.navigationItem.rightBarButtonItem = filterButton;
    
    [self configureView];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self zoomToUserLocation:mapView.userLocation];
}


#pragma mark - Buttons

-(IBAction)btnFilter:(id)sender {
    NSLog(@"Filter this shizzle!");
    
    if (_popoverPicker == nil) {
        _popoverPicker = [[PopoverViewController alloc] initWithStyle:UITableViewStylePlain];
        
        //Set this VC as the delegate.
        _popoverPicker.delegate = self;
    }
    
    if (_filterPopover == nil) {
        // Show
        _filterPopover = [[UIPopoverController alloc] initWithContentViewController:_popoverPicker];
        [_filterPopover presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender
                                    permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        // Hide
        [_filterPopover dismissPopoverAnimated:YES];
        _filterPopover = nil;
    }
}


- (void)mapView:(MKMapView *)theMapView didUpdateToUserLocation:(MKUserLocation *)location {
    [self zoomToUserLocation:location];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
