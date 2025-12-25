import cocotb
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_neural_net_digits(dut):
    dut._log.info("Starting Seven Segment Neural Network Test...")

    # Set the clock period (matches your 10kHz setting)
    # 10kHz = 100us period
    
    # Reset the circuit
    dut._log.info("Resetting...")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Define the 7-segment patterns (G F E D C B A)
    # Based on your Verilog: ui_in[0]=A, [1]=B, [2]=C, [3]=D, [4]=E, [5]=F, [6]=G
    segments = {
        0: 0b00111111, # 0
        1: 0b00000110, # 1
        2: 0b01011011, # 2
        3: 0b01001111, # 3
        4: 0b01100110, # 4
        5: 0b01101101, # 5
        6: 0b01111101, # 6
        7: 0b00000111, # 7
        8: 0b01111111, # 8
        9: 0b01101111  # 9
    }

    for expected_digit, pattern in segments.items():
        dut.ui_in.value = pattern
        
        # Wait for 2 clock cycles for the 'always @(posedge clk)' to register the winner
        await ClockCycles(dut.clk, 2)
        
        # The prediction is in the lower 4 bits of uo_out
        actual_prediction = int(dut.uo_out.value) & 0x0F
        
        if actual_prediction == expected_digit:
            dut._log.info(f"SUCCESS: Input {pattern:08b} predicted as {actual_prediction}")
        else:
            dut._log.error(f"FAILURE: Input {pattern:08b} expected {expected_digit}, got {actual_prediction}")
            assert actual_prediction == expected_digit
