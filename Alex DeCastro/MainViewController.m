//
//  MainViewController.m
//  Alex DeCastro
//
//  Created by Alex on 4/20/15.
//  Copyright (c) 2015 Alex DeCastro. All rights reserved.
//

#import "MainViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "DataHolder.h"
#import "NSString+WSStringAdditions.h"
#import "WordListModel.h"

@interface MainViewController () <UIActionSheetDelegate>

#pragma mark - Outlets

// Display the current word in a label
@property (weak, nonatomic) IBOutlet UILabel *currentWordLabel;

// Button to start the word list
@property (weak, nonatomic) IBOutlet UIButton *startButton;

// Button to check the word list
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

// Number of words for each iteration. { 4, 8, 12, 16 }
@property (weak, nonatomic) IBOutlet UISegmentedControl *numberOfWordsSegmentedControl;

// Display the scores for each iteration
@property (weak, nonatomic) IBOutlet UISegmentedControl *scoreForEachIterationSegmentedControl;

// Select one of four lists of words
@property (weak, nonatomic) IBOutlet UISegmentedControl *wordListSegmentedControl;

// Display the score for each word list
@property (weak, nonatomic) IBOutlet UISegmentedControl *scoreForEachWordListSegmentedControl;

// Word list model with the lists of words
@property (strong, nonatomic) WordListModel *wordListModel;

// The current word list index = { 0, 1, 2, 3 }
@property (nonatomic) NSUInteger currentListIndex;

// Array of words in the current list
@property (strong, nonatomic) NSArray *currentListOfWords;

// Number of words in the current iteration
@property (nonatomic) NSUInteger numberOfWords;

// Index for the current word
@property (nonatomic) NSUInteger currentWordIndex;

// Timer that controls the display of words
@property (strong, nonatomic) NSTimer *wordTimer;

// Number of seconds per word
@property (nonatomic) float secondsPerWord;

// Keep track of when the timer in on
@property (nonatomic) BOOL timerIsOn;

// Speech synthesizer
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@end

#pragma mark - Private variables

// Score for each word list
static int _wordListScore[4];

@implementation MainViewController

@synthesize wordListModel = _wordListModel;
@synthesize currentListIndex = _currentListIndex;
@synthesize currentListOfWords = _currentListOfWords;
@synthesize numberOfWords = _numberOfWords;
@synthesize currentWordIndex = _currentWordIndex;
@synthesize wordTimer = _wordTimer;
@synthesize secondsPerWord = _secondsPerWord;
@synthesize timerIsOn = _timerIsOn;
@synthesize synthesizer = _synthesizer;

#pragma mark - Property Getters and Setters

- (WordListModel *)wordListModel {
    // Initialize the words list model,
    // if it has not yet been initialized.
    if (!_wordListModel) {
        _wordListModel = [[WordListModel alloc] init];
    }
    return _wordListModel;
}

- (void)setCurrentListIndex:(NSUInteger)currentListIndex {
    NSLog(@"DEBUG: MainViewController: setCurrentListIndex: %d", (int)currentListIndex);
    
    _currentListIndex = currentListIndex;
    
    // Update the current list of words,
    // based on the current list index.
    switch (currentListIndex) {
        case 0:
            self.currentListOfWords = self.wordListModel.list1;
            break;
        case 1:
            self.currentListOfWords = self.wordListModel.list2;
            break;
        case 2:
            self.currentListOfWords = self.wordListModel.list3;
            break;
        case 3:
            self.currentListOfWords = self.wordListModel.list4;
            break;
        default:
            NSLog(@"ERROR: MainViewController: setCurrentListIndex: %d", (int)index);
            break;
    }
}

- (NSArray *)currentListOfWords
{
    // Initialize the current list of words to the first list
    if (!_currentListOfWords) {
        _currentListOfWords = self.wordListModel.list1;
    }
    return _currentListOfWords;
}

#pragma mark - Life Cycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Initialize the speech synthesizer
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    
    // Display an introduction alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verbal Learning Test"
                                                    message:@"Press [Show me the list of words] to begin"
                                                   delegate:self cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    // Intialize the settings
    [self initilizeSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Instance Methods

- (void)initilizeSettings {
    // Initialize the current word label
    self.currentWordLabel.text = @"---";
    
    // Initialize the start button
    self.startButton.enabled  = YES;
    [self.startButton setTitle:@"Show me the list of words" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    // Disable the check button
    self.checkButton.enabled = NO;
    [self.checkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    // Set the segmented controls to the first segment
    [self.numberOfWordsSegmentedControl setSelectedSegmentIndex:0];
    [self.wordListSegmentedControl setSelectedSegmentIndex:0];
    
    // Reset all the scores
    _wordListScore[0] = 0;
    _wordListScore[1] = 0;
    _wordListScore[2] = 0;
    _wordListScore[3] = 0;
    [self resetScoresForNumberOfWords];
    [self resetScoresForAllWordLists];
    
    self.currentListIndex = 0;
    self.numberOfWords = 4;
    self.currentWordIndex = 0;
    self.secondsPerWord = 1.5f;
    self.timerIsOn = NO;
    
    // Initialize the app state
    [DataHolder sharedInstance].appState = @"01-Initial-State";
}

#pragma mark - Timer

// Start the timer
- (void) startTimer {
    self.wordTimer = [NSTimer
                      scheduledTimerWithTimeInterval:self.secondsPerWord
                      target:self
                      selector:@selector(timerFired:)
                      userInfo:nil
                      repeats:YES];
    
    self.timerIsOn = YES;
}

// Handle the timer events
- (void)timerFired:(NSTimer *)theTimer {
    NSLog(@"DEBUG: MainViewController: timerFired @ %@", [theTimer fireDate]);
    
    // If reached end of word list
    if (self.currentWordIndex >= self.numberOfWords) {
        // Reset the timer
        [self resetTimer];
    } else {
        // Get the current word
        NSString *currentWord = [self.currentListOfWords objectAtIndex:self.currentWordIndex];
        
        // Update the current word label
        self.currentWordLabel.text = currentWord;
        
        // Speak the word for the user
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.currentWordLabel.text];
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
        [self.synthesizer speakUtterance:utterance];
        
        // Go to the next word
        self.currentWordIndex++;
    }
}

// Stop the timer
- (void) stopTimer {
    [self.wordTimer invalidate];
    self.timerIsOn = NO;
    
    // Disable the start button
    self.startButton.enabled = NO;
    [self.startButton setTitle:@"Repeat words on Apple Watch" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // Enable the check button
    self.checkButton.enabled = YES;
    [self.checkButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    // Update the app state
    [DataHolder sharedInstance].appState = @"02-Record-Answer";
}

// Reset the timer
- (void) resetTimer {
    // Stop the timer
    [self stopTimer];
    
    // Reset the current list
    self.currentWordIndex = 0;
    self.currentWordLabel.text = @"---";
}

#pragma mark - Action Handlers

// Start button was pressed
- (IBAction)startButtonPressed:(UIButton *)sender {
    // If the timer is on,
    if (self.timerIsOn)
    {
        // then stop the timer.
        [self stopTimer];
    }
    else // (!self.timerIsOn)
    {
        // Disable the start button
        self.startButton.enabled = NO;
        [self.startButton setTitle:@"Wait for the list to finish" forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        // Start the timer
        [self startTimer];
    }
}

// Check button was pressed
- (IBAction)checkButtonPressed:(UIButton *)sender {
    // Get the app state
    NSString *appState = [DataHolder sharedInstance].appState;
    NSLog(@"DEBUG: MainViewController: checkButtonPressed: appState: %@", appState);
    
    // If no answer was received from the watch,
    if (![appState isEqualToString:@"03-Received-Answer"]) {
        // then display an alert to the user.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Record your answer on the Apple Watch"
                                                        message:@"You must first record your answer on the Apple Watch. Then you can check your answer here."
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    int score = 0;
    
    // Get the list of words recorded from the watch
    NSString *wordList = [DataHolder sharedInstance].wordList;
    
    for (NSUInteger i = 0; i < self.numberOfWords; i++) {
        // For each word in the current list,
        NSString *word = [self.currentListOfWords objectAtIndex:i];
        word = [word lowercaseString];
        
        // Search for the word in the list of recorded words
        if ([wordList containsString:word]) {
            NSLog(@"DEBUG: MainViewController: checkButtonPressed: CORRECT: Found word: %@", word);
            
            // Increment the score for the current iteration
            score++;
            
            // Increment the score for the current list
            _wordListScore[(int)self.currentListIndex]++;
        } else {
            NSLog(@"DEBUG: MainViewController: checkButtonPressed: WRONG: Not found word: %@", word);
        }
    }
    
    // Update the score for the current iteration
    [self setScore:score forNumberOfWord:self.numberOfWords];
    
    // Update the score for the current word list
    [self setScore:(NSUInteger)_wordListScore[(int)self.currentListIndex] forWordListIndex:self.currentListIndex];
    
    // Go to the next number of words
    [self gotoTheNextNumberOfWords];
    
    // Enable the start button
    self.startButton.enabled = YES;
    [self.startButton setTitle:@"Show me the list of words" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    // Disable the check button
    self.checkButton.enabled = NO;
    [self.checkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [DataHolder sharedInstance].appState = @"01-Initial-State";
}

// Update the score for the this number of words = { 4, 8, 12, 16 }
- (void)setScore:(NSUInteger)score
 forNumberOfWord:(NSUInteger)numberOfWords {
    NSLog(@"DEBUG: MainViewController: setScore:%d forNumberOfWord:%d", (int)score, (int)numberOfWords);
    
    NSString *title = [NSString stringWithFormat:@"You got %d out of %d words correct", (int)score, (int)numberOfWords];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:@"Press [Show me the list of words] to see the next list"
                                                   delegate:self cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    NSString *scoreString = [NSString stringWithFormat:@"%d / %d", (int)score, (int)numberOfWords];
    switch (numberOfWords) {
        case 4:
            [self.scoreForEachIterationSegmentedControl setTitle:scoreString forSegmentAtIndex:0];
            break;
        case 8:
            [self.scoreForEachIterationSegmentedControl setTitle:scoreString forSegmentAtIndex:1];
            break;
        case 12:
            [self.scoreForEachIterationSegmentedControl setTitle:scoreString forSegmentAtIndex:2];
            break;
        case 16:
            [self.scoreForEachIterationSegmentedControl setTitle:scoreString forSegmentAtIndex:3];
            break;
        default:
            NSLog(@"ERROR: MainViewController: setScore:forNumberOfWord:%d", (int)numberOfWords);
            break;
    }
}

// Reset the scores associated with the number of words
- (void)resetScoresForNumberOfWords {
    [self.scoreForEachIterationSegmentedControl setTitle:@"0 / 4" forSegmentAtIndex:0];
    [self.scoreForEachIterationSegmentedControl setTitle:@"0 / 8" forSegmentAtIndex:1];
    [self.scoreForEachIterationSegmentedControl setTitle:@"0 / 12" forSegmentAtIndex:2];
    [self.scoreForEachIterationSegmentedControl setTitle:@"0 / 16" forSegmentAtIndex:3];
}

- (void)setScore:(NSUInteger)score
forWordListIndex:(NSUInteger)index {
    NSLog(@"DEBUG: MainViewController: setScore:%d forWordListIndex:%d", (int)score, (int)index);
    
    NSString *scoreString = [NSString stringWithFormat:@"%d / 40", (int)score];
    switch (index) {
        case 0:
            [self.scoreForEachWordListSegmentedControl setTitle:scoreString forSegmentAtIndex:0];
            break;
        case 1:
            [self.scoreForEachWordListSegmentedControl setTitle:scoreString forSegmentAtIndex:1];
            break;
        case 2:
            [self.scoreForEachWordListSegmentedControl setTitle:scoreString forSegmentAtIndex:2];
            break;
        case 3:
            [self.scoreForEachWordListSegmentedControl setTitle:scoreString forSegmentAtIndex:3];
            break;
        default:
            NSLog(@"ERROR: MainViewController: setScore:forWordListIndex:%d", (int)index);
            break;
    }
}

// Reset the scores associated with the number of words
- (void)resetScoresForAllWordLists {
    [self.scoreForEachWordListSegmentedControl setTitle:@"0 / 40" forSegmentAtIndex:0];
    [self.scoreForEachWordListSegmentedControl setTitle:@"0 / 40" forSegmentAtIndex:1];
    [self.scoreForEachWordListSegmentedControl setTitle:@"0 / 40" forSegmentAtIndex:2];
    [self.scoreForEachWordListSegmentedControl setTitle:@"0 / 40" forSegmentAtIndex:3];
}

- (void)gotoTheNextNumberOfWords {
    switch (self.numberOfWords) {
        case 4:
            self.numberOfWords = 8;
            [self.numberOfWordsSegmentedControl setSelectedSegmentIndex:1];
            break;
        case 8:
            self.numberOfWords = 12;
            [self.numberOfWordsSegmentedControl setSelectedSegmentIndex:2];
            break;
        case 12:
            self.numberOfWords = 16;
            [self.numberOfWordsSegmentedControl setSelectedSegmentIndex:3];
            break;
        case 16:
            self.numberOfWords = 4;
            [self.numberOfWordsSegmentedControl setSelectedSegmentIndex:0];
            
            // Go to the next word list
            [self gotoTheNextWordList];
            
            break;
        default:
            break;
    }
}

// Go to the next word list
- (void)gotoTheNextWordList {
    NSUInteger selectedIndex = [self.wordListSegmentedControl selectedSegmentIndex];
    if (selectedIndex < 3) {
        selectedIndex++;
    } else {
        selectedIndex = 0;
    }
    self.currentListIndex = selectedIndex;
    [self.wordListSegmentedControl setSelectedSegmentIndex:selectedIndex];
    [self resetScoresForNumberOfWords];
}

- (IBAction)numberOfWordsSegmentedControlHandler:(UISegmentedControl *)sender
{
    NSUInteger selectedIndex = [sender selectedSegmentIndex];
    NSLog(@"DEBUG: MainViewController: numberOfWordsSegmentedControlHandler: selectedIndex: %d", (int)selectedIndex);
    
    switch (selectedIndex) {
        case 0:
            self.numberOfWords = 4;
            break;
        case 1:
            self.numberOfWords = 8;
            break;
        case 2:
            self.numberOfWords = 12;
            break;
        case 3:
            self.numberOfWords = 16;
            break;
        default:
            NSLog(@"ERROR: MainViewController: numberOfWordsSegmentedControlHandler: selectedIndex: %d", (int)selectedIndex);
            break;
    }
}

- (IBAction)wordListSegmentedControlHandler:(UISegmentedControl *)sender
{
    NSUInteger selectedIndex = [sender selectedSegmentIndex];
    NSLog(@"DEBUG: MainViewController: wordListSegmentedControlHandler: selectedIndex: %d", (int)selectedIndex);
    self.currentListIndex = selectedIndex;
}

- (IBAction)resetButtonPressed:(UIBarButtonItem *)sender
{
    NSLog(@"DEBUG: MainViewController: resetButtonPressed:");
    
    // Open an action sheet to confirm
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"This will reset everything to the initial state"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Reset"
                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    
}

#pragma mark - UIActionSheetDelegate

// Handle the action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        // cancelled, nothing happen
        return;
    }
    else if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        // Reset here
        [self initilizeSettings];
    }
}

@end
