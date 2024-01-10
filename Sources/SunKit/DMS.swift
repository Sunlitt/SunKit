//
//  DMS.swift
//
//
//  Copyright 2023 Leonardo Bertinelli, Davide Biancardi, Raffaele Fulgente, Clelia Iovine, Nicolas Mariniello, Fabio Pizzano
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

import Foundation

/// DMS format to express angles
public struct DMS: Equatable, Hashable, Codable, Sendable {
    
    public var degrees: Double
    public var minutes: Double
    public var seconds: Double
    public var isANegativeZero: Bool
    
    
    init(degrees: Double, minutes: Double, seconds: Double, isANegativeZero: Bool = false) {
        self.degrees = degrees
        self.minutes = minutes
        self.seconds = seconds
        self.isANegativeZero = isANegativeZero
    }
    
    ///From decimal it will create the corresponding angle in DMS format
    /// - Parameter decimal: Decimal angle that will be converted in DMS format
    public init(decimal: Double){
        
        //Step1:
        let sign = decimal < 0 ? -1 : 1
        //Step2:
        let dec = abs(decimal)
        //Step3:
        var degrees = Int(dec)
        //Step4:
        let minutes = Int(60 * dec.truncatingRemainder(dividingBy: 1))
        //Step5:
        let seconds = 60 * (60 * dec.truncatingRemainder(dividingBy: 1)).truncatingRemainder(dividingBy: 1)
        //Step6:
        degrees *= sign
        if degrees == 0 && sign == -1 {
            self.degrees = Double(degrees)
            self.minutes = Double(minutes)
            self.seconds = seconds
            self.isANegativeZero = true
        }
        else{
            self.degrees = Double(degrees)
            self.minutes = Double(minutes)
            self.seconds = seconds
            self.isANegativeZero = false
        }
       
        
    }
    
    /// It converts from DMS format to decimal
    /// - Returns: DMS of the instance expressed in decimal format
    public func dMS2Decimal() -> Double {
        
        //Step1:
        let sign: Double = degrees < 0 ? -1 : 1
        //Step2:
        let degrees = abs(degrees)
        //Step3:
        let dm: Double = Double(seconds / 60)
        //Step4:
        let totalMinutes: Double = dm + Double(minutes)
        //Step5:
        var decimal: Double = totalMinutes / 60
        //Step6:
        decimal += Double(degrees)
        //Step7:
        decimal *= sign
        
        if isANegativeZero{
            
            decimal *= -1
        }
        
        return decimal
    }
}
