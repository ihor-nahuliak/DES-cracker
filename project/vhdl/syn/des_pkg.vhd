------------------------------------------------------------
-- Author       :   Alessandro Tempia Calvino, Pietro Mambelli
-- File         :   des_pkg.vhd
------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

package des_pkg is

    constant DES_NUMBER     : integer := 11;
    constant PIPE_STAGES    : natural := 17;

    --subtypes for redefinition of vectors
    subtype w28 is std_ulogic_vector(1 to 28);
    subtype w32 is std_ulogic_vector(1 to 32);
    subtype w48 is std_ulogic_vector(1 to 48);
    subtype w56 is std_ulogic_vector(1 to 56);
    subtype w64 is std_ulogic_vector(1 to 64);

    type table is array (natural range <>) of natural;
    type s_matrix is array (natural range <>, natural range <>) of std_ulogic_vector(1 to 4);
    type s_array is array (0 to 7) of s_matrix(0 to 3, 0 to 15);
    type key_array is array (1 to 16) of w48;
    type cd_array is array (0 to 16) of w28;
    type des_out_array is array (0 to DES_NUMBER-1) of w64;


    constant IP_TABLE : table (1 to 64) := (58, 50, 42, 34, 26, 18 , 10, 2,
                                            60, 52, 44, 36, 28, 20, 12, 4,
                                            62, 54, 46, 38, 30, 22, 14, 6,
                                            64, 56, 48, 40, 32, 24, 16, 8,
                                            57, 49, 41, 33, 25, 17, 9, 1,
                                            59, 51, 43, 35, 27, 19, 11, 3,
                                            61, 53, 45, 37, 29, 21, 13, 5,
                                            63, 55, 47, 39, 31, 23, 15, 7);

    constant FP_TABLE : table (1 to 64) := (40, 8, 48, 16, 56, 24, 64, 32,
                                            39, 7, 47, 15, 55, 23, 63, 31,
                                            38, 6, 46, 14, 54, 22, 62, 30,
                                            37, 5, 45, 13, 53, 21, 61, 29,
                                            36, 4, 44, 12, 52, 20, 60, 28,
                                            35, 3, 43, 11, 51, 19, 59, 27,
                                            34, 2, 42, 10, 50, 18, 58, 26,
                                            33, 1, 41,  9, 49, 17, 57, 25);

    constant E_TABLE : table (1 to 48) :=  (32,  1,  2,  3,  4,  5,
                                            4,  5,  6,  7,  8,  9,
                                            8,  9, 10, 11, 12, 13,
                                            12, 13, 14, 15, 16, 17,
                                            16, 17, 18, 19, 20, 21,
                                            20, 21, 22, 23, 24, 25,
                                            24, 25, 26, 27, 28, 29,
                                            28, 29, 30, 31, 32,  1);

    constant P_TABLE : table (1 to 32) :=  (16,  7, 20, 21,
                                            29, 12, 28, 17,
                                            1, 15, 23, 26,
                                            5, 18, 31, 10,
                                            2,  8, 24, 14,
                                            32, 27,  3,  9,
                                            19, 13, 30,  6,
                                            22, 11,  4, 25);

    constant PC1_TABLE : table (1 to 56) :=  (57, 49, 41, 33, 25, 17,  9,
                                              1, 58, 50, 42, 34, 26, 18,
                                              10,  2, 59, 51, 43, 35, 27,
                                              19, 11,  3, 60, 52, 44, 36,
                                              63, 55, 47, 39, 31, 23, 15,
                                              7, 62, 54, 46, 38, 30, 22,
                                              14,  6, 61, 53, 45, 37, 29,
                                              21, 13,  5, 28, 20, 12,  4);

    -- Used to generate subkeys
    constant PC2_TABLE : table(1 to 48) :=   (14, 17, 11, 24,  1,  5,
                                              3, 28, 15,  6, 21, 10,
                                              23, 19, 12,  4, 26,  8,
                                              16,  7, 27, 20, 13,  2,
                                              41, 52, 31, 37, 47, 55,
                                              30, 40, 51, 45, 33, 48,
                                              44, 49, 39, 56, 34, 53,
                                              46, 42, 50, 36, 29, 32);

    constant SHIFT_TABLE : table(1 to 16) := (1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1);


    constant S0 : s_matrix(0 to 3, 0 to 15) := (("1110", "0100", "1101", "0001", "0010", "1111", "1011", "1000", "0011", "1010", "0110", "1100", "0101", "1001", "0000", "0111"),
                ("0000", "1111", "0111", "0100", "1110", "0010", "1101", "0001", "1010", "0110", "1100", "1011", "1001", "0101", "0011", "1000"),
                ("0100", "0001", "1110", "1000", "1101", "0110", "0010", "1011", "1111", "1100", "1001", "0111", "0011", "1010", "0101", "0000"),
                ("1111", "1100", "1000", "0010", "0100", "1001", "0001", "0111", "0101", "1011", "0011", "1110", "1010", "0000", "0110", "1101"));


    constant S1 : s_matrix(0 to 3, 0 to 15) := (("1111", "0001", "1000", "1110", "0110", "1011", "0011", "0100", "1001", "0111", "0010", "1101", "1100", "0000", "0101", "1010"),
                ( "0011", "1101", "0100", "0111", "1111", "0010", "1000", "1110", "1100", "0000", "0001", "1010", "0110", "1001", "1011", "0101"),
                ( "0000", "1110", "0111", "1011", "1010", "0100", "1101", "0001", "0101", "1000", "1100", "0110", "1001", "0011", "0010", "1111"),
                ( "1101", "1000", "1010", "0001", "0011", "1111", "0100", "0010", "1011", "0110", "0111", "1100", "0000", "0101", "1110", "1001"));



    constant S2 : s_matrix(0 to 3, 0 to 15) := (("1010", "0000", "1001", "1110", "0110", "0011", "1111", "0101", "0001", "1101", "1100", "0111", "1011", "0100", "0010", "1000"),
                ( "1101", "0111", "0000", "1001", "0011", "0100", "0110", "1010", "0010", "1000", "0101", "1110", "1100", "1011", "1111", "0001"),
                ( "1101", "0110", "0100", "1001", "1000", "1111", "0011", "0000", "1011", "0001", "0010", "1100", "0101", "1010", "1110", "0111"),
                ( "0001", "1010", "1101", "0000", "0110", "1001", "1000", "0111", "0100", "1111", "1110", "0011", "1011", "0101", "0010", "1100"));


    constant S3 : s_matrix(0 to 3, 0 to 15) := (("0111", "1101", "1110", "0011", "0000", "0110", "1001", "1010", "0001", "0010", "1000", "0101", "1011", "1100", "0100", "1111"),
                ( "1101", "1000", "1011", "0101", "0110", "1111", "0000", "0011", "0100", "0111", "0010", "1100", "0001", "1010", "1110", "1001"),
                ( "1010", "0110", "1001", "0000", "1100", "1011", "0111", "1101", "1111", "0001", "0011", "1110", "0101", "0010", "1000", "0100"),
                ( "0011", "1111", "0000", "0110", "1010", "0001", "1101", "1000", "1001", "0100", "0101", "1011", "1100", "0111", "0010", "1110"));


    constant S4 : s_matrix(0 to 3, 0 to 15) := (("0010", "1100", "0100", "0001", "0111", "1010", "1011", "0110", "1000", "0101", "0011", "1111", "1101", "0000", "1110", "1001"),
                ( "1110", "1011", "0010", "1100", "0100", "0111", "1101", "0001", "0101", "0000", "1111", "1010", "0011", "1001", "1000", "0110"),
                ( "0100", "0010", "0001", "1011", "1010", "1101", "0111", "1000", "1111", "1001", "1100", "0101", "0110", "0011", "0000", "1110"),
                ( "1011", "1000", "1100", "0111", "0001", "1110", "0010", "1101", "0110", "1111", "0000", "1001", "1010", "0100", "0101", "0011"));


    constant S5 : s_matrix(0 to 3, 0 to 15) := (("1100", "0001", "1010", "1111", "1001", "0010", "0110", "1000", "0000", "1101", "0011", "0100", "1110", "0111", "0101", "1011"),
                ( "1010", "1111", "0100", "0010", "0111", "1100", "1001", "0101", "0110", "0001", "1101", "1110", "0000", "1011", "0011", "1000"),
                ( "1001", "1110", "1111", "0101", "0010", "1000", "1100", "0011", "0111", "0000", "0100", "1010", "0001", "1101", "1011", "0110"),
                ( "0100", "0011", "0010", "1100", "1001", "0101", "1111", "1010", "1011", "1110", "0001", "0111", "0110", "0000", "1000", "1101"));


    constant S6 : s_matrix(0 to 3, 0 to 15) := (("0100", "1011", "0010", "1110", "1111", "0000", "1000", "1101", "0011", "1100", "1001", "0111", "0101", "1010", "0110", "0001"),
              ( "1101", "0000", "1011", "0111", "0100", "1001", "0001", "1010", "1110", "0011", "0101", "1100", "0010", "1111", "1000", "0110"),
              ( "0001", "0100", "1011", "1101", "1100", "0011", "0111", "1110", "1010", "1111", "0110", "1000", "0000", "0101", "1001", "0010"),
              ( "0110", "1011", "1101", "1000", "0001", "0100", "1010", "0111", "1001", "0101", "0000", "1111", "1110", "0010", "0011", "1100"));


    constant S7 : s_matrix(0 to 3, 0 to 15) := (("1101", "0010", "1000", "0100", "0110", "1111", "1011", "0001", "1010", "1001", "0011", "1110", "0101", "0000", "1100", "0111"),
                ( "0001", "1111", "1101", "1000", "1010", "0011", "0111", "0100", "1100", "0101", "0110", "1011", "0000", "1110", "1001", "0010"),
                ( "0111", "1011", "0100", "0001", "1001", "1100", "1110", "0010", "0000", "0110", "1010", "1101", "1111", "0011", "0101", "1000"),
                ( "0010", "0001", "1110", "0111", "0100", "1010", "1000", "1101", "1111", "1100", "1001", "0000", "0011", "0101", "0110", "1011"));



    constant S_BOXES : s_array := (S0, S1, S2, S3, S4, S5, S6, S7);

    -- FUNCTIONS DECLARATION
    function left_shift(w: w28; amount: natural) return w28;
    --function right_shift(w: w28, amount: natural) return w28;
    function ip(w: w64) return w64;
    function fp(w: w64) return w64;
    function e(w: w32) return w48;
    function p(w: w32) return w32;
    function pc1(w: w64) return w56;
    function pc1_inv(w: w56) return w56;
    function pc2(w: w56) return w48;

end package;

package body des_pkg is

  function left_shift(w: w28; amount: natural) return w28 is
    begin
      if amount = 2 then
        return w(3 to 28) & w(1 to 2);
      elsif amount = 1 then
        return w(2 to 28) & w(1);
      else
        assert false report "ERROR: amount of shift not allowed" severity failure;
      end if;
  end function left_shift;

  function ip(w: w64) return w64 is
    variable result: w64;
    begin
      for i in 1 to 64 loop
        result(i) := w(IP_TABLE(i));
      end loop;
      return result;
  end function ip;

  function fp(w: w64) return w64 is
    variable result: w64;
    begin
      for i in 1 to 64 loop
        result(i) := w(FP_TABLE(i));
      end loop;
      return result;
  end function fp;

  function e(w: w32) return w48 is
    variable result: w48;
    begin
      for i in 1 to 48 loop
        result(i) := w(E_TABLE(i));
      end loop;
      return result;
  end function e;

  function p(w: w32) return w32 is
    variable result: w32;
    begin
      for i in 1 to 32 loop
        result(i) := w(P_TABLE(i));
      end loop;
      return result;
  end function p;

  function pc1(w: w64) return w56 is
    variable result: w56;
    begin
      for i in 1 to 56 loop
        result(i) := w(PC1_TABLE(i));
      end loop;
      return result;
  end function pc1;

  function pc1_inv(w: w56) return w56 is
    variable result : w56;
    variable tmp    : w64 := (others => '0');
    begin
      for i in 1 to 56 loop
        tmp(PC1_TABLE(i)) := w(i);
      end loop;
      result := tmp(1 to 7) & tmp(9 to 15) & tmp(17 to 23) & tmp(25 to 31) & tmp(33 to 39) & tmp(41 to 47) & tmp(49 to 55) & tmp(57 to 63);
      return result;
  end function pc1_inv;

  function pc2(w: w56) return w48 is
    variable result: w48;
    begin
      for i in 1 to 48 loop
        result(i) := w(PC2_TABLE(i));
      end loop;
      return result;
  end function pc2;

end package body des_pkg;
