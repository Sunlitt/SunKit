# SunKit

<div align="center">

<img height="110" alt="sunkit" src="https://user-images.githubusercontent.com/55358113/192140073-de19a887-b6e8-49b8-bba2-142df171df3e.png">

![GitHub](https://img.shields.io/github/license/sunlitt/sunkit) [![GitHub stars](https://img.shields.io/github/stars/Sunlitt/SunKit)](https://github.com/Sunlitt/SunKit/stargazers) [![GitHub issues](https://img.shields.io/github/issues/Sunlitt/SunKit)](https://github.com/Sunlitt/SunKit/issues) [![Requires Core Location](https://img.shields.io/badge/requires-CoreLocation-orange?style=flat&logo=Swift)](https://developer.apple.com/documentation/corelocation) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSunlitt%2FSunKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Sunlitt/SunKit) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSunlitt%2FSunKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Sunlitt/SunKit)

</div>

**SunKit** is a Swift package that uses math and trigonometry to compute several pieces of information about the Sun.

SunKit was first developed as part of a bigger project: [Sunlitt](https://github.com/Sunlitt/Sunlitt-AppStore). Even though Sunlitt is not meant to be open-sourced, we decided to wrap the fundamental logic of the app and build a library out of it, free for anyone to use, embrace and extend.

<img height="50" alt="sunkit" src="https://github.com/Sunlitt/SunKit/assets/55358113/a9d0b738-a4b6-49bf-bdfb-b462656cab92"> [<img src="https://user-images.githubusercontent.com/55358113/174020637-ca23803f-341c-48ce-b896-1fd4b7423310.svg" height="50">](https://apps.apple.com/app/sunlitt/id1628751457)

## Attribution
SunKit is licensed under the Apache License 2.0. For attribution, we request that you include an unmodified vector of SunKit's logo, available [here](Resources/sunkit.svg), along with our organization name "Sunlitt", both at legible sizes, and that they link back to our [website](https://sunlitt.app). 

If you are developing an app for Apple platforms, we additionally request that you include SunKit's license and copyright in the "Acknowledgments" section of your app's Settings.bundle file. We have included a Settings.bundle example [here](Resources/Settings.bundle) for you to download and import as is in your Xcode project.

Attribution is essential to make sure that our hard work is properly recognized and we thank you for complying with our requests.


## Usage
**CoreLocation framework is required for SunKit to work**. SunKit only needs a location and the relative time zone. Everything is computed locally, no internet connection is needed.

### Creating a Sun 

```swift

// Creating a CLLocation object with the coordinates you are interested in
let naplesLocation: CLLocation = .init(latitude: 40.84014, longitude: 14.25226)

// Timezone for the location of interest. It's highly recommended to initialize it via identifier
let timeZoneNaples: TimeZone = .init(identifier: "Europe/Rome") ?? .current

// Creating the Sun instance which will store all the information you need about sun events and his position
var mySun: Sun = .init(location: naplesLocation, timeZone: timeZoneNaples)

```

### Retrieve information

```swift
// Creating a Date instance
let myDate: Date = Date() // Your current date

// Setting inside mySun object the date of interest
mySun.setDate(myDate)

      // All the following informations are related to the given location for the date that has just been set

// Azimuth of the Sun 
mySun.azimuth.degrees  

// Altitude of the Sun
mySun.altitude.degrees

// Sunrise Date
mySun.sunrise

// Sunset Date
mySun.sunset

// Evening Golden Hour Start Date
mySun.eveningGoldenHourStart

// Evening Golden Hour End Date
mySun.eveningGoldenHourEnd

// To know all the information you can retrieve go to the **Features** section.

```


 ### Working with Timezones and Dates
To properly show the Sun Date Events use the following DateFormatter.

```swift

 //Creting a DateFormatter
 let dateFormatter =  DateFormatter()
 
 //Properly setting his attributes
 dateFormatter.locale    =  .current
 dateFormatter.timeZone  =  timeZoneNaples  // It shall be the same as the one used to initilize mySun
 dateFormatter.timeStyle = .full
 dateFormatter.dateStyle = .full
  
 //Printing Sun Date Events with the correct Timezone
  
 print("Sunrise: \(dateFormatter.string(from: mySun.sunrise))")
    
```

## Features
  * Sun Azimuth
  * Sun Altitude
  * Civil Dusk  Time
  * Civil Dawn Time
  * Sunrise Time
  * Solar Noon Time
  * Solar Midnight Time
  * Morning Golden Hour Time
  * Evening Golden Hour Time
  * Sunset Time
  * Astronomical Dusk
  * Astronomical Dawn
  * Nautical Dusk
  * Nautical Dawn
  * Morning Blue Hour Time
  * Evening Blue Hour Time 
  * Sun Azimuth at Sunrise
  * Sun Azimuth at Sunset
  * Sun Azimuth at Solar Noon
  * Total Daylight Duration
  * Total Night Duration
  * March Equinox
  * June Solstice
  * September Equinox
  * December Solstice


## References

* NOAA Global Monitoring Division. General Solar Position Calculations: [Link](https://gml.noaa.gov/grad/solcalc/solareqns.PDF).
* PV Education: [Link](https://www.pveducation.org).
* Celestial Calculations: A Gentle Introduction to Computational Astronomy: [Link](https://www.amazon.it/Celestial-Calculations-Introduction-Computational-Astronomy/dp/0262536633/ref=sr_1_1?__mk_it_IT=ÅMÅŽÕÑ&crid=1U99GMGDZ2CUF&keywords=celestial+calculations&qid=1674408445&sprefix=celestial+calculation%2Caps%2C109&sr=8-1).

## MoonKit  🌙
Take a look at SunKit's spiritual brother, [MoonKit](https://github.com/davideilmito/MoonKit).

## Special thanks
* [Davide Biancardi](https://github.com/davideilmito): Creator of SunKit.
