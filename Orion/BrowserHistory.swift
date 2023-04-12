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
  
  private var history: [String: Int] {
    didSet {
      userDefaults.set(history, forKey: "BrowserHistory")
    }
  }
  
  private init() {
    if let history = userDefaults.dictionary(forKey: "BrowserHistory") as? [String: Int] {
      self.history = history
    } else {
      self.history = [:]
    }
  }
  
  func add(url: String) {
    history[url, default: 1] += 1
  }
  
  func getTopVisitedUrls() -> [[String: String]] {
    let topCounts = history.sorted(by: { $0.value > $1.value }).prefix(10)
    let urls = topCounts.compactMap {
      ["url": "\($0.key)", "title": "\($0.key)"]
    }
    
    return urls
  }
}
