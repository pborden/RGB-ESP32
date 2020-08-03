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

// fit coefficients for red, green, blue
let redCoeff: [Float] = [0.071, 4139.0, -1433.0]
let greenCoeff: [Float] = [5.357, 3738.0, -620.5]
let blueCoeff: [Float] = [26.74, 3246.0, 0.0]

// these factors enable scaling the output of each LED string
let blueScaleFactor: Float = 1.0
let greenScaleFactor: Float = 1.0
let redScaleFactor: Float = 1.0

// maximum values in lux for red, green, blue at 10" and alpha = 1.0
let redMax = redCoeff[0] + redCoeff[1] + redCoeff[2]
let greenMax = greenCoeff[0] + greenCoeff[1] + greenCoeff[2]
let blueMax = blueCoeff[0] + blueCoeff[1] + greenCoeff[2]

let maxLampLux: Float = 10000.0  // maximum output of the lamp

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
    
    //print("Color: \(color), red: \(red), green: \(green), blue: \(blue), alpha: \(alpha)")
    
    // intensities as set by user - the string outputs are scaled by alpha
    let redIntensity = red * alpha
    let greenIntensity = green * alpha
    let blueIntensity = blue * alpha
    
    // find lux value for each color based on measured quadatic curve fit of output vs intensity setting
    let redLedLux = redCoeff[0] + redIntensity * (redCoeff[1] + redIntensity * redCoeff[2])
    let greenLedLux = greenCoeff[0] + greenIntensity * (greenCoeff[1] + greenIntensity * greenCoeff[2])
    let blueLedLux = blueCoeff[0] + blueIntensity * (blueCoeff[1] + blueIntensity * blueCoeff[2])
    //print("R, G, B Lux: \(redLedLux), \(greenLedLux), \(blueLedLux)")
    
    // Lamp has a maximum lux. See if set lux exceeds max. If so, find scale factor
    var luxScaleFactor: Float = 1.0
    let totalLux = redLedLux + greenLedLux + blueLedLux
    if (totalLux > maxLampLux) {
        luxScaleFactor = maxLampLux / totalLux
    }
    
    // Find ADC values. R,G,B scale factors set outputs of the 3 colors equal.
    var LED = 0
    if color == "red" {
        LED = Int(ADCMaximumValue * redScaleFactor * luxScaleFactor * redLedLux / redMax)
    } else if color == "green" {
        LED = Int(ADCMaximumValue * greenScaleFactor * luxScaleFactor * greenLedLux / greenMax)
    } else {
        LED = Int(ADCMaximumValue * blueScaleFactor * luxScaleFactor * blueLedLux / blueMax)
    }
   // print("LED value: \(LED)")
    
    return LED
}

