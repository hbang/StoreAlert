#import "Global.h"
#import "HBSAStorePermissionAlertItem.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBAppSliderController.h>
#import <SpringBoard/SBMediaController.h>
#import <UIKit/UIAlertView+Private.h>
#import <UIKit/UIViewController+Private.h>

void HBSAOverrideOpenURL(NSURL *url);
extern HBPreferences *preferences;

NSBundle *bundle;

@interface HBSAStorePermissionAlertItem () {
	NSURL *_url;
	NSString *_sourceDisplayName;
	NSString *_destinationDisplayName;
}

@end

@implementation HBSAStorePermissionAlertItem

- (instancetype)initWithURL:(NSURL *)url sourceDisplayName:(NSString *)sourceDisplayName destinationDisplayName:(NSString *)destinationDisplayName {
	self = [self init];

	if (self) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			bundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/StoreAlert.bundle"] retain];
		});

		_url = [url copy];
		_sourceDisplayName = [sourceDisplayName copy];
		_destinationDisplayName = [destinationDisplayName copy];

		if (!_sourceDisplayName) {
			_sourceDisplayName = NSLocalizedStringFromTableInBundle(@"UNKNOWN_APP", @"Localizable", bundle, @"Name used when the app can’t be determined.");
		}
	}

	return self;
}

#pragma mark - SBAlertItem

- (void)configure:(BOOL)configure requirePasscodeForActions:(BOOL)requirePasscode {
	[super configure:configure requirePasscodeForActions:requirePasscode];

	static NSBundle *UIKitBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIKitBundle = [[NSBundle bundleForClass:UIView.class] retain];
	});

	self.alertSheet.delegate = self;
	self.alertSheet.title = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"APP_WANTS_TO_OPEN_APP", @"Localizable", bundle, @"Message displayed in the alert, informing the user of the source and destination app."), _sourceDisplayName, _destinationDisplayName];

	if ([preferences boolForKey:kHBSAShowURLKey]) {
		self.alertSheet.message = _url.absoluteString;
	}

	[self.alertSheet addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Open Link", @"Localizable", UIKitBundle, nil)];
	[self.alertSheet addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", @"Localizable", UIKitBundle, nil)];

	self.alertSheet.cancelButtonIndex = 1;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
	[self dismiss];

	if (index != 0) {
		return;
	}

	HBSAOverrideOpenURL(_url);
}

#pragma mark - Memory management

- (void)dealloc {
	[_url release];
	[_sourceDisplayName release];
	[_destinationDisplayName release];

	[super dealloc];
}

@end
