//
//  ViewController.swift
//  tipper
//
//  Created by George Kedenburg on 2/25/15.
//  Copyright (c) 2015 GK3. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var billLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var splitLabel: UILabel!
    @IBOutlet weak var shouldLabel: UILabel!
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var vbadBtn: UIButton!
    @IBOutlet weak var badBtn: UIButton!
    @IBOutlet weak var neutBtn: UIButton!
    @IBOutlet weak var goodBtn: UIButton!
    @IBOutlet weak var vgoodBtn: UIButton!
    @IBOutlet weak var increaseBtn: UIButton!
    @IBOutlet weak var decreaseBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var serviceView: UIView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var billView: UIView!
    @IBOutlet weak var splitView: UIView!
    @IBOutlet weak var splitCount: UILabel!
    @IBOutlet var numToolbar: UIToolbar!
    
    var currentString = ""
    
    var tipPercent = 0.15
    var currentService = "😬"
    var guestCount = 0
    var maxGuestCount = 14
    
    let tipModes = ["normal", "up", "down"]
    var tipMode = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var attributedString = NSMutableAttributedString(string: "TIPMOJI")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(6), range: NSRange(location: 0, length: attributedString.length))
        appLabel.attributedText = attributedString
        
        attributedString = NSMutableAttributedString(string: "HOW MUCH WAS THE BILL?")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(1.4), range: NSRange(location: 0, length: attributedString.length))
        billLabel.attributedText = attributedString
        
        attributedString = NSMutableAttributedString(string: "HOW WAS THE SERVICE?")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(1.4), range: NSRange(location: 0, length: attributedString.length))
        serviceLabel.attributedText = attributedString
        
        attributedString = NSMutableAttributedString(string: "SPLIT HOW MANY WAYS?")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(1.4), range: NSRange(location: 0, length: attributedString.length))
        splitLabel.attributedText = attributedString

        attributedString = NSMutableAttributedString(string: "👇 COOL, YOU SHOULD TIP 👇")
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(1.4), range: NSRange(location: 0, length: attributedString.length))
        shouldLabel.attributedText = attributedString
        
        attributedString = NSMutableAttributedString(string: "$0.00")
        attributedString.addAttribute(NSKernAttributeName, value: -1.1, range: NSMakeRange(0, attributedString.length))
        tipLabel.attributedText = attributedString

        attributedString = NSMutableAttributedString(string: "($0.00 TOTAL PER PERSON)")
        attributedString.addAttribute(NSKernAttributeName, value: -1.1, range: NSMakeRange(0, attributedString.length))
        totalLabel.attributedText = attributedString
        
        splitCount.text = ""
        
        serviceView.alpha = 0
        splitView.alpha = 0
        totalView.alpha = 0
        decreaseBtn.alpha = 0.2
        self.resetBtn.alpha = 0
                    
        self.billField.delegate = self
        billField.becomeFirstResponder()
        
        
        billField.inputAccessoryView = numToolbar
        numToolbar.barStyle = UIBarStyle.BlackTranslucent
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(red:0.37, green:0.13, blue:0.55, alpha:1).CGColor, UIColor(red:0.77, green:0, blue:1, alpha:1).CGColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doneButtonAction() {
        self.billField.resignFirstResponder()
    }
    
    func textField(billField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            currentString += string
//            println(currentString)
            formatCurrency(string: currentString)
        default:
            var array = Array(string)
            var currentStringArray = Array(currentString)
            if array.count == 0 && currentStringArray.count != 0 {
                currentStringArray.removeLast()
                currentString = ""
                for character in currentStringArray {
                    currentString += String(character)
                }
                formatCurrency(string: currentString)
            }
        }
        return false
    }
    
    func formatCurrency(#string: String) {
//        println("format \(string)")
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        var numberFromField = (NSString(string: currentString).doubleValue)/100
        billField.text = formatter.stringFromNumber(numberFromField)
        onEditingChanged(self)
    }
    
    @IBAction func onEditingChanged(sender: AnyObject) {
        if billField.text == ""{
            UIView.animateWithDuration(0.2, animations: {
                self.resetBtn.alpha = 0
            })
        } else{
            UIView.animateWithDuration(0.2, animations: {
                self.serviceView.alpha = 1
                self.resetBtn.alpha = 1
            })
        }
        var billInputArr = billField.text.componentsSeparatedByString(",")
        
        let dirty = billField.text
        let clean = dirty.stringByReplacingOccurrencesOfString(
            "[\\$\\,]",
            withString: "",
            options: .RegularExpressionSearch)
        var billAmount = NSString(string: clean).doubleValue / Double(guestCount)
        var tip = billAmount * tipPercent
        var total = tip + billAmount
        
        if tipModes[tipMode] == "up"{
            var diff = ceil(total) - total
            tip = diff + tip
            total = tip + billAmount
            
        } else if tipModes[tipMode] == "down"{
            var diff = floor(total) - total
            tip = diff + tip
            total = tip + billAmount
        }
        
        var tipLabelText = String(format: "$%.2f", tip)
        var totalLabelText = "FOR A TOTAL OF " + String(format: "$%.2f", total)
        if guestCount > 1{
            totalLabelText += " EACH"
//            totalLabelText += currentService
        }
        var attributedString = NSMutableAttributedString(string:tipLabelText)
        attributedString.addAttribute(NSKernAttributeName, value: -6.1, range: NSMakeRange(0, attributedString.length))
        tipLabel.attributedText = attributedString
        
        attributedString = NSMutableAttributedString(string:totalLabelText)
        attributedString.addAttribute(NSKernAttributeName, value: 1.4, range: NSMakeRange(0, attributedString.length))
        totalLabel.attributedText = attributedString
        
    }

    @IBAction func serviceChange(sender: AnyObject) {
        if guestCount > 0{
            var guestList = ""
            for index in 1...guestCount{
                guestList += currentService
            }
            splitCount.text = guestList
        }
        UIView.animateWithDuration(0.2, animations: {
            self.splitView.alpha = 1
        })
    }
    
    @IBAction func guestDecrease(sender: AnyObject) {
        if guestCount > 1 {
            guestCount--
            if guestCount == 1{
                decreaseBtn.alpha = 0.2
            }
        } else {
            return
        }
        increaseBtn.alpha = 1
        var guestList = ""
        for index in 1...guestCount{
            guestList += currentService
        }
        splitCount.text = guestList
        onEditingChanged(self)
    }
    @IBAction func guestIncrease(sender: AnyObject) {
        if guestCount < maxGuestCount {
            guestCount++
            if guestCount == maxGuestCount{
                increaseBtn.alpha = 0.2
            }
        } else {
            return
        }
        if guestCount > 1 {
            decreaseBtn.alpha = 1
        } else {
            decreaseBtn.alpha = 0.2
            
        }
        
        var guestList = ""
        for index in 1...guestCount{
            guestList += currentService
        }
        splitCount.text = guestList
        onEditingChanged(self)
        UIView.animateWithDuration(0.2, animations: {
            self.totalView.alpha = 1
        })
    }
    @IBAction func onVbad(sender: AnyObject) {
        view.endEditing(true)
        currentService = "😭"
        vbadBtn.alpha = 1
        badBtn.alpha = 0.2
        neutBtn.alpha = 0.2
        goodBtn.alpha = 0.2
        vgoodBtn.alpha = 0.2
        tipPercent = 0.1
        serviceChange(vbadBtn)
        onEditingChanged(vbadBtn)
    }
    
    @IBAction func onBad(sender: AnyObject) {
        view.endEditing(true)
        currentService = "😕"
        vbadBtn.alpha = 0.2
        badBtn.alpha = 1
        neutBtn.alpha = 0.2
        goodBtn.alpha = 0.2
        vgoodBtn.alpha = 0.2
        tipPercent = 0.125
        serviceChange(badBtn)
        onEditingChanged(badBtn)
    }
    
    @IBAction func onNeut(sender: AnyObject) {
        view.endEditing(true)
        currentService = "😬"
        vbadBtn.alpha = 0.2
        badBtn.alpha = 0.2
        neutBtn.alpha = 1
        goodBtn.alpha = 0.2
        vgoodBtn.alpha = 0.2
        tipPercent = 0.15
        serviceChange(neutBtn)
        onEditingChanged(neutBtn)
    }
    @IBAction func onGood(sender: AnyObject) {
        view.endEditing(true)
        currentService = "😀"
        vbadBtn.alpha = 0.2
        badBtn.alpha = 0.2
        neutBtn.alpha = 0.2
        goodBtn.alpha = 1
        vgoodBtn.alpha = 0.2
        tipPercent = 0.18
        serviceChange(goodBtn)
        onEditingChanged(goodBtn)
    }
    @IBAction func onVgood(sender: AnyObject) {
        view.endEditing(true)
        currentService = "😍"
        vbadBtn.alpha = 0.2
        badBtn.alpha = 0.2
        neutBtn.alpha = 0.2
        goodBtn.alpha = 0.2
        vgoodBtn.alpha = 1
        tipPercent = 0.2
        serviceChange(vgoodBtn)
        onEditingChanged(vgoodBtn)
    }
    
    @IBAction func resetAll(sender: AnyObject) {
        billField.text = ""
        currentString = ""
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            
            // Animations
            self.serviceView.alpha = 0
            self.splitView.alpha = 0
            self.totalView.alpha = 0
            self.resetBtn.alpha = 0
            
            }, completion: { finished in
                
                if finished {
                    self.vbadBtn.alpha = 1
                    self.badBtn.alpha = 1
                    self.neutBtn.alpha = 1
                    self.goodBtn.alpha = 1
                    self.vgoodBtn.alpha = 1
                }
                
        })
        guestCount = 0
        splitCount.text = ""
        billField.becomeFirstResponder()

    }
    @IBAction func tipModeToggle(sender: AnyObject) {
        
        if tipMode == 2{
            tipMode = 0
        } else {
            tipMode++
        }
        onEditingChanged(totalView)
    }
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
}

