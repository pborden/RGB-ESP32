//
//  CameraViewController.swift
//  RGBLamp-ESP32
//
//  Created by Peter Borden on 8/7/21.
//  Copyright © 2021 Peter Borden. All rights reserved.
//

import UIKit
import AVFoundation
import CoreGraphics

// this is the home view controller
class CameraViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // Define the colors and initialize them using saved user defaults. White is not used; set to fixed value now.
    var redColor: Float = UserDefaults.standard.float(forKey: "red")
    var greenColor: Float = UserDefaults.standard.float(forKey: "green")
    var blueColor: Float = UserDefaults.standard.float(forKey: "blue")
    var whiteColor: Float = 0.9
    let thumbAlpha: Float = 0.3 // minimum value of alpha for slider thumb color
    var alpha: Float = UserDefaults.standard.float(forKey: "alpha") // alpha is the intensity
    var colorMode: Bool = true // color mode allows changes to each color; white mode toggled with color/white button
    var alertPresented: Bool = false // can be used with start-up alert (not implemented)
    
    // temporary values used to toggle white/color modes
    var tempRed: Float = 0.0
    var tempGreen: Float = 0.0
    var tempBlue: Float = 0.0
    var tempAlpha: Float = 0.0
    var tempWhite: Float = 0.0
    
    // temporary values used to toggle picture match
    var tempPicRed: Float = 0.0
    var tempPicGreen: Float = 0.0
    var tempPicBlue: Float = 0.0
    var tempPicAlpha: Float = 0.0
    
    var pictureRed: Float = 0.9         // rgba values of picture
    var pictureGreen: Float = 0.9
    var pictureBlue: Float = 0.9
    var pictureAlpha: Float = 1.0
    var pictureMatched: Bool = false
    
    var onState: Bool = true  // used to toggle on/off switch
    var alphaInOnState: Float = 1.0
    
    // arrays of user saved hues, used in PresetViewController
    // needs to be separate arrays vs. using a Hue object for saving as user defaults
    var userName: [String] = []
    var userRed: [Float] = []
    var userGreen: [Float] = []
    var userBlue: [Float] = []
    var userAlpha: [Float] = []
    
    // Control outlets

    @IBOutlet weak var redValue: UILabel!
    @IBOutlet weak var greenValue: UILabel!
    @IBOutlet weak var blueValue: UILabel!
    @IBOutlet weak var alphaValue: UILabel!
    @IBOutlet weak var setRedSlider: UISlider!
    @IBOutlet weak var setGreenSlider: UISlider!
    @IBOutlet weak var setBlueSlider: UISlider!
    @IBOutlet weak var setAlphaSlider: UISlider!
    @IBOutlet weak var colorWhiteSwitch: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var matchButton: UIButton!
    
    @IBAction func snapPicture(_ button: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func matchPictureColor(_ button: UIButton) {
        
        if !pictureMatched {  // match LEDs to color mix in picture
            tempPicRed = redColor
            tempPicGreen = greenColor
            tempPicBlue = blueColor
            tempPicAlpha = alpha
            
            redColor = pictureRed
            greenColor = pictureGreen
            blueColor = pictureBlue
            alpha = pictureAlpha
        
            setRedSlider.value = redColor
            setGreenSlider.value = greenColor
            setBlueSlider.value = blueColor
            setAlphaSlider.value = alpha
            
            matchButton.setTitleColor(UIColor.red, for: .normal)
            
            pictureMatched = true
        } else { // return LEDs to original state
            redColor = tempPicRed
            greenColor = tempPicGreen
            blueColor = tempPicBlue
            alpha = tempPicAlpha
        
            setRedSlider.value = redColor
            setGreenSlider.value = greenColor
            setBlueSlider.value = blueColor
            setAlphaSlider.value = alpha
            
            matchButton.setTitleColor(UIColor.white, for: .normal)
            
            pictureMatched = false
        }
        
        setLabels()
        setLEDs()
    }
    
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
    
    // sets the colored background and intensity (alpha) of the two text blocks
    func setBackgroundColor() {
        // set background color of both text blocks
        // make sure background not zero, or blocks become invisible
        
        colorMode = true
        loadDefaults()
        setLabels()
        setLEDs()
    }
    
    // sets a white background for the two text blocks. Used with colored/white button
    func setBackgroundWhite() {
        // set background color to white for both text blocks, with intensity same as colored light
        
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
        
        // set a low background level if all three colors are zero.
        // otherwise, the text blocks will be invisible
        if (redColor + greenColor + blueColor) == 0 {
            redColor = 0.1
            greenColor = 0.1
            blueColor = 0.1
        }
        
        colorWhiteSwitch.setTitle("White", for: .normal)
        
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
            userName = []
            userRed = []
            userGreen = []
            userBlue = []
            userAlpha = []
        } else { // not first try; initialize with user defaults
            loadUserDefaultArrays()
        }
        
        setBackgroundColor()
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let yourUIImage = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        guard let currentCGImage = yourUIImage.cgImage else { return }
        let currentCIImage = CIImage(cgImage: currentCGImage)
        
        // for filters see https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CILinearToSRGBToneCurve
        
        let context = CIContext()
        
        if let cgimg = context.createCGImage(currentCIImage, from: currentCIImage.extent) {
        //if let cgimg = context.createCGImage(currentCIImage, from: currentCIImage.extent){
           // show image
            let processedImage = UIImage(cgImage: cgimg)
            userImage.image = processedImage
            
            let height = cgimg.height
            let width = cgimg.width
            print("Picture width = \(cgimg.width)")
            print("Picture height = \(cgimg.height)")
            //let imageValues: [UInt8] = pixelValues(fromCGImage: cgimg)!
            let imageValues: [UInt8]? = UIImage.pixelData(processedImage)()

            var pixelCount = 0      // number of pixels counted
            var redSum: Int = 0
            var greenSum: Int = 0
            var blueSum: Int = 0
            var alphaSum: Int = 0
            let printInterval = 10000
            
            for column in 0..<width {
                for row in 0..<height {
                    let pixel = column * height + row
                    let redValue = Int((imageValues![4 * pixel]))
                    let greenValue = Int((imageValues![4 * pixel + 1]))
                    let blueValue = Int((imageValues![4 * pixel + 2]))
                    let alphaValue = Int((imageValues![4 * pixel + 3]))
                    redSum = redValue + redSum
                    greenSum = greenValue + greenSum
                    blueSum = blueValue + blueSum
                    alphaSum = alphaValue + alphaSum
                    pixelCount = pixelCount + 1
                    if Int(printInterval) == Int(Double(pixelCount) / Double(printInterval)) {
                        print("Red = \(redValue); Green = \(greenValue); Blue = \(blueValue)")
                    }// if
                } // row <= endRow
            } // column <= endColumn
            
            let redCount = Double(redSum) / Double(pixelCount)
            let greenCount = Double(greenSum) / Double(pixelCount)
            let blueCount = Double(blueSum) / Double(pixelCount)
            
            print("\(pixelCount) pixels; red = \(redCount), green = \(greenCount), blue = \(blueCount)")
            
            pictureRed = Float(redCount) / Float(ADCMaximumValue)
            pictureGreen = Float(greenCount) / Float(ADCMaximumValue)
            pictureBlue = Float(blueCount) / Float(ADCMaximumValue)
            
            print("Picture red = \(pictureRed), green = \(pictureGreen), blue = \(pictureBlue)")
        }
        
    } // imagePickerController
}

extension UIImage {
    func pixelData() -> [UInt8]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        return pixelData
    }
 } // UIImage extension
