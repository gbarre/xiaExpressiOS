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
    
    func test_print_html1( ) {
        let raw = "**text**"
        let expected_output = "<em>text</em>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html2( ) {
        let raw = "***text***"
        let expected_output = "<b>text</b>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html3( ) {
        let raw = "{{{text}}}"
        let expected_output = "<pre>\ntext</pre>\n"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html4( ) {
        let raw = "http://example.com/photo.jpg"
        let expected_output = "<img src=\"http://example.com/photo.jpg\" alt=\"http://example.com/photo.jpg\" style=\"max-width: \(videoWidth)px;\" />"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html5( ) {
        let raw = "http://example.com/photo.jpeg"
        let expected_output = "<img src=\"http://example.com/photo.jpeg\" alt=\"http://example.com/photo.jpeg\" style=\"max-width: \(videoWidth)px;\" />"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html6( ) {
        let raw = "http://example.com/photo.png"
        let expected_output = "<img src=\"http://example.com/photo.png\" alt=\"http://example.com/photo.png\" style=\"max-width: \(videoWidth)px;\" />"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html7( ) {
        let raw = "http://example.com/photo.gif"
        let expected_output = "<img src=\"http://example.com/photo.gif\" alt=\"http://example.com/photo.gif\" style=\"max-width: \(videoWidth)px;\" />"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html8( ) {
        let raw = "<&>"
        let expected_output = "&lt;&amp;&gt;"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html9( ) {
        let raw = "----"
        let expected_output = "<hr/>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html10( ) {
        let raw = "-----"
        let expected_output = "<hr size=3/>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html11( ) {
        let raw = "* line 1\n* line2\n"
        let expected_output = "<ul>\n\t<li>line 1<br /></li>\n<li>line2</li>\n</ul>\n<br />"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html12( ) {
        let raw = "* ***line 1***\n* [http://test.fr line2]\n"
        let expected_output = "<ul>\n\t<li><b>line 1</b><br /></li>\n<li><a href=\"http://test.fr\">line2</a></li>\n</ul>\n<br />"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html13( ) {
        let raw = "* line 1\n * line2\n"
        let expected_output = "<ul>\n\t<li>line 1<br /><ul>\n\t<li>line2</li>\n\t</ul></li>\n</ul>\n<br />"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html14( ) {
        let raw = "http://example.com/video.mp4"
        let expected_output = "<center><video controls preload=\"none\" width=\"\(videoWidth)\" height=\"\(videoHeight)\"><source type=\"video/mp4\" src=\"http://example.com/video.mp4\" /><source type=\"video/ogg\" src=\"http://example.com/video.ogv\" /><source type=\"video/webm\" src=\"http://example.com/video.webm\" /></video></center>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html15( ) {
        let raw = "http://example.com/video.ogv"
        let expected_output = "<center><video controls preload=\"none\" width=\"\(videoWidth)\" height=\"\(videoHeight)\"><source type=\"video/mp4\" src=\"http://example.com/video.mp4\" /><source type=\"video/ogg\" src=\"http://example.com/video.ogv\" /><source type=\"video/webm\" src=\"http://example.com/video.webm\" /></video></center>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html16( ) {
        let raw = "http://example.com/video.webm"
        let expected_output = "<center><video controls preload=\"none\" width=\"\(videoWidth)\" height=\"\(videoHeight)\"><source type=\"video/mp4\" src=\"http://example.com/video.mp4\" /><source type=\"video/ogg\" src=\"http://example.com/video.ogv\" /><source type=\"video/webm\" src=\"http://example.com/video.webm\" /></video></center>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html17( ) {
        let raw = "http://example.com/audio.mp3"
        let expected_output = "<center><audio controls><source type=\"audio/mpeg\" src=\"http://example.com/audio.mp3\" /><source type=\"audio/ogg\" src=\"http://example.com/audio.ogg\" /><source type=\"audio/m4a\" src=\"http://example.com/audio.m4a\" /></audio></center>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html18( ) {
        let raw = "http://example.com/audio.ogg"
        let expected_output = "<center><audio controls><source type=\"audio/mpeg\" src=\"http://example.com/audio.mp3\" /><source type=\"audio/ogg\" src=\"http://example.com/audio.ogg\" /><source type=\"audio/m4a\" src=\"http://example.com/audio.m4a\" /></audio></center>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html19( ) {
        let raw = "http://example.com/audio.m4a"
        let expected_output = "<center><audio controls><source type=\"audio/mpeg\" src=\"http://example.com/audio.mp3\" /><source type=\"audio/ogg\" src=\"http://example.com/audio.ogg\" /><source type=\"audio/m4a\" src=\"http://example.com/audio.m4a\" /></audio></center>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html20( ) {
        let raw = "[http://example.com A small test]"
        let expected_output = "<a href=\"http://example.com\">A small test</a>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html21( ) {
        let raw = "[http://example.com]"
        let expected_output = "<a href=\"http://example.com\">http://example.com</a>"
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html22( ) {
        let raw = " "
        let expected_output = " "
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
    
    func test_print_html23( ) {
        let raw = "}}}"
        let expected_output = ""
        let output = converter._text2html(inText: raw)
        XCTAssertEqual(expected_output, output)
    }
}
