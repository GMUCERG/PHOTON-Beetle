----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2019 11:55:17 AM
-- Design Name: 
-- Module Name: Datapath - Behavioral
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

entity Datapath is
    port (  clk 			: in STD_LOGIC;
			
			bdi 			: in STD_LOGIC_VECTOR( 31 downto 0 );
			key_in 			: in STD_LOGIC_VECTOR( 31 downto 0 );
			decrypt_in 		: in STD_LOGIC;
			
			bdi_valid_bytes : in STD_LOGIC_VECTOR( 3 downto 0 );
			bdi_pad_loc     : in STD_LOGIC_VECTOR( 3 downto 0 );
			
			-- Internal inputs and signals --
            
			iv_we 			: in STD_LOGIC;		
			
            iv_sel          : in STD_LOGIC_VECTOR( 1 downto 0);
            iv_input_sel    : in STD_LOGIC_VECTOR( 1 downto 0);
            iv_xor_sel      : in STD_LOGIC;
            
            iv1_en      : in STD_LOGIC;
            iv1_rst     : in STD_LOGIC;

			c0 				: in STD_LOGIC_VECTOR( 2 downto 0 );
			c1 				: in STD_LOGIC_VECTOR( 2 downto 0 );
			c1_sel          : in STD_LOGIC;
			c0_c1_en        : in STD_LOGIC;
			
            ozs_en          : in STD_LOGIC;
            zero_en         : in STD_LOGIC;
            hash_pad        : in STD_LOGIC;

			bdo_sel 		: in STD_LOGIC;
		    
		    temp_en         : in STD_LOGIC;
		    temp_rst        : in STD_LOGIC;
		    temp_sel        : in STD_LOGIC;
		    rho_reg_en      : in STD_LOGIC;
		    
			key_sel         : in STD_LOGIC;
			key_en          : in STD_LOGIC;
			
			ozs_input_sel 	: in STD_LOGIC;
			
			p256_s          : in STD_LOGIC;
			p256_sel        : in STD_LOGIC;
		    
		    msg_en          : in STD_LOGIC;
			round 			: in STD_LOGIC_VECTOR( 3 downto 0 );
			
			rho_vb          : in STD_LOGIC_VECTOR( 3 downto 0 );
			
			-- Output --
			tag_verify		: out STD_LOGIC;
			bdo             : out STD_LOGIC_VECTOR( 31 downto 0 ));
            
end Datapath;

architecture Behavioral of Datapath is

signal key_next : STD_LOGIC_VECTOR(127 downto 0);
signal key : STD_LOGIC_VECTOR(127 downto 0);
signal iv_next : STD_LOGIC_VECTOR(127 downto 0);
signal iv : STD_LOGIC_VECTOR(127 downto 0);
signal iv1 : STD_LOGIC_VECTOR(127 downto 0);
signal p256_iv1 : STD_LOGIC_VECTOR(127 downto 0);
signal iv1_next : STD_LOGIC_VECTOR(127 downto 0);

signal iv_32 : STD_LOGIC_VECTOR(31 downto 0);
signal temp_32 : STD_LOGIC_VECTOR(31 downto 0);

signal iv_en : STD_LOGIC_VECTOR(3 downto 0);

signal p256 : STD_LOGIC_VECTOR(127 downto 0);
signal p256_out : STD_LOGIC_VECTOR(127 downto 0);

signal temp_next : STD_LOGIC_VECTOR(127 downto 0);
signal temp : STD_LOGIC_VECTOR(127 downto 0);
signal temp_s : STD_LOGIC_VECTOR(127 downto 0);

signal ozs_out : STD_LOGIC_VECTOR(31 downto 0);

signal rho_bdo : STD_LOGIC_VECTOR(31 downto 0);

signal bdo_sig : STD_LOGIC_VECTOR(31 downto 0);
signal vb_in   : STD_LOGIC_VECTOR(3 downto 0);

signal c0_c1 : STD_LOGIC_VECTOR(2 downto 0);
signal c01_128 : STD_LOGIC_VECTOR(127 downto 0);
signal iv1_mux : STD_LOGIC_VECTOR(127 downto 0);
signal bdo_128 : STD_LOGIC_VECTOR(127 downto 0);
signal temp_mux : STD_LOGIC_VECTOR(127 downto 0);
signal temp_mux_sel : STD_LOGIC_VECTOR(1 downto 0);

signal rho_reg : STD_LOGIC_VECTOR(127 downto 0);
signal rho_reg_next : STD_LOGIC_VECTOR(127 downto 0);
signal sel_bytes : STD_LOGIC_VECTOR(3 downto 0);
signal key_reg_en : STD_LOGIC_VECTOR(3 downto 0);
signal pad_loc : STD_LOGIC_VECTOR(3 downto 0);
signal iv_rst : STD_LOGIC;

signal ozs_xor : STD_LOGIC_VECTOR(31 downto 0);
signal ozs_iv : STD_LOGIC_VECTOR(127 downto 0);

function rev_by_4bits(x : STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        variable y : STD_LOGIC_VECTOR(x'length - 1 downto 0);
        
    begin
        for ii in x'length/8 - 1 downto 0 loop
            y(8*ii+7 downto 8*ii+4) := x(8*ii+3 downto 8*ii);
            y(8*ii+3 downto 8*ii) := x(8*ii+7 downto 8*ii+4);
        end loop;

        return y;
end function rev_by_4bits;

begin	

-- Dictates which input is written to the state ram --
ozs_xor <= ozs_out XOR iv_32 when iv_xor_sel = '1' else ozs_out;

gen_ozs_128 : for ii in 0 to 3 generate
	ozs_iv(127 - 32*ii downto 96 - 32*ii) <= ozs_xor;
end generate gen_ozs_128;

with iv_sel(1) select iv_next <=
	rev_by_4bits(p256)    when '0',
    ozs_iv when others;
		
with iv_input_sel select sel_bytes <=
    "0001" when "00",
    "0010" when "01",
    "0100" when "10",
    "1000" when others;
    
key_reg_en <= sel_bytes AND (key_en & key_en & key_en & key_en);
    
-- add_sub/shiftr = straightforward transformation
gen_key_reg: for ii in 0 to 3 generate 
    key_reg0: entity work.reg(Behavioral)
        generic map (w => 32)
        port map (  clk => clk,
                    rst => '0',
                    en => key_reg_en(ii),
                    D => key_in,
                    Q => key(127 - 32*ii downto 96 - 32*ii));
end generate gen_key_reg;

iv_en <= (sel_bytes AND (iv_we & iv_we & iv_we & iv_we))
OR (p256_s & p256_s & p256_s & p256_s);

-- pad location used to actually pad ozs
gen_iv_reg: for ii in 0 to 3 generate 
    iv_reg0: entity work.reg(Behavioral)
        generic map (w => 32)
        port map (  clk => clk,
                    rst => iv_sel(0),
                    en => iv_en(ii),
                    D => iv_next(127 - 32*ii downto 96 - 32*ii),
                    Q => iv(127 - 32*ii downto 96 - 32*ii));
end generate gen_iv_reg;

c0_c1 <= c1 when c1_sel = '1' else c0;
c01_128 <= iv1(127 downto 8) & (c0_c1 xor iv1(7 downto 5)) & iv1(4 downto 0);

iv1_mux <= c01_128 when c0_c1_en = '1' else rev_by_4bits(p256_iv1);
iv1_next <= iv1_mux when key_sel = '0' else key;
iv_reg1: entity work.reg(Behavioral)
    generic map (w => 128)
    port map (  clk => clk,
                rst => iv1_rst,
                en => iv1_en,
                D => iv1_next,
                Q => iv1 );

-- Actual permutation
photon_256a: entity work.Photon_256(STRUCTURE)
    Port map (
		w0 => rev_by_4bits(iv),
        w1 => rev_by_4bits(iv1),
		
		temp => rev_by_4bits(temp),
		
		k   => round,
		p256_sel => p256_sel,
		
		y0 => p256,
		y1 => p256_iv1,
		temp_next => temp_s);

temp_mux_sel <= temp_sel & msg_en;
with temp_mux_sel select temp_next <=
    iv when "00",
    bdo_128 when "01",
    rev_by_4bits(temp_s) when others;

-- Register to store photon-256 intermediate multiplication value
temp1: entity work.reg(Behavioral)
	generic map(w => 128)
		Port map (	clk => clk,
		            rst => temp_rst,
					en => temp_en,
					D => temp_next,
					Q => temp);		

-- Padding
ozs1: entity work.Ozs(Behavioral)
    port map ( w0 => bdi,
               w1 => rho_bdo,
               pad_loc => bdi_pad_loc,

			   ozs_sel => ozs_input_sel,
               ozs_en => ozs_en,
               zero_en => zero_en,
               hash_pad => hash_pad,

               ozs_out => ozs_out);

rho_reg_next <= iv(63 downto 0) & iv(112) & iv(127 downto 121) & iv(104)
& iv(119 downto 113) & iv(96) & iv(111 downto 105) & iv(88) 
& iv(103 downto 97) & iv(80) & iv(95 downto 89) & iv(72) 
& iv(87 downto 81) & iv(64) & iv(79 downto 73) & iv(120) & iv(71 downto 65);

--What it is in the software implementation.
rho_reg1: entity work.reg(Behavioral)
	generic map(w => 128)
		Port map (	clk => clk,
		            rst => '0',
					en => rho_reg_en,
					D => rho_reg_next,
					Q => rho_reg);		

-- Encryption/decryption operation
rho1: entity work.Rho(Behavioral)
    port map ( rho_in => temp,
               shuffle => rho_reg,
               bdi => bdi,
               iv_input_sel => iv_input_sel,
               rho_valid => rho_vb,

			   ozs => ozs_out,
			   
               bdo => rho_bdo,
               bdo_128 => bdo_128);
 
-- bdo is a 32-bit output
with iv_input_sel select iv_32 <=
    iv(95 downto 64) when "01",
    iv(63 downto 32) when "10",
    iv(31 downto 0) when "11",
    iv(127 downto 96) when others;

with iv_input_sel select temp_32 <=
    temp(95 downto 64) when "01",
    temp(63 downto 32) when "10",
    temp(31 downto 0) when "11",
    temp(127 downto 96) when others;
    
bdo_sig <= temp_32;
    
tag_verify <= '1' when bdo_sig = bdi else '0';

bdo <= bdo_sig;
					
end Behavioral;
