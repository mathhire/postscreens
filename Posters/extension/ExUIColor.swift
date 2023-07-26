

import Foundation
import UIKit

extension UIColor{
    // get UIColor from hexa Int with alpha
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    // get UIColor from hexa string
    class func fromHexString (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        //Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: - COLOR_WITH_PATTERN_IMAGE
    func COLOR_WITH_PATTERN_IMAGE(image:NSString, view:UIView) -> UIColor {
        UIGraphicsBeginImageContext(view.frame.size)
        UIImage(named: image as String)?.drawAsPattern(in: view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image)
    }
    
    
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    //MARK: Get Hex String From UIcolor
 
    func hexFromUIColor(color: UIColor)  -> String
    {
        let hexString = String(format: "%02X%02X%02X",
                               Int((color.cgColor.components?[0])! * 255.0),
                               Int((color.cgColor.components?[1])!*255.0),
                               Int((color.cgColor.components?[2])! * 255.0))
        return hexString
    }
    
    //MARK: Get UIcolor From Hex String
    
    
  class func colorFromHexString(hexCode:String!) ->  UIColor {
    
        let scanner  = Scanner(string:hexCode)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "$+#")
//        var hex: CUnsignedInt = 0
//        if(!scanner.scanHexInt32(&hex))
//        {
        var hex: UInt64 = 0
        if(!scanner.scanHexInt64(&hex))
        {
            return UIColor()
        }
        let  r  = (hex >> 16) & 0xFF;
        let  g  = (hex >> 8) & 0xFF;
        let  b  = (hex) & 0xFF;
        
        return UIColor.init(red: CGFloat(r) / 255.0, green:  CGFloat(g) / 255.0, blue:  CGFloat(b) / 255.0, alpha: 1)
    }
}


