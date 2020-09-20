----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2020 11:33:45 PM
-- Design Name: 
-- Module Name: iv - Behavioral
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

entity ram is
	generic (w : integer := 1;
			 y : integer := 32);
    Port ( clk : in STD_LOGIC;
           din : in STD_LOGIC_VECTOR(y-1 downto 0);
           addr : in STD_LOGIC_VECTOR(w-1 downto 0);
           we : in STD_LOGIC;
           dout : out STD_LOGIC_VECTOR(y-1 downto 0));
           
end ram;
architecture Behavioral of ram is

type ram_type is array (0 to 2**w - 1) of STD_LOGIC_VECTOR (y-1 downto 0);
signal RAM : ram_type; 
begin

dout <= RAM(to_integer(unsigned(addr)));

process (clk)
begin
    if rising_edge(clk) then
        if we = '1' then
            RAM(to_integer(unsigned(addr))) <= din;
        end if;
    end if;
end process;
end Behavioral;