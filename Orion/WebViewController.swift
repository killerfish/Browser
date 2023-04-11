//
//  WebViewController.swift
//  Orion
//
//  Created by usman on 05/04/2023.
// 

import UIKit
import WebKit
import Zip

class WebViewController: UIViewController {
  private var webView: WKWebView!
  private var urlField: UITextField!
  private var urlInputAccessoryView: URLInputAccessoryView!
  private var addressBar: UIView!
  private var ignoreKeyboardNotification = false

  override func viewDidLoad() {
    super.viewDidLoad()

    makeWebView()
    makeAddressBar()
    makeURLInputAccessoryView()
    makeURLField()
    setupNotifications()
    setupConstraints()
    
    webView.load(URLRequest(url: URL(string: "http://google.com")!))
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func makeWebView() {
    webView = WKWebView()
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.navigationDelegate = self
    view.addSubview(webView)
  }
  
  func makeAddressBar() {
    addressBar = UIView()
    addressBar.translatesAutoresizingMaskIntoConstraints = false
    addressBar.backgroundColor = .customSystemBackground
    view.addSubview(addressBar)
  }
  
  func makeURLInputAccessoryView() {
    urlInputAccessoryView = URLInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 66))
    urlInputAccessoryView.cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
    urlInputAccessoryView.urlTextField.delegate = self
  }
  
  func makeURLField() {
    urlField = UITextField()
    urlField.translatesAutoresizingMaskIntoConstraints = false
    urlField.delegate = self
    urlField.setAsURLTextField()
    urlField.inputAccessoryView = urlInputAccessoryView
    addressBar.addSubview(urlField)
  }
  
  func setupNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
  }
  
  func setupConstraints() {
    let constraints = [
      webView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -66),
      webView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
      webView.topAnchor.constraint(equalTo: view.topAnchor),
      webView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      addressBar.heightAnchor.constraint(equalToConstant: 66),
      addressBar.widthAnchor.constraint(equalTo: view.widthAnchor),
      addressBar.topAnchor.constraint(equalTo: webView.bottomAnchor),
      addressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      urlField.heightAnchor.constraint(equalToConstant: 44),
      urlField.widthAnchor.constraint(equalTo: addressBar.widthAnchor, multiplier: 0.85),
      urlField.centerYAnchor.constraint(equalTo: addressBar.centerYAnchor),
      urlField.centerXAnchor.constraint(equalTo: addressBar.centerXAnchor)
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
}

extension WebViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if navigationAction.navigationType == .linkActivated,
      let downloadURL = navigationAction.request.url,
      downloadURL.pathExtension == "xpi" {

      let downloadTask = URLSession.shared.downloadTask(with: downloadURL) { url, response, error in
        guard let fileURL = url else {
          decisionHandler(.cancel)
          return
        }
        
        let newURL = fileURL.deletingPathExtension().appendingPathExtension("zip")
        let fileManager = FileManager.default
        
        do {
          try fileManager.moveItem(at: fileURL, to: newURL)
          
          let userInfo = ["path": newURL]
          let notification = Notification(name: Notification.Name("AddOnInstalledNotification"), object: nil, userInfo: userInfo)
          NotificationCenter.default.post(notification)
        } catch {
          print("Error renaming file: \(error.localizedDescription)")
          decisionHandler(.cancel)
          return
        }
      }

      downloadTask.resume()
    }
    
    urlField.text = webView.url?.absoluteString
    updateNavigationStatus()
    decisionHandler(.allow)
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    let jsCode = """
      var elements = document.getElementsByClassName("AMInstallButton-button");
      for (var i = 0; i < elements.length; i++) {
        if (elements[i].innerText === "Add to Firefox") {
          elements[i].innerText = "Add to Orion";
        }
      }
    """
    
    webView.evaluateJavaScript(jsCode, completionHandler: nil)
  }
}

extension WebViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == urlInputAccessoryView.urlTextField, let text = textField.text {
      urlField.text = text
      
      if let url = URL(string: text), url.isValid() {
        var request = URLRequest(url: url)
        if url.isMozillaAddonURL() {
          let firefoxUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:96.0) Gecko/20100101 Firefox/96.0"
          webView.customUserAgent = firefoxUserAgent
          request.setValue(firefoxUserAgent, forHTTPHeaderField: "User-Agent")
        }
        
        webView.load(request)
      } else {
        webView.googleSearchURL(for: text)
      }
    }
    
    urlInputAccessoryView.urlTextField.resignFirstResponder()
    urlField.resignFirstResponder()
    ignoreKeyboardNotification = false
    
    return true
  }
}

extension WebViewController {
  func updateNavigationStatus() {
    let userInfo = ["canGoBack": webView.canGoBack]
    let notification = Notification(name: Notification.Name("WebPageNavigationNotification"), object: nil, userInfo: userInfo)
    NotificationCenter.default.post(notification)
  }
  
  func navigateBack() {
    webView.goBack()
  }
  
  @objc
  func keyboardDidShow(_ notification: Notification) {
    if ignoreKeyboardNotification == false {
      urlInputAccessoryView.urlTextField.becomeFirstResponder()
      ignoreKeyboardNotification = true
    }
  }
  
  @objc
  func cancelButtonPressed() {
    urlInputAccessoryView.urlTextField.resignFirstResponder()
    urlField.resignFirstResponder()
  }
}
