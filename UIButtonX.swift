import UIKit

/*
 An @IBDEsignable custom button with several easily customizable features.
    1. With Background property set to UIColor.clear, a two color gradient background layer will show when button is unclicked, clicked or if isTempSelected. Gradient can be set horizontally, vertically or diagonally.
    2. A border feature with settable color and width. Border can have an independent circular shape on any of its 4 corners. The border's corner radius can exceed the height and width.
    3. With the UIButtonX's Line Break property set to Word Wrap, when the fixedWidth == true, the UIButtonX will adjust height to fit content, when the fixedWidth == false, the UIButtonX will adjust width to fit content
    4. Change the Content Mode property to redraw. This will allow border to render on dimension changes.
 */
@IBDesignable
class UIButtonX: UIButton {
    //Colors used in the UIButtonX gradient in its normal state.
    @IBInspectable var firstColor : UIColor = UIColor.clear
    @IBInspectable var secondColor : UIColor = UIColor.clear
    
    //Colors used in the UIButtonX gradient when pressed.
    @IBInspectable var firstClickColor : UIColor = UIColor.white.withAlphaComponent(0.5)
    @IBInspectable var secondClickColor : UIColor = UIColor.white.withAlphaComponent(0.5)
    @IBInspectable var clickTextColor : UIColor = UIColor.darkGray
    @IBInspectable var clickTintColor : UIColor = UIColor.darkGray
    
    //Colors used in the UIButtonX gradient when isTempSelected == true.
    @IBInspectable var firstSelectionColor : UIColor = UIColor.clear
    @IBInspectable var secondSelectionColor : UIColor = UIColor.clear
    @IBInspectable var selectTextColor : UIColor = UIColor.white
    @IBInspectable var selectTintColor : UIColor = UIColor.white
    
    //Indicates the start point for the gradient layer.
    @IBInspectable var x_StartPoint : Double = 1.0
    @IBInspectable var y_StartPoint : Double = 1.0
    
    //Indicates the end point for the gradient layer.
    @IBInspectable var x_EndPoint : Double = 0.0
    @IBInspectable var y_EndPoint : Double = 0.0
    
    //Settable border color, width, and cornerRadius length
    @IBInspectable var borderColor : UIColor = UIColor.clear
    @IBInspectable var borderWidth : CGFloat = 2.0
    
    @IBInspectable var cornerRadius : CGFloat  = 0.0
    @IBInspectable var topLeftRadius : CGFloat  = -1
    @IBInspectable var topRightRadius : CGFloat  = -1
    @IBInspectable var bottomLeftRadius : CGFloat  = -1
    @IBInspectable var bottomRightRadius : CGFloat  = -1
    
    override class var layerClass : AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    //Variable to detect if the UIButton is pressed or released, and if selected
    var pressed : Bool = false
    var isTempSelected : Bool = false
    
    //Variable to store the UIButtonX originat color
    var initialTextColor : UIColor?
    var initialTintColor : UIColor?
    
    //UIButtonX pressed and needs to be redrawn to reflect any graphical changes.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressed = true
        super.touchesBegan(touches, with: event)
        self.setNeedsDisplay()
    }
    
    //UIButtonX NOT pressed and needs to be redrawn to reflect any graphical changes.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressed = false
        super.touchesCancelled(touches, with: event)
        self.setNeedsDisplay()
    }
    
    //UIButtonX NOT pressed and needs to be redrawn to reflect any graphical changes.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressed = false
        super.touchesEnded(touches, with: event)
        self.setNeedsDisplay()
    }
    
    //Indicates what dimension should be adjusted to fit button content.
    @IBInspectable var fixedWidth : Bool = true
    /*
     Returns s CGSize that contains all content within the UIButton including text and images.
     */
    override var intrinsicContentSize: CGSize {
        
        let wImage = image(for: [])?.size.width ?? 0
        let wTitleInset = titleEdgeInsets.left + titleEdgeInsets.right
        let wImageInset = imageEdgeInsets.left + imageEdgeInsets.right
        let wContentInset = contentEdgeInsets.left + contentEdgeInsets.right
        
        let hTitleInset = titleEdgeInsets.top + titleEdgeInsets.bottom
        let hImageInset = imageEdgeInsets.top + imageEdgeInsets.bottom
        let hContentInset = contentEdgeInsets.top + contentEdgeInsets.bottom

        let labelSize = titleLabel?.sizeThatFits(CGSize(width: fixedWidth ? (frame.width - wImage - wTitleInset - wImageInset - wContentInset) : .greatestFiniteMagnitude, height: fixedWidth ? .greatestFiniteMagnitude : (frame.height - max(hTitleInset,hImageInset) - hContentInset))) ?? .zero
            
        let width : CGFloat = labelSize.width + wImage + wTitleInset + wImageInset + wContentInset
        let height : CGFloat = labelSize.height + max(hTitleInset,hImageInset) + hContentInset
        let desiredButtonSize = CGSize(width: width, height: height)
        
        return desiredButtonSize
    }
    /*
     overriden draw function adds the appropriate gradient layers, title color, corner radii, background color, border width and color
     */
    override func draw(_ rect: CGRect) {
        if let layer = self.layer as? CAGradientLayer {
            layer.colors = pressed ?
                [firstClickColor.cgColor,secondClickColor.cgColor] :
                (isTempSelected ? [firstSelectionColor.cgColor,secondSelectionColor.cgColor] : [firstColor.cgColor,secondColor.cgColor])
            layer.locations = [0.0,1.0] //Determines where color blends
            layer.startPoint = CGPoint(x: x_StartPoint, y:y_StartPoint)
            layer.endPoint = CGPoint(x: x_EndPoint,y: y_EndPoint)
        }
    
        if initialTextColor == nil {initialTextColor = titleColor(for: .normal)}
        self.setTitleColor(isTempSelected ? selectTextColor : initialTextColor, for: .normal)
        self.setTitleColor(clickTextColor, for: .highlighted)
        
        if initialTintColor == nil {initialTintColor = tintColor}
        self.tintColor = pressed ? clickTintColor : isTempSelected ? selectTintColor : initialTintColor
        
        if let title = self.attributedTitle(for: .normal) {
            let newTitle = NSMutableAttributedString(attributedString: title)
            newTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: isTempSelected ? selectTextColor : initialTextColor!, range: (newTitle.string as NSString).range(of: newTitle.string))
            self.setAttributedTitle(newTitle, for: .normal)
        }
        
        if topLeftRadius < 0 {topLeftRadius = cornerRadius}
        if topRightRadius < 0 {topRightRadius = cornerRadius}
        if bottomLeftRadius < 0 {bottomLeftRadius = cornerRadius}
        if bottomRightRadius < 0 {bottomRightRadius = cornerRadius}
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.origin.x + topLeftRadius, y: rect.origin.y))
        path.addLine(to: CGPoint(x: rect.origin.x + rect.width - topRightRadius, y: rect.origin.y))
        path.addArc(withCenter: CGPoint(x: rect.origin.x + rect.width - topRightRadius, y: rect.origin.y + topRightRadius), radius: topRightRadius, startAngle: -.pi/2, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height - bottomRightRadius))
        path.addArc(withCenter: CGPoint(x: rect.origin.x + rect.width - bottomRightRadius, y: rect.origin.y + rect.height - bottomRightRadius), radius: bottomRightRadius, startAngle: 0, endAngle: .pi/2, clockwise: true)
        path.addLine(to: CGPoint(x: rect.origin.x + bottomLeftRadius, y: rect.origin.y + rect.height))
        path.addArc(withCenter: CGPoint(x: rect.origin.x + bottomLeftRadius, y: rect.origin.y + rect.height - bottomLeftRadius), radius: bottomLeftRadius, startAngle: .pi/2, endAngle: .pi , clockwise: true)
        path.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y + topLeftRadius))
        path.addArc(withCenter: CGPoint(x: rect.origin.x + topLeftRadius, y: rect.origin.y + topLeftRadius), radius: topLeftRadius, startAngle: .pi, endAngle: -.pi/2 , clockwise: true)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
        
        (backgroundColor ?? UIColor.clear).setFill()
        path.fill()
        
        (pressed ? UIColor.clear : borderColor).setStroke()
        path.lineWidth = borderWidth
        path.stroke()
        
        super.draw(rect)
    }
}
