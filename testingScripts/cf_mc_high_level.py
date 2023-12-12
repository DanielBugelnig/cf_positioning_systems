import logging
import sys
import time
from threading import Event
import threading

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

counter = 0


def hl_motion_commander_fly_setpoints(scf):
    with PositionHlCommander(scf, default_height=DEFAULT_HEIGHT) as mc:
        mc.go_to(0, 0, 0.5)
        #time.sleep(2)
        mc.go_to(2, 0, 0.5)
        #time.sleep(2)
        mc.go_to(0, 0, 0.5)
        #time.sleep(2)
        mc.go_to(-1, 0, 0.5)
        #time.sleep(2)
        mc.go_to(0, 0, 0.5)
        #time.sleep(2)
def hl_motion_commander_fly_directions(scf):
    mc = PositionHlCommander(scf, default_height=DEFAULT_HEIGHT)
    mc.take_off(height = 0.4)
    #time.sleep(2)
    mc.go_to(0,0.8,0.5)
    #mc.up(0.3)
    #time.sleep(2)
    mc.forward(1)
    #time.sleep(2)
    mc.right(1)
    #time.sleep(2)
    mc.left(1)
    #time.sleep(2)
    mc.back(1)
    #time.sleep(2)
    mc.go_to(0.8,0.8,0,3)
    time.sleep(0.8)
    mc.land()

def hl_motion_commander_fly_frame(scf):
    mc = PositionHlCommander(scf, default_height=DEFAULT_HEIGHT)
    mc.take_off(height=0.4)
    mc.go_to(0.8,0.8,0.4)
    while exit[0] != 'exit':

        while mc.get_position()[0] < 1.4 and exit[0] != 'exit':
            mc.forward(0.05)
        while mc.get_position()[0] > 0.2 and exit[0] != 'exit':
            mc.back(0.05)
    mc.go_to(0.2,0.4,0.2)
    time.sleep(2)
    mc.land()





def log_pos_callback(timestamp, data, logconf):
    print('[%d][%s] %s' % (timestamp, logconf.name, data))





def param_deck_flow(_, value_str):
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
                                         cb=param_deck_flow)
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

        hl_motion_commander_fly_setpoints((scf))
        input_thread.join()


        #time.sleep(10)
        logconf.stop()
