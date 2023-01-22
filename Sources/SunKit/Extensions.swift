//
//  Extensions.swift
//  
//
//  Created by Davide Biancardi on 05/11/22.
//

import Foundation

//It consents us too loop between two dates for n as interval time
extension Date: Strideable {
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}


//TO DO: UT coverage
extension Calendar {
    func numberOfDaysSinceStartOfTheYear(for date: Date) -> Int {
        let startOfTheYear: Date = startOfYear(date)
        let startOfTheDay = startOfDay(for: date)
        let numberOfDays = dateComponents([.day], from: startOfTheYear, to: startOfTheDay)
        
        return numberOfDays.day! + 1
    }
    
    func startOfYear(_ date: Date) -> Date {
        return self.date(from: self.dateComponents([.year], from: date))!
    }
    
}
