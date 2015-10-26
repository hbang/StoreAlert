#import "Global.h"
#import "HBSAStorePermissionAlertItem.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBAppSliderController.h>
#import <SpringBoard/SBMediaController.h>
#import <UIKit/UIAlertView+Private.h>
#import <UIKit/UIViewController+Private.h>

extern HBPreferences *preferences;

@interface HBSAStorePermissionAlertItem () {
	NSBundle *_bundle;
	NSBundle *_uikitBundle;

	NSURL *_url;
	NSString *_sourceDisplayName;
	NSString *_destinationDisplayName;
}

@end

@implementation HBSAStorePermissionAlertItem

- (instancetype)initWithURL:(NSURL *)url sourceDisplayName:(NSString *)sourceDisplayName destinationDisplayName:(NSString *)destinationDisplayName {
	self = [self init];

	if (self) {
		// we need StoreAlert.bundle and UIKit's bundle, so we can get
		// localizations from it
		_bundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/StoreAlert.bundle"] retain];
		_uikitBundle = [[NSBundle bundleForClass:UIView.class] retain];

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

	self.alertSheet.delegate = self;
	self.alertSheet.title = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"APP_WANTS_TO_OPEN_APP", @"Localizable", bundle, @"Message displayed in the alert, informing the user of the source and destination app."), _sourceDisplayName, _destinationDisplayName];

	// if the user wants to see the URL in the alert, make it the message text
	if ([preferences boolForKey:kHBSAShowURLKey]) {
		self.alertSheet.message = _url.absoluteString;
	}

	// stealing some strings from UIKit for the buttons
	[self.alertSheet addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Open Link", @"Localizable", _uikitBundle, nil)];
	[self.alertSheet addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", @"Localizable", _uikitBundle, nil)];

	self.alertSheet.cancelButtonIndex = 1;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
	[self dismiss];

	// pass back the result to the completion handler. the open button is at
	// index 0
	_completion(index == 0);
}

#pragma mark - Memory management

- (void)dealloc {
	[_bundle release];
	[_uikitBundle release];

	[_url release];
	[_sourceDisplayName release];
	[_destinationDisplayName release];

	[_completion release];

	[super dealloc];
}

@end
