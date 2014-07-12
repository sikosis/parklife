//
//  MasterViewController.m
//  ParkLife
//
//  Created by Phil Greenway on 12/07/2014.
//  Copyright (c) 2014 Team UQ. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
    
    feeds = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://www.trumba.com/calendars/brisbane-events-rss.rss?filterview=parks"];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Parser

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        description = [[NSMutableString alloc] init];
        xcalDescription = [[NSMutableString alloc] init];
        xcalLocation = [[NSMutableString alloc] init];
        eventAddress   = [[NSMutableString alloc] init];
        eventDate = [[NSMutableString alloc] init];
        eventImage = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"description"]) {
        [description appendString:string];
    } else if ([element isEqualToString:@"link"]) {
        [link appendString:string];
    } else if ([element isEqualToString:@"xCal:description"]) {
        [xcalDescription appendString:string];
    } else if ([element isEqualToString:@"xCal:location"]) {
        [xcalLocation appendString:string];
    } else if ([element isEqualToString:@"x-trumba:formatteddatetime"]) {
        [eventDate appendString:string];
    } else if ([element isEqualToString:@"x-trumba:customfield"]) {
        // we only want the venue address but we can't get just it
        [eventAddress appendString:string];
        
        if ([string rangeOfString:@".jpg"].location != NSNotFound) {
            //NSLog(@"string:%@",string);
            // we found the image
            [eventImage appendString:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        [item setObject:title forKey:@"title"];
        [item setObject:description forKey:@"description"];
        [item setObject:link forKey:@"link"];
        [item setObject:xcalDescription forKey:@"xcalDescription"];
        [item setObject:xcalLocation forKey:@"xcalLocation"];
        [item setObject:eventAddress forKey:@"eventAddress"];
        [item setObject:eventDate forKey:@"eventDate"];
        [item setObject:eventImage forKey:@"eventImage"];
        
        [feeds addObject:[item copy]];
    }
    
}

#pragma mark - geolocation

- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    
    // first we need to mung the address by removing the name hopefully ...
    NSString *_start = @",";
    NSRange _rangeStart;
    NSInteger _length;
    _rangeStart = [address rangeOfString:_start];
    if(_rangeStart.location != NSNotFound) {
        
        _rangeStart.location = _rangeStart.location + 2;
        _length = (strlen([address UTF8String]) - _rangeStart.location);
        
        address = [address substringWithRange:NSMakeRange(_rangeStart.location,_length)];
        address = [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
    }

    
    /*
    
    __block CLLocationCoordinate2D coordinate;
    
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if([placemarks count]) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            coordinate = location.coordinate;
            //[self.mapView setCenterCoordinate:coordinate animated:YES];
        } else {
            NSLog(@"error");
        }
    }];
    
    return coordinate;
     
    */
     
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    return center;
}


#pragma mark - Segue

// not used
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        // or whatever we decide to do when it's pressed ...
        
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSString *string = [feeds[indexPath.row] objectForKey: @"link"];
//        [[segue destinationViewController] setUrl:string];
        
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return feeds.count;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    [self.tableView reloadData];
    
}


-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath {
        return 108;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    //cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] objectForKey: @"title"];
    
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *descLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *placeLabel = (UILabel *)[cell viewWithTag:4];
    UIImageView *eventThumbnail = (UIImageView *)[cell viewWithTag:5];
    
    [titleLabel setText:[[feeds objectAtIndex:indexPath.row] objectForKey: @"title"]];

  //  NSString *_desc = [[feeds objectAtIndex:indexPath.row] objectForKey: @"description"];

    

    
    
    //eventThumbnail.image = [images objectAtIndex:indexPath.row];

    
    eventThumbnail.image = nil;
    
    dispatch_async(kBgQueue, ^{
        NSString *_image = [[feeds objectAtIndex:indexPath.row] objectForKey: @"eventImage"];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_image]];

        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    eventThumbnail.image = image;
                });
            }
        }
    });
    
    
    
    
    /*
    
    NSString *eventDate;
    NSString *leftOvers;
    
    NSString *_start = @"<br/>";
    NSRange _rangeStart;
    NSInteger _length;
    _rangeStart = [_desc rangeOfString:_start];
    if(_rangeStart.location != NSNotFound) {
        _length = (strlen([_desc UTF8String]) - _rangeStart.location);
        eventDate = [_desc substringWithRange:NSMakeRange(0, _rangeStart.location)];
        eventDate = [eventDate stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        eventDate = [eventDate stringByReplacingOccurrencesOfString:@"&ndash;" withString:@"-"];
        
        leftOvers = [_desc substringWithRange:NSMakeRange(_rangeStart.location,_length)];
    }
    
    _start = @"img src=\"";
    _rangeStart = [leftOvers rangeOfString:_start];
    
    NSString *eventImage;
    
    if(_rangeStart.location != NSNotFound) {
        
        _rangeStart.location = _rangeStart.location + 9;
        _length = (strlen([leftOvers UTF8String]) - _rangeStart.location);
        eventImage = [leftOvers substringWithRange:NSMakeRange(_rangeStart.location,_length)];
        
        _rangeStart = [eventImage rangeOfString:@"\""];
        eventImage = [eventImage substringWithRange:NSMakeRange(0, _rangeStart.location)];

        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:eventImage]];
        eventThumbnail.image = [UIImage imageWithData:imageData];
    }
    
     [dateLabel setText:eventDate];
    
    */
    
    
    [dateLabel setText:[[feeds objectAtIndex:indexPath.row] objectForKey: @"eventDate"]];
    [descLabel setText:[[feeds objectAtIndex:indexPath.row] objectForKey: @"xcalDescription"]];
    [placeLabel setText:[[feeds objectAtIndex:indexPath.row] objectForKey: @"xcalLocation"]];
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *object = _objects[indexPath.row];
    self.detailViewController.detailItem = object;
    
    
    NSString *_eventAddress = [[feeds objectAtIndex:indexPath.row] objectForKey: @"eventAddress"];
    
    NSArray *lines = [_eventAddress componentsSeparatedByString: @"\n"];
    
    if ([lines count] > 0) {
        
        _eventAddress = @""; // set to blank it's all in lines anyway
        
        for (id object in lines) {
            NSLog(@"%@",object);
            
            if ([object rangeOfString:@", Australia"].location != NSNotFound) {
               // _eventAddress = [lines objectAtIndex:5];
                _eventAddress = object;
                _eventAddress = [_eventAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
        }
        
        if ([_eventAddress length] == 0) {
            // address doesn't have Australia in like the others so ... we grab the 2nd last line and try
            long max = [lines count] - 2;
            _eventAddress = [lines objectAtIndex:max];
            
            // check there are commas so it could be an address
            
            if ([_eventAddress rangeOfString:@","].location != NSNotFound) {
                _eventAddress = [_eventAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            } else {
                _eventAddress = @"";
            }
            
            
        }
        
        if ([_eventAddress length] == 0) {
            // another exception it might be the 3rd line from bottom
            long max = [lines count] - 3;
            _eventAddress = [lines objectAtIndex:max];
            _eventAddress = [_eventAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        
        
        CLLocationCoordinate2D coord;
        coord = [self geoCodeUsingAddress:_eventAddress];
        
        NSLog(@"%f %f",coord.longitude,coord.latitude);
        
        self.detailViewController.eventCoord = coord;
        
        self.detailViewController.eventAddress = _eventAddress;

    }
    
}

@end
