//
//  WordListModel.m
//  Alex DeCastro
//
//  Created by Alex on 4/20/15.
//  Copyright (c) 2015 Alex DeCastro. All rights reserved.
//

#import "WordListModel.h"

@implementation WordListModel

@synthesize list1 = _list1;
@synthesize list2 = _list2;
@synthesize list3 = _list3;
@synthesize list4 = _list4;
@synthesize list5 = _list5;

- (NSArray *)list1 {
    if (!_list1) {
        _list1 = [[NSArray alloc] initWithObjects:@"robin", @"yellow", @"beer", @"candy", @"gin", @"cookie", @"sparrow", @"green", @"cake", @"blue", @"wine", @"pigeon", @"red", @"hawk", @"vodka", @"pie", nil];
    }
    return _list1;
}

- (NSArray *)list2 {
    if (!_list2) {
        _list2 = [[NSArray alloc] initWithObjects:@"cow", @"apple", @"oak", @"shirt", @"banana", @"horse", @"pine", @"socks", @"elm", @"peach", @"pig", @"pants", @"birch", @"plum", @"dress", @"sheep", nil];
    }
    return _list2;
}

- (NSArray *)list3 {
    if (!_list3) {
        _list3 = [[NSArray alloc] initWithObjects:@"carrot", @"shark", @"milk", @"car", @"whale", @"lettuce", @"plane", @"coke", @"train", @"tea", @"dolphin", @"celery", @"crab", @"bus", @"pepper", @"juice", nil];
    }
    return _list3;
}

- (NSArray *)list4 {
    if (!_list4) {
        _list4 = [[NSArray alloc] initWithObjects:@"lion", @"pink", @"chair", @"England", @"purple", @"tiger", @"France", @"table", @"elephant", @"bed", @"white", @"America", @"black", @"Germany", @"zebra", @"couch", nil];
    }
    return _list4;
}

- (NSArray *)list5 {
    if (!_list5) {
        _list5 = [[NSArray alloc] initWithObjects:@"dog", @"mile", @"Kansas", @"meter", @"cat", @"Maryland", @"King", @"bird", @"Queen", @"inch", @"Oregon", @"yard", @"Texas", @"fish", @"Duke", nil];
    }
    return _list5;
}

@end
