//
//  HMS.swift
//  
//
//  Created by Davide Biancardi on 05/11/22.
//

import Foundation


/// Time expressed in HMS format
public struct HMS: Equatable{
    
    public var hours: Double
    public var minutes: Double
    public var seconds: Double
    
    public init(from date: Date){
        
        var calendar: Calendar = .init(identifier: .gregorian)
        calendar = .current
        
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
