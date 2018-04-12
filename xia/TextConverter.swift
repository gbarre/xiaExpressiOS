
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _text2html(inText: String) -> String {
        var htmlString = inText
        
        htmlString = htmlString.replacingOccurrences(of: "&", with: "&amp;")
        htmlString = htmlString.replacingOccurrences(of: "<", with: "&lt;")
        htmlString = htmlString.replacingOccurrences(of: ">", with: "&gt;")
        htmlString = htmlString.replacingOccurrences(of: "\n", with: "<br />")
        
        htmlString = pikipikiToHTML(text: htmlString)
        
        htmlString = htmlString.replacingOccurrences(of: "}}}", with: "")
        
        let defaults = UserDefaults.standard
        let offline = defaults.bool(forKey: "offline")
        let useCache = defaults.bool(forKey: "useCache")
        
        if Reachability.isConnectedToNetwork() && !offline {
            
            // we have "Internet", have fun !
            htmlString = replaceURL(inText: htmlString, updateDB: useCache)
            
            htmlString = showCustomLinks(inText: htmlString)
            
        } else {
            htmlString = showCustomLinks(inText: htmlString)
        }
        dbg.pt(htmlString)
        
        return htmlString
    }
    
    func replaceURL(inText: String!, updateDB: Bool) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "(^|\\ |\\<br \\/\\>)(((https?|ftp|file):\\/)|\\.)\\/[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            let baseURL = "https://oembedproxy.funraiders.io/?"
            
            // init local db
            let db = jsonDB(p: dbPath)
            db.getDict()
            
            for result in arrayResults { // browse all urls
                var cleanResult = result.replacingOccurrences(of: "<br />", with: "")
                cleanResult = cleanResult.replacingOccurrences(of: " ", with: "")
                
                let urlString = "url=\(cleanResult)"
                // look in local db for json
                var dictJson = db.getJson(url: cleanResult)
                if (dictJson == ["nothing": "here"]) {
                    let datasJson = getJSON(urlToRequest: baseURL + urlString)
                    dictJson = parseJSON(inputData: datasJson)
                    if (updateDB) {
                        db.insert(url: cleanResult, json: dictJson)
                    }
                }
                
                var htmlCode = dictJson["html"]! as! String
                
                if (htmlCode != "Please insert correct URL") {
                    let providerName = dictJson["provider_name"]! as! String
                    htmlCode = solveSrcPb(htmlCode)
                    // video / image resizing
                    if (providerName != "Instagram" && providerName != "Twitter") {
                        var jsonWidth: CGFloat;
                        var jsonHeight: CGFloat;
                        if (providerName.contains("WebTV de") || providerName.contains("Audio Lingua") || providerName.contains("Flickr")) {
                            jsonWidth = convertStringToCGFloat(dictJson["width"]! as! String)
                            jsonHeight = convertStringToCGFloat(dictJson["height"]! as! String)
                        } else {
                            jsonWidth = dictJson["width"]! as! CGFloat
                            jsonHeight = dictJson["height"]! as! CGFloat
                        }
                        let scaleX = videoWidth / jsonWidth
                        let scaleY = videoHeight / jsonHeight
                        let scale = min(min(scaleX, scaleY), 1)
                        let newWidth = Int(jsonWidth * scale)
                        let newHeight = Int(jsonHeight * scale)
                        htmlCode = htmlCode.replacingOccurrences(of: "width=\"\(jsonWidth)\"", with: "width=\"\(newWidth)\"");
                        htmlCode = htmlCode.replacingOccurrences(of: "height=\"\(jsonHeight)\"", with: "height=\"\(newHeight)\"");
                    }
                    // center iframe
                    htmlCode = "<center>" + htmlCode + "</center>"
                    output = output?.replacingOccurrences(of: cleanResult, with: htmlCode)
                } else if (cleanResult.prefix(2) == "./") {
                    let filePath = localDatasDirectory + "/" + cleanResult.suffix(cleanResult.count - 2)
                    if cleanResult.suffix(3) == "JPG" || cleanResult.suffix(3) == "jpg" {
                        if FileManager.default.fileExists(atPath: filePath) {
                            let img = UIImage(contentsOfFile: filePath)!
                            let imageData = UIImageJPEGRepresentation(img, 85)
                            let base64String = imageData!.base64EncodedString(options: .lineLength76Characters)
                            output = output?.replacingOccurrences(of: cleanResult, with: "<img src=\"data:image/jpeg;base64,\(base64String)\" alt=\"\(cleanResult)\" style=\"max-width: \(videoWidth)px;\" />")
                        }
                    } else if cleanResult.suffix(3) == "PNG" || cleanResult.suffix(3) == "png" {
                        if FileManager.default.fileExists(atPath: filePath) {
                            let img = UIImage(contentsOfFile: filePath)!
                            let imageData = UIImagePNGRepresentation(img)
                            let base64String = imageData!.base64EncodedString(options: .lineLength76Characters)
                            output = output?.replacingOccurrences(of: cleanResult, with: "<img src=\"data:image/png;base64,\(base64String)\" alt=\"\(cleanResult)\" style=\"max-width: \(videoWidth)px;\" />")
                        }
                    } else if cleanResult.suffix(3) == "MP4" || cleanResult.suffix(3) == "mp4" || cleanResult.suffix(3) == "MOV" || cleanResult.suffix(3) == "mov" {
                        let videoData = NSData(contentsOf: URL(fileURLWithPath: filePath))
                        let base64String = videoData?.base64EncodedString(options: .lineLength76Characters)
                        output = output?.replacingOccurrences(of: cleanResult, with: "<video controls width=\"\(videoWidth)\" height=\"\(videoHeight)\"><source type=\"video/mp4\" src=\"data:video/mp4;base64,\(base64String ?? "")\"><source type=\"video/mov\" src=\"data:video/mov;base64,\(base64String ?? "")\"></video>")
                    } else if cleanResult.suffix(3) == "M4A" || cleanResult.suffix(3) == "m4a" || cleanResult.suffix(3) == "MP3" || cleanResult.suffix(3) == "mp3" {
                        let audioData = NSData(contentsOf: URL(fileURLWithPath: filePath))
                        let base64String = audioData?.base64EncodedString(options: .lineLength76Characters)
                        output = output?.replacingOccurrences(of: cleanResult, with: "<audio controls><source type=\"audio/mpeg\" src=\"data:audio/mp3;base64,\(base64String ?? "")\" /><source type=\"audio/m4a\" src=\"data:audio/m4a;base64,\(base64String ?? "")\" /></audio>")
                    }
                } else if (cleanResult.range(of: "\\.(mp3|ogg|m4a)", options: .regularExpression) != nil) {
                    let audioUrl = showAudio(url: cleanResult)
                    output = output?.replacingOccurrences(of: cleanResult, with: audioUrl)
                } else if (cleanResult.range(of: "\\.(jpg|jpeg|gif|png)", options: .regularExpression) != nil) {
                    output = output?.replacingOccurrences(of: cleanResult, with: "<img src=\"\(cleanResult)\" alt=\"\(cleanResult)\" style=\"max-width: \(videoWidth)px;\" />")
                } else if (cleanResult.range(of: "\\.(mp4|ogv|webm)", options: .regularExpression) != nil) {
                    let videoUrl = showVideo(url: cleanResult)
                    output = output?.replacingOccurrences(of: cleanResult, with: videoUrl)
                }
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func getJSON(urlToRequest: String) -> Data{
        do {
            let data = try Data(contentsOf: URL(string: urlToRequest)!)
            return data
        } catch {
            let string = "{\"html\": \"Please insert correct URL\"}"
            return string.data(using: .utf8)!
        }
    }
    
    func parseJSON(inputData: Data) -> NSDictionary{
        var boardsDictionary = NSDictionary()
        do {
            boardsDictionary = try JSONSerialization.jsonObject(with: inputData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return boardsDictionary
    }
    
    func pikipikiToHTML(text: String) -> String {
        var output = text
        // Make bold
        do {
            let regex = try NSRegularExpression(pattern: "(\\*){3}((?!\\*{3}).)*\\*{3}", options: .caseInsensitive)
            let nsString = output as NSString
            let results = regex.matches(in: output, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let cleanResult = result.replacingOccurrences(of: "***", with: "")
                output = output.replacingOccurrences(of: result, with: "<b>\(cleanResult)</b>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        
        // Make emphasize
        do {
            let regex = try NSRegularExpression(pattern: "(\\*){2}((?!\\*{2}).)*\\*{2}", options: .caseInsensitive)
            let nsString = output as NSString
            let results = regex.matches(in: output, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let cleanResult = result.replacingOccurrences(of: "**", with: "")
                output = output.replacingOccurrences(of: result, with: "<em>\(cleanResult)</em>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        
        // Make pre-formatted
        do {
            let regex = try NSRegularExpression(pattern: "(\\{){3}((?!\\{{3}).)*\\}{3}", options: .caseInsensitive)
            let nsString = output as NSString
            let results = regex.matches(in: output, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                var cleanResult = result.replacingOccurrences(of: "{{{", with: "")
                cleanResult = cleanResult.replacingOccurrences(of: "}}}", with: "")
                output = output.replacingOccurrences(of: result, with: "<pre>\n\(cleanResult)</pre>\n")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        
        // Make line
        output = output.replacingOccurrences(of: "-----", with: "<hr size=3/>")
        output = output.replacingOccurrences(of: "----", with: "<hr/>")
        
        // Make list line by line
        let outputArray = output.components(separatedBy: "<br />")
        let nbLines = outputArray.count
        var onLine = 0
        var levelList = [Int:Bool]()
        var previousLine = ""
        for line in outputArray {
            var replace = line
            if line.count > 6 && line[line.index(line.startIndex, offsetBy: 0)...line.index(line.startIndex, offsetBy: 5)] != "<br />" {
                replace = line.replacingOccurrences(of: "<br />", with: "")
                if onLine == nbLines {
                    if (levelList[1] == true) {
                        levelList[1] = false
                        output = output + "</li>\n\t</ul>\n" + line
                    }
                    if (levelList[0] == true) {
                        levelList[0] = false
                        output = output + "</li>\n\t</ul>\n" + line
                    }
                }
                if line[line.index(line.startIndex, offsetBy: 0)...line.index(line.startIndex, offsetBy: 2)] != " * " {
                    if (levelList[1] == true) {
                        levelList[1] = false
                        replace = "</li>\n\t</ul>\n" + line
                    }
                }
                if line[line.index(line.startIndex, offsetBy: 0)...line.index(line.startIndex, offsetBy: 1)] != "* " {
                    if (levelList[0] == true && levelList[1] == false) {
                        levelList[0] = false
                        replace = "</li></ul>\n" + line
                    }
                }
                if line[line.index(line.startIndex, offsetBy: 0)...line.index(line.startIndex, offsetBy: 1)] == "* " {
                    if (levelList[0] == nil) {
                        levelList[0] = true
                        replace = "<ul>\n\t<li>"
                    }
                    else {
                        replace = "</li>\n<li>"
                    }
                    replace = replace + line[line.index(line.startIndex, offsetBy: 2)...line.index(before: line.endIndex)]
                }
                if line[line.index(line.startIndex, offsetBy: 0)...line.index(line.startIndex, offsetBy: 2)] == " * " {
                    if (levelList[1] == nil) {
                        levelList[1] = true
                        replace = "<ul>\n\t<li>"
                    }
                    else {
                        replace = "\t<li>"
                    }
                    replace = replace + line[line.index(line.startIndex, offsetBy: 3)...line.index(before: line.endIndex)]
                }
                output = output.replacingOccurrences(of: line, with: replace)
                previousLine = replace
            }
            else {
                if (levelList[1] == true) {
                    levelList[1] = false
                    replace = previousLine + "</li>\n\t</ul></li>\n</ul>\n" + line
                    output = output.replacingOccurrences(of: previousLine, with: replace)
                }
                else if (levelList[0] == true) {
                    levelList[0] = false
                    replace = previousLine + "</li>\n</ul>\n" + line
                    output = output.replacingOccurrences(of: previousLine, with: replace)
                }
                previousLine = line
            }
            onLine = onLine + 1
        }
        
        return output
    }
    
    func showAudio(url: String) -> String {
        let mp3Result = url.replacingOccurrences(of: "\\.(mp3|ogg|m4a)( autostart)?", with: ".mp3", options:NSString.CompareOptions.regularExpression, range: nil)
        let oggResult = url.replacingOccurrences(of: "\\.(mp3|ogg|m4a)( autostart)?", with: ".ogg", options:NSString.CompareOptions.regularExpression, range: nil)
        let m4aResult = url.replacingOccurrences(of: "\\.(mp3|ogg|m4a)( autostart)?", with: ".m4a", options:NSString.CompareOptions.regularExpression, range: nil)
        
        return "<center><audio controls><source type=\"audio/mpeg\" src=\"\(mp3Result)\" /><source type=\"audio/ogg\" src=\"\(oggResult)\" /><source type=\"audio/m4a\" src=\"\(m4aResult)\" /></audio></center>"
    }
    
    func showCustomLinks(inText: String) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "\\[https?:\\/{2}((?! ).)* *((?!\\]).)*\\]", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let text = result.replacingOccurrences(of: "\\[|\\]", with: "", options:NSString.CompareOptions.regularExpression, range: nil)
                let urlEndRange: NSRange = (text as NSString).range(of: " ")
                let url = (urlEndRange.length == 1) ? String(text[text.index(text.startIndex, offsetBy: 0)...text.index(text.startIndex, offsetBy: urlEndRange.location - 1)]) : text
                let linkText = (urlEndRange.length == 1) ? String(text[text.index(text.startIndex, offsetBy: urlEndRange.location+1)...text.index(before: text.endIndex)]) : text
                let replaceString = "<a href=\"\(url)\">\(linkText)</a>";
                output = output.replacingOccurrences(of: result, with: replaceString)
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func showVideo(url: String) -> String {
        let mp4Result = url.replacingOccurrences(of: "\\.(mp4|ogv|webm)", with: ".mp4", options:NSString.CompareOptions.regularExpression, range: nil)
        let ogvResult = url.replacingOccurrences(of: "\\.(mp4|ogv|webm)", with: ".ogv", options:NSString.CompareOptions.regularExpression, range: nil)
        let webmResult = url.replacingOccurrences(of: "\\.(mp4|ogv|webm)", with: ".webm", options:NSString.CompareOptions.regularExpression, range: nil)
        return "<center><video controls preload=\"none\" width=\"\(videoWidth)\" height=\"\(videoHeight)\"><source type=\"video/mp4\" src=\"\(mp4Result)\" /><source type=\"video/ogg\" src=\"\(ogvResult)\" /><source type=\"video/webm\" src=\"\(webmResult)\" /></video></center>";
    }
    
    func solveSrcPb(_ intext: String, s: String = "s") -> String {
        return intext.replacingOccurrences(of: "src=\"//", with: "src=\"http\(s)://")
    }
}
