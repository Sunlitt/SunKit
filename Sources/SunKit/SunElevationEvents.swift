//
//  SunElevationEvents.swift
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

enum SunElevationEvents: Double{
        
    case civil           = -6
    case nautical        = -12
    case astronomical    = -18
    case afternoonGoldenHourStart =  6
    case afternoonGoldenHourEnd   = -4
    
    static var morningGoldenHourStart: SunElevationEvents { .afternoonGoldenHourEnd }
    static var morningGoldenHourEnd: SunElevationEvents { .afternoonGoldenHourStart }
    
}