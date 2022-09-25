# SunKit

<img height="110" alt="sunkit" src="https://user-images.githubusercontent.com/55358113/192140073-de19a887-b6e8-49b8-bba2-142df171df3e.png">

SunKit is a Swift package which uses advanced math and trigonometry to
provide to compute several information about the Sun. This package has
been developed by a team of students not yet very familiar with the
Swift programming language, which means that there could be a lot of
space for improvements. Every contribution is welcome.

<img height="50" alt="sunkit" src="https://user-images.githubusercontent.com/55358113/174021100-c2c410f1-30e0-433c-b8ee-a7152545aa87.png"> [<img src="https://user-images.githubusercontent.com/55358113/174020637-ca23803f-341c-48ce-b896-1fd4b7423310.svg" height="50">](https://apps.apple.com/app/litt/id1628751457)

SunKit was first developed as part of a bigger project: Litt (https://github.com/seldon1000/Litt-AppStore). Even though Litt is not meant to be released as Open Source, me and the rest of team behind it decided to wrap the fundamental logic of the app and make a library out of it.

To compute Sunrise, Sunset; Golden Hour and so on we only need a
location and the time zone of that location.

## Local Solar Time Meridian

The Local Standard Time Meridian is a reference meridian used for a
particular time zone and is similar to the Prime Meridian, which is used
for Greenwich Mean Time. The LSTM is calculated according to the
equation:

$$LSTM= 15°  \Delta T_{U T C}$$

where $\Delta T_{U T C}$ is the difference of the Local Time (LT) from
Universal Coordinated Time (UTC) in hours. For instance, Rome Italy is
UTC \(+2\) so the Local Standard Time Meridian is $30°$.

``` swift
private var localStandardTimeMeridian: Double {
   return timeZone * 15
}
```

## The Equation Of Time

The equation of time (EoT) (in minutes) is an empirical equation that
corrects for the eccentricity of the Earth’s orbit and the Earth’s axial
tilt. An approximation 2 accurate to within $\frac{1}{2}$ minute is:

$$E o T=9.87 \sin (2 B)-7.53 \cos (B)-1.5 \sin (B)$$

where:

$$B=\frac{360}{365}(d-81)$$

in degrees and $\(d\)$ is thenumber of days since the start of the year.

``` swift
private var b: Angle {
   let angleInDegrees: Double = (360 / 365 * Double(daysPassedFromStartOfYear - 81))
   
   return .degrees(angleInDegrees)
}
    
private var equationOfTime: Double {
   let bRad = b.radians
        
   return 9.87 * sin(2 * bRad) - 7.53 * cos(bRad) - 1.5 * sin(bRad)
}
  
```

``` swift
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

   //It Doesn't count the current day
   daysPassedFromStartOfTheYear = daysPassedFromStartOfTheYear + 1
        
   return daysPassedFromStartOfTheYear
}
```

The *calendar* variable it’s a private varibale inside the *Sun* struct,
it’s initialised with the gregorian identifier.

``` swift
private var calendar: Calendar = .init(identifier: .gregorian)
```

We need this variable because an user could use a different calendar in
his phone, such as Japanese.

## Time Correction Factor

The net Time Correction Factor (in minutes) accounts for the variation
of the Local Solar Time (LST) within a given time zone due to the
longitude variations within the time zone and also incorporates the EoT
above.

$$T C=4(\text { Longitude }-L S T M)+E o T$$

The factor of 4 minutes comes from the fact that the Earth rotates $1°$
every 4 minutes.

``` swift
private var timeCorrectionFactorInSeconds: Double {
   let timeCorrectionFactor = 4 * (location.coordinate.longitude - localStandardTimeMeridian) + equationOfTime
   let minutes: Double = Double(Int(timeCorrectionFactor) * 60)
   let seconds: Double = timeCorrectionFactor.truncatingRemainder(dividingBy: 1) * 100
   let timeCorrectionFactorInSeconds =  minutes + seconds
        
   return timeCorrectionFactorInSeconds
}
```

The *timeCorrectionFactor* variable it’s in the form mm:ss, that’s why
we extract first the minutes and then the seconds to compute
*timeCorrectionFactorInSeconds* variable that we need.

## Local Solar Time

Twelve noon local solar time (LST) is defined as when the sun is highest
in the sky. Local time (LT) usually varies from LST because of the
eccentricity of the Earth’s orbit, and because of human adjustments such
as time zones and daylight saving.

The Local Solar Time (LST) can be found by using the previous two
corrections to adjust the local time (LT).

$$LST= LT + \frac{TC}{60}$$

``` swift
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
```

The *date* variable inside the *Sun* struct gives us the time at which
we have to compute the azimuth. But before compute it we need to compute
the Local Solar Time. Basically here the second row compute the equation.
We don’t need to divide the TC beacuse we already
have it in seconds. We then extract the minutes and the hour from the
date. For computation purpouse, we use a proportion to move the variable
*localSolarTimeMinute* from 0...59 range to the range 0...100.

## Hour Angle

The Hour Angle converts the local solar time (LST) into the number of
degrees which the sun moves across the sky. By definition, the Hour
Angle is $0°$ at solar noon. Since the Earth rotates $15°$ per hour, each
hour away from solar noon corresponds to an angular motion of the sun in
the sky of $15°$. In the morning the hour angle is negative, in the
afternoon the hour angle is positive.

$$HRA= 15° + (LST - 12)$$

``` swift
private var hourAngle: Angle {
   let angleInDegrees: Double = (localSolarTime - 12.0) * 15
        
   return .init(degrees: angleInDegrees)
}
```

## Declination Angle

The declination angle, denoted by $\(\delta\)$, varies seasonally due to
the tilt of the Earth on its axis of rotation and the rotation of the
Earth around the sun. If the Earth were not tilted on its axis of
rotation, the declination would always be $0°$. However, the Earth is
tilted by $23.45°$ and the declination angle varies plus or minus this
amount. Only at the spring and fall equinoxes is the declination angle
equal to $0°$. The rotation of the Earth around the sun and the change in
the declination angle is shown in the animation below. To compute the
declinaiton angle of the Earth: 

$$\delta=23.45^{\circ} \times \sin \left(\frac{360}{365} \times(d-81)\right)$$

``` swift
private var declination: Angle {
   let bRad = b.radians
   let declinationInDegree: Double = 23.45 * sin(bRad)
        
   return .init(degrees: declinationInDegree)
}
```

## Elevation Angle

The elevation angle (used interchangeably with altitude angle) is the
angular height of the sun in the sky measured from the horizontal.
Confusingly, both altitude and elevation are also used to describe the
height in meters above sea level. The elevation is $0°$ at sunrise and 90°
when the sun is directly overhead (which occurs for example at the
equator on the spring and fall equinoxes).It can be computed as follow.

$$\alpha=\sin ^{-1}[\sin \delta \sin \varphi+\cos \delta \cos \varphi \cos (H R A)]$$

Here $HRA$ is the hour angle that we already have computed, $\(\phi\)$ is
the latitude, and $\(\delta\)$ is the declination angle that we evaluated
already in the previous chapter.

``` swift
public var elevation: Angle {
   get {
      let declinationRad = declination.radians
      let hourAngleRad = hourAngle.radians
      let latitude: Angle = .degrees(location.coordinate.latitude)
      let latitudeRad = latitude.radians
      var elevationArg = sin(declinationRad) * sin(latitudeRad) + cos(declinationRad) * cos(latitudeRad) * cos(hourAngleRad)
      elevationArg = checkDomainForArcSinCosineFunction(argument: elevationArg)
      let elevationInRadians: Double = asin(elevationArg)
       
      return .init(radians: elevationInRadians)
   }
}
```

## Azimuth Angle

The azimuth angle is the compass direction from which the sunlight is
coming. At solar noon, the sun is always directly south in the northern
hemisphere and directly north in the southern hemisphere. The azimuth
angle varies throughout the day as shown in the animation below. At the
equinoxes, the sun rises directly east and sets directly west regardless
of the latitude, thus making the azimuth angles 90° at sunrise and 270°
at sunset. In general however, the azimuth angle varies with the
latitude and time of year and the full equations to calculate the sun’s
position throughout the day are given on the following page.

It can be calculated as follow:

$$Azimuth=cos^{-1}[\frac{sin\delta cos\varphi-cos\delta sin \varphi cos(HRA)}{cos\alpha}]$$

``` swift
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
        
   let azimuthAngle: Angle = .init(radians: azimuthRad)
   var azimuth = azimuthAngle.degrees
        
   if localSolarTime > 12 {
      azimuth = 360 - azimuth
   }
        
   return azimuth
}
```

The above equation only gives the correct azimuth in the solar morning
so that:

  - $$\(Azimuth = A_{zi}, for LST <12\)$$

  - $$\(Azimuth = 360° - A_{zi}, for LST > 12\)$$

The *checkDomainForArcSinCosineFunction* simply check if the argument
that will go inside the asin function or acos it’s inside the domain,
that is betweent -1 and 1. It’s necessary beacuse with al these
computations, it could happen that we could have as argument for acos
function or asin function 1,003 instead of 1. This could happen if you
pin yourself near one of the two poles.

``` swift
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
```

## Sunrise, Sunset and Solar Noon

For the special case of sunrise or sunset, the zenith is set to (the
approximate correction for atmospheric refraction at sunrise and sunset,
and the size of the solar disk), and the hour angle becomes:

$$ha=\pm \arccos \frac{\cos (90.833)}{\cos (l a t) \cos (d e c l)}-\tan (l a t) \tan (\text { decl })$$

Then the UTC time of sunrise (or sunset) in minutes is:

$$Sunrise/Sunset = 720 -4 *(longitude + ha) - EoT$$

For UTC solar noon:

$$snoon = 720 - 4 * longitude - EoT$$

Please note that this is for UTC Sunrise, Sunset and Solar Noon.We have
to convert it in your local time based on your time zone.

``` swift
private func getSunrise() throws -> Date {
   let latitude: Angle = .degrees(location.coordinate.latitude)
   let latitudeRad = latitude.radians
   let declinationRad = declination.radians
   var haArg = (cos(Angle.degrees(90.833).radians)) / (cos(latitudeRad) * cos(declinationRad)) - tan(latitudeRad) * tan(declinationRad)
   haArg = checkDomainForArcSinCosineFunction(argument: haArg)
   let ha: Angle = .init(radians: acos(haArg))
   let sunriseUTCMinutes = 720 - 4 * (location.coordinate.longitude + ha.degrees) - equationOfTime
   let sunriseSeconds = (sunriseUTCMinutes + timeZone * 60 ) * 60
   let startOfDay = calendar.startOfDay(for: date)
   guard var sunriseDate = calendar.date(byAdding: .second, value: Int(sunriseSeconds), to: startOfDay) else {
      throw SunError.unableToGenerateSunriseDate(from: date)
   }
        
   let hoursMinutesSeconds: (Int,Int,Int) = secondsToHoursMinutesSeconds(Int(sunriseSeconds))
        
   sunriseDate = calendar.date(bySettingHour: hoursMinutesSeconds.0 , minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: sunriseDate) ?? startOfDay
        
   return sunriseDate
}
```

``` swift
private func getSunset() throws -> Date {
   let secondsInOneDay: Double = 86399
   let latitude: Angle = .degrees(location.coordinate.latitude)
   let latitudeRad = latitude.radians
   let declinationRad = declination.radians
   var haArg = (cos(Angle.degrees(90.833).radians)) / (cos(latitudeRad) * cos(declinationRad)) - tan(latitudeRad) * tan(declinationRad)
   haArg = checkDomainForArcSinCosineFunction(argument: haArg)
   let ha: Angle = .init(radians: -acos(haArg))
   let sunsetUTCMinutes = 720 - 4 * (location.coordinate.longitude + ha.degrees) - equationOfTime
   var sunsetSeconds = (sunsetUTCMinutes + timeZone * 60 ) * 60
   let startOfDay = calendar.startOfDay(for: date)
        
   if sunsetSeconds > secondsInOneDay {
      sunsetSeconds = 86399
   }
        
   guard var sunsetDate = calendar.date(byAdding: .second, value: Int(sunsetSeconds), to: startOfDay) else {
      throw SunError.unableToGenerateSunsetDate(from: date)
   }
        
   let hoursMinutesSeconds: (Int,Int,Int) = secondsToHoursMinutesSeconds(Int(sunsetSeconds))
        
   sunsetDate = calendar.date(bySettingHour: hoursMinutesSeconds.0 , minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: sunsetDate) ?? Date()
        
   return sunsetDate
}
```

``` swift
private func getSolarNoon() throws -> Date {
   let secondsForUTCSolarNoon = (720 - 4 * location.coordinate.longitude - equationOfTime) * 60
   let secondsForSolarNoon = secondsForUTCSolarNoon + 3600 * timeZone
   let startOfTheDay = calendar.startOfDay(for: date)
   guard var solarNoon = calendar.date(byAdding: .second, value: Int(secondsForSolarNoon), to: startOfTheDay) else {
      throw SunError.unableToGenerateSolarNoon(from: date)
   }
        
   let hoursMinutesSeconds: (Int,Int,Int) = secondsToHoursMinutesSeconds(Int(secondsForSolarNoon))
        
   solarNoon = calendar.date(bySettingHour: hoursMinutesSeconds.0 , minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of: solarNoon) ?? Date()
        
   return solarNoon
}
```

## Golden Hour

In photography, the golden hour is the period of daytime shortly after
sunrise or before sunset, during which daylight is redder and softer
than when the sun is higher in the sky.

By definition, golden hour starts when the sun it’s at elevation; and
ends when it is at elevation.

Do compute it we have the function *getDateFrom(elevation : Angle)* ,
where we pass in it the angle and it outputs the time at which the sun
will reach that elevation.

``` swift
private func getGoldenHourStart() throws -> Date {
   let elevationSunGoldenHourStart: Angle = .init(degrees: 6.0)
   guard let goldenHourStart = getDateFrom(elevation: elevationSunGoldenHourStart) else {
      throw SunError.unableToGenerateGoldenHourStart(from: date)
   }
        
   return goldenHourStart
}
```

``` swift
private func getGoldenHourFinish() throws -> Date {
   let elevationSunGoldenHourFinish: Angle = .init(degrees: -4.0)
   guard let goldenHourFinish = getDateFrom(elevation: elevationSunGoldenHourFinish) else {
      throw SunError.unableToGenerateGoldenHourFinish(from: date)
   }
        
   return goldenHourFinish
}
```

To get a date from elevation we need to do three step, the first one
it’s to compute HRA from the elevation in input.

$$HRA=\arccos \frac{\sin (\alpha) - \sin (decl)\sin (lat)}{\cos (l a t) \cos (d e c l)}$$

After that we need now to compute the local solar time (LST) with the
following equation:

$$LST = 12 + (\frac{HRA}{15°})$$

The last step it’s to compute the local time (LT).

$$LT = LST - TC$$

``` swift
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
   let hoursMinutesSeconds: (Int,Int,Int) = secondsToHoursMinutesSeconds(Int(secondsForSunToReachElevation))
        
   var newDate = calendar.date(byAdding: .second, value: Int(secondsForSunToReachElevation), to: startOfTheDay)
        
   newDate = calendar.date(bySettingHour: hoursMinutesSeconds.0 , minute: hoursMinutesSeconds.1, second: hoursMinutesSeconds.2, of:newDate  ?? Date())
        
   return newDate
}
```

In this function we compute the equations
at row 9. The tenth row simply compute,
where 43200 it’s simple 12 hour in seconds, and we multiply
$\((\frac{HRA}{15°})\)$ by 3600 to convert this factor also in
seconds.

The if at row 13 is used beacuse near the poles could happen that the
sun will never reach that elevation, for example in summer in the north
pole is always day. The code in row 20 is needed because
*calendar.date(byAdding)* will add one hour more the day where the time
zone goes from +1 to +2. For example in Italy this happen 27 March. Also
the viceversa will happen of course.

## References

- NOAA Global Monitoring Division. General Solar Position Calculations. url: https://gml.noaa.gov/grad/solcalc/solareqns.PDF.
- PV Education. url: https://www.pveducation.org.

## Special thanks

- Davide Biancardi (https://github.com/davideilmito): main developer of SunKit.
