extension TunOl {
  func d23(_ d23: inout [Double], case j: Int, day0: [Double], d21: [Double], d22: [Double]) {
    let (B0, C0, E, F, G, H, O, P, Q, R, S, T, U, V, W, X) = (
      365, 730, 0, 365, 730, 1095, 3650, 4015, 4380, 4745, 5110, 5475, 5840, 6205, 6570, 6935
    )
    let AE = 9490
    let (EA, EB, EC, _, EE, EF, EG, EH, EI, EJ, EK, EL, EM, EN, EO, EP, EQ, ER, ES, ET, EV, EW, EY, EZ) = (
      3285, 3650, 4015, 4380, 4745, 5110, 5475, 5840, 6205, 6570, 6935, 7300, 7665, 8030, 8395, 8760, 9125,
      9490, 9855, 10220, 10950, 11315, 12045, 12410
    )

    let (DM, DN, DO) = (13140, 13505, 13870)
    let (DR, DS, DT, DU, DV, DW, DX, DY, DZ) = (0, 365, 730, 1095, 1460, 1825, 2190, 2555, 2920)

    /// Surplus harm op period el after min day harm op and min night op prep
    let FC = 0
    // FC=$EB3+$EH3-$O3-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$Q3-$EE3)/El_boiler_eff
    for i in 0..<365 {
      d23[FC + i] =
        d22[EB + i] + d22[EH + i] - d21[O + i] - max(
          0,
          d22[EA + i] + d21[E + i] + max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i]
            * BESS_chrg_eff) / BESS_chrg_eff - max(Double.zero, d21[Q + i] - d22[EE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after min day harm op and max night op prep
    let FD = 365
    // FD=$EB3+$EH3-$P3-MAX(0,$EA3+$F3+MAX(0,$H3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$R3-$EE3)/El_boiler_eff
    for i in 0..<365 {
      d23[FD + i] =
        d22[EB + i] + d22[EH + i] - d21[P + i] - max(
          0,
          d22[EA + i] + d21[F + i] + max(Double.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i]
            * BESS_chrg_eff) / BESS_chrg_eff - max(Double.zero, d21[R + i] - d22[EE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after max day harm op and min night op prep
    let FE = 730
    // FE=$EC3+$EI3-$O3-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$Q3-$EF3)/El_boiler_eff
    for i in 0..<365 {
      d23[FE + i] =
        d22[EC + i] + d22[EI + i] - d21[O + i] - max(
          0,
          d22[EA + i] + d21[E + i] + max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i]
            * BESS_chrg_eff) / BESS_chrg_eff - max(Double.zero, d21[Q + i] - d22[EF + i]) / El_boiler_eff
    }

    /// Surplus outside harm op period el after min day harm and min night op prep
    let FF = 1095
    // FF=($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3-MAX(0,$G3-$EG3)/El_boiler_eff
    for i in 0..<365 {
      d23[FF + i] =
        (d22[EK + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[E + i] - max(
          0, d21[G + i] - d22[EG + i]) / El_boiler_eff
    }

    /// Surplus outside harm op period el after min day harm and max night op prep
    let FG = 1460
    // FG=($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$F3-MAX(0,$H3-$EG3)/El_boiler_eff
    for i in 0..<365 {
      d23[FG + i] =
        (d22[EK + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[F + i] - max(
          0, d21[H + i] - d22[EG + i]) / El_boiler_eff
    }

    /// Surplus outside harm op period el after max day harm and min night op prep
    let FH = 1825
    // FH=($EL3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3-MAX(0,$G3-$EG3)/El_boiler_eff
    for i in 0..<365 {
      d23[FH + i] =
        (d22[EL + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[E + i] - max(
          0, d21[G + i] - d22[EG + i]) / El_boiler_eff
    }

    /// Surplus harm op heat after min day harm and min night op prep
    let FI = 2190
    // FI=$EE3+MAX(0,$EB3+$EH3-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-$O3)*El_boiler_eff-$Q3
    for i in 0..<365 {
      d23[FI + i] =
        d22[EE + i] + max(
          0,
          d22[EB + i] + d22[EH + i] - max(
            0,
            d22[EA + i] + d21[E + i] + max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i]
              * BESS_chrg_eff) / BESS_chrg_eff - d21[O + i]) * El_boiler_eff - d21[Q + i]
    }

    /// Surplus harm op heat after min day harm and max night op prep
    let FJ = 2555
    // FJ=$EE3+MAX(0,$EB3+$EH3-MAX(0,$EA3+$F3+MAX(0,$H3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-$P3)*El_boiler_eff-$R3
    for i in 0..<365 {
      d23[FJ + i] =
        d22[EE + i] + max(
          0,
          d22[EB + i] + d22[EH + i] - max(
            0,
            d22[EA + i] + d21[F + i] + max(Double.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i]
              * BESS_chrg_eff) / BESS_chrg_eff - d21[P + i]) * El_boiler_eff - d21[R + i]
    }

    /// Surplus harm op heat after max day harm and min night op prep
    let FK = 2920
    // FK=$EF3+MAX(0,$EC3+$EI3-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-$O3)*El_boiler_eff-$Q3
    for i in 0..<365 {
      d23[FK + i] =
        d22[EF + i] + max(
          0,
          d22[EC + i] + d22[EI + i] - max(
            0,
            d22[EA + i] + d21[E + i] + max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i] - d22[EM + i]
              * BESS_chrg_eff) / BESS_chrg_eff - d21[O + i]) * El_boiler_eff - d21[Q + i]
    }

    /// Surplus outside harm op heat after min day harm and min night op prep
    let FL = 3285
    // FL=$EG3+MAX(0,($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3)*El_boiler_eff-$G3
    for i in 0..<365 {
      d23[FL + i] =
        d22[EG + i] + max(
          0, (d22[EK + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[E + i])
        * El_boiler_eff - d21[G + i]
    }

    /// Surplus outside harm op heat after min day harm and max night op prep
    let FM = 3650
    // FM=$EG3+MAX(0,($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$F3)*El_boiler_eff-$H3
    for i in 0..<365 {
      d23[FM + i] =
        d22[EG + i] + max(
          0, (d22[EK + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[F + i])
        * El_boiler_eff - d21[H + i]
    }

    /// Surplus outside harm op heat after max day harm and min night op prep
    let FN = 4015
    // FN=$EG3+MAX(0,($EL3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3)*El_boiler_eff-$G3
    for i in 0..<365 {
      d23[FN + i] =
        d22[EG + i] + max(
          0, (d22[EL + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i] - d21[E + i])
        * El_boiler_eff - d21[G + i]
    }

    /// Surplus BESS cap after min harm op and min night op prep during harm op period
    let FO = 4380
    // FO=$EK3-MAX(0,$EA3+$E3+MIN($ER3,MAX(0,$G3-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff
    for i in 0..<365 {
      d23[FO + i] =
        d22[EK + i] - max(
          0,
          d22[EA + i] + d21[E + i] + min(d22[ER + i], max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff)
            - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff
    }

    /// Surplus BESS cap after min harm op and max night op prep during harm op period
    let FP = 4745
    // FP=$EK3-MAX(0,$EA3+$F3+MIN($ER3,MAX(0,$H3-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff
    for i in 0..<365 {
      d23[FP + i] =
        d22[EK + i] - max(
          0,
          d22[EA + i] + d21[F + i] + min(d22[ER + i], max(Double.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff)
            - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff
    }

    /// Surplus BESS cap after max harm op and min night op prep during harm op period
    let FQ = 5110
    // FQ=$EL3-MAX(0,$EA3+$E3+MIN($ER3,MAX(0,$G3-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff
    for i in 0..<365 {
      d23[FQ + i] =
        d22[EL + i] - max(
          0,
          d22[EA + i] + d21[E + i] + min(d22[ER + i], max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff)
            - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff
    }

    /// Surplus el boiler cap after min harm op and min night op prep during harm op period
    let FR = 5475
    // FR=IF(El_boiler_cap_ud=0,0,$EP3-MAX(0,$Q3-$EE3)/El_boiler_eff)
    for i in 0..<365 {
      d23[FR + i] = iff(
        El_boiler_cap_ud.isZero, Double.zero, d22[EP + i] - max(Double.zero, d21[Q + i] - d22[EE + i]) / El_boiler_eff)
    }

    /// Surplus el boiler cap after min harm op and max night op prep during harm op period
    let FS = 5840
    // FS=IF(El_boiler_cap_ud=0,0,$EP3-MAX(0,$R3-$EE3)/El_boiler_eff)
    for i in 0..<365 {
      d23[FS + i] = iff(
        El_boiler_cap_ud.isZero, Double.zero, d22[EP + i] - max(Double.zero, d21[R + i] - d22[EE + i]) / El_boiler_eff)
    }

    /// Surplus el boiler cap after max harm op and min night op prep during harm op period
    let FT = 6205
    // FT=IF(El_boiler_cap_ud=0,0,$EQ3-MAX(0,$Q3-$EF3)/El_boiler_eff)
    for i in 0..<365 {
      d23[FT + i] = iff(
        El_boiler_cap_ud.isZero, Double.zero, d22[EQ + i] - max(Double.zero, d21[Q + i] - d22[EF + i]) / El_boiler_eff)
    }

    /// Surplus el boiler cap after min harm op and min night op prep outside of harm op period
    let FU = 6570
    // FU=IF(El_boiler_cap_ud=0,0,$ER3-MAX(0,$G3-$EG3)/El_boiler_eff)
    for i in 0..<365 {
      d23[FU + i] = iff(
        El_boiler_cap_ud.isZero, Double.zero, d22[ER + i] - max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff)
    }

    /// Surplus el boiler cap after min harm op and max night op prep outside of harm op period
    let FV = 6935
    // FV=IF(El_boiler_cap_ud=0,0,$ER3-MAX(0,$H3-$EG3)/El_boiler_eff)
    for i in 0..<365 {
      d23[FV + i] = iff(
        El_boiler_cap_ud.isZero, Double.zero, d22[ER + i] - max(Double.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff)
    }

    /// Surplus el boiler cap after max harm op and min night op prep outside of harm op period
    let FW = 7300
    // FW=IF(El_boiler_cap_ud=0,0,$ER3-MAX(0,$G3-$EG3)/El_boiler_eff)
    for i in 0..<365 {
      d23[FW + i] = iff(
        El_boiler_cap_ud.isZero, Double.zero, d22[ER + i] - max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff)
    }

    /// Surplus RawMeth prod cap after min day harm and min night op prep
    let FX = 7665
    // FX=$ES3-$S3
    for i in 0..<365 { d23[FX + i] = d22[ES + i] - d21[S + i] }

    /// Surplus RawMeth prod cap after min day harm and max night op prep
    let FY = 8030
    // FY=$ES3-$T3
    for i in 0..<365 { d23[FY + i] = d22[ES + i] - d21[T + i] }

    /// Surplus RawMeth prod cap after max day harm and min night op prep
    let FZ = 8395
    // FZ=$ET3-$S3
    for i in 0..<365 { d23[FZ + i] = d22[ET + i] - d21[S + i] }

    /// Surplus CO2 prod cap after min day harm and min night op prep
    let GA = 8760
    // GA=$EV3-$U3
    for i in 0..<365 { d23[GA + i] = d22[EV + i] - d21[U + i] }

    /// Surplus CO2 prod cap after min day harm and max night op prep
    let GB = 9125
    // GB=$EV3-$V3
    for i in 0..<365 { d23[GB + i] = d22[EV + i] - d21[V + i] }

    /// Surplus CO2 prod cap after max day harm and min night op prep
    let GC = 9490
    // GC=$EW3-$U3
    for i in 0..<365 { d23[GC + i] = d22[EW + i] - d21[U + i] }

    /// Surplus H2 prod cap after min day harm and min night op prep
    let GD = 9855
    // GD=$EY3-$W3
    for i in 0..<365 { d23[GD + i] = d22[EY + i] - d21[W + i] }

    /// Surplus H2 prod cap after min day harm and max night op prep
    let GE = 10220
    // GE=$EY3-$X3
    for i in 0..<365 { d23[GE + i] = d22[EY + i] - d21[X + i] }

    /// Surplus H2 prod cap after max day harm and min night op prep
    let GF = 10585
    // GF=$EZ3-$W3
    for i in 0..<365 { d23[GF + i] = d22[EZ + i] - d21[W + i] }

    /// Optimal harmonious day prod after min night prep due to prod cap limits
    let GH = 10950
    // GH=IF(OR($AE3=0,FC3<0,FF3<0,FI3<0,FL3<0,FO3<0,FR3<0,FU3<0,FX3<0,GA3<0,GD3<0),-1,MIN(1,IFERROR(FC3/MAX(0,FC3-FE3),1),IFERROR(FF3/MAX(0,FF3-FH3),1),IFERROR(FI3/MAX(0,FI3-FK3),1),IFERROR(FL3/MAX(0,FL3-FN3),1),IFERROR(FO3/MAX(0,FO3-FQ3),1),IFERROR(FR3/MAX(0,FR3-FT3),1),IFERROR(FU3/MAX(0,FU3-FW3),1),IFERROR(FX3/MAX(0,FX3-FZ3),1),IFERROR(GA3/MAX(0,GA3-GC3),1),IFERROR(GD3/MAX(0,GD3-GF3),1)))
    for i in 0..<365 {
      d23[GH + i] = iff(
        or(
          d21[AE + i].isZero, d23[FC + i] < 0, d23[FF + i] < 0, d23[FI + i] < 0, d23[FL + i] < 0,
          d23[FO + i] < 0, d23[FR + i] < 0, d23[FU + i] < 0, d23[FX + i] < 0, d23[GA + i] < 0,
          d23[GD + i] < Double.zero), -1,
        min(
          1, ifFinite(d23[FC + i] / max(Double.zero, d23[FC + i] - d23[FE + i]), 1),
          ifFinite(d23[FF + i] / max(Double.zero, d23[FF + i] - d23[FH + i]), 1),
          ifFinite(d23[FI + i] / max(Double.zero, d23[FI + i] - d23[FK + i]), 1),
          ifFinite(d23[FL + i] / max(Double.zero, d23[FL + i] - d23[FN + i]), 1),
          ifFinite(d23[FO + i] / max(Double.zero, d23[FO + i] - d23[FQ + i]), 1),
          ifFinite(d23[FR + i] / max(Double.zero, d23[FR + i] - d23[FT + i]), 1),
          ifFinite(d23[FU + i] / max(Double.zero, d23[FU + i] - d23[FW + i]), 1),
          ifFinite(d23[FX + i] / max(Double.zero, d23[FX + i] - d23[FZ + i]), 1),
          ifFinite(d23[GA + i] / max(Double.zero, d23[GA + i] - d23[GC + i]), 1),
          ifFinite(d23[GD + i] / max(Double.zero, d23[GD + i] - d23[GF + i]), 1)))
    }

    /// Surplus harm op period el after opt day harm op and min night op prep
    let GI = 11315
    // GI=IF(GH3<0,0,ROUND(($EB3+($EC3-$EB3)*GH3)+($EH3+($EI3-$EH3)*GH3)-$O3-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$Q3-($EE3+($EF3-$EE3)*GH3))/El_boiler_eff,5))
    for i in 0..<365 {
      d23[GI + i] = iff(
        d23[GH + i] < Double.zero, Double.zero,
        round(
          (d22[EB + i] + (d22[EC + i] - d22[EB + i]) * d23[GH + i])
            + (d22[EH + i] + (d22[EI + i] - d22[EH + i]) * d23[GH + i]) - d21[O + i] - max(
              0,
              d22[EA + i] + d21[E + i] + max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i]
                - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(
              0, d21[Q + i] - (d22[EE + i] + (d22[EF + i] - d22[EE + i]) * d23[GH + i])) / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after opt day harm op and max night op prep
    let GJ = 11680
    // GJ=IF(GH3<0,0,ROUND(($EB3+($EC3-$EB3)*GH3)+($EH3+($EI3-$EH3)*GH3)-$P3-MAX(0,$EA3+$F3+MAX(0,$H3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$R3-($EE3+($EF3-$EE3)*GH3))/El_boiler_eff,5))
    for i in 0..<365 {
      d23[GJ + i] = iff(
        d23[GH + i] < Double.zero, Double.zero,
        round(
          (d22[EB + i] + (d22[EC + i] - d22[EB + i]) * d23[GH + i])
            + (d22[EH + i] + (d22[EI + i] - d22[EH + i]) * d23[GH + i]) - d21[P + i] - max(
              0,
              d22[EA + i] + d21[F + i] + max(Double.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i]
                - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(
              0, d21[R + i] - (d22[EE + i] + (d22[EF + i] - d22[EE + i]) * d23[GH + i])) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and min night op prep
    let GK = 12045
    // GK=IF(GH3<0,0,ROUND((($EK3+($EL3-$EK3)*GH3)+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3-MAX(0,$G3-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[GK + i] = iff(
        d23[GH + i] < Double.zero, Double.zero,
        round(
          ((d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[GH + i]) + d22[EM + i]) * BESS_chrg_eff
            + d22[EJ + i] - d22[EA + i] - d21[E + i] - max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and max night op prep
    let GL = 12410
    // GL=IF(GH3<0,0,ROUND((($EK3+($EL3-$EK3)*GH3)+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$F3-MAX(0,$H3-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[GL + i] = iff(
        d23[GH + i] < Double.zero, Double.zero,
        round(
          ((d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[GH + i]) + d22[EM + i]) * BESS_chrg_eff
            + d22[EJ + i] - d22[EA + i] - d21[F + i] - max(Double.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus harm op heat after opt day harm and min night op prep
    let GM = 12775
    // GM=IF(GH3<0,0,ROUND($EE3+($EF3-$EE3)*GH3+MAX(0,$EB3+($EC3-$EB3)*GH3+$EH3+($EI3-$EH3)*GH3-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-$O3)*El_boiler_eff-$Q3,5))
    for i in 0..<365 {
      d23[GM + i] = iff(
        d23[GH + i] < Double.zero, Double.zero,
        round(
          d22[EE + i] + (d22[EF + i] - d22[EE + i]) * d23[GH + i] + max(
            0,
            d22[EB + i] + (d22[EC + i] - d22[EB + i]) * d23[GH + i] + d22[EH + i]
              + (d22[EI + i] - d22[EH + i]) * d23[GH + i] - max(
                0,
                d22[EA + i] + d21[E + i] + max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i]
                  - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - d21[O + i]) * El_boiler_eff - d21[Q + i],
          5))
    }

    /// Surplus harm op heat after opt day harm and max night op prep
    let GN = 13140
    // GN=IF(GH3<0,0,ROUND(($EE3+($EF3-$EE3)*GH3)+MAX(0,($EB3+($EC3-$EB3)*GH3)+($EH3+($EI3-$EH3)*GH3)-MAX(0,$EA3+$F3+MAX(0,$H3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-$P3)*El_boiler_eff-$R3,5))
    for i in 0..<365 {
      d23[GN + i] = iff(
        d23[GH + i] < Double.zero, Double.zero,
        round(
          (d22[EE + i] + (d22[EF + i] - d22[EE + i]) * d23[GH + i]) + max(
            0,
            (d22[EB + i] + (d22[EC + i] - d22[EB + i]) * d23[GH + i])
              + (d22[EH + i] + (d22[EI + i] - d22[EH + i]) * d23[GH + i]) - max(
                0,
                d22[EA + i] + d21[F + i] + max(Double.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff - d22[EJ + i]
                  - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - d21[P + i]) * El_boiler_eff - d21[R + i],
          5))
    }

    /// Surplus outside harm op heat after opt day harm and min night op prep
    let GO = 13505
    // GO=IF(GH3<0,0,ROUND($EG3+MAX(0,(($EK3+($EL3-$EK3)*GH3)+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3)*El_boiler_eff-$G3,5))
    for i in 0..<365 {
      d23[GO + i] = iff(
        d23[GH + i] < Double.zero, Double.zero,
        round(
          d22[EG + i] + max(
            0,
            ((d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[GH + i]) + d22[EM + i]) * BESS_chrg_eff
              + d22[EJ + i] - d22[EA + i] - d21[E + i]) * El_boiler_eff - d21[G + i], 5))
    }

    /// Surplus outside harm op heat after opt day harm and max night op prep
    let GP = 13870
    // GP=IF(GH3<0,0,ROUND($EG3+MAX(0,($EK3+($EL3-$EK3)*GH3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$F3)*El_boiler_eff-$H3,5))
    for i in 0..<365 {
      d23[GP + i] = iff(
        d23[GH + i] < Double.zero, Double.zero,
        round(
          d22[EG + i] + max(
            0,
            (d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[GH + i] + d22[EM + i]) * BESS_chrg_eff
              + d22[EJ + i] - d22[EA + i] - d21[F + i]) * El_boiler_eff - d21[H + i], 5))
    }

    /// Surplus BESS cap after opt harm op and min night op prep during harm op period
    let GQ = 14235
    // GQ=IF(GH3<0,0,ROUND(($EK3+($EL3-$EK3)*GH3)-MAX(0,$EA3+$E3+MIN($ER3,MAX(0,$G3-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d23[GQ + i] = iff(
        d23[GH + i] < Double.zero, Double.zero,
        round(
          (d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[GH + i]) - max(
            0,
            d22[EA + i] + d21[E + i] + min(d22[ER + i], max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff)
              - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus BESS cap after opt harm op and max night op prep during harm op period
    let GR = 14600
    // GR=IF(GH3<0,0,ROUND(($EK3+($EL3-$EK3)*GH3)-MAX(0,$EA3+$F3+MIN($ER3,MAX(0,$H3-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d23[GR + i] = iff(
        d23[GH + i] < Double.zero, Double.zero,
        round(
          (d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[GH + i]) - max(
            0,
            d22[EA + i] + d21[F + i] + min(d22[ER + i], max(Double.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff)
              - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep during harm op period
    let GS = 14965
    // GS=IF(OR(GH3<0,El_boiler_cap_ud=0),0,ROUND(($EP3+($EQ3-$EP3)*GH3)-MAX(0,$Q3-($EE3+($EF3-$EE3)*GH3))/El_boiler_eff,5))
    for i in 0..<365 {
      d23[GS + i] = iff(
        or(d23[GH + i] < 0, El_boiler_cap_ud.isZero), 0,
        round(
          (d22[EP + i] + (d22[EQ + i] - d22[EP + i]) * d23[GH + i]) - max(
            0, d21[Q + i] - (d22[EE + i] + (d22[EF + i] - d22[EE + i]) * d23[GH + i])) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and max night op prep during harm op period
    let GT = 15330
    // GT=IF(OR(GH3<0,El_boiler_cap_ud=0),0,ROUND(($EP3+($EQ3-$EP3)*GH3)-MAX(0,$R3-($EE3+($EF3-$EE3)*GH3))/El_boiler_eff,5))
    for i in 0..<365 {
      d23[GT + i] = iff(
        or(d23[GH + i] < 0, El_boiler_cap_ud.isZero), 0,
        round(
          (d22[EP + i] + (d22[EQ + i] - d22[EP + i]) * d23[GH + i]) - max(
            0, d21[R + i] - (d22[EE + i] + (d22[EF + i] - d22[EE + i]) * d23[GH + i])) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep outside of harm op period
    let GU = 15695
    // GU=IF(OR(GH3<0,El_boiler_cap_ud=0),0,ROUND($ER3-MAX(0,$G3-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[GU + i] = iff(
        or(d23[GH + i] < 0, El_boiler_cap_ud.isZero), 0,
        round(d22[ER + i] - max(Double.zero, d21[G + i] - d22[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and max night op prep outside of harm op period
    let GV = 16060
    // GV=IF(OR(GH3<0,El_boiler_cap_ud=0),0,ROUND($ER3-MAX(0,$H3-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[GV + i] = iff(
        or(d23[GH + i] < 0, El_boiler_cap_ud.isZero), 0,
        round(d22[ER + i] - max(Double.zero, d21[H + i] - d22[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    let GW = 16425
    // GW=IF(GH3<0,0,ROUND(($ES3+($ET3-$ES3)*GH3)-$S3,5))
    for i in 0..<365 {
      d23[GW + i] = iff(
        d23[GH + i] < Double.zero, Double.zero, round((d22[ES + i] + (d22[ET + i] - d22[ES + i]) * d23[GH + i]) - d21[S + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    let GX = 16790
    // GX=IF(GH3<0,0,ROUND(($ES3+($ET3-$ES3)*GH3)-$T3,5))
    for i in 0..<365 {
      d23[GX + i] = iff(
        d23[GH + i] < Double.zero, Double.zero, round((d22[ES + i] + (d22[ET + i] - d22[ES + i]) * d23[GH + i]) - d21[T + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    let GY = 17155
    // GY=IF(GH3<0,0,ROUND(($EV3+($EW3-$EV3)*GH3)-$U3,5))
    for i in 0..<365 {
      d23[GY + i] = iff(
        d23[GH + i] < Double.zero, Double.zero, round((d22[EV + i] + (d22[EW + i] - d22[EV + i]) * d23[GH + i]) - d21[U + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    let GZ = 17520
    // GZ=IF(GH3<0,0,ROUND(($EV3+($EW3-$EV3)*GH3)-$V3,5))
    for i in 0..<365 {
      d23[GZ + i] = iff(
        d23[GH + i] < Double.zero, Double.zero, round((d22[EV + i] + (d22[EW + i] - d22[EV + i]) * d23[GH + i]) - d21[V + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    let HA = 17885
    // HA=IF(GH3=0,0,ROUND(($EY3+($EZ3-$EY3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-$W3,5))
    for i in 0..<365 {
      d23[HA + i] = iff(
        d23[GH + i] < Double.zero, 0,
        round(
          (d22[EY + i]
            + (d22[EZ + i] - d22[EY + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (d23[GH + i] - Overall_harmonious_min_perc))
            - d21[W + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    let HB = 18250
    // HB=IF(GH3<0,0,ROUND(($EY3+($EZ3-$EY3)*GH3)-$X3,5))
    for i in 0..<365 {
      d23[HB + i] = iff(
        d23[GH + i] < Double.zero, Double.zero, round((d22[EY + i] + (d22[EZ + i] - d22[EY + i]) * d23[GH + i]) - d21[X + i], 5))
    }

    /// Max harmonious day prod after min night prep due to prod cap limits
    let HC = 18615
    // HC=IF(OR(GH3<0,GI3<0,GK3<0,GM3<0,GO3<0,GQ3<0,GS3<0,GU3<0,GW3<0,GY3<0,HA3<0),-1,MIN(1,IFERROR(GI3/MAX(0,GI3-GJ3),1),IFERROR(GK3/MAX(0,GK3-GL3),1),IFERROR(GM3/MAX(0,GM3-GN3),1),IFERROR(GO3/MAX(0,GO3-GP3),1),IFERROR(GQ3/MAX(0,GQ3-GR3),1),IFERROR(GS3/MAX(0,GS3-GT3),1),IFERROR(GU3/MAX(0,GU3-GV3),1),IFERROR(GW3/MAX(0,GW3-GX3),1),IFERROR(GY3/MAX(0,GY3-GZ3),1),IFERROR(HA3/MAX(0,HA3-HB3),1)))
    for i in 0..<365 {
      d23[HC + i] = iff(
        or(
          d23[GH + i] < 0, d23[GI + i] < 0, d23[GK + i] < 0, d23[GM + i] < 0, d23[GO + i] < 0,
          d23[GQ + i] < 0, d23[GS + i] < 0, d23[GU + i] < 0, d23[GW + i] < 0, d23[GY + i] < 0,
          d23[HA + i] < Double.zero), -1,
        min(
          1, ifFinite(d23[GI + i] / max(Double.zero, d23[GI + i] - d23[GJ + i]), 1),
          ifFinite(d23[GK + i] / max(Double.zero, d23[GK + i] - d23[GL + i]), 1),
          ifFinite(d23[GM + i] / max(Double.zero, d23[GM + i] - d23[GN + i]), 1),
          ifFinite(d23[GO + i] / max(Double.zero, d23[GO + i] - d23[GP + i]), 1),
          ifFinite(d23[GQ + i] / max(Double.zero, d23[GQ + i] - d23[GR + i]), 1),
          ifFinite(d23[GS + i] / max(Double.zero, d23[GS + i] - d23[GT + i]), 1),
          ifFinite(d23[GU + i] / max(Double.zero, d23[GU + i] - d23[GV + i]), 1),
          ifFinite(d23[GW + i] / max(Double.zero, d23[GW + i] - d23[GX + i]), 1),
          ifFinite(d23[GY + i] / max(Double.zero, d23[GY + i] - d23[GZ + i]), 1),
          ifFinite(d23[HA + i] / max(Double.zero, d23[HA + i] - d23[HB + i]), 1)))
    }

    /// Max Equiv harmonious night prod due to prod cap limits
    let HE = 18980
    // HE=IF(OR($AE3=0,FC3<0,FF3<0,FI3<0,FL3<0,FO3<0,FR3<0,FU3<0,FX3<0,GA3<0,GD3<0),-1,MIN(1,IFERROR(FC3/MAX(0,FC3-FD3),1),IFERROR(FF3/MAX(0,FF3-FG3),1),IFERROR(FI3/MAX(0,FI3-FJ3),1),IFERROR(FL3/MAX(0,FL3-FM3),1),IFERROR(FO3/MAX(0,FO3-FP3),1),IFERROR(FR3/MAX(0,FR3-FS3),1),IFERROR(FU3/MAX(0,FU3-FV3),1),IFERROR(FX3/MAX(0,FX3-FY3),1),IFERROR(GA3/MAX(0,GA3-GB3),1),IFERROR(GD3/MAX(0,GD3-GE3),1)))
    for i in 0..<365 {
      d23[HE + i] = iff(
        or(
          d21[AE + i].isZero, d23[FC + i] < 0, d23[FF + i] < 0, d23[FI + i] < 0, d23[FL + i] < 0,
          d23[FO + i] < 0, d23[FR + i] < 0, d23[FU + i] < 0, d23[FX + i] < 0, d23[GA + i] < 0,
          d23[GD + i] < Double.zero), -1,
        min(
          1, ifFinite(d23[FC + i] / max(Double.zero, d23[FC + i] - d23[FD + i]), 1),
          ifFinite(d23[FF + i] / max(Double.zero, d23[FF + i] - d23[FG + i]), 1),
          ifFinite(d23[FI + i] / max(Double.zero, d23[FI + i] - d23[FJ + i]), 1),
          ifFinite(d23[FL + i] / max(Double.zero, d23[FL + i] - d23[FM + i]), 1),
          ifFinite(d23[FO + i] / max(Double.zero, d23[FO + i] - d23[FP + i]), 1),
          ifFinite(d23[FR + i] / max(Double.zero, d23[FR + i] - d23[FS + i]), 1),
          ifFinite(d23[FU + i] / max(Double.zero, d23[FU + i] - d23[FV + i]), 1),
          ifFinite(d23[FX + i] / max(Double.zero, d23[FX + i] - d23[FY + i]), 1),
          ifFinite(d23[GA + i] / max(Double.zero, d23[GA + i] - d23[GB + i]), 1),
          ifFinite(d23[GD + i] / max(Double.zero, d23[GD + i] - d23[GE + i]), 1)))
    }

    /// Surplus harm op period el after min day harm op and opt night op prep
    let HF = 19345
    // HF=IF(HE3=0,0,ROUND($EB3+$EH3-($O3+($P3-$O3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))-MAX(0,$EA3+($E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))+MAX(0,$G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$Q3+($R3-$Q3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)-$EE3)/El_boiler_eff,5))
    // HF=IF(HE3<0,0,ROUND($EB3+$EH3-($O3+($P3-$O3)*HE3)-MAX(0,$EA3+($E3+($F3-$E3)*HE3)+MAX(0,($G3+($H3-$G3)*HE3)-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,($Q3+($R3-$Q3)*HE3)-$EE3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[HF + i] = iff(
        d23[HE + i] < Double.zero, Double.zero,
        round(
          d22[EB + i] + d22[EH + i] - (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[HE + i]) - max(
            0,
            d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i]) + max(
              0, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]) - d22[EG + i]) / El_boiler_eff
              - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(
              0, (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[HE + i]) - d22[EE + i]) / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after max day harm op and opt night op prep
    let HG = 19710
    // HG=IF(HE3<0,0,ROUND($EC3+$EI3-($O3+($P3-$O3)*HE3)-MAX(0,$EA3+($E3+($F3-$E3)*HE3)+MAX(0,($G3+($H3-$G3)*HE3)-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,($Q3+($R3-$Q3)*HE3)-$EF3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[HG + i] = iff(
        d23[HE + i] < Double.zero, Double.zero,
        round(
          d22[EC + i] + d22[EI + i] - (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[HE + i]) - max(
            0,
            d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i]) + max(
              0, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]) - d22[EG + i]) / El_boiler_eff
              - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(
              0, (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[HE + i]) - d22[EF + i]) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after min day harm and opt night op prep
    let HH = 20075
    // HH=IF(HE3<0,0,ROUND(($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-($E3+($F3-$E3)*HE3)-MAX(0,($G3+($H3-$G3)*HE3)-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[HH + i] = iff(
        d23[HE + i] < Double.zero, Double.zero,
        round(
          (d22[EK + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i]
            - (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i]) - max(
              0, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]) - d22[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after max day harm and opt night op prep
    let HI = 20440
    // HI=IF(HE3<0,0,ROUND(($EL3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-($E3+($F3-$E3)*HE3)-MAX(0,($G3+($H3-$G3)*HE3)-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[HI + i] = iff(
        d23[HE + i] < Double.zero, Double.zero,
        round(
          (d22[EL + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i]
            - (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i]) - max(
              0, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]) - d22[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus harm op heat after min day harm and opt night op prep
    let HJ = 20805
    // HJ=IF(HE3<0,0,ROUND($EE3+MAX(0,$EB3+$EH3-MAX(0,$EA3+($E3+($F3-$E3)*HE3)+MAX(0,($G3+($H3-$G3)*HE3)-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-($O3+($P3-$O3)*HE3))*El_boiler_eff-($Q3+($R3-$Q3)*HE3),5))
    for i in 0..<365 {
      d23[HJ + i] = iff(
        d23[HE + i] < Double.zero, Double.zero,
        round(
          d22[EE + i] + max(
            0,
            d22[EB + i] + d22[EH + i] - max(
              0,
              d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i]) + max(
                0, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]) - d22[EG + i]) / El_boiler_eff
                - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff
              - (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[HE + i])) * El_boiler_eff
            - (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[HE + i]), 5))
    }

    /// Surplus harm op heat after max day harm and opt night op prep
    let HK = 21170
    // HK=IF(HE3<0,0,ROUND($EF3+MAX(0,$EC3+$EI3-MAX(0,$EA3+($E3+($F3-$E3)*HE3)+MAX(0,($G3+($H3-$G3)*HE3)-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-($O3+($P3-$O3)*HE3))*El_boiler_eff-($Q3+($R3-$Q3)*HE3),5))
    for i in 0..<365 {
      d23[HK + i] = iff(
        d23[HE + i] < Double.zero, Double.zero,
        round(
          d22[EF + i] + max(
            0,
            d22[EC + i] + d22[EI + i] - max(
              0,
              d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i]) + max(
                0, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]) - d22[EG + i]) / El_boiler_eff
                - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff
              - (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[HE + i])) * El_boiler_eff
            - (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[HE + i]), 5))
    }

    /// Surplus outside harm op heat after min day harm and opt night op prep
    let HL = 21535
    // HL=IF(HE3<0,0,ROUND($EG3+MAX(0,($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-($E3+($F3-$E3)*HE3))*El_boiler_eff-($G3+($H3-$G3)*HE3),5))
    for i in 0..<365 {
      d23[HL + i] = iff(
        d23[HE + i] < Double.zero, Double.zero,
        round(
          d22[EG + i] + max(
            0,
            (d22[EK + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i]
              - (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i])) * El_boiler_eff
            - (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]), 5))
    }

    /// Surplus outside harm op heat after max day harm and opt night op prep
    let HM = 21900
    // HM=IF(HE3<0,0,ROUND($EG3+MAX(0,($EL3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-($E3+($F3-$E3)*HE3))*El_boiler_eff-($G3+($H3-$G3)*HE3),5))
    for i in 0..<365 {
      d23[HM + i] = iff(
        d23[HE + i] < Double.zero, Double.zero,
        round(
          d22[EG + i] + max(
            0,
            (d22[EL + i] + d22[EM + i]) * BESS_chrg_eff + d22[EJ + i] - d22[EA + i]
              - (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i])) * El_boiler_eff
            - (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]), 5))
    }

    /// Surplus BESS cap after min harm op and opt night op prep during harm op period
    let HN = 22265
    // HN=IF(HE3<0,0,ROUND($EK3-MAX(0,$EA3+($E3+($F3-$E3)*HE3)+MIN($ER3,MAX(0,($G3+($H3-$G3)*HE3)-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d23[HN + i] = iff(
        d23[HE + i] < Double.zero, Double.zero,
        round(
          d22[EK + i] - max(
            0,
            d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i])
              + min(
                d22[ER + i],
                max(Double.zero, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]) - d22[EG + i]) / El_boiler_eff)
              - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus BESS cap after max harm op and opt night op prep during harm op period
    let HO = 22630
    // HO=IF(HE3<0,0,ROUND($EL3-MAX(0,$EA3+($E3+($F3-$E3)*HE3)+MIN($ER3,MAX(0,($G3+($H3-$G3)*HE3)-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      d23[HO + i] = iff(
        d23[HE + i] < Double.zero, Double.zero,
        round(
          d22[EL + i] - max(
            0,
            d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i])
              + min(
                d22[ER + i],
                max(Double.zero, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]) - d22[EG + i]) / El_boiler_eff)
              - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus el boiler cap after min harm op and opt night op prep during harm op period
    let HP = 22995
    // HP=IF(OR(El_boiler_cap_ud=0,HE3<0),0,ROUND($EP3-MAX(0,($Q3+($R3-$Q3)*HE3)-$EE3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[HP + i] = iff(
        or(El_boiler_cap_ud.isZero, d23[HE + i] < Double.zero), 0,
        round(
          d22[EP + i] - max(Double.zero, (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[HE + i]) - d22[EE + i])
            / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max harm op and opt night op prep during harm op period
    let HQ = 23360
    // HQ=IF(OR(El_boiler_cap_ud=0,HE3<0),0,ROUND($EQ3-MAX(0,($Q3+($R3-$Q3)*HE3)-$EF3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[HQ + i] = iff(
        or(El_boiler_cap_ud.isZero, d23[HE + i] < Double.zero), 0,
        round(
          d22[EQ + i] - max(Double.zero, (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[HE + i]) - d22[EF + i])
            / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after min harm op and opt night op prep outside of harm op period
    let HR = 23725
    // HR=IF(OR(El_boiler_cap_ud=0,HE3<0),0,ROUND($ER3-MAX(0,($G3+($H3-$G3)*HE3)-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[HR + i] = iff(
        or(El_boiler_cap_ud.isZero, d23[HE + i] < Double.zero), 0,
        round(
          d22[ER + i] - max(Double.zero, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]) - d22[EG + i])
            / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max harm op and opt night op prep outside of harm op period
    let HS = 24090
    // HS=IF(OR(El_boiler_cap_ud=0,HE3<0),0,ROUND($ER3-MAX(0,($G3+($H3-$G3)*HE3)-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      d23[HS + i] = iff(
        or(El_boiler_cap_ud.isZero, d23[HE + i] < Double.zero), 0,
        round(
          d22[ER + i] - max(Double.zero, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]) - d22[EG + i])
            / El_boiler_eff, 5))
    }
    /// Surplus RawMeth prod cap after min day harm and opt night op prep
    let HT = 24455
    // HT=IF(HE3<0,0,ROUND($ES3-($S3+($T3-$S3)*HE3),5))
    for i in 0..<365 {
      d23[HT + i] = iff(
        d23[HE + i] < Double.zero, Double.zero, round(d22[ES + i] - (d21[S + i] + (d21[T + i] - d21[S + i]) * d23[HE + i]), 5))
    }

    /// Surplus RawMeth prod cap after max day harm and opt night op prep
    let HU = 24820
    // HU=IF(HE3<0,0,ROUND($ET3-($S3+($T3-$S3)*HE3),5))
    for i in 0..<365 {
      d23[HU + i] = iff(
        d23[HE + i] < Double.zero, Double.zero, round(d22[ET + i] - (d21[S + i] + (d21[T + i] - d21[S + i]) * d23[HE + i]), 5))
    }

    /// Surplus CO2 prod cap after min day harm and opt night op prep
    let HV = 25185
    // HV=IF(HE3<0,0,ROUND($EV3-($U3+($V3-$U3)*HE3),5))
    for i in 0..<365 {
      d23[HV + i] = iff(
        d23[HE + i] < Double.zero, Double.zero, round(d22[EV + i] - (d21[U + i] + (d21[V + i] - d21[U + i]) * d23[HE + i]), 5))
    }

    /// Surplus CO2 prod cap after max day harm and opt night op prep
    let HW = 25550
    // HW=IF(HE3<0,0,ROUND($EW3-($U3+($V3-$U3)*HE3),5))
    for i in 0..<365 {
      d23[HW + i] = iff(
        d23[HE + i] < Double.zero, Double.zero, round(d22[EW + i] - (d21[U + i] + (d21[V + i] - d21[U + i]) * d23[HE + i]), 5))
    }

    /// Surplus H2 prod cap after min day harm and opt night op prep
    let HX = 25915
    // HX=IF(HE3<0,0,ROUND($EY3-($W3+($X3-$W3)*HE3),5))
    for i in 0..<365 {
      d23[HX + i] = iff(
        d23[HE + i] < Double.zero, Double.zero, round(d22[EY + i] - (d21[W + i] + (d21[X + i] - d21[W + i]) * d23[HE + i]), 5))
    }

    /// Surplus H2 prod cap after min day harm and opt night op prep
    let HY = 26280
    // HY=IF(HE3<0,0,ROUND($EZ3-($W3+($X3-$W3)*HE3),5))
    for i in 0..<365 {
      d23[HY + i] = iff(
        d23[HE + i] < Double.zero, Double.zero, round(d22[EZ + i] - (d21[W + i] + (d21[X + i] - d21[W + i]) * d23[HE + i]), 5))
    }

    /// Opt harm op period op during night prio operation
    let HZ = 26645
    // HZ=IF(OR(HE3<0,HF3<0,HH3<0,HJ3<0,HL3<0,HN3<0,HP3<0,HR3<0,HT3<0,HV3<0,HX3<0),-1,MIN(1,IFERROR(HF3/MAX(0,HF3-HG3),1),IFERROR(HH3/MAX(0,HH3-HI3),1),IFERROR(HJ3/MAX(0,HJ3-HK3),1),IFERROR(HL3/MAX(0,HL3-HM3),1),IFERROR(HN3/MAX(0,HN3-HO3),1),IFERROR(HP3/MAX(0,HP3-HQ3),1),IFERROR(HR3/MAX(0,HR3-HS3),1),IFERROR(HT3/MAX(0,HT3-HU3),1),IFERROR(HV3/MAX(0,HV3-HW3),1),IFERROR(HX3/MAX(0,HX3-HY3),1)))
    for i in 0..<365 {
      d23[HZ + i] = iff(
        or(
          d23[HE + i] < 0, d23[HF + i] < 0, d23[HH + i] < 0, d23[HJ + i] < 0, d23[HL + i] < 0,
          d23[HN + i] < 0, d23[HP + i] < 0, d23[HR + i] < 0, d23[HT + i] < 0, d23[HV + i] < 0,
          d23[HX + i] < Double.zero), -1,
        min(
          1, ifFinite(d23[HF + i] / max(Double.zero, d23[HF + i] - d23[HG + i]), 1),
          ifFinite(d23[HH + i] / max(Double.zero, d23[HH + i] - d23[HI + i]), 1),
          ifFinite(d23[HJ + i] / max(Double.zero, d23[HJ + i] - d23[HK + i]), 1),
          ifFinite(d23[HL + i] / max(Double.zero, d23[HL + i] - d23[HM + i]), 1),
          ifFinite(d23[HN + i] / max(Double.zero, d23[HN + i] - d23[HO + i]), 1),
          ifFinite(d23[HP + i] / max(Double.zero, d23[HP + i] - d23[HQ + i]), 1),
          ifFinite(d23[HR + i] / max(Double.zero, d23[HR + i] - d23[HS + i]), 1),
          ifFinite(d23[HT + i] / max(Double.zero, d23[HT + i] - d23[HU + i]), 1),
          ifFinite(d23[HV + i] / max(Double.zero, d23[HV + i] - d23[HW + i]), 1),
          ifFinite(d23[HX + i] / max(Double.zero, d23[HX + i] - d23[HY + i]), 1)))
    }

    /// el cons for harm op during harm op period incl grid import
    let IB = 27010
    // IB=IF($DR3=0,0,IF(HC3<0,MIN($DS3,MAX($DR3,$DS3+$EC3-MIN(BESS_cap_ud/BESS_chrg_eff,$EK3,MAX(0,$E3+$EA3+$DU3-$EJ3+MIN($ER3,($DZ3+$G3)/El_boiler_eff))/BESS_chrg_eff))),$DR3+($DS3-$DR3)*GH3))
    for i in 0..<365 {
      d23[IB + i] = iff(
        d22[DR + i] == Double.zero, 0,
        iff(
          d23[HC + i] < 0,
          min(
            d22[DS + i],
            max(
              d22[DR + i],
              d22[DS + i] + d22[EC + i]
                - min(
                  BESS_cap_ud / BESS_chrg_eff, d22[EK + i],
                  max(
                    0,
                    d21[E + i] + d22[EA + i] + d22[DU + i] - d22[EJ + i]
                      + min(d22[ER + i], (d22[DZ + i] + d21[G + i]) / El_boiler_eff)) / BESS_chrg_eff))),
          d22[DR + i] + (d22[DS + i] - d22[DR + i]) * d23[GH + i]))
    }

    /// el cons for night prep during harm op period
    let IC = 27375
    // IC=IF(HC3<0,0,($O3+($P3-$O3)*HC3))
    for i in 0..<365 {
      d23[IC + i] = iff(d23[HC + i] < Double.zero, Double.zero, (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[HC + i]))
    }

    /// el cons for BESS charging during harm op period
    let ID = 27740
    // ID=IF(OR(GH3<0,HC3<0),MIN(BESS_cap_ud/BESS_chrg_eff,$EK3,MAX($DR3,$E3+$EA3+$DU3-$EJ3+MIN($ER3,($G3+$DZ3)/El_boiler_eff))/BESS_chrg_eff,MIN($DS3,MAX(0,$DS3+$EC3-IB3))),MIN(($EK3+($EL3-$EK3)*GH3),MAX(0,$EA3+($E3+($F3-$E3)*HC3)+MIN($ER3,MAX(0,($G3+($H3-$G3)*HC3)-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff))
    for i in 0..<365 {
      d23[ID + i] = iff(
        or(d23[GH + i] < 0, d23[HC + i] < 0),
        min(
          BESS_cap_ud / BESS_chrg_eff, d22[EK + i],
          max(
            d22[DR + i],
            d21[E + i] + d22[EA + i] + d22[DU + i] - d22[EJ + i] + min(d22[ER + i], (d21[G + i] + d22[DZ + i]) / El_boiler_eff))
            / BESS_chrg_eff, min(d22[DS + i], max(0, d22[DS + i] + d22[EC + i] - d23[IB + i]))),
        min(
          (d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[GH + i]),
          max(
            0,
            d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HC + i])
              + min(d22[ER + i], max(0, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HC + i]) - d22[EG + i]) / El_boiler_eff)
              - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff))
    }

    /// Heat cons for night prep during harm op period
    let IE = 28105
    // IE=IF(HC3<0,0,($Q3+($R3-$Q3)*HC3))
    for i in 0..<365 {
      d23[IE + i] = iff(d23[HC + i] < Double.zero, Double.zero, (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[HC + i]))
    }

    /// CSP heat available after harm op during harm op period
    let IF = 28470
    // IF=IF(GH3<0,$EF3,$EE3+($EF3-$EE3)*GH3)
    for i in 0..<365 {
      d23[IF + i] = iff(
        d23[GH + i] < 0, d22[EF + i], d22[EE + i] + (d22[EF + i] - d22[EE + i]) * d23[GH + i])
    }

    /// El boiler heat prod for night prep during harm op period
    let IG = 28835
    // IG=IF(GH3<0,0,MIN(($EP3+($EQ3-$EP3)*GH3)*El_boiler_eff,MAX(0,IE3-IF3)))
    for i in 0..<365 {
      d23[IG + i] = iff(
        d23[GH + i] < Double.zero, Double.zero,
        min(
          (d22[EP + i] + (d22[EQ + i] - d22[EP + i]) * d23[GH + i]) * El_boiler_eff,
          max(Double.zero, d23[IE + i] - d23[IF + i])))
    }

    /// el cons of el boiler for night prep during harm op period
    let IH = 29200
    // IH=IG3/El_boiler_eff
    for i in 0..<365 { d23[IH + i] = d23[IG + i] / El_boiler_eff }

    /// PV available after harm op and stby during harm op period
    let II = 29565
    // II=IF(GH3<0,MAX(0,$EC3+MAX(0,$DS3-IB3)),$EB3+($EC3-$EB3)*GH3)
    for i in 0..<365 {
      d23[II + i] = iff(
        d23[GH + i] < 0, max(Double.zero, d22[EC + i] + max(Double.zero, d22[DS + i] - d23[IB + i])),
        d22[EB + i] + (d22[EC + i] - d22[EB + i]) * d23[GH + i])
    }

    /// grid input for harm op and stby during harm op period
    let IJ = 29930
    // IJ=IF(GH3<0,$DN3,$DM3+($DN3-$DM3)*GH3)
    for i in 0..<365 {
      d23[IJ + i] = iff(
        d23[GH + i] < 0, d22[DN + i], d22[DM + i] + (d22[DN + i] - d22[DM + i]) * d23[GH + i])
    }

    /// grid input for night prep during harm op period
    let IK = 30295
    // IK=MIN(IF(GH3<0,0,$EH3+($EI3-$EH3)*GH3),MAX(0,-(II3-IC3-ID3-IH3)))
    for i in 0..<365 {
      d23[IK + i] = min(
        iff(d23[GH + i] < Double.zero, Double.zero, d22[EH + i] + (d22[EI + i] - d22[EH + i]) * d23[GH + i]),
        max(Double.zero, -(d23[II + i] - d23[IC + i] - d23[ID + i] - d23[IH + i])))
    }

    /// Balance of electricity during harm op period
    let IL = 30660
    // IL=II3+IK3-IC3-ID3-IH3
    for i in 0..<365 { d23[IL + i] = d23[II + i] + d23[IK + i] - d23[IC + i] - d23[ID + i] - d23[IH + i] }

    /// Balance of heat during harm op period
    let IM = 31025
    // IM=IF3+IG3-IE3
    for i in 0..<365 { d23[IM + i] = d23[IF + i] + d23[IG + i] - d23[IE + i] }

    /// el cons for harm op outside of harm op period
    let IN = 31390
    // IN=IF(HC3<0,0,$E3+($F3-$E3)*HC3)
    for i in 0..<365 {
      d23[IN + i] = iff(d23[HC + i] < Double.zero, Double.zero, d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HC + i])
    }

    /// heat cons for harm op and stby outside of harm op period
    let IO = 31755
    // IO=IF(HC3<0,IF(GH3<0,$DZ3,$DY3+($DZ3-$DY3)*GH3),$G3+($H3-$G3)*HC3)
    for i in 0..<365 {
      d23[IO + i] = iff(
        d23[HC + i] < 0,
        iff(d23[GH + i] < 0, d22[DZ + i], d22[DY + i] + (d22[DZ + i] - d22[DY + i]) * d23[GH + i]),
        d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HC + i])
    }

    /// heat from CSP outside of harm op period
    let IP = 32120
    // IP=IF(HC3<0,0,$EG3)
    for i in 0..<365 { d23[IP + i] = iff(d23[HC + i] < Double.zero, Double.zero, d22[EG + i]) }

    let IQ = 32485
    // heat from el boiler outside of harm op period
    // IQ=MIN($ER3*El_boiler_eff,MAX(0,IO3+IF(HC3<0,Overall_heat_stby_cons*$B3+Overall_heat_stup_cons,0)-IP3))
    for i in 0..<365 {
      d23[IQ + i] = min(d22[ER + i] * El_boiler_eff, max(0, d23[IO + i] + iff(d23[HC + i] < 0, Overall_heat_stby_cons * day0[B0 + i] + Overall_heat_stup_cons, 0) - d23[IP + i]))
    }

    /// el cons by el boiler outside of harm op period
    let IR = 32850
    // IR=IQ3/El_boiler_eff
    for i in 0..<365 { d23[IR + i] = d23[IQ + i] / El_boiler_eff }

    /// el cons not covered by PV outside of harm op period
    let IS = 33215
    // IS=$EA3+IF(HC3>=0,0,IF(GH3<0,$DU3,$DT3+($DU3-$DT3)*GH3))
    for i in 0..<365 {
      d23[IS + i] =
        d22[EA + i]
        + iff(
          d23[HC + i] >= 0, 0,
          iff(d23[GH + i] < 0, d22[DU + i], d22[DT + i] + (d22[DU + i] - d22[DT + i]) * d23[GH + i]))
    }

    /// el from harm op period charged BESS discharging for stby outside of harm op period
    let IU = 33945
    // IU=ID3*BESS_chrg_eff
    for i in 0..<365 { d23[IU + i] = d23[ID + i] * BESS_chrg_eff }

    /// El to BESS charging outside harm op period
    let IT = 33580
    // IT=MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,IS3+IR3+IF(HC3<0,$E3,0)+IN3-IU3)/BESS_chrg_eff,IF(HC3>=0,$EM3,IF(GH3<0,$EO3,$EN3+($EO3-$EN3)*GH3)))
    for i in 0..<365 {
      d23[IT + i] = min(
        BESS_cap_ud / BESS_chrg_eff,
        max(Double.zero, d23[IS + i] + d23[IR + i] + iff(d23[HC + i] < 0, d21[E + i], Double.zero) + d23[IN + i] - d23[IU + i])
          / BESS_chrg_eff,
        iff(
          d23[HC + i] >= 0, d22[EM + i],
          iff(d23[GH + i] < 0, d22[EO + i], d22[EN + i] + (d22[EO + i] - d22[EN + i]) * d23[GH + i])))
    }

    // El to BESS charging outside harm op period
    // IT=MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,IS3+IR3+IF(HC3<0,Overall_stby_cons*$B3+Overall_stup_cons,0)+IN3-IU3)/BESS_chrg_eff,IF(HC3>=0,$EM3,IF(GH3<0,$EO3,$EN3+($EO3-$EN3)*GH3)))
    for i in 0..<365 {
      d23[IT + i] = min(
        BESS_cap_ud / BESS_chrg_eff,
        max(0, d23[IS + i] + d23[IR + i] + iff(d23[HC + i] < 0, Overall_stby_cons * day0[B0 + i] + Overall_stup_cons, 0) + d23[IN + i] - d23[IU + i]) / BESS_chrg_eff,
        iff(d23[HC + i] >= Double.zero, d22[EM + i], iff(d23[GH + i] < 0, d22[EO + i], d22[EN + i] + (d22[EO + i] - d22[EN + i]) * d23[GH + i])))
    }

    let IV = 34310
    // max possible grid input outside of harm op period
    // IV=MIN($DO3+$EJ3,MAX(0,-IT3*BESS_chrg_eff-IU3+IN3+IF(HC3<0,Overall_stby_cons*$B3+Overall_stup_cons,0)+IR3+IS3))
    for i in 0..<365 {
      d23[IV + i] = min(
        d22[DO + i] + d22[EJ + i],
        max(0, -d23[IT + i] * BESS_chrg_eff - d23[IU + i] + d23[IN + i] + iff(d23[HC + i] < 0, Overall_stby_cons * day0[B0 + i] + Overall_stup_cons, 0) + d23[IR + i] + d23[IS + i]))
    }
    let IW = 34675

    // Balance of electricity outside of harm op period
    // IW=IT3*BESS_chrg_eff+IU3+IV3-IN3-IF(HC3<0,Overall_stby_cons*$B3+Overall_stup_cons,0)-IR3-IS3
    for i in 0..<365 {
      d23[IW + i] = d23[IT + i] * BESS_chrg_eff + d23[IU + i] + d23[IV + i] - d23[IN + i] - iff(d23[HC + i] < 0, Overall_stby_cons * day0[B0 + i] + Overall_stup_cons, 0) - d23[IR + i] - d23[IS + i]
    }

    let IX = 35040
    // Balance of heat outside of harm op period
    // IX=IP3+IQ3-IF(HC3<0,Overall_heat_stby_cons*$B3+Overall_heat_stup_cons,0)-IO3
    for i in 0..<365 { d23[IX + i] = d23[IP + i] + d23[IQ + i] - iff(d23[HC + i] < 0, Overall_heat_stby_cons * day0[B0 + i] + Overall_heat_stup_cons, 0) - d23[IO + i] }

    let IY = 35405
    // Pure Methanol prod with min night prep and resp day op
    // IY=IFERROR(((MAX(0,IB3/$C3-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethDist_harmonious_max_perc-MethDist_harmonious_min_perc)+MethDist_harmonious_min_perc)*$C3+IF(HC3<0,0,$B3*(($AE3-A_equiv_harmonious_min_perc)*HC3/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_MethDist_max_perc-A_MethDist_min_perc)+A_MethDist_min_perc)),0)*MethDist_Meth_nom_prod_ud
    for i in 0..<365 {
      d23[IY + i] =
        ifFinite(
          ((max(0, d23[IB + i] / day0[C0 + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
            * (MethDist_harmonious_max_perc - MethDist_harmonious_min_perc) + MethDist_harmonious_min_perc) * day0[C0 + i]
            + iff(
              d23[HC + i] < 0, 0,
              day0[B0 + i]
                * ((d21[AE + i] - equiv_harmonious_min_perc[j]) * d23[HC + i] / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (MethDist_max_perc[j] - MethDist_min_perc[j]) + MethDist_min_perc[j])), 0) * MethDist_Meth_nom_prod_ud
    }
    /// Missing heat
    let IZ = 36500
    // IZ=MAX(0,-IM3)+MAX(0,-IX3)
    for i in 0..<365 { d23[IZ + i] = max(0, -d23[IM + i]) + max(0, -d23[IX + i]) }

    /// grid export
    let JA = 35770
    // JA=MAX(0,MIN(IL3,IF(GH3<0,$DW3,($DV3+($DW3-$DV3)*GH3))))+MAX(0,MIN(IW3,IF(OR(GH3<0,HC3<0),0,$DX3)))
    for i in 0..<365 {
      d23[JA + i] =
        max(0, min(d23[IL + i], iff(d23[GH + i] < 0, d22[DW + i], (d22[DV + i] + (d22[DW + i] - d22[DV + i]) * d23[GH + i]))))
        + max(0, min(d23[IW + i], iff(or(d23[GH + i] < 0, d23[HC + i] < 0), 0, d22[DX + i])))
    }

    /// grid import
    let JB = 36135
    // JB=(MAX(0,-IL3)+MAX(0,-IW3)+IZ3/El_boiler_eff)*EDG_elec_cost_factor+IJ3+IK3+IV3
    for i in 0..<365 {
      d23[JB + i] =
        (max(0, -d23[IL + i]) + max(0, -d23[IW + i]) + d23[IZ + i] / El_boiler_eff) * EDG_elec_cost_factor + d23[IJ + i]
        + d23[IK + i] + d23[IV + i]
    }

    /// el cons for harm op during harm op period
    let JD = 36865
    // JD=IF($DR3=0,0,IF(HZ3<0,MIN($DS3,MAX($DR3,$DS3+$EC3-MIN(BESS_cap_ud/BESS_chrg_eff,$EK3,MAX(0,$E3+$EA3+$DU3-$EJ3+MIN($ER3,($DZ3+$G3)/El_boiler_eff))/BESS_chrg_eff))),($DR3+($DS3-$DR3)*HZ3)))
    for i in 0..<365 {
      d23[JD + i] = iff(
        d22[DR + i] == Double.zero, 0,
        iff(
          d23[HZ + i] < 0,
          min(
            d22[DS + i],
            max(
              d22[DR + i],
              d22[DS + i] + d22[EC + i]
                - min(
                  BESS_cap_ud / BESS_chrg_eff, d22[EK + i],
                  max(
                    0,
                    d21[E + i] + d22[EA + i] + d22[DU + i] - d22[EJ + i]
                      + min(d22[ER + i], (d22[DZ + i] + d21[G + i]) / El_boiler_eff)) / BESS_chrg_eff))),
          (d22[DR + i] + (d22[DS + i] - d22[DR + i]) * d23[HZ + i])))
    }

    /// el cons for night prep during harm op period
    let JE = 37230
    // JE=IF(HE3<0,0,($O3+($P3-$O3)*HE3))
    for i in 0..<365 {
      d23[JE + i] = iff(d23[HE + i] < Double.zero, Double.zero, (d21[O + i] + (d21[P + i] - d21[O + i]) * d23[HE + i]))
    }

    /// el cons for BESS charging during harm op period
    let JF = 37595
    // JF=IF(OR(HE3<0,HZ3<0),MIN(BESS_cap_ud/BESS_chrg_eff,$EK3,MAX($DR3,$E3+$EA3+$DU3-$EJ3+MIN($ER3,($G3+$DZ3)/El_boiler_eff))/BESS_chrg_eff,MIN($DS3,MAX(0,$DS3+$EC3-IB3))),MIN(($EK3+($EL3-$EK3)*HZ3),MAX(0,$EA3+($E3+($F3-$E3)*HE3)+MIN($ER3,MAX(0,($G3+($H3-$G3)*HE3)-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff))
    for i in 0..<365 {
      d23[JF + i] = iff(
        or(d23[HE + i] < 0, d23[HZ + i] < 0),
        min(
          BESS_cap_ud / BESS_chrg_eff, d22[EK + i],
          max(
            d22[DR + i],
            d21[E + i] + d22[EA + i] + d22[DU + i] - d22[EJ + i] + min(d22[ER + i], (d21[G + i] + d22[DZ + i]) / El_boiler_eff))
            / BESS_chrg_eff, min(d22[DS + i], max(0, d22[DS + i] + d22[EC + i] - d23[IB + i]))),
        min(
          (d22[EK + i] + (d22[EL + i] - d22[EK + i]) * d23[HZ + i]),
          max(
            0,
            d22[EA + i] + (d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i])
              + min(d22[ER + i], max(0, (d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i]) - d22[EG + i]) / El_boiler_eff)
              - d22[EJ + i] - d22[EM + i] * BESS_chrg_eff) / BESS_chrg_eff))
    }

    /// Heat cons for night prep during harm op period
    let JG = 37960
    // JG=IF(HE3<0,0,($Q3+($R3-$Q3)*HE3))
    for i in 0..<365 {
      d23[JG + i] = iff(d23[HE + i] < Double.zero, Double.zero, (d21[Q + i] + (d21[R + i] - d21[Q + i]) * d23[HE + i]))
    }

    /// CSP heat available after harm op during harm op period
    let JH = 38325
    // JH=IF(HZ3<0,$EF3,($EE3+($EF3-$EE3)*HZ3))
    for i in 0..<365 {
      d23[JH + i] = iff(
        d23[HZ + i] < 0, d22[EF + i], (d22[EE + i] + (d22[EF + i] - d22[EE + i]) * d23[HZ + i]))
    }

    /// El boiler heat prod for night prep during harm op period
    let JI = 38690
    // JI=IF(HZ3<0,0,MIN(($EP3+($EQ3-$EP3)*HZ3)*El_boiler_eff,MAX(0,JG3-JH3)))
    for i in 0..<365 {
      d23[JI + i] = iff(
        d23[HZ + i] < Double.zero, Double.zero,
        min(
          (d22[EP + i] + (d22[EQ + i] - d22[EP + i]) * d23[HZ + i]) * El_boiler_eff,
          max(Double.zero, d23[JG + i] - d23[JH + i])))
    }

    /// el cons of el boiler for night prep during harm op period
    let JJ = 39055
    // JJ=JI3/El_boiler_eff
    for i in 0..<365 { d23[JJ + i] = d23[JI + i] / El_boiler_eff }

    /// PV available after harm op and stby during harm op period
    let JK = 39420
    // JK=IF(HZ3<0,MAX(0,$EC3+MAX(0,$DS3-JD3)),$EB3+($EC3-$EB3)*HZ3)
    for i in 0..<365 {
      d23[JK + i] = iff(
        d23[HZ + i] < 0, max(Double.zero, d22[EC + i] + max(Double.zero, d22[DS + i] - d23[JD + i])),
        d22[EB + i] + (d22[EC + i] - d22[EB + i]) * d23[HZ + i])
    }

    /// grid input for harm op and stby during harm op period
    let JL = 39785
    // JL=IF(HZ3<0,$DN3,$DM3+($DN3-$DM3)*HZ3)
    for i in 0..<365 {
      d23[JL + i] = iff(
        d23[HZ + i] < 0, d22[DN + i], d22[DM + i] + (d22[DN + i] - d22[DM + i]) * d23[HZ + i])
    }

    /// grid input for night prep during harm op period
    let JM = 40150
    // JM=MIN(IF(HZ3<0,0,$EH3+($EI3-$EH3)*HZ3),MAX(0,-(JK3-JE3-JF3-JJ3)))
    for i in 0..<365 {
      d23[JM + i] = min(
        iff(d23[HZ + i] < Double.zero, Double.zero, d22[EH + i] + (d22[EI + i] - d22[EH + i]) * d23[HZ + i]),
        max(Double.zero, -(d23[JK + i] - d23[JE + i] - d23[JF + i] - d23[JJ + i])))
    }

    /// Balance of electricity during harm op period
    let JN = 40515
    // JN=JK3+JM3-JE3-JF3-JJ3
    for i in 0..<365 { 
      d23[JN + i] = d23[JK + i] + d23[JM + i] - d23[JE + i] - d23[JF + i] - d23[JJ + i] 
    }

    /// Balance of heat during harm op period
    let JO = 40880
    // JO=JH3+JI3-JG3
    for i in 0..<365 { d23[JO + i] = d23[JH + i] + d23[JI + i] - d23[JG + i] }

    /// el cons for harm op outside of harm op period
    let JP = 41245
    // JP=IF(HE3<0,0,$E3+($F3-$E3)*HE3)
    for i in 0..<365 {
      d23[JP + i] = iff(d23[HE + i] < Double.zero, Double.zero, d21[E + i] + (d21[F + i] - d21[E + i]) * d23[HE + i])
    }

    /// heat cons for harm op and stby outside of harm op period
    let JQ = 41610
    // JQ=IF(HE3<0,IF(HZ3<0,$DZ3,$DY3+($DZ3-$DY3)*HZ3),$G3+($H3-$G3)*HE3)
    for i in 0..<365 {
      d23[JQ + i] = iff(
        d23[HE + i] < 0,
        iff(d23[HZ + i] < 0, d22[DZ + i], d22[DY + i] + (d22[DZ + i] - d22[DY + i]) * d23[HZ + i]),
        d21[G + i] + (d21[H + i] - d21[G + i]) * d23[HE + i])
    }

    /// heat from CSP outside of harm op period
    let JR = 41975
    // JR=IF(HE3<0,0,$EG3)
    for i in 0..<365 { d23[JR + i] = iff(d23[HE + i] < Double.zero, Double.zero, d22[EG + i]) }

    /// heat from el boiler outside of harm op period
    let JS = 42340
    // JS=MIN($ER3*El_boiler_eff,MAX(0,JQ3+IF(HE3<0,$G3,0)-JR3))
    for i in 0..<365 {
      d23[JS + i] = min(
        d22[ER + i] * El_boiler_eff, max(Double.zero, d23[JQ + i] + iff(d23[HE + i] < 0, d21[G + i], Double.zero) - d23[JR + i]))
    }

    /// el cons by el boiler outside of harm op period
    let JT = 42705
    // JT=JS3/El_boiler_eff
    for i in 0..<365 { d23[JT + i] = d23[JS + i] / El_boiler_eff }

    /// el cons not covered by PV outside of harm op period
    let JU = 43070
    // JU=$EA3+IF(HE3>=0,0,IF(HZ3<0,$DU3,$DT3+($DU3-$DT3)*HZ3))
    for i in 0..<365 {
      d23[JU + i] =
        d22[EA + i]
        + iff(
          d23[HE + i] >= 0, 0,
          iff(d23[HZ + i] < 0, d22[DU + i], d22[DT + i] + (d22[DU + i] - d22[DT + i]) * d23[HZ + i]))
    }

    /// el from harm op period charged BESS discharging for stby outside of harm op period
    let JW = 43800
    // JW=JF3*BESS_chrg_eff
    for i in 0..<365 { d23[JW + i] = d23[JF + i] * BESS_chrg_eff }

    /// El to BESS charging outside harm op period
    let JV = 43435
    // JV=MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,JU3+JT3+JP3+IF(HE3<0,$E3,0)-JW3)/BESS_chrg_eff,IF(HE3>=0,$EM3,IF(HZ3<0,$EO3,$EN3+($EO3-$EN3)*HZ3)))
    for i in 0..<365 {
      d23[JV + i] = min(
        BESS_cap_ud / BESS_chrg_eff,
        max(0, d23[JU + i] + d23[JT + i] + d23[JP + i] + iff(d23[HE + i] < 0, d21[E + i], 0) - d23[JW + i]) / BESS_chrg_eff,
        iff(
          d23[HE + i] >= Double.zero, d22[EM + i],
          iff(d23[HZ + i] < 0, d22[EO + i], d22[EN + i] + (d22[EO + i] - d22[EN + i]) * d23[HZ + i])))
    }

    /// max possible grid input outside of harm op period
    let JX = 44165
    // JX=MIN($DO3+$EJ3,MAX(0,-JV3*BESS_chrg_eff-JW3+JP3+IF(HE3<0,$E3,0)+JT3+JU3))
    for i in 0..<365 {
      d23[JX + i] = min(
        d22[DO + i] + d22[EJ + i],
        max(
          0,
          -d23[JV + i] * BESS_chrg_eff - d23[JW + i] + d23[JP + i] + iff(d23[HE + i] < 0, d21[E + i], Double.zero)
            + d23[JT + i] + d23[JU + i]))
    }

    /// Balance of electricity outside of harm op period
    let JY = 44530
    // JY=JV3*BESS_chrg_eff+JW3+JX3-JP3-IF(HE3<0,$E3,0)-JT3-JU3
    for i in 0..<365 {
      d23[JY + i] =
        d23[JV + i] * BESS_chrg_eff + d23[JW + i] + d23[JX + i] - d23[JP + i]
        - iff(d23[HE + i] < 0, d21[E + i], Double.zero) - d23[JT + i] - d23[JU + i]
    }

    /// Balance of heat outside of harm op period
    let JZ = 44895
    // JZ=JR3+JS3-JQ3-IF(HE3<0,$G3,0)
    for i in 0..<365 {
      d23[JZ + i] = d23[JR + i] + d23[JS + i] - d23[JQ + i] - iff(d23[HE + i] < 0, d21[G + i], Double.zero)
    }

    let KA = 45260
    // Pure Methanol prod with min night prep and resp day op
    // KA=IFERROR(((MAX(0,JD3/$C3-Overall_fix_cons)-Overall_harmonious_var_min_cons)/(Overall_harmonious_var_max_cons-Overall_harmonious_var_min_cons)*(MethDist_harmonious_max_perc-MethDist_harmonious_min_perc)+MethDist_harmonious_min_perc)*$C3+IF(HE3<0,0,$B3*(($AE3-A_equiv_harmonious_min_perc)*HE3/(A_equiv_harmonious_max_perc-A_equiv_harmonious_min_perc)*(A_MethDist_max_perc-A_MethDist_min_perc)+A_MethDist_min_perc)),0)*MethDist_Meth_nom_prod_ud
    for i in 0..<365 {
      d23[KA + i] =
        ifFinite(
          ((max(0, d23[JD + i] / day0[C0 + i] - Overall_fix_cons) - Overall_harmonious_var_min_cons) / (Overall_harmonious_var_max_cons - Overall_harmonious_var_min_cons)
            * (MethDist_harmonious_max_perc - MethDist_harmonious_min_perc) + MethDist_harmonious_min_perc) * day0[C0 + i]
            + iff(
              d23[HE + i] < 0, 0,
              day0[B0 + i]
                * ((d21[AE + i] - equiv_harmonious_min_perc[j]) * d23[HE + i] / (equiv_harmonious_max_perc[j] - equiv_harmonious_min_perc[j])
                  * (MethDist_max_perc[j] - MethDist_min_perc[j]) + MethDist_min_perc[j])), 0) * MethDist_Meth_nom_prod_ud
    }
    /// Missing heat
    let KB = 46355
    // KB=MAX(0,-JO3)+MAX(0,-JZ3)
    for i in 0..<365 { d23[KB + i] = max(0, -d23[JO + i]) + max(0, -d23[JZ + i]) }

    /// grid export
    let KC = 45625
    // KC=MAX(0,MIN(JN3,IF(HZ3<0,$DW3,($DV3+($DW3-$DV3)*HZ3))))+MAX(0,MIN(JY3,IF(OR(HZ3<0,HE3<0),0,$DX3)))
    for i in 0..<365 {
      d23[KC + i] =
        max(0, min(d23[JN + i], iff(d23[HZ + i] < 0, d22[DW + i], (d22[DV + i] + (d22[DW + i] - d22[DV + i]) * d23[HZ + i]))))
        + max(0, min(d23[JY + i], iff(or(d23[HZ + i] < 0, d23[HE + i] < 0), 0, d22[DX + i])))
    }

    /// grid import
    let KD = 45990
    // KD=(MAX(0,-JN3)+MAX(0,-JY3)+KB3/El_boiler_eff)*EDG_elec_cost_factor+JL3+JM3+JX3
    for i in 0..<365 {
      d23[KD + i] =
        (max(0, -d23[JN + i]) + max(0, -d23[JY + i]) + d23[KB + i] / El_boiler_eff) * EDG_elec_cost_factor + d23[JL + i]
        + d23[JM + i] + d23[JX + i]
    }
  }
}
