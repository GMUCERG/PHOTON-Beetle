library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CryptoCore is
    Port (  clk             : in   STD_LOGIC;
			rst             : in   STD_LOGIC;
       
			key             : in   STD_LOGIC_VECTOR( 31 downto 0 );
			key_valid       : in   STD_LOGIC;
			key_ready       : out  STD_LOGIC;
			
			bdi             : in   STD_LOGIC_VECTOR( 31 downto 0 );
			bdi_valid       : in   STD_LOGIC;
			bdi_ready       : out  STD_LOGIC;
			bdi_pad_loc     : in   STD_LOGIC_VECTOR( 3 downto 0 );
			bdi_valid_bytes : in   STD_LOGIC_VECTOR( 3 downto 0 );
			bdi_size        : in   STD_LOGIC_VECTOR( 2 downto 0 );
			bdi_eot         : in   STD_LOGIC;
			bdi_eoi         : in   STD_LOGIC;
			bdi_type        : in   STD_LOGIC_VECTOR( 3 downto 0 );
			decrypt_in      : in   STD_LOGIC;
			key_update      : in   STD_LOGIC;
			hash_in         : in   STD_LOGIC;
			
			bdo             : out  STD_LOGIC_VECTOR( 31 downto 0 );
			bdo_valid       : out  STD_LOGIC;
			bdo_ready       : in   STD_LOGIC;
			bdo_type        : out  STD_LOGIC_VECTOR( 3 downto 0 );
			bdo_valid_bytes : out  STD_LOGIC_VECTOR( 3 downto 0 );
			end_of_block    : out  STD_LOGIC;
			msg_auth_valid  : out  STD_LOGIC;
			msg_auth_ready  : in   STD_LOGIC;
			msg_auth        : out  STD_LOGIC
			);    
end CryptoCore;

architecture Behavioral of CryptoCore is

-- Internal inputs and signals --		

signal iv_we 			: STD_LOGIC;		
signal iv1_en           : STD_LOGIC;
signal iv1_rst          : STD_LOGIC;

signal iv_sel       	: STD_LOGIC_VECTOR( 1 downto 0 );
signal iv_input_sel 	: STD_LOGIC_VECTOR( 1 downto 0 );
signal iv_xor_sel      	: STD_LOGIC;
signal c1_sel           : STD_LOGIC;

signal c0 				: STD_LOGIC_VECTOR( 2 downto 0 );
signal c1 				: STD_LOGIC_VECTOR( 2 downto 0 );
signal c0_c1_en         : STD_LOGIC;

signal ozs_en          	: STD_LOGIC;
signal zero_en          : STD_LOGIC;
signal hash_pad         : STD_LOGIC;

signal p256_s           : STD_LOGIC;
signal bdo_sel 			: STD_LOGIC;

signal temp_en         	: STD_LOGIC;
signal temp_rst        : STD_LOGIC;
signal temp_sel         : STD_LOGIC;

signal key_sel          : STD_LOGIC;
signal key_en           : STD_LOGIC;

signal ozs_input_sel 	: STD_LOGIC;

signal p256_sel        	: STD_LOGIC;

signal round 			: STD_LOGIC_VECTOR( 3 downto 0 );
signal rho_vb           : STD_LOGIC_VECTOR( 3 downto 0 );
signal msg_en           : STD_LOGIC;
signal rho_reg_en       : STD_LOGIC;
-- Output --
signal tag_verify		: STD_LOGIC;

begin

datapath1: entity work.Datapath(Behavioral)
    Port map ( 
			clk => clk,
			bdi => bdi,
			key_in => key,
			decrypt_in => decrypt_in,
			
			bdi_valid_bytes => bdi_valid_bytes,
			bdi_pad_loc => bdi_pad_loc,		

			iv_we => iv_we,
			
			iv1_en => iv1_en,
			iv1_rst => iv1_rst,
			
            iv_sel => iv_sel,
            iv_input_sel => iv_input_sel,
            iv_xor_sel => iv_xor_sel,
            c1_sel => c1_sel,

			c0 => c0,
			c1 => c1,
			c0_c1_en => c0_c1_en,
			
            ozs_en => ozs_en,
            zero_en => zero_en,
            hash_pad => hash_pad,

			bdo_sel => bdo_sel,
		    
		    temp_en => temp_en,
		    temp_rst => temp_rst,
		    temp_sel => temp_sel,
		    rho_reg_en => rho_reg_en,
		    
			key_sel => key_sel,
			key_en => key_en,
			
			ozs_input_sel => ozs_input_sel,

            p256_s => p256_s,
			p256_sel => p256_sel,
			rho_vb => rho_vb,
			msg_en => msg_en,
		    
			round => round,
			
			-- Output --
			tag_verify => tag_verify,
			bdo => bdo
			
			);

controller1: entity work.Controller(Behavioral)
    port map (
            clk => clk,
	        rst => rst,

	        key_valid => key_valid,
	        key_update => key_update,
	
	        bdi_valid => bdi_valid,
	        bdi_pad_loc => bdi_pad_loc,
	        bdi_valid_bytes => bdi_valid_bytes,
	        bdi_size => bdi_size,
	        bdi_eot => bdi_eot,
	        bdi_eoi => bdi_eoi,
	        bdi_type => bdi_type,
	        decrypt_in => decrypt_in,
	        hash_in => hash_in,
	
	        bdo_ready => bdo_ready,
	        msg_auth_ready => msg_auth_ready,
	
	        tag_verify => tag_verify,
	
	        -- CryptoCore Outputs --
	
	        key_ready => key_ready,
	        bdi_ready => bdi_ready,			
	        bdo_valid => bdo_valid,
	        bdo_valid_bytes => bdo_valid_bytes,
	
	        -- IV / IV_addr --
	
	        iv_we => iv_we,
			iv1_en => iv1_en,
			iv1_rst => iv1_rst,
			
	        -- Select Signals -- 
	
            iv_sel => iv_sel,
            iv_input_sel => iv_input_sel,
	        iv_xor_sel => iv_xor_sel,
            c1_sel => c1_sel,
	
	        ozs_en => ozs_en,
	        ozs_input_sel => ozs_input_sel,
	        zero_en => zero_en,
            hash_pad => hash_pad,
	
            temp_en => temp_en,
            temp_rst => temp_rst,
		    rho_reg_en => rho_reg_en,
	        key_sel => key_sel,
	        key_en => key_en,
	
	        p256_s => p256_s,
	        p256_sel => p256_sel,
	        bdo_sel => bdo_sel,
	        temp_sel => temp_sel,
	        rho_vb => rho_vb,
	        msg_en => msg_en,
	
	        -- Register Signals --
	        c0 => c0,
	        c1 => c1,
			c0_c1_en => c0_c1_en,
	
	        bdo_type => bdo_type,
	
	        -- Submodule Controller Outputs --
	
	        round => round,

	        msg_auth => msg_auth,
	        msg_auth_valid => msg_auth_valid,
	        end_of_block => end_of_block
	        );
end Behavioral;