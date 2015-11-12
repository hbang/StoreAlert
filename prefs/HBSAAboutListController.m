#import "HBSAAboutListController.h"

@implementation HBSAAboutListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"About";
}

#pragma mark - Callbacks

- (void)openTranslations {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.hbang.ws/translations/"]];
}

@end
