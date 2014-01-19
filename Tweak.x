#import "HBSAStorePermissionAlertItem.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBAlertItemsController.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <version.h>

BOOL override = NO;

void HBSAOverrideOpenURL(NSURL *url) {
	override = YES;
	[[UIApplication sharedApplication] openURL:url];
	override = NO;
}

BOOL HBSAOpenURL(NSURL *url, SBApplication *display, NSString *sender) {
	if (!override && [@[ @"itms", @"itmss", @"itms-apps", @"itms-appss", @"http", @"https" ] containsObject:url.scheme] && [url.host isEqualToString:@"itunes.apple.com"]) {
		SBApplication *sourceApp = sender ? [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:sender] : ((SpringBoard *)[UIApplication sharedApplication])._accessibilityFrontMostApplication;

		HBSAStorePermissionAlertItem *alert = [[[HBSAStorePermissionAlertItem alloc] initWithURL:url sourceDisplayName:sourceApp.displayName destinationDisplayName:display.displayName] autorelease];
		[(SBAlertItemsController *)[%c(SBAlertItemsController) sharedInstance] activateAlertItem:alert];

		return NO;
	}

	return YES;
}

%hook SpringBoard

%group SteveJobs

- (void)_openURLCore:(NSURL *)url display:(SBApplication *)display publicURLsOnly:(BOOL)publicOnly animating:(BOOL)animate additionalActivationFlag:(NSUInteger)flags {
	if (HBSAOpenURL(url, display, nil)) {
		%orig;
	}
}

%end

%group ScottForstall

- (void)_openURLCore:(NSURL *)url display:(SBApplication *)display animating:(BOOL)animate sender:(NSString *)sender additionalActivationFlags:(id)flags {
	if (HBSAOpenURL(url, display, sender)) {
		%orig;
	}
}

%end

%group JonyIve

- (void)_openURLCore:(NSURL *)url display:(SBApplication *)display animating:(BOOL)animate sender:(NSString *)sender additionalActivationFlags:(id)flags activationHandler:(id)handler {
	if (HBSAOpenURL(url, display, sender)) {
		%orig;
	}
}

%end

%end

%ctor {
	%init;

	if (IS_IOS_OR_NEWER(iOS_7_0)) {
		%init(JonyIve);
	} else if (IS_IOS_OR_NEWER(iOS_6_0)) {
		%init(ScottForstall);
	} else {
		%init(SteveJobs);
	}
}
