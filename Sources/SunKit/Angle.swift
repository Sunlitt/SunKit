//
//  Angle.swift
//  
//
//  Created by Davide Biancardi on 25/11/22.
//

import Foundation

public struct Angle : Equatable {
    
    public static var zero: Angle = .init()
    
    public init() { _radians = 0 }
    
    public init(radians: Double) { _radians = radians }
  
    public init(degrees: Double) { _radians = degrees * Double.pi / 180.0 }
        
    public var degrees: Double {
        get { return _radians * 180.0 / Double.pi }
        set { _radians = newValue * Double.pi / 180 }
    }
    
    public var radians: Double {
        get { return _radians }
        set { _radians = newValue }
    }
    
    
    public static func ==(lhs: Angle, rhs: Angle) -> Bool {
        return lhs.radians == rhs.radians
    }
    
    private var _radians: Double
    
    public static func degrees(_ value:Double) -> Angle{
        return .init(degrees: value)
    }
    
    public static func radians(_ value:Double) -> Angle{
        return .init(radians: value)
    }

}
