//
//  Calculator.swift
//  CountOnMe
//
//  Created by Sébastien Kothé on 31/05/2020.
//  Copyright © 2020 sebastienkothe. All rights reserved.
//

import Foundation

final class Calculator {
    
    // MARK: - Internal properties
    weak var delegate: CalculatorDelegate?
    
    // MARK: - Internal methods
    
    /// To handle the addition of numbers
    func addDigit(_ digit: String) {
        
        // To reset the calculation to zero
        if isReadyToNewCalculation { cleanTextToCompute() }
        
        var digitRecovered = digit
        
        if digitRecovered.isNull && !textToCompute.isEmpty {
            guard let lastElement = elements.last else { return }
            guard let firstElement = elements.first else { return }
            
            guard lastElement.isAnOperator || (!firstElement.isNull && !lastElement.isNull) else { return }
            
            guard (firstElement != zeroNegative && lastElement.isAnOperator) || lastElement != zeroNegative else { return }
        } else {
            
            // To prevent the user from adding a number greater than 0 after a 0 or a -0
            guard !(elements.last == "0" || elements.last == zeroNegative) else { return }
        }
        
        // To create a negative number
        if textToCompute == MathOperator.minus.symbol {
            digitRecovered = MathOperator.minus.symbol + digitRecovered; cleanTextToCompute()
        }
        
        textToCompute.append(digitRecovered)
    }
    
    func cleanTextToCompute() {
        textToCompute.removeAll()
    }
    
    /// To add a math operator
    func addMathOperatorFrom(tag: Int) {
        var mathOperator: MathOperator?
        
        for (index, operatorName) in MathOperator.allCases.enumerated() where index == tag {
            mathOperator = operatorName
        }
        
        if let mathOperator = mathOperator {
            addMathOperator(mathOperator)
            
        } else { delegate?.didProduceError(.cannotConvertMathOperatorFromTag); return }
    }
    
    /// Used to add opertor to the operation
    func addMathOperator(_ mathOperator: MathOperator) {
        
        if mathOperator == .minus {
            
            // Here we are checking if we can add a minus operator in order to then create a negative number
            guard !(isReadyToNewCalculation && !elements.contains("0")) else { textToCompute = mathOperator.symbol; return }
            
            guard let lastElement = elements.last else { return }
            guard !lastElement.isPriorityOperator else { textToCompute += mathOperator.symbol; return }
        }
        
        guard lastElementIsNumber && !hasAResult else { delegate?.didProduceError(.cannotAddAMathOperator); return }
        
        textToCompute.append(" \(mathOperator.symbol) ")
    }
    
    /// Used to resolve the calculation
    func handleTheExpressionToCalculate() {
        guard lastElementIsNumber && hasEnoughElements && !hasAResult && !worthZero else {
            delegate?.didProduceError(.cannotAddEqualSign); return }
        
        var operatorRecovered: String = ""
        var operationsToReduce = elements
        var remainingFromCalculation: [String] = []
        var operandRight = 0.0
        var result = 0.0
        
        var operandLeft = 0.0 {
            didSet {
                let optionalOperator: String? = operationsToReduce[1]
                guard let operatorFound = optionalOperator else { return }
                if operatorFound.isAnOperator { operatorRecovered = operatorFound }
            }
        }
        
        while operationsToReduce.count > 1 || !remainingFromCalculation.isEmpty {
            
            if operationsToReduce.count == 1 && !remainingFromCalculation.isEmpty {
                addTheRestOfTheCalculation(&operationsToReduce, &remainingFromCalculation)
            }
            
            // Handles the priority operations
            if operationsToReduce.count > 3 && operationsToReduce[3].isPriorityOperator && !operationsToReduce[1].isPriorityOperator {
                handleThePriorityOperations(&operationsToReduce, &remainingFromCalculation)
            }
            
            convertOperandsToDouble(&operandLeft, &operandRight, operationsToReduce: operationsToReduce)
            
            performTheCalculation(operatorRecovered, operandLeft, operandRight, &result)
            
            guard !textToCompute.contains(errorMessage) else {return}
            
            // Used to exclude the first three elements
            excludeItems(&operationsToReduce)
            
            operationsToReduce.insert("\(convertAndFormat(temp: result))", at: 0)
        }
        
        guard let resultToDisplay = operationsToReduce.first else { return }
        textToCompute += " \(equalSign) \(resultToDisplay)"
    }
    
    // MARK: - Private properties
    private let errorMessage = "error_message".localized
    private let equalSign = "="
    private let zeroNegative = "-0"
    
    private var elements: [String] {
        return textToCompute.split(separator: " ").map { "\($0)" }
    }
    
    // When the value changes, we send the new value to the delegate
    private var textToCompute: String = "" {
        didSet {
            delegate?.didChangeOperation(textToCompute)
        }
    }
    
    private var lastElementIsNumber: Bool {
        guard let lastElement = textToCompute.last else { return false }
        return lastElement.isNumber
    }
    
    private var hasEnoughElements: Bool {
        elements.count >= 3
    }
    
    private var hasAResult: Bool {
        textToCompute.contains(equalSign)
    }
    
    private var worthZero: Bool {
        textToCompute.isNull
    }
    
    private var hasAErrorMessage: Bool {
        return textToCompute == errorMessage
    }
    
    private var isReadyToNewCalculation: Bool {
        worthZero || hasAResult || hasAErrorMessage || textToCompute.isEmpty
    }
    
    // MARK: - Private methods
    
    /// Used to perform the calculation
    private func performTheCalculation(_ operatorRecovered: String, _ operandLeft: Double, _ operandRight: Double, _ result: inout Double) {
        
        switch operatorRecovered {
        case MathOperator.plus.symbol: result = operandLeft + operandRight
        case MathOperator.minus.symbol: result = operandLeft - operandRight
        case MathOperator.multiplication.symbol:
            if operandRight.isZero || operandLeft == Double(zeroNegative) || operandLeft.isZero { result = 0; return }
            result = operandLeft * operandRight
        case MathOperator.division.symbol:
            guard !operandRight.isZero else {
                textToCompute = errorMessage
                delegate?.didProduceError(.cannotDivideByZero)
                return
            }
            result = operandLeft / operandRight
        default: return
            
        }
    }
    
    /// Used to convert operands from String to Double
    private func convertOperandsToDouble(_ operandLeft: inout Double, _ operandRight: inout Double, operationsToReduce: [String]) {
        guard let operandLeftConverted = Double(operationsToReduce[0]), let operandRightConverted = Double(operationsToReduce[2]) else { cleanTextToCompute(); textToCompute = errorMessage ; return }
        
        operandLeft = operandLeftConverted
        operandRight = operandRightConverted
    }
    
    /// Used to set aside non-priority operations
    private func handleTheNearestPriorityCalculation(_ remainingFromCalculation: inout [String], _ operationsToReduce: inout [String], operatorIsNegative: Bool) {
        
        let operatorRequired = operatorIsNegative ? MathOperator.minus.symbol : MathOperator.plus.symbol
        remainingFromCalculation.append(operatorRequired)
        
        if operatorIsNegative { operationsToReduce[0].removeFirst() }
        
        remainingFromCalculation.append(operationsToReduce[0])
        operationsToReduce.removeFirst()
        operationsToReduce[0] += operationsToReduce[1]
        operationsToReduce.remove(at: 1)
    }
    
    /// To add the rest of the calculation
    private func addTheRestOfTheCalculation(_ operationsToReduce: inout [String], _ remainingFromCalculation: inout [String]) {
        operationsToReduce += remainingFromCalculation
        remainingFromCalculation = []
    }
    
    private func handleThePriorityOperations(_ operationsToReduce: inout [String], _ remainingFromCalculation: inout [String]) {
        let numberIsNegative = operationsToReduce[0] == MathOperator.minus.symbol
        handleTheNearestPriorityCalculation(&remainingFromCalculation, &operationsToReduce, operatorIsNegative: numberIsNegative)
    }
    
    /// Used to delete items that are no longer needed
    private func excludeItems(_ operationsToReduce: inout [String]) {
        operationsToReduce = Array(operationsToReduce.dropFirst(3))
    }
    
    /// To convert the result from Double to String in the particular format
    private func convertAndFormat(temp: Double) -> String {
        let tempVar = String(format: "%g", temp)
        return tempVar
    }
}

extension String {
    
    var isPriorityOperator: Bool {
        self == MathOperator.multiplication.symbol || self == MathOperator.division.symbol
    }
    
    var isAnOperator: Bool {
        for operatorSign in MathOperator.allCases
            where self == operatorSign.symbol.trimmingCharacters(in: .whitespaces) {
                return true
        }
        return false
    }
    
    var isNull: Bool {
        self == "0"
    }
}
