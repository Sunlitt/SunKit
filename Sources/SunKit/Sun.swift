//
//  Sun.swift
//  litt
//
//  Created by Davide Biancardi on 27/05/22.
//

import CoreLocation
import SwiftUI

public class Sun {
    private let calendar: Calendar = Calendar(identifier: .gregorian)
    private let dateFormatter: DateFormatter = DateFormatter()
    
    public private(set) var location: CLLocation
    public private(set) var timeZone: Double
    public private(set) var date: Date = Date()
    public private(set) var azimuth: Double = .zero
    public private(set) var sunrise: Date = Date()
    public private(set) var solarNoon: Date = Date()
    public private(set) var sunset: Date = Date()
    public private(set) var goldenHourStart: Date = Date()
    public private(set) var goldenHourEnd: Date = Date()
    public private(set) var sunriseAzimuth: Double = 0
    public private(set) var sunsetAzimuth: Double = 0
    
    public static let common: Sun = {
        return Sun(location: CLLocation(latitude: 37.334886, longitude: -122.008988), timeZone: -7)
    }()
    
    public var isNight: Bool {
        if !isCircumPolar {
            return date < sunrise || date > sunset
        } else {
            return isAlwaysNight
        }
    }
    
    public var isSunrise: Bool {
        date == sunrise
    }
    
    public var isSunset: Bool {
        date == sunset
    }
    
    public var isGoldenHour: Bool {
        date.timeIntervalSince(goldenHourStart) >= 0 && goldenHourEnd.timeIntervalSince(date) >= 0
    }
    
    public var isCircumPolar: Bool {
        isAlwaysLight || isAlwaysNight
    }
    
    public var isAlwaysLight: Bool {
        let twentyThreeHoursAndFiftyNineMinutes: Double = 86399  //23:59
        let startOfTheDay = calendar.startOfDay(for: date)
        let almostNextDay = startOfTheDay + twentyThreeHoursAndFiftyNineMinutes
        
        return sunset == almostNextDay || sunrise < startOfTheDay + 600
    }
    
    public var isAlwaysNight: Bool {
        let twoHoursInSeconds: Double = 7200
        
        return sunset - twoHoursInSeconds < sunrise
    }
    
    public func getAzimuthFrom(date: Date) throws -> Double {
        guard let localSolarDate = calendar.date(byAdding: .second, value: Int(timeCorrectionFactorInSeconds), to: date) else {
            throw SunError.unableToGenerateLocalSolarDate(from: date, byAdding: timeCorrectionFactorInSeconds)
        }
        
        dateFormatter.dateFormat = "mm"
        guard var localSolarTimeMinute = Double(dateFormatter.string(from: localSolarDate)) else {
            throw SunError.unableToGenerateLocalSolarTimeMinute(from: date)
        }
        localSolarTimeMinute = localSolarTimeMinute / 100
        
        let localSolarTimeHour = Double(calendar.component(.hour, from: localSolarDate))
        
        localSolarTimeMinute *= 0.5084745763 / 0.299
        
        let lst =  localSolarTimeHour + localSolarTimeMinute
        let hra: Angle = .degrees(15 * (lst - 12))
        let declinationRad = declination.radians
        let latitude: Angle = .degrees(location.coordinate.latitude)
        let latitudeRad = latitude.radians
        var elevationArg = sin(declinationRad) * sin(latitudeRad) + cos(declinationRad) * cos(latitudeRad) * cos(hra.radians)
        elevationArg = checkDomainForArcSinCosineFunction(argument: elevationArg)
        let elevationInRadians: Double = asin(elevationArg)
        let elevation: Angle = .radians(elevationInRadians)
        let hourAngleRad = hra.radians
        let elevationRad = elevation.radians
        var azimuthArg = (sin(declinationRad) * cos(latitudeRad) - cos(declinationRad) * sin(latitudeRad) * cos(hourAngleRad)) / cos(elevationRad)
        azimuthArg = checkDomainForArcSinCosineFunction(argument: azimuthArg)
        let azimuthRad: Double = acos(azimuthArg)
        
        guard !azimuthRad.isInfinite else {
            throw SunError.azimuthIsInfinite
        }
        
        let azimuthAngle: Angle = .radians(azimuthRad)
        var azimuth = azimuthAngle.degrees
        
        if lst > 12 {
            azimuth = 360 - azimuth
        }
        
        return azimuth
    }
    
    //Variables To Compute Azimuth
    
    public var elevation: Angle {
        let declinationRad = declination.radians
        let hourAngleRad = hourAngle.radians
        let latitude: Angle = .degrees(location.coordinate.latitude)
        let latitudeRad = latitude.radians
        var elevationArg = sin(declinationRad) * sin(latitudeRad) + cos(declinationRad) * cos(latitudeRad) * cos(hourAngleRad)
        elevationArg = checkDomainForArcSinCosineFunction(argument: elevationArg)
        let elevationInRadians: Double = asin(elevationArg)
        
        return .radians(elevationInRadians)
    }
    
    private var hourAngle: Angle {
        let angleInDegrees: Double = (localSolarTime - 12.0) * 15
        
        return .degrees(angleInDegrees)
    }
    
    private var b: Angle {
        let angleInDegrees: Double = (360 / 365 * Double(daysPassedFromStartOfYear - 81))
        
        return .degrees(angleInDegrees)
    }
    
    private var localStandardTimeMeridian: Double {
        return timeZone * 15
    }
    
    private var equationOfTime: Double {
        let bRad = b.radians
        
        return 9.87 * sin(2 * bRad) - 7.53 * cos(bRad) - 1.5 * sin(bRad)
    }
    
    private var declination: Angle {
        let bRad = b.radians
        let declinationInDegree: Double = 23.45 * sin(bRad)
        
        return .degrees(declinationInDegree)
    }
    
    private var localSolarTime: Double = 0
    private var daysPassedFromStartOfYear: Int = 0
    
    private var timeCorrectionFactorInSeconds: Double {
        let timeCorrectionFactor = 4 * (location.coordinate.longitude - localStandardTimeMeridian) + equationOfTime
        let minutes: Double = Double(Int(timeCorrectionFactor) * 60)
        let seconds: Double = timeCorrectionFactor.truncatingRemainder(dividingBy: 1) * 100
        let timeCorrectionFactorInSeconds =  minutes + seconds
        
        return timeCorrectionFactorInSeconds
    }
    
    public init(location: CLLocation,timeZone: Double) {
        self.timeZone = timeZone
        self.location = location
        self.daysPassedFromStartOfYear = (try? getDaysPassedFromStartOfTheYear()) ?? 0
        self.localSolarTime = (try? getLocalSolarTime()) ?? 0
        self.azimuth = (try? getAzimuth()) ?? 0
        self.sunrise = (try? getSunrise()) ?? Date()
        self.sunset = (try? getSunset()) ?? Date()
        self.goldenHourStart = (try? getGoldenHourStart()) ?? Date()
        self.goldenHourEnd = (try? getGoldenHourFinish()) ?? Date()
        self.solarNoon = (try? getSolarNoon()) ?? Date()
        self.sunriseAzimuth = (try? getAzimuthFrom(date:sunrise)) ?? 0
        self.sunsetAzimuth = (try? getAzimuthFrom(date:sunset)) ?? 0
        self.dateFormatter.calendar = Calendar(identifier: .gregorian)
    }
    
    private func checkDomainForArcSinCosineFunction(argument: Double) -> Double {
        let inDomainValue: Double
        
        if argument > 1 {
            inDomainValue = 1.0
        } else if argument < -1 {
            inDomainValue = -1.0
        } else {
            inDomainValue = argument
        }
        
        return inDomainValue
    }
    
    private func generateVariables() throws {
        do {
            try daysPassedFromStartOfYear = getDaysPassedFromStartOfTheYear()
        } catch SunError.unableToGenerateDaysPassedFromStartOfTheYear(let dateOne, let dateTwo) {
            let errorOccurred: SunError = .unableToGenerateDaysPassedFromStartOfTheYear(from: dateOne, to: dateTwo)
            throw SunError.readableError(description: errorOccurred.description())
        } catch SunError.unableToGenerateStartOfTheYear(let dateOne) {
            let errorOccurred: SunError = .unableToGenerateStartOfTheYear(from: dateOne)
            throw SunError.readableError(description: errorOccurred.description())
        } catch {
            throw SunError.readableError(description: error.localizedDescription)
        }
        
        do {
            try localSolarTime = getLocalSolarTime()
        } catch SunError.unableToGenerateLocalSolarDate(let dateOne,  let numberOfseconds) {
            let errorOccurred: SunError = .unableToGenerateLocalSolarDate(from: dateOne, byAdding: numberOfseconds)
            throw SunError.readableError(description: errorOccurred.description())
        } catch SunError.unableToGenerateLocalSolarTimeMinute(let date) {
            let errorOccurred: SunError = .unableToGenerateLocalSolarTimeMinute(from: date)
            throw SunError.readableError(description: errorOccurred.description())
        } catch {
            throw SunError.readableError(description: error.localizedDescription)
        }
        
        do {
            try azimuth = getAzimuth()
        } catch SunError.azimuthIsInfinite {
            let errorOccurred: SunError = .azimuthIsInfinite
            throw SunError.readableError(description: errorOccurred.description())
        } catch {
            throw SunError.readableError(description: error.localizedDescription)
        }
        
        do {
            try sunrise = getSunrise()
        } catch SunError.unableToGenerateSunriseDate(let date) {
            let errorOccurred: SunError = .unableToGenerateSunriseDate(from: date)
            throw SunError.readableError(description: errorOccurred.description())
        } catch {
            throw SunError.readableError(description: error.localizedDescription)
        }
        
        do {
            try sunset = getSunset()
        } catch SunError.unableToGenerateSunsetDate(let date) {
            let errorOccurred: SunError = .unableToGenerateSunsetDate(from: date)
            throw SunError.readableError(description: errorOccurred.description())
        } catch {
            throw SunError.readableError(description: error.localizedDescription)
        }
        
        do {
            try goldenHourStart = getGoldenHourStart()
        } catch SunError.unableToGenerateGoldenHourStart(let date) {
            let errorOccurred: SunError = .unableToGenerateGoldenHourStart(from: date)
            throw SunError.readableError(description: errorOccurred.description())
        } catch {
            throw SunError.readableError(description: error.localizedDescription)
        }
        
        do {
            try goldenHourEnd = getGoldenHourFinish()
        } catch SunError.unableToGenerateGoldenHourFinish(let date) {
            let errorOccurred: SunError = .unableToGenerateGoldenHourFinish(from: date)
            throw SunError.readableError(description: errorOccurred.description())
        } catch {
            throw SunError.readableError(description: error.localizedDescription)
        }
        
        do {
            try solarNoon = getSolarNoon()
        } catch SunError.unableToGenerateSolarNoon(let date) {
            let errorOccurred: SunError = .unableToGenerateSolarNoon(from: date)
            throw SunError.readableError(description: errorOccurred.description())
        } catch {
            throw SunError.readableError(description: error.localizedDescription)
        }
        
        do {
            try sunriseAzimuth = getAzimuthFrom(date: sunrise)
            try sunsetAzimuth = getAzimuthFrom(date: sunset)
        } catch SunError.unableToGenerateLocalSolarDate(let dateOne,  let numberOfseconds) {
            let errorOccurred: SunError = .unableToGenerateLocalSolarDate(from: dateOne, byAdding: numberOfseconds)
            throw SunError.readableError(description: errorOccurred.description())
        } catch SunError.unableToGenerateLocalSolarTimeMinute(let date) {
            let errorOccurred: SunError = .unableToGenerateLocalSolarTimeMinute(from: date)
            throw SunError.readableError(description: errorOccurred.description())
        } catch SunError.azimuthIsInfinite {
            let errorOccurred: SunError = .azimuthIsInfinite
            throw SunError.readableError(description: errorOccurred.description())
        } catch {
            throw SunError.readableError(description: error.localizedDescription)
        }
    }
    
    private func getDaysPassedFromStartOfTheYear() throws -> Int {
        let year =  calendar.component(.year, from: date)
        
        dateFormatter.dateFormat = "yyyy/mm/dd"
        dateFormatter.calendar = calendar
        guard let dataFormatted = dateFormatter.date(from: "\(year)/01/01") else {
            throw SunError.unableToGenerateStartOfTheYear(from: date)
        }
        
        let startOfYear = calendar.startOfDay(for: dataFormatted)
        let startOfDay = calendar.startOfDay(for: date)
        
        guard var daysPassedFromStartOfTheYear = calendar.dateComponents([.day], from: startOfYear, to: startOfDay).day else {
            throw SunError.unableToGenerateDaysPassedFromStartOfTheYear(from: startOfYear, to: startOfDay)
        }
        
        daysPassedFromStartOfTheYear = daysPassedFromStartOfTheYear + 1
        
        return daysPassedFromStartOfTheYear
    }
    
    private func getLocalSolarTime() throws -> Double {
        guard let localSolarDate = calendar.date(byAdding: .second, value: Int(timeCorrectionFactorInSeconds), to: date) else {
            throw SunError.unableToGenerateLocalSolarDate(from: date, byAdding: timeCorrectionFactorInSeconds)
        }
        
        dateFormatter.dateFormat = "mm"
        guard var localSolarTimeMinute = Double(dateFormatter.string(from: localSolarDate)) else {
            throw SunError.unableToGenerateLocalSolarTimeMinute(from: localSolarDate)
        }
        localSolarTimeMinute = localSolarTimeMinute / 100
        
        let localSolarTimeHour = Double(calendar.component(.hour, from: localSolarDate))
        
        localSolarTimeMinute *= 0.5084745763 / 0.299
        
        return localSolarTimeHour + localSolarTimeMinute
    }
    
    private func getElevation() -> Angle {
        let declinationRad = declination.radians
        let hourAngleRad = hourAngle.radians
        let latitude: Angle = .degrees(location.coordinate.latitude)
        let latitudeRad = latitude.radians
        var elevationArg = sin(declinationRad) * sin(latitudeRad) + cos(declinationRad) * cos(latitudeRad) * cos(hourAngleRad)
        elevationArg = checkDomainForArcSinCosineFunction(argument: elevationArg)
        let elevationInRadians: Double = asin(elevationArg)
        
        return .radians(elevationInRadians)
    }
    
    private func getAzimuth() throws -> Double {
        let hourAngleRad = hourAngle.radians
        let declinationRad = declination.radians
        let latitude: Angle = .degrees(location.coordinate.latitude)
        let latitudeRad = latitude.radians
        let elevationRad = elevation.radians
        var azimuthArg = (sin(declinationRad) * cos(latitudeRad) - cos(declinationRad) * sin(latitudeRad) * cos(hourAngleRad)) / cos(elevationRad)
        azimuthArg = checkDomainForArcSinCosineFunction(argument: azimuthArg)
        let azimuthRad: Double = acos(azimuthArg)
        
        guard !azimuthRad.isInfinite else {
            throw SunError.azimuthIsInfinite
        }
        
        let azimuthAngle: Angle = .radians(azimuthRad)
        var azimuth = azimuthAngle.degrees
        
        if localSolarTime > 12 {
            azimuth = 360 - azimuth
        }
        
        return azimuth
    }
    
    public func setDate(_ newDate: Date) throws {
        date = newDate
        
        try generateVariables()
    }
    
    public func setLocation(_ newLocation: CLLocation) throws {
        location = newLocation
        
        try generateVariables()
    }
    
    public func setTimeZone(_ newTimeZone: Double) throws {
        timeZone = newTimeZone
        
        try generateVariables()
    }
    
    private func getSunrise() throws -> Date {
        let latitude: Angle = .degrees(location.coordinate.latitude)
        let latitudeRad = latitude.radians
        let declinationRad = declination.radians
        var haArg = (cos(Angle.degrees(90.833).radians)) / (cos(latitudeRad) * cos(declinationRad)) - tan(latitudeRad) * tan(declinationRad)
        haArg = checkDomainForArcSinCosineFunction(argument: haArg)
        let ha: Angle = .radians(acos(haArg))
        let sunriseUTCMinutes = 720 - 4 * (location.coordinate.longitude + ha.degrees) - equationOfTime
        let sunriseSeconds = (sunriseUTCMinutes + timeZone * 60 ) * 60
        let startOfDay = calendar.startOfDay(for: date)
        guard var sunriseDate = calendar.date(byAdding: .second, value: Int(sunriseSeconds), to: startOfDay) else {
            throw SunError.unableToGenerateSunriseDate(from: date)
        }
        
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(sunriseSeconds))
        
        sunriseDate = calendar.date(bySettingHour: hoursMinutesSeconds.0, minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: sunriseDate) ?? startOfDay
        
        return sunriseDate
    }
    
    private func secondsToHoursMinutesSeconds(_ seconds : Int) -> (Int,Int,Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func getSunset() throws -> Date {
        let secondsInOneDay: Double = 86399
        let latitude: Angle = .degrees(location.coordinate.latitude)
        let latitudeRad = latitude.radians
        let declinationRad = declination.radians
        var haArg = (cos(Angle.degrees(90.833).radians)) / (cos(latitudeRad) * cos(declinationRad)) - tan(latitudeRad) * tan(declinationRad)
        haArg = checkDomainForArcSinCosineFunction(argument: haArg)
        let ha: Angle = .radians(-acos(haArg))
        let sunsetUTCMinutes = 720 - 4 * (location.coordinate.longitude + ha.degrees) - equationOfTime
        var sunsetSeconds = (sunsetUTCMinutes + timeZone * 60 ) * 60
        let startOfDay = calendar.startOfDay(for: date)
        
        if sunsetSeconds > secondsInOneDay {
            sunsetSeconds = 86399
        }
        
        guard var sunsetDate = calendar.date(byAdding: .second, value: Int(sunsetSeconds), to: startOfDay) else {
            throw SunError.unableToGenerateSunsetDate(from: date)
        }
        
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(sunsetSeconds))
        
        sunsetDate = calendar.date(bySettingHour: hoursMinutesSeconds.0 , minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: sunsetDate) ?? Date()
        
        return sunsetDate
    }
    
    private func getDateFrom(elevation : Angle) -> Date? {
        let secondsInOneDay: Double = 86399
        let elevationRad = elevation.radians
        let latitude: Angle = .degrees(location.coordinate.latitude)
        let latitudeRad = latitude.radians
        let declinationRad = declination.radians
        var cosHra = (sin(elevationRad) - sin(declinationRad) * sin(latitudeRad)) / (cos(declinationRad) * cos(latitudeRad))
        cosHra = checkDomainForArcSinCosineFunction(argument: cosHra)
        let hraAngle: Angle = .radians(acos(cosHra))
        var secondsForSunToReachElevation = (hraAngle.degrees / 15) * 3600  + 43200 - timeCorrectionFactorInSeconds
        let startOfTheDay = calendar.startOfDay(for: date)
        
        if secondsForSunToReachElevation > secondsInOneDay {
            secondsForSunToReachElevation = 86399
        }
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(secondsForSunToReachElevation))
        
        var newDate = calendar.date(byAdding: .second, value: Int(secondsForSunToReachElevation), to: startOfTheDay)
        
        newDate = calendar.date(bySettingHour: hoursMinutesSeconds.0 , minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: newDate ?? Date())
        
        return newDate
    }
    
    private func getGoldenHourStart() throws -> Date {
        let elevationSunGoldenHourStart: Angle = .degrees(6.0)
        guard let goldenHourStart = getDateFrom(elevation: elevationSunGoldenHourStart) else {
            throw SunError.unableToGenerateGoldenHourStart(from: date)
        }
        
        return goldenHourStart
    }
    
    private func getGoldenHourFinish() throws -> Date {
        let elevationSunGoldenHourFinish: Angle = .degrees(-4.0)
        guard let goldenHourFinish = getDateFrom(elevation: elevationSunGoldenHourFinish) else {
            throw SunError.unableToGenerateGoldenHourFinish(from: date)
        }
        
        return goldenHourFinish
    }
    
    private func getSolarNoon() throws -> Date {
        let secondsForUTCSolarNoon = (720 - 4 * location.coordinate.longitude - equationOfTime) * 60
        let secondsForSolarNoon = secondsForUTCSolarNoon + 3600 * timeZone
        let startOfTheDay = calendar.startOfDay(for: date)
        guard var solarNoon = calendar.date(byAdding: .second, value: Int(secondsForSolarNoon), to: startOfTheDay) else {
            throw SunError.unableToGenerateSolarNoon(from: date)
        }
        
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(secondsForSolarNoon))
        
        solarNoon = calendar.date(bySettingHour: hoursMinutesSeconds.0 , minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: solarNoon) ?? Date()
        
        return solarNoon
    }
}
