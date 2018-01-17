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

let documentsDirectory: String = NSHomeDirectory() + "/Documents"
let imagesDirectory: String = documentsDirectory + "/images"
let xmlDirectory: String = documentsDirectory + "/xml"
let rootDirs: [String: String] = ["root": documentsDirectory, "images": imagesDirectory, "xml": xmlDirectory]

let dbPath = documentsDirectory + "/oembed.plist"
let importPath = documentsDirectory + "/importFile.xml"

let blueColor = UIColor(red: 0, green: 153/255, blue: 204/255, alpha: 1)
let selectingColor = UIColor(red: 255/255, green: 131/255, blue: 0/255, alpha: 1)
let editColor: UIColor = UIColor.red
let noEditColor: UIColor = UIColor.green

let constraintRectangle = "rectangle"
let constraintEllipse = "ellipse"
let constraintPolygon = "polygon"

let htmlHeader = "<!DOCTYPE html><html>\n" +
    "<head><script type=\"text/javascript\" async src=\"MathJax-2.7.2/MathJax.js?config=TeX-MML-AM_CHTML\"></script></head>\n" +
    "<body style=\"font-size:16pt; text-align:justify;\">"
let htmlFooter = "</body></html>"
