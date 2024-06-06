# crazyflies-positioning
## Commissioning and testing of localization systems for mini-drones

This project aims to set up and use Crazyflie with the loco positioning system to enable autonomous flight.
Furthermore, the preciseness and accuracy will be compared with the Optitrack motion-capturing positioning system.
The Loco Positioning System uses UWB (ultra-wide-band). Anchors in the room continuously connect with the crazyflie and calculate the distance between them. 
8 anchors were used in this setup, it is also possible with four.
The Optitrack system uses infrared cameras, which tracks a passive marker. The infrared light will reflect off the passive marker, mounted on the crazyflie, and the distance between camera and marker will be calculated.
7 cameras were used in this setup.

# Description of folders and files:
> #### / testing_scripts
>Scripts for testing several functions of the crazyflie
>> #### / setup_files
> #### / data_processing
>> Scripts that produce data for evaluation and plotting
> #### / results_plots
>> Evaluated data and plotted results
> #### / data
>> collected data from measurements

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
### Crazyflie Setup
https://www.bitcraze.io/documentation/tutorials/getting-started-with-crazyflie-2-x/
Mount the loco_positioning deck on top, place the marker upon it and fix it with tape. 
Working with the marker deck aswell caused troubles in flying. 
### Positioning Systems
For building up the flying environment, it is recommended to calibrate the two positioning systems to the same coordination system. Otherwise, an offset has to be calculated and taken into account.
#### Optitrack
[Set up](https://docs.optitrack.com/quick-start-guides/quick-start-guide-getting-started) the optitrack environment For this setup 7 cameras where used, which were mounted on a frame on the top of the room.
Calibration [file](setup_files/Calibration_Excellent_MeanErr_0.626_mm_2023-05-31_9.cal) for used setup

#### Loco Setup
To align the Loco System with Optitrack, use passive markers on the loco-anchors to get the exact position of the anchors. 
For the used environment, the position data of the anchors can be found here.
Follow the instructions of the documentation on [bitcraze](https://www.bitcraze.io/documentation/tutorials/getting-started-with-loco-positioning-system/).
- Used Mode: TWR
- To assign an ID (LPS configuration tool) to the anchors, it is recommended to use a [VM](https://github.com/bitcraze/bitcraze-vm/releases/), which is provided by bitcraze
- Position data for anchors, aligned with Optitrack --> [file](setup_files/anchor-position_optitrack.yaml) 
- 
If all steps are finished, do some manual tests to make sure everything is set up correctly.
Connect the crazyflie with the cfc client and test out some positions with the crazyflie manually to test the loco system.
Use the Opitrack system to make sure the positioning data is similar.

# Connect with Crazyflie by python
Several python libraries have to be installed
- numPy
- cflib

Remember to plug in the crazy_radio antenna.
Test out the connection with test [scripts](/testingScripts)
In this order: 
- connecting.py
- cf_logging_sync
- cf_logging_async
- cf_motion_commander
- cf_mc_high_level

Make sure the right address of the crazyfly is used.
If some errors occur, this documentation may help:
https://www.bitcraze.io/documentation/repository/crazyflie-lib-python/master/

# Create data
For comparison, several measures will be taken.
### Simple Position Comparison without flying
A simple comparison between the coordinates of the localization systems

### Flying trajectories with different heights (0.75m, 1m, 1.5m)
[cf_create evaluation_data](/testingScripts/cf_create_evaluation_data.py) 
The crazyflie will fly off 5 points in the form of a square.
Choose the right function for flying of 5 points: ``` hl_mc_fly_square(scf,z) ``` in line 131
This flight will be repeated at different heights.
To get the positioning data from the Optitrack system, start recording before flying and export the position data as .csv file.
Loco Positioning Data is automatically stored in the project folder, specify the file_name in [cf_create evaluation_data](/testingScripts/cf_create_evaluation_data.py) 
[Raw Data](/data/square_measurements/)

For flying the line measurement, enable ``` hl_mc_fly_line(scf, z) ``` 
Only enable one of these function at one time.


# Evaluation
For [evaluation](/data_processing/), Matlab is used, simply input the correct datapaths of the data, and the positioning data will be synchronized and evaluated automatically.

Eventually, cut off header information of the data.
Make sure, that the data files are complete.

There are scripts for processing the data for the square_measurement for each height and combined. Script [line_measurement](/data_processing/line_measurement.m) is for evaluation the line measurement.





