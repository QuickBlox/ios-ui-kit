# Overview

The QuickBlox UIKit for iOS is a comprehensive user interface kit specifically designed for building chat applications. It provides a collection of pre-built components, modules, and utilities that simplify the process of creating chat applications.

The main goal of the QuickBlox UIKit for iOS is to offer developers a streamlined and efficient way to implement chat functionality within their iOS applications.

The QuickBlox UIKit for iOS offers modules that encapsulate complex chat functionalities, such as dialogs and chat management and real-time updates. These modules provide a simplified interface for integrating chat features into applications without the need for extensive knowledge of the underlying protocols or server-side infrastructure.

## Features

- QuickBlox UIKit for iOS provides next functionality:
- List of dialogs
- Create dialog(Private or Group)
- Dialog screen
- Send text, image, video, audio, file messages
- Dialog info screen
- List, invite, remove members

# Send your first message

The QuickBlox UIKit for iOS comprises a collection of pre-assembled UI components that enable effortless creation of an in-app chat equipped with all the necessary messaging functionalities. Our development kit encompasses light and dark themes, colors, and various other features. These components can be personalized to fashion an engaging messaging interface that reflects your brand's distinct identity.

The QuickBlox UIKit fully supports both private and group dialogs. To initiate the process of sending a message from the ground up using Java or Kotlin, please refer to the instructions provided in the guide below.

## Requirements

The minimum requirements for QuickBlox UIKit for iOS are:
- iOS 15.0
- Xcode 14

## Before you begin

Register a new account following [this link](https://admin.quickblox.com/signup). Type in your email and password to sign in. You can also sign in with your Google or Github accounts.
Create the app clicking New app button.
Configure the app. Type in the information about your organization into corresponding fields and click Add button.
Go to Dashboard => YOUR_APP => Overview section and copy your Application ID, Authorization Key, Authorization Secret, and Account Key .

## Install QuickBlox UIKit

To add QuickBlox UIKit to your project using SPM, you can follow these steps:

Open your Xcode project and navigate to File > Swift Packages > Add Package Dependency.
In the search bar, enter the QuickBlox UIKit repository URL: https://github.com/QuickBlox/ios-ui-kit.git and click Add Package.
Xcode will then fetch the SDK and you can add it to your project by clicking Add Package.
You can then import QuickBloxUIKit modules into your code and use its API.

```
import QuickBloxUIKit
```

## Init QuickBlox SDK

To init QuickBlox SDK you need to pass Application ID, Authorization Key, Authorization Secret, and Account Key to the initWithApplicationId() method.

```
Quickblox.initWithApplicationId(92, authKey: "wJHdOcQSxXQGWx5", authSecret: "BTFsj7Rtt27DAmT", accountKey: "7yvNe17TnjNUqDoPwfqp")
```

## Authentication

Before sending your first message you need to authenticate users in the QuickBlox system. You can read more about different ways of authentication by [this link](https://docs.quickblox.com/docs/ios-authentication). 
In our example we show how to authenticate user with login and password.

```
QBRequest.logIn(withUserLogin: "userLogin", password: "userPassword", successBlock: { (response, user) in
    // Navigate user to the UIKit
}, errorBlock: { (response) in
    
})
```

## Show UIKit screen

```
struct ShowQuickBlox: View {
    var body: some View {
        QuickBloxUIKit.dialogsView()
    }
}
```

# Customization

The QuickBlox UIKit for iOS allows you to create your own unique view of the UIKit.

## Default themes

The QuickBlox UIKit for iOS by default supports Light and Dark themes, which theme will be applied depending on device settings.

## Use your own theme

You can create and use your own theme. To do this you need to create class that implements QuickBloxUIKit.ThemeColorProtocol

```
class CustomThemeColor: QuickBloxUIKit.ThemeColorProtocol {
    var mainElements: Color = Color("MainElements")
    var secondaryElements: Color = Color("SecondaryElements")
    var tertiaryElements: Color = Color("TertiaryElements")
    var disabledElements: Color = Color("DisabledElements")
    var mainText: Color = Color("MainText")
    var secondaryText: Color = Color("SecondaryText")
    var caption: Color = Color("Caption")
    var mainBackground: Color = Color("MainBackground")
    var secondaryBackground: Color = Color("SecondaryBackground")
    var tertiaryBackground: Color = Color("TertiaryBackground")
    var incomingBackground: Color = Color("IncomingBackground")
    var outgoingBackground: Color = Color("OutgoingBackground")
    var dropdownBackground: Color = Color("DropdownBackground")
    var inputBackground: Color = Color("InputBackground")
    var divider: Color = Color("Divider")
    var error: Color = Color("Error")
    var success: Color = Color("Success")
    var highLight: Color = Color("HighLight")
    var system: Color = Color("System")
    
    init() {}
}
```

And use it later to create your own theme

```
var customTheme: CustomTheme = CustomTheme(color: CustomThemeColor(),
                                   	   font: QuickBloxUIKit.ThemeFont(),
                                           image: QuickBloxUIKit.ThemeImage())
QuickBloxUIKit.settings.theme = customTheme
```

