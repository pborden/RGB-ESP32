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
    
    @IBOutlet weak var textLarge: UITextView!
    @IBOutlet weak var textMedium: UITextView!
    @IBOutlet weak var textSmall: UITextView!
    @IBOutlet weak var redValue: UILabel!
    @IBOutlet weak var greenValue: UILabel!
    @IBOutlet weak var blueValue: UILabel!
    @IBOutlet weak var alphaValue: UILabel!
    @IBOutlet weak var setRedSlider: UISlider!
    @IBOutlet weak var setGreenSlider: UISlider!
    @IBOutlet weak var setBlueSlider: UISlider!
    @IBOutlet weak var setAlphaSlider: UISlider!
    
    
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
        
        //set start-up values of sliders
        setRedSlider.value = UserDefaults.standard.float(forKey: "red")
        setGreenSlider.value = UserDefaults.standard.float(forKey: "green")
        setBlueSlider.value = UserDefaults.standard.float(forKey: "blue")
        setAlphaSlider.value = UserDefaults.standard.float(forKey: "alpha")
        
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
        }
        setBackgroundColor()
    }
    
   /* override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(redColor, forKey: "red")
        UserDefaults.standard.set(greenColor, forKey: "green")
        UserDefaults.standard.set(blueColor, forKey: "blue")
        UserDefaults.standard.set(alpha, forKey: "alpha")
    } */
}

