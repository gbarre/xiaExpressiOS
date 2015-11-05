//
//  Util.swift
//  xia4ipad
//
//  Created by Guillaume on 07/10/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

func createSVG (base64: String, size: CGSize, name: String) -> String {
    let width:Int = Int(size.width)
    let height:Int = Int(size.height)
    
    let svgFile = AEXMLDocument()
    
    // Create root svg with attributes
    let svgAttributes = ["xmlns:dc" : "http://purl.org/dc/elements/1.1/",
        "xmlns:cc" : "http://creativecommons.org/ns#",
        "xmlns:rdf" : "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "xmlns:svg" : "http://www.w3.org/2000/svg",
        "xmlns" : "http://www.w3.org/2000/svg",
        "xmlns:xlink" : "http://www.w3.org/1999/xlink",
        "xmlns:sodipodi" : "http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd",
        "xmlns:inkscape" : "http://www.inkscape.org/namespaces/inkscape",
        "id" : "svg3336",
        "version" : "1.1",
        "inkscape:version" : "0.91 r13725",
        "width" : "\(width)",
        "height" : "\(height)",
        "viewBox" : "0 0 \(width) \(height)",
        "sodipodi:docname" : "\(name).svg"]
    let svg = svgFile.addChild(name: "svg", attributes: svgAttributes)
    
    // Insert default title
    svg.addChild(name: "title", value: "\(name)", attributes: ["id" : "title1"])
    
    // Insert default metadatas
    let metadata = svg.addChild(name: "metadata", value: nil, attributes: ["id" : "metadata1"])
    let rdf = metadata.addChild(name: "rdf:RDF")
    let work = rdf.addChild(name: "cc:work", value: nil, attributes: ["rdf:about" : ""])
    work.addChild(name: "dc:format", value: "image/svg+xml", attributes: nil)
    work.addChild(name: "dc:type", value: nil, attributes: ["rdf:resource" : "http://purl.org/dc/dcmitype/StillImage"])
    work.addChild(name: "dc:title", value: "\(name)", attributes: nil)
    let creator = work.addChild(name: "dc:creator")
    let agent = creator.addChild(name: "cc:agent")
    agent.addChild(name: "dc:title", value: "Author", attributes: nil)
    
    // Insert def
    svg.addChild(name: "def", value: nil, attributes: ["id" : "def1"])
    
    // Insert default inkscape view
    let namedviewAttributes = ["pagecolor" : "#ffffff",
        "bordercolor" : "#666666",
        "borderopacity" : "1",
        "objecttolerance" : "10",
        "gridtolerance" : "10",
        "guidetolerance" : "10",
        "inkscape:pageopacity" : "0",
        "inkscape:pageshadow" : "2",
        "inkscape:window-width" : "640",
        "inkscape:window-height" : "480",
        "id" : "namedview3338",
        "showgrid" : "false",
        "inkscape:zoom" : "0.65",
        "inkscape:cx" : "300",
        "inkscape:cy" : "600",
        "inkscape:window-x" : "800",
        "inkscape:window-y" : "20",
        "inkscape:window-maximized" : "0",
        "inkscape:current-layer " : "svg3336"]
    svg.addChild(name: "sodipodi:namedview", value: nil, attributes: namedviewAttributes)
    
    // Insert background image
    let imageAttributes = ["width" : "\(width)",
        "height" : "\(height)",
        "preserveAspectRatio" : "none",
        "xlink:href" : "data:image/jpeg;base64,\(base64)",
        "id" : "image3344",
        "x" : "0",
        "y" : "0"]
    let image = svg.addChild(name: "image", value: nil, attributes: imageAttributes)
    image.addChild(name: "desc", value: "Default background description", attributes: ["id" : "desc1"])
    image.addChild(name: "title", value: "Default background title", attributes: ["id" : "title2"])
    
    return svgFile.xmlString
}

func addPathInSVG (sourceFile: AEXMLDocument, points: Array<AnyObject>) -> String {
    // make a copy of sourceFile
    let newFile = sourceFile
    
    return newFile.xmlString
}

func cleanBase64Header (source: String) -> String {
    return source.stringByReplacingOccurrencesOfString("data:image/[A-Za-z]+;base64,", withString: "", options: .RegularExpressionSearch, range: nil)
}
