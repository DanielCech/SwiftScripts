//
//  DoubleExtension.swift
//  stylesheetHelper
//
//  Created by Daniel Cech on 15/06/2020.
//

import Foundation


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
