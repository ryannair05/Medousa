@interface BSPlatform : NSObject
@property(nonatomic, readonly) long long homeButtonType;
+ (id)sharedInstance;
- (long long)homeButtonType;
@end

static BOOL enabled, wantsmultitasking, wantsuggestions, wantsrecentapps, wantsgesture;

%hook SBFloatingDockController
+ (BOOL)isFloatingDockSupported {
	return enabled;
}
%end

%hook SBMedusaConfigurationUsageMetric

+ (BOOL)_isFloatingActive {
	return wantsmultitasking;
}
%end

%hook UIApplication

+ (BOOL)isMedusaEnabled {
	return wantsmultitasking;
}
%end

%hook SBFloatingDockSuggestionsModel

- (BOOL)_shouldProcessAppSuggestion:(id)arg1 {
	return wantsuggestions;
}

-(void)_setRecentsEnabled:(BOOL)arg1 {
    arg1 = wantsrecentapps;
	return %orig;
}
%end

%hook SBPlatformController
-(long long)medusaCapabilities {
	return 2;
}
%end

%hook SBMainWorkspace
-(BOOL)isMedusaEnabled {
	return wantsmultitasking;
}
%end

%hook SBApplication
-(BOOL)isMedusaCapable {
	return wantsmultitasking;
}
%end

%group unsupported
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:@"You are missing a iPhone X gesture enabler"
        message:@"This tweak's gesture functionality only works on X series devices or devices with the iPhone X gestures enabled. Please install a tweak such as LittleXS to reslove this issue."
        preferredStyle:UIAlertControllerStyleAlert
    ];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [((UIApplication*)self).keyWindow.rootViewController dismissViewControllerAnimated:YES completion:NULL];
    }]];

    [((UIApplication*)self).keyWindow.rootViewController presentViewController:alertController animated:YES completion:NULL];
}

%end
%end

// Preferences.
static void loadPrefs() {
    BOOL isSystem = [NSHomeDirectory() isEqualToString:@"/var/mobile"];
    NSDictionary* globalSettings = nil;
    if(isSystem) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.ryannair05.medousaprefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if(keyList) {
            globalSettings = (__bridge NSDictionary *)CFPreferencesCopyMultiple(keyList, CFSTR("com.ryannair05.medousaprefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
            if(!globalSettings) globalSettings = [NSDictionary new];
            CFRelease(keyList);
        }
    }
    if (!globalSettings)
        globalSettings = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.ryannair05.medousaprefs.plist"];
        enabled = (BOOL)[[globalSettings objectForKey:@"Enabled"]?:@TRUE boolValue];
        wantsgesture = (BOOL)[[globalSettings objectForKey:@"Gesture"]?:@TRUE boolValue];
        wantsuggestions = (BOOL)[[globalSettings objectForKey:@"Suggestions"]?:@TRUE boolValue];
        wantsrecentapps = (BOOL)[[globalSettings objectForKey:@"Recent"]?:@TRUE boolValue];
        wantsmultitasking = (BOOL)[[globalSettings objectForKey:@"Multitasking"]?:@TRUE boolValue];
}

%ctor {
    @autoreleasepool {
        loadPrefs();
        BSPlatform *platform = [NSClassFromString(@"BSPlatform") sharedInstance];
	if ((platform.homeButtonType == 1) && wantsgesture) %init(unsupported);
       	else %init(_ungrouped);
	}
}
