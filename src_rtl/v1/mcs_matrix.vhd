library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mcs_matrix is
    Port ( w0 : in STD_LOGIC_VECTOR(15 downto 0);
           
           p256_sel : in STD_LOGIC;
           
           y0 : out STD_LOGIC_VECTOR(31 downto 0)
    );
           
end mcs_matrix;

architecture mat1 of mcs_matrix is

signal mcs_in : STD_LOGIC_VECTOR(159 downto 0); -- Stores the rom inputs w/ select
signal mcs_out : STD_LOGIC_VECTOR(127 downto 0); -- Contains the output of the roms

begin

    -- ROM input: p256_sel || 4 bits of w0 (loops from 15 downto 0)
	gen_mcs_in: for ii in 0 to 31 generate
		mcs_in((31 - ii) * 5 + 4 downto (31 - ii) * 5) 
			<=  p256_sel & w0(((3 - ii) mod 4) * 4 + 3 downto ((3 - ii) mod 4) * 4);
	end generate gen_mcs_in;
	
    -- Actual rom generation
	gen_roms: for ii in 0 to 31 generate
		mcs_rom0: entity work.mcs_rom(mr0)
				generic map (sel => ii) -- Uses select for generation
				port map (  ADDR => mcs_in((31 - ii) * 5 + 4 downto (31 - ii) * 5),
							Dout => mcs_out((31 - ii) * 4 + 3 downto (31 - ii) * 4));
	end generate gen_roms;

    -- XORs ROMs to perform first/last 4 multiplications
    gen_y: for ii in 0 to 7 generate
        y0(31 - (ii*4) downto (28 - (ii*4))) 
            <= mcs_out(127-(ii*16) downto 124-(ii*16))
            XOR mcs_out(123-(ii*16) downto 120-(ii*16))
            XOR mcs_out(119-(ii*16) downto 116-(ii*16)) 
            XOR mcs_out(115-(ii*16) downto 112-(ii*16));
    end generate gen_y;
    
end mat1;









