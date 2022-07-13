//
//  DetailsViewController.h
//  Calendar
//
//  Created by Angelina Zhang on 7/13/22.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "ParseEventHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController

@property (nonatomic) Event *event;
@property (nonatomic) ParseEventHandler *parseEventHandler;

@end

NS_ASSUME_NONNULL_END
