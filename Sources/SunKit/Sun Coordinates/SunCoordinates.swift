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
}
