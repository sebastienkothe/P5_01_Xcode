//
//  CalculatorTestCase.swift
//  CountOnMeTests
//
//  Created by Sébastien Kothé on 05/06/2020.
//  Copyright © 2020 sebastienkothe. All rights reserved.
//

import XCTest
@testable import CountOnMe

class CalculatorTestCase: XCTestCase {
    var calculator: Calculator!
    var calculatorDelegateMock: CalculatorDelegateMock!
    
    override func setUp() {
        calculator = Calculator()
        calculatorDelegateMock = CalculatorDelegateMock()
        calculator.delegate = calculatorDelegateMock
    }
    
    func addExpressionToTextToCompute(_ expression: String) {
        for element in expression.elementsSplit {
            if element.isAnOperator {
                for operatorSign in MathOperator.allCases where element == operatorSign.symbol {
                    calculator.addMathOperator(operatorSign)
                }
            } else {
                calculator.addDigit(element)
            }
        }
    }
    
    func testGivenExpressionsAreContainedInTheDictionary_WhenTryingToCalculateThem_ThenResultShouldBeValueOfKey() {
        
        // Expressions to calculate
        let expressionToCalculateWithResult = [
            "2 * 0": " = 0",
            "0 * 2": " = 0",
            "2 * -1": " = -2",
            "-2 * 0": " = 0",
            "-0 * 2": " = 0",
            "8 * -5": " = -40",
            "6 * 8 - 3 / 1 + 8 * 9 - 5 / 4 * 5": " = 110.75",
            "6 * 8 + 3 / 1 - 8 * 9 - 5 / 4 * 5": " = -27.25",
            "6 * 8 - 3 / 1 - 8 * 9 - 5 / 4 * 5": " = -33.25",
            "6 * 8 + 3 / 1 + 8 * 9 - 5 / 4 * 5": " = 116.75",
            "-6 * 8 - 3 / 1 + 8 * 9 - 5 / 4 * 5": " = 14.75",
            "1 + 5 - 2 + 4 * 8": " = 36",
            "9 + 4 + 5 + 6 + 7 + 4 + 2 / 1 + 4 + 3 + 3 + 5 * 2": " = 57",
            "-9 + 4 + 5 + 6 + 7 + 4 + 2 / 1 + 4 + 3 + 3 + 5 * 2": " = 39",
            "9 + 4 - 5 + 6 + 7 + 4 - 2 / 1 + 4 - 3 + 3 + 5 * 2": " = 37",
            "-9 - 9 - 9 - 9 * 4": " = -63",
            "-1 + 2 - 1 + 4 / 2 - 3 + 6 + 5 / 2": " = 7.5",
            "-2 + 3 - 4 - 6 - 4 * 3": " = -21",
            "2 + 0": " = 2",
            "2 - 0": " = 2",
            "-6 * -2 / -2": " = -6",
            "-3 - 6 * 9 - 5 / -5 * 6 - 3 + 9": " = -45",
            "-6 + 3 + 4 / -4 + 9 + 6 - 3 * -6": " = 29"
        ]
        
        for expression in expressionToCalculateWithResult {
            addExpressionToTextToCompute(expression.key)
            calculator.handleTheExpressionToCalculate()
            XCTAssertEqual(calculatorDelegateMock.textToCompute, "\(expression.key)\(expression.value)")
        }
    }
    
    func testGivenOperatorIsMinus_WhenTextToComputeIsWorthTextToComputeCase_ThenTextToComputeShouldContainMinus() {
        let textToComputeCases = ["=", "error_message".localized, ""]
        
        for textToComputeCase in textToComputeCases {
            calculator.addDigit(textToComputeCase)
            calculator.addMathOperator(MathOperator.minus)
            XCTAssertEqual(calculatorDelegateMock.textToCompute, "-")
            calculator.cleanTextToCompute()
        }
    }
    
    func testTextToComputeIsWorth5Plus5Equal10_WhenTryingToAddEachOperator_ThenErrorRecoveredShouldContainAppropriateError() {
        addExpressionToTextToCompute("5 + 5")
        calculator.handleTheExpressionToCalculate()
        
        for mathOperator in MathOperator.allCases {
            calculator.addMathOperator(mathOperator)
            if mathOperator == .minus {
                XCTAssertEqual(calculatorDelegateMock.textToCompute, "-")
                continue
            }
            XCTAssertEqual(calculatorDelegateMock.errorRecovered, .cannotAddAMathOperator)
        }
    }
    
    func testTextToComputeIsWorth1_WhenTryingToAddPlusOperator_ThenErrorRecoveredShouldBeWorthNil() {
        addExpressionToTextToCompute("1 +")
        
        XCTAssertNil(calculatorDelegateMock.errorRecovered)
    }
    
    func testGivenTextToComputeIsWorth1DividedBy0_WhenTryingToCalculateThis_ThenErrorRecoveredShouldContainAppropriateError() {
        addExpressionToTextToCompute("1 / 0")
        
        calculator.handleTheExpressionToCalculate()
        
        XCTAssertEqual(calculatorDelegateMock.errorRecovered, .cannotDivideByZero)
        
    }
    
    func testGivenTextToComputeIsWorth1Plus2Equal3_WhenPressingEqualSign_ThenErrorRecoveredShouldContainAppropriateError() {
        addExpressionToTextToCompute("1 + 2")
        calculator.handleTheExpressionToCalculate()
        
        calculator.handleTheExpressionToCalculate()
        
        XCTAssertEqual(calculatorDelegateMock.errorRecovered, .cannotAddEqualSign)
    }
    
    func testGivenTextToComputeIsWorth1Plus_WhenTryingToAddMathOperators_ThenErrorRecoveredShouldContainAppropriateError() {
        addExpressionToTextToCompute("1 +")
        
        for mathOperator in MathOperator.allCases {
            calculator.addMathOperator(mathOperator)
            XCTAssertEqual(calculatorDelegateMock.errorRecovered, .cannotAddAMathOperator)
        }
    }
    
    func testGivenCalculatorErrorContainsFourCases_WhenTryingToAccessToTitleFromEachCase_ThenTitleShouldReturnTheCorrectString() {
        
        var counter = 0
        
        let calculatorErrorCases: [CalculatorError] = [
            .cannotDivideByZero, .cannotAddAMathOperator, .cannotAddEqualSign, .cannotConvertMathOperatorFromTag
        ]
        
        let calculatorErrorTitle = [
            "error_divide_by_zero_title".localized,
            "error_add_operator_title".localized,
            "error_add_equal_sign_title".localized,
            "error_convert_math_operator_title".localized
        ]
        
        for calculatorErrorCase in calculatorErrorCases {
            XCTAssertEqual(calculatorErrorCase.title, calculatorErrorTitle[counter])
            counter += 1
        }
    }
    
    func testGivenTextToComputeContainsANonConvertibleNumber_WhenTryingToConvertIt_ThenErrorMessageIsDisplayed() {
        for _ in 0...308 {
            calculator.addDigit("9")
        }
        addExpressionToTextToCompute("* 9")
        
        calculator.handleTheExpressionToCalculate()
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "error_message".localized)
    }
    
    func testGivenTextToComputeIsEmpty_WhenTryingToAddAnMinusOperatorAnd1_ThenTextToComputeShouldTheNegativeNumber() {
        addExpressionToTextToCompute("- 1")
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "-1")
    }
    
    func testGivenTextToComputeIsReset_WhenTryingToAddAnMinusOperator_ThenTextToComputeShouldContainIt() {
        calculator.cleanTextToCompute()
        
        calculator.addMathOperator(MathOperator.minus)
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "-")
    }
    
    func testGivenTextToComputeIsWorth1Plus0_WhenTryingToAddAZero_Then0ShouldNotBeAdded() {
        addExpressionToTextToCompute("1 + 0")
        
        calculator.addDigit("0")
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "1 + 0")
    }
    
    func testGivenTextToComputeIsWorth1_WhenTryingToAddAZero_Then0ShouldBeAdded() {
        calculator.addDigit("1")
        
        calculator.addDigit("0")
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "10")
    }
    
    func testGivenTextToComputeIsWorth10_WhenTryingToAddAZero_Then0ShouldBeAdded() {
        addExpressionToTextToCompute("10")
        
        calculator.addDigit("0")
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "100")
    }
    
    func testGivenTextToComputeIsWorthMinus0_WhenTryingToAddAZero_Then0ShouldNotBeAdded() {
        addExpressionToTextToCompute("-0")
        
        calculator.addDigit("0")
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "-0")
    }
    
    func testGivenTextToComputeIsWorth1Plus0_WhenTryingToAddA1_Then1ShouldNotBeAdded() {
        addExpressionToTextToCompute("1 + 0")
        
        calculator.addDigit("1")
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "1 + 0")
    }
    
    func testGivenTextToComputeIsWorth2MultipliedBy_WhenTryingToAddMinusOperator_ThenErrorRecoveredShouldBeWorthNil() {
        addExpressionToTextToCompute("2 *")
        
        calculator.addMathOperator(MathOperator.minus)
        
        XCTAssertNil(calculatorDelegateMock.errorRecovered)
    }
    
    func testGivenTextToComputeIsWorth8Minus_WhenTryingToAddMinusOperator_ThenErrorRecoveredShouldContainAppropriateError() {
        addExpressionToTextToCompute("8 -")
        
        calculator.addMathOperator(MathOperator.minus)
        
        XCTAssertEqual(calculatorDelegateMock.errorRecovered, .cannotAddAMathOperator)
    }
    
    func testGivenTextToComputeIsWorthMinus5Minus_WhenTryingToAddPlusOperator_ThenErrorRecoveredShouldContainAppropriateError() {
        addExpressionToTextToCompute("-5 -")
        
        calculator.addMathOperator(MathOperator.plus)
        
        XCTAssertEqual(calculatorDelegateMock.errorRecovered, .cannotAddAMathOperator)
    }
    
    func testGivenTextToComputeIsWorthMinus6_WhenTryingToAdd0_ThenTextToComputeShouldContainIt() {
        addExpressionToTextToCompute("-6")
        
        calculator.addDigit("0")
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "-60")
    }
    
    func testGivenTextToComputeIsWorth1Plus1_WhenTryingToCalculateThis_ThenResultShouldNotContainComma() {
        addExpressionToTextToCompute("1 + 1")
        
        calculator.handleTheExpressionToCalculate()
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "1 + 1 = 2")
    }
    
    func testGivenTextToComputeIsWorth8MultipliedByMinus0_WhenTryingToAddAZero_Then0ShouldNotBeAdded() {
        addExpressionToTextToCompute("8 * -0")
        
        calculator.addDigit("0")
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "8 * -0")
    }
    
    func testGivenTextToComputeIsWorthMinus0MultipliedByMinus_WhenTryingToAddAZero_Then0ShouldBeAdded() {
        addExpressionToTextToCompute("-0 * -")
        
        calculator.addDigit("0")
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "-0 * -0")
    }
    
    func testGivenTextToComputeIsEmpty_WhenTryingToAddMathOperators_ThenErrorRecoveredShouldContainAppropriateError() {
        for mathOperator in MathOperator.allCases {
            if mathOperator == .minus { continue }
            calculator.addMathOperator(mathOperator)
            XCTAssertEqual(calculatorDelegateMock.errorRecovered, .cannotAddAMathOperator)
        }
    }
    
    func testGivenTextToComputeIsWorthMinus0_WhenTryingToAdd1_Then1ShouldNotBeAdded() {
        addExpressionToTextToCompute("-0")
        
        calculator.addDigit("1")
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "-0")
    }
    
    func testGivenTextToComputeIsWorthMinus0Minus5_WhenTryingToAdd0_Then0ShouldBeAdded() {
        addExpressionToTextToCompute("-0 - 5")
        
        calculator.addDigit("0")
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "-0 - 50")
    }
    
    func testGivenTextToComputeIsEmpty_WhenTryingToAdd0AndMinusOperator_ThenMinusOperatorShouldBeAdded() {
        
        calculator.addDigit("0")
        calculator.addMathOperator(MathOperator.minus)
        
        XCTAssertEqual(calculatorDelegateMock.textToCompute, "0 - ")
    }
    
    func testGivenSenderTagIsWorth0_WhenSenderTagIsAddedToTheMethod_ThenErrorRecoveredShouldBeWorthNil() {
        for senderTag in 0...3 {
            calculator.addDigit("1")
            calculator.addMathOperatorFrom(tag: senderTag)
            XCTAssertNil(calculatorDelegateMock.errorRecovered)
            calculator.cleanTextToCompute()
        }
        
        calculator.addMathOperatorFrom(tag: 4)
        XCTAssertEqual(calculatorDelegateMock.errorRecovered, .cannotConvertMathOperatorFromTag)
    }
    
}

extension String {
    var elementsSplit: [String] {
        return self.split(separator: " ").map { "\($0)" }
    }
}
