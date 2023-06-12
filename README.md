# color_crasher
<h1> Color Crasher - A Game of Wits and Rainbows </h1>

Hey everyone! This is our Capstone project for the Digital Design Architecture and Verification Project at IEEE at UCLA. Our idea for this project was to integrate the concept of Asteroids into a color-based game, where users would get to play an MC who shoots colorful attacks at some enemies.

This project is composed of 4 key sections:
- I2C Integration for Wii Nunchuk operation \n
- VGA Operation for gameplay \n
- *Game State Updater for MC, Bullet(Bill), and Enemy operation* \n
- Graphics Generator for VGA Input \n

<h2> Project Goals </h2>
The near-completion of this project taught us how to develop, integrate, and debug an I2C Protocol. It also taught us how to successfully utilize pixel RGB bit classificaiton to show images on a VGA Display. We were also able to implement a simulation-based fully functional state machine for gameplay processing. A future goal of ours is to reflect on what was accomplished in this repository and integrate a functional variation of this gameplay using RAM in addition to a more modular approach in its development.

<h2> Disclaimer </h2>
This project still has some bugs but we are excited to launch the code! \n

The repository is complete with the exception of <em>game_state_updater.sv</em>. When running the simulation for this project the state machine worked within Quartus' Questa Waveforms but in hardware application it failed to appear. We believe the bug to be a result of timing issues due to our use of 3 seperate clocks for seperate object gameplay. However, the remainder of the code works just fine in hardware application so feel free to use it as reference!

This project is powered by systemVerilog and Intel's Quartus FPGA HDL processor.

<h2> Component List </h2>
- Altera TerasIC DE-10 Lite FPGA \n
- Wii Nunchuck \n
- VGA Display \n
- VGA Cable \n
- Appropriate Power Cables
