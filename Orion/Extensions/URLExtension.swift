//
//  URLExtension.swift
//  Orion
//
//  Created by usman on 05/04/2023.
//

import UIKit

extension URL {
  func isValid() -> Bool {
    guard let scheme = self.scheme else { return false }
    let allowedSchemes = ["http", "https"]
    if !allowedSchemes.contains(scheme.lowercased()) {
      return false
    }
    
    return UIApplication.shared.canOpenURL(self)
  }
  
  func isMozillaAddonURL() -> Bool {
    guard let host = self.host, host.hasSuffix("addons.mozilla.org") else {
      return false
    }
    
    let pathComponents = self.pathComponents
    if pathComponents.count >= 4, pathComponents[2] == "firefox", pathComponents[3] == "addon" {
      return true
    }

    return false
  }
}
