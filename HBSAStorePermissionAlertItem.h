#import <SpringBoardUI/SBAlertItem.h>

@interface HBSAStorePermissionAlertItem : SBAlertItem

- (instancetype)initWithURL:(NSURL *)url sourceDisplayName:(NSString *)sourceDisplayName destinationDisplayName:(NSString *)destinationDisplayName;

@end
