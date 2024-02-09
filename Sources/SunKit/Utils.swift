//
//  Utils.swift
//  
//
//   Copyright 2024 Leonardo Bertinelli, Davide Biancardi, Raffaele Fulgente, Clelia Iovine, Nicolas Mariniello, Fabio Pizzano
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

let SECONDS_IN_ONE_DAY = 86399
let TWELVE_HOUR_IN_SECONDS: Double = 43200
let TWO_HOURS_IN_SECONDS: Double = 7200
let SECONDS_IN_TEN_MINUTES: Double = 600
let SECONDS_IN_ONE_HOUR: Double = 3600


/// - Parameters:
///   - a: first operand
///   - n: second operand
/// - Returns: a % n if a is positive. If a isn't positive, it will add to the result of the modulo operation the value of the n operand until the result is positive.Please note that this function only works when both operands are integers.
 public func mod(_ a: Int, _ n: Int) -> Int {
     let r = a % n
     return r >= 0 ? r : r + n
 }


 /// Same as mod function described above, but this function can accept as first operand a Double and it handle the edge case where a is included between -1 and 0.
 /// - Parameters:
 ///   - a: first operand
 ///   - n: second operand
 /// - Returns: a % n if a is positive. If a isn't positive, it will add to the result of the modulo operation the value of the n operand until the result is positive.
 public func extendedMod(_ a: Double, _ n: Int) -> Double {

     let remainder: Double = a.truncatingRemainder(dividingBy: 1)

     if (a < 0 && a > -1){

         return Double(n) + remainder
     }

     let x = Double(mod(Int(a),n))

     return x + remainder
 }



public func clamp(lower: Double, upper: Double, number: Double) -> Double {
    
    return min(upper,max(lower,number))
 }


/// Creates a date with the UTC timezone
/// - Parameters:
///   - day: day of the date you want to create
///   - month: month of the date you want to create
///   - year: year of the date you want to create
///   - hour: hour of the date you want to create
///   - minute: minute of the date you want to create
///   - seconds: second of the date you want to create
///   - nanosecond: nanosecond of the date you want to create
/// - Returns: A date with the parameters given in input. Used in combination with function jdFromDate, that accepts dates in UTC format
public func createDateUTC(day: Int,month: Int,year: Int,hour: Int,minute: Int,seconds: Int, nanosecond: Int = 0) -> Date{
    
    var calendarUTC:Calendar = .init(identifier: .gregorian)
    calendarUTC.timeZone = .init(secondsFromGMT: 0)!
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = hour
    dateComponents.minute = minute
    dateComponents.second = seconds
    dateComponents.nanosecond = nanosecond
    
    return calendarUTC.date(from: dateComponents) ?? Date()
}


/// Creates a date with the timezone used in your current device
/// - Parameters:
///   - day: day of the date you want to create
///   - month: month of the date you want to create
///   - year: year of the date you want to create
///   - hour: hour of the date you want to create
///   - minute: minute of the date you want to create
///   - seconds: second of the date you want to create
///   - nanosecond: nanosecond of the date you want to create
/// - Returns: A date with the parameters given in input
public func createDateCurrentTimeZone(day: Int,month: Int,year: Int,hour: Int,minute: Int,seconds: Int, nanosecond: Int = 0) -> Date{
    
    var calendar: Calendar = .init(identifier: .gregorian)
    calendar.timeZone = .current
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = hour
    dateComponents.minute = minute
    dateComponents.second = seconds
    dateComponents.nanosecond = nanosecond
    
    return calendar.date(from: dateComponents) ?? Date()
}

/// Creates a date with a custom timezone
/// - Parameters:
///   - day: day of the date you want to create
///   - month: month of the date you want to create
///   - year: year of the date you want to create
///   - hour: hour of the date you want to create
///   - minute: minute of the date you want to create
///   - seconds: second of the date you want to create
///   - nanosecond: nanosecond of the date you want to create
///   - timeZone: timezone of the date
/// - Returns: A date with the parameters given in input
public func createDateCustomTimeZone(day: Int,month: Int,year: Int,hour: Int,minute: Int,seconds: Int, nanosecond: Int = 0, timeZone: TimeZone) -> Date{
    
    var calendar: Calendar = .init(identifier: .gregorian)
    calendar.timeZone = timeZone
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = hour
    dateComponents.minute = minute
    dateComponents.second = seconds
    dateComponents.nanosecond = nanosecond
    
    return calendar.date(from: dateComponents) ?? Date()
}


/// Converts  Julian Number in a date
/// - Parameter jd: Julian number to convert in an UTC date
/// - Returns: The date corresponding to the julian number in input
public func dateFromJd(jd : Double) -> Date {
    let JD_JAN_1_1970_0000GMT = 2440587.5
    return  Date(timeIntervalSince1970: (jd - JD_JAN_1_1970_0000GMT) * 86400)
}


/// Converts date in his Julian Number
/// - Parameter date: UTC date to convert in julian number. TimeZone  of the given date shall be equals to +0000.
/// - Returns: The julian day number corresponding to date in input
public func jdFromDate(date : Date) -> Double {
    let JD_JAN_1_1970_0000GMT = 2440587.5
    return JD_JAN_1_1970_0000GMT + date.timeIntervalSince1970
    / 86400
}


/// Converts UT time to Greenwich Sidereal Time
/// - Parameter ut: UT time to convert in GST
/// - Parameter timeZoneInSeconds: time zone expressed in seconds of your local civil time
/// - Returns: GST equivalent of the UT given in input
public func uT2GST(_ ut:Date) -> HMS{
    
    var calendarUTC: Calendar = .init(identifier: .gregorian)
    calendarUTC.timeZone = TimeZone(identifier: "GMT")!
    
    //Step1:
    let jd = jdFromDate(date: calendarUTC.startOfDay(for: ut))
    
    //Step2:
    let year = calendarUTC.component(.year, from: ut)
    let firstDayOfTheYear = calendarUTC.date(from: DateComponents(year: year , month: 1, day: 1)) ?? Date()
    let jdZero = jdFromDate(date: firstDayOfTheYear)
    
    //Step3:
    let days = jd - jdZero
    
    //Step4:
    let T = (jdZero - 2415020.0) / 36525.0
    
    //Step5:
    let R = 6.6460656 + 2400.051262 * T + 0.00002581*(T*T)
    
    //Step6:
    let B :Double = 24 - R + Double(24 * (year - 1900))
    
    //Step7:
    let TZero = 0.0657098 * days - B
    
    //Step8:
    let utDecimal =  HMS.init(from: ut).hMS2Decimal()
    
    //Step9:
    var gstDecimal = TZero + 1.002738 * utDecimal
    
    if gstDecimal < 0 {
        
        gstDecimal += 24
        
    }else if gstDecimal >= 24 {
        
        gstDecimal -= 24
    }
    
    let gstHMS = HMS.init(decimal: gstDecimal)
    
    return gstHMS
}

/// Converts GST to Local Sidereal Time
/// - Parameters:
///   - gst: GST time to convert in LST
///   - longitude: longitude of the observer
///   - Parameter timeZoneInSeconds: time zone expressed in seconds of your local civil time
/// - Returns: LST equivalent for the GST given in input
public func gST2LST(_ gst: HMS, longitude: Angle) -> HMS{
        
    //Step1:
    let gstDecimal = gst.hMS2Decimal()
    
    //Step2:
    let adjustment: Double = longitude.degrees / 15.0
    
    //Step3:
    var lstDecimal = gstDecimal + adjustment
        
    if lstDecimal < 0 {
        
        lstDecimal += 24
    }else if lstDecimal >= 24 {
        
        lstDecimal -= 24
    }
        
    let lstHMS = HMS.init(decimal: lstDecimal)
    
    return lstHMS
}


/// Converts the number of seconds in HH:MM:ss
/// - Parameter seconds: Number of seconds that have to be converted
/// - Returns: From value in input the equivalent in (hours,minute,seconds)
public func secondsToHoursMinutesSeconds(_ seconds : Int) -> (Int,Int,Int) {

    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}
