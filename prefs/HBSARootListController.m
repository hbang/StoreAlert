#include "HBSARootListController.h"

@implementation HBSARootListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

+ (NSString *)hb_shareText {
	return [NSString stringWithFormat:@"I’m using StoreAlert to stop malicious ads from opening the App Store on my %@!", [UIDevice currentDevice].localizedModel];
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"https://www.hbang.ws/tweaks/storealert"];
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:9.f / 255.f green:85.f / 255.f blue:252.f / 255.f alpha:1];
}

@end
