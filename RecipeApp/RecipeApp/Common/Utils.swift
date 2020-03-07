//
//  Utils.swift
//  RecipeApp
//
//  Created by Nguyen D on 3/7/20.
//  Copyright © 2020 Nguyen D. All rights reserved.
//

import UIKit

class Utils: NSObject {
    class func getTextHeight(_ text: String?, font: UIFont, constrainedToWidth width: CGFloat, textLineHeight lineHeight: CGFloat = 22) -> CGFloat {
        if text == nil {
            return 0
        }
        
        let attributedText: NSAttributedString = NSAttributedString(string: text!, attributes: [NSAttributedString.Key.font:font])
        let rect : CGRect = attributedText.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        var height = rect.height
        if height > lineHeight {
            height += lineHeight / 3
        }
        return height
    }
    
    /*class func convertImageToBase64(_ image : UIImage) -> String {
        let imageData = image.pngData()!
        let base64 = imageData.base64EncodedString(options: .lineLength64Characters)
        return base64
    }*/
    
    class func convertImageToBase64(_ image: UIImage) -> String {
        let imageData:NSData = image.jpegData(compressionQuality: 0.4)! as NSData
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }
    
    class func convertBase64ToImage(_ str: String) -> UIImage? {
        let dataDecoded : Data = Data(base64Encoded: str, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        return decodedimage
    }
    
    /*class func convertBase64ToImage(_ base64: String) -> UIImage? {
        /*if let dataDecoded = NSData(base64Encoded: base64, options: NSData.Base64DecodingOptions(rawValue: 0)) {
            let decodedimage = UIImage(data: dataDecoded as Data)
            return decodedimage
        }*/
        
        let temp = base64.components(separatedBy: ",")
        if temp.count > 1 {
            let dataDecoded : Data = Data(base64Encoded: temp[1], options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            return decodedimage
        }
        
        return nil
    }*/
    
    class func trim(_ string: String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
