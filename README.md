<div align="center">

<p>
        <a href="https://discord.gg/Yc56F9KG"><img src="https://img.shields.io/discord/1042743094833065985?color=5865F2&logo=discord&logoColor=white&label=QuickBlox%20Discord%20server&style=for-the-badge" alt="Discord server" /></a>
</p>

</div>

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

## Use your own Color theme

You can create and use your own color theme. To do this you need to create class that implements QuickBloxUIKit.ThemeColorProtocol

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
## Use your own String theme

You can create and use your own string theme. To do this you need to create class that implements QuickBloxUIKit.ThemeStringProtocol

```
public class CustomThemeString: ThemeStringProtocol {
    public var dialogsEmpty: String = String(localized: "dialog.items.empty")
    public var usersEmpty: String = String(localized: "dialog.members.empty")
    public var messegesEmpty: String = String(localized: "dialog.messages.empty")
    
    public var privateDialog: String = String(localized: "dialog.type.private")
    public var groupDialog: String = String(localized: "dialog.type.group")
    public var publicDialog: String = String(localized: "dialog.type.group")
    
    public var typingOne: String = String(localized: "dialog.typing.one")
    public var typingTwo: String = String(localized: "dialog.typing.two")
    public var typingFour: String = String(localized: "dialog.typing.four")
    
    public var enterName: String = String(localized: "alert.actions.enterName")
    public var nameHint: String = String(localized: "dialog.name.hint")
    public var create: String = String(localized: "dialog.name.create")
    public var next: String = String(localized: "dialog.name.next")
    public var search: String = String(localized: "dialog.name.search")
    public var edit: String = String(localized: "dialog.info.edit")
    public var members: String = String(localized: "dialog.info.members")
    public var notification: String = String(localized: "dialog.info.notification")
    public var searchInDialog: String = String(localized: "dialog.info.searchInDialog")
    public var leaveDialog: String = String(localized: "dialog.info.leaveDialog")
    
    public var you: String = String(localized: "dialog.info.you")
    public var admin: String = String(localized: "dialog.info.admin")
    public var typeMessage: String = String(localized: "dialog.action.typeMessage")
    
    public var dialogs: String = String(localized: "screen.title.dialogs")
    public var dialog: String = String(localized: "screen.title.dialog")
    public var dialogType: String = String(localized: "screen.title.dialogType")
    public var newDialog: String = String(localized: "screen.title.newDialog")
    public var createDialog: String = String(localized: "screen.title.createDialog")
    public var addMembers: String = String(localized: "screen.title.addMembers")
    public var dialogInformation: String = String(localized: "screen.title.dialogInformation")
    
    public var add: String = String(localized: "alert.actions.add")
    public var dialogName: String = String(localized: "alert.actions.dialogName")
    public var changeImage: String = String(localized: "alert.actions.changeImage")
    public var changeDialogName: String = String(localized: "alert.actions.changeDialogName")
    
    public var photo: String = String(localized: "alert.actions.photo")
    public var removePhoto: String = String(localized: "alert.actions.removePhoto")
    public var camera: String = String(localized: "alert.actions.camera")
    public var gallery: String = String(localized: "alert.actions.gallery")
    public var file: String = String(localized: "alert.actions.file")
    
    public var remove: String = String(localized: "alert.actions.remove")
    public var cancel: String = String(localized: "alert.actions.cancel")
    public var ok: String = String(localized: "alert.actions.ok")
    public var removeUser: String = String(localized: "alert.message.removeUser")
    public var questionMark: String = String(localized: "alert.message.questionMark")
    public var errorValidation: String = String(localized: "alert.message.errorValidation")
    public var addUser: String = String(localized: "alert.message.addUser")
    public var toDialog: String = String(localized: "alert.message.toDialog")
    
    public var maxSize: String = String(localized: "attachment.maxSize.title")
    public var maxSizeHint: String = String(localized: "attachment.maxSize.hint")
    public var fileTitle: String  = String(localized: "attachment.title.file")
    public var gif: String = String(localized: "attachment.title.gif")
    
    public init() {}
}
```
with such default strings:

```
"dialog.items.empty" = "You don’t have any dialogs.";
"dialog.members.empty" = "You don’t have any users.";
"dialog.messages.empty" = "You don’t have any messages.";
"dialog.type.private" = "Private";
"dialog.type.group" = "Group";
"dialog.type.public" = "Public";
"dialog.typing.one" = " is typing...";
"dialog.typing.two" = " are typing...";
"dialog.typing.four" = " and 2 others are typing...";
"dialog.name.hint" = "Use alphanumeric characters and spaces in a range from 3 to 60. Cannot contain more than one space in a row.";
"dialog.name.create" = "Create";
"dialog.name.next" = "Next";
"dialog.name.search" = "Search";
"dialog.name.cancel" = "Cancel";
"dialog.info.edit" = "Edit";
"dialog.info.members" = "Members";
"dialog.info.notification" = "Notification";
"dialog.info.searchInDialog" = "Search in dialog";
"dialog.info.leaveDialog" = "Leave dialog";
"dialog.info.you" = " (You)";
"dialog.info.admin" = "Admin";
"dialog.action.typeMessage" = "Type message";

"screen.title.dialogs" = "Dialogs";
"screen.title.dialog" = "Dialog";
"screen.title.dialogType" = "Dialog type";
"screen.title.newDialog" = "New Dialog";
"screen.title.createDialog" = "Create Dialog";
"screen.title.addMembers" = "Add Members";
"screen.title.dialogInformation" = "Dialog information";

"alert.actions.add" = "Add";
"alert.actions.dialogName" = "Dialog name";
"alert.actions.enterName" = "Enter name";
"alert.actions.changeImage" = "Change image";
"alert.actions.changeDialogName" = "Change dialog name";
"alert.actions.photo" = "Photo";
"alert.actions.removePhoto" = "Remove photo";
"alert.actions.camera" = "Camera";
"alert.actions.gallery" = "Gallery";
"alert.actions.file" = "File";
"alert.actions.remove" = "Remove";
"alert.actions.cancel" = "Cancel";
"alert.actions.ok" = "Ok";
"alert.message.removeUser" = "Are you sure you want to remove ";
"alert.message.questionMark" = "?";
"alert.message.errorValidation" = "Error Validation";
"alert.message.addUser" = "Are you sure you want to add ";
"alert.message.toDialog" = " to this dialog?";

"attachment.maxSize.title" = "The uploaded file exceeds maximum file size (10MB)";
"attachment.maxSize.hint" = "Please select a smaller attachment.";
"attachment.title.file" = "file";
"attachment.title.gif" = "GIF";
```

#### Use Localization to expand the capabilities of your application.

For custom localization, customize your application by adding the necessary localization files. You can learn more about how to do this at the [Apple Documentation](https://developer.apple.com/documentation/xcode/localization).

1. Copy and add to the localization file in your project the necessary string constants from QuickBlox iOS UI Kit. If you do not have a localization file yet, then create it following the guide from [Apple Documentation](https://developer.apple.com/documentation/xcode/localization).
2. [Customize](https://docs.quickblox.com/docs/ios-uikit-customization#use-your-own-string-theme) these constants as you need for your purposes.
3. Create and add the necessary localization files to your project

 For example, add a localization file for Spanish to your project:
 
``` 
"dialog.items.empty" = "No tiene ningún cuadro de diálogo.";
"dialog.members.empty" = "No tiene ningún usuario.";
"dialog.messages.empty" = "No tiene ningún mensaje.";
"dialog.type.private" = "Privado";
"dialog.type.group" = "Grupo";
"dialog.type.public" = "Público";
"dialog.typing.one" = " está escribiendo...";
"dialog.typing.two" = " están escribiendo...";
"dialog.typing.four" = " y otros 2 están escribiendo...";
"dialog.name.hint" = "Use caracteres alfanuméricos y espacios en un rango de 3 a 60. No puede contener más de un espacio en una fila.";
"dialog.name.create" = "Crear";
"dialog.name.next" = "Siguiente";
"dialog.name.search" = "Buscar";
"dialog.name.cancel" = "Cancelar";
"dialog.info.edit" = "Editar";
"dialog.info.members" = "Miembros";
"dialog.info.notification" = "Notificación";
"dialog.info.searchInDialog" = "Buscar en diálogo";
"dialog.info.leaveDialog" = "Salir del cuadro de diálogo";
"dialog.info.you" = " (usted)";
"dialog.info.admin" = "Admin";
"dialog.action.typeMessage" = "Escribir mensaje";

"screen.title.dialogs" = "Diálogos";
"screen.title.dialog" = "Diálogo";
"screen.title.dialogType" = "Tipo de diálogo";
"screen.title.newDialog" = "Diálogo nuevo";
"screen.title.createDialog" = "Crear diálogo";
"screen.title.addMembers" = "Agregar miembros";
"screen.title.dialogInformation" = "Información de diálogo";

"alert.actions.add" = "Agregar";
"alert.actions.dialogName" = "Nombre del diálogo";
"alert.actions.enterName" = "Ingrese el nombre";
"alert.actions.changeImage" = "Cambiar imagen";
"alert.actions.changeDialogName" = "Cambiar nombre de diálogo";
"alert.actions.photo" = "Foto";
"alert.actions.removePhoto" = "Eliminar foto";
"alert.actions.camera" = "Cámara";
"alert.actions.gallery" = "Galería";
"alert.actions.file" = "Archivo";
"alert.actions.remove" = "Eliminar";
"alert.actions.cancel" = "Cancelar";
"alert.actions.ok" = "Ok";
"alert.message.removeUser" = "¿Está seguro de que desea eliminar ";
"alert.message.questionMark" = "?";
"alert.message.errorValidation" = "Error de validación";
"alert.message.addUser" = "¿Está seguro de que desea agregar ";
"alert.message.toDialog" = "¿a este cuadro de diálogo?";

"attachment.maxSize.title" = "El archivo cargado supera el tamaño máximo de archivo (10 MB)";
"attachment.maxSize.hint" = "Seleccione un archivo adjunto más pequeño.";
"attachment.title.file" = "archivo";
"attachment.title.gif" = "GIF";
```


And use it later to create your own theme

```
var customTheme: CustomTheme = CustomTheme(color: CustomThemeColor(),
                                      font: QuickBloxUIKit.ThemeFont(),
                                      image: QuickBloxUIKit.ThemeImage(),
                                      string: CustomThemeString())
                                      
QuickBloxUIKit.settings.theme = customTheme
```

