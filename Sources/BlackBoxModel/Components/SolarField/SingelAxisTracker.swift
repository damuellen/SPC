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

/// A function for single-axis trackers
///
/// Determine the rotation angle of a single axis tracker using the
/// equations in [1] when given a particular sun zenith and azimuth
/// angle. backtracking may be specified, and if so, a ground coverage
/// ratio is required.
///
/// Rotation angle is determined in a panel-oriented coordinate system.
/// The tracker azimuth axis_azimuth defines the positive y-axis; the
/// positive x-axis is 90 degress clockwise from the y-axis and parallel
/// to the earth surface, and the positive z-axis is normal and oriented
/// towards the sun. Rotation angle trackerTheta indicates tracker
/// position relative to horizontal: trackerTheta = 0 is horizontal,
/// and positive trackerTheta is a clockwise rotation around the y axis
/// in the x, y, z coordinate system. For example, if tracker azimuth
/// axis_azimuth is 180 (oriented south), trackerTheta = 30 is a
/// rotation of 30 degrees towards the west, and trackerTheta = -90 is
/// a rotation to the vertical plane facing east.
///
/// - Parameters:
/// - apparentZenith:
/// Solar apparent zenith angles in decimal degrees.
///
/// - apparentAzimuth:
/// Solar apparent azimuth angles in decimal degrees.
///
/// - axisTilt:
/// The tilt of the axis of rotation (i.e, the y-axis defined by
/// axisAzimuth) with respect to horizontal, in decimal degrees.
///
/// - axisAzimuth:
/// A value denoting the compass direction along which the axis of
/// rotation lies. Measured in decimal degrees East of North.
///
/// - maxAngle:
/// A value denoting the maximum rotation angle, in decimal degrees,
/// of the one-axis tracker from its horizontal position (horizontal
/// if axisTilt = 0). A max_angle of 90 degrees allows the tracker
/// to rotate to a vertical position to point the panel towards a
/// horizon. max_angle of 180 degrees allows for full rotation.
///
/// - GCR:
/// A value denoting the ground coverage ratio of a tracker system
/// which utilizes backtracking; i.e. the ratio between the PV array
/// surface area to total ground area. A tracker system with modules
/// 2 meters wide, centered on the tracking axis, with 6 meters
/// between the tracking axes has a gcr of 2/6=0.333. if gcr is not
/// provided, a gcr of 2/7 is default. gcr must be <=1.
///
/// - shouldBacktrack:
/// Controls whether the tracker has the capability to "backtrack"
/// to avoid row-to-row shading. False denotes no backtrack
/// capability. True denotes backtrack capability.
///
/// - Returns:
/// The rotation angle of the tracker.
/// trackerTheta = 0 is horizontal, and positive rotation angles are
/// clockwise.
/// The angle-of-incidence of direct irradiance onto the
/// rotated panel surface.
/// The angle between the panel surface and the earth
/// surface, accounting for panel rotation.
/// The azimuth of the rotated panel, determined by
/// projecting the vector normal to the panel's surface to the earth's
/// surface.
///
/// References
/// ----------
/// [1] Lorenzo, E et al., 2011, "Tracking and back-tracking", Prog. in
/// Photovoltaics: Research and Applications, v. 19, pp. 747-753.
func singleAxisTracker(
  apparentZenith: Double, apparentAzimuth: Double, latitude: Double = 0,
  axisTilt: Double = 0, axisAzimuth: Double = 180, maxAngle: Double,
  GCR: Double, shouldBacktrack: Bool = true
) -> (trackerTheta: Double, AOI: Double, surfTilt: Double, surfAz: Double) {
  let azimuth = apparentAzimuth - 180
  let elev = 90 - apparentZenith
  var x = cosd(elev) * sind(azimuth)
  var y = cosd(elev) * cosd(azimuth)
  var z = sind(elev)

  // translate array azimuth from compass bearing to [1] coord system
  var axisAz: Double
  axisAz = axisAzimuth - 180

  // translate input array tilt angle axistilt to [1] coordinate system.  In
  // [1] coordinates, axistilt is a rotation about the x-axis.  For a system
  // with array azimuth (y-axis) oriented south, the x-axis is oriented west,
  // and a positive axistilt is a counterclockwise rotation, i.e, lifting the
  // north edge of the panel. Thus, in [1] coordinate system, in the northern
  // hemisphere a positive axistilt indicates a rotation toward the equator,
  // whereas in the southern hemisphere rotation toward the equator is
  // indicated by axistilt<0. Here, the input axistilt is always positive and
  // is a rotation toward the equator.

  // Calculate sun position (xp, yp, zp) in panel-oriented coordinate system:
  // positive y-axis is oriented along tracking axis at panel tilt
  // positive x-axis is orthogonal, clockwise, parallel to earth surface
  // positive z-axis is normal to x-y axes, pointed upward.
  // Calculate sun position (xp,yp,zp) in panel coordinates using [1] Eq 11
  let xp = x * cosd(axisAz) - y * sind(axisAz)
  let yp =
    x * cosd(axisTilt) * sind(axisAz) + y * cosd(axisTilt) * cosd(axisAz) - z
    * sind(axisTilt)
  // note that equation for yp (y// in Eq. 11 of Lorenzo et al 2011) is
  // corrected, after conversation with paper's authors
  let zp =
    x * sind(axisTilt) * sind(axisAz) + y * sind(axisTilt) * cosd(axisAz) + z
    * cosd(axisTilt)

  // The ideal tracking angle wid is the rotation to place the sun position
  // vector (xp, yp, zp) in the (y, z) plane i.e., normal to the panel and
  // containing the axis of rotation.  wid = 0 indicates that the panel is
  // horizontal.  Here, our convention is that a clockwise rotation is
  // positive, to view rotation angles in the same frame of reference as
  // azimuth.  For example, for a system with tracking axis oriented south,
  // a rotation toward the east is negative, and a rotation to the west is
  // positive.
  var tmp: Double
  if xp == 0 {
    tmp = zp >= 0 ? 90 : -90
  } else {
    tmp = atand(zp / xp)  // angle from x-y plane to projection of sun vector onto x-z plane
  }

  // Obtain wid by translating tmp to convention for rotation angles.
  // Have to account for which quadrant of the x-z plane in which the sun
  // vector lies. Complete solution here but probably not necessary to
  // consider QIII and QIV.
  var wid = tmp
  if xp >= 0 && zp >= 0 { wid = 90 - tmp }  // QI
  if xp < 0 && zp >= 0 { wid = -90 - tmp }  // QII
  if xp < 0 && zp < 0 { wid = -90 - tmp }  // QIII
  if xp >= 0 && zp < 0 { wid = 90 - tmp }  // QIV

  // apply limits to ideal rotation angle
  if zp < 0 { wid = 0 }  // set horizontal if zenith<0, sun is below panel horizon

  // Account for backtracking modified from [1] to account for rotation
  // angle convention being used here.
  var temp: Double
  var wc: Double
  var widc = wid
  if shouldBacktrack {
    let Lew = 1 / GCR
    temp = min(Lew * cosd(wid), 1)
    // backtrack angle always positive (acosd returns values between 0 and 180)
    wc = acos(temp).toDegrees
    if wid < 0 {  // Eq 4 applied when wid in QIV
      widc = wid + wc
    }
    if wid > 0 {  // Eq 4 applied when wid in QI
      widc = wid - wc
    }
  } else {
    widc = wid
  }

  var trackerTheta = widc

  if zp < 0 { trackerTheta = 0 }  // set to zero when sun is below panel horizon

  if trackerTheta > maxAngle { trackerTheta = maxAngle }
  if trackerTheta < -maxAngle { trackerTheta = -maxAngle }

  // calculate normal vector to panel in panel-oriented x, y, z coordinates
  // y-axis is axis of tracker rotation. `trackerTheta` is a compass angle
  // (clockwise is positive) rather than a trigonometric angle.
  x = sind(trackerTheta)
  y = 0
  z = cosd(trackerTheta)

  // sun position in vector format in panel-oriented x, y, z coordinates

  // calculate angle-of-incidence on panel
  var AOI = acos(abs(x * xp + y * yp + z * zp)).toDegrees
  if AOI == 90 { AOI = 0.0 }
  if AOI < 0 { AOI = 0.0 }  // set to zero when sun is below panel horizon

  // calculate panel elevation and azimuth in a coordinate system where the
  // panel elevation is the angle from horizontal, and the panel azimuth is
  // the compass angle (clockwise from north) to the projection of the panel's
  // normal to the earth's surface.  These outputs are provided for
  // convenience and comparison with other PV software which use these angle
  // conventions.

  // project normal vector to earth surface.  First rotate
  // about x-axis by angle -AxisTilt so that y-axis is also parallel to earth
  // surface, then project.
  let rotation_angle = -axisTilt
  let temp_x = x
  let temp_y = y * cosd(rotation_angle) - z * sind(rotation_angle)
  let temp_z = y * sind(rotation_angle) + z * cosd(rotation_angle)

  let proj_x = temp_x
  let proj_y = temp_y
  let proj_z = 0.0

  func module(_ x: Double, _ y: Double, _ z: Double) -> Double {
    sqrt(x * x + y * y + z * z)
  }

  let tempNorm = module(temp_x, temp_y, temp_z)
  let projNorm = module(proj_x, proj_y, proj_z)

  var surfAz: Double

  if proj_x == 0 && proj_y > 0 {
    surfAz = 90
  } else if proj_x == 0 && proj_y < 0 {
    surfAz = -90
  } else if proj_y == 0 && proj_x > 0 {
    surfAz = 0
  } else if proj_y == 0 && proj_x < 0 {
    surfAz = 180
  } else {
    surfAz = atan2(proj_y, proj_x)
  }

  // at this point surfAz contains angles between -90 and +270, where 0 is
  // along the positive x-axis, the y-axis is in the direction of the tracker
  // azimuth, and positive angles are rotations from the positive x axis towards
  // the positive y-axis.
  // Adjust to compass angles (clockwise rotation from 0 along the positive y-axis)
  if surfAz <= 90 { surfAz = 90 - surfAz }
  if surfAz > 90 { surfAz = 450 - surfAz }

  // finally rotate to align y-axis with true north
  if latitude > 0 {
    surfAz = surfAz - axisAzimuth
  } else {
    surfAz = surfAz - axisAzimuth - 180
  }
  if surfAz < 0 { surfAz += 360 }

  let divisor = (tempNorm * projNorm * 10000).rounded() / 10000
  let dividend =
    ((temp_x * proj_x + temp_y * proj_y + temp_z * proj_z) * 10000).rounded()
    / 10000
  let surfTilt: Double
  if surfAz == .nan || divisor == 0 {
    surfTilt = 0
  } else {
    surfTilt = 90 - acos(dividend / divisor).toDegrees
  }
  return (trackerTheta, AOI, surfTilt, surfAz)
}

private func cosd(_ angle: Angle) -> Double { cos(angle.toRadians) }
private func sind(_ angle: Angle) -> Double { sin(angle.toRadians) }
private func asind(_ angle: Angle) -> Double { asin(angle.toRadians) }
private func tand(_ angle: Angle) -> Double { tan(angle.toRadians) }
private func atand(_ angle: Angle) -> Double { atan(angle).toDegrees }
