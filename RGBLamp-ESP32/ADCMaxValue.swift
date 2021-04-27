//
//  ADCMaxValue.swift
//  LuxIQ
//
//  Contains ADC maximum value and function to send data from a module to the bluetooth interface
//
//  Created by Peter Borden on 12/28/18.
//  Copyright © 2018 Peter Borden. All rights reserved.
//

import Foundation

// set the maximum value of the ADC here as a global picked up by all modules
let ADCMaximumValue: Float = 255.0   // For 10 bit PWM: 10230. For 8 bit PWM: 255.0
let delaySec = 0.0    // delay between successive transmissions of values on BlueTooth
let base = 10.0  // for number conversion 32 for BlueFruit, 10 for ESP32

// fit coefficients for red, green, blue lux
/*
let redLuxCoeff: [Float] = [-233.7, 7.714, 0.0]   //[0.071, 4139.0, -1433.0]
let greenLuxCoeff: [Float] = [-180.44, 7.8952, 0.0]   //[5.357, 3738.0, -620.5]
let blueLuxCoeff: [Float] = [-395.2, 12.28, 0.0]   //[26.74, 3246.0, 0.0]
 */

// fit coefficients for red, green, blue A/D counts as a function of lux (inverse of above)
let redADCoeff: [Float] = [-11.19, 0.2011, 4.788e-5] //[45.07, 0.3567, -1.093e-4] for LM3410
let greenADCoeff: [Float] = [-9.33, 0.07355, 5.699e-5] //[55.41, 0.2086, -4.165e-5] for LM3410
let blueADCoeff: [Float] = [-6.69, 0.1111, 2.016e-5 ] //[54.77, 0.2001, -1.573e-5 ] for LM3410

// A/D counts where the LEDs turn on
let turnOnOffset: Float = 0.0 // Reduce turn-on to ensure LEDs off at zero intensity
let redTurnOn: Float = 2.0
let greenTurnOn: Float = 2.0
let blueTurnOn: Float = 2.0

// these factors enable scaling the output of each LED string
// based on spreadsheet RGB lamp - filter matching. Calculates x,y,z based on spectra
// and normalizes power spectra to measured power at 255 A/D counts.
// rgb scale factors of 0.52, 1.0, 0.27 give best fit to white 6000K.
let redScaleFactor: Float = 0.52  // .69  4.26 ->.53
let greenScaleFactor: Float = 1.0 // 1.0
let blueScaleFactor: Float = 0.27// .4728 4.22 .24 -> .321 4.26->.1477
let alphaScaleFactor: Float = 1.0 // .62 for blue max = 100
// more slider range. Scales all three colors equally

// colors need to exceed these lux levels individually or they won't turn on.
// this results, for example in white having red and green but no blue.
let lowestBlue: Float = 80.0
let lowestGreen: Float = 116.0
let lowestRed: Float = 55.0

// maximum values in lux for red, green, blue at 10" and alpha = 1.0
/*
let redMax = redLuxCoeff[0] + ADCMaximumValue * (redLuxCoeff[1] + ADCMaximumValue * redLuxCoeff[2])
let greenMax = greenLuxCoeff[0] + ADCMaximumValue * (greenLuxCoeff[1] + ADCMaximumValue * greenLuxCoeff[2])
let blueMax = blueLuxCoeff[0] + ADCMaximumValue * (blueLuxCoeff[1] + ADCMaximumValue * greenLuxCoeff[2])
 */

// Lux limits for individual colors
let redLimit: Float = 1280.0 //3.17.21 increased from 1500 to 2250 4.22 set to 1280 per spreadsheet
let greenLimit: Float = 1230.0 //3.17.21 increased from 2000 to 3000. 4,8 decreased from 1620 to 1500
                                // 4.14.21 decreased to 1200  4.22 set to 1230 per spreadsheet
let blueLimit: Float = 1820.0 //3.17.21 increased from 2000 to 3000

let maxLampLux: Float = 3000.0  // maximum output of the lamp

// For ESP32:
// Convert 3 or 4 digit number for each LED value to ASCII string, then combine to make BLE string
func valueToString(white: Int, red: Int, green: Int, blue: Int) {
    var stringResult = ""
    
    // find ASCII strings for each of the colors (red, green, blue)
    // then append to string, and add a comma as an end of string value.
    // stringResult = stringConversion(number: 0) // ignore white value
    stringResult = stringResult + stringConversion(number: red)
    stringResult = stringResult + stringConversion(number: green)
    stringResult = stringResult + stringConversion(number: blue)
    stringResult = stringResult + " "  // need to append a space to indicate end of string
    
    // send result to the BlueTooth and print it to the console.
    BTComm.shared().writeValue(data: stringResult)
    print(stringResult)
    let checkValue = BTComm.shared().receivedData
    print("Check value = \(checkValue)")
}

// Convert 3 or 4 integer digits to an ascii string. Used to build 9 or 12 digit string, 3 or 4 for each LED output.
func stringConversion(number: Int) -> String {
    var asciiString = ""
    
    let baseCubed = base * base * base
    let baseSquared = base * base
    
    var residual = number
    let thousandsPlace = Int(Double(number) / baseCubed)
    residual = residual - Int(Double(thousandsPlace) * baseCubed)
    let hundredsPlace =  Int(Double(residual) / baseSquared)
    residual = residual - Int(Double(hundredsPlace) * baseSquared)
    let tensPlace = Int(Double(residual) / base)
    let unitsPlace = residual - Int(Double(tensPlace) * base)
    
    //print("1000's: \(thousandsPlace), 100's: \(hundredsPlace), 10's: \(tensPlace), 1's: \(unitsPlace)")
    let thousandsPlaceString = convertToAscii(number: thousandsPlace)
    let hundredsPlaceString = convertToAscii(number: hundredsPlace)
    let tensPlaceString = convertToAscii(number: tensPlace)
    let unitsPlaceString = convertToAscii(number: unitsPlace)
   // print("String 1000's: \(thousandsPlaceString), 100's: \(hundredsPlaceString), 10's: \(tensPlaceString), 1's: \(unitsPlaceString)")
    
    asciiString = hundredsPlaceString + tensPlaceString + unitsPlaceString
    if (ADCMaximumValue >= 1000) {
        asciiString = thousandsPlaceString + asciiString
    }
    
    return asciiString
}

// Convert an integer from 0 to 9 to an string value corresponding to ASCII 48 to 57.
// Any out of range inputs are given the value of "0", ASCII 48.
func convertToAscii(number: Int) -> String {
    var result = "0"
    if number == 0 {
        result = "0"            //ASCII 48
    } else if number == 1 {
        result = "1"            //ASCII 49
    } else if number == 2 {
        result = "2"            //ASCII 50
    } else if number == 3 {
        result = "3"            //ASCII 51
    } else if number == 4 {
        result = "4"            //ASCII 52
    } else if number == 5 {
        result = "5"            //ASCII 53
    } else if number == 6 {
        result = "6"            //ASCII 54
    } else if number == 7 {
        result = "7"            //ASCII 55
    } else if number == 8 {
        result = "8"            //ASCII 56
    } else if number == 9 {
        result = "9"            //ASCII 57
    } else {
        result = "0"
    }
    
    return result
}

func saveValues(for redColor: Float, for greenColor: Float, for blueColor: Float, for alpha: Float) {
    
    // save values across all view controllers
    BTComm.shared().research.alpha = alpha
    BTComm.shared().research.red = redColor
    BTComm.shared().research.green = greenColor
    BTComm.shared().research.blue = blueColor
     
    // save to user defaults
     UserDefaults.standard.set(redColor, forKey: "red")
     UserDefaults.standard.set(greenColor, forKey: "green")
     UserDefaults.standard.set(blueColor, forKey: "blue")
     UserDefaults.standard.set(alpha, forKey: "alpha")
}

// find the output of each string, consistent with the value of alpha and the maximum lamp output
func ledValue(color: String, for red: Float, for green: Float, for blue: Float, for alpha: Float) -> Int {
    
    print("Color: \(color), red: \(red), green: \(green), blue: \(blue), alpha: \(alpha)")
    
    // find fraction of total intensity for each color
    let redFraction = red / (red + green + blue)
    let greenFraction = green / (red + green + blue)
    let blueFraction = blue / (red + green + blue)
    
    //print("Fractions: red \(redFraction), green \(greenFraction), blue \(blueFraction)")
    
    // find intensity in lux for each color
    var redLux = redFraction * maxLampLux * alpha * redScaleFactor * alphaScaleFactor
    var greenLux = greenFraction * maxLampLux * alpha * greenScaleFactor * alphaScaleFactor
    var blueLux = blueFraction * maxLampLux * alpha * blueScaleFactor * alphaScaleFactor
    
    print("Lux values: red \(redLux), green \(greenLux), blue \(blueLux)")
    
    // make sure output limit for each color not exceeded; if so, scale outputs down
    // first determine the factor needed for each color and find the smallest of the three
    var lampScaleFactor: Float = 1.0
    if redLux > redLimit {
        let redScaling = redLimit / redLux
        lampScaleFactor = redScaling
    }
    if greenLux > greenLimit {
        let greenScaling = greenLimit / greenLux
        if greenScaling < lampScaleFactor {
            lampScaleFactor = greenScaling
        }
    }
    if blueLux > blueLimit {
        let blueScaling = blueLimit / blueLux
        if blueScaling < lampScaleFactor {
            lampScaleFactor = blueScaling
        }
    }
    
    // scale each color by the same factor (to maintain constant hue)
    redLux = redLux * lampScaleFactor
    greenLux = greenLux * lampScaleFactor
    blueLux = blueLux * lampScaleFactor
    
    print("Adjusted lux values: red \(redLux), green \(greenLux), blue \(blueLux)")
    
    //print("Lux values after scaling: red \(redLux), green \(greenLux), blue \(blueLux)")
    
    // Find AD counts corresponding to the intensity of each color
    var redAD = redADCoeff[0] + redLux * (redADCoeff[1] + redLux * redADCoeff[2])
    var greenAD = greenADCoeff[0] + greenLux * (greenADCoeff[1] + greenLux * greenADCoeff[2])
    var blueAD = blueADCoeff[0] + blueLux * (blueADCoeff[1] + blueLux * blueADCoeff[2])
    
    // make sure AD counts at turn-on value
    if (redAD < redTurnOn) && (red > 0) {
        redAD = redTurnOn
    }
    if (greenAD < greenTurnOn) && (green > 0) {
        greenAD = greenTurnOn
    }
    if (blueAD < blueTurnOn) && (blue > 0) {
        blueAD = blueTurnOn
    }
    
    // make sure color is off if value is zero
    if (red == 0) {
        redAD = 0
    }
    if (green == 0) {
        greenAD = 0
    }
    if (blue == 0) {
        blueAD = 0
    }
    
    // make sure values do not exceed maximum allowed
    if (redAD > ADCMaximumValue) {
        redAD = ADCMaximumValue
    }
    if (greenAD > ADCMaximumValue) {
        greenAD = ADCMaximumValue
    }
    if (blueAD > ADCMaximumValue) {
        blueAD = ADCMaximumValue
    }
    
    // scale values for case of 10 bit PWM
    if (ADCMaximumValue > 1000) {
        redAD = 4.0 * redAD
        greenAD = 4.0 * greenAD
        blueAD = 4.0 * blueAD
    }
    
    // return value of LED A/D counts
    var LED: Int = 0
    if color == "red" {
        LED = Int(redAD)
    } else if color == "green" {
        LED = Int(greenAD)
    } else {
        LED = Int(blueAD)
    }
    
    print("LED value for color \(color) = \(LED)")
    
    return LED
    
}

