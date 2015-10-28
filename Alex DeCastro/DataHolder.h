//
//  DataHolder.h
//  Alex DeCastro
//
//  Created by Alex on 4/20/15.
//  Copyright (c) 2015 Alex DeCastro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataHolder : NSObject

+ (DataHolder *)sharedInstance;

@property (strong, nonatomic) NSString *appState;
@property (strong, nonatomic) NSString *appTestValue;
@property (strong, nonatomic) NSString *wordList;

@end
