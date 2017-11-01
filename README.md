# IFTTT iOS SDK

The IFTTT iOS SDK makes it easy for IFTTT services to embed Applets directly into their iOS app. We provide wrappers and data models for the various endpoints of the [IFTTT API](https://platform.ifttt.com/docs/embedding_applets#ifttt-api). You can use the data returned to display your Applets within your app however you’d like. We’ll also provide web URLs that allow your users to activate Applets.

### Features

**Fetch Applets:**
Fetch your service’s Applets from the IFTTT API in the order you prefer. The SDK doesn’t provide any UI components to use in your app, so it’s up to users of the SDK to use the data provided by the `IFTTTApplet` and `IFTTTService` objects to show users Applets.

**Activate Applets through the web:**
Currently, all Applets need to be activated through the IFTTT website, using a special embedded URL provided by the IFTTT API. Presenting an `SFSafariViewController` is the preferred method for opening these webpages. We strongly recommend redirecting the user to the provided URL through a page on your service that ensures the current user is authenticated in the web session. This will ensure a seamless process for connecting the user to their IFTTT account and activating the Applet.

**Enable/Disable activated Applets:**
Once an Applet is activated (i.e., in the enabled or disabled state), we provide programmatic access to change its status. This allows users to enable or disable one of your Applets without opening a web view.

### Contents

**SDK** (_IFTTTSDK/IFTTTSDK.xcodeproj_)

This is the code you’ll include in your app to connect to the IFTTT API.

**Example App** (_IFTTTSDK Example.xcodeproj_)

This is a barebones iOS app that logs into a simple service and retrieves its Applets. It is included to demonstrate usage of the SDK. Everyone’s codebase is different and every service has a different looking API, so much of it may not apply to your app.

The example service, "IFTTT API Example," is simple: it has no triggers or actions, and its authentication system is passwordless. You can see its code here: https://github.com/ifttt/ifttt-api-example

## Requirements

- Xcode 9 and iOS 11 SDK
- iOS 8.0+ deployment target

## Installing

The easiest way to install the SDK and keep it up to date is using [Cocoapods](https://cocoapods.org). Simply add this line to your `Podfile`.

```ruby
pod 'IFTTTSDK', :git => 'git@github.com:IFTTT/IFTTTSDK-iOS.git'
```

**Note (Nov. 1, 2017):** The git address specified above is included because the pod has not been published to CocoaPods yet. You should remove this line once the pod has been published.

You can also use [Carthage](https://github.com/Carthage/Carthage) or add the Xcode project directly to your project/workspace.

## Setup

Before making any calls to the SDK, make sure you set your service’s slug:

```objc
[[IFTTTAPIManager sharedManager] setServiceSlug:@"ifttt_api_example"];
```

If your service hasn’t been published yet, you should also set its invite code so you can test the flow end-to-end for new users. You can find your invite code under [**Invite URL** on the Service tab](https://platform.ifttt.com/mkt/general) on the IFTTT platform.

```objc
[[IFTTTAPIManager sharedManager] setInviteCode:@"21790-7d53f29b1eaca0bdc5bd6ad24b8f4e1c"];
```

## Authentication

Some operations can be done without user authentication, such as fetching your service’s Applets. However, to get user-specific status (enabled vs. disabled), or to change an activated Applet’s status, you need to provide the IFTTT SDK with an IFTTT user token. You should fetch such a token on your backend service using the ["Get a user token" API](https://platform.ifttt.com/docs/ifttt_api#get-a-user-token). See [here](https://github.com/IFTTT/ifttt-api-example/blob/master/controllers/mobile_api_controller.rb#L39) for the example service’s implementation.

Once you have an IFTTT user token, pass it to the IFTTT SDK:

```objc
#import <IFTTTSDK/IFTTTSDK.h>
...
NSString *token = ...;
[[IFTTTAPIManager sharedManager] setUserToken:token];
```

All future requests will be made with the given token.

If the user logs out, or the IFTTT user token is no longer valid, pass the SDK `nil`:

```objc
[[IFTTTAPIManager sharedManager] setUserToken:nil];
```

## Fetching Applets

### Request

To get the current list of your service’s Applets:

```objc
#import <IFTTTSDK/IFTTTSDK.h>
...
[[IFTTTAPIManager sharedManager] fetchAppletsInOrder:IFTTTOrderTypeDefault
                                            platform:IFTTTPlatformTypeIos
                                          completion:^(NSArray<IFTTTApplet *> * _Nullable applets, NSError * _Nullable error) {
  if (applets) {
    // Store or show Applets to user
  } else if (error) {
    // React to error
  }
}];

```

To use a different ordering, use `IFTTTOrderTypePublishedAtAscending` or `IFTTTOrderTypePublishedAtAscending` for the `order` parameter or their corresponding descending versions.

The platform parameter, described in [the API documentation](https://platform.ifttt.com/docs/ifttt_api#list-applets), should be left as `IFTTTPlatformTypeIos` unless you have a good reason to change it.

### Response

If the request is successful, the completion block will be called with an `NSArray` of `IFTTTApplet` objects in the order requested. Each `IFTTTApplet` has the fields required to display it in your app, including a reference to multiple `IFTTTService` objects through its `primaryService` and `secondaryServices` properties. For example, you might configure your UI element like so:

```objc
  AppletView *appletView = [AppletView new];
  appletView.nameLabel.text = applet.name;
  appletView.backgroundColor = applet.primaryService.brandColor;
  [appletView.iconImageView setImageWithURL: applet.primaryService.colorIconUrl];
  ...
```

If you didn’t provide an IFTTT user token before making the request, all of the `IFTTTApplet` objects will have a `IFTTTAppletStatusUnknown` value for their `status` property.

*Note:* this and all other completion blocks will be called on the main thread.

### Fetching individual Applets

You can also fetch an individual Applet if you know its ID already:

```objc
[[IFTTTAPIManager sharedManager] fetchAppletWithId:applet.identifier completion:^(IFTTTApplet * _Nullable updatedApplet, NSError * _Nullable error) {
    if (updatedApplet) {
        [self updateApplet:updatedApplet atIndex:indexPath.row];
    }
}];
```

In general, we don’t recommend hardcoding Applet IDs into your app’s binary.

## Activating Applets

If an Applet’s status is `IFTTTAppletStatusUnknown` or `IFTTTAppletStatusNeverEnabled`, it can be activated using on the web. For this, we strongly recommend the use of an `SFSafariViewController` on iOS 9+. For iOS 8, you can either use a UIWebView, WKWebView, or Safari.

The URL to open is always fetchable from an `IFTTTApplet` object using the `embeddedUrlWithCallbackUrl:email:userId` method.
- `callbackUrl` (required) is the URL that should return users to your app once the Applet activation process is complete. It must use a [URL scheme registered to your app in your Info.plist](https://developer.apple.com/library/content/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html#//apple_ref/doc/uid/TP40007072-CH6-SW10) and be [registered on the IFTTT platform](https://platform.ifttt.com/services/ifttt_api_example/embedded_redirects) as a valid redirect.

- `email` (optional but encouraged) is the email address of the current user. If you include it, we can try to streamline the process of logging into or signing up for IFTTT by looking for a matching account or prefilling the signup form. We won’t store the address unless the user signs up with it.

- `userId` (required) is the user id of the current user on your service. This will help us ensure that the user is logged into the correct IFTTT account and streamline the process of logging into or signing up for IFTTT.

**IMPORTANT**: We don’t encourage you to open this URL directly. Instead, you should generate (likely in cooperation with your backend service) a URL that will sign in the user to your service in the web session so that connecting your service is simple once they create an IFTTT account.

For example, the service used by the example app [has an authenticated API endpoint](https://github.com/IFTTT/ifttt-api-example/blob/master/controllers/mobile_api_controller.rb#L74-L81) that accepts a `redirect_to` as a URL. It returns a URL that, if opened, sets a session cookie to login the current user, then immediately redirects (with a 302) to the URL specified by `redirect_to`. The example app then opens this URL. When it’s time to connect your service to IFTTT, the user does not then need to sign into their account, but is instead sent straight to the OAuth authorization page.

After the activation flow is complete, the web view will be redirected to the URL you specified in `callbackUrl`. Your app should handle this in your `UIApplicationDelegate`’s `application:openURL:options:` method. At this point, you should close the web view that you opened to activate the Applet. You will probably want to refetch the list of Applets, or at least the Applet that just went through the activation flow, and then update your UI to reflect the new status.

## Enabling/Disabling activated Applets

You can easily update the status of an Applet that has a status of `IFTTTAppletStatusEnabled` or `IFTTTAppletStatusDisabled`. The updated Applet object will be passed into the completion block.

```objc
BOOL newStatus = NO;
[[IFTTTAPIManager sharedManager] setStatus:newStatus
                               forAppletId:applet.identifier
                                completion:^(IFTTTApplet * _Nullable updatedApplet, NSError * _Nullable error) {
    // Do something with updatedApplet
}];
```

## License

The IFTTT iOS SDK is released under the MIT license. See LICENSE for more details.
