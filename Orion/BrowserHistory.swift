//
//  BrowserHistory.swift
//  Orion
//
//  Created by usman on 12/04/2023.
//

import Foundation

class BrowserHistory {
  static let shared = BrowserHistory()
  private let userDefaults = UserDefaults.standard
  
  private var history: [String] {
    didSet {
      userDefaults.set(history, forKey: "BrowserHistory")
    }
  }
  
  private init() {
    if let history = userDefaults.array(forKey: "BrowserHistory") as? [String] {
      self.history = history
    } else {
      self.history = []
    }
  }
  
  func add(url: String) {
    history.removeAll(where: { $0 == url })
    history.insert(url, at: 0)
    if history.count > 100 {
      history.removeLast(history.count - 100)
    }
  }
  
  func get() -> [String] {
    return history
  }
}
