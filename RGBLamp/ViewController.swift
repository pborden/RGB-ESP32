//
//  ViewController.swift
//  RGBLamp
//
//  Created by Peter Borden on 12/19/19.
//  Copyright © 2019 Peter Borden. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var redColor: Float = UserDefaults.standard.float(forKey: "red")
    var greenColor: Float = UserDefaults.standard.float(forKey: "green")
    var blueColor: Float = UserDefaults.standard.float(forKey: "blue")
    var whiteColor: Float = 0.9
    var alpha: Float = UserDefaults.standard.float(forKey: "alpha")
    var colorMode: Bool = true
    
    var largeFontSize: Float = 18.0
    var mediumFontSize: Float = 14.0
    var smallFontSize: Float = 10.0
    
    let minSize: Float = 4.0 // minimum font size
    
    @IBOutlet weak var textLarge: UITextView!
    @IBOutlet weak var textMedium: UITextView!
    @IBOutlet weak var textSmall: UITextView!
    @IBOutlet weak var largeFont: UITextField!
    @IBOutlet weak var mediumFont: UITextField!
    @IBOutlet weak var smallFont: UITextField!
    @IBOutlet weak var redValue: UILabel!
    @IBOutlet weak var greenValue: UILabel!
    @IBOutlet weak var blueValue: UILabel!
    @IBOutlet weak var alphaValue: UILabel!
    @IBOutlet weak var setRedSlider: UISlider!
    @IBOutlet weak var setGreenSlider: UISlider!
    @IBOutlet weak var setBlueSlider: UISlider!
    @IBOutlet weak var setAlphaSlider: UISlider!
    
    @IBAction func largeTextBigger(_ button: UIButton) {
        largeFontSize = largeFontSize + 1.0
        textLarge.font = .systemFont(ofSize: CGFloat(largeFontSize))
        largeFont.text = "\(Int(largeFontSize))"
        UserDefaults.standard.set(largeFontSize, forKey: "largeFont")
    }
    
    @IBAction func largeTextSmaller(_ button: UIButton) {
        largeFontSize = largeFontSize - 1.0
            if largeFontSize < minSize {
                largeFontSize = minSize
            }
        textLarge.font = .systemFont(ofSize: CGFloat(largeFontSize))
        largeFont.text = "\(Int(largeFontSize))"
        UserDefaults.standard.set(largeFontSize, forKey: "largeFont")
    }
    
    @IBAction func mediumTextBigger(_ button: UIButton) {
        mediumFontSize = mediumFontSize + 1.0
        textMedium.font = .systemFont(ofSize: CGFloat(mediumFontSize))
        mediumFont.text = "\(Int(mediumFontSize))"
        UserDefaults.standard.set(mediumFontSize, forKey: "mediumFont")
    }
    
    @IBAction func mediumTextSmaller(_ button: UIButton) {
        mediumFontSize = mediumFontSize - 1.0
            if mediumFontSize < minSize {
                mediumFontSize = minSize
            }
        textMedium.font = .systemFont(ofSize: CGFloat(mediumFontSize))
        mediumFont.text = "\(Int(mediumFontSize))"
        UserDefaults.standard.set(mediumFontSize, forKey: "mediumFont")
    }
    
    @IBAction func smallTextBigger(_ button: UIButton) {
        smallFontSize = smallFontSize + 1.0
        textSmall.font = .systemFont(ofSize: CGFloat(smallFontSize))
        smallFont.text = "\(Int(smallFontSize))"
        UserDefaults.standard.set(smallFontSize, forKey: "smallFont")
    }
    
    @IBAction func smallTextSmaller(_ button: UIButton) {
        smallFontSize = smallFontSize - 1.0
            if smallFontSize < minSize {
                smallFontSize = minSize
            }
        textSmall.font = .systemFont(ofSize: CGFloat(smallFontSize))
        smallFont.text = "\(Int(smallFontSize))"
        UserDefaults.standard.set(smallFontSize, forKey: "smallFont")
    }
    
    @IBAction func redSlider(_ slider: UISlider) {
        redColor = slider.value
        setBackgroundColor()
    }
    
    @IBAction func greenSlider(_ slider: UISlider) {
        greenColor = slider.value
        setBackgroundColor()
    }
    
    @IBAction func blueSlider(_ slider: UISlider) {
        blueColor = slider.value
        setBackgroundColor()
    }
    
    @IBAction func alphaSlider(_ slider: UISlider) {
        alpha = slider.value
        setBackgroundColor()
    }
    
    @IBAction func colorButton(_ button: UIButton) {
         if colorMode {
            setBackgroundWhite()
        } else {
            setBackgroundColor()
        }
    }
    
    func setBackgroundColor() {
        textLarge.backgroundColor = UIColor(
            red: CGFloat(redColor),
            green: CGFloat(greenColor),
            blue: CGFloat(blueColor),
            alpha: CGFloat(alpha)
        )
        textMedium.backgroundColor = textLarge.backgroundColor
        textSmall.backgroundColor = textLarge.backgroundColor
        colorMode = true
        
        setLabels()
    }
    
    func setBackgroundWhite() {
        textLarge.backgroundColor = UIColor(
            red: CGFloat(whiteColor),
            green: CGFloat(whiteColor),
            blue: CGFloat(whiteColor),
            alpha: CGFloat(alpha)
        )
        textMedium.backgroundColor = textLarge.backgroundColor
        textSmall.backgroundColor = textLarge.backgroundColor
        colorMode = false
        
    }
    
    func setLabels() {
        let redColorInt = Int(100 * redColor)
        let greenColorInt = Int(100 * greenColor)
        let blueColorInt = Int(100 * blueColor)
        let alphaInt = Int(100 * alpha)
        
        redValue.text = "\(redColorInt)"
        greenValue.text = "\(greenColorInt)"
        blueValue.text = "\(blueColorInt)"
        alphaValue.text = "\(alphaInt)"
        
        UserDefaults.standard.set(redColor, forKey: "red")
        UserDefaults.standard.set(greenColor, forKey: "green")
        UserDefaults.standard.set(blueColor, forKey: "blue")
        UserDefaults.standard.set(alpha, forKey: "alpha")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Red = \(redColor)")
        print("Green = \(greenColor)")
        print("Blue = \(blueColor)")
        print("Alpha = \(alpha)")
        print("Large font size = \(largeFontSize)")
        print("Medium font size = \(mediumFontSize)")
        print("Small font size = \(smallFontSize)")
        
        //set start-up values of sliders
        setRedSlider.value = UserDefaults.standard.float(forKey: "red")
        setGreenSlider.value = UserDefaults.standard.float(forKey: "green")
        setBlueSlider.value = UserDefaults.standard.float(forKey: "blue")
        
        largeFontSize = UserDefaults.standard.float(forKey: "largeFont")
        mediumFontSize = UserDefaults.standard.float(forKey: "mediumFont")
        smallFontSize = UserDefaults.standard.float(forKey: "smallFont")
        
        textLarge.font = .systemFont(ofSize: CGFloat(largeFontSize))
        textMedium.font = .systemFont(ofSize: CGFloat(mediumFontSize))
        textSmall.font = .systemFont(ofSize: CGFloat(smallFontSize))
        
        // on first run of program, need to set initial values
        if UserDefaults.standard.string(forKey: "firstTry") != "no" {
            UserDefaults.standard.set("no", forKey: "firstTry")
            setRedSlider.value = 0.9
            setGreenSlider.value = 0.9
            setBlueSlider.value = 0.9
            setAlphaSlider.value = 0.9
            redColor = 0.9
            greenColor = 0.9
            blueColor = 0.9
            alpha = 0.9
            
            textLarge.font = .systemFont(ofSize: CGFloat(largeFontSize))
            textMedium.font = .systemFont(ofSize: CGFloat(mediumFontSize))
            textSmall.font = .systemFont(ofSize: CGFloat(smallFontSize))
            
        }
        setBackgroundColor()
        
        largeFont.text = "\(Int(largeFontSize))"
        mediumFont.text = "\(Int(mediumFontSize))"
        smallFont.text = "\(Int(smallFontSize))"
    }
    
   /* override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(redColor, forKey: "red")
        UserDefaults.standard.set(greenColor, forKey: "green")
        UserDefaults.standard.set(blueColor, forKey: "blue")
        UserDefaults.standard.set(alpha, forKey: "alpha")
    } */
}

