//
//  MasterViewController.h
//  ParkLife
//
//  Created by Phil Greenway on 12/07/2014.
//  Copyright (c) 2014 Team UQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <NSXMLParserDelegate> {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *description;
    NSMutableString *xcalDescription;
    NSMutableString *xcalLocation;
    NSMutableString *eventDate;
    NSMutableString *eventAddress;
    NSMutableString *link;
    NSMutableString *eventImage;
    
    NSString *element;    
    long counter;
}

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
