//
//  Debugging Utils.swift
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


extension Sun {
    /// Dumps all the Sun Events dates.
    public func dumpDateInfos() {
        print("Current Date              -> \(dateFormatter.string(from: date))")
        print("Sunrise                   -> \(dateFormatter.string(from: sunrise))")
        print("Sunset                    -> \(dateFormatter.string(from: sunset))")
        print("Solar Noon                -> \(dateFormatter.string(from: solarNoon))")
        print("Solar Midnight            -> \(dateFormatter.string(from: solarMidnight))")
        print("Evening Golden Hour Start -> \(dateFormatter.string(from: eveningGoldenHourStart))")
        print("Evening Golden Hour End   -> \(dateFormatter.string(from: eveningGoldenHourEnd))")
        print("Morning Golden Hour Start -> \(dateFormatter.string(from: morningGoldenHourStart))")
        print("Morning Golden Hour End   -> \(dateFormatter.string(from: morningGoldenHourEnd))")
        print("Civil dusk                -> \(dateFormatter.string(from: civilDusk))")
        print("Civil Dawn                -> \(dateFormatter.string(from: civilDawn))")
        print("Nautical Dusk             -> \(dateFormatter.string(from: nauticalDusk))")
        print("Nautical Dawn             -> \(dateFormatter.string(from: nauticalDawn))")
        print("Astronomical Dusk         -> \(dateFormatter.string(from: astronomicalDusk))")
        print("Astronomical Dawn         -> \(dateFormatter.string(from: astronomicalDawn))")
        print("Morning Blue Hour Start   -> \(dateFormatter.string(from: morningBlueHourStart))")
        print("Morning Blue Hour End     -> \(dateFormatter.string(from: morningBlueHourEnd))")
        print("evening Blue Hour Start   -> \(dateFormatter.string(from: eveningBlueHourStart))")
        print("evening Blue Hour End     -> \(dateFormatter.string(from: eveningBlueHourEnd))")
        
        print("March Equinox             -> \(dateFormatter.string(from: marchEquinox))")
        print("June Solstice             -> \(dateFormatter.string(from: juneSolstice))")
        print("September Equinox         -> \(dateFormatter.string(from: septemberEquinox))")
        print("December Solstice         -> \(dateFormatter.string(from: decemberSolstice))")
    }
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = self.timeZone
        dateFormatter.timeStyle = .full
        dateFormatter.dateStyle = .full
        return dateFormatter
    }
}
