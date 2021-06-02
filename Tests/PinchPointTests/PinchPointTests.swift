import XCTest

@testable import PinchPoint
import PhysicalQuantities

class PinchPointTests: XCTestCase {
  func testsCalculation() {
    let tol = 0.1

    var pp1 = Calculation(parameter: .case1)
    pp1()

    XCTAssertLessThan(pp1.mixHTFTemperature, pp1.upperHTFTemperature)
    XCTAssertLessThan(pp1.mixHTFTemperature, pp1.economizer.temperature.htf.outlet)
    XCTAssertGreaterThan(pp1.mixHTFTemperature, pp1.reheater.temperature.htf.outlet)

    XCTAssertEqual(pp1.mixHTFTemperature.celsius, 295.3, accuracy: tol)
    XCTAssertEqual(pp1.mixHTFMassflow, 629.3, accuracy: tol)
    XCTAssertEqual(pp1.powerBlockPower, 150.2, accuracy: tol)

    XCTAssertEqual(
      pp1.economizer.pressure.ws.outlet,
      pp1.economizer.pressure.ws.inlet - pp1.parameter.pressureDrop.economizer,
      accuracy: tol
    )

    XCTAssertEqual(
      pp1.steamGenerator.pressure.ws.outlet,
      pp1.steamGenerator.pressure.ws.inlet - pp1.parameter.pressureDrop.steamGenerator,
      accuracy: tol
    )

    XCTAssertEqual(
      pp1.superheater.pressure.ws.outlet,
      pp1.superheater.pressure.ws.inlet - pp1.parameter.pressureDrop.superHeater,
      accuracy: tol
    )

    XCTAssertEqual(
      pp1.reheater.pressure.ws.outlet,
      pp1.reheatOutletSteamPressure,
      accuracy: tol
    )

    XCTAssertLessThan(pp1.reheater.enthalpy.ws.inlet, pp1.reheater.enthalpy.ws.outlet)
    XCTAssertGreaterThan(pp1.reheater.enthalpy.htf.inlet, pp1.reheater.enthalpy.htf.outlet)
    XCTAssertLessThan(pp1.economizer.enthalpy.ws.inlet, pp1.economizer.enthalpy.ws.outlet)
    XCTAssertGreaterThan(pp1.economizer.enthalpy.htf.inlet, pp1.economizer.enthalpy.htf.outlet)
    XCTAssertLessThan(pp1.steamGenerator.enthalpy.ws.inlet, pp1.steamGenerator.enthalpy.ws.outlet)
    XCTAssertGreaterThan(pp1.steamGenerator.enthalpy.htf.inlet, pp1.steamGenerator.enthalpy.htf.outlet)
    XCTAssertLessThan(pp1.superheater.enthalpy.ws.inlet, pp1.superheater.enthalpy.ws.outlet)
    XCTAssertGreaterThan(pp1.superheater.enthalpy.htf.inlet, pp1.superheater.enthalpy.htf.outlet)
  }
}

