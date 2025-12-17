import UIKit

final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    private var g: CAGradientLayer { layer as! CAGradientLayer }

    override func awakeFromNib() {
        super.awakeFromNib()
        g.colors = [
            UIColor(named: "AuthBGTop")?.cgColor ?? UIColor.black.cgColor,
            UIColor(named: "AuthBGBottom")?.cgColor ?? UIColor.darkGray.cgColor
        ]
        g.startPoint = CGPoint(x: 0.5, y: 0.0)
        g.endPoint   = CGPoint(x: 0.5, y: 1.0)
    }
}
