#  Purchase NFT SwiftUI - Dreamerly Sample

Purchase NFT is a sample app demonstrating the proper methods for using Dreamerly's SDK. This sample uses only front-end components - no back-end needed.

Sign up for a free Dreamerly account [here](https://www.app.dreamerly.com).

## Requirements

This sample uses:

- SwiftUI
- Xcode 14.0
- iOS 16.0
- Swift 5


## Features

| Feature                          | Sample Project Location                   |
| -------------------------------- | ----------------------------------------- |
| Get Apple product data  | [UI/Screens/NftDetailView](https://github.com/dreamerlyhq/dreamerly-ios-sdk/blob/main/examples/purchase-nft-ios-app/DreamerlyNFT/UI/Screens/NftDetailView/NftDetailView.swift) |
| Purchase product through In-App Purchase         | [UI/Screens/NftDetailView](https://github.com/dreamerlyhq/dreamerly-ios-sdk/blob/main/examples/purchase-nft-ios-app/DreamerlyNFT/UI/Screens/NftDetailView/NftDetailView.swift) |
| Fetch purchase's receipt   | [UI/Screens/NftDetailView](https://github.com/dreamerlyhq/dreamerly-ios-sdk/blob/main/examples/purchase-nft-ios-app/DreamerlyNFT/UI/Screens/NftDetailView/NftDetailView.swift) |
| Create NFT transaction           | [UI/Screens/NftDetailView](https://github.com/dreamerlyhq/dreamerly-ios-sdk/blob/main/examples/purchase-nft-ios-app/DreamerlyNFT/UI/Screens/NftDetailView/NftDetailView.swift) |
| Check NFT transaction status             | [UI/Screens/NftDetailView](https://github.com/dreamerlyhq/dreamerly-ios-sdk/blob/main/examples/purchase-nft-ios-app/DreamerlyNFT/UI/Screens/NftDetailView/NftDetailView.swift) |

## Setup & Run

### Prerequisites
- Be sure to have an [Apple Developer Account](https://developer.apple.com/account/).
    - You must join the [Apple Developer Program](https://developer.apple.com/programs/) to create In-App Purchases.
    - You must sign the [Paid Applications Agreement](https://docs.revenuecat.com/docs/getting-started#3-store-setup) and complete your [bank/tax information](https://docs.revenuecat.com/docs/getting-started#3-store-setup) to test In-App Purchases.
- Be sure to set up a [Sandbox Tester Account](https://help.apple.com/app-store-connect/#/dev8b997bee1) for testing purposes.
- Get your API key from Dreamerly website. If you don't have a Dreamerly account yet, sign up for free [here](https://app.dreamerly.com).
- If you're testing on a simulator instead of a physical device, be sure to set up your [StoreKit configuration files](https://docs.revenuecat.com/docs/apple-app-store#ios-14-only-testing-on-the-simulator).
- Create In App Purchase item in your App Store Connect with the same product Id as iosId in file [NftData](https://github.com/dreamerlyhq/dreamerly-ios-sdk/blob/main/examples/purchase-nft-ios-app/DreamerlyNFT/Models/NftData.swift)

### Steps to Run
1. Open the file `DreamerlyNft.xcworkspace` in Xcode.
2. On the **General** tab of the project editor, match the bundle ID to your bundle ID in App Store Connect.
    
4. On the **Signing & Capabilities** tab of the project editor, select the correct development team from the **Team** dropdown.  
    
5. Build the app and run it on your device. 

### Example Flow: Purchasing a Subscription

1. On the profile page, enter your wallet.
2. On the home page, select an NFT.
3. Tap on Buy button and finish the In-App Purchase flow.
4. Reload the app and reselect the NFT that you have purchase after 2 days to see the information of the NFT that has been minted to your wallet.

## Support

TBD
