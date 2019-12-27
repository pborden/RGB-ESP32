//
//  ViewController.swift
//  RGBLamp
//
//  Created by Peter Borden on 12/19/19.
//  Copyright © 2019 Peter Borden. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var redColor: Float = 0.9
    var greenColor: Float = 0.9
    var blueColor: Float = 0.9
    var whiteColor: Float = 0.9
    var alpha: Float = 0.9
    var colorMode: Bool = true
    
    @IBOutlet weak var textLarge: UITextView!
    @IBOutlet weak var textMedium: UITextView!
    @IBOutlet weak var textSmall: UITextView!
    @IBOutlet weak var redValue: UILabel!
    @IBOutlet weak var greenValue: UILabel!
    @IBOutlet weak var blueValue: UILabel!
    @IBOutlet weak var alphaValue: UILabel!
    
    
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        
        // Do any additional setup after loading the view.
    }
}

