//
//  Util.swift
//  xia4ipad
//
//  Created by Guillaume on 07/10/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

func buildSVG (base64: String, size: CGSize, name: Int) -> String{
    let width:Int = Int(size.width)
    let height:Int = Int(size.height)
    
    var svgParts:String = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n"
    svgParts = svgParts + "<!-- Created with Inkscape (http://www.inkscape.org/) -->\n"
    svgParts = svgParts + "\n"
    svgParts = svgParts + "<svg\n"
    svgParts = svgParts + "xmlns:dc=\"http://purl.org/dc/elements/1.1/\"\n"
    svgParts = svgParts + "xmlns:cc=\"http://creativecommons.org/ns#\"\n"
    svgParts = svgParts + "xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"\n"
    svgParts = svgParts + "xmlns:svg=\"http://www.w3.org/2000/svg\"\n"
    svgParts = svgParts + "xmlns=\"http://www.w3.org/2000/svg\"\n"
    svgParts = svgParts + "xmlns:xlink=\"http://www.w3.org/1999/xlink\"\n"
    svgParts = svgParts + "xmlns:sodipodi=\"http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd\"\n"
    svgParts = svgParts + "xmlns:inkscape=\"http://www.inkscape.org/namespaces/inkscape\"\n"
    svgParts = svgParts + "id=\"svg3371\"\n"
    svgParts = svgParts + "version=\"1.1\"\n"
    svgParts = svgParts + "inkscape:version=\"0.91pre3 r13670\"\n"
    svgParts = svgParts + "width=\"\(width)\"\n"
    svgParts = svgParts + "height=\"\(height)\"\n"
    svgParts = svgParts + "viewBox=\"0 0 \(width) \(height)\"\n"
    svgParts = svgParts + "sodipodi:docname=\"\(name)\">\n"
    svgParts = svgParts + "<metadata\n"
    svgParts = svgParts + "id=\"metadata3377\">\n"
    svgParts = svgParts + "<rdf:RDF>\n"
    svgParts = svgParts + "<cc:Work\n"
    svgParts = svgParts + "rdf:about=\"\">\n"
    svgParts = svgParts + "<dc:format>image/svg+xml</dc:format>\n"
    svgParts = svgParts + "<dc:type\n"
    svgParts = svgParts + "rdf:resource=\"http://purl.org/dc/dcmitype/StillImage\" />\n"
    svgParts = svgParts + "<dc:title></dc:title>\n"
    svgParts = svgParts + "</cc:Work>\n"
    svgParts = svgParts + "</rdf:RDF>\n"
    svgParts = svgParts + "</metadata>\n"
    svgParts = svgParts + "<defs\n"
    svgParts = svgParts + "id=\"defs3375\" />\n"
    svgParts = svgParts + "<sodipodi:namedview\n"
    svgParts = svgParts + "pagecolor=\"#ffffff\"\n"
    svgParts = svgParts + "bordercolor=\"#666666\"\n"
    svgParts = svgParts + "borderopacity=\"1\"\n"
    svgParts = svgParts + "objecttolerance=\"10\"\n"
    svgParts = svgParts + "gridtolerance=\"10\"\n"
    svgParts = svgParts + "guidetolerance=\"10\"\n"
    svgParts = svgParts + "inkscape:pageopacity=\"0\"\n"
    svgParts = svgParts + "inkscape:pageshadow=\"2\"\n"
    svgParts = svgParts + "inkscape:window-width=\"640\"\n"
    svgParts = svgParts + "inkscape:window-height=\"480\"\n"
    svgParts = svgParts + "id=\"namedview3373\"\n"
    svgParts = svgParts + "showgrid=\"false\"\n"
    svgParts = svgParts + "inkscape:zoom=\"0.65065147\"\n"
    svgParts = svgParts + "inkscape:cx=\"909\"\n"
    svgParts = svgParts + "inkscape:cy=\"614\"\n"
    svgParts = svgParts + "inkscape:current-layer=\"svg3371\" />\n"
    svgParts = svgParts + "<image\n"
    svgParts = svgParts + "width=\"\(width)\"\n"
    svgParts = svgParts + "height=\"\(height)\"\n"
    svgParts = svgParts + "preserveAspectRatio=\"none\"\n"
    svgParts = svgParts + "xlink:href=\"data:image/jpeg;base64,\(base64)\n"
    svgParts = svgParts + "\"\n"
    svgParts = svgParts + "id=\"\(name)\"\n"
    svgParts = svgParts + "x=\"0\"\n"
    svgParts = svgParts + "y=\"0\" />\n"
    svgParts = svgParts + "</svg>\n"
    
    return svgParts
}
