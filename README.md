# crazyflies-positioning
## Commissioning and testing of localization systems for mini-drones

This project aims to set up and use Crazyflie with the loco positioning system to enable autonomous flight.
Furthermore, the preciseness and accuracy will be compared with the optitrack motion-capturing positioning system.
The Loco Positioning System uses UWB (ultra-wide-band). Anchors in the room continously connect with the crazyflie and calculate the distance between them. 
8 anchors were used in this setup, it is also possible with four.
The Optitrack system uses infrared cameras, witch tracks a passive marker. The infrared ligth will reflect off the passive marker, mounted on the crazyflie, and the distance between camera and marker will be calculated.
7 cameras were used in this setup.

# Description of folders and files:
> #### / testing_scripts
>Scripts for testing several functions of the crazyflie
>> #### / setup_files
> #### / evaluation_scripts
>> Scripts that produce data for evaluation and plotting
> #### / results_plots
>> Evaluated data and plotted results

# Set up
This project uses several parts of hardware and software; setups for specific parts are listed below.
### Hardware 
* #### Crazyflie
   * crazyflie     
   * loco_positioning_deck
   * marker_deck with one passive marker
   * crazy_radio antenna
* #### positioning hardware
   * Optitrack, a total of seven infrared cameras
   * Loco Positioning, a total of 8 anchors
* #### Software
   * cfc client (crazyflie)
   * LPS configuration tool (loco)
   * motive (optitrack)
   * matlab (evaluation)
   * python (execution)

Follow the documentation on bitcraze.io to set up the crazyflie and the loco positioning system
### Crazyfly Setup
https://www.bitcraze.io/documentation/tutorials/getting-started-with-crazyflie-2-x/
Mount the loco_positioning deck to the bottom side of the crazyflie, on top place the marker_deck with one passive marker.
### Positioning Systems
For building up the flying environment, it is recommended to calibrate the two positioning systems to the same coordination system. Otherwise, an offset has to be calculated and has to take into account.
#### Optitrack
Set up the optitrack environment(https://docs.optitrack.com/quick-start-guides/quick-start-guide-getting-started) For this setup 7 cameras where used, which were mounted on a frame on the top of the room.
Calibration [file](setup_files/Calibration Excellent (MeanErr 0.626 mm) 2023-05-31 9.cal) for used setup

#### Loco Setup
To align the Loco System with Optitrack, use passive markers on the loco-anchors to get the exact position of the anchors. 
For the used environment, position data of the anchors can be found here.
Follow the instructions of the documentation on bitcraze.io.
https://www.bitcraze.io/documentation/tutorials/getting-started-with-loco-positioning-system/
- Used Mode: TWR
- To assign an ID (LPS configuration tool) to the anchors, it is recommended to use a VM, which is provided by bitcraze
- Position data for anchors, aligned with Optitrack --> [file](setup_files/anchor-position_optitrack.yaml) 
- 
If all steps are finished, make some manual test to make sure everything is set up correct.
Connect the crazyflie with the cfc client and test out some positions with the crazyflie manually to test the loco system.
Use the opitrack system to make sure the positioning data is similar.

# Connect with Crazyflie by python
Several python libraries have to be installed
- numPy
- cflib

Remember to plug in the crazy_radio antenna.
Test out the connection with test scripts (/testingScripts)
In this order: 
- connecting.py
- cf_logging_sync
- cf_logging_async
- cf_motion_commander
- cf_mc_high_level

If errors occur, this documentation may help:
https://www.bitcraze.io/documentation/repository/crazyflie-lib-python/master/

# Create data
For comparison, several measures will be done.
Simple Position Comparison without flying
Flying multiple trajectories with different heights
cf_create evaluation_data fly the crazyflie from A to B, uses different heights as input.
The loco positioning data will be saved under xyz_coordinates.
To get the positioning data from the optitrack system, start recording before flying and export the position data as .csv file.

# Evaluation
For evaluation, Matlab is used, simply input the correct datapaths of the data and the positioning data will be synchronzied and evaluated automatically.





