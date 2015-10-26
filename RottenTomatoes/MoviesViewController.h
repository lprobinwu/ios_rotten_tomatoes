//
//  ViewController.h
//  RottenTomatoes
//
//  Created by Robin Wu on 10/20/15.
//  Copyright © 2015 Robin Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *movies;
@property (nonatomic, strong) NSMutableArray *searchResult;

// User sees error message when there's a networking error.
@property (weak, nonatomic) IBOutlet UIView *networkErrorView;
@property (weak, nonatomic) IBOutlet UILabel *networkErrorLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


// User can pull to refresh the movie list.
@property (nonatomic, strong) UIRefreshControl *refreshControl;

- (void) showNetworkError;

- (void)onRefresh;

- (void) fetchMovies;

@end

