//
//  Utils.swift
//  
//
//  Created by Davide Biancardi on 05/11/22.
//

import Foundation

let SECONDS_IN_ONE_DAY = 86399
let TWELVE_HOUR_IN_SECONDS: Double = 43200
let TWO_HOURS_IN_SECONDS: Double = 7200
let SECONDS_IN_TEN_MINUTES: Double = 600

/// This function returns a % n also if a is negative. The standard % function provided by swift doesn't do that
/// - Parameters:
///   - a: first operand
///   - n: second operand
/// - Returns: a % n if a is positive. If a isn't positive, it will add to the result of the modulo operation the value of the n operand.Please note that this function only works when both operands are integers. 
public func mod(_ a: Int, _ n: Int) -> Int {
    let r = a % n
    return r >= 0 ? r : r + n
}


public func clamp(lower: Double, upper: Double, number: Double) -> Double {
    
    return min(upper,max(lower,number))
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

/// It converts decimal to a date type with timezone used on your current device
/// - Parameters:
///   - decimal: Hour expressed in decimal format
///   - day: day of the date that will we created
///   - month: month of the date that will we created
///   - year: year of the date that will be created
/// - Returns: Date
public func decimal2Date(_ decimal: Double,day: Int,month: Int,year: Int) -> Date {
    
    var calendar: Calendar = .init(identifier: .gregorian)
    calendar.timeZone = .current
    let hms = HMS.init(decimal: decimal)
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = Int(hms.hours)
    dateComponents.minute = Int(hms.minutes)
    dateComponents.second = Int(hms.seconds)
    
    return calendar.date(from: dateComponents) ?? Date()

}

/// It converts local civil time to UT time.
/// Converting between LCT and UT is independent of the date because it is merely a matter of making a time zone adjustment.
///
/// - Parameter lct: Local civil time date
/// - Parameter timeZoneInSeconds: time zone expressed in seconds of your local civil time
/// - Returns: UT equivalent for the LCT given in input. TimeZone will remain the same:  set to the one used on your current device.
public func lCT2UT(_ lct: Date, timeZoneInSeconds: Int) -> Date{
    
    var calendar: Calendar = .init(identifier: .gregorian)
    calendar.timeZone = .current
    
    var lctDecimal = HMS.init(from: lct).hMS2Decimal()
    
    lctDecimal = lctDecimal - Double(timeZoneInSeconds) / 3600
   
    var day = calendar.component(.day,from: lct)
    if lctDecimal < 0 {
        
        lctDecimal += 24
        day = calendar.component(.day,from: lct) - 1
        
    }else if lctDecimal >= 24 {
        
        lctDecimal -= 24
        day = calendar.component(.day,from: lct) + 1
    }
    
    let lctHMS = HMS.init(decimal: lctDecimal)
    let year = calendar.component(.year, from: lct)
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = calendar.component(.month, from: lct)
    dateComponents.day = day
    dateComponents.hour = Int(lctHMS.hours)
    dateComponents.minute = Int(lctHMS.minutes)
    dateComponents.second = Int(lctHMS.seconds)
    
    return calendar.date(from: dateComponents) ?? Date()
}

/// It converts UT time to LCT
///
/// - Parameter lct: Local civil time date
/// - Parameter timeZoneInSeconds: time zone expressed in seconds of your local civil time
/// - Returns: LCT equivalent for the UT given in input. TimeZone will remain the same:  set to the one used on your current device.
public func UT2LCT(_ ut: Date,timeZoneInSeconds: Int) -> Date{
    
    var calendar: Calendar = .init(identifier: .gregorian)
    calendar.timeZone = .current
    
    var utDecimal = HMS.init(from: ut).hMS2Decimal()
    
    utDecimal = utDecimal + Double(timeZoneInSeconds) / 3600.0
    
    var day = calendar.component(.day,from: ut)
    if utDecimal < 0 {
        
        utDecimal += 24
        day = calendar.component(.day,from: ut) - 1
        
    }else if utDecimal >= 24 {
        
        utDecimal -= 24
        day = calendar.component(.day,from: ut) + 1
    }
    
    let utHMS = HMS.init(decimal: utDecimal)
    let year = calendar.component(.year, from: ut)
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = calendar.component(.month, from: ut)
    dateComponents.day = day
    dateComponents.hour = Int(utHMS.hours)
    dateComponents.minute = Int(utHMS.minutes)
    dateComponents.second = Int(utHMS.seconds)
    
    return calendar.date(from: dateComponents) ?? Date()
    
}

/// Converts UT time to Greenwich Sidereal Time
/// Timezone will remain the same: set to the one used on your current device.
/// - Parameter ut: UT time to convert in GST
/// - Returns: GST equivalent of the UT given in input
public func uT2GST(_ ut:Date) -> Date{
    
    var calendarUTC: Calendar = .init(identifier: .gregorian)
    calendarUTC.timeZone = .init(secondsFromGMT: 0)!
    
    var calendar: Calendar = .init(identifier: .gregorian)
    calendar.timeZone = .current
    
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
    
    //Step10:
    var day = calendar.component(.day,from: ut)
    if gstDecimal < 0 {
        
        gstDecimal += 24
        day = calendar.component(.day,from: ut) - 1
        
    }else if gstDecimal >= 24 {
        
        gstDecimal -= 24
        day = calendar.component(.day,from: ut) + 1
    }
    
    let gstHMS = HMS.init(decimal: gstDecimal)
    
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = calendar.component(.month, from: ut)
    dateComponents.day = day
    dateComponents.hour = Int(gstHMS.hours)
    dateComponents.minute = Int(gstHMS.minutes)
    dateComponents.second = Int(gstHMS.seconds)
    
    return calendar.date(from: dateComponents) ?? Date()
}

/// Converts UT time to Greenwich Sidereal Time
/// Timezone will remain the same: set to the one used on your current device.
/// - Parameter gst: GST time to convert in UT
/// - Returns: UT equivalent of the GST given in input
public func gST2UT(_ gst:Date) -> Date{
    
    var calendarUTC: Calendar = .init(identifier: .gregorian)
    calendarUTC.timeZone = .init(secondsFromGMT: 0)!
    
    var calendar: Calendar = .init(identifier: .gregorian)
    calendar.timeZone = .current
    
    //Step1:
    let jd = jdFromDate(date: calendarUTC.startOfDay(for: gst))

    //Step2:
    let year = calendarUTC.component(.year, from: gst)
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
    var TZero = 0.0657098 * days - B
    
    //Step8:
    if TZero < 0 {
        TZero += 24
    }else if TZero >= 24{
        TZero -= 24
    }
    //Step9:
    let gstDecimal = HMS.init(from: gst).hMS2Decimal()
    
    //Step10:
    var a = gstDecimal - TZero
    
    //Step11:
    if a < 0 {
        
        a += 24
    }
    
    //Step12
    let utDecimal = 0.997270 * a
    
    //Step13
    let utHMS = HMS.init(decimal: utDecimal)
    let day = calendar.component(.day,from: gst)
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = calendarUTC.component(.month, from: gst)
    dateComponents.day = day
    dateComponents.hour = Int(utHMS.hours)
    dateComponents.minute = Int(utHMS.minutes)
    dateComponents.second = Int(utHMS.seconds)
    
    return calendar.date(from: dateComponents) ?? Date()
    
}


/// Converts GST to Local Sidereal Time
/// - Parameters:
///   - gst: GST time to convert in LST
///   - longitude: longitude of the observer
/// - Returns: LST equivalent for the GST given in input
public func gST2LST(_ gst: Date, longitude: Angle) -> Date{
    
    var calendar: Calendar = .init(identifier: .gregorian)
    calendar.timeZone = .current
    
    //Step1:
    let gstDecimal = HMS.init(from: gst).hMS2Decimal()
    
    //Step2:
    let adjustment:Double = longitude.degrees / 15.0
    
    //Step3:
    var lstDecimal = gstDecimal + adjustment
        
    var day = calendar.component(.day,from: gst)
    if lstDecimal < 0 {
        
        lstDecimal += 24
        day = calendar.component(.day,from: gst) - 1
        
    }else if gstDecimal >= 24 {
        
        lstDecimal -= 24
        day = calendar.component(.day,from: gst) + 1
    }
    
    let lstHMS = HMS.init(decimal: lstDecimal)
    let year = calendar.component(.year, from: gst)
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = calendar.component(.month, from: gst)
    dateComponents.day = day
    dateComponents.hour = Int(lstHMS.hours)
    dateComponents.minute = Int(lstHMS.minutes)
    dateComponents.second = Int(lstHMS.seconds)
    
    return calendar.date(from: dateComponents) ?? Date()
    
}

/// Converts LST to Greenwich Sidereal Time
/// - Parameters:
///   - gst: LST time to convert in GST
///   - longitude: longitude of the observer
/// - Returns: GST equivalent for the LST given in input
public func lST2GST(_ lst: Date, longitude: Angle) -> Date{
    
    var calendar: Calendar = .init(identifier: .gregorian)
    calendar.timeZone = .current
    
    //Step1:
    let lstDecimal = HMS.init(from: lst).hMS2Decimal()
    
    //Step2:
    let adjustment:Double = longitude.degrees / 15.0
    
    //Step3:
    var gstDecimal = lstDecimal - adjustment
    
    //Step4:
    var day = calendar.component(.day,from: lst)
    if gstDecimal < 0 {
        day = day + 1
        gstDecimal += 24
    } else if gstDecimal >= 24{
        day = day - 1
        gstDecimal -= 24
    }
    
    let gstHMS = HMS.init(decimal: gstDecimal)
    
    let year = calendar.component(.year, from: lst)
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = calendar.component(.month, from: lst)
    dateComponents.day = day
    dateComponents.hour = Int(gstHMS.hours)
    dateComponents.minute = Int(gstHMS.minutes)
    dateComponents.second = Int(gstHMS.seconds)
    
    
    return calendar.date(from: dateComponents) ?? Date()
    
}

/// Converts the number of seconds in HH:MM:ss
/// - Parameter seconds: Number of seconds that have to be converted
/// - Returns: From value in input the equivalent in (hours,minute,seconds)
public func secondsToHoursMinutesSeconds(_ seconds : Int) -> (Int,Int,Int) {

    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}
