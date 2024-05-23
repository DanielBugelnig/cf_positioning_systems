#############################################################################
# this is a simple script, which connects to the Crazyfly and uses asynchronous logging
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
uri = uri_helper.uri_from_env(default='radio://0/80/2M/E7E7E7E701')
# Only output errors from the logging framework
logging.basicConfig(level=logging.ERROR)


def simple_log_async(scf, logconf):
    cf = scf.cf
    cf.log.add_config(logconf)
    logconf.data_received_cb.add_callback(log_callback)

    logconf.start()
    time.sleep(1)
    #logconf.stop()
    #test

def log_callback(timestamp, data, logconf):
    print('[%d][%s] %s' % (timestamp, logconf.name, data))


if __name__ == '__main__':
    # Initialize the low-level drivers
    cflib.crtp.init_drivers()

    #add logging configuration
    lg_stab = LogConfig(name='Stabilizer', period_in_ms=10)
    lg_stab.add_variable('kalman.stateX', 'float')
    lg_stab.add_variable('kalman.stateY', 'float')
    lg_stab.add_variable('kalman.stateZ', 'float')
    lg_stab.add_variable('stateEstimate.x', 'float')

    with SyncCrazyflie(uri, cf=Crazyflie(rw_cache='./cache')) as scf:

        #simple_connect()
        #simple_log(scf, lg_stab)
        simple_log_async(scf, lg_stab)
        time.sleep(10)

        lg_stab.stop()