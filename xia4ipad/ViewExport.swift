//
//  ViewExport.swift
//  xia
//
//  Created by Guillaume on 24/02/2016.
//  Copyright © 2016 Guillaume. All rights reserved.
//

import UIKit

class ViewExport: UIViewController, UIDocumentInteractionControllerDelegate {
    var docController:UIDocumentInteractionController!
    
    let dbg = debug(enable: true)
    
    let documentsDirectory = NSHomeDirectory() + "/Documents"
    
    var filePath: String = ""
    var fileName: String = ""
    var xml: AEXMLDocument = AEXMLDocument()
    var img = UIImage()
    
    var xmlSimpleXML: AEXMLDocument = AEXMLDocument()
    var xmlSVG: AEXMLDocument = AEXMLDocument()
    var tmpFilePath: String = ""
    let now:Int = Int(NSDate().timeIntervalSince1970)
    
    let xmlElements: [String] = ["license", "title", "date", "creator",
        "rights", "publisher", "identifier", "source", "relation", "language",
        "keywords", "coverage", "contributors", "description"
    ]
    
    var counter:Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }

    @IBOutlet var sendingButton: UIButton!
    @IBAction func selectSendingMode(sender: AnyObject) {
        //performSegueWithIdentifier("export", sender: self)
        openDocumentInteractionController(tmpFilePath)
    }

    @IBOutlet var progressView: UIProgressView!
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var imgSimpleXML: UIButton!
    @IBOutlet weak var btnSimpleXML: UIButton!
    @IBAction func exportSimpleXML(sender: AnyObject) {
        progressView.hidden = false
        sendingButton.hidden = true
        
        imgSVG.alpha = 0.5
        btnSVG.alpha = 0.5
        
        imgSimpleXML.alpha = 1
        btnSimpleXML.alpha = 1
        
        self.counter = 5
        // encode image to base64
        let imageData = UIImageJPEGRepresentation(img, 85)
        let base64String = imageData!.base64EncodedStringWithOptions(.Encoding76CharacterLineLength)
        let trimmedBase64String = base64String.stringByReplacingOccurrencesOfString("\n", withString: "")
        
        self.counter = 25
        
        // prepare xml
        xmlSimpleXML.addChild(name: "XiaiPad")
        xmlSimpleXML["XiaiPad"].addChild(xml["xia"])
        xmlSimpleXML["XiaiPad"].addChild(name: "image", value: trimmedBase64String, attributes: nil)
        
        self.counter = 50
        
        // write xml to temp directory
        tmpFilePath = NSHomeDirectory() + "/tmp/\(now).xml"
        do {
            self.counter = 75
            try xmlSimpleXML.xmlString.writeToFile(tmpFilePath, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {
            dbg.pt("\(error)")
        }
        
        openDocumentInteractionController(tmpFilePath)
    }
    
    @IBOutlet var imgSVG: UIButton!
    @IBOutlet var btnSVG: UIButton!
    @IBAction func exportSVG(sender: AnyObject) {
        progressView.hidden = false
        sendingButton.hidden = true
        
        imgSVG.alpha = 1
        btnSVG.alpha = 1
        
        imgSimpleXML.alpha = 0.5
        btnSimpleXML.alpha = 0.5
        self.counter = 5
        // encode image to base64
        let imageData = UIImageJPEGRepresentation(img, 85)
        let base64String = imageData!.base64EncodedStringWithOptions(.Encoding76CharacterLineLength)
        let trimmedBase64String = base64String.stringByReplacingOccurrencesOfString("\n", withString: "")
        
        self.counter = 25
        
        // randomize svg id
        let svgID: UInt32 = arc4random_uniform(8999)
        
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
            "sodipodi:docname" : "\(now).svg"]
        xmlSVG.addChild(name: "svg", value: "", attributes: xmlAttributes)
        

        xmlSVG["svg"].addChild(name: "title", value: getElementValue("title"), attributes: ["id" : "title\(svgID+1)"])
        
        // Metas
        xmlSVG["svg"].addChild(name: "metadata", value: "", attributes: ["id" : "metadata\(svgID+2)"])
        xmlSVG["svg"]["metadata"].addChild(name: "rdf:RDF")
        xmlSVG["svg"]["metadata"]["rdf:RDF"].addChild(name: "cc:Work", value: "", attributes: ["rdf:about" : ""])
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:format", value: "image/svg+xml", attributes: nil)
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:type", value: "", attributes: ["rdf:resource" : "http://purl.org/dc/dcmitype/StillImage"])
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:title", value: getElementValue("title"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:date", value: getElementValue("date"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:creator")
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:creator"].addChild(name: "cc:Agent")
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:creator"]["cc:Agent"].addChild(name: "dc:title", value: getElementValue("creator"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:rights")
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:rights"].addChild(name: "cc:Agent")
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:rights"]["cc:Agent"].addChild(name: "dc:title", value: getElementValue("rights"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:publisher")
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:publisher"].addChild(name: "cc:Agent")
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:publisher"]["cc:Agent"].addChild(name: "dc:title", value: getElementValue("publisher"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:identifier", value: getElementValue("identifier"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:source", value: getElementValue("source"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:relation", value: getElementValue("relation"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:language", value: getElementValue("language"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:subject")
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:subject"].addChild(name: "rdf:Bag")
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:subject"]["rdf:Bag"].addChild(name: "rdf:li", value: getElementValue("keywords"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:coverage", value: getElementValue("coverage"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:description", value: getElementValue("description"), attributes: nil)
        
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "dc:contributor")
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:contributor"].addChild(name: "cc:Agent")
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"]["dc:contributor"]["cc:Agent"].addChild(name: "dc:title", value: getElementValue("contributor"), attributes: nil)
        
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
            xmlSVG["svg"]["metadata"]["rdf:RDF"].addChild(name: "cc:license", value: "", attributes: ["rdf:about" : rdfResource])
            xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/Reproduction"])
            xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/Distribution"])
            xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/Embedding"])
            xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/DerivativeWorks"])
            xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/Notice"])
            xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/Attribution"])
            xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/ShareAlike"])
            xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/DerivativeRenaming"])
            xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:permits", value: "", attributes: ["rdf:resource" : "http://scripts.sil.org/pub/OFL/BundlingWhenSelling"])
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
        xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:Work"].addChild(name: "cc:license", value: "", attributes: ["rdf:resource" : rdfResource])
        if addPermits {
            xmlSVG["svg"]["metadata"]["rdf:RDF"].addChild(name: "cc:license", value: "", attributes: ["rdf:about" : rdfResource])
            for (permit, state) in permits {
                if state != "none" {
                    xmlSVG["svg"]["metadata"]["rdf:RDF"]["cc:license"].addChild(name: "cc:\(state)", value: "", attributes: ["rdf:resource" : "http://creativecommons.org/ns#\(permit)"])
                }
            }
        }
        
        xmlSVG["svg"].addChild(name: "defs", value: "", attributes: ["id" : "defs\(svgID+3)"])
        
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
        xmlSVG["svg"].addChild(name: "sodipodi:namedview", value: "", attributes: sodipodiAttributes)
        
        let imageAttributes = ["width" : "\(img.size.width)",
            "height" : "\(img.size.height)",
            "preserveAspectRatio" : "none",
            "xlink:href" : "data:image/jpeg;base64,\(trimmedBase64String)",
            "id" : "image\(svgID+6)"
        ]
        xmlSVG["svg"].addChild(name: "image", value: "", attributes: imageAttributes)
        
        xmlSVG["svg"]["image"].addChild(name: "desc", value: getElementValue("description"), attributes: ["id" : "desc\(svgID+7)"])
        xmlSVG["svg"]["image"].addChild(name: "title", value: getElementValue("title"), attributes: ["id" : "title\(svgID+8)"])
        
        self.counter = 50
        
        if let xmlDetails = xml.root["details"]["detail"].all {
            let nbDetails = xmlDetails.count
            let offset = nbDetails / 25
            for detail in xmlDetails {
                let path = detail.attributes["path"]
                let pointsArray = path!.characters.split{$0 == " "}.map(String.init)
                
                let currentDetail: AEXMLDocument = AEXMLDocument()
                let detailTitle = (detail.attributes["title"] != nil) ? detail.attributes["title"]! : ""
                let detailDescription = (detail.value != nil) ? detail.value! : ""
                var detailType = "polygon"
                var detailAttributes = [String:String]()
                
                if ( detail.attributes["constraint"] == "rectangle" || detail.attributes["constraint"] == "ellipse" ) {
                    detailType = (detail.attributes["constraint"] == "rectangle") ? "rect" : "ellipse"
                    var originPoint = CGPointMake(CGFloat.max, CGFloat.max)
                    var maxPoint = CGPointMake(0.0, 0.0)
                    
                    for point in pointsArray {
                        let coords = point.characters.split{$0 == ";"}.map(String.init)
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
                        "d" : "M \(path!.stringByReplacingOccurrencesOfString(";", withString: ",")) Z",
                        "inkscape:connector-curvature" : "0"
                    ]
                }
                
                currentDetail.addChild(name: detailType, value: "", attributes: detailAttributes)
                currentDetail[detailType].addChild(name: "desc", value: detailDescription, attributes: ["id" : "desc\(Int(svgID) + Int(detail.attributes["tag"]!)! + 100)"])
                currentDetail[detailType].addChild(name: "title", value: detailTitle, attributes: ["id" : "title\(Int(svgID) + Int(detail.attributes["tag"]!)! + 200)"])
                
                xmlSVG["svg"].addChild(currentDetail[detailType])
                self.counter += offset
            }
        }
        
        // write xml to temp directory
        tmpFilePath = NSHomeDirectory() + "/tmp/\(now).svg"
        do {
            try xmlSVG.xmlString.writeToFile(tmpFilePath, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {
            dbg.pt("\(error)")
        }
        
        self.counter = 80
        
        openDocumentInteractionController(tmpFilePath)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        img = UIImage(contentsOfFile: "\(documentsDirectory)/\(fileName).jpg")!
        
        progressView.setProgress(0, animated: false)
        progressView.hidden = true
        sendingButton.hidden = true
        
    }
    
    // Disable round corners on modal view
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.superview!.layer.cornerRadius  = 0.0
        self.view.superview!.layer.masksToBounds = false
    }
    
    func getElementValue(element: String) -> String {
        if (xml["xia"][element].value != nil && xml["xia"][element].value! != "element <\(element)> not found") {
            return xml["xia"][element].value!
        }
        else {
            return ""
        }
    }
    
    func openDocumentInteractionController(url: String) {
        // Show native export controller
        self.counter = 100
        progressView.hidden = true
        self.counter = 0
        sendingButton.hidden = false
        docController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: url))
        docController.delegate = self
        docController.presentOptionsMenuFromRect(sendingButton.frame, inView:self.view, animated:true)
    }
    
    func documentInteractionControllerDidDismissOptionsMenu(controller: UIDocumentInteractionController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
