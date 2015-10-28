//
//  IntroViewController.m
//  Alex DeCastro
//
//  Created by Alex on 4/20/15.
//  Copyright (c) 2015 Alex DeCastro. All rights reserved.
//

#import "IntroViewController.h"

#import "ContentViewController.h"

@interface IntroViewController () <UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@end

static int myNumber = 0;

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.alexdecastro.wordgame.v01"];
    [sharedDefaults synchronize];
    
    self.pageTitles = [[NSArray alloc] initWithObjects:@"Help Screen 1", @"Help Screen 2", nil];
    self.pageImages = [[NSArray alloc] initWithObjects:@"ScreenShot03", @"ScreenShot04", nil];
    
    self.pageViewController = (UIPageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    ContentViewController *startVC = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:startVC, nil];
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.pageViewController.view.frame = CGRectMake(0, 60, self.view.frame.size.width , self.view.frame.size.height - 120);
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendButtonPressed:(UIButton *)sender {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.alexdecastro.wordgame.v01"];
    
    myNumber++;
    
    self.numberLabel.text = [NSString stringWithFormat:@"%d", myNumber];
    [sharedDefaults setObject:self.numberLabel.text forKey:@"kMyNumber"];
    [sharedDefaults synchronize];
}

- (IBAction)restartButtonPressed:(UIButton *)sender {
    ContentViewController *startVC = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:startVC, nil];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

// Create a new ContentViewController
// and assign the title and image.
- (ContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count))
    {
        return [[ContentViewController alloc] init];
    }
    ContentViewController *vc = (ContentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ContentViewController"];
    vc.imageFile = (NSString *)[self.pageImages objectAtIndex:index];
    vc.titleText = (NSString *)[self.pageTitles objectAtIndex:index];
    vc.pageIndex = index;
    
    return vc;
}

// MARK: - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    ContentViewController *vc = (ContentViewController *) viewController;
    NSUInteger index = vc.pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    ContentViewController *vc = (ContentViewController *) viewController;
    NSUInteger index = vc.pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    if (index == self.pageTitles.count) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.pageTitles.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
