import UIKit

enum SelahHero {
    static let windowResource = "selah-hero-window"

    static var windowImage: UIImage? {
        if let named = UIImage(named: windowResource) {
            return named
        }
        guard let url = Bundle.main.url(forResource: windowResource, withExtension: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }
}
