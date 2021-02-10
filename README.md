# gps2photos
MacOS app to compliment gp4camera used to interface ExifTool to geotag your photos. This app requires ExifTool to be installed. Download and install instructions can be found here: https://exiftool.org/install.html   

It goes well with gps4camera (https://github.com/rsbauer/gps4camera/ and also availabe in the Apple app store, https://apps.apple.com/us/app/gps4camera/id1517533492), which can generate both the gpx and qr code image to be used with this app, gps2photos.

Using gps4camera and gps2photos together, the workflow would be:  

1. Before taking photos, start gps4camera app and press start on the GPS tab.  gps4camera is now recording your tracks.  
1. In gps4camera, select the Sync tab (this can be done at anytime, even while recording tracks).  The Sync tab will show the current date and time and a changing QR code.  
1. Using the camera you wish to geotag photos with, take a photo of the Sync tab. It is important that the QR code is legible and sharp. The phone screen should fill the camera's view finder as much as possible while still in focus.  Use a high enough shutter speed and ISO to ensure there's no motion blur from the changing QR code or from hand holding the camera.
1. Keep gps4camera recording and go about taking photos

When done taking photos:

1. Stop gps4camera's GPS recording by tapping the stop button
1. Tap the Files tab and locate the date and time of your recent session (should be at the top)
1. Tap the session or swipe it to the left then tap Share
1. From Share, tap GPX
1. Tap a share option. I find email or AirDrop work nicely, but any other method you can access from your computer will do too.
1. Send
1. Load the photos from the camera to the computer. Make sure one of the photos is also the photo with the QR code. 
1. Copy the gpx file from step 5 to the folder/directory the photos were copied to
1. It is highly recommended to make a backup of the photos in case the gps2photos results are not to your liking
1. Start gps2photos
1. Drag the photos and the gpx file to gps2photos (or click the + button to add the folder or photos)
1. If gps2photos detects the gpx file and exiftool, the Geotag Images button will be enabled. Click the Geotag Images button
1. Photos will now be geotagged

Do NOT run the app more than once on the same photos.  Running it a second time will set the photos' date and time off and geotagging will be incorrect.  

### App Features:
* Checks in place for the gpx file and ExifTool
* Ability to have ExifTool generate backups of the photos
* Scan for the QR code image
* Drag and drop

### Project Features:
* SwiftUI

### Screen Shots

<img src="https://raw.githubusercontent.com/rsbauer/gps2photos/master/images/gps2photos-start.png" width="752"> 

### Building - Getting Started

You will need the source code from here and the latest Xcode installed.  

### Prerequisites

Before starting, you will need Cocoapods installed.  

1. Clone this repo

  `git clone [this repo url]`

2. Open the gps2photos.xcworkspace

  `open gps2phtoos.xcworkspace`

3. Build!
