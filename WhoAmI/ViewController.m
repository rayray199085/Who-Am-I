//
//  ViewController.m
//  WhoAmI
//
//  Created by Stephen Cao on 6/2/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

#import "ViewController.h"
#import "SCQuestion.h"
@interface ViewController ()<UIAlertViewDelegate>
@property(nonatomic, strong) NSArray *data;
@property(nonatomic, assign) int index;
@property(nonatomic, assign) BOOL isExpand;
@property(weak, nonatomic) IBOutlet UILabel *indexNotification;
@property(weak, nonatomic) IBOutlet UIButton *coins;
@property (weak, nonatomic) IBOutlet UIButton *hintBtn;
@property(weak, nonatomic) IBOutlet UILabel *questionTitle;
@property(weak, nonatomic) IBOutlet UIButton *image;
@property(weak, nonatomic) IBOutlet UIButton *nextBtn;
@property(weak, nonatomic) IBOutlet UIButton *cover;
@property(nonatomic, assign) CGRect originalRect;
@property(weak, nonatomic) IBOutlet UIView *answerView;
@property(weak, nonatomic) IBOutlet UIView *optionView;
- (IBAction)next:(id)sender;
- (IBAction)hint:(id)sender;
- (IBAction)expandImage:(id)sender;
- (void)removeCover;
- (void)showContent;
- (void)expandPic;
- (void)shrinkPic;
- (void)initAnswer:(SCQuestion *)question;
- (void)initOptions:(SCQuestion *)question;
- (void)editCoinQuantityWithNumber:(int)coinAmount;
- (void)optionButtonClick:(UIButton *)button;
- (void)answerButtonClick:(UIButton *)button;
- (void)putOptionWordsBackWithButton:(UIButton *)button;
- (void)showFinishedAlertDialog;
- (void)setButtonTitleInViews:(UIView *)view withColor:(UIColor *)color;
- (IBAction)imageExpand:(id)sender;
@end

@implementation ViewController
- (NSArray *)data {
  if (_data == nil) {
    NSString *path =
        [[NSBundle mainBundle] pathForResource:@"questions.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *tempData = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
      SCQuestion *question = [SCQuestion questionWithDictionary:dict];
      [tempData addObject:question];
    }
    _data = tempData;
  }
  return _data;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  [self showContent];
}

- (IBAction)next:(id)sender {
  if (self.index < self.data.count - 1) {
    self.index++;
    [self showContent];
  } else {
    self.nextBtn.enabled = NO;
  }
}

- (IBAction)expandImage:(id)sender {
  [self expandPic];
}
- (void)removeCover {
  [self shrinkPic];
}

/**
 Display the main contents
 */
- (void)showContent {
  self.hintBtn.enabled = YES;
  self.optionView.userInteractionEnabled = YES;
  self.indexNotification.text =
      [NSString stringWithFormat:@"%d/%lu", self.index + 1, self.data.count];
  SCQuestion *currentQuestion = self.data[self.index];
  self.questionTitle.text = currentQuestion.title;
  [self.image setImage:[UIImage imageNamed:currentQuestion.icon]
              forState:UIControlStateNormal];
  [self initAnswer:currentQuestion];
  [self initOptions:currentQuestion];
}
/**
 Initialize the option buttons for users to choose
 */
- (void)initOptions:(SCQuestion *)question {
  [self.optionView.subviews
      makeObjectsPerformSelector:@selector(removeFromSuperview)];
  NSArray *optionList = question.options;
  NSInteger len = optionList.count;
  CGFloat optionWidth = 36;
  int column = 7;
  CGFloat margin =
      (self.optionView.frame.size.width - optionWidth * column) / (column + 1);

  for (int i = 0; i < len; i++) {
    CGRect rect =
        CGRectMake(margin + (optionWidth + margin) * (i % column),
                   (i / column) * optionWidth + margin * (i / column + 1),
                   optionWidth, optionWidth);
    UIButton *button = [[UIButton alloc] init];
    button.frame = rect;
    [button setTitle:optionList[i] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_option"]
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"]
                      forState:UIControlStateHighlighted];
    button.tag = i + 11;
    [self.optionView addSubview:button];
    [button addTarget:self
                  action:@selector(optionButtonClick:)
        forControlEvents:UIControlEventTouchUpInside];
  }
}
/**
 Option buttons click listener
 */
- (void)optionButtonClick:(UIButton *)button {
  button.hidden = YES;
  NSString *word = [button titleForState:UIControlStateNormal];
  for (UIButton *answerButton in self.answerView.subviews) {
    if (answerButton.currentTitle == nil) {
      answerButton.tag = button.tag;
      [answerButton setTitle:word forState:UIControlStateNormal];
      break;
    }
  }
  BOOL isFull = YES;
  NSMutableString *currentAnswer = [NSMutableString string];
  for (UIButton *answerButton in self.answerView.subviews) {
    [currentAnswer appendFormat:@"%@", answerButton.currentTitle];
    if (answerButton.currentTitle == nil) {
      isFull = NO;
    }
  }
  if (isFull) {
    SCQuestion *currentQuestion = self.data[self.index];
    if ([currentAnswer isEqualToString:currentQuestion.answer]) {
      [self setButtonTitleInViews:self.answerView
                        withColor:[UIColor blueColor]];
      if (self.index < self.data.count - 1) {
        self.index++;
        [self performSelector:@selector(showContent)
                   withObject:nil
                   afterDelay:0.5];
        [self editCoinQuantityWithNumber:300];
      } else {
        [self showFinishedAlertDialog];
      }
    } else {
      [self setButtonTitleInViews:self.answerView withColor:[UIColor redColor]];
    }
    self.optionView.userInteractionEnabled = NO;
  } else {
    self.optionView.userInteractionEnabled = YES;
  }
  currentAnswer = nil;
}
/**
 Initialize the places for answers
 */
- (void)answerButtonClick:(UIButton *)button {
  [self putOptionWordsBackWithButton:button];
}
- (void)putOptionWordsBackWithButton:(UIButton *)button {
  self.optionView.userInteractionEnabled = YES;
  [button setTitle:nil forState:UIControlStateNormal];
  [self setButtonTitleInViews:self.answerView withColor:[UIColor blackColor]];
  for (UIButton *optionBtn in self.optionView.subviews) {
    if (optionBtn.tag == button.tag) {
      optionBtn.hidden = NO;
    }
  }
}
- (void)initAnswer:(SCQuestion *)question {
  NSString *answer = question.answer;
  NSInteger len = answer.length;
  CGFloat buttonWidth = 36;
  CGFloat margin = buttonWidth / 2;
  CGFloat firstButtonOffset = (self.answerView.frame.size.width -
                               buttonWidth * len - margin * (len - 1)) /
                              2;
  [self.answerView.subviews
      makeObjectsPerformSelector:@selector(removeFromSuperview)];
  for (int i = 0; i < len; i++) {
    UIButton *button = [[UIButton alloc] init];
    CGRect rect = CGRectMake(firstButtonOffset + i * (buttonWidth + margin), 0,
                             buttonWidth, buttonWidth);
    button.frame = rect;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_answer"]
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"]
                      forState:UIControlStateHighlighted];
    [self.answerView addSubview:button];
    [button addTarget:self
                  action:@selector(answerButtonClick:)
        forControlEvents:UIControlEventTouchUpInside];
  }
}

- (IBAction)imageExpand:(id)sender {
  if (!self.isExpand) {
    [self expandPic];
    self.isExpand = YES;
  } else {
    [self shrinkPic];
    self.isExpand = NO;
  }
}
/**
 Press large button or click the image to large the image
 */
- (void)expandPic {
  CGFloat screenWidth = self.view.frame.size.width;
  CGFloat screenHeight = self.view.frame.size.height;

  UIButton *cover = [[UIButton alloc] init];
  self.cover = cover;
  CGRect rect = CGRectMake(0, 0, screenWidth, screenHeight);
  self.cover.frame = rect;
  self.cover.alpha = 0;
  self.cover.backgroundColor = [UIColor blackColor];
  [self.view addSubview:self.cover];
  [self.view bringSubviewToFront:self.image];
  CGFloat translateDistance = (screenHeight - screenWidth) / 2;
  self.originalRect = self.image.frame;
  [UIView animateWithDuration:1
                   animations:^{
                     self.cover.alpha = 0.6;
                     CGRect imageRect = CGRectMake(0, translateDistance,
                                                   screenWidth, screenWidth);
                     self.image.frame = imageRect;
                   }];
  [self.cover addTarget:self
                 action:@selector(removeCover)
       forControlEvents:UIControlEventTouchDown];
}
/**
 Recover the image to its original size
 */
- (void)shrinkPic {
  [UIView animateWithDuration:1
      animations:^{
        self.image.frame = self.originalRect;
        self.cover.alpha = 0;
      }
      completion:^(BOOL finished) {
        if (finished) {
          [self.cover removeFromSuperview];
        }
      }];
}
- (void)setButtonTitleInViews:(UIView *)view withColor:(UIColor *)color {
  for (UIButton *button in view.subviews) {
    [button setTitleColor:color forState:UIControlStateNormal];
  }
}
- (void)showFinishedAlertDialog {
  //    UIAlertController *alert = [UIAlertController
  //    alertControllerWithTitle:@"Congratulates!" message:@"This is the last
  //    Question." preferredStyle:UIAlertControllerStyleAlert];
  //    [alert addAction:[UIAlertAction actionWithTitle:@"Confirm"
  //    style:UIAlertActionStyleCancel handler:nil]];
  //    [self presentViewController:alert animated:YES completion:^{
  //        self.index = 0;
  //        [self showContent];
  //    }];
  UIAlertView *alert = [[UIAlertView alloc]
          initWithTitle:@"Congratulates!"
                message:@"This is the last question. Do you want to play again?"
               delegate:self
      cancelButtonTitle:@"No"
      otherButtonTitles:@"Yes", nil];
  [alert show];
}
- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 0:
      break;
    case 1:
      self.index = 0;
      [self showContent];
      self.nextBtn.enabled = YES;
      break;
    default:
      break;
  }
}
- (IBAction)hint:(id)sender {
  int currentCoinAmount = [self.coins.currentTitle intValue];
  if (currentCoinAmount - 1000 >= 0) {
    [self editCoinQuantityWithNumber:-1000];
    for (UIButton *button in self.answerView.subviews) {
      [self putOptionWordsBackWithButton:button];
    }
      SCQuestion *currentQuestion = self.data[self.index];
      NSString *word =  [currentQuestion.answer substringToIndex:1];
      for(UIButton *button in self.optionView.subviews){
          if([button.currentTitle isEqualToString:word]){
              [self optionButtonClick:button];
              break;
          }
      }
      self.hintBtn.enabled = NO;
  }
}
- (void)editCoinQuantityWithNumber:(int)coinAmount {
  [self.coins
      setTitle:[NSString
                   stringWithFormat:@"%d", [self.coins.currentTitle intValue] +
                                               coinAmount]
      forState:UIControlStateNormal];
}
@end
