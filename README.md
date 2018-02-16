## Introduction

The BugsplatMac OS X framework enables posting crash reports from Cocoa applications to Bugsplat. Visit http://www.bugsplat.com for more information and to sign up for an account. 

## 1. Requirements

* BugsplatMac supports OS X 10.7 and later.
* BugsplatMac supports x86_64 applications only.

## 2. Integration

BugsplatMac supports multiple methods for installing the library in a project.

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like BugsplatMac in your projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

#### Podfile

To integrate BugsplatMac into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
target 'TargetName' do
pod 'BugsplatMac'
end
```

Then, run the following command:

```bash
$ pod install
```

The pod install command creates an xcworkspace file next to your application's xcodeproj file. Open the xcworkspace file in lieu of the xcodeproj file to ensure BugsplatMac.framework is included in your build.

### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate BugsplatMac into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "BugsplatGit/BugsplatMac"
```

Run `carthage` to build the framework and drag the built `BugsplatMac.framework` into your Xcode project.

### Manual Setup

To use this library in your project manually you may:  

1. Download the latest release from https://github.com/BugSplatGit/BugsplatMac/releases which is provided as a zip file
2. Unzip the archive and add BugsplatMac.framework to your Xcode project
3. Drag & drop `BugsplatMac.framework` from your window in the `Finder` into your project in Xcode and move it to the desired location in the `Project Navigator`
4. A popup will appear. Select `Create groups for any added folders` and set the checkmark for your target. Then click `Finish`.
5. Configure the framework to be copied into your app bundle:
- Click on your project in the `Project Navigator` (⌘+1).
- Click your target in the project editor.
- Click on the `Build Phases` tab.
- Click the `Add Build Phase` button at the bottom and choose `Add Copy Files`.
- Click the disclosure triangle next to the new build phase.
- Choose `Frameworks` from the Destination list.
- Drag `BugsplatMac` from the Project Navigator left sidebar to the list in the new Copy Files phase.

## 3. Usage

#### Configuration

BugsplatMac requires a few configuration steps in order integrate the framework with your Bugsplat account

1. Add the following key to your app's Info.plist replacing DATABASE_NAME with your BugSplat database name

    ```
    <key>BugsplatServerURL</key>
    <string>https://DATABASE_NAME.bugsplat.com/</string>
    ```

2. You must upload an xcarchive containing your app's binary and symbols to the Bugsplat server in order to symbolicate crash reports.  
    - Create a ~/.bugsplat.conf file to store your Bugsplat credentials

        ```
        BUGSPLAT_USER="<username>"
        BUGSPLAT_PASS="<password>"
        ```    
    - Add the upload-archive.sh script located in `${PROJECT_DIR}/Pods/BugsplatMac/BugsplatMac/Bugsplat.framework/Versions/A/Resources` as an Archive post-action in your build scheme. Set the "Provide build settings from" target in the dropdown so that the `${PROJECT_DIR}` environment variable can be used to locate upload-archive.sh. The script will be invoked when archiving completes which will upload the xcarchive to Bugsplat for processing. You can view the script output in `/tmp/bugsplat-upload.log`.  To share amongst your team, mark the scheme as 'Shared'.

        ![Alt text](/BugsplatTester/post-archive-script.png?raw=true)

#### Initialization
```objc
@import BugsplatMac;
```
```objc
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[BugsplatStartupManager sharedManager] start];
}
```
#### Crash Reporter UI Customization
1. Custom banner image
	- Bugsplat provides the ability to configure a custom image to be displayed in the crash reporter UI for branding purposes.  The image view dimensions are 440x110 and will scale down proportionately. There are 2 ways developers can provide an image:
		1. Set the image property directly on BugsplatStartupManager 
		2. Provide an image named `bugsplat-logo` in the main app bundle or asset calalog

2. User details
	- Set `askUserDetails` to `NO` in order to prevent the name and email fields from displaying in the crash reporter UI 

#### Attachments
1. Bugsplat supports uploading attachments with crash reports. There's a delegate method provided by `BugsplatStartupManagerDelegate` that can be implemented to provide an attachment to be uploaded.

	```objc
	- (BugsplatAttachment *)attachmentForBugsplatStartupManager:(BugsplatStartupManager *)bugsplatStartupManager {
	    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"example" withExtension:@"json"];
	    NSData *data = [NSData dataWithContentsOfURL:fileURL];
	    
	    BugsplatAttachment *attachment = [[BugsplatAttachment alloc] initWithFilename:@"example.json"
	                                                                   attachmentData:data
	                                                                      contentType:@"application/json"];
	    return attachment;
	}
	```	

#### Command line utility support
1. Add "Other Linker Flags" build setting to embed Info.plist

	```
	-sectcreate __TEXT __info_plist "$(SRCROOT)/BugsplatTesterCLI/Info.plist"
	```

2. Add `@executable_path/` to "Runtime Search Paths" build setting
3. Follow main configuration steps listed above, however, use upload-archive-cl.sh for uploading archives
4. Initialize as follows:

	```objc
	[BugsplatStartupManager sharedManager].autoSubmitCrashReport = YES;
	[BugsplatStartupManager sharedManager].askUserDetails = NO;
	[[BugsplatStartupManager sharedManager] start];
	```
5. Given the "Runtime Search Paths" setting change in step 2, be sure any 3rd party dependencies are located in the same directory as the CLI program so they can be found at runtime.
	
## 4. Sample Application

We have provided BugsplatTester as a sample application for you to test BugSplat. The quickest way to test BugSplat is to do the following:

1. Open the BugsplatTester.xcworkspace file. Edit the current scheme and uncheck "Debug executable" in the Run section, close the scheme editor and run the application.

2. Click the "crash" button when prompted.

3. Click the run button a second time in Xcode. The BugSplat crash dialog will appear the next time the app is launched.

4. Fill out the crash dialog and submit the crash report.

5. Visit BugSplat's [All Crash](https://app.bugsplat.com/allcrash/) page. When prompted for credentials enter user "Fred" and password "Flintstone". The crash you posted from BugsplatTester should be at the top of the list of crashes.

6. Click the link in the "Crash Id" column to view more details about your crash.

7. You will notice there are no function names or line numbers, this is because you need to upload the application's xcarchive. See step 2 in the "Configuration" section above for more information.

8. Repeat this process with the executable from the xcarchive you created with BugsplatTester. To find the executable within the xcarchive, right click the xcarchive in finder and select "Show Package Contents". The executable should be located in .../Products/Applications/. BugSplat will display function names and line numbers for all crashes posted from this executable.