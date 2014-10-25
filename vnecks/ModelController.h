//
//  ModelController.h
//  vnecks
//
//  Created by Eric Lewis on 10/20/14.
//  Copyright (c) 2014 Eric Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (ItemViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(ItemViewController *)viewController;

@end

