extension TunOl {
  func daily2() {
    let daysA = [[Int]]()
    let daysCS = [[Int]]()
    let daysEZ = [[Int]]()
    let hourly0 = [Double]()
    let hourly1 = [Double]() 
    let hourly2 = [Double]() 
    let hourly3 = [Double]() 
    let hourly4 = [Double]() 
    var daily10 = [Double]()
    let hourlyJ = 26280
    let hourlyL = 43800
    let hourlyDJ = 175200
    let hourlyCI = 122640
    let hourlyCJ = 131400
    let hourlyCQ = 8760
    let hourlyCS = 26280
    let hourlyCT = 35040
    let hourlyCU = 43800
    let hourlyCM = 157680
    let hourlyCN = 166440
    let hourlyCR = 17520
    let hourlyCV = 52560
    let hourlyCW = 61320
    let hourlyCX = 70080
    let hourlyCY = 78840
    let hourlyCZ = 87600
    let hourlyDA = 96360
    let hourlyDB = 105120
    let hourlyDC = 113880
    let hourlyDD = 122640
    let hourlyDE = 131400
    let hourlyDF = 140160
    let hourlyDH = 157680
    let hourlyDI = 166440
    let hourlyDK = 183960
    let hourlyDL = 192720
    let hourlyDM = 201480
    let hourlyDN = 210240
    let hourlyDO = 219000
    let hourlyDP = 227760
    let hourlyDQ = 236520
    let hourlyDR = 245280
    let hourlyDS = 254040
    let hourlyDT = 262800
    let hourlyEH = 105120
    let hourlyEI = 113880
    let hourlyEP = 175200
    let hourlyEQ = 183960
    let hourlyET = 210240
    let hourlyEU = 219000
    let hourlyEX = 236520
    let hourlyEY = 245280
    let hourlyEZ = 254040
    let hourlyFA = 262800
    let hourlyFB = 271560
    let hourlyFC = 280320
    let hourlyFD = 289080
    let hourlyFE = 297840
    let hourlyFF = 306600
    let hourlyFG = 315360
    let hourlyFH = 324120
    let hourlyFI = 332880
    let hourlyFJ = 341640
    let hourlyFK = 350400
    let hourlyFL = 359160
    let hourlyFM = 367920
    let hourlyFO = 385440
    let hourlyFU = 438000
    let hourlyFP = 394200
    let hourlyFQ = 402960
    let hourlyFR = 411720
    let hourlyFS = 420480
    let hourlyFT = 429240
    let hourlyFV = 446760
    let hourlyFW = 455520
    let hourlyFX = 464280
    let hourlyFY = 473040
    let hourlyFZ = 481800
    let hourlyGA = 490560
    /// Day
    let daily1A = 0
    // A5+1
    for i in 0..<365 { daily10[daily1A + i] = daily10[daily1A + i - 1] + 1 }

    // let CQ_CScountZero = hourly3.countOf(hourlyCS, days: daysA, condition: hourlyCQ, predicate: {$0<=0})
    // let CQ_CScountNonZero = hourly3.countOf(hourlyCS, days: daysA, condition: hourlyCQ, predicate: {$0>0})

    var daily11 = [Double]()
    /// Nr of hours outside of harm op period after min night prep
    let daily1C = 0
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"<=0")
    // for i in 0..<365 { daily11[daily1C + i] = CQ_CScountZero[i] }

    /// Nr of harm op period hours after min night prep
    let daily1D = 365
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // for i in 0..<365 { daily11[daily1D + i] = CQ_CScountNonZero[i] }

    /// Nr of PB op hours after min night prep
    let daily1E = 730
    // COUNTIFS(CalculationCS5:CS8763,"="A6,CalculationBX5:BX8763,">0",CalculationCC5:CC8763,">0")
    for i in 0..<365 {
      // daily11[daily1E + i] =  countIFS(Calculationdaily1_[(CS+i)...].prefix(),"="daily10[daily1A + i],Calculationdaily1_[(BX+i)...].prefix(),{!$0.isZero},Calculationdaily1_[(CC+i)...].prefix(),{!$0.isZero})
    }
  let j = 0
    /// Min RawMeth cons during night
    let daily1F = 1095
    // A_RawMeth_min_cons*C6
    for i in 0..<365 { daily11[daily1F + i] = RawMeth_min_cons[j] * daily11[daily1C + i] }

    /// Max RawMeth cons during night
    let daily1G = 1460
    // A_RawMeth_max_cons*C6
    for i in 0..<365 { daily11[daily1G + i] = RawMeth_max_cons[j] * daily11[daily1C + i] }

    /// Min CO2 cons during night
    let daily1H = 1825
    // A_CO2_min_cons*C6
    for i in 0..<365 { daily11[daily1H + i] = C_O_2_min_cons[j] * daily11[daily1C + i] }

    /// Max CO2 cons during night
    let daily1I = 2190
    // A_CO2_max_cons*C6
    for i in 0..<365 { daily11[daily1I + i] = C_O_2_max_cons[j] * daily11[daily1C + i] }

    /// Min H2 cons during night
    let daily1J = 2555
    // A_Hydrogen_min_cons*C6
    for i in 0..<365 { daily11[daily1J + i] = Hydrogen_min_cons[j] * daily11[daily1C + i] }

    /// Max H2 cons during night
    let daily1K = 2920
    // A_Hydrogen_max_cons*C6
    for i in 0..<365 { daily11[daily1K + i] = Hydrogen_max_cons[j] * daily11[daily1C + i] }

    /// Surplus RawMeth storage cap after night min op  prep
    let daily1L = 3285
    // 1-F6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily11[daily1L + i] = 1 - daily11[daily1F + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let daily1M = 3650
    // 1-G6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily11[daily1M + i] = 1 - daily11[daily1G + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let daily1N = 4015
    // 1-H6/CO2_storage_cap_ud
    for i in 0..<365 { daily11[daily1N + i] = 1 - daily11[daily1H + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily1O = 4380
    // 1-I6/CO2_storage_cap_ud
    for i in 0..<365 { daily11[daily1O + i] = 1 - daily11[daily1I + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let daily1P = 4745
    // 1-J6/Hydrogen_storage_cap_ud
    for i in 0..<365 { daily11[daily1P + i] = 1 - daily11[daily1J + i] / Hydrogen_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let daily1Q = 5110
    // 1-K6/Hydrogen_storage_cap_ud
    for i in 0..<365 { daily11[daily1Q + i] = 1 - daily11[daily1K + i] / Hydrogen_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let daily1R = 5475
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-M6),1),IFERROR(N6/(N6-O6),1),IFERROR(P6/(P6-Q6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily11[daily1R + i] = iff(
        or(daily11[daily1L + i] <= 0, daily11[daily1N + i] <= 0, daily11[daily1P + i] <= 0), 0,
        min(
          1, ifFinite(daily11[daily1L + i] / (daily11[daily1L + i] - daily11[daily1M + i]), 1),
          ifFinite(daily11[daily1N + i] / (daily11[daily1N + i] - daily11[daily1O + i]), 1),
          ifFinite(daily11[daily1P + i] / (daily11[daily1P + i] - daily11[daily1Q + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }
    // let EX_EZcountZero = hourly4.countOf(hourlyEZ, days: daysA, condition: hourlyEX, predicate: {$0<=0})
    /// Nr of hours outside of harm op period after max night prep
    let daily1T = 5840
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"<=0")
    // for i in 0..<365 { daily11[daily1T + i] = EX_EZcountZero[i] }

    // let EX_EZcountNonZero = hourly4.countOf(hourlyEZ, days: daysA, condition: hourlyEX, predicate: {$0>0})
    /// Nr of harm op period hours after max night prep
    let daily1U = 6205
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    // for i in 0..<365 { daily11[daily1U + i] = EX_EZcountNonZero[i] }

    // let EH_EZcountNonZero = hourly4.countOf(hourlyEZ, days: daysA, condition: hourlyEH, predicate: {$0>0})
    /// Nr of PB op hours after max night prep
    let daily1V = 6570
    // COUNTIFS(CalculationEZ5:EZ8763,"="A6,CalculationEH5:EH8763,">0")
    // for i in 0..<365 { daily11[daily1V + i] = EH_EZcountNonZero[i] }

    /// Max RawMeth cons during night
    let daily1W = 6935
    // A_RawMeth_max_cons*T6
    for i in 0..<365 { daily11[daily1W + i] = RawMeth_max_cons[j] * daily11[daily1T + i] }

    /// Max CO2 cons during night
    let daily1X = 7300
    // A_CO2_max_cons*T6
    for i in 0..<365 { daily11[daily1X + i] = C_O_2_max_cons[j] * daily11[daily1T + i] }

    /// Max H2 cons during night
    let daily1Y = 7665
    // A_Hydrogen_max_cons*T6
    for i in 0..<365 { daily11[daily1Y + i] = Hydrogen_max_cons[j] * daily11[daily1T + i] }

    /// Min el cons during day for night op prep
    let daily1Z = 8030
    // (J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+D6*EY_fix_cons+(H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+D6*CCU_fix_cons+F6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+D6*MethSynt_fix_cons
    for i in 0..<365 {
      daily11[daily1Z + i] =
        (daily11[daily1J + i] + daily11[daily1F + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily11[daily1D + i] * EY_fix_cons
        + (daily11[daily1H + i] + daily11[daily1F + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily11[daily1D + i] * CCU_fix_cons
        + daily11[daily1F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily11[daily1D + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let daily1AA = 8395
    // (Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+U6*EY_fix_cons+(X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+U6*CCU_fix_cons+W6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+U6*MethSynt_fix_cons
    for i in 0..<365 {
      daily11[daily1AA + i] =
        (daily11[daily1Y + i] + daily11[daily1W + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily11[daily1U + i] * EY_fix_cons
        + (daily11[daily1X + i] + daily11[daily1W + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily11[daily1U + i] * CCU_fix_cons
        + daily11[daily1W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily11[daily1U + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let daily1AB = 8760
    // (J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+D6*EY_heat_fix_cons+(H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+D6*CCU_fix_heat_cons-F6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-D6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily11[daily1AB + i] =
        (daily11[daily1J + i] + daily11[daily1F + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily11[daily1D + i] * EY_heat_fix_cons
        + (daily11[daily1H + i] + daily11[daily1F + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily11[daily1D + i] * CCU_fix_heat_cons
        - daily11[daily1F + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily11[daily1D + i] * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let daily1AC = 9125
    // (Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+U6*EY_heat_fix_cons+(X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+U6*CCU_fix_heat_cons-W6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-U6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily11[daily1AC + i] =
        (daily11[daily1Y + i] + daily11[daily1W + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily11[daily1U + i] * EY_heat_fix_cons
        + (daily11[daily1X + i] + daily11[daily1W + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily11[daily1U + i] * CCU_fix_heat_cons
        - daily11[daily1W + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily11[daily1U + i] * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let daily1AD = 9490
    // F6
    for i in 0..<365 { daily11[daily1AD + i] = daily11[daily1F + i] }

    /// Max Rawmeth prod during day for night op prep
    let daily1AE = 9855
    // W6
    for i in 0..<365 { daily11[daily1AE + i] = daily11[daily1W + i] }

    /// Min CO2 prod during day for night op prep
    let daily1AF = 10220
    // H6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily11[daily1AF + i] =
        daily11[daily1H + i] + daily11[daily1F + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let daily1AG = 10585
    // X6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily11[daily1AG + i] =
        daily11[daily1X + i] + daily11[daily1W + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let daily1AH = 10950
    // J6+F6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily11[daily1AH + i] =
        daily11[daily1J + i] + daily11[daily1F + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let daily1AI = 11315
    // Y6+W6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily11[daily1AI + i] =
        daily11[daily1Y + i] + daily11[daily1W + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after max night op prep
    let daily1AJ = 11680
    // 1-W6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily11[daily1AJ + i] = 1 - daily11[daily1W + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily1AK = 12045
    // 1-X6/CO2_storage_cap_ud
    for i in 0..<365 { daily11[daily1AK + i] = 1 - daily11[daily1X + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let daily1AL = 12410
    // 1-Y6/Hydrogen_storage_cap_ud
    for i in 0..<365 { daily11[daily1AL + i] = 1 - daily11[daily1Y + i] / Hydrogen_storage_cap_ud }

    /// Max Equiv harmonious night prod due to physical limits
    let daily1AM = 12775
    // IF(OR(L6<=0,N6<=0,P6<=0),0,MIN(1,IFERROR(L6/(L6-AJ6),1),IFERROR(N6/(N6-AK6),1),IFERROR(P6/(P6-AL6),1))*(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily11[daily1AM + i] = iff(
        or(daily11[daily1L + i] <= 0, daily11[daily1N + i] <= 0, daily11[daily1P + i] <= 0), 0,
        min(
          1, ifFinite(daily11[daily1L + i] / (daily11[daily1L + i] - daily11[daily1AJ + i]), 1),
          ifFinite(daily11[daily1N + i] / (daily11[daily1N + i] - daily10[daily1AK + i]), 1),
          ifFinite(daily11[daily1P + i] / (daily11[daily1P + i] - daily11[daily1AL + i]), 1))
          * (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }
/*
    var daily12 = [Double]()

    /// Nr of hours outside of harm op period after min night prep
    let daily1AO = 0
    // COUNTIFS(CalculationHA5:HA8763,"="A6,CalculationGY5:GY8763,"<=0")
    for i in 0..<365 { daily12[daily1AO + i] = GY_HAcountZero[i] }

    /// Nr of harm op period hours after min night prep
    let daily1AP = 365
    // COUNTIFS(CalculationHA5:HA8763,"="A6,CalculationGY5:GY8763,">0")
    for i in 0..<365 { daily12[daily1AP + i] = GY_HAcountNonZero[i] }

    /// Nr of PB op hours after min night prep
    let daily1AQ = 730
    // COUNTIFS(CalculationHA5:HA8763,"="A6,CalculationGF5:GF8763,">0",CalculationGK5:GK8763,">0")
    for i in 0..<365 {
      // daily12[daily1AQ + i] =  countIFS(Calculationdaily1_[(HA+i)...].prefix(),"="daily10[daily1A + i],Calculationdaily1_[(GF+i)...].prefix(),{!$0.isZero},Calculationdaily1_[(GK+i)...].prefix(),{!$0.isZero})
    }

    /// Min RawMeth cons during night
    let daily1AR = 1095
    // B_RawMeth_min_cons*AO6
    for i in 0..<365 { daily12[daily1AR + i] = B_RawMeth_min_cons * daily12[daily1AO + i] }

    /// Max RawMeth cons during night
    let daily1AS = 1460
    // B_RawMeth_max_cons*AO6
    for i in 0..<365 { daily12[daily1AS + i] = B_RawMeth_max_cons * daily12[daily1AO + i] }

    /// Min CO2 cons during night
    let daily1AT = 1825
    // B_CO2_min_cons*AO6
    for i in 0..<365 { daily12[daily1AT + i] = B_C_O_2_min_cons * daily12[daily1AO + i] }

    /// Max CO2 cons during night
    let daily1AU = 2190
    // B_CO2_max_cons*AO6
    for i in 0..<365 { daily12[daily1AU + i] = B_C_O_2_max_cons * daily12[daily1AO + i] }

    /// Min H2 cons during night
    let daily1AV = 2555
    // B_Hydrogen_min_cons*AO6
    for i in 0..<365 { daily12[daily1AV + i] = B_Hydrogen_min_cons * daily12[daily1AO + i] }

    /// Max H2 cons during night
    let daily1AW = 2920
    // B_Hydrogen_max_cons*AO6
    for i in 0..<365 { daily12[daily1AW + i] = B_Hydrogen_max_cons * daily12[daily1AO + i] }

    /// Surplus RawMeth storage cap after night min op  prep
    let daily1AX = 3285
    // 1-AR6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily12[daily1AX + i] = 1 - daily10[daily1AR + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let daily1AY = 3650
    // 1-AS6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily12[daily1AY + i] = 1 - daily12[daily1AS + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let daily1AZ = 4015
    // 1-AT6/CO2_storage_cap_ud
    for i in 0..<365 { daily12[daily1AZ + i] = 1 - daily12[daily1AT + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily1BA = 4380
    // 1-AU6/CO2_storage_cap_ud
    for i in 0..<365 { daily12[daily1BA + i] = 1 - daily12[daily1AU + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let daily1BB = 4745
    // 1-AV6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily12[daily1BB + i] = 1 - daily10[daily1AV + i] / Hydrogen_storage_cap_ud
    }

    /// Surplus H2 storage cap after max night op prep
    let daily1BC = 5110
    // 1-AW6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily12[daily1BC + i] = 1 - daily10[daily1AW + i] / Hydrogen_storage_cap_ud
    }

    /// Max Equiv harmonious night prod due to physical limits
    let daily1BD = 5475
    // IF(OR(AX6<=0,AZ6<=0,BB6<=0),0,MIN(1,IFERROR(AX6/(AX6-AY6),1),IFERROR(AZ6/(AZ6-BA6),1),IFERROR(BB6/(BB6-BC6),1))*(B_equiv_harmonious_max_perc-B_equiv_harmonious_min_perc)+B_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily12[daily1BD + i] = iff(
        or(daily10[daily1AX + i] <= 0, daily10[daily1AZ + i] <= 0, daily12[daily1BB + i] <= 0), 0,
        min(
          1, ifFinite(daily10[daily1AX + i] / (daily10[daily1AX + i] - daily12[daily1AY + i]), 1),
          ifFinite(daily10[daily1AZ + i] / (daily10[daily1AZ + i] - daily12[daily1BA + i]), 1),
          ifFinite(daily12[daily1BB + i] / (daily12[daily1BB + i] - daily12[daily1BC + i]), 1))
          * (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc)
          + B_equiv_harmonious_min_perc)
    }

    /// Nr of hours outside of harm op period after max night prep
    let daily1BF = 5840
    // COUNTIFS(CalculationJH5:JH8763,"="A6,CalculationJF5:JF8763,"<=0")
    for i in 0..<365 { daily12[daily1BF + i] = JF_JHcountZero[i] }

    /// Nr of harm op period hours after max night prep
    let daily1BG = 6205
    // COUNTIFS(CalculationJH5:JH8763,"="A6,CalculationJF5:JF8763,">0")
    for i in 0..<365 { daily12[daily1BG + i] = JF_JHcountNonZero[i] }

    /// Nr of PB op hours after max night prep
    let daily1BH = 6570
    // COUNTIFS(CalculationJH5:JH8763,"="A6,CalculationIP5:IP8763,">0")
    for i in 0..<365 { daily12[daily1BH + i] = IP_JHcountNonZero[i] }

    /// Max RawMeth cons during night
    let daily1BI = 6935
    // B_RawMeth_max_cons*BF6
    for i in 0..<365 { daily12[daily1BI + i] = B_RawMeth_max_cons * daily12[daily1BF + i] }

    /// Max CO2 cons during night
    let daily1BJ = 7300
    // B_CO2_max_cons*BF6
    for i in 0..<365 { daily12[daily1BJ + i] = B_C_O_2_max_cons * daily12[daily1BF + i] }

    /// Max H2 cons during night
    let daily1BK = 7665
    // B_Hydrogen_max_cons*BF6
    for i in 0..<365 { daily12[daily1BK + i] = B_Hydrogen_max_cons * daily12[daily1BF + i] }

    /// Min el cons during day for night op prep
    let daily1BL = 8030
    // (AV6+AR6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+AP6*EY_fix_cons+(AT6+AR6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+AP6*CCU_fix_cons+AR6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+AP6*MethSynt_fix_cons
    for i in 0..<365 {
      daily12[daily1BL + i] =
        (daily10[daily1AV + i] + daily10[daily1AR + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily10[daily1AP + i] * EY_fix_cons
        + (daily12[daily1AT + i] + daily10[daily1AR + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily10[daily1AP + i] * CCU_fix_cons
        + daily10[daily1AR + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily10[daily1AP + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let daily1BM = 8395
    // (BK6+BI6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+BG6*EY_fix_cons+(BJ6+BI6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+BG6*CCU_fix_cons+BI6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+BG6*MethSynt_fix_cons
    for i in 0..<365 {
      daily12[daily1BM + i] =
        (daily12[daily1BK + i] + daily12[daily1BI + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily12[daily1BG + i] * EY_fix_cons
        + (daily12[daily1BJ + i] + daily12[daily1BI + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily12[daily1BG + i] * CCU_fix_cons
        + daily12[daily1BI + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily12[daily1BG + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let daily1BN = 8760
    // (AV6+AR6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+AP6*EY_heat_fix_cons+(AT6+AR6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+AP6*CCU_fix_heat_cons-AR6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-AP6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily12[daily1BN + i] =
        (daily10[daily1AV + i] + daily10[daily1AR + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily10[daily1AP + i] * EY_heat_fix_cons
        + (daily12[daily1AT + i] + daily10[daily1AR + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily10[daily1AP + i] * CCU_fix_heat_cons
        - daily10[daily1AR + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily10[daily1AP + i] * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let daily1BO = 9125
    // (BK6+BI6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+BG6*EY_heat_fix_cons+(BJ6+BI6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+BG6*CCU_fix_heat_cons-BI6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-BG6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily12[daily1BO + i] =
        (daily12[daily1BK + i] + daily12[daily1BI + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily12[daily1BG + i] * EY_heat_fix_cons
        + (daily12[daily1BJ + i] + daily12[daily1BI + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily12[daily1BG + i] * CCU_fix_heat_cons
        - daily12[daily1BI + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily12[daily1BG + i] * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let daily1BP = 9490
    // AR6
    for i in 0..<365 { daily12[daily1BP + i] = daily10[daily1AR + i] }

    /// Max Rawmeth prod during day for night op prep
    let daily1BQ = 9855
    // BI6
    for i in 0..<365 { daily12[daily1BQ + i] = daily12[daily1BI + i] }

    /// Min CO2 prod during day for night op prep
    let daily1BR = 10220
    // AT6+AR6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily12[daily1BR + i] =
        daily12[daily1AT + i] + daily10[daily1AR + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let daily1BS = 10585
    // BJ6+BI6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily12[daily1BS + i] =
        daily12[daily1BJ + i] + daily12[daily1BI + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let daily1BT = 10950
    // AV6+AR6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily12[daily1BT + i] =
        daily10[daily1AV + i] + daily10[daily1AR + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let daily1BU = 11315
    // BK6+BI6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily12[daily1BU + i] =
        daily12[daily1BK + i] + daily12[daily1BI + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after max night op prep
    let daily1BV = 11680
    // 1-BI6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily12[daily1BV + i] = 1 - daily12[daily1BI + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily1BW = 12045
    // 1-BJ6/CO2_storage_cap_ud
    for i in 0..<365 { daily12[daily1BW + i] = 1 - daily12[daily1BJ + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let daily1BX = 12410
    // 1-BK6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily12[daily1BX + i] = 1 - daily12[daily1BK + i] / Hydrogen_storage_cap_ud
    }

    /// Max Equiv harmonious night prod due to physical limits
    let daily1BY = 12775
    // IF(OR(AX6<=0,AZ6<=0,BB6<=0),0,MIN(1,IFERROR(AX6/(AX6-BV6),1),IFERROR(AZ6/(AZ6-BW6),1),IFERROR(BB6/(BB6-BX6),1))*(B_equiv_harmonious_max_perc-B_equiv_harmonious_min_perc)+B_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily12[daily1BY + i] = iff(
        or(daily10[daily1AX + i] <= 0, daily10[daily1AZ + i] <= 0, daily12[daily1BB + i] <= 0), 0,
        min(
          1, ifFinite(daily10[daily1AX + i] / (daily10[daily1AX + i] - daily12[daily1BV + i]), 1),
          ifFinite(daily10[daily1AZ + i] / (daily10[daily1AZ + i] - daily12[daily1BW + i]), 1),
          ifFinite(daily12[daily1BB + i] / (daily12[daily1BB + i] - daily12[daily1BX + i]), 1))
          * (B_equiv_harmonious_max_perc - B_equiv_harmonious_min_perc)
          + B_equiv_harmonious_min_perc)
    }

    var daily13 = [Double]()

    /// Nr of hours outside of harm op period after min night prep
    let daily1CA = 0
    // COUNTIFS(CalculationLI5:LI8763,"="A6,CalculationLG5:LG8763,"<=0")
    for i in 0..<365 { daily13[daily1CA + i] = LG_LIcountZero[i] }

    /// Nr of harm op period hours after min night prep
    let daily1CB = 365
    // COUNTIFS(CalculationLI5:LI8763,"="A6,CalculationLG5:LG8763,">0")
    for i in 0..<365 { daily13[daily1CB + i] = LG_LIcountNonZero[i] }

    /// Nr of PB op hours after min night prep
    let daily1CC = 730
    // COUNTIFS(CalculationLI5:LI8763,"="A6,CalculationKN5:KN8763,">0",CalculationKS5:KS8763,">0")
    for i in 0..<365 {
      // daily13[daily1CC + i] =  countIFS(Calculationdaily1_[(LI+i)...].prefix(),"="daily10[daily1A + i],Calculationdaily1_[(KN+i)...].prefix(),{!$0.isZero},Calculationdaily1_[(KS+i)...].prefix(),{!$0.isZero})
    }

    /// Min RawMeth cons during night
    let daily1CD = 1095
    // C_RawMeth_min_cons*CA6
    for i in 0..<365 { daily13[daily1CD + i] = C_RawMeth_min_cons * daily13[daily1CA + i] }

    /// Max RawMeth cons during night
    let daily1CE = 1460
    // C_RawMeth_max_cons*CA6
    for i in 0..<365 { daily13[daily1CE + i] = C_RawMeth_max_cons * daily13[daily1CA + i] }

    /// Min CO2 cons during night
    let daily1CF = 1825
    // C_CO2_min_cons*CA6
    for i in 0..<365 { daily13[daily1CF + i] = C_C_O_2_min_cons * daily13[daily1CA + i] }

    /// Max CO2 cons during night
    let daily1CG = 2190
    // C_CO2_max_cons*CA6
    for i in 0..<365 { daily13[daily1CG + i] = C_C_O_2_max_cons * daily13[daily1CA + i] }

    /// Min H2 cons during night
    let daily1CH = 2555
    // C_Hydrogen_min_cons*CA6
    for i in 0..<365 { daily13[daily1CH + i] = C_Hydrogen_min_cons * daily13[daily1CA + i] }

    /// Max H2 cons during night
    let daily1CI = 2920
    // C_Hydrogen_max_cons*CA6
    for i in 0..<365 { daily13[daily1CI + i] = C_Hydrogen_max_cons * daily13[daily1CA + i] }

    /// Surplus RawMeth storage cap after night min op  prep
    let daily1CJ = 3285
    // 1-CD6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily13[daily1CJ + i] = 1 - daily13[daily1CD + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let daily1CK = 3650
    // 1-CE6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily13[daily1CK + i] = 1 - daily11[daily1CE + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let daily1CL = 4015
    // 1-CF6/CO2_storage_cap_ud
    for i in 0..<365 { daily13[daily1CL + i] = 1 - daily11[daily1CF + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily1CM = 4380
    // 1-CG6/CO2_storage_cap_ud
    for i in 0..<365 { daily13[daily1CM + i] = 1 - daily11[daily1CG + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let daily1CN = 4745
    // 1-CH6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily13[daily1CN + i] = 1 - daily13[daily1CH + i] / Hydrogen_storage_cap_ud
    }

    /// Surplus H2 storage cap after max night op prep
    let daily1CO = 5110
    // 1-CI6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily13[daily1CO + i] = 1 - daily11[daily1CI + i] / Hydrogen_storage_cap_ud
    }

    /// Max Equiv harmonious night prod due to physical limits
    let daily1CP = 5475
    // IF(OR(CJ6<=0,CL6<=0,CN6<=0),0,MIN(1,IFERROR(CJ6/(CJ6-CK6),1),IFERROR(CL6/(CL6-CM6),1),IFERROR(CN6/(CN6-CO6),1))*(C_equiv_harmonious_max_perc-C_equiv_harmonious_min_perc)+C_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily13[daily1CP + i] = iff(
        or(daily11[daily1CJ + i] <= 0, daily11[daily1CL + i] <= 0, daily11[daily1CN + i] <= 0), 0,
        min(
          1, ifFinite(daily11[daily1CJ + i] / (daily11[daily1CJ + i] - daily11[daily1CK + i]), 1),
          ifFinite(daily11[daily1CL + i] / (daily11[daily1CL + i] - daily13[daily1CM + i]), 1),
          ifFinite(daily11[daily1CN + i] / (daily11[daily1CN + i] - daily11[daily1CO + i]), 1))
          * (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc)
          + C_equiv_harmonious_min_perc)
    }

    /// Nr of hours outside of harm op period after max night prep
    let daily1CR = 5840
    // COUNTIFS(CalculationNP5:NP8763,"="A6,CalculationNN5:NN8763,"<=0")
    for i in 0..<365 { daily13[daily1CR + i] = NN_NPcountZero[i] }

    /// Nr of harm op period hours after max night prep
    let daily1CS = 6205
    // COUNTIFS(CalculationNP5:NP8763,"="A6,CalculationNN5:NN8763,">0")
    for i in 0..<365 { daily13[daily1CS + i] = NN_NPcountNonZero[i] }

    /// Nr of PB op hours after max night prep
    let daily1CT = 6570
    // COUNTIFS(CalculationNP5:NP8763,"="A6,CalculationMX5:MX8763,">0")
    for i in 0..<365 { daily13[daily1CT + i] = MX_NPcountNonZero[i] }

    /// Max RawMeth cons during night
    let daily1CU = 6935
    // C_RawMeth_max_cons*CR6
    for i in 0..<365 { daily13[daily1CU + i] = C_RawMeth_max_cons * daily11[daily1CR + i] }

    /// Max CO2 cons during night
    let daily1CV = 7300
    // C_CO2_max_cons*CR6
    for i in 0..<365 { daily13[daily1CV + i] = C_C_O_2_max_cons * daily11[daily1CR + i] }

    /// Max H2 cons during night
    let daily1CW = 7665
    // C_Hydrogen_max_cons*CR6
    for i in 0..<365 { daily13[daily1CW + i] = C_Hydrogen_max_cons * daily11[daily1CR + i] }

    /// Min el cons during day for night op prep
    let daily1CX = 8030
    // (CH6+CD6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+CB6*EY_fix_cons+(CF6+CD6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+CB6*CCU_fix_cons+CD6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+CB6*MethSynt_fix_cons
    for i in 0..<365 {
      daily13[daily1CX + i] =
        (daily13[daily1CH + i] + daily13[daily1CD + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily13[daily1CB + i] * EY_fix_cons
        + (daily11[daily1CF + i] + daily13[daily1CD + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily13[daily1CB + i] * CCU_fix_cons
        + daily13[daily1CD + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily13[daily1CB + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let daily1CY = 8395
    // (CW6+CU6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+CS6*EY_fix_cons+(CV6+CU6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+CS6*CCU_fix_cons+CU6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+CS6*MethSynt_fix_cons
    for i in 0..<365 {
      daily13[daily1CY + i] =
        (daily11[daily1CW + i] + daily11[daily1CU + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily11[daily1CS + i] * EY_fix_cons
        + (daily13[daily1CV + i] + daily11[daily1CU + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily11[daily1CS + i] * CCU_fix_cons
        + daily11[daily1CU + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily11[daily1CS + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let daily1CZ = 8760
    // (CH6+CD6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+CB6*EY_heat_fix_cons+(CF6+CD6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+CB6*CCU_fix_heat_cons-CD6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-CB6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily13[daily1CZ + i] =
        (daily13[daily1CH + i] + daily13[daily1CD + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily13[daily1CB + i] * EY_heat_fix_cons
        + (daily11[daily1CF + i] + daily13[daily1CD + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily13[daily1CB + i] * CCU_fix_heat_cons
        - daily13[daily1CD + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily13[daily1CB + i] * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let daily1DA = 9125
    // (CW6+CU6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+CS6*EY_heat_fix_cons+(CV6+CU6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+CS6*CCU_fix_heat_cons-CU6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-CS6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily13[daily1DA + i] =
        (daily11[daily1CW + i] + daily11[daily1CU + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily11[daily1CS + i] * EY_heat_fix_cons
        + (daily13[daily1CV + i] + daily11[daily1CU + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily11[daily1CS + i] * CCU_fix_heat_cons
        - daily11[daily1CU + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily11[daily1CS + i] * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let daily1DB = 9490
    // CD6
    for i in 0..<365 { daily13[daily1DB + i] = daily13[daily1CD + i] }

    /// Max Rawmeth prod during day for night op prep
    let daily1DC = 9855
    // CU6
    for i in 0..<365 { daily13[daily1DC + i] = daily11[daily1CU + i] }

    /// Min CO2 prod during day for night op prep
    let daily1DD = 10220
    // CF6+CD6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily13[daily1DD + i] =
        daily11[daily1CF + i] + daily13[daily1CD + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let daily1DE = 10585
    // CV6+CU6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily13[daily1DE + i] =
        daily13[daily1CV + i] + daily11[daily1CU + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let daily1DF = 10950
    // CH6+CD6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily13[daily1DF + i] =
        daily13[daily1CH + i] + daily13[daily1CD + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let daily1DG = 11315
    // CW6+CU6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily13[daily1DG + i] =
        daily11[daily1CW + i] + daily11[daily1CU + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after max night op prep
    let daily1DH = 11680
    // 1-CU6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily13[daily1DH + i] = 1 - daily11[daily1CU + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily1DI = 12045
    // 1-CV6/CO2_storage_cap_ud
    for i in 0..<365 { daily13[daily1DI + i] = 1 - daily13[daily1CV + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let daily1DJ = 12410
    // 1-CW6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily13[daily1DJ + i] = 1 - daily11[daily1CW + i] / Hydrogen_storage_cap_ud
    }

    /// Max Equiv harmonious night prod due to physical limits
    let daily1DK = 12775
    // IF(OR(CJ6<=0,CL6<=0,CN6<=0),0,MIN(1,IFERROR(CJ6/(CJ6-DH6),1),IFERROR(CL6/(CL6-DI6),1),IFERROR(CN6/(CN6-DJ6),1))*(C_equiv_harmonious_max_perc-C_equiv_harmonious_min_perc)+C_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily13[daily1DK + i] = iff(
        or(daily11[daily1CJ + i] <= 0, daily11[daily1CL + i] <= 0, daily11[daily1CN + i] <= 0), 0,
        min(
          1, ifFinite(daily11[daily1CJ + i] / (daily11[daily1CJ + i] - daily13[daily1DH + i]), 1),
          ifFinite(daily11[daily1CL + i] / (daily11[daily1CL + i] - daily13[daily1DI + i]), 1),
          ifFinite(daily11[daily1CN + i] / (daily11[daily1CN + i] - daily13[daily1DJ + i]), 1))
          * (C_equiv_harmonious_max_perc - C_equiv_harmonious_min_perc)
          + C_equiv_harmonious_min_perc)
    }

    var daily14 = [Double]()

    /// Nr of hours outside of harm op period after min night prep
    let daily1DM = 0
    // COUNTIFS(CalculationPQ5:PQ8763,"="A6,CalculationPO5:PO8763,"<=0")
    for i in 0..<365 { daily14[daily1DM + i] = PO_PQcountZero[i] }

    /// Nr of harm op period hours after min night prep
    let daily1DN = 365
    // COUNTIFS(CalculationPQ5:PQ8763,"="A6,CalculationPO5:PO8763,">0")
    for i in 0..<365 { daily14[daily1DN + i] = PO_PQcountNonZero[i] }

    /// Nr of PB op hours after min night prep
    let daily1DO = 730
    // COUNTIFS(CalculationPQ5:PQ8763,"="A6,CalculationOV5:OV8763,">0",CalculationPA5:PA8763,">0")
    for i in 0..<365 {
      // daily14[daily1DO + i] =  countIFS(Calculationdaily1_[(PQ+i)...].prefix(),"="daily10[daily1A + i],Calculationdaily1_[(OV+i)...].prefix(),{!$0.isZero},Calculationdaily1_[(PA+i)...].prefix(),{!$0.isZero})
    }

    /// Min RawMeth cons during night
    let daily1DP = 1095
    // D_RawMeth_min_cons*DM6
    for i in 0..<365 { daily14[daily1DP + i] = D_RawMeth_min_cons * daily14[daily1DM + i] }

    /// Max RawMeth cons during night
    let daily1DQ = 1460
    // D_RawMeth_max_cons*DM6
    for i in 0..<365 { daily14[daily1DQ + i] = D_RawMeth_max_cons * daily14[daily1DM + i] }

    /// Min CO2 cons during night
    let daily1DR = 1825
    // D_CO2_min_cons*DM6
    for i in 0..<365 { daily14[daily1DR + i] = D_C_O_2_min_cons * daily14[daily1DM + i] }

    /// Max CO2 cons during night
    let daily1DS = 2190
    // D_CO2_max_cons*DM6
    for i in 0..<365 { daily14[daily1DS + i] = D_C_O_2_max_cons * daily14[daily1DM + i] }

    /// Min H2 cons during night
    let daily1DT = 2555
    // D_Hydrogen_min_cons*DM6
    for i in 0..<365 { daily14[daily1DT + i] = D_Hydrogen_min_cons * daily14[daily1DM + i] }

    /// Max H2 cons during night
    let daily1DU = 2920
    // D_Hydrogen_max_cons*DM6
    for i in 0..<365 { daily14[daily1DU + i] = D_Hydrogen_max_cons * daily14[daily1DM + i] }

    /// Surplus RawMeth storage cap after night min op  prep
    let daily1DV = 3285
    // 1-DP6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily14[daily1DV + i] = 1 - daily14[daily1DP + i] / RawMeth_storage_cap_ud }

    /// Surplus RawMeth storage cap after max night op prep
    let daily1DW = 3650
    // 1-DQ6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily14[daily1DW + i] = 1 - daily14[daily1DQ + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after min night op prep
    let daily1DX = 4015
    // 1-DR6/CO2_storage_cap_ud
    for i in 0..<365 { daily14[daily1DX + i] = 1 - daily14[daily1DR + i] / C_O_2_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily1DY = 4380
    // 1-DS6/CO2_storage_cap_ud
    for i in 0..<365 { daily14[daily1DY + i] = 1 - daily14[daily1DS + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after min night op prep
    let daily1DZ = 4745
    // 1-DT6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily14[daily1DZ + i] = 1 - daily14[daily1DT + i] / Hydrogen_storage_cap_ud
    }

    /// Surplus H2 storage cap after max night op prep
    let daily1EA = 5110
    // 1-DU6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily14[daily1EA + i] = 1 - daily14[daily1DU + i] / Hydrogen_storage_cap_ud
    }

    /// Max Equiv harmonious night prod due to physical limits
    let daily1EB = 5475
    // IF(OR(DV6<=0,DX6<=0,DZ6<=0),0,MIN(1,IFERROR(DV6/(DV6-DW6),1),IFERROR(DX6/(DX6-DY6),1),IFERROR(DZ6/(DZ6-EA6),1))*(D_equiv_harmonious_max_perc-D_equiv_harmonious_min_perc)+D_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily14[daily1EB + i] = iff(
        or(daily11[daily1DV + i] <= 0, daily14[daily1DX + i] <= 0, daily14[daily1DZ + i] <= 0), 0,
        min(
          1, ifFinite(daily11[daily1DV + i] / (daily11[daily1DV + i] - daily14[daily1DW + i]), 1),
          ifFinite(daily14[daily1DX + i] / (daily14[daily1DX + i] - daily14[daily1DY + i]), 1),
          ifFinite(daily14[daily1DZ + i] / (daily14[daily1DZ + i] - daily14[daily1EA + i]), 1))
          * (D_equiv_harmonious_max_perc - D_equiv_harmonious_min_perc)
          + D_equiv_harmonious_min_perc)
    }

    /// Nr of hours outside of harm op period after max night prep
    let daily1ED = 5840
    // COUNTIFS(CalculationRX5:RX8763,"="A6,CalculationRV5:RV8763,"<=0")
    for i in 0..<365 { daily14[daily1ED + i] = RV_RXcountZero[i] }

    /// Nr of harm op period hours after max night prep
    let daily1EE = 6205
    // COUNTIFS(CalculationRX5:RX8763,"="A6,CalculationRV5:RV8763,">0")
    for i in 0..<365 { daily14[daily1EE + i] = RV_RXcountNonZero[i] }

    /// Nr of PB op hours after max night prep
    let daily1EF = 6570
    // COUNTIFS(CalculationRX5:RX8763,"="A6,CalculationRF5:RF8763,">0")
    for i in 0..<365 { daily14[daily1EF + i] = RF_RXcountNonZero[i] }

    /// Max RawMeth cons during night
    let daily1EG = 6935
    // D_RawMeth_max_cons*ED6
    for i in 0..<365 { daily14[daily1EG + i] = D_RawMeth_max_cons * daily14[daily1ED + i] }

    /// Max CO2 cons during night
    let daily1EH = 7300
    // D_CO2_max_cons*ED6
    for i in 0..<365 { daily14[daily1EH + i] = D_C_O_2_max_cons * daily14[daily1ED + i] }

    /// Max H2 cons during night
    let daily1EI = 7665
    // D_Hydrogen_max_cons*ED6
    for i in 0..<365 { daily14[daily1EI + i] = D_Hydrogen_max_cons * daily14[daily1ED + i] }

    /// Min el cons during day for night op prep
    let daily1EJ = 8030
    // (DT6+DP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+DN6*EY_fix_cons+(DR6+DP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+DN6*CCU_fix_cons+DP6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+DN6*MethSynt_fix_cons
    for i in 0..<365 {
      daily14[daily1EJ + i] =
        (daily14[daily1DT + i] + daily14[daily1DP + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily14[daily1DN + i] * EY_fix_cons
        + (daily14[daily1DR + i] + daily14[daily1DP + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily14[daily1DN + i] * CCU_fix_cons
        + daily14[daily1DP + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily14[daily1DN + i] * MethSynt_fix_cons
    }

    /// Max el cons during day for night op prep
    let daily1EK = 8395
    // (EI6+EG6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_gross_nom_cons+EE6*EY_fix_cons+(EH6+EG6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_nom_cons+EE6*CCU_fix_cons+EG6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_nom_cons+EE6*MethSynt_fix_cons
    for i in 0..<365 {
      daily14[daily1EK + i] =
        (daily11[daily1EI + i] + daily11[daily1EG + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_gross_nom_cons + daily11[daily1EE + i] * EY_fix_cons
        + (daily14[daily1EH + i] + daily11[daily1EG + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_nom_cons + daily11[daily1EE + i] * CCU_fix_cons
        + daily11[daily1EG + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_nom_cons
        + daily11[daily1EE + i] * MethSynt_fix_cons
    }

    /// Min heat cons during day for night op prep
    let daily1EL = 8760
    // (DT6+DP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+DN6*EY_heat_fix_cons+(DR6+DP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+DN6*CCU_fix_heat_cons-DP6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-DN6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily14[daily1EL + i] =
        (daily14[daily1DT + i] + daily14[daily1DP + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily14[daily1DN + i] * EY_heat_fix_cons
        + (daily14[daily1DR + i] + daily14[daily1DP + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily14[daily1DN + i] * CCU_fix_heat_cons
        - daily14[daily1DP + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily14[daily1DN + i] * MethSynt_heat_fix_prod
    }

    /// Max heat cons during day for prep of night
    let daily1EM = 9125
    // (EI6+EG6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons)/EY_Hydrogen_nom_prod*EY_var_heat_nom_cons+EE6*EY_heat_fix_cons+(EH6+EG6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons)/CCU_CO2_nom_prod_ud*CCU_var_heat_nom_cons+EE6*CCU_fix_heat_cons-EG6/MethSynt_RawMeth_nom_prod_ud*MethSynt_var_heat_nom_prod-EE6*MethSynt_heat_fix_prod
    for i in 0..<365 {
      daily14[daily1EM + i] =
        (daily11[daily1EI + i] + daily11[daily1EG + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons)
        / EY_Hydrogen_nom_prod * EY_var_heat_nom_cons + daily11[daily1EE + i] * EY_heat_fix_cons
        + (daily14[daily1EH + i] + daily11[daily1EG + i]
          / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons)
        / CCU_C_O_2_nom_prod_ud * CCU_var_heat_nom_cons + daily11[daily1EE + i] * CCU_fix_heat_cons
        - daily11[daily1EG + i] / MethSynt_RawMeth_nom_prod_ud * MethSynt_var_heat_nom_prod
        - daily11[daily1EE + i] * MethSynt_heat_fix_prod
    }

    /// Min Rawmeth prod during day for night op prep
    let daily1EN = 9490
    // DP6
    for i in 0..<365 { daily14[daily1EN + i] = daily14[daily1DP + i] }

    /// Max Rawmeth prod during day for night op prep
    let daily1EO = 9855
    // EG6
    for i in 0..<365 { daily14[daily1EO + i] = daily11[daily1EG + i] }

    /// Min CO2 prod during day for night op prep
    let daily1EP = 10220
    // DR6+DP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily14[daily1EP + i] =
        daily14[daily1DR + i] + daily14[daily1DP + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Max CO2 prod during day for night op prep
    let daily1EQ = 10585
    // EH6+EG6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_CO2_nom_cons
    for i in 0..<365 {
      daily14[daily1EQ + i] =
        daily14[daily1EH + i] + daily11[daily1EG + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_C_O_2_nom_cons
    }

    /// Min H2 prod during day for night op prep
    let daily1ER = 10950
    // DT6+DP6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily14[daily1ER + i] =
        daily14[daily1DT + i] + daily14[daily1DP + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Max H2 prod during day for night op prep
    let daily1ES = 11315
    // EI6+EG6/(MethSynt_CO2_nom_cons+MethSynt_Hydrogen_nom_cons)*MethSynt_Hydrogen_nom_cons
    for i in 0..<365 {
      daily14[daily1ES + i] =
        daily11[daily1EI + i] + daily11[daily1EG + i]
        / (MethSynt_C_O_2_nom_cons + MethSynt_Hydrogen_nom_cons) * MethSynt_Hydrogen_nom_cons
    }

    /// Surplus RawMeth storage cap after max night op prep
    let daily1ET = 11680
    // 1-EG6/RawMeth_storage_cap_ud
    for i in 0..<365 { daily14[daily1ET + i] = 1 - daily11[daily1EG + i] / RawMeth_storage_cap_ud }

    /// Surplus CO2 storage cap after max night op prep
    let daily1EU = 12045
    // 1-EH6/CO2_storage_cap_ud
    for i in 0..<365 { daily14[daily1EU + i] = 1 - daily14[daily1EH + i] / C_O_2_storage_cap_ud }

    /// Surplus H2 storage cap after max night op prep
    let daily1EV = 12410
    // 1-EI6/Hydrogen_storage_cap_ud
    for i in 0..<365 {
      daily14[daily1EV + i] = 1 - daily11[daily1EI + i] / Hydrogen_storage_cap_ud
    }

    /// Max Equiv harmonious night prod due to physical limits
    let daily1EW = 12775
    // IF(OR(DV6<=0,DX6<=0,DZ6<=0),0,MIN(1,IFERROR(DV6/(DV6-ET6),1),IFERROR(DX6/(DX6-EU6),1),IFERROR(DZ6/(DZ6-EV6),1))*(D_equiv_harmonious_max_perc-D_equiv_harmonious_min_perc)+D_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily14[daily1EW + i] = iff(
        or(daily11[daily1DV + i] <= 0, daily14[daily1DX + i] <= 0, daily14[daily1DZ + i] <= 0), 0,
        min(
          1, ifFinite(daily11[daily1DV + i] / (daily11[daily1DV + i] - daily11[daily1ET + i]), 1),
          ifFinite(daily14[daily1DX + i] / (daily14[daily1DX + i] - daily11[daily1EU + i]), 1),
          ifFinite(daily14[daily1DZ + i] / (daily14[daily1DZ + i] - daily14[daily1EV + i]), 1))
          * (D_equiv_harmonious_max_perc - D_equiv_harmonious_min_perc)
          + D_equiv_harmonious_min_perc)
    }
*/
    var daily15 = [Double]()
    let CS_CQ_Lsum = hourly0.sumOf(hourlyL, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    let CS_CQ_CIsum = hourly2.sumOf(hourlyCI, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Available elec after TES chrg during harm op period
    let daily1EY = 0
    // SUMIFS(CalculationL5:L8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")+SUMIFS(CalculationBX5:BX8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")-SUMIFS(CalculationCI5:CI8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // for i in 0..<365 { daily15[daily1EY + i] = CS_CQ_Lsum[i] + CC_CS_BXsum[i] - CS_CQ_CIsum[i] }

    /// Available elec after TES chrg outside harm op period
    let daily1EZ = 365
    // SUMIFS(CalculationL5:L8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")+SUMIFS(CalculationBX5:BX8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")-SUMIFS(CalculationCI5:CI8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    // for i in 0..<365 { daily15[daily1EZ + i] = CS_CQ_Lsum[i] + CC_CS_BXsum[i] - CS_CQ_CIsum[i] }


    let CS_CQ_CJsum = hourly2.sumOf(hourlyCJ, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    let CS_CQ_Jsum = hourly0.sumOf(hourlyJ, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Available heat after TES chrg during harm op period
    let daily1FA = 730
    // SUMIFS(CalculationJ5:J8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")+SUMIFS(CalculationCB5:CB8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationCJ5:CJ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    // for i in 0..<365 {
    //   daily15[daily1FA + i] =
    //     CS_CQ_Jsum[i] + CC_CS_CBsum[i] / PB_Ratio_Heat_input_vs_output - CS_CQ_CJsum[i]
    // }

    /// Available heat after TES chrg outside of harm op period
    let daily1FB = 1095
    // SUMIFS(CalculationJ5:J8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")+SUMIFS(CalculationCB5:CB8763,CalculationCC5:CC8763,">0",CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationCJ5:CJ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    // for i in 0..<365 {
    //   daily15[daily1FB + i] =
    //     CS_CQ_Jsum[i] + CC_CS_CBsum[i] / PB_Ratio_Heat_input_vs_output - CS_CQ_CJsum[i]
    // }
    let CQsum = hourly3.sum(days: daysCS, range: hourlyCQ) 
    let CS_CQ_CTsum = hourly3.sumOf(hourlyCT, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Harm el cons considering min harm op during harm op period
    let daily1FC = 1460
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FC + i] = CQsum[i] + CS_CQ_CTsum[i] }

    let DHsum = hourly3.sum(days: daysCS, range: hourlyDH) 
    let CS_DH_CTsum = hourly3.sumOf(hourlyCT, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Harm el cons considering max harm op during harm op period
    let daily1FD = 1825
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763)+SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FD + i] = DHsum[i] + CS_DH_CTsum[i] }

    /// Harm el cons outside of harm op period
    let daily1FE = 2190
    // SUMIFS(CalculationCT5:CT8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 { daily15[daily1FE + i] = CS_CQ_CTsum[i] }

    let CRsum = hourly3.sum(days: daysCS, range: hourlyCR) 
    let CS_CQ_CUsum = hourly3.sumOf(hourlyCU, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Harm heat cons considering min harm op during harm op period
    let daily1FF = 2555
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCR5:CR8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FF + i] = CRsum[i] + CS_CQ_CUsum[i] }

    let DIsum = hourly3.sum(days: daysCS, range: hourlyDI) 
    let CS_DH_CUsum = hourly3.sumOf(hourlyCU, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Harm heat cons considering max harm op during harm op period
    let daily1FG = 2920
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDI5:DI8763)+SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FG + i] = DIsum[i] + CS_DH_CUsum[i] }

    /// Harm heat cons outside of harm op period
    let daily1FH = 3285
    // SUMIFS(CalculationCU5:CU8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0")
    for i in 0..<365 { daily15[daily1FH + i] = CS_CQ_CUsum[i] }

    let CS_CQ_CXsum = hourly3.sumOf(hourlyCX, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Grid import considering min harm op during harm op period
    let daily1FI = 3650
    // SUMIFS(CalculationCX5:CX8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FI + i] = CS_CQ_CXsum[i] }

    let CS_DH_DLsum = hourly3.sumOf(hourlyDL, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Grid import considering max harm op during harm op period
    let daily1FJ = 4015
    // SUMIFS(CalculationDL5:DL8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FJ + i] = CS_DH_DLsum[i] }

    let CXsum = hourly3.sum(days: daysCS, range: hourlyCX) 
    /// Grid import  outside of harm op period
    let daily1FK = 4380
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCX5:CX8763)-FI6
    for i in 0..<365 { daily15[daily1FK + i] = CXsum[i] - daily15[daily1FI + i] }

    let CS_CQ_CZsum = hourly3.sumOf(hourlyCZ, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// El boiler op considering min harm op during harm op period
    let daily1FL = 4745
    // SUMIFS(CalculationCZ5:CZ8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FL + i] = CS_CQ_CZsum[i] }

    let CS_DH_DNsum = hourly3.sumOf(hourlyDN, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// El boiler op considering max harm op during harm op period
    let daily1FM = 5110
    // SUMIFS(CalculationDN5:DN8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FM + i] = CS_DH_DNsum[i] }

    let CZsum = hourly3.sum(days: daysCS, range: hourlyCZ) 
    /// El boiler op outside harm op period
    let daily1FN = 5475
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCZ5:CZ8763)-FL6
    for i in 0..<365 { daily15[daily1FN + i] = CZsum[i] - daily15[daily1FL + i] }

    let CS_CQ_CMsum = hourly2.sumOf(hourlyCM, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Total aux cons during harm op period
    let daily1FO = 5840
    // SUMIFS(CalculationCM5:CM8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FO + i] = CS_CQ_CMsum[i] }

    let CMsum = hourly3.sum(days: daysCS, range: hourlyCM) 
    /// Total aux cons outside of harm op period
    let daily1FP = 6205
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCM5:CM8763)-FO6
    for i in 0..<365 { daily15[daily1FP + i] = CMsum[i] - daily15[daily1FO + i] }

    let CS_CQ_CNsum = hourly2.sumOf(hourlyCN, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// El cons not covered during harm op period
    let daily1FQ = 6570
    // SUMIFS(CalculationCN5:CN8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FQ + i] = CS_CQ_CNsum[i] }

    let CNsum = hourly3.sum(days: daysCS, range: hourlyCN) 
    /// El cons not covered outside of harm op period
    let daily1FR = 6935
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCN5:CN8763)-FQ6
    for i in 0..<365 { daily15[daily1FR + i] = CNsum[i] - daily15[daily1FQ + i] }

    let CS_CQ_CVsum = hourly3.sumOf(hourlyCV, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Remaining PV el after TES chrg&min harm&aux during harm op period
    let daily1FS = 7300
    // SUMIFS(CalculationCV5:CV8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FS + i] = CS_CQ_CVsum[i] }

    let CS_DH_DJsum = hourly3.sumOf(hourlyDJ, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Remaining PV el after TES chrg&max harm&aux op during harm op period
    let daily1FT = 7665
    // SUMIFS(CalculationDJ5:DJ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FT + i] = CS_DH_DJsum[i] }

    let CVsum = hourly3.sum(days: daysCS, range: hourlyCV) 
    /// Remaining PV el outside of harm op period
    let daily1FU = 8030
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCV5:CV8763)-FS6
    for i in 0..<365 { daily15[daily1FU + i] = CVsum[i] - daily15[daily1FS + i] }

    let CS_CQ_CWsum = hourly3.sumOf(hourlyCW, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Remaining CSP heat after min harm during harm op period
    let daily1FV = 8395
    // SUMIFS(CalculationCW5:CW8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1FV + i] = CS_CQ_CWsum[i] }

    let CS_DH_DKsum = hourly3.sumOf(hourlyDK, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Remaining CSP heat after max harm op during harm op period
    let daily1FW = 8760
    // SUMIFS(CalculationDK5:DK8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1FW + i] = CS_DH_DKsum[i] }

    let CWsum = hourly3.sum(days: daysCS, range: hourlyCW) 
    /// Remaining CSP heat outside of harm op period
    let daily1FX = 9125
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCW5:CW8763)-FV6
    for i in 0..<365 { daily15[daily1FX + i] = CWsum[i] - daily15[daily1FV + i] }

    let CS_CQ_DEsum = hourly3.sumOf(hourlyDE, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Max BESS night prep after min harm cons during harm op period
    let daily1FY = 9490
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily15[daily1FY + i] = min(CS_CQ_DEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let CS_DH_DSsum = hourly3.sumOf(hourlyDS, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Max BESS night prep after max harm cons during harm op period
    let daily1FZ = 9855
    // MIN(SUMIFS(CalculationDS5:DS8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily15[daily1FZ + i] = min(CS_DH_DSsum[i], BESS_cap_ud / BESS_chrg_eff) }

    /// Max BESS night prep outside of harm op period
    let daily1GA = 10220
    // MIN(SUMIFS(CalculationDE5:DE8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily15[daily1GA + i] = min(CS_CQ_DEsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let CS_CQ_DFsum = hourly3.sumOf(hourlyDF, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Max grid export after min harm cons during harm op period
    let daily1GB = 10585
    // SUMIFS(CalculationDF5:DF8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GB + i] = CS_CQ_DFsum[i] }

    let CS_DH_DTsum = hourly3.sumOf(hourlyDT, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Max grid export after max harm cons during harm op period
    let daily1GC = 10950
    // SUMIFS(CalculationDT5:DT8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GC + i] = CS_DH_DTsum[i] }

    let DFsum = hourly3.sum(days: daysCS, range: hourlyDF) 
    /// Max grid export outside of harm op period
    let daily1GD = 11315
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDF5:DF8763)-GB6
    for i in 0..<365 { daily15[daily1GD + i] = DFsum[i] - daily15[daily1GB + i] }

    let CS_CQ_CYsum = hourly3.sumOf(hourlyCY, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Remaining grid import during harm op period after min harm
    let daily1GE = 11680
    // SUMIFS(CalculationCY5:CY8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GE + i] = CS_CQ_CYsum[i] }

    let CS_DH_DMsum = hourly3.sumOf(hourlyDM, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Remaining grid import during harm op period after max harm
    let daily1GF = 12045
    // SUMIFS(CalculationDM5:DM8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GF + i] = CS_DH_DMsum[i] }

    let CYsum = hourly3.sum(days: daysCS, range: hourlyCY) 
    /// Remaining grid import outside of harm op period
    let daily1GG = 12410
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationCY5:CY8763)-GE6
    for i in 0..<365 { daily15[daily1GG + i] = CYsum[i] - daily15[daily1GE + i] }

    let CS_CQ_DAsum = hourly3.sumOf(hourlyDA, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Remaining El boiler cap during harm op period after min harm
    let daily1GH = 12775
    // SUMIFS(CalculationDA5:DA8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GH + i] = CS_CQ_DAsum[i] }

    let CS_DH_DOsum = hourly3.sumOf(hourlyDO, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Remaining El boiler cap during harm op period after max harm
    let daily1GI = 13140
    // SUMIFS(CalculationDO5:DO8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GI + i] = CS_DH_DOsum[i] }

    let DAsum = hourly3.sum(days: daysCS, range: hourlyDA) 
    /// Remaining El boiler cap outside of harm op period
    let daily1GJ = 13505
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDA5:DA8763)-GH6
    for i in 0..<365 { daily15[daily1GJ + i] = DAsum[i] - daily11[daily1GH + i] }

    let CS_CQ_DBsum = hourly3.sumOf(hourlyDB, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Remaining MethSynt cap during harm op after min harm op
    let daily1GK = 13870
    // SUMIFS(CalculationDB5:DB8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GK + i] = CS_CQ_DBsum[i] }

    let CS_DH_DPsum = hourly3.sumOf(hourlyDP, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Remaining MethSynt cap during harm op period after max harm op
    let daily1GL = 14235
    // SUMIFS(CalculationDP5:DP8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GL + i] = CS_DH_DPsum[i] }

    let DBsum = hourly3.sum(days: daysCS, range: hourlyDB) 
    /// Remaining MethSynt cap outside of harm op period
    let daily1GM = 14600
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDB5:DB8763)-GK6
    for i in 0..<365 { daily15[daily1GM + i] = DBsum[i] - daily15[daily1GK + i] }

    let CS_CQ_DCsum = hourly3.sumOf(hourlyDC, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Remaining CCU cap during harm op after min harm
    let daily1GN = 14965
    // SUMIFS(CalculationDC5:DC8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GN + i] = CS_CQ_DCsum[i] }

    let CS_DH_DQsum = hourly3.sumOf(hourlyDQ, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Remaining CCU cap during harm op after max harm
    let daily1GO = 15330
    // SUMIFS(CalculationDQ5:DQ8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GO + i] = CS_DH_DQsum[i] }

    let DCsum = hourly3.sum(days: daysCS, range: hourlyDC) 
    /// Remaining CCU cap outside of harm op after min harm
    let daily1GP = 15695
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDC5:DC8763)-GN6
    for i in 0..<365 { daily15[daily1GP + i] = DCsum[i] - daily15[daily1GN + i] }

    let CS_CQ_DDsum = hourly3.sumOf(hourlyDD, days: daysCS, condition: hourlyCQ, predicate: {$0>0})
    /// Remaining EY cap during harm op after min harm
    let daily1GQ = 16060
    // SUMIFS(CalculationDD5:DD8763,CalculationCS5:CS8763,"="A6,CalculationCQ5:CQ8763,">0")
    for i in 0..<365 { daily15[daily1GQ + i] = CS_CQ_DDsum[i] }

    let DDsum = hourly3.sum(days: daysCS, range: hourlyDD) 
    let CS_DH_DRsum = hourly3.sumOf(hourlyDR, days: daysCS, condition: hourlyDH, predicate: {$0>0})
    /// Remaining EY cap during harm op period after max harm
    let daily1GR = 16425
    // SUMIFS(CalculationDR5:DR8763,CalculationCS5:CS8763,"="A6,CalculationDH5:DH8763,">0")
    for i in 0..<365 { daily15[daily1GR + i] = CS_DH_DRsum[i] }

    /// Remaining EY cap outside of harm op period
    let daily1GS = 16790
    // SUMIF(CalculationCS5:CS8763,"="A6,CalculationDD5:DD8763)-GQ6
    for i in 0..<365 { daily15[daily1GS + i] = DDsum[i] - daily15[daily1GQ + i] }

    var daily16 = [Double]()

    let EZ_EX_Lsum = hourly0.sumOf(hourlyL, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    let EZ_EX_EHsum = hourly4.sumOf(hourlyEH, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    let EZ_EX_EPsum = hourly4.sumOf(hourlyEP, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Available elec after TES chrg during harm op period
    let daily1GU = 0
    // SUMIFS(CalculationL5:L8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")+SUMIFS(CalculationEH5:EH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")-SUMIFS(CalculationEP5:EP8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1GU + i] = EZ_EX_Lsum[i] + EZ_EX_EHsum[i] - EZ_EX_EPsum[i] }

    /// Available elec after TES chrg outside harm op period
    let daily1GV = 365
    // SUMIFS(CalculationL5:L8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEH5:EH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")-SUMIFS(CalculationEP5:EP8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { daily16[daily1GV + i] = EZ_EX_Lsum[i] + EZ_EX_EHsum[i] - EZ_EX_EPsum[i] }

    let EZ_EX_Jsum = hourly0.sumOf(hourlyJ, days: daysEZ, condition: hourlyEX, predicate: {$0>0}) // FIXME
    let EZ_EX_EQsum = hourly4.sumOf(hourlyEQ, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    let EZ_EX_EIsum = hourly4.sumOf(hourlyEI, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Available heat after TES chrg during harm op period
    let daily1GW = 730
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 {
      daily16[daily1GW + i] =
        EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i]
    }

    /// Available heat after TES chrg outside of harm op period
    let daily1GX = 1095
    // SUMIFS(CalculationJ5:J8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")+SUMIFS(CalculationEI5:EI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")/PB_Ratio_Heat_input_vs_output-SUMIFS(CalculationEQ5:EQ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 {
      daily16[daily1GX + i] =
        EZ_EX_Jsum[i] + EZ_EX_EIsum[i] / PB_Ratio_Heat_input_vs_output - EZ_EX_EQsum[i]
    }

    let EXsum = hourly4.sum(days: daysEZ, range: hourlyEX) 
    let EZ_EX_FAsum = hourly4.sumOf(hourlyFA, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Harm el cons considering min harm op during harm op period
    let daily1GY = 1460
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763)+SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1GY + i] = EXsum[i] + EZ_EX_FAsum[i] }

    let FOsum = hourly4.sum(days: daysEZ, range: hourlyFO) 
    let EZ_FO_FAsum = hourly4.sumOf(hourlyFA, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// Harm el cons considering max harm op during harm op period
    let daily1GZ = 1825
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763)+SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1GZ + i] = FOsum[i] + EZ_FO_FAsum[i] }

    /// Harm el cons outside of harm op period
    let daily1HA = 2190
    // SUMIFS(CalculationFA5:FA8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { daily16[daily1HA + i] = EZ_EX_FAsum[i] }

    let EYsum = hourly4.sum(days: daysEZ, range: hourlyEY) 
    let EZ_EX_FBsum = hourly4.sumOf(hourlyFB, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Harm heat cons considering min harm op during harm op period
    let daily1HB = 2555
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEY5:EY8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HB + i] = EYsum[i] + EZ_EX_FBsum[i] }

    let FPsum = hourly4.sum(days: daysEZ, range: hourlyFP) 
    let EZ_FO_FBsum = hourly4.sumOf(hourlyFB, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// Harm heat cons considering max harm op during harm op period
    let daily1HC = 2920
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFP5:FP8763)+SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HC + i] = FPsum[i] + EZ_FO_FBsum[i] }

    /// Harm heat cons outside of harm op period
    let daily1HD = 3285
    // SUMIFS(CalculationFB5:FB8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0")
    for i in 0..<365 { daily16[daily1HD + i] = EZ_EX_FBsum[i] }

    let EZ_EX_FEsum = hourly4.sumOf(hourlyFE, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Grid import considering min harm op during harm op period
    let daily1HE = 3650
    // SUMIFS(CalculationFE5:FE8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HE + i] = EZ_EX_FEsum[i] }

    let EZ_FO_FSsum = hourly4.sumOf(hourlyFS, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// Grid import considering max harm op during harm op period
    let daily1HF = 4015
    // SUMIFS(CalculationFS5:FS8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HF + i] = EZ_FO_FSsum[i] }

    let FEsum = hourly4.sum(days: daysEZ, range: hourlyFE) 
    /// Grid import  outside of harm op period
    let daily1HG = 4380
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFE5:FE8763)-HE6
    for i in 0..<365 { daily16[daily1HG + i] = FEsum[i] - daily11[daily1HE + i] }

    let EZ_EX_FGsum = hourly4.sumOf(hourlyFG, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// El boiler op considering min harm op during harm op period
    let daily1HH = 4745
    // SUMIFS(CalculationFG5:FG8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HH + i] = EZ_EX_FGsum[i] }

    let EZ_FO_FUsum = hourly4.sumOf(hourlyFU, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// El boiler op considering max harm op during harm op period
    let daily1HI = 5110
    // SUMIFS(CalculationFU5:FU8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HI + i] = EZ_FO_FUsum[i] }

    let FGsum = hourly4.sum(days: daysEZ, range: hourlyFG) 
    /// El boiler op outside harm op period
    let daily1HJ = 5475
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFG5:FG8763)-HH6
    for i in 0..<365 { daily16[daily1HJ + i] = FGsum[i] - daily16[daily1HH + i] }
    let EZ_EX_ETsum = hourly4.sumOf(hourlyET, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Total aux cons during harm op period
    let daily1HK = 5840
    // SUMIFS(CalculationET5:ET8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HK + i] = EZ_EX_ETsum[i] }

    let ETsum = hourly4.sum(days: daysEZ, range: hourlyET) 
    /// Total aux cons outside of harm op period
    let daily1HL = 6205
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationET5:ET8763)-HK6
    for i in 0..<365 { daily16[daily1HL + i] = ETsum[i] - daily16[daily1HK + i] }

    let EZ_EX_EUsum = hourly4.sumOf(hourlyEU, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// El cons not covered during harm op period
    let daily1HM = 6570
    // SUMIFS(CalculationEU5:EU8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HM + i] = EZ_EX_EUsum[i] }

    let EUsum = hourly4.sum(days: daysEZ, range: hourlyEU) 
    /// El cons not covered outside of harm op period
    let daily1HN = 6935
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationEU5:EU8763)-HM6
    for i in 0..<365 { daily16[daily1HN + i] = EUsum[i] - daily11[daily1HM + i] }

    let EZ_EX_FCsum = hourly4.sumOf(hourlyFC, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Remaining PV el after TES chrg& min harm&aux during harm op period
    let daily1HO = 7300
    // SUMIFS(CalculationFC5:FC8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HO + i] = EZ_EX_FCsum[i] }

    let EZ_FO_FQsum = hourly4.sumOf(hourlyFQ, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// Remaining PV el after TES chrg& max harm&aux during harm op period
    let daily1HP = 7665
    // SUMIFS(CalculationFQ5:FQ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HP + i] = EZ_FO_FQsum[i] }

    let FCsum = hourly4.sum(days: daysEZ, range: hourlyFC) 
    /// Remaining PV el outside of harm op period
    let daily1HQ = 8030
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFC5:FC8763)-HO6
    for i in 0..<365 { daily16[daily1HQ + i] = FCsum[i] - daily11[daily1HO + i] }

    let EZ_EX_FDsum = hourly4.sumOf(hourlyFD, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Remaining CSP heat after min harm during harm op period
    let daily1HR = 8395
    // SUMIFS(CalculationFD5:FD8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HR + i] = EZ_EX_FDsum[i] }

    let EZ_FO_FRsum = hourly4.sumOf(hourlyFR, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// Remaining CSP heat after max harm op during harm op period
    let daily1HS = 8760
    // SUMIFS(CalculationFR5:FR8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HS + i] = EZ_FO_FRsum[i] }

    let FDsum = hourly4.sum(days: daysEZ, range: hourlyFD) 
    /// Remaining CSP heat outside of harm op period
    let daily1HT = 9125
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFD5:FD8763)-HR6
    for i in 0..<365 { daily16[daily1HT + i] = FDsum[i] - daily11[daily1HR + i] }

    let EZ_EX_FLsum = hourly4.sumOf(hourlyFL, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Max elec to BESS for night prep after min harm op during harm op period
    let daily1HU = 9490
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily16[daily1HU + i] = min(EZ_EX_FLsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_FO_FZsum = hourly4.sumOf(hourlyFZ, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// Max elec to BESS for night prep after max harm op during harm op period
    let daily1HV = 9855
    // MIN(SUMIFS(CalculationFZ5:FZ8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily16[daily1HV + i] = min(EZ_FO_FZsum[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_EX_FLsumZero = hourly4.sumOf(hourlyFL, days: daysEZ, condition: hourlyEX, predicate: {$0.isZero})
    /// Max elec to BESS for night prep outside of harm op period
    let daily1HW = 10220
    // MIN(SUMIFS(CalculationFL5:FL8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,"=0"),BESS_cap_ud/BESS_chrg_eff)
    for i in 0..<365 { daily16[daily1HW + i] = min(EZ_EX_FLsumZero[i], BESS_cap_ud / BESS_chrg_eff) }

    let EZ_EX_FMsum = hourly4.sumOf(hourlyFM, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Max grid export after min harm cons during harm op period
    let daily1HX = 10585
    // SUMIFS(CalculationFM5:FM8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1HX + i] = EZ_EX_FMsum[i] }

    let EZ_FO_GAsum = hourly4.sumOf(hourlyGA, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// Max grid export after max harm cons during harm op period
    let daily1HY = 10950
    // SUMIFS(CalculationGA5:GA8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1HY + i] = EZ_FO_GAsum[i] }

    let FMsum = hourly4.sum(days: daysEZ, range: hourlyFM) 
    /// Max grid export outside of harm op period
    let daily1HZ = 11315
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFM5:FM8763)-HX6
    for i in 0..<365 { daily16[daily1HZ + i] = FMsum[i] - daily16[daily1HX + i] }

    let EZ_EX_FFsum = hourly4.sumOf(hourlyFF, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Remaining grid import during harm op period after min harm
    let daily1IA = 11680
    // SUMIFS(CalculationFF5:FF8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1IA + i] = EZ_EX_FFsum[i] }

    let EZ_FO_FTsum = hourly4.sumOf(hourlyFT, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// Remaining grid import during harm op period after max harm
    let daily1IB = 12045
    // SUMIFS(CalculationFT5:FT8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1IB + i] = EZ_FO_FTsum[i] }

    let FFsum = hourly4.sum(days: daysEZ, range: hourlyFF) 
    /// Remaining grid import outside of harm op period
    let daily1IC = 12410
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFF5:FF8763)-IA6
    for i in 0..<365 { daily16[daily1IC + i] = FFsum[i] - daily16[daily1IA + i] }

    let EZ_EX_FHsum = hourly4.sumOf(hourlyFH, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Remaining El boiler cap during harm op period after min harm
    let daily1ID = 12775
    // SUMIFS(CalculationFH5:FH8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1ID + i] = EZ_EX_FHsum[i] }

    let EZ_FO_FVsum = hourly4.sumOf(hourlyFV, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// Remaining El boiler cap during harm op period after max harm
    let daily1IE = 13140
    // SUMIFS(CalculationFV5:FV8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1IE + i] = EZ_FO_FVsum[i] }

    let FHsum = hourly4.sum(days: daysEZ, range: hourlyFH) 
    /// Remaining El boiler cap outside of harm op period
    let daily1IF = 13505
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFH5:FH8763)-ID6
    for i in 0..<365 { daily16[daily1IF + i] = FHsum[i] - daily16[daily1ID + i] }

    let EZ_EX_FIsum = hourly4.sumOf(hourlyFI, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Remaining MethSynt cap during harm op after min harm op
    let daily1IG = 13870
    // SUMIFS(CalculationFI5:FI8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1IG + i] = EZ_EX_FIsum[i] }

    let EZ_FO_FWsum = hourly4.sumOf(hourlyFW, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// Remaining MethSynt cap during harm op period after max harm op
    let daily1IH = 14235
    // SUMIFS(CalculationFW5:FW8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1IH + i] = EZ_FO_FWsum[i] }

    let FIsum = hourly4.sum(days: daysEZ, range: hourlyFI) 
    /// Remaining MethSynt cap outside of harm op period
    let daily1II = 14600
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFI5:FI8763)-IG6
    for i in 0..<365 { daily16[daily1II + i] = FIsum[i] - daily16[daily1IG + i] }

    let EZ_EX_FJsum = hourly4.sumOf(hourlyFJ, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Remaining CCU cap during harm op after min harm
    let daily1IJ = 14965
    // SUMIFS(CalculationFJ5:FJ8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1IJ + i] = EZ_EX_FJsum[i] }

    let EZ_FO_FXsum = hourly4.sumOf(hourlyFX, days: daysEZ, condition: hourlyFO, predicate: {$0>0})  
    /// Remaining CCU cap during harm op after max harm
    let daily1IK = 15330
    // SUMIFS(CalculationFX5:FX8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1IK + i] = EZ_FO_FXsum[i] }

    let FJsum = hourly4.sum(days: daysEZ, range: hourlyFJ) 
    /// Remaining CCU cap outside of harm op after min harm
    let daily1IL = 15695
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFJ5:FJ8763)-IJ6
    for i in 0..<365 { daily16[daily1IL + i] = FJsum[i] - daily16[daily1IJ + i] }

    let EZ_EX_FKsum = hourly4.sumOf(hourlyFK, days: daysEZ, condition: hourlyEX, predicate: {$0>0})
    /// Remaining EY cap during harm op after min harm
    let daily1IM = 16060
    // SUMIFS(CalculationFK5:FK8763,CalculationEZ5:EZ8763,"="A6,CalculationEX5:EX8763,">0")
    for i in 0..<365 { daily16[daily1IM + i] = EZ_EX_FKsum[i] }

    let EZ_FO_FYsum = hourly4.sumOf(hourlyFY, days: daysEZ, condition: hourlyFO, predicate: {$0>0})
    /// Remaining EY cap during harm op period after max harm
    let daily1IN = 16425
    // SUMIFS(CalculationFY5:FY8763,CalculationEZ5:EZ8763,"="A6,CalculationFO5:FO8763,">0")
    for i in 0..<365 { daily16[daily1IN + i] = EZ_FO_FYsum[i] }

    let FKsum = hourly4.sum(days: daysEZ, range: hourlyFK) 
    /// Remaining EY cap outside of harm op period
    let daily1IO = 16790
    // SUMIF(CalculationEZ5:EZ8763,"="A6,CalculationFK5:FK8763)-IM6
    for i in 0..<365 { daily16[daily1IO + i] = FKsum[i] - daily16[daily1IM + i] }

    var daily17 = [Double]()

    /// Surplus harm op period electricity after min harm op and min night op prep
    let daily1IQ = 0
    // FS6+GE6-Z6-MAX(0,AB6-FV6)/El_boiler_eff-FR6/BESS_chrg_eff
    for i in 0..<365 {
      daily17[daily1IQ + i] =
        daily15[daily1FS + i] + daily15[daily1GE + i] - daily11[daily1Z + i] - max(
          0, daily10[daily1AB + i] - daily15[daily1FV + i]) / El_boiler_eff - daily15[daily1FR + i]
        / BESS_chrg_eff
    }

    /// Surplus harm op period electricity after min harm op and max night op prep
    let daily1IR = 365
    // HO6+IA6-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff-HN6/BESS_chrg_eff
    for i in 0..<365 {
      daily17[daily1IR + i] =
        daily11[daily1HO + i] + daily16[daily1IA + i]
        - (daily11[daily1Z + i]
          + (daily10[daily1AA + i] - daily11[daily1Z + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
        - max(
          0,
          (daily10[daily1AB + i]
            + (daily11[daily1AC + i] - daily10[daily1AB + i])
              / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
              * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
            - daily11[daily1HR + i]) / El_boiler_eff - daily11[daily1HN + i] / BESS_chrg_eff
    }

    /// Surplus harm op period electricity after max harm op and min night op prep
    let daily1IS = 730
    // FT6+GF6-Z6-MAX(0,AB6-FW6)/El_boiler_eff-FR6/BESS_chrg_eff
    for i in 0..<365 {
      daily17[daily1IS + i] =
        daily15[daily1FT + i] + daily15[daily1GF + i] - daily11[daily1Z + i] - max(
          0, daily10[daily1AB + i] - daily15[daily1FW + i]) / El_boiler_eff - daily15[daily1FR + i]
        / BESS_chrg_eff
    }

    /// Surplus harm op heat+boiler prod after min harm op and min night op prep
    let daily1IT = 1095
    // FV6+MAX(0,FS6+GE6-Z6-FR6/BESS_chrg_eff)*El_boiler_eff-AB6
    for i in 0..<365 {
      daily17[daily1IT + i] =
        daily15[daily1FV + i] + max(
          0,
          daily15[daily1FS + i] + daily15[daily1GE + i] - daily11[daily1Z + i]
            - daily15[daily1FR + i] / BESS_chrg_eff) * El_boiler_eff - daily10[daily1AB + i]
    }

    /// Surplus harm op heat+boiler prod after min harm op and max night op prep
    let daily1IU = 1460
    // HR6+MAX(0,HO6+IA6-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HN6/BESS_chrg_eff)*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1IU + i] =
        daily11[daily1HR + i] + max(
          0,
          daily11[daily1HO + i] + daily16[daily1IA + i]
            - (daily11[daily1Z + i]
              + (daily10[daily1AA + i] - daily11[daily1Z + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
            - daily11[daily1HN + i] / BESS_chrg_eff) * El_boiler_eff
        - (daily10[daily1AB + i]
          + (daily11[daily1AC + i] - daily10[daily1AB + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus harm op heat+boiler prod after max harm op and min night op prep
    let daily1IV = 1825
    // FW6+MAX(0,FT6+GF6-Z6-FR6/BESS_chrg_eff)*El_boiler_eff-AB6
    for i in 0..<365 {
      daily17[daily1IV + i] =
        daily15[daily1FW + i] + max(
          0,
          daily15[daily1FT + i] + daily15[daily1GF + i] - daily11[daily1Z + i]
            - daily15[daily1FR + i] / BESS_chrg_eff) * El_boiler_eff - daily10[daily1AB + i]
    }

    /// Surplus el boiler cap after min harm op and min night op prep
    let daily1IW = 2190
    // GH6-(AB6-FV6)/El_boiler_eff
    for i in 0..<365 {
      daily17[daily1IW + i] =
        daily11[daily1GH + i] - (daily10[daily1AB + i] - daily15[daily1FV + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after min harm op and max night op prep
    let daily1IX = 2555
    // ID6-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HR6)/El_boiler_eff
    for i in 0..<365 {
      daily17[daily1IX + i] =
        daily16[daily1ID + i]
        - ((daily10[daily1AB + i]
          + (daily11[daily1AC + i] - daily10[daily1AB + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
          - daily11[daily1HR + i]) / El_boiler_eff
    }

    /// Surplus el boiler cap after max harm op and min night op prep
    let daily1IY = 2920
    // GI6-(AB6-FW6)/El_boiler_eff
    for i in 0..<365 {
      daily17[daily1IY + i] =
        daily15[daily1GI + i] - (daily10[daily1AB + i] - daily15[daily1FW + i]) / El_boiler_eff
    }

    /// Surplus BESS chrg cap after min harm op and min night op prep
    let daily1IZ = 3285
    // FY6-FR6/BESS_chrg_eff
    for i in 0..<365 {
      daily17[daily1IZ + i] = daily15[daily1FY + i] - daily15[daily1FR + i] / BESS_chrg_eff
    }

    /// Surplus BESS chrg cap after min harm op and max night op prep
    let daily1JA = 3650
    // HU6-HN6/BESS_chrg_eff
    for i in 0..<365 {
      daily17[daily1JA + i] = daily16[daily1HU + i] - daily11[daily1HN + i] / BESS_chrg_eff
    }

    /// Surplus BESS chrg cap after max harm op and min night op prep
    let daily1JB = 4015
    // FZ6-FR6/BESS_chrg_eff
    for i in 0..<365 {
      daily17[daily1JB + i] = daily15[daily1FZ + i] - daily15[daily1FR + i] / BESS_chrg_eff
    }

    /// Surplus RawMeth prod cap after min harm op and min night op prep
    let daily1JC = 4380
    // GK6-AD6
    for i in 0..<365 { daily17[daily1JC + i] = daily15[daily1GK + i] - daily11[daily1AD + i] }

    /// Surplus RawMeth prod cap after min harm op and max night op prep
    let daily1JD = 4745
    // IG6-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1JD + i] =
        daily16[daily1IG + i]
        - (daily11[daily1AD + i]
          + (daily11[daily1AE + i] - daily11[daily1AD + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus RawMeth prod cap after max harm op and min night op prep
    let daily1JE = 5110
    // GL6-AD6
    for i in 0..<365 { daily17[daily1JE + i] = daily11[daily1GL + i] - daily11[daily1AD + i] }

    /// Surplus CO2 prod cap after min harm op and min night op prep
    let daily1JF = 5475
    // GN6-AF6
    for i in 0..<365 { daily17[daily1JF + i] = daily15[daily1GN + i] - daily10[daily1AF + i] }

    /// Surplus CO2 prod cap after min harm op and max night op prep
    let daily1JG = 5840
    // IJ6-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1JG + i] =
        daily16[daily1IJ + i]
        - (daily10[daily1AF + i]
          + (daily11[daily1AG + i] - daily10[daily1AF + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus CO2 prod cap after max harm op and min night op prep
    let daily1JH = 6205
    // GO6-AF6
    for i in 0..<365 { daily17[daily1JH + i] = daily15[daily1GO + i] - daily10[daily1AF + i] }

    /// Surplus H2 prod cap after min harm op and min night op prep
    let daily1JI = 6570
    // GQ6-AH6
    for i in 0..<365 { daily17[daily1JI + i] = daily15[daily1GQ + i] - daily10[daily1AH + i] }

    /// Surplus H2 prod cap after min harm op and max night op prep
    let daily1JJ = 6935
    // IM6-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1JJ + i] =
        daily16[daily1IM + i]
        - (daily10[daily1AH + i]
          + (daily11[daily1AI + i] - daily10[daily1AH + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
    }

    /// Surplus H2 prod cap after max harm op and min night op prep
    let daily1JK = 7300
    // GR6-AH6
    for i in 0..<365 { daily17[daily1JK + i] = daily11[daily1GR + i] - daily10[daily1AH + i] }

    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let daily1JM = 7665
    // IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0),0,MIN(1,IFERROR(IQ6/(IQ6-IS6),1),IFERROR(IT6/(IT6-IV6),1),IFERROR(IW6/(IW6-IY6),1),IFERROR(IZ6/(IZ6-JB6),1),IFERROR(JC6/(JC6-JE6),1),IFERROR(JF6/(JF6-JH6),1),IFERROR(JI6/(JI6-JK6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      daily17[daily1JM + i] = iff(
        or(
          daily11[daily1IQ + i] < 0, daily17[daily1IT + i] < 0, daily17[daily1IW + i] < 0,
          daily17[daily1IZ + i] < 0, daily11[daily1JC + i] < 0, daily11[daily1JF + i] < 0,
          daily11[daily1JI + i] < 0), 0,
        min(
          1, ifFinite(daily11[daily1IQ + i] / (daily11[daily1IQ + i] - daily17[daily1IS + i]), 1),
          ifFinite(daily17[daily1IT + i] / (daily17[daily1IT + i] - daily17[daily1IV + i]), 1),
          ifFinite(daily17[daily1IW + i] / (daily17[daily1IW + i] - daily17[daily1IY + i]), 1),
          ifFinite(daily17[daily1IZ + i] / (daily17[daily1IZ + i] - daily11[daily1JB + i]), 1),
          ifFinite(daily11[daily1JC + i] / (daily11[daily1JC + i] - daily11[daily1JE + i]), 1),
          ifFinite(daily11[daily1JF + i] / (daily11[daily1JF + i] - daily11[daily1JH + i]), 1),
          ifFinite(daily11[daily1JI + i] / (daily11[daily1JI + i] - daily11[daily1JK + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          + Overall_harmonious_min_perc)
    }

    /// Surplus harm op period electricity after opt harmonious and min night op prep
    let daily1JN = 8030
    // IF(JM6=0,0,ROUND((FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-Z6-MAX(0,AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff-FR6/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1JN + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily15[daily1FS + i]
            + (daily15[daily1FT + i] - daily15[daily1FS + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            + (daily15[daily1GE + i]
              + (daily15[daily1GF + i] - daily15[daily1GE + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - daily11[daily1Z + i] - max(
              0,
              daily10[daily1AB + i]
                - (daily15[daily1FV + i]
                  + (daily15[daily1FW + i] - daily15[daily1FV + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff - daily15[daily1FR + i] / BESS_chrg_eff, 5))
    }

    /// Surplus harm op period electricity after opt harmonious and max night op prep
    let daily1JO = 8395
    // IF(JM6=0,0,ROUND((HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff-HN6/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1JO + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily11[daily1HO + i]
            + (daily11[daily1HP + i] - daily11[daily1HO + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            + (daily16[daily1IA + i]
              + (daily16[daily1IB + i] - daily16[daily1IA + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - (daily11[daily1Z + i]
              + (daily10[daily1AA + i] - daily11[daily1Z + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              (daily10[daily1AB + i]
                + (daily11[daily1AC + i] - daily10[daily1AB + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
                - (daily11[daily1HR + i]
                  + (daily11[daily1HS + i] - daily11[daily1HR + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff - daily11[daily1HN + i] / BESS_chrg_eff, 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and min night op prep
    let daily1JP = 8760
    // IF(JM6=0,0,ROUND((FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+MAX(0,(FS6+(FT6-FS6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(GE6+(GF6-GE6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-Z6-FR6/BESS_chrg_eff)*El_boiler_eff-AB6,5))
    for i in 0..<365 {
      daily17[daily1JP + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily15[daily1FV + i]
            + (daily15[daily1FW + i] - daily15[daily1FV + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            + max(
              0,
              (daily15[daily1FS + i]
                + (daily15[daily1FT + i] - daily15[daily1FS + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
                + (daily15[daily1GE + i]
                  + (daily15[daily1GF + i] - daily15[daily1GE + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
                - daily11[daily1Z + i] - daily15[daily1FR + i] / BESS_chrg_eff) * El_boiler_eff
            - daily10[daily1AB + i], 5))
    }

    /// Surplus harm op csp steam+boiler prod cap after opt day harm and max night op prep
    let daily1JQ = 9125
    // IF(JM6=0,0,ROUND((HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+MAX(0,(HO6+(HP6-HO6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))+(IA6+(IB6-IA6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-HN6/BESS_chrg_eff)*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1JQ + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily11[daily1HR + i]
            + (daily11[daily1HS + i] - daily11[daily1HR + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            + max(
              0,
              (daily11[daily1HO + i]
                + (daily11[daily1HP + i] - daily11[daily1HO + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
                + (daily16[daily1IA + i]
                  + (daily16[daily1IB + i] - daily16[daily1IA + i])
                    / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
                - (daily11[daily1Z + i]
                  + (daily10[daily1AA + i] - daily11[daily1Z + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
                - daily11[daily1HN + i] / BESS_chrg_eff) * El_boiler_eff
            - (daily10[daily1AB + i]
              + (daily11[daily1AC + i] - daily10[daily1AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after opt day harm and min night op prep
    let daily1JR = 9490
    // IF(JM6=0,0,ROUND((GH6+(GI6-GH6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-(AB6-(FV6+(FW6-FV6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      daily17[daily1JR + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily11[daily1GH + i]
            + (daily15[daily1GI + i] - daily11[daily1GH + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - (daily10[daily1AB + i]
              - (daily15[daily1FV + i]
                + (daily15[daily1FW + i] - daily15[daily1FV + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (daily11[daily1JM + i] - Overall_harmonious_min_perc)))
              / El_boiler_eff,
          5))
    }

    /// Surplus el boiler cap after opt day harm and max night op prep
    let daily1JS = 9855
    // IF(JM6=0,0,ROUND((ID6+(IE6-ID6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc))-(HR6+(HS6-HR6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      daily17[daily1JS + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily16[daily1ID + i]
            + (daily16[daily1IE + i] - daily16[daily1ID + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - ((daily10[daily1AB + i]
              + (daily11[daily1AC + i] - daily10[daily1AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]))
              - (daily11[daily1HR + i]
                + (daily11[daily1HS + i] - daily11[daily1HR + i])
                  / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (daily11[daily1JM + i] - Overall_harmonious_min_perc)))
              / El_boiler_eff,
          5))
    }

    /// Surplus BESS chrg cap after opt day harm and min night op prep
    let daily1JT = 10220
    // IF(JM6=0,0,ROUND((FY6+(FZ6-FY6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-FR6/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1JT + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily15[daily1FY + i]
            + (daily15[daily1FZ + i] - daily15[daily1FY + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - daily15[daily1FR + i] / BESS_chrg_eff, 5))
    }

    /// Surplus BESS chrg cap after opt day harm and max night op prep
    let daily1JU = 10585
    // IF(JM6=0,0,ROUND((HU6+(HV6-HU6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-HN6/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1JU + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily16[daily1HU + i]
            + (daily11[daily1HV + i] - daily16[daily1HU + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - daily11[daily1HN + i] / BESS_chrg_eff, 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let daily1JV = 10950
    // IF(JM6=0,0,ROUND((GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AD6,5))
    for i in 0..<365 {
      daily17[daily1JV + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily15[daily1GK + i]
            + (daily11[daily1GL + i] - daily15[daily1GK + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - daily11[daily1AD + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let daily1JW = 11315
    // IF(JM6=0,0,ROUND(GK6+(GL6-GK6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1JW + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          daily15[daily1GK + i] + (daily11[daily1GL + i] - daily15[daily1GK + i])
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (daily11[daily1JM + i] - Overall_harmonious_min_perc)
            - (daily11[daily1AD + i]
              + (daily11[daily1AE + i] - daily11[daily1AD + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let daily1JX = 11680
    // IF(JM6=0,0,ROUND((GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AF6,5))
    for i in 0..<365 {
      daily17[daily1JX + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          (daily15[daily1GN + i]
            + (daily15[daily1GO + i] - daily15[daily1GN + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1JM + i] - Overall_harmonious_min_perc))
            - daily10[daily1AF + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let daily1JY = 12045
    // IF(JM6=0,0,ROUND(GN6+(GO6-GN6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1JY + i] = iff(
        daily11[daily1JM + i].isZero, 0,
        round(
          daily15[daily1GN + i] + (daily15[daily1GO + i] - daily15[daily1GN + i])
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (daily11[daily1JM + i] - Overall_harmonious_min_perc)
            - (daily10[daily1AF + i]
              + (daily11[daily1AG + i] - daily10[daily1AF + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let daily1JZ = 12410
    // IF(JM6=0,0,ROUND((GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))-AH6,5))
    for i in 0..<365 {
      daily17[daily1JZ + i] = iff(
        daily17[daily1JM + i].isZero, 0,
        round(
          (daily11[daily1GQ + i]
            + (daily11[daily1GR + i] - daily11[daily1GQ + i])
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
            - daily10[daily1AH + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let daily1KA = 12775
    // IF(JM6=0,0,ROUND(GQ6+(GR6-GQ6)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(AM6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KA + i] = iff(
        daily17[daily1JM + i].isZero, 0,
        round(
          daily11[daily1GQ + i] + (daily11[daily1GR + i] - daily11[daily1GQ + i])
            / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (daily17[daily1JM + i] - Overall_harmonious_min_perc)
            - (daily10[daily1AH + i]
              + (daily10[daily1AI + i] - daily10[daily1AH + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt night prep during day prio operation
    let daily1KB = 13140
    // IF(OR(JM6=0,JN6<0,JP6<0,JR6<0,JT6<0,JV6<0,JX6<0,JZ6<0),0,MIN(1,IFERROR(JN6/(JN6-JO6),1),IFERROR(JP6/(JP6-JQ6),1),IFERROR(JR6/(JR6-JS6),1),IFERROR(JT6/(JT6-JU6),1),IFERROR(JV6/(JV6-JW6),1),IFERROR(JX6/(JX6-JY6),1),IFERROR(JZ6/(JZ6-KA6),1))*(AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily17[daily1KB + i] = iff(
        or(
          daily17[daily1JM + i].isZero, daily11[daily1JN + i] < 0, daily11[daily1JP + i] < 0,
          daily17[daily1JR + i] < 0, daily11[daily1JT + i] < 0, daily17[daily1JV + i] < 0,
          daily11[daily1JX + i] < 0, daily17[daily1JZ + i] < 0), 0,
        min(
          1, ifFinite(daily11[daily1JN + i] / (daily11[daily1JN + i] - daily17[daily1JO + i]), 1),
          ifFinite(daily11[daily1JP + i] / (daily11[daily1JP + i] - daily11[daily1JQ + i]), 1),
          ifFinite(daily17[daily1JR + i] / (daily17[daily1JR + i] - daily11[daily1JS + i]), 1),
          ifFinite(daily11[daily1JT + i] / (daily11[daily1JT + i] - daily11[daily1JU + i]), 1),
          ifFinite(daily17[daily1JV + i] / (daily17[daily1JV + i] - daily11[daily1JW + i]), 1),
          ifFinite(daily11[daily1JX + i] / (daily11[daily1JX + i] - daily11[daily1JY + i]), 1),
          ifFinite(daily17[daily1JZ + i] / (daily17[daily1JZ + i] - daily11[daily1KA + i]), 1))
          * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// min harmonious day prod after opt equiv harmonious night prod due to prod cap limits
    let daily1KD = 13505
    // IF(OR(IQ6<0,IT6<0,IW6<0,IZ6<0,JC6<0,JF6<0,JI6<0),0,MIN(1,IFERROR(IQ6/(IQ6-IR6),1),IFERROR(IT6/(IT6-IU6),1),IFERROR(IW6/(IW6-IX6),1),IFERROR(IZ6/(IZ6-JA6),1),IFERROR(JC6/(JC6-JD6),1),IFERROR(JF6/(JF6-JG6),1),IFERROR(JI6/(JI6-JJ6),1))*(AM6-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      daily17[daily1KD + i] = iff(
        or(
          daily11[daily1IQ + i] < 0, daily11[daily1IT + i] < 0, daily17[daily1IW + i] < 0,
          daily11[daily1IZ + i] < 0, daily11[daily1JC + i] < 0, daily11[daily1JF + i] < 0,
          daily11[daily1JI + i] < 0), 0,
        min(
          1, ifFinite(daily11[daily1IQ + i] / (daily11[daily1IQ + i] - daily11[daily1IR + i]), 1),
          ifFinite(daily11[daily1IT + i] / (daily11[daily1IT + i] - daily11[daily1IU + i]), 1),
          ifFinite(daily17[daily1IW + i] / (daily17[daily1IW + i] - daily11[daily1IX + i]), 1),
          ifFinite(daily11[daily1IZ + i] / (daily11[daily1IZ + i] - daily11[daily1JA + i]), 1),
          ifFinite(daily11[daily1JC + i] / (daily11[daily1JC + i] - daily11[daily1JD + i]), 1),
          ifFinite(daily11[daily1JF + i] / (daily11[daily1JF + i] - daily17[daily1JG + i]), 1),
          ifFinite(daily11[daily1JI + i] / (daily11[daily1JI + i] - daily17[daily1JJ + i]), 1))
          * (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) + equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period electricity after min day harmonious and opti night op prep
    let daily1KE = 13870
    // IF(KD6=0,0,ROUND((FS6+(HO6-FS6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1KE + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FS + i]
            + (daily16[daily1HO + i] - daily15[daily1FS + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            + (daily15[daily1GE + i]
              + (daily11[daily1IA + i] - daily15[daily1GE + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily11[daily1Z + i]
              + (daily10[daily1AA + i] - daily11[daily1Z + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              (daily10[daily1AB + i]
                + (daily10[daily1AC + i] - daily10[daily1AB + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily15[daily1FV + i]
                  + (daily16[daily1HR + i] - daily15[daily1FV + i])
                    / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            ) / El_boiler_eff
            - (daily15[daily1FR + i]
              + (daily16[daily1HN + i] - daily15[daily1FR + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus harm op period electricity after max day harmonious and opti night op prep
    let daily1KF = 14235
    // IF(KD6=0,0,ROUND((FT6+(HP6-FT6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-MAX(0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1KF + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FT + i]
            + (daily16[daily1HP + i] - daily15[daily1FT + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            + (daily15[daily1GF + i]
              + (daily11[daily1IB + i] - daily15[daily1GF + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily11[daily1Z + i]
              + (daily10[daily1AA + i] - daily11[daily1Z + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              (daily10[daily1AB + i]
                + (daily10[daily1AC + i] - daily10[daily1AB + i])
                  / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily15[daily1FW + i]
                  + (daily11[daily1HS + i] - daily15[daily1FW + i])
                    / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            ) / El_boiler_eff
            - (daily15[daily1FR + i]
              + (daily16[daily1HN + i] - daily15[daily1FR + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after min day harmonious and opti night op prep
    let daily1KG = 14600
    // IF(KD6=0,0,ROUND((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(MAX(0,(FS6+(HO6-FS6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff)))*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KG + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FV + i]
            + (daily16[daily1HR + i] - daily15[daily1FV + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            + (max(
              0,
              (daily15[daily1FS + i]
                + (daily16[daily1HO + i] - daily15[daily1FS + i])
                  / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                + (daily15[daily1GE + i]
                  + (daily11[daily1IA + i] - daily15[daily1GE + i])
                    / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily11[daily1Z + i]
                  + (daily10[daily1AA + i] - daily11[daily1Z + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - ((daily15[daily1FR + i]
                  + (daily16[daily1HN + i] - daily15[daily1FR + i])
                    / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                  / BESS_chrg_eff))) * El_boiler_eff
            - (daily10[daily1AB + i]
              + (daily10[daily1AC + i] - daily10[daily1AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus harmonious op csp steam+boiler prod cap after max day harmonious and opti night op prep
    let daily1KH = 14965
    // IF(KD6=0,0,ROUND((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(MAX(0,(FT6+(HP6-FT6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+(GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff)))*El_boiler_eff-(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KH + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FW + i]
            + (daily11[daily1HS + i] - daily15[daily1FW + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            + (max(
              0,
              (daily15[daily1FT + i]
                + (daily16[daily1HP + i] - daily15[daily1FT + i])
                  / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                + (daily15[daily1GF + i]
                  + (daily11[daily1IB + i] - daily15[daily1GF + i])
                    / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily11[daily1Z + i]
                  + (daily10[daily1AA + i] - daily11[daily1Z + i])
                    / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - ((daily15[daily1FR + i]
                  + (daily16[daily1HN + i] - daily15[daily1FR + i])
                    / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                  / BESS_chrg_eff))) * El_boiler_eff
            - (daily10[daily1AB + i]
              + (daily10[daily1AC + i] - daily10[daily1AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus el boiler cap after min day harmonious and opti night op prep
    let daily1KI = 15330
    // IF(KD6=0,0,ROUND((GH6+(ID6-GH6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      daily17[daily1KI + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily11[daily1GH + i]
            + (daily11[daily1ID + i] - daily11[daily1GH + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - ((daily10[daily1AB + i]
              + (daily10[daily1AC + i] - daily10[daily1AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              - (daily15[daily1FV + i]
                + (daily16[daily1HR + i] - daily15[daily1FV + i])
                  / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
              / El_boiler_eff,
          5))
    }

    /// Surplus el boiler cap after max day harmonious and opti night op prep
    let daily1KJ = 15695
    // IF(KD6=0,0,ROUND((GI6+(IE6-GI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-((AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      daily17[daily1KJ + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1GI + i]
            + (daily11[daily1IE + i] - daily15[daily1GI + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - ((daily10[daily1AB + i]
              + (daily10[daily1AC + i] - daily10[daily1AB + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              - (daily15[daily1FW + i]
                + (daily11[daily1HS + i] - daily15[daily1FW + i])
                  / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
              / El_boiler_eff,
          5))
    }

    /// Surplus BESS cap after min day harmonious and opti night op prep
    let daily1KK = 16060
    // IF(KD6=0,0,ROUND((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1KK + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FY + i]
            + (daily16[daily1HU + i] - daily15[daily1FY + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FR + i]
              + (daily16[daily1HN + i] - daily15[daily1FR + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus BESS cap after max day harmonious and opti night op prep
    let daily1KL = 16425
    // IF(KD6=0,0,ROUND((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff,5))
    for i in 0..<365 {
      daily17[daily1KL + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1FZ + i]
            + (daily16[daily1HV + i] - daily15[daily1FZ + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FR + i]
              + (daily16[daily1HN + i] - daily15[daily1FR + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              / BESS_chrg_eff,
          5))
    }

    /// Surplus RawMeth prod cap after min day harmonious and opti night op prep
    let daily1KM = 16790
    // IF(KD6=0,0,ROUND((GK6+(IG6-GK6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KM + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily11[daily1GK + i]
            + (daily11[daily1IG + i] - daily11[daily1GK + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AD + i]
              + (daily10[daily1AE + i] - daily10[daily1AD + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus RawMeth prod cap after max day harmonious and opti night op prep
    let daily1KN = 17155
    // IF(KD6=0,0,ROUND((GL6+(IH6-GL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AD6+(AE6-AD6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KN + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1GL + i]
            + (daily11[daily1IH + i] - daily15[daily1GL + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AD + i]
              + (daily10[daily1AE + i] - daily10[daily1AD + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after min day harmonious and opti night op prep
    let daily1KO = 17520
    // IF(KD6=0,0,ROUND((GN6+(IJ6-GN6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KO + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1GN + i]
            + (daily11[daily1IJ + i] - daily15[daily1GN + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AF + i]
              + (daily10[daily1AG + i] - daily10[daily1AF + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after max day harmonious and opti night op prep
    let daily1KP = 17885
    // IF(KD6=0,0,ROUND((GO6+(IK6-GO6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AF6+(AG6-AF6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KP + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily15[daily1GO + i]
            + (daily11[daily1IK + i] - daily15[daily1GO + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AF + i]
              + (daily10[daily1AG + i] - daily10[daily1AF + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harmonious and opti night op prep
    let daily1KQ = 18250
    // IF(KD6=0,0,ROUND((GQ6+(IM6-GQ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KQ + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily11[daily1GQ + i]
            + (daily11[daily1IM + i] - daily11[daily1GQ + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AH + i]
              + (daily10[daily1AI + i] - daily10[daily1AH + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after max day harmonious and opti night op prep
    let daily1KR = 18615
    // IF(KD6=0,0,ROUND((GR6+(IN6-GR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(AH6+(AI6-AH6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      daily17[daily1KR + i] = iff(
        daily11[daily1KD + i].isZero, 0,
        round(
          (daily11[daily1GR + i]
            + (daily11[daily1IN + i] - daily11[daily1GR + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily10[daily1AH + i]
              + (daily10[daily1AI + i] - daily10[daily1AH + i])
                / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt harm op period op during night prio operation
    let daily1KS = 18980
    // IF(KD6<=0,0,MIN(1,IFERROR(KE6/(KE6-KF6),1),IFERROR(KG6/(KG6-KH6),1),IFERROR(KI6/(KI6-KJ6),1),IFERROR(KK6/(KK6-KL6),1),IFERROR(KM6/(KM6-KN6),1),IFERROR(KO6/(KO6-KP6),1),IFERROR(KQ6/(KQ6-KR6),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      daily17[daily1KS + i] = iff(
        daily11[daily1KD + i] <= 0, 0,
        min(
          1, ifFinite(daily11[daily1KE + i] / (daily11[daily1KE + i] - daily11[daily1KF + i]), 1),
          ifFinite(daily17[daily1KG + i] / (daily17[daily1KG + i] - daily11[daily1KH + i]), 1),
          ifFinite(daily11[daily1KI + i] / (daily11[daily1KI + i] - daily11[daily1KJ + i]), 1),
          ifFinite(daily11[daily1KK + i] / (daily11[daily1KK + i] - daily11[daily1KL + i]), 1),
          ifFinite(daily17[daily1KM + i] / (daily17[daily1KM + i] - daily11[daily1KN + i]), 1),
          ifFinite(daily11[daily1KO + i] / (daily11[daily1KO + i] - daily11[daily1KP + i]), 1),
          ifFinite(daily11[daily1KQ + i] / (daily11[daily1KQ + i] - daily11[daily1KR + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          + Overall_harmonious_min_perc)
    }

    /// el cons for harm op during harm op period
    let daily1KU = 19345
    // IF(OR(JM6=0,KB6=0),0,(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FD6+(GZ6-FD6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1KU + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily15[daily1FC + i]
          + (daily16[daily1GY + i] - daily15[daily1FC + i])
            / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FD + i]
            + (daily11[daily1GZ + i] - daily15[daily1FD + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FC + i]
              + (daily16[daily1GY + i] - daily15[daily1FC + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let daily1KV = 19710
    // IF(OR(JM6=0,KB6=0),0,(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1KV + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily11[daily1Z + i]
          + (daily10[daily1AA + i] - daily11[daily1Z + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el to cover aux cons during harm op period
    let daily1KW = 20075
    // IF(OR(JM6=0,KB6=0),0,FO6+(HK6-FO6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1KW + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FO + i] + (daily16[daily1HK + i] - daily15[daily1FO + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for BESS charging during harm op period
    let daily1KX = 20440
    // IF(OR(JM6=0,KB6=0),0,MIN(((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      daily17[daily1KX + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        min(
          ((daily15[daily1FY + i]
            + (daily16[daily1HU + i] - daily15[daily1FY + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            + ((daily15[daily1FZ + i]
              + (daily16[daily1HV + i] - daily15[daily1FZ + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
              - (daily15[daily1FY + i]
                + (daily16[daily1HU + i] - daily15[daily1FY + i])
                  / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily17[daily1JM + i] - Overall_harmonious_min_perc)),
          (daily15[daily1FR + i]
            + (daily16[daily1HN + i] - daily15[daily1FR + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    let daily1KY = 20805
    // IF(OR(JM6=0,KB6=0),0,(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1KY + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily15[daily1FL + i]
          + (daily16[daily1HH + i] - daily15[daily1FL + i])
            / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FM + i]
            + (daily16[daily1HI + i] - daily15[daily1FM + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FL + i]
              + (daily16[daily1HH + i] - daily15[daily1FL + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
    }

    /// el cons for el boiler op for night prep during harm op period
    let daily1KZ = 21170
    // LH6/El_boiler_eff
    // for i in 0..<365 { daily17[daily1KZ + i] = daily11[daily1LH + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let daily1LA = 21535
    // IF(OR(JM6=0,KB6=0),0,EY6+(GU6-EY6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LA + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily11[daily1EY + i] + (daily16[daily1GU + i] - daily11[daily1EY + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import for harm op during harm op period
    let daily1LB = 21900
    // IF(OR(JM6=0,KB6=0),0,(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LB + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily15[daily1FI + i]
          + (daily16[daily1HE + i] - daily15[daily1FI + i])
            / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FJ + i]
            + (daily11[daily1HF + i] - daily15[daily1FJ + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FI + i]
              + (daily16[daily1HE + i] - daily15[daily1FI + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let daily1LC = 22265
    // IF(OR(JM6=0,KB6=0),0,MIN((GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc),MAX(0,-(LA6+LB6-KU6-KV6-KW6-KX6-KY6-KZ6))))
    // for i in 0..<365 {
    //   daily17[daily1LC + i] = iff(
    //   or(
    //  daily17[daily1JM + i]=0,daily11[daily1KB + i]=0),0, min((daily15[daily1GE + i] + (daily11[daily1IA + i] - daily15[daily1GE + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])) + ((daily15[daily1GF + i] + (daily11[daily1IB + i] - daily15[daily1GF + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])) - (daily15[daily1GE + i] + (daily11[daily1IA + i] - daily15[daily1GE + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily17[daily1JM + i] - Overall_harmonious_min_perc),max(0, - (daily11[daily1LA + i] + daily11[daily1LB + i] - daily11[daily1KU + i] - daily11[daily1KV + i] - daily11[daily1KW + i] - daily17[daily1KX + i] - daily17[daily1KY + i] - daily11[daily1KZ + i]))))
    // }

    /// Balance of electricity during harm op period
    let daily1LD = 22630
    // LA6+LB6+LC6-KU6-KV6-KW6-KX6-KY6-KZ6
    for i in 0..<365 {
      daily17[daily1LD + i] =
        daily11[daily1LA + i] + daily11[daily1LB + i] + daily11[daily1LC + i]
        - daily11[daily1KU + i] - daily11[daily1KV + i] - daily11[daily1KW + i]
        - daily17[daily1KX + i] - daily17[daily1KY + i] - daily11[daily1KZ + i]
    }

    /// heat cons for harm op during harm op period
    let daily1LE = 22995
    // IF(OR(JM6=0,KB6=0),0,(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LE + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily15[daily1FF + i]
          + (daily16[daily1HB + i] - daily15[daily1FF + i])
            / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FG + i]
            + (daily11[daily1HC + i] - daily15[daily1FG + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FF + i]
              + (daily16[daily1HB + i] - daily15[daily1FF + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for night prep during harm op period
    let daily1LF = 23360
    // IF(OR(JM6=0,KB6=0),0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1LF + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        (daily10[daily1AB + i]
          + (daily10[daily1AC + i] - daily10[daily1AB + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// heat prod by el boiler for harm op during harm op period
    let daily1LG = 23725
    // IF(OR(JM6=0,KB6=0),0,KY6*El_boiler_eff)
    for i in 0..<365 {
      daily17[daily1LG + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily17[daily1KY + i] * El_boiler_eff)
    }

    /// heat prod by el boiler for night prep during harm op period
    let daily1LH = 24090
    // IF(OR(JM6=0,KB6=0),0,MAX(0,LF6-((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      daily17[daily1LH + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        max(
          0,
          daily11[daily1LF + i]
            - ((daily15[daily1FV + i]
              + (daily16[daily1HR + i] - daily15[daily1FV + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
              + ((daily15[daily1FW + i]
                + (daily11[daily1HS + i] - daily15[daily1FW + i])
                  / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
                - (daily15[daily1FV + i]
                  + (daily16[daily1HR + i] - daily15[daily1FV + i])
                    / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (daily17[daily1JM + i] - Overall_harmonious_min_perc))
        ))
    }

    /// Heat available during harm op period after TES chrg
    let daily1LI = 24455
    // IF(OR(JM6=0,KB6=0),0,FA6+(GW6-FA6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LI + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily11[daily1FA + i] + (daily11[daily1GW + i] - daily11[daily1FA + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat during harm op period
    let daily1LJ = 24820
    // LG6+LH6+LI6-LE6-LF6
    for i in 0..<365 {
      daily17[daily1LJ + i] =
        daily11[daily1LG + i] + daily11[daily1LH + i] + daily11[daily1LI + i]
        - daily11[daily1LE + i] - daily11[daily1LF + i]
    }

    /// el cons for harm op outside of harm op period
    let daily1LK = 25185
    // IF(OR(JM6=0,KB6=0),0,FE6+(HA6-FE6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LK + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FE + i] + (daily11[daily1HA + i] - daily15[daily1FE + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el to cover aux cons outside of harm op period
    let daily1LL = 25550
    // IF(OR(JM6=0,KB6=0),0,FP6+(HL6-FP6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LL + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FP + i] + (daily11[daily1HL + i] - daily15[daily1FP + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for el boiler for harm op outside of harm op period
    let daily1LM = 25915
    // IF(OR(JM6=0,KB6=0),0,FN6+(HJ6-FN6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LM + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FN + i] + (daily11[daily1HJ + i] - daily15[daily1FN + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// el from BESS discharging outside of harm op period
    let daily1LN = 26280
    // KX6*BESS_chrg_eff
    for i in 0..<365 { daily17[daily1LN + i] = daily17[daily1KX + i] * BESS_chrg_eff }

    /// El available outside of harm op period after TES chrg
    let daily1LO = 26645
    // IF(OR(JM6=0,KB6=0),0,EZ6+(GV6-EZ6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LO + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily11[daily1EZ + i] + (daily11[daily1GV + i] - daily11[daily1EZ + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import needed outside of harm op period
    let daily1LP = 27010
    // IF(OR(JM6=0,KB6=0),0,MIN(GG6+(IC6-GG6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc),MAX(0,-(LN6+LO6-LK6-LL6-LM6))))
    // for i in 0..<365 {
    //   daily17[daily1LP + i] = iff(
    //   or(
    //  daily17[daily1JM + i]=0,daily11[daily1KB + i]=0),0, min(daily15[daily1GG + i] + (daily11[daily1IC + i] - daily15[daily1GG + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]),max(0, - (daily17[daily1LN + i] + daily11[daily1LO + i] - daily11[daily1LK + i] - daily11[daily1LL + i] - daily11[daily1LM + i]))))
    // }

    /// Balance of electricity outside of harm op period
    let daily1LQ = 27375
    // LN6+LO6+LP6-LK6-LL6-LM6
    for i in 0..<365 {
      daily17[daily1LQ + i] =
        daily17[daily1LN + i] + daily11[daily1LO + i] + daily11[daily1LP + i]
        - daily11[daily1LK + i] - daily11[daily1LL + i] - daily11[daily1LM + i]
    }

    /// heat cons for harm op outside of harm op period
    let daily1LR = 27740
    // IF(OR(JM6=0,KB6=0),0,FH6+(HD6-FH6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LR + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FH + i] + (daily11[daily1HD + i] - daily15[daily1FH + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat prod by el boiler for harm op outside of harm op period
    let daily1LS = 28105
    // IF(OR(JM6=0,KB6=0),0,LM6*El_boiler_eff)
    for i in 0..<365 {
      daily17[daily1LS + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily11[daily1LM + i] * El_boiler_eff)
    }

    /// Heat available outside of harm op period after TES chrg
    let daily1LT = 28470
    // IF(OR(JM6=0,KB6=0),0,FB6+(GX6-FB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1LT + i] = iff(
        or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
        daily15[daily1FB + i] + (daily11[daily1GX + i] - daily15[daily1FB + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat outside of harm op period
    let daily1LU = 28835
    // LS6+LT6-LR6
    for i in 0..<365 {
      daily17[daily1LU + i] = daily17[daily1LS + i] + daily11[daily1LT + i] - daily11[daily1LR + i]
    }

    /// Pure Methanol prod with day priority and resp night op
    let daily1LV = 29200
    // IF(KU6<=0,0,KU6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(LK6<=0,0,(LK6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      daily17[daily1LV + i] =
        iff(
          daily11[daily1KU + i] <= 0, 0,
          daily11[daily1KU + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud)
        + iff(
          daily11[daily1LK + i] <= 0, 0,
          (daily11[daily1LK + i] - overall_stup_cons[j])
            / (overall_var_max_cons[j] + overall_fix_stby_cons[j]) * MethDist_max_perc[j]
            * MethDist_Meth_nom_prod_ud)
    }

    /// grid export
    let daily1LW = 29565
    // MIN(LD6,IF(OR(JM6=0,KB6=0),0,(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))+((GC6+(HY6-GC6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(JM6-Overall_harmonious_min_perc)))+MIN(LQ6,IF(OR(JM6=0,KB6=0),0,GD6+(HZ6-GD6)/(AM6-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1LW + i] =
        min(
          daily11[daily1LD + i],
          iff(
            or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
            (daily11[daily1GB + i]
              + (daily16[daily1HX + i] - daily11[daily1GB + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
              + ((daily11[daily1GC + i]
                + (daily11[daily1HY + i] - daily11[daily1GC + i])
                  / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
                - (daily11[daily1GB + i]
                  + (daily16[daily1HX + i] - daily11[daily1GB + i])
                    / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily17[daily1JM + i] - Overall_harmonious_min_perc)))
        + min(
          daily17[daily1LQ + i],
          iff(
            or(daily17[daily1JM + i].isZero, daily11[daily1KB + i].isZero), 0,
            daily15[daily1GD + i] + (daily16[daily1HZ + i] - daily15[daily1GD + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j])))
    }

    /// Grid import
    let daily1LX = 29930
    // LP6+LC6
    for i in 0..<365 { daily17[daily1LX + i] = daily11[daily1LP + i] + daily11[daily1LC + i] }

    /// Outside harmonious operation period hours
    let daily1LY = 30295
    // IF(KB6<=0,0,(C6+(T6-C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1LY + i] = iff(
        daily11[daily1KB + i] <= 0, 0,
        (daily11[daily1C + i]
          + (daily11[daily1T + i] - daily11[daily1C + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Harmonious operation period hours
    let daily1LZ = 30660
    // IF(KB6<=0,0,(D6+(U6-D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1LZ + i] = iff(
        daily11[daily1KB + i] <= 0, 0,
        (daily11[daily1D + i]
          + (daily11[daily1U + i] - daily11[daily1D + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// PB operating hours
    let daily1MA = 31025
    // IF(KB6<=0,0,(E6+(V6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KB6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1MA + i] = iff(
        daily11[daily1KB + i] <= 0, 0,
        (daily11[daily1E + i]
          + (daily11[daily1V + i] - daily11[daily1E + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KB + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Checksum
    let daily1MB = 31390
    // MAX(0,-LD6)+MAX(0,-LJ6)+MAX(0,-LQ6)+MAX(0,-LU6)
    for i in 0..<365 {
      daily17[daily1MB + i] =
        max(0, -daily11[daily1LD + i]) + max(0, -daily11[daily1LJ + i])
        + max(0, -daily17[daily1LQ + i]) + max(0, -daily11[daily1LU + i])
    }

    /// el cons for harm op during harm op period
    let daily1MD = 31755
    // IF(OR(KS6=0,KD6=0),0,(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FD6+(GZ6-FD6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FC6+(GY6-FC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MD + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        (daily15[daily1FC + i]
          + (daily16[daily1GY + i] - daily15[daily1FC + i])
            / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FD + i]
            + (daily11[daily1GZ + i] - daily15[daily1FD + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FC + i]
              + (daily16[daily1GY + i] - daily15[daily1FC + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (daily11[daily1KS + i] - Overall_harmonious_min_perc))
    }

    /// el cons for night prep during harm op period
    let daily1ME = 32120
    // IF(OR(KS6=0,KD6=0),0,(Z6+(AA6-Z6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1ME + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        (daily11[daily1Z + i]
          + (daily10[daily1AA + i] - daily11[daily1Z + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el to cover aux cons during harm op period
    let daily1MF = 32485
    // IF(OR(KS6=0,KD6=0),0,FO6+(HK6-FO6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MF + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FO + i] + (daily16[daily1HK + i] - daily15[daily1FO + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for BESS charging during harm op period
    let daily1MG = 32850
    // IF(OR(KS6=0,KD6=0),0,MIN(((FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FZ6+(HV6-FZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FY6+(HU6-FY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc)),(FR6+(HN6-FR6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))/BESS_chrg_eff))
    for i in 0..<365 {
      daily17[daily1MG + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        min(
          ((daily15[daily1FY + i]
            + (daily16[daily1HU + i] - daily15[daily1FY + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            + ((daily15[daily1FZ + i]
              + (daily16[daily1HV + i] - daily15[daily1FZ + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              - (daily15[daily1FY + i]
                + (daily16[daily1HU + i] - daily15[daily1FY + i])
                  / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1KS + i] - Overall_harmonious_min_perc)),
          (daily15[daily1FR + i]
            + (daily16[daily1HN + i] - daily15[daily1FR + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            / BESS_chrg_eff))
    }

    /// el cons for el boiler op for harm op during harm op period
    let daily1MH = 33215
    // IF(OR(KS6=0,KD6=0),0,(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FM6+(HI6-FM6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FL6+(HH6-FL6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MH + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        (daily15[daily1FL + i]
          + (daily16[daily1HH + i] - daily15[daily1FL + i])
            / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FM + i]
            + (daily16[daily1HI + i] - daily15[daily1FM + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FL + i]
              + (daily16[daily1HH + i] - daily15[daily1FL + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (daily11[daily1KS + i] - Overall_harmonious_min_perc))
    }

    /// el cons for el boiler op for night prep during harm op period
    let daily1MI = 33580
    // MQ6/El_boiler_eff
    // for i in 0..<365 { daily17[daily1MI + i] = daily11[daily1MQ + i] / El_boiler_eff }

    /// El available during harm op period after TES chrg
    let daily1MJ = 33945
    // IF(OR(KS6=0,KD6=0),0,EY6+(GU6-EY6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MJ + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily11[daily1EY + i] + (daily16[daily1GU + i] - daily11[daily1EY + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import for harm op during harm op period
    let daily1MK = 34310
    // IF(OR(KD6=0,KS6=0),0,(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FJ6+(HF6-FJ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FI6+(HE6-FI6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MK + i] = iff(
        or(daily11[daily1KD + i].isZero, daily11[daily1KS + i].isZero), 0,
        (daily15[daily1FI + i]
          + (daily16[daily1HE + i] - daily15[daily1FI + i])
            / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FJ + i]
            + (daily11[daily1HF + i] - daily15[daily1FJ + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FI + i]
              + (daily16[daily1HE + i] - daily15[daily1FI + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (daily11[daily1KS + i] - Overall_harmonious_min_perc))
    }

    /// Grid import for night prep during harm op period
    let daily1ML = 34675
    // IF(OR(KD6=0,KS6=0),0,MIN((GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((GF6+(IB6-GF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(GE6+(IA6-GE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc),MAX(0,-(MJ6+MK6-MD6-ME6-MF6-MG6-MH6-MI6))))
    // for i in 0..<365 {
    //   daily17[daily1ML + i] = iff(
    //   or(
    //  daily11[daily1KD + i]=0,daily11[daily1KS + i]=0),0, min((daily15[daily1GE + i] + (daily11[daily1IA + i] - daily15[daily1GE + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])) + ((daily15[daily1GF + i] + (daily11[daily1IB + i] - daily15[daily1GF + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])) - (daily15[daily1GE + i] + (daily11[daily1IA + i] - daily15[daily1GE + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc) * (daily11[daily1KS + i] - Overall_harmonious_min_perc),max(0, - (daily11[daily1MJ + i] + daily11[daily1MK + i] - daily11[daily1MD + i] - daily11[daily1ME + i] - daily17[daily1MF + i] - daily11[daily1MG + i] - daily11[daily1MH + i] - daily11[daily1MI + i]))))
    // }

    /// Balance of electricity during harm op period
    let daily1MM = 35040
    // MJ6+MK6+ML6-MD6-ME6-MF6-MG6-MH6-MI6
    for i in 0..<365 {
      daily17[daily1MM + i] =
        daily11[daily1MJ + i] + daily11[daily1MK + i] + daily11[daily1ML + i]
        - daily11[daily1MD + i] - daily11[daily1ME + i] - daily17[daily1MF + i]
        - daily11[daily1MG + i] - daily11[daily1MH + i] - daily11[daily1MI + i]
    }

    /// heat cons for harm op during harm op period
    let daily1MN = 35405
    // IF(OR(KS6=0,KD6=0),0,(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FG6+(HC6-FG6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FF6+(HB6-FF6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MN + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        (daily15[daily1FF + i]
          + (daily16[daily1HB + i] - daily15[daily1FF + i])
            / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
          + ((daily15[daily1FG + i]
            + (daily11[daily1HC + i] - daily15[daily1FG + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
            - (daily15[daily1FF + i]
              + (daily16[daily1HB + i] - daily15[daily1FF + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
          / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (daily11[daily1KS + i] - Overall_harmonious_min_perc))
    }

    /// heat cons for night prep during harm op period
    let daily1MO = 35770
    // IF(OR(KS6=0,KD6=0),0,(AB6+(AC6-AB6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1MO + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        (daily10[daily1AB + i]
          + (daily10[daily1AC + i] - daily10[daily1AB + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// heat prod by el boiler for harm op during harm op period
    let daily1MP = 36135
    // IF(OR(KS6=0,KD6=0),0,MH6*El_boiler_eff)
    for i in 0..<365 {
      daily17[daily1MP + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily11[daily1MH + i] * El_boiler_eff)
    }

    /// heat prod by el boiler for night prep during harm op period
    let daily1MQ = 36500
    // IF(OR(KS6=0,KD6=0),0,MAX(0,MO6-((FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((FW6+(HS6-FW6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(FV6+(HR6-FV6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      daily17[daily1MQ + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        max(
          0,
          daily11[daily1MO + i]
            - ((daily15[daily1FV + i]
              + (daily16[daily1HR + i] - daily15[daily1FV + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              + ((daily15[daily1FW + i]
                + (daily11[daily1HS + i] - daily15[daily1FW + i])
                  / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily15[daily1FV + i]
                  + (daily16[daily1HR + i] - daily15[daily1FV + i])
                    / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (daily11[daily1KS + i] - Overall_harmonious_min_perc))
        ))
    }

    /// Heat available during harm op period after TES chrg
    let daily1MR = 36865
    // IF(OR(KS6=0,KD6=0),0,FA6+(GW6-FA6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MR + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily11[daily1FA + i] + (daily11[daily1GW + i] - daily11[daily1FA + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat during harm op period
    let daily1MS = 37230
    // MP6+MQ6+MR6-MN6-MO6
    for i in 0..<365 {
      daily17[daily1MS + i] =
        daily11[daily1MP + i] + daily17[daily1MQ + i] + daily11[daily1MR + i]
        - daily11[daily1MN + i] - daily11[daily1MO + i]
    }

    /// el cons for harm op outside of harm op period
    let daily1MT = 37595
    // IF(OR(KS6=0,KD6=0),0,FE6+(HA6-FE6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MT + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FE + i] + (daily11[daily1HA + i] - daily15[daily1FE + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el to cover aux cons outside of harm op period
    let daily1MU = 37960
    // IF(OR(KS6=0,KD6=0),0,FP6+(HL6-FP6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MU + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FP + i] + (daily11[daily1HL + i] - daily15[daily1FP + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el cons for el boiler for harm op outside of harm op period
    let daily1MV = 38325
    // IF(OR(KS6=0,KD6=0),0,FN6+(HJ6-FN6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MV + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FN + i] + (daily11[daily1HJ + i] - daily15[daily1FN + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// el from BESS discharging outside of harm op period
    let daily1MW = 38690
    // MG6*BESS_chrg_eff
    for i in 0..<365 { daily17[daily1MW + i] = daily11[daily1MG + i] * BESS_chrg_eff }

    /// El available outside of harm op period after TES chrg
    let daily1MX = 39055
    // IF(OR(KS6=0,KD6=0),0,EZ6+(GV6-EZ6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1MX + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily11[daily1EZ + i] + (daily11[daily1GV + i] - daily11[daily1EZ + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Grid import needed outside of harm op period
    let daily1MY = 39420
    // IF(OR(KS6=0,KD6=0),0,MIN(GG6+(IC6-GG6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc),MAX(0,-(MW6+MX6-MT6-MU6-MV6))))
    // for i in 0..<365 {
    //   daily17[daily1MY + i] = iff(
    //   or(
    //  daily11[daily1KS + i]=0,daily11[daily1KD + i]=0),0, min(daily15[daily1GG + i] + (daily11[daily1IC + i] - daily15[daily1GG + i]) / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j]) * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]),max(0, - (daily11[daily1MW + i] + daily11[daily1MX + i] - daily11[daily1MT + i] - daily11[daily1MU + i] - daily17[daily1MV + i]))))
    // }

    /// Balance of electricity outside of harm op period
    let daily1MZ = 39785
    // MW6+MX6+MY6-MT6-MU6-MV6
    for i in 0..<365 {
      daily17[daily1MZ + i] =
        daily11[daily1MW + i] + daily11[daily1MX + i] + daily11[daily1MY + i]
        - daily11[daily1MT + i] - daily11[daily1MU + i] - daily17[daily1MV + i]
    }

    /// heat cons for harm op outside of harm op period
    let daily1NA = 40150
    // IF(OR(KS6=0,KD6=0),0,FH6+(HD6-FH6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1NA + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FH + i] + (daily11[daily1HD + i] - daily15[daily1FH + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Heat prod by el boiler for harm op outside of harm op period
    let daily1NB = 40515
    // IF(OR(KS6=0,KD6=0),0,MV6*El_boiler_eff)
    for i in 0..<365 {
      daily17[daily1NB + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily17[daily1MV + i] * El_boiler_eff)
    }

    /// Heat available outside of harm op period after TES chrg
    let daily1NC = 40880
    // IF(OR(KS6=0,KD6=0),0,FB6+(GX6-FB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      daily17[daily1NC + i] = iff(
        or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
        daily15[daily1FB + i] + (daily11[daily1GX + i] - daily15[daily1FB + i])
          / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
          * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
    }

    /// Balance of heat outside of harm op period
    let daily1ND = 41245
    // NB6+NC6-NA6
    for i in 0..<365 {
      daily17[daily1ND + i] = daily11[daily1NB + i] + daily11[daily1NC + i] - daily11[daily1NA + i]
    }

    /// Pure Methanol prod with night priority and resp day op
    let daily1NE = 41610
    // IF(MD6<=0,0,MD6/(Overall_harmonious_var_max_cons+Overall_fix_cons)*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud)+IF(MT6<=0,0,(MT6-A_overall_stup_cons)/(A_overall_var_max_cons+A_overall_fix_stby_cons)*A_MethDist_max_perc*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      daily17[daily1NE + i] =
        iff(
          daily11[daily1MD + i] <= 0, 0,
          daily11[daily1MD + i] / (Overall_harmonious_var_max_cons + Overall_fix_cons)
            * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud)
        + iff(
          daily11[daily1MT + i] <= 0, 0,
          (daily11[daily1MT + i] - overall_stup_cons[j])
            / (overall_var_max_cons[j] + overall_fix_stby_cons[j]) * MethDist_max_perc[j]
            * MethDist_Meth_nom_prod_ud)
    }

    /// Grid export
    let daily1NF = 41975
    // MIN(MM6,IF(OR(KS6=0,KD6=0),0,(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))+((GC6+(HY6-GC6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc))-(GB6+(HX6-GB6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(KS6-Overall_harmonious_min_perc)))+MIN(MZ6,IF(OR(KS6=0,KD6=0),0,GD6+(HZ6-GD6)/(AM6-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1NF + i] =
        min(
          daily11[daily1MM + i],
          iff(
            or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
            (daily11[daily1GB + i]
              + (daily16[daily1HX + i] - daily11[daily1GB + i])
                / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
              + ((daily11[daily1GC + i]
                + (daily11[daily1HY + i] - daily11[daily1GC + i])
                  / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                  * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
                - (daily11[daily1GB + i]
                  + (daily16[daily1HX + i] - daily11[daily1GB + i])
                    / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
                    * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
              / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (daily11[daily1KS + i] - Overall_harmonious_min_perc)))
        + min(
          daily17[daily1MZ + i],
          iff(
            or(daily11[daily1KS + i].isZero, daily11[daily1KD + i].isZero), 0,
            daily15[daily1GD + i] + (daily16[daily1HZ + i] - daily15[daily1GD + i])
              / (daily10[daily1AM + i] - equiv_harmonious_min_perc[j])
              * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j])))
    }

    /// Grid import
    let daily1NG = 42340
    // MY6+ML6
    for i in 0..<365 { daily17[daily1NG + i] = daily11[daily1MY + i] + daily11[daily1ML + i] }

    /// Outside harmonious operation period hours
    let daily1NH = 42705
    // IF(KD6<=0,0,(C6+(T6-C6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1NH + i] = iff(
        daily11[daily1KD + i] <= 0, 0,
        (daily11[daily1C + i]
          + (daily11[daily1T + i] - daily11[daily1C + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Harmonious operation period hours
    let daily1NI = 43070
    // IF(KD6<=0,0,(D6+(U6-D6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1NI + i] = iff(
        daily11[daily1KD + i] <= 0, 0,
        (daily11[daily1D + i]
          + (daily11[daily1U + i] - daily11[daily1D + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// PB operating hours
    let daily1NJ = 43435
    // IF(KD6<=0,0,(E6+(V6-E6)/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(KD6-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      daily17[daily1NJ + i] = iff(
        daily11[daily1KD + i] <= 0, 0,
        (daily11[daily1E + i]
          + (daily11[daily1V + i] - daily11[daily1E + i])
            / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
            * (daily11[daily1KD + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// Checksum
    let daily1NK = 43800
    // MAX(0,-MM6)+MAX(0,-MS6)+MAX(0,-MZ6)+MAX(0,-ND6)
    for i in 0..<365 {
      daily17[daily1NK + i] =
        max(0, -daily11[daily1MM + i]) + max(0, -daily17[daily1MS + i])
        + max(0, -daily17[daily1MZ + i]) + max(0, -daily11[daily1ND + i])
    }
  }
}
