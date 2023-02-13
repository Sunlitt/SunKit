//
//  Sun.swift
//
//
//  Created by Davide Biancardi on 23/12/22.
//

import Foundation
import CoreLocation

public class Sun {
    /*--------------------------------------------------------------------
     Public get Variables
     *-------------------------------------------------------------------*/
    
    public private(set) var location: CLLocation
    public private(set) var timeZone: Double
    public private(set) var date: Date = Date()
    
    ///Date of Sunrise in local timezone
    public private(set) var sunrise: Date = Date()
    ///Date of Sunset in local timezone
    public private(set) var sunset: Date = Date()
    ///Date of Solar Noon  in local timezone
    public private(set) var solarNoon: Date = Date()
    ///Date at which Golden hour starts in local timezone
    public private(set) var goldenHourStart: Date = Date()
    ///Date at which Golden hour ends in local timezone
    public private(set) var goldenHourEnd: Date = Date()
    ///Date at which there is the first light  in local timezone
    public private(set) var firstLight: Date = Date()
    ///Date at which there is the last light  in local timezone
    public private(set) var lastLight: Date = Date()
    ///Azimuth of Sunrise
    public private(set) var sunriseAzimuth: Double = 0
    ///Azimuth of Sunset
    public private(set) var sunsetAzimuth: Double = 0
    ///Azimuth of Solar noon
    public private(set) var solarNoonAzimuth: Double = 0

    ///Date at which  there will be march equinox in local timezone
    public private(set) var marchEquinox: Date = Date()
    ///Date at which  there will be june solstice in locla timezone
    public private(set) var juneSolstice: Date = Date()
    ///Date at which  there will be september solstice in local timezone
    public private(set) var septemberEquinox: Date = Date()
    ///Date at which  there will be december solstice in local timezone
    public private(set) var decemberSolstice: Date = Date()
    
    
    public static let common: Sun = {
        return Sun(location: CLLocation(latitude: 37.334886, longitude: -122.008988), timeZone: -7)
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
     Private Variables
     *-------------------------------------------------------------------*/
    
    private var calendar: Calendar {
        var calendar: Calendar = .init(identifier: .gregorian)
        calendar.timeZone = .current
        
        return calendar
    }
    
    private var timeZoneInSeconds: Int {
        Int(timeZone * 3600)
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
        return timeZone * 15
    }
    
    private var timeCorrectionFactorInSeconds: Double {
        let timeCorrectionFactor = 4 * (location.coordinate.longitude - localStandardTimeMeridian) + equationOfTime
        let minutes: Double = Double(Int(timeCorrectionFactor) * 60)
        let seconds: Double = timeCorrectionFactor.truncatingRemainder(dividingBy: 1) * 100
        let timeCorrectionFactorInSeconds =  minutes + seconds
        
        return timeCorrectionFactorInSeconds
    }
    
    /*--------------------------------------------------------------------
     Public methods
     *-------------------------------------------------------------------*/
    
    public init(location: CLLocation,timeZone: Double) {
        self.timeZone = timeZone
        self.location = location
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
    
    public func setTimeZone(_ newTimeZone: Double) {
        timeZone = newTimeZone
        refresh()
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
        let utDate = lCT2UT(self.date, timeZoneInSeconds: self.timeZoneInSeconds)
        let gstDate = uT2GST(utDate)
        let lstDate = gST2LST(gstDate,longitude: longitude)
        
        let lstDecimal = HMS.init(from: lstDate).hMS2Decimal()
        
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
    
    private func getSunHorizonCoordinatesFrom(date: Date) -> HorizonCoordinates {
        //Step1:
        //Convert LCT to UT, GST, and LST times and adjust the date if needed
        let utDate = lCT2UT(date, timeZoneInSeconds: self.timeZoneInSeconds)
        let gstDate = uT2GST(utDate)
        let lstDate = gST2LST(gstDate,longitude: longitude)
        
        let lstDecimal = HMS.init(from: lstDate).hMS2Decimal()
        
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
    
    ///  Computes the time at which the sun will reach the elevation given in input
    /// - Parameters:
    ///   - elevation: Elevation
    ///   - morning: Sun reaches a specific elevation twice, this bolean variable is needed to find out which one need to be considered. The one reached in the morning or not.
    /// - Returns: Time at which the Sun reaches that elevation. Nil if it didn't find it.
    private func getDateFrom(elevation : Angle, morning: Bool = false) -> Date? {
        var cosHra = (sin(elevation.radians) - sin(sunEquatorialCoordinates.declination.radians) * sin(latitude.radians)) / (cos(sunEquatorialCoordinates.declination.radians) * cos(latitude.radians))
        cosHra = clamp(lower: -1, upper: 1, number: cosHra)
        let hraAngle: Angle = .radians(acos(cosHra))
        var secondsForSunToReachElevation = (morning ? -1 : 1) * (hraAngle.degrees / 15) * 3600  + TWELVE_HOUR_IN_SECONDS - timeCorrectionFactorInSeconds
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
        
        return UT2LCT(marchEquinoxUTC, timeZoneInSeconds: 0)
    }
    
    private func getJuneSolstice() -> Date {
        
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let julianDayJuneSolstice: Double = 1721233.2486 + 365.2417284 * year - 0.0530180 * pow(t, 2) + 0.0093320 * pow(t, 3)
        
        let juneSolsticeUTC = dateFromJd(jd: julianDayJuneSolstice)
        
        return UT2LCT(juneSolsticeUTC, timeZoneInSeconds: 0)
    }
    
    private func getSeptemberEquinox() -> Date {
        
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let julianDaySeptemberEquinox: Double = 1721325.6978 + 365.2425055 * year - 0.126689 * pow(t, 2) + 0.0019401 * pow(t, 3)
        
        let septemberEquinoxUTC = dateFromJd(jd: julianDaySeptemberEquinox)
        
        return UT2LCT(septemberEquinoxUTC, timeZoneInSeconds: 0)
    }
    
    private func getDecemberSolstice() -> Date {
        
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let julianDayDecemberSolstice: Double = 1721414.3920 + 365.2428898 * year - 0.0109650 * pow(t, 2) - 0.0084885 * pow(t, 3)
        
        let decemberSolsticeUTC = dateFromJd(jd: julianDayDecemberSolstice)
        
        return UT2LCT(decemberSolsticeUTC, timeZoneInSeconds: 0)
    }

}
