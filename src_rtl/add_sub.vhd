----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2019 11:49:58 AM
-- Design Name: 
-- Module Name: Add_and_Sub - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Add_and_Sub is
    Port ( rc_in : in STD_LOGIC_VECTOR (3 downto 0);
           ic_in : in STD_LOGIC_VECTOR (2 downto 0);
           addc_in : in STD_LOGIC_VECTOR (31 downto 0);
           subc_out : out STD_LOGIC_VECTOR (31 downto 0));
end Add_and_Sub;

architecture addc_subc of Add_and_Sub is

signal addc_rom_ic_out : STD_LOGIC_VECTOR(3 downto 0);
signal addc_rom_rc_out : STD_LOGIC_VECTOR(3 downto 0);

signal addc_xor1_out : STD_LOGIC_VECTOR(3 downto 0);
signal addc_out : STD_LOGIC_VECTOR(3 downto 0);
signal subc_in : STD_LOGIC_VECTOR(31 downto 0);

begin
    
    -- addc only affects first cell (4 bits) of row
    addc_xor1_out <= addc_in(31 downto 28) xor addc_rom_rc_out;
    addc_out <= addc_xor1_out xor addc_rom_ic_out;
    
    addc_rom_ic1: entity work.add_sub_rom(asr)
		generic map (w => 3, y => 4, sel => 0)
        port map (ADDR => ic_in,
                  Dout => addc_rom_ic_out);
                  
    addc_rom_rc1: entity work.add_sub_rom(asr)
		generic map (w => 4, y => 4, sel => 1)
        port map (ADDR => rc_in,
                  Dout => addc_rom_rc_out);
   

    subc_in <= addc_out & addc_in(27 downto 0);

	-- Generate x8 sboxes --
	gen_sbox: for i in 7 downto 0 generate 
		subc_rom_sbox: entity work.add_sub_rom(asr)
			generic map (w => 4, y => 4, sel => 2)
			port map (ADDR => subc_in(4*i + 3 downto 4*i),
					  Dout => subc_out(4*i + 3 downto 4*i));
	end generate gen_sbox;
	
end addc_subc;
