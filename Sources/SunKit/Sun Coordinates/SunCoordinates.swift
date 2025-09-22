//
//  SunCoordinates.swift
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


internal struct SunCoordinates: Sendable {
    internal var eclipticCoordinates: EclipticCoordinates
    internal var equatorialCoordinates: EquatorialCoordinates
    internal var horizonCoordinates: HorizonCoordinates
    
    internal let sunEclipticLongitudeAtTheEpoch: Angle = .init(degrees: 280.466069)
    internal let sunEclipticLongitudePerigee: Angle = .init(degrees: 282.938346)
    
    internal var azimuth: Angle {
        horizonCoordinates.azimuth
    }
    
    internal var altitude: Angle {
        horizonCoordinates.altitude
    }
    
    init(
        eclipticCoordinates: EclipticCoordinates,
        equatorialCoordinates: EquatorialCoordinates,
        horizonCoordinates: HorizonCoordinates
    ) {
        self.eclipticCoordinates = eclipticCoordinates
        self.equatorialCoordinates = equatorialCoordinates
        self.horizonCoordinates = horizonCoordinates
    }
    
    init() {
        self.eclipticCoordinates = EclipticCoordinates(eclipticLatitude: .zero, eclipticLongitude: .zero)
        self.equatorialCoordinates = EquatorialCoordinates(declination: .zero)
        self.horizonCoordinates = HorizonCoordinates(altitude: .zero, azimuth: .zero)
    }
    
    // MARK: - Coordinates
    
    internal mutating func setCoordinates(
        sunEclipticLongitude: Angle,
        lstDecimal: Double,
        latitude: Angle
    ) {
        setSunEclipticCoordinates(using: sunEclipticLongitude)
        setSunEquatorialCoordinates(using: eclipticCoordinates)
        setSunHorizonCoordinates(using: lstDecimal, latitude: latitude)
    }
    
    // TODO: Remove mutating func, need to refactor EquatorialCoordinates
    internal mutating func getSunHorizonCoordinatesGiven(
        sunEclipticLongitude: Angle,
        lstDecimal: Double,
        latitude: Angle
    ) -> HorizonCoordinates {
        let eclipticCoordinates = calculateSunEclipticCoordinates(using: sunEclipticLongitude)
        let equatorialCoordinates = calculateSunEquatorialCoordinates(using: eclipticCoordinates)
        let horizonCoordinates = calculateSunHorizonCoordinates(
            using: equatorialCoordinates,
            lstDecimal: lstDecimal,
            latitude: latitude
        )
        
        return horizonCoordinates
    }
    
    // MARK: Ecliptic Coordinates
    
    internal mutating func setSunEclipticCoordinates(using sunEclipticLongitude: Angle) {
        self.eclipticCoordinates = calculateSunEclipticCoordinates(using: sunEclipticLongitude)
    }
    
    internal func calculateSunEclipticCoordinates(using sunEclipticLongitude: Angle) -> EclipticCoordinates {
        EclipticCoordinates(eclipticLatitude: .zero, eclipticLongitude: sunEclipticLongitude)
    }
    
    // MARK: Equatorial Coordinates
    
    internal mutating func setSunEquatorialCoordinates(using sunEclipticCoordinates: EclipticCoordinates) {
        self.equatorialCoordinates = calculateSunEquatorialCoordinates(using: sunEclipticCoordinates)
    }
    
    // TODO: Move behavior into EclipticCoordinates
    internal func calculateSunEquatorialCoordinates(using sunEclipticCoordinates: EclipticCoordinates) -> EquatorialCoordinates {
        sunEclipticCoordinates.ecliptic2Equatorial()
    }
    
    // MARK: Horizon Coordinates
    
    internal mutating func setSunHorizonCoordinates(
        using lstDecimal: Double,
        latitude: Angle
    ) {
//        self.horizonCoordinates = calculateSunHorizonCoordinates(
//            using: equatorialCoordinates,
//            lstDecimal: lstDecimal,
//            latitude: latitude
//        )
    }
    
    // TODO: Remove mutating func, need to refactor EquatorialCoordinates
    internal mutating func calculateSunHorizonCoordinates(
        using sunEquatorialCoordinates: EquatorialCoordinates,
        lstDecimal: Double,
        latitude: Angle
    ) -> HorizonCoordinates {
//        let horizonCoordinates = sunEquatorialCoordinates.getHorizonCoordinates(lstDecimal: lstDecimal, latitude: latitude)
        
//        return horizonCoordinates ?? .init(altitude: .zero, azimuth: .zero)
        return .init(altitude: .zero, azimuth: .zero)
    }
    
    // MARK: - Helpers
    
    internal func calculateSunEclipticLongitude(using date: Date) -> Angle {
        // Julian number for standard epoch 2000
        let jdEpoch = 2451545.00
        // Compute the Julian day number for the desired date using the Greenwich date and TT
        let jdTT = jdFromDate(date: date)
        // Compute the total number of elapsed days, including fractional days, since the standard epoch (i.e., JD − JDe)
        let elapsedDaysSinceStandardEpoch: Double = jdTT - jdEpoch
        // Use the algorithm from section 6.2.3 to calculate the Sun’s ecliptic longitude and mean anomaly for the given UT date and time.
        let sunMeanAnomaly = getSunMeanAnomaly(from: elapsedDaysSinceStandardEpoch)
        // Use Equation 6.2.4 to aproximate the Equation of the center
        let equationOfCenter = 360 / Double.pi * sin(sunMeanAnomaly.radians) * 0.016708
        // Add EoC to sun mean anomaly to get the sun true anomaly
        var sunTrueAnomaly = sunMeanAnomaly.degrees + equationOfCenter
        // Add or subtract multiples of 360° to adjust sun true anomaly to the range of 0° to 360°
        sunTrueAnomaly = extendedMod(sunTrueAnomaly, 360)
        var sunEclipticLongitude: Angle = .init(degrees: sunTrueAnomaly + sunEclipticLongitudePerigee.degrees)
        
        if sunEclipticLongitude.degrees > 360 {
            sunEclipticLongitude.degrees -= 360
        }
        
        return sunEclipticLongitude
    }
    
    private func getSunMeanAnomaly(from elapsedDaysSinceStandardEpoch: Double) -> Angle {
        var sunMeanAnomaly: Angle = .init(degrees: (((360.0 * elapsedDaysSinceStandardEpoch) / 365.242191) + sunEclipticLongitudeAtTheEpoch.degrees - sunEclipticLongitudePerigee.degrees))
        sunMeanAnomaly = .init(degrees: extendedMod(sunMeanAnomaly.degrees, 360))
        
        return sunMeanAnomaly
    }
}
