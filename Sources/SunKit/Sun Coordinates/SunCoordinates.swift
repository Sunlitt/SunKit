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


internal final class SunCoordinates: Sendable {
    let eclipticCoordinates: EclipticCoordinates
    let equatorialCoordinates: EquatorialCoordinates
    let horizonCoordinates: HorizonCoordinates
    
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
}
