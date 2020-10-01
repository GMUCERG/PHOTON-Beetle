----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2020 08:31:30 PM
-- Design Name: 
-- Module Name: shift-row - Behavioral
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

entity Shift_Row is
    generic ( i : in integer := 0 ); -- Row being shifted
    Port (  w : in  STD_LOGIC_VECTOR(31 downto 0);
            p256_sel : in STD_LOGIC;
            y : out STD_LOGIC_VECTOR(31 downto 0)
     
    );
end Shift_Row;

architecture shiftr of Shift_Row is

signal shiftr_out : STD_LOGIC_VECTOR(31 downto 0);

begin

    gen_shiftr_1: if i = 1 generate
        shiftr_out <= w(27 downto 0) & w(31 downto 28);
    end generate gen_shiftr_1;
    
    gen_shiftr_2: if i = 2 generate
        shiftr_out <= w(23 downto 0) & w(31 downto 24);
    end generate gen_shiftr_2;
    
    gen_shiftr_3: if  i = 3 generate
    	shiftr_out <= w(19 downto 0) & w(31 downto 20);
    end generate gen_shiftr_3;
    
    gen_shiftr_0: if i = 0  generate
        shiftr_out <= w;
    end generate gen_shiftr_0;

    -- Inputs are from 0 to 3; p256_sel = 1 when processing rows 4 to 7
    y <= shiftr_out when p256_sel = '0' else shiftr_out(15 downto 0) & shiftr_out(31 downto 16);

end shiftr;
