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
    var fileUrl: URL!

    convenience init(_ title: String, fileName: String, order: Int)
    {
        self.init()
        
        self.title = title
        self.fileName = fileName
        self.order = order
        
        // get file URL
        let samplePieces = fileName.components(separatedBy: ".")
        let path = Bundle.main.path(forResource: samplePieces[0], ofType: samplePieces.last)
        self.fileUrl = URL(fileURLWithPath: path!)
    }
    
}
