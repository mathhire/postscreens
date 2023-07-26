

import Foundation
import UIKit

extension String{
    func isValidEmail() ->Bool{
        let regEx = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        let pred = NSPredicate(format: "SELF MATCHES %@", regEx)
        return pred.evaluate(with: self)
    }
    
    func digitsOnly() -> String{
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    func toTimeString()->String{
        let format = DateFormatter()
        format.dateFormat = "MMM dd yyyy"
        return format.string(from: Date(timeIntervalSince1970: Double(self) ?? 0))
    }
    
    func imageWith()-> UIImage?{
        let frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.backgroundColor = .gray
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.text = self.uppercased()
        UIGraphicsBeginImageContext(frame.size)
        if let context = UIGraphicsGetCurrentContext(){
            label.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
}

extension UserDefaults {
    static var post_id: String {
        get {
            standard.string(forKey: "post_id") ?? ""
        }
        set {
            standard.set(newValue, forKey: "post_id")
        }
    }
    static var social_type: String {
        get {
            standard.string(forKey: "social_type") ?? ""
        }
        set {
            standard.set(newValue, forKey: "social_type")
        }
    }
    static var inviteUserID: String {
        get {
            standard.string(forKey: "invite_user_id") ?? ""
        }
        set {
            standard.set(newValue, forKey: "invite_user_id")
        }
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date)),"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))mins" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
