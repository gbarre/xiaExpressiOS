//
//  debug.swift
//  xia4ipad
//
//  Created by Guillaume on 30/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class debug: NSObject {
    
    var enable: Bool = false
    
    init(enable: Bool){
        self.enable = enable
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pt(obj: AnyObject) {
        if enable {
            print(obj)
        }
    }
    
    func ptSubviews(view: AnyObject) {
        if self.enable {
            print("Subviews of \(view) :")
            for subview in view.subviews {
                print("\(subview)")
            }
        }
    }
    
    func ptLine() {
        if enable {
            print("===============================================================")
        }
    }

}
