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
    public private(set) var date: Date = Date()
    
    /*--------------------------------------------------------------------
     Sun Events during the day
     *-------------------------------------------------------------------*/
    
    ///Date of Sunrise
    public private(set) var sunrise: Date = Date()
    ///Date of Sunset
    public private(set) var sunset: Date = Date()
    ///Date of Solar Noon  for
    public private(set) var solarNoon: Date = Date()
    
    ///Date at which evening  evening Golden hour starts
    public private(set) var goldenHourStart: Date = Date()
    ///Date at which evening  evening Golden hour ends
    public private(set) var goldenHourEnd: Date = Date()
    
    ///Date at which evening  Morning Golden hour starts
    public private(set) var morningGoldenHourStart: Date = Date()
    ///Date at which evening  Morning Golden hour ends
    public private(set) var morningGoldenHourEnd: Date = Date()
    
    
    ///Date at which there is the first light, also known as Civil Sunrise
    public private(set) var firstLight: Date = Date()
    ///Date at which there is the last light, also known as Civil Sunset
    public private(set) var lastLight: Date = Date()
    
    ///Date at which there is the Nautical Sunrise
    public private(set) var nauticalSunrise: Date = Date()
    ///Date at which there is the Nautical Sunset
    public private(set) var nauticalSunset: Date = Date()
    
    ///Date at which there is the Astronomical Sunrise
    public private(set) var astronomicalSunrise: Date = Date()
    ///Date at which there is the Astronomical Sunset
    public private(set) var astronomicalSunset: Date = Date()
    
    ///Date at which morning Blue Hour starts. Sun at -4 degrees elevation = morning golden hour start
    public var morningBlueHourStart: Date{
        return morningGoldenHourStart
    }
    
    ///Date at which morning Blue Hour ends. Sun at -6 degrees elevation = first light
    public var morningBlueHourEnd: Date {
        return firstLight
    }
    
    ///Date at which evening Blue Hour starts. Sun at -4 degrees elevation = evening golden hour end
    public var eveningBlueHourStart: Date{
        return goldenHourEnd
    }
    
    ///Date at which morning Blue Hour ends. Sun at -6 degrees elevation = last light
    public var eveningBlueHourEnd: Date {
        return lastLight
    }
    
    
    /*--------------------------------------------------------------------
     Sun Azimuths for Self.date and for Sunrise,Sunset and Solar Noon
     *-------------------------------------------------------------------*/
    
    ///Azimuth of Sunrise
    public private(set) var sunriseAzimuth: Double = 0
    ///Azimuth of Sunset
    public private(set) var sunsetAzimuth: Double = 0
    ///Azimuth of Solar noon
    public private(set) var solarNoonAzimuth: Double = 0
    
    // Sun azimuth for (Location,Date) in Self
    public var azimuth: Angle {
        return self.sunHorizonCoordinates.azimuth
    }
    
    // Sun altitude for (Location,Date) in Self
    public var altitude: Angle {
        return self.sunHorizonCoordinates.altitude
    }
    
    /*--------------------------------------------------------------------
     Sun Events during the year
     *-------------------------------------------------------------------*/
    
    ///Date at which  there will be march equinox
    public private(set) var marchEquinox: Date = Date()
    ///Date at which  there will be june solstice
    public private(set) var juneSolstice: Date = Date()
    ///Date at which  there will be september solstice
    public private(set) var septemberEquinox: Date = Date()
    ///Date at which  there will be december solstice
    public private(set) var decemberSolstice: Date = Date()
    
    /*--------------------------------------------------------------------
     Nice To Have public variables
     *-------------------------------------------------------------------*/
    
    /// Longitude of location
    public var longitude: Angle {
        return .init(degrees: self.location.coordinate.longitude)
    }
    
    /// Latitude of Location
    public var latitude: Angle {
        return .init(degrees: self.location.coordinate.latitude)
    }
    
    /// Returns daylight time in seconds
    public var totalDayLightTime: Int {
        let diffComponents = calendar.dateComponents([.second], from: sunrise, to: sunset)
        
        return diffComponents.second ?? 0
    }
    
    /// Returns night time in seconds
    public var totalNightTime: Int {
        let startOfTheDay   = calendar.startOfDay(for: date)
        let endOfTheDay     = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfTheDay)!
        var diffComponents  = calendar.dateComponents([.second], from: startOfTheDay, to: sunrise)
        var nightHours: Int = diffComponents.second ?? 0
        diffComponents      = calendar.dateComponents([.second], from: sunset, to: endOfTheDay)
        nightHours          = nightHours + (diffComponents.second ?? 0)
        
        return nightHours
    }
    
    /// Returns True if is night
    public var isNight: Bool {
        if !isCircumPolar {
            return date < firstLight || date > lastLight
        } else {
            return isAlwaysNight
        }
    }
    
    /// Returns True if is sunrise
    public var isSunrise: Bool {
        date >= firstLight && date <= sunrise
    }
    
    /// Returns True if is sunset
    public var isSunset: Bool {
        date >= sunset && date <= lastLight
    }
    
    /// Returns True if we are in evening golden hour range
    public var isGoldenHour: Bool {
        date.timeIntervalSince(goldenHourStart) >= 0 && goldenHourEnd.timeIntervalSince(date) >= 0
    }
    
    /// Returns true if we are near the pole and we are in a situation in which Sun Events during the day could have no meaning
    public var isCircumPolar: Bool {
        isAlwaysLight || isAlwaysNight
    }
    
    /// Returns true if for (Location,Date) is always daylight (e.g Tromso city  in summer)
    public var isAlwaysLight: Bool {
        let startOfTheDay = calendar.startOfDay(for: date)
        let almostNextDay = startOfTheDay + Double(SECONDS_IN_ONE_DAY)
        
        return sunset == almostNextDay || sunrise < startOfTheDay + SECONDS_IN_TEN_MINUTES
    }
    
    /// Returns true if for (Location,Date) is always daylight (e.g Tromso city in Winter)
    public var isAlwaysNight: Bool {
        return sunset - TWO_HOURS_IN_SECONDS < sunrise
    }
    
    /*--------------------------------------------------------------------
     Initializers
     *-------------------------------------------------------------------*/
    
    public init(location: CLLocation,timeZone: Double) {
        let timeZoneSeconds: Int = Int(timeZone * SECONDS_IN_ONE_HOUR)
        self.timeZone = TimeZone.init(secondsFromGMT: timeZoneSeconds) ?? .current
        self.location = location
        refresh()
    }
    
    public init(location: CLLocation,timeZone: TimeZone) {
        self.timeZone = timeZone
        self.location = location
        refresh()
    }
    
    /*--------------------------------------------------------------------
     Public methods
     *-------------------------------------------------------------------*/
    
    /*--------------------------------------------------------------------
     Changing date of interest
     *-------------------------------------------------------------------*/
    
    public func setDate(_ newDate: Date) {
        let newDay = calendar.dateComponents([.day,.month,.year], from: newDate)
        let oldDay = calendar.dateComponents([.day,.month,.year], from: date)
        
        let isSameDay: Bool = (newDay == oldDay)
        date = newDate
        
        refresh(needToComputeSunEvents: !isSameDay)  //If is the same day no need to compute again Daily Sun Events
    }
    
    /*--------------------------------------------------------------------
     Changing Location
     *-------------------------------------------------------------------*/
    
    
    /// Changing location and timezone
    /// - Parameters:
    ///   - newLocation: New location
    ///   - newTimeZone: New timezone for the given location. Is highly recommanded to pass a Timezone initialized via .init(identifier: ) method
    public func setLocation(_ newLocation: CLLocation,_ newTimeZone: TimeZone) {
        timeZone = newTimeZone
        location = newLocation
        refresh()
    }
    
    /// Changing only the location
    /// - Parameter newLocation: New Location
    public func setLocation(_ newLocation: CLLocation) {
        location = newLocation
        refresh()
    }
    
    
    /// Is highly recommanded to use the other method to change both location and timezone. This will be kept only for backwards retrocompatibility.
    /// - Parameters:
    ///   - newLocation: New Location
    ///   - newTimeZone: New Timezone express in Double. For timezones which differs of half an hour add 0.5,
    public func setLocation(_ newLocation: CLLocation,_ newTimeZone: Double) {
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
    public func setTimeZone(_ newTimeZone: TimeZone) {
        timeZone = newTimeZone
        refresh()
    }
    
    /// Is highly recommanded to use the other method to change timezone. This will be kept only for backwards retrocompatibility.
    /// - Parameter newTimeZone: New Timezone express in Double. For timezones which differs of half an hour add 0.5,
    public func setTimeZone(_ newTimeZone: Double) {
        let timeZoneSeconds: Int = Int(newTimeZone * SECONDS_IN_ONE_HOUR)
        timeZone = TimeZone(secondsFromGMT: timeZoneSeconds) ?? .current
        refresh()
    }
    
    /*--------------------------------------------------------------------
     Debug functions
     *-------------------------------------------------------------------*/
    
    /// Dumps all the Sun Events dates
    public func dumpDateInfos(){
        
        print("Current Date      -> \(dateFormatter.string(from: date))")
        print("Sunrise           -> \(dateFormatter.string(from: sunrise))")
        print("Sunset            -> \(dateFormatter.string(from: sunset))")
        print("Solar Noon        -> \(dateFormatter.string(from: solarNoon))")
        print("evening Golden Hour Start -> \(dateFormatter.string(from: goldenHourStart))")
        print("evening Golden Hour End   -> \(dateFormatter.string(from: goldenHourEnd))")
        print("Morning Golden Hour Start -> \(dateFormatter.string(from: morningGoldenHourStart))")
        print("Morning Golden Hour End   -> \(dateFormatter.string(from: morningGoldenHourEnd))")
        print("First Light          -> \(dateFormatter.string(from: firstLight))")
        print("Last Light           -> \(dateFormatter.string(from: lastLight))")
        print("Nautical Sunrise     -> \(dateFormatter.string(from: nauticalSunrise))")
        print("Nautical Sunset      -> \(dateFormatter.string(from: nauticalSunset))")
        print("Astronomical Sunrise -> \(dateFormatter.string(from: astronomicalSunrise))")
        print("Astronomical Sunset  -> \(dateFormatter.string(from: astronomicalSunset))")
        print("Morning Blue Hour Start -> \(dateFormatter.string(from: morningBlueHourStart))")
        print("Morning Blue Hour End   -> \(dateFormatter.string(from: morningBlueHourEnd))")
        print("evening Blue Hour Start -> \(dateFormatter.string(from: eveningBlueHourStart))")
        print("evening Blue Hour End   -> \(dateFormatter.string(from: eveningBlueHourEnd))")
        
        print("March Equinox     -> \(dateFormatter.string(from: marchEquinox))")
        print("June Solstice     -> \(dateFormatter.string(from: juneSolstice))")
        print("September Equinox -> \(dateFormatter.string(from: septemberEquinox))")
        print("December Solstice -> \(dateFormatter.string(from: decemberSolstice))")
        
    }
    
    /*--------------------------------------------------------------------
     Private Variables
     *-------------------------------------------------------------------*/
    
    private var calendar: Calendar {
        var calendar: Calendar = .init(identifier: .gregorian)
        calendar.timeZone      = self.timeZone
        
        return calendar
    }
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = self.timeZone
        dateFormatter.timeStyle = .full
        dateFormatter.dateStyle = .full
        return dateFormatter
    }
    
    private var timeZoneInSeconds: Int {
        timeZone.secondsFromGMT(for: self.date)
    }
    
    private var sunHorizonCoordinates: HorizonCoordinates       = .init(altitude: .zero, azimuth: .zero)
    private var sunEquatorialCoordinates: EquatorialCoordinates = .init(declination: .zero)
    private var sunEclipticCoordinates: EclipticCoordinates     = .init(eclipticLatitude: .zero, eclipticLongitude: .zero)
    
    //Sun constants
    private let sunEclipticLongitudeAtTheEpoch: Angle = .init(degrees: 280.466069)
    private let sunEclipticLongitudePerigee:    Angle = .init(degrees: 282.938346)
    
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
        return (Double(self.timeZoneInSeconds) / SECONDS_IN_ONE_HOUR) * 15  //TimeZone in hour
    }
    
    private var timeCorrectionFactorInSeconds: Double {
        let timeCorrectionFactor          = 4 * (location.coordinate.longitude - localStandardTimeMeridian) + equationOfTime
        let minutes: Double               = Double(Int(timeCorrectionFactor) * 60)
        let seconds: Double               = timeCorrectionFactor.truncatingRemainder(dividingBy: 1) * 100
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
    /// - Parameter needToComputeAgainSunEvents: True if Sunrise,Sunset and all the others daily sun events have to be computed.
    private func refresh(needToComputeSunEvents: Bool = true) {
        updateSunCoordinates()
        
        if(needToComputeSunEvents){
            self.sunrise          = getSunrise() ?? Date()
            self.sunriseAzimuth   = getSunHorizonCoordinatesFrom(date: sunrise).azimuth.degrees
            self.sunset           = getSunset() ?? Date()
            self.sunsetAzimuth    = getSunHorizonCoordinatesFrom(date: sunset).azimuth.degrees
            self.solarNoon        = getSolarNoon() ?? Date()
            self.solarNoonAzimuth = getSunHorizonCoordinatesFrom(date: solarNoon).azimuth.degrees
            self.goldenHourStart  = getGoldenHourStart()  ?? Date()
            self.goldenHourEnd    = getGoldenHourFinish() ?? Date()
            self.firstLight       = getFirstLight() ?? Date()
            self.lastLight        = getLastLight()  ?? Date()
            self.nauticalSunrise  = getNauticalSunrise() ?? Date()
            self.nauticalSunset   = getNauticalSunset()  ?? Date()
            self.astronomicalSunrise = getAstronomicalSunrise() ?? Date()
            self.astronomicalSunset  = getAstronomicalSunset()  ?? Date()
            self.morningGoldenHourStart = getMorningGoldenHourStart() ?? Date()
            self.morningGoldenHourEnd   = getMorningGoldenHourEnd() ?? Date()
            
        }
        
        self.marchEquinox     = getMarchEquinox()     ?? Date()
        self.juneSolstice     = getJuneSolstice()     ?? Date()
        self.septemberEquinox = getSeptemberEquinox() ?? Date()
        self.decemberSolstice = getDecemberSolstice() ?? Date()
    }
    
    private func getSunMeanAnomaly(from elapsedDaysSinceStandardEpoch: Double) -> Angle {
        //Compute mean anomaly sun
        var sunMeanAnomaly: Angle  = .init(degrees:(((360.0 * elapsedDaysSinceStandardEpoch) / 365.242191) + sunEclipticLongitudeAtTheEpoch.degrees - sunEclipticLongitudePerigee.degrees))
        sunMeanAnomaly = .init(degrees: extendedMod(sunMeanAnomaly.degrees, 360))
        
        return sunMeanAnomaly
    }
    
    private func getSunEclipticLongitude(from sunMeanAnomaly: Angle) -> Angle {
        //eclipticLatitude
        let equationOfCenter        = 360 / Double.pi * sin(sunMeanAnomaly.radians) * 0.016708
        let trueAnomaly             = sunMeanAnomaly.degrees + equationOfCenter
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
        let gstHMS = uT2GST(self.date)
        let lstHMS = gST2LST(gstHMS,longitude: longitude)
        
        let lstDecimal = lstHMS.hMS2Decimal()
        
        //Step2:
        //Julian number for standard epoch 2000
        let jdEpoch = 2451545.00
        
        //Step3:
        //Compute the Julian day number for the desired date using the Greenwich date and TT
        
        let jdTT = jdFromDate(date: self.date)
        
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
        let gstHMS = uT2GST(date)
        let lstHMS = gST2LST(gstHMS,longitude: longitude)
        
        let lstDecimal = lstHMS.hMS2Decimal()
        
        //Step2:
        //Julian number for standard epoch 2000
        let jdEpoch = 2451545.00
        
        //Step3:
        //Compute the Julian day number for the desired date using the Greenwich date and TT
        
        let jdTT = jdFromDate(date: date)
        
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
        let secondsForSolarNoon    = secondsForUTCSolarNoon + Double(timeZoneInSeconds)
        let startOfTheDay          = calendar.startOfDay(for: date)
        
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(secondsForSolarNoon))
        
        let solarNoon = calendar.date(bySettingHour: hoursMinutesSeconds.0, minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: startOfTheDay)
        
        return solarNoon
    }
    
    /// Computes the Sunrise time for self.date
    /// - Returns: Sunrise time
    private func getSunrise() -> Date? {
        var haArg = (cos(Angle.degrees(90.833).radians)) / (cos(latitude.radians) * cos(sunEquatorialCoordinates.declination.radians)) - tan(latitude.radians) * tan(sunEquatorialCoordinates.declination.radians)
        
        haArg                 = clamp(lower: -1, upper: 1, number: haArg)
        let ha: Angle         = .radians(acos(haArg))
        let sunriseUTCMinutes = 720 - 4 * (location.coordinate.longitude + ha.degrees) - equationOfTime
        var sunriseSeconds    = (Int(sunriseUTCMinutes) * 60) + timeZoneInSeconds
        let startOfDay        = calendar.startOfDay(for: date)
        
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
        
        haArg                = clamp(lower: -1, upper: 1, number: haArg)
        let ha: Angle        = .radians(-acos(haArg))
        let sunsetUTCMinutes = 720 - 4 * (location.coordinate.longitude + ha.degrees) - equationOfTime
        var sunsetSeconds    = (Int(sunsetUTCMinutes) * 60) + timeZoneInSeconds
        let startOfDay       = calendar.startOfDay(for: date)
        
        if sunsetSeconds > SECONDS_IN_ONE_DAY {
            sunsetSeconds = SECONDS_IN_ONE_DAY
        }
        
        let hoursMinutesSeconds: (Int, Int, Int) = secondsToHoursMinutesSeconds(Int(sunsetSeconds))
        
        let sunsetDate = calendar.date(bySettingHour: hoursMinutesSeconds.0, minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: startOfDay)
        
        return sunsetDate
    }
    
    ///  Computes the time at which the sun will reach the elevation given in input for self.date
    /// - Parameters:
    ///   - elevation: Elevation
    ///   - morning: Sun reaches a specific elevation twice, this boolean variable is needed to find out which one need to be considered. The one reached in the morning or not.
    /// - Returns: Time at which the Sun reaches that elevation. Nil if it didn't find it.
    private func getDateFrom(sunEvent : SunElevationEvents, morning: Bool = false) -> Date? {
        
        let elevationSunFirstLight: Angle = .degrees(sunEvent.rawValue)
        var cosHra = (sin(elevationSunFirstLight.radians) - sin(sunEquatorialCoordinates.declination.radians) * sin(latitude.radians)) / (cos(sunEquatorialCoordinates.declination.radians) * cos(latitude.radians))
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
    
    
    
    /// Golden Hour in the evening begins when the sun reaches elevation equals to 6 degrees
    /// - Returns: Time at which the GoldenHour starts
    private func getGoldenHourStart() -> Date? {
        guard let goldenHourStart = getDateFrom(sunEvent: .eveningGoldenHourStart) else {
            return nil
        }
        
        return goldenHourStart
    }
    
    /// Golden Hour in the evening ends when the sun reaches elevation equals to -4 degrees
    /// - Returns: Time at which the GoldenHour ends
    private func getGoldenHourFinish() -> Date? {
        guard let goldenHourFinish = getDateFrom(sunEvent: .eveningGoldenHourEnd) else {
            return nil
        }
        
        return goldenHourFinish
    }
    
    /// Last light is when the Sun reaches -6 degrees of elevation. Also known as civil sunset.
    /// - Returns: Last light time
    private func getLastLight() -> Date? {
        guard let lastLight = getDateFrom(sunEvent: .civil) else {
            return nil
        }
        return lastLight
    }
    
    /// First light is when the Sun reaches -6 degrees of elevation. Also known as civil sunrise.
    /// - Returns: First light time
    private func getFirstLight() -> Date? {
        guard let firstLight = getDateFrom(sunEvent: .civil, morning: true) else {
            return nil
        }
        return firstLight
    }
    
    /// Nautical Sunrise is when the Sun reaches -12 degrees of elevation.
    /// - Returns: Nautical Sunrise
    private func getNauticalSunrise() -> Date? {
        guard let nauticalSunrise = getDateFrom(sunEvent: .nautical, morning: true) else {
            return nil
        }
        return nauticalSunrise
    }
    
    /// Nautical Sunrise is when the Sun reaches -12 degrees of elevation.
    /// - Returns: Nautical Sunset
    private func getNauticalSunset() -> Date? {
        guard let nauticalSunset = getDateFrom(sunEvent: .nautical, morning: false) else {
            return nil
        }
        return nauticalSunset
    }
    
    /// Astronomical Sunrise is when the Sun reaches -18 degrees of elevation.
    /// - Returns: Nautical Sunrise
    private func getAstronomicalSunrise() -> Date? {
        guard let nauticalSunrise = getDateFrom(sunEvent: .astronomical, morning: true) else {
            return nil
        }
        return nauticalSunrise
    }
    
    /// Astronomical Sunset is when the Sun reaches -18 degrees of elevation.
    /// - Returns: Nautical Sunset
    private func getAstronomicalSunset() -> Date? {
        guard let nauticalSunset = getDateFrom(sunEvent: .astronomical, morning: false) else {
            return nil
        }
        return nauticalSunset
    }
    
    /// Morning Golden Hour start when Sun reaches -4 degress  of elevation
    /// - Returns: Morning golden hour start
    private func getMorningGoldenHourStart() -> Date? {
        guard let morningGoldenHourStart = getDateFrom(sunEvent: .morningGoldenHourStart , morning: true) else {
            return nil
        }
        return morningGoldenHourStart
    }
    
    /// Morning Golden Hour ends when Sun reaches 6 degress  of elevation
    /// - Returns: Morning golden hour end
    private func getMorningGoldenHourEnd() -> Date? {
        guard let morningGoldenHourEnd = getDateFrom(sunEvent: .morningGoldenHourEnd , morning: true) else {
            return nil
        }
        return morningGoldenHourEnd
    }
    
    private func getMarchEquinox() -> Date? {
        
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let julianDayMarchEquinox: Double = 1721139.2855 + 365.2421376 * year + 0.0679190 * pow(t, 2) - 0.0027879 * pow(t, 3)
        
        let marchEquinoxUTC = dateFromJd(jd: julianDayMarchEquinox)
        
        return marchEquinoxUTC
    }
    
    private func getJuneSolstice() -> Date? {
        
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let julianDayJuneSolstice: Double = 1721233.2486 + 365.2417284 * year - 0.0530180 * pow(t, 2) + 0.0093320 * pow(t, 3)
        
        let juneSolsticeUTC = dateFromJd(jd: julianDayJuneSolstice)
        
        return juneSolsticeUTC
    }
    
    private func getSeptemberEquinox() -> Date? {
        
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let julianDaySeptemberEquinox: Double = 1721325.6978 + 365.2425055 * year - 0.126689 * pow(t, 2) + 0.0019401 * pow(t, 3)
        
        let septemberEquinoxUTC = dateFromJd(jd: julianDaySeptemberEquinox)
        
        return septemberEquinoxUTC
    }
    
    private func getDecemberSolstice() -> Date? {
        
        let year = Double(calendar.component(.year, from: self.date))
        let t: Double = year / 1000
        let julianDayDecemberSolstice: Double = 1721414.3920 + 365.2428898 * year - 0.0109650 * pow(t, 2) - 0.0084885 * pow(t, 3)
        
        let decemberSolsticeUTC = dateFromJd(jd: julianDayDecemberSolstice)
        
        return decemberSolsticeUTC
    }
    
}
