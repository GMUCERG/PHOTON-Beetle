----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2020 06:45:02 AM
-- Design Name: 
-- Module Name: mcs - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mcs is
    Port ( w0 : in STD_LOGIC_VECTOR(127 downto 0);
           
           p256_sel : in STD_LOGIC;
           
           y0 : out STD_LOGIC_VECTOR(255 downto 0)
        );
end mcs;

architecture Behavioral of mcs is

signal mcs_in : STD_LOGIC_VECTOR(127 downto 0);
signal mcs_sig : STD_LOGIC_VECTOR(255 downto 0);
signal mcs_out : STD_LOGIC_VECTOR(255 downto 0);

begin

    -- Accounts for multiplying rows instead of columns
    -- Ex: w0[32*4 - 1 downto 31 * 4]
    -- 4-bit segments of 32-bit sections
    gen_mcs_in1: for ii in 0 to 7 generate
        mcs_in(127-(ii*16) downto 112-(ii*16)) <= 
            w0((4*(8-ii))+95 downto (4*(7-ii)+96)) &
            w0((4*(8-ii))+63 downto (4*(7-ii)+64)) &
            w0((4*(8-ii))+31 downto (4*(7-ii)+32)) &
            w0((4*(8-ii))-1 downto (4*(7-ii)));
    end generate gen_mcs_in1;
    
    -- Actual multiplication operation
    gen_mat1: for ii in 0 to 7 generate
        mcs_mat1: entity work.mcs_matrix(mat1)
        Port map ( w0 => mcs_in(16*(7-ii)+15 downto 16*(7-ii)),
                   p256_sel => p256_sel,
                   y0 => mcs_sig(255-(ii*32) downto 224-(ii*32)));
    end generate gen_mat1;

    -- Accounts for multiplying rows instead of columns
    gen_mat2: for ii in 0 to 7 generate
        mcs_out(255-(ii*32) downto 224-(ii*32)) <= mcs_sig(255-(ii*4) downto 252-(ii*4))
           & mcs_sig(223-(ii*4) downto 220-(ii*4))
           & mcs_sig(191-(ii*4) downto 188-(ii*4))
           & mcs_sig(159-(ii*4) downto 156-(ii*4))
           & mcs_sig(127-(ii*4) downto 124-(ii*4))
           & mcs_sig(95-(ii*4) downto 92-(ii*4))
           & mcs_sig(63-(ii*4) downto 60-(ii*4))
           & mcs_sig(31-(ii*4) downto 28-(ii*4));
    end generate gen_mat2;

                       
    y0 <= mcs_out;

    
end Behavioral;
