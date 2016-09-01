//
//  Sample.swift
//  CarsonDaily
//
//  Created by Kevin Clark on 8/4/16.
//  Copyright © 2016 Translate Abroad. All rights reserved.
//

import UIKit

class Sample: NSObject {
    
    var title: String!
    var fileName: String!
    var order: Int!
    var fileUrl: NSURL!

    convenience init(_ title: String, fileName: String, order: Int)
    {
        self.init()
        
        self.title = title
        self.fileName = fileName
        self.order = order
        
        // get file URL
        let samplePieces = fileName.componentsSeparatedByString(".")
        let path = NSBundle.mainBundle().pathForResource(samplePieces[0], ofType: samplePieces.last)
        self.fileUrl = NSURL(fileURLWithPath: path!)
    }
    
}
