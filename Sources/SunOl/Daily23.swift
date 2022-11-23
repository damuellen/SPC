extension TunOl {
  func d23(_ h: UnsafeMutableBufferPointer<Double>, case j: Int) {
  let (A, B, C) = (96725, 97090, 97455)
  let (
    E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, AA, AB, AC, AD, AE
  ) = (
    97820, 98185, 98550, 98915, 99280, 99645, 100010, 100375, 100740, 101105,
    101470, 101835, 102200, 102565, 102930, 103295, 103660, 104025, 104390,
    104755, 105120, 105485, 105850, 106215, 106580, 106945, 107310
  )

  let (DM, DN, DO, DP) = (107675, 108040, 108405, 108770)

  let (
    DR, DS, DT, DU, DV, DW, DX, DY, DZ, EA, EB, EC, ED, EE, EF, EG, EH, EI,
    EJ, EK, EL, EM, EN, EO, EP, EQ, ER, ES, ET, EU, EV, EW, EX, EY, EZ, FA
  ) = (
    109500, 109865, 110230, 110595, 110960, 111325, 111690, 112055, 112420,
    112785, 113150, 113515, 113880, 114245, 114610, 114975, 115340, 115705,
    116070, 116435, 116800, 117165, 117530, 117895, 118260, 118625, 118990,
    119355, 119720, 120085, 120450, 120815, 121180, 121545, 121910, 122275
  )

  let (
    FC, FD, FE, FF, FG, FH, FI, FJ, FK, FL, FM, FN, FO, FP, FQ, FR, FS, FT, FU,
    FV, FW, FX, FY, FZ, GA, GB, GC, GD, GE, GF
  ) = (
    123005, 123370, 123735, 124100, 124465, 124830, 125195, 125560, 125925,
    126290, 126655, 127020, 127385, 127750, 128115, 128480, 128845, 129210,
    129575, 129940, 130305, 130670, 131035, 131400, 131765, 132130, 132495,
    132860, 133225, 133590
  )

  let (
    GH, GI, GJ, GK, GL, GM, GN, GO, GP, GQ, GR, GS, GT, GU, GV, GW, GX, GY, GZ,
    HA, HB, HC
  ) = (
    134320, 134685, 135050, 135415, 135780, 136145, 136510, 136875, 137240,
    137605, 137970, 138335, 138700, 139065, 139430, 139795, 140160, 140525,
    140890, 141255, 141620, 141985
  )

  let (
    HE, HF, HG, HH, HI, HJ, HK, HL, HM, HN, HO, HP, HQ, HR, HS, HT, HU, HV, HW,
    HX, HY, HZ
  ) = (
    142715, 143080, 143445, 143810, 144175, 144540, 144905, 145270, 145635,
    146000, 146365, 146730, 147095, 147460, 147825, 148190, 148555, 148920,
    149285, 149650, 150015, 150380
  )

  let (
    IB, IC, ID, IE, IF, IG, IH, II, IJ, IK, IL, IM, IN, IO, IP, IQ, IR, IS, IT,
    IU, IV, IW, IX, IY, IZ, JA, JB
  ) = (
    151110, 151475, 151840, 152205, 152570, 152935, 153300, 153665, 154030,
    154395, 154760, 155125, 155490, 155855, 156220, 156585, 156950, 157315,
    157680, 158045, 158410, 158775, 159140, 159505, 159870, 160235, 160600
  )

  let (
    JD, JE, JF, JG, JH, JI, JJ, JK, JL, JM, JN, JO, JP, JQ, JR, JS, JT, JU, JV,
    JW, JX, JY, JZ, KA, KB, KC, KD
  ) = (
    161330, 161695, 162060, 162425, 162790, 163155, 163520, 163885, 164250,
    164615, 164980, 165345, 165710, 166075, 166440, 166805, 167170, 167535,
    167900, 168265, 168630, 168995, 169360, 169725, 170090, 170455, 170820
  )

    /// Surplus harm op period el after min day harm op and min night op prep
    // FC=$EB3+$EH3-$O3-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$Q3-$EE3)/El_boiler_eff
    for i in 0..<365 {
      h[FC + i] =
        h[EB + i] + h[EH + i] - h[O + i] - max(
          0,
          h[EA + i] + h[E + i] + max(0, h[G + i] - h[EG + i]) / El_boiler_eff - h[EJ + i] - h[EM + i]
            * BESS_chrg_eff) / BESS_chrg_eff - max(0, h[Q + i] - h[EE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after min day harm op and max night op prep
    // FD=$EB3+$EH3-$P3-MAX(0,$EA3+$F3+MAX(0,$H3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$R3-$EE3)/El_boiler_eff
    for i in 0..<365 {
      h[FD + i] =
        h[EB + i] + h[EH + i] - h[P + i] - max(
          0,
          h[EA + i] + h[F + i] + max(0, h[H + i] - h[EG + i]) / El_boiler_eff - h[EJ + i] - h[EM + i]
            * BESS_chrg_eff) / BESS_chrg_eff - max(0, h[R + i] - h[EE + i]) / El_boiler_eff
    }

    /// Surplus harm op period el after max day harm op and min night op prep
    // FE=$EC3+$EI3-$O3-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$Q3-$EF3)/El_boiler_eff
    for i in 0..<365 {
      h[FE + i] =
        h[EC + i] + h[EI + i] - h[O + i] - max(
          0,
          h[EA + i] + h[E + i] + max(0, h[G + i] - h[EG + i]) / El_boiler_eff - h[EJ + i] - h[EM + i]
            * BESS_chrg_eff) / BESS_chrg_eff - max(0, h[Q + i] - h[EF + i]) / El_boiler_eff
    }

    /// Surplus outside harm op period el after min day harm and min night op prep
    // FF=($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3-MAX(0,$G3-$EG3)/El_boiler_eff
    for i in 0..<365 {
      h[FF + i] =
        (h[EK + i] + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i] - h[E + i] - max(
          0, h[G + i] - h[EG + i]) / El_boiler_eff
    }

    /// Surplus outside harm op period el after min day harm and max night op prep
    // FG=($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$F3-MAX(0,$H3-$EG3)/El_boiler_eff
    for i in 0..<365 {
      h[FG + i] =
        (h[EK + i] + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i] - h[F + i] - max(
          0, h[H + i] - h[EG + i]) / El_boiler_eff
    }

    /// Surplus outside harm op period el after max day harm and min night op prep
    // FH=($EL3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3-MAX(0,$G3-$EG3)/El_boiler_eff
    for i in 0..<365 {
      h[FH + i] =
        (h[EL + i] + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i] - h[E + i] - max(
          0, h[G + i] - h[EG + i]) / El_boiler_eff
    }

    /// Surplus harm op heat after min day harm and min night op prep
    // FI=$EE3+MAX(0,$EB3+$EH3-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-$O3)*El_boiler_eff-$Q3
    for i in 0..<365 {
      h[FI + i] =
        h[EE + i] + max(
          0,
          h[EB + i] + h[EH + i] - max(
            0,
            h[EA + i] + h[E + i] + max(0, h[G + i] - h[EG + i]) / El_boiler_eff - h[EJ + i] - h[EM + i]
              * BESS_chrg_eff) / BESS_chrg_eff - h[O + i]) * El_boiler_eff - h[Q + i]
    }

    /// Surplus harm op heat after min day harm and max night op prep
    // FJ=$EE3+MAX(0,$EB3+$EH3-MAX(0,$EA3+$F3+MAX(0,$H3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-$P3)*El_boiler_eff-$R3
    for i in 0..<365 {
      h[FJ + i] =
        h[EE + i] + max(
          0,
          h[EB + i] + h[EH + i] - max(
            0,
            h[EA + i] + h[F + i] + max(0, h[H + i] - h[EG + i]) / El_boiler_eff - h[EJ + i] - h[EM + i]
              * BESS_chrg_eff) / BESS_chrg_eff - h[P + i]) * El_boiler_eff - h[R + i]
    }

    /// Surplus harm op heat after max day harm and min night op prep
    // FK=$EF3+MAX(0,$EC3+$EI3-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-$O3)*El_boiler_eff-$Q3
    for i in 0..<365 {
      h[FK + i] =
        h[EF + i] + max(
          0,
          h[EC + i] + h[EI + i] - max(
            0,
            h[EA + i] + h[E + i] + max(0, h[G + i] - h[EG + i]) / El_boiler_eff - h[EJ + i] - h[EM + i]
              * BESS_chrg_eff) / BESS_chrg_eff - h[O + i]) * El_boiler_eff - h[Q + i]
    }

    /// Surplus outside harm op heat after min day harm and min night op prep
    // FL=$EG3+MAX(0,($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3)*El_boiler_eff-$G3
    for i in 0..<365 {
      h[FL + i] =
        h[EG + i] + max(0, (h[EK + i] + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i] - h[E + i])
        * El_boiler_eff - h[G + i]
    }

    /// Surplus outside harm op heat after min day harm and max night op prep
    // FM=$EG3+MAX(0,($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$F3)*El_boiler_eff-$H3
    for i in 0..<365 {
      h[FM + i] =
        h[EG + i] + max(0, (h[EK + i] + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i] - h[F + i])
        * El_boiler_eff - h[H + i]
    }

    /// Surplus outside harm op heat after max day harm and min night op prep
    // FN=$EG3+MAX(0,($EL3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3)*El_boiler_eff-$G3
    for i in 0..<365 {
      h[FN + i] =
        h[EG + i] + max(0, (h[EL + i] + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i] - h[E + i])
        * El_boiler_eff - h[G + i]
    }

    /// Surplus BESS cap after min harm op and min night op prep during harm op period
    // FO=$EK3-MAX(0,$EA3+$E3+MIN($ER3,MAX(0,$G3-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff
    for i in 0..<365 {
      h[FO + i] =
        h[EK + i] - max(
          0,
          h[EA + i] + h[E + i] + min(h[ER + i], max(0, h[G + i] - h[EG + i]) / El_boiler_eff) - h[EJ + i]
            - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff
    }

    /// Surplus BESS cap after min harm op and max night op prep during harm op period
    // FP=$EK3-MAX(0,$EA3+$F3+MIN($ER3,MAX(0,$H3-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff
    for i in 0..<365 {
      h[FP + i] =
        h[EK + i] - max(
          0,
          h[EA + i] + h[F + i] + min(h[ER + i], max(0, h[H + i] - h[EG + i]) / El_boiler_eff) - h[EJ + i]
            - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff
    }

    /// Surplus BESS cap after max harm op and min night op prep during harm op period
    // FQ=$EL3-MAX(0,$EA3+$E3+MIN($ER3,MAX(0,$G3-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff
    for i in 0..<365 {
      h[FQ + i] =
        h[EL + i] - max(
          0,
          h[EA + i] + h[E + i] + min(h[ER + i], max(0, h[G + i] - h[EG + i]) / El_boiler_eff) - h[EJ + i]
            - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff
    }

    /// Surplus el boiler cap after min harm op and min night op prep during harm op period
    // FR=IF(El_boiler_cap_ud=0,0,$EP3-MAX(0,$Q3-$EE3)/El_boiler_eff)
    for i in 0..<365 {
      h[FR + i] = iff(El_boiler_cap_ud == 0.0, 0, h[EP + i] - max(0, h[Q + i] - h[EE + i]) / El_boiler_eff)
    }

    /// Surplus el boiler cap after min harm op and max night op prep during harm op period
    // FS=IF(El_boiler_cap_ud=0,0,$EP3-MAX(0,$R3-$EE3)/El_boiler_eff)
    for i in 0..<365 {
      h[FS + i] = iff(El_boiler_cap_ud == 0.0, 0, h[EP + i] - max(0, h[R + i] - h[EE + i]) / El_boiler_eff)
    }

    /// Surplus el boiler cap after max harm op and min night op prep during harm op period
    // FT=IF(El_boiler_cap_ud=0,0,$EQ3-MAX(0,$Q3-$EF3)/El_boiler_eff)
    for i in 0..<365 {
      h[FT + i] = iff(El_boiler_cap_ud == 0.0, 0, h[EQ + i] - max(0, h[Q + i] - h[EF + i]) / El_boiler_eff)
    }

    /// Surplus el boiler cap after min harm op and min night op prep outside of harm op period
    // FU=IF(El_boiler_cap_ud=0,0,$ER3-MAX(0,$G3-$EG3)/El_boiler_eff)
    for i in 0..<365 {
      h[FU + i] = iff(El_boiler_cap_ud == 0.0, 0, h[ER + i] - max(0, h[G + i] - h[EG + i]) / El_boiler_eff)
    }

    /// Surplus el boiler cap after min harm op and max night op prep outside of harm op period
    // FV=IF(El_boiler_cap_ud=0,0,$ER3-MAX(0,$H3-$EG3)/El_boiler_eff)
    for i in 0..<365 {
      h[FV + i] = iff(El_boiler_cap_ud == 0.0, 0, h[ER + i] - max(0, h[H + i] - h[EG + i]) / El_boiler_eff)
    }

    /// Surplus el boiler cap after max harm op and min night op prep outside of harm op period
    // FW=IF(El_boiler_cap_ud=0,0,$ER3-MAX(0,$G3-$EG3)/El_boiler_eff)
    for i in 0..<365 {
      h[FW + i] = iff(El_boiler_cap_ud == 0.0, 0, h[ER + i] - max(0, h[G + i] - h[EG + i]) / El_boiler_eff)
    }

    /// Surplus RawMeth prod cap after min day harm and min night op prep
    // FX=$ES3-$S3
    for i in 0..<365 { h[FX + i] = h[ES + i] - h[S + i] }

    /// Surplus RawMeth prod cap after min day harm and max night op prep
    // FY=$ES3-$T3
    for i in 0..<365 { h[FY + i] = h[ES + i] - h[T + i] }

    /// Surplus RawMeth prod cap after max day harm and min night op prep
    // FZ=$ET3-$S3
    for i in 0..<365 { h[FZ + i] = h[ET + i] - h[S + i] }

    /// Surplus CO2 prod cap after min day harm and min night op prep
    // GA=$EV3-$U3
    for i in 0..<365 { h[GA + i] = h[EV + i] - h[U + i] }

    /// Surplus CO2 prod cap after min day harm and max night op prep
    // GB=$EV3-$V3
    for i in 0..<365 { h[GB + i] = h[EV + i] - h[V + i] }

    /// Surplus CO2 prod cap after max day harm and min night op prep
    // GC=$EW3-$U3
    for i in 0..<365 { h[GC + i] = h[EW + i] - h[U + i] }

    /// Surplus H2 prod cap after min day harm and min night op prep
    // GD=$EY3-$W3
    for i in 0..<365 { h[GD + i] = h[EY + i] - h[W + i] }

    /// Surplus H2 prod cap after min day harm and max night op prep
    // GE=$EY3-$X3
    for i in 0..<365 { h[GE + i] = h[EY + i] - h[X + i] }

    /// Surplus H2 prod cap after max day harm and min night op prep
    // GF=$EZ3-$W3
    for i in 0..<365 { h[GF + i] = h[EZ + i] - h[W + i] }

    /// Optimal harmonious day prod after min night prep due to prod cap limits
    // GH=IF(OR($AE3=0,FC3<0,FF3<0,FI3<0,FL3<0,FO3<0,FR3<0,FU3<0,FX3<0,GA3<0,GD3<0),0,MIN(1,IFERROR(FC3/MAX(0,FC3-FE3),1),IFERROR(FF3/MAX(0,FF3-FH3),1),IFERROR(FI3/MAX(0,FI3-FK3),1),IFERROR(FL3/MAX(0,FL3-FN3),1),IFERROR(FO3/MAX(0,FO3-FQ3),1),IFERROR(FR3/MAX(0,FR3-FT3),1),IFERROR(FU3/MAX(0,FU3-FW3),1),IFERROR(FX3/MAX(0,FX3-FZ3),1),IFERROR(GA3/MAX(0,GA3-GC3),1),IFERROR(GD3/MAX(0,GD3-GF3),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      h[GH + i] = iff(
        or(
          h[AE + i] == 0.0, h[FC + i] < 0, h[FF + i] < 0, h[FI + i] < 0, h[FL + i] < 0, h[FO + i] < 0,
          h[FR + i] < 0, h[FU + i] < 0, h[FX + i] < 0, h[GA + i] < 0, h[GD + i] < 0), 0,
        min(
          1, ifFinite(h[FC + i] / max(0, h[FC + i] - h[FE + i]), 1),
          ifFinite(h[FF + i] / max(0, h[FF + i] - h[FH + i]), 1),
          ifFinite(h[FI + i] / max(0, h[FI + i] - h[FK + i]), 1),
          ifFinite(h[FL + i] / max(0, h[FL + i] - h[FN + i]), 1),
          ifFinite(h[FO + i] / max(0, h[FO + i] - h[FQ + i]), 1),
          ifFinite(h[FR + i] / max(0, h[FR + i] - h[FT + i]), 1),
          ifFinite(h[FU + i] / max(0, h[FU + i] - h[FW + i]), 1),
          ifFinite(h[FX + i] / max(0, h[FX + i] - h[FZ + i]), 1),
          ifFinite(h[GA + i] / max(0, h[GA + i] - h[GC + i]), 1),
          ifFinite(h[GD + i] / max(0, h[GD + i] - h[GF + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc) + Overall_harmonious_min_perc)
    }

    /// Surplus harm op period el after opt day harm op and min night op prep
    // GI=IF(GH3=0,0,ROUND(($EB3+($EC3-$EB3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))+($EH3+($EI3-$EH3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-$O3-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$Q3-($EE3+($EF3-$EE3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      h[GI + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          (h[EB + i]
            + (h[EC + i] - h[EB + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            + (h[EH + i]
              + (h[EI + i] - h[EH + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (h[GH + i] - Overall_harmonious_min_perc))
            - h[O + i] - max(
              0,
              h[EA + i] + h[E + i] + max(0, h[G + i] - h[EG + i]) / El_boiler_eff - h[EJ + i] - h[EM + i]
                * BESS_chrg_eff) / BESS_chrg_eff - max(
              0,
              h[Q + i]
                - (h[EE + i]
                  + (h[EF + i] - h[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (h[GH + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after opt day harm op and max night op prep
    // GJ=IF(GH3=0,0,ROUND(($EB3+($EC3-$EB3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))+($EH3+($EI3-$EH3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-$P3-MAX(0,$EA3+$F3+MAX(0,$H3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$R3-($EE3+($EF3-$EE3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      h[GJ + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          (h[EB + i]
            + (h[EC + i] - h[EB + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            + (h[EH + i]
              + (h[EI + i] - h[EH + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (h[GH + i] - Overall_harmonious_min_perc))
            - h[P + i] - max(
              0,
              h[EA + i] + h[F + i] + max(0, h[H + i] - h[EG + i]) / El_boiler_eff - h[EJ + i] - h[EM + i]
                * BESS_chrg_eff) / BESS_chrg_eff - max(
              0,
              h[R + i]
                - (h[EE + i]
                  + (h[EF + i] - h[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (h[GH + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and min night op prep
    // GK=IF(GH3=0,0,ROUND((($EK3+($EL3-$EK3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3-MAX(0,$G3-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[GK + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          ((h[EK + i]
            + (h[EL + i] - h[EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i] - h[E + i] - max(0, h[G + i] - h[EG + i])
            / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after opt day harm and max night op prep
    // GL=IF(GH3=0,0,ROUND((($EK3+($EL3-$EK3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$F3-MAX(0,$H3-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[GL + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          ((h[EK + i]
            + (h[EL + i] - h[EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i] - h[F + i] - max(0, h[H + i] - h[EG + i])
            / El_boiler_eff, 5))
    }

    /// Surplus harm op heat after opt day harm and min night op prep
    // GM=IF(GH3=0,0,ROUND($EE3+($EF3-$EE3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)+MAX(0,$EB3+($EC3-$EB3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)+$EH3+($EI3-$EH3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)-MAX(0,$EA3+$E3+MAX(0,$G3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-$O3)*El_boiler_eff-$Q3,5))
    for i in 0..<365 {
      h[GM + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          h[EE + i] + (h[EF + i] - h[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (h[GH + i] - Overall_harmonious_min_perc) + max(
              0,
              h[EB + i] + (h[EC + i] - h[EB + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (h[GH + i] - Overall_harmonious_min_perc) + h[EH + i] + (h[EI + i] - h[EH + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (h[GH + i] - Overall_harmonious_min_perc) - max(
                  0,
                  h[EA + i] + h[E + i] + max(0, h[G + i] - h[EG + i]) / El_boiler_eff - h[EJ + i]
                    - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - h[O + i]) * El_boiler_eff - h[Q + i], 5))
    }

    /// Surplus harm op heat after opt day harm and max night op prep
    // GN=IF(GH3=0,0,ROUND($EE3+($EF3-$EE3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)+MAX(0,$EB3+($EC3-$EB3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)+$EH3+($EI3-$EH3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)-MAX(0,$EA3+$F3+MAX(0,$H3-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-$P3)*El_boiler_eff-$R3,5))
    for i in 0..<365 {
      h[GN + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          h[EE + i] + (h[EF + i] - h[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (h[GH + i] - Overall_harmonious_min_perc) + max(
              0,
              h[EB + i] + (h[EC + i] - h[EB + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (h[GH + i] - Overall_harmonious_min_perc) + h[EH + i] + (h[EI + i] - h[EH + i])
                / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                * (h[GH + i] - Overall_harmonious_min_perc) - max(
                  0,
                  h[EA + i] + h[F + i] + max(0, h[H + i] - h[EG + i]) / El_boiler_eff - h[EJ + i]
                    - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - h[P + i]) * El_boiler_eff - h[R + i], 5))
    }

    /// Surplus outside harm op heat after opt day harm and min night op prep
    // GO=IF(GH3=0,0,ROUND($EG3+MAX(0,($EK3+($EL3-$EK3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$E3)*El_boiler_eff-$G3,5))
    for i in 0..<365 {
      h[GO + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          h[EG + i] + max(
            0,
            (h[EK + i] + (h[EL + i] - h[EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc) + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i]
              - h[E + i]) * El_boiler_eff - h[G + i], 5))
    }

    /// Surplus outside harm op heat after opt day harm and max night op prep
    // GP=IF(GH3=0,0,ROUND($EG3+MAX(0,($EK3+($EL3-$EK3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)+$EM3)*BESS_chrg_eff+$EJ3-$EA3-$F3)*El_boiler_eff-$H3,5))
    for i in 0..<365 {
      h[GP + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          h[EG + i] + max(
            0,
            (h[EK + i] + (h[EL + i] - h[EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc) + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i]
              - h[F + i]) * El_boiler_eff - h[H + i], 5))
    }

    /// Surplus BESS cap after opt harm op and min night op prep during harm op period
    // GQ=IF(GH3=0,0,ROUND(($EK3+($EL3-$EK3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-MAX(0,$EA3+$E3+MIN($ER3,MAX(0,$G3-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[GQ + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          (h[EK + i]
            + (h[EL + i] - h[EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            - max(
              0,
              h[EA + i] + h[E + i] + min(h[ER + i], max(0, h[G + i] - h[EG + i]) / El_boiler_eff)
                - h[EJ + i] - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus BESS cap after opt harm op and max night op prep during harm op period
    // GR=IF(GH3=0,0,ROUND(($EK3+($EL3-$EK3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-MAX(0,$EA3+$F3+MIN($ER3,MAX(0,$H3-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[GR + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          (h[EK + i]
            + (h[EL + i] - h[EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            - max(
              0,
              h[EA + i] + h[F + i] + min(h[ER + i], max(0, h[H + i] - h[EG + i]) / El_boiler_eff)
                - h[EJ + i] - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep during harm op period
    // GS=IF(OR(GH3=0,El_boiler_cap_ud=0),0,ROUND(($EP3+($EQ3-$EP3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-MAX(0,$Q3-($EE3+($EF3-$EE3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      h[GS + i] = iff(
        or(h[GH + i] == 0.0, El_boiler_cap_ud == 0.0), 0,
        round(
          (h[EP + i]
            + (h[EQ + i] - h[EP + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            - max(
              0,
              h[Q + i]
                - (h[EE + i]
                  + (h[EF + i] - h[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (h[GH + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and max night op prep during harm op period
    // GT=IF(OR(GH3=0,El_boiler_cap_ud=0),0,ROUND(($EP3+($EQ3-$EP3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-MAX(0,$R3-($EE3+($EF3-$EE3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)))/El_boiler_eff,5))
    for i in 0..<365 {
      h[GT + i] = iff(
        or(h[GH + i] == 0.0, El_boiler_cap_ud == 0.0), 0,
        round(
          (h[EP + i]
            + (h[EQ + i] - h[EP + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            - max(
              0,
              h[R + i]
                - (h[EE + i]
                  + (h[EF + i] - h[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                    * (h[GH + i] - Overall_harmonious_min_perc))
            ) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and min night op prep outside of harm op period
    // GU=IF(OR(GH3=0,El_boiler_cap_ud=0),0,ROUND($ER3-MAX(0,$G3-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[GU + i] = iff(
        or(h[GH + i] == 0.0, El_boiler_cap_ud == 0.0), 0,
        round(h[ER + i] - max(0, h[G + i] - h[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after opt harm op and max night op prep outside of harm op period
    // GV=IF(OR(GH3=0,El_boiler_cap_ud=0),0,ROUND($ER3-MAX(0,$H3-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[GV + i] = iff(
        or(h[GH + i] == 0.0, El_boiler_cap_ud == 0.0), 0,
        round(h[ER + i] - max(0, h[H + i] - h[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and min night op prep
    // GW=IF(GH3=0,0,ROUND(($ES3+($ET3-$ES3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-$S3,5))
    for i in 0..<365 {
      h[GW + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          (h[ES + i]
            + (h[ET + i] - h[ES + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            - h[S + i], 5))
    }

    /// Surplus RawMeth prod cap after opt day harm and max night op prep
    // GX=IF(GH3=0,0,ROUND(($ES3+($ET3-$ES3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-$T3,5))
    for i in 0..<365 {
      h[GX + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          (h[ES + i]
            + (h[ET + i] - h[ES + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            - h[T + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and min night op prep
    // GY=IF(GH3=0,0,ROUND(($EV3+($EW3-$EV3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-$U3,5))
    for i in 0..<365 {
      h[GY + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          (h[EV + i]
            + (h[EW + i] - h[EV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            - h[U + i], 5))
    }

    /// Surplus CO2 prod cap after opt day harm and max night op prep
    // GZ=IF(GH3=0,0,ROUND(($EV3+($EW3-$EV3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-$V3,5))
    for i in 0..<365 {
      h[GZ + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          (h[EV + i]
            + (h[EW + i] - h[EV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            - h[V + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and min night op prep
    // HA=IF(GH3=0,0,ROUND(($EY3+($EZ3-$EY3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-$W3,5))
    for i in 0..<365 {
      h[HA + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          (h[EY + i]
            + (h[EZ + i] - h[EY + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            - h[W + i], 5))
    }

    /// Surplus H2 prod cap after opt day harm and max night op prep
    // HB=IF(GH3=0,0,ROUND(($EY3+($EZ3-$EY3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))-$X3,5))
    for i in 0..<365 {
      h[HB + i] = iff(
        h[GH + i] == 0.0, 0,
        round(
          (h[EY + i]
            + (h[EZ + i] - h[EY + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            - h[X + i], 5))
    }

    /// Max harmonious day prod after min night prep due to prod cap limits
    // HC=IF(OR(GH3=0,GI3<0,GK3<0,GM3<0,GO3<0,GQ3<0,GS3<0,GU3<0,GW3<0,GY3<0,HA3<0),0,MIN(1,IFERROR(GI3/MAX(0,GI3-GJ3),1),IFERROR(GK3/MAX(0,GK3-GL3),1),IFERROR(GM3/MAX(0,GM3-GN3),1),IFERROR(GO3/MAX(0,GO3-GP3),1),IFERROR(GQ3/MAX(0,GQ3-GR3),1),IFERROR(GS3/MAX(0,GS3-GT3),1),IFERROR(GU3/MAX(0,GU3-GV3),1),IFERROR(GW3/MAX(0,GW3-GX3),1),IFERROR(GY3/MAX(0,GY3-GZ3),1),IFERROR(HA3/MAX(0,HA3-HB3),1))*($AE3-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      h[HC + i] = iff(
        or(
          h[GH + i] == 0.0, h[GI + i] < 0, h[GK + i] < 0, h[GM + i] < 0, h[GO + i] < 0, h[GQ + i] < 0,
          h[GS + i] < 0, h[GU + i] < 0, h[GW + i] < 0, h[GY + i] < 0, h[HA + i] < 0), 0,
        min(
          1, ifFinite(h[GI + i] / max(0, h[GI + i] - h[GJ + i]), 1),
          ifFinite(h[GK + i] / max(0, h[GK + i] - h[GL + i]), 1),
          ifFinite(h[GM + i] / max(0, h[GM + i] - h[GN + i]), 1),
          ifFinite(h[GO + i] / max(0, h[GO + i] - h[GP + i]), 1),
          ifFinite(h[GQ + i] / max(0, h[GQ + i] - h[GR + i]), 1),
          ifFinite(h[GS + i] / max(0, h[GS + i] - h[GT + i]), 1),
          ifFinite(h[GU + i] / max(0, h[GU + i] - h[GV + i]), 1),
          ifFinite(h[GW + i] / max(0, h[GW + i] - h[GX + i]), 1),
          ifFinite(h[GY + i] / max(0, h[GY + i] - h[GZ + i]), 1),
          ifFinite(h[HA + i] / max(0, h[HA + i] - h[HB + i]), 1)) * (h[AE + i] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }

    /// Max Equiv harmonious night prod due to prod cap limits
    // HE=IF(OR($AE3=0,FC3<0,FF3<0,FI3<0,FL3<0,FO3<0,FR3<0,FU3<0,FX3<0,GA3<0,GD3<0),0,MIN(1,IFERROR(FC3/MAX(0,FC3-FD3),1),IFERROR(FF3/MAX(0,FF3-FG3),1),IFERROR(FI3/MAX(0,FI3-FJ3),1),IFERROR(FL3/MAX(0,FL3-FM3),1),IFERROR(FO3/MAX(0,FO3-FP3),1),IFERROR(FR3/MAX(0,FR3-FS3),1),IFERROR(FU3/MAX(0,FU3-FV3),1),IFERROR(FX3/MAX(0,FX3-FY3),1),IFERROR(GA3/MAX(0,GA3-GB3),1),IFERROR(GD3/MAX(0,GD3-GE3),1))*($AE3-A_equiv_harmonious_min_perc)+A_equiv_harmonious_min_perc)
    for i in 0..<365 {
      h[HE + i] = iff(
        or(
          h[AE + i] == 0.0, h[FC + i] < 0, h[FF + i] < 0, h[FI + i] < 0, h[FL + i] < 0, h[FO + i] < 0,
          h[FR + i] < 0, h[FU + i] < 0, h[FX + i] < 0, h[GA + i] < 0, h[GD + i] < 0), 0,
        min(
          1, ifFinite(h[FC + i] / max(0, h[FC + i] - h[FD + i]), 1),
          ifFinite(h[FF + i] / max(0, h[FF + i] - h[FG + i]), 1),
          ifFinite(h[FI + i] / max(0, h[FI + i] - h[FJ + i]), 1),
          ifFinite(h[FL + i] / max(0, h[FL + i] - h[FM + i]), 1),
          ifFinite(h[FO + i] / max(0, h[FO + i] - h[FP + i]), 1),
          ifFinite(h[FR + i] / max(0, h[FR + i] - h[FS + i]), 1),
          ifFinite(h[FU + i] / max(0, h[FU + i] - h[FV + i]), 1),
          ifFinite(h[FX + i] / max(0, h[FX + i] - h[FY + i]), 1),
          ifFinite(h[GA + i] / max(0, h[GA + i] - h[GB + i]), 1),
          ifFinite(h[GD + i] / max(0, h[GD + i] - h[GE + i]), 1)) * (h[AE + i] - equiv_harmonious_min_perc[j])
          + equiv_harmonious_min_perc[j])
    }

    /// Surplus harm op period el after min day harm op and opt night op prep
    // HF=IF(HE3=0,0,ROUND($EB3+$EH3-($O3+($P3-$O3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))-MAX(0,$EA3+($E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))+MAX(0,$G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$Q3+($R3-$Q3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)-$EE3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[HF + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EB + i] + h[EH + i]
            - (h[O + i]
              + (h[P + i] - h[O + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              h[EA + i]
                + (h[E + i]
                  + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                    * (h[HE + i] - equiv_harmonious_min_perc[j]))
                + max(
                  0,
                  h[G + i] + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                    * (h[HE + i] - equiv_harmonious_min_perc[j]) - h[EG + i]) / El_boiler_eff - h[EJ + i]
                - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(
              0,
              h[Q + i] + (h[R + i] - h[Q + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]) - h[EE + i]) / El_boiler_eff, 5))
    }

    /// Surplus harm op period el after max day harm op and opt night op prep
    // HG=IF(HE3=0,0,ROUND($EC3+$EI3-($O3+($P3-$O3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))-MAX(0,$EA3+($E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))+MAX(0,$G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-MAX(0,$Q3+($R3-$Q3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)-$EF3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[HG + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EC + i] + h[EI + i]
            - (h[O + i]
              + (h[P + i] - h[O + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              h[EA + i]
                + (h[E + i]
                  + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                    * (h[HE + i] - equiv_harmonious_min_perc[j]))
                + max(
                  0,
                  h[G + i] + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                    * (h[HE + i] - equiv_harmonious_min_perc[j]) - h[EG + i]) / El_boiler_eff - h[EJ + i]
                - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff - max(
              0,
              h[Q + i] + (h[R + i] - h[Q + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]) - h[EF + i]) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after min day harm and opt night op prep
    // HH=IF(HE3=0,0,ROUND(($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-($E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))-MAX(0,$G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[HH + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          (h[EK + i] + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i]
            - (h[E + i]
              + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              h[G + i] + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]) - h[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus outside harm op period el after max day harm and opt night op prep
    // HI=IF(HE3=0,0,ROUND(($EL3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-($E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))-MAX(0,$G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[HI + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          (h[EL + i] + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i]
            - (h[E + i]
              + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]))
            - max(
              0,
              h[G + i] + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]) - h[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus harm op heat after min day harm and opt night op prep
    // HJ=IF(HE3=0,0,ROUND($EE3+MAX(0,$EB3+$EH3-MAX(0,$EA3+$E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)+MAX(0,$G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-($O3+($P3-$O3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)))*El_boiler_eff-($Q3+($R3-$Q3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[HJ + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EE + i] + max(
            0,
            h[EB + i] + h[EH + i] - max(
              0,
              h[EA + i] + h[E + i] + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]) + max(
                  0,
                  h[G + i] + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                    * (h[HE + i] - equiv_harmonious_min_perc[j]) - h[EG + i]) / El_boiler_eff - h[EJ + i]
                - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff
              - (h[O + i]
                + (h[P + i] - h[O + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                  * (h[HE + i] - equiv_harmonious_min_perc[j]))
          ) * El_boiler_eff
            - (h[Q + i]
              + (h[R + i] - h[Q + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus harm op heat after max day harm and opt night op prep
    // HK=IF(HE3=0,0,ROUND($EF3+MAX(0,$EC3+$EI3-MAX(0,$EA3+$E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)+MAX(0,$G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)-$EG3)/El_boiler_eff-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff-($O3+($P3-$O3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)))*El_boiler_eff-($Q3+($R3-$Q3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[HK + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EF + i] + max(
            0,
            h[EC + i] + h[EI + i] - max(
              0,
              h[EA + i] + h[E + i] + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]) + max(
                  0,
                  h[G + i] + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                    * (h[HE + i] - equiv_harmonious_min_perc[j]) - h[EG + i]) / El_boiler_eff - h[EJ + i]
                - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff
              - (h[O + i]
                + (h[P + i] - h[O + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                  * (h[HE + i] - equiv_harmonious_min_perc[j]))
          ) * El_boiler_eff
            - (h[Q + i]
              + (h[R + i] - h[Q + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus outside harm op heat after min day harm and opt night op prep
    // HL=IF(HE3=0,0,ROUND($EG3+MAX(0,($EK3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-($E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)))*El_boiler_eff-($G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[HL + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EG + i] + max(
            0,
            (h[EK + i] + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i]
              - (h[E + i]
                + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                  * (h[HE + i] - equiv_harmonious_min_perc[j]))
          ) * El_boiler_eff
            - (h[G + i]
              + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus outside harm op heat after max day harm and opt night op prep
    // HM=IF(HE3=0,0,ROUND($EG3+MAX(0,($EL3+$EM3)*BESS_chrg_eff+$EJ3-$EA3-($E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)))*El_boiler_eff-($G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[HM + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EG + i] + max(
            0,
            (h[EL + i] + h[EM + i]) * BESS_chrg_eff + h[EJ + i] - h[EA + i]
              - (h[E + i]
                + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                  * (h[HE + i] - equiv_harmonious_min_perc[j]))
          ) * El_boiler_eff
            - (h[G + i]
              + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus BESS cap after min harm op and opt night op prep during harm op period
    // HN=IF(HE3=0,0,ROUND($EK3-MAX(0,$EA3+($E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))+MIN($ER3,MAX(0,($G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[HN + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EK + i] - max(
            0,
            h[EA + i]
              + (h[E + i]
                + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                  * (h[HE + i] - equiv_harmonious_min_perc[j]))
              + min(
                h[ER + i],
                max(
                  0,
                  (h[G + i]
                    + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                      * (h[HE + i] - equiv_harmonious_min_perc[j]))
                    - h[EG + i]) / El_boiler_eff) - h[EJ + i] - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus BESS cap after max harm op and opt night op prep during harm op period
    // HO=IF(HE3=0,0,ROUND($EL3-MAX(0,$EA3+($E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))+MIN($ER3,MAX(0,($G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff,5))
    for i in 0..<365 {
      h[HO + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EL + i] - max(
            0,
            h[EA + i]
              + (h[E + i]
                + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                  * (h[HE + i] - equiv_harmonious_min_perc[j]))
              + min(
                h[ER + i],
                max(
                  0,
                  (h[G + i]
                    + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                      * (h[HE + i] - equiv_harmonious_min_perc[j]))
                    - h[EG + i]) / El_boiler_eff) - h[EJ + i] - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff, 5))
    }

    /// Surplus el boiler cap after min harm op and opt night op prep during harm op period
    // HP=IF(OR(El_boiler_cap_ud=0,HE3=0),0,ROUND($EP3-MAX(0,($Q3+($R3-$Q3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))-$EE3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[HP + i] = iff(
        or(El_boiler_cap_ud == 0.0, h[HE + i] == 0.0), 0,
        round(
          h[EP + i] - max(
            0,
            (h[Q + i]
              + (h[R + i] - h[Q + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]))
              - h[EE + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max harm op and opt night op prep during harm op period
    // HQ=IF(OR(El_boiler_cap_ud=0,HE3=0),0,ROUND($EQ3-MAX(0,($Q3+($R3-$Q3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))-$EF3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[HQ + i] = iff(
        or(El_boiler_cap_ud == 0.0, h[HE + i] == 0.0), 0,
        round(
          h[EQ + i] - max(
            0,
            (h[Q + i]
              + (h[R + i] - h[Q + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]))
              - h[EF + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after min harm op and opt night op prep outside of harm op period
    // HR=IF(OR(El_boiler_cap_ud=0,HE3=0),0,ROUND($ER3-MAX(0,($G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[HR + i] = iff(
        or(El_boiler_cap_ud == 0.0, h[HE + i] == 0.0), 0,
        round(
          h[ER + i] - max(
            0,
            (h[G + i]
              + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]))
              - h[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus el boiler cap after max harm op and opt night op prep outside of harm op period
    // HS=IF(OR(El_boiler_cap_ud=0,HE3=0),0,ROUND($ER3-MAX(0,($G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))-$EG3)/El_boiler_eff,5))
    for i in 0..<365 {
      h[HS + i] = iff(
        or(El_boiler_cap_ud == 0.0, h[HE + i] == 0.0), 0,
        round(
          h[ER + i] - max(
            0,
            (h[G + i]
              + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j]))
              - h[EG + i]) / El_boiler_eff, 5))
    }

    /// Surplus RawMeth prod cap after min day harm and opt night op prep
    // HT=IF(HE3=0,0,ROUND($ES3-($S3+($T3-$S3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[HT + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[ES + i]
            - (h[S + i]
              + (h[T + i] - h[S + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus RawMeth prod cap after max day harm and opt night op prep
    // HU=IF(HE3=0,0,ROUND($ET3-($S3+($T3-$S3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[HU + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[ET + i]
            - (h[S + i]
              + (h[T + i] - h[S + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after min day harm and opt night op prep
    // HV=IF(HE3=0,0,ROUND($EV3-($U3+($V3-$U3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[HV + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EV + i]
            - (h[U + i]
              + (h[V + i] - h[U + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus CO2 prod cap after max day harm and opt night op prep
    // HW=IF(HE3=0,0,ROUND($EW3-($U3+($V3-$U3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[HW + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EW + i]
            - (h[U + i]
              + (h[V + i] - h[U + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harm and opt night op prep
    // HX=IF(HE3=0,0,ROUND($EY3-($W3+($X3-$W3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[HX + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EY + i]
            - (h[W + i]
              + (h[X + i] - h[W + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Surplus H2 prod cap after min day harm and opt night op prep
    // HY=IF(HE3=0,0,ROUND($EZ3-($W3+($X3-$W3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)),5))
    for i in 0..<365 {
      h[HY + i] = iff(
        h[HE + i] == 0.0, 0,
        round(
          h[EZ + i]
            - (h[W + i]
              + (h[X + i] - h[W + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                * (h[HE + i] - equiv_harmonious_min_perc[j])),
          5))
    }

    /// Opt harm op period op during night prio operation
    // HZ=IF(OR(HE3=0,HF3<0,HH3<0,HJ3<0,HL3<0,HN3<0,HP3<0,HR3<0,HT3<0,HV3<0,HX3<0),0,MIN(1,IFERROR(HF3/MAX(0,HF3-HG3),1),IFERROR(HH3/MAX(0,HH3-HI3),1),IFERROR(HJ3/MAX(0,HJ3-HK3),1),IFERROR(HL3/MAX(0,HL3-HM3),1),IFERROR(HN3/MAX(0,HN3-HO3),1),IFERROR(HP3/MAX(0,HP3-HQ3),1),IFERROR(HR3/MAX(0,HR3-HS3),1),IFERROR(HT3/MAX(0,HT3-HU3),1),IFERROR(HV3/MAX(0,HV3-HW3),1),IFERROR(HX3/MAX(0,HX3-HY3),1))*(Overall_harmonious_max_perc-Overall_harmonious_min_perc)+Overall_harmonious_min_perc)
    for i in 0..<365 {
      h[HZ + i] = iff(
        or(
          h[HE + i] == 0.0, h[HF + i] < 0, h[HH + i] < 0, h[HJ + i] < 0, h[HL + i] < 0, h[HN + i] < 0,
          h[HP + i] < 0, h[HR + i] < 0, h[HT + i] < 0, h[HV + i] < 0, h[HX + i] < 0), 0,
        min(
          1, ifFinite(h[HF + i] / max(0, h[HF + i] - h[HG + i]), 1),
          ifFinite(h[HH + i] / max(0, h[HH + i] - h[HI + i]), 1),
          ifFinite(h[HJ + i] / max(0, h[HJ + i] - h[HK + i]), 1),
          ifFinite(h[HL + i] / max(0, h[HL + i] - h[HM + i]), 1),
          ifFinite(h[HN + i] / max(0, h[HN + i] - h[HO + i]), 1),
          ifFinite(h[HP + i] / max(0, h[HP + i] - h[HQ + i]), 1),
          ifFinite(h[HR + i] / max(0, h[HR + i] - h[HS + i]), 1),
          ifFinite(h[HT + i] / max(0, h[HT + i] - h[HU + i]), 1),
          ifFinite(h[HV + i] / max(0, h[HV + i] - h[HW + i]), 1),
          ifFinite(h[HX + i] / max(0, h[HX + i] - h[HY + i]), 1))
          * (Overall_harmonious_max_perc - Overall_harmonious_min_perc) + Overall_harmonious_min_perc)
    }

    /// el cons for harm op during harm op period incl grid import
    // IB=IF($DR3=0,0,IF(HC3=0,MIN($DS3,MAX(0,$DS3+$EC3-MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,$EA3+$DU3-$EJ3+$DZ3/El_boiler_eff)/BESS_chrg_eff))),$DR3+($DS3-$DR3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      h[IB + i] = iff(
        h[DR + i] == 0.0, 0,
        iff(
          h[HC + i] == 0.0,
          min(
            h[DS + i],
            max(
              0,
              h[DS + i] + h[EC + i]
                - min(
                  BESS_cap_ud / BESS_chrg_eff,
                  max(0, h[EA + i] + h[DU + i] - h[EJ + i] + h[DZ + i] / El_boiler_eff) / BESS_chrg_eff))),
          h[DR + i] + (h[DS + i] - h[DR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (h[GH + i] - Overall_harmonious_min_perc)))
    }

    /// el cons for night prep during harm op period
    // IC=IF(HC3=0,0,($O3+($P3-$O3)/($AE3-A_equiv_harmonious_min_perc)*(HC3-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      h[IC + i] = iff(
        h[HC + i] == 0.0, 0,
        (h[O + i]
          + (h[P + i] - h[O + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
            * (h[HC + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el cons for BESS charging during harm op period
    // ID=IF(OR(GH3=0,HC3=0),MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,$EA3+$DU3-$EJ3+$DZ3/El_boiler_eff)/BESS_chrg_eff,MIN($DS3,MAX(0,$DS3+$EC3-IB3))),MIN($EK3+($EL3-$EK3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc),MAX(0,$EA3+$E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HC3-A_equiv_harmonious_min_perc)+MIN($ER3,MAX(0,$G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HC3-A_equiv_harmonious_min_perc)-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff))
    for i in 0..<365 {
      h[ID + i] = iff(
        or(h[GH + i] == 0.0, h[HC + i] == 0.0),
        min(
          BESS_cap_ud / BESS_chrg_eff,
          max(0, h[EA + i] + h[DU + i] - h[EJ + i] + h[DZ + i] / El_boiler_eff) / BESS_chrg_eff,
          min(h[DS + i], max(0, h[DS + i] + h[EC + i] - h[IB + i]))),
        min(
          h[EK + i]
            + (h[EL + i] - h[EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc),
          max(
            0,
            h[EA + i] + h[E + i] + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
              * (h[HC + i] - equiv_harmonious_min_perc[j])
              + min(
                h[ER + i],
                max(
                  0,
                  h[G + i] + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                    * (h[HC + i] - equiv_harmonious_min_perc[j]) - h[EG + i]) / El_boiler_eff) - h[EJ + i]
              - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff))
    }

    /// Heat cons for night prep during harm op period
    // IE=IF(HC3=0,0,($Q3+($R3-$Q3)/($AE3-A_equiv_harmonious_min_perc)*(HC3-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      h[IE + i] = iff(
        h[HC + i] == 0.0, 0,
        (h[Q + i]
          + (h[R + i] - h[Q + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
            * (h[HC + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// CSP heat available after harm op during harm op period
    // IF=IF(GH3=0,$EF3,$EE3+($EF3-$EE3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[IF + i] = iff(
        h[GH + i] == 0.0, h[EF + i],
        h[EE + i] + (h[EF + i] - h[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (h[GH + i] - Overall_harmonious_min_perc))
    }

    /// El boiler heat prod for night prep during harm op period
    // IG=IF(GH3=0,0,MIN(($EP3+($EQ3-$EP3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,IE3-IF3)))
    for i in 0..<365 {
      h[IG + i] = iff(
        h[GH + i] == 0.0, 0,
        min(
          (h[EP + i]
            + (h[EQ + i] - h[EP + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))
            * El_boiler_eff, max(0, h[IE + i] - h[IF + i])))
    }

    /// el cons of el boiler for night prep during harm op period
    // IH=IG3/El_boiler_eff
    for i in 0..<365 { h[IH + i] = h[IG + i] / El_boiler_eff }

    /// PV available after harm op and stby during harm op period
    // II=IF(GH3=0,MAX(0,$EC3+MAX(0,$DS3-IB3)),$EB3+($EC3-$EB3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[II + i] = iff(
        h[GH + i] == 0.0, max(0, h[EC + i] + max(0, h[DS + i] - h[IB + i])),
        h[EB + i] + (h[EC + i] - h[EB + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (h[GH + i] - Overall_harmonious_min_perc))
    }

    /// grid input for harm op and stby during harm op period
    // IJ=IF(GH3=0,$DN3,$DM3+($DN3-$DM3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[IJ + i] = iff(
        h[GH + i] == 0.0, h[DN + i],
        h[DM + i] + (h[DN + i] - h[DM + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (h[GH + i] - Overall_harmonious_min_perc))
    }

    /// grid input for night prep during harm op period
    // IK=MIN(IF(GH3=0,0,$EH3+($EI3-$EH3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)),MAX(0,-(II3-IC3-ID3-IH3)))
    for i in 0..<365 {
      h[IK + i] = min(
        iff(
          h[GH + i] == 0.0, 0,
          h[EH + i] + (h[EI + i] - h[EH + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (h[GH + i] - Overall_harmonious_min_perc)),
        max(0, -(h[II + i] - h[IC + i] - h[ID + i] - h[IH + i])))
    }

    /// Balance of electricity during harm op period
    // IL=II3+IK3-IC3-ID3-IH3
    for i in 0..<365 { h[IL + i] = h[II + i] + h[IK + i] - h[IC + i] - h[ID + i] - h[IH + i] }

    /// Balance of heat during harm op period
    // IM=IF3+IG3-IE3
    for i in 0..<365 { h[IM + i] = h[IF + i] + h[IG + i] - h[IE + i] }

    /// el cons for harm op outside of harm op period
    // IN=IF(HC3=0,0,$E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HC3-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      h[IN + i] = iff(
        h[HC + i] == 0.0, 0,
        h[E + i] + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
          * (h[HC + i] - equiv_harmonious_min_perc[j]))
    }

    /// heat cons for harm op and stby outside of harm op period
    // IO=IF(HC3=0,IF(GH3=0,$DZ3,$DY3+($DZ3-$DY3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)),$G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HC3-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      h[IO + i] = iff(
        h[HC + i] == 0.0,
        iff(
          h[GH + i] == 0.0, h[DZ + i],
          h[DY + i] + (h[DZ + i] - h[DY + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (h[GH + i] - Overall_harmonious_min_perc)),
        h[G + i] + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
          * (h[HC + i] - equiv_harmonious_min_perc[j]))
    }

    /// heat from CSP outside of harm op period
    // IP=IF(HC3=0,0,$EG3)
    for i in 0..<365 { h[IP + i] = iff(h[HC + i] == 0.0, 0, h[EG + i]) }

    /// heat from el boiler outside of harm op period
    // IQ=MIN($ER3*El_boiler_eff,MAX(0,IO3-IP3))
    for i in 0..<365 { h[IQ + i] = min(h[ER + i] * El_boiler_eff, max(0, h[IO + i] - h[IP + i])) }

    /// el cons by el boiler outside of harm op period
    // IR=IQ3/El_boiler_eff
    for i in 0..<365 { h[IR + i] = h[IQ + i] / El_boiler_eff }

    /// el cons not covered by PV outside of harm op period
    // IS=$EA3+IF(HC3>0,0,IF(GH3=0,$DU3,$DT3+($DU3-$DT3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      h[IS + i] =
        h[EA + i]
        + iff(
          h[HC + i] > 0.0, 0,
          iff(
            h[GH + i] == 0.0, h[DU + i],
            h[DT + i] + (h[DU + i] - h[DT + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc)))
    }

    /// el from harm op period charged BESS discharging for stby outside of harm op period
    // IU=ID3*BESS_chrg_eff
    for i in 0..<365 { h[IU + i] = h[ID + i] * BESS_chrg_eff }

    /// El to BESS charging outside harm op period
    // IT=MIN(MAX(0,IS3+IR3+IN3-IU3)/BESS_chrg_eff,IF(HC3>0,$EM3,IF(GH3=0,$EO3,$EN3+($EO3-$EN3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      h[IT + i] = min(
        max(0, h[IS + i] + h[IR + i] + h[IN + i] - h[IU + i]) / BESS_chrg_eff,
        iff(
          h[HC + i] > 0.0, h[EM + i],
          iff(
            h[GH + i] == 0.0, h[EO + i],
            h[EN + i] + (h[EO + i] - h[EN + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[GH + i] - Overall_harmonious_min_perc))))
    }

    /// max possible grid input outside of harm op period
    // IV=MIN($DO3+$EJ3,MAX(0,-IT3*BESS_chrg_eff-IU3+IN3+IR3+IS3))
    for i in 0..<365 {
      h[IV + i] = min(
        h[DO + i] + h[EJ + i],
        max(0, -h[IT + i] * BESS_chrg_eff - h[IU + i] + h[IN + i] + h[IR + i] + h[IS + i]))
    }

    /// Balance of electricity outside of harm op period
    // IW=IT3*BESS_chrg_eff+IU3+IV3-IN3-IR3-IS3
    for i in 0..<365 {
      h[IW + i] = h[IT + i] * BESS_chrg_eff + h[IU + i] + h[IV + i] - h[IN + i] - h[IR + i] - h[IS + i]
    }

    /// Balance of heat outside of harm op period
    // IX=IP3+IQ3-IO3
    for i in 0..<365 { h[IX + i] = h[IP + i] + h[IQ + i] - h[IO + i] }

    /// Pure Methanol prod with min night prep and resp day op
    // IY=MAX(0,IB3-$C3*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+IF(IN3=0,0,IF(A_overall_var_max_cons=0,$B3*HC3,MAX(0,IN3-$B3*A_overall_fix_stby_cons-A_overall_stup_cons)/A_overall_var_max_cons*A_MethDist_max_perc)*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      h[IY + i] =
        max(0, h[IB + i] - h[C + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons
        * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud
        + iff(
          h[IN + i] == 0.0, 0,
          iff(
            overall_var_max_cons[j] == 0.0, h[B + i] * h[HC + i],
            max(0, h[IN + i] - h[B + i] * overall_fix_stby_cons[j] - overall_stup_cons[j])
              / overall_var_max_cons[j] * MethDist_max_perc[j]) * MethDist_Meth_nom_prod_ud)
    }

    /// Missing heat
    // IZ=ROUND(MAX(0,-IM3)+MAX(0,-IX3),0)
    for i in 0..<365 { h[IZ + i] = round(max(0, -h[IM + i]) + max(0, -h[IX + i]), 0) }

    /// grid export
    // JA=ROUND(MAX(0,MIN(IL3,IF(GH3=0,$DW3,($DV3+($DW3-$DV3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(GH3-Overall_harmonious_min_perc)))))+MAX(0,MIN(IW3,IF(OR(GH3=0,HC3=0),0,$DX3))),0)
    for i in 0..<365 {
      h[JA + i] = round(
        max(
          0,
          min(
            h[IL + i],
            iff(
              h[GH + i] == 0.0, h[DW + i],
              (h[DV + i]
                + (h[DW + i] - h[DV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (h[GH + i] - Overall_harmonious_min_perc))
            ))) + max(0, min(h[IW + i], iff(or(h[GH + i] == 0.0, h[HC + i] == 0.0), 0, h[DX + i]))), 0)
    }

    /// grid import
    // JB=ROUND(MAX(0,-IL3)+MAX(0,-IW3)+IZ3/El_boiler_eff,0)*EDG_elec_cost_factor+ROUND(IJ3+IK3+IV3,0)
    for i in 0..<365 {
      h[JB + i] =
        round(max(0, -h[IL + i]) + max(0, -h[IW + i]) + h[IZ + i] / El_boiler_eff, 0) * EDG_elec_cost_factor
        + round(h[IJ + i] + h[IK + i] + h[IV + i], 0)
    }

    /// el cons for harm op during harm op period
    // JD=IF($DR3=0,0,IF(HZ3=0,MIN($DS3,MAX(0,$DS3+$EC3-MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,$EA3+$DU3-$EJ3+$DZ3/El_boiler_eff)/BESS_chrg_eff))),$DR3+($DS3-$DR3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HZ3-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      h[JD + i] = iff(
        h[DR + i] == 0.0, 0,
        iff(
          h[HZ + i] == 0.0,
          min(
            h[DS + i],
            max(
              0,
              h[DS + i] + h[EC + i]
                - min(
                  BESS_cap_ud / BESS_chrg_eff,
                  max(0, h[EA + i] + h[DU + i] - h[EJ + i] + h[DZ + i] / El_boiler_eff) / BESS_chrg_eff))),
          h[DR + i] + (h[DS + i] - h[DR + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (h[HZ + i] - Overall_harmonious_min_perc)))
    }

    /// el cons for night prep during harm op period
    // JE=IF(HE3=0,0,($O3+($P3-$O3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      h[JE + i] = iff(
        h[HE + i] == 0.0, 0,
        (h[O + i]
          + (h[P + i] - h[O + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
            * (h[HE + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// el cons for BESS charging during harm op period
    // JF=IF(OR(HE3=0,HZ3=0),MIN(BESS_cap_ud/BESS_chrg_eff,MAX(0,$EA3+$DU3-$EJ3+$DZ3/El_boiler_eff)/BESS_chrg_eff,MIN($DS3,MAX(0,$DS3+$EC3-IB3))),MIN($EK3+($EL3-$EK3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HZ3-Overall_harmonious_min_perc),MAX(0,$EA3+$E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)+MIN($ER3,MAX(0,$G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)-$EG3)/El_boiler_eff)-$EJ3-$EM3*BESS_chrg_eff)/BESS_chrg_eff))
    for i in 0..<365 {
      h[JF + i] = iff(
        or(h[HE + i] == 0.0, h[HZ + i] == 0.0),
        min(
          BESS_cap_ud / BESS_chrg_eff,
          max(0, h[EA + i] + h[DU + i] - h[EJ + i] + h[DZ + i] / El_boiler_eff) / BESS_chrg_eff,
          min(h[DS + i], max(0, h[DS + i] + h[EC + i] - h[IB + i]))),
        min(
          h[EK + i]
            + (h[EL + i] - h[EK + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[HZ + i] - Overall_harmonious_min_perc),
          max(
            0,
            h[EA + i] + h[E + i] + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
              * (h[HE + i] - equiv_harmonious_min_perc[j])
              + min(
                h[ER + i],
                max(
                  0,
                  h[G + i] + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
                    * (h[HE + i] - equiv_harmonious_min_perc[j]) - h[EG + i]) / El_boiler_eff) - h[EJ + i]
              - h[EM + i] * BESS_chrg_eff) / BESS_chrg_eff))
    }

    /// Heat cons for night prep during harm op period
    // JG=IF(HE3=0,0,($Q3+($R3-$Q3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc)))
    for i in 0..<365 {
      h[JG + i] = iff(
        h[HE + i] == 0.0, 0,
        (h[Q + i]
          + (h[R + i] - h[Q + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
            * (h[HE + i] - equiv_harmonious_min_perc[j]))
      )
    }

    /// CSP heat available after harm op during harm op period
    // JH=IF(HZ3=0,$EF3,$EE3+($EF3-$EE3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HZ3-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[JH + i] = iff(
        h[HZ + i] == 0.0, h[EF + i],
        h[EE + i] + (h[EF + i] - h[EE + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (h[HZ + i] - Overall_harmonious_min_perc))
    }

    /// El boiler heat prod for night prep during harm op period
    // JI=IF(HZ3=0,0,MIN(($EP3+($EQ3-$EP3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HZ3-Overall_harmonious_min_perc))*El_boiler_eff,MAX(0,JG3-JH3)))
    for i in 0..<365 {
      h[JI + i] = iff(
        h[HZ + i] == 0.0, 0,
        min(
          (h[EP + i]
            + (h[EQ + i] - h[EP + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[HZ + i] - Overall_harmonious_min_perc))
            * El_boiler_eff, max(0, h[JG + i] - h[JH + i])))
    }

    /// el cons of el boiler for night prep during harm op period
    // JJ=JI3/El_boiler_eff
    for i in 0..<365 { h[JJ + i] = h[JI + i] / El_boiler_eff }

    /// PV available after harm op and stby during harm op period
    // JK=IF(HZ3=0,MAX(0,$EC3+MAX(0,$DS3-JD3)),$EB3+($EC3-$EB3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HZ3-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[JK + i] = iff(
        h[HZ + i] == 0.0, max(0, h[EC + i] + max(0, h[DS + i] - h[JD + i])),
        h[EB + i] + (h[EC + i] - h[EB + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (h[HZ + i] - Overall_harmonious_min_perc))
    }

    /// grid input for harm op and stby during harm op period
    // JL=IF(HZ3=0,$DN3,$DM3+($DN3-$DM3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HZ3-Overall_harmonious_min_perc))
    for i in 0..<365 {
      h[JL + i] = iff(
        h[HZ + i] == 0.0, h[DN + i],
        h[DM + i] + (h[DN + i] - h[DM + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
          * (h[HZ + i] - Overall_harmonious_min_perc))
    }

    /// grid input for night prep during harm op period
    // JM=MIN(IF(HZ3=0,0,$EH3+($EI3-$EH3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HZ3-Overall_harmonious_min_perc)),MAX(0,-(JK3-JE3-JF3-JJ3)))
    for i in 0..<365 {
      h[JM + i] = min(
        iff(
          h[HZ + i] == 0.0, 0,
          h[EH + i] + (h[EI + i] - h[EH + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (h[HZ + i] - Overall_harmonious_min_perc)),
        max(0, -(h[JK + i] - h[JE + i] - h[JF + i] - h[JJ + i])))
    }

    /// Balance of electricity during harm op period
    // JN=JK3+JM3-JE3-JF3-JJ3
    for i in 0..<365 { h[JN + i] = h[JK + i] + h[JM + i] - h[JE + i] - h[JF + i] - h[JJ + i] }

    /// Balance of heat during harm op period
    // JO=JH3+JI3-JG3
    for i in 0..<365 { h[JO + i] = h[JH + i] + h[JI + i] - h[JG + i] }

    /// el cons for harm op outside of harm op period
    // JP=IF(HE3=0,0,$E3+($F3-$E3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      h[JP + i] = iff(
        h[HE + i] == 0.0, 0,
        h[E + i] + (h[F + i] - h[E + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
          * (h[HE + i] - equiv_harmonious_min_perc[j]))
    }

    /// heat cons for harm op and stby outside of harm op period
    // JQ=IF(HE3=0,IF(HZ3=0,$DZ3,$DY3+($DZ3-$DY3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HZ3-Overall_harmonious_min_perc)),$G3+($H3-$G3)/($AE3-A_equiv_harmonious_min_perc)*(HE3-A_equiv_harmonious_min_perc))
    for i in 0..<365 {
      h[JQ + i] = iff(
        h[HE + i] == 0.0,
        iff(
          h[HZ + i] == 0.0, h[DZ + i],
          h[DY + i] + (h[DZ + i] - h[DY + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
            * (h[HZ + i] - Overall_harmonious_min_perc)),
        h[G + i] + (h[H + i] - h[G + i]) / (h[AE + i] - equiv_harmonious_min_perc[j])
          * (h[HE + i] - equiv_harmonious_min_perc[j]))
    }

    /// heat from CSP outside of harm op period
    // JR=IF(HE3=0,0,$EG3)
    for i in 0..<365 { h[JR + i] = iff(h[HE + i] == 0.0, 0, h[EG + i]) }

    /// heat from el boiler outside of harm op period
    // JS=MIN($ER3*El_boiler_eff,MAX(0,JQ3-JR3))
    for i in 0..<365 { h[JS + i] = min(h[ER + i] * El_boiler_eff, max(0, h[JQ + i] - h[JR + i])) }

    /// el cons by el boiler outside of harm op period
    // JT=JS3/El_boiler_eff
    for i in 0..<365 { h[JT + i] = h[JS + i] / El_boiler_eff }

    /// el cons not covered by PV outside of harm op period
    // JU=$EA3+IF(HE3>0,0,IF(HZ3=0,$DU3,$DT3+($DU3-$DT3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HZ3-Overall_harmonious_min_perc)))
    for i in 0..<365 {
      h[JU + i] =
        h[EA + i]
        + iff(
          h[HE + i] > 0.0, 0,
          iff(
            h[HZ + i] == 0.0, h[DU + i],
            h[DT + i] + (h[DU + i] - h[DT + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[HZ + i] - Overall_harmonious_min_perc)))
    }

    /// el from harm op period charged BESS discharging for stby outside of harm op period
    // JW=JF3*BESS_chrg_eff
    for i in 0..<365 { h[JW + i] = h[JF + i] * BESS_chrg_eff }

    /// El to BESS charging outside harm op period
    // JV=MIN(MAX(0,JU3+JT3+JP3-JW3)/BESS_chrg_eff,IF(HE3>0,$EM3,IF(HZ3=0,$EO3,$EN3+($EO3-$EN3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HZ3-Overall_harmonious_min_perc))))
    for i in 0..<365 {
      h[JV + i] = min(
        max(0, h[JU + i] + h[JT + i] + h[JP + i] - h[JW + i]) / BESS_chrg_eff,
        iff(
          h[HE + i] > 0.0, h[EM + i],
          iff(
            h[HZ + i] == 0.0, h[EO + i],
            h[EN + i] + (h[EO + i] - h[EN + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
              * (h[HZ + i] - Overall_harmonious_min_perc))))
    }


    /// max possible grid input outside of harm op period
    // JX=MIN($DO3+$EJ3,MAX(0,-JV3*BESS_chrg_eff-JW3+JP3+JT3+JU3))
    for i in 0..<365 {
      h[JX + i] = min(
        h[DO + i] + h[EJ + i],
        max(0, -h[JV + i] * BESS_chrg_eff - h[JW + i] + h[JP + i] + h[JT + i] + h[JU + i]))
    }

    /// Balance of electricity outside of harm op period
    // JY=JV3*BESS_chrg_eff+JW3+JX3-JP3-JT3-JU3
    for i in 0..<365 {
      h[JY + i] = h[JV + i] * BESS_chrg_eff + h[JW + i] + h[JX + i] - h[JP + i] - h[JT + i] - h[JU + i]
    }

    /// Balance of heat outside of harm op period
    // JZ=JR3+JS3-JQ3
    for i in 0..<365 { h[JZ + i] = h[JR + i] + h[JS + i] - h[JQ + i] }

    /// Pure Methanol prod with min night prep and resp day op
    // KA=MAX(0,JD3-$C3*Overall_fix_cons)/Overall_harmonious_var_max_cons*MethDist_harmonious_max_perc*MethDist_Meth_nom_prod_ud+IF(JP3=0,0,IF(A_overall_var_max_cons=0,$B3*HE3,MAX(0,JP3-$B3*A_overall_fix_stby_cons-A_overall_stup_cons)/A_overall_var_max_cons*A_MethDist_max_perc)*MethDist_Meth_nom_prod_ud)
    for i in 0..<365 {
      h[KA + i] =
        max(0, h[JD + i] - h[C + i] * Overall_fix_cons) / Overall_harmonious_var_max_cons
        * MethDist_harmonious_max_perc * MethDist_Meth_nom_prod_ud
        + iff(
          h[JP + i] == 0.0, 0,
          iff(
            overall_var_max_cons[j] == 0.0, h[B + i] * h[HE + i],
            max(0, h[JP + i] - h[B + i] * overall_fix_stby_cons[j] - overall_stup_cons[j])
              / overall_var_max_cons[j] * MethDist_max_perc[j]) * MethDist_Meth_nom_prod_ud)
    }

    /// Missing heat
    // KB=ROUND(MAX(0,-JO3)+MAX(0,-JZ3),0)
    for i in 0..<365 { h[KB + i] = round(max(0, -h[JO + i]) + max(0, -h[JZ + i]), 0) }

    /// grid export
    // KC=ROUND(MAX(0,MIN(JN3,IF(HZ3=0,$DW3,($DV3+($DW3-$DV3)/(Overall_harmonious_max_perc-Overall_harmonious_min_perc)*(HZ3-Overall_harmonious_min_perc)))))+MAX(0,MIN(JY3,IF(OR(HZ3=0,HE3=0),0,$DX3))),0)
    for i in 0..<365 {
      h[KC + i] = round(
        max(
          0,
          min(
            h[JN + i],
            iff(
              h[HZ + i] == 0.0, h[DW + i],
              (h[DV + i]
                + (h[DW + i] - h[DV + i]) / (Overall_harmonious_max_perc - Overall_harmonious_min_perc)
                  * (h[HZ + i] - Overall_harmonious_min_perc))
            ))) + max(0, min(h[JY + i], iff(or(h[HZ + i] == 0.0, h[HE + i] == 0.0), 0, h[DX + i]))), 0)
    }

    /// grid import
    // KD=ROUND(MAX(0,-JN3)+MAX(0,-JY3)+KB3/El_boiler_eff,0)*EDG_elec_cost_factor+ROUND(JL3+JM3+JX3,0)
    for i in 0..<365 {
      h[KD + i] =
        round(max(0, -h[JN + i]) + max(0, -h[JY + i]) + h[KB + i] / El_boiler_eff, 0) * EDG_elec_cost_factor
        + round(h[JL + i] + h[JM + i] + h[JX + i], 0)
    }
  }
}
