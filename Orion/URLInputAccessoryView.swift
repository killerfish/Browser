//
//  URLInputAccessoryView.swift
//  Orion
//
//  Created by usman on 05/04/2023.
// 

import UIKit

class URLInputAccessoryView: UIView {
  let urlTextField = UITextField()
  let cancelButton = UIButton(type: .system)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .customSystemBackground
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configure() {
    urlTextField.translatesAutoresizingMaskIntoConstraints = false
    urlTextField.setAsURLTextField()
    addSubview(urlTextField)
    
    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    cancelButton.setTitle("Cancel", for: .normal)
    addSubview(cancelButton)
    
   let constraints = [
      urlTextField.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
      urlTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75),
      urlTextField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      urlTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
      
      cancelButton.leftAnchor.constraint(equalTo: urlTextField.rightAnchor, constant: 8),
      cancelButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
      cancelButton.centerYAnchor.constraint(equalTo: urlTextField.centerYAnchor)
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
}
