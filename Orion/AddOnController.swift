//
//  addOnController.swift
//  Orion
//
//  Created by usman on 07/04/2023.
//

import UIKit
import WebKit
import Zip

class AddOnController: UIViewController {
  private var webView: WKWebView!
  private var addOnPath: URL!
  var unzipDirectory: URL!
  
  var webConfig: WKWebViewConfiguration {
    get {
      let config = WKWebViewConfiguration()
      let userController = WKUserContentController()
      let userScript = getUserScript()
          
      config.setURLSchemeHandler(self, forURLScheme: "customscheme")
      
      userController.add(self, name: "getMostVisitedSites")
      userController.addUserScript(userScript)
      config.userContentController = userController;

      return config
    }
  }
  
  private func getUserScript() -> WKUserScript {
    let scriptSource = """
      window.browser = {
        topSites: {
          get: function() {
            return new Promise(function(resolve, reject) {
              window.webkit.messageHandlers.getMostVisitedSites.postMessage(null);
              window.tempFunction = function(jsonString) {
                delete window.tempFunction;
                resolve(jsonString);
              };
            });
          }
        }
      };
    """
    let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    return script
  }
  
  convenience init(addOnPath: URL) {
    self.init()
    self.addOnPath = addOnPath
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    makeWebView()
    makeCloseButton()
    setupConstraints()
    loadAddOn()
  }
    
  func makeWebView() {
    webView = WKWebView(frame: .zero, configuration: webConfig)
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.navigationDelegate = self
    view.addSubview(webView)
  }
  
  func makeCloseButton() {
    let closeButtonImage = UIImage(systemName: "xmark")
    let closeButton = UIBarButtonItem(image: closeButtonImage, style: .plain, target: self, action: #selector(closeButtonPressed))
    navigationItem.rightBarButtonItem = closeButton
  }
  
  func setupConstraints() {
    let constraints = [
      webView.heightAnchor.constraint(equalTo: view.heightAnchor),
      webView.widthAnchor.constraint(equalTo: view.widthAnchor),
      webView.topAnchor.constraint(equalTo: view.topAnchor),
      webView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
  
  func loadAddOn() {
    do {
      unzipDirectory = try Zip.quickUnzipFile(addOnPath)
      
      let path = unzipDirectory.appendingPathComponent("manifest.json")
      var popPath: String!
      
      do {
        let data = try Data(contentsOf: path)
        if let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let browserAction = jsonResult["browser_action"] as? [String: Any],
           let defaultPopup = browserAction["default_popup"] as? String {
            popPath = defaultPopup
          
          if let title = jsonResult["name"] as? String {
            self.title = title
          }
          
          let htmlPath = unzipDirectory.appendingPathComponent(popPath)
          let url = URL(string: "customscheme://\(htmlPath)")!
          let request = URLRequest(url: url)
          webView.load(request)
        }
      } catch {
        print("Error reading manifest file: \(error.localizedDescription)")
      }
     } catch {
         print("Error unzipping file: \(error.localizedDescription)")
         return
     }
  }
}

extension AddOnController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    decisionHandler(.allow)
  }
}

extension AddOnController: WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    
    if message.name == "getMostVisitedSites" {
      let topSites = getMostVisitedSites()
      let topSitesJson = try? JSONSerialization.data(withJSONObject: topSites, options: [])
      let topSitesJsonString = String(data: topSitesJson!, encoding: .utf8)
      let javascript = "tempFunction(\(topSitesJsonString ?? "[]"))"
      self.webView.evaluateJavaScript(javascript) { _, err in
        if let err = err {
          print(err)
        }
      }
    }
  }
}

extension AddOnController {
  @objc
  func closeButtonPressed() {
    dismiss(animated: true)
  }
  
  func getMostVisitedSites() -> [[String: String]] {
    return BrowserHistory.shared.getTopVisitedUrls()
  }
}

extension AddOnController: WKURLSchemeHandler {
  func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
    guard let url = urlSchemeTask.request.url else {
      return
    }
    
    var path = url.path
    let pathExtension = url.pathExtension
    
    if pathExtension == "js" || pathExtension == "css" {
      path = unzipDirectory.relativePath + path
    }
    
    let localFileUrl = URL(fileURLWithPath: path)
    if let data = try? Data(contentsOf: localFileUrl) {
      let mimeType = getMimeType(pathExtension)
      let response = URLResponse(url: url, mimeType: mimeType, expectedContentLength: data.count, textEncodingName: "utf-8")
      urlSchemeTask.didReceive(response)
      urlSchemeTask.didReceive(data)
      urlSchemeTask.didFinish()
    }
  }
  
  func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
  
  func getMimeType(_ pathExtension: String) -> String {
    switch pathExtension {
    case "html":
      return "text/html"
    case "js":
      return "application/javascript"
    case "css":
      return "text/css"
    default:
      return ""
    }
  }
}




