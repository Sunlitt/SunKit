//
//  Sun.swift
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
import CoreLocation

public class Sun {
    /*--------------------------------------------------------------------
     Public get Variables
     *-------------------------------------------------------------------*/
    
    public private(set) var location: CLLocation
    public private(set) var timeZone: TimeZone
    public private(set) var useSameTimeZone: Bool
    public private(set) var date: Date = Date()
    
    ///Date of Sunrise
    public private(set) var sunrise: Date = Date()
    ///Date of Sunset
    public private(set) var sunset: Date = Date()
    ///Date of Solar Noon  for
    public private(set) var solarNoon: Date = Date()
    ///Date at which evening  Golden hour starts for instance timezone
    public private(set) var goldenHourStart: Date = Date()
    ///Date at which evening  Golden hour ends
    public private(set) var goldenHourEnd: Date = Date()
    ///Date at which there is the first light
    public private(set) var firstLight: Date = Date()
    ///Date at which there is the last light
    public private(set) var lastLight: Date = Date()
    ///Azimuth of Sunrise
    public private(set) var sunriseAzimuth: Double = 0
    ///Azimuth of Sunset
    public private(set) var sunsetAzimuth: Double = 0
    ///Azimuth of Solar noon
    public private(set) var solarNoonAzimuth: Double = 0

    ///Date at which  there will be march equinox
    public private(set) var marchEquinox: Date = Date()
    ///Date at which  there will be june solstice
    public private(set) var juneSolstice: Date = Date()
    ///Date at which  there will be september solstice
    public private(set) var septemberEquinox: Date = Date()
    ///Date at which  there will be december solstice
    public private(set) var decemberSolstice: Date = Date()
    
    
    public static let common: Sun = {
        return Sun(location: CLLocation(latitude: 37.334886, longitude: -122.008988), timeZone: -7, useSameTimeZone: true)
    }()
    
    public var azimuth: Angle {
        return self.sunHorizonCoordinates.azimuth
    }
    
    public var altitude: Angle {
        return self.sunHorizonCoordinates.altitude
    }
    
    public var longitude: Angle {
        return .init(degrees: self.location.coordinate.longitude)
    }
    
    public var latitude: Angle {
        return .init(degrees: self.location.coordinate.latitude)
    }
    
    public var totalDayLightTime: Int {
        let diffComponents = calendar.dateComponents([.second], from: sunrise, to: sunset)
        
        return diffComponents.second ?? 0
    }
    
    public var totalNightTime: Int {
        let startOfTheDay = calendar.startOfDay(for: date)
        let endOfTheDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfTheDay)!
        var diffComponents = calendar.dateComponents([.second], from: startOfTheDay, to: sunrise)
        var nightHours: Int = diffComponents.second ?? 0
        diffComponents = calendar.dateComponents([.second], from: sunset, to: endOfTheDay)
        nightHours = nightHours + (diffComponents.second ?? 0)
        
        return nightHours
    }
    
    public var isNight: Bool {
        if !isCircumPolar {
            return date < firstLight || date > lastLight
        } else {
            return isAlwaysNight
        }
    }
    
    public var isSunrise: Bool {
        date >= firstLight && date <= sunrise
    }
    
    public var isSunset: Bool {
        date >= sunset && date <= lastLight
    }
    
    public var isGoldenHour: Bool {
        date.timeIntervalSince(goldenHourStart) >= 0 && goldenHourEnd.timeIntervalSince(date) >= 0
    }
    
    public var isCircumPolar: Bool {
        isAlwaysLight || isAlwaysNight
    }
    
    public var isAlwaysLight: Bool {
        let startOfTheDay = calendar.startOfDay(for: date)
        let almostNextDay = startOfTheDay + Double(SECONDS_IN_ONE_DAY)
        
        return sunset == almostNextDay || sunrise < startOfTheDay + SECONDS_IN_TEN_MINUTES
    }
    
    public var isAlwaysNight: Bool {
        return sunset - TWO_HOURS_IN_SECONDS < sunrise
    }
    
    /*--------------------------------------------------------------------
     Public methods
     *-------------------------------------------------------------------*/
    
    public init(location: CLLocation,timeZone: Double,useSameTimeZone: Bool = false) {
        let timeZoneSeconds: Int = Int(timeZone * SECONDS_IN_ONE_HOUR)
        self.timeZone = TimeZone.init(secondsFromGMT: timeZoneSeconds) ?? .current
        self.location = location
        self.useSameTimeZone = useSameTimeZone
        refresh()
    }
    
    public init(location: CLLocation,timeZone: TimeZone,useSameTimeZone: Bool = false) {
        self.timeZone = timeZone
        self.location = location
        self.useSameTimeZone = useSameTimeZone
        refresh()
    }
    
    public func setDate(_ newDate: Date) {
        date = newDate
        refresh()
    }
    
    public func setLocation(_ newLocation: CLLocation) {
        location = newLocation
        refresh()
    }
    
    public func setLocation(_ newLocation: CLLocation,_ newTimeZone: Double) {
        let timeZoneSeconds: Int = Int(newTimeZone * SECONDS_IN_ONE_HOUR)
        timeZone = TimeZone(secondsFromGMT: timeZoneSeconds) ?? .current
        location = newLocation
        changeCurrentDate()
        refresh()
    }
    
    public func setLocation(_ newLocation: CLLocation,_ newTimeZone: TimeZone) {
        timeZone = newTimeZone
        location = newLocation
        changeCurrentDate()
        refresh()
    }
    
    public func setTimeZone(_ newTimeZone: Double) {
        let timeZoneSeconds: Int = Int(newTimeZone * SECONDS_IN_ONE_HOUR)
        timeZone = TimeZone(secondsFromGMT: timeZoneSeconds) ?? .current
        changeCurrentDate()
        refresh()
    }
    
    public func setTimeZone(_ newTimeZone: TimeZone) {
        timeZone = newTimeZone
        changeCurrentDate()
        refresh()
    }
    
    /// Usefull function for debug
    public func dumpDateInfos(){
        
        print("Current Date -> \(dateFormatter.string(from: date))")
        print("Sunrise -> \(dateFormatter.string(from: sunrise))")
        print("Sunset -> \(dateFormatter.string(from: sunset))")
        print("Solar Noon -> \(dateFormatter.string(from: solarNoon))")
        print("Golden Hour Start -> \(dateFormatter.string(from: goldenHourStart))")
        print("Golden Hour End -> \(dateFormatter.string(from: goldenHourEnd))")
        print("First Light -> \(dateFormatter.string(from: firstLight))")
        print("Last Light -> \(dateFormatter.string(from: lastLight))")
        print("March Equinox -> \(dateFormatter.string(from: marchEquinox))")
        print("June Solstice -> \(dateFormatter.string(from: juneSolstice))")
        print("September Equinox -> \(dateFormatter.string(from: septemberEquinox))")
        print("December Solstice -> \(dateFormatter.string(from: decemberSolstice))")
    
    }
    
    ///  Computes the time at which the sun will reach the elevation given in input for self.date
    /// - Parameters:
    ///   - elevation: Elevation
    ///   - morning: Sun reaches a specific elevation twice, this boolean variable is needed to find out which one need to be considered. The one reached in the morning or not.
    /// - Returns: Time at which the Sun reaches that elevation. Nil if it didn't find it.
    public func getDateFrom(elevation : Angle, morning: Bool = false) -> Date? {
        var cosHra = (sin(elevation.radians) - sin(sunEquatorialCoordinates.declination.radians) * sin(latitude.radians)) / (cos(sunEquatorialCoordinates.declination.radians) * cos(latitude.radians))
        cosHra = clamp(lower: -1, upper: 1, number: cosHra)
        let hraAngle: Angle = .radians(acos(cosHra))
        var secondsForSunToReachElevation = (morning ? -1 : 1) * (hraAngle.degrees / 15) * SECONDS_IN_ONE_HOUR  + TWELVE_HOUR_IN_SECONDS - timeCorrectionFactorInSeconds
        let startOfTheDay = calendar.startOfDay(for: date)
        
        if (Int(secondsForSunToReachElevation) > SECONDS_IN_ONE_DAY){
            
            secondsForSunToReachElevation = Double(SECONDS_IN_ONE_DAY)
        }
        else if (secondsForSunToReachElevation < 0){
            
            secondsForSunToReachElevation = 0
        }
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(secondsForSunToReachElevation))
        
        let newDate = calendar.date(bySettingHour: hoursMinutesSeconds.0 , minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: startOfTheDay)
        
        return newDate
    }
    
    /*--------------------------------------------------------------------
     Private Variables
     *-------------------------------------------------------------------*/
    
    private var calendar: Calendar {
        var calendar: Calendar = .init(identifier: .gregorian)
        calendar.timeZone =  useSameTimeZone ?  .current : self.timeZone
        
        return calendar
    }
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: timeZone.secondsFromGMT())
        dateFormatter.timeStyle = .full
        dateFormatter.dateStyle = .full
        return dateFormatter
    }
    
    private var timeZoneInSeconds: Int {
        timeZone.secondsFromGMT()
    }
    
    private var sunHorizonCoordinates: HorizonCoordinates = .init(altitude: .zero, azimuth: .zero)
    
    private var sunEquatorialCoordinates: EquatorialCoordinates = .init(declination: .zero)
    
    private var sunEclipticCoordinates: EclipticCoordinates = .init(eclipticLatitude: .zero, eclipticLongitude: .zero)
    
    //Sun constants
    private let sunEclipticLongitudeAtTheEpoch: Angle = .init(degrees: 280.466069)
    private let sunEclipticLongitudePerigee: Angle = .init(degrees: 282.938346)
    
    /// Number of the days passed since the start of the year for the self.date
    private var daysPassedFromStartOfTheYear: Int {
        let year =  calendar.component(.year, from: date)
        
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/mm/dd"
        dateFormatter.calendar = calendar
        let dataFormatted = dateFormatter.date(from: "\(year)/01/01")
        
        let startOfYear = calendar.startOfDay(for: dataFormatted!)
        let startOfDay = calendar.startOfDay(for: date)
        
        var daysPassedFromStartOfTheYear = calendar.dateComponents([.day], from: startOfYear, to: startOfDay).day!
        daysPassedFromStartOfTheYear = daysPassedFromStartOfTheYear + 1
        
        return daysPassedFromStartOfTheYear
    }
    
    private var b: Angle {
        let angleInDegrees: Double = (360 / 365 * Double(daysPassedFromStartOfTheYear - 81))
        
        return .degrees(angleInDegrees)
    }
    
    private var equationOfTime: Double {
        let bRad = b.radians
        
        return 9.87 * sin(2 * bRad) - 7.53 * cos(bRad) - 1.5 * sin(bRad)
    }
    
    private var localStandardTimeMeridian: Double {
        return (Double(timeZone.secondsFromGMT()) / SECONDS_IN_ONE_HOUR) * 15  //TimeZone in hour
    }
    
    private var timeCorrectionFactorInSeconds: Double {
        let timeCorrectionFactor = 4 * (location.coordinate.longitude - localStandardTimeMeridian) + equationOfTime
        let minutes: Double = Double(Int(timeCorrectionFactor) * 60)
        let seconds: Double = timeCorrectionFactor.truncatingRemainder(dividingBy: 1) * 100
        let timeCorrectionFactorInSeconds =  minutes + seconds
        
        return timeCorrectionFactorInSeconds
    }
    
    
    /*--------------------------------------------------------------------
     Private methods
     *-------------------------------------------------------------------*/
    
    /// Updates in order all the sun coordinates: horizon, ecliptic and equatorial.
    /// Then get rise, set and noon times and their relative azimuths in degrees.
    /// Compute Solar noon.
    /// Compute Golden hour start and end time.
    /// Compute first light and last light time
    ///
    private func refresh() {
        updateSunCoordinates()
        
        self.sunrise = getSunrise() ?? Date()
        self.sunriseAzimuth = getSunHorizonCoordinatesFrom(date: sunrise).azimuth.degrees
        self.sunset = getSunset() ?? Date()
        self.sunsetAzimuth = getSunHorizonCoordinatesFrom(date: sunset).azimuth.degrees
        self.solarNoon = getSolarNoon() ?? Date()
        self.solarNoonAzimuth = getSunHorizonCoordinatesFrom(date: solarNoon).azimuth.degrees
        self.goldenHourStart = getGoldenHourStart() ?? Date()
        self.goldenHourEnd = getGoldenHourFinish() ?? Date()
        self.firstLight = getFirstLight() ?? Date()
        self.lastLight = getLastLight() ?? Date()
        self.marchEquinox = getMarchEquinox()
        self.juneSolstice = getJuneSolstice()
        self.septemberEquinox = getSeptemberEquinox()
        self.decemberSolstice = getDecemberSolstice()
    }
    
    /// function called after timezone changes in order to change the date accordingly
    private func changeCurrentDate(){
        let components = calendar.dateComponents(in: self.timeZone, from: self.date)
        self.date = calendar.date(from: components) ?? self.date
    }
    
    private func getSunMeanAnomaly(from elapsedDaysSinceStandardEpoch: Double) -> Angle {
        //Compute mean anomaly sun
        var sunMeanAnomaly: Angle  = .init(degrees:(((360.0 * elapsedDaysSinceStandardEpoch) / 365.242191) + sunEclipticLongitudeAtTheEpoch.degrees - sunEclipticLongitudePerigee.degrees))
        sunMeanAnomaly = .init(degrees: extendedMod(sunMeanAnomaly.degrees, 360))
        
        return sunMeanAnomaly
    }
    
    private func getSunEclipticLongitude(from sunMeanAnomaly: Angle) -> Angle {
        //eclipticLatitude
        let equationOfCenter = 360 / Double.pi * sin(sunMeanAnomaly.radians) * 0.016708
        let trueAnomaly = sunMeanAnomaly.degrees + equationOfCenter
        var eclipticLatitude: Angle =  .init(degrees: trueAnomaly + sunEclipticLongitudePerigee.degrees)
        
        if eclipticLatitude.degrees > 360 {
            eclipticLatitude.degrees -= 360
        }
        
        return eclipticLatitude
    }
    
    
    /// Updates Horizon coordinates, Ecliptic coordinates and Equatorial coordinates of the Sun
    private func updateSunCoordinates() {
        //Step1:
        //Convert LCT to UT, GST, and LST times and adjust the date if needed
        let utDate = lCT2UT(self.date, timeZoneInSeconds: self.timeZoneInSeconds,useSameTimeZone: self.useSameTimeZone)
        let gstDate = uT2GST(utDate, timeZoneInSeconds: self.timeZoneInSeconds,useSameTimeZone: self.useSameTimeZone)
        let lstDate = gST2LST(gstDate,longitude: longitude,  timeZoneInSeconds: self.timeZoneInSeconds,useSameTimeZone: self.useSameTimeZone)
        
        let lstDecimal = HMS.init(from: lstDate, timeZoneInSeconds: self.timeZoneInSeconds,useSameTimeZone: self.useSameTimeZone).hMS2Decimal()
        
        //Step2:
        //Julian number for standard epoch 2000
        let jdEpoch = 2451545.00
        
        //Step3:
        //Compute the Julian day number for the desired date using the Greenwich date and TT
        
        let jdTT = jdFromDate(date: utDate)
        
        //Step5:
        //Compute the total number of elapsed days, including fractional days, since the standard epoch (i.e., JD − JDe)
        let elapsedDaysSinceStandardEpoch: Double = jdTT - jdEpoch //De
        
        //Step6: Use the algorithm from section 6.2.3 to calculate the Sun’s ecliptic longitude and mean anomaly for the given UT date and time.
        let sunMeanAnomaly = getSunMeanAnomaly(from: elapsedDaysSinceStandardEpoch)
        
        //Step7: Use Equation 6.2.4 to aproximate the Equation of the center
        let equationOfCenter = 360 / Double.pi * sin(sunMeanAnomaly.radians) * 0.016708
        
        //Step8: Add EoC to sun mean anomaly to get the sun true anomaly
        var sunTrueAnomaly = sunMeanAnomaly.degrees + equationOfCenter
        
        //Step9:
        sunTrueAnomaly = extendedMod(sunTrueAnomaly, 360)
        
        //Step10:
        var sunEclipticLongitude: Angle = .init(degrees: sunTrueAnomaly + sunEclipticLongitudePerigee.degrees)
        
        //Step11:
        if sunEclipticLongitude.degrees > 360 {
            sunEclipticLongitude.degrees -= 360
        }
        
        sunEclipticCoordinates = .init(eclipticLatitude: .zero, eclipticLongitude: sunEclipticLongitude)
        
        //Step12: Ecliptic to Equatorial
        sunEquatorialCoordinates = sunEclipticCoordinates.ecliptic2Equatorial()
        
        //Step13: Equatorial to Horizon
        sunHorizonCoordinates = sunEquatorialCoordinates.equatorial2Horizon(lstDecimal: lstDecimal,latitude: latitude) ?? .init(altitude: .zero, azimuth: .zero)
        
    }
    
    public func getSunHorizonCoordinatesFrom(date: Date) -> HorizonCoordinates {
        //Step1:
        //Convert LCT to UT, GST, and LST times and adjust the date if needed
        let utDate = lCT2UT(date, timeZoneInSeconds: self.timeZoneInSeconds,useSameTimeZone: self.useSameTimeZone)
        let gstDate = uT2GST(utDate, timeZoneInSeconds: self.timeZoneInSeconds,useSameTimeZone: self.useSameTimeZone)
        let lstDate = gST2LST(gstDate,longitude: longitude, timeZoneInSeconds: self.timeZoneInSeconds,useSameTimeZone: self.useSameTimeZone)
        
        let lstDecimal = HMS.init(from: lstDate,timeZoneInSeconds: self.timeZoneInSeconds,useSameTimeZone: self.useSameTimeZone).hMS2Decimal()
        
        //Step2:
        //Julian number for standard epoch 2000
        let jdEpoch = 2451545.00
        
        //Step3:
        //Compute the Julian day number for the desired date using the Greenwich date and TT
        
        let jdTT = jdFromDate(date: utDate)
        
        //Step5:
        //Compute the total number of elapsed days, including fractional days, since the standard epoch (i.e., JD − JDe)
        let elapsedDaysSinceStandardEpoch: Double = jdTT - jdEpoch //De
        
        //Step6: Use the algorithm from section 6.2.3 to calculate the Sun’s ecliptic longitude and mean anomaly for the given UT date and time.
        let sunMeanAnomaly = getSunMeanAnomaly(from: elapsedDaysSinceStandardEpoch)
        
        //Step7: Use Equation 6.2.4 to aproximate the Equation of the center
        let equationOfCenter = 360 / Double.pi * sin(sunMeanAnomaly.radians) * 0.016708
        
        //Step8: Add EoC to sun mean anomaly to get the sun true anomaly
        var sunTrueAnomaly = sunMeanAnomaly.degrees + equationOfCenter
        
        //Step9: Add or subtract multiples of 360° to adjust sun true anomaly to the range of 0° to 360°
        sunTrueAnomaly = extendedMod(sunTrueAnomaly, 360)
        
        
        //Step10: Getting ecliptic longitude.
        var sunEclipticLongitude: Angle = .init(degrees: sunTrueAnomaly + sunEclipticLongitudePerigee.degrees)
        
        //Step11:
        if sunEclipticLongitude.degrees > 360 {
            sunEclipticLongitude.degrees -= 360
        }
        
        let sunEclipticCoordinates: EclipticCoordinates = .init(eclipticLatitude: .zero, eclipticLongitude: sunEclipticLongitude)
        
        //Step12: Ecliptic to Equatorial
        var sunEquatorialCoordinates: EquatorialCoordinates = sunEclipticCoordinates.ecliptic2Equatorial()
        
        //Step13: Equatorial to Horizon
        let sunHorizonCoordinates: HorizonCoordinates = sunEquatorialCoordinates.equatorial2Horizon(lstDecimal: lstDecimal,latitude: latitude) ?? .init(altitude: .zero, azimuth: .zero)
        
        return .init(altitude: sunHorizonCoordinates.altitude, azimuth: sunHorizonCoordinates.azimuth)
    }
    
    /// Computes the solar noon for self.date. Solar noon is the time when the sun is highest in the sky.
    /// - Returns: Solar noon time
    private func getSolarNoon() -> Date? {
        let secondsForUTCSolarNoon = (720 - 4 * location.coordinate.longitude - equationOfTime) * 60
        let secondsForSolarNoon = secondsForUTCSolarNoon + Double(timeZoneInSeconds)
        let startOfTheDay = calendar.startOfDay(for: date)
        
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(secondsForSolarNoon))
        
        let solarNoon = calendar.date(bySettingHour: hoursMinutesSeconds.0, minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: startOfTheDay)
        
        return solarNoon
    }
    
    /// Computes the Sunrise time for self.date
    /// - Returns: Sunrise time
    private func getSunrise() -> Date? {
        var haArg = (cos(Angle.degrees(90.833).radians)) / (cos(latitude.radians) * cos(sunEquatorialCoordinates.declination.radians)) - tan(latitude.radians) * tan(sunEquatorialCoordinates.declination.radians)
        
        haArg = clamp(lower: -1, upper: 1, number: haArg)
        let ha: Angle = .radians(acos(haArg))
        let sunriseUTCMinutes = 720 - 4 * (location.coordinate.longitude + ha.degrees) - equationOfTime
        var sunriseSeconds = (Int(sunriseUTCMinutes) * 60) + timeZoneInSeconds
        let startOfDay = calendar.startOfDay(for: date)
        
        if sunriseSeconds < 0 {
            sunriseSeconds = 0
        }
        
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(sunriseSeconds))
        
        let sunriseDate = calendar.date(bySettingHour: hoursMinutesSeconds.0, minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: startOfDay)
        
        return sunriseDate
    }
    
    /// Computes the Sunset time for self.date
    /// - Returns: Sunset time
    private func getSunset() -> Date? {
        var haArg = (cos(Angle.degrees(90.833).radians)) / (cos(latitude.radians) * cos(sunEquatorialCoordinates.declination.radians)) - tan(latitude.radians) * tan(sunEquatorialCoordinates.declination.radians)
        
        haArg = clamp(lower: -1, upper: 1, number: haArg)
        let ha: Angle = .radians(-acos(haArg))
        let sunsetUTCMinutes = 720 - 4 * (location.coordinate.longitude + ha.degrees) - equationOfTime
        var sunsetSeconds = (Int(sunsetUTCMinutes) * 60) + timeZoneInSeconds
        let startOfDay = calendar.startOfDay(for: date)
        
        if sunsetSeconds > SECONDS_IN_ONE_DAY {
            sunsetSeconds = SECONDS_IN_ONE_DAY
        }
        
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(sunsetSeconds))
        
        let sunsetDate = calendar.date(bySettingHour: hoursMinutesSeconds.0, minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: startOfDay)
        
        return sunsetDate
    }
    
    
    /// Golden Hour in the afternoon begins when the sun reaches elevation equals to 6 degrees
    /// - Returns: Time at which the GoldenHour starts
    private func getGoldenHourStart() -> Date? {
        let elevationSunGoldenHourStart: Angle = .degrees(6.0)
        guard let goldenHourStart = getDateFrom(elevation: elevationSunGoldenHourStart) else {
            return nil
        }
        
        return goldenHourStart
    }
    
    /// Golden Hour in the afternoon ends when the sun reaches elevation equals to -4 degrees
    /// - Returns: Time at which the GoldenHour ends
    private func getGoldenHourFinish() -> Date? {
        let elevationSunGoldenHourFinish: Angle = .degrees(-4.0)
        guard let goldenHourFinish = getDateFrom(elevation: elevationSunGoldenHourFinish) else {
            return nil
        }
        
        return goldenHourFinish
    }
    
    /// Last light is when the Sun reaches -6 degrees of elevation
    /// - Returns: Last light time
    private func getLastLight() -> Date? {
        let elevationSunLastLight: Angle = .degrees(-6.0)
        guard let lastLight = getDateFrom(elevation: elevationSunLastLight) else {
            return nil
        }
        return lastLight
    }
    
    /// First light is when the Sun reaches -6 degrees of elevation.
    /// - Returns: First light time
    private func getFirstLight() -> Date? {
        let elevationSunFirstLight: Angle = .degrees(-6.0)
        guard let firstLight = getDateFrom(elevation: elevationSunFirstLight,morning: true) else {
            return nil
        }
        return firstLight
    }
    
    private func getMarchEquinox() -> Date {
        
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let julianDayMarchEquinox: Double = 1721139.2855 + 365.2421376 * year + 0.0679190 * pow(t, 2) - 0.0027879 * pow(t, 3)
        
        let marchEquinoxUTC = dateFromJd(jd: julianDayMarchEquinox)
        let components = calendar.dateComponents(in: self.timeZone, from: marchEquinoxUTC)
        return calendar.date(from: components) ?? Date()
    }
    
    private func getJuneSolstice() -> Date {
        
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let julianDayJuneSolstice: Double = 1721233.2486 + 365.2417284 * year - 0.0530180 * pow(t, 2) + 0.0093320 * pow(t, 3)
        
        let juneSolsticeUTC = dateFromJd(jd: julianDayJuneSolstice)
        let components = calendar.dateComponents(in: self.timeZone, from: juneSolsticeUTC)
        return calendar.date(from: components) ?? Date()
        
    }
    
    private func getSeptemberEquinox() -> Date {
        
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let julianDaySeptemberEquinox: Double = 1721325.6978 + 365.2425055 * year - 0.126689 * pow(t, 2) + 0.0019401 * pow(t, 3)
        
        let septemberEquinoxUTC = dateFromJd(jd: julianDaySeptemberEquinox)
        let components = calendar.dateComponents(in: self.timeZone, from: septemberEquinoxUTC)
        return calendar.date(from: components) ?? Date()
    }
    
    private func getDecemberSolstice() -> Date {
        
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let julianDayDecemberSolstice: Double = 1721414.3920 + 365.2428898 * year - 0.0109650 * pow(t, 2) - 0.0084885 * pow(t, 3)
        
        let decemberSolsticeUTC = dateFromJd(jd: julianDayDecemberSolstice)
        let components = calendar.dateComponents(in: self.timeZone, from: decemberSolsticeUTC)
        return calendar.date(from: components) ?? Date()
    }

}
