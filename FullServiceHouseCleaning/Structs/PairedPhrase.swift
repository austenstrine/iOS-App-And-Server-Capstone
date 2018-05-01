//
//  PairedPhrase.swift
//  FullServiceHouseCleaning
//
//  Created by admin on Monday4/30/18.
//  Copyright © 2018 Student. All rights reserved.
//

import UIKit

struct PairedPhrase
{
    static let valArray = [84, 104, 101,
                                   97, 32, 65,
                                   117, 103, 117,
                                   115, 116, 97,
                                   32, 80, 97,
                                   117, 108, 101,
                                   116, 116, 101,
                                   32, 83, 116,
                                   114, 105, 110, 101]
    
    static func encodePass(pass:String) -> String
    {
        let str:String = pass
        let valArray = PairedPhrase.valArray
        var newString = ""
        var i = 0
        for char in str
        {
            var val:Int
            if i >= valArray.count
            {
                val = valArray[i % valArray.count]
            }
            else
            {
                val = valArray[i]
            }
            let scalars = char.unicodeScalars.map { $0.value }
            let unicodeScalarValue = Int(scalars.reduce(0, +))
            newString += String(UnicodeScalar(unicodeScalarValue+val)!)
            i += 1
        }
        return newString
    }
}
