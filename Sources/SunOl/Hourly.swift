import Utilities
/*
extension SunOl2 {

  mutating func hourly(_ Q_Sol_MW_thLoop: [Double], _ Reference_PV_plant_power_at_inverter_inlet_DC: [Double], _ Reference_PV_MV_power_at_transformer_outlet: [Double]) {
    var PV = SunOl.PV()
    let PVMVPowerAtTransformerOutletMWel = [Double]()

    let BESS_charging_max_cons: Double = 0.0  // B$86
    let CCU_CO2_nom_prod: Double = 0.0  // B$147
    let CCU_fix_aux_cons: Double = 0.0  // B$149
    let CCU_harmonious_min_perc: Double = 0.0  // L$8
    let CCU_var_aux_nom_cons: Double = 0.0  // B$150
    let CCU_var_heat_nom_cons: Double = 0.0  // B$151
    let CSP_Loop_Nr: Double = 0.0  // B$70
    let CSP_nonsolar_aux_cons: Double = 0.0  // B$73
    let CSP_var_aux_nom_perc: Double = 0.0  // G$75
    let EY_H2_nom_prod: Double = 0.0  // B$99
    let EY_fix_aux_elec: Double = 0.0  // B$95
    let EY_harmonious_min_perc: Double = 0.0  // L$9
    let EY_var_gross_nom_cons: Double = 0.0  // B$93
    let EY_var_heat_nom_cons: Double = 0.0  // B$97
    let El_boiler_cap: Double = 0.0  // B$134
    let grid_max_import: Double = 0.0  // B$138
    let Heater_cap: Double = 0.0  // B$81
    let MethDist_harmonious_min_perc: Double = 0.0  // L$6
    let MethSynt_RawMeth_nom_prod: Double = 0.0  // B$108
    let MethSynt_fix_aux_cons: Double = 0.0  // B$114
    let MethSynt_harmonious_min_perc: Double = 0.0  // L$7
    let MethSynt_var_aux_nom_cons: Double = 0.0  // B$115
    let Overall_fix_aux_cons: Double = 0.0  // L$3
    let Overall_harmonious_max_var_cons: Double = 0.0  // L$20
    let Overall_harmonious_max_var_heat_cons: Double = 0.0  // L$21
    let Overall_harmonious_min_var_cons: Double = 0.0  // L$11

    let PB_stby_aux_cons: Double = 0.0  // B$32

    let PV_AC_Cap: Double = 0.0  // B$53

    let TES_Aux_elec_percentage: Double = 0.0  // G$81

    let TES_Thermal_capacity: Double = 0.0  // B$77

    let Heater_eff = 0.99
    let El_boiler_eff = 0.99
    let Ratio_CSP_vs_Heater = 1.315007

    let range = 0..<8760
    let zeroes = Array(repeating: 0.0, count: range.count)

    let indices = Reference_PV_MV_power_at_transformer_outlet.indices
    let Q_solar_before_dumping = Q_Sol_MW_thLoop.map { $0 * CSP_Loop_Nr }
    let maximum = Reference_PV_MV_power_at_transformer_outlet.max() ?? 0
    let Inverter_power_fraction = Reference_PV_MV_power_at_transformer_outlet.map { max(0, $0 / maximum) }
    let Inverter_eff = indices.map { return iff(Reference_PV_MV_power_at_transformer_outlet[$0] < maximum, max(Reference_PV_MV_power_at_transformer_outlet[$0], 0) / Reference_PV_plant_power_at_inverter_inlet_DC[$0], 0) }
    let inverter = zip(Inverter_power_fraction, Inverter_eff).filter { $0.0 > 0 && $0.0 < 1 }.sorted(by: { $0.0 < $1.0 })
    let chunks = inverter.chunked { Int($0.0 * 100) == Int($1.0 * 100) }
    let eff1 = chunks.map { bin in bin.reduce(0.0) { $0 + $1.1 } / Double(bin.count) }
    let eff2 = zip(stride(from: 0.01, through: 1, by: 0.01), eff1).map { PV.AC_Cap * $0.0 / $0.1 / PV.DC_Cap }
    let LL = Polynomial.fit(x: Array(eff2[...20]), y: Array(eff1[...20]), degree: 6)
    let ML = Polynomial.fit(x: Array(eff2[8...22]), y: Array(eff1[8...22]), degree: 3)
    let HL = Polynomial.fit(x: Array(eff2[20...]), y: Array(eff1[20...]), degree: 4)

    let E_PV_total_Scaled_DC = Reference_PV_plant_power_at_inverter_inlet_DC.map { $0 * PV.DC_Cap / PV.Ref_DC_cap }

    let PV_MV_power_at_transformer_outlet: [Double] = indices.map {
      let load = E_PV_total_Scaled_DC[$0] / PV.DC_Cap
      let value: Double
      if load > 0.2 {
        value = E_PV_total_Scaled_DC[$0] * HL(load)
      } else if load > 0.1 {
        value = E_PV_total_Scaled_DC[$0] * ML(load)
      } else if load > 0 {
        value = E_PV_total_Scaled_DC[$0] * LL(load)
      } else {
        value = Reference_PV_MV_power_at_transformer_outlet[$0] / PV.Ref_AC_cap * PV.AC_Cap
      }
      return min(PV_AC_Cap, value)
    }

    let auxElecForPBStby_CSPSFAndPVPlantMWel: [Double] = indices.map { i -> Double in
      iff(Q_solar_before_dumping[i] > 0, Q_solar_before_dumping[i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + max(0, -PV_MV_power_at_transformer_outlet[i]) + PB_stby_aux_cons
    }

    let availablePVPowerMWel: [Double] = indices.map { i -> Double in max(0, PV_MV_power_at_transformer_outlet[i] - auxElecForPBStby_CSPSFAndPVPlantMWel[i]) }

    let pvDayRanges = Array(E_PV_total_Scaled_DC.indices.chunked(by:) { !(E_PV_total_Scaled_DC[$0] == 0.0 && E_PV_total_Scaled_DC[$1] > 0.0) })

    let day = [0] + pvDayRanges.indices.flatMap { i in Array(repeating: i, count: pvDayRanges[i].count) }

    let pvDays = pvDayRanges.map { r in Array(PV_MV_power_at_transformer_outlet[r]) }
    let pvDayStats: [(Double, Double, Double)] = pvDays.map { day in let n = day.reduce(into: 0) { counter, value in if value > 0 { counter += 1 } }
      return (sum(day[0...]), Double(n), Double(day.count) - Double(n))
    }
    var xy = [Double](repeating: 0.0, count: 2_216_280 + 8760)
    /// Q_solar (before dumping) MWth
    let J = 78840
    for i in indices { xy[J + i] = Q_solar_before_dumping[i] }
    /// E_PV_Total _Scaled MWel_DC
    let K = 87600
    for i in indices { xy[K + i] = E_PV_total_Scaled_DC[i] }
    /// PV MV power at transformer outlet MWel
    let L = 96360
    for i in indices { xy[L + i] = PV_MV_power_at_transformer_outlet[i] }
    /// Aux electricity for PB stby, CSP SF and PV Plant MWel
    let M = 105120
    for i in indices { xy[M + i] = auxElecForPBStby_CSPSFAndPVPlantMWel[i] }
    /// Available PV power MWel
    let N = 113880
    for i in indices { xy[N + i] = availablePVPowerMWel[i] }
    /// Not covered aux electricity for PB stby, CSP SF and PV Plant MWel
    let O = 122640
    for i in 1..<8760 { xy[O + i] = max(0, xy[M + i] - xy[N + i]) }

    /// Min harmonious net electricity counsumption
    let P = 131400
    for i in 1..<8760 {
      xy[P + i] = iff(
        min(
          Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
          xy[N + i] + grid_max_import,
          min(
            xy[J + i] + El_boiler_cap * El_boiler_eff,
            (xy[N + i] + grid_max_import) / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(0, (Overall_harmonious_max_var_heat_cons - xy[J + i])) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
          ) / Overall_harmonious_max_var_heat_cons * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons,
        0,
        Overall_harmonious_min_var_cons + Overall_fix_aux_cons
      )
    }

    /// Optimized min harmonious net electricity counsumption
    let Q = 140160
    for i in 1..<8760 {
      xy[Q + i] = iff(
        false,  //and(xy[P + i] > 0, xy[P + i - 1] == 0, countiff(xy[P + i], P6, 0) > 0),
        0,
        xy[P + i]
      )
    }

    /// Min harmonious net heat counsumption
    let R = 148920
    for i in 1..<8760 { xy[R + i] = xy[Q + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) * Overall_harmonious_max_var_heat_cons }

    /// Photovoltaic day
    let S = 157680
    for i in 1..<8760 { xy[S + i] = iff(and(xy[Q + i - 1] <= 0, xy[Q + i] > 0), xy[S + i - 1] + 1, xy[S + i - 1]) }

    /// Remaining PV after min harmonious
    let T = 166440
    for i in 1..<8760 { xy[T + i] = max(0, xy[N + i] - xy[O + i] - xy[Q + i] - max(0, (xy[R + i] - xy[J + i]) / El_boiler_eff)) }

    /// Remaining CSP heat after min harmonious
    let U = 175200
    for i in 1..<8760 { xy[U + i] = max(0, xy[J + i] - xy[R + i]) }

    /// Grid import necessary for min harmonious
    let V = 183960
    for i in 1..<8760 { xy[V + i] = max(0, -(xy[N + i] - xy[Q + i] - max(0, (xy[R + i] - xy[J + i]) / El_boiler_eff)) + xy[O + i]) }

    /// Remaining grid import capacity after min harmonious
    let W = 192720
    for i in 1..<8760 { xy[W + i] = grid_max_import - xy[V + i] }

    /// Remaining electric boiler capacity after min harmonious heat counsumption
    let X = 201480
    for i in 1..<8760 { xy[X + i] = max(0, min(El_boiler_cap - max(0, (xy[R + i] - xy[J + i]) / El_boiler_eff), xy[T + i] + xy[W + i])) }

    /// Remaining MethSynt capacity after min harmonious counsumption
    let Y = 210240
    for i in 1..<8760 {
      xy[Y + i] = max(
        0,
        min(
          (1 - xy[Q + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc * MethSynt_harmonious_min_perc) * MethSynt_RawMeth_nom_prod,
          (xy[T + i] + xy[W + i]) / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons) * MethSynt_RawMeth_nom_prod
        )
      )
    }

    /// Remaining CCU capacity after min harmonious counsumption
    let Z = 219000
    for i in 1..<8760 {
      xy[Z + i] = max(
        0,
        min(
          (1 - xy[Q + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc * CCU_harmonious_min_perc),
          (xy[T + i] + xy[W + i]) / (CCU_var_aux_nom_cons + CCU_fix_aux_cons + max(0, CCU_var_heat_nom_cons - xy[U + i]) / El_boiler_eff),
          ifFinite(xy[X + i] / (max(0, CCU_var_heat_nom_cons - xy[U + i]) / El_boiler_eff), 1)
        ) * CCU_CO2_nom_prod
      )
    }

    /// Remaining EY capacity after min harmonious counsumption
    let AA = 227760
    for i in 1..<8760 {
      xy[AA + i] = max(
        0,
        min(
          (1 - xy[Q + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc * EY_harmonious_min_perc),
          (xy[T + i] + xy[W + i]) / (EY_var_gross_nom_cons + EY_fix_aux_elec + max(0, EY_var_heat_nom_cons - xy[U + i]) / El_boiler_eff),
          ifFinite(xy[X + i] / (max(0, EY_var_heat_nom_cons - xy[U + i]) / El_boiler_eff), 1)
        ) * EY_H2_nom_prod
      )
    }

    /// Max BESS charging after min harmonious counsumption
    let AB = 236520
    for i in 1..<8760 { xy[AB + i] = min(BESS_charging_max_cons, xy[T + i]) }

    /// Max harmonious net electricity counsumption
    let AC = 245280
    for i in 1..<8760 {
      xy[AC + i] = iff(
        min(
          Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
          xy[N + i] + grid_max_import,
          min(
            xy[J + i] + El_boiler_cap * El_boiler_eff,
            (xy[N + i] + grid_max_import) / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(0, (Overall_harmonious_max_var_heat_cons - xy[J + i])) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
          ) / Overall_harmonious_max_var_heat_cons * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons,
        0,
        min(
          Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
          xy[N + i] + grid_max_import,
          min(
            xy[J + i] + El_boiler_cap * El_boiler_eff,
            (xy[N + i] + grid_max_import) / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(0, (Overall_harmonious_max_var_heat_cons - xy[J + i])) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
          ) / Overall_harmonious_max_var_heat_cons * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
        )
      )
    }

    /// Optimized max harmonious net electricity counsumption
    let AD = 254040
    for i in 1..<8760 {
      xy[AD + i] = iff(
        false,  //and(xy[AC + i] > 0, xy[AC + i - 1] == 0, countiff(xy[AC + i], AC6, 0) > 0),
        0,
        xy[AC + i]
      )
    }

    /// max harmonious net heat counsumption
    let AE = 262800
    for i in 1..<8760 { xy[AE + i] = xy[AD + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) * Overall_harmonious_max_var_heat_cons }

    /// Remaining PV after max harmonious
    let AF = 271560
    for i in 1..<8760 { xy[AF + i] = max(0, xy[N + i] - xy[O + i] - xy[AD + i] - max(0, (xy[AE + i] - xy[J + i]) / El_boiler_eff)) }

    /// Remaining CSP heat after max harmonious
    let AG = 280320
    for i in 1..<8760 { xy[AG + i] = max(0, xy[J + i] - xy[AE + i]) }

    /// Grid import necessary for max harmonious
    let AH = 289080
    for i in 1..<8760 { xy[AH + i] = max(0, -(xy[N + i] - xy[AD + i] - max(0, (xy[AE + i] - xy[J + i]) / El_boiler_eff)) + xy[O + i]) }

    /// Remaining grid import capacity after max harmonious
    let AI = 297840
    for i in 1..<8760 { xy[AI + i] = grid_max_import - xy[AH + i] }

    /// Remaining electric boiler capacity after max harmonious heat counsumption
    let AJ = 306600
    for i in 1..<8760 { xy[AJ + i] = max(0, min(El_boiler_cap - max(0, (xy[AE + i] - xy[J + i]) / El_boiler_eff), xy[AF + i] + xy[AI + i])) }

    /// Remaining MethSynt capacity after max harmonious counsumption
    let AK = 315360
    for i in 1..<8760 {
      xy[AK + i] = max(
        0,
        min(
          (1 - xy[AD + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc * MethSynt_harmonious_min_perc) * MethSynt_RawMeth_nom_prod,
          (xy[AF + i] + xy[AI + i]) / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons) * MethSynt_RawMeth_nom_prod
        )
      )
    }

    /// Remaining CCU capacity after max harmonious counsumption
    let AL = 324120
    for i in 1..<8760 {
      xy[AL + i] = max(
        0,
        min(
          (1 - xy[AD + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc * CCU_harmonious_min_perc) * CCU_CO2_nom_prod,
          (xy[AF + i] + xy[AI + i]) / (CCU_var_aux_nom_cons + CCU_fix_aux_cons + max(0, CCU_var_heat_nom_cons - xy[AG + i])),
          ifFinite(xy[AJ + i] / (max(0, CCU_var_heat_nom_cons - xy[AG + i]) / El_boiler_eff), 1)
        ) * CCU_CO2_nom_prod
      )
    }

    /// Remaining EY capacity after max harmonious counsumption
    let AM = 332880
    for i in 1..<8760 {
      xy[AM + i] = max(
        0,
        min(
          (1 - xy[AD + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons) / MethDist_harmonious_min_perc * EY_harmonious_min_perc) * EY_H2_nom_prod,
          (xy[AF + i] + xy[AI + i]) / (EY_var_gross_nom_cons + EY_fix_aux_elec + max(0, EY_var_heat_nom_cons - xy[AG + i])),
          ifFinite(xy[AJ + i] / (max(0, EY_var_heat_nom_cons - xy[AG + i]) / El_boiler_eff), 1)
        ) * EY_H2_nom_prod
      )
    }

    /// Max BESS charging after max harmonious counsumption
    let AN = 341640
    for i in 1..<8760 { xy[AN + i] = min(BESS_charging_max_cons, xy[AF + i]) }

    /// Aux electricity for CSP SF and PV Plant MWel
    let AP = 359160
    for i in 1..<8760 { xy[AP + i] = iff(xy[J + i] > 0, xy[J + i] * CSP_var_aux_nom_perc, CSP_nonsolar_aux_cons) + max(0, -xy[L + i]) }

    /// Available PV power MWel
    let AQ = 367920
    for i in 1..<8760 { xy[AQ + i] = max(0, xy[L + i] - xy[AP + i]) }

    /// Not covered aux electricity for PB stby, CSP SF and PV Plant MWel
    let AR = 376680
    for i in 1..<8760 { xy[AR + i] = max(0, xy[AP + i] - xy[AQ + i]) }

    /// Max possible PV electricity to TES
    let AS = 385440
    var ASsum = 122
    for i in 1..<8760 {
      xy[AS + i] = max(0, min(xy[AQ + i] * (1 - (1 + 1 / Ratio_CSP_vs_Heater) * TES_Aux_elec_percentage), Heater_cap, xy[J + i] * Ratio_CSP_vs_Heater / Heater_eff))
      xy[ASsum + day[i]] += xy[AS + i]
    }
    /*
  /// Remaining PV after TES
  let AT = 394200
  for i in 1..<8760 {
    xy[AT + i] = max(
      0,
      xy[AQ + i] - xy[AS + i] * (1 + (1 + 1 / Ratio_CSP_vs_Heater) * TES_Aux_elec_percentage)
    )
  }

  /// Maximum TES energy per PV day
  let AU = 402960
  for i in 1..<8760 {
    xy[AU + i] = min(
      TES_Thermal_capacity,
      ASsum[day[i]] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)
    )
  }

  /// Surplus energy due to TES size limit
  let AV = 411720
  for i in 1..<8760 {
    xy[AV + i] = max(
      0,
      ASsum[day[i]] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater) - TES_Thermal_capacity
    )
  }

  /// Peripherial hour heater Operation
  let AW = 420480
  var AWsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[AW + i] = iff(
      or(
        and(xy[AV + i] > 0, xy[AS + i] < Heater_cap, xy[AS + i] > 0, xy[AS + i - 1] == 0),
        and(xy[AV + i] > 0, xy[AS + i] < Heater_cap, xy[AS + i + 1] == 0, xy[AS + i] > 0)
      ),
      xy[AS + i],
      0
    )
    AWsum[day[i]] += xy[AW + i]
  }

  /// Surplus energy due to TES size limit after removal of peripherial hours
  let AX = 429240
  for i in 1..<8760 {
    xy[AX + i] = max(
      0,
      xy[AV + i] - AWsum[day[i]] * Heater_eff
        * (1 + 1 / Ratio_CSP_vs_Heater)
    )
  }

  /// corrected max possible PV electricity to TES
  let AY = 438000
  for i in 1..<8760 {
    xy[AY + i] = iff(
      xy[AV + i] > xy[AX + i],
      iff(
        xy[AX + i] > 0,
        xy[AS + i] - xy[AW + i],
        xy[AS + i]
          - iff(
            xy[AW + i] == 0,
            0,
            xy[AV + i] / Heater_eff / (1 + 1 / Ratio_CSP_vs_Heater)
              / AWsum[[day[i]] * xy[AW + i]
          )
      ),
      xy[AS + i]
    )
  }

  /// Hours of above average heater Operation
  let AZ = 446760
  for i in 1..<8760 {
    xy[AZ + i] = countIFS(
      AY >= AVERAGEIFS(AY, AY > 0, day),
      day
    )
  }

  /// corrected max possible PV electricity to TES
  let BA = 455520
  for i in 1..<8760 {
    xy[BA + i] = iff(
      xy[AZ + i] > 0,
      iff(
        and(
          xy[AY + i]
            >= AVERAGEIFS(
              AY,
              AY > 0,
              day
            ),
          xy[AX + i] > 0
        ),
        xy[AY + i] - xy[AX + i] / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff / xy[AZ + i],
        xy[AY + i]
      ),
      0
    )
  }

  /// Max possible CSP heat to TES
  let BB = 464280
  for i in 1..<8760 { xy[BB + i] = min(xy[J + i], xy[BA + i] * Heater_eff / Ratio_CSP_vs_Heater) }

  /// Not covered aux electricity for PB stby, TES charging, CSP SF and PV Plant MWel
  let BC = 473040
  for i in 1..<8760 {
    xy[BC + i] = xy[AR + i] + (xy[BA + i] * Heater_eff + xy[BB + i]) * TES_Aux_elec_percentage
  }

  /// Remaining PV after TES charging
  let BD = 481800
  var BDsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[BD + i] = max(0, xy[AQ + i] - xy[BA + i] - xy[BC + i])
    BDsum[day[i]] += xy[BD + i]
  }

  /// Remaining CSP heat after TES
  let BE = 490560
  for i in 1..<8760 { xy[BE + i] = xy[J + i] - xy[BB + i] }

  /// Min harmonious net electricity counsumption
  let BF = 499320
  for i in 1..<8760 {
    xy[BF + i] = iff(
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
        xy[BD + i] + grid_max_import - PB_stby_aux_cons,
        min(
          xy[BE + i] + El_boiler_cap * El_boiler_eff,
          (xy[BD + i] + grid_max_import - PB_stby_aux_cons)
            / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons + max(
              0,
              (Overall_harmonious_max_var_heat_cons - xy[BE + i])
            ) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons
          * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons)
      ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
      0,
      Overall_harmonious_min_var_cons + Overall_fix_aux_cons
    )
  }

  /// Optimized min harmonious net electricity counsumption
  let BG = 508080
  for i in 1..<8760 {
    xy[BG + i] = iff(
      and(xy[BF + i] > 0, xy[BF + i - 1] == 0, countiff(xy[(BF + i)...].prefix(2), { $0 > 0 }) > 0),
      0,
      xy[BF + i]
    )
  }

  /// Min harmonious net heat counsumption
  let BH = 516840
  for i in 1..<8760 {
    xy[BH + i] =
      xy[BG + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
      * Overall_harmonious_max_var_heat_cons
  }

  /// Photovoltaic day
  let BI = 525600
  for i in 1..<8760 {
    xy[BI + i] = iff(and(xy[BG + i - 1] <= 0, xy[BG + i] > 0), xy[BI + i - 1] + 1, xy[BI + i - 1])
  }

  /// Not covered aux electricity PB stby, forTES charging, CSP SF and PV Plant MWel
  let BJ = 534360
  for i in 1..<8760 { xy[BJ + i] = xy[BC + i] + iff(xy[BG + i] > 0, PB_stby_aux_cons, 0) }

  /// Remaining PV after min harmonious
  let BK = 543120
  for i in 1..<8760 {
    xy[BK + i] = max(
      0,
      xy[BD + i] - xy[BG + i] - max(0, (xy[BH + i] - xy[BE + i]) / El_boiler_eff) - xy[BJ + i]
    )
  }

  /// Remaining CSP heat after min harmonious
  let BL = 551880
  for i in 1..<8760 { xy[BL + i] = max(0, xy[BE + i] - xy[BH + i]) }

  /// Not covered aux electricity MWel
  let BM = 560640
  for i in 1..<8760 {
    xy[BM + i] = max(
      0,
      min(
        xy[BJ + i],
        -(xy[BD + i] - xy[BG + i] - max(0, (xy[BH + i] - xy[BE + i]) / El_boiler_eff) - xy[BJ + i])
      )
    )
  }

  /// Grid import necessary for min harmonious
  let BN = 569400
  for i in 1..<8760 {
    xy[BN + i] = max(
      0,
      -(xy[BD + i] - xy[BG + i] - max(0, (xy[BH + i] - xy[BE + i]) / El_boiler_eff)) + xy[BJ + i]
    )
  }

  /// Remaining grid import capacity after min harmonious
  let BO = 578160
  for i in 1..<8760 { xy[BO + i] = grid_max_import - xy[BN + i] }

  /// Remaining electric boiler capacity after min harmonious heat counsumption
  let BP = 586920
  for i in 1..<8760 {
    xy[BP + i] = max(
      0,
      min(
        El_boiler_cap - max(0, (xy[BH + i] - xy[BL + i]) / El_boiler_eff),
        xy[BK + i] + xy[BO + i]
      )
    )
  }

  /// Remaining MethSynt capacity after min harmonious counsumption
  let BQ = 595680
  for i in 1..<8760 {
    xy[BQ + i] = max(
      0,
      min(
        (1 - xy[BG + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
          / MethDist_harmonious_min_perc * MethSynt_harmonious_min_perc)
          * MethSynt_RawMeth_nom_prod,
        (xy[BK + i] + xy[BO + i]) / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons)
          * MethSynt_RawMeth_nom_prod
      )
    )
  }

  /// Remaining CCU capacity after min harmonious counsumption
  let BR = 604440
  for i in 1..<8760 {
    xy[BR + i] = max(
      0,
      min(
        (1 - xy[BG + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
          / MethDist_harmonious_min_perc * CCU_harmonious_min_perc),
        (xy[BK + i] + xy[BO + i])
          / (CCU_var_aux_nom_cons + CCU_fix_aux_cons + max(0, CCU_var_heat_nom_cons - xy[BL + i])
            / El_boiler_eff),
        ifFinite(xy[BP + i] / (max(0, CCU_var_heat_nom_cons - xy[BL + i]) / El_boiler_eff), 1)
      ) * CCU_CO2_nom_prod
    )
  }

  /// Remaining EY capacity after min harmonious counsumption
  let BS = 613200
  for i in 1..<8760 {
    xy[BS + i] = max(
      0,
      min(
        (1 - xy[BG + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
          / MethDist_harmonious_min_perc * EY_harmonious_min_perc),
        (xy[BK + i] + xy[BO + i])
          / (EY_var_gross_nom_cons + EY_fix_aux_elec + max(0, EY_var_heat_nom_cons - xy[BL + i])
            / El_boiler_eff),
        ifFinite(xy[BP + i] / (max(0, EY_var_heat_nom_cons - xy[BL + i]) / El_boiler_eff), 1)
      ) * EY_H2_nom_prod
    )
  }

  /// Max BESS charging after min harmonious counsumption
  let BT = 621960
  for i in 1..<8760 { xy[BT + i] = min(BESS_charging_max_cons, xy[BK + i]) }

  /// Max harmonious net electricity counsumption
  let BU = 630720
  for i in 1..<8760 {
    xy[BU + i] = iff(
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
        xy[BD + i] + grid_max_import - PB_stby_aux_cons,
        min(
          xy[BE + i] + El_boiler_cap * El_boiler_eff,
          (xy[BD + i] + grid_max_import - PB_stby_aux_cons)
            / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons + max(
              0,
              (Overall_harmonious_max_var_heat_cons - xy[BE + i])
            ) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons
          * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons)
      ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons + PB_stby_aux_cons,
      0,
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
        xy[BD + i] + grid_max_import - PB_stby_aux_cons,
        min(
          xy[BE + i] + El_boiler_cap * El_boiler_eff,
          (xy[BD + i] + grid_max_import - PB_stby_aux_cons)
            / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons + max(
              0,
              (Overall_harmonious_max_var_heat_cons - xy[BE + i])
            ) / El_boiler_eff) * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons
          * (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
      )
    )
  }

  /// Optimized max harmonious net electricity counsumption
  let BV = 639480
  for i in 1..<8760 {
    xy[BV + i] = iff(
      and(xy[BU + i] > 0, xy[BU + i - 1] == 0, countiff(xy[(BU + i)...].prefix(2), { $0 > 0 }) > 0),
      0,
      xy[BU + i]
    )
  }

  /// max harmonious net heat counsumption
  let BW = 648240
  for i in 1..<8760 {
    xy[BW + i] =
      xy[BV + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
      * Overall_harmonious_max_var_heat_cons
  }

  /// Not covered aux electricity PB stby, forTES charging, CSP SF and PV Plant MWel
  let BX = 657000
  for i in 1..<8760 { xy[BX + i] = xy[BC + i] + iff(xy[BV + i] > 0, PB_stby_aux_cons, 0) }

  /// Remaining PV after max harmonious
  let BY = 665760
  for i in 1..<8760 {
    xy[BY + i] = max(
      0,
      xy[BD + i] - xy[BV + i] - max(0, (xy[BW + i] - xy[BE + i]) / El_boiler_eff) - xy[BX + i]
    )
  }

  /// Remaining CSP heat after max harmonious
  let BZ = 674520
  for i in 1..<8760 { xy[BZ + i] = max(0, xy[BE + i] - xy[BW + i]) }

  /// Not covered aux electricity MWel
  let CA = 683280
  for i in 1..<8760 {
    xy[CA + i] = max(
      0,
      min(
        xy[BX + i],
        -(xy[BD + i] - xy[BV + i] - max(0, (xy[BW + i] - xy[BE + i]) / El_boiler_eff) - xy[BX + i])
      )
    )
  }

  /// Grid import necessary for max harmonious
  let CB = 692040
  for i in 1..<8760 {
    xy[CB + i] = max(
      0,
      -(xy[BD + i] - xy[BV + i] - max(0, (xy[BW + i] - xy[BE + i]) / El_boiler_eff)) + xy[BX + i]
    )
  }

  /// Remaining grid import capacity after max harmonious
  let CC = 700800
  for i in 1..<8760 { xy[CC + i] = grid_max_import - xy[CB + i] }

  /// Remaining electric boiler capacity after max harmonious heat counsumption
  let CD = 709560
  for i in 1..<8760 {
    xy[CD + i] = max(
      0,
      min(El_boiler_cap - max(0, (xy[BW + i] - xy[J + i]) / El_boiler_eff), xy[BY + i] + xy[CC + i])
    )
  }

  /// Remaining MethSynt capacity after max harmonious counsumption
  let CE = 718320
  for i in 1..<8760 {
    xy[CE + i] = max(
      0,
      min(
        (1 - xy[BV + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
          / MethDist_harmonious_min_perc * MethSynt_harmonious_min_perc)
          * MethSynt_RawMeth_nom_prod,
        (xy[BY + i] + xy[CC + i]) / (MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons)
          * MethSynt_RawMeth_nom_prod
      )
    )
  }

  /// Remaining CCU capacity after max harmonious counsumption
  let CF = 727080
  for i in 1..<8760 {
    xy[CF + i] = max(
      0,
      min(
        (1 - xy[BV + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
          / MethDist_harmonious_min_perc * CCU_harmonious_min_perc),
        (xy[BY + i] + xy[CC + i])
          / (CCU_var_aux_nom_cons + CCU_fix_aux_cons + max(0, CCU_var_heat_nom_cons - xy[BZ + i])
            / El_boiler_eff),
        ifFinite(xy[CD + i] / (max(0, CCU_var_heat_nom_cons - xy[BZ + i]) / El_boiler_eff), 1)
      ) * CCU_CO2_nom_prod
    )
  }

  /// Remaining EY capacity after max harmonious counsumption
  let CG = 735840
  for i in 1..<8760 {
    xy[CG + i] = max(
      0,
      min(
        (1 - xy[BV + i] / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons)
          / MethDist_harmonious_min_perc * EY_harmonious_min_perc),
        (xy[BY + i] + xy[CC + i])
          / (EY_var_gross_nom_cons + EY_fix_aux_elec + max(0, EY_var_heat_nom_cons - xy[BZ + i])
            / El_boiler_eff),
        ifFinite(xy[CD + i] / (max(0, EY_var_heat_nom_cons - xy[BZ + i]) / El_boiler_eff), 1)
      ) * EY_H2_nom_prod
    )
  }

  /// Max BESS charging after max harmonious counsumption
  let CH = 744600
  for i in 1..<8760 { xy[CH + i] = min(BESS_charging_max_cons, xy[BY + i]) }

  /// Remaining CSP heat after TES charging
  let CU = 858480
  for i in 1..<8760 {
    xy[CU + i] = max(0, xy[J + i] - xy[BA + i] * Heater_eff / Ratio_CSP_vs_Heater)
  }

  /// Min harmonious net electricity counsumption
  let CV = 867240
  for i in 1..<8760 {
    xy[CV + i] = iff(
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
        xy[BD + i],
        min(
          xy[CU + i] + El_boiler_cap * El_boiler_eff,
          xy[BD + i] / (Overall_harmonious_max_var_cons
              + (Overall_harmonious_max_var_heat_cons - xy[CU + i]) / El_boiler_eff)
            * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons * Overall_harmonious_max_var_cons
      ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons,
      0,
      Overall_harmonious_min_var_cons + Overall_fix_aux_cons
    )
  }

  /// Min harmonious net heat counsumption
  let CW = 876000
  for i in 1..<8760 {
    xy[CW + i] =
      xy[CV + i] / Overall_harmonious_var_cons_at_PB_min * Overall_harmonious_var_heat_cons_at_PB_min
  }

  /// Remaining PV after TES and min harmonious
  let CX = 884760
  var CXsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[CX + i] = xy[BD + i] - xy[CV + i] - max(0, (xy[CW + i] - xy[CU + i]) / El_boiler_eff)
    CXsum[day[i]] += xy[CX + i]
  }

  /// Remaining CSP heat after TES and min harmonious
  let CY = 893520
  var CYsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[CY + i] = max(0, xy[CU + i] - xy[CW + i])
    CYsum[day[i]] += xy[CY + i]
  }

  /// Max harmonious net electricity counsumption
  let CZ = 902280
  for i in 1..<8760 {
    xy[CZ + i] = iff(
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
        xy[BD + i],
        min(
          xy[CU + i] + El_boiler_cap * El_boiler_eff,
          xy[BD + i]
            / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons
              + (Overall_harmonious_max_var_heat_cons - xy[CU + i]) / El_boiler_eff)
            * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons * Overall_harmonious_max_var_cons
          + Overall_fix_aux_cons
      ) < Overall_harmonious_min_var_cons + Overall_fix_aux_cons,
      0,
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
        xy[BD + i],
        min(
          xy[CU + i] + El_boiler_cap * El_boiler_eff,
          xy[BD + i]
            / (Overall_harmonious_max_var_cons + Overall_fix_aux_cons
              + (Overall_harmonious_max_var_heat_cons - xy[CU + i]) / El_boiler_eff)
            * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons * Overall_harmonious_max_var_cons
          + Overall_fix_aux_cons
      )
    )
  }

  /// Max harmonious net heat counsumption
  let DA = 911040
  for i in 1..<8760 {
    xy[DA + i] = xy[CZ + i] / Overall_harmonious_max_var_cons * Overall_harmonious_max_var_heat_cons
  }

  /// Remaining PV after TES and max harmonious
  let DB = 919800
  for i in 1..<8760 {
    xy[DB + i] = xy[BD + i] - xy[CZ + i] - max(0, (xy[DA + i] - xy[CU + i]) / El_boiler_eff)
  }

  /// Remaining CSP heat after TES and max harmonious
  let DC = 928560
  for i in 1..<8760 { xy[DC + i] = max(0, xy[CU + i] - xy[DA + i]) }

  /// Estimated surplus electricity consumption for case A night operation
  let DD = 937320
  for i in 1..<8760 {
    xy[DD + i] =
      countIFS(dayPV, CV == 0)
      * (A_CO2_min_cons / CCU_CO2_nom_prod * CCU_var_aux_nom_cons + CCU_fix_aux_cons + A_H2_min_cons
        / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_aux_elec)
      + sumiff(dayPV, CX)
  }

  /// Estimated surplus heat consumption for case A night operation
  let DE = 946080
  for i in 1..<8760 {
    xy[DE + i] =
      countIFS(dayPV, CW == 0)
      * (A_CO2_min_cons / CCU_CO2_nom_prod * CCU_var_heat_nom_cons + A_H2_min_cons / EY_H2_nom_prod
        * EY_var_heat_nom_cons) + sumiff(dayPV, CY)
  }

  /// Abs min net electricity, methanol only
  let DF = 954840
  for i in 1..<8760 {
    xy[DF + i] = iff(
      xy[CZ + i] > 0,
      0,
      (A_overall_var_min_cons + Overall_fix_aux_cons + max(0, xy[M + i] - max(0, xy[L + i]))
        + (min(
          PB_nom_net_cap,
          max(
            PB_net_min_cap,
            A_overall_var_min_cons + Overall_fix_aux_cons + max(0, xy[M + i] - max(0, xy[L + i]))
          )
        ) / PB_net_min_cap * PB_gross_min_cap / PB_gross_min_eff + A_overall_var_heat_min_cons
          * PB_Ratio_Heat_input_vs_output) * TES_Aux_elec_percentage)
    )
  }

  /// Corrected abs min net elec, methanol only
  let DG = 963600
  for i in 1..<8760 {
    xy[DG + i] = iff(
      and(xy[DF + i] > 0, xy[DF + i - 1] == 0, countiff(xy[DF + i], DF9, 0) > 0),
      0,
      xy[DF + i]
    )
  }

  /// Corresponding PB abs min net electricity output
  let DH = 972360
  for i in 1..<8760 {
    xy[DH + i] = max(
      0,
      min(
        PB_nom_net_cap,
        iff(
          xy[DG + i] == 0,
          0,
          iff(
            xy[CX + i] > xy[DG + i]
              + max(0, (A_overall_var_heat_min_cons - xy[CY + i]) / El_boiler_eff),
            0,
            iff(
              xy[DG + i] - xy[CX + i] < PB_net_min_cap,
              PB_net_min_cap,
              max(PB_net_min_cap, xy[DG + i] - xy[CX + i])
            )
          )
        )
      )
    )
  }

  /// Abs min net elec, methanol only
  let DI = 981120
  for i in 1..<8760 {
    xy[DI + i] = iff(
      xy[CZ + i] > 0,
      0,
      (A_overall_var_max_cons + Overall_fix_aux_cons + max(0, xy[M + i] - max(0, xy[L + i]))
        + (min(
          PB_nom_net_cap,
          max(
            PB_net_min_cap,
            A_overall_var_max_cons + Overall_fix_aux_cons + max(0, xy[M + i] - max(0, xy[L + i]))
          )
        ) / PB_net_min_cap * PB_gross_min_cap / PB_gross_min_eff + A_overall_var_heat_max_cons
          * PB_Ratio_Heat_input_vs_output) * TES_Aux_elec_percentage)
    )
  }

  /// Corrected abs min net elec, methanol only
  let DJ = 989880
  for i in 1..<8760 {
    xy[DJ + i] = iff(
      and(xy[DI + i] > 0, xy[DI + i - 1] == 0, countiff(xy[DI + i], DI9, 0) > 0),
      0,
      xy[DI + i]
    )
  }

  /// Corresponding PB abs min net electricity output
  let DK = 998640
  for i in 1..<8760 {
    xy[DK + i] = max(
      0,
      min(
        PB_nom_net_cap,
        iff(
          xy[DJ + i] == 0,
          0,
          iff(
            xy[CX + i] > xy[DJ + i]
              + max(0, (A_overall_var_heat_max_cons - xy[CY + i]) / El_boiler_eff),
            0,
            iff(
              xy[DJ + i] - xy[CX + i] < PB_net_min_cap,
              PB_net_min_cap,
              max(PB_net_min_cap, xy[DJ + i] - xy[CX + i])
            )
          )
        )
      )
    )
  }

  /// Abs min net elec, meth+co2
  let DL = 1_007_400
  for i in 1..<8760 {
    xy[DL + i] = iff(
      xy[CZ + i] > 0,
      0,
      (B_overall_var_min_cons + Overall_fix_aux_cons + max(0, xy[M + i] - max(0, xy[L + i]))
        + (min(
          PB_nom_net_cap,
          max(
            PB_net_min_cap,
            B_overall_var_min_cons + Overall_fix_aux_cons + max(0, xy[M + i] - max(0, xy[L + i]))
          )
        ) / PB_net_min_cap * PB_gross_min_cap / PB_gross_min_eff + B_overall_var_heat_min_cons
          * PB_Ratio_Heat_input_vs_output) * TES_Aux_elec_percentage)
    )
  }

  /// Corrected abs min net elec, meth+co2
  let DM = 1_016_160
  for i in 1..<8760 {
    xy[DM + i] = iff(
      and(xy[DL + i] > 0, xy[DL + i - 1] == 0, countiff(xy[DL + i], DL9, 0) > 0),
      0,
      xy[DL + i]
    )
  }

  /// Corresponding PB min net electricity output
  let DN = 1_024_920
  for i in 1..<8760 {
    xy[DN + i] = max(
      0,
      min(
        PB_nom_net_cap,
        iff(
          xy[DM + i] == 0,
          0,
          iff(
            xy[CX + i] > xy[DM + i]
              + max(0, (B_overall_var_heat_min_cons - xy[CY + i]) / El_boiler_eff),
            0,
            iff(
              xy[DM + i] - xy[CX + i] < PB_net_min_cap,
              PB_net_min_cap,
              max(PB_net_min_cap, xy[DM + i] - xy[CX + i])
            )
          )
        )
      )
    )
  }

  /// Abs max net elec, meth+co2
  let DO = 1_033_680
  for i in 1..<8760 {
    xy[DO + i] = iff(
      xy[CZ + i] > 0,
      0,
      (B_overall_var_max_cons + Overall_fix_aux_cons + max(0, xy[M + i] - max(0, xy[L + i]))
        + (min(
          PB_nom_net_cap,
          max(
            PB_net_min_cap,
            B_overall_var_max_cons + Overall_fix_aux_cons + max(0, xy[M + i] - max(0, xy[L + i]))
          )
        ) / PB_net_min_cap * PB_gross_min_cap / PB_gross_min_eff + B_overall_var_heat_max_cons
          * PB_Ratio_Heat_input_vs_output) * TES_Aux_elec_percentage)
    )
  }

  /// Corrected abs max net electricity, meth+co2
  let DP = 1_042_440
  for i in 1..<8760 {
    xy[DP + i] = iff(
      and(xy[DO + i] > 0, xy[DO + i - 1] == 0, countiff(xy[DO + i], DO9, 0) > 0),
      0,
      xy[DO + i]
    )
  }

  /// Corresponding PB net electricity output
  let DQ = 1_051_200
  for i in 1..<8760 {
    xy[DQ + i] = max(
      0,
      min(
        PB_nom_net_cap,
        iff(
          xy[DP + i] == 0,
          0,
          iff(
            xy[CX + i] > xy[DP + i]
              + max(0, (B_overall_var_heat_max_cons - xy[CY + i]) / El_boiler_eff),
            0,
            iff(
              xy[DP + i] - xy[CX + i] < PB_net_min_cap,
              PB_net_min_cap,
              max(PB_net_min_cap, xy[DP + i] - xy[CX + i])
            )
          )
        )
      )
    )
  }

  /// min net elec, meth+co2 harmonic+EY variable
  let DR = 1_059_960
  for i in 1..<8760 {
    xy[DR + i] = iff(
      xy[CZ + i] > 0,
      0,
      (C_overall_var_min_cons + Overall_fix_aux_cons + max(0, xy[M + i] - max(0, xy[L + i]))
        + (min(
          PB_nom_net_cap,
          max(
            PB_net_min_cap,
            C_overall_var_min_cons + Overall_fix_aux_cons + max(0, xy[M + i] - max(0, xy[L + i]))
          )
        ) / PB_net_min_cap * PB_gross_min_cap / PB_gross_min_eff + C_overall_var_heat_min_cons
          * PB_Ratio_Heat_input_vs_output) * TES_Aux_elec_percentage)
    )
  }

  /// Corrected min net elec, meth+co2 harmonic+EY variable
  let DS = 1_068_720
  for i in 1..<8760 {
    xy[DS + i] = iff(
      and(xy[DR + i] > 0, xy[DR + i - 1] == 0, countiff(xy[DR + i], DR9, 0) > 0),
      0,
      xy[DR + i]
    )
  }

  /// Corresponding PB net electricity output
  let DT = 1_077_480
  for i in 1..<8760 {
    xy[DT + i] = max(
      0,
      min(
        PB_nom_net_cap,
        iff(
          xy[DS + i] == 0,
          0,
          iff(
            xy[CX + i] > xy[DS + i]
              + max(0, (C_overall_var_heat_min_cons - xy[CY + i]) / El_boiler_eff),
            0,
            iff(
              xy[DS + i] - xy[CX + i] < PB_net_min_cap,
              PB_net_min_cap,
              max(PB_net_min_cap, xy[DS + i] - xy[CX + i])
            )
          )
        )
      )
    )
  }

  /// min harmonic meth+co2+EY
  let DU = 1_086_240
  for i in 1..<8760 {
    xy[DU + i] = iff(
      xy[CZ + i] > 0,
      0,
      (E_overall_var_aux_min_cons + Overall_fix_aux_cons + max(0, xy[M + i] - max(0, xy[L + i]))
        + (min(
          PB_nom_net_cap,
          max(
            PB_net_min_cap,
            E_overall_var_aux_min_cons + Overall_fix_aux_cons
              + max(0, xy[M + i] - max(0, xy[L + i]))
          )
        ) / PB_net_cap_at_min_harmonious * PB_gross_cap_at_min_harmonious
          / PB_eff_at_min_harmounious + D_overall_var_heat_min_cons * PB_Ratio_Heat_input_vs_output)
          * TES_Aux_elec_percentage)
    )
  }

  /// Corrected min harmonic meth+co2+EY
  let DV = 1_095_000
  for i in 1..<8760 {
    xy[DV + i] = iff(
      and(xy[DU + i] > 0, xy[DU + i - 1] == 0, countiff(xy[DU + i], DU9, 0) > 0),
      0,
      xy[DU + i]
    )
  }

  /// Corresponding PB net electricity output
  let DW = 1_103_760
  for i in 1..<8760 {
    xy[DW + i] = max(
      0,
      min(
        PB_nom_net_cap,
        iff(
          xy[DV + i] == 0,
          0,
          iff(
            xy[CX + i] > xy[DV + i]
              + max(0, (D_overall_var_heat_min_cons - xy[CY + i]) / El_boiler_eff),
            0,
            iff(
              xy[DV + i] - xy[CX + i] < PB_net_min_cap,
              PB_net_min_cap,
              max(PB_net_min_cap, xy[DV + i] - xy[CX + i])
            )
          )
        )
      )
    )
  }

  /// max harmonic meth+co2+EY
  let DX = 1_112_520
  for i in 1..<8760 {
    xy[DX + i] = iff(
      Overall_harmonious_max_var_cons + Overall_fix_aux_cons <= xy[CZ + i],
      0,
      (min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons - xy[CZ + i],
        E_overall_var_aux_max_cons + Overall_fix_aux_cons
      ) + max(0, xy[M + i] - max(0, xy[L + i])))
        * (1 + TES_Aux_elec_percentage
          * (1 / PB_net_cap_at_max_harmonious * PB_gross_cap_at_max_harmonious
            / PB_eff_at_max_harmonious + D_overall_var_heat_max_cons
            / Overall_harmonious_max_var_cons * PB_Ratio_Heat_input_vs_output))
    )
  }

  /// Corrected max harmonic meth+co2+EY
  let DY = 1_121_280
  for i in 1..<8760 {
    xy[DY + i] = iff(
      and(xy[DX + i] > 0, xy[DX + i - 1] == 0, countiff(xy[DX + i], DX9, 0) > 0),
      0,
      xy[DX + i]
    )
  }

  /// Corresponding PB net electricity output
  let DZ = 1_130_040
  for i in 1..<8760 {
    xy[DZ + i] = max(
      0,
      min(
        PB_nom_net_cap,
        iff(
          xy[DY + i] == 0,
          0,
          iff(
            xy[DB + i] > xy[DY + i]
              + max(0, (D_overall_var_heat_max_cons - xy[DC + i]) / El_boiler_eff),
            0,
            iff(
              xy[DY + i] - xy[DB + i] < PB_net_min_cap,
              PB_net_min_cap,
              max(PB_net_min_cap, xy[DY + i] - xy[DB + i])
            )
          )
        )
      )
    )
  }

  /// PB at min methsynt and methanol distallationgross electricity output
  let EA = 1_138_800
  for i in 1..<8760 {
    xy[EA + i] = iff(
      xy[DH + i] == 0,
      0,
      xy[DH + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
        * (PB_n2g_var_aux_el(xy[DH + i] / PB_nom_net_cap)) + PB_fix_aux_el
    )
  }

  /// PB at max methsynt and methanol distallationgross electricity output
  let EB = 1_147_560
  for i in 1..<8760 {
    xy[EB + i] = iff(
      xy[DK + i] == 0,
      0,
      xy[DK + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
        * PB_n2g_var_aux_el(xy[DK + i] / PB_nom_net_cap) + PB_fix_aux_el
    )
  }

  /// PB abs min op incl co2 gross electricity output
  let EC = 1_156_320
  for i in 1..<8760 {
    xy[EC + i] = iff(
      xy[DN + i] == 0,
      0,
      xy[DN + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
        * PB_n2g_var_aux_el(xy[DN + i] / PB_nom_net_cap) + PB_fix_aux_el
    )
  }

  /// PB op incl max co2 gross electricity output
  let ED = 1_165_080
  for i in 1..<8760 {
    xy[ED + i] = iff(
      xy[DQ + i] == 0,
      0,
      xy[DQ + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
        * PB_n2g_var_aux_el(xy[DQ + i] / PB_nom_net_cap) + PB_fix_aux_el
    )
  }

  /// PB op incl co2 and ey gross electricity output
  let EE = 1_173_840
  for i in 1..<8760 {
    xy[EE + i] = iff(
      xy[DT + i] == 0,
      0,
      xy[DT + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
        * PB_n2g_var_aux_el(xy[DT + i] / PB_nom_net_cap) + PB_fix_aux_el
    )
  }

  /// PB min harmonic gross electricity output
  let EF = 1_182_600
  for i in 1..<8760 {
    xy[EF + i] = iff(
      xy[DW + i] == 0,
      0,
      xy[DW + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
        * PB_n2g_var_aux_el(xy[DW + i] / PB_nom_net_cap) + PB_fix_aux_el
    )
  }

  /// PB nominal / max harmonic gross electricity output
  let EG = 1_191_360
  for i in 1..<8760 {
    xy[EG + i] = iff(
      xy[DZ + i] == 0,
      0,
      xy[DZ + i] + PB_nom_net_cap * PB_nom_var_aux_cons_perc_net
        * PB_n2g_var_aux_el(xy[DZ + i] / PB_nom_net_cap) + PB_fix_aux_el
    )
  }

  /// PB at min methanol distallation and synthese gross heat consumption for ST
  let EH = 1_200_120
  for i in 1..<8760 {
    xy[EH + i] = iff(
      and(xy[EA + i] == 0, EA6 > 0),
      iff(
        countiff(EA1, xy[EA + i], 0) == PB_warm_start_duration,
        PB_warm_start_heat_req,
        PB_hot_start_heat_req
      ),
      0
    )
  }

  /// PB at min methanol distallation and synthese gross heat consumption for ST
  let EI = 1_208_880
  for i in 1..<8760 {
    xy[EI + i] = iff(
      xy[EA + i] == 0,
      0,
      xy[EA + i] / PB_nom_gross_eff / el(xy[EA + i] / PB_nom_gross_cap)
    )
  }

  /// PB at min methanol distallation and synthese gross heat consumption for extraction
  let EJ = 1_217_640
  for i in 1..<8760 {
    xy[EJ + i] = iff(
      xy[EA + i] == 0,
      0,
      PB_Ratio_Heat_input_vs_output * A_overall_var_heat_min_cons
    )
  }

  /// PB at max methanol distallation and synthese gross heat consumption for ST
  let EK = 1_226_400
  for i in 1..<8760 {
    xy[EK + i] = iff(
      and(xy[EB + i] == 0, EB6 > 0),
      iff(
        countiff(EB1, xy[EB + i], 0) == PB_warm_start_duration,
        PB_warm_start_heat_req,
        PB_hot_start_heat_req
      ),
      0
    )
  }

  /// PB at max methanol distallation and synthese gross heat consumption for ST
  let EL = 1_235_160
  for i in 1..<8760 {
    xy[EL + i] = iff(
      xy[EB + i] == 0,
      0,
      xy[EB + i] / PB_nom_gross_eff
        / el(xy[EB + i] / PB_nom_gross_cap)
    )
  }

  /// PB at max methanol distallation and synthese gross heat consumption for extraction
  let EM = 1_243_920
  for i in 1..<8760 {
    xy[EM + i] = iff(
      xy[EB + i] == 0,
      0,
      PB_Ratio_Heat_input_vs_output * A_overall_var_heat_max_cons
    )
  }

  /// PB gross heat consumption for min meth&CO2 for ST
  let EN = 1_252_680
  var ENsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[EN + i] = iff(
      and(xy[EC + i] == 0, EC6 > 0),
      iff(
        countiff(EC1, xy[EC + i], 0) == PB_warm_start_duration,
        PB_warm_start_heat_req,
        PB_hot_start_heat_req
      ),
      0
    )
    ENsum[day[i]] += xy[EN + i]
  }

  /// PB gross heat consumption for min meth&CO2 for ST
  let EO = 1_261_440
  var EOsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[EO + i] = iff(
      xy[EC + i] == 0,
      0,
      xy[EC + i] / PB_nom_gross_eff / el(xy[EC + i] / PB_nom_gross_cap)
    )
    EOsum[day[i]] += xy[EO + i]
  }

  /// PB gross heat consumption for min meth&CO2 for Extr
  let EP = 1_270_200
  var EPsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[EP + i] = iff(
      xy[EC + i] == 0,
      0,
      PB_Ratio_Heat_input_vs_output * C_overall_var_heat_min_cons
    )
    EPsum[day[i]] += xy[EP + i]
  }

  /// PB gross heat consumption for max meth&CO2 for ST
  let EQ = 1_278_960
  var EQsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[EQ + i] = iff(
      and(xy[ED + i] == 0, ED6 > 0),
      iff(
        countiff(ED1, xy[ED + i], 0) == PB_warm_start_duration,
        PB_warm_start_heat_req,
        PB_hot_start_heat_req
      ),
      0
    )
    EQsum[day[i]] += xy[EQ + i]
  }

  /// PB gross heat consumption for max meth&CO2 for ST
  let ER = 1_287_720
  var ERsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[ER + i] = iff(
      xy[ED + i] == 0,
      0,
      xy[ED + i] / PB_nom_gross_eff / el(xy[ED + i] / PB_nom_gross_cap)
    )
    ERsum[day[i]] += xy[ER + i]
  }

  /// PB gross heat consumption for max meth&CO2 for Extraction
  let ES = 1_296_480
  var ESsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[ES + i] = iff(xy[ED + i] == 0, 0, PB_Ratio_Heat_input_vs_output * Input_Output_Summary_L108)
  }

  /// PB gross heat cons incl CO2 and EY for ST
  let ET = 1_305_240
  var ETsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[ET + i] = iff(
      and(xy[EE + i] == 0, EE6 > 0),
      iff(
        countiff(EE1, xy[EE + i], 0) == PB_warm_start_duration,
        PB_warm_start_heat_req,
        PB_hot_start_heat_req
      ),
      0
    )
    ETsum[day[i]] += xy[ET + i]
  }

  /// PB gross heat cons incl CO2 and EY for ST
  let EU = 1_314_000
  var EUsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[EU + i] = iff(
      xy[EE + i] == 0,
      0,
      xy[EE + i] / PB_nom_gross_eff
        / el(xy[EE + i] / PB_nom_gross_cap)
    )
    EUsum[day[i]] += xy[EU + i]
  }

  /// PB gross heat cons incl CO2 and EY for Extraction
  let EV = 1_322_760
  var EVsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[EV + i] = iff(
      xy[EE + i] == 0,
      0,
      PB_Ratio_Heat_input_vs_output * CD_overall_var_heat_min_cons
    )
    EVsum[day[i]] += xy[EV + i]
  }

  /// PB  min  harmonic gross heat consumption for ST
  let EW = 1_331_520
  var EWsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[EW + i] = iff(
      and(xy[EF + i] == 0, EF6 > 0),
      iff(
        countiff(EF1, xy[EF + i], 0) == PB_warm_start_duration,
        PB_warm_start_heat_req,
        PB_hot_start_heat_req
      ),
      0
    )
    EWsum[day[i]] += xy[EW + i]
  }

  /// PB  min  harmonic gross heat consumption for ST
  let EX = 1_340_280
  var EXsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[EX + i] = iff(
      xy[EF + i] == 0,
      0,
      xy[EF + i] / PB_nom_gross_eff / el(xy[EF + i] / PB_nom_gross_cap)
    )
    EXsum[day[i]] += xy[EX + i]
  }

  /// PB  min  harmonic gross heat consumption for Extr
  let EY = 1_349_040
  var EYsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[EY + i] = iff(
      xy[EF + i] == 0,
      0,
      PB_Ratio_Heat_input_vs_output * Overall_harmonious_max_var_heat_cons
        / Overall_harmonious_max_var_cons * xy[DW + i]
    )
    EYsum[day[i]] += xy[EY + i]
  }

  /// PB  max  harmonic gross heat consumption for ST
  let EZ = 1_357_800
  for i in 1..<8760 {
    xy[EZ + i] = iff(
      and(xy[EG + i] == 0, EG6 > 0),
      iff(
        countiff(EG1, xy[EG + i], 0) == PB_warm_start_duration,
        PB_warm_start_heat_req,
        PB_hot_start_heat_req
      ),
      0
    )
  }

  /// PB  max  harmonic gross heat consumption for ST
  let FA = 1_366_560
  var FAsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[FA + i] = iff(
      xy[EG + i] == 0,
      0,
      xy[EG + i] / PB_nom_gross_eff
        / el(xy[EG + i] / PB_nom_gross_cap)
    )
    FAsum[day[i]] += xy[FA + i]
  }

  /// PB  max  harmonic gross heat consumption for Extraction
  let FB = 1_375_320
  var FBsum = Array(repeating: 0.0, count: 366)
  for i in 1..<8760 {
    xy[FB + i] = iff(
      xy[EG + i] == 0,
      0,
      PB_Ratio_Heat_input_vs_output * Overall_harmonious_max_var_heat_cons
        / Overall_harmonious_max_var_cons * xy[DZ + i]
    )
    FBsum[day[i]] += xy[FB + i]
  }

  /// Maximum TES energy per PV day modified
  let FC = 1_384_080
  for i in 1..<8760 {
    xy[FC + i] = iff(
      xy[S + i] == S6,
      FC6,
      iff(
        xy[DD + i] + xy[DE + i] / El_boiler_eff < 0,
        0,
        iff(
          xy[AU + i] + FD6 < sumiff(dayPV, EH)
            + sumiff(dayPV, EI)
            + sumiff(dayPV, EJ),
          sumiff(dayPV, EH)
            + sumiff(dayPV, EI)
            + sumiff(dayPV, EJ),
          xy[AU + i] + FD6
        )
      )
    )
  }

  /// Reserve energy
  let FD = 1_392_840
  for i in 1..<8760 { xy[FD + i] = iff(xy[S + i] == S6, FD6, FD6 + xy[AU + i] - xy[FC + i]) }

  /// Check storage overflow
  let FE = 1_401_600
  for i in 1..<8760 {
    xy[FE + i] = iff(
      sumiff(dayPV, EH)
        + sumiff(dayPV, EI)
        + sumiff(dayPV, EJ) < xy[FC + i],
      xy[AU + i] - xy[FC + i],
      -SUM(xy[EH + i], xy[EJ + i]) + xy[CI + i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)
        + xy[FE + i - 1]
    )
  }

  /// days with storage overflow
  let FF = 1_410_360
  for i in 1..<8760 {
    xy[FF + i] = iff(
      and(xy[FF + i - 1] > 0, xy[FD + i] <> 0),
      xy[FF + i - 1],
      iff(
        countIFS(dayPV, FE  > TES_Thermal_capacity)
          > 0,
        1,
        0
      )
    )
  }

  /// days where PB must be stopped
  let FG = 1_419_120
  for i in 1..<8760 {
    xy[FG + i] = iff(
      and(xy[FF + i] == 1, FF6 == 0),
      1,
      iff(and(FG6 == 1, xy[AU + i] <> AU6), 0, FG6)
    )
  }

  /// Corrected Max TES energy per PV day modified
  let FH = 1_427_880
  for i in 1..<8760 {
    xy[FH + i] = iff(
      xy[S + i] == S6,
      FH6,
      iff(
        and(
          xy[FG + i] == 0,
          xy[AU + i] + FI6 < sumiff(dayPV, EH)
            + sumiff(dayPV, EI)
            + sumiff(dayPV, EJ)
        ),
        sumiff(dayPV, EH)
          + sumiff(dayPV, EI)
          + sumiff(dayPV, EJ),
        xy[AU + i] + FI6
      )
    )
  }

  /// Corrected reserve energy
  let FI = 1_436_640
  for i in 1..<8760 { xy[FI + i] = iff(xy[S + i] == S6, FI6, FI6 + xy[AU + i] - xy[FH + i]) }

  /// Check storage overflow again
  let FJ = 1_445_400
  for i in 1..<8760 {
    xy[FJ + i] = iff(
      or(
        xy[FH + i] == 0,
        sumiff(dayPV, EH)
          + sumiff(dayPV, EI)
          + sumiff(dayPV, EJ) < xy[FH + i]
      ),
      xy[AU + i] - xy[FH + i],
      -SUM(xy[EH + i], xy[EJ + i]) + xy[BD + i] * Heater_eff * (1 + 1 / Ratio_CSP_vs_Heater)
        + xy[FJ + i - 1]
    )
  }

  /// Op Mode
  let FK = 1_454_160
  for i in 1..<8760 {
    xy[FK + i] = iff(
      xy[FH + i] < sumiff(dayPV, EN)
        + sumiff(dayPV, EO)
        + sumiff(dayPV, EP),
      1,
      iff(
        xy[FH + i] < sumiff(dayPV, ET)
          + sumiff(dayPV, EU)
          + sumiff(dayPV, EV),
        2,
        iff(
          xy[FH + i] < sumiff(dayPV, EW)
            + sumiff(dayPV, EX)
            + sumiff(dayPV, EY),
          3,
          iff(
            xy[FH + i] < sumiff(dayPV, EZ)
              + sumiff(dayPV, FA)
              + sumiff(dayPV, FV),
            _[i - 1],
            _[i]
          )
        )
      )
    )
  }

  /// Proposed steam to ST
  let FL = 1_462_920
  for i in 1..<8760 {
    xy[FL + i] = iff(
      or(xy[FK + i] < 1, xy[FH + i] == 0),
      0,
      (sumiff(dayPV, EI)
        + sumiff(dayPV, EH)
        + (sumiff(dayPV, EL)
          - sumiff(dayPV, EI))
          * (min(
            xy[FH + i],
            sumiff(dayPV, EK)
              + sumiff(dayPV, EL)
              + sumiff(dayPV, EM)
          ) - sumiff(dayPV, EH)
            - sumiff(dayPV, EI)
            - sumiff(dayPV, EJ))
          / (sumiff(dayPV, EL)
            - sumiff(dayPV, EI)
            + sumiff(dayPV, EM)
            - sumiff(dayPV, EJ)))
    )
  }

  /// Proposed steam to extraction
  let FM = 1_471_680
  for i in 1..<8760 {
    xy[FM + i] = iff(
      xy[FL + i] == 0,
      0,
      (sumiff(dayPV, EJ)
        + (sumiff(dayPV, EM)
          - sumiff(dayPV, EJ))
          * (min(
            xy[FH + i],
            sumiff(dayPV, EK)
              + sumiff(dayPV, EL)
              + sumiff(dayPV, EM)
          ) - sumiff(dayPV, EH)
            - sumiff(dayPV, EI)
            - sumiff(dayPV, EJ))
          / (sumiff(dayPV, EL)
            - sumiff(dayPV, EI)
            + sumiff(dayPV, EM)
            - sumiff(dayPV, EJ)))
    )
  }

  /// Necessary raw methanol for night operation
  let FN = 1_480_440
  for i in 1..<8760 {
    xy[FN + i] = ROUND(
      iff(
        xy[FM + i] == 0,
        0,
        -(A_RawMeth_min_cons
          + (xy[FM + i] - sumiff(dayPV, EJ))
            / (sumiff(dayPV, EM)
              - sumiff(dayPV, EJ))
            * (A_RawMeth_max_cons - A_RawMeth_min_cons))
          * countIFS(dayPV, EM, >0)
      ),
      3
    )
  }

  /// Necessary CO2 for night operation
  let FO = 1_489_200
  for i in 1..<8760 {
    xy[FO + i] = ROUND(
      iff(
        xy[FM + i] == 0,
        0,
        -(A_CO2_min_cons
          + (xy[FM + i] - sumiff(dayPV, EJ))
            / (sumiff(dayPV, EM)
              - sumiff(dayPV, EJ))
            * (A_CO2_max_cons - A_CO2_min_cons))
          * countIFS(dayPV, EM, >0)
      ),
      3
    )
  }

  /// Necessary H2 for night operation
  let FP = 1_497_960
  for i in 1..<8760 {
    xy[FP + i] = ROUND(
      iff(
        xy[FM + i] == 0,
        0,
        -(A_H2_min_cons
          + (xy[FM + i] - sumiff(dayPV, EJ))
            / (sumiff(dayPV, EM)
              - sumiff(dayPV, EJ))
            * (A_H2_max_cons - A_H2_min_cons))
          * countIFS(dayPV, EM, >0)
      ),
      3
    )
  }

  /// Necessary electricity for prep of night incl CO2&H2 for raw methanol
  let FQ = 1_506_720
  for i in 1..<8760 {
    xy[FQ + i] =
      (xy[FP + i] + xy[FN + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_aux_elec
      + (xy[FO + i] + xy[FN + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod * CCU_var_aux_nom_cons + CCU_fix_aux_cons
      + xy[FN + i] / MethSynt_RawMeth_nom_prod * MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons
  }

  /// Necessary heat for prep of night incl CO2&H2 for raw methanol
  let FR = 1_515_480
  for i in 1..<8760 {
    xy[FR + i] =
      (xy[FP + i] + xy[FN + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
      + (xy[FO + i] + xy[FN + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod * CCU_var_heat_nom_cons + xy[FN + i]
      / MethSynt_RawMeth_nom_prod * MethSynt_var_heat_nom_prod
  }

  /// Addt. PV electricity available due to reduced PB load
  let FS = 1_524_240
  for i in 1..<8760 {
    xy[FS + i] = iff(
      xy[FL + i] == 0,
      0,
      max(
        0,
        (xy[FH + i] - SUM(xy[FL + i], xy[FM + i]))
          * (TES_Aux_elec_percentage + 1 / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff)
      )
    )
  }

  /// Addt. CSP heat available due to reduced PB load
  let FT = 1_533_000
  for i in 1..<8760 {
    xy[FT + i] = iff(
      xy[FL + i] == 0,
      0,
      max(0, (xy[FH + i] - SUM(xy[FL + i], xy[FM + i])) * 1 / (1 + Ratio_CSP_vs_Heater))
    )
  }

  /// Corrected steam to ST
  let FU = 1_541_760
  for i in 1..<8760 {
    xy[FU + i] = iff(
      xy[FV + i] == 0,
      0,
      xy[FL + i]
        - (sumiff(dayPV, EL)
          - sumiff(dayPV, EI))
        / (sumiff(dayPV, EM)
          - sumiff(dayPV, EJ)) * (xy[FM + i] - xy[FV + i])
    )
  }

  /// Corrected steam to extraction
  let FV = 1_550_520
  for i in 1..<8760 {
    xy[FV + i] = iff(
      min(
        ifFinite(RawMeth_storage_cap / xy[FN + i], 1),
        ifFinite(CO2_storage_cap / xy[FO + i], 1),
        ifFinite(H2_storage_cap / xy[FP + i], 1),
        ifFinite(
          max(
            0,
            (sumiff(dayPV, xy[CX + i], CX_end) + xy[FS + i]
              - (xy[FR + i] - xy[FT + i]
                - sumiff(dayPV, CY) / El_boiler_eff)
          ) / xy[FQ + i],
          1
        )
      ) * xy[FM + i] < sumiff(dayPV, EJ),
      0,
      min(
        1,
        ifFinite(RawMeth_storage_cap / xy[FN + i], 1),
        ifFinite(CO2_storage_cap / xy[FO + i], 1),
        ifFinite(H2_storage_cap / xy[FP + i], 1),
        ifFinite(
          max(
            0,
            (sumiff(dayPV, xy[CX + i], CX_end) + xy[FS + i]
              - (xy[FR + i] - xy[FT + i]
                - sumiff(dayPV, CY) / El_boiler_eff)
          ) / xy[FQ + i],
          1
        )
      ) * xy[FM + i]
    )
  }

  /// Necessary raw methanol for night
  let FW = 1_559_280
  for i in 1..<8760 { xy[FW + i] = ifFinite(xy[FN + i] / xy[FM + i] * xy[FV + i], 0) }

  /// Necessary CO2 for night
  let FX = 1_568_040
  for i in 1..<8760 { xy[FX + i] = ifFinite(xy[FO + i] / xy[FM + i] * xy[FV + i], 0) }

  /// Necessary H2 for night
  let FY = 1_576_800
  for i in 1..<8760 { xy[FY + i] = ifFinite(xy[FP + i] / xy[FM + i] * xy[FV + i], 0) }

  /// Necessary electricity for prep of night  incl CO2&H2 for raw methanol
  let FZ = 1_585_560
  for i in 1..<8760 { xy[FZ + i] = ifFinite(xy[FQ + i] / xy[FM + i] * xy[FV + i], 0) }

  /// Necessary heat for prep of night  incl CO2&H2 for raw methanol
  let GA = 1_594_320
  for i in 1..<8760 { xy[GA + i] = ifFinite(xy[FR + i] / xy[FM + i] * xy[FV + i], 0) }

  /// Proposed steam to ST
  let GC = 1_611_840
  for i in 1..<8760 {
    xy[GC + i] = iff(
      or(xy[FK + i] < 2, xy[FH + i] == 0),
      0,
      (sumiff(dayPV, EO)
        + sumiff(dayPV, EN)
        + (sumiff(dayPV, ER)
          - sumiff(dayPV, EO))
          * (min(
            xy[FH + i],
            sumiff(dayPV, EQ) + sumiff(dayPV, ER) + sumiff(dayPV, ES)
          ) - sumiff(dayPV, EN) - sumiff(dayPV, EO) - sumiff(dayPV, EP))
          / (sumiff(dayPV, ER) - sumiff(dayPV, EO) + sumiff(dayPV, ES) - sumiff(dayPV, EP)))
    )
  }

  /// Proposed steam to extraction
  let GD = 1_620_600
  for i in 1..<8760 {
    xy[GD + i] = iff(
      xy[GC + i] == 0,
      0,
      (sumiff(dayPV, EP)
        + (sumiff(dayPV, ES)
          - sumiff(dayPV, EP))
          * (min(
            xy[FH + i],
            sumiff(dayPV, EQ)
              + sumiff(dayPV, ER)
              + sumiff(dayPV, ES)
          ) - sumiff(dayPV, EN)
            - sumiff(dayPV, EO)
            - sumiff(dayPV, EP))
          / (sumiff(dayPV, ER)
            - sumiff(dayPV, EO)
            + sumiff(dayPV, ES)
            - sumiff(dayPV, EP)))
    )
  }

  /// Necessary raw methanol for night operation
  let GE = 1_629_360
  for i in 1..<8760 {
    xy[GE + i] = ROUND(
      iff(
        xy[GD + i] == 0,
        0,
        -(C_RawMeth_min_cons
          + (xy[GD + i] - sumiff(dayPV, EP))
            / (sumiff(dayPV, ES)
              - sumiff(dayPV, EP))
            * (C_RawMeth_max_cons - C_RawMeth_min_cons))
          * countIFS(dayPV, ES, >0)
      ),
      3
    )
  }

  /// Necessary CO2 for night operation
  let GF = 1_638_120
  for i in 1..<8760 {
    xy[GF + i] = ROUND(
      iff(
        xy[GD + i] == 0,
        0,
        -(C_CO2_min_cons
          + (xy[GD + i] - sumiff(dayPV, EP))
            / (sumiff(dayPV, ES)
              - sumiff(dayPV, EP))
            * (C_CO2_max_cons - C_CO2_min_cons))
          * countIFS(dayPV, ES, >0)
      ),
      3
    )
  }

  /// Necessary H2 for night operation
  let GG = 1_646_880
  for i in 1..<8760 {
    xy[GG + i] = ROUND(
      iff(
        xy[GD + i] == 0,
        0,
        -(C_H2_min_cons
          + (xy[GD + i] - sumiff(dayPV, EP))
            / (sumiff(dayPV, ES)
              - sumiff(dayPV, EP))
            * (C_H2_max_cons - C_H2_min_cons))
          * countIFS(dayPV, ES, >0)
      ),
      3
    )
  }

  /// Necessary electricity for prep of night incl CO2&H2 for raw methanol
  let GH = 1_655_640
  for i in 1..<8760 {
    xy[GH + i] =
      (xy[GG + i] + xy[GE + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_aux_elec
      + (xy[GF + i] + xy[GE + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod * CCU_var_aux_nom_cons + CCU_fix_aux_cons
      + xy[GE + i] / MethSynt_RawMeth_nom_prod * MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons
  }

  /// Necessary heat for prep of night incl CO2&H2 for raw methanol
  let GI = 1_664_400
  for i in 1..<8760 {
    xy[GI + i] =
      (xy[GG + i] + xy[GE + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
      + (xy[GF + i] + xy[GE + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod * CCU_var_heat_nom_cons + xy[GE + i]
      / MethSynt_RawMeth_nom_prod * MethSynt_var_heat_nom_prod
  }

  /// Addt. PV electricity available due to reduced PB load
  let GJ = 1_673_160
  for i in 1..<8760 {
    xy[GJ + i] = iff(
      xy[GC + i] == 0,
      0,
      max(
        0,
        (xy[FH + i] - SUM(xy[GC + i], xy[GD + i]))
          * (TES_Aux_elec_percentage + 1 / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff)
      )
    )
  }

  /// Addt. CSP heat available due to reduced PB load
  let GK = 1_681_920
  for i in 1..<8760 {
    xy[GK + i] = iff(
      xy[GC + i] == 0,
      0,
      max(0, (xy[FH + i] - SUM(xy[GC + i], xy[GD + i])) * 1 / (1 + Ratio_CSP_vs_Heater))
    )
  }

  /// Corrected steam to ST
  let GL = 1_690_680
  for i in 1..<8760 {
    xy[GL + i] = iff(
      xy[GM + i] == 0,
      0,
      xy[GC + i]
        - (sumiff(dayPV, ER)
          - sumiff(dayPV, EO))
        / (sumiff(dayPV, ES)
          - sumiff(dayPV, EP)) * (xy[GD + i] - xy[GM + i])
    )
  }

  /// Corrected steam to extraction
  let GM = 1_699_440
  for i in 1..<8760 {
    xy[GM + i] = iff(
      min(
        ifFinite(RawMeth_storage_cap / xy[GE + i], 1),
        ifFinite(CO2_storage_cap / xy[GF + i], 1),
        ifFinite(H2_storage_cap / xy[GG + i], 1),
        ifFinite(
          max(
            0,
            (sumiff(dayPV, xy[CX + i], CX_end) + xy[GJ + i]
              - (xy[GI + i] - xy[GK + i]
                - sumiff(dayPV, CY) / El_boiler_eff)
          ) / xy[GH + i],
          1
        )
      ) * xy[GD + i] < sumiff(dayPV, EP),
      0,
      min(
        1,
        ifFinite(RawMeth_storage_cap / xy[GE + i], 1),
        ifFinite(CO2_storage_cap / xy[GF + i], 1),
        ifFinite(H2_storage_cap / xy[GG + i], 1),
        ifFinite(
          max(
            0,
            (sumiff(dayPV, xy[CX + i], CX_end) + xy[GJ + i]
              - (xy[GI + i] - xy[GK + i]
                - sumiff(dayPV, CY) / El_boiler_eff)
          ) / xy[GH + i],
          1
        )
      ) * xy[GD + i]
    )
  }

  /// Necessary raw methanol for night
  let GN = 1_708_200
  for i in 1..<8760 { xy[GN + i] = ifFinite(xy[GE + i] / xy[GD + i] * xy[GM + i], 0) }

  /// Necessary CO2 for night
  let GO = 1_716_960
  for i in 1..<8760 { xy[GO + i] = ifFinite(xy[GF + i] / xy[GD + i] * xy[GM + i], 0) }

  /// Necessary H2 for night
  let GP = 1_725_720
  for i in 1..<8760 { xy[GP + i] = ifFinite(xy[GG + i] / xy[GD + i] * xy[GM + i], 0) }

  /// Necessary electricity for prep of night  incl CO2&H2 for raw methanol
  let GQ = 1_734_480
  for i in 1..<8760 { xy[GQ + i] = ifFinite(xy[GH + i] / xy[GD + i] * xy[GM + i], 0) }

  /// Necessary heat for prep of night  incl CO2&H2 for raw methanol
  let GR = 1_743_240
  for i in 1..<8760 { xy[GR + i] = ifFinite(xy[GI + i] / xy[GD + i] * xy[GM + i], 0) }

  /// Proposed steam to ST
  let GT = 1_760_760
  for i in 1..<8760 {
    xy[GT + i] = iff(
      or(xy[FK + i] < 3, xy[FH + i] == 0),
      0,
      (sumiff(dayPV, EU)
        + sumiff(dayPV, ET)
        + (sumiff(dayPV, EX)
          - sumiff(dayPV, EU))
          * (min(
            xy[FH + i],
            sumiff(dayPV, EW)
              + sumiff(dayPV, EX)
              + sumiff(dayPV, EY)
          ) - sumiff(dayPV, ET)
            - sumiff(dayPV, EU)
            - sumiff(dayPV, EV))
          / (sumiff(dayPV, EX)
            - sumiff(dayPV, EU)
            + sumiff(dayPV, EY)
            - sumiff(dayPV, EV)))
    )
  }

  /// Proposed steam to extraction
  let GU = 1_769_520
  for i in 1..<8760 {
    xy[GU + i] = iff(
      xy[GT + i] == 0,
      0,
      (sumiff(dayPV, EV)
        + (sumiff(dayPV, EY)
          - sumiff(dayPV, EV))
          * (min(
            xy[FH + i],
            sumiff(dayPV, EW)
              + sumiff(dayPV, EX)
              + sumiff(dayPV, EY)
          ) - sumiff(dayPV, ET)
            - sumiff(dayPV, EU)
            - sumiff(dayPV, EV))
          / (sumiff(dayPV, EX)
            - sumiff(dayPV, EU)
            + sumiff(dayPV, EY)
            - sumiff(dayPV, EV)))
    )
  }

  /// Necessary raw methanol for night operation
  let GV = 1_778_280
  for i in 1..<8760 {
    xy[GV + i] = ROUND(
      iff(
        xy[GU + i] == 0,
        0,
        -(CD_RawMeth_min_cons
          + (xy[GU + i] - sumiff(dayPV, EV))
            / (sumiff(dayPV, EY)
              - sumiff(dayPV, EV))
            * (CD_RawMeth_max_cons - CD_RawMeth_min_cons))
          * countIFS(dayPV, EY, >0)
      ),
      3
    )
  }

  /// Necessary CO2 for night operation
  let GW = 1_787_040
  for i in 1..<8760 {
    xy[GW + i] = ROUND(
      iff(
        xy[GU + i] == 0,
        0,
        -(CD_CO2_min_cons
          + (xy[GU + i] - sumiff(dayPV, EV))
            / (sumiff(dayPV, EY)
              - sumiff(dayPV, EV))
            * (CD_CO2_max_cons - CD_CO2_min_cons))
          * countIFS(dayPV, EY, >0)
      ),
      3
    )
  }

  /// Necessary H2 for night operation
  let GX = 1_795_800
  for i in 1..<8760 {
    xy[GX + i] = ROUND(
      iff(
        xy[GU + i] == 0,
        0,
        -(CD_H2_min_cons
          + (xy[GU + i] - sumiff(dayPV, EV))
            / (sumiff(dayPV, EY)
              - sumiff(dayPV, EV))
            * (CD_H2_max_cons - CD_H2_min_cons))
          * countIFS(dayPV, EY, >0)
      ),
      3
    )
  }

  /// Necessary electricity for prep of night incl CO2&H2 for raw methanol
  let GY = 1_804_560
  for i in 1..<8760 {
    xy[GY + i] =
      (xy[GX + i] + xy[GV + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_aux_elec
      + (xy[GW + i] + xy[GV + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod * CCU_var_aux_nom_cons + CCU_fix_aux_cons
      + xy[GV + i] / MethSynt_RawMeth_nom_prod * MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons
  }

  /// Necessary heat for prep of night incl CO2&H2 for raw methanol
  let GZ = 1_813_320
  for i in 1..<8760 {
    xy[GZ + i] =
      (xy[GX + i] + xy[GV + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
      + (xy[GW + i] + xy[GV + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod * CCU_var_heat_nom_cons + xy[GV + i]
      / MethSynt_RawMeth_nom_prod * MethSynt_var_heat_nom_prod
  }

  /// Addt. PV electricity available due to reduced PB load
  let HA = 1_822_080
  for i in 1..<8760 {
    xy[HA + i] = iff(
      xy[GT + i] == 0,
      0,
      max(
        0,
        (xy[FH + i] - SUM(xy[GT + i], xy[GU + i]))
          * (TES_Aux_elec_percentage + 1 / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff)
      )
    )
  }

  /// Addt. CSP heat available due to reduced PB load
  let HB = 1_830_840
  for i in 1..<8760 {
    xy[HB + i] = iff(
      xy[GT + i] == 0,
      0,
      max(0, (xy[FH + i] - SUM(xy[GT + i], xy[GU + i])) * 1 / (1 + Ratio_CSP_vs_Heater))
    )
  }

  /// Corrected steam to ST
  let HC = 1_839_600
  for i in 1..<8760 {
    xy[HC + i] = iff(
      xy[HD + i] == 0,
      0,
      xy[GT + i]
        - (sumiff(dayPV, EX)
          - sumiff(dayPV, EU))
        / (sumiff(dayPV, EY)
          - sumiff(dayPV, EV)) * (xy[GU + i] - xy[HD + i])
    )
  }

  /// Corrected steam to extraction
  let HD = 1_848_360
  for i in 1..<8760 {
    xy[HD + i] = iff(
      min(
        ifFinite(RawMeth_storage_cap / xy[GV + i], 1),
        ifFinite(CO2_storage_cap / xy[GW + i], 1),
        ifFinite(H2_storage_cap / xy[GX + i], 1),
        ifFinite(
          max(
            0,
            (sumiff(dayPV, xy[CX + i], CX_end) + xy[HA + i]
              - (xy[GZ + i] - xy[HB + i]
                - sumiff(dayPV, CY) / El_boiler_eff)
          ) / xy[GY + i],
          1
        )
      ) * xy[GU + i] < sumiff(dayPV, EV),
      0,
      min(
        1,
        ifFinite(RawMeth_storage_cap / xy[GV + i], 1),
        ifFinite(CO2_storage_cap / xy[GW + i], 1),
        ifFinite(H2_storage_cap / xy[GX + i], 1),
        ifFinite(
          max(
            0,
            (sumiff(dayPV, xy[CX + i], CX_end) + xy[HA + i]
              - (xy[GZ + i] - xy[HB + i]
                - sumiff(dayPV, CY) / El_boiler_eff)
          ) / xy[GY + i],
          1
        )
      ) * xy[GU + i]
    )
  }

  /// Necessary raw methanol for night
  let HE = 1_857_120
  for i in 1..<8760 { xy[HE + i] = ifFinite(xy[GV + i] / xy[GU + i] * xy[HD + i], 0) }

  /// Necessary CO2 for night
  let HF = 1_865_880
  for i in 1..<8760 { xy[HF + i] = ifFinite(xy[GW + i] / xy[GD + i] * xy[GM + i], 0) }

  /// Necessary H2 for night
  let HG = 1_874_640
  for i in 1..<8760 { xy[HG + i] = ifFinite(xy[GX + i] / xy[GD + i] * xy[GM + i], 0) }

  /// Necessary electricity for prep of night  incl CO2&H2 for raw methanol
  let HH = 1_883_400
  for i in 1..<8760 { xy[HH + i] = ifFinite(xy[GY + i] / xy[GD + i] * xy[GM + i], 0) }

  /// Necessary heat for prep of night  incl CO2&H2 for raw methanol
  let HI = 1_892_160
  for i in 1..<8760 { xy[HI + i] = ifFinite(xy[GZ + i] / xy[GD + i] * xy[GM + i], 0) }

  /// Proposed steam to ST
  let HK = 1_909_680
  for i in 1..<8760 {
    xy[HK + i] = iff(
      or(xy[FK + i] < _[i - 1], xy[FH + i] == 0),
      0,
      (sumiff(dayPV, EX)
        + sumiff(dayPV, EW)
        + (sumiff(dayPV, FA)
          - sumiff(dayPV, EX))
          * (min(
            xy[FH + i],
            sumiff(dayPV, EZ)
              + sumiff(dayPV, FA)
              + sumiff(dayPV, FV)
          ) - sumiff(dayPV, EW)
            - sumiff(dayPV, EX)
            - sumiff(dayPV, EY))
          / (sumiff(dayPV, FA)
            - sumiff(dayPV, EX)
            + sumiff(dayPV, FV)
            - sumiff(dayPV, EY)))
    )
  }

  /// Proposed steam to extraction
  let HL = 1_918_440
  for i in 1..<8760 {
    xy[HL + i] = iff(
      xy[HK + i] == 0,
      0,
      (sumiff(dayPV, EY)
        + (sumiff(dayPV, FV)
          - sumiff(dayPV, EY))
          * (min(
            xy[FH + i],
            sumiff(dayPV, EZ)
              + sumiff(dayPV, FA)
              + sumiff(dayPV, FV)
          ) - sumiff(dayPV, EW)
            - sumiff(dayPV, EX)
            - sumiff(dayPV, EY))
          / (sumiff(dayPV, FA)
            - sumiff(dayPV, EX)
            + sumiff(dayPV, FV)
            - sumiff(dayPV, EY)))
    )
  }

  /// Necessary raw methanol for night operation
  let HM = 1_927_200
  for i in 1..<8760 {
    xy[HM + i] = ROUND(
      iff(
        xy[HL + i] == 0,
        0,
        -(D_RawMeth_min_cons
          + (xy[HL + i] - sumiff(dayPV, EY))
            / (sumiff(dayPV, FV)
              - sumiff(dayPV, EY))
            * (D_RawMeth_max_cons - D_RawMeth_min_cons))
          * countIFS(dayPV, FV, >0)
      ),
      3
    )
  }

  /// Necessary CO2 for night operation
  let HN = 1_935_960
  for i in 1..<8760 {
    xy[HN + i] = ROUND(
      iff(
        xy[HL + i] == 0,
        0,
        -(D_CO2_min_cons
          + (xy[HL + i] - sumiff(dayPV, EY))
            / (sumiff(dayPV, FV)
              - sumiff(dayPV, EY))
            * (D_CO2_max_cons - D_CO2_min_cons))
          * countIFS(dayPV, FV, >0)
      ),
      3
    )
  }

  /// Necessary H2 for night operation
  let HO = 1_944_720
  for i in 1..<8760 {
    xy[HO + i] = ROUND(
      iff(
        xy[HL + i] == 0,
        0,
        -(D_H2_min_cons
          + (xy[HL + i] - sumiff(dayPV, EY))
            / (sumiff(dayPV, FV)
              - sumiff(dayPV, EY))
            * (D_H2_max_cons - D_H2_min_cons))
          * countIFS(dayPV, FV, >0)
      ),
      3
    )
  }

  /// Necessary electricity for prep of night incl CO2&H2 for raw methanol
  let HP = 1_953_480
  for i in 1..<8760 {
    xy[HP + i] =
      (xy[HO + i] + xy[HM + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_gross_nom_cons + EY_fix_aux_elec
      + (xy[HN + i] + xy[HM + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod * CCU_var_aux_nom_cons + CCU_fix_aux_cons
      + xy[HM + i] / MethSynt_RawMeth_nom_prod * MethSynt_var_aux_nom_cons + MethSynt_fix_aux_cons
  }

  /// Necessary heat for prep of night incl CO2&H2 for raw methanol
  let HQ = 1_962_240
  for i in 1..<8760 {
    xy[HQ + i] =
      (xy[HO + i] + xy[HM + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_H2_nom_cons) / EY_H2_nom_prod * EY_var_heat_nom_cons
      + (xy[HN + i] + xy[HM + i] / (MethSynt_CO2_nom_cons + MethSynt_H2_nom_cons)
        * MethSynt_CO2_nom_cons) / CCU_CO2_nom_prod * CCU_var_heat_nom_cons + xy[HM + i]
      / MethSynt_RawMeth_nom_prod * MethSynt_var_heat_nom_prod
  }

  /// Addt. PV electricity available due to reduced PB load
  let HR = 1_971_000
  for i in 1..<8760 {
    xy[HR + i] = iff(
      xy[HK + i] == 0,
      0,
      max(
        0,
        (xy[FH + i] - SUM(xy[HK + i], xy[HL + i]))
          * (TES_Aux_elec_percentage + 1 / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff)
      )
    )
  }

  /// Addt. CSP heat available due to reduced PB load
  let HS = 1_979_760
  for i in 1..<8760 {
    xy[HS + i] = iff(
      xy[HK + i] == 0,
      0,
      max(0, (xy[FH + i] - SUM(xy[HK + i], xy[HL + i])) * 1 / (1 + Ratio_CSP_vs_Heater))
    )
  }

  /// Corrected steam to ST
  let HT = 1_988_520
  for i in 1..<8760 {
    xy[HT + i] = iff(
      xy[HU + i] == 0,
      0,
      xy[HK + i]
        - (sumiff(dayPV, FA)
          - sumiff(dayPV, EX))
        / (sumiff(dayPV, FV)
          - sumiff(dayPV, EY)) * (xy[HL + i] - xy[HU + i])
    )
  }

  /// Corrected steam to extraction
  let HU = 1_997_280
  for i in 1..<8760 {
    xy[HU + i] = iff(
      min(
        ifFinite(RawMeth_storage_cap / xy[HM + i], 1),
        ifFinite(CO2_storage_cap / xy[HN + i], 1),
        ifFinite(H2_storage_cap / xy[HO + i], 1),
        ifFinite(
          max(
            0,
            (sumiff(dayPV, xy[CX + i], CX_end) + xy[HR + i]
              - (xy[HQ + i] - xy[HS + i]
                - sumiff(dayPV, CY) / El_boiler_eff)
          ) / xy[HP + i],
          1
        )
      ) * xy[HL + i] <= sumiff(dayPV, EY),
      0,
      min(
        1,
        ifFinite(RawMeth_storage_cap / xy[HM + i], 1),
        ifFinite(CO2_storage_cap / xy[HN + i], 1),
        ifFinite(H2_storage_cap / xy[HO + i], 1),
        ifFinite(
          max(
            0,
            (sumiff(dayPV, xy[CX + i], CX_end) + xy[HR + i]
              - (xy[HQ + i] - xy[HS + i]
                - sumiff(dayPV, CY) / El_boiler_eff)
          ) / xy[HP + i],
          1
        )
      ) * xy[HL + i]
    )
  }

  /// Necessary raw methanol for night operation
  let HV = 2_006_040
  for i in 1..<8760 { xy[HV + i] = ifFinite(xy[HM + i] / xy[HL + i] * xy[HU + i], 0) }

  /// Necessary CO2 for night operation
  let HW = 2_014_800
  for i in 1..<8760 { xy[HW + i] = ifFinite(xy[HN + i] / xy[HL + i] * xy[HU + i], 0) }

  /// Necessary H2 for night operation
  let HX = 2_023_560
  for i in 1..<8760 { xy[HX + i] = ifFinite(xy[HO + i] / xy[HL + i] * xy[HU + i], 0) }

  /// Necessary electricity for prep of night  incl CO2&H2 for raw methanol
  let HY = 2_032_320
  for i in 1..<8760 { xy[HY + i] = ifFinite(xy[HP + i] / xy[HL + i] * xy[HU + i], 0) }

  /// Necessary heat for prep of night  incl CO2&H2 for raw methanol
  let HZ = 2_041_080
  for i in 1..<8760 { xy[HZ + i] = ifFinite(xy[HQ + i] / xy[HL + i] * xy[HU + i], 0) }

  /// PV electricity available after corrected TES charging
  let IB = 2_058_600
  for i in 1..<8760 {
    xy[IB + i] = ifFinite(
      max(
        0,
        xy[L + i] - xy[M + i] - xy[BA + i]
          * (1
            - (xy[FH + i] - xy[FL + i] - xy[FM + i]) / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
              / xy[AU + i])
      ),
      0
    )
  }

  /// Heat available after corrected TES charging
  let IC = 2_067_360
  for i in 1..<8760 {
    xy[IC + i] = ifFinite(
      max(
        0,
        xy[J + i] - xy[BB + i]
          * (1 - (xy[FH + i] - xy[FL + i] - xy[FM + i]) / (1 + Ratio_CSP_vs_Heater) / xy[AU + i])
      ),
      0
    )
  }

  /// PV electricity available after night prep
  let IE = 2_084_880
  for i in 1..<8760 {
    xy[IE + i] = iff(
      xy[FL + i] == 0,
      0,
      max(
        0,
        sumiff(dayPV, xy[BD + i], BD_end)
          + (xy[FH + i] - xy[FL + i] - xy[FM + i]) / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
          - xy[FZ + i]
          - max(
            0,
            xy[GA + i]
              - (sumiff(dayPV, CU)
                + (xy[FH + i] - xy[FL + i] - xy[FM + i]) / (1 + Ratio_CSP_vs_Heater))
              / El_boiler_eff
          )
      )
    )
  }

  /// Heat available after night prep
  let IF = 2_093_640
  for i in 1..<8760 {
    xy[IF + i] = iff(
      xy[FL + i] == 0,
      0,
      max(
        0,
        sumiff(dayPV, CU)
          + (xy[FH + i] - xy[FL + i] - xy[FM + i]) / (1 + Ratio_CSP_vs_Heater) - xy[GA + i]
      )
    )
  }

  /// PV electricity available after night prep
  let IH = 2_111_160
  for i in 1..<8760 {
    xy[IH + i] = iff(
      xy[GC + i] == 0,
      0,
      max(
        0,
        sumiff(dayPV, xy[BD + i], BD_end)
          + (xy[FH + i] - xy[GC + i] - xy[GD + i]) / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
          - xy[GQ + i]
          - max(
            0,
            xy[GR + i]
              - (sumiff(dayPV, CU)
                + (xy[FH + i] - xy[GC + i] - xy[GD + i]) / (1 + Ratio_CSP_vs_Heater))
              / El_boiler_eff
          )
      )
    )
  }

  /// Heat available after night prep
  let II = 2_119_920
  for i in 1..<8760 {
    xy[II + i] = iff(
      xy[GC + i] == 0,
      0,
      max(
        0,
        sumiff(dayPV, CU)
          + (xy[FH + i] - xy[GC + i] - xy[GD + i]) / (1 + Ratio_CSP_vs_Heater) - xy[GR + i]
      )
    )
  }

  /// PV electricity available after night prep
  let IJ = 2_128_680
  for i in 1..<8760 {
    xy[IJ + i] = iff(
      xy[GT + i] == 0,
      0,
      max(
        0,
        sumiff(dayPV, xy[BD + i], BD_end)
          + (xy[FH + i] - xy[GT + i] - xy[GU + i]) / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
          - xy[HH + i]
          - max(
            0,
            xy[HI + i]
              - (sumiff(dayPV, CU)
                + (xy[FH + i] - xy[GT + i] - xy[GU + i]) / (1 + Ratio_CSP_vs_Heater))
              / El_boiler_eff
          )
      )
    )
  }

  /// Heat available after night prep
  let IK = 2_137_440
  for i in 1..<8760 {
    xy[IK + i] = iff(
      xy[GT + i] == 0,
      0,
      max(
        0,
        sumiff(dayPV, CU)
          + (xy[FH + i] - xy[GT + i] - xy[GU + i]) / (1 + Ratio_CSP_vs_Heater) - xy[HI + i]
      )
    )
  }

  /// PV electricity available after night prep
  let IL = 2_146_200
  for i in 1..<8760 {
    xy[IL + i] = iff(
      xy[HK + i] == 0,
      0,
      max(
        0,
        sumiff(dayPV, xy[BD + i], BD_end)
          + (xy[FH + i] - xy[HK + i] - xy[HL + i]) / (1 + 1 / Ratio_CSP_vs_Heater) / Heater_eff
          - xy[HY + i]
          - max(
            0,
            xy[HZ + i]
              - (sumiff(dayPV, CU)
                + (xy[FH + i] - xy[HK + i] - xy[HL + i]) / (1 + Ratio_CSP_vs_Heater))
              / El_boiler_eff
          )
      )
    )
  }

  /// Heat available after night preparation
  let IM = 2_154_960
  for i in 1..<8760 {
    xy[IM + i] = iff(
      xy[HK + i] == 0,
      0,
      max(
        0,
        sumiff(dayPV, CU)
          + (xy[FH + i] - xy[HK + i] - xy[HL + i]) / (1 + Ratio_CSP_vs_Heater) - xy[HZ + i]
      )
    )
  }

  /// After TES: Possible harmonious electricity counsumption
  let IN = 2_163_720
  for i in 1..<8760 {
    xy[IN + i] = iff(
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
        xy[BD + i],
        min(
          xy[CU + i] + El_boiler_cap * El_boiler_eff,
          xy[BD + i]
            / (Overall_harmonious_max_var_cons
              + (Overall_harmonious_max_var_heat_cons - xy[CU + i]) / El_boiler_eff)
            * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons * Overall_harmonious_max_var_cons
      ) < Overall_harmonious_min_var_cons,
      0,
      min(
        Overall_harmonious_max_var_cons + Overall_fix_aux_cons,
        xy[BD + i],
        min(
          xy[CU + i] + El_boiler_cap * El_boiler_eff,
          xy[BD + i]
            / (Overall_harmonious_max_var_cons
              + (Overall_harmonious_max_var_heat_cons - xy[CU + i]) / El_boiler_eff)
            * Overall_harmonious_max_var_heat_cons
        ) / Overall_harmonious_max_var_heat_cons * Overall_harmonious_max_var_cons
      )
    )
  }

  /// Remaining PV after TES and harmonious electricity counsumption
  let IO = 2_172_480
  for i in 1..<8760 {
    xy[IO + i] =
      xy[BD + i] - xy[IN + i]
      - max(
        0,
        (xy[IN + i] / Overall_harmonious_max_var_cons * Overall_harmonious_max_var_heat_cons
          - xy[CU + i]) / El_boiler_eff
      )
  }

  /// Remaining CSP heat after TES and harmonious heat counsumption
  let IP = 2_181_240
  for i in 1..<8760 {
    xy[IP + i] = max(
      0,
      xy[CU + i] - xy[IN + i] / Overall_harmonious_max_var_cons
        * Overall_harmonious_max_var_heat_cons
    )
  }

  /// Number of hours < abs min counsumption
  let IQ = 2_190_000
  for i in 1..<8760 {
    xy[IQ + i] = countIFS(
      IN < A_overall_var_min_cons + Overall_fix_aux_cons,
      dayPV
    )
  }

  /// Possible battery charging
  let IR = 2_198_760
  for i in 1..<8760 { xy[IR + i] = min(xy[IO + i], BESS_charging_max_cons) }

  /// Abs min amount of electricity needed during night
  let IS = 2_207_520
  for i in 1..<8760 {
    xy[IS + i] =
      xy[IQ + i] * (Overall_fix_aux_cons + A_overall_var_min_cons)
      + SUMIFS(M, L < 0, dayPV)
  }

  /// Abs min amount of heat needed during night
  let IT = 2_216_280
  for i in 1..<8760 { xy[IT + i] = xy[IQ + i] * A_overall_var_heat_min_cons }
*/
  }
}
*/