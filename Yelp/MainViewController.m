//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"
#import "DetailViewController.h"
#import "MapViewController.h"
#import <UIScrollView+SVInfiniteScrolling.h>

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate, MapViewControllerDelegate>

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSDictionary *filters;
@property (nonatomic) NSInteger offset;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSString *searchText;

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;

@end

@implementation MainViewController

- (instancetype)init
{
    NSLog(@"init");
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSLog(@"initWithCoder");
    self = [super initWithCoder:coder];
    if (self) {
        self = [self initWithNibName:@"MainViewController" bundle:nil];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"initWithNibName");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        [self fetchBusinessesWithQuery:self.searchText params:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"viewDidLoad");
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    
    self.tableView.estimatedRowHeight = 1.1;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self fetchAdditionalBusinessesWithQuery:self.searchText params:self.filters];
    }
    ];
    
    UIView *infiniteScrollView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UILabel *infiniteScrollLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    infiniteScrollLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
    infiniteScrollLabel.text = @"More...";
    infiniteScrollLabel.textAlignment = NSTextAlignmentCenter;
    infiniteScrollLabel.textColor = [UIColor grayColor];
    [infiniteScrollView addSubview:infiniteScrollLabel];
    [self.tableView.infiniteScrollingView setCustomView:infiniteScrollView forState:SVInfiniteScrollingStateTriggered];
    
    self.parentViewController.title = @"Yelp";
    
    self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
 
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar sizeToFit];
    self.searchBar = searchBar;
    self.searchBar.delegate = self;
    
    self.parentViewController.navigationItem.titleView = searchBar;
    
    self.businesses = [NSArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSLog(@"prepareForSegue");
    //BusinessCell *cell = sender;
    //NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Business *business = self.businesses[indexPath.row];
    DetailViewController *destinationVC = segue.destinationViewController;
    destinationVC.business = business;
}

- (NSString *)searchText {
    if ([_searchText length] == 0) {
        return @"Restaurants";
    }
    else {
        return _searchText;
    }
}

#pragma mark - Table view methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*
    CGFloat actualPosition = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height - scrollView.frame.size.height;
    if (actualPosition >= contentHeight) {
        [self fetchAdditionalBusinessesWithQuery:@"Restaurants" params:self.filters];
        [self.tableView reloadData];
    }
    
    NSLog(@"%ld", (long)scrollView.contentOffset.y);
    NSLog(@"%ld", (long)scrollView.contentSize.height);
    NSLog(@"%ld", (long)scrollView.frame.size.height);
    */
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"] animated:YES];
    //[self performSegueWithIdentifier:@"DetailSegue" sender:self];
    DetailViewController *detailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
    Business *business = self.businesses[indexPath.row];
    detailViewController.business = business;
    //[self.navigationController presentViewController:detailViewController animated:true completion:nil];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Filter delegate methods
- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    NSLog(@"fire new network event: %@", filters);
    
    _filters = filters;
    [self fetchBusinessesWithQuery:self.searchText params:filters];
}

#pragma mark - MapViewController delegate methods

- (void)setBusinessesForMapViewController:(MapViewController *)mapViewController {
    mapViewController.businesses = self.businesses;
}

- (void)setRegionForMapViewController:(MapViewController *)mapViewController {
    mapViewController.region = self.region;
}

#pragma mark - Navigation controller delegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.title = @"Yelp";
    
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    
    viewController.navigationItem.titleView = self.searchBar;
}

#pragma mark - Search bar delegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self setSearchNavigationBarItems];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchText = searchText;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //NSLog(searchBar.text);
    [self fetchBusinessesWithQuery:searchBar.text params:nil];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self setMainNavigationBarItems];
}

#pragma mark - Private methods

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"params: %@", params);
        //NSLog(@"response: %@", response);

        int startingRow = [self.businesses count];
        NSArray *businessDictionaries = response[@"businesses"];
        self.region = response[@"region"];
        
        if ([params objectForKey:@"offset"] == nil) {
            self.businesses = [Business businessWithDictionaries:businessDictionaries];
            [self.tableView reloadData];
        }
        else {
            self.businesses = [self.businesses arrayByAddingObjectsFromArray:[Business businessWithDictionaries:businessDictionaries]];
            int endingRow = [self.businesses count];
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (; startingRow < endingRow; startingRow++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
            }
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [self.tableView.infiniteScrollingView stopAnimating];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateSearchResults" object:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

- (void)fetchAdditionalBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    NSMutableDictionary *allParams = [NSMutableDictionary dictionary];
    [allParams addEntriesFromDictionary:params];
    
    if (self.offset == 0) {
        self.offset = self.businesses.count;
    }
    else {
        self.offset += 5;
    }
    NSDictionary *limitAndOffset = @{@"limit": @5, @"offset": [NSNumber numberWithInt:(int)self.offset]};
    [allParams addEntriesFromDictionary:limitAndOffset];
    
    [self fetchBusinessesWithQuery:query params:allParams];
}

- (void)onFilterButton {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    vc.delegate = self;
    
    //UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    //[self presentViewController:nvc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setMainNavigationBarItems {
    self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
}

- (void)setSearchNavigationBarItems {
    self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(searchBarCancelButtonClicked:)];
}

@end
