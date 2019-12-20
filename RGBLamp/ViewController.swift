//
//  ViewController.swift
//  RGBLamp
//
//  Created by Peter Borden on 12/19/19.
//  Copyright © 2019 Peter Borden. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var redColor: Float = 0.33
    var greenColor: Float = 0.33
    var blueColor: Float = 0.33
    var whiteColor: Float = 0.90
    
    @IBOutlet weak var textLarge: UITextView!
    @IBOutlet weak var textMedium: UITextView!
    @IBOutlet weak var textSmall: UITextView!
    
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
    
    @IBAction func whiteButton(_ button: UIButton) {
        setBackgroundWhite()
    }
    
    @IBAction func colorButton(_ button: UIButton) {
        setBackgroundColor()
    }
    
    func setBackgroundColor() {
        textLarge.backgroundColor = UIColor(
            red: CGFloat(redColor),
            green: CGFloat(greenColor),
            blue: CGFloat(blueColor),
            alpha: 1.0
        )
        textMedium.backgroundColor = textLarge.backgroundColor
        textSmall.backgroundColor = textLarge.backgroundColor
    }
    
    func setBackgroundWhite() {
        textLarge.backgroundColor = UIColor(
            red: CGFloat(whiteColor),
            green: CGFloat(whiteColor),
            blue: CGFloat(whiteColor),
            alpha: 1.0
        )
        textMedium.backgroundColor = textLarge.backgroundColor
        textSmall.backgroundColor = textLarge.backgroundColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        
        // Do any additional setup after loading the view.
    }


}

