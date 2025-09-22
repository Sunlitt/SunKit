//
//  Sun.swift
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
import CoreLocation


public struct Sun: Identifiable, Sendable {
    public let id: UUID = UUID()
    
    /*--------------------------------------------------------------------
     Public get Variables
     *-------------------------------------------------------------------*/
    
    public private(set) var location: CLLocation
    public private(set) var timeZone: TimeZone
    public private(set) var date: Date
    
    /*--------------------------------------------------------------------
     Sun Events during the day
     *-------------------------------------------------------------------*/
    
    /*
     Sun Events during the day organized chronologically
     */
    public private(set) var astronomicalDawn: Date = Date()
    public private(set) var nauticalDawn: Date = Date()
    public private(set) var civilDawn: Date = Date()
    public private(set) var morningGoldenHourStart: Date = Date()
    public private(set) var sunrise: Date = Date()
    public private(set) var morningGoldenHourEnd: Date = Date()
    
    public private(set) var solarNoon: Date = Date()
    
    public private(set) var eveningGoldenHourStart: Date = Date()
    public private(set) var sunset: Date = Date()
    public private(set) var eveningGoldenHourEnd: Date = Date()
    public private(set) var civilDusk: Date = Date()
    public private(set) var nauticalDusk: Date = Date()
    public private(set) var astronomicalDusk: Date = Date()
    public private(set) var solarMidnight: Date = Date()
    
    /// Date at which the morning Blue Hour starts.
    /// The same elevation as Civil Dawn--when the Sun is at -6 degrees.
    public var morningBlueHourStart: Date {
        civilDawn
    }
    
    /// Date at which morning Blue Hour ends and the morning Golden Hour begins.
    /// The same elevation as morning Golden Hour start--when the Sun is at -4 degrees.
    public var morningBlueHourEnd: Date {
        morningGoldenHourStart
    }
    
    /// Date at which evening Golden Hour ends and the evening Blue Hour begins.
    /// The same elevation as morning Golden Hour end--when the Sun is at -4 degrees.
    public var eveningBlueHourStart: Date {
        eveningGoldenHourEnd
    }
    
    /// Date at which evening Blue Hour ends.
    /// The same elevation as Civil Dusk--when the Sun is at -6 degrees.
    public var eveningBlueHourEnd: Date {
        civilDusk
    }
    
    /*--------------------------------------------------------------------
     Sun Azimuths for Self.date and for Sunrise,Sunset and Solar Noon
     *-------------------------------------------------------------------*/
    
    public private(set) var sunriseAzimuth: Double = 0
    public private(set) var solarNoonAzimuth: Double = 0
    public private(set) var sunsetAzimuth: Double = 0
    
    /// The object backing the public interface for Sun coordinates.
    private var sunCoordinates: SunCoordinates = .init()
    
    public var azimuth: Angle {
        sunHorizonCoordinates.azimuth
    }
    
    public var altitude: Angle {
        sunHorizonCoordinates.altitude
    }
    // TODO: Use SunCoordinates as backing object for these Coordinates.
    private var sunHorizonCoordinates: HorizonCoordinates = .init(altitude: .zero, azimuth: .zero)
    public private(set) var sunEquatorialCoordinates: EquatorialCoordinates = .init(declination: .zero)
    public private(set) var sunEclipticCoordinates: EclipticCoordinates = .init(eclipticLatitude: .zero, eclipticLongitude: .zero)

    /*
     public var azimuth: Angle {
         sunCoordinates.azimuth
     }
     
     public var altitude: Angle {
         sunCoordinates.altitude
     }
     
     private var sunHorizonCoordinates: HorizonCoordinates {
         sunCoordinates.horizonCoordinates
     }
     
     public var sunEquatorialCoordinates: EquatorialCoordinates {
         sunCoordinates.equatorialCoordinates
     }
     
     public var sunEclipticCoordinates: EclipticCoordinates {
         sunCoordinates.eclipticCoordinates
     }
     */
    /*--------------------------------------------------------------------
     Sun Events during the year
     *-------------------------------------------------------------------*/
    
    public private(set) var marchEquinox: Date = Date()
    public private(set) var juneSolstice: Date = Date()
    public private(set) var septemberEquinox: Date = Date()
    public private(set) var decemberSolstice: Date = Date()
    
    /*--------------------------------------------------------------------
     Nice To Have public variables
     *-------------------------------------------------------------------*/
    
    /// Longitude of location
    public var longitude: Angle {
        .init(degrees: location.coordinate.longitude)
    }
    
    /// Latitude of Location
    public var latitude: Angle {
        .init(degrees: location.coordinate.latitude)
    }
    
    /// Returns daylight time in seconds.
    public var totalDayLightTime: Int {
        let diffComponents = calendar.dateComponents([.second], from: sunrise, to: sunset)
        
        return diffComponents.second ?? 0
    }
    
    /// Returns night time in seconds.
    public var totalNightTime: Int {
        let startOfTheDay = calendar.startOfDay(for: date)
        let endOfTheDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfTheDay)!
        var diffComponents = calendar.dateComponents([.second], from: startOfTheDay, to: sunrise)
        var nightHours: Int = diffComponents.second ?? 0
        diffComponents = calendar.dateComponents([.second], from: sunset, to: endOfTheDay)
        nightHours = nightHours + (diffComponents.second ?? 0)
        
        return nightHours
    }
    
    /// Returns True if is night
    public var isNight: Bool {
        if !isCircumPolar {
            date < sunrise || date > sunset
        } else {
            isAlwaysNight
        }
    }
    
    /// Returns True if is twilight time
    public var isTwilight: Bool {
        (astronomicalDawn <= date && date < sunrise) || (sunset < date && date <= astronomicalDusk)
    }
    
    /// Returns True if we are in evening golden hour range
    public var isEveningGoldenHour: Bool {
        date >= eveningGoldenHourStart && date <= eveningGoldenHourEnd
    }
    
    /// Returns True if we are in morning golden hour range
    public var isMorningGoldenHour: Bool {
        date >= morningGoldenHourStart && date <= morningGoldenHourEnd
    }
    
    /// Returns True if we are in  golden hour range
    public var isGoldenHour: Bool {
        isMorningGoldenHour || isEveningGoldenHour
    }
    
    /// Returns True if we are in evening blue hour range
    public var isEveningBlueHour: Bool {
        date >= eveningBlueHourStart && date <= eveningBlueHourEnd
    }
    
    /// Returns True if we are in morning blue hour range
    public var isMorningBlueHour: Bool {
        date >= morningBlueHourStart && date <= morningBlueHourEnd
    }
    
    /// Returns True if we are in  blue hour range
    public var isBlueHour: Bool {
        isMorningBlueHour || isEveningBlueHour
    }
    
    /// Returns true if we are near the pole and we are in a situation in which Sun Events during the day could have no meaning
    public var isCircumPolar: Bool {
        isAlwaysDay || isAlwaysNight
    }
    
    /// Returns true if for (Location,Date) is always daylight (e.g Tromso city  in summer)
    public var isAlwaysDay: Bool {
        let startOfTheDay = calendar.startOfDay(for: date)
        let almostNextDay = startOfTheDay + Double(SECONDS_IN_ONE_DAY)
        
        return sunset == almostNextDay || sunrise < startOfTheDay + SECONDS_IN_TEN_MINUTES
    }
    
    /// Returns true if for (Location,Date) is always daylight (e.g Tromso city in Winter)
    public var isAlwaysNight: Bool {
        sunset - TWO_HOURS_IN_SECONDS < sunrise
    }
    
    /*--------------------------------------------------------------------
     Initializers
     *-------------------------------------------------------------------*/
    
    public init(location: CLLocation, timeZone: TimeZone, date: Date = Date()) {
        self.timeZone = timeZone
        self.location = location
        self.date = date
        
        refresh()
    }
    
    init(location: CLLocation, timeZone: Double, date: Date = Date()) {
        let timeZoneSeconds: Int = Int(timeZone * SECONDS_IN_ONE_HOUR)
        self.timeZone = TimeZone.init(secondsFromGMT: timeZoneSeconds) ?? .current
        self.location = location
        self.date = date
        
        refresh()
    }
    
    /*--------------------------------------------------------------------
     Public methods
     *-------------------------------------------------------------------*/
    
    /*--------------------------------------------------------------------
     Changing date of interest
     *-------------------------------------------------------------------*/
    
    public mutating func setDate(_ newDate: Date) {
        let newDay = calendar.dateComponents([.day,.month,.year], from: newDate)
        let oldDay = calendar.dateComponents([.day,.month,.year], from: date)
        let isSameDay: Bool = (newDay == oldDay)
        date = newDate
        
        refresh(needToComputeSunEvents: !isSameDay)  // If is the same day no need to compute again Daily Sun Events
    }
    
    /*--------------------------------------------------------------------
     Changing Location
     *-------------------------------------------------------------------*/
    
    /// Changing location and timezone
    /// - Parameters:
    ///   - newLocation: New location
    ///   - newTimeZone: New timezone for the given location. Is highly recommanded to pass a Timezone initialized via .init(identifier: ) method
    public mutating func setLocation(_ newLocation: CLLocation,_ newTimeZone: TimeZone) {
        timeZone = newTimeZone
        location = newLocation
        refresh()
    }
    
    /// Changing only the location
    /// - Parameter newLocation: New Location
    public mutating func setLocation(_ newLocation: CLLocation) {
        location = newLocation
        refresh()
    }
    
    /// Is highly recommanded to use the other method to change both location and timezone. This will be kept only for backwards retrocompatibility.
    /// - Parameters:
    ///   - newLocation: New Location
    ///   - newTimeZone: New Timezone express in Double. For timezones which differs of half an hour add 0.5,
    public mutating func setLocation(_ newLocation: CLLocation,_ newTimeZone: Double) {
        let timeZoneSeconds: Int = Int(newTimeZone * SECONDS_IN_ONE_HOUR)
        timeZone = TimeZone(secondsFromGMT: timeZoneSeconds) ?? .current
        location = newLocation
        refresh()
    }
    
    /*--------------------------------------------------------------------
     Changing Timezone
     *-------------------------------------------------------------------*/
    
    /// Changing only the timezone.
    /// - Parameter newTimeZone: New Timezone
    public mutating func setTimeZone(_ newTimeZone: TimeZone) {
        timeZone = newTimeZone
        refresh()
    }
    
    /// Is highly recommanded to use the other method to change timezone. This will be kept only for backwards retrocompatibility.
    /// - Parameter newTimeZone: New Timezone express in Double. For timezones which differs of half an hour add 0.5,
    public mutating func setTimeZone(_ newTimeZone: Double) {
        let timeZoneSeconds: Int = Int(newTimeZone * SECONDS_IN_ONE_HOUR)
        timeZone = TimeZone(secondsFromGMT: timeZoneSeconds) ?? .current
        refresh()
    }
    
    /*--------------------------------------------------------------------
     Private Variables
     *-------------------------------------------------------------------*/
    
    private var calendar: Calendar {
        var calendar: Calendar = .init(identifier: .gregorian)
        calendar.timeZone = self.timeZone
        
        return calendar
    }
    
    private var timeZoneInSeconds: Int {
        timeZone.secondsFromGMT(for: self.date)
    }
    
    /// Number of the days passed since the start of the year for the self.date
    private var daysPassedFromStartOfTheYear: Int {
        let year = calendar.component(.year, from: date)
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
        return (Double(self.timeZoneInSeconds) / SECONDS_IN_ONE_HOUR) * 15  // TimeZone in hour
    }
    
    private var timeCorrectionFactorInSeconds: Double {
        let timeCorrectionFactor = 4 * (location.coordinate.longitude - localStandardTimeMeridian) + equationOfTime
        let minutes: Double = Double(Int(timeCorrectionFactor) * 60)
        let seconds: Double = timeCorrectionFactor.truncatingRemainder(dividingBy: 1) * 100
        let timeCorrectionFactorInSeconds = minutes + seconds
        
        return timeCorrectionFactorInSeconds
    }
    
    /// - Returns: Length in meters of the object's shadow by the provided object height and current sun altitude.
    public func shadowLength(
        for objectHeight: Double = 1,
        with altitude: Angle? = nil
    ) -> Double? {
        let altitude = altitude ?? self.altitude
        
        return if altitude.degrees > 0 && altitude.degrees < 90 {
            objectHeight / tan(altitude.radians)
        } else if altitude.degrees <= 0 {
            nil
        } else {
            0
        }
    }
 
    // MARK: - Refresh Sun State
    
    /// Updates in order all the sun coordinates: horizon, ecliptic and equatorial.
    /// Then get rise, set and noon times and their relative azimuths in degrees.
    /// Compute Solar noon.
    /// Compute Golden hour start and end time.
    /// Compute civil dusk and Civil Dawn time
    ///
    /// - Parameter needToComputeAgainSunEvents: True if Sunrise,Sunset and all the others daily sun events have to be computed.
    private mutating func refresh(needToComputeSunEvents: Bool = true) {
        updateSunCoordinates(using: self.date, longitude: self.longitude, latitude: self.latitude)
        
        if (needToComputeSunEvents) {
            self.astronomicalDawn = getAstronomicalDawn() ?? Date()
            self.nauticalDawn = getNauticalDawn() ?? Date()
            self.civilDawn = getCivilDawn() ?? Date()
            self.morningGoldenHourStart = getMorningGoldenHourStart() ?? Date()
            self.sunrise = getSunrise() ?? Date()
            self.morningGoldenHourEnd = getMorningGoldenHourEnd() ?? Date()
            
            self.solarNoon = getSolarNoon() ?? Date()
            
            self.eveningGoldenHourStart = getEveningGoldenHourStart() ?? Date()
            self.sunset = getSunset() ?? Date()
            self.eveningGoldenHourEnd = getEveningGoldenHourEnd() ?? Date()
            self.civilDusk = getCivilDusk() ?? Date()
            self.nauticalDusk = getNauticalDusk() ?? Date()
            self.astronomicalDusk = getAstronomicalDusk() ?? Date()
            self.solarMidnight = getSolarMidnight() ?? Date()
            
            self.sunriseAzimuth = getSunHorizonCoordinatesFrom(date: sunrise).azimuth.degrees
            self.solarNoonAzimuth = getSunHorizonCoordinatesFrom(date: solarNoon).azimuth.degrees
            self.sunsetAzimuth = getSunHorizonCoordinatesFrom(date: sunset).azimuth.degrees
        }
        
        self.marchEquinox = getMarchEquinox() ?? Date()
        self.juneSolstice = getJuneSolstice() ?? Date()
        self.septemberEquinox = getSeptemberEquinox() ?? Date()
        self.decemberSolstice = getDecemberSolstice() ?? Date()
    }
    
    /// Updates Horizon coordinates, Ecliptic coordinates and Equatorial coordinates of the Sun
    private mutating func updateSunCoordinates(using date: Date, longitude: Angle, latitude: Angle) {
        let lstDecimal = sunCoordinates.calculateLSTDecimal(using: date, longitude: longitude)
        let sunEclipticLongitude: Angle = sunCoordinates.calculateSunEclipticLongitude(using: date)
        
        updateCoordinates(sunEclipticLongitude: sunEclipticLongitude, lstDecimal: lstDecimal, latitude: latitude)
    }
    
    private mutating func updateCoordinates(
        sunEclipticLongitude: Angle,
        lstDecimal: Double,
        latitude: Angle
    ) {
        sunEclipticCoordinates = sunCoordinates.calculateSunEclipticCoordinates(using: sunEclipticLongitude)
        // Ecliptic to Equatorial
        sunEquatorialCoordinates = sunCoordinates.calculateSunEquatorialCoordinates(using: sunEclipticCoordinates)
        // Equatorial to Horizon
        sunHorizonCoordinates = sunCoordinates.calculateSunHorizonCoordinates(
            using: sunEquatorialCoordinates,
            lstDecimal: lstDecimal,
            latitude: latitude
        )
    }
    
    public func getSunHorizonCoordinatesFrom(date: Date) -> HorizonCoordinates {
        let sunHorizonCoordinates = sunCoordinates.getSunHorizonCoordinates(
            given: date,
            longitude: self.longitude,
            latitude: self.latitude
        )
        
        return sunHorizonCoordinates
    }
    
    // MARK: - Get Day Events
    
    /// Astronomical Dawn is when the Sun reaches -18 degrees of elevation.
    private func getAstronomicalDawn() -> Date? {
        guard let astronomicalDawn = getDateFrom(sunEvent: .astronomical, morning: true) else {
            return nil
        }
        
        return astronomicalDawn
    }
    
    /// Nautical Dusk is when the Sun reaches -12 degrees of elevation.
    private func getNauticalDawn() -> Date? {
        guard let nauticalDawn = getDateFrom(sunEvent: .nautical, morning: true) else {
            return nil
        }
        
        return nauticalDawn
    }
    
    /// Civil Dawn is when the Sun reaches -6 degrees of elevation.
    private func getCivilDawn() -> Date? {
        guard let civilDawn = getDateFrom(sunEvent: .civil,morning: true) else {
            return nil
        }
        
        return civilDawn
    }
    
    /// Morning Golden Hour starts when the Sun reaches -4 degrees of elevation.
    private func getMorningGoldenHourStart() -> Date? {
        guard let morningGoldenHourStart = getDateFrom(sunEvent: .morningGoldenHourStart, morning: true) else {
            return nil
        }
        
        return morningGoldenHourStart
    }
    
    /// Sunrise is when the Sun reaches 0 degrees of elevation, aka the horizon, at the start of the day.
    private func getSunrise() -> Date? {
        let sunriseSeconds = calculateSunriseSeconds()
        let sunriseDate = calculateDate(using: sunriseSeconds)
        
        return sunriseDate
    }
    
    private func calculateSunriseSeconds() -> Int {
        let solarHourAngle = calculateSunriseSolarHourAngle()
        let sunriseUTCMinutes = calculateUTCMinutes(using: solarHourAngle)
        var sunriseSeconds = calculateSeconds(using: sunriseUTCMinutes)
        
        if sunriseSeconds < Int(SECONDS_IN_ONE_HOUR) {
            sunriseSeconds = 0
        }
        
        return sunriseSeconds
    }
    
    private func calculateSunriseSolarHourAngle() -> Angle {
        let cosSolarHourAngle = clampCosineOfSolarHourAngle()
        let solarHourAngle: Angle = .radians(acos(cosSolarHourAngle))
        
        return solarHourAngle
    }
    
    private func clampCosineOfSolarHourAngle() -> Double {
        let cosSolarHourAngle = calculateCosineOfSolarHourAngle()
        
        return clamp(lower: -1, upper: 1, number: cosSolarHourAngle)
    }
    
    private func calculateCosineOfSolarHourAngle() -> Double {
        let solarZenithAngle = 90.833
        let cosSolarZenithAngle = cos(Angle.degrees(solarZenithAngle).radians)
        let cosLatitude = cos(latitude.radians)
        let cosSunDeclination = cos(sunEquatorialCoordinates.declination.radians)
        let tanLatitude = tan(latitude.radians)
        let tanSunDeclination = tan(sunEquatorialCoordinates.declination.radians)
        
        return cosSolarZenithAngle / (cosLatitude * cosSunDeclination) - tanLatitude * tanSunDeclination
    }
    
    private func calculateUTCMinutes(using solarHourAngle: Angle) -> Double {
        let longitude = location.coordinate.longitude
        
        return 720 - 4 * (longitude + solarHourAngle.degrees) - equationOfTime
    }
    
    private func calculateSeconds(using UTCMinutes: Double) -> Int {
        let UTCSeconds = Int(UTCMinutes) * 60
        
        return UTCSeconds + timeZoneInSeconds
    }
    
    private func calculateDate(using seconds: Int) -> Date? {
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(seconds))
        let startOfDay = calendar.startOfDay(for: date)
        let date = calendar.date(
            bySettingHour: hoursMinutesSeconds.0,
            minute: hoursMinutesSeconds.1,
            second: hoursMinutesSeconds.2,
            of: startOfDay
        )
        
        return date
    }
    
    /// Morning Golden Hour ends when Sun reaches 6 degrees of elevation.
    private func getMorningGoldenHourEnd() -> Date? {
        guard let morningGoldenHourEnd = getDateFrom(sunEvent: .morningGoldenHourEnd, morning: true) else {
            return nil
        }
        
        return morningGoldenHourEnd
    }
    
    /// Solar Noon is the time when the Sun is highest in the sky.
    private func getSolarNoon() -> Date? {
        let secondsForUTCSolarNoon = (720 - 4 * location.coordinate.longitude - equationOfTime) * 60
        let secondsForSolarNoon = secondsForUTCSolarNoon + Double(timeZoneInSeconds)
        let startOfTheDay = calendar.startOfDay(for: date)
        let solarNoon = calendar.date(byAdding: .second, value: Int(secondsForSolarNoon), to: startOfTheDay)
        
        return solarNoon
    }
    
    /// Evening Golden Hour begins when the Sun reaches 6 degrees of elevation.
    private func getEveningGoldenHourStart() -> Date? {
        guard let eveningGoldenHourStart = getDateFrom(sunEvent: .eveningGoldenHourStart) else {
            return nil
        }
        
        return eveningGoldenHourStart
    }
    
    /// Sunset is when the Sun reaches 0 degrees of elevation, aka the horizon, at the end of the day.
    private func getSunset() -> Date? {
        let sunsetSeconds = calculateSunsetSeconds()
        let sunsetDate = calculateDate(using: sunsetSeconds)
        
        return sunsetDate
    }
    
    private func calculateSunsetSeconds() -> Int {
        let solarHourAngle = calculateSunsetSolarHourAngle()
        let sunsetUTCMinutes = calculateUTCMinutes(using: solarHourAngle)
        var sunsetSeconds = calculateSeconds(using: sunsetUTCMinutes)
        
        if sunsetSeconds > SECONDS_IN_ONE_DAY {
            sunsetSeconds = SECONDS_IN_ONE_DAY
        }
        
        return sunsetSeconds
    }
    
    private func calculateSunsetSolarHourAngle() -> Angle {
        let cosSolarHourAngle = clampCosineOfSolarHourAngle()
        let solarHourAngle: Angle = .radians(-acos(cosSolarHourAngle))
        
        return solarHourAngle
    }
    
    /// Evening Golden Hour ends when the sun reaches -4 degrees of elevation.
    private func getEveningGoldenHourEnd() -> Date? {
        guard let goldenHourFinish = getDateFrom(sunEvent: .eveningGoldenHourEnd) else {
            return nil
        }
        
        return goldenHourFinish
    }
    
    /// Civil Dusk is when the Sun reaches -6 degrees of elevation.
    private func getCivilDusk() -> Date? {
        guard let civilDusk = getDateFrom(sunEvent: .civil, morning: false) else {
            return nil
        }
        
        return civilDusk
    }
    
    /// Nautical Dusk is when the Sun reaches -12 degrees of elevation.
    private func getNauticalDusk() -> Date? {
        guard let nauticalDusk = getDateFrom(sunEvent: .nautical, morning: false) else {
            return nil
        }
        
        return nauticalDusk
    }
    
    /// Astronomical Dusk is when the Sun reaches -18 degrees of elevation.
    private func getAstronomicalDusk() -> Date? {
        guard let astronomicalDusk = getDateFrom(sunEvent: .astronomical, morning: false) else {
            return nil
        }
        
        return astronomicalDusk
    }
    
    /// Computes the solar midnight for self.date.
    private func getSolarMidnight() -> Date? {
        let secondsForUTCSolarMidnight = (0 - 4 * location.coordinate.longitude - equationOfTime) * 60
        let secondsForSolarMidnight = secondsForUTCSolarMidnight + Double(timeZoneInSeconds)
        let startOfTheDay = calendar.startOfDay(for: date)
        let solarMidnight = calendar.date(byAdding: .second, value: Int(secondsForSolarMidnight), to: startOfTheDay)
        
        return solarMidnight
    }
    
    ///  Computes the time at which the sun will reach the elevation given in input for self.date
    /// - Parameters:
    ///   - elevation: Elevation
    ///   - morning: Sun reaches a specific elevation twice, this boolean variable is needed to find out which one need to be considered. The one reached in the morning or not.
    /// - Returns: Time at which the Sun reaches that elevation. Nil if it didn't find it.
    private func getDateFrom(
        sunEvent : SunElevationEvents,
        morning: Bool = false
    ) -> Date? {
        let elevationSun: Angle = .degrees(sunEvent.rawValue)
        var cosHra = (sin(elevationSun.radians) - sin(sunEquatorialCoordinates.declination.radians) * sin(latitude.radians)) / (cos(sunEquatorialCoordinates.declination.radians) * cos(latitude.radians))
        cosHra = clamp(lower: -1, upper: 1, number: cosHra)
        let hraAngle: Angle = .radians(acos(cosHra))
        var secondsForSunToReachElevation = (morning ? -1 : 1) * (hraAngle.degrees / 15) * SECONDS_IN_ONE_HOUR + TWELVE_HOUR_IN_SECONDS - timeCorrectionFactorInSeconds
        let startOfTheDay = calendar.startOfDay(for: date)
        
        if (Int(secondsForSunToReachElevation) > SECONDS_IN_ONE_DAY) {
            secondsForSunToReachElevation = Double(SECONDS_IN_ONE_DAY)
        } else if (secondsForSunToReachElevation < SECONDS_IN_ONE_HOUR) {
            secondsForSunToReachElevation = 0
        }
        
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(secondsForSunToReachElevation))
        let newDate = calendar.date(bySettingHour: hoursMinutesSeconds.0 , minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: startOfTheDay)
        
        return newDate
    }
    
    // MARK: - Get Month Events
    
    // TODO: Move magic numbers into Enum cases or subclasses
    
    private func getMarchEquinox() -> Date? {
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let marchSolsticeJulianDayConstant = 1721139.2855
        let marchSolsticeMeanYearLengthInDays = 365.2421376
        let quadraticCorrection = 0.0679190
        let cubicCorrection = 0.0027879
        
        let julianDayMarchEquinox: Double = marchSolsticeJulianDayConstant + marchSolsticeMeanYearLengthInDays * year + quadraticCorrection * pow(t, 2) - cubicCorrection * pow(t, 3)
        let marchEquinoxUTC = dateFromJd(jd: julianDayMarchEquinox)
        
        return marchEquinoxUTC
    }
    
    private func getJuneSolstice() -> Date? {
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let juneSolsticeJulianDayConstant = 1721233.2486
        let juneSolsticeMeanYearLengthInDays = 365.2417284
        let quadraticCorrection = 0.0530180
        let cubicCorrection = 0.0093320
        
        let julianDayJuneSolstice: Double = juneSolsticeJulianDayConstant + juneSolsticeMeanYearLengthInDays * year - quadraticCorrection * pow(t, 2) + cubicCorrection * pow(t, 3)
        let juneSolsticeUTC = dateFromJd(jd: julianDayJuneSolstice)
        
        return juneSolsticeUTC
    }
    
    private func getSeptemberEquinox() -> Date? {
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let septemberSolsticeJulianDayConstant = 1721325.6978
        let septemberSolsticeMeanYearLengthInDays = 365.2425055
        let quadraticCorrection = 0.126689
        let cubicCorrection = 0.0019401
        
        let julianDaySeptemberEquinox: Double = septemberSolsticeJulianDayConstant + septemberSolsticeMeanYearLengthInDays * year - quadraticCorrection * pow(t, 2) + cubicCorrection * pow(t, 3)
        let septemberEquinoxUTC = dateFromJd(jd: julianDaySeptemberEquinox)
        
        return septemberEquinoxUTC
    }
    
    private func getDecemberSolstice() -> Date? {
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let decemberSolsticeJulianDayConstant = 1721414.3920
        let decemberSolsticeMeanYearLengthInDays = 365.2428898
        let quadraticCorrection = 0.0109650
        let cubicCorrection = 0.0084885
        
        let julianDayDecemberSolstice: Double = decemberSolsticeJulianDayConstant + decemberSolsticeMeanYearLengthInDays * year - quadraticCorrection * pow(t, 2) - cubicCorrection * pow(t, 3)
        let decemberSolsticeUTC = dateFromJd(jd: julianDayDecemberSolstice)
        
        return decemberSolsticeUTC
    }
}
