	component procesador is
		port (
			clk_clk                               : in    std_logic                     := 'X';             -- clk
			clk_custom_in_clk                     : in    std_logic                     := 'X';             -- clk
			clk_custom_out_clk                    : out   std_logic;                                        -- clk
			divisor_clock_export                  : out   std_logic_vector(31 downto 0);                    -- export
			enable_export                         : out   std_logic;                                        -- export
			fifo0_32_bit_in_valid                 : in    std_logic                     := 'X';             -- valid
			fifo0_32_bit_in_data                  : in    std_logic_vector(31 downto 0) := (others => 'X'); -- data
			fifo0_32_bit_in_ready                 : out   std_logic;                                        -- ready
			fifo0_64_bit_down_in_valid            : in    std_logic                     := 'X';             -- valid
			fifo0_64_bit_down_in_data             : in    std_logic_vector(31 downto 0) := (others => 'X'); -- data
			fifo0_64_bit_down_in_ready            : out   std_logic;                                        -- ready
			fifo0_64_bit_up_in_valid              : in    std_logic                     := 'X';             -- valid
			fifo0_64_bit_up_in_data               : in    std_logic_vector(31 downto 0) := (others => 'X'); -- data
			fifo0_64_bit_up_in_ready              : out   std_logic;                                        -- ready
			fifo1_32_bit_in_valid                 : in    std_logic                     := 'X';             -- valid
			fifo1_32_bit_in_data                  : in    std_logic_vector(31 downto 0) := (others => 'X'); -- data
			fifo1_32_bit_in_ready                 : out   std_logic;                                        -- ready
			fifo1_64_bit_down_in_valid            : in    std_logic                     := 'X';             -- valid
			fifo1_64_bit_down_in_data             : in    std_logic_vector(31 downto 0) := (others => 'X'); -- data
			fifo1_64_bit_down_in_ready            : out   std_logic;                                        -- ready
			fifo1_64_bit_up_in_valid              : in    std_logic                     := 'X';             -- valid
			fifo1_64_bit_up_in_data               : in    std_logic_vector(31 downto 0) := (others => 'X'); -- data
			fifo1_64_bit_up_in_ready              : out   std_logic;                                        -- ready
			finalizacion_export                   : in    std_logic                     := 'X';             -- export
			memory_mem_a                          : out   std_logic_vector(12 downto 0);                    -- mem_a
			memory_mem_ba                         : out   std_logic_vector(2 downto 0);                     -- mem_ba
			memory_mem_ck                         : out   std_logic;                                        -- mem_ck
			memory_mem_ck_n                       : out   std_logic;                                        -- mem_ck_n
			memory_mem_cke                        : out   std_logic;                                        -- mem_cke
			memory_mem_cs_n                       : out   std_logic;                                        -- mem_cs_n
			memory_mem_ras_n                      : out   std_logic;                                        -- mem_ras_n
			memory_mem_cas_n                      : out   std_logic;                                        -- mem_cas_n
			memory_mem_we_n                       : out   std_logic;                                        -- mem_we_n
			memory_mem_reset_n                    : out   std_logic;                                        -- mem_reset_n
			memory_mem_dq                         : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- mem_dq
			memory_mem_dqs                        : inout std_logic                     := 'X';             -- mem_dqs
			memory_mem_dqs_n                      : inout std_logic                     := 'X';             -- mem_dqs_n
			memory_mem_odt                        : out   std_logic;                                        -- mem_odt
			memory_mem_dm                         : out   std_logic;                                        -- mem_dm
			memory_oct_rzqin                      : in    std_logic                     := 'X';             -- oct_rzqin
			parameters_1_user_interface_dataout_0 : out   std_logic_vector(31 downto 0);                    -- dataout_0
			parameters_1_user_interface_dataout_1 : out   std_logic_vector(31 downto 0);                    -- dataout_1
			parameters_1_user_interface_dataout_2 : out   std_logic_vector(31 downto 0);                    -- dataout_2
			parameters_1_user_interface_dataout_3 : out   std_logic_vector(31 downto 0);                    -- dataout_3
			parameters_1_user_interface_dataout_4 : out   std_logic_vector(31 downto 0);                    -- dataout_4
			parameters_1_user_interface_dataout_5 : out   std_logic_vector(31 downto 0);                    -- dataout_5
			parameters_1_user_interface_dataout_6 : out   std_logic_vector(31 downto 0);                    -- dataout_6
			parameters_1_user_interface_dataout_7 : out   std_logic_vector(31 downto 0);                    -- dataout_7
			parameters_1_user_interface_dataout_8 : out   std_logic_vector(31 downto 0);                    -- dataout_8
			parameters_1_user_interface_dataout_9 : out   std_logic_vector(31 downto 0);                    -- dataout_9
			parameters_1_user_interface_datain_10 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_10
			parameters_1_user_interface_datain_11 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_11
			parameters_1_user_interface_datain_12 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_12
			parameters_1_user_interface_datain_13 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_13
			parameters_1_user_interface_datain_14 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_14
			parameters_1_user_interface_datain_15 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_15
			parameters_2_user_interface_dataout_0 : out   std_logic_vector(31 downto 0);                    -- dataout_0
			parameters_2_user_interface_dataout_1 : out   std_logic_vector(31 downto 0);                    -- dataout_1
			parameters_2_user_interface_dataout_2 : out   std_logic_vector(31 downto 0);                    -- dataout_2
			parameters_2_user_interface_dataout_3 : out   std_logic_vector(31 downto 0);                    -- dataout_3
			parameters_2_user_interface_dataout_4 : out   std_logic_vector(31 downto 0);                    -- dataout_4
			parameters_2_user_interface_dataout_5 : out   std_logic_vector(31 downto 0);                    -- dataout_5
			parameters_2_user_interface_dataout_6 : out   std_logic_vector(31 downto 0);                    -- dataout_6
			parameters_2_user_interface_dataout_7 : out   std_logic_vector(31 downto 0);                    -- dataout_7
			parameters_2_user_interface_dataout_8 : out   std_logic_vector(31 downto 0);                    -- dataout_8
			parameters_2_user_interface_dataout_9 : out   std_logic_vector(31 downto 0);                    -- dataout_9
			parameters_2_user_interface_datain_10 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_10
			parameters_2_user_interface_datain_11 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_11
			parameters_2_user_interface_datain_12 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_12
			parameters_2_user_interface_datain_13 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_13
			parameters_2_user_interface_datain_14 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_14
			parameters_2_user_interface_datain_15 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_15
			parameters_3_user_interface_dataout_0 : out   std_logic_vector(31 downto 0);                    -- dataout_0
			parameters_3_user_interface_dataout_1 : out   std_logic_vector(31 downto 0);                    -- dataout_1
			parameters_3_user_interface_dataout_2 : out   std_logic_vector(31 downto 0);                    -- dataout_2
			parameters_3_user_interface_dataout_3 : out   std_logic_vector(31 downto 0);                    -- dataout_3
			parameters_3_user_interface_dataout_4 : out   std_logic_vector(31 downto 0);                    -- dataout_4
			parameters_3_user_interface_dataout_5 : out   std_logic_vector(31 downto 0);                    -- dataout_5
			parameters_3_user_interface_dataout_6 : out   std_logic_vector(31 downto 0);                    -- dataout_6
			parameters_3_user_interface_dataout_7 : out   std_logic_vector(31 downto 0);                    -- dataout_7
			parameters_3_user_interface_dataout_8 : out   std_logic_vector(31 downto 0);                    -- dataout_8
			parameters_3_user_interface_dataout_9 : out   std_logic_vector(31 downto 0);                    -- dataout_9
			parameters_3_user_interface_datain_10 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_10
			parameters_3_user_interface_datain_11 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_11
			parameters_3_user_interface_datain_12 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_12
			parameters_3_user_interface_datain_13 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_13
			parameters_3_user_interface_datain_14 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_14
			parameters_3_user_interface_datain_15 : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_15
			parameters_user_interface_dataout_0   : out   std_logic_vector(31 downto 0);                    -- dataout_0
			parameters_user_interface_dataout_1   : out   std_logic_vector(31 downto 0);                    -- dataout_1
			parameters_user_interface_dataout_2   : out   std_logic_vector(31 downto 0);                    -- dataout_2
			parameters_user_interface_dataout_3   : out   std_logic_vector(31 downto 0);                    -- dataout_3
			parameters_user_interface_dataout_4   : out   std_logic_vector(31 downto 0);                    -- dataout_4
			parameters_user_interface_dataout_5   : out   std_logic_vector(31 downto 0);                    -- dataout_5
			parameters_user_interface_dataout_6   : out   std_logic_vector(31 downto 0);                    -- dataout_6
			parameters_user_interface_dataout_7   : out   std_logic_vector(31 downto 0);                    -- dataout_7
			parameters_user_interface_dataout_8   : out   std_logic_vector(31 downto 0);                    -- dataout_8
			parameters_user_interface_dataout_9   : out   std_logic_vector(31 downto 0);                    -- dataout_9
			parameters_user_interface_datain_10   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_10
			parameters_user_interface_datain_11   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_11
			parameters_user_interface_datain_12   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_12
			parameters_user_interface_datain_13   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_13
			parameters_user_interface_datain_14   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_14
			parameters_user_interface_datain_15   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- datain_15
			reset_reset_n                         : in    std_logic                     := 'X';             -- reset_n
			reset_fifos_reset                     : in    std_logic                     := 'X';             -- reset
			reset_op_export                       : out   std_logic;                                        -- export
			result0_32_bit_in_export              : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			result0_64_bit_down_in_export         : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			result0_64_bit_up_in_export           : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			result1_32_bit_in_export              : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			result1_64_bit_down_in_export         : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			result1_64_bit_up_in_export           : in    std_logic_vector(31 downto 0) := (others => 'X')  -- export
		);
	end component procesador;

	u0 : component procesador
		port map (
			clk_clk                               => CONNECTED_TO_clk_clk,                               --                         clk.clk
			clk_custom_in_clk                     => CONNECTED_TO_clk_custom_in_clk,                     --               clk_custom_in.clk
			clk_custom_out_clk                    => CONNECTED_TO_clk_custom_out_clk,                    --              clk_custom_out.clk
			divisor_clock_export                  => CONNECTED_TO_divisor_clock_export,                  --               divisor_clock.export
			enable_export                         => CONNECTED_TO_enable_export,                         --                      enable.export
			fifo0_32_bit_in_valid                 => CONNECTED_TO_fifo0_32_bit_in_valid,                 --             fifo0_32_bit_in.valid
			fifo0_32_bit_in_data                  => CONNECTED_TO_fifo0_32_bit_in_data,                  --                            .data
			fifo0_32_bit_in_ready                 => CONNECTED_TO_fifo0_32_bit_in_ready,                 --                            .ready
			fifo0_64_bit_down_in_valid            => CONNECTED_TO_fifo0_64_bit_down_in_valid,            --        fifo0_64_bit_down_in.valid
			fifo0_64_bit_down_in_data             => CONNECTED_TO_fifo0_64_bit_down_in_data,             --                            .data
			fifo0_64_bit_down_in_ready            => CONNECTED_TO_fifo0_64_bit_down_in_ready,            --                            .ready
			fifo0_64_bit_up_in_valid              => CONNECTED_TO_fifo0_64_bit_up_in_valid,              --          fifo0_64_bit_up_in.valid
			fifo0_64_bit_up_in_data               => CONNECTED_TO_fifo0_64_bit_up_in_data,               --                            .data
			fifo0_64_bit_up_in_ready              => CONNECTED_TO_fifo0_64_bit_up_in_ready,              --                            .ready
			fifo1_32_bit_in_valid                 => CONNECTED_TO_fifo1_32_bit_in_valid,                 --             fifo1_32_bit_in.valid
			fifo1_32_bit_in_data                  => CONNECTED_TO_fifo1_32_bit_in_data,                  --                            .data
			fifo1_32_bit_in_ready                 => CONNECTED_TO_fifo1_32_bit_in_ready,                 --                            .ready
			fifo1_64_bit_down_in_valid            => CONNECTED_TO_fifo1_64_bit_down_in_valid,            --        fifo1_64_bit_down_in.valid
			fifo1_64_bit_down_in_data             => CONNECTED_TO_fifo1_64_bit_down_in_data,             --                            .data
			fifo1_64_bit_down_in_ready            => CONNECTED_TO_fifo1_64_bit_down_in_ready,            --                            .ready
			fifo1_64_bit_up_in_valid              => CONNECTED_TO_fifo1_64_bit_up_in_valid,              --          fifo1_64_bit_up_in.valid
			fifo1_64_bit_up_in_data               => CONNECTED_TO_fifo1_64_bit_up_in_data,               --                            .data
			fifo1_64_bit_up_in_ready              => CONNECTED_TO_fifo1_64_bit_up_in_ready,              --                            .ready
			finalizacion_export                   => CONNECTED_TO_finalizacion_export,                   --                finalizacion.export
			memory_mem_a                          => CONNECTED_TO_memory_mem_a,                          --                      memory.mem_a
			memory_mem_ba                         => CONNECTED_TO_memory_mem_ba,                         --                            .mem_ba
			memory_mem_ck                         => CONNECTED_TO_memory_mem_ck,                         --                            .mem_ck
			memory_mem_ck_n                       => CONNECTED_TO_memory_mem_ck_n,                       --                            .mem_ck_n
			memory_mem_cke                        => CONNECTED_TO_memory_mem_cke,                        --                            .mem_cke
			memory_mem_cs_n                       => CONNECTED_TO_memory_mem_cs_n,                       --                            .mem_cs_n
			memory_mem_ras_n                      => CONNECTED_TO_memory_mem_ras_n,                      --                            .mem_ras_n
			memory_mem_cas_n                      => CONNECTED_TO_memory_mem_cas_n,                      --                            .mem_cas_n
			memory_mem_we_n                       => CONNECTED_TO_memory_mem_we_n,                       --                            .mem_we_n
			memory_mem_reset_n                    => CONNECTED_TO_memory_mem_reset_n,                    --                            .mem_reset_n
			memory_mem_dq                         => CONNECTED_TO_memory_mem_dq,                         --                            .mem_dq
			memory_mem_dqs                        => CONNECTED_TO_memory_mem_dqs,                        --                            .mem_dqs
			memory_mem_dqs_n                      => CONNECTED_TO_memory_mem_dqs_n,                      --                            .mem_dqs_n
			memory_mem_odt                        => CONNECTED_TO_memory_mem_odt,                        --                            .mem_odt
			memory_mem_dm                         => CONNECTED_TO_memory_mem_dm,                         --                            .mem_dm
			memory_oct_rzqin                      => CONNECTED_TO_memory_oct_rzqin,                      --                            .oct_rzqin
			parameters_1_user_interface_dataout_0 => CONNECTED_TO_parameters_1_user_interface_dataout_0, -- parameters_1_user_interface.dataout_0
			parameters_1_user_interface_dataout_1 => CONNECTED_TO_parameters_1_user_interface_dataout_1, --                            .dataout_1
			parameters_1_user_interface_dataout_2 => CONNECTED_TO_parameters_1_user_interface_dataout_2, --                            .dataout_2
			parameters_1_user_interface_dataout_3 => CONNECTED_TO_parameters_1_user_interface_dataout_3, --                            .dataout_3
			parameters_1_user_interface_dataout_4 => CONNECTED_TO_parameters_1_user_interface_dataout_4, --                            .dataout_4
			parameters_1_user_interface_dataout_5 => CONNECTED_TO_parameters_1_user_interface_dataout_5, --                            .dataout_5
			parameters_1_user_interface_dataout_6 => CONNECTED_TO_parameters_1_user_interface_dataout_6, --                            .dataout_6
			parameters_1_user_interface_dataout_7 => CONNECTED_TO_parameters_1_user_interface_dataout_7, --                            .dataout_7
			parameters_1_user_interface_dataout_8 => CONNECTED_TO_parameters_1_user_interface_dataout_8, --                            .dataout_8
			parameters_1_user_interface_dataout_9 => CONNECTED_TO_parameters_1_user_interface_dataout_9, --                            .dataout_9
			parameters_1_user_interface_datain_10 => CONNECTED_TO_parameters_1_user_interface_datain_10, --                            .datain_10
			parameters_1_user_interface_datain_11 => CONNECTED_TO_parameters_1_user_interface_datain_11, --                            .datain_11
			parameters_1_user_interface_datain_12 => CONNECTED_TO_parameters_1_user_interface_datain_12, --                            .datain_12
			parameters_1_user_interface_datain_13 => CONNECTED_TO_parameters_1_user_interface_datain_13, --                            .datain_13
			parameters_1_user_interface_datain_14 => CONNECTED_TO_parameters_1_user_interface_datain_14, --                            .datain_14
			parameters_1_user_interface_datain_15 => CONNECTED_TO_parameters_1_user_interface_datain_15, --                            .datain_15
			parameters_2_user_interface_dataout_0 => CONNECTED_TO_parameters_2_user_interface_dataout_0, -- parameters_2_user_interface.dataout_0
			parameters_2_user_interface_dataout_1 => CONNECTED_TO_parameters_2_user_interface_dataout_1, --                            .dataout_1
			parameters_2_user_interface_dataout_2 => CONNECTED_TO_parameters_2_user_interface_dataout_2, --                            .dataout_2
			parameters_2_user_interface_dataout_3 => CONNECTED_TO_parameters_2_user_interface_dataout_3, --                            .dataout_3
			parameters_2_user_interface_dataout_4 => CONNECTED_TO_parameters_2_user_interface_dataout_4, --                            .dataout_4
			parameters_2_user_interface_dataout_5 => CONNECTED_TO_parameters_2_user_interface_dataout_5, --                            .dataout_5
			parameters_2_user_interface_dataout_6 => CONNECTED_TO_parameters_2_user_interface_dataout_6, --                            .dataout_6
			parameters_2_user_interface_dataout_7 => CONNECTED_TO_parameters_2_user_interface_dataout_7, --                            .dataout_7
			parameters_2_user_interface_dataout_8 => CONNECTED_TO_parameters_2_user_interface_dataout_8, --                            .dataout_8
			parameters_2_user_interface_dataout_9 => CONNECTED_TO_parameters_2_user_interface_dataout_9, --                            .dataout_9
			parameters_2_user_interface_datain_10 => CONNECTED_TO_parameters_2_user_interface_datain_10, --                            .datain_10
			parameters_2_user_interface_datain_11 => CONNECTED_TO_parameters_2_user_interface_datain_11, --                            .datain_11
			parameters_2_user_interface_datain_12 => CONNECTED_TO_parameters_2_user_interface_datain_12, --                            .datain_12
			parameters_2_user_interface_datain_13 => CONNECTED_TO_parameters_2_user_interface_datain_13, --                            .datain_13
			parameters_2_user_interface_datain_14 => CONNECTED_TO_parameters_2_user_interface_datain_14, --                            .datain_14
			parameters_2_user_interface_datain_15 => CONNECTED_TO_parameters_2_user_interface_datain_15, --                            .datain_15
			parameters_3_user_interface_dataout_0 => CONNECTED_TO_parameters_3_user_interface_dataout_0, -- parameters_3_user_interface.dataout_0
			parameters_3_user_interface_dataout_1 => CONNECTED_TO_parameters_3_user_interface_dataout_1, --                            .dataout_1
			parameters_3_user_interface_dataout_2 => CONNECTED_TO_parameters_3_user_interface_dataout_2, --                            .dataout_2
			parameters_3_user_interface_dataout_3 => CONNECTED_TO_parameters_3_user_interface_dataout_3, --                            .dataout_3
			parameters_3_user_interface_dataout_4 => CONNECTED_TO_parameters_3_user_interface_dataout_4, --                            .dataout_4
			parameters_3_user_interface_dataout_5 => CONNECTED_TO_parameters_3_user_interface_dataout_5, --                            .dataout_5
			parameters_3_user_interface_dataout_6 => CONNECTED_TO_parameters_3_user_interface_dataout_6, --                            .dataout_6
			parameters_3_user_interface_dataout_7 => CONNECTED_TO_parameters_3_user_interface_dataout_7, --                            .dataout_7
			parameters_3_user_interface_dataout_8 => CONNECTED_TO_parameters_3_user_interface_dataout_8, --                            .dataout_8
			parameters_3_user_interface_dataout_9 => CONNECTED_TO_parameters_3_user_interface_dataout_9, --                            .dataout_9
			parameters_3_user_interface_datain_10 => CONNECTED_TO_parameters_3_user_interface_datain_10, --                            .datain_10
			parameters_3_user_interface_datain_11 => CONNECTED_TO_parameters_3_user_interface_datain_11, --                            .datain_11
			parameters_3_user_interface_datain_12 => CONNECTED_TO_parameters_3_user_interface_datain_12, --                            .datain_12
			parameters_3_user_interface_datain_13 => CONNECTED_TO_parameters_3_user_interface_datain_13, --                            .datain_13
			parameters_3_user_interface_datain_14 => CONNECTED_TO_parameters_3_user_interface_datain_14, --                            .datain_14
			parameters_3_user_interface_datain_15 => CONNECTED_TO_parameters_3_user_interface_datain_15, --                            .datain_15
			parameters_user_interface_dataout_0   => CONNECTED_TO_parameters_user_interface_dataout_0,   --   parameters_user_interface.dataout_0
			parameters_user_interface_dataout_1   => CONNECTED_TO_parameters_user_interface_dataout_1,   --                            .dataout_1
			parameters_user_interface_dataout_2   => CONNECTED_TO_parameters_user_interface_dataout_2,   --                            .dataout_2
			parameters_user_interface_dataout_3   => CONNECTED_TO_parameters_user_interface_dataout_3,   --                            .dataout_3
			parameters_user_interface_dataout_4   => CONNECTED_TO_parameters_user_interface_dataout_4,   --                            .dataout_4
			parameters_user_interface_dataout_5   => CONNECTED_TO_parameters_user_interface_dataout_5,   --                            .dataout_5
			parameters_user_interface_dataout_6   => CONNECTED_TO_parameters_user_interface_dataout_6,   --                            .dataout_6
			parameters_user_interface_dataout_7   => CONNECTED_TO_parameters_user_interface_dataout_7,   --                            .dataout_7
			parameters_user_interface_dataout_8   => CONNECTED_TO_parameters_user_interface_dataout_8,   --                            .dataout_8
			parameters_user_interface_dataout_9   => CONNECTED_TO_parameters_user_interface_dataout_9,   --                            .dataout_9
			parameters_user_interface_datain_10   => CONNECTED_TO_parameters_user_interface_datain_10,   --                            .datain_10
			parameters_user_interface_datain_11   => CONNECTED_TO_parameters_user_interface_datain_11,   --                            .datain_11
			parameters_user_interface_datain_12   => CONNECTED_TO_parameters_user_interface_datain_12,   --                            .datain_12
			parameters_user_interface_datain_13   => CONNECTED_TO_parameters_user_interface_datain_13,   --                            .datain_13
			parameters_user_interface_datain_14   => CONNECTED_TO_parameters_user_interface_datain_14,   --                            .datain_14
			parameters_user_interface_datain_15   => CONNECTED_TO_parameters_user_interface_datain_15,   --                            .datain_15
			reset_reset_n                         => CONNECTED_TO_reset_reset_n,                         --                       reset.reset_n
			reset_fifos_reset                     => CONNECTED_TO_reset_fifos_reset,                     --                 reset_fifos.reset
			reset_op_export                       => CONNECTED_TO_reset_op_export,                       --                    reset_op.export
			result0_32_bit_in_export              => CONNECTED_TO_result0_32_bit_in_export,              --           result0_32_bit_in.export
			result0_64_bit_down_in_export         => CONNECTED_TO_result0_64_bit_down_in_export,         --      result0_64_bit_down_in.export
			result0_64_bit_up_in_export           => CONNECTED_TO_result0_64_bit_up_in_export,           --        result0_64_bit_up_in.export
			result1_32_bit_in_export              => CONNECTED_TO_result1_32_bit_in_export,              --           result1_32_bit_in.export
			result1_64_bit_down_in_export         => CONNECTED_TO_result1_64_bit_down_in_export,         --      result1_64_bit_down_in.export
			result1_64_bit_up_in_export           => CONNECTED_TO_result1_64_bit_up_in_export            --        result1_64_bit_up_in.export
		);

