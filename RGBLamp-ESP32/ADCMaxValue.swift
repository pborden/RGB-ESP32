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
let ADCMaximumValue: Float = 255.0   // Maximum value in digital counts (8 bit conversion in ESP32)
let delaySec = 0.0    // delay between successive transmissions of values on BlueTooth
let base = 10.0  // for number conversion 32 for BlueFruit, 10 for ESP32

// fit coefficients for red, green, blue lux
/*
let redLuxCoeff: [Float] = [-233.7, 7.714, 0.0]   //[0.071, 4139.0, -1433.0]
let greenLuxCoeff: [Float] = [-180.44, 7.8952, 0.0]   //[5.357, 3738.0, -620.5]
let blueLuxCoeff: [Float] = [-395.2, 12.28, 0.0]   //[26.74, 3246.0, 0.0]
 */

// fit coefficients for reg, green, blue A/D counts as a function of lux (inverse of above)
let redADCoeff: [Float] = [73.16, 0.2893, -7.697e-5] //[30.34, 0.1296, 0.0]
let greenADCoeff: [Float] = [79.48, 0.1536, 1.676e-5] //[23.03, 0.1256, 0.0]
let blueADCoeff: [Float] = [83.49, 0.1355, -1.764e-5 ] //[32.58, 0.08103, 0.0]

// A/D counts where the LEDs turn on
let turnOnOffset: Float = 8.0 // Reduce turn-on to ensure LEDs off at zero intensity
let redTurnOn: Float = redADCoeff[0] - turnOnOffset
let greenTurnOn: Float = greenADCoeff[0] - turnOnOffset
let blueTurnOn: Float = blueADCoeff[0] - turnOnOffset

// these factors enable scaling the output of each LED string
let blueScaleFactor: Float = 1.0 // .67 from calibration
let greenScaleFactor: Float = 1.0 // 1.0
let redScaleFactor: Float = 1.0  // .9585 from calibration
let alphaScaleFactor: Float = 1.0 // 1.0 Scales alpha when peak intensity reached at low values of alpha to provide
                                    // more slider range. Scales all three colors equally

// maximum values in lux for red, green, blue at 10" and alpha = 1.0
/*
let redMax = redLuxCoeff[0] + ADCMaximumValue * (redLuxCoeff[1] + ADCMaximumValue * redLuxCoeff[2])
let greenMax = greenLuxCoeff[0] + ADCMaximumValue * (greenLuxCoeff[1] + ADCMaximumValue * greenLuxCoeff[2])
let blueMax = blueLuxCoeff[0] + ADCMaximumValue * (blueLuxCoeff[1] + ADCMaximumValue * greenLuxCoeff[2])
 */

// Lux limits for individual colors
let redLimit: Float = 780.0 //825.0; gets too hot beyond this value
let greenLimit: Float = 1000.0 //1100.0
let blueLimit: Float = 1550.0 //1260.0

let maxLampLux: Float = 2200.0  // maximum output of the lamp

// For ESP32:
// Convert 3 digit number for each LED value to ASCII string, then combine to make BLE string
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

// Convert three integer digits to an ascii string. Used to build 9 digit string, 3 for each LED output.
func stringConversion(number: Int) -> String {
    let hundredsPlace = Int(Double(number) / base / base)
    let tensPlace = Int((Double(number) - Double(hundredsPlace) * base * base) / base)
    let unitsPlace = number - Int(base * (Double(tensPlace) + base * Double(hundredsPlace)))
    //print("100's: \(hundredsPlace), 10's: \(tensPlace), 1's: \(unitsPlace)")
    let hundredsPlaceString = convertToAscii(number: hundredsPlace)
    let tensPlaceString = convertToAscii(number: tensPlace)
    let unitsPlaceString = convertToAscii(number: unitsPlace)
   // print("String 100's: \(hundredsPlaceString), 10's: \(tensPlaceString), 1's: \(unitsPlaceString)")
    let asciiString = hundredsPlaceString + tensPlaceString + unitsPlaceString
    
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
    var redLux = redFraction * maxLampLux * alpha
    var greenLux = greenFraction * maxLampLux * alpha
    var blueLux = blueFraction * maxLampLux * alpha
    
    //print("Lux values: red \(redLux), green \(greenLux), blue \(blueLux)")
    
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
    
    // convert slider settings (red, green, blue) to digital values over range of TurnOn to ADCMaximum
    /*let redIntensity = red * redScaleFactor * alpha * alphaScaleFactor * (ADCMaximumValue - redTurnOn) + redTurnOn
    let greenIntensity = green * greenScaleFactor * alpha * alphaScaleFactor * (ADCMaximumValue - greenTurnOn) + greenTurnOn
    let blueIntensity = blue * blueScaleFactor * alpha * alphaScaleFactor * (ADCMaximumValue - blueTurnOn) + blueTurnOn */
    
    // find lux value for each color based on measured quadatic curve fit of lux vs A/D counts
    
    /*
    var redLedLux = redLuxCoeff[0] + redIntensity * (redLuxCoeff[1] + redIntensity * redLuxCoeff[2])
    var greenLedLux = greenLuxCoeff[0] + greenIntensity * (greenLuxCoeff[1] + greenIntensity * greenLuxCoeff[2])
    var blueLedLux = blueLuxCoeff[0] + blueIntensity * (blueLuxCoeff[1] + blueIntensity * blueCLuxoeff[2])
    
    // make sure all the lux values are greater than zero
    if (redLedLux < 0) {
        redLedLux = 0
    }
    if (greenLedLux < 0) {
        greenLedLux = 0
    }
    if (blueLedLux < 0) {
        blueLedLux = 0
    }
    
    // make sure lux values for individual colors do not exceed allowable limit
    // find a common scaling factor to reduce all colors by same fraction if any color is over the limit
    var luxScaleFactor: Float = 1.0
    if redLedLux > redLimit {
        luxScaleFactor = redLimit / redLedLux
    }
    if greenLedLux > greenLimit {
        let tempLuxScaleFactor = greenLimit / greenLedLux
        if tempLuxScaleFactor < luxScaleFactor {
            luxScaleFactor = tempLuxScaleFactor
        }
    }
    if blueLedLux > blueLimit {
        let tempLuxScaleFactor = blueLimit / blueLedLux
        if tempLuxScaleFactor < luxScaleFactor {
            luxScaleFactor = tempLuxScaleFactor
        }
    }
    
    // Lamp also has a maximum total lux. See if set lux exceeds max. If so, find scale factor
    let totalLux = redLedLux + greenLedLux + blueLedLux
    if (totalLux > maxLampLux) {
        let templuxScaleFactor = maxLampLux / totalLux
        if templuxScaleFactor < luxScaleFactor {
            luxScaleFactor = templuxScaleFactor
        }
    }
    print("R, G, B, total Lux: \(redLedLux), \(greenLedLux), \(blueLedLux), \(totalLux)")
    
    // Find ADC values; scale by luxScalFactor if any LED too bright
    var LED = 0
    if alpha > 0 {
        if color == "red" {
            if red > 0.0 {
                LED = Int(luxScaleFactor * redIntensity)
            }
        } else if color == "green" {
            if green > 0.0 {
                LED = Int(luxScaleFactor * greenIntensity)
            }
        } else {
            if blue > 0.0 {
                LED = Int(luxScaleFactor * blueIntensity)
            }
        }
    }
    
    if (LED > Int(ADCMaximumValue)) {
        LED = Int(ADCMaximumValue)
    }
    */
    
}

