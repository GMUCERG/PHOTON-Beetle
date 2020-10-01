library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity add_sub_rom is
	generic(w   : integer := 5;
	        y   : integer := 4;
	        sel : integer := 0);
	port(ADDR : in  STD_LOGIC_VECTOR(w - 1 downto 0);
	     Dout : out STD_LOGIC_VECTOR(y - 1 downto 0));
end add_sub_rom;

architecture asr of add_sub_rom is

	signal input1 : integer range 0 to 2**w - 1;
	type v_arr is array (0 to 2**w - 1) of STD_LOGIC_VECTOR(y - 1 downto 0);

begin

	-- Generates rom based on selection
	gen_rom_0 : if sel = 0 generate
		-- addc_rom_ic --
		constant MEMORY : v_arr := ("0000", -- 0
		                            "0001", -- 1
		                            "0011", -- 3
		                            "0111", -- 7
		                            "1111", -- 15
		                            "1110", -- 14
		                            "1100", -- 12
		                            "1000" -- 8
		                           );
	begin
		input1 <= to_integer(unsigned(ADDR));
		Dout   <= MEMORY(input1);

	end generate gen_rom_0;
	gen_rom_1 : if sel = 1 generate
		-- addc_rom_rc --
		constant MEMORY : v_arr := ("0001", -- 1
		                            "0011", -- 3
		                            "0111", -- 7
		                            "1110", -- 14
		                            "1101", -- 13
		                            "1011", -- 11
		                            "0110", -- 6
		                            "1100", -- 12
		                            "1001", -- 9
		                            "0010", -- 2
		                            "0101", -- 5
		                            "1010", -- 10
		                            "0000",
		                            "0000",
		                            "0000",
		                            "0000");

	begin
		input1 <= to_integer(unsigned(ADDR));
		Dout   <= MEMORY(input1);

	end generate gen_rom_1;
	gen_rom_2 : if sel = 2 generate
		-- subc_rom_sbox --
		constant MEMORY : v_arr := ("1100", -- C
		                            "0101", -- 5
		                            "0110", -- 6
		                            "1011", -- B
		                            "1001", -- 9
		                            "0000", -- 0
		                            "1010", -- A
		                            "1101", -- D
		                            "0011", -- 3
		                            "1110", -- E
		                            "1111", -- F
		                            "1000", -- 8
		                            "0100", -- 4
		                            "0111", -- 7
		                            "0001", -- 1
		                            "0010" -- 2
		                           );
	begin
		input1 <= to_integer(unsigned(ADDR));
		Dout   <= MEMORY(input1);

	end generate gen_rom_2;

end asr;
