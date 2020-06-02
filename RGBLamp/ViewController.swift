//
//  ViewController.swift
//  RGBLamp
//
//  Created by Peter Borden on 12/19/19.
//  Copyright © 2019 Peter Borden. All rights reserved.
//

import UIKit

struct Hue {
    var name: String
    var red: Float
    var green: Float
    var blue: Float
    var alpha: Float
}

class ViewController: UIViewController {
    
    var redColor: Float = UserDefaults.standard.float(forKey: "red")
    var greenColor: Float = UserDefaults.standard.float(forKey: "green")
    var blueColor: Float = UserDefaults.standard.float(forKey: "blue")
    var whiteColor: Float = 0.9
    var alpha: Float = UserDefaults.standard.float(forKey: "alpha")
    var colorMode: Bool = true
    var alertPresented: Bool = false
    var minFontSize: Float = 4.0
    
    // temporary values used to toggle white/color mode
    var tempRed: Float = 0.0
    var tempGreen: Float = 0.0
    var tempBlue: Float = 0.0
    var tempAlpha: Float = 0.0
    var tempWhite: Float = 0.0
    
    var onState: Bool = true  // used to toggle on/off switch
    
    // arrays of user saved hues, used in PresetViewController
    // needs to be separate arrays vs. Hue object for saving as user default
    var userName: [String] = []
    var userRed: [Float] = []
    var userGreen: [Float] = []
    var userBlue: [Float] = []
    var userAlpha: [Float] = []
    
    var largeFontSize = UserDefaults.standard.float(forKey: "largeFont")
    var smallFontSize = UserDefaults.standard.float(forKey: "smallFont")
    
    let minSize: Float = 4.0 // minimum font size
    
    @IBOutlet weak var textLarge: UITextView!
    @IBOutlet weak var textSmall: UITextView!
    @IBOutlet weak var largeFont: UITextField!
    @IBOutlet weak var smallFont: UITextField!
    @IBOutlet weak var redValue: UILabel!
    @IBOutlet weak var greenValue: UILabel!
    @IBOutlet weak var blueValue: UILabel!
    @IBOutlet weak var alphaValue: UILabel!
    @IBOutlet weak var setRedSlider: UISlider!
    @IBOutlet weak var setGreenSlider: UISlider!
    @IBOutlet weak var setBlueSlider: UISlider!
    @IBOutlet weak var setAlphaSlider: UISlider!
    
    @IBAction func saveHue(_ button: UIButton) {
        var hueName = ""
        let alert = UIAlertController(title: "Name of saved color?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input name here..."
        })
        
        loadUserDefaultArrays()

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

            if let name = alert.textFields?.first?.text {
                hueName = name
                print("Your name: \(hueName)")
                
                self.userName.append(hueName)
                self.userRed.append(self.redColor)
                self.userBlue.append(self.blueColor)
                self.userGreen.append(self.greenColor)
                self.userAlpha.append(self.alpha)
                
                UserDefaults.standard.set(self.userName, forKey: "userName")
                UserDefaults.standard.set(self.userRed, forKey: "userRed")
                UserDefaults.standard.set(self.userGreen, forKey: "userGreen")
                UserDefaults.standard.set(self.userBlue, forKey: "userBlue")
                UserDefaults.standard.set(self.userAlpha, forKey: "userAlpha")
                
            }
            print("Saved: \(self.userName)")
            
        }))

        self.present(alert, animated: true)
    }
    
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
        slider.isContinuous = false
        redColor = slider.value
        setBackgroundColor()
    }
    
    @IBAction func greenSlider(_ slider: UISlider) {
        slider.isContinuous = false
        greenColor = slider.value
        setBackgroundColor()
    }
    
    @IBAction func blueSlider(_ slider: UISlider) {
        slider.isContinuous = false
        blueColor = slider.value
        setBackgroundColor()
    }
    
    @IBAction func alphaSlider(_ slider: UISlider) {
        slider.isContinuous = false
        alpha = slider.value
        setBackgroundColor()
    }
    
    @IBAction func colorButton(_ button: UIButton) {
         if colorMode {
            tempRed = redColor
            tempGreen = greenColor
            tempBlue = blueColor
            tempAlpha = alpha
            
            redColor = whiteColor
            greenColor = whiteColor
            blueColor = whiteColor
            
            setBackgroundWhite()
        } else {
            redColor = tempRed
            greenColor = tempGreen
            blueColor = tempBlue
            
            setBackgroundColor()
        }
    }
    
    @IBAction func onOff (_ sender: AnyObject) {
        // initiate bluetooth connection
        if onState {
            tempAlpha = alpha
            alpha = 0.0
            setLEDs()
            onState = false
        } else {
            alpha = tempAlpha
            BTComm.shared().centralManager.scanForPeripherals(withServices: [BLEService_UUID], options: nil)
            setLEDs()
            onState = true
        }
    }
    
    func setBackgroundColor() {
        
        textLarge.backgroundColor = UIColor(
            red: CGFloat(redColor),
            green: CGFloat(greenColor),
            blue: CGFloat(blueColor),
            alpha: CGFloat(alpha)
        )
        textSmall.backgroundColor = textLarge.backgroundColor
        colorMode = true
        
        setLabels()
        setLEDs()
    }
    
    func setBackgroundWhite() {
        textLarge.backgroundColor = UIColor(
            red: CGFloat(whiteColor),
            green: CGFloat(whiteColor),
            blue: CGFloat(whiteColor),
            alpha: CGFloat(alpha)
        )
        textSmall.backgroundColor = textLarge.backgroundColor
        colorMode = false
        
        setLabels()
        setLEDs()
        
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
    
    func setLEDs() {
        
        // normalize so output independent of mix of colors, only dependent on alpha
        /*let colorSum = redColor + greenColor + blueColor
        let newRed = redColor / colorSum
        let newGreen = greenColor / colorSum
        let newBlue = blueColor / colorSum */
        
        let newRed = redColor
        let newGreen = greenColor
        let newBlue = blueColor
        
        let redLEDunscaled = (ADCMaximumValue * newRed * alpha)
        let greenLEDunscaled = (ADCMaximumValue * newGreen * alpha)
        let blueLEDunscaled = (ADCMaximumValue * newBlue * alpha)
        let whiteLEDunscaled = (ADCMaximumValue * whiteColor * alpha)
        
        // find the lowest maximum lux value between red, green blue
        let maxLux = findMaxLux()
        
        // find scaling factors for each color
        let redScale = maxLux / redMax
        let greenScale = maxLux / greenMax
        let blueScale = maxLux / blueMax
        let whiteScale: Float  = 1.0
        
        let redLED = Int(redLEDunscaled * redScale)
        let greenLED = Int(greenLEDunscaled * greenScale)
        let blueLED = Int(blueLEDunscaled * blueScale)
        let whiteLED = Int(whiteLEDunscaled * whiteScale)
        
        BTComm.shared().research.alpha = alpha
        BTComm.shared().research.red = redColor
        BTComm.shared().research.green = greenColor
        BTComm.shared().research.blue = blueColor
        
        //sendToBT(color: color, white: white, red: red, green: green, blue: blue, frequency: maxFrequency, dutyCycle: maxDutyCycle)
        valueToString(white: whiteLED, red: redLED, green: greenLED, blue: blueLED)
    }
    
    func findMaxLux() -> Float {
        var maximumLux = redMax
        if greenMax < maximumLux {
            maximumLux = greenMax
        }
        if blueMax < maximumLux {
            maximumLux = blueMax
        }
        return maximumLux
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDefaults()
        setBackgroundColor()
        print("View controller appearing")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Red = \(redColor)")
        print("Green = \(greenColor)")
        print("Blue = \(blueColor)")
        print("Alpha = \(alpha)")
        print("Large font size = \(largeFontSize)")
        print("Small font size = \(smallFontSize)")
        
        if (redColor + greenColor + blueColor) == 0 {
            redColor = 0.1
            greenColor = 0.1
            blueColor = 0.1
        }
        
        //set start-up values of sliders
        setRedSlider.value = UserDefaults.standard.float(forKey: "red")
        setGreenSlider.value = UserDefaults.standard.float(forKey: "green")
        setBlueSlider.value = UserDefaults.standard.float(forKey: "blue")
        
        largeFontSize = UserDefaults.standard.float(forKey: "largeFont")
        smallFontSize = UserDefaults.standard.float(forKey: "smallFont")
        
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
            largeFontSize = 18.0
            smallFontSize = 10.0
            userName = []
            userRed = []
            userGreen = []
            userBlue = []
            userAlpha = []
        } else {
            loadUserDefaultArrays()
        }
        
        setBackgroundColor()
        
        if largeFontSize < minFontSize {
            largeFontSize = minFontSize
        }
        
        if smallFontSize < minFontSize {
            smallFontSize = minFontSize
        }
        
        textLarge.font = .systemFont(ofSize: CGFloat(largeFontSize))
        textSmall.font = .systemFont(ofSize: CGFloat(smallFontSize))
        
        largeFont.text = "\(Int(largeFontSize))"
        smallFont.text = "\(Int(smallFontSize))"
        
       /* if !alertPresented {
            let alert = UIAlertController(title: "How to use", message: "For instructions, hit Help at lower right", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            
            alertPresented = true
        } */
    }
    
    func loadUserDefaultArrays() {
        userName = UserDefaults.standard.stringArray(forKey: "userName") ?? [String]()
        userRed = UserDefaults.standard.array(forKey: "userRed") as? [Float] ?? [Float]()
        userGreen = UserDefaults.standard.array(forKey: "userGreen") as? [Float] ?? [Float]()
        userBlue = UserDefaults.standard.array(forKey: "userBlue") as? [Float] ?? [Float]()
        userAlpha = UserDefaults.standard.array(forKey: "userAlpha") as? [Float] ?? [Float]()
    }
    
    func loadDefaults() {
        redColor = UserDefaults.standard.float(forKey: "red")
        greenColor = UserDefaults.standard.float(forKey: "green")
        blueColor = UserDefaults.standard.float(forKey: "blue")
        whiteColor = 0.9
        alpha = UserDefaults.standard.float(forKey: "alpha")
        colorMode = true
        setRedSlider.value = redColor
        setGreenSlider.value = greenColor
        setBlueSlider.value = blueColor
        setAlphaSlider.value = alpha
    }
    
   /* override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(redColor, forKey: "red")
        UserDefaults.standard.set(greenColor, forKey: "green")
        UserDefaults.standard.set(blueColor, forKey: "blue")
        UserDefaults.standard.set(alpha, forKey: "alpha")
    } */
}

