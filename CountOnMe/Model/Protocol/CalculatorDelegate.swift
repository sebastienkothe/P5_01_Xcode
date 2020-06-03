//
//  CalculatorDelegate.swift
//  CountOnMe
//
//  Created by Sébastien Kothé on 31/05/2020.
//  Copyright © 2020 sebastienkothe. All rights reserved.
//

import Foundation

protocol CalculatorDelegate {
    func textToComputeDidChange(textToCompute: String)
}