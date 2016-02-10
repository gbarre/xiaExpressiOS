//
//  ViewMetasContainer.swift
//  xia4ipad
//
//  Created by Guillaume on 10/02/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit
var globalXML: AEXMLDocument = AEXMLDocument()
var globalFilePath: String = ""

class ViewMetasContainer: UIViewController {
    
    var xml: AEXMLDocument = AEXMLDocument()
    var filePath: String = ""
    
    override func viewDidLoad() {
        globalXML = xml
        globalFilePath = filePath
    }
}
