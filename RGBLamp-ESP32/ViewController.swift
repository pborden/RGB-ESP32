//
//  ViewController.swift
//  RGBLamp
//
//  Created by Peter Borden on 12/19/19.
//  Copyright © 2019 Peter Borden. All rights reserved.
//

import UIKit

// this is the home view controller
class ViewController: UIViewController {
    
    // Define the colors and initialize them using saved user defaults. White is not used; set to fixed value now.
    var redColor: Float = UserDefaults.standard.float(forKey: "red")
    var greenColor: Float = UserDefaults.standard.float(forKey: "green")
    var blueColor: Float = UserDefaults.standard.float(forKey: "blue")
    var whiteColor: Float = 0.9
    let minTextBackground: Float = 0.0  // sets minimum brightness in text field. Set to zero with borders added
    let thumbAlpha: Float = 0.3 // minimum value of alpha for slider thumb color
    var alpha: Float = UserDefaults.standard.float(forKey: "alpha") // alpha is the intensity
    var colorMode: Bool = true // color mode allows changes to each color; white mode toggled with color/white button
    var alertPresented: Bool = false // can be used with start-up alert (not implemented)
    var minFontSize: Float = 4.0 // minimum sizes of the fonts in the reading chart text blocks
    
    // temporary values used to toggle white/color modes
    var tempRed: Float = 0.0
    var tempGreen: Float = 0.0
    var tempBlue: Float = 0.0
    var tempAlpha: Float = 0.0
    var tempWhite: Float = 0.0
    
    var onState: Bool = true  // used to toggle on/off switch
    var alphaInOnState: Float = 1.0
    
    // arrays of user saved hues, used in PresetViewController
    // needs to be separate arrays vs. using a Hue object for saving as user defaults
    var userName: [String] = []
    var userRed: [Float] = []
    var userGreen: [Float] = []
    var userBlue: [Float] = []
    var userAlpha: [Float] = []
    
    // Set the font size for the vision chart text blocks. Top block is large font; bottom block is small font
    var largeFontSize = UserDefaults.standard.float(forKey: "largeFont")
    var smallFontSize = UserDefaults.standard.float(forKey: "smallFont")
    
    // Control outlets
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
    @IBOutlet weak var onOffSwitch: UIButton!
    @IBOutlet weak var colorWhiteSwitch: UIButton!
    
    // Saves the current hue (RGB combination)
    @IBAction func saveHue(_ button: UIButton) {
        // Provide alert to let user give the hue a name.
        var hueName = ""
        let alert = UIAlertController(title: "Name of saved color?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input name here..."
        })
        
        loadUserDefaultArrays() //Subroutine to populate arrays with previously saved hues

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

            if let name = alert.textFields?.first?.text {
                hueName = name
                print("Your name: \(hueName)")
                
                // Append the new name and colors to the existing arrays and save in User Defaults
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
        // Show the alert
        self.present(alert, animated: true)
    }
    
    // Increase the font size in the top box
    @IBAction func largeTextBigger(_ button: UIButton) {
        largeFontSize = largeFontSize + 1.0 // Increment size
        textLarge.font = .systemFont(ofSize: CGFloat(largeFontSize))
        largeFont.text = "\(Int(largeFontSize))" // Update text showing current font size
        UserDefaults.standard.set(largeFontSize, forKey: "largeFont") // Save current font size
    }
    
    // Decrease the font size in the top box
    @IBAction func largeTextSmaller(_ button: UIButton) {
        largeFontSize = largeFontSize - 1.0 // Decrement size; check if >= minimum size
            if largeFontSize < minFontSize {
                largeFontSize = minFontSize
            }
        textLarge.font = .systemFont(ofSize: CGFloat(largeFontSize))
        largeFont.text = "\(Int(largeFontSize))"  // Update text showing current font size
        UserDefaults.standard.set(largeFontSize, forKey: "largeFont") // Save current font size
    }
    
    @IBAction func smallTextBigger(_ button: UIButton) {
        smallFontSize = smallFontSize + 1.0 // Increment size
        textSmall.font = .systemFont(ofSize: CGFloat(smallFontSize))
        smallFont.text = "\(Int(smallFontSize))"  // Update text showing current font size
        UserDefaults.standard.set(smallFontSize, forKey: "smallFont") // Save current font size
    }
    
    @IBAction func smallTextSmaller(_ button: UIButton) {
        smallFontSize = smallFontSize - 1.0 // Decrement size; check if >= minimum size
            if smallFontSize < minFontSize {
                smallFontSize = minFontSize
            }
        textSmall.font = .systemFont(ofSize: CGFloat(smallFontSize))
        smallFont.text = "\(Int(smallFontSize))"  // Update text showing current font size
        UserDefaults.standard.set(smallFontSize, forKey: "smallFont") // Save current font size
    }
    
    // These 4 actions set the RGB and alpha values based on the sliders and change the background
    // color of the two text boxes according to the new slider values.
    // Only the final slider value is read (not continuous, as this could overload Bluetooth output.
    @IBAction func redSlider(_ slider: UISlider) {
        slider.isContinuous = false
        redColor = slider.value
        // let redValue = thumbAlpha + (1 - thumbAlpha) * redColor
        // slider.thumbTintColor = UIColor(red: CGFloat(redValue), green: 0.0, blue: 0.0, alpha: 1.0)
        setBackgroundColor()
    }
    
    @IBAction func greenSlider(_ slider: UISlider) {
        slider.isContinuous = false
        greenColor = slider.value
        // let greenValue = thumbAlpha + (1 - thumbAlpha) * greenColor
        // slider.thumbTintColor = UIColor(red: 0.0, green: CGFloat(greenValue), blue: 0.0, alpha: 1.0)
        setBackgroundColor()
    }
    
    @IBAction func blueSlider(_ slider: UISlider) {
        slider.isContinuous = false
        blueColor = slider.value
        // let blueValue = thumbAlpha + (1 - thumbAlpha) * blueColor
        // slider.thumbTintColor = UIColor(red: 0.0, green: 0.0, blue: CGFloat(blueValue), alpha: 1.0)
        setBackgroundColor()
    }
    
    @IBAction func alphaSlider(_ slider: UISlider) {
        slider.isContinuous = false
        alpha = slider.value
        // let alphaValue = thumbAlpha + (1 - thumbAlpha) * alpha
        // slider.thumbTintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: CGFloat(alphaValue))
        setBackgroundColor()
    }
    
    // This button switches the background of the text fields between colored and white
    @IBAction func colorButton(_ button: UIButton) {
         if colorMode {  // in color mode, switch to white mode
            tempRed = redColor      // save current color settings
            tempGreen = greenColor
            tempBlue = blueColor
            tempAlpha = alpha
            
            redColor = whiteColor
            greenColor = whiteColor
            blueColor = whiteColor
            
            redValue.text = "\(whiteColor)"
            greenValue.text = "\(whiteColor)"
            blueValue.text = "\(whiteColor)"
            setRedSlider.value = whiteColor
            setGreenSlider.value = whiteColor
            setBlueSlider.value = whiteColor
            
            colorWhiteSwitch.setTitle("Color", for: .normal)
            
            setBackgroundWhite()
            
        } else {  // return to color mode
            redColor = tempRed  // recover color settings
            greenColor = tempGreen
            blueColor = tempBlue
            
            redValue.text = "\(redColor)"
            greenValue.text = "\(greenColor)"
            blueValue.text = "\(blueColor)"
            setRedSlider.value = redColor
            setGreenSlider.value = greenColor
            setBlueSlider.value = blueColor
            
            colorWhiteSwitch.setTitle("White", for: .normal)
            
            setBackgroundColor()
        }
    }
    
    // Provide function to on/off switch. Turn off by setting alpha to zero. Also re-establishes Bluetooth
    // connection if lost, which may be the case if user turns off lamp, walks away, and comes back.
    @IBAction func onOff (_ sender: AnyObject) {
        // initiate bluetooth connection
        if onState {
            alphaInOnState = alpha
            alpha = 0.0  // if on, setting alpha=0 means no LED output for any color.
            setLEDs()
            onState = false
            onOffSwitch.setTitle("Turn On", for: .normal)
        } else {
            alpha = alphaInOnState // reset to original alpha value
            // reconnect in event Bluetooth connection was lost
            BTComm.shared().centralManager.scanForPeripherals(withServices: [BLEService_UUID], options: nil)
            setLEDs()
            onState = true
            onOffSwitch.setTitle("Turn Off", for: .normal)
        }
    }
    
    // sets the colored background and intensity (alpha) of the two text blocks
    func setBackgroundColor() {
        // set background color of both text blocks
        // make sure background not zero, or blocks become invisible
        var tempRed = redColor
        var tempGreen = greenColor
        var tempBlue = blueColor
        var tempAlpha = alpha
        if (tempRed + tempGreen + tempBlue) < minTextBackground {
            tempRed = minTextBackground
            tempGreen = minTextBackground
            tempBlue = minTextBackground
        }
        if tempAlpha < minTextBackground {
            tempAlpha = minTextBackground
        }
        textLarge.backgroundColor = UIColor(
            red: CGFloat(tempRed),
            green: CGFloat(tempGreen),
            blue: CGFloat(tempBlue),
            alpha: CGFloat(tempAlpha)
        )
        textSmall.backgroundColor = textLarge.backgroundColor
        colorMode = true
        
        setLabels()
        setLEDs()
    }
    
    // sets a white background for the two text blocks. Used with colored/white button
    func setBackgroundWhite() {
        // set background color to white for both text blocks, with intensity same as colored light
        var tempWhite = (redColor + greenColor + blueColor)
        var tempAlpha = alpha
        
        if tempAlpha < minTextBackground {
            tempAlpha = minTextBackground
        }
        if tempWhite < minTextBackground {
            tempWhite = minTextBackground
        }
        
        textLarge.backgroundColor = UIColor(
            red: CGFloat(tempWhite),
            green: CGFloat(tempWhite),
            blue: CGFloat(tempWhite),
            alpha: CGFloat(tempAlpha)
        )
        textSmall.backgroundColor = textLarge.backgroundColor
        colorMode = false
        
        setLabels()
        setLEDs()
        
    }
    
    // sets the labels at the ends of the sliders to read out a numeric value between 0 and 100
    func setLabels() {
        // label values must be integers. Multiply by 100 since base values are in the range of 0 to 1
        let redColorInt = Int(100 * redColor)
        let greenColorInt = Int(100 * greenColor)
        let blueColorInt = Int(100 * blueColor)
        let alphaInt = Int(100 * alpha)
        
        redValue.text = "\(redColorInt)"
        greenValue.text = "\(greenColorInt)"
        blueValue.text = "\(blueColorInt)"
        alphaValue.text = "\(alphaInt)"
    }
    
    // send the LED string intensities to the lamp
    func setLEDs() {
        
        // find the led output values (the ledValue() routine is in ADCMaxValue.swift)
        let redLED = ledValue(color: "red", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let greenLED = ledValue(color: "green", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let blueLED = ledValue(color: "blue", for: redColor, for: greenColor, for: blueColor, for: alpha)
        let whiteLED: Int = 0
        
        // save the color values to user defaults (the saveValues() routine is in ADCMaxValue.swift)
        saveValues(for: redColor, for: greenColor, for: blueColor, for: alpha)
        
        print("red: \(redLED), green: \(greenLED), blue: \(blueLED)")
        
        // send the color values to the Bluetooth (the valueToString() routine is in ADCMaxValue.swift)
        valueToString(white: whiteLED, red: redLED, green: greenLED, blue: blueLED)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDefaults() // load user defaults at start
        setBackgroundColor() // set the background color of the text blocks based on the user defaults
        print("View controller appearing")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // print current values for diagnostic purposes
        print("Red = \(redColor)")
        print("Green = \(greenColor)")
        print("Blue = \(blueColor)")
        print("Alpha = \(alpha)")
        print("Large font size = \(largeFontSize)")
        print("Small font size = \(smallFontSize)")
        
        // set a low background level if all three colors are zero.
        // otherwise, the text blocks will be invisible
        if (redColor + greenColor + blueColor) == 0 {
            redColor = 0.1
            greenColor = 0.1
            blueColor = 0.1
        }
        
        //set start-up values of sliders by loading user defaults
        setRedSlider.value = UserDefaults.standard.float(forKey: "red")
        setGreenSlider.value = UserDefaults.standard.float(forKey: "green")
        setBlueSlider.value = UserDefaults.standard.float(forKey: "blue")
        
        largeFontSize = UserDefaults.standard.float(forKey: "largeFont")
        smallFontSize = UserDefaults.standard.float(forKey: "smallFont")
        
        // add borders to text fields so their presence is seen even at low intensity
        textLarge!.layer.borderWidth = 1
        textLarge!.layer.borderColor = UIColor.darkGray.cgColor
        textSmall!.layer.borderWidth = 1
        textSmall!.layer.borderColor = UIColor.darkGray.cgColor
        
        colorWhiteSwitch.setTitle("White", for: .normal)
        onOffSwitch.setTitle("Turn OFF", for: .normal)
        
        // on first run of program, need to set initial values
        if UserDefaults.standard.string(forKey: "firstTry") != "no" {
            UserDefaults.standard.set("no", forKey: "firstTry") // not first try anymore
            // set initial values
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
        } else { // not first try; initialize with user defaults
            loadUserDefaultArrays()
        }
        
        setBackgroundColor()
        // make sure fonts in the two text blocks are at least the minimum font size
        if largeFontSize < minFontSize {
            largeFontSize = minFontSize
        }
        
        if smallFontSize < minFontSize {
            smallFontSize = minFontSize
        }
        // set font size in the two text blocks
        textLarge.font = .systemFont(ofSize: CGFloat(largeFontSize))
        textSmall.font = .systemFont(ofSize: CGFloat(smallFontSize))
        // label the font size
        largeFont.text = "\(Int(largeFontSize))"
        smallFont.text = "\(Int(smallFontSize))"
        
        // this alert is not used. Presents on start-up to tell user how to find help in using app.
       /* if !alertPresented {
            let alert = UIAlertController(title: "How to use", message: "For instructions, hit Help at lower right", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            
            alertPresented = true
        } */
    }
    
    // load arrays containing name, RGB and alpha values for each user saved setting
    func loadUserDefaultArrays() {
        userName = UserDefaults.standard.stringArray(forKey: "userName") ?? [String]()
        userRed = UserDefaults.standard.array(forKey: "userRed") as? [Float] ?? [Float]()
        userGreen = UserDefaults.standard.array(forKey: "userGreen") as? [Float] ?? [Float]()
        userBlue = UserDefaults.standard.array(forKey: "userBlue") as? [Float] ?? [Float]()
        userAlpha = UserDefaults.standard.array(forKey: "userAlpha") as? [Float] ?? [Float]()
    }
    
    // load last saved values of the various settings and slider positions.
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
}

