//
//  ContentViewController.h
//  Alex DeCastro
//
//  Created by Alex on 4/20/15.
//  Copyright (c) 2015 Alex DeCastro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController

@property (nonatomic) NSUInteger pageIndex;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *imageFile;

@end
