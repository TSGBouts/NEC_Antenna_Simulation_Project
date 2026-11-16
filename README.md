# NEC Antenna Simulations

Electromagnetic modeling and radiation analysis of four antenna configurations using 4NEC2 (NEC-2):

- Discone antenna
- Helical antenna
- Folded dipole antenna
- Beverage (traveling-wave) antenna

The project examines input impedance, reflection coefficient, SWR, radiation patterns and the effects of frequency, antenna geometry and ground conditions.

## Repository contents

- `models/`: NEC input files for the four antenna configurations.
- `matlab/`: MATLAB scripts for generating discone, folded dipole and Beverage models.
- [Simulation report](NEC_Antenna_Simulation_Report.pdf): theoretical background, simulation results and discussion.

## Tools

- 4NEC2
- MATLAB

Open the NEC input files in 4NEC2 to perform frequency sweeps and radiation-pattern calculations. The helical antenna was modeled directly in 4NEC2.
