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
	SBApplication *sourceApp;

	if (sender) {
		sourceApp = [%c(SBApplicationController) instancesRespondToSelector:@selector(applicationWithBundleIdentifier:)] ? [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:sender] : [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:sender];
	} else {
		sourceApp = ((SpringBoard *)[UIApplication sharedApplication])._accessibilityFrontMostApplication;
	}

	NSLog(@"override %i",override);
	NSLog(@"matches scheme %i",[@[ @"itms", @"itmss", @"itms-apps", @"itms-appss", @"http", @"https" ] containsObject:url.scheme]);
	NSLog(@"matches host %i",[url.host isEqualToString:@"itunes.apple.com"]);
	NSLog(@"%@ == %@ == %i",sender,sourceApp.bundleIdentifier,[sender isEqualToString:display.bundleIdentifier]);

	if (!override && [@[ @"itms", @"itmss", @"itms-apps", @"itms-appss", @"http", @"https" ] containsObject:url.scheme] && [url.host isEqualToString:@"itunes.apple.com"] && ![sender isEqualToString:display.bundleIdentifier]) {
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

%group CraigFederighi

- (void)_openURLCore:(NSURL *)url display:(SBApplication *)display animating:(BOOL)animating sender:(NSString *)sender activationSettings:(id)settings withResult:(id)result {
	if (HBSAOpenURL(url, display, sender)) {
		%orig;
	}
}

%end

%end

%ctor {
	%init;

	if (IS_IOS_OR_NEWER(iOS_8_0)) {
		%init(CraigFederighi);
	} else if (IS_IOS_OR_NEWER(iOS_7_0)) {
		%init(JonyIve);
	} else if (IS_IOS_OR_NEWER(iOS_6_0)) {
		%init(ScottForstall);
	} else {
		%init(SteveJobs);
	}
}
