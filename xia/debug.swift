//
//  debug.swift
//  xia4ipad
//
//  Created by Guillaume on 30/11/2015.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//
//
//  @author : guillaume.barre@ac-versailles.fr
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
