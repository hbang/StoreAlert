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

@interface SpringBoard ()

- (void)_storealert_applicationOpenURL:(NSURL *)url withApplication:(SBApplication *)application sender:(NSString *)sender completion:(HBSAOpenURLCompletion)completion;

@end

#pragma mark - Hooks

%hook SpringBoard

%new - (void)_storealert_applicationOpenURL:(NSURL *)url withApplication:(SBApplication *)application sender:(NSString *)sender completion:(HBSAOpenURLCompletion)completion {
	SBApplication *sourceApp = nil;

	if (sender) {
		// get the SBApplication with the sender bundle id
		sourceApp = [%c(SBApplicationController) instancesRespondToSelector:@selector(applicationWithBundleIdentifier:)] ? [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:sender] : [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:sender];
	} else {
		// iOS 5: just assume it’s the frontmost app
		sourceApp = ((SpringBoard *)[UIApplication sharedApplication])._accessibilityFrontMostApplication;
	}

	// allow to go through if the tweak is disabled, the source and destination
	// are the same app, or the source is the in-app product view controller
	// (SKStoreProductViewController)
	if (![preferences boolForKey:kHBSAEnabledKey] || [sourceApp.bundleIdentifier isEqualToString:application.bundleIdentifier] || [sourceApp.bundleIdentifier isEqualToString:@"com.apple.ios.StoreKitUIService"]) {
		completion(YES);
	}

	// if itmsURL != nil (confirms it’ll open the store), or it's an itms*://
	// url, and the app isn’t whitelisted, show the alert
	if ((url.itmsURL || [url.scheme hasPrefix:@"itms"]) && [preferences boolForKey:[@"DisplayIn-" stringByAppendingString:sourceApp.bundleIdentifier ?: @"Fallback"] default:YES]) {
		HBSAStorePermissionAlertItem *alert = [[[HBSAStorePermissionAlertItem alloc] initWithURL:url sourceDisplayName:sourceApp.displayName destinationDisplayName:application.displayName] autorelease];
		alert.completion = completion;
		[(SBAlertItemsController *)[%c(SBAlertItemsController) sharedInstance] activateAlertItem:alert];

		return;
	}

	// otherwise, let the open operation go through
	completion(YES);
}

%group CraigFederighi // 8.0 – 9.0 (wow, streak!)
- (void)applicationOpenURL:(NSURL *)url withApplication:(SBApplication *)application sender:(NSString *)sender publicURLsOnly:(BOOL)publicURLsOnly animating:(BOOL)animating needsPermission:(BOOL)needsPermission activationSettings:(id)activationSettings withResult:(id)result {
	__block id newResult = [result copy];

	[self _storealert_applicationOpenURL:url withApplication:application sender:sender completion:^(BOOL allowed) {
		if (allowed) {
			%orig(url, application, sender, publicURLsOnly, animating, needsPermission, activationSettings, newResult);
		}

		[newResult release];
	}];
}
%end

%group JonyIvePointOne // 7.1
- (void)applicationOpenURL:(NSURL *)url withApplication:(SBApplication *)application sender:(NSString *)sender publicURLsOnly:(BOOL)publicURLsOnly animating:(BOOL)animating needsPermission:(BOOL)needsPermission activationContext:(id)context activationHandler:(id)handler {
	__block id newHandler = [handler copy];

	[self _storealert_applicationOpenURL:url withApplication:application sender:sender completion:^(BOOL allowed) {
		if (allowed) {
			%orig(url, application, sender, publicURLsOnly, animating, needsPermission, context, newHandler);
		}

		[newHandler release];
	}];
}
%end

%group JonyIve // 7.0
- (void)applicationOpenURL:(NSURL *)url withApplication:(SBApplication *)application sender:(NSString *)sender publicURLsOnly:(BOOL)publicURLsOnly animating:(BOOL)animating needsPermission:(BOOL)needsPermission additionalActivationFlags:(id)flags activationHandler:(id)handler {
	__block id newHandler = [handler copy];

	[self _storealert_applicationOpenURL:url withApplication:application sender:sender completion:^(BOOL allowed) {
		if (allowed) {
			%orig(url, application, sender, publicURLsOnly, animating, needsPermission, flags, newHandler);
		}

		[newHandler release];
	}];
}
%end

%group ScottForstall // 6.0 – 6.1
- (void)applicationOpenURL:(NSURL *)url withApplication:(SBApplication *)application sender:(NSString *)sender publicURLsOnly:(BOOL)publicURLsOnly animating:(BOOL)animating needsPermission:(BOOL)needsPermission additionalActivationFlags:(id)flags {
	[self _storealert_applicationOpenURL:url withApplication:application sender:sender completion:^(BOOL allowed) {
		if (allowed) {
			%orig;
		}
	}];
}
%end

%group SteveJobs // 5.0 – 5.1
- (void)applicationOpenURL:(NSURL *)url publicURLsOnly:(BOOL)publicURLsOnly animating:(BOOL)animating sender:(NSString *)sender additionalActivationFlag:(unsigned)flag {
	[self _storealert_applicationOpenURL:url withApplication:nil sender:sender completion:^(BOOL allowed) {
		if (allowed) {
			%orig;
		}
	}];
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
