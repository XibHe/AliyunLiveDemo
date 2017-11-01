
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ALIVC_ALERT_TAG) {
    ALIVC_START_ALERT_TAG_VIDEOCALL_INVITE = 1000,               // 连麦邀请
    ALIVC_START_ALERT_TAG_VIDEOCALL_EXIT = 1001,               // 退出连麦
    ALIVC_START_ALERT_TAG_ROOM_EXIT = 1002,               // 退出房间

};

@protocol AlivcLiveAlertViewDelegate;

@interface AlivcLiveAlertView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, weak) id<AlivcLiveAlertViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon message:(NSString *)message delegate:(id<AlivcLiveAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)showInView:(UIView *)view;

- (void)hide;

@end

@protocol AlivcLiveAlertViewDelegate <NSObject>

- (void)alertView:(AlivcLiveAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
