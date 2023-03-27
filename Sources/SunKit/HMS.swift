//
//  HMS.swift
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


/// Time expressed in HMS format
public struct HMS: Equatable{
    
    public var hours: Double
    public var minutes: Double
    public var seconds: Double
    
    public init(from date: Date, useSameTimeZone: Bool){
        
        var calendar: Calendar = .init(identifier: .gregorian)
        calendar.timeZone = useSameTimeZone ?  .current : .init(abbreviation: "GMT")!
        
        self.hours = Double(calendar.component(.hour, from: date))
        self.minutes = Double(calendar.component(.minute, from: date))
        self.seconds = Double(calendar.component(.second, from: date))
    }
    
    public init(hours: Double,minutes: Double,seconds: Double){
        
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    public init(decimal: Double){
        
        //Step1:
        let sign = decimal < 0 ? -1 : 1
        //Step2:
        let dec = abs(decimal)
        //Step3:
        var hours = Int(dec)
        //Step4:
        let minutes = Int(60 * dec.truncatingRemainder(dividingBy: 1))
        //Step5:
        let seconds = 60 * (60 * dec.truncatingRemainder(dividingBy: 1)).truncatingRemainder(dividingBy: 1)
        //Step6:
        hours *= sign

        self.hours = Double(hours)
        self.minutes = Double(minutes)
        self.seconds = seconds
    
    }
    
    /// It converts from HMS format to decimal
    /// - Returns: HMS of the instance expressed in decimal format
    public func hMS2Decimal() -> Double {
        
        //Step3:
        let dm: Double = Double(seconds / 60)
        //Step4:
        let totalMinutes: Double = dm + Double(minutes)
        //Step5:
        var decimalHour: Double = totalMinutes / 60
        //Step6:
        decimalHour += Double(hours)
        
        return decimalHour
    }
    
}
