#############################################################################
# this is a simple script, which connects to the Crazyfly and uses snynchronous logging
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

#import logging packages
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie

from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncLogger import SyncLogger

# URI to the Crazyflie to connect to
uri = uri_helper.uri_from_env(default='radio://0/80/2M/E7E7E7E7E7')
# Only output errors from the logging framework
logging.basicConfig(level=logging.ERROR)

def simple_connect():

    print("Yeah, I'm connected! :D")
    time.sleep(3)
    print("Now I will disconnect :'(")

def simple_log(scf, logconf):

    with SyncLogger(scf, logconf) as logger:
            for log_entry in logger:

                timestamp = log_entry[0]
                data = log_entry[1]
                logconf_name = log_entry[2]

                print('[%d][%s]: %s' % (timestamp, data, logconf_name))

                time.sleep(3)

if __name__ == '__main__':
    # Initialize the low-level drivers
    cflib.crtp.init_drivers()

    #add logging configuration
    lg_stab = LogConfig(name='Stabilizer', period_in_ms=10)
    lg_stab.add_variable('kalman.stateX', 'float')
    lg_stab.add_variable('kalman.stateY', 'float')
    lg_stab.add_variable('kalman.stateZ', 'float')

    with SyncCrazyflie(uri, cf=Crazyflie(rw_cache='./cache')) as scf:

        #simple_connect()
        simple_log(scf, lg_stab)