
@_functionBuilder
public struct TupleBuilder {
 /*   public static func buildBlock<T1>(_ t1: T1...) -> T1 {
    return t1.randomElement()!
  }*/

  public static func buildBlock<T1>(_ t1: T1) -> (T1) {
    //  print(t1)
    return (t1)
  }

  public static func buildBlock<T1, T2>(_ t1: T1, _ t2: T2) -> (T1, T2) {
   //   print(t1,t2)
    return (t1, t2)
  }

  public static func buildBlock<T1>(_ t1: T1, _ t2: T1) -> [T1] {

    return [t1, t2]
  }
  
  public static func buildBlock<T1, T2, T3>(_ t1: T1, _ t2: T2, _ t3: T3)
      -> (T1, T2, T3) {
    return (t1, t2, t3)
  }

  public static func buildBlock<T1, T2, T3, T4>(_ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4)
      -> (T1, T2, T3, T4) {
    return (t1, t2, t3, t4)
  }

  public static func buildBlock<T1, T2, T3, T4, T5>(
    _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4, _ t5: T5
  ) -> (T1, T2, T3, T4, T5) {
    return (t1, t2, t3, t4, t5)
  }
}

public func solarfield<T>(@TupleBuilder body: () throws -> T) rethrows {
  //print(try body())
}

public func loops<T>(lhs: T, rhs: T) {

}

extension SolarField {
    public convenience init<T>(massFlow: Double, @TupleBuilder body: () -> (T)) {
        self.init()
       self.connectors = body() as! [Connector]
    }
}


public func loops<T>(lhs: Int, rhs: Int, @TupleBuilder body: () throws -> T) rethrows {
  //print(try body())
}

public func subfield<T>(_ name: String, @TupleBuilder body: () throws -> T) rethrows -> T {
  return try body()
}
/*
public func header<T>(_ name: String, @TupleBuilder body: () throws -> T) rethrows -> Connector  {
    print(try body())
  return Connector()
}*/