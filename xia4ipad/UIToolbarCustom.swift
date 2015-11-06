//
//  UIToolbarCustom.swift
//  xia4ipad
//
//  Created by Guillaume on 05/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class UIToolbarCustom: UIView, UIToolbarDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let height: CGFloat = 50.0
        
        let tb = UIToolbar(frame: CGRectMake(0, self.frame.height - height, self.frame.width, height))
        self.addSubview(tb)
        
        // (Default, Black, BlackTranslucent)
        tb.barStyle = UIBarStyle.Default
        
        /*tb.backgroundColor = colorPattern.back()
        
        tb.tintColor = colorPattern.accent()*/
        
        // (Done, Cancel, Edit, Save, Add, FlexibleSpace, FixedSpace, Compose, Reply, Action, Organize, Bookmarks, Search, Refresh, Stop, Camera, Trash, Play, Pause, Rewind, FastForward, Undo, Redo, PageCurl)
        var items0: [UIBarButtonItem] = []
        var items1: [UIBarButtonItem] = []
        var items2: [UIBarButtonItem] = []
        var items3: [UIBarButtonItem] = []
        var items4: [UIBarButtonItem] = []
        items0.append(UIBarButtonItem(title: "original1", style: UIBarButtonItemStyle.Plain, target: self, action: "buttonPushed:"))
        items0.append(UIBarButtonItem(title: "original2", style: UIBarButtonItemStyle.Done, target: self, action: "buttonPushed:"))
        items0.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "buttonPushed:"))
        items0.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "buttonPushed:"))
        items0.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "buttonPushed:"))
        
        items1.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "buttonPushed:"))
        items1.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "buttonPushed:"))
        items1.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: "buttonPushed:"))
        items1.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: self, action: "buttonPushed:"))
        items1.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "buttonPushed:"))
        items1.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: self, action: "buttonPushed:"))
        items1.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "buttonPushed:"))
        items1.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: "buttonPushed:"))
        items1.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: "buttonPushed:"))
        items1.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "buttonPushed:"))
        items1.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "buttonPushed:"))
        
        items2.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "buttonPushed:"))
        items2.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "buttonPushed:"))
        items2.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "buttonPushed:"))
        items2.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Play, target: self, action: "buttonPushed:"))
        items2.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action: "buttonPushed:"))
        items2.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Rewind, target: self, action: "buttonPushed:"))
        items2.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FastForward, target: self, action: "buttonPushed:"))
        items2.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Undo, target: self, action: "buttonPushed:"))
        items2.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Redo, target: self, action: "buttonPushed:"))
        items2.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.PageCurl, target: self, action: "buttonPushed:"))
        
        tb.setItems(items1, animated: true)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonPushed(sender: UIBarButtonItem) {
        print(sender)
    }
}