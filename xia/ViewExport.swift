//
//  ViewExport.swift
//  xia
//
//  Created by Guillaume on 24/02/2016.
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
import SSZipArchive

class ViewExport: UITableViewController, UIDocumentInteractionControllerDelegate {
    
    var docController:UIDocumentInteractionController!
    
    var fileName: String = ""
    var xml: AEXMLDocument = AEXMLDocument()
    var img = UIImage()
    
    var xmlSimpleXML: AEXMLDocument = AEXMLDocument()
    var xmlSVG: AEXMLDocument = AEXMLDocument()
    var tmpFilePath: String = ""
    weak var ViewCollection: ViewCollectionController?
    var currentDirs = rootDirs
    var salt = "14876_"
    
    let sectionsElements: [String] = [NSLocalizedString("FILE", comment: ""), NSLocalizedString("DIRECTORY", comment: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if fileName.prefix(salt.count) != salt {
            img = UIImage(contentsOfFile: "\(currentDirs["images"]!)/\(fileName).jpg")!
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let fileCase = (fileName.prefix(salt.count) != salt) ? true : false
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                return fileCase
            case 1:
                return fileCase
            default:
                return false
            }
        case 1:
            return !fileCase
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                exportSimpleXML()
                break
            case 1:
                exportSVG()
                break
            default:
                break
            }
        case 1:
            exportZip()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        returnedView.backgroundColor = selectingColor
        
        let label = UILabel(frame: CGRect(x: 10, y: 2, width: view.frame.size.width, height: 25))
        label.text = sectionsElements[section]
        label.textColor = .black
        returnedView.addSubview(label)
        
        return returnedView
    }
    
    func exportSimpleXML() {
        // encode image to base64
        let imageData = UIImageJPEGRepresentation(img, 85)
        let base64String = imageData!.base64EncodedString(options: .lineLength76Characters)
        let trimmedBase64String: String = base64String.replacingOccurrences(of: "\n", with: "")
        
        // prepare xml
        let _ = xmlSimpleXML.addChild(name: "XiaiPad")
        let _ = xmlSimpleXML["XiaiPad"].addChild(xml["xia"])
        let _ = xmlSimpleXML["XiaiPad"].addChild(name: "image", value: trimmedBase64String)
        
        // write xml to temp directory
        let tmpTitle = cleanInput(getElementValue("title"))
        let tempTitle = (tmpTitle == "") ? fileName : tmpTitle;
        tmpFilePath = NSHomeDirectory() + "/tmp/\(tempTitle).xml"
        do {
            try xmlSimpleXML.xml.write(toFile: tmpFilePath, atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            dbg.pt(error.localizedDescription)
        }
        
        openDocumentInteractionController(tmpFilePath)
    }
    
    func exportSVG() {
       // encode image to base64
        let imageData = UIImageJPEGRepresentation(img, 85)
        let base64String = imageData!.base64EncodedString(options: .lineLength76Characters)
        let trimmedBase64String = base64String.replacingOccurrences(of: "\n", with: "")
        
        // randomize svg id
        let svgID: UInt32 = arc4random_uniform(8999)
        
        let tmpTitle = cleanInput(getElementValue("title"))
        let tempTitle = (tmpTitle == "") ? fileName : tmpTitle;
        
        // prepare xml
        let xmlAttributes = ["xmlns:dc" : "http://purl.org/dc/elements/1.1/",
                             "xmlns:cc" : "http://creativecommons.org/ns#",
                             "xmlns:rdf" : "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                             "xmlns:svg" : "http://www.w3.org/2000/svg",
                             "xmlns" : "http://www.w3.org/2000/svg",
                             "xmlns:xlink" : "http://www.w3.org/1999/xlink",
                             "xmlns:sodipodi" : "http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd",
                             "xmlns:inkscape" : "http://www.inkscape.org/namespaces/inkscape",
                             "id" : "svg\(svgID)",
                             "version" : "1.1",
                             "inkscape:version" : "0.91",
                             "width" : "\(img.size.width)",
                             "height" : "\(img.size.height)",
                             "viewBox" : "0 0 \(img.size.width) \(img.size.height)",
                             "sodipodi:docname" : "\(tempTitle).svg"]
        let _ = xmlSVG.addChild(name: "svg", value: "", attributes: xmlAttributes)
        
        
        let _ = xmlSVG["svg"].addChild(name: "title", value: getElementValue("title"), attributes: ["id" : "title\(svgID+1)"])
        
        // Metas
        let _ = xmlSVG["svg"].addChild(name: "metadata", value: "", attributes: ["id" : "metadata\(svgID+2)"])
        let _ = xmlSVG["svg"]["metadata"].addChild(name: "rdf:RDF")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"].addChild(name: "cc:Work", value: "", attributes: ["rdf:about" : ""])
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:format", value: "image/svg+xml")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:type", value: "", attributes: ["rdf:resource" : "http://purl.org/dc/dcmitype/StillImage"])
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:title", value: getElementValue("title"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:date", value: getElementValue("date"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:creator")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:creator"].addChild(name: "cc:Agent")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:creator"]["cc:Agent"].addChild(name: "dc:title", value: getElementValue("creator"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:rights")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:rights"].addChild(name: "cc:Agent")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:rights"]["cc:Agent"].addChild(name: "dc:title", value: getElementValue("rights"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:publisher")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:publisher"].addChild(name: "cc:Agent")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:publisher"]["cc:Agent"].addChild(name: "dc:title", value: getElementValue("publisher"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:identifier", value: getElementValue("identifier"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:source", value: getElementValue("source"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:relation", value: getElementValue("relation"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:language", value: getElementValue("language"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:subject")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:subject"].addChild(name: "rdf:Bag")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:subject"]["rdf:Bag"].addChild(name: "rdf:li", value: getElementValue("keywords"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:coverage", value: getElementValue("coverage"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:description", value: getElementValue("description"))
        
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:contributor")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:contributor"].addChild(name: "cc:Agent")
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:contributor"]["cc:Agent"].addChild(name: "dc:title", value: getElementValue("contributor"))
        
        let license = getElementValue("license")
        var addPermits: Bool = false
        var permits: [String: String] = [
            "Reproduction" : "none",
            "Distribution" : "none",
            "Notice" : "none",
            "Attribution" : "none",
            "CommercialUse" : "none",
            "DerivativeWorks" : "none",
            "ShareAlike" : "none"
        ]
        var rdfResource: String = ""
        switch license {
        case "Proprietary - CC-Zero":
            rdfResource = ""
            addPermits = false
            break
        case "CC Attribution - CC-BY":
            rdfResource = "http://creativecommons.org/licenses/by/3.0/"
            addPermits = true
            permits["Reproduction"] = "permits"
            permits["Distribution"] = "permits"
            permits["Notice"] = "requires"
            permits["Attribution"] = "requires"
            permits["DerivativeWorks"] = "permits"
            break
        case "CC Attribution-ShareALike - CC-BY-SA":
            rdfResource = "http://creativecommons.org/licenses/by-sa/3.0/"
            addPermits = true
            permits["Reproduction"] = "permits"
            permits["Distribution"] = "permits"
            permits["Notice"] = "requires"
            permits["Attribution"] = "requires"
            permits["DerivativeWorks"] = "permits"
            permits["ShareAlike"] = "requires"
            break
        case "CC Attribution-NoDerivs - CC-BY-ND":
            rdfResource = "http://creativecommons.org/licenses/by-nd/3.0/"
            addPermits = true
            permits["Reproduction"] = "permits"
            permits["Distribution"] = "permits"
            permits["Notice"] = "requires"
            permits["Attribution"] = "requires"
            break
        case "CC Attribution-NonCommercial - CC-BY-NC":
            rdfResource = "http://creativecommons.org/licenses/by-nc/3.0/"
            addPermits = true
            permits["Reproduction"] = "permits"
            permits["Distribution"] = "permits"
            permits["Notice"] = "requires"
            permits["Attribution"] = "requires"
            permits["CommercialUse"] = "prohibits"
            permits["DerivativeWorks"] = "permits"
            break
        case "CC Attribution-NonCommercial-ShareALike - CC-BY-NC-SA":
            rdfResource = "http://creativecommons.org/licenses/by-nc-sa/3.0/"
            addPermits = true
            permits["Reproduction"] = "permits"
            permits["Distribution"] = "permits"
            permits["Notice"] = "requires"
            permits["Attribution"] = "requires"
            permits["CommercialUse"] = "prohibits"
            permits["DerivativeWorks"] = "permits"
            permits["ShareAlike"] = "requires"
            break
        case "CC Attribution-NonCommercial-NoDerivs - CC-BY-NC-ND":
            rdfResource = "http://creativecommons.org/licenses/by-nc-nd/3.0/"
            addPermits = true
            permits["Reproduction"] = "permits"
            permits["Distribution"] = "permits"
            permits["Notice"] = "requires"
            permits["Attribution"] = "requires"
            permits["CommercialUse"] = "prohibits"
            break
        case "CC0 Public Domain Dedication":
            rdfResource = "http://creativecommons.org/publicdomain/zero/1.0/"
            addPermits = true
            permits["Reproduction"] = "permits"
            permits["Distribution"] = "permits"
            permits["DerivativeWorks"] = "permits"
            break
        case "Free Art":
            rdfResource = "http://artlibre.org/licence/lal"
            addPermits = true
            permits["Reproduction"] = "permits"
            permits["Distribution"] = "permits"
            permits["Notice"] = "requires"
            permits["Attribution"] = "requires"
            permits["DerivativeWorks"] = "permits"
            permits["ShareAlike"] = "requires"
            break
        case "Open Font License":
            rdfResource = "http://scripts.sil.org/OFL"
            addPermits = false
            let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"].addChild(name: "cc:license", value: "", attributes: ["rdf:about" : rdfResource])
            let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/Reproduction"])
            let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/Distribution"])
            let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/Embedding"])
            let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/DerivativeWorks"])
            let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/Notice"])
            let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/Attribution"])
            let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/ShareAlike"])
            let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/DerivativeRenaming"])
            let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/BundlingWhenSelling"])
            break
        case "Other":
            rdfResource = ""
            addPermits = false
            break
        default:
            rdfResource = ""
            addPermits = false
            break
        }
        let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "cc:license", value: "", attributes: ["rdf:resource" : rdfResource])
        if addPermits {
            let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"].addChild(name: "cc:license", value: "", attributes: ["rdf:about" : rdfResource])
            for (permit, state) in permits {
                if state != "none" {
                    let _ = xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:\(state)", value: "", attributes: ["rdf:resource" : "http://creativecommons.org/ns#\(permit)"])
                }
            }
        }
        
        let _ = xmlSVG["svg"].addChild(name: "defs", value: "", attributes: ["id" : "defs\(svgID+3)"])
        
        let sodipodiAttributes = ["pagecolor" : "#ffffff",
                                  "bordercolor" : "#666666",
                                  "borderopacity" : "1",
                                  "objecttolerance" : "10",
                                  "gridtolerance" : "10",
                                  "guidetolerance" : "10",
                                  "inkscape:pageopacity" : "0",
                                  "inkscape:pageshadow" : "2",
                                  "inkscape:window-width" : "640",
                                  "inkscape:window-height" : "480",
                                  "id" : "namedview\(svgID+4)",
                                  "showgrid" : "false",
                                  "inkscape:zoom" : "0.25",
                                  "inkscape:cx" : "640",
                                  "inkscape:cy" : "480",
                                  "inkscape:current-layer" : "svg\(svgID+5)"
        ]
        let _ = xmlSVG["svg"].addChild(name: "sodipodi:namedview", value: "", attributes: sodipodiAttributes)
        
        let imageAttributes = ["width" : "\(img.size.width)",
                               "height" : "\(img.size.height)",
                               "preserveAspectRatio" : "none",
                               "xlink:href" : "data:image/jpeg;base64,\(trimmedBase64String)",
                               "id" : "image\(svgID+6)"
        ]
        let _ = xmlSVG["svg"].addChild(name: "image", value: "", attributes: imageAttributes)
        
        let _ = xmlSVG["svg"]["image"].addChild(name: "desc", value: getElementValue("description"), attributes: ["id" : "desc\(svgID+7)"])
        let _ = xmlSVG["svg"]["image"].addChild(name: "title", value: getElementValue("title"), attributes: ["id" : "title\(svgID+8)"])
        
        if let xmlDetails = xml.root["details"]["detail"].all {
            for detail in xmlDetails {
                let path = detail.attributes["path"]
                let pointsArray = path!.split{$0 == " "}.map(String.init)
                
                let currentDetail: AEXMLDocument = AEXMLDocument()
                let detailTitle = (detail.attributes["title"] != nil) ? detail.attributes["title"]! : ""
                let detailDescription = (detail.value != nil) ? detail.value! : ""
                var detailType = constraintPolygon
                var detailAttributes = [String:String]()
                
                if ( detail.attributes["constraint"] == constraintRectangle || detail.attributes["constraint"] == constraintEllipse ) {
                    detailType = (detail.attributes["constraint"] == constraintRectangle) ? "rect" : constraintEllipse
                    var originPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)
                    var maxPoint = CGPoint(x: 0.0, y: 0.0)
                    
                    for point in pointsArray {
                        let coords = point.split{$0 == ";"}.map(String.init)
                        let x = convertStringToCGFloat(coords[0])
                        let y = convertStringToCGFloat(coords[1])
                        if x < originPoint.x {
                            originPoint.x = x
                        }
                        if x > maxPoint.x {
                            maxPoint.x = x
                        }
                        if y < originPoint.y {
                            originPoint.y = y
                        }
                        if y > maxPoint.y {
                            maxPoint.y = y
                        }
                    }
                    let width: CGFloat = maxPoint.x - originPoint.x
                    let height: CGFloat = maxPoint.y - originPoint.y
                    
                    let rectAttributes = ["style" : "opacity:0.3;fill:#ff0000;stroke:#000000;stroke-width:0.1;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1",
                                          "id" : "rect\(Int(svgID) + Int(detail.attributes["tag"]!)!)",
                                          "width" : "\(width)",
                                          "height" : "\(height)",
                                          "x" : "\(originPoint.x)",
                                          "y" : "\(originPoint.y)"
                    ]
                    let ellipseAttributes = ["style" : "opacity:0.3;fill:#ff0000;stroke:#000000;stroke-width:0.1;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1",
                                             "id" : "path\(Int(svgID) + Int(detail.attributes["tag"]!)!)",
                                             "cx" : "\(originPoint.x + width/2)",
                                             "cy" : "\(originPoint.y + height/2)",
                                             "rx" : "\(width/2)",
                                             "ry" : "\(height/2)"
                    ]
                    
                    detailAttributes = (detailType == "rect") ? rectAttributes : ellipseAttributes
                }
                else {
                    detailType = "path"
                    detailAttributes = ["style" : "opacity:0.3;fill:#ff0000;stroke:#000000;stroke-width:0.1;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1",
                                        "id" : "path\(Int(svgID) + Int(detail.attributes["tag"]!)!)",
                                        "d" : "M \(path!.replacingOccurrences(of: ";", with: ",")) Z",
                                        "inkscape:connector-curvature" : "0"
                    ]
                }
                
                let _ = currentDetail.addChild(name: detailType, attributes: detailAttributes)
                let _ = currentDetail[detailType].addChild(name: "desc", value: detailDescription, attributes: ["id" : "desc\(Int(svgID) + Int(detail.attributes["tag"]!)! + 100)"])
                let _ = currentDetail[detailType].addChild(name: "title", value: detailTitle, attributes: ["id" : "title\(Int(svgID) + Int(detail.attributes["tag"]!)! + 200)"])
                
                let _ = xmlSVG["svg"].addChild(currentDetail[detailType])
            }
        }
        
        // write xml to temp directory
        tmpFilePath = NSHomeDirectory() + "/tmp/\(tempTitle).svg"
        do {
            try xmlSVG.xml.write(toFile: tmpFilePath, atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            dbg.pt(error.localizedDescription)
        }
        
        openDocumentInteractionController(tmpFilePath)
    }
    
    func exportZip() {
        let cleanName = fileName.suffix(fileName.count - salt.count)
        tmpFilePath = NSHomeDirectory() + "/tmp/\(cleanName).zip"
        let _ = SSZipArchive.createZipFile(atPath: tmpFilePath, withContentsOfDirectory: "\(currentDirs["root"]!)/\(cleanName)")
        openDocumentInteractionController(tmpFilePath)
        
    }
    
    func getElementValue(_ element: String) -> String {
        if (xml["xia"][element].value != nil && xml["xia"][element].value! != "element <\(element)> not found") {
            return xml["xia"][element].value!
        }
        else {
            return ""
        }
    }
    
    func openDocumentInteractionController(_ url: String) {
        self.preferredContentSize = CGSize(width: 500, height: 600)
        // Show native export controller
        docController = UIDocumentInteractionController(url: URL(fileURLWithPath: url))
        docController.delegate = self
        docController.presentOptionsMenu(from: self.view.frame, in:self.view, animated:true)
    }
    
    func documentInteractionControllerDidDismissOptionsMenu(_ controller: UIDocumentInteractionController) {
        ViewCollection?.buildLeftNavbarItems()
        ViewCollection?.endEdit()
        self.dismiss(animated: true, completion: nil)
    }
}
