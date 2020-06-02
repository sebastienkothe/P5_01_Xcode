//
//  ExpressionChecker.swift
//  CountOnMe
//
//  Created by Sébastien Kothé on 31/05/2020.
//  Copyright © 2020 sebastienkothe. All rights reserved.
//

//import Foundation
//import UIKit
//
//final class ExpressionChecker {
//
//    // MARK: - Internal methods
//    internal func checkIfTheExpressionIsCorrect(itemsToCheck: [String]) -> Bool {
//        var operatorSign = Operator().operatorSign
//        operatorSign[4] = " = "
//
//        for (_, `operator`) in operatorSign where itemsToCheck.last == `operator`.trimmingCharacters(in: .whitespaces) {
//            return false
//        }
//        return true
//    }
//
//    internal func checkIfTheExpressionHasAResult(element: UITextView) -> Bool {
//        return element.text.firstIndex(of: "=") != nil
//    }
//
//    internal func checkTheExpressionLength(itemsToCheck: [String]) -> Bool {
//        return itemsToCheck.count >= 3
//    }
//
//    internal func checkTheExpressionConformity(textView: UITextView, elements: [String]) -> [Int] {
//        var errorsFound = [Int]()
//
//        if textView.text == "ERROR" { errorsFound.append(1) }
//
//        if !checkTheExpressionLength(itemsToCheck: elements) { errorsFound.append(2) }
//
//        if checkIfTheExpressionHasAResult(element: textView) { errorsFound.append(3) }
//
//        if !checkIfTheExpressionIsCorrect(itemsToCheck: elements) { errorsFound.append(4) }
//
//        return errorsFound
//    }
//}
