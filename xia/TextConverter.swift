
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
    
    func _text2html(_ inText: String) -> String {
        var htmlString = inText
        
        htmlString = htmlString.replacingOccurrences(of: "&", with: "&amp;")
        htmlString = htmlString.replacingOccurrences(of: "<", with: "&lt;")
        htmlString = htmlString.replacingOccurrences(of: ">", with: "&gt;")
        htmlString = htmlString.replacingOccurrences(of: "\n", with: "<br />")
        
        htmlString = pikipikiToHTML(htmlString)
        htmlString = htmlString.replacingOccurrences(of: "}}}", with: "")
        
        let defaults = UserDefaults.standard
        let offline = defaults.bool(forKey: "offline")
        
        if Reachability.isConnectedToNetwork() && !offline {
            // we have "Internet", have fun !
            htmlString = showAudio(htmlString)
            htmlString = showCustomLinks(htmlString)
            htmlString = showPictures(htmlString)
            htmlString = showVideo(htmlString)
            
            htmlString = buildAudiolinguaLinks(htmlString)
            htmlString = buildDailymotionLinks(htmlString)
            htmlString = buildFlickrLinks(htmlString)
            htmlString = buildInstagramLinks(htmlString)
            htmlString = buildScolawebtvLinks(htmlString)
            htmlString = buildSlideshareLinks(htmlString)
            htmlString = buildTwitterLinks(htmlString)
            htmlString = buildVimeoLinks(htmlString)
            htmlString = buildYoutubeLinks(htmlString)
            htmlString = buildWebtvLinks(htmlString)
        }
        
        //dbg.pt(htmlString)
        
        return htmlString
    }
    
    func buildAudiolinguaLinks(_ inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}www\\.audio-lingua\\.eu\\/spip\\.php\\?article([0-9]*)", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let audioCode = result.replacingOccurrences(of: "http://www.audio-lingua.eu/spip.php?article", with: "", options: NSString.CompareOptions.caseInsensitive, range: nil)
                output = output?.replacingOccurrences(of: result, with: "<center><iframe frameborder=\"0\" width=\"\(videoWidth)\" height=\"120\" src=\"http://www.audio-lingua.eu/spip.php?page=mp3&id_article=\(audioCode)&color=00aaea\"></iframe></center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildDailymotionLinks(_ inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "http:\\/{2}dai\\.ly\\/(\\w|-|_)*", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let videoCode = result.replacingOccurrences(of: "http://dai.ly/", with: "", options: NSString.CompareOptions.caseInsensitive, range: nil)
                output = output?.replacingOccurrences(of: result, with: "<center><iframe frameborder=\"0\" width=\"\(videoWidth)\" height=\"\(videoHeight)\" src=\"http://www.dailymotion.com/embed/video/\(videoCode)\" allowfullscreen></iframe></center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildInstagramLinks(_ inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https:\\/{2}www\\.instagram\\.com\\/p\\/(\\w|-|_)*\\/", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            let baseURL = "https://api.instagram.com/oembed?"
            for result in arrayResults {
                let urlString = "url=\(result)"
                
                let datasJson = getJSON(baseURL + urlString + "&omitscript=true")
                let dictJson = parseJSON(datasJson)
                let author = dictJson["author_name"]! as! String
                let authorURL = dictJson["author_url"]! as! String
                let thumbnailURL = dictJson["thumbnail_url"]! as! String
                let title = dictJson["title"]! as! String
                output = output?.replacingOccurrences(of: result, with: "<center><img src=\"\(thumbnailURL)\" alt=\"\(thumbnailURL)\" style=\"max-width: \(videoWidth);\" /><p><a href=\"\(result)\" style=\"color:#000; font-family:Arial,sans-serif; font-size:14px; font-style:normal; font-weight:normal; line-height:17px; text-decoration:none; word-wrap:break-word;\">\(title)</a></p><p>\(NSLocalizedString("PHOTO_PUBLISHED_BY", comment: "")) <a href=\"\(authorURL)\">@\(author)</a></p></center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildFlickrLinks(_ inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https:\\/{2}flic\\.kr\\/p\\/(\\w|-|_)*", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            let baseURL = "https://www.flickr.com/services/oembed/?format=json&callback=?"
            let callbackString = "&jsoncallback="
            for result in arrayResults {
                let urlString = "&url=\(result)"
                let datasJson = getJSON(baseURL + callbackString + urlString)
                let dictJson = parseJSON(datasJson)
                let width = convertStringToCGFloat(dictJson["width"]! as! String)
                let height = convertStringToCGFloat(dictJson["height"]! as! String)
                let scaleX = videoWidth / width
                let scaleY = videoHeight / height
                let scale = min(scaleX, scaleY, 1)
                let newWidth = width * scale
                let newHeight = height * scale
                let html = (dictJson["html"]! as! String).replacingOccurrences(of: "width=\"\(Int(width))\" height=\"\(Int(height))\"", with: "width=\"\(newWidth)\" height=\"\(newHeight)\"")
                output = output?.replacingOccurrences(of: result, with: "<center>\(html)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildScolawebtvLinks(_ inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}scolawebtv\\.crdp-versailles\\.fr\\/\\?id=?[0-9]*", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            let baseURL = "http://scolawebtv.crdp-versailles.fr/oembed.api/?"
            let formatString = "format=json"
            for result in arrayResults {
                let urlString = "&url=\(result)"
                let datasJson = getJSON(baseURL + formatString + urlString)
                let dictJson = parseJSON(datasJson)
                let width = dictJson["width"]! as! CGFloat
                let height = dictJson["height"]! as! CGFloat
                let scaleX = videoWidth / width
                let scaleY = videoHeight / height
                let scale = min(scaleX, scaleY, 1)
                let newWidth = width * scale
                let newHeight = height * scale
                var html = (dictJson["html"]! as! String).replacingOccurrences(of: "width=\"\(Int(width))\" height=\"\(Int(height))\"", with: "width=\"\(newWidth)\" height=\"\(newHeight)\"")
                html = solveSrcPb(html, s: "s")
                output = output?.replacingOccurrences(of: result, with: "<center>\(html)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildSlideshareLinks(_ inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "http:\\/{2}([a-z]|[0-9]|-|_)*\\.slideshare\\.net\\/\\w*\\/(\\w|-|_)*", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            let baseURL = "http://www.slideshare.net/api/oembed/2?"
            let formatString = "&format=json"
            for result in arrayResults {
                let urlString = "url=\(result)"
                let datasJson = getJSON(baseURL + urlString + formatString)
                let dictJson = parseJSON(datasJson)
                output = output?.replacingOccurrences(of: result, with: "<center>\(dictJson["html"]! as! String)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildTwitterLinks(_ inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}twitter\\.com\\/([a-z]|[0-9]|-|_)*\\/status\\/[0-9]*", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            let baseURL = "https://api.twitter.com/1/statuses/oembed.json?"
            for result in arrayResults {
                let urlString = "url=\(result)"
                let datasJson = getJSON(baseURL + urlString)
                let dictJson = parseJSON(datasJson)
                output = output?.replacingOccurrences(of: result, with: "\(dictJson["html"]! as! String)")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildVimeoLinks(_ inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https:\\/{2}vimeo\\.com\\/(\\w|\\/|-|_)*", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            let baseURL = "https://vimeo.com/api/oembed.json?"
            let maxWidth = "&width=\(Int(videoWidth))"
            for result in arrayResults {
                let urlString = "url=\(result)"
                let datasJson = getJSON(baseURL + urlString + maxWidth)
                let dictJson = parseJSON(datasJson)
                output = output?.replacingOccurrences(of: result, with: "<center>\(dictJson["html"]! as! String)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildYoutubeLinks(_ inText: String!) -> String {
        var output = inText
        do {
            // youtu.be
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}youtu\\.be\\/(\\w|-|_)*", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let videoCode = result.replacingOccurrences(of: "http://youtu.be/", with: "", options: NSString.CompareOptions.caseInsensitive, range: nil).replacingOccurrences(of: "https://youtu.be/", with: "", options: NSString.CompareOptions.caseInsensitive, range: nil)
                output = output?.replacingOccurrences(of: result, with: "<center><iframe width=\"\(videoWidth)\" height=\"\(videoHeight)\" src=\"https://www.youtube.com/embed/\(videoCode)\" frameborder=\"0\" allowfullscreen></iframe></center>")
            }
            // youtube.com/embed
            let regex2 = try NSRegularExpression(pattern: "http:\\/{2}youtube\\.com\\/embed\\/(\\w|-|_)*", options: .caseInsensitive)
            let nsString2 = inText as NSString
            let results2 = regex2.matches(in: inText, options: [], range: NSMakeRange(0, nsString2.length))
            let arrayResults2 = results2.map {nsString2.substring(with: $0.range)}
            for result in arrayResults2 {
                output = output?.replacingOccurrences(of: result, with: "<center><iframe width=\"\(videoWidth)\" height=\"\(videoHeight)\" src=\"\(result)\" frameborder=\"0\" allowfullscreen></iframe></center>")
            }
            
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildWebtvLinks(_ inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}webtv\\.ac-versailles\\.fr\\/(spip\\.php)?(\\?)?article[0-9]*", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            let baseURL = "http://webtv.ac-versailles.fr/oembed.api/?"
            let formatString = "format=json"
            for result in arrayResults {
                let urlString = "&url=\(result)"
                let datasJson = getJSON(baseURL + formatString + urlString)
                let dictJson = parseJSON(datasJson)
                let html = solveSrcPb(dictJson["html"]! as! String, s: "s")
                output = output?.replacingOccurrences(of: result, with: "<center>\(html)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func getJSON(_ urlToRequest: String) -> Data{
        return (try! Data(contentsOf: URL(string: urlToRequest)!))
        //return (try! Data(contentsOf: URL(string: urlToRequest)!))
    }
    
    func parseJSON(_ inputData: Data) -> NSDictionary{
        var boardsDictionary = NSDictionary()
        do {
            boardsDictionary = try JSONSerialization.jsonObject(with: inputData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return boardsDictionary
    }
    
    func pikipikiToHTML(_ text: String) -> String {
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
            if line.characters.count > 6 && line[line.characters.index(line.startIndex, offsetBy: 0)...line.characters.index(line.startIndex, offsetBy: 5)] != "<br />" {
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
                if line[line.characters.index(line.startIndex, offsetBy: 0)...line.characters.index(line.startIndex, offsetBy: 2)] != " * " {
                    if (levelList[1] == true) {
                        levelList[1] = false
                        replace = "</li>\n\t</ul>\n" + line
                    }
                }
                if line[line.characters.index(line.startIndex, offsetBy: 0)...line.characters.index(line.startIndex, offsetBy: 1)] != "* " {
                    if (levelList[0] == true && levelList[1] == false) {
                        levelList[0] = false
                        replace = "</li></ul>\n" + line
                    }
                }
                if line[line.characters.index(line.startIndex, offsetBy: 0)...line.characters.index(line.startIndex, offsetBy: 1)] == "* " {
                    if (levelList[0] == nil) {
                        levelList[0] = true
                        replace = "<ul>\n\t<li>"
                    }
                    else {
                        replace = "</li>\n<li>"
                    }
                    replace = replace + line[line.characters.index(line.startIndex, offsetBy: 2)...line.characters.index(before: line.endIndex)]
                }
                if line[line.characters.index(line.startIndex, offsetBy: 0)...line.characters.index(line.startIndex, offsetBy: 2)] == " * " { // 4
                    if (levelList[1] == nil) {
                        levelList[1] = true
                        replace = "<ul>\n\t<li>"
                    }
                    else {
                        replace = "\t<li>"
                    }
                    replace = replace + line[line.characters.index(line.startIndex, offsetBy: 3)...line.characters.index(before: line.endIndex)]
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
    
    func showAudio(_ inText: String) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}(\\w|\\/|\\.|-|\\%|\\#)*\\.(mp3|ogg)( autostart)?", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let autostartRange: NSRange = (result as NSString).range(of: " autostart")
                let dataState = (autostartRange.length > 0) ? "autostart" : "none"
                let mp3Result = result.replacingOccurrences(of: "\\.(mp3|ogg)( autostart)?", with: ".mp3", options:NSString.CompareOptions.regularExpression, range: nil)
                let oggResult = result.replacingOccurrences(of: "\\.(mp3|ogg)( autostart)?", with: ".ogg", options:NSString.CompareOptions.regularExpression, range: nil)
                let replaceString = "<center><audio controls data-state=\"\(dataState)\"><source type=\"audio/mpeg\" src=\"\(mp3Result)\" /><source type=\"audio/ogg\" src=\"\(oggResult)\" /></audio></center>";
                output = output.replacingOccurrences(of: result, with: replaceString)
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func showCustomLinks(_ inText: String) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "\\[https?:\\/{2}((?! ).)* *((?!\\]).)*\\]", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let text = result.replacingOccurrences(of: "\\[|\\]", with: "", options:NSString.CompareOptions.regularExpression, range: nil)
                let urlEndRange: NSRange = (text as NSString).range(of: " ")
                let url = (urlEndRange.length == 1) ? text[text.characters.index(text.startIndex, offsetBy: 0)...text.characters.index(text.startIndex, offsetBy: urlEndRange.location - 1)] : text
                let linkText = (urlEndRange.length == 1) ? text[text.characters.index(text.startIndex, offsetBy: urlEndRange.location+1)...text.characters.index(before: text.endIndex)] : text
                let replaceString = "<a href=\"\(url)\">\(linkText)</a>";
                output = output.replacingOccurrences(of: result, with: replaceString)
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func showPictures(_ inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}(\\w|\\/|\\.|-|\\%|\\#)*\\.(jpg|jpeg|gif|png)", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                output = output?.replacingOccurrences(of: result, with: "<img src=\"\(result)\" alt=\"\(result)\" style=\"max-width: \(videoWidth);\" />")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func showVideo(_ inText: String) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}(\\w|\\/|\\.|-|\\%|\\#)*\\.(mp4|ogv|webm)( autostart)?", options: .caseInsensitive)
            let nsString = inText as NSString
            let results = regex.matches(in: inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substring(with: $0.range)}
            for result in arrayResults {
                let autostartRange: NSRange = (result as NSString).range(of: " autostart")
                let dataState = (autostartRange.length > 0) ? "autostart" : "none"
                let mp4Result = result.replacingOccurrences(of: "\\.(mp4|ogv|webm)( autostart)?", with: ".mp4", options:NSString.CompareOptions.regularExpression, range: nil)
                let ogvResult = result.replacingOccurrences(of: "\\.(mp4|ogv|webm)( autostart)?", with: ".ogv", options:NSString.CompareOptions.regularExpression, range: nil)
                let webmResult = result.replacingOccurrences(of: "\\.(mp4|ogv|webm)( autostart)?", with: ".webm", options:NSString.CompareOptions.regularExpression, range: nil)
                let replaceString = "<center><video controls preload=\"none\" data-state=\"\(dataState)\" width=\"\(videoWidth)\" height=\"\(videoHeight)\"><source type=\"video/mp4\" src=\"\(mp4Result)\" /><source type=\"video/ogg\" src=\"\(ogvResult)\" /><source type=\"video/webm\" src=\"\(webmResult)\" /></video></center>";
                output = output.replacingOccurrences(of: result, with: replaceString)
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func solveSrcPb(_ intext: String, s: String = "") -> String {
        return intext.replacingOccurrences(of: "src=\"//", with: "src=\"http\(s)://")
    }
}
