
extension TunOl {
  func daily1(r16: inout [Double]) {

    /// Pure Methanol produced
    let AND = 0
    // LV6
    for i in 0..<365 { r38[AND + i] = r38[LV + i] }

    /// grid cost balance
    let ANE = 365
    // MAX(0,LW6)*Specific_CostP8-MAX(0,LX6)*Specific_CostP7
    for i in 0..<365 {
      r38[ANE + i] =
        max(0, r38[LW + i]) * Specific_Costr38[P + i] - max(0, r38[LX + i])
        * Specific_Costr38[P + i]
    }

    /// LCOM of day
    let ANF = 730
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-ANE6*1000)/AND6,"NA")
    for i in 0..<365 {
      r38[ANF + i] = ifFinite(
        ((Specific_Costr38[P + i - 1] * Lec_calcr38[AZ + i] + Lec_calcr38[BA + i]) / 365
          - r38[ANE + i] * 1000) / r38[AND + i], "NA")
    }

    /// Outside harmonious operation period hours
    let ANG = 1095
    // LY6
    for i in 0..<365 { r38[ANG + i] = r38[LY + i] }

    /// Harmonious operation period hours
    let ANH = 1460
    // LZ6
    for i in 0..<365 { r38[ANH + i] = r38[LZ + i] }

    /// PB operating hours
    let ANI = 1825
    // MA6
    for i in 0..<365 { r38[ANI + i] = r38[MA + i] }

    /// Checksum
    let ANJ = 2190
    // MB6
    for i in 0..<365 { r38[ANJ + i] = r38[MB + i] }

    /// Pure Methanol produced
    let ANK = 2555
    // NE6
    for i in 0..<365 { r38[ANK + i] = r38[NE + i] }

    /// grid cost balance
    let ANL = 2920
    // MAX(0,NF6)*Specific_CostP8-MAX(0,NG6)*Specific_CostP7
    for i in 0..<365 {
      r38[ANL + i] =
        max(0, r38[NF + i]) * Specific_Costr38[P + i] - max(0, r38[NG + i])
        * Specific_Costr38[P + i]
    }

    /// LCOM of day
    let ANM = 3285
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-ANL6*1000)/ANK6,"NA")
    for i in 0..<365 {
      r38[ANM + i] = ifFinite(
        ((Specific_Costr38[P + i - 1] * Lec_calcr38[AZ + i] + Lec_calcr38[BA + i]) / 365
          - r38[ANL + i] * 1000) / r38[ANK + i], "NA")
    }

    /// Outside harmonious operation period hours
    let ANN = 3650
    // NH6
    for i in 0..<365 { r38[ANN + i] = r38[NH + i] }

    /// Harmonious operation period hours
    let ANO = 4015
    // NI6
    for i in 0..<365 { r38[ANO + i] = r38[NI + i] }

    /// PB operating hours
    let ANP = 4380
    // NJ6
    for i in 0..<365 { r38[ANP + i] = r38[NJ + i] }

    /// Checksum
    let ANQ = 4745
    // NK6
    for i in 0..<365 { r38[ANQ + i] = r38[NK + i] }

    /// Pure Methanol produced
    let ANR = 5110
    // UJ6
    for i in 0..<365 { r38[ANR + i] = r38[UJ + i] }

    /// grid cost balance
    let ANS = 5475
    // MAX(0,UK6)*Specific_CostP8-MAX(0,UL6)*Specific_CostP7
    for i in 0..<365 {
      r38[ANS + i] =
        max(0, r38[UK + i]) * Specific_Costr38[P + i] - max(0, r38[UL + i])
        * Specific_Costr38[P + i]
    }

    /// LCOM of day
    let ANT = 5840
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-ANS6*1000)/ANR6,"NA")
    for i in 0..<365 {
      r38[ANT + i] = ifFinite(
        ((Specific_Costr38[P + i - 1] * Lec_calcr38[AZ + i] + Lec_calcr38[BA + i]) / 365
          - r38[ANS + i] * 1000) / r38[ANR + i], "NA")
    }

    /// Outside harmonious operation period hours
    let ANU = 6205
    // UM6
    for i in 0..<365 { r38[ANU + i] = r38[UM + i] }

    /// Harmonious operation period hours
    let ANV = 6570
    // UN6
    for i in 0..<365 { r38[ANV + i] = r38[UN + i] }

    /// PB operating hours
    let ANW = 6935
    // UO6
    for i in 0..<365 { r38[ANW + i] = r38[UO + i] }

    /// Checksum
    let ANX = 7300
    // UP6
    for i in 0..<365 { r38[ANX + i] = r38[UP + i] }

    /// Pure Methanol produced
    let ANY = 7665
    // VS6
    for i in 0..<365 { r38[ANY + i] = r38[VS + i] }

    /// grid cost balance
    let ANZ = 8030
    // MAX(0,VT6)*Specific_CostP8-MAX(0,VU6)*Specific_CostP7
    for i in 0..<365 {
      r38[ANZ + i] =
        max(0, r38[VT + i]) * Specific_Costr38[P + i] - max(0, r38[VU + i])
        * Specific_Costr38[P + i]
    }

    /// LCOM of day
    let AOA = 8395
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-ANZ6*1000)/ANY6,"NA")
    for i in 0..<365 {
      r38[AOA + i] = ifFinite(
        ((Specific_Costr38[P + i - 1] * Lec_calcr38[AZ + i] + Lec_calcr38[BA + i]) / 365
          - r38[ANZ + i] * 1000) / r38[ANY + i], "NA")
    }

    /// Outside harmonious operation period hours
    let AOB = 8760
    // VV6
    for i in 0..<365 { r38[AOB + i] = r38[VV + i] }

    /// Harmonious operation period hours
    let AOC = 9125
    // VW6
    for i in 0..<365 { r38[AOC + i] = r38[VW + i] }

    /// PB operating hours
    let AOD = 9490
    // VX6
    for i in 0..<365 { r38[AOD + i] = r38[VX + i] }

    /// Checksum
    let AOE = 9855
    // VY6
    for i in 0..<365 { r38[AOE + i] = r38[VY + i] }

    /// Pure Methanol produced
    let AOF = 10220
    // ACX6
    for i in 0..<365 { r38[AOF + i] = r38[ACX + i] }

    /// grid cost balance
    let AOG = 10585
    // MAX(0,ACY6)*Specific_CostP8-MAX(0,ACZ6)*Specific_CostP7
    for i in 0..<365 {
      r38[AOG + i] =
        max(0, r38[ACY + i]) * Specific_Costr38[P + i] - max(0, r38[ACZ + i])
        * Specific_Costr38[P + i]
    }

    /// LCOM of day
    let AOH = 10950
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-AOG6*1000)/AOF6,"NA")
    for i in 0..<365 {
      r38[AOH + i] = ifFinite(
        ((Specific_Costr38[P + i - 1] * Lec_calcr38[AZ + i] + Lec_calcr38[BA + i]) / 365
          - r38[AOG + i] * 1000) / r38[AOF + i], "NA")
    }

    /// Outside harmonious operation period hours
    let AOI = 11315
    // ADA6
    for i in 0..<365 { r38[AOI + i] = r38[ADA + i] }

    /// Harmonious operation period hours
    let AOJ = 11680
    // ADB6
    for i in 0..<365 { r38[AOJ + i] = r38[ADB + i] }

    /// PB operating hours
    let AOK = 12045
    // ADC6
    for i in 0..<365 { r38[AOK + i] = r38[ADC + i] }

    /// Checksum
    let AOL = 12410
    // ADD6
    for i in 0..<365 { r38[AOL + i] = r38[ADD + i] }

    /// Pure Methanol produced
    let AOM = 12775
    // AEG6
    for i in 0..<365 { r38[AOM + i] = r38[AEG + i] }

    /// grid cost balance
    let AON = 13140
    // MAX(0,AEH6)*Specific_CostP8-MAX(0,AEI6)*Specific_CostP7
    for i in 0..<365 {
      r38[AON + i] =
        max(0, r38[AEH + i]) * Specific_Costr38[P + i] - max(0, r38[AEI + i])
        * Specific_Costr38[P + i]
    }

    /// LCOM of day
    let AOO = 13505
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-AON6*1000)/AOM6,"NA")
    for i in 0..<365 {
      r38[AOO + i] = ifFinite(
        ((Specific_Costr38[P + i - 1] * Lec_calcr38[AZ + i] + Lec_calcr38[BA + i]) / 365
          - r38[AON + i] * 1000) / r38[AOM + i], "NA")
    }

    /// Outside harmonious operation period hours
    let AOP = 13870
    // AEJ6
    for i in 0..<365 { r38[AOP + i] = r38[AEJ + i] }

    /// Harmonious operation period hours
    let AOQ = 14235
    // AEK6
    for i in 0..<365 { r38[AOQ + i] = r38[AEK + i] }

    /// PB operating hours
    let AOR = 14600
    // AEL6
    for i in 0..<365 { r38[AOR + i] = r38[AEL + i] }

    /// Checksum
    let AOS = 14965
    // AEM6
    for i in 0..<365 { r38[AOS + i] = r38[AEM + i] }

    /// Pure Methanol produced
    let AOT = 15330
    // ALL6
    for i in 0..<365 { r38[AOT + i] = r38[ALL + i] }

    /// grid cost balance
    let AOU = 15695
    // MAX(0,ALM6)*Specific_CostP8-MAX(0,ALN6)*Specific_CostP7
    for i in 0..<365 {
      r38[AOU + i] =
        max(0, r38[ALM + i]) * Specific_Costr38[P + i] - max(0, r38[ALN + i])
        * Specific_Costr38[P + i]
    }

    /// LCOM of day
    let AOV = 16060
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-AOU6*1000)/AOT6,"NA")
    for i in 0..<365 {
      r38[AOV + i] = ifFinite(
        ((Specific_Costr38[P + i - 1] * Lec_calcr38[AZ + i] + Lec_calcr38[BA + i]) / 365
          - r38[AOU + i] * 1000) / r38[AOT + i], "NA")
    }

    /// Outside harmonious operation period hours
    let AOW = 16425
    // ALO6
    for i in 0..<365 { r38[AOW + i] = r38[ALO + i] }

    /// Harmonious operation period hours
    let AOX = 16790
    // ALP6
    for i in 0..<365 { r38[AOX + i] = r38[ALP + i] }

    /// PB operating hours
    let AOY = 17155
    // ALQ6
    for i in 0..<365 { r38[AOY + i] = r38[ALQ + i] }

    /// Checksum
    let AOZ = 17520
    // ALR6
    for i in 0..<365 { r38[AOZ + i] = r38[ALR + i] }

    /// Pure Methanol produced
    let APA = 17885
    // AMU6
    for i in 0..<365 { r38[APA + i] = r38[AMU + i] }

    /// grid cost balance
    let APB = 18250
    // MAX(0,AMV6)*Specific_CostP8-MAX(0,AMW6)*Specific_CostP7
    for i in 0..<365 {
      r38[APB + i] =
        max(0, r38[AMV + i]) * Specific_Costr38[P + i] - max(0, r38[AMW + i])
        * Specific_Costr38[P + i]
    }

    /// LCOM of day
    let APC = 18615
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-APB6*1000)/APA6,"NA")
    for i in 0..<365 {
      r38[APC + i] = ifFinite(
        ((Specific_Costr38[P + i - 1] * Lec_calcr38[AZ + i] + Lec_calcr38[BA + i]) / 365
          - r38[APB + i] * 1000) / r38[APA + i], "NA")
    }

    /// Outside harmonious operation period hours
    let APD = 18980
    // AMX6
    for i in 0..<365 { r38[APD + i] = r38[AMX + i] }

    /// Harmonious operation period hours
    let APE = 19345
    // AMY6
    for i in 0..<365 { r38[APE + i] = r38[AMY + i] }

    /// PB operating hours
    let APF = 19710
    // AMZ6
    for i in 0..<365 { r38[APF + i] = r38[AMZ + i] }

    /// Checksum
    let APG = 20075
    // ANA6
    for i in 0..<365 { r38[APG + i] = r38[ANA + i] }

    /// Best op case
    let APH = 20440
    // IF(ANF6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),"1a day prio",IF(ANM6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),"1a night prio",IF(ANT6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),"1b day prio",IF(AOA6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),"1b night prio",IF(AOH6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),"1c day prio",IF(AOO6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),"1c night prio",IF(AOV6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),"1d day prio",IF(APC6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),"1d night prio","NA"))))))))
    for i in 0..<365 {
      r38[APH + i] = iff(
        r38[ANF + i]
          == min(
            r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
            r38[AOV + i], r38[APC + i]), "1a day prio",
        iff(
          r38[ANM + i]
            == min(
              r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
              r38[AOV + i], r38[APC + i]), "1a night prio",
          iff(
            r38[ANT + i]
              == min(
                r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
                r38[AOV + i], r38[APC + i]), "1b day prio",
            iff(
              r38[AOA + i]
                == min(
                  r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                  r38[AOO + i], r38[AOV + i], r38[APC + i]), "1b night prio",
              iff(
                r38[AOH + i]
                  == min(
                    r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                    r38[AOO + i], r38[AOV + i], r38[APC + i]), "1c day prio",
                iff(
                  r38[AOO + i]
                    == min(
                      r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                      r38[AOO + i], r38[AOV + i], r38[APC + i]), "1c night prio",
                  iff(
                    r38[AOV + i]
                      == min(
                        r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                        r38[AOO + i], r38[AOV + i], r38[APC + i]), "1d day prio",
                    iff(
                      r38[APC + i]
                        == min(
                          r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                          r38[AOO + i], r38[AOV + i], r38[APC + i]), "1d night prio", "NA"))))))))
    }

    /// Meth produced
    let API = 20805
    // IF(ANF6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AND6,IF(ANM6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANK6,IF(ANT6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANR6,IF(AOA6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANY6,IF(AOH6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOF6,IF(AOO6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOM6,IF(AOV6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOT6,IF(APC6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),APA6,0))))))))
    for i in 0..<365 {
      r38[API + i] = iff(
        r38[ANF + i]
          == min(
            r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
            r38[AOV + i], r38[APC + i]), r38[AND + i],
        iff(
          r38[ANM + i]
            == min(
              r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
              r38[AOV + i], r38[APC + i]), r38[ANK + i],
          iff(
            r38[ANT + i]
              == min(
                r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
                r38[AOV + i], r38[APC + i]), r38[ANR + i],
            iff(
              r38[AOA + i]
                == min(
                  r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                  r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[ANY + i],
              iff(
                r38[AOH + i]
                  == min(
                    r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                    r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOF + i],
                iff(
                  r38[AOO + i]
                    == min(
                      r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                      r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOM + i],
                  iff(
                    r38[AOV + i]
                      == min(
                        r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                        r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOT + i],
                    iff(
                      r38[APC + i]
                        == min(
                          r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                          r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[APA + i], 0))))))))
    }

    /// grid cost balance
    let APJ = 21170
    // IF(ANF6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANE6,IF(ANM6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANL6,IF(ANT6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANS6,IF(AOA6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANZ6,IF(AOH6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOG6,IF(AOO6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AON6,IF(AOV6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOU6,IF(APC6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),APB6,0))))))))
    for i in 0..<365 {
      r38[APJ + i] = iff(
        r38[ANF + i]
          == min(
            r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
            r38[AOV + i], r38[APC + i]), r38[ANE + i],
        iff(
          r38[ANM + i]
            == min(
              r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
              r38[AOV + i], r38[APC + i]), r38[ANL + i],
          iff(
            r38[ANT + i]
              == min(
                r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
                r38[AOV + i], r38[APC + i]), r38[ANS + i],
            iff(
              r38[AOA + i]
                == min(
                  r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                  r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[ANZ + i],
              iff(
                r38[AOH + i]
                  == min(
                    r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                    r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOG + i],
                iff(
                  r38[AOO + i]
                    == min(
                      r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                      r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AON + i],
                  iff(
                    r38[AOV + i]
                      == min(
                        r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                        r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOU + i],
                    iff(
                      r38[APC + i]
                        == min(
                          r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                          r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[APB + i], 0))))))))
    }

    /// LCOM of day
    let APK = 21535
    // IF(ANF6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANF6,IF(ANM6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANM6,IF(ANT6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANT6,IF(AOA6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOA6,IF(AOH6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOH6,IF(AOO6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOO6,IF(AOV6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOV6,IF(APC6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),APC6,0))))))))
    for i in 0..<365 {
      r38[APK + i] = iff(
        r38[ANF + i]
          == min(
            r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
            r38[AOV + i], r38[APC + i]), r38[ANF + i],
        iff(
          r38[ANM + i]
            == min(
              r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
              r38[AOV + i], r38[APC + i]), r38[ANM + i],
          iff(
            r38[ANT + i]
              == min(
                r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
                r38[AOV + i], r38[APC + i]), r38[ANT + i],
            iff(
              r38[AOA + i]
                == min(
                  r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                  r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOA + i],
              iff(
                r38[AOH + i]
                  == min(
                    r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                    r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOH + i],
                iff(
                  r38[AOO + i]
                    == min(
                      r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                      r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOO + i],
                  iff(
                    r38[AOV + i]
                      == min(
                        r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                        r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOV + i],
                    iff(
                      r38[APC + i]
                        == min(
                          r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                          r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[APC + i], 0))))))))
    }

    /// Outside harmonious operation period hours
    let APL = 21900
    // IF(ANF6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANG6,IF(ANM6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANN6,IF(ANT6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANU6,IF(AOA6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOB6,IF(AOH6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOI6,IF(AOO6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOP6,IF(AOV6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOW6,IF(APC6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),APD6,0))))))))
    for i in 0..<365 {
      r38[APL + i] = iff(
        r38[ANF + i]
          == min(
            r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
            r38[AOV + i], r38[APC + i]), r38[ANG + i],
        iff(
          r38[ANM + i]
            == min(
              r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
              r38[AOV + i], r38[APC + i]), r38[ANN + i],
          iff(
            r38[ANT + i]
              == min(
                r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
                r38[AOV + i], r38[APC + i]), r38[ANU + i],
            iff(
              r38[AOA + i]
                == min(
                  r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                  r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOB + i],
              iff(
                r38[AOH + i]
                  == min(
                    r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                    r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOI + i],
                iff(
                  r38[AOO + i]
                    == min(
                      r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                      r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOP + i],
                  iff(
                    r38[AOV + i]
                      == min(
                        r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                        r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOW + i],
                    iff(
                      r38[APC + i]
                        == min(
                          r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                          r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[APD + i], 0))))))))
    }

    /// Harmonious operation period hours
    let APM = 22265
    // IF(ANF6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANH6,IF(ANM6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANO6,IF(ANT6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANV6,IF(AOA6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOC6,IF(AOH6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOJ6,IF(AOO6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOQ6,IF(AOV6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOX6,IF(APC6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),APE6,0))))))))
    for i in 0..<365 {
      r38[APM + i] = iff(
        r38[ANF + i]
          == min(
            r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
            r38[AOV + i], r38[APC + i]), r38[ANH + i],
        iff(
          r38[ANM + i]
            == min(
              r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
              r38[AOV + i], r38[APC + i]), r38[ANO + i],
          iff(
            r38[ANT + i]
              == min(
                r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
                r38[AOV + i], r38[APC + i]), r38[ANV + i],
            iff(
              r38[AOA + i]
                == min(
                  r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                  r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOC + i],
              iff(
                r38[AOH + i]
                  == min(
                    r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                    r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOJ + i],
                iff(
                  r38[AOO + i]
                    == min(
                      r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                      r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOQ + i],
                  iff(
                    r38[AOV + i]
                      == min(
                        r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                        r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOX + i],
                    iff(
                      r38[APC + i]
                        == min(
                          r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                          r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[APE + i], 0))))))))
    }

    /// PB operating hours
    let APN = 22630
    // IF(ANF6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANI6,IF(ANM6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANP6,IF(ANT6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANW6,IF(AOA6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOD6,IF(AOH6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOK6,IF(AOO6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOR6,IF(AOV6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOY6,IF(APC6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),APF6,0))))))))
    for i in 0..<365 {
      r38[APN + i] = iff(
        r38[ANF + i]
          == min(
            r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
            r38[AOV + i], r38[APC + i]), r38[ANI + i],
        iff(
          r38[ANM + i]
            == min(
              r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
              r38[AOV + i], r38[APC + i]), r38[ANP + i],
          iff(
            r38[ANT + i]
              == min(
                r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
                r38[AOV + i], r38[APC + i]), r38[ANW + i],
            iff(
              r38[AOA + i]
                == min(
                  r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                  r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOD + i],
              iff(
                r38[AOH + i]
                  == min(
                    r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                    r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOK + i],
                iff(
                  r38[AOO + i]
                    == min(
                      r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                      r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOR + i],
                  iff(
                    r38[AOV + i]
                      == min(
                        r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                        r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOY + i],
                    iff(
                      r38[APC + i]
                        == min(
                          r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                          r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[APF + i], 0))))))))
    }

    /// Checksum
    let APO = 22995
    // IF(ANF6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANJ6,IF(ANM6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANQ6,IF(ANT6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),ANX6,IF(AOA6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOE6,IF(AOH6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOL6,IF(AOO6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOS6,IF(AOV6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),AOZ6,IF(APC6=MIN(ANF6,ANM6,ANT6,AOA6,AOH6,AOO6,AOV6,APC6),APG6,0))))))))
    for i in 0..<365 {
      r38[APO + i] = iff(
        r38[ANF + i]
          == min(
            r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
            r38[AOV + i], r38[APC + i]), r38[ANJ + i],
        iff(
          r38[ANM + i]
            == min(
              r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
              r38[AOV + i], r38[APC + i]), r38[ANQ + i],
          iff(
            r38[ANT + i]
              == min(
                r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i], r38[AOO + i],
                r38[AOV + i], r38[APC + i]), r38[ANX + i],
            iff(
              r38[AOA + i]
                == min(
                  r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                  r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOE + i],
              iff(
                r38[AOH + i]
                  == min(
                    r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                    r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOL + i],
                iff(
                  r38[AOO + i]
                    == min(
                      r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                      r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOS + i],
                  iff(
                    r38[AOV + i]
                      == min(
                        r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                        r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[AOZ + i],
                    iff(
                      r38[APC + i]
                        == min(
                          r38[ANF + i], r38[ANM + i], r38[ANT + i], r38[AOA + i], r38[AOH + i],
                          r38[AOO + i], r38[AOV + i], r38[APC + i]), r38[APG + i], 0))))))))
    }

  }
}
