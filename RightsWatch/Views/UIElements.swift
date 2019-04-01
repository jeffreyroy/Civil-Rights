//
//  UIElements.swift
//  RightsWatch
//
//  Created by Jeffrey Roy on 6/29/18.
//  Copyright © 2018 Jeffrey Roy. All rights reserved.
//

import Foundation
import UIKit
import WebKit

// Text field that accepts numerical input
class NumberField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.keyboardType = UIKeyboardType.numberPad
//        fatalError("init(coder:) has not been implemented")
    }
}

class CaseDisplay: WKWebView {
    
}

// Extension to display HTML as formatted text
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

