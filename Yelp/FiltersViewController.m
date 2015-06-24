//
//  FiltersViewController.m
//  Yelp
//
//  Created by Sean Zeng on 6/18/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "CheckboxCell.h"
#import "ExpandCell.h"
#import "ShowAllCell.h"
#import "SwitchCell.h"

typedef NS_ENUM(NSInteger, FilterSection) {
    FilterSectionDeals = 0,
    FilterSectionDistance = 1,
    FilterSectionSort = 2,
    FilterSectionCategories = 3
};

typedef NS_ENUM(NSInteger, SortMethod) {
    SortMethodBestMatch = 0,
    SortMethodDistance = 1,
    SortMethodHighestRated = 2
};


@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, CheckboxCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *distances;
@property (nonatomic, strong) NSArray *sortMethods;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, strong) NSDictionary *selectedDistance;
@property (nonatomic, strong) NSDictionary *selectedSortMethod;

@property (nonatomic) BOOL isOfferingDeals;
@property (nonatomic) BOOL isDistanceExpanded;
@property (nonatomic) BOOL isSortExpanded;
@property (nonatomic) BOOL isCategoriesExpanded;

- (void)initCategories;

@end

@implementation FiltersViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        [self initArrays];
        [self initCategories];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CheckboxCell" bundle:nil]
         forCellReuseIdentifier:@"CheckboxCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ExpandCell" bundle:nil]
         forCellReuseIdentifier:@"ExpandCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShowAllCell" bundle:nil]
         forCellReuseIdentifier:@"ShowAllCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    
    if (!self.selectedDistance) {
        self.selectedDistance = self.distances[0];
    }
    if (!self.selectedSortMethod) {
        self.selectedSortMethod = self.sortMethods[0];
    }
    if (!self.selectedCategories) {
        self.selectedCategories = [NSMutableSet set];
    }
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

#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == FilterSectionDeals) {
        return 1;
    }
    else if (section == FilterSectionDistance) {
        if (self.isDistanceExpanded) {
            return 4;
        }
        else {
            return 1;
        }
    }
    else if (section == FilterSectionSort) {
        if (self.isSortExpanded) {
            return 3;
        }
        else {
            return 1;
        }
    }
    else if (section == FilterSectionCategories) {
        if (self.isCategoriesExpanded) {
            return self.categories.count;
        }
        else {
            return 4;
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == FilterSectionDeals) {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        cell.titleLabel.text = @"Offering a Deal";
        cell.on = self.isOfferingDeals;
        cell.delegate = self;
        return cell;
    }
    else if (indexPath.section == FilterSectionDistance) {
        if (!self.isDistanceExpanded) {
            ExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExpandCell"];
            cell.titleLabel.text = self.selectedDistance[@"name"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else {
            CheckboxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckboxCell"];
            cell.titleLabel.text = self.distances[indexPath.row][@"name"];
            cell.on = [self.selectedDistance isEqualToDictionary:self.distances[indexPath.row]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            return cell;
        }
    }
    else if (indexPath.section == FilterSectionSort) {
        if (!self.isSortExpanded) {
            ExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExpandCell"];
            cell.titleLabel.text = self.selectedSortMethod[@"name"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else {
            CheckboxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckboxCell"];
            cell.titleLabel.text = self.sortMethods[indexPath.row][@"name"];
            cell.on = [self.selectedSortMethod isEqualToDictionary:self.sortMethods[indexPath.row]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            return cell;
        }
        
    }
    else if (indexPath.section == FilterSectionCategories) {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
        
        if (!self.isCategoriesExpanded) {
            if (indexPath.row == 3) {
                ShowAllCell *showAllcell = [tableView dequeueReusableCellWithIdentifier:@"ShowAllCell"];
                return showAllcell;
            }
            else {
                cell.titleLabel.text = self.categories[indexPath.row][@"name"];
                cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
                cell.delegate = self;
                return cell;
            }
        }
        else {
            cell.titleLabel.text = self.categories[indexPath.row][@"name"];
            cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            cell.delegate = self;
            return cell;
        }
    }
    else {
        return [[UITableViewCell alloc] init];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == FilterSectionDistance) {
        if (!self.isDistanceExpanded) {
            self.isDistanceExpanded = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FilterSectionDistance] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            CheckboxCell *cell = (CheckboxCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.on = YES;
            [self checkboxCell:cell didUpdateValue:YES];
        }
    } else if (indexPath.section == FilterSectionSort) {
        if (!self.isSortExpanded) {
            self.isSortExpanded = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FilterSectionSort] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            CheckboxCell *cell = (CheckboxCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.on = YES;
            [self checkboxCell:cell didUpdateValue:YES];
        }
    }
    else if (indexPath.section == FilterSectionCategories) {
        if (!self.isCategoriesExpanded && indexPath.row == 3) {
            self.isCategoriesExpanded = YES;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FilterSectionCategories] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            SwitchCell *cell = (SwitchCell *)[tableView cellForRowAtIndexPath:indexPath];
            //[cell toggleOn];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case FilterSectionDeals:
            return @"";
        case FilterSectionDistance:
            return @"Distance";
        case FilterSectionSort:
            return @"Sort by";
        case FilterSectionCategories:
            return @"Categories";
        default:
            return @"";
    }
}


#pragma mark - Switch cell delegate methods

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (value) {
        [self.selectedCategories addObject:self.categories[indexPath.row]];
    }
    else {
         [self.selectedCategories removeObject:self.categories[indexPath.row]];
    }
}

#pragma mark - Checkbox cell delegate methods

- (void)checkboxCell:(CheckboxCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    if (indexPath.section == FilterSectionDistance) {
        if (value) {
            self.selectedDistance = self.distances[indexPath.row];
            for (NSInteger row = 0; row < 4; row++) {
                if (row != indexPath.row) {
                    CheckboxCell *cell = (CheckboxCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:indexPath.section]];
                    [cell setOn:NO];
                }
            }

            self.isDistanceExpanded = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FilterSectionDistance] withRowAnimation:UITableViewRowAnimationNone];
        }
        /*
        else {
            cell.on = YES;
            self.isDistanceExpanded = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FilterSectionDistance] withRowAnimation:UITableViewRowAnimationFade];
        }
        */
        
    }
    else if (indexPath.section == FilterSectionSort) {
        if (value) {
            self.selectedSortMethod = self.sortMethods[indexPath.row];
            for (NSInteger row = 0; row < 3; row++) {
                if (row != indexPath.row) {
                    CheckboxCell *cell = (CheckboxCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:indexPath.section]];
                    [cell setOn:NO];
                }
            }
            
            self.isSortExpanded = NO;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FilterSectionSort] withRowAnimation:UITableViewRowAnimationNone];
            
        }
        /*
        else {
            self.selectedSortMethod = nil;
        }
        */
    }
}

#pragma mark - Private methods

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    if (self.isOfferingDeals) {
        [filters setObject:@"true" forKey:@"deals_filter"];
    }
    
    if (self.selectedSortMethod) {
        [filters setObject:self.selectedSortMethod[@"value"] forKey:@"sort"];
    }
    
    if (self.selectedDistance && ![self.selectedDistance isEqualToDictionary:self.distances[0]]) {
        [filters setObject:self.selectedDistance[@"value"] forKey:@"radius_filter"];
    }
    
    return filters;
}

- (void)onCancelButton {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)initArrays {
    self.distances =
    @[
      @{@"name" : @"Auto", @"value" : @""},
      @{@"name" : @"2 blocks", @"value" : @160},
      @{@"name" : @"6 blocks", @"value" : @480},
      @{@"name" : @"1 mile", @"value" : @1609},
      @{@"name" : @"5 miles", @"value" : @8047}
      ];
    
    self.sortMethods =
    @[
      @{@"name" : @"Best Match", @"value" : @0},
      @{@"name" : @"Distance", @"value" : @1},
      @{@"name" : @"Rating", @"value" : @2}
      ];
}

- (void)initCategories {
    self.categories =
    @[
      @{@"name" : @"Afghan", @"code" : @"afghani"},
      @{@"name" : @"African", @"code" : @"african"},
      @{@"name" : @"American (New)", @"code" : @"newamerican"},
      @{@"name" : @"American (Traditional)", @"code" : @"tradamerican"},
      @{@"name" : @"Arabian", @"code" : @"arabian"},
      @{@"name" : @"Argentine", @"code" : @"argentine"},
      @{@"name" : @"Armenian", @"code" : @"armenian"},
      @{@"name" : @"Asian Fusion", @"code" : @"asianfusion"},
      @{@"name" : @"Australian", @"code" : @"australian"},
      @{@"name" : @"Austrian", @"code" : @"austrian"},
      @{@"name" : @"Bangladeshi", @"code" : @"bangladeshi"},
      @{@"name" : @"Barbeque", @"code" : @"bbq"},
      @{@"name" : @"Basque", @"code" : @"basque"},
      @{@"name" : @"Belgian", @"code" : @"belgian"},
      @{@"name" : @"Brasseries", @"code" : @"brasseries"},
      @{@"name" : @"Brazilian", @"code" : @"brazilian"},
      @{@"name" : @"Breakfast & Brunch", @"code" : @"breakfast_brunch"},
      @{@"name" : @"British", @"code" : @"british"},
      @{@"name" : @"Buffets", @"code" : @"buffets"},
      @{@"name" : @"Burgers", @"code" : @"burgers"},
      @{@"name" : @"Burmese", @"code" : @"burmese"},
      @{@"name" : @"Cafes", @"code" : @"cafes"},
      @{@"name" : @"Cafeteria", @"code" : @"cafeteria"},
      @{@"name" : @"Cajun/Creole", @"code" : @"cajun"},
      @{@"name" : @"Cambodian", @"code" : @"cambodian"},
      @{@"name" : @"Caribbean", @"code" : @"caribbean"},
      @{@"name" : @"Catalan", @"code" : @"catalan"},
      @{@"name" : @"Cheesesteaks", @"code" : @"cheesesteaks"},
      @{@"name" : @"Chicken Wings", @"code" : @"chicken_wings"},
      @{@"name" : @"Chinese", @"code" : @"chinese"},
      @{@"name" : @"Comfort Food", @"code" : @"comfortfood"},
      @{@"name" : @"Creperies", @"code" : @"creperies"},
      @{@"name" : @"Cuban", @"code" : @"cuban"},
      @{@"name" : @"Czech", @"code" : @"czech"},
      @{@"name" : @"Delis", @"code" : @"delis"},
      @{@"name" : @"Diners", @"code" : @"diners"},
      @{@"name" : @"Ethiopian", @"code" : @"ethiopian"},
      @{@"name" : @"Fast Food", @"code" : @"hotdogs"},
      @{@"name" : @"Filipino", @"code" : @"filipino"},
      @{@"name" : @"Fish & Chips", @"code" : @"fishnchips"},
      @{@"name" : @"Fondue", @"code" : @"fondue"},
      @{@"name" : @"Food Court", @"code" : @"food_court"},
      @{@"name" : @"Food Stands", @"code" : @"foodstands"},
      @{@"name" : @"French", @"code" : @"french"},
      @{@"name" : @"Gastropubs", @"code" : @"gastropubs"},
      @{@"name" : @"German", @"code" : @"german"},
      @{@"name" : @"Gluten-Free", @"code" : @"gluten_free"},
      @{@"name" : @"Greek", @"code" : @"greek"},
      @{@"name" : @"Halal", @"code" : @"halal"},
      @{@"name" : @"Hawaiian", @"code" : @"hawaiian"},
      @{@"name" : @"Himalayan/Nepalese", @"code" : @"himalayan"},
      @{@"name" : @"Hot Dogs", @"code" : @"hotdog"},
      @{@"name" : @"Hot Pot", @"code" : @"hotpot"},
      @{@"name" : @"Hungarian", @"code" : @"hungarian"},
      @{@"name" : @"Iberian", @"code" : @"iberian"},
      @{@"name" : @"Indian", @"code" : @"indpak"},
      @{@"name" : @"Indonesian", @"code" : @"indonesian"},
      @{@"name" : @"Irish", @"code" : @"irish"},
      @{@"name" : @"Italian", @"code" : @"italian"},
      @{@"name" : @"Japanese", @"code" : @"japanese"},
      @{@"name" : @"Korean", @"code" : @"korean"},
      @{@"name" : @"Kosher", @"code" : @"kosher"},
      @{@"name" : @"Laotian", @"code" : @"laotian"},
      @{@"name" : @"Latin American", @"code" : @"latin"},
      @{@"name" : @"Live/Raw Food", @"code" : @"raw_food"},
      @{@"name" : @"Malaysian", @"code" : @"malaysian"},
      @{@"name" : @"Mediterranean", @"code" : @"mediterranean"},
      @{@"name" : @"Mexican", @"code" : @"mexican"},
      @{@"name" : @"Middle Eastern", @"code" : @"mideastern"},
      @{@"name" : @"Modern European", @"code" : @"modern_european"},
      @{@"name" : @"Mongolian", @"code" : @"mongolian"},
      @{@"name" : @"Moroccan", @"code" : @"moroccan"},
      @{@"name" : @"Pakistani", @"code" : @"pakistani"},
      @{@"name" : @"Persian/Iranian", @"code" : @"persian"},
      @{@"name" : @"Peruvian", @"code" : @"peruvian"},
      @{@"name" : @"Pizza", @"code" : @"pizza"},
      @{@"name" : @"Polish", @"code" : @"polish"},
      @{@"name" : @"Portuguese", @"code" : @"portuguese"},
      @{@"name" : @"Russian", @"code" : @"russian"},
      @{@"name" : @"Salad", @"code" : @"salad"},
      @{@"name" : @"Sandwiches", @"code" : @"sandwiches"},
      @{@"name" : @"Scandinavian", @"code" : @"scandinavian"},
      @{@"name" : @"Scottish", @"code" : @"scottish"},
      @{@"name" : @"Seafood", @"code" : @"seafood"},
      @{@"name" : @"Singaporean", @"code" : @"singaporean"},
      @{@"name" : @"Slovakian", @"code" : @"slovakian"},
      @{@"name" : @"Soul Food", @"code" : @"soulfood"},
      @{@"name" : @"Soup", @"code" : @"soup"},
      @{@"name" : @"Southern", @"code" : @"southern"},
      @{@"name" : @"Spanish", @"code" : @"spanish"},
      @{@"name" : @"Steakhouses", @"code" : @"steak"},
      @{@"name" : @"Sushi Bars", @"code" : @"sushi"},
      @{@"name" : @"Taiwanese", @"code" : @"taiwanese"},
      @{@"name" : @"Tapas Bars", @"code" : @"tapas"},
      @{@"name" : @"Tapas/Small Plates", @"code" : @"tapasmallplates"},
      @{@"name" : @"Tex-Mex", @"code" : @"tex-mex"},
      @{@"name" : @"Thai", @"code" : @"thai"},
      @{@"name" : @"Turkish", @"code" : @"turkish"},
      @{@"name" : @"Ukrainian", @"code" : @"ukrainian"},
      @{@"name" : @"Uzbek", @"code" : @"uzbek"},
      @{@"name" : @"Vegan", @"code" : @"vegan"},
      @{@"name" : @"Vegetarian", @"code" : @"vegetarian"},
      @{@"name" : @"Vietnamese", @"code" : @"vietnamese"}
      ];
}

@end
