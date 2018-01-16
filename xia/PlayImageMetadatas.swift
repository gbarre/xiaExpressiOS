//
//  PlayImageMetadatas.swift
//  xia
//
//  Created by Guillaume on 12/12/2015.
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
import WebKit

class PlayImageMetadatas: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var xml: AEXMLDocument!
    let xmlElementsDict: [String: String?] = [
        "license" : NSLocalizedString("LICENSE", comment: ""),
        "title" : NSLocalizedString("TITLE", comment: ""),
        "date" : NSLocalizedString("DATE", comment: ""),
        "creator" : NSLocalizedString("CREATOR", comment: ""),
        "rights" : NSLocalizedString("RIGHTS", comment: ""),
        "publisher" : NSLocalizedString("PUBLISHER", comment: ""),
        "identifier" : NSLocalizedString("IDENTIFIER", comment: ""),
        "source" : NSLocalizedString("SOURCE", comment: ""),
        "relation" : NSLocalizedString("RELATION", comment: ""),
        "language" : NSLocalizedString("LANGUAGES", comment: ""),
        "keywords" : NSLocalizedString("KEYWORDS", comment: ""),
        "coverage" : NSLocalizedString("COVERAGE", comment: ""),
        "contributors" : NSLocalizedString("CONTRIBUTORS", comment: ""),
        "description" : NSLocalizedString("DESCRIPTION", comment: "")
    ]
    
    var landscape: Bool = true
    let converter: TextConverter = TextConverter(videoWidth: 480, videoHeight: 270)
    
    @IBAction func Hide(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var documentLicense: UILabel!
    @IBOutlet var documentTitle: UILabel!
    @IBOutlet var documentDate: UILabel!
    @IBOutlet var documentCreator: UILabel!
    @IBOutlet var documentRights: UILabel!
    @IBOutlet var documentPublisher: UILabel!
    @IBOutlet var documentIdentifier: UILabel!
    @IBOutlet var documentSource: UILabel!
    @IBOutlet var documentRelation: UILabel!
    @IBOutlet var documentLanguage: UILabel!
    @IBOutlet var documentKeywords: UILabel!
    @IBOutlet var documentCoverage: UILabel!
    @IBOutlet var documentContributors: UILabel!
    @IBOutlet weak var documentDescription: UIView!
    
    override func viewDidLoad() {
        
        documentLicense.attributedText = getLicense()
        documentTitle.text = (xml["xia"]["title"].value != nil && xml["xia"]["title"].value != "element <title> not found") ? xml["xia"]["title"].value! : ""
        documentDate.attributedText = getElementValue("date")
        documentCreator.text = (xml["xia"]["creator"].value != nil && xml["xia"]["creator"].value != "element <creator> not found") ? xml["xia"]["creator"].value! : ""
        documentRights.attributedText = getElementValue("rights")
        documentPublisher.attributedText = getElementValue("publisher")
        documentIdentifier.attributedText = getElementValue("identifier")
        documentSource.attributedText = getElementValue("source")
        documentRelation.attributedText = getElementValue("relation")
        documentLanguage.attributedText = getElementValue("language")
        documentKeywords.attributedText = getElementValue("keywords")
        documentCoverage.attributedText = getElementValue("coverage")
        documentContributors.attributedText = getElementValue("contributors")
        
        var htmlString = (xml["xia"]["description"].value != nil && xml["xia"]["description"].value != "element <description> not found") ? xml["xia"]["description"].value! : ""
        // Build the webView
        if !landscape {
            converter.videoWidth = 360
            converter.videoHeight = 210
        }
        htmlString = converter._text2html(inText: htmlString)
        // show latex, jutify & font-size
        htmlString = "<!DOCTYPE html><html>\n" +
            "<head><script type=\"text/javascript\" async src=\"MathJax-2.7.2/MathJax.js?config=TeX-MML-AM_CHTML\"></script></head>\n" +
            "<body style=\"font-size:16pt; text-align:justify;\">" + htmlString + "</body></html>"
        
        var webView: WKWebView!
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsAirPlayForMediaPlayback = true
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.allowsAirPlayForMediaPlayback = true
        if #available(iOS 10.0, *) {
            webConfiguration.dataDetectorTypes = .all
        }
        
        webView = WKWebView(frame: CGRect(x:0, y:0, width: documentDescription.frame.width, height: documentDescription.frame.height), configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        let bundlePath = Bundle.main.bundlePath
        let baseURL = NSURL.fileURL(withPath: bundlePath)
        
        webView.loadHTMLString(htmlString, baseURL: baseURL)
        documentDescription.addSubview(webView)
        
    }
    
    // Disable round corners on modal view
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.superview!.layer.cornerRadius  = 0.0
        self.view.superview!.layer.masksToBounds = false
    }
    
    func getElementValue(_ element: String) -> NSAttributedString! {
        let key = xmlElementsDict[element]
        let keyWidth = key??.count
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: key!!)
        let txtSize: CGFloat = 14
        attributedText.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: txtSize)], range: NSRange(location: 0, length: keyWidth!))
        
        if (xml["xia"][element].value != nil && xml["xia"][element].value != "element <\(element)> not found") {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: xml["xia"][element].value!)
            attributedText.append(attributedValue)
        }
        
        return attributedText
    }
    
    func getDescriptionValue() -> NSAttributedString! {
        let key = xmlElementsDict["description"]
        let keyWidth = key??.count
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: key!!)
        attributedText.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)], range: NSRange(location: 0, length: keyWidth!))
        
        if (xml["xia"]["description"].value != nil && xml["xia"]["description"].value != "element <description> not found") {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: xml["xia"]["description"].value!)
            attributedText.append(attributedValue)
            let descWidth = xml["xia"]["description"].value!.count
            attributedText.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)], range: NSRange(location: keyWidth!, length: descWidth))

        }
        
        return attributedText
    }
    
    func getLicense() -> NSAttributedString! {
        let key = xmlElementsDict["license"]
        let keyWidth = key!?.count
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: key!!)
        attributedText.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)], range: NSRange(location: 0, length: keyWidth!))
        
        if (xml["xia"]["license"].value != nil && xml["xia"]["license"].value != "element <license> not found") {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: " \(xml["xia"]["license"].value!)")
            attributedText.append(attributedValue)
        }
        else {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: " None")
            attributedText.append(attributedValue)
        }
        
        return attributedText
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            let url = navigationAction.request.url
            let shared = UIApplication.shared
            
            if shared.canOpenURL(url!) {
                shared.openURL(url!)
            }
            
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
    
}
