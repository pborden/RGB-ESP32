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
let ADCMaximumValue: Float = 255.0   // Maximum value in digital counts (8 bit conversion in ESP32
let delaySec = 0.0    // delay between successive transmissions of values on BlueTooth

let maxFrequency: Int = 1000  // these values are tests to see if not in flicker mode
let maxDutyCycle: Int = 2
let base = 10.0  // for number conversion 32 for BlueFruit, 10 for ESP32

// fit coefficients for red, green, blue
let redCoeff: [Float] = [0.071, 4139.0, -1433.0]
let greenCoeff: [Float] = [5.357, 3738.0, -620.5]
let blueCoeff: [Float] = [26.74, 3246.0, 0.0]

let blueScaleFactor: Float = 1.0
let greenScaleFactor: Float = 1.0
let redScaleFactor: Float = 1.0

// maximum values in lux for red, green, blue at 10"
let redMax = redCoeff[0] + redCoeff[1] + redCoeff[2]
let greenMax = greenCoeff[0] + greenCoeff[1] + greenCoeff[2]
let blueMax = blueCoeff[0] + blueCoeff[1] + greenCoeff[2]

let maxLampLux: Float = 10000.0  // maximum output of the lamp

// This function is used by all modules to send data to the bluetooth interface.
// A color must be specified, followed by ADC values (0 to ADCMaximumValue above) for that color
// The color is a single letter as seen in the if statements below
// The module will send the color letter and the integer value.

// 3.18.19 This is now used only in flicker mode.
// valueToString is used for all other modes.
func sendToBT(color: String, white: Int, red: Int, green: Int, blue: Int, frequency: Int, dutyCycle: Int) {

    if (color == "r") {
        BTComm.shared().writeData(header: "r", value: red)
        //DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {}
    } else if (color == "g") {
        BTComm.shared().writeData(header: "g", value: green)
        //DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {}
    } else if (color == "b") {
        BTComm.shared().writeData(header: "b", value: blue)
        //DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {}
    } else if (color == "w") {
        BTComm.shared().writeData(header: "w", value: white)
        //DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {}
    } else if (color == "f") {
        BTComm.shared().writeData(header: "f", value: frequency)
        //DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {}
    } else if (color == "d") {
        //BTComm.shared().writeData(header: "d", value: dutyCycle)
        // don't need to send duty cycle - is same as intensity
        //DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {}
    }
}

// Note: Not done in ESP32 - only for BlueFruit and AVR
// By using base 32 two ASCII digits represent an LED value from 0 to 1024 (which is 32 * 32)
// Two ASCII digits take 4 bytes, so 4 LEDs use 16 bytes
// The Bluetooth has a 20 byte buffer, so using base 32 enables sending 4 LEDs worth of data
// as a string of 8 ASCII characters (16 bytes) plus a comma as an end of string character (2 bytes)

// Function valueToString takes the integer LED value and converts it to 2 ASCII base 32 characters
// Function convertToAscii tales a number from 0 to 32 and converts it to an ASCII character,
// starting with "0" to "9", then the characters :, ;, <, =, >, ?, and @, then "A" through "P"
// if the result is "Q" then there was an error in the conversion.

// The AVR reads the ASCII value for each character and subtracts 48 (ASCII "0") to get the decimal value
// The AVR then multiplies the first digit by the base (32) and adds the second digit to get the
// intensity value for each color.

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
    stringResult = stringResult + " "  // need to append a space to end string
    
    /*if BTComm.shared().flickerMode == false {  // end of string character determines mode
        stringResult = stringResult + "}"
    } else {
        stringResult = stringResult + "{"
    }*/
    
    // send result to the BlueTooth and print it to the console.
    BTComm.shared().writeValue(data: stringResult)
    print(stringResult)
}

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

// Convert an integer from 0 to 32 to an string value corresponding to ASCII 48 to 80.
// Any out of range inputs are given the value of "Q", ASCII 81.
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
    } else if number == 10 {
        result = ":"            //ASCII 58
    } else if number == 11 {
        result = ";"            //ASCII 59
    } else if number == 12 {
        result = "<"            //ASCII 60
    } else if number == 13 {
        result = "="            //ASCII 61
    } else if number == 14 {
        result = ">"            //ASCII 62
    } else if number == 15 {
        result = "?"            //ASCII 63
    } else if number == 16 {
        result = "@"            //ASCII 64
    } else if number == 17 {
        result = "A"            //ASCII 65
    } else if number == 18 {
        result = "B"            //ASCII 66
    } else if number == 19 {
        result = "C"            //ASCII 67
    } else if number == 20 {
        result = "D"            //ASCII 68
    } else if number == 21 {
        result = "E"            //ASCII 69
    } else if number == 22 {
        result = "F"            //ASCII 70
    } else if number == 23 {
        result = "G"            //ASCII 71
    } else if number == 24 {
        result = "H"            //ASCII 72
    } else if number == 25 {
        result = "I"            //ASCII 73
    } else if number == 26 {
        result = "J"            //ASCII 74
    } else if number == 27 {
        result = "K"            //ASCII 75
    } else if number == 28 {
        result = "L"            //ASCII 76
    } else if number == 29 {
        result = "M"            //ASCII 77
    } else if number == 30 {
        result = "N"            //ASCII 78
    } else if number == 31 {
        result = "O"            //ASCII 79
    } else if number == 32 {
        result = "P"            //ASCII 80
    } else if number == 34 {
        result = "R"            //ASCII 82 (used for flicker red)
    } else if number == 35 {
        result = "S"            //ASCII 83 (used for flicker green)
    } else if number == 36 {
        result = "T"            //ASCII 84 (used for flicker blue)
    } else if number == 37 {
        result = "U"            //ASCII 85 (used for flicker white)
    } else {
        result = "V"
    }
    
    return result
}

func saveValues(for redColor: Float, for greenColor: Float, for blueColor: Float, for alpha: Float) {
    
     BTComm.shared().research.alpha = alpha
     BTComm.shared().research.red = redColor
     BTComm.shared().research.green = greenColor
     BTComm.shared().research.blue = blueColor
     
     UserDefaults.standard.set(redColor, forKey: "red")
     UserDefaults.standard.set(greenColor, forKey: "green")
     UserDefaults.standard.set(blueColor, forKey: "blue")
     UserDefaults.standard.set(alpha, forKey: "alpha")
}

func ledValue(color: String, for red: Float, for green: Float, for blue: Float, for alpha: Float) -> Int {
    
    //print("Color: \(color), red: \(red), green: \(green), blue: \(blue), alpha: \(alpha)")
    // intensities as set by user
    let redIntensity = red * alpha
    let greenIntensity = green * alpha
    let blueIntensity = blue * alpha
    
    // find lux value for each color
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
