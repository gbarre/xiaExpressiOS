
//
//  TextConverter.swift
//  xia
//
//  Created by Guillaume on 23/05/2016.
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

class TextConverter: NSObject {
    
    var videoWidth: CGFloat = 480
    var videoHeight: CGFloat = 270
    
    init(videoWidth: CGFloat, videoHeight: CGFloat){
        self.videoWidth = videoWidth
        self.videoHeight = videoHeight
    }
    
    func _text2html(inText: String) -> String {
        var htmlString = inText
        
        htmlString = htmlString.replacingOccurrences(of: ampersandString, with: htmlAmpersandString)
        htmlString = htmlString.replacingOccurrences(of: lowerChevronString, with: htmlLowerChevronString)
        htmlString = htmlString.replacingOccurrences(of: upperChevronString, with: htmlUpperChevronString)
        htmlString = htmlString.replacingOccurrences(of: breakLineString, with: htmlBreakLineString)
        
        htmlString = pikipikiToHTML(text: htmlString)
        
        htmlString = htmlString.replacingOccurrences(of: String(repeating: closingBraceString, count: 3), with: emptyString)
        
        let defaults = UserDefaults.standard
        let offline = defaults.bool(forKey: offlineKey)
        let useCache = defaults.bool(forKey: useCacheKey)
        
        if Reachability.isConnectedToNetwork() && !offline {
            
            // we have Internet, have fun !
            htmlString = replaceURL(inText: htmlString, updateDB: useCache)
            
            htmlString = showCustomLinks(inText: htmlString)
            
        } else {
            htmlString = showCustomLinks(inText: htmlString)
        }
        //debugPrint(htmlString)
        
        return htmlString
    }
    
    func replaceURL(inText: String!, updateDB: Bool) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: urlRegex, options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            
            // init local db
            let db = jsonDB(p: dbPath)
            db.getDict()
            
            for result in arrayResults { // browse all urls
                var cleanResult = result.replacingOccurrences(of: htmlBreakLineString, with: emptyString)
                cleanResult = cleanResult.replacingOccurrences(of: spaceString, with: emptyString)
                
                // look in local db for json
                var dictJson = db.getJson(url: cleanResult)
                if (dictJson == nothingHereDictionary) {
                    let datasJson = getJSON(urlToRequest: oembedProxyUrl + cleanResult)
                    dictJson = parseJSON(inputData: datasJson)
                    if (updateDB) {
                        db.insert(url: cleanResult, json: dictJson)
                    }
                }
                
                var htmlCode = dictJson[htmlKey]! as! String
                
                if (htmlCode != pleaseInsertCorrectUrlString) {
                    htmlCode = solveSrcPb(htmlCode)
                    
                    // center iframe
                    htmlCode = String(format: htmlCenterString, htmlCode)
                    output = output?.replacingOccurrences(of: cleanResult, with: htmlCode)
                } else if (cleanResult.prefix(2) == localDirString) {
                    let filePath = localDatasDirectory + separatorString + String(cleanResult.suffix(cleanResult.count - 2))
                    if cleanResult.suffix(4).lowercased() == jpgExtension {
                        if FileManager.default.fileExists(atPath: filePath) {
                            let img = UIImage(contentsOfFile: filePath)!
                            let imageData = UIImageJPEGRepresentation(img, 85)
                            let base64String = imageData!.base64EncodedString(options: .lineLength76Characters)
                            output = output?.replacingOccurrences(of: cleanResult,
                                                                  with: String(format: htmlImgString, jpgB64String + base64String, cleanResult, videoWidth))
                        }
                    } else if cleanResult.suffix(4).lowercased() == pngExtension {
                        if FileManager.default.fileExists(atPath: filePath) {
                            let img = UIImage(contentsOfFile: filePath)!
                            let imageData = UIImagePNGRepresentation(img)
                            let base64String = imageData!.base64EncodedString(options: .lineLength76Characters)
                            output = output?.replacingOccurrences(of: cleanResult,
                                                                  with: String(format: htmlImgString, pngB64String + base64String, cleanResult, videoWidth))
                        }
                    }
                } else if (cleanResult.range(of: audioExtentionRegex, options: .regularExpression) != nil) {
                    let audioUrl = showAudio(url: cleanResult)
                    output = output?.replacingOccurrences(of: cleanResult, with: audioUrl)
                } else if (cleanResult.range(of: imageExtentionRegex, options: .regularExpression) != nil) {
                    output = output?.replacingOccurrences(of: cleanResult,
                                                          with: String(format: htmlImgString, cleanResult, cleanResult, videoWidth))
                } else if (cleanResult.range(of: videoExtentionRegex, options: .regularExpression) != nil) {
                    let videoUrl = showVideo(url: cleanResult)
                    output = output?.replacingOccurrences(of: cleanResult, with: videoUrl)
                }
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        return output!
    }
    
    func getJSON(urlToRequest: String) -> Data{
        do {
            let data = try Data(contentsOf: URL(string: urlToRequest)!)
            return data
        } catch {
            let string = errorJSONString
            return string.data(using: .utf8)!
        }
    }
    
    func parseJSON(inputData: Data) -> NSDictionary{
        var boardsDictionary = NSDictionary()
        do {
            boardsDictionary = try JSONSerialization.jsonObject(with: inputData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        return boardsDictionary
    }
    
    func pikipikiToHTML(text: String) -> String {
        var output = text
        // Make bold
        do {
            let regex = try NSRegularExpression(pattern: boldRegex, options: .caseInsensitive)
            let nsString = output as NSString
            let results = regex.matches(in: output, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let cleanResult = result.replacingOccurrences(of: String(repeating: jokerString, count: 3), with: emptyString)
                output = output.replacingOccurrences(of: result, with: String(format: htmlBoldString, cleanResult))
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        
        // Make emphasize
        do {
            let regex = try NSRegularExpression(pattern: emphasizeRegex, options: .caseInsensitive)
            let nsString = output as NSString
            let results = regex.matches(in: output, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let cleanResult = result.replacingOccurrences(of: String(repeating: jokerString, count: 2), with: emptyString)
                output = output.replacingOccurrences(of: result, with: String(format: htmlEmphasizeString, cleanResult))
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        
        // Make pre-formatted
        do {
            let regex = try NSRegularExpression(pattern: preformattedRegex, options: .caseInsensitive)
            let nsString = output as NSString
            let results = regex.matches(in: output, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let cleanResult = result.replacingOccurrences(of: String(repeating: openingBraceString, count: 3), with: emptyString)
                    .replacingOccurrences(of: String(repeating: closingBraceString, count: 3), with: emptyString)
                output = output.replacingOccurrences(of: result, with: String(format: htmlPreFormattedString, cleanResult))
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        
        // Make line
        output = output.replacingOccurrences(of: String(repeating: dashString, count: 5), with: htmlLineBigString)
            .replacingOccurrences(of: String(repeating: dashString, count: 4), with: htmlLineString)
        
        // Make list line by line
        let outputArray = output.components(separatedBy: htmlBreakLineString)
        let nbLines = outputArray.count
        var onLine = 0
        var levelList = [Int:Bool]()
        var previousLine = emptyString
        for line in outputArray {
            var replace = line
            if line.count > 6 && line[line.index(line.startIndex, offsetBy: 0)...line.index(line.startIndex, offsetBy: 5)] != htmlBreakLineString {
                replace = line.replacingOccurrences(of: htmlBreakLineString, with: emptyString)
                if onLine == nbLines {
                    if (levelList[1] == true) {
                        levelList[1] = false
                        output = output + htmlListCloseLevel2String + line
                    }
                    if (levelList[0] == true) {
                        levelList[0] = false
                        output = output + htmlListCloseLevel2String + line
                    }
                }
                if line[line.index(line.startIndex, offsetBy: 0)...line.index(line.startIndex, offsetBy: 2)] != spaceString + jokerString + spaceString {
                    if (levelList[1] == true) {
                        levelList[1] = false
                        replace = htmlListCloseLevel2String + line
                    }
                }
                if line[line.index(line.startIndex, offsetBy: 0)...line.index(line.startIndex, offsetBy: 1)] != jokerString + spaceString {
                    if (levelList[0] == true && levelList[1] == false) {
                        levelList[0] = false
                        replace = htmlListCloseLevel1String + line
                    }
                }
                if line[line.index(line.startIndex, offsetBy: 0)...line.index(line.startIndex, offsetBy: 1)] == jokerString + spaceString {
                    if (levelList[0] == nil) {
                        levelList[0] = true
                        replace = htmlListOpenLevel1String
                    }
                    else {
                        replace = htmlListCloseOpenString
                    }
                    replace = replace + line[line.index(line.startIndex, offsetBy: 2)...line.index(before: line.endIndex)]
                }
                if line[line.index(line.startIndex, offsetBy: 0)...line.index(line.startIndex, offsetBy: 2)] == spaceString + jokerString + spaceString {
                    if (levelList[1] == nil) {
                        levelList[1] = true
                        replace = htmlListOpenLevel1String
                    }
                    else {
                        replace = htmlListOpenString
                    }
                    replace = replace + line[line.index(line.startIndex, offsetBy: 3)...line.index(before: line.endIndex)]
                }
                output = output.replacingOccurrences(of: line, with: replace)
                previousLine = replace
            }
            else {
                if (levelList[1] == true) {
                    levelList[1] = false
                    replace = previousLine + htmlListCloseAtEndLevel2String + line
                    output = output.replacingOccurrences(of: previousLine, with: replace)
                }
                else if (levelList[0] == true) {
                    levelList[0] = false
                    replace = previousLine + htmlListCloseAtEndLevel1String + line
                    output = output.replacingOccurrences(of: previousLine, with: replace)
                }
                previousLine = line
            }
            onLine = onLine + 1
        }
        
        return output
    }
    
    func showAudio(url: String) -> String {
        let mp3Result = url.replacingOccurrences(of: audioAutoRegex, with: mp3Extension, options:NSString.CompareOptions.regularExpression, range: nil)
        let oggResult = url.replacingOccurrences(of: audioAutoRegex, with: oggExtension, options:NSString.CompareOptions.regularExpression, range: nil)
        let m4aResult = url.replacingOccurrences(of: audioAutoRegex, with: m4aExtension, options:NSString.CompareOptions.regularExpression, range: nil)
        
        return String(format: htmlCenterString, String(format: htmlAudioString, mp3Result, oggResult, m4aResult))
    }
    
    func showCustomLinks(inText: String) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: customLinkRegex, options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let text = result.replacingOccurrences(of: hookRegex, with: emptyString, options:NSString.CompareOptions.regularExpression, range: nil)
                let urlEndRange: NSRange = (text as NSString).range(of: spaceString)
                let url = (urlEndRange.length == 1) ? String(text[text.index(text.startIndex, offsetBy: 0)...text.index(text.startIndex, offsetBy: urlEndRange.location - 1)]) : text
                let linkText = (urlEndRange.length == 1) ? String(text[text.index(text.startIndex, offsetBy: urlEndRange.location+1)...text.index(before: text.endIndex)]) : text
                let replaceString = String(format: htmlLinkString, url, linkText)
                output = output.replacingOccurrences(of: result, with: replaceString)
            }
        } catch let error as NSError {
            debugPrint(error.localizedDescription)
        }
        return output
    }
    
    func showVideo(url: String) -> String {
        let mp4Result = url.replacingOccurrences(of: videoRegex, with: mp4Extension, options:NSString.CompareOptions.regularExpression, range: nil)
        let ogvResult = url.replacingOccurrences(of: videoRegex, with: ogvExtension, options:NSString.CompareOptions.regularExpression, range: nil)
        let webmResult = url.replacingOccurrences(of: videoRegex, with: webmExtension, options:NSString.CompareOptions.regularExpression, range: nil)
        return String(format: htmlCenterString, String(format: htmlVideoString, videoWidth, videoHeight, mp4Result, ogvResult, webmResult))
    }
    
    func solveSrcPb(_ intext: String, s: String = sString) -> String {
        return intext.replacingOccurrences(of: srcRegex, with: String(format: srcReplaceString, s))
    }
}
