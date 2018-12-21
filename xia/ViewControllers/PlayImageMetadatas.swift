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
        
        documentTitle.text =
            (xml[xmlXiaKey][xmlTitleKey].value != nil &&
                xml[xmlXiaKey][xmlTitleKey].value != String(format: xmlElementNotFound, xmlTitleKey))
            ? xml[xmlXiaKey][xmlTitleKey].value! : emptyString
        
        documentDate.attributedText = getElementValue(dateKey)
        
        documentCreator.text =
            (xml[xmlXiaKey][creatorKey].value != nil &&
                xml[xmlXiaKey][creatorKey].value != String(format: xmlElementNotFound, creatorKey))
            ? xml[xmlXiaKey][creatorKey].value! : emptyString
        
        documentRights.attributedText = getElementValue(rightsKey)
        documentPublisher.attributedText = getElementValue(publisherKey)
        documentIdentifier.attributedText = getElementValue(identifierKey)
        documentSource.attributedText = getElementValue(sourceKey)
        documentRelation.attributedText = getElementValue(relationKey)
        documentLanguage.attributedText = getElementValue(languageKey)
        documentKeywords.attributedText = getElementValue(keywordsKey)
        documentCoverage.attributedText = getElementValue(coverageKey)
        documentContributors.attributedText = getElementValue(contributorsKey)
        
        var htmlString =
            (xml[xmlXiaKey][xmlDescriptionKey].value != nil &&
                xml[xmlXiaKey][xmlDescriptionKey].value != String(format: xmlElementNotFound, xmlDescriptionKey))
                ? xml[xmlXiaKey][xmlDescriptionKey].value! : emptyString
        
        // Build the webView
        if !landscape {
            converter.videoWidth = 360
            converter.videoHeight = 210
        }
        htmlString = converter._text2html(inText: htmlString)
        // show latex, jutify & font-size
        htmlString = htmlHeader + htmlString + htmlFooter
        
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
        
        if (xml[xmlXiaKey][element].value != nil &&
            xml[xmlXiaKey][element].value != String(format: xmlElementNotFound, element)) {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: xml[xmlXiaKey][element].value!)
            attributedText.append(attributedValue)
        }
        
        return attributedText
    }
    
    func getDescriptionValue() -> NSAttributedString! {
        let key = xmlElementsDict[xmlDescriptionKey]
        let keyWidth = key??.count
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: key!!)
        attributedText.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)], range: NSRange(location: 0, length: keyWidth!))
        
        if (xml[xmlXiaKey][xmlDescriptionKey].value != nil &&
            xml[xmlXiaKey][xmlDescriptionKey].value != String(format: xmlElementNotFound, xmlDescriptionKey)) {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: xml[xmlXiaKey][xmlDescriptionKey].value!)
            attributedText.append(attributedValue)
            let descWidth = xml[xmlXiaKey][xmlDescriptionKey].value!.count
            attributedText.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)], range: NSRange(location: keyWidth!, length: descWidth))

        }
        
        return attributedText
    }
    
    func getLicense() -> NSAttributedString! {
        let key = xmlElementsDict[licenseKey]
        let keyWidth = key!?.count
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: key!!)
        attributedText.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)], range: NSRange(location: 0, length: keyWidth!))
        
        if (xml[xmlXiaKey][licenseKey].value != nil &&
            xml[xmlXiaKey][licenseKey].value != String(format: xmlElementNotFound, licenseKey)) {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: String(spaceString + xml[xmlXiaKey][licenseKey].value!))
            attributedText.append(attributedValue)
        }
        else {
            let attributedValue: NSMutableAttributedString = NSMutableAttributedString(string: spaceString + noneString)
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
