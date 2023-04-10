//
//  WkWebViewExtension.swift
//  Orion
//
//  Created by usman on 05/04/2023.
//

import WebKit

extension WKWebView {
  func googleSearchURL(for searchTerm: String) {
    let searchURLString = "https://www.google.com/search?q=\(searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
    if let url = URL(string: searchURLString) {
      load(URLRequest(url: url))
    }
  }
}
