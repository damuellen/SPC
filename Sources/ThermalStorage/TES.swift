import Helpers
import Libc
import Physics

struct TES {
  // let salt = StorageMedium.ss
  let htf = VP1
  let min_salt_mass_flow_per_pump__kg_s = 260.0
  let low_salt_mass_flow__kg_s = 420.0
  let min_level_at_low_salt_mass_flow = 0.6
  let max_salt_mass_flow_per_pump__kg_s = 1000.0
  let min_level_at_max_salt_mass_flow = 1.5
  let max_pumps_per_tank = 4
  let p_th_max_per_trainW_th = 130.0
  let maximum_train_quant_Per_2_tank_system = 4
  let max_active_tank_height = 15.0
  let max_tank_diameter = 38.5
  let requested_minimum_possible_part_load_charge = 0.2
  let max_turn_down_ratio_per_HEX_train = 0.3
  let tes_design_total_head_at_highest_salt_flow = 63.0
  let tank_height_diameter_ratio_of_active_salt_volume = 0.3506
  let free_Board_Allowance = 0.35
  let pump_suction_clearance__distance_suction_inlet_to_tank_floor = 0.257
  let tank_roof_radius_factor__radius___factor___tank_diameter = 1.5
  let horizontal_distance__pump___tank_wall = 2.5
  let vert_distance_tank_roof_pump_mounting_plate = 2.5
  let vertical_distance_between_HEX_level_and_pump_mount_level = 0.0
  let pressure_drop_piping_and_valves_design_charge_mass_flow = 0.500
  let pressure_drop_hot_tank_sparger_eductor_system_at_design_charge_mass_flow = 1.700
  let pressure_drop_cold_tank_sparger_eductor_system_at_design_discharge_mass_flow = 2.000
  let function_of_pressure_drop_vs_mass_flow = 2.0
  let default_salt_pump_efficiency = 73.0
  let pump_aux_resolution_interval = 10.0

  let c_2 = -3.56E-07
  let c_1 = 5.44E-03
  let c_0 = 5.80E+01

  let alpha_insulation_to_air = 2.00E+01

  let lambda_insulation_calculation_coefficient_a_cold_tank = 0.000
  let lambda_insulation_calculation_coefficient_b_cold_tank = 0.031
  let thickness_tank_shell_insulation_cold_tank = 0.300
  let thickness_tank_roof_insulation_cold_tank = 0.300
  let lambda_foundation_cold_tank = 0.411
  let thickness_foundation_cold_tank = 2.400

  let lambda_insulation_calculation_coefficient_a_hot_tank = 0.000
  let lambda_insulation_calculation_coefficient_b_hot_tank = 0.031
  let thickness_tank_shell_insulation_hot_tank = 0.400
  let thickness_tank_roof_insulation_hot_tank = 0.400
  let lambda_foundation_hot_tank = 0.398
  let thickness_foundation_hot_tank = 2.400

  let factor_thermal_bridges_roof_and_shell = 15.0
  let factor_thermal_bridges_bottom = 10.0

  let estimated_average_ambient_temperature = 15.0
  let estimated_average_Soil_temperature = 10.0

  let salt_mass_safety_margin = 3.0
  let temp_loss_charge = 7.0
  let temp_loss_discharge = 7.0
  let salt_p_drop_100 = 4.62
  let TES_HX_p_loss_100 = 5.0

  let temperatureLossCharge = 7.0
  let temperatureLossDischarge = 7.0

  // DesignConditions(100_SolarMode)
  let turbineEfficiencyGross = 38.42
  let thermalNominalCapacityOfPb = 156.2
  var turbineGrossElectricalOutput: Double {
      thermalNominalCapacityOfPb * turbineEfficiencyGross
}
  let htfPbHexInletTemperature = 393.0
  let htfPbHexNominalOutletTemperature = 296.3
  let solarCapacityMultiplyer = 2.0

  //  DefinitionOfTesMode
  let thermalDischargeRateOfTes = 78.0
  let tesStorageCapacity = 1406
  let activeSaltMassSafetyMargin = 3.0
  let approachTemperatureInTesHeatExchangerDuringCharge = 7.0  // [K]
  let approachTemperatureInTesHeatExchangerDuringDischarge = 7.0  // [K]
/*
  mutating func callAsFunction() {
    //  CalculationOfTesMode
    let hotTankTemperature = htfPbHexInletTemperature - temperatureLossCharge
    let htfPbHexInletTemperatureDischarging =
      htfPbHexInletTemperature - temperatureLossCharge - temperatureLossDischarge

    //  Calculation - HtfTemperatures
    //  InputValues

    //  ImportedValuesFromPreviousInputsUndCalculations
    //let htfPbHexNominalOutletTemperature = htfPbHexNominalOutletTemperature
    let thermalNominalPowerOfPb = thermalNominalCapacityOfPb
    let htfPbHexInletTemperatureAt100_SolarMode = htfPbHexInletTemperature
    //let htfPbHexOutletTemperatureAt100_SolarMode = htfPbHexNominalOutletTemperature
    // let approachTemperatureInTesHeatExchangerDuringCharge = approachTemperatureInTesHeatExchangerDuringCharge
    let tesModeHtfHexInletTemperature = htfPbHexInletTemperatureDischarging
    let thermalDischargeRateOfTesOfNominalPbHtfMassFlow = thermalDischargeRateOfTes

    //  Calculation
    let nominalHtfMassFlowInPbHexAt100_SolarMode =
      thermalNominalPowerOfPb * 1_000
      / (htf.enthalpy(htfPbHexInletTemperatureAt100_SolarMode)
        - htf.enthalpy(htfPbHexOutletTemperatureAt100_SolarMode))
    //  CoefficientsForHtfHexPartLoadFunction
    let a = 0.000759241986926377
    let b = 0.494382589322317
    let c = 0.000140082388237702
    let d = -0.0110227028559065
    let e = -0.000151638913322927

    let totalT_Hex_OutFactor =
      (a * (tesModeHtfHexInletTemperature + 273.15) + b)
      * thermalDischargeRateOfTesOfNominalPbHtfMassFlow
      ** (c * (tesModeHtfHexInletTemperature + 273.15) + d) + e  //  [%_K]
    let htfPbHexOutletTemperatureDischarging =
      (htfPbHexNominalOutletTemperature + 273.15) * totalT_Hex_OutFactor - 273.15  //  [°C]
    let totalHtfMassFlowDischarging =
      thermalDischargeRateOfTesOfNominalPbHtfMassFlow * nominalHtfMassFlowInPbHexAt100_SolarMode  //  [Kg / S]
    let thermalPowerPb_TesDischarging =
      (htf.enthalpy(tesModeHtfHexInletTemperature) - htf.enthalpy(htfPbHexOutletTemperatureDischarging))
      * totalHtfMassFlowDischarging / 1_000  //
    let coldTankTemperature = htfPbHexOutletTemperatureDischarging + temperatureLossDischarge  //  [°C]
    let htfTemperatureAtTesHexOutletDuringCharge =
      coldTankTemperature + approachTemperatureInTesHeatExchangerDuringCharge  //  [°C]
    //  Results
    let thermalPowerOfPb_TesDischarging = thermalPowerPb_TesDischarging
    // let nominalHtfMassFlowInPbHexAt100_SolarMode = nominalHtfMassFlowInPbHexAt100_SolarMode
    let dischargeHtfMassFlowThroughTes_PbHex = totalHtfMassFlowDischarging
    // htfPbHexOutletTemperatureDischarging
    // coldTankTemperature
    // htfTemperatureAtTesHexOutletDuringCharge

    //  DeterminationOfTesModeTurbineEfficiency
    //  InputValues

    //  importedValuesFromPreviousInputsUndCalculations
    let turbineEfficiency = turbineEfficiencyGross
    // let htfPbHexInletTemperatureDischarging = htfPbHexInletTemperatureDischarging
    // let =B109 = thermalNominalCapacityOfPb
    let thermalPowerOfPb_TesDischarging = thermalPowerOfPb_TesDischarging

    //  Calculation
    let dischargeLoadRatio = thermalPowerOfPb_TesDischarging / thermalNominalCapacityOfPb
    // pbEfficiency=F(Load)
    let c0 = 0.6526
    let c1 = 1.1839
    let c2 = -1.8611
    let c3 = 1.5008
    let c4 = -0.4761
    let efficiencyFactor =
      c0 + c1 * dischargeLoadRatio ** 1 + c2 * dischargeLoadRatio ** 2 + c3 * dischargeLoadRatio
      ** 3 + c4 * dischargeLoadRatio ** 4
    let efficiencyAtNewLoad = turbineEfficiency * efficiencyFactor

    // pbEfficiency=F(Temp)
    let aTemp = 0.998122828278924
    let cTemp = 0.2383
    let xTemp = 0.2404
    let efficiencyFactorTemp = (cTemp * htfPbHexInletTemperatureDischarging ** xTemp) * aTemp
    let efficiencyAtNewTemp = turbineEfficiency * efficiencyFactorTemp

    let turbineEfficiencyDischarging = turbineEfficiency * efficiencyFactor * efficiencyFactorTemp
    let turbineGrossElectricalOutputDischarging =
      thermalPowerOfPb_TesDischarging * turbineEfficiencyDischarging
    //  Results
    let dischargeLoadOfTes = dischargeLoadRatio
    //let turbineEfficiencyDischarging = turbineEfficiencyDischarging
    //let turbineGrossElectricalOutputDischarging = turbineGrossElectricalOutputDischarging

    //  (Thermal)EquivalentFullLoadHours
    //  InputValues

    //let importedValuesFromPreviousInputsOrResults
    // let nominalHtfMassFlowInPbHexAt100_SolarMode = nominalHtfMassFlowInPbHexAt100_SolarMode
    let nominalThermalPbPower = thermalNominalCapacityOfPb
    // let tesStorageCapacity = tesStorageCapacity
    // let solarMultiple(ReferingToPbMassflow) = solarCapacityMultiplyer
    let htfPbNominalHexInletTemperature = htfPbHexInletTemperature

    //  Calculation
    let htfMassFlowThroughSfAt100_SolarMode =
      solarCapacityMultiplyer * nominalHtfMassFlowInPbHexAt100_SolarMode
    let chargeHtfMassFlowThroughTesHex =
      htfMassFlowThroughSfAt100_SolarMode - nominalHtfMassFlowInPbHexAt100_SolarMode
    let p_Th_Tes_ChargeNominalThermalPowerToTesInChargeMode =
      chargeHtfMassFlowThroughTesHex / 1_000
      * (htf.enthalpy(C203)
        - htf.enthalpy(coldTankTemperature + approachTemperatureInTesHeatExchangerDuringCharge))
    let nominalChargeTime = tesStorageCapacity / p_Th_Tes_ChargeNominalThermalPowerToTesInChargeMode
    let thermalEquivalentFullLoadHours = tesStorageCapacity / nominalThermalPbPower
    //  Results
    let nominalChargeTimeForNominalChargePower = nominalChargeTime
    // chargeHtfMassFlowThroughTesHex
    // thermalEquivalentFullLoadHours
    // p_Th_Tes_ChargeNominalThermalPowerToTesInChargeMode

    // (Electrical)EquivalentFullLoadHours
    //  InputValues

    // importedValuesFromPreviousInputsUndCalculations
    // let tesStorageCapacity = Calc_Tes_Cap
    let tesModeThermalPbPowerInTesMode = thermalPowerOfPb_TesDischarging
    // let turbineGrossElectricalOutput = turbineGrossElectricalOutput
    // let turbineGrossElectricalOutputDischarging = turbineGrossElectricalOutputDischarging

    //  Calculation
    let dischargeTimeAtDesignDischargeLoad = tesStorageCapacity / tesModeThermalPbPowerInTesMode
    let electricalOutputOfTesForCompleteDischarge =
      turbineGrossElectricalOutputDischarging * dischargeTimeAtDesignDischargeLoad
    let electricalEquivalentFullLoadHours =
      electricalOutputOfTesForCompleteDischarge / turbineGrossElectricalOutput
    //  Results
    // electricalOutputOfTesForCompleteDischarge
    // electricalEquivalentFullLoadHours
    // dischargeTimeAtDesignDischargeLoad

    // saltMassFlows(SfToPb&TesMode)
    //  InputValues

    let p_Th_Tes_DischargeNominal = thermalPowerPb_TesDischarging
    let p_Th_Tes_ChargeNominal = C210
    //let OptionalInput
    let totalActiveSaltMass = If(
      Act_Salt_Mass = 0,
      If(
        Not(Tes_Cap = ""),
        Tes_Cap * 3_600 * 1_000 / (salt.enthalpy(hotTankTemperature) - salt.enthalpy(coldTankTemperature)) / 1000,
        "CheckInputParameter"), If(Tes_Cap = "", Act_Salt_Mass, "CheckInputParameter"))

    //  Calculation
    let decisiveCaseForTesDesign = If(
      p_Th_Tes_DischargeNominal > p_Th_Tes_ChargeNominal, "Discharge", "Charge")
    //let modeRatio(<0,4:VeryBad;<1:Bad;1 - 3:Good;>3:Bad) = p_Th_Tes_ChargeNominal / p_Th_Tes_DischargeNominal
    let chargeSaltMassFlow =
      p_Th_Tes_ChargeNominal * 1_000 / (salt.enthalpy(hotTankTemperature) - salt.enthalpy(C241))
    let dischargeSaltMassFlow =
      p_Th_Tes_DischargeNominal * 1_000 / (salt.enthalpy(hotTankTemperature) - salt.enthalpy(C241))
    //  Results
    // let totalActiveSaltMass = C246
    let decisiveCaseForTesDesign = C249
    let nominalChargeSaltMassFlow = chargeSaltMassFlow
    let nominalDischargeSaltMassFlow = dischargeSaltMassFlow

    // tesHexsDesignValues(Total)
    //  InputValues
    let p_Th_MaxPerTesHexTrain = p_Th_Max_Per_Trainw_Th
    let maximumTrainQuantPerTwoTankSystem = maximum_Train_Quant._Per_2_Tank_System
    let requestedMinimumPossiblePartLoadCharge = requested_Minimum_Possible_Part_Load_Charge
    let maxTurnDownRatioPerHexTrain = max_Turn_Down_Ratio_Per_Hex_Train

    let thermalPbPowerDischarging = C154
    let p_Th_Tes_ChargeNominal = p_Th_Tes_ChargeNominalThermalPowerToTesInChargeMode
    // nominalChargeSaltMassFlow
    //nominalDischargeSaltMassFlow

    //  Calculation
    let designTotalThermalTesHexsPower = max(thermalPbPowerDischarging, p_Th_Tes_ChargeNominal)
    let designTotalSaltMassFlow = max(nominalChargeSaltMassFlow, nominalDischargeSaltMassFlow)

    let necessaryTrainsFromMaxDuty = designTotalThermalTesHexsPower / p_Th_MaxPerTesHexTrain
    let maximumDesignDutyPerHexTrain =
      p_Th_Tes_ChargeNominal * requestedMinimumPossiblePartLoadCharge / maxTurnDownRatioPerHexTrain
    let necessaryTrainsParallelTrainsPerTwoTankSystemFromPartLoadRequirements =
      max(thermalPbPowerDischarging, p_Th_Tes_ChargeNominal) / maximumDesignDutyPerHexTrain
    let tankSystemsInParallelFromPartLoadRequir = (
      necessaryTrainsParallelTrainsPerTwoTankSystemFromPartLoadRequirements
        / maximumTrainQuantPerTwoTankSystem, 0).rounded(.up)
    let tankSystemsInParallelFromHexMaxDuty = (
      necessaryTrainsFromMaxDuty / maximumTrainQuantPerTwoTankSystem, 0).rounded(.up)
    //  Results
    // designTotalThermalTesHexsPower
    // designTotalSaltMassFlow
    let tankSystemsInParallelFromHexLimitations = max(
      tankSystemsInParallelFromPartLoadRequir, tankSystemsInParallelFromHexMaxDuty)

    // tesPumpsDesignValues(Total)
    //  InputValues
    let minSaltMassFlowPerPump = min_Salt_Mass_Flow_Per_Pump__Kg_S
    let lowSaltMassFlow = low_Salt_Mass_Flow__Kg_S
    let minLevelAtLowSaltMassFlow = min_Level_At_Low_Salt_Mass_Flow
    let maxSaltMassFlowPerPump = max_Salt_Mass_Flow_Per_Pump__Kg_S
    let minLevelAtMaxSaltMassFlow = min_Level_At_Max_Salt_Mass_Flow
    let maxPumpsPerTank = max_Pumps_Per_Tank
    //  importedValuesFromPreviousInputsUndCalculations
    let designSaltMassFlow = designTotalSaltMassFlow

    //  Calculation
    let maxSaltMassFlowPerTwoTankSystem = C293 * C291
    let tankSystemsInParallelFromPumpConditions = (C295 / C298, 0).rounded(up)
    //  Results
    /// let tankSystemsInParallelFromPumpConditions = C299

    //let tesTankDesignValues(PreliminaryForSizeEstimation)
    //  InputValues
    let maxActiveTankHeight = Max_Active_Tank_Height
    let maxTankDiameter = Max_Tank_Diameter
    let importedValuesFromPreviousInputsUndCalculations
    let activeSaltMassSafetyMargin = C118
    let totalActiveSaltMassForPerformanceCalculation = Act_Salt_Mass
    let designTotalThermalTesHexsPower = C281

    //  Calculation
    let totalActiveSaltMassInclSafetyMarginForTankSizing =
      totalActiveSaltMassForPerformanceCalculation + totalActiveSaltMassForPerformanceCalculation
      * activeSaltMassSafetyMargin
    let totalSaltMassFromHexTrainsEstimate = designTotalThermalTesHexsPower * (400 / 130)
    let totalActiveSaltMassInclSafetyMargin = totalSaltMassFromHexTrains + totalActiveSaltMassIncl

    let minNecessaryActiveTankHeightToAccomodateActiveSaltMass =
      totalActiveSaltMassInclSafetyMargin * 1_000 / salt.density(hotTankTemperature)
      / (maxTankDiameter ** 2 / 4 * .pi)
    let minNecessaryTankDiameterToAccomodateActiveSaltMass = sqrt(
      4 / .pi
        * (totalActiveSaltMassInclSafetyMargin * 1_000 / salt.density(hotTankTemperature)
          / (maxActiveTankHeight)))
    let tankSystemsInParallelFromTankConditionsHeight = (
      minNecessaryActiveTankHeightToAccomodateActiveSaltMass / maxActiveTankHeight, 0).rounded(.up)

    //  Results
    // let totalActiveSaltMassIncl.SafetyMargin + HexSaltMass[T] = totalActiveSaltMassInclSafetyMargin
    // let tankSystemsInParallelFromTankConditions = tankSystemsInParallelFromTankConditionsHeight

    //  TesTanks - Overview
    // let tankSystemsInParallelFromPartLoadRequir = tankSystemsInParallelFromPartLoadRequir
    // let tankSystemsInParallelFromHexMaxDuty = tankSystemsInParallelFromHexMaxDuty
    // let tankSystemsInParallelFromPumpConditions = tankSystemsInParallelFromPumpConditions
    // let tankSystemsInParallelFromTankConditions = tankSystemsInParallelFromTankConditions

    let totalNumberOfTanks =
      2
      * max(
        tankSystemsInParallelFromTankConditionsHeight, tankSystemsInParallelFromPumpConditions,
        tankSystemsInParallelFromHexLimitations)

    let specificHeatExchangerTrainDesignPerTwoTankSystemToBeAdjusted
    let minimumNumberOfTrainsTotal = max(
      (necessaryTrainsFromMaxDuty / (totalNumberOfTanks / 2), 0).rounded(.up) * (totalNumberOfTanks / 2),
      (necessaryTrainsParallelTrainsPerTwoTankSystemFromPartLoadRequirements, 0).rounded(.up)
        * (totalNumberOfTanks / 2))
    let minimumNumberOfTrainsPerTwoTankSystem =
      minimumNumberOfTrainsTotal / (totalNumberOfTanks / 2)
    let designHeatDutyPerTrain =
      max(p_Th_Tes_ChargeNominal, p_Th_Tes_DischargeNominal) / minimumNumberOfTrainsTotal
    let chargeDutyPerTwoTankSystem = C210 / (totalNumberOfTanks / 2)
    let tesHexTrainsPerTqoTankSystemInActionDuringNominal100Charge = (
      chargeDutyPerTwoTankSystem / designHeatDutyPerTrain).rounded(.up)
    let saltFlowPerTrainDuringNominal100Charge =
      If(C249 = "Discharge", dischargeSaltMassFlow, designTotalSaltMassFlow)
      / tesHexTrainsPerTqoTankSystemInActionDuringNominal100Charge / (totalNumberOfTanks / 2)
    let tesHexTrainsPerPerTwoTankSystemInActionDuring20Charge = (
      C339 * 0.2 / designHeatDutyPerTrain).rounded(.up)
    let saltFlowPerTrainDuring20Charge =
      If(C249 = "Discharge", dischargeSaltMassFlow, designTotalSaltMassFlow) * 0.2
      / tesHexTrainsPerPerTwoTankSystemInActionDuring20Charge / (totalNumberOfTanks / 2)
    let tesHexTrainsPerTwoTankSystemInActionDuringDischarge = (
      p_Th_Tes_DischargeNominal / (totalNumberOfTanks / 2) / designHeatDutyPerTrain).rounded(.up)
    let saltFlowPerTrainDuringDischarge =
      If(C249 = "Charge", dischargeSaltMassFlow, designTotalSaltMassFlow)
      / tesHexTrainsPerTwoTankSystemInActionDuringDischarge / (totalNumberOfTanks / 2)

    // specificPumpDesignPerTwoTankSystem
    //  InputValues
    let minSaltMassFlowPerPump = min_Salt_Mass_Flow_Per_Pump__Kg_S
    let lowSaltMassFlow = low_Salt_Mass_Flow__Kg_S
    let minLevelAtLowSaltMassFlow = min_Level_At_Low_Salt_Mass_Flow
    let maxSaltMassFlowPerPump = max_Salt_Mass_Flow_Per_Pump__Kg_S
    let minLevelAtMaxSaltMassFlow = min_Level_At_Max_Salt_Mass_Flow
    let maxPumpsPerTank = max_Pumps_Per_Tank
    let importedValuesFromPreviousInputsUndCalculations
    // totalNumberOfTanks
    // chargeSaltMassFlow
    // dischargeSaltMassFlow

    //  Calculation
    let possibleNumberOfPumpsTotal = totalNumberOfTanks * maxPumpsPerTank
    let necessaryNumberOfPumpsPerColdTankCharging = 1  //If(Rounddown(C357 / (totalNumberOfTanks / 2) / minSaltMassFlowPerPump,0)<=1,1,If(Rounddown(chargeSaltMassFlow / (totalNumberOfTanks / 2) / minSaltMassFlowPerPump,0)<(C354 + 1),Rounddown(let c357 / (C385 / 2) / minSaltMassFlowPerPump,0),C354))
    let flowPerColdTankPumpCharging =
      chargeSaltMassFlow / (necessaryNumberOfPumpsPerColdTankCharging * (totalNumberOfTanks / 2))
    let minTankLevelInColdTankCharging =
      C351
      + (If(
        C363 > lowSaltMassFlow,
        (flowPerColdTankPumpCharging - lowSaltMassFlow) / (maxSaltMassFlowPerPump - lowSaltMassFlow)
          * (minLevelAtMaxSaltMassFlow - C351), 0))

    let totalSaltMassFlowDischarging = dischargeSaltMassFlow

    let numberOfPumpsPerHotTankDischarging = If(
      (dischargeSaltMassFlow / (totalNumberOfTanks / 2) / minSaltMassFlowPerPump).rounded(.down)
        < (C354 + 1),
      Rounddown(dischargeSaltMassFlow / (totalNumberOfTanks / 2) / minSaltMassFlowPerPump), C354)
    let flowPerHotTankPumpDischarging =
      dischargeSaltMassFlow / numberOfPumpsPerHotTankDischarging / (totalNumberOfTanks / 2)
    let minTankLevelInHotTankDischarging =
      C351
      + (If(
        flowPerHotTankPumpDischarging > lowSaltMassFlow,
        (flowPerHotTankPumpDischarging - lowSaltMassFlow)
          / (maxSaltMassFlowPerPump - lowSaltMassFlow)
          * (minLevelAtMaxSaltMassFlow - C351), 0))
    //  Results
    // let numberOfPumpsPerColdTankCharging = necessaryNumberOfPumpsPerColdTankCharging
    // let numberOfPumpsPerHotTankDischarging = numberOfPumpsPerHotTankDischarging
    // let flowPerColdTankPumpCharging = flowPerColdTankPumpCharging
    // let flowPerHotTankPumpDischarging = flowPerHotTankPumpDischarging
    // let minTankLevelInColdTankCharging = C364
    // let minTankLevelInHotTankDischarging = minTankLevelInHotTankDischarging

    // tankDimensionDetails
    // specificTankDesignPerTwo - TankSystem
    //  InputValues
    let maxActiveTankHeight = max_Active_Tank_Height
    let maxTankDiameter = max_Tank_Diameter
    //let importedValuesFromPreviousInputsUndCalculations
    //let preliminaryResult:TotalNumberOfTanks = totalNumberOfTanks
    //let totalActiveSaltMassIncl.SafetyMargin + HexSaltMass[T] = totalActiveSaltMassInclSafetyMargin

    //  Calculation
    let twoTankActiveSaltMassInclSafetyMargin =
      totalActiveSaltMassInclSafetyMargin / (totalNumberOfTanks / 2)
    let twoTankActiveSaltVolumeInclSafetyMargin =
      twoTankActiveSaltMassInclSafetyMargin * 1_000 / salt.density(C388)

    let minimumActiveHeightDiameterRatio =
      twoTankActiveSaltVolumeInclSafetyMargin / (.pi / 4 * maxTankDiameter ** 2) / maxTankDiameter
    let maximumActiveHeightDiameterRatio =
      maxActiveTankHeight
      / sqrt(twoTankActiveSaltVolumeInclSafetyMargin / maxActiveTankHeight * (4 / .pi))
    let setActiveHeightRatioDiameterRatio = tank_Height_Diameter_Ratio_Of_Active_Salt_Volume
    let actualTankDiameter =
      ((4 / .pi) * twoTankActiveSaltVolumeInclSafetyMargin / setActiveHeightRatioDiameterRatio)
      ** (1 / 3)
    let actualActiveTankHeightHot = setActiveHeightRatio * actualTankDiameter
    //  Results
    // let =B397 = C397 actualTankDiameter
    // let actualActiveTankHeightHot = actualActiveTankHeightHot
    // let twoTankActiveSaltMassInclSafetyMargin + SaltMassInHexTrains(PerTwo - TankSystem)[T] = twoTankActiveSaltMassInclSafetyMargin

    let designFillLevelsAndInitialFillLevels
    let importedValuesFromPreviousInputsUndCalculations
    let minimumSaltLevelInColdTank = minTankLevelInColdTankCharging
    let minimumSaltLevelInHotTank = minTankLevelInHotTankDischarging
    let temperatureForTankSizeCalculationUpperDesignTemp = C123
    let tankDiameter = actualTankDiameter
    // let activeSaltMassInclSafetyMargin + SaltMassInHexTrainsPerTwo - TankSystem[T] = twoTankActiveSaltMassInclSafetyMargin

    //  Calculation
    let tankFloorArea = tankDiameter ** 2 / 4 * .pi

    let activeSaltVolumeInclSafetyMarginInColdTank =
      twoTankActiveSaltMassInclSafetyMargin * 1_000 / salt.density(coldTankTemperature)
    let activeLevelChangeInColdTank = C417 / tankFloorArea  // (Sor / Eor)
    let upperOperationalColdTankFillLevel = activeLevelChangeInColdTank + minimumSaltLevelInColdTank

    let activeSaltVolumeInclSafetyMarginInHotTank =
      twoTankActiveSaltMassInclSafetyMargin * 1_000 / salt.density(hotTankTemperature)
    let activeLevelChangeInHotTankSor_Eor = C421 / tankFloorArea
    let upperOperationalHotTankFillLevel = C422 + C407

    let coldTankDeadSaltVolume = minimumSaltLevelInColdTank * tankFloorArea
    let coldTankDeadSaltMass = coldTankDeadSaltVolume * salt.density(C411) / 1_000
    let hotTankDeadSaltVolume = minimumSaltLevelInColdTank * tankFloorArea
    let hotTankDeadSaltMass = hotTankDeadSaltVolume * salt.density(C412) / 1_000
    let totalSaltMassPerTwoTankSystem =
      twoTankActiveSaltMassInclSafetyMargin + coldTankDeadSaltMass + hotTankDeadSaltMass
    let totalSaltVolumePerTwoTankSystemInitialFill =
      totalSaltMassPerTwoTankSystem * 1_000
      / salt.density(temperatureForTankSizeCalculationUpperDesignTemp)
    let maximumDesignFillLevelInTankInitialFill =
      totalSaltVolumePerTwoTankSystemInitialFill / tankFloorArea

    //  Results
    // upperOperationalColdTankFillLevel
    // upperOperationalHotTankFillLevel
    // maximumDesignFillLevelInTank
    // coldTankDeadSaltMass
    // hotTankDeadSaltMass

    // totalSaltMass
    // importedValuesFromPreviousInputsUndCalculations
    //let totalNumberOfTanks = totalNumberOfTanks
    //let totalActiveSaltMass(ForPerformanceCalculations,WithoutSafetyMargin) = C254
    //let activeSaltMassInclSafetyMargin + SaltMassInHexTrainsPerTwo - TankSystem[T] = C402
    //let coldTankDeadSaltMass = coldTankDeadSaltMass
    //let hotTankDeadSaltMass = hotTankDeadSaltMass

    //  Calculation
    let totalSaltMassInTesSystem =
      totalNumberOfTanks / 2
      * ((coldTankDeadSaltMass + hotTankDeadSaltMass) + activeSaltMassInclSafetyMargin)
    let totalSaltMassToBeBought = totalSaltMassInTesSystem / (1 - 0.001 - 0.0005)
    let fractionTotalDeadSaltMassVsTotalActiveSaltMassForPct =
      (coldTankDeadSaltMass + hotTankDeadSaltMass) / C443
    //  Results
    //let totalSaltMass[T](InTesSystem) = totalSaltMassInTesSystem
    //let totalSaltMass[T](ToBeBought) = totalSaltMassToBeBought
    // let fraction = fractionTotalDeadSaltMassVsTotalActiveSaltMassForPct

    let pumpShaftLengthAndSurfaceAreaOfTankShell
    //  InputValues
    let freeBoardAllowance = free_Board_Allowance
    let pumpSuctionClearance = pump_Suction_Clearance__Distance_Suction_Inlet_To_Tank_Floor_
    let tankRoofRadiusFactor = tank_Roof_Radius_factor__Radius___factor___Tank_Diameter
    let horizontalDistancePumpTankWall = horizontal_Distance__Pump___Tank_Wall
    let distanceBetweenTankRoofAndPumpMountingPlate = vert_Distance_Tank_Roof_Pump_Mounting_Plate
    let importedValuesFromPreviousInputsUndCalculations
    // let tankDiameter = Tank_Diam
    //let maximumFillLevelOfTanks(InitialFill) = maximumDesignFillLevelInTank

    //  Calculations
    let tankRoofRadius = tankDiameter * tankRoofRadiusFactor
    let verticalDistancePumpMountTankRim =
      (tankRoofRadius ** 2 - (tankDiameter / 2 - horizontalDistancePumpTankWall) ** 2) ** 0.5
      - (tankRoofRadius ** 2 - (tankDiameter / 2) ** 2) ** 0.5
      + distanceBetweenTankRoofAndPumpMountingPlate
    let tankWallHeightBottomToRim = maximumDesignFillLevelInTank + freeBoardAllowance
    let maximumTankHeightAtTopBottomToTop =
      tankRoofRadius - (tankRoofRadius ** 2 - (tankDiameter / 2) ** 2) ** 0.5
      + tankWallHeightBottomToRim
    let pumpShaftLengthPumpMountToSuctionInlet =
      tankWallHeightBottomToRim + verticalDistancePumpMountTankRim - pumpSuctionClearance

    let surfaceAreaOfTankRoof =
      2 * .pi * tankRoofRadius * (maximumTankHeightAtTopBottomToTop - tankWallHeightBottomToRim)
    let surfaceAreaOfCylindricalTankShell = tankWallHeightBottomToRim * .pi * tankDiameter
    //  Results
    //let =B471 = C471
    //let =B472 = C472
    //let pumpShaftLengthPumpMountToSuctionInlet = pumpShaftLengthPumpMountToSuctionInlet
    let surfaceAreaOfTankShellWithoutTankBottom =
      surfaceAreaOfCylindricalTankShell + surfaceAreaOfTankRoof

    //  TesPressureDrops,SaltHeadsAndAuxiliaries
    //  InputValues
    //let tesHexSaltPressureDropDuringDesignMode = 'In - OutputSummary'!C29
    let verticalDistanceBetweenHexLevelAndPumpMountLevel =
      vertical_Distance_Between_Hex_Level_And_Pump_Mount_Level
    let pumpSuctionClearanceDistanceSuctionInletToTankFloor =
      pump_Suction_Clearance__Distance_Suction_Inlet_To_Tank_Floor
    let pressureDropPipingAndValvesDesignChargeMassFlow =
      pressure_Drop_Piping_And_Valves_Design_Charge_Mass_Flow__Bar
    let pressureDropHotTankSpargerAtDesignChargeMassFlow =
      pressure_Drop_Hot_Tank_Sparger_Eductor_System_At_Design_Charge_Mass_Flow__Bar
    let pressureDropColdTankSpargerAtDesignDischargeMassFlow =
      pressure_Drop_Cold_Tank_Sparger_Eductor_System_At_Design_Discharge_Mass_Flow__Bar
    let functionOfPressureDropVsMassFlow = function_of_pressure_drop_vs_mass_flow
    let importedValuesFromPreviousInputsUndCalculations
    //let coldTankTemperature = C158
    //let hotTankTemperature = C123

    //let upperOperationalColdTankFillLevel = upperOperationalColdTankFillLevel
    //let upperOperationalHotTankFillLevel = upperOperationalHotTankFillLevel
    let minimumTankLevelInColdTank = minTankLevelInColdTankCharging
    let minimumTankLevelInHotTank = minTankLevelInHotTankDischarging

    // let pumpShaftLengthPumpMountToSuctionInlet = C480

    // let totalNumberOfTanks = totalNumberOfTanks
    let numberOfPumpsPerColdTankCharging = necessaryNumberOfPumpsPerColdTankCharging
    let numberOfPumpsPerHotTankDischarging = C373
    let flowPerColdTankPumpCharging = C374  //  [Kg / S]
    let flowPerHotTankPumpDischarging = C375  //  [Kg / S]

    let designSaltMassFlow = C282  //  [Kg / S]
    let totalChargeSaltMassFlow = C256  //  [Kg / S]
    let dischargeSaltMassFlow = C257  //  [Kg / S]

    //  Calculations
    let coldSaltDensity = salt.density(coldTankTemperature)  // [Kg / M³]
    let hotSaltDensity = salt.density(hotTankTemperature)
    let verticalDistanceBetweenHexTrainOutletAndSparger =
      -(pumpShaftLengthPumpMountToSuctionInlet + verticalDistanceBetweenHexLevelAndPumpMountLevel)

    //  CalculationChargeAuxliliaries
    let massFlowRatio = 1
    let actualTotalChargeMassFlow = massFlowRatio * totalChargeSaltMassFlow  // [Ks/S]
    let actualFlowPerColdTankPumpCharging =
      actualTotalChargeMassFlow / (numberOfPumpsPerColdTankCharging * totalNumberOfTanks / 2)
    let actualTesHexSaltPressureDropDuringDesignCharge =
      tesHexSaltPressureDropDuringDesignMode * (actualTotalChargeMassFlow / designSaltMassFlow)
      ** functionOfPressureDropVsMassFlow
    let actualPressureDropPipingAndValvesDesignChargeMassFlow =
      pressureDropPipingAndValvesDesignChargeMassFlow
      * (actualTotalChargeMassFlow / designSaltMassFlow)
      ** functionOfPressureDropVsMassFlow
    let actualPressureDropHotTankSparger =
      pressureDropHotTankSpargerAtDesignChargeMassFlow
      * (actualTotalChargeMassFlow / designSaltMassFlow) ** functionOfPressureDropVsMassFlow

    // (0) - >(1)
    let nominalPressureInColdTank = 1
    let equivalentSaltHeadOfTankPressureCold =
      -nominalPressureInColdTank * 100_000 / (coldSaltDensity * 9.81)
    let activeSaltColumnColdTankAt100ChargedSystem =
      -minimumTankLevelInColdTank + pumpSuctionClearanceDistanceSuctionInletToTankFloor
    let pressureDifferenceAtmPumpSuctionInlet =
      activeSaltColumnColdTankAt100ChargedSystem * coldSaltDensity * 9.81 / 100_000
    // (1) - >(2)
    let headFromPumpShaftLengthColdSide = pumpShaftLengthPumpMountToSuctionInlet
    let pressureDifferenceAlongPumpShaftLengthColdSide =
      headFromPumpShaftLengthColdSide * coldSaltDensity * 9.81 / 100_000
    let headFromPumpOutletToHexHeightColdSide = verticalDistanceBetweenHexLevelAndPumpMountLevel
    let pressureDifferenceAlongPumpOutletToHexHeightColdSide =
      headFromPumpOutletToHexHeightColdSide * coldSaltDensity * 9.81 / 100_000
    // (2) - >(3)
    let pressureDropsInHex = actualTesHexSaltPressureDropDuringDesignCharge
    let staticColdSaltHeadDueToHexPressureDrop =
      pressureDropsInHex * 100_000 / (coldSaltDensity * 9.81)
    let pressureDropsInPipesAndValves = actualPressureDropPipingAndValvesDesignChargeMassFlow
    let staticHeadDueToPipesAndValvesPressureDrop =
      pressureDropsInPipesAndValves * 100_000 / (coldSaltDensity * 9.81)
    // (3) - >(4)
    let headFromPumpShaftLengthHotSide = verticalDistanceBetweenHexTrainOutletAndSparger
    let pressureDifferenceAlongPumpShaftHotSide =
      headFromPumpShaftLengthHotSide * hotSaltDensity * 9.81 / 100_000
    let pressureDropAtSparger = actualPressureDropHotTankSparger
    let staticHeadDueToSpargerDrop = pressureDropAtSparger * 100_000 / (hotSaltDensity * 9.81)
    // (4) - >(5)
    let activeSaltColumnOnSpargerOutletAt100ChargedSystemHot =
      upperOperationalHotTankFillLevel - pumpSuctionClearanceDistanceSuctionInletToTankFloor
    let pressureDifferenceSpargerOutletAtm =
      activeSaltColumnOnSpargerOutletAt100ChargedSystemHot * hotSaltDensity * 9.81 / 100_000
    let nominalPressureInHotTank = 1
    let totalPressureDifferenceHexAtmHot =
      pressureDifferenceAlongPumpShaftHotSide + pressureDropAtSparger
      + pressureDifferenceSpargerOutletAtm + nominalPressureInHotTank
    let physicalSuctionLimit1Barg = If(C550 < 1, 1, C550)
    let equivalentColdSaltHeadHexAtmHot =
      physicalSuctionLimit1Barg * 100_000 / (coldSaltDensity * 9.81)

    let totalPressureDifference =
      -nominalPressureInColdTank + pressureDifferenceAtmPumpSuctionInlet
      + pressureDifferenceAlongPumpShaftLengthColdSide
      + pressureDifferenceAlongPumpOutletToHexHeightColdSide + pressureDropsInHex
      + pressureDropsInPipesAndValves + physicalSuctionLimit1Barg
    let totalHeadForPumps =
      equivalentSaltHeadOfTankPressureCold + activeSaltColumnColdTankAt100ChargedSystem
      + headFromPumpShaftLengthColdSide + headFromPumpOutletToHexHeightColdSide
      + staticColdSaltHeadDueToHexPressureDrop + C540 + C552

    let volumeFlowPerPump = actualFlowPerColdTankPumpCharging / hotSaltDensity * 3_600  // [M³ / H]
    let A = Vflow2 / H = volumeFlowPerPump ** 2 / totalHeadForPumps
    let pumpEfficiencyΗ = default_Salt_Pump_Efficiency
    let requiredMechanicalPowerP_MPerPump =
      flowPerColdTankPumpCharging * totalHeadForPumps * 9.81 / 1000
    let powerConsumptionP_ElPerPump = requiredMechanicalPowerP_MPerPump / pumpEfficiencyΗ
    let saltSideAuxiliaryPowerConsumptionForDesignCharge =
      powerConsumptionP_ElPerPump * numberOfPumpsPerColdTankCharging * totalNumberOfTanks / 2
    //  CalculationDischargeAuxliliaries
    let actualTotalDischargeMassFlow = massFlowRatio * dischargeSaltMassFlow
    let actualFlowPerHotTankPumpDischarging =
      actualTotalDischargeMassFlow / (numberOfPumpsPerHotTankDischarging * totalNumberOfTanks / 2)
    let actualTesHexSaltPressureDropDuringNominalDischarge =
      tesHexSaltPressureDropDuringDesignMode * (actualTotalDischargeMassFlow / designSaltMassFlow)
      ** functionOfPressureDropVsMassFlow
    let actualPressureDropPipingAndValvesNominalDischargeMassFlow =
      pressureDropPipingAndValvesDesignChargeMassFlow
      * (actualTotalDischargeMassFlow / designSaltMassFlow) ** functionOfPressureDropVsMassFlow
    let actualPressureDropColdTankSpargerDischargeMassFlow =
      pressureDropColdTankSpargerAtDesignDischargeMassFlow
      * (actualTotalDischargeMassFlow / designSaltMassFlow) ** functionOfPressureDropVsMassFlow

    // (0) - >(1)
    let nominalPressureInHotTank = 1
    let equivalentSaltHeadOfTankPressureHot =
      nominalPressureInHotTank * 100_000 / (hotSaltDensity * 9.81)
    let activeHotSaltColumnDesignAt0ChargedSystemHot =
      -minimumTankLevelInColdTank + pumpSuctionClearanceDistanceSuctionInletToTankFloor
    let pressureDifferenceAtmShaftInlet =
      activeHotSaltColumnDesignAt0ChargedSystemHot * hotSaltDensity * 9.81 / 100_000
    // (1) - >(2)
    // let headFromPumpShaftLengthHot = pumpShaftLengthPumpMountToSuctionInlet
    let pressureDifferenceAlongPumpShaftLengthHot =
      pumpShaftLengthPumpMountToSuctionInlet * hotSaltDensity * 9.81 / 100_000
    let headFromPumpHexHot = C486
    let pressureDifferenceAlongPumpHexHot = headFromPumpHexHot * hotSaltDensity * 9.81 / 100_000
    // (2) - >(3)
    // let pressureDropsInHex = actualTesHexSaltPressureDropDuringNominalDischarge
    let staticHeadDueToHexPressureDrop =
      actualTesHexSaltPressureDropDuringNominalDischarge * 100_000 / (hotSaltDensity * 9.81)
    let pressureDropsInPipesAndValves = actualPressureDropPipingAndValvesNominalDischargeMassFlow
    let staticHeadDueToPipesAndValvesPressureDrop =
      pressureDropsInPipesAndValves * 100_000 / (hotSaltDensity * 9.81)
    // (3) - >(4)
    let headFromPumpShaftLengthCold = verticalDistanceBetweenHexTrainOutletAndSparger
    let pressureDifferenceAlongPumpShaftCold =
      headFromPumpShaftLengthCold * coldSaltDensity * 9.81 / 100_000
    let pressureDropAtSparger = actualPressureDropColdTankSpargerDischargeMassFlow
    let staticHotSaltHeadDueToSpargerDrop =
      pressureDropAtSparger * 100_000 / (hotSaltDensity * 9.81)
    // (4) - >(5)
    let activeSaltColumnAt0ChargeColdSide =
      upperOperationalHotTankFillLevel - pumpSuctionClearanceDistanceSuctionInletToTankFloor
    let pressureDifferenceSpargerOutletAtm =
      activeSaltColumnAt0ChargeColdSide * coldSaltDensity * 9.81 / 100_000
    let nominalPressureInColdTank = 1
    let totalPressureDifferenceHexAtmCold =
      pressureDifferenceAlongPumpShaftCold + pressureDropAtSparger
      + pressureDifferenceSpargerOutletAtm
      + nominalPressureInColdTank
    let physicalSuctionLimit1Barg = If(C594 < 1, 1, totalPressureDifferenceHexAtmCold)
    let equivalentHotSaltHeadHexAtmCold =
      totalPressureDifferenceHexAtmCold * 100_000 / (hotSaltDensity * 9.81)

    let totalPressureDifference =
      -nominalPressureInHotTank + pressureDifferenceAtmShaftInlet
      + pressureDifferenceAlongPumpShaftLengthHot + pressureDifferenceAlongPumpHexHot
      + actualTesHexSaltPressureDropDuringNominalDischarge + pressureDropsInPipesAndValves
      + physicalSuctionLimit1Barg
    let totalHeadForPumps =
      -equivalentSaltHeadOfTankPressureHot + activeHotSaltColumnDesignAt0ChargedSystemHot
      + pumpShaftLengthPumpMountToSuctionInlet + headFromPumpHexHot + staticHeadDueToHexPressureDrop
      + staticHeadDueToPipesAndValvesPressureDrop + equivalentHotSaltHeadHexAtmCold

    let volumeFlowPerPump = actualFlowPerHotTankPumpDischarging / hotSaltDensity * 3_600
    let _ = volumeFlowPerPump ** 2 / totalHeadForPumps
    let pumpEfficiencyΗ = default_Salt_Pump_Efficiency
    let requiredMechanicalPowerP_MPerPump =
      flowPerHotTankPumpDischarging * totalHeadForPumps * 9.81 / 1_000
    let powerConsumptionP_ElPerPump = requiredMechanicalPowerP_MPerPump / pumpEfficiencyΗ
    let saltSideAuxiliaryPowerConsumptionForNominalDischarge =
      100_000 * numberOfPumpsPerHotTankDischarging * totalNumberOfTanks / 2

    let massFlowResolutionInterval = pump_Aux_Resolution_Interval  // =10(Caution:Max.100)
    let chargeLevelResolutionInterval = pump_Aux_Resolution_Interval  // =10(Caution:Max.100)
    //  Results
    let verticalDistanceBetweenHexLevelAndPumpMountLevel = C486
    // let pumpShaftLengthPumpMountToSuctionInlet = pumpShaftLengthPumpMountToSuctionInlet

    let nominalAuxiliaryPowerConsumptionChargeModeSaltPumpsOnly =
      saltSideAuxiliaryPowerConsumptionForDesignCharge
    let nominalAuxiliaryPowerConsumptionDischargeModeSaltPumpsOnly =
      saltSideAuxiliaryPowerConsumptionForNominalDischarge

    //  HtfMassFlows
    //  InputValues

    let importedValuesFromPreviousInputsUndCalculations
    let htfPbHexInletTemperatureAtNominalCharge = htfPbHexInletTemperature
    let htfPbHexOutletTemperatureAtNominalCharge = htfPbHexNominalOutletTemperature
    let approachTemperatureInTesHeatExchangerDuringCharge =
      approachTemperatureInTesHeatExchangerDuringCharge  // [K]
    //let coldTankTemperature = C158
    //let p_Th_Tes_Charge(Nominal) = C210
    let htfNominalMassFlowInPbHex = C155
    let chargeHtfMassFlowThroughTes = C209

    //  Calculation
    let sfInletTemperatureAtSfToPb_TesMode = htf.temperature(
      (htf.enthalpy(coldTankTemperature + approachTemperatureInTesHeatExchangerDuringCharge)
        * chargeHtfMassFlowThroughTes + htf.enthalpy(C622) * htfNominalMassFlowInPbHex)
        / (htfNominalMassFlowInPbHex + chargeHtfMassFlowThroughTes))
    let totalHtfMassFlowToSf = chargeHtfMassFlowThroughTes + htfNominalMassFlowInPbHex
    let htfMassFlowToPowerBlockAtDesignPoint = htfNominalMassFlowInPbHex / totalHtfMassFlowToSf
    //  Results
    let sfInletTemperature = sfInletTemperatureAtSfToPb_TesMode
    let totalHtfMassFlowToSf = C631
    let massFlowToPowerBlockAtDesignPoint = htfMassFlowToPowerBlockAtDesignPoint

    let htfPressureDropsAndAuxiliaryPowerConsumptionInHexAndPb
    //  InputValues
    let tesHexHtfPressureDropAtDesignMassFlowOfDecisiveCase = 1  //'In - OutputSummary'!C30
    let htfPressureDropInPbHexAt100_SolarMode = 1  //'In - OutputSummary'!C31
    let functionOfPressureDropVsMassFlow = function_of_pressure_drop_vs_mass_flow
    let importedValuesFromPreviousInputsUndCalculations
    let sfInletTemperatureAtSfToPbTesMode = sfInletTemperature
    let htfPbHexOutletTemperatureDischarging = pbHexHtfOutletTemperatureDischarging

    let totalChargeHtfMassFlowThroughTesHex = C209
    let tesHexTrainsPerTwoTankSystemInActionDuringDesignCharge = C340
    let totalDischargeHtfMassFlowTesOnlyMode = C156
    // let tesHexTrainsPerTwoTankSystemInActionDuringDischarge = tesHexTrainsPerTwoTankSystemInActionDuringDischarge
    // let totalNumberOfTanks = totalNumberOfTanks

    let htfMassFlowInPbAt100_SolarMode = C155
    //  Calculation
    let tesHexHtfMassFlowAtNominalChargeModePerTrain =
      totalChargeHtfMassFlowThroughTesHex / (totalNumberOfTanks / 2)
      / tesHexTrainsPerTwoTankSystemInActionDuringDesignCharge
    let tesHexHtfMassFlowAtNominalDischargeModePerTrain =
      totalDischargeHtfMassFlowTesOnlyMode / (totalNumberOfTanks / 2)
      / tesHexTrainsPerTwoTankSystemInActionDuringDischarge
    let nominalHtfMassFlowInOneTesHexTrainOfDecisiveCase = max(
      tesHexHtfMassFlowAtNominalChargeModePerTrain, tesHexHtfMassFlowAtNominalDischargeModePerTrain)

    let htfPressureDropInTesHexAtDesignChargeMode =
      tesHexHtfPressureDropAtDesignMassFlowOfDecisiveCase
      * (tesHexHtfMassFlowAtNominalChargeModePerTrain
        / nominalHtfMassFlowInOneTesHexTrainOfDecisiveCase)
      ** C642
    let powerConsumptionForPushingHtfThroughTesHexDuring100Charge =
      totalChargeHtfMassFlowThroughTesHex / htf.density(sfInletTemperatureAtSfToPbTesMode)
      * htfPressureDropInTesHexAtDesignChargeMode * 10 ** 5 / 10 ** 6 / 0.7  // [Mwe]

    let htfPressureDropInTesHexAtDesignDischargeMode =
      tesHexHtfPressureDropAtDesignMassFlowOfDecisiveCase
      * (tesHexHtfMassFlowAtNominalDischargeModePerTrain
        / nominalHtfMassFlowInOneTesHexTrainOfDecisiveCase) ** C642
    let powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge =
      totalDischargeHtfMassFlowTesOnlyMode / htf.density(htfPbHexOutletTemperatureDischarging)
      * htfPressureDropInTesHexAtDesignDischargeMode * 10 ** 5 / 10 ** 6 / 0.7  // [Mwe]

    let htfPressureDropInPbHexAtDesignDischargeMode =
      htfPressureDropInPbHexAt100_SolarMode
      * (totalDischargeHtfMassFlowTesOnlyMode / htfMassFlowInPbAt100_SolarMode)
      ** functionOfPressureDropVsMassFlow
    let powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge =
      totalDischargeHtfMassFlowTesOnlyMode / htf.density(htfPbHexOutletTemperatureDischarging)
      * htfPressureDropInPbHexAtDesignDischargeMode * 10 ** 5 / 10 ** 6 / 0.7  // [Mwe]
    //  Results
    let powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge =
      powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge  // [Mwe]
    let powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge =
      powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge  // [Mwe]

    //  DischargeAuxiliaryPowerFactor
    //  ImportedValuesFromPreviousInputsUndCalculations
    // let nominalAuxiliaryPowerConsumptionDischargeModeSaltPumpsOnly = nominalAuxiliaryPowerConsumptionDischargeModeSaltPumpsOnly
    // let powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge = powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge // [Mwe]
    // let powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge = powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge // [Mwe]
    //  Calculation
    let htfSaltPumpAuxiliaryLoadDuringDischarge =
      nominalAuxiliaryPowerConsumptionDischargeModeSaltPumpsOnly / 1_000
      + powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge
      + powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge

    //  Results
    //let =B677 = htfSaltPumpAuxiliaryLoadDuringDischarge

    //  HeatLossesTesTanks
    //  InputValues

    let alphaInsulationToAir = alpha_insulation_to_air

    let lambdaInsulationCalculationCoefficientAColdTank =
      lambda_insulation_calculation_coefficient_a_cold_tank  // [W / (M * K * °C)]
    let lambdaInsulationCalculationCoefficientBColdTank =
      lambda_insulation_calculation_coefficient_b_cold_tank  // [W / (M * K)]
    let thicknessTankShellInsulationColdTank = thickness_Tank_Shell_Insulation_Cold_Tank
    let thicknessTankRoofInsulationColdTank = thickness_Tank_Roof_Insulation_Cold_Tank
    let lambdaFoundationColdTank = lambda_foundation_cold_tank  // [W / M * K]
    let thicknessFoundationColdTank = thickness_Foundation_Cold_Tank

    let lambdaInsulationCalculationCoefficientAHotTank =
      lambda_insulation_calculation_coefficient_a_hot_tank  // [W / (M * K * °C)]
    let lambdaInsulationCalculationCoefficientBHotTank =
      lambda_insulation_calculation_coefficient_b_hot_tank  // [W / (M * K)]
    let thicknessTankShellInsulationHotTank = thickness_Tank_Shell_Insulation_Hot_Tank
    let thicknessTankRoofInsulationHotTank = thickness_Tank_Roof_Insulation_Hot_Tank
    let lambdaFoundationHotTank = lambda_Foundation_Hot_Tank__W_M_K  // [W / M * K]
    let thicknessFoundationHotTank = thickness_Foundation_Hot_Tank

    let factorThermalBridgesRoofAndShell = factor_Thermal_Bridges_Roof_And_Shell
    let factorThermalBridgesBottom = factor_Thermal_Bridges_Bottom

    let ambientTemperature = estimated_Average_Ambient_Temperature
    let soilTemperature = estimated_Average_Soil_Temperature

    // importedValuesFromPreviousInputsAndCalculations
    let tankHeightBottomRim = Iferror(C478, 14)
    let tankDiameter = Iferror(C400, 38)
    let coldTankTemperature = Iferror(C158, 280)
    let hotTankTemperature = Iferror(C123, 386)
    let quantityOfTanks = Iferror(totalNumberOfTanks, 2)

    //  Calculation

    let tankAreaShell = .pi * tankDiameter * tankHeightBottomRim
    let bendingRadiusRoof = 1.5 * tankDiameter
    let heightRoof = bendingRadiusRoof - (bendingRadiusRoof ** 2 - tankDiameter ** 2 / 4) ** 0.5
    let tankAreaRoof = 2 * .pi * bendingRadiusRoof * heightRoof
    let tankAreaBottom = .pi * tankDiameter ** 2 / 4

    //  ColdTank:

    //  Shell:
    let temperatureOuterWallInsulationColdTank = 17.5619897785805
    let temperatureInsulationEffectiveColdTank =
      (coldTankTemperature + temperatureOuterWallInsulationColdTank) / 2
    let lambdaInsulationEffectiveColdTank =
      lambdaInsulationCalculationCoefficientAColdTank * temperatureInsulationEffectiveColdTank
      + lambdaInsulationCalculationCoefficientBColdTank
    let diameter_IColdTank = tankDiameter
    let diameter_AColdTank = diameter_IColdTank + 2 * thicknessTankShellInsulationColdTank
    let heatLossesShellColdTank =
      (temperatureOuterWallInsulationColdTank - ambientTemperature)
      * (.pi * diameter_AColdTank * tankHeightBottomRim * alphaInsulationToAir)
    let heatLossesShellColdTank =
      (1 + factorThermalBridgesRoofAndShell) * tankHeightBottomRim * .pi
      * (coldTankTemperature - ambientTemperature)
      / (1 / (2 * lambdaInsulationEffectiveColdTank) * log(diameter_AColdTank / diameter_IColdTank)
        + 1
        / (alphaInsulationToAir * diameter_AColdTank))
    let differenceOfHeatLossShellColdTankForIteration = C731 - C732
    //let spec.HeatLossesShellColdTank = C732 / tankAreaShell
    //let iterationSuccessful?["Ok" / "Iterate!"] = If(Abs(C731 - C732)<0.1,"Ok","Iterate!")
    //  Roof:
    let temperatureOuterWallInsulationColdTankForIteration = 17.5794213728555
    let temperatureInsulationEffectiveColdTank =
      (coldTankTemperature + temperatureOuterWallInsulationColdTankForIteration) / 2
    let lambdaInsulationEffectiveColdTank =
      lambdaInsulationCalculationCoefficientAColdTank * temperatureInsulationEffectiveColdTank
      + lambdaInsulationCalculationCoefficientBColdTank
    let kValueRoofColdTank = (C690 / lambdaInsulationEffectiveColdTank) ** -1
    let specHeatLossesRoofColdTank =
      (1 + factorThermalBridgesRoofAndShell) * kValueRoofColdTank
      * (coldTankTemperature - T_Outer_Roof_Cold_1)
    var heatLossesRoofColdTank = specHeatLossesRoofColdTank * tankAreaRoof
    heatLossesRoofColdTank =
      (temperatureOuterWallInsulationColdTankForIteration - ambientTemperature)
      * (tankAreaRoof * alphaInsulationToAir)
    let differenceOfHeatLossRoofColdTankForIteration =
      heatLossesRoofColdTank - heatLossesRoofColdTank
    //let iterationSuccessful?["Ok" / "Iterate!"] = If(Abs(heatLossesRoofColdTank - heatLossesRoofColdTank)<0.1,"Ok","Iterate!")
    //  Bottom:
    let kValueBottomColdTank = lambdaFoundationColdTank / thicknessFoundationColdTank
    let specHeatLossesBottomColdTank =
      (1 + factorThermalBridgesBottom) * kValueBottomColdTank
      * (coldTankTemperature - soilTemperature)
    let heatLossesBottomColdTank = specHeatLossesBottomColdTank * tankAreaBottom

    let heatLossesOneColdTank =
      (heatLossesShellColdTank + heatLossesRoofColdTank + heatLossesBottomColdTank) / 1_000
    let heatLossesAllColdTanks = heatLossesOneColdTank * totalNumberOfTanks / 2

    //let hotTank:
    //  Shell:
    let temperatureOuterWallInsulationHotTank = 17.9544435304503
    let temperatureInsulationEffectiveHotTank =
      (hotTankTemperature + temperatureOuterWallInsulationHotTank) / 2
    let lambdaInsulationEffectiveHotTank =
      lambdaInsulationCalculationCoefficientAHotTank * temperatureInsulationEffectiveHotTank
      + lambdaInsulationCalculationCoefficientBHotTank
    let diameter_IHotTank = tankDiameter
    let diameter_AHotTank = diameter_IHotTank + 2 * thicknessTankShellInsulationHotTank
    let heatLossesShellHotTank =
      (1 + factorThermalBridgesRoofAndShell) * tankHeightBottomRim * .pi
      * (hotTankTemperature - ambientTemperature)
      / (1 / (2 * lambdaInsulationEffectiveHotTank) * Ln(diameter_AHotTank / diameter_IHotTank) + 1
        / (alphaInsulationToAir * diameter_AHotTank))
    let heatLossesShellHotTank =
      (C756 - ambientTemperature)
      * (.pi * diameter_AHotTank * tankHeightBottomRim * alphaInsulationToAir)
    //let differenceOfHeatLossShellHotTank(ForIteration) = heatLossesShellHotTank - heatLossesShellHotTank
    //let spec.HeatLossesShellHotTank = heatLossesShellHotTank / tankAreaShell
    //let iterationSuccessful?["Ok" / "Iterate!"] = If(Abs(heatLossesShellHotTank - C762)<0.1,"Ok","Iterate!")
    //  Roof:
    //let temperatureOuterWallInsulationHotTank[°C](ForIteration)	17.9822336749726
    let temperatureInsulationEffectiveHotTank =
      (hotTankTemperature + temperatureOuterWallInsulationHotTank) / 2
    let lambdaInsulationEffectiveHotTank =
      lambdaInsulationCalculationCoefficientAHotTank * temperatureInsulationEffectiveHotTank
      + lambdaInsulationCalculationCoefficientBHotTank
    let kValueRoofHotTank =
      (thicknessTankRoofInsulationHotTank / lambdaInsulationEffectiveHotTank) ** -1
    let specHeatLossesRoofHotTank =
      (1 + factorThermalBridgesRoofAndShell) * kValueRoofHotTank
      * (hotTankTemperature - T_Outer_Roof_Hot_1)
    let heatLossesRoofHotTank = C771 * tankAreaRoof
    let heatLossesRoofHotTankOuterShellToAmbient =
      (T_Outer_Roof_Hot_1 - ambientTemperature) * (tankAreaRoof * alphaInsulationToAir)
    //let differenceOfHeatLossRoofHotTank(ForIteration) = heatLossesRoofHotTankOuterShellToAmbient - heatLossesRoofHotTank
    //let iterationSuccessful?["Ok" / "Iterate!"] = If(Abs(heatLossesRoofHotTank - heatLossesRoofHotTankOuterShellToAmbient)<0.1,"Ok","Iterate!")
    //  Bottom:
    let kValueBottomHotTank = lambdaFoundationHotTank / thicknessFoundationHotTank
    let heatLossesBottomHotTank =
      (1 + C702) * kValueBottomHotTank * (hotTankTemperature - soilTemperature)
    let heatLossesBottomHotTank = heatLossesBottomHotTank * tankAreaBottom

    let heatLossesOneHotTank =
      (heatLossesShellHotTank + heatLossesRoofHotTank + heatLossesBottomHotTank) / 1_000
    let heatLossesAllHotTanks = heatLossesOneHotTank * quantityOfTanks / 2
    //  Iteration2:
    //  Results
    //let iterationSuccessful?["Ok" / "Iterate!"] = If(Abs(C731 - C732)>0.1,"Iterate!",If(Abs(heatLossesRoofColdTank - C743)>0.1,"Iterate!",If(Abs(heatLossesShellHotTank - heatLossesShellHotTank)>0.1,"Iterate!",If(Abs(heatLossesRoofHotTank - heatLossesRoofHotTankOuterShellToAmbient)>0.1,"Iterate!","Ok"))))
    // let heatLossesAllColdTanks = heatLossesAllColdTanks
    // let heatLossesAllHotTanks = heatLossesAllHotTanks

    //  PressureDropFactorCalculationForPct
    //  UserAndExpertInputs
    let storagePumpEff = default_Salt_Pump_Efficiency

    //  ImportedValuesFromPreviousResultsAndInputs
    let htfTemperatureAtTesHexInletDuringCharge = htfPbHexInletTemperature

    let htfPbHexOutletTemperature = htfPbHexNominalOutletTemperature
    let chargeHtfMassFlowThroughTesHex = C215  // [Kg/S]
    let dischargeHtfMassFlowThroughTesHex = dischargeHtfMassFlowThroughTes_PbHex
    let htfTemperatureTesHexInletAtDischarge = pbHexHtfOutletTemperatureDischarging
    let htfTemperatureTesHexOutletAtDischarge = htfPbHexInletTemperatureDischarging
    let nominalAuxiliaryPowerConsumptionChargeModeSaltPumpsOnly = C614
    //let = B677 = htfSaltPumpAuxiliaryLoadDuringDischarge
    let htfTemperatureAtTesHexOutletDuringCharge = Htfinsto.Tout = C159

    //  CalculationsForChargeMode
    let rohDPCharge = htf.density((htfPbHexInletTemperature + htfPbHexOutletTemperature) / 2)
    let prl =
      (nominalAuxiliaryPowerConsumptionChargeModeSaltPumpsOnly / 1_000) * rohmeanCharge
      * storagePumpEff
      * 10 ** 6 / chargeHtfMassFlowThroughTesHex
    let rohmeanCharge = htf.density(
      (htfTemperatureAtTesHexInletDuringCharge + htfTemperatureAtTesHexOutletDuringCharge) / 2)
    let storagePressurelossDP =
      prl * rohmeanCharge / rohDPCharge
      * (chargeHtfMassFlowThroughTesHex / chargeHtfMassFlowThroughTesHex) ** 2  // [Pa](DeterminesSalt - ParasiticsAtChargeMode)

    //  CalculationsForDischargeMode
    let rohmeanDischarge = htf.density(
      (htfTemperatureTesHexInletAtDischarge + htfTemperatureTesHexOutletAtDischarge) / 2)
    let prlAtDischargeMode =
      storagePressurelossDP * (rohDPCharge / rohmeanDischarge)
      * (dischargeHtfMassFlowThroughTesHex / chargeHtfMassFlowThroughTesHex) ** 2  // [N / M²]
    let chargeParasiticsAtDischargeMode =
      prlAtDischargeMode * dischargeHtfMassFlowThroughTesHex / rohmeanDischarge / storagePumpEff
      / 10
      ** 6
    let factorForAuxiliariesDuringStorageDischarge =
      htfSaltPumpAuxiliaryLoadDuringDischarge / chargeParasiticsAtDischargeMode  // (Htf.PumpsIncl.)[Non - Dim.]

  }*/
  //  Results
  //storagePressurelossDP
  //factorForAuxiliariesDuringStorageDischarge //  (Htf.PumpsIncl.)[Non - Dim.]
}
precedencegroup ExponentiationPrecedence {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiationPrecedence
infix operator **=: AssignmentPrecedence

extension Double {
  static func ** (lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
  }

  static func **= (lhs: inout Double, rhs: Double) {
    lhs = lhs ** rhs
  }
}