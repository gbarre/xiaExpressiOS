//
//  PlayDetail.swift
//  xia4ipad
//
//  Created by Guillaume on 17/01/2016.
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

class PlayDetail: UIViewController, UIViewControllerTransitioningDelegate {
    
    var dbg = debug(enable: true)
    
    var tag: Int = 0
    var xml: AEXMLDocument = AEXMLDocument()
    var detail: xiaDetail!
    var path: UIBezierPath!
    var bkgdImage: UIImageView!
    var zoomDisable: Bool = true
    var showZoom: Bool = false
    var landscape: Bool = true
    
    let transition = BubbleTransition()
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height
    var currentScale: CGFloat = 1.0
    var currentCenter: CGPoint!
    var zoomScale: CGFloat = 1.0
    let transitionDuration: NSTimeInterval = 0.5
    
    var videoWidth: CGFloat = 480
    var videoHeight: CGFloat = 270
    
    @IBAction func close(sender: AnyObject) {
        if !showZoom {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBOutlet var popup: UIView!
    @IBOutlet var imgArea: UIView!
    @IBOutlet var imgThumb: UIImageView!
    @IBOutlet var titleArea: UIView!
    @IBOutlet var detailTitle: UILabel!
    @IBOutlet var descView: UIWebView!
    @IBOutlet var descViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var bkgdzoom: UIImageView!
    
    @IBAction func btnZoomAction(sender: AnyObject) {
        if !zoomDisable && !showZoom {
            showDetail(imgThumb)
        }
    }
    
    @IBAction func closeZoom(sender: AnyObject) {
        if showZoom {
            // Show / hide elements
            self.imgArea.hidden = false
            self.imgArea.alpha = 0
            descView.userInteractionEnabled = true
            UIView.animateWithDuration(transitionDuration) { () -> Void in
                self.imgThumb.transform = CGAffineTransformScale(self.imgThumb.transform, self.currentScale / self.zoomScale, self.currentScale / self.zoomScale)
                self.imgThumb.center = self.currentCenter
                self.bkgdzoom.alpha = 0
            }
            UIView.animateWithDuration(2 * transitionDuration) { () -> Void in
                self.imgArea.alpha = 1
                self.titleArea.alpha = 1
            }
            showZoom = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background must be larger the popup
        bkgdzoom.transform = CGAffineTransformScale(bkgdzoom.transform, 3, 3)
        
        imgThumb = UIImageView(frame: CGRect(x: 0, y: 0, width: bkgdImage.frame.width, height: bkgdImage.frame.height))
        imgThumb.contentMode = UIViewContentMode.ScaleAspectFit
        imgThumb.image = bkgdImage.image
        
        videoWidth = (landscape) ? 480 : 360
        videoHeight = (landscape) ? 270 : 210
        
        // Cropping image
        let myMask = CAShapeLayer()
        if tag != 0 {
            myMask.path = path.CGPath
            imgThumb.layer.mask = myMask
        }
        self.view.addSubview(imgThumb)
        imgThumb.hidden = true
        
        // Scaling cropped image to fit in the 200 x 200 square
        let pathFrameCorners = (tag != 0) ? detail.bezierFrame() : UIScreen.mainScreen().bounds
        let detailScaleX = (imgArea.frame.width - 10) / pathFrameCorners.width
        let detailScaleY = (imgArea.frame.height - 10) / pathFrameCorners.height
        let detailScale = min(detailScaleX, detailScaleY, 1) // 1 avoid to zoom if the detail is smaller than 200 x 200
        currentScale = detailScale
        imgThumb.transform = CGAffineTransformScale(imgThumb.transform, detailScale, detailScale)
        
        // Centering the cropped image in imgArea
        let pathCenter = CGPointMake(pathFrameCorners.midX * detailScale, pathFrameCorners.midY * detailScale)
        let newCenter = CGPointMake(imgThumb.center.x * detailScale - pathCenter.x + imgArea.center.x, imgThumb.center.y * detailScale - pathCenter.y + imgArea.center.y)
        imgThumb.center = newCenter
        
        // Show text
        var htmlString: String = ""
        if tag != 0 {
            if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(tag)"]) {
                for d in detail {
                    detailTitle.text = d.attributes["title"]
                    detailTitle.sizeToFit()
                    detailTitle.numberOfLines = 0
                    htmlString = (d.value != nil) ? d.value! : ""
                    zoomDisable = (d.attributes["zoom"] == "true") ? false : true
                }
            }
        }
        else {
            detailTitle.text = (xml["xia"]["image"].attributes["title"] != nil) ? xml["xia"]["image"].attributes["title"] : ""
            detailTitle.sizeToFit()
            detailTitle.numberOfLines = 0
            htmlString = (xml["xia"]["image"].attributes["description"] != nil) ? xml["xia"]["image"].attributes["description"]! : ""
            zoomDisable = false
        }
        
        // Build the webView
        htmlString = htmlString.stringByReplacingOccurrencesOfString("<", withString: "&lt;")
        htmlString = htmlString.stringByReplacingOccurrencesOfString(">", withString: "&gt;")
        htmlString = htmlString.stringByReplacingOccurrencesOfString("\n", withString: "<br />")
        htmlString = buildPicturesLinks(htmlString)

        // oembed
        htmlString = buildAudiolinguaLinks(htmlString)
        htmlString = buildDailymotionLinks(htmlString)
        htmlString = buildFlickrLinks(htmlString)
        htmlString = buildInstagramLinks(htmlString)
        htmlString = buildScolawebtvLinks(htmlString)
        htmlString = buildSlideshareLinks(htmlString)
        htmlString = buildVimeoLinks(htmlString)
        htmlString = buildYoutubeLinks(htmlString)
        htmlString = buildWebtvLinks(htmlString)
        
        
        //dbg.pt(htmlString)
        descView.loadHTMLString(htmlString, baseURL: nil)
        descView.allowsInlineMediaPlayback = true
        
        // wait 0.5s before showing image (bubbletransition effect)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * 500))
        dispatch_after(delayTime, dispatch_get_main_queue()){
            self.imgThumb.hidden = false
        }
    }
    
    // Disable round corners on modal view
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.superview!.layer.cornerRadius  = 0.0
        self.view.superview!.layer.masksToBounds = false
    }
    
    func buildAudiolinguaLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/\\/www\\.audio-lingua\\.eu\\/spip\\.php\\?article([0-9]*)", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                let audioCode = result.stringByReplacingOccurrencesOfString("http://www.audio-lingua.eu/spip.php?article", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<center><iframe frameborder=\"0\" width=\"\(videoWidth)\" height=\"120\" src=\"http://www.audio-lingua.eu/spip.php?page=mp3&id_article=\(audioCode)&color=00aaea\"></iframe></center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func buildDailymotionLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "http:\\/\\/dai\\.ly\\/(\\w|-|_)*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                let videoCode = result.stringByReplacingOccurrencesOfString("http://dai.ly/", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<center><iframe frameborder=\"0\" width=\"\(videoWidth)\" height=\"\(videoHeight)\" src=\"http://www.dailymotion.com/embed/video/\(videoCode)\" allowfullscreen></iframe></center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func buildInstagramLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https:\\/\\/www\\.instagram\\.com\\/p\\/(\\w|-|_)*\\/", options: .CaseInsensitive)
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
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<center><img src=\"\(thumbnailURL)\" alt=\"\(thumbnailURL)\" style=\"max-width: \(videoWidth);\" /><p><a href=\"\(result)\" style=\"color:#000; font-family:Arial,sans-serif; font-size:14px; font-style:normal; font-weight:normal; line-height:17px; text-decoration:none; word-wrap:break-word;\">\(title)</a></p><p>\(NSLocalizedString("PHOTO_PUBLISHED_BY", comment: "")) <a href=\"\(authorURL)\">@\(author)</a></p></center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func buildFlickrLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https:\\/\\/flic\\.kr\\/p\\/(\\w|-|_)*", options: .CaseInsensitive)
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
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<center>\(html)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func buildPicturesLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/\\/(\\w|\\/|\\.)*\\.(jpg|jpeg|gif|png)", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<img src=\"\(result)\" alt=\"\(result)\" style=\"max-width: \(videoWidth);\" />")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func buildScolawebtvLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/\\/scolawebtv\\.crdp-versailles\\.fr\\/\\?id=?[0-9]*", options: .CaseInsensitive)
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
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<center>\(html)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func buildSlideshareLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "http:\\/\\/[a-z]*\\.slideshare\\.net\\/\\w*\\/(\\w|-|_)*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            let baseURL = "http://www.slideshare.net/api/oembed/2?"
            let formatString = "&format=json"
            for result in arrayResults {
                let urlString = "url=\(result)"
                let datasJson = getJSON(baseURL + urlString + formatString)
                let dictJson = parseJSON(datasJson)
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<center>\(dictJson["html"]! as! String)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func buildVimeoLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https:\\/\\/vimeo\\.com\\/(\\w|\\/|-|_)*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            let baseURL = "https://vimeo.com/api/oembed.json?"
            let maxWidth = "&width=\(Int(videoWidth))"
            for result in arrayResults {
                let urlString = "url=\(result)"
                let datasJson = getJSON(baseURL + urlString + maxWidth)
                let dictJson = parseJSON(datasJson)
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<center>\(dictJson["html"]! as! String)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func buildYoutubeLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "http:\\/\\/youtu\\.be\\/(\\w|-|_)*", options: .CaseInsensitive)
            let nsString = inText as NSString
            let results = regex.matchesInString(inText, options: [], range: NSMakeRange(0, nsString.length))
            let arrayResults = results.map {nsString.substringWithRange($0.range)}
            for result in arrayResults {
                let videoCode = result.stringByReplacingOccurrencesOfString("http://youtu.be/", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<center><iframe width=\"\(videoWidth)\" height=\"\(videoHeight)\" src=\"https://www.youtube.com/embed/\(videoCode)\" frameborder=\"0\" allowfullscreen></iframe></center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func buildWebtvLinks(inText: String!) -> String {
        var output = inText
        do {
            let regex = try NSRegularExpression(pattern: "https?:\\/\\/webtv\\.ac-versailles\\.fr\\/(spip\\.php)?(\\?)?article[0-9]*", options: .CaseInsensitive)
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
                output = output.stringByReplacingOccurrencesOfString(result, withString: "<center>\(html)</center>")
            }
        } catch let error as NSError {
            dbg.pt(error.localizedDescription)
        }
        return output
    }
    
    func getJSON(urlToRequest: String) -> NSData{
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
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
    
    func showDetail(detailImg: UIImageView) {
        // Show / hide elements
        self.bkgdzoom.hidden = false
        self.bkgdzoom.alpha = 0
        descView.userInteractionEnabled = false
        showZoom = true
        
        currentCenter = detailImg.center
        
        // Scale the detail
        let detailScaleX = (screenWidth - 10) / detail.bezierFrame().width
        let detailScaleY = (screenHeight - 50) / detail.bezierFrame().height
        let detailScale = min(detailScaleX, detailScaleY, 3) // 3 is maximum zoom
        zoomScale = detailScale
        
        UIView.animateWithDuration(transitionDuration) { () -> Void in
            self.bkgdzoom.alpha = 1
            self.titleArea.alpha = 0
            self.imgArea.alpha = 0
            detailImg.transform = CGAffineTransformScale(detailImg.transform, detailScale / self.currentScale, detailScale / self.currentScale)
        }
        
        // Center the detail
        let distanceX = screenWidth/2 - detail.bezierFrame().midX
        let distanceY = screenHeight/2 - detail.bezierFrame().midY
        
        let newCenter = CGPointMake(screenWidth/2 + distanceX * detailScale - getCenter().x + 100, screenHeight/2 + distanceY * detailScale - getCenter().y + 100)
        
        UIView.animateWithDuration(transitionDuration) { () -> Void in
            detailImg.center = newCenter
        }
        
        UIView.animateWithDuration(transitionDuration / 10) { () -> Void in
            self.imgArea.alpha = 0
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC * 500))
        dispatch_after(delayTime, dispatch_get_main_queue()){
            self.imgArea.hidden = true
        }
    }
    
    func solveSrcPb(intext: String, s: String = "") -> String {
        return intext.stringByReplacingOccurrencesOfString("src=\"//", withString: "src=\"http\(s)://")
    }
    
}
