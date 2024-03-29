import Libc
import Utilities

struct TES {
  enum Mode { case charge, discharge }
  let salt = StorageMedium.solarSalt.properties
  let htf = HeatTransferFluid.VP1

  let minSaltMassFlowPerPump_KgS = 260.0
  let lowSaltMassFlow_KgS = 420.0
  let minLevelAtLowSaltMassFlow = 0.6
  let maxSaltMassFlowPerPump_KgS = 1000.0
  let minLevelAtMaxSaltMassFlow = 1.5
  let maxPumpsPerTank = 4.0
  let pThMaxPerTrainWTh = 130.0
  let maximumTrainQuant_Per_2TankSystem = 4.0
  let maxActiveTankHeight = 15.0
  let maxTankDiameter = 38.5
  let requestedMinimumPossiblePartLoadCharge = 0.2
  let maxTurnDownRatioPer_HEXTrain = 0.3
  let tesDesignTotalHeadAtHighestSaltFlow = 63.0
  let tankHeightDiameterRatioOfActiveSaltVolume = 0.3506
  let freeBoardAllowance = 0.35
  let pumpSuctionClearance_DistanceSuctionInletToTankFloor = 0.257
  let tankRoofRadiusFactor_Radius_Factor_TankDiameter = 1.5
  let horizontalDistance_Pump_TankWall = 2.5
  let vertDistanceTankRoofPumpMountingPlate = 2.5
  let verticalDistanceBetween_HEXLevelAndPumpMountLevel = 0.0
  let pressureDropPipingAndValvesDesignChargeMassFlow = 0.500
  let pressureDropHotTankSpargerEductorSystem = 1.7
  let pressureDropColdTankSpargerEductorSystem = 2.0
  let functionOfPressureDropVsMassFlow = 2.0
  let defaultSaltPumpEfficiency = 73.0
  let pumpAuxResolutionInterval = 10.0

  let pumpCharacteristics = Polynomial([
    58.0392873368767, 0.00543837439333072, -3.55755682196363E-07,
  ])

  // Heat loss parameters
  let alphaInsulationToAir = 20.0
  let lambdaInsulationCalculationCoefficientAColdTank = 0.000
  let lambdaInsulationCalculationCoefficientBColdTank = 0.031
  let thicknessTankShellInsulationColdTank = 0.300
  let thicknessTankRoofInsulationColdTank = 0.300
  let lambdaFoundationColdTank = 0.411
  let thicknessFoundationColdTank = 2.400

  let lambdaInsulationCalculationCoefficientAHotTank = 0.000
  let lambdaInsulationCalculationCoefficientBHotTank = 0.031
  let thicknessTankShellInsulationHotTank = 0.400
  let thicknessTankRoofInsulationHotTank = 0.400
  let lambdaFoundationHotTank = 0.398
  let thicknessFoundationHotTank = 2.400

  let factorThermalBridgesRoofAndShell = 15.0
  let factorThermalBridgesBottom = 10.0

  let estimatedAverageAmbientTemperature = Temperature(celsius: 15.0)
  let estimatedAverage_SoilTemperature = Temperature(celsius: 10.0)

  // Standard TES Mode Conditions
  let saltMassSafetyMargin = 3.0
  let tempLossCharge = 7.0
  let tempLossDischarge = 7.0
  let saltPDrop_100 = 4.62
  let TES_HXPLoss_100 = 5.0

  let temperatureLossCharge = 7.0
  let temperatureLossDischarge = 7.0

  // Design Conditions (100%_SolarMode)
  let turbineEfficiencyGross = 38.42
  let thermalNominalCapacityOfPb = 156.2
  let turbineGrossElectricalOutput: Double

  let htfPbHexInletTemperature = Temperature(celsius: 393.0)
  let htfPbHexNominalOutletTemperature = Temperature(celsius: 296.3)
  let solarCapacityMultiplyer = 2.0

  //  Definition Of Tes Mode
  let thermalDischargeRateOfTes = 78.0
  let tesStorageCapacity = 1406.0
  let activeSaltMassSafetyMargin = 3.0
  let approachTemperatureInTesHeatExchangerDuringCharge = 7.0  // [K]
  let approachTemperatureInTesHeatExchangerDuringDischarge = 7.0  // [K]

  init() {
    self.turbineGrossElectricalOutput =
      thermalNominalCapacityOfPb * turbineEfficiencyGross
  }

  mutating func callAsFunction() {
    // Calculation Of Tes Mode
    let hotTankTemperature = htfPbHexInletTemperature - temperatureLossCharge
    let htfPbHexInletTemperatureDischarging =
      htfPbHexInletTemperature - temperatureLossCharge
      - temperatureLossDischarge

    //let htfPbHexNominalOutletTemperature = htfPbHexNominalOutletTemperature
    let thermalNominalPowerOfPb = thermalNominalCapacityOfPb
    let htfPbHexInletTemperatureAt100_SolarMode = htfPbHexInletTemperature
    let htfPbHexOutletTemperatureAt100_SolarMode =
      htfPbHexNominalOutletTemperature
    // let approachTemperatureInTesHeatExchangerDuringCharge = approachTemperatureInTesHeatExchangerDuringCharge
    let tesModeHtfHexInletTemperature = htfPbHexInletTemperatureDischarging
    let thermalDischargeRateOfTesOfNominalPbHtfMassFlow =
      thermalDischargeRateOfTes
    let nominalHtfMassFlowInPbHexAt100_SolarMode =
      thermalNominalPowerOfPb * 1_000
      / (htf.enthalpy(htfPbHexInletTemperatureAt100_SolarMode)
        - htf.enthalpy(htfPbHexOutletTemperatureAt100_SolarMode))
    //  CoefficientsForHtfHexPartLoadFunction
    func HtfHexPartLoad(at temperature: Temperature) -> Double {
      let (a, b, c, d, e) = (
        0.000759241986926377, 0.494382589322317, 0.000140082388237702,
        -0.0110227028559065, -0.000151638913322927
      )
      return (a * temperature.kelvin + b)
        * thermalDischargeRateOfTesOfNominalPbHtfMassFlow
        ** (c * temperature.kelvin + d) + e  //  [%_K]
    }

    let totalT_Hex_OutFactor = HtfHexPartLoad(
      at: tesModeHtfHexInletTemperature)
    let htfPbHexOutletTemperatureDischarging = Temperature(
      htfPbHexNominalOutletTemperature.kelvin * totalT_Hex_OutFactor)
    let totalHtfMassFlowDischarging =
      thermalDischargeRateOfTesOfNominalPbHtfMassFlow
      * nominalHtfMassFlowInPbHexAt100_SolarMode  //  [Kg / S]
    let thermalPowerPb_TesDischarging =
      (htf.enthalpy(tesModeHtfHexInletTemperature)
        - htf.enthalpy(htfPbHexOutletTemperatureDischarging))
      * totalHtfMassFlowDischarging / 1_000  //
    let coldTankTemperature =
      htfPbHexOutletTemperatureDischarging + temperatureLossDischarge  //  [°C]
    let htfTemperatureAtTesHexOutletDuringCharge =
      coldTankTemperature + approachTemperatureInTesHeatExchangerDuringCharge  //  [°C]

    let thermalPowerOfPb_TesDischarging = thermalPowerPb_TesDischarging
    // let nominalHtfMassFlowInPbHexAt100_SolarMode = nominalHtfMassFlowInPbHexAt100_SolarMode
    let dischargeHtfMassFlowThroughTes_PbHex = totalHtfMassFlowDischarging
    // htfPbHexOutletTemperatureDischarging
    // htfTemperatureAtTesHexOutletDuringCharge

    //  Determination Of Tes Mode Turbine Efficiency

    // let htfPbHexInletTemperatureDischarging = htfPbHexInletTemperatureDischarging
    // let =B109 = thermalNominalCapacityOfPb
    // let thermalPowerOfPb_TesDischarging = thermalPowerOfPb_TesDischarging

    let dischargeLoadRatio =
      thermalPowerOfPb_TesDischarging / thermalNominalCapacityOfPb
    // pbEfficiency=F(Load)

    func pbEfficiency(at load: Double) -> Double {
      let c = (0.6526, 1.1839, -1.8611, 1.5008, -0.4761)
      return c.0 + c.1 * load ** 1.0 + c.2 * load ** 2.0 + c.3 * load ** 3.0
        + c.4 * load ** 4.0
    }
    let efficiencyFactorLoad = pbEfficiency(at: dischargeLoadRatio)

    let efficiencyAtNewLoad = turbineEfficiencyGross * efficiencyFactorLoad

    // pbEfficiency=F(Temp)

    func pbEfficiency(at temperature: Temperature) -> Double {
      let (a, c, x) = (0.998122828278924, 0.2383, 0.2404)
      return (c * temperature.celsius ** x) * a
    }
    let efficiencyFactorTemperature = pbEfficiency(
      at: htfPbHexInletTemperatureDischarging)

    let efficiencyAtNewTemp =
      turbineEfficiencyGross * efficiencyFactorTemperature

    let turbineEfficiencyDischarging =
      turbineEfficiencyGross * efficiencyFactorLoad
      * efficiencyFactorTemperature
    let turbineGrossElectricalOutputDischarging =
      thermalPowerOfPb_TesDischarging * turbineEfficiencyDischarging

    let dischargeLoadOfTes = dischargeLoadRatio

    // (Thermal) Equivalent Full Load Hours
    let nominalThermalPbPower = thermalNominalCapacityOfPb

    let htfMassFlowThroughSfAt100_SolarMode =
      solarCapacityMultiplyer * nominalHtfMassFlowInPbHexAt100_SolarMode
    let chargeHtfMassFlowThroughTesHex =
      htfMassFlowThroughSfAt100_SolarMode
      - nominalHtfMassFlowInPbHexAt100_SolarMode
    let p_Th_Tes_ChargeNominalThermalPowerToTesInChargeMode =
      chargeHtfMassFlowThroughTesHex / 1_000.0
      * (htf.enthalpy(htfPbHexInletTemperature)
        - htf.enthalpy(
          coldTankTemperature
            + approachTemperatureInTesHeatExchangerDuringCharge))
    let nominalChargeTime =
      tesStorageCapacity / p_Th_Tes_ChargeNominalThermalPowerToTesInChargeMode
    let thermalEquivalentFullLoadHours =
      tesStorageCapacity / nominalThermalPbPower

    let nominalChargeTimeForNominalChargePower = nominalChargeTime
    // chargeHtfMassFlowThroughTesHex
    // p_Th_Tes_ChargeNominalThermalPowerToTesInChargeMode

    // let tesStorageCapacity = Calc_Tes_Cap
    let tesModeThermalPbPowerInTesMode = thermalPowerOfPb_TesDischarging

    let dischargeTimeAtDesignDischargeLoad =
      tesStorageCapacity / tesModeThermalPbPowerInTesMode
    let electricalOutputOfTesForCompleteDischarge =
      turbineGrossElectricalOutputDischarging
      * dischargeTimeAtDesignDischargeLoad
    let electricalEquivalentFullLoadHours =
      electricalOutputOfTesForCompleteDischarge / turbineGrossElectricalOutput

    // electricalOutputOfTesForCompleteDischarge
    // electricalEquivalentFullLoadHours
    // dischargeTimeAtDesignDischargeLoad

    // saltMassFlows(SfToPb&TesMode)

    let p_Th_Tes_DischargeNominal = thermalPowerPb_TesDischarging
    let p_Th_Tes_ChargeNominal =
      p_Th_Tes_ChargeNominalThermalPowerToTesInChargeMode

    // let totalActiveSaltMass = If(
    //   Act_Salt_Mass = 0,
    //   If(
    //     Not(Tes_Cap = ""),
    //     Tes_Cap * 3_600 * 1_000 / (salt.enthalpy(hotTankTemperature) - salt.enthalpy(coldTankTemperature)) / 1000,
    //     "CheckInputParameter"), If(Tes_Cap = "", Act_Salt_Mass, "CheckInputParameter"))

    let decisiveCaseForTesDesign: Mode =
      p_Th_Tes_DischargeNominal > p_Th_Tes_ChargeNominal ? .discharge : .charge
    let modeRatio = p_Th_Tes_ChargeNominal / p_Th_Tes_DischargeNominal  // (<0,4:VeryBad;<1:Bad;1 - 3:Good;>3:Bad)
    let chargeSaltMassFlow =
      p_Th_Tes_ChargeNominal * 1_000
      / (salt.enthalpy(hotTankTemperature) - salt.enthalpy(coldTankTemperature))
    let dischargeSaltMassFlow =
      p_Th_Tes_DischargeNominal * 1_000
      / (salt.enthalpy(hotTankTemperature) - salt.enthalpy(coldTankTemperature))

    let totalActiveSaltMass = 0.0  //C246
    // let decisiveCaseForTesDesign = 0.0  //C249

    // tesHexsDesignValues(Total)
    let p_Th_MaxPerTesHexTrain = pThMaxPerTrainWTh
    let maximumTrainQuantPerTwoTankSystem =
      maximumTrainQuant_Per_2TankSystem
    let requestedMinimumPossiblePartLoadCharge =
      requestedMinimumPossiblePartLoadCharge
    let maxTurnDownRatioPerHexTrain = maxTurnDownRatioPer_HEXTrain

    let thermalPbPowerDischarging = p_Th_Tes_DischargeNominal

    let designTotalThermalTesHexsPower = max(
      thermalPbPowerDischarging, p_Th_Tes_ChargeNominal)
    let designTotalSaltMassFlow = max(
      chargeSaltMassFlow, dischargeSaltMassFlow)

    let necessaryTrainsFromMaxDuty =
      designTotalThermalTesHexsPower / p_Th_MaxPerTesHexTrain
    let maximumDesignDutyPerHexTrain =
      p_Th_Tes_ChargeNominal * requestedMinimumPossiblePartLoadCharge
      / maxTurnDownRatioPerHexTrain
    let necessaryTrainsParallelTrainsPerTwoTankSystemFromPartLoadRequirements =
      max(thermalPbPowerDischarging, p_Th_Tes_ChargeNominal)
      / maximumDesignDutyPerHexTrain
    let tankSystemsInParallelFromPartLoadRequir =
      (necessaryTrainsParallelTrainsPerTwoTankSystemFromPartLoadRequirements
      / maximumTrainQuantPerTwoTankSystem)
      .rounded(.up)
    let tankSystemsInParallelFromHexMaxDuty =
      (necessaryTrainsFromMaxDuty / maximumTrainQuantPerTwoTankSystem)
      .rounded(.up)

    let tankSystemsInParallelFromHexLimitations = max(
      tankSystemsInParallelFromPartLoadRequir,
      tankSystemsInParallelFromHexMaxDuty)

    let maxSaltMassFlowPerTwoTankSystem = 0.0  // C293 * C291
    let tankSystemsInParallelFromPumpConditions = 0.0  //(C295 / C298).rounded(up)

    /// let tankSystemsInParallelFromPumpConditions = C299

    //let tesTankDesignValues(PreliminaryForSizeEstimation)

    let maxActiveTankHeight = maxActiveTankHeight
    let maxTankDiameter = maxTankDiameter

    let activeSaltMassSafetyMargin = 0.0  //C118
    let totalActiveSaltMassForPerformanceCalculation = 0.0  //Act_Salt_Mass

    let totalActiveSaltMassInclSafetyMarginForTankSizing =
      totalActiveSaltMassForPerformanceCalculation
      + totalActiveSaltMassForPerformanceCalculation
      * activeSaltMassSafetyMargin
    let totalSaltMassFromHexTrainsEstimate =
      designTotalThermalTesHexsPower * (400.0 / 130.0)
    let totalActiveSaltMassInclSafetyMargin =
      totalSaltMassFromHexTrainsEstimate
      + totalActiveSaltMassInclSafetyMarginForTankSizing

    let minNecessaryActiveTankHeightToAccomodateActiveSaltMass =
      totalActiveSaltMassInclSafetyMargin * 1_000.0
      / salt.density(hotTankTemperature) / (maxTankDiameter ** 2.0 / 4.0 * .pi)
    let minNecessaryTankDiameterToAccomodateActiveSaltMass = sqrt(
      4.0 / .pi
        * (totalActiveSaltMassInclSafetyMargin * 1_000.0
          / salt.density(hotTankTemperature) / (maxActiveTankHeight)))
    let tankSystemsInParallelFromTankConditionsHeight =
      (minNecessaryActiveTankHeightToAccomodateActiveSaltMass
      / maxActiveTankHeight)
      .rounded(.up)

    //  TesTanks - Overview

    let totalNumberOfTanks =
      2.0
      * max(
        tankSystemsInParallelFromTankConditionsHeight,
        tankSystemsInParallelFromPumpConditions,
        tankSystemsInParallelFromHexLimitations)

    let minimumNumberOfTrainsTotal = max(
      (necessaryTrainsFromMaxDuty / (totalNumberOfTanks / 2.0)).rounded(.up)
        * (totalNumberOfTanks / 2.0),
      necessaryTrainsParallelTrainsPerTwoTankSystemFromPartLoadRequirements
        .rounded(.up) * (totalNumberOfTanks / 2))
    let minimumNumberOfTrainsPerTwoTankSystem =
      minimumNumberOfTrainsTotal / (totalNumberOfTanks / 2.0)
    let designHeatDutyPerTrain =
      max(p_Th_Tes_ChargeNominal, p_Th_Tes_DischargeNominal)
      / minimumNumberOfTrainsTotal
    let chargeDutyPerTwoTankSystem = 0.0  //C210 / (totalNumberOfTanks / 2)
    let tesHexTrainsPerTqoTankSystemInActionDuringNominal100Charge =
      (chargeDutyPerTwoTankSystem / designHeatDutyPerTrain).rounded(.up)
    // let saltFlowPerTrainDuringNominal100Charge =
    //   If(C249 = "Discharge", dischargeSaltMassFlow, designTotalSaltMassFlow)
    //   / tesHexTrainsPerTqoTankSystemInActionDuringNominal100Charge
    //   / (totalNumberOfTanks / 2)
    // let tesHexTrainsPerPerTwoTankSystemInActionDuring20Charge =
    //   (C339 * 0.2 / designHeatDutyPerTrain).rounded(.up)
    // let saltFlowPerTrainDuring20Charge =
    //   If(C249 = "Discharge", dischargeSaltMassFlow, designTotalSaltMassFlow)
    //   * 0.2 / tesHexTrainsPerPerTwoTankSystemInActionDuring20Charge
    //   / (totalNumberOfTanks / 2)
    // let tesHexTrainsPerTwoTankSystemInActionDuringDischarge =
    //   (p_Th_Tes_DischargeNominal / (totalNumberOfTanks / 2)
    //   / designHeatDutyPerTrain)
    //   .rounded(.up)
    // let saltFlowPerTrainDuringDischarge =
    //   If(C249 = "Charge", dischargeSaltMassFlow, designTotalSaltMassFlow)
    //   / tesHexTrainsPerTwoTankSystemInActionDuringDischarge
    //   / (totalNumberOfTanks / 2)

    let possibleNumberOfPumpsTotal = totalNumberOfTanks * maxPumpsPerTank
    let necessaryNumberOfPumpsPerColdTankCharging = 1.0  //If(Rounddown(C357 / (totalNumberOfTanks / 2) / minSaltMassFlowPerPump,0)<=1,1,If(Rounddown(chargeSaltMassFlow / (totalNumberOfTanks / 2) / minSaltMassFlowPerPump,0)<(C354 + 1),Rounddown(let c357 / (C385 / 2) / minSaltMassFlowPerPump,0),C354))
    let flowPerColdTankPumpCharging =
      chargeSaltMassFlow
      / (necessaryNumberOfPumpsPerColdTankCharging
        * (totalNumberOfTanks / 2.0))
    var minTankLevelInColdTankCharging = lowSaltMassFlow_KgS
    let C363 = 0.0
    let lowSaltMassFlow = lowSaltMassFlow_KgS
    let minSaltMassFlowPerPump = minSaltMassFlowPerPump_KgS
    let maxSaltMassFlowPerPump = maxSaltMassFlowPerPump_KgS
    let minLevelAtMaxSaltMassFlow = minLevelAtMaxSaltMassFlow
    if C363 > lowSaltMassFlow {
      minTankLevelInColdTankCharging +=
        (flowPerColdTankPumpCharging - lowSaltMassFlow)
        / (maxSaltMassFlowPerPump - lowSaltMassFlow)
        * (minLevelAtMaxSaltMassFlow - lowSaltMassFlow_KgS)
    }
    let totalSaltMassFlowDischarging = dischargeSaltMassFlow
    let C354 = 0.0
    let numberOfPumpsPerHotTankDischarging =
      (dischargeSaltMassFlow / (totalNumberOfTanks / 2)
        / minSaltMassFlowPerPump) < (C354 + 1)
      ? (dischargeSaltMassFlow / (totalNumberOfTanks / 2)
        / minSaltMassFlowPerPump)
        .rounded(.down) : C354
    let flowPerHotTankPumpDischarging =
      dischargeSaltMassFlow / numberOfPumpsPerHotTankDischarging
      / (totalNumberOfTanks / 2)
    let minTankLevelInHotTankDischarging =
      lowSaltMassFlow_KgS
      + (flowPerHotTankPumpDischarging > lowSaltMassFlow
        ? (flowPerHotTankPumpDischarging - lowSaltMassFlow)
          / (maxSaltMassFlowPerPump - lowSaltMassFlow)
          * (minLevelAtMaxSaltMassFlow - lowSaltMassFlow_KgS) : 0)

    // let numberOfPumpsPerColdTankCharging = necessaryNumberOfPumpsPerColdTankCharging
    // let numberOfPumpsPerHotTankDischarging = numberOfPumpsPerHotTankDischarging
    // let flowPerColdTankPumpCharging = flowPerColdTankPumpCharging
    // let flowPerHotTankPumpDischarging = flowPerHotTankPumpDischarging
    // let minTankLevelInColdTankCharging = C364
    // let minTankLevelInHotTankDischarging = minTankLevelInHotTankDischarging

    //let preliminaryResult:TotalNumberOfTanks = totalNumberOfTanks
    //let totalActiveSaltMassIncl.SafetyMargin + HexSaltMass[T] = totalActiveSaltMassInclSafetyMargin

    let twoTankActiveSaltMassInclSafetyMargin =
      totalActiveSaltMassInclSafetyMargin / (totalNumberOfTanks / 2)
    let twoTankActiveSaltVolumeInclSafetyMargin =
      twoTankActiveSaltMassInclSafetyMargin * 1_000.0
      / salt.density(hotTankTemperature)

    let minimumActiveHeightDiameterRatio =
      twoTankActiveSaltVolumeInclSafetyMargin
      / (.pi / 4 * maxTankDiameter ** 2) / maxTankDiameter
    let maximumActiveHeightDiameterRatio =
      maxActiveTankHeight
      / sqrt(
        twoTankActiveSaltVolumeInclSafetyMargin / maxActiveTankHeight
          * (4.0 / .pi))
    let setActiveHeightRatioDiameterRatio =
      tankHeightDiameterRatioOfActiveSaltVolume
    let actualTankDiameter =
      ((4 / .pi) * twoTankActiveSaltVolumeInclSafetyMargin
        / setActiveHeightRatioDiameterRatio) ** (1.0 / 3.0)
    let setActiveHeightRatio = 0.0
    let actualActiveTankHeightHot = setActiveHeightRatio * actualTankDiameter

    // let =B397 = C397 actualTankDiameter
    // let actualActiveTankHeightHot = actualActiveTankHeightHot
    // let twoTankActiveSaltMassInclSafetyMargin + SaltMassInHexTrains(PerTwo - TankSystem)[T] = twoTankActiveSaltMassInclSafetyMargin

    let minimumSaltLevelInColdTank = minTankLevelInColdTankCharging
    let minimumSaltLevelInHotTank = minTankLevelInHotTankDischarging
    let temperatureForTankSizeCalculationUpperDesignTemp = hotTankTemperature  //C123
    let tankDiameter = actualTankDiameter
    // let activeSaltMassInclSafetyMargin + SaltMassInHexTrainsPerTwo - TankSystem[T] = twoTankActiveSaltMassInclSafetyMargin
    let tankFloorArea = tankDiameter ** 2.0 / 4.0 * .pi

    let activeSaltVolumeInclSafetyMarginInColdTank =
      twoTankActiveSaltMassInclSafetyMargin * 1_000.0
      / salt.density(coldTankTemperature)
    let activeLevelChangeInColdTank =
      activeSaltVolumeInclSafetyMarginInColdTank / tankFloorArea  // (Sor / Eor)
    let upperOperationalColdTankFillLevel =
      activeLevelChangeInColdTank + minimumSaltLevelInColdTank

    let activeSaltVolumeInclSafetyMarginInHotTank =
      twoTankActiveSaltMassInclSafetyMargin * 1_000.0
      / salt.density(hotTankTemperature)
    let activeLevelChangeInHotTankSor_Eor =
      activeSaltVolumeInclSafetyMarginInHotTank / tankFloorArea
    let upperOperationalHotTankFillLevel =
      activeLevelChangeInHotTankSor_Eor + minimumSaltLevelInHotTank

    let coldTankDeadSaltVolume = minimumSaltLevelInColdTank * tankFloorArea
    let coldTankDeadSaltMass =
      coldTankDeadSaltVolume * salt.density(coldTankTemperature) / 1_000.0
    let hotTankDeadSaltVolume = minimumSaltLevelInColdTank * tankFloorArea
    let hotTankDeadSaltMass =
      hotTankDeadSaltVolume * salt.density(hotTankTemperature) / 1_000.0
    let totalSaltMassPerTwoTankSystem =
      twoTankActiveSaltMassInclSafetyMargin + coldTankDeadSaltMass
      + hotTankDeadSaltMass
    let totalSaltVolumePerTwoTankSystemInitialFill =
      totalSaltMassPerTwoTankSystem * 1_000
      / salt.density(temperatureForTankSizeCalculationUpperDesignTemp)
    let maximumDesignFillLevelInTankInitialFill =
      totalSaltVolumePerTwoTankSystemInitialFill / tankFloorArea

    // upperOperationalColdTankFillLevel
    // upperOperationalHotTankFillLevel
    // maximumDesignFillLevelInTank
    // coldTankDeadSaltMass
    // hotTankDeadSaltMass

    // totalSaltMass
    // importedValuesFromPreviousInputsUndCalculations
    //let totalNumberOfTanks = totalNumberOfTanks
    let totalActiveSaltMass_ForPerformanceCalculations_WithoutSafetyMargin =
      totalActiveSaltMassForPerformanceCalculation
    let activeSaltMassInclSafetyMargin = 0.0  //+ SaltMassInHexTrainsPerTwo - TankSystem[T] = C402
    //let coldTankDeadSaltMass = coldTankDeadSaltMass
    //let hotTankDeadSaltMass = hotTankDeadSaltMass

    let totalSaltMassInTesSystem =
      totalNumberOfTanks / 2.0
      * ((coldTankDeadSaltMass + hotTankDeadSaltMass)
        + activeSaltMassInclSafetyMargin)
    let totalSaltMassToBeBought =
      totalSaltMassInTesSystem / (1.0 - 0.001 - 0.0005)
    let fractionTotalDeadSaltMassVsTotalActiveSaltMassForPct =
      (coldTankDeadSaltMass + hotTankDeadSaltMass)
      / totalActiveSaltMass_ForPerformanceCalculations_WithoutSafetyMargin

    //let totalSaltMass[T](InTesSystem) = totalSaltMassInTesSystem
    //let totalSaltMass[T](ToBeBought) = totalSaltMassToBeBought
    // let fraction = fractionTotalDeadSaltMassVsTotalActiveSaltMassForPct

    let freeBoardAllowance = freeBoardAllowance
    let pumpSuctionClearance =
      pumpSuctionClearance_DistanceSuctionInletToTankFloor
    let tankRoofRadiusFactor =
      tankRoofRadiusFactor_Radius_Factor_TankDiameter
    let horizontalDistancePumpTankWall = horizontalDistance_Pump_TankWall
    let distanceBetweenTankRoofAndPumpMountingPlate =
      vertDistanceTankRoofPumpMountingPlate

    // let tankDiameter = Tank_Diam
    //let maximumFillLevelOfTanks(InitialFill) = maximumDesignFillLevelInTank
    let maximumDesignFillLevelInTank = 0.0
    let tankRoofRadius = tankDiameter * tankRoofRadiusFactor
    let verticalDistancePumpMountTankRim =
      (tankRoofRadius ** 2.0
        - (tankDiameter / 2.0 - horizontalDistancePumpTankWall) ** 2) ** 0.5
      - (tankRoofRadius ** 2.0 - (tankDiameter / 2.0) ** 2.0) ** 0.5
      + distanceBetweenTankRoofAndPumpMountingPlate
    let tankWallHeightBottomToRim =
      maximumDesignFillLevelInTank + freeBoardAllowance
    let maximumTankHeightAtTopBottomToTop =
      tankRoofRadius - (tankRoofRadius ** 2.0 - (tankDiameter / 2.0) ** 2.0)
      ** 0.5 + tankWallHeightBottomToRim
    let pumpShaftLengthPumpMountToSuctionInlet =
      tankWallHeightBottomToRim + verticalDistancePumpMountTankRim
      - pumpSuctionClearance

    let surfaceAreaOfTankRoof =
      2.0 * .pi * tankRoofRadius
      * (maximumTankHeightAtTopBottomToTop - tankWallHeightBottomToRim)
    let surfaceAreaOfCylindricalTankShell =
      tankWallHeightBottomToRim * .pi * tankDiameter

    //let =B471 = C471
    //let =B472 = C472
    //let pumpShaftLengthPumpMountToSuctionInlet = pumpShaftLengthPumpMountToSuctionInlet
    let surfaceAreaOfTankShellWithoutTankBottom =
      surfaceAreaOfCylindricalTankShell + surfaceAreaOfTankRoof

    //  TesPressureDrops,SaltHeadsAndAuxiliaries
    //let tesHexSaltPressureDropDuringDesignMode = 'In - OutputSummary'!C29
    let verticalDistanceBetweenHexLevelAndPumpMountLevel =
      verticalDistanceBetween_HEXLevelAndPumpMountLevel
    let pumpSuctionClearanceDistanceSuctionInletToTankFloor =
      pumpSuctionClearance_DistanceSuctionInletToTankFloor
    let pressureDropPipingAndValvesDesignChargeMassFlow =
      pressureDropPipingAndValvesDesignChargeMassFlow
    let pressureDropHotTankSpargerAtDesignChargeMassFlow =
      pressureDropHotTankSpargerEductorSystem
    let pressureDropColdTankSpargerAtDesignDischargeMassFlow =
      pressureDropColdTankSpargerEductorSystem
    let functionOfPressureDropVsMassFlow =
      functionOfPressureDropVsMassFlow
    let coldSaltDensity = salt.density(coldTankTemperature)  // [Kg / M³]
    let hotSaltDensity = salt.density(hotTankTemperature)
    let minimumTankLevelInColdTank = 0.0
    let nominalPressureInColdTank = 1.0
    let nominalPressureInHotTank = 1.0
    let physicalSuctionLimit1Barg = 0.0  // If(C550 < 1, 1, C550)
    let massFlowRatio = 1.0
    let tesHexSaltPressureDropDuringDesignMode = 0.0
    //let upperOperationalColdTankFillLevel = upperOperationalColdTankFillLevel
    //let upperOperationalHotTankFillLevel = upperOperationalHotTankFillLevel
    // let pumpShaftLengthPumpMountToSuctionInlet = C480

    // let totalNumberOfTanks = totalNumberOfTanks
    let numberOfPumpsPerColdTankCharging =
      necessaryNumberOfPumpsPerColdTankCharging
    // let numberOfPumpsPerHotTankDischarging = C373
    // let flowPerColdTankPumpCharging = C374  //  [Kg / S]
    // let flowPerHotTankPumpDischarging = C375  //  [Kg / S]

    // let designTotalSaltMassFlow = C282  //  [Kg / S]
    let totalChargeSaltMassFlow = 0.0  // C256  //  [Kg / S]
    // let dischargeSaltMassFlow = C257  //  [Kg / S]

    let verticalDistanceBetweenHexTrainOutletAndSparger =
      -(pumpShaftLengthPumpMountToSuctionInlet
      + verticalDistanceBetweenHexLevelAndPumpMountLevel)
    do {
      // ChargeAuxliliaries

      let actualTotalChargeMassFlow = massFlowRatio * totalChargeSaltMassFlow  // [Ks/S]
      let actualFlowPerColdTankPumpCharging =
        actualTotalChargeMassFlow
        / (numberOfPumpsPerColdTankCharging * totalNumberOfTanks / 2)

      let actualTesHexSaltPressureDropDuringDesignCharge =
        tesHexSaltPressureDropDuringDesignMode
        * (actualTotalChargeMassFlow / designTotalSaltMassFlow)
        ** functionOfPressureDropVsMassFlow
      let actualPressureDropPipingAndValvesDesignChargeMassFlow =
        pressureDropPipingAndValvesDesignChargeMassFlow
        * (actualTotalChargeMassFlow / designTotalSaltMassFlow)
        ** functionOfPressureDropVsMassFlow
      let actualPressureDropHotTankSparger =
        pressureDropHotTankSpargerAtDesignChargeMassFlow
        * (actualTotalChargeMassFlow / designTotalSaltMassFlow)
        ** functionOfPressureDropVsMassFlow

      // (0) - >(1)
      let nominalPressureInColdTank = 1.0
      let equivalentSaltHeadOfTankPressureCold =
        -nominalPressureInColdTank * 100_000.0 / (coldSaltDensity * 9.81)
      let activeSaltColumnColdTankAt100ChargedSystem =
        -minimumTankLevelInColdTank
        + pumpSuctionClearanceDistanceSuctionInletToTankFloor
      let pressureDifferenceAtmPumpSuctionInlet =
        activeSaltColumnColdTankAt100ChargedSystem * coldSaltDensity * 9.81
        / 100_000.0
      // (1) - >(2)
      let headFromPumpShaftLengthColdSide =
        pumpShaftLengthPumpMountToSuctionInlet
      let pressureDifferenceAlongPumpShaftLengthColdSide =
        headFromPumpShaftLengthColdSide * coldSaltDensity * 9.81 / 100_000.0
      let headFromPumpOutletToHexHeightColdSide =
        verticalDistanceBetweenHexLevelAndPumpMountLevel
      let pressureDifferenceAlongPumpOutletToHexHeightColdSide =
        headFromPumpOutletToHexHeightColdSide * coldSaltDensity * 9.81
        / 100_000.0
      // (2) - >(3)

      let pressureDropsInHex = actualTesHexSaltPressureDropDuringDesignCharge
      let staticColdSaltHeadDueToHexPressureDrop =
        pressureDropsInHex * 100_000.0 / (coldSaltDensity * 9.81)
      let pressureDropsInPipesAndValves =
        actualPressureDropPipingAndValvesDesignChargeMassFlow
      let staticHeadDueToPipesAndValvesPressureDrop =
        pressureDropsInPipesAndValves * 100_000.0 / (coldSaltDensity * 9.81)
      // (3) - >(4)
      let headFromPumpShaftLengthHotSide =
        verticalDistanceBetweenHexTrainOutletAndSparger
      let pressureDifferenceAlongPumpShaftHotSide =
        headFromPumpShaftLengthHotSide * hotSaltDensity * 9.81 / 100_000.0
      let pressureDropAtSparger = actualPressureDropHotTankSparger
      let staticHeadDueToSpargerDrop =
        pressureDropAtSparger * 100_000.0 / (hotSaltDensity * 9.81)
      // (4) - >(5)
      let activeSaltColumnOnSpargerOutletAt100ChargedSystemHot =
        upperOperationalHotTankFillLevel
        - pumpSuctionClearanceDistanceSuctionInletToTankFloor
      let pressureDifferenceSpargerOutletAtm =
        activeSaltColumnOnSpargerOutletAt100ChargedSystemHot * hotSaltDensity
        * 9.81 / 100_000.0

      let totalPressureDifferenceHexAtmHot =
        pressureDifferenceAlongPumpShaftHotSide + pressureDropAtSparger
        + pressureDifferenceSpargerOutletAtm + nominalPressureInHotTank

      let equivalentColdSaltHeadHexAtmHot =
        physicalSuctionLimit1Barg * 100_000.0 / (coldSaltDensity * 9.81)

      let totalPressureDifference =
        -nominalPressureInColdTank + pressureDifferenceAtmPumpSuctionInlet
        + pressureDifferenceAlongPumpShaftLengthColdSide
        + pressureDifferenceAlongPumpOutletToHexHeightColdSide
        + pressureDropsInHex + pressureDropsInPipesAndValves
        + physicalSuctionLimit1Barg
      let C540 = 0.0
      let C552 = 0.0
      let totalHeadForPumps =
        equivalentSaltHeadOfTankPressureCold
        + activeSaltColumnColdTankAt100ChargedSystem
        + headFromPumpShaftLengthColdSide
        + headFromPumpOutletToHexHeightColdSide
        + staticColdSaltHeadDueToHexPressureDrop + C540 + C552

      let volumeFlowPerPump =
        actualFlowPerColdTankPumpCharging / hotSaltDensity * 3_600.0  // [M³ / H]
      // let A = Vflow2 / H = volumeFlowPerPump ** 2 / totalHeadForPumps
      let pumpEfficiencyΗ = defaultSaltPumpEfficiency
      let requiredMechanicalPowerP_MPerPump =
        flowPerColdTankPumpCharging * totalHeadForPumps * 9.81 / 1_000.0
      let powerConsumptionP_ElPerPump =
        requiredMechanicalPowerP_MPerPump / pumpEfficiencyΗ
      let saltSideAuxiliaryPowerConsumptionForDesignCharge =
        powerConsumptionP_ElPerPump * numberOfPumpsPerColdTankCharging
        * totalNumberOfTanks / 2
    }
    do {
      let actualTotalDischargeMassFlow = massFlowRatio * dischargeSaltMassFlow
      let actualFlowPerHotTankPumpDischarging =
        actualTotalDischargeMassFlow
        / (numberOfPumpsPerHotTankDischarging * totalNumberOfTanks / 2.0)
      let actualTesHexSaltPressureDropDuringNominalDischarge =
        tesHexSaltPressureDropDuringDesignMode
        * (actualTotalDischargeMassFlow / designTotalSaltMassFlow)
        ** functionOfPressureDropVsMassFlow
      let actualPressureDropPipingAndValvesNominalDischargeMassFlow =
        pressureDropPipingAndValvesDesignChargeMassFlow
        * (actualTotalDischargeMassFlow / designTotalSaltMassFlow)
        ** functionOfPressureDropVsMassFlow
      let actualPressureDropColdTankSpargerDischargeMassFlow =
        pressureDropColdTankSpargerAtDesignDischargeMassFlow
        * (actualTotalDischargeMassFlow / designTotalSaltMassFlow)
        ** functionOfPressureDropVsMassFlow

      // (0) - >(1)

      let equivalentSaltHeadOfTankPressureHot =
        nominalPressureInHotTank * 100_000.0 / (hotSaltDensity * 9.81)
      let activeHotSaltColumnDesignAt0ChargedSystemHot =
        -minimumTankLevelInColdTank
        + pumpSuctionClearanceDistanceSuctionInletToTankFloor
      let pressureDifferenceAtmShaftInlet =
        activeHotSaltColumnDesignAt0ChargedSystemHot * hotSaltDensity * 9.81
        / 100_000.0
      // (1) - >(2)

      // let headFromPumpShaftLengthHot = pumpShaftLengthPumpMountToSuctionInlet
      let pressureDifferenceAlongPumpShaftLengthHot =
        pumpShaftLengthPumpMountToSuctionInlet * hotSaltDensity * 9.81
        / 100_000.0
      let headFromPumpHexHot = 0.0  // C486

      let pressureDifferenceAlongPumpHexHot =
        headFromPumpHexHot * hotSaltDensity * 9.81 / 100_000.0
      // (2) - >(3)
      // let pressureDropsInHex = actualTesHexSaltPressureDropDuringNominalDischarge
      let staticHeadDueToHexPressureDrop =
        actualTesHexSaltPressureDropDuringNominalDischarge * 100_000
        / (hotSaltDensity * 9.81)

      let staticHeadDueToPipesAndValvesPressureDrop =
        actualPressureDropPipingAndValvesNominalDischargeMassFlow * 100_000.0
        / (hotSaltDensity * 9.81)
      // (3) - >(4)

      let headFromPumpShaftLengthCold =
        verticalDistanceBetweenHexTrainOutletAndSparger
      let pressureDifferenceAlongPumpShaftCold =
        headFromPumpShaftLengthCold * coldSaltDensity * 9.81 / 100_000.0
      let pressureDropAtSparger =
        actualPressureDropColdTankSpargerDischargeMassFlow
      let staticHotSaltHeadDueToSpargerDrop =
        pressureDropAtSparger * 100_000.0 / (hotSaltDensity * 9.81)
      // (4) - >(5)
      let activeSaltColumnAt0ChargeColdSide =
        upperOperationalHotTankFillLevel
        - pumpSuctionClearanceDistanceSuctionInletToTankFloor
      let pressureDifferenceSpargerOutletAtm =
        activeSaltColumnAt0ChargeColdSide * coldSaltDensity * 9.81 / 100_000.0

      let totalPressureDifferenceHexAtmCold =
        pressureDifferenceAlongPumpShaftCold + pressureDropAtSparger
        + pressureDifferenceSpargerOutletAtm + nominalPressureInColdTank
      // let physicalSuctionLimit1Barg = 0.0  //If(C594 < 1, 1, totalPressureDifferenceHexAtmCold)
      let equivalentHotSaltHeadHexAtmCold =
        totalPressureDifferenceHexAtmCold * 100_000.0 / (hotSaltDensity * 9.81)
      let pressureDropsInPipesAndValves = 0.0
      let totalPressureDifference =
        -nominalPressureInHotTank + pressureDifferenceAtmShaftInlet
        + pressureDifferenceAlongPumpShaftLengthHot
        + pressureDifferenceAlongPumpHexHot
        + actualTesHexSaltPressureDropDuringNominalDischarge
        + pressureDropsInPipesAndValves + physicalSuctionLimit1Barg
      let totalHeadForPumps =
        -equivalentSaltHeadOfTankPressureHot
        + activeHotSaltColumnDesignAt0ChargedSystemHot
        + pumpShaftLengthPumpMountToSuctionInlet + headFromPumpHexHot
        + staticHeadDueToHexPressureDrop
        + staticHeadDueToPipesAndValvesPressureDrop
        + equivalentHotSaltHeadHexAtmCold

      let volumeFlowPerPump =
        actualFlowPerHotTankPumpDischarging / hotSaltDensity * 3_600.0
      let _ = volumeFlowPerPump ** 2.0 / totalHeadForPumps
      let pumpEfficiencyΗ = 0.0  // defaultSaltPumpEfficiency
      let requiredMechanicalPowerP_MPerPump =
        flowPerHotTankPumpDischarging * totalHeadForPumps * 9.81 / 1_000.0
      let powerConsumptionP_ElPerPump =
        requiredMechanicalPowerP_MPerPump / pumpEfficiencyΗ
      let saltSideAuxiliaryPowerConsumptionForNominalDischarge =
        100_000 * numberOfPumpsPerHotTankDischarging * totalNumberOfTanks / 2.0

      let massFlowResolutionInterval = pumpAuxResolutionInterval  // =10(Caution:Max.100)
      let chargeLevelResolutionInterval = pumpAuxResolutionInterval  // =10(Caution:Max.100)

      let verticalDistanceBetweenHexLevelAndPumpMountLevel = 0.0  //C486
      // let pumpShaftLengthPumpMountToSuctionInlet = pumpShaftLengthPumpMountToSuctionInlet

      // let nominalAuxiliaryPowerConsumptionChargeModeSaltPumpsOnly = saltSideAuxiliaryPowerConsumptionForDesignCharge
      // let nominalAuxiliaryPowerConsumptionDischargeModeSaltPumpsOnly = saltSideAuxiliaryPowerConsumptionForNominalDischarge

    }
    //  Htf MassFlows
    do {
      let htfPbHexInletTemperatureAtNominalCharge = htfPbHexInletTemperature
      let htfPbHexOutletTemperatureAtNominalCharge =
        htfPbHexNominalOutletTemperature
      let approachTemperatureInTesHeatExchangerDuringCharge =
        approachTemperatureInTesHeatExchangerDuringCharge  // [K]
      //let coldTankTemperature = C158
      //let p_Th_Tes_Charge(Nominal) = C210
      let htfNominalMassFlowInPbHex = 0.0  //C155
      let chargeHtfMassFlowThroughTes = 0.0  //C209
      let C622 = Temperature()
      let sfInletTemperatureAtSfToPb_TesMode = htf.temperature(
        (htf.enthalpy(
          coldTankTemperature
            + approachTemperatureInTesHeatExchangerDuringCharge)
          * chargeHtfMassFlowThroughTes + htf.enthalpy(C622)
          * htfNominalMassFlowInPbHex)
          / (htfNominalMassFlowInPbHex + chargeHtfMassFlowThroughTes))
      let totalHtfMassFlowToSf =
        chargeHtfMassFlowThroughTes + htfNominalMassFlowInPbHex
      let htfMassFlowToPowerBlockAtDesignPoint =
        htfNominalMassFlowInPbHex / totalHtfMassFlowToSf

      let sfInletTemperature = sfInletTemperatureAtSfToPb_TesMode
      // let totalHtfMassFlowToSf = 0.0  //C631
      let massFlowToPowerBlockAtDesignPoint =
        htfMassFlowToPowerBlockAtDesignPoint

      let tesHexHtfPressureDropAtDesignMassFlowOfDecisiveCase = 1.0  //'In - OutputSummary'!C30
      let htfPressureDropInPbHexAt100_SolarMode = 1.0  //'In - OutputSummary'!C31
      let functionOfPressureDropVsMassFlow =
        functionOfPressureDropVsMassFlow

      let sfInletTemperatureAtSfToPbTesMode = sfInletTemperature
      let htfPbHexOutletTemperatureDischarging = Temperature()  // pbHexHtfOutletTemperatureDischarging

      let totalChargeHtfMassFlowThroughTesHex = 0.0  //C209
      let tesHexTrainsPerTwoTankSystemInActionDuringDesignCharge = 0.0  //C340
      let totalDischargeHtfMassFlowTesOnlyMode = 0.0  //C156
      // let tesHexTrainsPerTwoTankSystemInActionDuringDischarge = tesHexTrainsPerTwoTankSystemInActionDuringDischarge
      // let totalNumberOfTanks = totalNumberOfTanks
      let tesHexTrainsPerTwoTankSystemInActionDuringDischarge = 0.0
      let htfMassFlowInPbAt100_SolarMode = 0.0  //C155
      let tesHexHtfMassFlowAtNominalChargeModePerTrain =
        totalChargeHtfMassFlowThroughTesHex / (totalNumberOfTanks / 2.0)
        / tesHexTrainsPerTwoTankSystemInActionDuringDesignCharge
      let tesHexHtfMassFlowAtNominalDischargeModePerTrain =
        totalDischargeHtfMassFlowTesOnlyMode / (totalNumberOfTanks / 2.0)
        / tesHexTrainsPerTwoTankSystemInActionDuringDischarge
      let nominalHtfMassFlowInOneTesHexTrainOfDecisiveCase = max(
        tesHexHtfMassFlowAtNominalChargeModePerTrain,
        tesHexHtfMassFlowAtNominalDischargeModePerTrain)

      let htfPressureDropInTesHexAtDesignChargeMode =
        tesHexHtfPressureDropAtDesignMassFlowOfDecisiveCase
        * (tesHexHtfMassFlowAtNominalChargeModePerTrain
          / nominalHtfMassFlowInOneTesHexTrainOfDecisiveCase) ** 0.0  //C642
      let powerConsumptionForPushingHtfThroughTesHexDuring100Charge =
        totalChargeHtfMassFlowThroughTesHex
        / htf.density(sfInletTemperatureAtSfToPbTesMode)
        * htfPressureDropInTesHexAtDesignChargeMode * 10 ** 5 / 10 ** 6 / 0.7  // [Mwe]

      let htfPressureDropInTesHexAtDesignDischargeMode =
        tesHexHtfPressureDropAtDesignMassFlowOfDecisiveCase
        * (tesHexHtfMassFlowAtNominalDischargeModePerTrain
          / nominalHtfMassFlowInOneTesHexTrainOfDecisiveCase) ** 0.0  //C642
      let powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge =
        totalDischargeHtfMassFlowTesOnlyMode
        / htf.density(htfPbHexOutletTemperatureDischarging)
        * htfPressureDropInTesHexAtDesignDischargeMode * 10.0 ** 5.0 / 10.0
        ** 6.0 / 0.7  // [Mwe]

      let htfPressureDropInPbHexAtDesignDischargeMode =
        htfPressureDropInPbHexAt100_SolarMode
        * (totalDischargeHtfMassFlowTesOnlyMode
          / htfMassFlowInPbAt100_SolarMode) ** functionOfPressureDropVsMassFlow
      let powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge =
        totalDischargeHtfMassFlowTesOnlyMode
        / htf.density(htfPbHexOutletTemperatureDischarging)
        * htfPressureDropInPbHexAtDesignDischargeMode * 10.0 ** 5.0 / 10.0 ** 6
        / 0.7  // [Mwe]

      // let powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge =
      //   powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge  // [Mwe]
      // let powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge =
      //   powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge  // [Mwe]

      //  DischargeAuxiliaryPowerFactor

      let nominalAuxiliaryPowerConsumptionDischargeModeSaltPumpsOnly = 0.0  // nominalAuxiliaryPowerConsumptionDischargeModeSaltPumpsOnly
      // let powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge = powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge // [Mwe]
      // let powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge = powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge // [Mwe]
      let htfSaltPumpAuxiliaryLoadDuringDischarge =
        nominalAuxiliaryPowerConsumptionDischargeModeSaltPumpsOnly / 1_000.0
        + powerConsumptionForPushingHtfThroughTesHexDuringDesignDischarge
        + powerConsumptionForPushingHtfThroughPbHexDuringDesignDischarge

      //let =B677 = htfSaltPumpAuxiliaryLoadDuringDischarge
    }
    //  HeatLosses Tes Tanks
    do {
      let lambdaInsulationCalculationCoefficientAColdTank =
        lambdaInsulationCalculationCoefficientAColdTank  // [W / (M * K * °C)]
      let lambdaInsulationCalculationCoefficientBColdTank =
        lambdaInsulationCalculationCoefficientBColdTank  // [W / (M * K)]
      let thicknessTankShellInsulationColdTank =
        thicknessTankShellInsulationColdTank
      let thicknessTankRoofInsulationColdTank =
        thicknessTankRoofInsulationColdTank
      let lambdaFoundationColdTank = lambdaFoundationColdTank  // [W / M * K]
      let thicknessFoundationColdTank = thicknessFoundationColdTank

      let lambdaInsulationCalculationCoefficientAHotTank =
        lambdaInsulationCalculationCoefficientAHotTank  // [W / (M * K * °C)]
      let lambdaInsulationCalculationCoefficientBHotTank =
        lambdaInsulationCalculationCoefficientBHotTank  // [W / (M * K)]
      let thicknessTankShellInsulationHotTank =
        thicknessTankShellInsulationHotTank
      let thicknessTankRoofInsulationHotTank =
        thicknessTankRoofInsulationHotTank
      let lambdaFoundationHotTank = lambdaFoundationHotTank  // [W / M * K]
      let thicknessFoundationHotTank = thicknessFoundationHotTank

      let factorThermalBridgesRoofAndShell =
        factorThermalBridgesRoofAndShell
      let factorThermalBridgesBottom = factorThermalBridgesBottom

      let ambientTemperature = estimatedAverageAmbientTemperature.celsius
      let soilTemperature = estimatedAverage_SoilTemperature.celsius

      let tankHeightBottomRim = 0.0  //Iferror(C478, 14)
      let tankDiameter = 0.0  //Iferror(C400, 38)
      let coldTankTemperature = 0.0  //Iferror(C158, 280)
      let hotTankTemperature = 0.0  //Iferror(C123, 386)
      let quantityOfTanks = 0.0  //Iferror(totalNumberOfTanks, 2)

      let tankAreaShell = .pi * tankDiameter * tankHeightBottomRim
      let bendingRadiusRoof = 1.5 * tankDiameter
      let heightRoof =
        bendingRadiusRoof
        - (bendingRadiusRoof ** 2.0 - tankDiameter ** 2.0 / 4.0) ** 0.5
      let tankAreaRoof = 2.0 * .pi * bendingRadiusRoof * heightRoof
      let tankAreaBottom = .pi * tankDiameter ** 2.0 / 4.0

      //  Cold Tank
      let C731 = 0.0
      let C732 = 0.0
      //  Shell
      let temperatureOuterWallInsulationColdTank = 17.5619897785805
      let temperatureInsulationEffectiveColdTank =
        (coldTankTemperature + temperatureOuterWallInsulationColdTank) / 2.0
      let lambdaInsulationEffectiveColdTank =
        lambdaInsulationCalculationCoefficientAColdTank
        * temperatureInsulationEffectiveColdTank
        + lambdaInsulationCalculationCoefficientBColdTank
      let diameter_IColdTank = tankDiameter
      let diameter_AColdTank =
        diameter_IColdTank + 2.0 * thicknessTankShellInsulationColdTank
      let heatLossesShellColdTank =
        (temperatureOuterWallInsulationColdTank - ambientTemperature)
        * (.pi * diameter_AColdTank * tankHeightBottomRim
          * alphaInsulationToAir)
      let heatLossesShellColdTank2 =
        (1.0 + factorThermalBridgesRoofAndShell) * tankHeightBottomRim * .pi
        * (coldTankTemperature - ambientTemperature)
        / (1.0 / (2.0 * lambdaInsulationEffectiveColdTank)
          * log(diameter_AColdTank / diameter_IColdTank) + 1.0
          / (alphaInsulationToAir * diameter_AColdTank))
      let differenceOfHeatLossShellColdTankForIteration = C731 - C732
      //let spec.HeatLossesShellColdTank = C732 / tankAreaShell
      //let iterationSuccessful?["Ok" / "Iterate!"] = If(Abs(C731 - C732)<0.1,"Ok","Iterate!")
      //  Roof:
      let temperatureOuterWallInsulationColdTankForIteration = 17.5794213728555
      let temperatureInsulationEffectiveColdTank2 =
        (coldTankTemperature
          + temperatureOuterWallInsulationColdTankForIteration) / 2.0
      let C690 = 0.0
      let lambdaInsulationEffectiveColdTank2 =
        lambdaInsulationCalculationCoefficientAColdTank
        * temperatureInsulationEffectiveColdTank2
        + lambdaInsulationCalculationCoefficientBColdTank
      let kValueRoofColdTank =
        (C690 / lambdaInsulationEffectiveColdTank2) ** -1.0
      let T_Outer_Roof_Cold_1 = 0.0
      let specHeatLossesRoofColdTank =
        (1.0 + factorThermalBridgesRoofAndShell) * kValueRoofColdTank
        * (coldTankTemperature - T_Outer_Roof_Cold_1)
      var heatLossesRoofColdTank = specHeatLossesRoofColdTank * tankAreaRoof
      heatLossesRoofColdTank =
        (temperatureOuterWallInsulationColdTankForIteration
          - ambientTemperature) * (tankAreaRoof * alphaInsulationToAir)
      let differenceOfHeatLossRoofColdTankForIteration =
        heatLossesRoofColdTank - heatLossesRoofColdTank
      //let iterationSuccessful?["Ok" / "Iterate!"] = If(Abs(heatLossesRoofColdTank - heatLossesRoofColdTank)<0.1,"Ok","Iterate!")
      //  Bottom:
      let kValueBottomColdTank =
        lambdaFoundationColdTank / thicknessFoundationColdTank
      let specHeatLossesBottomColdTank =
        (1 + factorThermalBridgesBottom) * kValueBottomColdTank
        * (coldTankTemperature - soilTemperature)
      let heatLossesBottomColdTank =
        specHeatLossesBottomColdTank * tankAreaBottom

      let heatLossesOneColdTank =
        (heatLossesShellColdTank + heatLossesRoofColdTank
          + heatLossesBottomColdTank) / 1_000.0
      let heatLossesAllColdTanks =
        heatLossesOneColdTank * totalNumberOfTanks / 2.0

      let temperatureOuterWallInsulationHotTank = 17.9544435304503
      //let hotTank:
      //  Shell:
      do {
        let temperatureInsulationEffectiveHotTank =
          (hotTankTemperature + temperatureOuterWallInsulationHotTank) / 2.0
        let lambdaInsulationEffectiveHotTank =
          lambdaInsulationCalculationCoefficientAHotTank
          * temperatureInsulationEffectiveHotTank
          + lambdaInsulationCalculationCoefficientBHotTank
        let diameter_IHotTank = tankDiameter
        let diameter_AHotTank =
          diameter_IHotTank + 2.0 * thicknessTankShellInsulationHotTank
        let heatLossesShellHotTank =
          (1.0 + factorThermalBridgesRoofAndShell) * tankHeightBottomRim * .pi
          * (hotTankTemperature - ambientTemperature)
          / (1.0 / (2.0 * lambdaInsulationEffectiveHotTank)
            * log(diameter_AHotTank / diameter_IHotTank) + 1.0
            / (alphaInsulationToAir * diameter_AHotTank))
      }
      let C756 = 0.0
      let diameter_AHotTank = 0.0
      let heatLossesShellHotTank =
        (C756 - ambientTemperature)
        * (.pi * diameter_AHotTank * tankHeightBottomRim * alphaInsulationToAir)
      //let differenceOfHeatLossShellHotTank(ForIteration) = heatLossesShellHotTank - heatLossesShellHotTank
      //let spec.HeatLossesShellHotTank = heatLossesShellHotTank / tankAreaShell
      //let iterationSuccessful?["Ok" / "Iterate!"] = If(Abs(heatLossesShellHotTank - C762)<0.1,"Ok","Iterate!")

      //  Roof:
      //let temperatureOuterWallInsulationHotTank[°C](ForIteration)	17.9822336749726
      let temperatureInsulationEffectiveHotTank =
        (hotTankTemperature + temperatureOuterWallInsulationHotTank) / 2.0
      let lambdaInsulationEffectiveHotTank =
        lambdaInsulationCalculationCoefficientAHotTank
        * temperatureInsulationEffectiveHotTank
        + lambdaInsulationCalculationCoefficientBHotTank
      let kValueRoofHotTank =
        (thicknessTankRoofInsulationHotTank / lambdaInsulationEffectiveHotTank)
        ** -1.0
      let C771 = 0.0
      let T_Outer_Roof_Hot_1 = 0.0
      let specHeatLossesRoofHotTank =
        (1 + factorThermalBridgesRoofAndShell) * kValueRoofHotTank
        * (hotTankTemperature - T_Outer_Roof_Hot_1)
      let heatLossesRoofHotTank = C771 * tankAreaRoof
      let heatLossesRoofHotTankOuterShellToAmbient =
        (T_Outer_Roof_Hot_1 - ambientTemperature)
        * (tankAreaRoof * alphaInsulationToAir)
      //let differenceOfHeatLossRoofHotTank(ForIteration) = heatLossesRoofHotTankOuterShellToAmbient - heatLossesRoofHotTank
      //let iterationSuccessful?["Ok" / "Iterate!"] = If(Abs(heatLossesRoofHotTank - heatLossesRoofHotTankOuterShellToAmbient)<0.1,"Ok","Iterate!")
      //  Bottom:
      let C702 = 0.0
      let kValueBottomHotTank =
        lambdaFoundationHotTank / thicknessFoundationHotTank
      let heatLossesBottomHotTank =
        (1 + C702) * kValueBottomHotTank
        * (hotTankTemperature - soilTemperature)
      let heatLossesBottomHotTank2 = heatLossesBottomHotTank * tankAreaBottom  // FIXME

      let heatLossesOneHotTank =
        (heatLossesShellHotTank + heatLossesRoofHotTank
          + heatLossesBottomHotTank) / 1_000.0
      let heatLossesAllHotTanks = heatLossesOneHotTank * quantityOfTanks / 2  //  Iteration2:

      //let iterationSuccessful?["Ok" / "Iterate!"] = If(Abs(C731 - C732)>0.1,"Iterate!",If(Abs(heatLossesRoofColdTank - C743)>0.1,"Iterate!",If(Abs(heatLossesShellHotTank - heatLossesShellHotTank)>0.1,"Iterate!",If(Abs(heatLossesRoofHotTank - heatLossesRoofHotTankOuterShellToAmbient)>0.1,"Iterate!","Ok"))))
      // let heatLossesAllColdTanks = heatLossesAllColdTanks
      // let heatLossesAllHotTanks = heatLossesAllHotTanks
    }
    do {
      let storagePumpEff = defaultSaltPumpEfficiency

      let htfTemperatureAtTesHexInletDuringCharge = htfPbHexInletTemperature

      let htfPbHexOutletTemperature = htfPbHexNominalOutletTemperature
      let chargeHtfMassFlowThroughTesHex = 0.0  //C215  // [Kg/S]
      let dischargeHtfMassFlowThroughTesHex =
        dischargeHtfMassFlowThroughTes_PbHex
      let htfTemperatureTesHexInletAtDischarge = Temperature()  // pbHexHtfOutletTemperatureDischarging
      let htfTemperatureTesHexOutletAtDischarge =
        htfPbHexInletTemperatureDischarging
      let nominalAuxiliaryPowerConsumptionChargeModeSaltPumpsOnly = 0.0  //C614
      //let = B677 = htfSaltPumpAuxiliaryLoadDuringDischarge
      let htfTemperatureAtTesHexOutletDuringCharge = 0.0  //Htfinsto.Tout = C159

      let rohDPCharge = htf.density(
        Temperature(
          (htfPbHexInletTemperature + htfPbHexOutletTemperature).kelvin / 2.0))
      let rohmeanCharge = htf.density(
        Temperature(
          (htfTemperatureAtTesHexInletDuringCharge
            + htfTemperatureAtTesHexOutletDuringCharge)
            .kelvin / 2.0))
      let prl =
        (nominalAuxiliaryPowerConsumptionChargeModeSaltPumpsOnly / 1_000.0)
        * rohmeanCharge * storagePumpEff * 10 ** 6.0
        / chargeHtfMassFlowThroughTesHex

      let storagePressurelossDP =
        prl * rohmeanCharge / rohDPCharge
        * (chargeHtfMassFlowThroughTesHex / chargeHtfMassFlowThroughTesHex)
        ** 2.0  // [Pa](DeterminesSalt - ParasiticsAtChargeMode)

      let rohmeanDischarge = htf.density(
        Temperature(
          (htfTemperatureTesHexInletAtDischarge
            + htfTemperatureTesHexOutletAtDischarge)
            .kelvin / 2.0))
      let prlAtDischargeMode =
        storagePressurelossDP * (rohDPCharge / rohmeanDischarge)
        * (dischargeHtfMassFlowThroughTesHex / chargeHtfMassFlowThroughTesHex)
        ** 2.0  // [N / M²]
      let chargeParasiticsAtDischargeMode =
        prlAtDischargeMode * dischargeHtfMassFlowThroughTesHex
        / rohmeanDischarge / storagePumpEff / 10 ** 6.0
      let htfSaltPumpAuxiliaryLoadDuringDischarge = 0.0
      let factorForAuxiliariesDuringStorageDischarge =
        htfSaltPumpAuxiliaryLoadDuringDischarge
        / chargeParasiticsAtDischargeMode  // (Htf.PumpsIncl.)[Non - Dim.]
    }
  }  //storagePressurelossDP

  //factorForAuxiliariesDuringStorageDischarge //  (Htf.PumpsIncl.)[Non - Dim.]
}
precedencegroup ExponentiationPrecedence {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiationPrecedence
infix operator **=: AssignmentPrecedence

extension Double {
  static func ** (lhs: Double, rhs: Double) -> Double { pow(lhs, rhs) }

  static func **= (lhs: inout Double, rhs: Double) { lhs = lhs ** rhs }
}

/// Find the value within a given range that satisfies a goal using the bisection method.
///
/// - Parameters:
///   - goal: The target value that the function output should satisfy.
///   - range: The closed range within which to search for the value (default is 0...1).
///   - tolerance: The acceptable tolerance level for the difference between the function
///     value at the midpoint and the goal (default is 0.0001).
///   - maxIterations: The maximum number of iterations allowed to find the solution
///     (default is 100).
///   - f: The function for which the goal is sought. It takes a `Double` argument and
///     returns a `Double` result.
/// - Returns: The value within the specified range that satisfies the given goal. If no
///   such value is found within the provided range and tolerance, it returns `Double.nan`.
///
/// The `seek` function utilizes the bisection method to find the value within a specified
/// range that satisfies the given goal. The method iteratively narrows down the range by
/// halving it based on the function values at the endpoints and the midpoint. The goal is
/// considered to be met when the function value at the midpoint is equal to the desired goal,
/// or when the range has been narrowed down to the specified tolerance.
func seek(
  goal: Double, _ range: ClosedRange<Double> = 0...1,
  tolerance: Double = 0.0001, maxIterations: Int = 100, _ f: (Double) -> Double
) -> Double {
  var a: Double = range.lowerBound
  var b: Double = range.upperBound
  for _ in 0..<maxIterations {
    let c: Double = (a + b) / 2.0
    let fc: Double = f(c)
    let fa: Double = f(a)
    if fc == goal || (b - a) / 2.0 < tolerance { return c }
    if (fc < goal && fa < goal) || (fc > goal && fa > goal) {
      a = c
    } else {
      b = c
    }
  }
  return Double.nan
}
