import logging
import sys
import time
from threading import Event
import threading
import numpy as np

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.positioning.motion_commander import MotionCommander
from cflib.utils import uri_helper
from cflib.positioning.position_hl_commander import PositionHlCommander

#def user_input_listener(x):
#    while x[0] != 'exit':
#        x[0]= input()


# Start the user input listener in a separate thread



URI = uri_helper.uri_from_env(default='radio://0/80/2M/E7E7E7E7E7')

DEFAULT_HEIGHT = 0.5
BOX_LIMIT1 = 1.35
BOX_LIMIT2 = 0.15

deck_attached_event = Event()

logging.basicConfig(level=logging.ERROR)

x_coordinates = np.zeros(100000)
y_coordinates = np.empty(100000)
z_coordinates = np.empty(100000)
timestamp_ = np.empty(100000)
counter = 0


def hl_motion_commander_fly_setpoints(scf):
    with PositionHlCommander(scf, default_height=DEFAULT_HEIGHT) as mc:
        mc.go_to(0.0,0.0,0.5)
        mc.go_to(1, 0, 0.5)
        mc.go_to(-1, 0, 0.5)
        mc.go_to(1, -1, 0.5)
        mc.go_to(0,0,0.5)

        mc.go_to(0,0,1.5)
        mc.go_to(1.5,1,1.5)
        mc.go_to(1.5, -0.5, 1.5)
        mc.go_to(-1.5, -0.5, 1.5)
        mc.go_to(-1.5, 0.5
                 , 1.5)
        mc.go_to(0,0, 1.5)

        mc.go_to(0, 0, 0.7)
        mc.go_to(0, 0, 0.3)







def log_pos_callback(timestamp, data, logconf):
    global x_coordinates
    global y_coordinates
    global z_coordinates
    global timestamp_
    global counter
    x_coordinates[counter] = data['stateEstimate.x']
    y_coordinates[counter] = data['stateEstimate.y']
    z_coordinates[counter] = data['stateEstimate.z']
    timestamp_[counter] = timestamp

    print(data)
    counter = counter + 1



def param_deck_bcLoco(_, value_str):
    value = int(value_str)
    print(value)
    if value:
        deck_attached_event.set()
        print('Deck is attached!')
    else:
        print('Deck is NOT attached!')

if __name__ == '__main__':
    cflib.crtp.init_drivers()

   # exit = [2]
    #input_thread = threading.Thread(target=user_input_listener, args=(exit,))
    #input_thread.start()


    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache='./cache')) as scf:

        scf.cf.param.add_update_callback(group='deck', name='bcLoco',
                                         cb=param_deck_bcLoco)
        time.sleep(1)

        logconf = LogConfig(name='Position', period_in_ms=16.66666)
        logconf.add_variable('stateEstimate.x', 'float')
        logconf.add_variable('stateEstimate.y', 'float')
        logconf.add_variable('stateEstimate.z', 'float')
        scf.cf.log.add_config(logconf)
        logconf.data_received_cb.add_callback(log_pos_callback)

        if not deck_attached_event.wait(timeout=5):
            print('No flow deck detected!')
            sys.exit(1)

        logconf.start()
        #input_thread.join()
        hl_motion_commander_fly_setpoints(scf)
        logconf.stop()
        print(x_coordinates[10:20])
        print(timestamp_[10:20])