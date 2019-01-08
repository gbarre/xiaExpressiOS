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

// Strings
let emptyString: String = ""
let spaceCharacter: Character = " "
let spaceString: String = " "
let semicolonCharacter: Character = ";"
let semicolonString: String = ";"
let ampersandString: String = "&"
let htmlAmpersandString: String = "&amp;"
let lowerChevronString: String = "<"
let htmlLowerChevronString: String = "&lt;"
let upperChevronString: String = ">"
let htmlUpperChevronString: String = "&gt;"
let breakLineString: String = "\n"
let tabString: String = "\t"
let htmlBreakLineString: String = "<br />"
let openingBraceString: String = "{"
let closingBraceString: String = "}"
let localDirString: String = "./"
let jokerString: String = "*"
let dashString: String = "-"
let underscoreString: String = "_"
let dotString: String = "."
let commaString: String = ","
let dString: String = "d"
let rString: String = "r"
let sString: String = "s"
let xString: String = "x"
let yString: String = "y"
let cxString: String = "cx"
let cyString: String = "cy"
let rxString: String = "rx"
let ryString: String = "ry"
let tagString: String = "tag"
let trueString: String = "true"
let falseString: String = "false"
let imagesString: String = "images"
let separatorString: String = "/"
let xmlExtension: String = ".xml"
let jpgExtension: String = ".jpg"
let pngExtension: String = ".png"
let mp3Extension: String = ".mp3"
let oggExtension: String = ".ogg"
let m4aExtension: String = ".m4a"
let mp4Extension: String = ".mp4"
let ogvExtension: String = ".ogv"
let webmExtension: String = ".webm"
let svgExtension: String = ".svg"
let zipExtension: String = ".zip"
let cornerString: String = "corner"
let editString: String = "edit"
let tmpString: String = "tmp"
let XiaTitleString: String = "Xia"
let XiaTitleSubDirString: String = XiaTitleString + " (%@)"
let noneString: String = "None"
let pleaseInsertCorrectUrlString: String = "Please insert correct URL"
let errorJSONString: String = "{\"html\": \"Please insert correct URL\"}"
let htmlCenterString: String = "<center>%@</center>"
let htmlBoldString: String = "<b>%@</b>"
let htmlEmphasizeString: String = "<em>%@</em>"
let htmlPreFormattedString: String = "<pre>\n%@</pre>\n"
let jpgB64String: String = "data:image/jpg;base64,"
let pngB64String: String = "data:image/png;base64,"

let htmlImgString: String = "<img src=\"%@\" alt=\"%@\" style=\"max-width: %0.fpx;\" />"
let htmlLineBigString: String = "<hr size=3/>"
let htmlLineString: String = "<hr/>"
let htmlListOpenLevel1String: String = "<ul>\n\t<li>"
let htmlListCloseLevel1String: String = "</li></ul>\n"
let htmlListCloseLevel2String: String = "</li>\n\t</ul>\n"
let htmlListCloseOpenString: String = "</li>\n<li>"
let htmlListOpenString: String = "\t<li>"
let htmlListCloseAtEndLevel2String: String = "</li>\n\t</ul></li>\n</ul>\n"
let htmlListCloseAtEndLevel1String: String = "</li>\n</ul>\n"
let htmlLinkString: String = "<a href=\"%@\">%@</a>"
let htmlAudioString: String = "<audio controls>" +
    "<source type=\"audio/mpeg\" src=\"%@\" />" +
    "<source type=\"audio/ogg\" src=\"%@\" />" +
    "<source type=\"audio/m4a\" src=\"%@\" />" +
"</audio>"
let htmlVideoString: String = "<video controls preload=\"none\" width=\"%0.f\" height=\"%0.f\">" +
    "<source type=\"video/mp4\" src=\"%@\" />" +
    "<source type=\"video/ogg\" src=\"%@\" />" +
    "<source type=\"video/webm\" src=\"%@\" />" +
"</video>"

let xmlStartXiaString: String = "<xia>"
let xmlEndXiaString: String = "</xia>"
let xmlHeaderString: String = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n"
let xmlImageString: String = "<image>"

let lockString: String = "lock"
let rootString: String = "root"
let xmlString: String = "xml"
let backString: String = "< Back"
let importingString: String = "importing"
let DSStoreString: String = ".DS_Store"
let jpgString: String = "jpg"
let newDetailPathString: String = "0;0"
let svgString: String = "svg"
let zeroSpaceString: String = "0 "
let permitsString: String = "permits"
let requiresString: String = "requires"
let prohibitsString: String = "prohibits"
let rectString: String = "rect"
let styleString: String = "style"
let pathString: String = "path"
let iPad67String: String = "iPad6,7"
let iPad68String: String = "iPad6,8"

// Specific for svg
let imgSvgXmlString: String = "image/svg+xml"
let dcTypeAttribute: [String: String] = ["rdf:resource" : "http://purl.org/dc/dcmitype/StillImage"]
let urlCCBY: String = "http://creativecommons.org/licenses/by/3.0/"
let urlCCBYSA: String = "http://creativecommons.org/licenses/by-sa/3.0/"
let urlCCBYND: String = "http://creativecommons.org/licenses/by-nd/3.0/"
let urlCCBYNC: String = "http://creativecommons.org/licenses/by-nc/3.0/"
let urlCCBYNCSA: String = "http://creativecommons.org/licenses/by-nc-sa/3.0/"
let urlCCBYNCNS: String = "http://creativecommons.org/licenses/by-nc-nd/3.0/"
let urlPublicDomain: String = "http://creativecommons.org/publicdomain/zero/1.0/"
let urlFreeArt: String = "http://artlibre.org/licence/lal"
let urlOFL: String = "http://scripts.sil.org/OFL"
let svgCC: String = "cc:"
let ccOrgNS: String = "http://creativecommons.org/ns#"
let defsString: String = "defs"
let svgDefaultStyle: String = "opacity:0.3;fill:#ff0000;stroke:#000000;stroke-width:0.1;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
let pathAttribute: String = "M %@ Z"

// Keys
let CFBundleShortVersionStringKey: String = "CFBundleShortVersionString"
let versionKey: String = "version"
let useCacheKey: String = "useCache"
let oembedKey: String = "oembed"
let plistKey: String = "plist"
let fatalErrorInit: String = "init(coder:) has not been implemented"
let nothingHereDictionary: NSDictionary = ["nothing": "here"]
let offlineKey: String = "offline"
let htmlKey: String = "html"
let widthKey: String = "width"
let heightKey: String = "height"
let defaultCodeDict: [String: String] = [xmlCodeKey : "1234"]

let deleteFileKey: String = "DELETE_FILE"
let deleteNFilesKey: String = "DELETE_N_FILES"
let filesSelectedKey: String = "FILES_SELECTED"
let fileSelectedKey: String = "FILE_SELECTED"
let folderNameKey: String = "FOLDER_NAME"
let alphaNumKey: String = "ALPHANUM_ONLY"
let cancelKey: String = "CANCEL"
let okKey: String = "OK"
let yesKey: String = "YES"
let noKey: String = "NO"
let duplicateKey: String = "DUPLICATE"
let doneKey: String = "DONE"
let createDocumentKey: String = "CREATE_DOCUMENT"
let createDetailKey: String = "CREATE_DETAIL"
let deleteDetailKey: String = "DELETE_DETAIL"
let warningKey: String = "WARNING"
let reservedKey: String = "RESERVED"
let alreadyExistKey: String = "ALREADY_EXIST"
let editKey: String = "EDIT"
let collectionKey: String = "COLLECTION"
let descriptionDotKey: String = "DESCRIPTION..."
let fileKey: String = "FILE"
let directoryKey: String = "DIRECTORY"
let errorKey: String = "ERROR"
let noCameraKey: String = "NO_CAMERA"
let enterCodeKey: String = "ENTER_CODE"
let createCodeKey: String = "CREATE_CODE"
let passwordKey: String = "PASSWORD"
let tryAgainKey: String = "TRY_AGAIN"
let doubleCheckKey: String = "DOUBLE_CHECK"
let importKey: String = "IMPORT"
let importSuccessKey: String = "IMPORT_SUCCESSFULL"
let importErrorKey: String = "IMPORT_ERROR"
let chooseFileNameKey: String = "CHOOSE_FILENAME"

let inboxKey: String = "Inbox"
let localDatasKey: String = "localDatas"
let plusImgKey: String = "plus"
let folderImgKey: String = "folder"
let attributedTitleKey: String = "attributedTitle"
let IPCImageURLKey: String = "UIImagePickerControllerImageURL"

let xmlXiaIPadKey: String = "XiaiPad"
let xmlXiaKey: String = "xia"
let xmlDetailsKey: String = "details"
let xmlDetailKey: String = "detail"
let xmlTitleKey: String = "title"
let xmlZoomKey: String = "zoom"
let xmlImageKey: String = "image"
let xmlDescriptionKey: String = "description"
let xmlPathKey: String = "path"
let xmlConstraintKey: String = "constraint"
let xmlShowKey: String = "show"
let xmlElementNotFound: String = "element <%@> not found"
let xmlreadonlyKey: String = "readonly"
let xmlLockedKey: String = "locked"
let xmlAuthorKey: String = "author"
let xmlCodeKey: String = "code"

let svgRootKey: String = "svg"
let svgIdKey: String = "id"
let svgViewBoxKey: String = "viewBox"
let svgSodipodiDocnameKey: String = "sodipodi:docname"
let svgMetaDataKey: String = "metadata"
let svgRDFKey: String = "rdf:RDF"
let svgCcWorkKey: String = "cc:Work"
let svgRdfAboutKey: String = "rdf:about"
let svgDcFormatKey: String = "dc:format"
let svgDcTypeKey: String = "dc:type"
let svgDcTitleKey: String = "dc:title"
let svgDcDateKey: String = "dc:date"
let svgDcCreatorKey: String = "dc:creator"
let svgCcAgentKey: String = "cc:Agent"
let svgDcRightKey: String = "dc:rights"
let svgDcPublisherKey: String = "dc:publisher"
let svgDcIdentifierKey: String = "dc:identifier"
let svgDcSourceKey: String = "dc:source"
let svgDcRelationKey: String = "dc:relation"
let svgDcLanguageKey: String = "dc:language"
let svgDcSubjectKey: String = "dc:subject"
let svgRdfBagKey: String = "rdf:Bag"
let svgRdfLiKey: String = "rdf:li"
let svgDcCoverageKey: String = "dc:coverage"
let svgDcDescriptionKey: String = "dc:description"
let svgDcContributorKey: String = "dc:contributor"
let svgCcLicenseKey: String = "cc:license"
let svgCcPermitsKey: String = "cc:permits"
let svgRdfResourceKey: String = "rdf:resource"
let svgLicenseProprietaryKey: String = "Proprietary - CC-Zero"
let svgLicenseCCBYKey: String = "CC Attribution - CC-BY"
let svgLicenseCCBYSAKey: String = "CC Attribution-ShareALike - CC-BY-SA"
let svgLicenseCCBYNDKey: String = "CC Attribution-NoDerivs - CC-BY-ND"
let svgLicenseCCBYNCKey: String = "CC Attribution-NonCommercial - CC-BY-NC"
let svgLicenseCCBYNCSAKey: String = "CC Attribution-NonCommercial-ShareALike - CC-BY-NC-SA"
let svgLicenseCCBYNCNDKey: String = "CC Attribution-NonCommercial-NoDerivs - CC-BY-NC-ND"
let svgLicenceCC0Key: String = "CC0 Public Domain Dedication"
let svgLicenceFreeArtKey: String = "Free Art"
let svgLicenseOFLKey: String = "Open Font License"
let svgLicenseOtherKey: String = "Other"
let svgReproductionKey: String = "Reproduction"
let svgDistributionKey: String = "Distribution"
let svgEmbeddingKey: String = "Embedding"
let svgNoticeKey: String = "Notice"
let svgAttributionKey: String = "Attribution"
let svgCommercialUseKey: String = "CommercialUse"
let svgDerivativeWorksKey: String = "DerivativeWorks"
let svgShareAlikeKey: String = "ShareAlike"
let svgDerivativeRenamingKey: String = "DerivativeRenaming"
let svgBundlingWhenSellingKey : String = "BundlingWhenSelling"
let svgInkscapeCurrentLayerKey: String = "inkscape:current-layer"
let svgSodipodiNamedviewKey: String = "sodipodi:namedview"
let svgPreserveAspectRatioKey: String = "preserveAspectRatio"
let svgXlinkHrefKey: String = "xlink:href"
let svgDescKey: String = "desc"
let svgInkscapeConnectorCurvatureKey: String = "inkscape:connector-curvature"
let svgOpenTitle: String = "<title>"
let svgCloseTitle: String = "</title>"

let svgDefaultLicensePermits: [String: String] = [
    svgReproductionKey : noneString.lowercased(),
    svgDistributionKey : noneString.lowercased(),
    svgNoticeKey : noneString.lowercased(),
    svgAttributionKey : noneString.lowercased(),
    svgCommercialUseKey : noneString.lowercased(),
    svgDerivativeWorksKey : noneString.lowercased(),
    svgShareAlikeKey : noneString.lowercased()
]

let xmlDefaultAttributes = ["xmlns:dc" : "http://purl.org/dc/elements/1.1/",
                     "xmlns:cc" : "http://creativecommons.org/ns#",
                     "xmlns:rdf" : "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                     "xmlns:svg" : "http://www.w3.org/2000/svg",
                     "xmlns" : "http://www.w3.org/2000/svg",
                     "xmlns:xlink" : "http://www.w3.org/1999/xlink",
                     "xmlns:sodipodi" : "http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd",
                     "xmlns:inkscape" : "http://www.inkscape.org/namespaces/inkscape",
                     "id" : "svg",
                     "version" : "1.1",
                     "inkscape:version" : "0.91",
                     widthKey : "0",
                     heightKey : "0",
                     "viewBox" : "0 0 0 0",
                     "sodipodi:docname" : "tempTitle.svg"
]

let sodipodiDefaultAttributes: [String: String] = [
    "pagecolor" : "#ffffff",
    "bordercolor" : "#666666",
    "borderopacity" : "1",
    "objecttolerance" : "10",
    "gridtolerance" : "10",
    "guidetolerance" : "10",
    "inkscape:pageopacity" : "0",
    "inkscape:pageshadow" : "2",
    "inkscape:window-width" : "640",
    "inkscape:window-height" : "480",
    svgIdKey : "namedview",
    "showgrid" : falseString,
    "inkscape:zoom" : "0.25",
    "inkscape:cx" : "640",
    "inkscape:cy" : "480",
    svgInkscapeCurrentLayerKey : "svg1"
]

let titleKey: String = "title"
let descriptionKey: String = "description"
let creatorKey: String = "creator"
let rightsKey: String = "rights"
let licenseKey: String = "license"
let dateKey: String = "date"
let publisherKey: String = "publisher"
let identifierKey: String = "identifier"
let sourceKey: String = "source"
let relationKey: String = "relation"
let languageKey: String = "language"
let keywordsKey: String = "keywords"
let coverageKey: String = "coverage"
let contributorsKey: String = "contributors"
let defaultSalt: String = "14876_"

let xmlElements: [String] = [titleKey, descriptionKey, creatorKey,
                             rightsKey, licenseKey, dateKey, publisherKey,
                             identifierKey, sourceKey, relationKey, languageKey,
                             keywordsKey, coverageKey, contributorsKey
]

var xmlElementsDict: [String: String?] {    // Ok here is a var in constant file
    var dict = [String: String?]()          // It's a fake var !!
    for element in xmlElements {
        if element == languageKey {
            let languages = "LANGUAGES"
            dict[element] = NSLocalizedString(languages, comment: emptyString)
        } else {
            dict[element] = NSLocalizedString(element.uppercased(), comment: emptyString)
        }
        
    }
    return dict
}

// Segues
let playMetasSegueKey: String = "playMetas"
let openDetailSegueKey: String = "openDetail"
let exportSegueKey: String = "export"
let viewMetasSegueKey: String = "viewMetas"
let reorderSegueKey: String = "reorder"
let addSegueKey: String = "Add"
let viewLargePhotoSegueKey: String = "viewLargePhoto"
let playXiaSegueKey: String = "playXia"
let viewDetailInfosSegueKey: String = "ViewDetailInfos"
let viewExportSegueKey: String = "viewExport"
let addMediaSegueKey: String = "addMedia"
let showPickerSegueKey: String = "showPicker"

// Identifiers
let photoCellIdentifier: String = "PhotoCell"
let importIdentifier: String = "importIdentifier"
let cellReuseIdentifier: String = "reorderIdentifier"
let fileIdentifier: String = "fileID"

// Regex
let urlRegex: String = "(^|\\ |\\<br \\/\\>)(((https?|ftp|file):\\/)|\\.)\\/[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]"
let audioExtentionRegex: String = "\\.(mp3|ogg|m4a)"
let imageExtentionRegex: String = "\\.(jpg|jpeg|gif|png)"
let videoExtentionRegex: String = "\\.(mp4|ogv|webm)"
let boldRegex: String = "(\\*){3}((?!\\*{3}).)*\\*{3}"
let emphasizeRegex: String = "(\\*){2}((?!\\*{2}).)*\\*{2}"
let preformattedRegex: String = "(\\{){3}((?!\\{{3}).)*\\}{3}"
let audioAutoRegex: String = "\\.(mp3|ogg|m4a)( autostart)?"
let customLinkRegex: String = "\\[https?:\\/{2}((?! ).)* *((?!\\]).)*\\]"
let hookRegex: String = "\\[|\\]"
let videoRegex: String = "\\.(mp4|ogv|webm)"
let srcRegex: String = "src=\"//"
let srcReplaceString: String = "src=\"http%@://"
let wordRegex: String = "[^\\w\\.\\-\\_]"
let alphaNumericRegex: String = "[^a-zA-Z0-9\\-\\_]"
let tabRegex: String = "\\t"
let titleRegex: String = "(\\t?)*<title>.*"


let oembedProxyUrl: String = "https://oembedproxy.backbone.education/?url="
let documentsDirectory: String = NSHomeDirectory() + separatorString + "Documents"
let imagesDirectory: String = documentsDirectory + separatorString + imagesString
let xmlDirectory: String = documentsDirectory + separatorString + xmlString
let localDatasDirectory: String = documentsDirectory + separatorString + localDatasKey
let rootDirs: [String: String] = [rootString: documentsDirectory, imagesString: imagesDirectory, xmlString: xmlDirectory]
let reservedDirs: [String] = [imagesString, xmlString, inboxKey, localDatasKey]

let dbPath: String = documentsDirectory + separatorString + oembedKey + dotString + plistKey
let importFileString: String = "importFile"
let importPath: String = documentsDirectory + separatorString + importFileString + xmlExtension
