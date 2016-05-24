//
//  TextConvertersTest.swift
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

import XCTest

class TextConvertersTest: XCTestCase {
    
    let videoWidth: CGFloat = 480
    let videoHeight: CGFloat = 270
    let converter = TextConverter(videoWidth: 480, videoHeight: 270)
    
    func test_print_html( ) {
        let raw = "**text**"
        let expected_output = "<em>text</em>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html2( ) {
        let raw = "***text***"
        let expected_output = "<b>text</b>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html3( ) {
        let raw = "{{{text}}}"
        let expected_output = "<pre>\ntext</pre>\n"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html4( ) {
        let raw = "http://example.com/photo.jpg"
        let expected_output = "<img src=\"http://example.com/photo.jpg\" alt=\"http://example.com/photo.jpg\" style=\"max-width: \(videoWidth);\" />"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html5( ) {
        let raw = "http://example.com/photo.jpeg"
        let expected_output = "<img src=\"http://example.com/photo.jpeg\" alt=\"http://example.com/photo.jpeg\" style=\"max-width: \(videoWidth);\" />"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html6( ) {
        let raw = "http://example.com/photo.png"
        let expected_output = "<img src=\"http://example.com/photo.png\" alt=\"http://example.com/photo.png\" style=\"max-width: \(videoWidth);\" />"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html7( ) {
        let raw = "http://example.com/photo.gif"
        let expected_output = "<img src=\"http://example.com/photo.gif\" alt=\"http://example.com/photo.gif\" style=\"max-width: \(videoWidth);\" />"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html8( ) {
        let raw = "<&>"
        let expected_output = "&lt;&amp;&gt;"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html9( ) {
        let raw = "----"
        let expected_output = "<hr/>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html10( ) {
        let raw = "-----"
        let expected_output = "<hr size=3/>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html11( ) {
        let raw = "* line 1\n* line2\n"
        let expected_output = "<ul>\n\t<li>line 1<br /></li>\n<li>line2</li>\n</ul>\n<br />"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html12( ) {
        let raw = "* ***line 1***\n* [http://test.fr line2]\n"
        let expected_output = "<ul>\n\t<li><b>line 1</b><br /></li>\n<li><a href=\"http://test.fr\">line2</a></li>\n</ul>\n<br />"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html13( ) {
        let raw = "* line 1\n * line2\n"
        let expected_output = "<ul>\n\t<li>line 1<br /><ul>\n\t<li>line2</li>\n\t</ul></li>\n</ul>\n<br />"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html14( ) {
        let raw = "http://example.com/video.mp4"
        let expected_output = "<center><video controls preload=\"none\" data-state=\"none\" width=\"\(videoWidth)\" height=\"\(videoHeight)\"><source type=\"video/mp4\" src=\"http://example.com/video.mp4\" /><source type=\"video/ogg\" src=\"http://example.com/video.ogv\" /><source type=\"video/webm\" src=\"http://example.com/video.webm\" /></video></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html15( ) {
        let raw = "http://example.com/video.mp4 autostart"
        let expected_output = "<center><video controls preload=\"none\" data-state=\"autostart\" width=\"\(videoWidth)\" height=\"\(videoHeight)\"><source type=\"video/mp4\" src=\"http://example.com/video.mp4\" /><source type=\"video/ogg\" src=\"http://example.com/video.ogv\" /><source type=\"video/webm\" src=\"http://example.com/video.webm\" /></video></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html16( ) {
        let raw = "http://example.com/video.ogv"
        let expected_output = "<center><video controls preload=\"none\" data-state=\"none\" width=\"\(videoWidth)\" height=\"\(videoHeight)\"><source type=\"video/mp4\" src=\"http://example.com/video.mp4\" /><source type=\"video/ogg\" src=\"http://example.com/video.ogv\" /><source type=\"video/webm\" src=\"http://example.com/video.webm\" /></video></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html17( ) {
        let raw = "http://example.com/video.webm"
        let expected_output = "<center><video controls preload=\"none\" data-state=\"none\" width=\"\(videoWidth)\" height=\"\(videoHeight)\"><source type=\"video/mp4\" src=\"http://example.com/video.mp4\" /><source type=\"video/ogg\" src=\"http://example.com/video.ogv\" /><source type=\"video/webm\" src=\"http://example.com/video.webm\" /></video></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html18( ) {
        let raw = "http://example.com/audio.mp3"
        let expected_output = "<center><audio controls data-state=\"none\"><source type=\"audio/mpeg\" src=\"http://example.com/audio.mp3\" /><source type=\"audio/ogg\" src=\"http://example.com/audio.ogg\" /></audio></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html19( ) {
        let raw = "http://example.com/audio.ogg"
        let expected_output = "<center><audio controls data-state=\"none\"><source type=\"audio/mpeg\" src=\"http://example.com/audio.mp3\" /><source type=\"audio/ogg\" src=\"http://example.com/audio.ogg\" /></audio></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html20( ) {
        let raw = "http://example.com/audio.mp3 autostart"
        let expected_output = "<center><audio controls data-state=\"autostart\"><source type=\"audio/mpeg\" src=\"http://example.com/audio.mp3\" /><source type=\"audio/ogg\" src=\"http://example.com/audio.ogg\" /></audio></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html21( ) {
        let raw = "http://example.com/audio.ogg autostart"
        let expected_output = "<center><audio controls data-state=\"autostart\"><source type=\"audio/mpeg\" src=\"http://example.com/audio.mp3\" /><source type=\"audio/ogg\" src=\"http://example.com/audio.ogg\" /></audio></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html22( ) {
        let raw = "[http://example.com A small test]"
        let expected_output = "<a href=\"http://example.com\">A small test</a>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html23( ) {
        let raw = "[http://example.com]"
        let expected_output = "<a href=\"http://example.com\">http://example.com</a>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html24( ) {
        let raw = " "
        let expected_output = " "
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html25( ) {
        let raw = "}}}"
        let expected_output = ""
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html26( ) {
        let raw = "http://www.audio-lingua.eu/spip.php?article4826"
        let expected_output = "<center><iframe frameborder=\"0\" width=\"\(videoWidth)\" height=\"120\" src=\"http://www.audio-lingua.eu/spip.php?page=mp3&id_article=4826&color=00aaea\"></iframe></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html27( ) {
        let raw = "http://dai.ly/x42ehc2"
        let expected_output = "<center><iframe frameborder=\"0\" width=\"\(videoWidth)\" height=\"\(videoHeight)\" src=\"http://www.dailymotion.com/embed/video/x42ehc2\" allowfullscreen></iframe></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html28( ) {
        let raw = "https://www.instagram.com/p/BFrgVznQfdT/"
        let expected_output = "<center><img src=\"https://scontent-cdg2-1.cdninstagram.com/t51.2885-15/s640x640/e15/13248888_862328127227573_1296951348_n.jpg?ig_cache_key=MTI1NTIzOTE1NzE2OTY0OTQ5MQ%3D%3D.2\" alt=\"https://scontent-cdg2-1.cdninstagram.com/t51.2885-15/s640x640/e15/13248888_862328127227573_1296951348_n.jpg?ig_cache_key=MTI1NTIzOTE1NzE2OTY0OTQ5MQ%3D%3D.2\" style=\"max-width: 480.0;\" /><p><a href=\"https://www.instagram.com/p/BFrgVznQfdT/\" style=\"color:#000; font-family:Arial,sans-serif; font-size:14px; font-style:normal; font-weight:normal; line-height:17px; text-decoration:none; word-wrap:break-word;\">Thank you thank you thank you!</a></p><p>\(NSLocalizedString("PHOTO_PUBLISHED_BY", comment: "")) <a href=\"https://www.instagram.com/danicapatrick\">@danicapatrick</a></p></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html29( ) {
        let raw = "https://flic.kr/p/5xrLEU"
        let expected_output = "<center><a data-flickr-embed=\"true\" href=\"https://www.flickr.com/photos/fousdunet/2981266520/\" title=\"P1000924 by fousdunet, on Flickr\"><img src=\"https://farm4.staticflickr.com/3013/2981266520_bfd7e888a2_b.jpg\" width=\"360.0\" height=\"270.0\" alt=\"P1000924\"></a><script async src=\"https://embedr.flickr.com/assets/client-code.js\" charset=\"utf-8\"></script></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html30( ) {
        let raw = "https://scolawebtv.crdp-versailles.fr/?id=10125"
        let expected_output = "<center><iframe src=\"https://scolawebtv.crdp-versailles.fr/?iframe&id=10125\" width=\"480.0\" height=\"269.6\" frameborder=\"0\" allowfullscreen></iframe></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html31( ) {
        let raw = "http://fr.slideshare.net/haraldf/business-quotes-for-2011"
        let expected_output = "<center><iframe src=\"https://www.slideshare.net/slideshow/embed_code/key/6PCWPGFw9SwsAY\" width=\"427\" height=\"356\" frameborder=\"0\" marginwidth=\"0\" marginheight=\"0\" scrolling=\"no\" style=\"border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;\" allowfullscreen> </iframe> <div style=\"margin-bottom:5px\"> <strong> <a href=\"https://www.slideshare.net/haraldf/business-quotes-for-2011\" title=\"Business Quotes for 2011\" target=\"_blank\">Business Quotes for 2011</a> </strong> from <strong><a href=\"http://www.slideshare.net/haraldf\" target=\"_blank\">Harald Felgner (PhD)</a></strong> </div>\n\n</center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html32( ) {
        let raw = "https://vimeo.com/staff/player"
        let expected_output = "<center><iframe src=\"https://player.vimeo.com/video/76979871\" width=\"480\" height=\"270\" frameborder=\"0\" title=\"The New Vimeo Player (You Know, For Videos)\" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html33( ) {
        let raw = "https://youtu.be/oes3P0sbl5w"
        let expected_output = "<center><iframe width=\"480.0\" height=\"270.0\" src=\"https://www.youtube.com/embed/https://youtu.be/oes3P0sbl5w\" frameborder=\"0\" allowfullscreen></iframe></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html34( ) {
        let raw = "https://scolawebtv.crdp-versailles.fr/?id=10125"
        let expected_output = "<center><iframe src=\"https://scolawebtv.crdp-versailles.fr/?iframe&id=10125\" width=\"480.0\" height=\"269.6\" frameborder=\"0\" allowfullscreen></iframe></center>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html35( ) {
        let raw = "https://twitter.com/ChrisFiasson/status/707570099369148416"
        let expected_output = "<blockquote class=\"twitter-tweet\"><p lang=\"fr\" dir=\"ltr\">Présentation en exclusivité pour <a href=\"https://twitter.com/hashtag/educatectice?src=hash\">#educatectice</a> de la version tablette de <a href=\"https://twitter.com/hashtag/xia?src=hash\">#xia</a> ! <a href=\"https://twitter.com/hashtag/beta?src=hash\">#beta</a> <a href=\"https://twitter.com/hashtag/iPad?src=hash\">#iPad</a> <a href=\"https://twitter.com/DANEVersailles\">@DANEVersailles</a> <a href=\"https://t.co/KluLREhnI3\">pic.twitter.com/KluLREhnI3</a></p>&mdash; Christine FIASSON (@ChrisFiasson) <a href=\"https://twitter.com/ChrisFiasson/status/707570099369148416\">March 9, 2016</a></blockquote>\n<script async src=\"//platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>"
        let output = converter._text2html(raw)
        XCTAssertEqual(expected_output, output)
    }
}
