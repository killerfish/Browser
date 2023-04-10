//
//  UITextFieldExtension.swift
//  Orion
//
//  Created by usman on 05/04/2023.
//

import UIKit

extension UITextField {
  func setAsURLTextField() {
    placeholder = "Enter URL"
    text = "http://google.com"
    borderStyle = .roundedRect
    keyboardType = .URL
    autocapitalizationType = .none
    autocorrectionType = .no
    backgroundColor = .white
    returnKeyType = .done
    textAlignment = .center
    clearButtonMode = .whileEditing
  }
}
