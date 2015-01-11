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
		_url = [url copy];
		_sourceDisplayName = [sourceDisplayName copy];
		_destinationDisplayName = [destinationDisplayName copy];
	}

	return self;
}

#pragma mark - SBAlertItem

- (void)configure:(BOOL)configure requirePasscodeForActions:(BOOL)requirePasscode {
	[super configure:configure requirePasscodeForActions:requirePasscode];

	self.alertSheet.delegate = self;
	self.alertSheet.title = [NSString stringWithFormat:@"“%@” Would Like To Open “%@”", _sourceDisplayName, _destinationDisplayName];

	if ([preferences boolForKey:kHBSAShowURLKey]) {
		self.alertSheet.message = _url.absoluteString;
	}

	[self.alertSheet addButtonWithTitle:@"Cancel"];
	[self.alertSheet addButtonWithTitle:@"Open"];

	self.alertSheet.cancelButtonIndex = 0;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index {
	[self dismiss];

	if (index != 1) {
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
