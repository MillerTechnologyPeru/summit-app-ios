//
//  Observable.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/20/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public final class Observable<Value: Equatable> {
    
    // MARK: - Properties
    
    public var value: Value {
        
        didSet {
            
            if value != oldValue {
                
                observers.forEach { $0.callback(value, oldValue) }
            }
        }
    }
    
    // MARK: - Private Properties
    
    fileprivate var observers = [Observer<Value>]()
    
    fileprivate var nextID = 1
    
    // MARK: - Initialization
    
    public init(_ value: Value) {
        
        self.value = value
    }
    
    // MARK: - Methods
    
    public func observe(_ observer: (new: Value, old: Value) -> ()) -> Int {
        
        let identifier = nextID
        
        // create notification
        let observer = Observer(identifier: identifier, callback: observer)
        
        // increment ID
        nextID += 1
        
        // add to queue
        observers.append(observer)
        
        return identifier
    }
    
    public func remove(_ observer: Int) -> Bool {
        
        guard let index = observers.index(where: { $0.identifier == observer })
            else { return false }
        
        observers.remove(at: index)
        
        return true
    }
}

public extension Observable where Value: ExpressibleByNilLiteral {
    
    convenience init() { self.init(nil) }
}

private struct Observer<Value> {
    
    let identifier: Int
    
    let callback: (Value, Value) -> ()
    
    init(identifier: Int, callback: (Value, Value) -> ()) {
        
        self.identifier = identifier
        self.callback = callback
    }
}
