# KaleyraVideoNoiseFilter

A Swift Package that seamlessly adds noise filter functionality to the KaleyraVideoSDK for iOS.

## Features

✅ Built-in noise suppression for all video calls

✅ Automatic integration with KaleyraVideoSDK

## Installation

To integrate the noise filter into your app:

- Make sure your app already includes KaleyraVideoSDK (v4.5.0 or newer)

- Add this package as a dependency using Swift Package Manager

```swift
.package(url: "https://github.com/KaleyraVideo/KaleyraVideoiOSNoiseFilter.git", branch: "master")
```
That’s it! The noise filter will automatically be active in all calls, with a toggle available in the call settings screen.

## Usage

Once this package is installed alongside your existing KaleyraVideoSDK integration the noise filtering functionality will be automatically available in all calls.

## User Controls

Once installed, users can control the noise filter through the call settings:

- The noise filter toggle will appear in the call settings page
- Users can enable/disable the feature during active calls

## Requirements

- iOS 15.0+

- KaleyraVideoSDK (v4.5.0 or newer) already installed in your project

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
