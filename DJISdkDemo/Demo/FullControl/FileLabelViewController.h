//
//  FileLabelViewController.h
//  
//
//  Created by Ping Chen on 5/8/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FileLabelDelegate <NSObject>

- (void)setFileLabel:(NSString *)fileLabel;

@end


@interface FileLabelViewController : UIViewController

@property (assign, nonatomic) IBOutlet UIView *contentView;
@property (assign, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) IBOutlet UITextField *textField;
@property (assign, nonatomic) IBOutlet UIButton *readyButton;

@property (weak, nonatomic) id<FileLabelDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
