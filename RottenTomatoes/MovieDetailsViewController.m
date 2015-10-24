//
//  MovieDetailsViewController.m
//  RottenTomatoes
//
//  Created by Robin Wu on 10/21/15.
//  Copyright © 2015 Robin Wu. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailsViewController ()

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height * 3);
    
    NSString *originalUrlString = self.movie[@"posters"][@"detailed"];
    
    NSRange range = [originalUrlString rangeOfString:@".*cloudfront.net/"
                                             options:NSRegularExpressionSearch];
    
    NSString *newUrlString = [originalUrlString stringByReplacingCharactersInRange:range
                                                                        withString:@"https://content6.flixster.com/"];
    
    NSURL *url = [NSURL URLWithString:newUrlString];

    [self.imageView setImageWithURL:url];
    self.imageView.clipsToBounds = YES;
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", self.movie[@"title"], self.movie[@"year"]];
    self.synopsisLabel.text = self.movie[@"synopsis"];
    self.scoreLabel.text = [NSString stringWithFormat:@"Critics: %@, Audience: %@", self.movie[@"ratings"][@"critics_score"], self.movie[@"ratings"][@"audience_score"] ];
    self.ratingLabel.text = self.movie[@"mpaa_rating"];
    
    CGRect frame = self.synopsisLabel.frame;
    [self.synopsisLabel sizeToFit];
    frame.size.height = self.synopsisLabel.frame.size.height;
    self.synopsisLabel.frame = frame;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.synopsisLabel.frame.origin.y + self.synopsisLabel.frame.size.height + 20);
    
    self.navigationItem.title = self.movie[@"title"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
