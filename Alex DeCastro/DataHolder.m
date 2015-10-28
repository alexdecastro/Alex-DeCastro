//
//  DataHolder.m
//  Alex DeCastro
//
//  Created by Alex on 4/20/15.
//  Copyright (c) 2015 Alex DeCastro. All rights reserved.
//

#import "DataHolder.h"

@interface DataHolder()

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

static NSString * const kAppState = @"kAppState";
static NSString * const kAppTestValue = @"kAppTestValue";
static NSString * const kWordList = @"kWordList";

@implementation DataHolder

@synthesize appState = _appState;
@synthesize appTestValue = _appTestValue;
@synthesize wordList = _wordList;

+ (DataHolder *)sharedInstance {
    static DataHolder *_sharedInstance = nil;
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      _sharedInstance = [[self alloc] init];
                  });
    
    return _sharedInstance;
}

- (NSUserDefaults *)defaults
{
    if (!_defaults) {
        _defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.alexdecastro.wordgame.v01"];
    }
    return _defaults;
}

- (NSString *)appState
{
    NSUserDefaults *defaults = self.defaults;
    
    [defaults synchronize];
    
    if ([defaults objectForKey:kAppState]) {
        _appState = [defaults objectForKey:kAppState];
    } else {
        _appState = nil;
    }
    NSLog(@"DEBUG: DataHolder: appState: %@", _appState);
    return _appState;
}

- (void)setAppState:(NSString *)appState
{
    NSLog(@"DEBUG: DataHolder: setAppState: %@", appState);
    _appState = appState;
    [self.defaults setObject:_appState forKey:kAppState];
    [self.defaults synchronize];
}

- (NSString *)appTestValue {
    NSUserDefaults *defaults = self.defaults;
    
    [defaults synchronize];
    
    if ([defaults objectForKey:kAppTestValue]) {
        _appTestValue = [defaults objectForKey:kAppTestValue];
    } else {
        _appTestValue = nil;
    }
    NSLog(@"DEBUG: DataHolder: appTestValue: %@", _appTestValue);
    return _appTestValue;
}

- (void)setAppTestValue:(NSString *)appTestValue {
    NSLog(@"DEBUG: DataHolder: setAppTestValue: %@", appTestValue);
    _appTestValue = appTestValue;
    [self.defaults setObject:_appTestValue forKey:kAppTestValue];
    [self.defaults synchronize];
}

- (NSString *)wordList {
    NSUserDefaults *defaults = self.defaults;
    
    [defaults synchronize];
    
    if ([defaults objectForKey:kWordList]) {
        _wordList = [defaults objectForKey:kWordList];
    } else {
        _wordList = nil;
    }
    NSLog(@"DEBUG: DataHolder: wordList: %@", _wordList);
    return _wordList;
}

- (void)setWordList:(NSString *)wordList {
    NSLog(@"DEBUG: DataHolder: setWordList: %@", wordList);
    _wordList = wordList;
    [self.defaults setObject:_wordList forKey:kWordList];
    [self.defaults synchronize];
}

@end
