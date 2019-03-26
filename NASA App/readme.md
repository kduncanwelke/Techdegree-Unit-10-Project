# Nasa App

This app uses the [NASA API](https://api.nasa.gov/api.html) in order to provide users with a fun and informative way to learn more about our solar system. The **Mars Rover** section allows randomization and search of the full range of photos taken by the three Mars rovers, and allows application of text and filters to a given image, which can be emailed out into the world. The **Earth Satellite Imagery** section provides views of Earth from NASA's satellites. These locations can be selected via map or search, and a user's contacts' locations can also be imported for display.

### 'Exceeds Expectations' Item

The third and additional section allows exploration of the **Astronomy Photo of the Day** provided by NASA. Users can step through the photos day by day, or search for a given day, then see results. This feature incorporates the use of both photo and video display (via web view), as an APOD for a given day can also come in video format.


## Dependencies

[Nuke](https://github.com/kean/Nuke) is used in this project to handle image downloading and display. [Carthage](https://github.com/Carthage/Carthage) has been used as the dependency manager. Please refer to Carthage documentation for installation instructions.

The content of the Cartfile for this project is as follows:

```
github "kean/Nuke" ~> 7.0
``` 

The "Adding frameworks to an application" section in the Carthage documentation provides more explicit instructions for setup than the brief guide offered by Nuke. Simply follow the steps in the "If you're building for iOS, tvOS, or watchOS" section on the Carthage. It explains every step and should make setup easy. 


## Postcard Email Details

The email address the Mars Rover Postcard will be sent to can be set on line 168 of the PostcardViewController. Please change this address to one of your liking in order to receive the postcard. Also please note that email must be tested from a device - the Xcode simulator will not send emails.


## Known Issues

* Leaks caused by bugs in WKWebView can occur in debugging view - a fix for these is as of yet unknown. Upon update to Xcode 10.2 this bug has vanished, but in may be present if the project is viewed in a previous version of Xcode.

* The dateFormatter function on Line 91 in RefineSearchController is causing a leak for unknown reasons. This began with the Xcode 10.2 update, and may have been caused by it. A fix is unknown.

* Certain default contacts contained in the Xcode simulator will result in buggy returns when importing contact addresses into the Earth Satellite Imagery section. If a contact creates a bad response, simply choose another one. Some of the addresses Apple included are non-existent or inaccurate.

* If an extremely small image is imported into the postcard creator from among the Mars Rover photos, the text placed upon it will be difficult to read. This is because the text is set based on image size. It is legible on most images, however, this edge case may still come up. You will recognize the photos this might occur with immediately if you see them, as they are clearly very pixellated.  