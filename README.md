# BetIT-iOS

## Project setup

### Requirements
- Xcode 10.2
- OSX 10.14.0 or later

### Getting Started
#### CocoaPods
This project uses [Cocoapods](https://cocoapods.org) for third-party dependencies management, therefore before opening it you have to make sure you have the latest stable version by running:

    sudo gem install cocoapods

We are also using the [cocoapods-keys](https://github.com/orta/cocoapods-keys) plugin for storing config variables and secret keys securely in each developer's keychain, make sure to have it installed:

    sudo gem install cocoapods-keys

Then cd to the root of the project and run:

    pod install --repo-update
    
Any time a key is missing from your keychain you will be asked for its value. Please ask someone in the team if you don't have access to secret keys.

Now you can open the `betit.xcworkspace` file to run the project in Xcode.

#### SwiftLint
This project uses [SwiftLint](https://github.com/realm/SwiftLint) as a lint / formatter tool.
You can see the errors and warnings of each build right inside Xcode's issue navigator, as the regular ones.
You can either fix them manually or rely on the SwiftLint's autocorrection feature that can be run via the following command `Pods/SwiftLint/swiftlint autocorrect`.
The lint rules are contained in the `.swiftlint.yml` file and should be progressively hardened, the initial version is reasonable enough to start using it without having a huge impact on the codebase.

#### Code style
The code style definition follows [Google's Swift Style Guide](https://google.github.io/swift/) which is a review of the official Apple's Swift standard library style.

## Mobile Branching Process
* [Mobile Branching Process](https://github.com/Majestykapps/BetIT-iOS/wiki/Mobile-Branching-Strategy)

## Release Train Process
* [Release Train Process](https://github.com/Majestykapps/BetIT-iOS/wiki/Mobile-Release-Train-Process)

## Mobile CI Setup
* [Mobile CI Setup](https://github.com/Majestykapps/BetIT-iOS/wiki/Mobile-CI-setup)
