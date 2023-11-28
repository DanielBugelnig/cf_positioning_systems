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

def user_input_listener(x):
    while x[0] != 'exit':
        x[0]= input()


# Start the user input listener in a separate thread



URI = uri_helper.uri_from_env(default='radio://0/80/2M/E7E7E7E7E7')

DEFAULT_HEIGHT = 0.5
BOX_LIMIT1 = 1.35
BOX_LIMIT2 = 0.15

deck_attached_event = Event()

logging.basicConfig(level=logging.ERROR)

x_coordinates = np.empty(1)
y_coordinates = np.empty(1)
z_coordinates = np.empty(1)
timestamp_ = np.empty(1)
counter = 0


def hl_motion_commander_fly_setpoints(scf):
    with PositionHlCommander(scf, default_height=DEFAULT_HEIGHT) as mc:
        mc.go_to(0.8,0.8,0.5)
        time.sleep(2)
        mc.go_to(1.4, 1.4, 0.5)
        time.sleep(2)
        mc.go_to(1.4, 0.2, 0.5)
        time.sleep(2)
        mc.go_to(0.2, 0.2, 0.5)
        time.sleep(2)
        mc.go_to(0.2, 1.4, 0.5)
        time.sleep(2)
        mc.go_to(0.8, 0.8, 0.3)
        time.sleep(2)
        mc.go_to(0.8, 0.8, 0.1)
        time.sleep(2)







def log_pos_callback(timestamp, data, logconf):
    global x_coordinates
    global y_coordinates
    global z_coordinates
    global timestamp_
    x_coordinates.append = data['stateEstimate.x']
    y_coordinates.append = data['stateEstimate.x']
    z_coordinates.append = data['stateEstimate.x']
    timestamp_ = data['timestamp']

    print(data)



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

    exit = [2]
    input_thread = threading.Thread(target=user_input_listener, args=(exit,))
    input_thread.start()


    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache='./cache')) as scf:

        scf.cf.param.add_update_callback(group='deck', name='bcLoco',
                                         cb=param_deck_bcLoco)
        time.sleep(1)

        logconf = LogConfig(name='Position', period_in_ms=10)
        logconf.add_variable('stateEstimate.x', 'float')
        logconf.add_variable('stateEstimate.y', 'float')
        logconf.add_variable('stateEstimate.z', 'float')
        scf.cf.log.add_config(logconf)
        logconf.data_received_cb.add_callback(log_pos_callback)

        if not deck_attached_event.wait(timeout=5):
            print('No flow deck detected!')
            sys.exit(1)

        logconf.start()
        input_thread.join()
        hl_motion_commander_fly_setpoints(scf)
        logconf.stop()
        print(x_coordinates[10:20])