//
//  Constants.swift
//  xia
//
//  Created by Guillaume on 24/05/2016.
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

let dbg = debug(enable: false)

let xmlElements: [String] = ["title", "description", "creator",
                             "rights", "license", "date", "publisher",
                             "identifier", "source", "relation", "language",
                             "keywords", "coverage", "contributors"
]

let documentsDirectory = NSHomeDirectory() + "/Documents"

let blueColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
let selectingColor = UIColor(red: 255/255, green: 131/255, blue: 0/255, alpha: 1)
let editColor: UIColor = UIColor.redColor()
let noEditColor: UIColor = UIColor.greenColor()

let constraintRectangle = "rectangle"
let constraintEllipse = "ellipse"
let constraintPolygon = "polygon"
