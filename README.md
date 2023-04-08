## Orion Browser Project

This is a web browser app created using standard components in Swift, targeting iOS 13.0.

## User Interface

The user interface consists of three main parts: the Base Controller, Page Controller and WebView Controller.

### Base Controller
The Base Controller contains the custom toolbar with four buttons: Navigate Back, Close Tab, Add Tab, Run Top Sites Addon. It is the parent view of the Page Controller.

### Page Controller
The Page Controller is a child view of the Base Controller. It contains an array of WebViewControllers, which can be thought of as tabs. The role of this Controller is to add or remove tabs. 

### WebView Controller
Each WebViewController has a WKWebView and an address bar (with a UITextField).

### Custom Input Bar
There is also a custom input accessory view for the address bar, which displays a textfield above the keyboard.

## Functionality

The app allows users to browse the internet by adding and removing tabs, navigating back, and running the Top Sites Addon. The WKWebView component is used to display web pages in the app.

### Top Sites Addon
If the browser visits https://addons.mozilla.org/en-US/firefox/addon, the user agent is set as Firefox and the "Add to Firefox" button is updated to "Add to Orion" on page load.

If the user taps the "Add to Orion" button, the xpi file is downloaded and renamed to zip. The file is then unzipped to activate the Run TopSites Addon button.

When the user taps the Run TopSites Addon button, a view controller is presented modally. This contains a WKWebView and reads the topsite manifest.json file to get the path to the HTML file for running the extension. The HTML file is then loaded.

Our code is injected into the Javascript file (which is executed by the HTML file), to send messages from JavaScript to Swift, and get the topsites through a function getMostVisitedSites in Swift. This returns the array to the JavaScript code, which loads the result on a modally presented screen with a WKWebView.

## Getting Started

To run the app, clone the repository and open it in Xcode. The app can be run on an iPhone, or on a physical device.

## Challenges

The main challenge was how to inject code in Javascript file to get the results from Swift, which was solved by using WKScriptMessageHandler.

## Screenshots
<img src="https://user-images.githubusercontent.com/1424236/230740732-81b05e1e-35e9-4053-9869-e4a667440621.png" style="margin-right: 10px;" width="20%"><img src="https://user-images.githubusercontent.com/1424236/230740723-9eb4d645-e6ad-4893-a454-4ef6b83d541d.png" width="20%" style="margin-right: 10px;"> <img src="https://user-images.githubusercontent.com/1424236/230740717-dafa4797-55e6-45f6-b09f-554597d53fb3.png" width="20%" style="margin-right: 10px;">
