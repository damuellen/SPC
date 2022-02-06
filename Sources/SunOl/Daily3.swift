
extension TunOl {
  
  func daily2(r27: inout [Double]) {

    /// Pure Methanol produced
    let ZK = 0
    // IU6
    for i in 0..<365 { r27[ZK + i] = r27[IU + i] }

    /// grid cost balance
    let ZL = 365
    // MIN(C6*Grid_export_max_ud,IV6)*Specific_CostP8-(IW6)*Specific_CostP7
    for i in 0..<365 {
      r27[ZL + i] =
        min(r27[C + i] * Grid_export_max_ud, r27[IV + i]) * Specific_Costr27[P + i] - (r27[IW + i])
        * Specific_Costr27[P + i]
    }

    /// LCOM of day
    let ZM = 730
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-ZL6*1000)/ZK6,"NA")
    for i in 0..<365 {
      r27[ZM + i] = ifFinite(
        ((Specific_Costr27[P + i - 1] * Lec_calcr27[AZ + i] + Lec_calcr27[BA + i]) / 365
          - r27[ZL + i] * 1000) / r27[ZK + i], "NA")
    }

    /// Checksum
    let ZN = 1095
    // IX6
    for i in 0..<365 { r27[ZN + i] = r27[IX + i] }

    /// Pure Methanol produced
    let ZO = 1460
    // JZ6
    for i in 0..<365 { r27[ZO + i] = r27[JZ + i] }

    /// grid cost balance
    let ZP = 1825
    // MIN(C6*Grid_export_max_ud,KA6)*Specific_CostP8-(KB6)*Specific_CostP7
    for i in 0..<365 {
      r27[ZP + i] =
        min(r27[C + i] * Grid_export_max_ud, r27[KA + i]) * Specific_Costr27[P + i] - (r27[KB + i])
        * Specific_Costr27[P + i]
    }

    /// LCOM of day
    let ZQ = 2190
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-ZP6*1000)/ZO6,"NA")
    for i in 0..<365 {
      r27[ZQ + i] = ifFinite(
        ((Specific_Costr27[P + i - 1] * Lec_calcr27[AZ + i] + Lec_calcr27[BA + i]) / 365
          - r27[ZP + i] * 1000) / r27[ZO + i], "NA")
    }

    /// Checksum
    let ZR = 2555
    // KC6
    for i in 0..<365 { r27[ZR + i] = r27[KC + i] }

    /// Pure Methanol produced
    let ZS = 2920
    // NW6
    for i in 0..<365 { r27[ZS + i] = r27[NW + i] }

    /// grid cost balance
    let ZT = 3285
    // MIN(C6*Grid_export_max_ud,NX6)*Specific_CostP8-(NY6)*Specific_CostP7
    for i in 0..<365 {
      r27[ZT + i] =
        min(r27[C + i] * Grid_export_max_ud, r27[NX + i]) * Specific_Costr27[P + i] - (r27[NY + i])
        * Specific_Costr27[P + i]
    }

    /// LCOM of day
    let ZU = 3650
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-ZT6*1000)/ZS6,"NA")
    for i in 0..<365 {
      r27[ZU + i] = ifFinite(
        ((Specific_Costr27[P + i - 1] * Lec_calcr27[AZ + i] + Lec_calcr27[BA + i]) / 365
          - r27[ZT + i] * 1000) / r27[ZS + i], "NA")
    }

    /// Checksum
    let ZV = 4015
    // NZ6
    for i in 0..<365 { r27[ZV + i] = r27[NZ + i] }

    /// Pure Methanol produced
    let ZW = 4380
    // PB6
    for i in 0..<365 { r27[ZW + i] = r27[PB + i] }

    /// grid cost balance
    let ZX = 4745
    // MIN(C6*Grid_export_max_ud,PC6)*Specific_CostP8-(PD6)*Specific_CostP7
    for i in 0..<365 {
      r27[ZX + i] =
        min(r27[C + i] * Grid_export_max_ud, r27[PC + i]) * Specific_Costr27[P + i] - (r27[PD + i])
        * Specific_Costr27[P + i]
    }

    /// LCOM of day
    let ZY = 5110
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-ZX6*1000)/ZW6,"NA")
    for i in 0..<365 {
      r27[ZY + i] = ifFinite(
        ((Specific_Costr27[P + i - 1] * Lec_calcr27[AZ + i] + Lec_calcr27[BA + i]) / 365
          - r27[ZX + i] * 1000) / r27[ZW + i], "NA")
    }

    /// Checksum
    let ZZ = 5475
    // PE6
    for i in 0..<365 { r27[ZZ + i] = r27[PE + i] }

    /// Pure Methanol produced
    let AAA = 5840
    // SY6
    for i in 0..<365 { r27[AAA + i] = r27[SY + i] }

    /// grid cost balance
    let AAB = 6205
    // MIN(C6*Grid_export_max_ud,SZ6)*Specific_CostP8-(TA6)*Specific_CostP7
    for i in 0..<365 {
      r27[AAB + i] =
        min(r27[C + i] * Grid_export_max_ud, r27[SZ + i]) * Specific_Costr27[P + i] - (r27[TA + i])
        * Specific_Costr27[P + i]
    }

    /// LCOM of day
    let AAC = 6570
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-AAB6*1000)/AAA6,"NA")
    for i in 0..<365 {
      r27[AAC + i] = ifFinite(
        ((Specific_Costr27[P + i - 1] * Lec_calcr27[AZ + i] + Lec_calcr27[BA + i]) / 365
          - r27[AAB + i] * 1000) / r27[AAA + i], "NA")
    }

    /// Checksum
    let AAD = 6935
    // TB6
    for i in 0..<365 { r27[AAD + i] = r27[TB + i] }

    /// Pure Methanol produced
    let AAE = 7300
    // UD6
    for i in 0..<365 { r27[AAE + i] = r27[UD + i] }

    /// grid cost balance
    let AAF = 7665
    // MIN(C6*Grid_export_max_ud,UE6)*Specific_CostP8-(UF6)*Specific_CostP7
    for i in 0..<365 {
      r27[AAF + i] =
        min(r27[C + i] * Grid_export_max_ud, r27[UE + i]) * Specific_Costr27[P + i] - (r27[UF + i])
        * Specific_Costr27[P + i]
    }

    /// LCOM of day
    let AAG = 8030
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-AAF6*1000)/AAE6,"NA")
    for i in 0..<365 {
      r27[AAG + i] = ifFinite(
        ((Specific_Costr27[P + i - 1] * Lec_calcr27[AZ + i] + Lec_calcr27[BA + i]) / 365
          - r27[AAF + i] * 1000) / r27[AAE + i], "NA")
    }

    /// Checksum
    let AAH = 8395
    // UG6
    for i in 0..<365 { r27[AAH + i] = r27[UG + i] }

    /// Pure Methanol produced
    let AAI = 8760
    // YA6
    for i in 0..<365 { r27[AAI + i] = r27[YA + i] }

    /// grid cost balance
    let AAJ = 9125
    // MIN(C6*Grid_export_max_ud,YB6)*Specific_CostP8-(YC6)*Specific_CostP7
    for i in 0..<365 {
      r27[AAJ + i] =
        min(r27[C + i] * Grid_export_max_ud, r27[YB + i]) * Specific_Costr27[P + i] - (r27[YC + i])
        * Specific_Costr27[P + i]
    }

    /// LCOM of day
    let AAK = 9490
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-AAJ6*1000)/AAI6,"NA")
    for i in 0..<365 {
      r27[AAK + i] = ifFinite(
        ((Specific_Costr27[P + i - 1] * Lec_calcr27[AZ + i] + Lec_calcr27[BA + i]) / 365
          - r27[AAJ + i] * 1000) / r27[AAI + i], "NA")
    }

    /// Checksum
    let AAL = 9855
    // YD6
    for i in 0..<365 { r27[AAL + i] = r27[YD + i] }

    /// Pure Methanol produced
    let AAM = 10220
    // ZF6
    for i in 0..<365 { r27[AAM + i] = r27[ZF + i] }

    /// grid cost balance
    let AAN = 10585
    // MIN(C6*Grid_export_max_ud,ZG6)*Specific_CostP8-(ZH6)*Specific_CostP7
    for i in 0..<365 {
      r27[AAN + i] =
        min(r27[C + i] * Grid_export_max_ud, r27[ZG + i]) * Specific_Costr27[P + i] - (r27[ZH + i])
        * Specific_Costr27[P + i]
    }

    /// LCOM of day
    let AAO = 10950
    // IFERROR(((Specific_CostP5*LEC_CalcAZ3+LEC_CalcBA3)/365-AAN6*1000)/AAM6,"NA")
    for i in 0..<365 {
      r27[AAO + i] = ifFinite(
        ((Specific_Costr27[P + i - 1] * Lec_calcr27[AZ + i] + Lec_calcr27[BA + i]) / 365
          - r27[AAN + i] * 1000) / r27[AAM + i], "NA")
    }

    /// Checksum
    let AAP = 11315
    // ZI6
    for i in 0..<365 { r27[AAP + i] = r27[ZI + i] }

    /// Best op case
    let AAQ = 11680
    // IF(ZM6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),"2a day prio",IF(ZQ6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),"2a night prio",IF(ZU6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),"2b day prio",IF(ZY6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),"2b night prio",IF(AAC6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),"2c day prio",IF(AAG6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),"2c night prio",IF(AAK6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),"2d day prio",IF(AAO6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),"2d night prio","NA"))))))))
    for i in 0..<365 {
      r27[AAQ + i] = iff(
        r27[ZM + i]
          == min(
            r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
            r27[AAK + i], r27[AAO + i]), "0",
        iff(
          r27[ZQ + i]
            == min(
              r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
              r27[AAK + i], r27[AAO + i]), "1",
          iff(
            r27[ZU + i]
              == min(
                r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                r27[AAK + i], r27[AAO + i]), "2",
            iff(
              r27[ZY + i]
                == min(
                  r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                  r27[AAK + i], r27[AAO + i]), "3",
              iff(
                r27[AAC + i]
                  == min(
                    r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                    r27[AAK + i], r27[AAO + i]), "4",
                iff(
                  r27[AAG + i]
                    == min(
                      r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                      r27[AAG + i], r27[AAK + i], r27[AAO + i]), "5",
                  iff(
                    r27[AAK + i]
                      == min(
                        r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                        r27[AAG + i], r27[AAK + i], r27[AAO + i]), "6",
                    iff(
                      r27[AAO + i]
                        == min(
                          r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                          r27[AAG + i], r27[AAK + i], r27[AAO + i]), "7", "NA"))))))))
    }

    /// Meth produced
    let AAR = 12045
    // IF(ZM6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZK6,IF(ZQ6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZO6,IF(ZU6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZS6,IF(ZY6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZW6,IF(AAC6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAA6,IF(AAG6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAE6,IF(AAK6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAI6,IF(AAO6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAM6,0))))))))
    for i in 0..<365 {
      r27[AAR + i] = iff(
        r27[ZM + i]
          == min(
            r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
            r27[AAK + i], r27[AAO + i]), r27[ZK + i],
        iff(
          r27[ZQ + i]
            == min(
              r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
              r27[AAK + i], r27[AAO + i]), r27[ZO + i],
          iff(
            r27[ZU + i]
              == min(
                r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                r27[AAK + i], r27[AAO + i]), r27[ZS + i],
            iff(
              r27[ZY + i]
                == min(
                  r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                  r27[AAK + i], r27[AAO + i]), r27[ZW + i],
              iff(
                r27[AAC + i]
                  == min(
                    r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                    r27[AAK + i], r27[AAO + i]), r27[AAA + i],
                iff(
                  r27[AAG + i]
                    == min(
                      r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                      r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAE + i],
                  iff(
                    r27[AAK + i]
                      == min(
                        r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                        r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAI + i],
                    iff(
                      r27[AAO + i]
                        == min(
                          r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                          r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAM + i], 0))))))))
    }

    /// grid cost balance
    let AAS = 12410
    // IF(ZM6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZL6,IF(ZQ6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZP6,IF(ZU6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZT6,IF(ZY6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZX6,IF(AAC6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAB6,IF(AAG6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAF6,IF(AAK6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAJ6,IF(AAO6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAN6,0))))))))
    for i in 0..<365 {
      r27[AAS + i] = iff(
        r27[ZM + i]
          == min(
            r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
            r27[AAK + i], r27[AAO + i]), r27[ZL + i],
        iff(
          r27[ZQ + i]
            == min(
              r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
              r27[AAK + i], r27[AAO + i]), r27[ZP + i],
          iff(
            r27[ZU + i]
              == min(
                r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                r27[AAK + i], r27[AAO + i]), r27[ZT + i],
            iff(
              r27[ZY + i]
                == min(
                  r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                  r27[AAK + i], r27[AAO + i]), r27[ZX + i],
              iff(
                r27[AAC + i]
                  == min(
                    r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                    r27[AAK + i], r27[AAO + i]), r27[AAB + i],
                iff(
                  r27[AAG + i]
                    == min(
                      r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                      r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAF + i],
                  iff(
                    r27[AAK + i]
                      == min(
                        r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                        r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAJ + i],
                    iff(
                      r27[AAO + i]
                        == min(
                          r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                          r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAN + i], 0))))))))
    }

    /// LCOM of day
    let AAT = 12775
    // IF(ZM6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZM6,IF(ZQ6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZQ6,IF(ZU6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZU6,IF(ZY6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZY6,IF(AAC6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAC6,IF(AAG6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAG6,IF(AAK6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAK6,IF(AAO6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAO6,0))))))))
    for i in 0..<365 {
      r27[AAT + i] = iff(
        r27[ZM + i]
          == min(
            r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
            r27[AAK + i], r27[AAO + i]), r27[ZM + i],
        iff(
          r27[ZQ + i]
            == min(
              r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
              r27[AAK + i], r27[AAO + i]), r27[ZQ + i],
          iff(
            r27[ZU + i]
              == min(
                r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                r27[AAK + i], r27[AAO + i]), r27[ZU + i],
            iff(
              r27[ZY + i]
                == min(
                  r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                  r27[AAK + i], r27[AAO + i]), r27[ZY + i],
              iff(
                r27[AAC + i]
                  == min(
                    r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                    r27[AAK + i], r27[AAO + i]), r27[AAC + i],
                iff(
                  r27[AAG + i]
                    == min(
                      r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                      r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAG + i],
                  iff(
                    r27[AAK + i]
                      == min(
                        r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                        r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAK + i],
                    iff(
                      r27[AAO + i]
                        == min(
                          r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                          r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAO + i], 0))))))))
    }

    /// Outside harmonious operation period hours
    let AAU = 13140
    // IF(AAR6=0,0,B6)
    for i in 0..<365 { r27[AAU + i] = iff(r27[AAR + i] = 0, 0, r27[B + i]) }

    /// Harmonious operation period hours
    let AAV = 13505
    // IF(AAR6=0,0,C6)
    for i in 0..<365 { r27[AAV + i] = iff(r27[AAR + i] = 0, 0, r27[C + i]) }

    // IF(ZM6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZN6,IF(ZQ6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZR6,IF(ZU6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZV6,IF(ZY6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),ZZ6,IF(AAC6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAD6,IF(AAG6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAH6,IF(AAK6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAL6,IF(AAO6=MIN(ZM6,ZQ6,ZU6,ZY6,AAC6,AAG6,AAK6,AAO6),AAP6,0))))))))
    for i in 0..<365 {
      r27[AAX + i] = iff(
        r27[ZM + i]
          == min(
            r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
            r27[AAK + i], r27[AAO + i]), r27[ZN + i],
        iff(
          r27[ZQ + i]
            == min(
              r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
              r27[AAK + i], r27[AAO + i]), r27[ZR + i],
          iff(
            r27[ZU + i]
              == min(
                r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                r27[AAK + i], r27[AAO + i]), r27[ZV + i],
            iff(
              r27[ZY + i]
                == min(
                  r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                  r27[AAK + i], r27[AAO + i]), r27[ZZ + i],
              iff(
                r27[AAC + i]
                  == min(
                    r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i], r27[AAG + i],
                    r27[AAK + i], r27[AAO + i]), r27[AAD + i],
                iff(
                  r27[AAG + i]
                    == min(
                      r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                      r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAH + i],
                  iff(
                    r27[AAK + i]
                      == min(
                        r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                        r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAL + i],
                    iff(
                      r27[AAO + i]
                        == min(
                          r27[ZM + i], r27[ZQ + i], r27[ZU + i], r27[ZY + i], r27[AAC + i],
                          r27[AAG + i], r27[AAK + i], r27[AAO + i]), r27[AAP + i], 0))))))))
    }

  }
}