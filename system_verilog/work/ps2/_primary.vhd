library verilog;
use verilog.vl_types.all;
entity ps2 is
    port(
        serial_data     : out    vl_logic_vector(7 downto 0);
        last_serial_data: out    vl_logic_vector(7 downto 0);
        valid           : out    vl_logic;
        paritycheck     : out    vl_logic;
        Clk             : in     vl_logic;
        nReset          : in     vl_logic;
        ps2_nclk        : in     vl_logic;
        ndata           : in     vl_logic
    );
end ps2;
