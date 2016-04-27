//
//  String+AddText.swift
//  MyLocations
//
//  Created by Roman Ustiantcev on 27/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import Foundation

extension String {

    mutating func addText(text: String?, withSeparator separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}