//
//  File.swift
//  Scientific calculator
//
//  Created by luka on 10/11/2016.
//  Copyright © 2016 luka. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    
    private var currentPriority: Int?
    
    private var internalProgram = [AnyObject]()
    
    typealias  PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            internalProgram.removeAll()
            accumulator = 0
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if variablesName[op as! String] != nil {
                        setOperand(operand: op as! String)
                    } else if let operation = op as? String {
                        performOperation(symbol: operation)
                    }
                    
                }
            }
        }
    }
    
    func undo(){
        if internalProgram.isEmpty{
            clearAll()
            return
        }else{
            internalProgram.removeLast()
            program = internalProgram as CalculatorBrain.PropertyList
            pending = nil
        }
        
    }

    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
        descAccumulator = formatter.string(from: NSNumber(value: accumulator))!
    }
    
    var variablesName = [String: Double]()
    
    func setOperand(operand: String) {
        if variablesName[operand] == nil {
            variablesName[operand] = 0.0
        }
        accumulator = variablesName[operand]!
        internalProgram.append(operand as AnyObject)
        descAccumulator = " " + operand + " "
    }
    
    private var descAccumulator = ""
    
    var description: String{
        get{
            if pending == nil{
                return descAccumulator
            }else{
                return pending!.descFunction(pending!.descOperand, "" )
            }
        }
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "✔️": Operation.UnaryOperation(sqrt,{"√("+$0+")"}),
        "cos": Operation.UnaryOperation(cos,{"cos("+$0+")"}),
        "sin": Operation.UnaryOperation(sin,{"sin("+$0+")"}),
        "✖️": Operation.BinaryOperation({$0 * $1}, { $0+"×"+$1},1), // (op1, op2) in return op1 * op2
        "➗": Operation.BinaryOperation({$0 / $1}, { $0+"/"+$1},1),
        "➖": Operation.BinaryOperation({$0 - $1}, { $0+"-"+$1},0),
        "➕": Operation.BinaryOperation({$0 + $1}, { $0+"+"+$1},0),
        "=": Operation.Equals,
        "C": Operation.Clear
    ]
    //enum can't have inheritance
    //pass by value
    private enum Operation {
        case Constant(Double)
        case UnaryOperation( (Double) -> Double, (String)->String )
        case BinaryOperation( (Double, Double) -> Double, (String,String)->String, Int)
        case Equals
        case Clear
        
    }
    var isPartialResult: Bool {
        get{
            return pending != nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function, let descFunction):
                accumulator = function(accumulator)
                if descAccumulator != " " {
                    descAccumulator = descFunction(descAccumulator)
                }
            case .BinaryOperation(let function, let descFunction, let priority):
                executePendingBinaryOperation()
                if currentPriority != nil {
                    if priority > currentPriority! {
                        descAccumulator = "("+descAccumulator+")"
                    }
                }
                currentPriority = priority
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descFunction: descFunction, descOperand: descAccumulator)
            case .Equals:
                executePendingBinaryOperation()
                currentPriority = nil
            case .Clear:
                clearAll()
            }
        }
    }
    private func clearAll(){
        descAccumulator = " "
        pending = nil
        internalProgram.removeAll()
        variablesName.removeAll()
        accumulator = 0.0
        currentPriority = nil
        
    }
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descAccumulator = pending!.descFunction(pending!.descOperand, descAccumulator)
            pending = nil
            
        }
    }
    
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descFunction: (String, String) -> String
        var descOperand: String
    }
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var formatter: NumberFormatter{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.groupingSeparator = " "
        return formatter
    }
}
