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
  
  var webConfig: WKWebViewConfiguration {
    get {
      let config = WKWebViewConfiguration()
      let userController = WKUserContentController()
      userController.add(self, name: "getMostVisitedSites")
      config.userContentController = userController;

      return config
    }
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
      let unzipDirectory = try Zip.quickUnzipFile(addOnPath)
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
          let htmlString = try! String(contentsOf: htmlPath, encoding: .utf8)
          let newHTML = htmlString.replacingOccurrences(of: "\"/popup/", with: "\"")

          let jsPath = unzipDirectory.appendingPathComponent("popup/panel.js")
          let jsScript = try! String(contentsOf: jsPath, encoding: .utf8)
          let modifiedScript = jsScript.replacingOccurrences(of: "var gettingTopSites = browser.topSites.get()", with: "window.webkit.messageHandlers.getMostVisitedSites.postMessage(null);")

          do {
            try modifiedScript.write(to: jsPath, atomically: true, encoding: .utf8)
          } catch {
            print("Error modifiying js script")
          }
          
          webView.loadHTMLString(newHTML, baseURL: htmlPath.deletingLastPathComponent())
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
      getMostVisitedSites { topSites in
        let topSitesJson = try? JSONSerialization.data(withJSONObject: topSites, options: [])
        let topSitesJsonString = String(data: topSitesJson!, encoding: .utf8)
        let javascript = "logTopSites(\(topSitesJsonString ?? "[]"))"
        self.webView.evaluateJavaScript(javascript) { _, err in
          if let err = err {
            print(err) 
          }
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
  
  func getMostVisitedSites(completion: @escaping ([[String: String]]) -> Void) {
    WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
      var counts = [String: Int]()
      
      for record in records where record.dataTypes.contains(WKWebsiteDataTypeCookies) {
        let url = record.displayName
        counts[url, default: 0] += 1
      }
      
      let topCounts = counts.sorted(by: { $0.value > $1.value }).prefix(10)
      let urls = topCounts.compactMap {
        ["url": "http://\($0.key)", "title": "http://\($0.key)"]
      }
      completion(urls)
    }
  }
}

