//
//  Copyright 2021 Daniel Müllenborn
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
import Libc
import PhysicalQuantities

/// The PV_System struct wraps the functions of the pv system components.
///
/// This simplifies the API by eliminating the need for a user to specify
/// arguments such as module and inverter properties.
public struct PV_System {
  var array = PV_Array()
  var inverter = Inverter()
  var transformer = Transformer()
}