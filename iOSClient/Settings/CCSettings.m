//
//  CCSettings.m
//  Nextcloud
//
//  Created by Marino Faggiana on 24/11/14.
//  Copyright (c) 2017 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "CCSettings.h"
#import "AppDelegate.h"
#import "CCMain.h"
#import "OCCapabilities.h"
#import "CCSynchronize.h"
#import "CCAdvanced.h"
#import "CCManageAccount.h"
#import "NCManageEndToEndEncryption.h"
#import "NCBridgeSwift.h"
#import <TOPasscodeViewController/TOPasscodeViewController.h>


#define alertViewEsci 1
#define alertViewAzzeraCache 2

@interface CCSettings () <TOPasscodeSettingsViewControllerDelegate, TOPasscodeViewControllerDelegate>
{
    AppDelegate *appDelegate;
}
@end

@implementation CCSettings

- (void)initializeForm
{
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"_settings_", nil)];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    NSInteger versionServer = [[NCManageDatabase sharedInstance] getServerVersionWithAccount:appDelegate.activeAccount];
    
    form.rowNavigationOptions = XLFormRowNavigationOptionNone;
    
    // Section AUTO UPLOAD OF CAMERA IMAGES ----------------------------
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"autoUpload" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"_settings_autoupload_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundView;
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"autoUpload"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
    row.action.viewControllerClass = [CCManageAutoUpload class];
    [section addFormRow:row];

    // Section FOLDERS FAVORITES OFFLINE ------------------------------------
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"favoriteoffline" rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedString(@"_favorite_offline_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundView;
    [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"favorite"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
    [section addFormRow:row];
    
    // Section : LOCK --------------------------------------------------------------
    
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"_lock_", nil)];
    [form addFormSection:section];
    
    // Lock active YES/NO
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"bloccopasscode" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"_lock_not_active_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundView;
    [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"settingsPasscodeNO"] multiplier:2 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:@(NSTextAlignmentLeft) forKey:@"textLabel.textAlignment"];
    //[row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
    row.action.formSelector = @selector(passcode:);
    [section addFormRow:row];
    
    // Lock no screen
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"onlylockdir" rowType:XLFormRowDescriptorTypeBooleanSwitch title:NSLocalizedString(@"_lock_protection_no_screen_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundView;
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
    [section addFormRow:row];
    
    // Section : Screen --------------------------------------------------------------
    
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"_screen_", nil)];
    [form addFormSection:section];
    
    // Dark Mode
    if (@available(iOS 13.0, *)) {
        
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"darkModeDetect" rowType:XLFormRowDescriptorTypeBooleanSwitch title:[NSString stringWithFormat:@"%@ (beta)", NSLocalizedString(@"_dark_mode_detect_", nil)]];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundView;
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"darkModeDetect"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        if ([CCUtility getDarkModeDetect]) row.value = @1;
        else row.value = @0;
        [section addFormRow:row];
        
    } else {
        
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"darkMode" rowType:XLFormRowDescriptorTypeBooleanSwitch title:[NSString stringWithFormat:@"%@ (beta)", NSLocalizedString(@"_dark_mode_", nil)]];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundView;
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"themeLightDark"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        if ([CCUtility getDarkMode]) row.value = @1;
        else row.value = @0;
        [section addFormRow:row];
    }
    
    // Section : E2EEncryption From Nextcloud 19 --------------------------------------------------------------

    if (versionServer >= k_nextcloud_version_19_0) {
        
        section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"_e2e_settings_title_", nil)];
        [form addFormSection:section];
        
        // EndToEnd Encryption
        NSString *title = [NSString stringWithFormat:@"%@ (%@)",NSLocalizedString(@"_e2e_settings_", nil), NSLocalizedString(@"_experimental_", nil)];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"e2eEncryption" rowType:XLFormRowDescriptorTypeButton title:title];
        row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundView;
        [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
        [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
        [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"lock"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
        row.action.viewControllerClass = [NCManageEndToEndEncryption class];
        
        [section addFormRow:row];
    }
    
    // Section Advanced -------------------------------------------------
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // Advanced
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"advanced" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"_advanced_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundView;
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"settings"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
    row.action.viewControllerClass = [CCAdvanced class];
    [section addFormRow:row];

    // Section : INFORMATION ------------------------------------------------

    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"_information_", nil)];
    [form addFormSection:section];
    
    // Acknowledgements
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"buttonLeftAligned" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"_acknowledgements_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = NCBrandColor.sharedInstance.backgroundView;
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:@(NSTextAlignmentLeft) forKey:@"textLabel.textAlignment"];
    [row.cellConfig setObject:NCBrandColor.sharedInstance.textView forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"acknowledgements"] width:50 height:50 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
    row.action.formBlock = ^(XLFormRowDescriptor * sender){
        [self performSegueWithIdentifier:@"AcknowledgementsSegue" sender:sender];
        [self deselectFormRow:sender];
    };
    [section addFormRow:row];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.form = form;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // changeTheming
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheming) name:k_notificationCenter_changeTheming object:nil];
    [self changeTheming];
}

- (void)changeTheming
{
    [appDelegate changeTheming:self tableView:self.tableView collectionView:nil form:true];
    [self initializeForm];
    [self reloadForm];
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark === Chiamate dal Form ===
#pragma --------------------------------------------------------------------------------------------

- (void)reloadForm
{
    self.form.delegate = nil;
    
    // ------------------------------------------------------------------

    XLFormRowDescriptor *rowBloccoPasscode = [self.form formRowWithTag:@"bloccopasscode"];
    XLFormRowDescriptor *rowSimplyPasscode = [self.form formRowWithTag:@"simplypasscode"];
    XLFormRowDescriptor *rowOnlyLockDir = [self.form formRowWithTag:@"onlylockdir"];
    XLFormRowDescriptor *rowFavoriteOffline = [self.form formRowWithTag:@"favoriteoffline"];
    XLFormRowDescriptor *rowDarkModeDetect = [self.form formRowWithTag:@"darkModeDetect"];
    XLFormRowDescriptor *rowDarkMode = [self.form formRowWithTag:@"darkMode"];

    // ------------------------------------------------------------------
    
    if ([[CCUtility getBlockCode] length]) {
        rowBloccoPasscode.title = NSLocalizedString(@"_lock_active_", nil);
        [rowBloccoPasscode.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"settingsPasscodeYES"] multiplier:2 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
    } else {
        rowBloccoPasscode.title = NSLocalizedString(@"_lock_not_active_", nil);
        [rowBloccoPasscode.cellConfig setObject:[CCGraphics changeThemingColorImage:[UIImage imageNamed:@"settingsPasscodeNO"] multiplier:2 color:NCBrandColor.sharedInstance.icon] forKey:@"imageView.image"];
    }
    
    if ([CCUtility getSimplyBlockCode]) [rowSimplyPasscode setValue:@1]; else [rowSimplyPasscode setValue:@0];
    if ([CCUtility getOnlyLockDir]) [rowOnlyLockDir setValue:@1]; else [rowOnlyLockDir setValue:@0];
    if ([CCUtility getFavoriteOffline]) [rowFavoriteOffline setValue:@1]; else [rowFavoriteOffline setValue:@0];
    if ([CCUtility getDarkModeDetect]) [rowDarkModeDetect setValue:@1]; else [rowDarkModeDetect setValue:@0];
    if ([CCUtility getDarkMode]) [rowDarkMode setValue:@1]; else [rowDarkMode setValue:@0];

    // -----------------------------------------------------------------
    
    [self.tableView reloadData];
    
    self.form.delegate = self;
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    
    if ([rowDescriptor.tag isEqualToString:@"onlylockdir"]) {
        
        if ([[rowDescriptor.value valueData] boolValue] == YES) {
            [CCUtility setOnlyLockDir:true];
        } else {
            [CCUtility setOnlyLockDir:false];
        }
    }
    
    if ([rowDescriptor.tag isEqualToString:@"favoriteoffline"]) {
        
        if ([[rowDescriptor.value valueData] boolValue] == YES) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"_continue_request_", nil) preferredStyle:UIAlertControllerStyleActionSheet];
            
            [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"_ok_", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [CCUtility setFavoriteOffline:true];
                [self synchronizeFavorites];
            }]];
            
            [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"_cancel_", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self reloadForm];
            }]];
            
            alertController.popoverPresentationController.sourceView = self.view;
            NSIndexPath *indexPath = [self.form indexPathOfFormRow:rowDescriptor];
            CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
            alertController.popoverPresentationController.sourceRect = CGRectOffset(cellRect, -self.tableView.contentOffset.x, -self.tableView.contentOffset.y);
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        } else {
            
            [CCUtility setFavoriteOffline:false];
        }
    }
    
    if ([rowDescriptor.tag isEqualToString:@"darkMode"]) {
        
        if ([[rowDescriptor.value valueData] boolValue] == YES) {
            [CCUtility setDarkMode:true];
        } else {
            [CCUtility setDarkMode:false];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:k_notificationCenter_changeTheming object:nil];
    }
    
    if ([rowDescriptor.tag isEqualToString:@"darkModeDetect"]) {
        
        if ([[rowDescriptor.value valueData] boolValue] == YES) {
            [CCUtility setDarkModeDetect:true];
            // detect Dark Mode
            if (@available(iOS 12.0, *)) {
                appDelegate.preferredUserInterfaceStyle = self.traitCollection.userInterfaceStyle;
                if (appDelegate.preferredUserInterfaceStyle == UIUserInterfaceStyleDark) {
                    [CCUtility setDarkMode:YES];
                } else {
                    [CCUtility setDarkMode:NO];
                }
            }
        } else {
            [CCUtility setDarkModeDetect:false];
            [CCUtility setDarkMode:false];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:k_notificationCenter_changeTheming object:nil];
    }
}

#pragma mark - Passcode -

- (void)didPerformBiometricValidationRequestInPasscodeViewController:(TOPasscodeViewController *)passcodeViewController
{
    [[LAContext new] evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:[[NCBrandOptions sharedInstance] brand] reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
                [CCUtility setBlockCode:@""];
                [passcodeViewController dismissViewControllerAnimated:YES completion:nil];
                [self reloadForm];
            });
        }
    }];
}

- (void)passcodeSettingsViewController:(TOPasscodeSettingsViewController *)passcodeSettingsViewController didChangeToNewPasscode:(NSString *)passcode ofType:(TOPasscodeType)type
{
    [CCUtility setBlockCode:passcode];
    [passcodeSettingsViewController dismissViewControllerAnimated:YES completion:nil];
    
    [self reloadForm];
}

- (void)didTapCancelInPasscodeViewController:(TOPasscodeViewController *)passcodeViewController
{
    [passcodeViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)passcodeViewController:(TOPasscodeViewController *)passcodeViewController isCorrectCode:(NSString *)code
{
    if ([code isEqualToString:[CCUtility getBlockCode]]) {
        [CCUtility setBlockCode:@""];
        [self reloadForm];
        
        return YES;
    }
         
    return NO;
}

- (void)passcode:(XLFormRowDescriptor *)sender
{
    LAContext *laContext = [LAContext new];
    NSError *error;
    
    [self deselectFormRow:sender];

    if ([[CCUtility getBlockCode] length] == 0) {
        
        TOPasscodeSettingsViewController *settingsController = [[TOPasscodeSettingsViewController alloc] init];
        if (@available(iOS 13.0, *)) {
            if ([[UITraitCollection currentTraitCollection] userInterfaceStyle] == UIUserInterfaceStyleDark) {
                settingsController.style = TOPasscodeSettingsViewStyleDark;
            }
        }
        
        settingsController.hideOptionsButton = YES;
        settingsController.requireCurrentPasscode = NO;
        settingsController.passcodeType = TOPasscodeTypeSixDigits;
        settingsController.delegate = self;
        
        [self presentViewController:settingsController animated:YES completion:nil];
        
    } else {
     
        TOPasscodeViewController *passcodeViewController = [[TOPasscodeViewController alloc] initWithStyle:TOPasscodeViewStyleTranslucentLight passcodeType:TOPasscodeTypeSixDigits];
        if (@available(iOS 13.0, *)) {
            if ([[UITraitCollection currentTraitCollection] userInterfaceStyle] == UIUserInterfaceStyleDark) {
                passcodeViewController.style = TOPasscodeViewStyleTranslucentDark;
            }
        }
        
        passcodeViewController.allowCancel = true;
        passcodeViewController.delegate = self;
        passcodeViewController.keypadButtonShowLettering = false;
        
        if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            if (error == NULL) {
                if (laContext.biometryType == LABiometryTypeFaceID) {
                    passcodeViewController.biometryType = TOPasscodeBiometryTypeFaceID;
                    passcodeViewController.allowBiometricValidation = true;
                    passcodeViewController.automaticallyPromptForBiometricValidation = true;
                } else if (laContext.biometryType == LABiometryTypeTouchID) {
                    passcodeViewController.biometryType = TOPasscodeBiometryTypeTouchID;
                    passcodeViewController.allowBiometricValidation = true;
                    passcodeViewController.automaticallyPromptForBiometricValidation = true;
                } else {
                    NSLog(@"No Biometric support");
                }
            }
        }

        [self presentViewController:passcodeViewController animated:YES completion:nil];
    }
}

- (void)synchronizeFavorites
{    
    NSArray *metadatas = [[NCManageDatabase sharedInstance] getMetadatasWithPredicate:[NSPredicate predicateWithFormat:@"account == %@ AND favorite == true", appDelegate.activeAccount]  sorted:nil ascending:NO];
    
    for (tableMetadata *metadata in metadatas) {
        
        if (metadata.directory) {
        
            NSString *serverUrl = [CCUtility stringAppendServerUrl:metadata.serverUrl addFileName:metadata.fileName];
            NSString *serverUrlBeginWith = serverUrl;
            
            if (![serverUrl hasSuffix:@"/"])
                serverUrlBeginWith = [serverUrl stringByAppendingString:@"/"];

            NSArray *directories = [[NCManageDatabase sharedInstance] getTablesDirectoryWithPredicate:[NSPredicate predicateWithFormat:@"account == %@ AND (serverUrl == %@ OR serverUrl BEGINSWITH %@)", appDelegate.activeAccount, serverUrl, serverUrlBeginWith] sorted:@"serverUrl" ascending:true];
            
            for (tableDirectory *directory in directories)
                [[NCManageDatabase sharedInstance] clearDateReadWithServerUrl:directory.serverUrl account:appDelegate.activeAccount];
        } 
    }
    
    [appDelegate.activeFavorites listingFavorites];
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark === Table View ===
#pragma --------------------------------------------------------------------------------------------

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *sectionName;
    
    switch (section)
    {
        case 1: {
            sectionName = NSLocalizedString(@"_favorite_offline_footer_", nil);
        }
        break;
        case 2: {
            sectionName = NSLocalizedString(@"_lock_protection_no_screen_footer_", nil);
        }
        break;
        case 5: {
            
            tableCapabilities *capabilities = [[NCManageDatabase sharedInstance] getCapabilitesWithAccount:appDelegate.activeAccount];
            
            NSString *versionServer = capabilities.versionString;
            
            NSString *versionApp = [NSString stringWithFormat:@"%@.%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
            
            NSString *versionNextcloud = [NSString stringWithFormat:[NCBrandOptions sharedInstance].textCopyrightNextcloudServer, versionServer];
            NSString *versionNextcloudiOS = [NSString stringWithFormat:[NCBrandOptions sharedInstance].textCopyrightNextcloudiOS, versionApp];
            
            NSString *nameSlogan = [NSString stringWithFormat:@"%@ - %@", capabilities.themingName, capabilities.themingSlogan];
            
            sectionName = [NSString stringWithFormat:@"%@\n\n%@\n%@", versionNextcloudiOS, versionNextcloud, nameSlogan];
        }
        break;
    }
    return sectionName;
}

@end
