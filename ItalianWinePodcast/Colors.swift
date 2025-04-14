import UIKit

extension UIColor {
    static let bordeaux = UIColor(red: 134/255, green: 21/255, blue: 34/255, alpha: 1.0)
    static let backgroundBeige = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
    static let gold = UIColor(red: 186/255, green: 45/255, blue: 40/255, alpha: 1.0)
    
    convenience init?(named: String) {
        switch named {
        case "Bordeaux":
            self.init(red: 134/255, green: 21/255, blue: 34/255, alpha: 1.0)
        case "BackgroundBeige":
            self.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        case "Gold":
            self.init(red: 186/255, green: 45/255, blue: 40/255, alpha: 1.0)
        default:
            return nil
        }
    }
}
