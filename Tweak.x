#define _STOREALERT_TWEAK_X
#import "Global.h"
#import "HBSAStorePermissionAlertItem.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBAlertItemsController.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <UIKit/NSURL+UIKitAdditions.h>
#import <version.h>

HBPreferences *preferences;
BOOL override = NO;

void HBSAOverrideOpenURL(NSURL *url) {
	override = YES;
	[[UIApplication sharedApplication] openURL:url];
	override = NO;
}

BOOL HBSAOpenURL(NSURL *url, SBApplication *display, NSString *sender) {
	SBApplication *sourceApp;

	if (sender) {
		// get the SBApplication with the sender bundle id
		sourceApp = [%c(SBApplicationController) instancesRespondToSelector:@selector(applicationWithBundleIdentifier:)] ? [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:sender] : [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:sender];
	} else {
		// iOS 5: just assume it’s the frontmost app
		sourceApp = ((SpringBoard *)[UIApplication sharedApplication])._accessibilityFrontMostApplication;
	}

	// allow to go through if this is an override, the tweak is disabled, or the
	// source and destination are the same app
	if (override || ![preferences boolForKey:kHBSAEnabledKey] || ![sourceApp.bundleIdentifier isEqualToString:display.bundleIdentifier]) {
		return YES;
	}

	// if itmsURL != nil (confirms it’ll open the store), or it's an itms*://
	// url, and the app isn’t whitelisted, show the alert
	if ((url.itmsURL || [url.scheme hasPrefix:@"itms"]) && [preferences boolForKey:[@"DisplayIn-" stringByAppendingString:sourceApp.bundleIdentifier ?: @"Fallback"] default:YES]) {
		HBSAStorePermissionAlertItem *alert = [[[HBSAStorePermissionAlertItem alloc] initWithURL:url sourceDisplayName:sourceApp.displayName destinationDisplayName:display.displayName] autorelease];
		[(SBAlertItemsController *)[%c(SBAlertItemsController) sharedInstance] activateAlertItem:alert];

		return NO;
	}

	// otherwise, let the open operation go through
	return YES;
}

#pragma mark - Hooks

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

%group JonyIvePointOne

- (void)_openURLCore:(NSURL *)url display:(SBApplication *)display animating:(BOOL)animate sender:(NSString *)sender activationContext:(id)context activationHandler:(id)handler {
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

#pragma mark - Constructor

%ctor {
	%init;

	preferences = [[HBPreferences alloc] initWithIdentifier:@"ws.hbang.storealert"];
	[preferences registerDefaults:@{
		kHBSAEnabledKey: @YES,
		kHBSAShowURLKey: @YES
	}];

	// set these apps as trusted by default, because they show their own alerts
	for (NSString *app in @[ @"com.saurik.Cydia", @"com.tapbots.Tweetbot", @"com.tapbots.TweetbotPad", @"com.tapbots.Tweetbot3", @"com.tapbots.Tweetbot4" ]) {
		NSString *key = [@"DisplayIn-" stringByAppendingString:app];

		if (![preferences objectForKey:key]) {
			[preferences setBool:NO forKey:key];
		}
	}

	if (IS_IOS_OR_NEWER(iOS_8_0)) {
		%init(CraigFederighi);
	} else if (IS_IOS_OR_NEWER(iOS_7_1)) {
		%init(JonyIvePointOne);
	} else if (IS_IOS_OR_NEWER(iOS_7_0)) {
		%init(JonyIve);
	} else if (IS_IOS_OR_NEWER(iOS_6_0)) {
		%init(ScottForstall);
	} else {
		%init(SteveJobs);
	}
}
