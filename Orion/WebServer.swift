//
//  WebServer.swift
//  Orion
//
//  Created by usman on 12/04/2023.
//

import Foundation
import Swifter

class WebServer {
  static let shared = WebServer()
  private let server = HttpServer()
  var unzipDirectory: URL!
  
  private init() {
    server["/*/:filename"] = { request in
      let directoryUrl = self.unzipDirectory.deletingLastPathComponent()
      let fileUrl = directoryUrl.appendingPathComponent(request.path)
      let fileContents = try! String(contentsOf: fileUrl, encoding: .utf8)
      let contentType = request.path.hasSuffix(".js") ? "text/javascript" : "text/css"
        return .raw(200, "OK", ["Content-Type": contentType], { writer in
          try writer.write(fileContents.data(using: .utf8)!)
      })
    }
    
    start()
  }

  func start() {
    do {
      try server.start()
    } catch {
      print("Error starting server: \(error.localizedDescription)")
    }
  }
}
