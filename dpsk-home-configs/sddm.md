# macOS-like SDDM Theme Configuration

To create an SDDM (Simple Desktop Display Manager) login screen that resembles macOS, you'll need to either modify an existing theme or create a new one. Here's how to configure SDDM to look like the macOS login screen:

Change to downloadable tokyonight-sddm theme

## Option 1: Use an Existing macOS-like Theme

1. Install the `sddm-theme-macos` theme (if available in your distribution's repositories):
   ```bash
   # For Arch Linux
   yay -S sddm-theme-macos

   # For Debian/Ubuntu (if available)
   sudo apt install sddm-theme-macos
   ```

2. Set the theme in SDDM configuration:
   ```bash
   sudo nano /etc/sddm.conf
   ```
   Add or modify these lines:
   ```ini
   [Theme]
   Current=macos
   ```

## Option 2: Create a Custom macOS-like Configuration

If you want to create your own, follow these steps:

1. Create a theme directory:
   ```bash
   sudo mkdir -p /usr/share/sddm/themes/macos-like
   ```

2. Create the theme configuration file:
   ```bash
   sudo nano /usr/share/sddm/themes/macos-like/theme.conf
   ```
   Paste this configuration:
   ```ini
   [General]
   background=background.jpg
   blur-background=true
   blur-radius=100
   dim-background=0.3
   screen-width=1280
   screen-height=720

   [Users]
   avatar-size=100
   avatar-shape=circle
   show-users=true
   user-image=/usr/share/sddm/faces/.face.icon

   [Login]
   background-color=#00000000
   font="SF Pro Display"
   font-size=13
   text-color=#ffffff
   password-color=#ffffff
   password-background-color=#00000000
   password-border-color=#ffffff
   password-border-radius=5
   password-border-width=1

   [Time]
   color=#ffffff
   font="SF Pro Display"
   font-size=48
   alignment=center

   [Power]
   alignment=right
   ```

3. Create a simple QML file for the login screen:
   ```bash
   sudo nano /usr/share/sddm/themes/macos-like/Main.qml
   ```
   Here's a basic QML implementation:
   ```qml
   import QtQuick 2.0
   import QtQuick.Controls 2.0
   import SddmComponents 2.0

   Item {
       anchors.fill: parent

       Rectangle {
           id: background
           anchors.fill: parent
           color: "black"
       }

       Image {
           id: bgImage
           anchors.fill: parent
           source: "background.jpg"
           fillMode: Image.PreserveAspectCrop
       }

       Column {
           anchors.centerIn: parent
           spacing: 20

           Clock {
               id: time
               color: "white"
               font.pixelSize: 48
               font.family: "SF Pro Display"
           }

           UserList {
               id: userList
               width: 200
               height: 300
               userModel: users
               avatarSize: 100
               showAvatars: true
               nameColor: "white"
           }

           TextField {
               id: passwordField
               width: 200
               placeholderText: "Password"
               echoMode: TextInput.Password
               color: "white"
               font.family: "SF Pro Display"
               background: Rectangle {
                   color: "transparent"
                   border.color: "white"
                   radius: 5
               }
           }

           Button {
               id: loginButton
               width: 200
               text: "Login"
               onClicked: sddm.login(userList.currentUser, passwordField.text, sessionModel[sessionIndex].file)
           }
       }
   }
   ```

4. Add a macOS-like background image:
   ```bash
   sudo cp ~/Downloads/macos-background.jpg /usr/share/sddm/themes/macos-like/background.jpg
   ```

5. Set the theme in SDDM configuration:
   ```bash
   sudo nano /etc/sddm.conf
   ```
   Add or modify these lines:
   ```ini
   [Theme]
   Current=macos-like
   ```

## Additional Styling Tips

1. For best results, install Apple's San Francisco font (SF Pro Display):
   ```bash
   # For Arch Linux
   yay -S apple-fonts

   # For Debian/Ubuntu
   sudo apt install fonts-apple
   ```

2. Use a high-quality macOS wallpaper as your background image.

3. For a more authentic look, you might want to:
   - Add a subtle blur effect to the background
   - Include the user profile pictures in circles
   - Center-align all elements
   - Add a semi-transparent overlay

4. Restart SDDM to see your changes:
   ```bash
   sudo systemctl restart sddm
   ```

Remember that creating a perfect macOS clone might require more advanced QML customization, but this configuration will give you a close approximation of the macOS login screen aesthetic.
