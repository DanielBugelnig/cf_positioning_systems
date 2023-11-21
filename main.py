#############################################################################
# this is a simple script, which connects to the Crazyfly
############################################################################
#standard packages
import logging
import time

#The cflib.crtp module is for scanning for Crazyflies instances
#The Crazyflie class is used to easily connect/send/receive data from a Crazyflie.
#The synCrazyflie class is a wrapper around the “normal” Crazyflie class.
#It handles the asynchronous nature of the Crazyflie API and turns it into blocking function.

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.utils import uri_helper

# URI to the Crazyflie to connect to
uri = uri_helper.uri_from_env(default='radio://0/80/2M/E7E7E7E7E7')

def simple_connect():

    print("Yeah, I'm connected! :D")
    time.sleep(3)
    print("Now I will disconnect :'(")
kkkk
if __name__ == '__main__':
    # Initialize the low-level drivers
    cflib.crtp.init_drivers()

    with SyncCrazyflie(uri, cf=Crazyflie(rw_cache='./cache')) as scf:

        simple_connect()