//
//  ViewController.m
//  RottenTomatoes
//
//  Created by Robin Wu on 10/20/15.
//  Copyright © 2015 Robin Wu. All rights reserved.
//

#import "MoviesViewController.h"
#import "MoviesTableViewCell.h"
#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "JTProgressHUD.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    BOOL isSearch;
}

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    self.tableView.dataSource= self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    // User sees loading state while waiting for movies API
    [JTProgressHUD showWithStyle:NO];
    
    [self fetchMovies];
}

- (void) showNetworkError {
    CGRect frame = self.networkErrorView.frame;
    frame.origin.y = 60;
    self.networkErrorView.frame = frame;
    
    self.networkErrorView.hidden = NO;
    
    // TODO use alpha and hide the error after 3 seconds
}

- (void)onRefresh {
    [self.searchBar resignFirstResponder];
    
    NSString *urlString =
    @"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      [self.refreshControl endRefreshing];
                                  }];
    
    [task resume];
}

- (void) fetchMovies {
    self.networkErrorView.hidden = YES;
    
    NSString *urlString =
    @"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    NSLog(@"Response: %@", responseDictionary);
                                                    self.movies = responseDictionary[@"movies"];
                                                    
                                                    [JTProgressHUD hide];
                                                    
                                                    [self.tableView reloadData];
                                                    self.searchResult = [NSMutableArray arrayWithCapacity:[self.movies count]];
                                                    
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                    
                                                    [JTProgressHUD hide];
                                                    self.searchBar.hidden = YES;
                                                    
                                                    [self showNetworkError];
                                                }
                                            }];
    [task resume];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearch) {
        return self.searchResult.count;
    } else {
        return self.movies.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MovieCell";
    
    MoviesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = (MoviesTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *movie;
    if (isSearch) {
        if (self.searchResult.count > indexPath.row) {
            movie = self.searchResult[indexPath.row];
        }
    } else {
        movie = self.movies[indexPath.row];
    }
    
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"synopsis"];
    
    NSString *originalUrlString = movie[@"posters"][@"thumbnail"];
    NSRange range = [originalUrlString rangeOfString:@".*cloudfront.net/"
                                             options:NSRegularExpressionSearch];
    NSString *newUrlString = [originalUrlString stringByReplacingCharactersInRange:range
                                                                        withString:@"https://content6.flixster.com/"];
    newUrlString = [newUrlString stringByReplacingOccurrencesOfString:@"_ori.jpg" withString:@"_tmb.jpg"];
    
    NSURL *url = [NSURL URLWithString:newUrlString];
    
    [cell.posterImageView setImageWithURL:url];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if([searchText isEqualToString:@""] || searchText==nil) {
        isSearch = NO;
        [self.tableView reloadData];
        return;
    }
    isSearch = YES;
    [self.searchResult removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    
    self.searchResult = [NSMutableArray arrayWithArray: [self.movies filteredArrayUsingPredicate:resultPredicate]];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue is called");
    
    MoviesTableViewCell *cell = (MoviesTableViewCell *) sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSDictionary *movie;
    if (isSearch) {
        movie = self.searchResult[indexPath.row];
    } else {
        movie = self.movies[indexPath.row];
    }
    
    MovieDetailsViewController *destViewController = (MovieDetailsViewController *) segue.destinationViewController;
    destViewController.movie = movie;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
