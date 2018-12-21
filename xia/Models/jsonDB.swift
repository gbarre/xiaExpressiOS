//
//  jsonDB.swift
//  xia
//
//  Created by Guillaume on 27/09/2017.
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

class jsonDB: NSObject {
    
    var path: String
    var dict = [String: NSDictionary]()
    
    init(p: String){
        self.path = p
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError(fatalErrorInit)
    }
    
    func getDict() {
        // check if file exist
        let fileManager = FileManager.default
        if (!fileManager.fileExists(atPath: path)) {
            do {
                let pathToBundleDB = Bundle.main.path(forResource: oembedKey, ofType: plistKey)!
                try fileManager.copyItem(atPath: pathToBundleDB, toPath: path)
            }
            catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
        }
        dict = NSDictionary(contentsOfFile: path)! as! [String: NSDictionary]
    }
    
    func writeDB() {
        let nsDict = dict as NSDictionary
        nsDict.write(toFile: path, atomically: true)
    }
    
    func insert(url: String, json: NSDictionary) {
        dict[url] = json
        writeDB()
    }
    
    func getJson(url: String) -> NSDictionary {
        if (dict[url] != nil) {
            return dict[url]!
        } else {
            return nothingHereDictionary
        }
    }
}
