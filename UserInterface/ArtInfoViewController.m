//
//  ArtInfoViewController.m
//  iBurn
//
//  Created by Jeffrey Johnson on 2009-01-18.
//  Copyright 2009 Burning Man Earth. All rights reserved.
//

#import "ArtInfoViewController.h"
#import "ArtInstall.h"
#import "Favorite.h"
#import "ArtTableViewController.h"
#import "iBurnAppDelegate.h"
#import "MyCLController.h"

@implementation ArtInfoViewController


- (void) showOnMap {
	iBurnAppDelegate *t = (iBurnAppDelegate *)[[UIApplication sharedApplication] delegate];
  [[t tabBarController]setSelectedViewController:[[[t tabBarController]viewControllers]objectAtIndex:0]];
  [[[[t tabBarController]viewControllers]objectAtIndex:0] popToRootViewControllerAnimated:YES];
  [[[[[t tabBarController]viewControllers]objectAtIndex:0]visibleViewController] showMapForObject:art];
}


- (void) setupViewInfo {
  NSMutableArray *tempTitles = [[[NSMutableArray alloc]init]autorelease];
  NSMutableArray *tempTexts = [[[NSMutableArray alloc]init]autorelease];
  if (art.name && ![art.name isEqualToString:@""]) {
    [tempTitles addObject:@"Name"];
    if ([art.latitude floatValue] > 1 
        && [art.longitude floatValue] < -1) {
      CLLocation *loc = [[[CLLocation alloc]initWithLatitude:[art.latitude floatValue] longitude:[art.longitude floatValue]]autorelease];
      float distanceAway = [[MyCLController sharedInstance] currentDistanceToLocation:loc] * 0.000621371192;
      if (distanceAway > 0) {
        [tempTexts addObject:[art.name stringByAppendingFormat:@" (%1.1f miles)",distanceAway]];
      } else {
        [tempTexts addObject:art.name];
      }      
    } else {      
      [tempTexts addObject:art.name];
    }
  }
  if (art.artist && ![art.artist isEqualToString:@""]) {
    [tempTitles addObject:@"Artist"];
    [tempTexts addObject:art.artist];
  }
  if (art.url && ![art.url isEqualToString:@""]) {
    [tempTitles addObject:@"URL"];
    if ([art.url rangeOfString:@"http://"].location == NSNotFound) {
      art.url = [@"http://" stringByAppendingString:art.url]; 
    }
    [tempTexts addObject:art.url];
  }
  if (art.contactEmail && ![art.contactEmail isEqualToString:@""]) {
    [tempTitles addObject:@"Contact Email"];
    [tempTexts addObject:art.contactEmail];
  }
  if ([art.latitude floatValue] > 1 
      && [art.longitude floatValue] < -1) {
		iBurnAppDelegate *t = (iBurnAppDelegate *)[[UIApplication sharedApplication] delegate];
    [tempTitles addObject:@"Coordinates"];
		if ([t embargoed]) {
			[tempTexts addObject:@"Location data is embargoed until gates open."];
		} else {
			NSString *locString = [NSString stringWithFormat:@"%1.5f, %1.5f",[art.latitude floatValue], [art.longitude floatValue]];
			[tempTexts addObject:locString];
		}
  }
  if (art.desc && ![art.desc isEqualToString:@""] ) {
    [tempTitles addObject:@"Description"];
    [tempTexts addObject:art.desc];
  }  
  cellTexts = [tempTexts retain];
  headerTitles = [tempTitles retain];
  
  
}

- (id)initWithArt:(ArtInstall*)artInstall {
	self = [super initWithTitle:artInstall.name];
	art = [artInstall retain];
  [self setupViewInfo];
  return self;
}


- (CGFloat)tableView:(UITableView *)tb heightForRowAtIndexPath:(NSIndexPath *) indexPath {
  return [super tableView:tb heightForRowAtIndexPath:indexPath object:art];  
}


- (void)dealloc {
  [art release];
  [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void) addToFavorites: (id) sender {
  iBurnAppDelegate *t = (iBurnAppDelegate *)[[UIApplication sharedApplication] delegate];
  NSManagedObjectContext *moc = [t managedObjectContext];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorite" inManagedObjectContext:moc];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:entity];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ArtInstall = %@", art];
  [fetchRequest setPredicate:predicate];	
  NSError *error;
  NSArray *favorites = [moc executeFetchRequest:fetchRequest error:&error];
  if ([favorites count] == 0) {
    Favorite *newFav = [NSEntityDescription insertNewObjectForEntityForName:@"Favorite"
                                                     inManagedObjectContext:moc];      
    newFav.ArtInstall = art;
    NSError *error;
    [moc save:&error];
  }
}


@end