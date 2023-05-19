//
//  Browser.swift
//  Orion
//
//  Created by usman on 04/04/2023.
// 

import UIKit
import WebKit

class BrowserViewController: UIViewController {
  var webPageTabController: WebPageTabController!
  var backButton: UIBarButtonItem!
  var addTabButton: UIBarButtonItem!
  var closeTabButton: UIBarButtonItem!
  var addOnsButton: UIBarButtonItem!
  var moreOptionsButton: UIBarButtonItem!
  var toolbar: UIToolbar!
  var addOnPath: URL!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    makeToolBar()
    makeToolBarButtons()
    makeWebPageTabController()
    setupConstraints()
    setupNotifications()
  }
  
  func makeToolBar() {
    toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
    toolbar.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toolbar)
  }
  
  func makeToolBarButtons() {
    let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .thin)
    let backButtonImage = UIImage(systemName: "chevron.left", withConfiguration: config)
    backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonPressed))
    backButton.isEnabled = false
    backButton.width = 50
    
    let addTabButtonImage = UIImage(systemName: "plus", withConfiguration: config)
    addTabButton = UIBarButtonItem(image: addTabButtonImage, style: .plain, target: self, action: #selector(addTabButtonPressed))
    
    let closeTabButtonImage = UIImage(systemName: "xmark", withConfiguration: config)
    closeTabButton = UIBarButtonItem(image: closeTabButtonImage, style: .plain, target: self, action: #selector(closeTabButtonPressed))

    let addOnsButtonImage = UIImage(systemName: "paperclip", withConfiguration: config)
    addOnsButton = UIBarButtonItem(image: addOnsButtonImage, style: .plain, target: self, action: #selector(addOnsButtonPressed))
    addOnsButton.isEnabled = false
    
    let moreOptionsButtonImage = UIImage(systemName: "line.3.horizontal.circle", withConfiguration: config)
    moreOptionsButton = UIBarButtonItem(image: moreOptionsButtonImage, style: .plain, target: self, action: #selector(settingsButtonPressed))
    
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    fixedSpace.width = 10
    
    let toolbarButtonItems = [fixedSpace, backButton!, flexibleSpace, closeTabButton!, flexibleSpace, addTabButton!, flexibleSpace, addOnsButton!, flexibleSpace, moreOptionsButton!, fixedSpace]
    toolbar.items = toolbarButtonItems
  }
  
  func makeWebPageTabController() {
    webPageTabController = WebPageTabController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    addChild(webPageTabController)
    view.addSubview(webPageTabController.view)
  }
  
  func setupConstraints() {
    webPageTabController.view.translatesAutoresizingMaskIntoConstraints = false
    
    let constraints = [
      toolbar.heightAnchor.constraint(equalToConstant: 44),
      toolbar.leftAnchor.constraint(equalTo: view.leftAnchor),
      toolbar.rightAnchor.constraint(equalTo: view.rightAnchor),
      toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      
      webPageTabController.view.topAnchor.constraint(equalTo: view.topAnchor),
      webPageTabController.view.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
      webPageTabController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      webPageTabController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
    ]
    
    NSLayoutConstraint.activate(constraints)
    webPageTabController.didMove(toParent: self)
  }
  
  func setupNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: Notification.Name("WebPageNavigationNotification"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(addOnNotification(_:)), name: Notification.Name("AddOnInstalledNotification"), object: nil)
  }
}

extension BrowserViewController {
  @objc
  func addTabButtonPressed() {
    let newTabController = WebViewController()
    webPageTabController.addWebViewController(newTabController)
  }

  @objc
  func backButtonPressed() {
    webPageTabController.goBack()
  }
  
  @objc
  func closeTabButtonPressed() {
    webPageTabController.removeWebViewController()
  }
  
  @objc
  func addOnsButtonPressed() {
    let addOnController = AddOnController(addOnPath: addOnPath)
    let addOnNavController = UINavigationController(rootViewController: addOnController)
    present(addOnNavController, animated: true)
  }
  
  @objc
  func settingsButtonPressed() { }
}

extension BrowserViewController {
  @objc
  func handleNotification(_ notification: Notification) {
    if let userInfo = notification.userInfo,
      let canGoBack = userInfo["canGoBack"] as? Bool {
      backButton.isEnabled = canGoBack
    }
  }
  
  @objc
  func addOnNotification(_ notification: Notification) {
    if let userInfo = notification.userInfo,
      let addOnPath = userInfo["path"] as? URL {
      self.addOnPath = addOnPath
      DispatchQueue.main.async {
        self.addOnsButton.isEnabled = true
        self.addOnsButton.tintColor = .red
      }
    }
  }
}

