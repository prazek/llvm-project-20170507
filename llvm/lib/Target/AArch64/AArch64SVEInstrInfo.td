//=- AArch64SVEInstrInfo.td -  AArch64 SVE Instructions -*- tablegen -*-----=//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// AArch64 Scalable Vector Extension (SVE) Instruction definitions.
//
//===----------------------------------------------------------------------===//

let Predicates = [HasSVE] in {
  defm ADD_ZZZ   : sve_int_bin_cons_arit_0<0b000, "add">;
  defm SUB_ZZZ   : sve_int_bin_cons_arit_0<0b001, "sub">;

  defm AND_ZI    : sve_int_log_imm<0b10, "and", "bic">;

  defm ADD_ZPmZ  : sve_int_bin_pred_arit_0<0b000, "add">;
  defm SUB_ZPmZ  : sve_int_bin_pred_arit_0<0b001, "sub">;

  // continuous load with reg+immediate
  defm LD1B_IMM    : sve_mem_cld_si<0b0000, "ld1b",  Z_b, ZPR8>;
  defm LD1B_H_IMM  : sve_mem_cld_si<0b0001, "ld1b",  Z_h, ZPR16>;
  defm LD1B_S_IMM  : sve_mem_cld_si<0b0010, "ld1b",  Z_s, ZPR32>;
  defm LD1B_D_IMM  : sve_mem_cld_si<0b0011, "ld1b",  Z_d, ZPR64>;
  defm LD1SW_D_IMM : sve_mem_cld_si<0b0100, "ld1sw", Z_d, ZPR64>;
  defm LD1H_IMM    : sve_mem_cld_si<0b0101, "ld1h",  Z_h, ZPR16>;
  defm LD1H_S_IMM  : sve_mem_cld_si<0b0110, "ld1h",  Z_s, ZPR32>;
  defm LD1H_D_IMM  : sve_mem_cld_si<0b0111, "ld1h",  Z_d, ZPR64>;
  defm LD1SH_D_IMM : sve_mem_cld_si<0b1000, "ld1sh", Z_d, ZPR64>;
  defm LD1SH_S_IMM : sve_mem_cld_si<0b1001, "ld1sh", Z_s, ZPR32>;
  defm LD1W_IMM    : sve_mem_cld_si<0b1010, "ld1w",  Z_s, ZPR32>;
  defm LD1W_D_IMM  : sve_mem_cld_si<0b1011, "ld1w",  Z_d, ZPR64>;
  defm LD1SB_D_IMM : sve_mem_cld_si<0b1100, "ld1sb", Z_d, ZPR64>;
  defm LD1SB_S_IMM : sve_mem_cld_si<0b1101, "ld1sb", Z_s, ZPR32>;
  defm LD1SB_H_IMM : sve_mem_cld_si<0b1110, "ld1sb", Z_h, ZPR16>;
  defm LD1D_IMM    : sve_mem_cld_si<0b1111, "ld1d",  Z_d, ZPR64>;

  // LD1R loads (splat scalar to vector)
  defm LD1RB_IMM    : sve_mem_ld_dup<0b00, 0b00, "ld1rb",  Z_b, ZPR8,  uimm6s1>;
  defm LD1RB_H_IMM  : sve_mem_ld_dup<0b00, 0b01, "ld1rb",  Z_h, ZPR16, uimm6s1>;
  defm LD1RB_S_IMM  : sve_mem_ld_dup<0b00, 0b10, "ld1rb",  Z_s, ZPR32, uimm6s1>;
  defm LD1RB_D_IMM  : sve_mem_ld_dup<0b00, 0b11, "ld1rb",  Z_d, ZPR64, uimm6s1>;
  defm LD1RSW_IMM   : sve_mem_ld_dup<0b01, 0b00, "ld1rsw", Z_d, ZPR64, uimm6s4>;
  defm LD1RH_IMM    : sve_mem_ld_dup<0b01, 0b01, "ld1rh",  Z_h, ZPR16, uimm6s2>;
  defm LD1RH_S_IMM  : sve_mem_ld_dup<0b01, 0b10, "ld1rh",  Z_s, ZPR32, uimm6s2>;
  defm LD1RH_D_IMM  : sve_mem_ld_dup<0b01, 0b11, "ld1rh",  Z_d, ZPR64, uimm6s2>;
  defm LD1RSH_D_IMM : sve_mem_ld_dup<0b10, 0b00, "ld1rsh", Z_d, ZPR64, uimm6s2>;
  defm LD1RSH_S_IMM : sve_mem_ld_dup<0b10, 0b01, "ld1rsh", Z_s, ZPR32, uimm6s2>;
  defm LD1RW_IMM    : sve_mem_ld_dup<0b10, 0b10, "ld1rw",  Z_s, ZPR32, uimm6s4>;
  defm LD1RW_D_IMM  : sve_mem_ld_dup<0b10, 0b11, "ld1rw",  Z_d, ZPR64, uimm6s4>;
  defm LD1RSB_D_IMM : sve_mem_ld_dup<0b11, 0b00, "ld1rsb", Z_d, ZPR64, uimm6s1>;
  defm LD1RSB_S_IMM : sve_mem_ld_dup<0b11, 0b01, "ld1rsb", Z_s, ZPR32, uimm6s1>;
  defm LD1RSB_H_IMM : sve_mem_ld_dup<0b11, 0b10, "ld1rsb", Z_h, ZPR16, uimm6s1>;
  defm LD1RD_IMM    : sve_mem_ld_dup<0b11, 0b11, "ld1rd",  Z_d, ZPR64, uimm6s8>;

  // LD1RQ loads (load quadword-vector and splat to scalable vector)
  defm LD1RQ_B_IMM  : sve_mem_ldqr_si<0b00, "ld1rqb", Z_b, ZPR8>;
  defm LD1RQ_H_IMM  : sve_mem_ldqr_si<0b01, "ld1rqh", Z_h, ZPR16>;
  defm LD1RQ_W_IMM  : sve_mem_ldqr_si<0b10, "ld1rqw", Z_s, ZPR32>;
  defm LD1RQ_D_IMM  : sve_mem_ldqr_si<0b11, "ld1rqd", Z_d, ZPR64>;
  defm LD1RQ_B      : sve_mem_ldqr_ss<0b00, "ld1rqb", Z_b, ZPR8,  GPR64NoXZRshifted8>;
  defm LD1RQ_H      : sve_mem_ldqr_ss<0b01, "ld1rqh", Z_h, ZPR16, GPR64NoXZRshifted16>;
  defm LD1RQ_W      : sve_mem_ldqr_ss<0b10, "ld1rqw", Z_s, ZPR32, GPR64NoXZRshifted32>;
  defm LD1RQ_D      : sve_mem_ldqr_ss<0b11, "ld1rqd", Z_d, ZPR64, GPR64NoXZRshifted64>;

  // continuous load with reg+reg addressing.
  defm LD1B    : sve_mem_cld_ss<0b0000, "ld1b",  Z_b, ZPR8,  GPR64NoXZRshifted8>;
  defm LD1B_H  : sve_mem_cld_ss<0b0001, "ld1b",  Z_h, ZPR16, GPR64NoXZRshifted8>;
  defm LD1B_S  : sve_mem_cld_ss<0b0010, "ld1b",  Z_s, ZPR32, GPR64NoXZRshifted8>;
  defm LD1B_D  : sve_mem_cld_ss<0b0011, "ld1b",  Z_d, ZPR64, GPR64NoXZRshifted8>;
  defm LD1SW_D : sve_mem_cld_ss<0b0100, "ld1sw", Z_d, ZPR64, GPR64NoXZRshifted32>;
  defm LD1H    : sve_mem_cld_ss<0b0101, "ld1h",  Z_h, ZPR16, GPR64NoXZRshifted16>;
  defm LD1H_S  : sve_mem_cld_ss<0b0110, "ld1h",  Z_s, ZPR32, GPR64NoXZRshifted16>;
  defm LD1H_D  : sve_mem_cld_ss<0b0111, "ld1h",  Z_d, ZPR64, GPR64NoXZRshifted16>;
  defm LD1SH_D : sve_mem_cld_ss<0b1000, "ld1sh", Z_d, ZPR64, GPR64NoXZRshifted16>;
  defm LD1SH_S : sve_mem_cld_ss<0b1001, "ld1sh", Z_s, ZPR32, GPR64NoXZRshifted16>;
  defm LD1W    : sve_mem_cld_ss<0b1010, "ld1w",  Z_s, ZPR32, GPR64NoXZRshifted32>;
  defm LD1W_D  : sve_mem_cld_ss<0b1011, "ld1w",  Z_d, ZPR64, GPR64NoXZRshifted32>;
  defm LD1SB_D : sve_mem_cld_ss<0b1100, "ld1sb", Z_d, ZPR64, GPR64NoXZRshifted8>;
  defm LD1SB_S : sve_mem_cld_ss<0b1101, "ld1sb", Z_s, ZPR32, GPR64NoXZRshifted8>;
  defm LD1SB_H : sve_mem_cld_ss<0b1110, "ld1sb", Z_h, ZPR16, GPR64NoXZRshifted8>;
  defm LD1D    : sve_mem_cld_ss<0b1111, "ld1d",  Z_d, ZPR64, GPR64NoXZRshifted64>;

  // non-faulting continuous load with reg+immediate
  defm LDNF1B_IMM    : sve_mem_cldnf_si<0b0000, "ldnf1b",  Z_b, ZPR8>;
  defm LDNF1B_H_IMM  : sve_mem_cldnf_si<0b0001, "ldnf1b",  Z_h, ZPR16>;
  defm LDNF1B_S_IMM  : sve_mem_cldnf_si<0b0010, "ldnf1b",  Z_s, ZPR32>;
  defm LDNF1B_D_IMM  : sve_mem_cldnf_si<0b0011, "ldnf1b",  Z_d, ZPR64>;
  defm LDNF1SW_D_IMM : sve_mem_cldnf_si<0b0100, "ldnf1sw", Z_d, ZPR64>;
  defm LDNF1H_IMM    : sve_mem_cldnf_si<0b0101, "ldnf1h",  Z_h, ZPR16>;
  defm LDNF1H_S_IMM  : sve_mem_cldnf_si<0b0110, "ldnf1h",  Z_s, ZPR32>;
  defm LDNF1H_D_IMM  : sve_mem_cldnf_si<0b0111, "ldnf1h",  Z_d, ZPR64>;
  defm LDNF1SH_D_IMM : sve_mem_cldnf_si<0b1000, "ldnf1sh", Z_d, ZPR64>;
  defm LDNF1SH_S_IMM : sve_mem_cldnf_si<0b1001, "ldnf1sh", Z_s, ZPR32>;
  defm LDNF1W_IMM    : sve_mem_cldnf_si<0b1010, "ldnf1w",  Z_s, ZPR32>;
  defm LDNF1W_D_IMM  : sve_mem_cldnf_si<0b1011, "ldnf1w",  Z_d, ZPR64>;
  defm LDNF1SB_D_IMM : sve_mem_cldnf_si<0b1100, "ldnf1sb", Z_d, ZPR64>;
  defm LDNF1SB_S_IMM : sve_mem_cldnf_si<0b1101, "ldnf1sb", Z_s, ZPR32>;
  defm LDNF1SB_H_IMM : sve_mem_cldnf_si<0b1110, "ldnf1sb", Z_h, ZPR16>;
  defm LDNF1D_IMM    : sve_mem_cldnf_si<0b1111, "ldnf1d",  Z_d, ZPR64>;

  // First-faulting loads with reg+reg addressing.
  defm LDFF1B    : sve_mem_cldff_ss<0b0000, "ldff1b",  Z_b, ZPR8,  GPR64shifted8>;
  defm LDFF1B_H  : sve_mem_cldff_ss<0b0001, "ldff1b",  Z_h, ZPR16, GPR64shifted8>;
  defm LDFF1B_S  : sve_mem_cldff_ss<0b0010, "ldff1b",  Z_s, ZPR32, GPR64shifted8>;
  defm LDFF1B_D  : sve_mem_cldff_ss<0b0011, "ldff1b",  Z_d, ZPR64, GPR64shifted8>;
  defm LDFF1SW_D : sve_mem_cldff_ss<0b0100, "ldff1sw", Z_d, ZPR64, GPR64shifted32>;
  defm LDFF1H    : sve_mem_cldff_ss<0b0101, "ldff1h",  Z_h, ZPR16, GPR64shifted16>;
  defm LDFF1H_S  : sve_mem_cldff_ss<0b0110, "ldff1h",  Z_s, ZPR32, GPR64shifted16>;
  defm LDFF1H_D  : sve_mem_cldff_ss<0b0111, "ldff1h",  Z_d, ZPR64, GPR64shifted16>;
  defm LDFF1SH_D : sve_mem_cldff_ss<0b1000, "ldff1sh", Z_d, ZPR64, GPR64shifted16>;
  defm LDFF1SH_S : sve_mem_cldff_ss<0b1001, "ldff1sh", Z_s, ZPR32, GPR64shifted16>;
  defm LDFF1W    : sve_mem_cldff_ss<0b1010, "ldff1w",  Z_s, ZPR32, GPR64shifted32>;
  defm LDFF1W_D  : sve_mem_cldff_ss<0b1011, "ldff1w",  Z_d, ZPR64, GPR64shifted32>;
  defm LDFF1SB_D : sve_mem_cldff_ss<0b1100, "ldff1sb", Z_d, ZPR64, GPR64shifted8>;
  defm LDFF1SB_S : sve_mem_cldff_ss<0b1101, "ldff1sb", Z_s, ZPR32, GPR64shifted8>;
  defm LDFF1SB_H : sve_mem_cldff_ss<0b1110, "ldff1sb", Z_h, ZPR16, GPR64shifted8>;
  defm LDFF1D    : sve_mem_cldff_ss<0b1111, "ldff1d",  Z_d, ZPR64, GPR64shifted64>;

  // LD(2|3|4) structured loads with reg+immediate
  defm LD2B_IMM : sve_mem_eld_si<0b00, 0b01, ZZ_b,   "ld2b", simm4s2>;
  defm LD3B_IMM : sve_mem_eld_si<0b00, 0b10, ZZZ_b,  "ld3b", simm4s3>;
  defm LD4B_IMM : sve_mem_eld_si<0b00, 0b11, ZZZZ_b, "ld4b", simm4s4>;
  defm LD2H_IMM : sve_mem_eld_si<0b01, 0b01, ZZ_h,   "ld2h", simm4s2>;
  defm LD3H_IMM : sve_mem_eld_si<0b01, 0b10, ZZZ_h,  "ld3h", simm4s3>;
  defm LD4H_IMM : sve_mem_eld_si<0b01, 0b11, ZZZZ_h, "ld4h", simm4s4>;
  defm LD2W_IMM : sve_mem_eld_si<0b10, 0b01, ZZ_s,   "ld2w", simm4s2>;
  defm LD3W_IMM : sve_mem_eld_si<0b10, 0b10, ZZZ_s,  "ld3w", simm4s3>;
  defm LD4W_IMM : sve_mem_eld_si<0b10, 0b11, ZZZZ_s, "ld4w", simm4s4>;
  defm LD2D_IMM : sve_mem_eld_si<0b11, 0b01, ZZ_d,   "ld2d", simm4s2>;
  defm LD3D_IMM : sve_mem_eld_si<0b11, 0b10, ZZZ_d,  "ld3d", simm4s3>;
  defm LD4D_IMM : sve_mem_eld_si<0b11, 0b11, ZZZZ_d, "ld4d", simm4s4>;

  // LD(2|3|4) structured loads (register + register)
  def LD2B : sve_mem_eld_ss<0b00, 0b01, ZZ_b,   "ld2b", GPR64NoXZRshifted8>;
  def LD3B : sve_mem_eld_ss<0b00, 0b10, ZZZ_b,  "ld3b", GPR64NoXZRshifted8>;
  def LD4B : sve_mem_eld_ss<0b00, 0b11, ZZZZ_b, "ld4b", GPR64NoXZRshifted8>;
  def LD2H : sve_mem_eld_ss<0b01, 0b01, ZZ_h,   "ld2h", GPR64NoXZRshifted16>;
  def LD3H : sve_mem_eld_ss<0b01, 0b10, ZZZ_h,  "ld3h", GPR64NoXZRshifted16>;
  def LD4H : sve_mem_eld_ss<0b01, 0b11, ZZZZ_h, "ld4h", GPR64NoXZRshifted16>;
  def LD2W : sve_mem_eld_ss<0b10, 0b01, ZZ_s,   "ld2w", GPR64NoXZRshifted32>;
  def LD3W : sve_mem_eld_ss<0b10, 0b10, ZZZ_s,  "ld3w", GPR64NoXZRshifted32>;
  def LD4W : sve_mem_eld_ss<0b10, 0b11, ZZZZ_s, "ld4w", GPR64NoXZRshifted32>;
  def LD2D : sve_mem_eld_ss<0b11, 0b01, ZZ_d,   "ld2d", GPR64NoXZRshifted64>;
  def LD3D : sve_mem_eld_ss<0b11, 0b10, ZZZ_d,  "ld3d", GPR64NoXZRshifted64>;
  def LD4D : sve_mem_eld_ss<0b11, 0b11, ZZZZ_d, "ld4d", GPR64NoXZRshifted64>;

  // Gathers using unscaled 32-bit offsets, e.g.
  //    ld1h z0.s, p0/z, [x0, z0.s, uxtw]
  defm GLD1SB_S   : sve_mem_32b_gld_vs_32_unscaled<0b0000, "ld1sb",   ZPR32ExtSXTW8Only, ZPR32ExtUXTW8Only>;
  defm GLDFF1SB_S : sve_mem_32b_gld_vs_32_unscaled<0b0001, "ldff1sb", ZPR32ExtSXTW8Only, ZPR32ExtUXTW8Only>;
  defm GLD1B_S    : sve_mem_32b_gld_vs_32_unscaled<0b0010, "ld1b",    ZPR32ExtSXTW8Only, ZPR32ExtUXTW8Only>;
  defm GLDFF1B_S  : sve_mem_32b_gld_vs_32_unscaled<0b0011, "ldff1b",  ZPR32ExtSXTW8Only, ZPR32ExtUXTW8Only>;
  defm GLD1SH_S   : sve_mem_32b_gld_vs_32_unscaled<0b0100, "ld1sh",   ZPR32ExtSXTW8, ZPR32ExtUXTW8>;
  defm GLDFF1SH_S : sve_mem_32b_gld_vs_32_unscaled<0b0101, "ldff1sh", ZPR32ExtSXTW8, ZPR32ExtUXTW8>;
  defm GLD1H_S    : sve_mem_32b_gld_vs_32_unscaled<0b0110, "ld1h",    ZPR32ExtSXTW8, ZPR32ExtUXTW8>;
  defm GLDFF1H_S  : sve_mem_32b_gld_vs_32_unscaled<0b0111, "ldff1h",  ZPR32ExtSXTW8, ZPR32ExtUXTW8>;
  defm GLD1W      : sve_mem_32b_gld_vs_32_unscaled<0b1010, "ld1w",    ZPR32ExtSXTW8, ZPR32ExtUXTW8>;
  defm GLDFF1W    : sve_mem_32b_gld_vs_32_unscaled<0b1011, "ldff1w",  ZPR32ExtSXTW8, ZPR32ExtUXTW8>;

  // Gathers using scaled 32-bit offsets, e.g.
  //    ld1h z0.s, p0/z, [x0, z0.s, uxtw #1]
  defm GLD1SH_S   : sve_mem_32b_gld_sv_32_scaled<0b0100, "ld1sh",   ZPR32ExtSXTW16, ZPR32ExtUXTW16>;
  defm GLDFF1SH_S : sve_mem_32b_gld_sv_32_scaled<0b0101, "ldff1sh", ZPR32ExtSXTW16, ZPR32ExtUXTW16>;
  defm GLD1H_S    : sve_mem_32b_gld_sv_32_scaled<0b0110, "ld1h",    ZPR32ExtSXTW16, ZPR32ExtUXTW16>;
  defm GLDFF1H_S  : sve_mem_32b_gld_sv_32_scaled<0b0111, "ldff1h",  ZPR32ExtSXTW16, ZPR32ExtUXTW16>;
  defm GLD1W      : sve_mem_32b_gld_sv_32_scaled<0b1010, "ld1w",    ZPR32ExtSXTW32, ZPR32ExtUXTW32>;
  defm GLDFF1W    : sve_mem_32b_gld_sv_32_scaled<0b1011, "ldff1w",  ZPR32ExtSXTW32, ZPR32ExtUXTW32>;

  // Gathers using scaled 32-bit pointers with offset, e.g.
  //    ld1h z0.s, p0/z, [z0.s, #16]
  defm GLD1SB_S   : sve_mem_32b_gld_vi_32_ptrs<0b0000, "ld1sb",   imm0_31>;
  defm GLDFF1SB_S : sve_mem_32b_gld_vi_32_ptrs<0b0001, "ldff1sb", imm0_31>;
  defm GLD1B_S    : sve_mem_32b_gld_vi_32_ptrs<0b0010, "ld1b",    imm0_31>;
  defm GLDFF1B_S  : sve_mem_32b_gld_vi_32_ptrs<0b0011, "ldff1b",  imm0_31>;
  defm GLD1SH_S   : sve_mem_32b_gld_vi_32_ptrs<0b0100, "ld1sh",   uimm5s2>;
  defm GLDFF1SH_S : sve_mem_32b_gld_vi_32_ptrs<0b0101, "ldff1sh", uimm5s2>;
  defm GLD1H_S    : sve_mem_32b_gld_vi_32_ptrs<0b0110, "ld1h",    uimm5s2>;
  defm GLDFF1H_S  : sve_mem_32b_gld_vi_32_ptrs<0b0111, "ldff1h",  uimm5s2>;
  defm GLD1W      : sve_mem_32b_gld_vi_32_ptrs<0b1010, "ld1w",    uimm5s4>;
  defm GLDFF1W    : sve_mem_32b_gld_vi_32_ptrs<0b1011, "ldff1w",  uimm5s4>;

  // Gathers using scaled 64-bit pointers with offset, e.g.
  //    ld1h z0.d, p0/z, [z0.d, #16]
  defm GLD1SB_D   : sve_mem_64b_gld_vi_64_ptrs<0b0000, "ld1sb",   imm0_31>;
  defm GLDFF1SB_D : sve_mem_64b_gld_vi_64_ptrs<0b0001, "ldff1sb", imm0_31>;
  defm GLD1B_D    : sve_mem_64b_gld_vi_64_ptrs<0b0010, "ld1b",    imm0_31>;
  defm GLDFF1B_D  : sve_mem_64b_gld_vi_64_ptrs<0b0011, "ldff1b",  imm0_31>;
  defm GLD1SH_D   : sve_mem_64b_gld_vi_64_ptrs<0b0100, "ld1sh",   uimm5s2>;
  defm GLDFF1SH_D : sve_mem_64b_gld_vi_64_ptrs<0b0101, "ldff1sh", uimm5s2>;
  defm GLD1H_D    : sve_mem_64b_gld_vi_64_ptrs<0b0110, "ld1h",    uimm5s2>;
  defm GLDFF1H_D  : sve_mem_64b_gld_vi_64_ptrs<0b0111, "ldff1h",  uimm5s2>;
  defm GLD1SW_D   : sve_mem_64b_gld_vi_64_ptrs<0b1000, "ld1sw",   uimm5s4>;
  defm GLDFF1SW_D : sve_mem_64b_gld_vi_64_ptrs<0b1001, "ldff1sw", uimm5s4>;
  defm GLD1W_D    : sve_mem_64b_gld_vi_64_ptrs<0b1010, "ld1w",    uimm5s4>;
  defm GLDFF1W_D  : sve_mem_64b_gld_vi_64_ptrs<0b1011, "ldff1w",  uimm5s4>;
  defm GLD1D      : sve_mem_64b_gld_vi_64_ptrs<0b1110, "ld1d",    uimm5s8>;
  defm GLDFF1D    : sve_mem_64b_gld_vi_64_ptrs<0b1111, "ldff1d",  uimm5s8>;

  // Gathers using unscaled 64-bit offsets, e.g.
  //    ld1h z0.d, p0/z, [x0, z0.d]
  defm GLD1SB_D   : sve_mem_64b_gld_vs2_64_unscaled<0b0000, "ld1sb">;
  defm GLDFF1SB_D : sve_mem_64b_gld_vs2_64_unscaled<0b0001, "ldff1sb">;
  defm GLD1B_D    : sve_mem_64b_gld_vs2_64_unscaled<0b0010, "ld1b">;
  defm GLDFF1B_D  : sve_mem_64b_gld_vs2_64_unscaled<0b0011, "ldff1b">;
  defm GLD1SH_D   : sve_mem_64b_gld_vs2_64_unscaled<0b0100, "ld1sh">;
  defm GLDFF1SH_D : sve_mem_64b_gld_vs2_64_unscaled<0b0101, "ldff1sh">;
  defm GLD1H_D    : sve_mem_64b_gld_vs2_64_unscaled<0b0110, "ld1h">;
  defm GLDFF1H_D  : sve_mem_64b_gld_vs2_64_unscaled<0b0111, "ldff1h">;
  defm GLD1SW_D   : sve_mem_64b_gld_vs2_64_unscaled<0b1000, "ld1sw">;
  defm GLDFF1SW_D : sve_mem_64b_gld_vs2_64_unscaled<0b1001, "ldff1sw">;
  defm GLD1W_D    : sve_mem_64b_gld_vs2_64_unscaled<0b1010, "ld1w">;
  defm GLDFF1W_D  : sve_mem_64b_gld_vs2_64_unscaled<0b1011, "ldff1w">;
  defm GLD1D      : sve_mem_64b_gld_vs2_64_unscaled<0b1110, "ld1d">;
  defm GLDFF1D    : sve_mem_64b_gld_vs2_64_unscaled<0b1111, "ldff1d">;

  // Gathers using scaled 64-bit offsets, e.g.
  //    ld1h z0.d, p0/z, [x0, z0.d, lsl #1]
  defm GLD1SH_D   : sve_mem_64b_gld_sv2_64_scaled<0b0100, "ld1sh",   ZPR64ExtLSL16>;
  defm GLDFF1SH_D : sve_mem_64b_gld_sv2_64_scaled<0b0101, "ldff1sh", ZPR64ExtLSL16>;
  defm GLD1H_D    : sve_mem_64b_gld_sv2_64_scaled<0b0110, "ld1h",    ZPR64ExtLSL16>;
  defm GLDFF1H_D  : sve_mem_64b_gld_sv2_64_scaled<0b0111, "ldff1h",  ZPR64ExtLSL16>;
  defm GLD1SW_D   : sve_mem_64b_gld_sv2_64_scaled<0b1000, "ld1sw",   ZPR64ExtLSL32>;
  defm GLDFF1SW_D : sve_mem_64b_gld_sv2_64_scaled<0b1001, "ldff1sw", ZPR64ExtLSL32>;
  defm GLD1W_D    : sve_mem_64b_gld_sv2_64_scaled<0b1010, "ld1w",    ZPR64ExtLSL32>;
  defm GLDFF1W_D  : sve_mem_64b_gld_sv2_64_scaled<0b1011, "ldff1w",  ZPR64ExtLSL32>;
  defm GLD1D      : sve_mem_64b_gld_sv2_64_scaled<0b1110, "ld1d",    ZPR64ExtLSL64>;
  defm GLDFF1D    : sve_mem_64b_gld_sv2_64_scaled<0b1111, "ldff1d",  ZPR64ExtLSL64>;

  // Gathers using unscaled 32-bit offsets unpacked in 64-bits elements, e.g.
  //    ld1h z0.d, p0/z, [x0, z0.d, uxtw]
  defm GLD1SB_D   : sve_mem_64b_gld_vs_32_unscaled<0b0000, "ld1sb",   ZPR64ExtSXTW8Only, ZPR64ExtUXTW8Only>;
  defm GLDFF1SB_D : sve_mem_64b_gld_vs_32_unscaled<0b0001, "ldff1sb", ZPR64ExtSXTW8Only, ZPR64ExtUXTW8Only>;
  defm GLD1B_D    : sve_mem_64b_gld_vs_32_unscaled<0b0010, "ld1b",    ZPR64ExtSXTW8Only, ZPR64ExtUXTW8Only>;
  defm GLDFF1B_D  : sve_mem_64b_gld_vs_32_unscaled<0b0011, "ldff1b",  ZPR64ExtSXTW8Only, ZPR64ExtUXTW8Only>;
  defm GLD1SH_D   : sve_mem_64b_gld_vs_32_unscaled<0b0100, "ld1sh",   ZPR64ExtSXTW8, ZPR64ExtUXTW8>;
  defm GLDFF1SH_D : sve_mem_64b_gld_vs_32_unscaled<0b0101, "ldff1sh", ZPR64ExtSXTW8, ZPR64ExtUXTW8>;
  defm GLD1H_D    : sve_mem_64b_gld_vs_32_unscaled<0b0110, "ld1h",    ZPR64ExtSXTW8, ZPR64ExtUXTW8>;
  defm GLDFF1H_D  : sve_mem_64b_gld_vs_32_unscaled<0b0111, "ldff1h",  ZPR64ExtSXTW8, ZPR64ExtUXTW8>;
  defm GLD1SW_D   : sve_mem_64b_gld_vs_32_unscaled<0b1000, "ld1sw",   ZPR64ExtSXTW8, ZPR64ExtUXTW8>;
  defm GLDFF1SW_D : sve_mem_64b_gld_vs_32_unscaled<0b1001, "ldff1sw", ZPR64ExtSXTW8, ZPR64ExtUXTW8>;
  defm GLD1W_D    : sve_mem_64b_gld_vs_32_unscaled<0b1010, "ld1w",    ZPR64ExtSXTW8, ZPR64ExtUXTW8>;
  defm GLDFF1W_D  : sve_mem_64b_gld_vs_32_unscaled<0b1011, "ldff1w",  ZPR64ExtSXTW8, ZPR64ExtUXTW8>;
  defm GLD1D      : sve_mem_64b_gld_vs_32_unscaled<0b1110, "ld1d",    ZPR64ExtSXTW8, ZPR64ExtUXTW8>;
  defm GLDFF1D    : sve_mem_64b_gld_vs_32_unscaled<0b1111, "ldff1d",  ZPR64ExtSXTW8, ZPR64ExtUXTW8>;

  // Gathers using scaled 32-bit offsets unpacked in 64-bits elements, e.g.
  //    ld1h z0.d, p0/z, [x0, z0.d, uxtw #1]
  defm GLD1SH_D   : sve_mem_64b_gld_sv_32_scaled<0b0100, "ld1sh",  ZPR64ExtSXTW16, ZPR64ExtUXTW16>;
  defm GLDFF1SH_D : sve_mem_64b_gld_sv_32_scaled<0b0101, "ldff1sh",ZPR64ExtSXTW16, ZPR64ExtUXTW16>;
  defm GLD1H_D    : sve_mem_64b_gld_sv_32_scaled<0b0110, "ld1h",   ZPR64ExtSXTW16, ZPR64ExtUXTW16>;
  defm GLDFF1H_D  : sve_mem_64b_gld_sv_32_scaled<0b0111, "ldff1h", ZPR64ExtSXTW16, ZPR64ExtUXTW16>;
  defm GLD1SW_D   : sve_mem_64b_gld_sv_32_scaled<0b1000, "ld1sw",  ZPR64ExtSXTW32, ZPR64ExtUXTW32>;
  defm GLDFF1SW_D : sve_mem_64b_gld_sv_32_scaled<0b1001, "ldff1sw",ZPR64ExtSXTW32, ZPR64ExtUXTW32>;
  defm GLD1W_D    : sve_mem_64b_gld_sv_32_scaled<0b1010, "ld1w",   ZPR64ExtSXTW32, ZPR64ExtUXTW32>;
  defm GLDFF1W_D  : sve_mem_64b_gld_sv_32_scaled<0b1011, "ldff1w", ZPR64ExtSXTW32, ZPR64ExtUXTW32>;
  defm GLD1D      : sve_mem_64b_gld_sv_32_scaled<0b1110, "ld1d",   ZPR64ExtSXTW64, ZPR64ExtUXTW64>;
  defm GLDFF1D    : sve_mem_64b_gld_sv_32_scaled<0b1111, "ldff1d", ZPR64ExtSXTW64, ZPR64ExtUXTW64>;

  // Non-temporal contiguous loads (register + immediate)
  defm LDNT1B_ZRI : sve_mem_cldnt_si<0b00, "ldnt1b", Z_b, ZPR8>;
  defm LDNT1H_ZRI : sve_mem_cldnt_si<0b01, "ldnt1h", Z_h, ZPR16>;
  defm LDNT1W_ZRI : sve_mem_cldnt_si<0b10, "ldnt1w", Z_s, ZPR32>;
  defm LDNT1D_ZRI : sve_mem_cldnt_si<0b11, "ldnt1d", Z_d, ZPR64>;

  // Non-temporal contiguous loads (register + register)
  defm LDNT1B_ZRR : sve_mem_cldnt_ss<0b00, "ldnt1b", Z_b, ZPR8,  GPR64NoXZRshifted8>;
  defm LDNT1H_ZRR : sve_mem_cldnt_ss<0b01, "ldnt1h", Z_h, ZPR16, GPR64NoXZRshifted16>;
  defm LDNT1W_ZRR : sve_mem_cldnt_ss<0b10, "ldnt1w", Z_s, ZPR32, GPR64NoXZRshifted32>;
  defm LDNT1D_ZRR : sve_mem_cldnt_ss<0b11, "ldnt1d", Z_d, ZPR64, GPR64NoXZRshifted64>;

  // contiguous store with immediates
  defm ST1B_IMM   : sve_mem_cst_si<0b00, 0b00, "st1b", Z_b, ZPR8>;
  defm ST1B_H_IMM : sve_mem_cst_si<0b00, 0b01, "st1b", Z_h, ZPR16>;
  defm ST1B_S_IMM : sve_mem_cst_si<0b00, 0b10, "st1b", Z_s, ZPR32>;
  defm ST1B_D_IMM : sve_mem_cst_si<0b00, 0b11, "st1b", Z_d, ZPR64>;
  defm ST1H_IMM   : sve_mem_cst_si<0b01, 0b01, "st1h", Z_h, ZPR16>;
  defm ST1H_S_IMM : sve_mem_cst_si<0b01, 0b10, "st1h", Z_s, ZPR32>;
  defm ST1H_D_IMM : sve_mem_cst_si<0b01, 0b11, "st1h", Z_d, ZPR64>;
  defm ST1W_IMM   : sve_mem_cst_si<0b10, 0b10, "st1w", Z_s, ZPR32>;
  defm ST1W_D_IMM : sve_mem_cst_si<0b10, 0b11, "st1w", Z_d, ZPR64>;
  defm ST1D_IMM   : sve_mem_cst_si<0b11, 0b11, "st1d", Z_d, ZPR64>;

  // contiguous store with reg+reg addressing.
  defm ST1B   : sve_mem_cst_ss<0b0000, "st1b", Z_b, ZPR8,  GPR64NoXZRshifted8>;
  defm ST1B_H : sve_mem_cst_ss<0b0001, "st1b", Z_h, ZPR16, GPR64NoXZRshifted8>;
  defm ST1B_S : sve_mem_cst_ss<0b0010, "st1b", Z_s, ZPR32, GPR64NoXZRshifted8>;
  defm ST1B_D : sve_mem_cst_ss<0b0011, "st1b", Z_d, ZPR64, GPR64NoXZRshifted8>;
  defm ST1H   : sve_mem_cst_ss<0b0101, "st1h", Z_h, ZPR16, GPR64NoXZRshifted16>;
  defm ST1H_S : sve_mem_cst_ss<0b0110, "st1h", Z_s, ZPR32, GPR64NoXZRshifted16>;
  defm ST1H_D : sve_mem_cst_ss<0b0111, "st1h", Z_d, ZPR64, GPR64NoXZRshifted16>;
  defm ST1W   : sve_mem_cst_ss<0b1010, "st1w", Z_s, ZPR32, GPR64NoXZRshifted32>;
  defm ST1W_D : sve_mem_cst_ss<0b1011, "st1w", Z_d, ZPR64, GPR64NoXZRshifted32>;
  defm ST1D   : sve_mem_cst_ss<0b1111, "st1d", Z_d, ZPR64, GPR64NoXZRshifted64>;

  // Scatters using unscaled 32-bit offsets, e.g.
  //    st1h z0.s, p0, [x0, z0.s, uxtw]
  // and unpacked:
  //    st1h z0.d, p0, [x0, z0.d, uxtw]
  defm SST1B_D : sve_mem_sst_sv_32_unscaled<0b000, "st1b", Z_d, ZPR64, ZPR64ExtSXTW8Only, ZPR64ExtUXTW8Only>;
  defm SST1B_S : sve_mem_sst_sv_32_unscaled<0b001, "st1b", Z_s, ZPR32, ZPR32ExtSXTW8Only, ZPR32ExtUXTW8Only>;
  defm SST1H_D : sve_mem_sst_sv_32_unscaled<0b010, "st1h", Z_d, ZPR64, ZPR64ExtSXTW8, ZPR64ExtUXTW8>;
  defm SST1H_S : sve_mem_sst_sv_32_unscaled<0b011, "st1h", Z_s, ZPR32, ZPR32ExtSXTW8, ZPR32ExtUXTW8>;
  defm SST1W_D : sve_mem_sst_sv_32_unscaled<0b100, "st1w", Z_d, ZPR64, ZPR64ExtSXTW8, ZPR64ExtUXTW8>;
  defm SST1W   : sve_mem_sst_sv_32_unscaled<0b101, "st1w", Z_s, ZPR32, ZPR32ExtSXTW8, ZPR32ExtUXTW8>;
  defm SST1D   : sve_mem_sst_sv_32_unscaled<0b110, "st1d", Z_d, ZPR64, ZPR64ExtSXTW8, ZPR64ExtUXTW8>;

  // Scatters using scaled 32-bit offsets, e.g.
  //    st1h z0.s, p0, [x0, z0.s, uxtw #1]
  // and unpacked:
  //    st1h z0.d, p0, [x0, z0.d, uxtw #1]
  defm SST1H_D : sve_mem_sst_sv_32_scaled<0b010, "st1h", Z_d, ZPR64, ZPR64ExtSXTW16, ZPR64ExtUXTW16>;
  defm SST1H_S : sve_mem_sst_sv_32_scaled<0b011, "st1h", Z_s, ZPR32, ZPR32ExtSXTW16, ZPR32ExtUXTW16>;
  defm SST1W_D : sve_mem_sst_sv_32_scaled<0b100, "st1w", Z_d, ZPR64, ZPR64ExtSXTW32, ZPR64ExtUXTW32>;
  defm SST1W   : sve_mem_sst_sv_32_scaled<0b101, "st1w", Z_s, ZPR32, ZPR32ExtSXTW32, ZPR32ExtUXTW32>;
  defm SST1D   : sve_mem_sst_sv_32_scaled<0b110, "st1d", Z_d, ZPR64, ZPR64ExtSXTW64, ZPR64ExtUXTW64>;

  // Scatters using 32/64-bit pointers with offset, e.g.
  //    st1h z0.s, p0, [z0.s, #16]
  //    st1h z0.d, p0, [z0.d, #16]
  defm SST1B_D : sve_mem_sst_vi_ptrs<0b000, "st1b", Z_d, ZPR64, imm0_31>;
  defm SST1B_S : sve_mem_sst_vi_ptrs<0b001, "st1b", Z_s, ZPR32, imm0_31>;
  defm SST1H_D : sve_mem_sst_vi_ptrs<0b010, "st1h", Z_d, ZPR64, uimm5s2>;
  defm SST1H_S : sve_mem_sst_vi_ptrs<0b011, "st1h", Z_s, ZPR32, uimm5s2>;
  defm SST1W_D : sve_mem_sst_vi_ptrs<0b100, "st1w", Z_d, ZPR64, uimm5s4>;
  defm SST1W   : sve_mem_sst_vi_ptrs<0b101, "st1w", Z_s, ZPR32, uimm5s4>;
  defm SST1D   : sve_mem_sst_vi_ptrs<0b110, "st1d", Z_d, ZPR64, uimm5s8>;

  // Scatters using unscaled 64-bit offsets, e.g.
  //    st1h z0.d, p0, [x0, z0.d]
  defm SST1B_D : sve_mem_sst_sv_64_unscaled<0b00, "st1b">;
  defm SST1H_D : sve_mem_sst_sv_64_unscaled<0b01, "st1h">;
  defm SST1W_D : sve_mem_sst_sv_64_unscaled<0b10, "st1w">;
  defm SST1D   : sve_mem_sst_sv_64_unscaled<0b11, "st1d">;

  // Scatters using scaled 64-bit offsets, e.g.
  //    st1h z0.d, p0, [x0, z0.d, lsl #1]
  defm SST1H_D_SCALED : sve_mem_sst_sv_64_scaled<0b01, "st1h", ZPR64ExtLSL16>;
  defm SST1W_D_SCALED : sve_mem_sst_sv_64_scaled<0b10, "st1w", ZPR64ExtLSL32>;
  defm SST1D_SCALED   : sve_mem_sst_sv_64_scaled<0b11, "st1d", ZPR64ExtLSL64>;

  // ST(2|3|4) structured stores (register + immediate)
  defm ST2B_IMM : sve_mem_est_si<0b00, 0b01, ZZ_b,   "st2b", simm4s2>;
  defm ST3B_IMM : sve_mem_est_si<0b00, 0b10, ZZZ_b,  "st3b", simm4s3>;
  defm ST4B_IMM : sve_mem_est_si<0b00, 0b11, ZZZZ_b, "st4b", simm4s4>;
  defm ST2H_IMM : sve_mem_est_si<0b01, 0b01, ZZ_h,   "st2h", simm4s2>;
  defm ST3H_IMM : sve_mem_est_si<0b01, 0b10, ZZZ_h,  "st3h", simm4s3>;
  defm ST4H_IMM : sve_mem_est_si<0b01, 0b11, ZZZZ_h, "st4h", simm4s4>;
  defm ST2W_IMM : sve_mem_est_si<0b10, 0b01, ZZ_s,   "st2w", simm4s2>;
  defm ST3W_IMM : sve_mem_est_si<0b10, 0b10, ZZZ_s,  "st3w", simm4s3>;
  defm ST4W_IMM : sve_mem_est_si<0b10, 0b11, ZZZZ_s, "st4w", simm4s4>;
  defm ST2D_IMM : sve_mem_est_si<0b11, 0b01, ZZ_d,   "st2d", simm4s2>;
  defm ST3D_IMM : sve_mem_est_si<0b11, 0b10, ZZZ_d,  "st3d", simm4s3>;
  defm ST4D_IMM : sve_mem_est_si<0b11, 0b11, ZZZZ_d, "st4d", simm4s4>;

  // ST(2|3|4) structured stores (register + register)
  def ST2B : sve_mem_est_ss<0b00, 0b01, ZZ_b,   "st2b", GPR64NoXZRshifted8>;
  def ST3B : sve_mem_est_ss<0b00, 0b10, ZZZ_b,  "st3b", GPR64NoXZRshifted8>;
  def ST4B : sve_mem_est_ss<0b00, 0b11, ZZZZ_b, "st4b", GPR64NoXZRshifted8>;
  def ST2H : sve_mem_est_ss<0b01, 0b01, ZZ_h,   "st2h", GPR64NoXZRshifted16>;
  def ST3H : sve_mem_est_ss<0b01, 0b10, ZZZ_h,  "st3h", GPR64NoXZRshifted16>;
  def ST4H : sve_mem_est_ss<0b01, 0b11, ZZZZ_h, "st4h", GPR64NoXZRshifted16>;
  def ST2W : sve_mem_est_ss<0b10, 0b01, ZZ_s,   "st2w", GPR64NoXZRshifted32>;
  def ST3W : sve_mem_est_ss<0b10, 0b10, ZZZ_s,  "st3w", GPR64NoXZRshifted32>;
  def ST4W : sve_mem_est_ss<0b10, 0b11, ZZZZ_s, "st4w", GPR64NoXZRshifted32>;
  def ST2D : sve_mem_est_ss<0b11, 0b01, ZZ_d,   "st2d", GPR64NoXZRshifted64>;
  def ST3D : sve_mem_est_ss<0b11, 0b10, ZZZ_d,  "st3d", GPR64NoXZRshifted64>;
  def ST4D : sve_mem_est_ss<0b11, 0b11, ZZZZ_d, "st4d", GPR64NoXZRshifted64>;

  // Non-temporal contiguous stores (register + immediate)
  defm STNT1B_ZRI : sve_mem_cstnt_si<0b00, "stnt1b", Z_b, ZPR8>;
  defm STNT1H_ZRI : sve_mem_cstnt_si<0b01, "stnt1h", Z_h, ZPR16>;
  defm STNT1W_ZRI : sve_mem_cstnt_si<0b10, "stnt1w", Z_s, ZPR32>;
  defm STNT1D_ZRI : sve_mem_cstnt_si<0b11, "stnt1d", Z_d, ZPR64>;

  // Non-temporal contiguous stores (register + register)
  defm STNT1B_ZRR : sve_mem_cstnt_ss<0b00, "stnt1b", Z_b, ZPR8, GPR64NoXZRshifted8>;
  defm STNT1H_ZRR : sve_mem_cstnt_ss<0b01, "stnt1h", Z_h, ZPR16, GPR64NoXZRshifted16>;
  defm STNT1W_ZRR : sve_mem_cstnt_ss<0b10, "stnt1w", Z_s, ZPR32, GPR64NoXZRshifted32>;
  defm STNT1D_ZRR : sve_mem_cstnt_ss<0b11, "stnt1d", Z_d, ZPR64, GPR64NoXZRshifted64>;

  // Fill/Spill
  defm LDR_ZXI : sve_mem_z_fill<"ldr">;
  defm LDR_PXI : sve_mem_p_fill<"ldr">;
  defm STR_ZXI : sve_mem_z_spill<"str">;
  defm STR_PXI : sve_mem_p_spill<"str">;

  // Contiguous prefetch (register + immediate)
  defm PRFB_PRI : sve_mem_prfm_si<0b00, "prfb">;
  defm PRFH_PRI : sve_mem_prfm_si<0b01, "prfh">;
  defm PRFW_PRI : sve_mem_prfm_si<0b10, "prfw">;
  defm PRFD_PRI : sve_mem_prfm_si<0b11, "prfd">;

  // Contiguous prefetch (register + register)
  def PRFB_PRR : sve_mem_prfm_ss<0b001, "prfb", GPR64NoXZRshifted8>;
  def PRFH_PRR : sve_mem_prfm_ss<0b011, "prfh", GPR64NoXZRshifted16>;
  def PRFS_PRR : sve_mem_prfm_ss<0b101, "prfw", GPR64NoXZRshifted32>;
  def PRFD_PRR : sve_mem_prfm_ss<0b111, "prfd", GPR64NoXZRshifted64>;

  // Gather prefetch using scaled 32-bit offsets, e.g.
  //    prfh pldl1keep, p0, [x0, z0.s, uxtw #1]
  defm PRFB_S : sve_mem_32b_prfm_sv_scaled<0b00, "prfb", ZPR32ExtSXTW8Only,  ZPR32ExtUXTW8Only>;
  defm PRFH_S : sve_mem_32b_prfm_sv_scaled<0b01, "prfh", ZPR32ExtSXTW16, ZPR32ExtUXTW16>;
  defm PRFW_S : sve_mem_32b_prfm_sv_scaled<0b10, "prfw", ZPR32ExtSXTW32, ZPR32ExtUXTW32>;
  defm PRFD_S : sve_mem_32b_prfm_sv_scaled<0b11, "prfd", ZPR32ExtSXTW64, ZPR32ExtUXTW64>;

  // Gather prefetch using unpacked, scaled 32-bit offsets, e.g.
  //    prfh pldl1keep, p0, [x0, z0.d, uxtw #1]
  defm PRFB_D : sve_mem_64b_prfm_sv_ext_scaled<0b00, "prfb", ZPR64ExtSXTW8Only, ZPR64ExtUXTW8Only>;
  defm PRFH_D : sve_mem_64b_prfm_sv_ext_scaled<0b01, "prfh", ZPR64ExtSXTW16, ZPR64ExtUXTW16>;
  defm PRFW_D : sve_mem_64b_prfm_sv_ext_scaled<0b10, "prfw", ZPR64ExtSXTW32, ZPR64ExtUXTW32>;
  defm PRFD_D : sve_mem_64b_prfm_sv_ext_scaled<0b11, "prfd", ZPR64ExtSXTW64, ZPR64ExtUXTW64>;

  // Gather prefetch using scaled 64-bit offsets, e.g.
  //    prfh pldl1keep, p0, [x0, z0.d, lsl #1]
  defm PRFB_D_SCALED : sve_mem_64b_prfm_sv_lsl_scaled<0b00, "prfb", ZPR64ExtLSL8>;
  defm PRFH_D_SCALED : sve_mem_64b_prfm_sv_lsl_scaled<0b01, "prfh", ZPR64ExtLSL16>;
  defm PRFW_D_SCALED : sve_mem_64b_prfm_sv_lsl_scaled<0b10, "prfw", ZPR64ExtLSL32>;
  defm PRFD_D_SCALED : sve_mem_64b_prfm_sv_lsl_scaled<0b11, "prfd", ZPR64ExtLSL64>;

  // Gather prefetch using 32/64-bit pointers with offset, e.g.
  //    prfh pldl1keep, p0, [z0.s, #16]
  //    prfh pldl1keep, p0, [z0.d, #16]
  defm PRFB_S_PZI : sve_mem_32b_prfm_vi<0b00, "prfb", imm0_31>;
  defm PRFH_S_PZI : sve_mem_32b_prfm_vi<0b01, "prfh", uimm5s2>;
  defm PRFW_S_PZI : sve_mem_32b_prfm_vi<0b10, "prfw", uimm5s4>;
  defm PRFD_S_PZI : sve_mem_32b_prfm_vi<0b11, "prfd", uimm5s8>;

  defm PRFB_D_PZI : sve_mem_64b_prfm_vi<0b00, "prfb", imm0_31>;
  defm PRFH_D_PZI : sve_mem_64b_prfm_vi<0b01, "prfh", uimm5s2>;
  defm PRFW_D_PZI : sve_mem_64b_prfm_vi<0b10, "prfw", uimm5s4>;
  defm PRFD_D_PZI : sve_mem_64b_prfm_vi<0b11, "prfd", uimm5s8>;

  defm ZIP1_ZZZ : sve_int_perm_bin_perm_zz<0b000, "zip1">;
  defm ZIP2_ZZZ : sve_int_perm_bin_perm_zz<0b001, "zip2">;

  defm ZIP1_PPP : sve_int_perm_bin_perm_pp<0b000, "zip1">;
  defm ZIP2_PPP : sve_int_perm_bin_perm_pp<0b001, "zip2">;

  defm DUP_ZR  : sve_int_perm_dup_r<"dup">;

  def RDVLI_XI  : sve_int_read_vl_a<0b0, 0b11111, "rdvl">;
  def ADDVL_XXI : sve_int_arith_vl<0b0, "addvl">;
  def ADDPL_XXI : sve_int_arith_vl<0b1, "addpl">;

  defm INDEX_RR : sve_int_index_rr<"index">;
  defm INDEX_IR : sve_int_index_ir<"index">;
  defm INDEX_RI : sve_int_index_ri<"index">;
  defm INDEX_II : sve_int_index_ii<"index">;

  defm LSR_ZZI : sve_int_bin_cons_shift_b_right<0b01, "lsr">;
  defm LSL_ZZI : sve_int_bin_cons_shift_b_left< 0b11, "lsl">;
}
