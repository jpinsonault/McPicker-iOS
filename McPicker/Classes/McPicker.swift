//Copyright (c) 2017 Kevin McGill <kevin@mcgilldevtech.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

import UIKit

open class McPicker: UIView {

    open var fontSize:CGFloat = 25.0
    open var label:UILabel?
    open var toolbarButtonsColor:UIColor? {
        didSet {
            cancelBarButton.tintColor = toolbarButtonsColor
            doneBarButton.tintColor = toolbarButtonsColor
        }
    }
    open var toolbarDoneButtonColor:UIColor? {
        didSet {
            doneBarButton.tintColor = toolbarDoneButtonColor
        }
    }
    open var toolbarCancelButtonColor:UIColor? {
        didSet {
            cancelBarButton.tintColor = toolbarCancelButtonColor
        }
    }
    open var toolbarBarTintColor:UIColor? {
        didSet {
            toolbar.barTintColor = toolbarBarTintColor
        }
    }
    open var toolbarItemsFont: UIFont? {
        didSet {
            for item in toolbar.items ?? [] {
                item.setTitleTextAttributes([NSFontAttributeName: toolbarItemsFont!], for: .normal)
            }
        }
    }
    open var pickerBackgroundColor:UIColor? {
        didSet {
            picker.backgroundColor = pickerBackgroundColor
        }
    }
    
    
    fileprivate var pickerSelection:[Int:String] = [:]
    fileprivate var pickerData:[[String]] = []
    fileprivate var numberOfComponents:Int {
        get {
            return pickerData.count
        }
    }
    
    
    private enum AnimationDirection {
        case `in`, out
    }
    private var picker:UIPickerView = UIPickerView()
    private var toolbar:UIToolbar = UIToolbar()
    private let backgroundView:UIView = UIView()
    
    private let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    private let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
    private let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    private var fixedSpace: UIBarButtonItem {
        get {
            let fixedSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            fixedSpaceBarButtonItem.width = appWindow.bounds.size.width * 0.02
            return fixedSpaceBarButtonItem
        }
    }
    private var appWindow:UIWindow {
        get {
            return UIApplication.shared.keyWindow!
        }
    }
    private let PICKER_HEIGHT:CGFloat = 216.0
    private let TOOLBAR_HEIGHT:CGFloat = 44.0
    private let BACKGROUND_ALPHA:CGFloat =  0.75
    private let ANIMATION_SPEED = 0.25

    private var doneHandler:(_ selections:[Int:String]) -> Void = {_ in }
    private var cancelHandler:() -> Void = {_ in }

    
    convenience public init(data:[[String]]) {
        self.init(frame: CGRect.zero)
        self.pickerData = data
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    open func show(cancelHandler:@escaping () -> Void, doneHandler:@escaping (_ selections:[Int:String]) -> Void){
        self.doneHandler = doneHandler
        self.cancelHandler = cancelHandler
        animateViews(direction: .in)
    }
    
    open func show(doneHandler:@escaping (_ selections:[Int:String]) -> Void){
        show(cancelHandler: {}, doneHandler: doneHandler)
    }
    
    open class func show(data:[[String]], cancelHandler:@escaping () -> Void, doneHandler:@escaping (_ selections:[Int:String]) -> Void) {
        McPicker(data:data).show(cancelHandler: cancelHandler, doneHandler: doneHandler)
    }
    
    open class func show(data:[[String]], doneHandler:@escaping (_ selections:[Int:String]) -> Void) {
        McPicker(data:data).show(cancelHandler: {}, doneHandler: doneHandler)
    }
    
    open func setToolbarItems(items: [UIBarButtonItem]) {
        toolbar.items = items
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if let _ = newWindow {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(sizeViews),
                                                   name: NSNotification.Name.UIDeviceOrientationDidChange,
                                                   object: nil)
        } else {
            NotificationCenter.default.removeObserver(self,
                                                      name: NSNotification.Name.UIDeviceOrientationDidChange,
                                                      object: nil)
        }
    }
    
    private func setup() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancel)))
        
        setToolbarItems(items: [fixedSpace, cancelBarButton, flexibleSpace, doneBarButton, fixedSpace])
        
        self.backgroundColor = UIColor.black.withAlphaComponent(BACKGROUND_ALPHA)
        backgroundView.backgroundColor = UIColor.white
        
        picker.delegate = self
        picker.dataSource = self
        
        sizeViews()
        
        // Default selection to first item per component
        //
        for (index, element) in pickerData.enumerated() {
            pickerSelection[index] = element.first
        }
    }
    
    @objc private func done() {
        animateViews(direction: .out)
        self.doneHandler(self.pickerSelection)
    }
    
    @objc private func cancel() {
        animateViews(direction: .out)
        self.cancelHandler()
    }

    @objc private func sizeViews() {
        self.frame = CGRect(x: 0,
                            y: 0,
                            width: self.appWindow.bounds.size.width,
                            height: self.appWindow.bounds.size.height)
        backgroundView.frame = CGRect(x: 0,
                                      y: self.bounds.size.height - (PICKER_HEIGHT + TOOLBAR_HEIGHT),
                                      width: self.bounds.size.width,
                                      height: PICKER_HEIGHT + TOOLBAR_HEIGHT)
        toolbar.frame = CGRect(x: 0,
                               y: 0,
                               width: backgroundView.bounds.size.width,
                               height: TOOLBAR_HEIGHT)
        picker.frame = CGRect(x: 0,
                              y: toolbar.bounds.size.height,
                              width: backgroundView.bounds.size.width,
                              height: PICKER_HEIGHT)
    }
    
    private func animateViews(direction:AnimationDirection){
        
        var backgroundFrame = backgroundView.frame

        if direction == .in {
            // Start transparent
            //
            self.backgroundColor = UIColor.black.withAlphaComponent(0)
            
            // Start picker off the bottom of the screen
            //
            backgroundFrame.origin.y = self.appWindow.bounds.size.height
            backgroundView.frame = backgroundFrame
            
            // Add views
            //
            backgroundView.addSubview(picker)
            backgroundView.addSubview(toolbar)
            self.addSubview(backgroundView)
            appWindow.addSubview(self)
            
            // Animate things on screen
            //
            UIView.animate(withDuration: ANIMATION_SPEED, animations: {
                self.backgroundColor = UIColor.black.withAlphaComponent(self.BACKGROUND_ALPHA)
                backgroundFrame.origin.y = self.appWindow.bounds.size.height - self.backgroundView.bounds.height
                self.backgroundView.frame = backgroundFrame
            })
        } else {
            // Animate things off screen
            //
            UIView.animate(withDuration: ANIMATION_SPEED, animations: {
                self.backgroundColor = UIColor.black.withAlphaComponent(0)
                backgroundFrame.origin.y = self.appWindow.bounds.size.height
                self.backgroundView.frame = backgroundFrame
            }, completion: { completed in
                self.removeFromSuperview()
            })
        }
    }
}


extension McPicker : UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.numberOfComponents
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
}


extension McPicker : UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel
        
        if (pickerLabel == nil) {
            pickerLabel = UILabel()

            if let goodLabel = label {
                pickerLabel?.textAlignment = goodLabel.textAlignment
                pickerLabel?.font = goodLabel.font
                pickerLabel?.textColor = goodLabel.textColor
                pickerLabel?.backgroundColor = goodLabel.backgroundColor
                pickerLabel?.numberOfLines = goodLabel.numberOfLines
            } else {
                pickerLabel?.textAlignment = .center
                pickerLabel?.font = UIFont.systemFont(ofSize: self.fontSize)
            }
        }
        
        pickerLabel?.text = pickerData[component][row]
        
        return pickerLabel!
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickerSelection[component] = pickerData[component][row]
    }
}
