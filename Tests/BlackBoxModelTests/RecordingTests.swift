import XCTest
@testable import Meteo
@testable import BlackBoxModel

class RecordingTests: XCTestCase {

    func testRecordingInitialization() {
        // Create a sample date for the start date of the recording
        let startDate = Date(timeIntervalSinceReferenceDate: 0)

        // Create a sample insolation data
     //   let irradiance = Insolation()

        // Initialize the recording instance
    //    let recording = Recording(startDate: startDate, irradiance: irradiance)

        // Assert that the performance, irradiance, performanceHistory, and statusHistory are initialized
    //    XCTAssertNotNil(recording.performance)
    //    XCTAssertNotNil(recording.irradiance)
        //XCTAssertEqual(recording.performanceHistory, [])
        //XCTAssertEqual(recording.statusHistory, [])
    }
    func testSolarFieldHeader() {
    // Create a sample date for the start date of the recording
    let startDate = Date(timeIntervalSinceReferenceDate: 0)

    // Create a sample insolation data
  //  let irradiance = Insolation()

    // Initialize the recording instance
  //  var recording = Recording(startDate: startDate, irradiance: irradiance)

    // Modify the solar field header data for testing
 //   let solarFieldHeaderData: [[Double]] = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]]
 //   recording.performance.solarField.header.values = solarFieldHeaderData

    // Get the solar field header data using the accessor function
 //   let (mass, inletOutlet) = recording.solarFieldHeader(range: .init(start: startDate, end: startDate.addingTimeInterval(3600)))

    // Assert that the data matches the modified solar field header data
 //   XCTAssertEqual(mass, [1.0])
 //   XCTAssertEqual(inletOutlet, [[4.0, 7.0], [5.0, 8.0], [6.0, 9.0]])
}
func testPerformanceSubscript() {
    // Create a sample date for the start date of the recording
    let startDate = Date(timeIntervalSinceReferenceDate: 0)

    // Create a sample insolation data
    //let irradiance = Insolation()

    // Initialize the recording instance
    //var recording = Recording(startDate: startDate, irradiance: irradiance)

    // Modify the performance history for testing
   // let performanceHistoryData: [PlantPerformance] = [
  //      PlantPerformance(thermal: ThermalEnergy(solar: 100.0, production: 90.0, toStorage: 10.0, storage: 20.0),
   //                      electric: ElectricPower(steamTurbineGross: 80.0, net: 70.0, consum: 60.0)),
   //     PlantPerformance(thermal: ThermalEnergy(solar: 200.0, production: 180.0, toStorage: 20.0, storage: 40.0),
   //                      electric: ElectricPower(steamTurbineGross: 160.0, net: 140.0, consum: 120.0))
   // ]
  //  recording.performanceHistory = performanceHistoryData
//
    // Get the thermal and electric power data using the subscript accessor
    //let thermalPowerData = recording[\.thermal.solar, \.thermal.production, range: .init(start: startDate, end: startDate.addingTimeInterval(3600))]
    //let electricPowerData = recording[\.electric.steamTurbineGross, \.electric.net, \.electric.consum, range: .init(start: startDate, end: startDate.addingTimeInterval(3600))]

    // Assert that the data matches the modified performance history data
  //  XCTAssertEqual(thermalPowerData, [[100.0], [200.0]])
  //  XCTAssertEqual(electricPowerData, [[80.0, 70.0, 60.0], [160.0, 140.0, 120.0]])
}


}
