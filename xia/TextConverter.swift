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
        
        htmlString = htmlString.stringByReplacingOccurrencesOfString("&", withString: "&amp;")
        htmlString = htmlString.stringByReplacingOccurrencesOfString("<", withString: "&lt;")
        htmlString = htmlString.stringByReplacingOccurrencesOfString(">", withString: "&gt;")
        htmlString = htmlString.stringByReplacingOccurrencesOfString("\n", withString: "<br />")
        
        htmlString = pikipikiToHTML(htmlString)
        htmlString = htmlString.stringByReplacingOccurrencesOfString("}}}", withString: "")
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
        
        //dbg.pt(htmlString)
        
        return htmlString
    }
    
    func buildAudiolinguaLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}www\\.audio-lingua\\.eu\\/spip\\.php\\?article([0-9]*)", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                let audioCode = result.stringByReplacingOccurrencesOfString("http://www.audio-lingua.eu/spip.php?article", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "<center><iframe frameborder=\"0\" width=\"\(videoWidth)\" height=\"120\" src=\"http://www.audio-lingua.eu/spip.php?page=mp3&id_article=\(audioCode)&color=00aaea\"></iframe></center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildDailymotionLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "http:\\/{2}dai\\.ly\\/(\\w|-|_)*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                let videoCode = result.stringByReplacingOccurrencesOfString("http://dai.ly/", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "<center><iframe frameborder=\"0\" width=\"\(videoWidth)\" height=\"\(videoHeight)\" src=\"http://www.dailymotion.com/embed/video/\(videoCode)\" allowfullscreen></iframe></center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildInstagramLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https:\\/{2}www\\.instagram\\.com\\/p\\/(\\w|-|_)*\\/", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            let baseURL = "https://api.instagram.com/oembed?"
            for result in arrayResults {
                let urlString = "url=\(result)"
                
                let datasJson = getJSON(baseURL + urlString + "&omitscript=true")
                let dictJson = parseJSON(datasJson)
                let author = dictJson["author_name"]! as! String
                let authorURL = dictJson["author_url"]! as! String
                let thumbnailURL = dictJson["thumbnail_url"]! as! String
                let title = dictJson["title"]! as! String
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "<center><img src=\"\(thumbnailURL)\" alt=\"\(thumbnailURL)\" style=\"max-width: \(videoWidth);\" /><p><a href=\"\(result)\" style=\"color:#000; font-family:Arial,sans-serif; font-size:14px; font-style:normal; font-weight:normal; line-height:17px; text-decoration:none; word-wrap:break-word;\">\(title)</a></p><p>\(NSLocalizedString("PHOTO_PUBLISHED_BY", comment: "")) <a href=\"\(authorURL)\">@\(author)</a></p></center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildFlickrLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https:\\/{2}flic\\.kr\\/p\\/(\\w|-|_)*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
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
                let html = (dictJson["html"]! as! String).stringByReplacingOccurrencesOfString("width=\"\(Int(width))\" height=\"\(Int(height))\"", withString: "width=\"\(newWidth)\" height=\"\(newHeight)\"")
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "<center>\(html)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildScolawebtvLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}scolawebtv\\.crdp-versailles\\.fr\\/\\?id=?[0-9]*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
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
                var html = (dictJson["html"]! as! String).stringByReplacingOccurrencesOfString("width=\"\(Int(width))\" height=\"\(Int(height))\"", withString: "width=\"\(newWidth)\" height=\"\(newHeight)\"")
                html = solveSrcPb(html, s: "s")
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "<center>\(html)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildSlideshareLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "http:\\/{2}([a-z]|[0-9]|-|_)*\\.slideshare\\.net\\/\\w*\\/(\\w|-|_)*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            let baseURL = "http://www.slideshare.net/api/oembed/2?"
            let formatString = "&format=json"
            for result in arrayResults {
                let urlString = "url=\(result)"
                let datasJson = getJSON(baseURL + urlString + formatString)
                let dictJson = parseJSON(datasJson)
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "<center>\(dictJson["html"]! as! String)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildTwitterLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}twitter\\.com\\/([a-z]|[0-9]|-|_)*\\/status\\/[0-9]*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            let baseURL = "https://api.twitter.com/1/statuses/oembed.json?"
            for result in arrayResults {
                let urlString = "url=\(result)"
                let datasJson = getJSON(baseURL + urlString)
                let dictJson = parseJSON(datasJson)
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "\(dictJson["html"]! as! String)")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildVimeoLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https:\\/{2}vimeo\\.com\\/(\\w|\\/|-|_)*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            let baseURL = "https://vimeo.com/api/oembed.json?"
            let maxWidth = "&width=\(Int(videoWidth))"
            for result in arrayResults {
                let urlString = "url=\(result)"
                let datasJson = getJSON(baseURL + urlString + maxWidth)
                let dictJson = parseJSON(datasJson)
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "<center>\(dictJson["html"]! as! String)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildYoutubeLinks(inText: String!) -> String {
        var output = inText
        do {
            // youtu.be
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}youtu\\.be\\/(\\w|-|_)*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                let videoCode = result.stringByReplacingOccurrencesOfString("http://youtu.be/", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "<center><iframe width=\"\(videoWidth)\" height=\"\(videoHeight)\" src=\"https://www.youtube.com/embed/\(videoCode)\" frameborder=\"0\" allowfullscreen></iframe></center>")
            }
            // youtube.com/embed
            let regex2 = try NSRegularExpression(pattern: "http:\\/{2}youtube\\.com\\/embed\\/(\\w|-|_)*", options: .CaseInsensitive)
            let nsString2 = inText as NSString
            let results2 = regex2.matchesInString(inText, options: [], range: NSMakeRange(0, nsString2.length))
            let arrayResults2 = results2.map {nsString2.substringWithRange($0.range)}
            for result in arrayResults2 {
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "<center><iframe width=\"\(videoWidth)\" height=\"\(videoHeight)\" src=\"\(result)\" frameborder=\"0\" allowfullscreen></iframe></center>")
            }
            
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func buildWebtvLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}webtv\\.ac-versailles\\.fr\\/(spip\\.php)?(\\?)?article[0-9]*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            let baseURL = "http://webtv.ac-versailles.fr/oembed.api/?"
            let formatString = "format=json"
            for result in arrayResults {
                let urlString = "&url=\(result)"
                let datasJson = getJSON(baseURL + formatString + urlString)
                let dictJson = parseJSON(datasJson)
                let html = solveSrcPb(dictJson["html"]! as! String, s: "s")
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "<center>\(html)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func getJSON(urlToRequest: String) -> NSData{
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
        //return (try! Data(contentsOf: URL(string: urlToRequest)!))
    }
    
    func parseJSON(inputData: NSData) -> NSDictionary{
        var boardsDictionary = NSDictionary()
        do {
            boardsDictionary = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        } catch let error as NSError {
            dbg.pt(error)
        }
        return boardsDictionary
    }
    
    func pikipikiToHTML(text: String) -> String {
        var output = text
        // Make bold
        do {
            let regex = try NSRegularExpression(pattern: "(\\*){3}((?!\\*{3}).)*\\*{3}", options: .CaseInsensitive)
            let nsString = output as NSString
            let results = regex.matchesInString(output, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                let cleanResult = result.stringByReplacingOccurrencesOfString("***", withString: "")
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<b>\(cleanResult)</b>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        
        // Make emphasize
        do {
            let regex = try NSRegularExpression(pattern: "(\\*){2}((?!\\*{2}).)*\\*{2}", options: .CaseInsensitive)
            let nsString = output as NSString
            let results = regex.matchesInString(output, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                let cleanResult = result.stringByReplacingOccurrencesOfString("**", withString: "")
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<em>\(cleanResult)</em>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        
        // Make pre-formatted
        do {
            let regex = try NSRegularExpression(pattern: "(\\{){3}((?!\\{{3}).)*\\}{3}", options: .CaseInsensitive)
            let nsString = output as NSString
            let results = regex.matchesInString(output, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                var cleanResult = result.stringByReplacingOccurrencesOfString("{{{", withString: "")
                cleanResult = cleanResult.stringByReplacingOccurrencesOfString("}}}", withString: "")
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<pre>\n\(cleanResult)</pre>\n")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        
        // Make line
        output = output.stringByReplacingOccurrencesOfString("-----", withString: "<hr size=3/>")
        output = output.stringByReplacingOccurrencesOfString("----", withString: "<hr/>")
        
        // Make list line by line
        let outputArray = output.componentsSeparatedByString("<br />")
        let nbLines = outputArray.count
        var onLine = 0
        var levelList = [Int:Bool]()
        var previousLine = ""
        for line in outputArray {
            var replace = line
            if line.characters.count > 6 && line[line.startIndex.advancedBy(0)...line.startIndex.advancedBy(5)] != "<br />" {
                replace = line.stringByReplacingOccurrencesOfString("<br />", withString: "")
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
                if line[line.startIndex.advancedBy(0)...line.startIndex.advancedBy(2)] != " * " {
                    if (levelList[1] == true) {
                        levelList[1] = false
                        replace = "</li>\n\t</ul>\n" + line
                    }
                }
                if line[line.startIndex.advancedBy(0)...line.startIndex.advancedBy(1)] != "* " {
                    if (levelList[0] == true && levelList[1] == false) {
                        levelList[0] = false
                        replace = "</li></ul>\n" + line
                    }
                }
                if line[line.startIndex.advancedBy(0)...line.startIndex.advancedBy(1)] == "* " {
                    if (levelList[0] == nil) {
                        levelList[0] = true
                        replace = "<ul>\n\t<li>"
                    }
                    else {
                        replace = "</li>\n<li>"
                    }
                    replace = replace + line[line.startIndex.advancedBy(2)...line.endIndex.predecessor()]
                }
                if line[line.startIndex.advancedBy(0)...line.startIndex.advancedBy(2)] == " * " { // 4
                    if (levelList[1] == nil) {
                        levelList[1] = true
                        replace = "<ul>\n\t<li>"
                    }
                    else {
                        replace = "\t<li>"
                    }
                    replace = replace + line[line.startIndex.advancedBy(3)...line.endIndex.predecessor()]
                }
                output = output.stringByReplacingOccurrencesOfString(line, withString: replace)
                previousLine = replace
            }
            else {
                if (levelList[1] == true) {
                    levelList[1] = false
                    replace = previousLine + "</li>\n\t</ul></li>\n</ul>\n" + line
                    output = output.stringByReplacingOccurrencesOfString(previousLine, withString: replace)
                }
                else if (levelList[0] == true) {
                    levelList[0] = false
                    replace = previousLine + "</li>\n</ul>\n" + line
                    output = output.stringByReplacingOccurrencesOfString(previousLine, withString: replace)
                }
                previousLine = line
            }
            onLine = onLine + 1
        }
        
        return output
    }
    
    func showAudio(inText: String) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}(\\w|\\/|\\.|-|\\%|\\#)*\\.(mp3|ogg)( autostart)?", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                let autostartRange: NSRange = (result as NSString).rangeOfString(" autostart")
                let dataState = (autostartRange.length > 0) ? "autostart" : "none"
                let mp3Result = result.stringByReplacingOccurrencesOfString("\\.(mp3|ogg)( autostart)?", withString: ".mp3", options:NSStringCompareOptions.RegularExpressionSearch, range: nil)
                let oggResult = result.stringByReplacingOccurrencesOfString("\\.(mp3|ogg)( autostart)?", withString: ".ogg", options:NSStringCompareOptions.RegularExpressionSearch, range: nil)
                let replaceString = "<center><audio controls data-state=\"\(dataState)\"><source type=\"audio/mpeg\" src=\"\(mp3Result)\" /><source type=\"audio/ogg\" src=\"\(oggResult)\" /></audio></center>";
                output = output.stringByReplacingOccurrencesOfString(result, withString: replaceString)
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func showCustomLinks(inText: String) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "\\[https?:\\/{2}((?! ).)* *((?!\\]).)*\\]", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                let text = result.stringByReplacingOccurrencesOfString("\\[|\\]", withString: "", options:NSStringCompareOptions.RegularExpressionSearch, range: nil)
                let urlEndRange: NSRange = (text as NSString).rangeOfString(" ")
                let url = (urlEndRange.length == 1) ? text[text.startIndex.advancedBy(0)...text.startIndex.advancedBy(urlEndRange.location - 1)] : text
                let linkText = (urlEndRange.length == 1) ? text[text.startIndex.advancedBy(urlEndRange.location+1)...text.endIndex.predecessor()] : text
                let replaceString = "<a href=\"\(url)\">\(linkText)</a>";
                output = output.stringByReplacingOccurrencesOfString(result, withString: replaceString)
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func showPictures(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}(\\w|\\/|\\.|-|\\%|\\#)*\\.(jpg|jpeg|gif|png)", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                output = output?.stringByReplacingOccurrencesOfString(result, withString: "<img src=\"\(result)\" alt=\"\(result)\" style=\"max-width: \(videoWidth);\" />")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output!
    }
    
    func showVideo(inText: String) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/{2}(\\w|\\/|\\.|-|\\%|\\#)*\\.(mp4|ogv|webm)( autostart)?", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                let autostartRange: NSRange = (result as NSString).rangeOfString(" autostart")
                let dataState = (autostartRange.length > 0) ? "autostart" : "none"
                let mp4Result = result.stringByReplacingOccurrencesOfString("\\.(mp4|ogv|webm)( autostart)?", withString: ".mp4", options:NSStringCompareOptions.RegularExpressionSearch, range: nil)
                let ogvResult = result.stringByReplacingOccurrencesOfString("\\.(mp4|ogv|webm)( autostart)?", withString: ".ogv", options:NSStringCompareOptions.RegularExpressionSearch, range: nil)
                let webmResult = result.stringByReplacingOccurrencesOfString("\\.(mp4|ogv|webm)( autostart)?", withString: ".webm", options:NSStringCompareOptions.RegularExpressionSearch, range: nil)
                let replaceString = "<center><video controls preload=\"none\" data-state=\"\(dataState)\" width=\"\(videoWidth)\" height=\"\(videoHeight)\"><source type=\"video/mp4\" src=\"\(mp4Result)\" /><source type=\"video/ogg\" src=\"\(ogvResult)\" /><source type=\"video/webm\" src=\"\(webmResult)\" /></video></center>";
                output = output.stringByReplacingOccurrencesOfString(result, withString: replaceString)
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func solveSrcPb(intext: String, s: String = "") -> String {
        return intext.stringByReplacingOccurrencesOfString("src=\"//", withString: "src=\"http\(s)://")
    }
}
