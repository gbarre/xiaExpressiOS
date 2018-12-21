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
    
    var fileName: String = emptyString
    var xml: AEXMLDocument = AEXMLDocument()
    var img = UIImage()
    
    var xmlSimpleXML: AEXMLDocument = AEXMLDocument()
    var xmlSVG: AEXMLDocument = AEXMLDocument()
    var tmpFilePath: String = emptyString
    weak var ViewCollection: ViewCollectionController?
    var currentDirs = rootDirs
    var salt = defaultSalt
    
    let sectionsElements: [String] = [NSLocalizedString(fileKey, comment: emptyString), NSLocalizedString(directoryKey, comment: emptyString)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if fileName.prefix(salt.count) != salt {
            img = UIImage(contentsOfFile: currentDirs[imagesString]! + separatorString + fileName + jpgExtension)!
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = sectionsElements[section]
        return title.firstUppercased
    }
    
    func exportSimpleXML() {
        // encode image to base64
        let imageData = UIImageJPEGRepresentation(img, 85)
        let base64String = imageData!.base64EncodedString(options: .lineLength76Characters)
        let trimmedBase64String: String = base64String.replacingOccurrences(of: htmlBreakLineString, with: emptyString)
        
        // prepare xml
        let _ = xmlSimpleXML.addChild(name: xmlXiaIPadKey)
        let _ = xmlSimpleXML[xmlXiaIPadKey].addChild(xml[xmlXiaKey])
        let _ = xmlSimpleXML[xmlXiaIPadKey].addChild(name: xmlImageKey, value: trimmedBase64String)
        
        // write xml to temp directory
        let tmpTitle = cleanInput(getElementValue(titleKey))
        let tempTitle = (tmpTitle == emptyString) ? fileName : tmpTitle;
        tmpFilePath = NSHomeDirectory() + separatorString + tmpString + separatorString + tempTitle + xmlExtension
        do {
            try xmlSimpleXML.xml.write(toFile: tmpFilePath, atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            debugPrint(error.localizedDescription)
        }
        
        openDocumentInteractionController(tmpFilePath)
    }
    
    func exportSVG() {
       // encode image to base64
        let imageData = UIImageJPEGRepresentation(img, 85)
        let base64String = imageData!.base64EncodedString(options: .lineLength76Characters)
        let trimmedBase64String = base64String.replacingOccurrences(of: htmlBreakLineString, with: emptyString)
        
        // randomize svg id
        let svgID: UInt32 = arc4random_uniform(8999)
        
        let tmpTitle = cleanInput(getElementValue(titleKey))
        let tempTitle = (tmpTitle == emptyString) ? fileName : tmpTitle;
        
        // prepare xml
        var xmlAttributes = xmlDefaultAttributes
        xmlAttributes[svgIdKey] = svgString + String(svgID)
        xmlAttributes[widthKey] = img.size.width.toString
        xmlAttributes[heightKey] = img.size.height.toString
        xmlAttributes[svgViewBoxKey] = zeroSpaceString + zeroSpaceString + img.size.width.toString + spaceString + img.size.height.toString
        xmlAttributes[svgSodipodiDocnameKey] = tempTitle + svgExtension
        
        let _ = xmlSVG.addChild(name: svgString, value: emptyString, attributes: xmlAttributes)
        
        
        let _ = xmlSVG[svgRootKey].addChild(name: titleKey, value: getElementValue(titleKey), attributes: [svgIdKey : titleKey + String(svgID+1)])
        
        // Metas
        let _ = xmlSVG[svgRootKey].addChild(name: svgMetaDataKey, value: emptyString, attributes: [svgIdKey : svgMetaDataKey + String(svgID+2)])
        let _ = xmlSVG[svgRootKey][svgMetaDataKey].addChild(name: svgRDFKey)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey].addChild(name: svgCcWorkKey, value: emptyString, attributes: [svgRdfAboutKey : emptyString])
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcFormatKey, value: imgSvgXmlString)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcTypeKey, value: emptyString, attributes: dcTypeAttribute)
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcTitleKey, value: getElementValue(titleKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcDateKey, value: getElementValue(dateKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcCreatorKey)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey][svgDcCreatorKey].addChild(name: svgCcAgentKey)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey][svgDcCreatorKey][svgCcAgentKey].addChild(name: svgDcTitleKey, value: getElementValue(creatorKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcRightKey)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey][svgDcRightKey].addChild(name: svgCcAgentKey)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey][svgDcRightKey][svgCcAgentKey].addChild(name: svgDcTitleKey, value: getElementValue(rightsKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcPublisherKey)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey][svgDcPublisherKey].addChild(name: svgCcAgentKey)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey][svgDcPublisherKey][svgCcAgentKey].addChild(name: svgDcTitleKey, value: getElementValue(publisherKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcIdentifierKey, value: getElementValue(identifierKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcSourceKey, value: getElementValue(sourceKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcRelationKey, value: getElementValue(relationKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcLanguageKey, value: getElementValue(languageKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcSubjectKey)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey][svgDcSubjectKey].addChild(name: svgRdfBagKey)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey][svgDcSubjectKey][svgRdfBagKey].addChild(name: svgRdfLiKey, value: getElementValue(keywordsKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcCoverageKey, value: getElementValue(coverageKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcDescriptionKey, value: getElementValue(descriptionKey))
        
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgDcContributorKey)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey][svgDcContributorKey].addChild(name: svgCcAgentKey)
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey][svgDcContributorKey][svgCcAgentKey].addChild(name: svgDcTitleKey, value: getElementValue(contributorsKey))
        
        let license = getElementValue(licenseKey)
        var addPermits: Bool = false
        var permits = svgDefaultLicensePermits
        
        var rdfResource: String = emptyString
        switch license {
        case svgLicenseProprietaryKey:
            rdfResource = emptyString
            addPermits = false
            break
        case svgLicenseCCBYKey:
            rdfResource = urlCCBY
            addPermits = true
            permits[svgReproductionKey] = permitsString
            permits[svgDistributionKey] = permitsString
            permits[svgNoticeKey] = requiresString
            permits[svgAttributionKey] = requiresString
            permits[svgDerivativeWorksKey] = permitsString
            break
        case svgLicenseCCBYSAKey:
            rdfResource = urlCCBYSA
            addPermits = true
            permits[svgReproductionKey] = permitsString
            permits[svgDistributionKey] = permitsString
            permits[svgNoticeKey] = requiresString
            permits[svgAttributionKey] = requiresString
            permits[svgDerivativeWorksKey] = permitsString
            permits[svgShareAlikeKey] = requiresString
            break
        case svgLicenseCCBYNDKey:
            rdfResource = urlCCBYND
            addPermits = true
            permits[svgReproductionKey] = permitsString
            permits[svgDistributionKey] = permitsString
            permits[svgNoticeKey] = requiresString
            permits[svgAttributionKey] = requiresString
            break
        case svgLicenseCCBYNCKey:
            rdfResource = urlCCBYNC
            addPermits = true
            permits[svgReproductionKey] = permitsString
            permits[svgDistributionKey] = permitsString
            permits[svgNoticeKey] = requiresString
            permits[svgAttributionKey] = requiresString
            permits[svgCommercialUseKey] = prohibitsString
            permits[svgDerivativeWorksKey] = permitsString
            break
        case svgLicenseCCBYNCSAKey:
            rdfResource = urlCCBYNCSA
            addPermits = true
            permits[svgReproductionKey] = permitsString
            permits[svgDistributionKey] = permitsString
            permits[svgNoticeKey] = requiresString
            permits[svgAttributionKey] = requiresString
            permits[svgCommercialUseKey] = prohibitsString
            permits[svgDerivativeWorksKey] = permitsString
            permits[svgShareAlikeKey] = requiresString
            break
        case svgLicenseCCBYNCNDKey:
            rdfResource = urlCCBYNCNS
            addPermits = true
            permits[svgReproductionKey] = permitsString
            permits[svgDistributionKey] = permitsString
            permits[svgNoticeKey] = requiresString
            permits[svgAttributionKey] = requiresString
            permits[svgCommercialUseKey] = prohibitsString
            break
        case svgLicenceCC0Key:
            rdfResource = urlPublicDomain
            addPermits = true
            permits[svgReproductionKey] = permitsString
            permits[svgDistributionKey] = permitsString
            permits[svgDerivativeWorksKey] = permitsString
            break
        case svgLicenceFreeArtKey:
            rdfResource = urlFreeArt
            addPermits = true
            permits[svgReproductionKey] = permitsString
            permits[svgDistributionKey] = permitsString
            permits[svgNoticeKey] = requiresString
            permits[svgAttributionKey] = requiresString
            permits[svgDerivativeWorksKey] = permitsString
            permits[svgShareAlikeKey] = requiresString
            break
        case svgLicenseOFLKey:
            rdfResource = urlOFL
            addPermits = false
            let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey].addChild(name: svgCcLicenseKey, value: emptyString, attributes: [svgRdfAboutKey : rdfResource])
            let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcLicenseKey].addChild(
                name: svgCcPermitsKey,
                value: emptyString,
                attributes: [svgRdfResourceKey : urlOFL + separatorString + svgReproductionKey]
            )
            let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcLicenseKey].addChild(
                name: svgCcPermitsKey,
                value: emptyString,
                attributes: [svgRdfResourceKey : urlOFL + separatorString + svgDistributionKey]
            )
            let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcLicenseKey].addChild(
                name: svgCcPermitsKey,
                value: emptyString,
                attributes: [svgRdfResourceKey : urlOFL + separatorString + svgEmbeddingKey]
            )
            let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcLicenseKey].addChild(
                name: svgCcPermitsKey,
                value: emptyString,
                attributes: [svgRdfResourceKey : urlOFL + separatorString + svgDerivativeWorksKey]
            )
            let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcLicenseKey].addChild(
                name: svgCcPermitsKey,
                value: emptyString,
                attributes: [svgRdfResourceKey : urlOFL + separatorString + svgNoticeKey]
            )
            let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcLicenseKey].addChild(
                name: svgCcPermitsKey,
                value: emptyString,
                attributes: [svgRdfResourceKey : urlOFL + separatorString + svgAttributionKey]
            )
            let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcLicenseKey].addChild(
                name: svgCcPermitsKey,
                value: emptyString,
                attributes: [svgRdfResourceKey : urlOFL + separatorString + svgShareAlikeKey]
            )
            let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcLicenseKey].addChild(
                name: svgCcPermitsKey,
                value: emptyString,
                attributes: [svgRdfResourceKey : urlOFL + separatorString + svgDerivativeRenamingKey]
            )
            let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcLicenseKey].addChild(
                name: svgCcPermitsKey,
                value: emptyString,
                attributes: [svgRdfResourceKey : urlOFL + separatorString + svgBundlingWhenSellingKey]
            )
            break
        case svgLicenseOtherKey:
            rdfResource = emptyString
            addPermits = false
            break
        default:
            rdfResource = emptyString
            addPermits = false
            break
        }
        let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcWorkKey].addChild(name: svgCcLicenseKey, value: emptyString, attributes: [svgRdfResourceKey : rdfResource])
        if addPermits {
            let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey].addChild(name: svgCcLicenseKey, value: emptyString, attributes: [svgRdfAboutKey : rdfResource])
            for (permit, state) in permits {
                if state != noneString.lowercased() {
                    let _ = xmlSVG[svgRootKey][svgMetaDataKey][svgRDFKey][svgCcLicenseKey].addChild(name: svgCC + state, value: emptyString, attributes: [svgRdfResourceKey : ccOrgNS + permit])
                }
            }
        }
        
        let _ = xmlSVG[svgRootKey].addChild(name: defsString, value: emptyString, attributes: [svgIdKey : defsString + String(svgID+3)])
        
        var sodipodiAttributes = sodipodiDefaultAttributes
        sodipodiAttributes[svgIdKey] = (sodipodiAttributes[svgIdKey])! + String(svgID+4)
        sodipodiAttributes[svgInkscapeCurrentLayerKey] = (sodipodiAttributes[svgInkscapeCurrentLayerKey])! + String(svgID+5)
        
        let _ = xmlSVG[svgRootKey].addChild(name: svgSodipodiNamedviewKey, value: emptyString, attributes: sodipodiAttributes)
        
        let imageAttributes = [widthKey : img.size.width.toString,
                               heightKey : img.size.height.toString,
                               svgPreserveAspectRatioKey : noneString.lowercased(),
                               svgXlinkHrefKey : jpgB64String + trimmedBase64String,
                               svgIdKey : xmlImageKey + String(svgID+6)
        ]
        let _ = xmlSVG[svgRootKey].addChild(name: xmlImageKey, value: emptyString, attributes: imageAttributes)
        
        let _ = xmlSVG[svgRootKey][xmlImageKey].addChild(name: svgDescKey, value: getElementValue(descriptionKey), attributes: [svgIdKey : svgDescKey + String(svgID+7)])
        let _ = xmlSVG[svgRootKey][xmlImageKey].addChild(name: titleKey, value: getElementValue(titleKey), attributes: [svgIdKey : titleKey +  String(svgID+8)])
        
        if let xmlDetails = xml.root[xmlDetailsKey][xmlDetailKey].all {
            for detail in xmlDetails {
                let path = detail.attributes[xmlPathKey]
                let pointsArray = path!.split{$0 == spaceCharacter}.map(String.init)
                
                let currentDetail: AEXMLDocument = AEXMLDocument()
                let detailTitle = (detail.attributes[xmlTitleKey] != nil) ? detail.attributes[xmlTitleKey]! : emptyString
                let detailDescription = (detail.value != nil) ? detail.value! : emptyString
                var detailType = constraintPolygon
                var detailAttributes = [String:String]()
                
                if ( detail.attributes[xmlConstraintKey] == constraintRectangle || detail.attributes[xmlConstraintKey] == constraintEllipse ) {
                    detailType = (detail.attributes[xmlConstraintKey] == constraintRectangle) ? rectString : constraintEllipse
                    var originPoint = CGPoint(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude)
                    var maxPoint = CGPoint(x: 0.0, y: 0.0)
                    
                    for point in pointsArray {
                        let coords = point.split{$0 == semicolonCharacter}.map(String.init)
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
                    
                    let rectAttributes = [styleString : svgDefaultStyle,
                                          svgIdKey : rectString + String(Int(svgID) + Int(detail.attributes[tagString]!)!),
                                          widthKey : width.toString,
                                          heightKey : height.toString,
                                          xString : originPoint.x.toString,
                                          yString : originPoint.y.toString
                    ]
                    let ellipseAttributes = [styleString : svgDefaultStyle,
                                             svgIdKey : pathString + String(Int(svgID) + Int(detail.attributes[tagString]!)!),
                                             cxString : (originPoint.x + width/2).toString,
                                             cyString : (originPoint.y + height/2).toString,
                                             rxString : (width/2).toString,
                                             ryString : (height/2).toString
                    ]
                    
                    detailAttributes = (detailType == rectString) ? rectAttributes : ellipseAttributes
                }
                else {
                    detailType = pathString
                    detailAttributes = [styleString : svgDefaultStyle,
                                        svgIdKey : pathString + String(Int(svgID) + Int(detail.attributes[tagString]!)!),
                                        dString : String(format: pathAttribute, path!.replacingOccurrences(of: semicolonString, with: commaString)),
                                        svgInkscapeConnectorCurvatureKey : String(0)
                    ]
                }
                
                let _ = currentDetail.addChild(name: detailType, attributes: detailAttributes)
                let _ = currentDetail[detailType].addChild(
                    name: svgDescKey,
                    value: detailDescription,
                    attributes: [svgIdKey : svgDescKey + String(Int(svgID) + Int(detail.attributes[tagString]!)! + 100)]
                )
                let _ = currentDetail[detailType].addChild(
                    name: titleKey,
                    value: detailTitle,
                    attributes: [svgIdKey : titleKey + String(Int(svgID) + Int(detail.attributes[tagString]!)! + 200)]
                )
                
                let _ = xmlSVG[svgRootKey].addChild(currentDetail[detailType])
            }
        }
        
        // write xml to temp directory
        tmpFilePath = NSHomeDirectory() + separatorString + tmpString + separatorString + tempTitle + svgExtension
        do {
            try xmlSVG.xml.write(toFile: tmpFilePath, atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            debugPrint(error.localizedDescription)
        }
        
        openDocumentInteractionController(tmpFilePath)
    }
    
    func exportZip() {
        let cleanName = fileName.suffix(fileName.count - salt.count)
        tmpFilePath = NSHomeDirectory() + separatorString + tmpString + separatorString + cleanName + zipExtension
        let _ = SSZipArchive.createZipFile(atPath: tmpFilePath, withContentsOfDirectory: currentDirs[rootString]! + separatorString + cleanName)
        openDocumentInteractionController(tmpFilePath)
        
    }
    
    func getElementValue(_ element: String) -> String {
        if (xml[xmlXiaKey][element].value != nil && xml[xmlXiaKey][element].value! != String(format: xmlElementNotFound, element)) {
            return xml[xmlXiaKey][element].value!
        }
        else {
            return emptyString
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
