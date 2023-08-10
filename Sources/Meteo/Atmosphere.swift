// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

import Libc
import Utilities

/// The Atmosphere enum contains public static methods to calculate relative and
/// absolute airmass and to determine pressure from altitude or vice versa.
public enum Atmosphere {
  /**
   Determine altitude from site pressure.

   - Parameter pressure: Atmospheric pressure (Pascals)

   - Returns: Altitude in meters above sea level

   Note:
   -----
   The following assumptions are made

   - Base pressure                  101325 Pa
   - Temperature at zero altitude   288.15 K
   - Gravitational acceleration     9.80665 m/s^2
   - Lapse rate                     -6.5E-3 K/m
   - Gas constant for air           287.053 J/(kgK)
   - Relative Humidity              0%

   References:
   -----------
   [1] "A Quick Derivation relating altitude to air pressure" from
   Portland State Aerospace Society, Version 1.03, 12/22/2004.
   */
  public static func altitude(pressure: Double) -> Double {
    return 44331.5 - 4946.62 * pow(pressure, 0.190263)
  }

  /**
   Determine site pressure from altitude.

   - Parameter altitude: Altitude in meters above sea level

   - Returns: Atmospheric pressure (Pascals)

   Note:
   -----
   The following assumptions are made

   - Base pressure                  101325 Pa
   - Temperature at zero altitude   288.15 K
   - Gravitational acceleration     9.80665 m/s^2
   - Lapse rate                     -6.5E-3 K/m
   - Gas constant for air           287.053 J/(kgK)
   - Relative Humidity              0%

   References:
   -----------
   [1] "A Quick Derivation relating altitude to air pressure" from
   Portland State Aerospace Society, Version 1.03, 12/22/2004.
   */
  public static func pressure(altitude: Double) -> Double {
    return 100 * pow(((44331.514 - altitude) / 11880.516), (1.0 / 0.1902632))
  }

  /**
   Determine absolute (pressure corrected) airmass from relative
   airmass and pressure

   Gives the airmass for locations not at sea-level (i.e. not at
   standard pressure). The input argument "AMrelative" is the relative
   airmass. The input argument "pressure" is the pressure (in Pascals)
   at the location of interest and must be greater than 0. The
   calculation for absolute airmass is

   `absolute airmass = (relative airmass)*pressure/101325`

   - Parameter airmassRelative: The airmass at sea-level.
   - Parameter pressure: The site pressure in Pascal. default 101325

   - Returns: Absolute (pressure corrected) airmass

   References:
   -----------
   [1] C. Gueymard, "Critical analysis and performance assessment of
   clear sky solar irradiance models using theoretical and measured
   data," Solar Energy, vol. 51, pp. 121-138, 1993.
   */
  public static func absoluteAirMass(
    airmassRelative: Double, pressure: Double = 101_325.0
  ) -> Double {
    let airmassAbsolute = airmassRelative * pressure / 101_325.0
    return airmassAbsolute
  }

  public enum Model: String {
    case kastenyoung1989
    case kasten1966
    case simple
    case pickering2002
    case youngirvine1967
    case young1994
    case gueymard1993
  }

  /**
   Gives the relative (not pressure-corrected) airmass.

   Gives the airmass at sea-level when given a sun zenith angle (in
   degrees). The `model` variable allows selection of different
   airmass models (described below). If `model` is not included or is
   not valid, the default model is 'kastenyoung1989'.

   - Parameter zenith:
   Zenith angle of the sun in degrees. Note that some models use
   the apparent (refraction corrected) zenith angle, and some
   models use the true (not refraction-corrected) zenith angle. See
   model descriptions to determine which type of zenith angle is
   required. Apparent zenith angles must be calculated at sea level.

   - Parameter model: default kastenyoung1989
   Available models include the following:

   * simple - secant(apparent zenith angle) -
   Note that this gives -inf at zenith=90
   * kasten1966 - See reference [1] -
   requires apparent sun zenith
   * youngirvine1967 - See reference [2] -
   requires true sun zenith
   * kastenyoung1989 - See reference [3] -
   requires apparent sun zenith
   * gueymard1993 - See reference [4] -
   requires apparent sun zenith
   * young1994 - See reference [5] -
   requries true sun zenith
   * pickering2002 - See reference [6] -
   requires apparent sun zenith

   - Returns: Relative airmass at sea level. Will return NaN values for any
   zenith angle greater than 90 degrees.

   References:
   -----------
   [1] Fritz Kasten. "A New Table and Approximation Formula for the
   Relative Optical Air Mass". Technical Report 136, Hanover, N.H.:
   U.S. Army Material Command, CRREL.

   [2] A. T. Young and W. M. Irvine, "Multicolor Photoelectric
   Photometry of the Brighter Planets," The Astronomical Journal, vol.
   72, pp. 945-950, 1967.

   [3] Fritz Kasten and Andrew Young. "Revised optical air mass tables
   and approximation formula". Applied Optics 28:4735-4738

   [4] C. Gueymard, "Critical analysis and performance assessment of
   clear sky solar irradiance models using theoretical and measured
   data," Solar Energy, vol. 51, pp. 121-138, 1993.

   [5] A. T. Young, "AIR-MASS AND REFRACTION," Applied Optics, vol. 33,
   pp. 1108-1110, Feb 1994.

   [6] Keith A. Pickering. "The Ancient Star Catalog". DIO 12:1, 20,

   [7] Matthew J. Reno, Clifford W. Hansen and Joshua S. Stein, "Global
   Horizontal Irradiance Clear Sky Models: Implementation and Analysis"
   Sandia Report, (2012).
   */
  public static func relativeAirMass(
    zenith: Double, model: Model = .kastenyoung1989
  ) -> Double {
    let z = zenith > 90 ? .nan : zenith
    let zenith_rad = z.toRadians

    let am: Double
    switch model {
    case .kastenyoung1989:
      am =
        (1.0
          / (cos(zenith_rad) + 0.50572 * (((6.07995 + (90 - z)) ** -1.6364))))
    case .kasten1966:
      am = 1.0 / (cos(zenith_rad) + 0.15 * ((93.885 - z) ** -1.253))
    case .simple: am = 1.0 / cos(zenith_rad)
    case .pickering2002:
      am =
        (1.0
          / (sin((90 - z + 244.0 / (165 + 47.0 * (90 - z) ** 1.1)).toRadians)))
    case .youngirvine1967:
      am =
        ((1.0 / cos(zenith_rad))
          * (1 - 0.0012 * ((1.0 / cos(zenith_rad)) ** 2) - 1))
    case .young1994:
      am =
        ((1.002432 * ((cos(zenith_rad)) ** 2) + 0.148386 * (cos(zenith_rad))
          + 0.0096467)
          / (cos(zenith_rad) ** 3 + 0.149864 * (cos(zenith_rad) ** 2)
            + 0.0102963 * (cos(zenith_rad)) + 0.000303978))
    case .gueymard1993:
      am =
        (1.0
          / (cos(zenith_rad) + 0.00176759 * z * ((94.37515 - z) ** -1.21563)))
    }
    return am
  }

  /**
   Calculates precipitable water (cm) from ambient air temperature (C)
   and relatively humidity (%) using an empirical model. The
   accuracy of this method is approximately 20% for moderate PW (1-3
   cm) and less accurate otherwise.

   The model was developed by expanding Eq. 1 in [2]_:

   `w = 0.1 H_v \rho_v`

   using Eq. 2 in [2]_

   `rho_v = 216.7 R_H e_s /T`

   `H_v` is the apparant water vapor scale height (km). The
   expression for :math:`H_v` is Eq. 4 in [2]_:

   H_v = 0.4976 + 1.5265*T/273.15 + \exp(13.6897*T/273.15 - 14.9188*(T/273.15)^3)

   `rho_v` is the surface water vapor density (g/m^3). In the
   expression :math:`\rho_v`, :math:`e_s` is the saturation water vapor
   pressure (millibar). The
   expression for :math:`e_s` is Eq. 1 in [3]_

   `e_s = \exp(22.330 - 49.140*(100/T) - 10.922*(100/T)^2 - 0.39015*T/100)`

   - Parameter tempAir: ambient air temperature at the surface (C)
   - Parameter relativeHumidity: relative humidity at the surface (%)

   - Returns: precipitable water (cm)

   References:
   -----------
   .. [1] W. M. Keogh and A. W. Blakers, Accurate Measurement, Using Natural
   Sunlight, of Silicon Solar Cells, Prog. in Photovoltaics: Res.
   and Appl. 2004, vol 12, pp. 1-19 (:doi:`10.1002/pip.517`)

   .. [2] C. Gueymard, Analysis of Monthly Average Atmospheric Precipitable
   Water and Turbidity in Canada and Northern United States,
   Solar Energy vol 53(1), pp. 57-71, 1994.

   .. [3] C. Gueymard, Assessment of the Accuracy and Computing Speed of
   simplified saturation vapor equations using a new reference
   dataset, J. of Applied Meteorology 1993, vol. 32(7), pp.
   1294-1300.
   */
  public static func gueymard94_pw(tempAir: Double, relativeHumidity: Double)
    -> Double
  {
    let T = tempAir + 273.15  // Convert to Kelvin
    let RH = relativeHumidity

    let theta = T / 273.15

    // Eq. 1 from Keogh and Blakers
    var pw =
      (0.1
        * (0.4976 + 1.5265 * theta
          + exp(13.6897 * theta - 14.9188 * theta ** 3))
        * (216.7 * RH / (100 * T)
          * exp(
            22.330 - 49.140 * (100 / T) - 10.922 * (100 / T) ** 2 - 0.39015 * T
              / 100)))

    pw = max(pw, 0.1)

    return pw
  }

  public enum ModuleType {
    case none(coefficients: [Double])
    case cdte
    case monosi, xsi
    case multisi, polysi
    case cigs
    case asi
  }

  /**
   Spectral mismatch modifier based on precipitable water and absolute
   (pressure corrected) airmass.

   Estimates a spectral mismatch modifier M representing the effect on
   module short circuit current of variation in the spectral
   irradiance. M is estimated from absolute (pressure currected) air
   mass, AMa, and precipitable water, Pwat, using the following
   function:

   `M = c_1 + c_2*AMa + c_3*Pwat + c_4*AMa^.5 + c_5*Pwat^.5 + c_6*AMa/Pwat^.5`

   Default coefficients are determined for several cell types with
   known quantum efficiency curves, by using the Simple Model of the
   Atmospheric Radiative Transfer of Sunshine (SMARTS) [1]_. Using
   SMARTS, spectrums are simulated with all combinations of AMa and
   Pwat where:

   * 0.5 cm <= Pwat <= 5 cm
   * 1.0 <= AMa <= 5.0
   * Spectral range is limited to that of CMP11 (280 nm to 2800 nm)
   * spectrum simulated on a plane normal to the sun
   * All other parameters fixed at G173 standard

   From these simulated spectra, M is calculated using the known
   quantum efficiency curves. Multiple linear regression is then
   applied to fit Eq. 1 to determine the coefficients for each module.

   Based on the PVLIB Matlab function `pvl_FSspeccorr` by Mitchell
   Lee and Alex Panchula, at First Solar, 2016 [2]_.

   - Parameter pw:
   atmospheric precipitable water (cm).

   - Parameter airmassAbsolute:
   absolute (pressure corrected) airmass.

   - Parameter moduleType:
   a enum case specifying a cell type.

   * cdte' - First Solar Series 4-2 CdTe modules.
   * monosi, xsi - First Solar TetraSun modules.
   * multisi, polysi - multi-crystalline silicon modules.
   * cigs - anonymous copper indium gallium selenide PV module
   * asi - anonymous amorphous silicon PV module

   The module used to calculate the spectral correction
   coefficients corresponds to the Mult-crystalline silicon
   Manufacturer 2 Model C from [3]_. Spectral Response (SR) of CIGS
   and a-Si modules used to derive coefficients can be found in [4]_

   - Parameter coefficients:
   allows for entry of user funcined spectral correction
   coefficients. Coefficients must be of length 6. Derivation of
   coefficients requires use of SMARTS and PV module quantum
   efficiency curve. Useful for modeling PV module types which are
   not included as defaults, or to fine tune the spectral
   correction to a particular mono-Si, multi-Si, or CdTe PV module.
   Note that the parameters for modules with very similar QE should
   be similar, in most cases limiting the need for module specific
   coefficients.

   - Returns: spectral mismatch factor (unitless) which is can be multiplied
   with broadband irradiance reaching a module's cells to estimate
   effective irradiance, i.e., the irradiance that is converted to
   electrical current.

   References:
   -----------
   .. [1] Gueymard, Christian. SMARTS2: a simple model of the atmospheric
   radiative transfer of sunshine: algorithms and performance
   assessment. Cocoa, FL: Florida Solar Energy Center, 1995.
   .. [2] Lee, Mitchell, and Panchula, Alex. "Spectral Correction for
   Photovoltaic Module Performance Based on Air Mass and Precipitable
   Water." IEEE Photovoltaic Specialists Conference, Portland, 2016
   .. [3] Marion, William F., et al. User's Manual for Data for Validating
   Models for PV Module Performance. National Renewable Energy
   Laboratory, 2014. http://www.nrel.gov/docs/fy14osti/61610.pdf
   .. [4] Schweiger, M. and Hermann, W, Influence of Spectral Effects
   on Energy Yield of Different PV Modules: Comparison of Pwat and
   MMF Approach, TUV Rheinland Energy GmbH report 21237296.003,
   January 2017
   */
  public static func firstSolarSpectralCorrection(
    pw: Double, airmassAbsolute: Double, moduleType: ModuleType
  ) -> Double {
    // --- Screen Input Data ---

    // *** Pwat ***
    // Replace Pwat Values below 0.1 cm with 0.1 cm to prevent model from
    // diverging"

    if pw < 0.1 {
      print(
        "Exceptionally low Pwat values replaced with 0.1 cm to prevent"
          + " model divergence")
    }
    let pw = max(pw, 0.1)
    // Warn user about Pwat data that is exceptionally high
    if pw > 8 {
      print(
        "Exceptionally high Pwat values. Check input data:"
          + " model may diverge in this range")
    }
    // *** AMa ***
    // Replace Extremely High AM with AM 10 to prevent model divergence
    // AM > 10 will only occur very close to sunset
    let airmassAbsolute = min(airmassAbsolute, 10.0)
    // Warn user about AMa data that is exceptionally low
    if airmassAbsolute < 0.58 {
      print(
        "Exceptionally low air mass:"
          + " model not intended for extra-terrestrial use")
    }
    // pvl_absoluteairmass(1,pvl_alt2pres(4340)) = 0.58 Elevation of
    // Mina Pirquita, Argentian = 4340 m. Highest elevation city with
    // population over 50,000.

    let coeff: [Double]
    switch moduleType {
    case .asi:
      coeff = [1.12094, -0.047620, -0.0083627, -0.10443, 0.098382, -0.0033818]
    case .cdte:
      coeff = [0.86273, -0.038948, -0.012506, 0.098871, 0.084658, -0.0042948]
    case .monosi, .xsi:
      coeff = [0.85914, -0.020880, -0.0058853, 0.12029, 0.026814, -0.0017810]
    case .polysi, .multisi:
      coeff = [0.84090, -0.027539, -0.0079224, 0.13570, 0.038024, -0.0021218]
    case .cigs:
      coeff = [0.85252, -0.022314, -0.0047216, 0.13666, 0.013342, -0.0008945]
    case let .none(coefficients):
      precondition(coefficients.count == 6)
      coeff = coefficients
    }

    // Evaluate Spectral Shift
    let ama = airmassAbsolute
    var modifier = coeff[0]
    modifier += coeff[1] * ama
    modifier += coeff[2] * pw
    modifier += coeff[3] * sqrt(ama)
    modifier += coeff[4] * sqrt(pw)
    modifier += coeff[5] * ama / sqrt(pw)
    return modifier
  }

  /**
   Approximate broadband aerosol optical depth.

   Bird and Hulstrom developed a correlation for broadband aerosol optical
   depth (AOD) using two wavelengths, 380 nm and 500 nm.

   - Parameter aod380: AOD measured at 380 nm
   - Parameter aod500: AOD measured at 500 nm

   - Returns: broadband AOD

   - SeeAlso: kasten96_lt

   References:
   -----------
   [1] Bird and Hulstrom, "Direct Insolation Models" (1980)
   `SERI/TR-335-344 <http://www.nrel.gov/docs/legosti/old/344.pdf>`_

   [2] R. E. Bird and R. L. Hulstrom, "Review, Evaluation, and Improvement of
   Direct Irradiance Models", Journal of Solar Energy Engineering 103(3),
   pp. 182-192 (1981)
   :doi:`10.1115/1.3266239`
   */
  public static func birdHulstrom80_aod_bb(aod380: Double, aod500: Double)
    -> Double
  {
    // approximate broadband AOD using (Bird-Hulstrom 1980)
    return 0.27583 * aod380 + 0.35 * aod500
  }

  /**
   Calculate Linke turbidity factor using Kasten pyrheliometric formula.

   Note that broadband aerosol optical depth (AOD) can be approximated by AOD
   measured at 700 nm according to Molineaux [4] . Bird and Hulstrom offer an
   alternate approximation using AOD measured at 380 nm and 500 nm.

   Based on original implementation by Armel Oumbe.

   - Warning:
   These calculations are only valid for air mass less than 5 atm and
   precipitable water less than 5 cm.
   - Parameters:
     - airmassAbsolute: airmass, pressure corrected in atmospheres
     - precipitableWater: precipitable water or total column water vapor in centimeters
     - aodBb: broadband AOD

   - Returns: Linke turbidity

   - SeeAlso: bird_hulstrom80_aod_bb
   - SeeAlso: angstrom_aod_at_lambda

   References
   ----------
   [1] F. Linke, "Transmissions-Koeffizient und Trubungsfaktor", Beitrage
   zur Physik der Atmosphare, Vol 10, pp. 91-103 (1922)

   [2] F. Kasten, "A simple parameterization of the pyrheliometric formula for
   determining the Linke turbidity factor", Meteorologische Rundschau 33,
   pp. 124-127 (1980)

   [3] Kasten, "The Linke turbidity factor based on improved values of the
   integral Rayleigh optical thickness", Solar Energy, Vol. 56, No. 3,
   pp. 239-244 (1996)
   :doi:`10.1016/0038-092X(95)00114-7`

   [4] B. Molineaux, P. Ineichen, N. O'Neill, "Equivalence of pyrheliometric
   and monochromatic aerosol optical depths at a single key wavelength",
   Applied Optics Vol. 37, issue 10, 7008-7018 (1998)
   :doi:`10.1364/AO.37.007008`

   [5] P. Ineichen, "Conversion function between the Linke turbidity and the
   atmospheric water vapor and aerosol content", Solar Energy 82,
   pp. 1095-1097 (2008)
   :doi:`10.1016/j.solener.2008.04.010`

   [6] P. Ineichen and R. Perez, "A new airmass independent formulation for
   the Linke Turbidity coefficient", Solar Energy, Vol. 73, no. 3, pp. 151-157
   (2002)
   :doi:`10.1016/S0038-092X(02)00045-2`
   */
  public static func kasten96_lt(
    airmassAbsolute: Double, precipitableWater: Double, aodBb: Double
  ) -> Double {
    // "From numerically integrated spectral simulations done with Modtran
    // (Berk, 1989), Molineaux (1998) obtained for the broadband optical depth
    // of a clean and dry atmospshere (fictitious atmosphere that comprises
    // only the effects of Rayleigh scattering and absorption by the
    // atmosphere gases other than the water vapor) the following expression"
    // - P. Ineichen (2008)
    let delta_cda = -0.101 + 0.235 * airmassAbsolute ** (-0.16)
    // "and the broadband water vapor optical depth where pwat is the
    // integrated precipitable water vapor content of the atmosphere expressed
    // in cm and am the optical air mass. The precision of these fits is
    // better than 1% whencompared with Modtran simulations in the range
    // 1 < am < 5 and 0 < pwat < 5 cm at sea level" - P. Ineichen (2008)
    let delta_w =
      0.112 * airmassAbsolute ** (-0.55) * precipitableWater ** 0.34
    // broadband AOD
    let delta_a = aodBb
    // "Then using the Kasten pyrheliometric formula (1980, 1996), the Linke
    // turbidity at am = 2 can be written. The extension of the Linke turbidity
    // coefficient to other values of air mass was published by Ineichen and
    // Perez (2002)" - P. Ineichen (2008)
    let lt =
      -(9.4 + 0.9 * airmassAbsolute)
      * log(exp(-airmassAbsolute * (delta_cda + delta_w + delta_a)))
      / airmassAbsolute
    // filter out of extrapolated values
    return lt
  }

  /** Get AOD at specified wavelength using Angstrom turbidity model.

   - Parameters:
     - aod0: aerosol optical depth (AOD) measured at known wavelength
     - lambda0: wavelength in nanometers corresponding to `aod0`
     - alpha: Angstrom α exponent corresponding to `aod0`
     - lambda1: desired wavelength in nanometers

   - Returns: AOD at desired wavelength, `lambda1`

   - SeeAlso: angstrom_alpha

   References:
   -----------
   [1] Anders Angstrom, "On the Atmospheric Transmission of Sun Radiation and
   On Dust in the Air", Geografiska Annaler Vol. 11, pp. 156-166 (1929) JSTOR
   :doi:`10.2307/519399`

   [2] Anders Angstrom, "Techniques of Determining the Turbidity of the
   Atmosphere", Tellus 13:2, pp. 214-223 (1961) Taylor & Francis
   :doi:`10.3402/tellusa.v13i2.9493` and Co-Action Publishing
   :doi:`10.1111/j.2153-3490.1961.tb00078.x`
   */
  public static func angstromAodAtLambda(
    aod0: Double, lambda0: Double, alpha: Double, lambda1: Double = 700.0
  ) -> Double { return aod0 * ((lambda1 / lambda0) ** (-alpha)) }

  /** Calculate Angstrom alpha exponent.

   - Parameter aod1: first aerosol optical depth
   - Parameter lambda1: wavelength in nanometers corresponding to `aod1`
   - Parameter aod2: second aerosol optical depth
   - Parameter lambda2: wavelength in nanometers corresponding to `aod2`

   - Returns: Angstrom: α exponent for AOD in `(lambda1, lambda2)`

   - SeeAlso: angstrom_aod_at_lambda
   */
  public static func angstromAlpha(
    aod1: Double, lambda1: Double, aod2: Double, lambda2: Double
  ) -> Double { return -log(aod1 / aod2) / log(lambda1 / lambda2) }
}

/// A type representing an angle.
typealias Angle = Double

extension Angle {
  /// Converts the angle from degrees to radians.
  public var toRadians: Double { self * .pi / 180 }
  /// Converts the angle from radians to degrees.
  public var toDegrees: Double { self * (180 / .pi) }
}
