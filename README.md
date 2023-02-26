# SunKit

<div align="center">

<img height="110" alt="sunkit" src="https://user-images.githubusercontent.com/55358113/192140073-de19a887-b6e8-49b8-bba2-142df171df3e.png">

![GitHub](https://img.shields.io/github/license/sunlitt/sunkit) [![GitHub stars](https://img.shields.io/github/stars/Sunlitt/SunKit)](https://github.com/Sunlitt/SunKit/stargazers) [![GitHub issues](https://img.shields.io/github/issues/Sunlitt/SunKit)](https://github.com/Sunlitt/SunKit/issues) [![Requires Core Location](https://img.shields.io/badge/requires-CoreLocation-orange?style=flat&logo=Swift)](https://developer.apple.com/documentation/corelocation) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSunlitt%2FSunKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Sunlitt/SunKit) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSunlitt%2FSunKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Sunlitt/SunKit)

</div>

**SunKit** is a Swift package which uses math and trigonometry to compute several information about the Sun. This package has been developed by a team of learners relatively new to the Swift programming language, which means that there could be a lot of space for improvements. Every contribution is welcome.

SunKit was first developed as part of a bigger project: [Sunlitt](https://github.com/Sunlitt/Sunlitt-AppStore). Even though Sunlitt is not meant to be released as Open Source we decided to wrap the fundamental logic of the app and make an open source library out of it.

<img height="50" alt="sunkit" src="https://user-images.githubusercontent.com/55358113/174021100-c2c410f1-30e0-433c-b8ee-a7152545aa87.png"> [<img src="https://user-images.githubusercontent.com/55358113/174020637-ca23803f-341c-48ce-b896-1fd4b7423310.svg" height="50">](https://apps.apple.com/app/sunlitt/id1628751457)

To compute Sunrise, Sunset, Golden Hour and so on we only need a CLLocation and the time zone of that location. **CoreLocation framework is required for SunKit to work**.

## Features
  * Sun Azimuth
  * Sun Altitude
  * First Light Time
  * Last Light Time
  * Sunrise Time
  * Solar Noon Time
  * Golden Hour Time
  * Sunset Time
  * Sun Azimuth at Sunrise
  * Sun Azimuth at Sunset
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
Take a look to the other Package, this time about the Moon: [MoonKit](https://github.com/davideilmito/MoonKit).

## Special thanks

* [Davide Biancardi](https://github.com/davideilmito): main developer of SunKit.
