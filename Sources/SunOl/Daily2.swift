extension TunOl {
  func day0(hour0: [Double]) -> [Double] {
    let daysU: [[Int]] = hour0[113881..<(113880 + 8760)].indices.chunked(by: { hour0[$0] == hour0[$1] })
      .map { $0.map { $0 - 113880 } }
   // let end = daysU.removeLast()
   // daysU[0].append(contentsOf: end)
    let hourS = 96360

    let S_UcountZero = hour0.countOf(daysU, condition: hourS, predicate: { $0 <= 0 })
    let S_UcountNonZero = hour0.countOf(daysU, condition: hourS, predicate: { $0 > 0 })
  
    var day0 = [Double](repeating: Double.zero, count: 1_095)
    /// Day
    let dayA = 0
    // A5+1
    for i in 1..<365 { day0[dayA + i] = day0[dayA + i - 1] + 1 }

    /// Nr of hours where min harmonious is not possible in spite of grid support
    let dayB = 365
    // COUNTIFS(CalculationU5:U8763,"="A6,CalculationS5:S8763,"<=0")
    for i in 0..<365 { day0[dayB + i] = S_UcountZero[i] }

    /// Nr of hours where min harmonious is possible considering grid support
    let dayC = 730
    // COUNTIFS(CalculationU5:U8763,"="A6,CalculationS5:S8763,">0")
    for i in 0..<365 { day0[dayC + i] = S_UcountNonZero[i] }
    return day0
  }

  func day21(_ day1: inout [Double], case j: Int, day0: [Double]) {
    let dayB = 365
    let dayC = 730
    /// Min el cons during night
    let dayE = 0
    // (A_overall_var_min_cons+A_overall_fix_stby_cons)*B6+A_overall_stup_cons
    for i in 0..<365 {
      day1[dayE + i] = (overall_var_min_cons[j] + overall_fix_stby_cons[j]) * day0[dayB + i] + overall_stup_cons[j]
    }

    /// Max el cons during night
    let dayF = 365
    // (A_overall_var_max_cons+A_overall_fix_stby_cons)*B6+A_overall_stup_cons
    for i in 0..<365 {
      day1[dayF + i] = (overall_var_max_cons[j] + overall_fix_stby_cons[j]) * day0[dayB + i] + overall_stup_cons[j]
    }

    /// Min heat cons during night
    let dayG = 730
    // (A_overall_var_heat_min_cons+A_overall_heat_fix_stby_cons)*B6+A_overall_heat_stup_cons
    for i in 0..<365 {
      day1[dayG + i] =
        (overall_var_heat_min_cons[j] + overall_heat_fix_stby_cons[j]) * day0[dayB + i] + overall_heat_stup_cons[j]
    }

    /// Max heat cons during night
    let dayH = 1095
    // (A_overall_var_heat_max_cons+A_overall_heat_fix_stby_cons)*B6+A_overall_heat_stup_cons
    for i in 0..<365 {
      day1[dayH + i] =
        (overall_var_heat_max_cons[j] + overall_heat_fix_stby_cons[j]) * day0[dayB + i] + overall_heat_stup_cons[j]
    }

    /// Min RawMeth cons during night
    let dayI = 1460
    /// Max RawMeth cons during night
    let dayJ = 1825
    /// Min CO2 cons during night
    let dayK = 2190
    /// Max CO2 cons during night
    let dayL = 2555
    /// Min H2 cons during night
    let dayM = 2920
    /// Max H2 cons during night
    let dayN = 3285
    
    for i in 0..<365 { 
      // A_RawMeth_min_cons*B6
      day1[dayI + i] = RawMeth_min_cons[j] * day0[dayB + i] 
      // A_RawMeth_max_cons*B6
      day1[dayJ + i] = RawMeth_max_cons[j] * day0[dayB + i] 
      // A_CO2_min_cons*B6
      day1[dayK + i] = C_O_2_min_cons[j] * day0[dayB + i] 
      // A_CO2_max_cons*B6
      day1[dayL + i] = C_O_2_max_cons[j] * day0[dayB + i] 
      // A_Hydrogen_min_cons*B6
      day1[dayM + i] = Hydrogen_min_cons[j] * day0[dayB + i] 
      // A_Hydrogen_max_cons*B6
      day1[dayN + i] = Hydrogen_max_cons[j] * day0[dayB + i]
    }

    /// Min el cons during day for night op prep
    let dayO = 3650
    // IF(AND(M3=0;I3=0);0;(M3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+$C3*EY_fix_cons)+IF(AND(K3=0;I3=0);0;(K3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+$C3*CCU_fix_cons)+IF(I3=0;0;I3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+$C3*MethSynt_fix_cons)
    for i in 0..<365 {
      day1[dayO + i] = iff(
        and(day1[dayM + i].isZero, day1[dayI + i].isZero), Double.zero, 
        (day1[dayM + i] + day1[dayI + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + day0[dayC + i] * EY_fix_cons)
        + iff(and(day1[dayK + i].isZero, day1[dayI + i].isZero), Double.zero,  
          (day1[dayK + i] + day1[dayI + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + day0[dayC + i] * CCU_fix_cons)
        + iff(day1[dayI + i].isZero, Double.zero,
          day1[dayI + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + day0[dayC + i] * MethSynt_fix_cons)
    }

    /// Max el cons during day for night op prep
    let dayP = 4015
    // IF(AND(N3=0;J3=0);0;(N3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+$C3*EY_fix_cons)+IF(AND(L3=0;J3=0);0;(L3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+$C3*CCU_fix_cons)+IF(J3=0;0;J3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+$C3*MethSynt_fix_cons)
    for i in 0..<365 {
      day1[dayP + i] = iff(
        and(day1[dayN + i].isZero, day1[dayJ + i].isZero), Double.zero, 
        (day1[dayN + i] + day1[dayJ + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + day0[dayC + i] * EY_fix_cons)
        + iff(and(day1[dayL + i].isZero, day1[dayJ + i].isZero), Double.zero,
          (day1[dayL + i] + day1[dayJ + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + day0[dayC + i] * CCU_fix_cons)
        + iff(day1[dayJ + i].isZero, Double.zero,
          day1[dayJ + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons + day0[dayC + i] * MethSynt_fix_cons)
    }

    /// Min heat cons during day for night op prep
    let dayQ = 4380
    // IF(AND(M3=0;I3=0);0;(M3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+$C3*EY_heat_fix_cons)+IF(AND(K3=0;I3=0);0;(K3+I3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+$C3*CCU_heat_fix_cons)-IF(I3=0;0;I3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod+$C3*MethSynt_heat_fix_prod)
    for i in 0..<365 {
      day1[dayQ + i] = iff(
        and(day1[dayM + i].isZero, day1[dayI + i].isZero), Double.zero,
        (day1[dayM + i] + day1[dayI + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + day0[dayC + i] * EY_heat_fix_cons)
        + iff(and(day1[dayK + i].isZero, day1[dayI + i].isZero), Double.zero,
          (day1[dayK + i] + day1[dayI + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + day0[dayC + i] * CCU_fix_heat_cons)
        - iff(day1[dayI + i].isZero, Double.zero,
          day1[dayI + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod + day0[dayC + i] * MethSynt_heat_fix_prod)
    }

    /// Max heat cons during day for prep of night
    let dayR = 4745
    // IF(AND(N3=0;J3=0);0;(N3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+$C3*EY_heat_fix_cons)+IF(AND(L3=0;J3=0);0;(L3+J3/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+$C3*CCU_heat_fix_cons)-IF(J3=0;0;J3/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod+$C3*MethSynt_heat_fix_prod)
    for i in 0..<365 {
      day1[dayR + i] = iff(
        and(day1[dayN + i].isZero, day1[dayJ + i].isZero), Double.zero,
        (day1[dayN + i] + day1[dayJ + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_Hydrogen_nom_cons) / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + day0[dayC + i] * EY_heat_fix_cons)
        + iff(and(day1[dayL + i].isZero, day1[dayJ + i].isZero), Double.zero,
          (day1[dayL + i] + day1[dayJ + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
          * MethSynt_C_O_2_nom_cons) / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + day0[dayC + i] * CCU_fix_heat_cons)
        - iff(day1[dayJ + i].isZero, Double.zero,
          day1[dayJ + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod + day0[dayC + i] * MethSynt_heat_fix_prod)
    }

    /// Min Rawmeth prod during day for night op prep
    let dayS = 5110
    // I6
    for i in 0..<365 { day1[dayS + i] = day1[dayI + i] }

    /// Max Rawmeth prod during day for night op prep
    let dayT = 5475
    // J6
    for i in 0..<365 { day1[dayT + i] = day1[dayJ + i] }

    /// Min CO2 prod during day for night op prep
    let dayU = 5840
    // K6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      day1[dayU + i] =
        day1[dayK + i] + day1[dayI + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let dayV = 6205
    // L6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      day1[dayV + i] =
        day1[dayL + i] + day1[dayJ + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let dayW = 6570
    // M6+I6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      day1[dayW + i] =
        day1[dayM + i] + day1[dayI + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let dayX = 6935
    // N6+J6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      day1[dayX + i] =
        day1[dayN + i] + day1[dayJ + i] / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons)
        * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after night min op  prep
    let dayY = 7300
    /// Surplus RawMeth storage cap after max night op prep
    let dayZ = 7665
    /// Surplus CO2 storage cap after min night op prep
    let dayAA = 8030
    /// Surplus CO2 storage cap after max night op prep
    let dayAB = 8395
    /// Surplus H2 storage cap after min night op prep
    let dayAC = 8760
    /// Surplus H2 storage cap after max night op prep
    let dayAD = 9125
    
    for i in 0..<365 { 
      // 1-IF(I3=0;0;IFERROR(I3/RawMeth_storage_cap_ud;1))
      day1[dayY + i] = 1 - iff(
        day1[dayI + i].isZero, Double.zero, ifFinite(day1[dayI + i] / RawMeth_storage_cap_ud, 1)) 
      // 1-IF(J3=0;0;IFERROR(J3/RawMeth_storage_cap_ud;1))
      day1[dayZ + i] = 1 - iff(
        day1[dayJ + i].isZero, Double.zero, ifFinite(day1[dayJ + i] / RawMeth_storage_cap_ud, 1)) 
      // 1-IF(K3=0;0;IFERROR(K3/CO2_storage_cap_ud;1))
      day1[dayAA + i] = 1 - iff(
        day1[dayK + i].isZero, Double.zero, ifFinite(day1[dayK + i] / C_O_2_storage_cap_ud, 1)) 
      // 1-IF(L3=0;0;IFERROR(L3/CO2_storage_cap_ud;1))
      day1[dayAB + i] = 1 - iff(
        day1[dayL + i].isZero, Double.zero, ifFinite(day1[dayL + i] / C_O_2_storage_cap_ud, 1)) 
      // 1-IF(M3=0;0;IFERROR(M6/Hydrogen_storage_cap_ud;1))
      day1[dayAC + i] = 1 - iff(
        day1[dayM + i].isZero, Double.zero, ifFinite(day1[dayM + i] / Hydrogen_storage_cap_ud, 1)) 
      // 1-IF(N3=0;0;IFERROR(N6/Hydrogen_storage_cap_ud;1))
      day1[dayAD + i] = 1 - iff(
        day1[dayN + i].isZero, Double.zero, ifFinite(day1[dayN + i] / Hydrogen_storage_cap_ud, 1)) 
    }

    /// Max Equiv harmonious night prod due to physical limits
    let dayAE = 9490
    // IF(OR(Y6<=0,AA6<=0,AC6<=0),0,MIN(1,IFERROR(Y6/(Y6-Z6),1),IFERROR(AA6/(AA6-AB6),1),IFERROR(AC6/(AC6-AD6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      day1[dayAE + i] = iff(
        or(day1[dayY + i] <= Double.zero, day1[dayAA + i] <= Double.zero, day1[dayAC + i] <= 0), Double.zero,
        min(
          1, ifFinite(day1[dayY + i] / (day1[dayY + i] - day1[dayZ + i]), 1),
          ifFinite(day1[dayAA + i] / (day1[dayAA + i] - day1[dayAB + i]), 1),
          ifFinite(day1[dayAC + i] / (day1[dayAC + i] - day1[dayAD + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }
  }  
}  

