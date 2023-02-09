# Performance Model of Parabolic Trough Solar Power Plants

## Overview

The performance model, SPM, is a computer program that simulates
the performance of entire solar thermal power plants. Such a tool is
indispensable when the daily, monthly and annual output of a
certain solar power plant configuration is to be estimated, the output
of an existing plant is to be recalculated, or the potential of
improvements is to be assessed. The model accommodates normal
quasi-steady state conditions, daily startup and shutdown operations,
and changing weather conditions during operation. The performance model
was developed on the basis of the experience gained from similar programs
such as SOLERGY and the LUZ model for plants of the SEGS type.
It has been significantly extended to include plant configurations with
combustion turbine combined cycles, thermal energy storage and dry cooling.

## Calculation Method

First, the meteorological record is read and the solar angles are
calculated based on the time, the day of the year and the latitude and
longitude of the site.

Then the energy output of the solar field is calculated, taking the
following into account: radiation, ambient temperature, condition of the
solar field (Mirror and HCE Cleanliness, Availability) , HTF system
(availability), availability of main components, shadowing caused by
other collector rows, cosine losses, end losses of collectors, shadowing
by bellows, reflection losses, dirt and alignment losses, transmissivity
of the glass tube, absorption of the selective layer on the absorber
tube, incident angle effects on the above factors, degradation and, of
course, the thermal losses by radiation, convection and conduction.

The collector model contains the following: net collector surface area,
length, parabola aperture, average distance from focus, optical
efficiency, absorber extension beyond collector, absorber tube outer
radius, inner radius and coating emittance coefficient as a function of
temperature, radius of glass cover tube, bellow shadowing, and optical
efficiency as a function of incident angle (incident angle modifier).

The solar field is specified by the total number of loops, number of
collectors per loop, distance between collectors in a row, distance
between rows, azimuth angle and elevation angle of solar field, heat
losses in piping, maximum wind speed for tracking, nominal HTF flow,
“freeze protection” HTF flow and minimal HTF flow, and parasitic power
as a function of HTF flow.

The Heat Transfer Fluid is characterized through maximum operating
temperature, freeze temperature, specific heat capacity, viscosity,
thermal conductivity and density as a function of temperature. The
maximum operating temperature is one of the key parameters for the
layout of the solar power plants because it dictates the maximum
achievable steam parameters. In the simulating process this maximum
allowable temperature of the HTF is the reason that parts of the solar
field have to be defocused at high insolation.

The thermal losses depend on the temperatures of the absorber tube and
the heat transfer fluid (HTF) as well as the ambient temperature. The
solar field inlet temperature is dependent on the HTF system outlet
temperature (closed circuit), which may be different for different
configurations, operation modes and subsystem loads. The mass flow of
the HTF is limited by the pumps: at the upper limit, the mass flow
cannot be further increased beyond the design point. In cases when the
maximum mass flow is reached and HTF temperature higher than that of the
design temperature, some collectors have to be defocused to prevent the
HTF from overheating. This effect is called dumping. After the solar
field is simulated its outlet temperature and the HTF mass flow through
the solar field are known and are used to calculate the delivered solar
thermal energy.

The solar field goes into startup mode when a minimum specified level of
insolation is reached. In addition to the level of insolation different
conditions namely the availabilities of CCPP and SFI are checked for the
release of startup. The effects of changes of the radiation level in
large solar fields are incorporated in the model, where these loops may
have different temperatures at the inlet and outlet, especially during
transients. During the night, the cooling down of the solar field is
monitored and, if necessary, HTF pumping or antifreeze HTF heating is
simulated.

After simulating the solar field, the solar field outlet temperature and
the HTF mass flow through the solar field are known and are used to
calculate the delivered solar thermal energy. Then the heat exchanger
routine calculates the steam production, thermal losses and the
temperatures of both fluids. Now the contribution of the solar system to
the power block is known.

The HTF inlet and outlet temperatures and the water inlet and steam
outlet temperatures at both the minimum operating point (minimum load)
and the maximum operating point (nominal load) are described in the heat
exchanger files.

The auxiliary consumption calculation of SPM considers all electric
consumers. For an instantaneous auxiliary consumption calculation,
the SPM considers electric consumer components that are in operation
together with their mode of operation. As DNI value varies, so do also
load of SFI and level of operation of each electric consumer. This effect
on auxiliary consumption of each electric consumer will then be
considered by the SPM to calculate an auxiliary consumption.
