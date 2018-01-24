//
//  ViewImport.swift
//  xia
//
//  Created by Guillaume on 24/01/2018.
//  Copyright © 2018 Dane Versailles. All rights reserved.
//

import UIKit

class ViewImport: UITableViewController {
    
    var importingFiles = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentsDirectory)
            for file in files {
                if file.prefix(9) == "importing" {
                    let title = quickTitleSearch(file)
                    importingFiles.append(title)
                }
            }
        } catch {
            dbg.pt(error.localizedDescription)
        }
        importingFiles.sort()
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let height = (importingFiles.count) * 45
        self.preferredContentSize = CGSize(width: 300, height: height)
        return importingFiles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "importIdentifier", for: indexPath)

        cell.textLabel?.text = importingFiles[indexPath.row]

        return cell
    }
    
    func quickTitleSearch(_ fileName: String, maxLine: Int = 10) -> String {
        var i = 0
        let file = fopen(documentsDirectory + "/" + fileName,"r") // open the file stream
        for line in lineGenerator(file: file!) {
            let cleanLine = line.replacingOccurrences(of: "\\t", with: "")
            if i < 10 {
                do {
                    let regex = try NSRegularExpression(pattern: "(\\t?)*<title>.*", options: .caseInsensitive)
                    let nsString = cleanLine as NSString
                    let results = regex.matches(in: cleanLine, options: [], range: NSMakeRange(0, nsString.length))
                    let arrayResults = results.map {nsString.substring(with: $0.range)}
                    for result in arrayResults {
                        let cleanResult = result.replacingOccurrences(of: "</title>", with: "").replacingOccurrences(of: "<title>", with: "").replacingOccurrences(of: "\t", with: "")
                        return cleanLine.replacingOccurrences(of: result, with: cleanResult)
                    }
                    i = i + 1
                } catch let error as NSError {
                        dbg.pt(error.localizedDescription)
                }
            }
            else {
                break
            }
        }
        return String(fileName.prefix(fileName.count - 4))
    }
}
