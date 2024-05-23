import logging
import sys
import time
from threading import Event

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.positioning.motion_commander import MotionCommander
from cflib.utils import uri_helper
from cflib.positioning.position_hl_commander import PositionHlCommander


URI = uri_helper.uri_from_env(default='radio://0/80/2M/E7E7E7E701')

DEFAULT_HEIGHT = 0.5
BOX_LIMIT1 = 1.35
BOX_LIMIT2 = 0.15

deck_attached_event = Event()

logging.basicConfig(level=logging.ERROR)

position_estimate = [0, 0, 0]
counter = 0

def move_linear_simple(scf):
    with MotionCommander(scf, default_height=DEFAULT_HEIGHT) as mc:
        time.sleep(1)
        print(position_estimate)
        mc.forward(0.5)
        time.sleep(1)
        print(position_estimate)
        mc.turn_left(180)
        time.sleep(1)
        print(position_estimate)
        mc.forward(0.5)
        time.sleep(1)
        print(position_estimate)

def move_linear_simple2(scf):
    with MotionCommander(scf, default_height=DEFAULT_HEIGHT) as mc:
        time.sleep(1)
        mc.start_forward(0.5)
        time.sleep(4)
        #mc.turn_left(180)
        mc.stop()
        time.sleep(4)
        mc.start_back(0.5)
        time.sleep(3)

def move_box_limit(scf):
    with MotionCommander(scf, default_height=DEFAULT_HEIGHT) as mc:

        while (1):
            pos = position_estimate
            time.sleep(0.2)
            if pos[0] > 1.5:
                mc.stop()
                mc.start_back(1)
                print('border reached+')
            elif pos[0] < 0.4:
                mc.stop()
                mc.start_forward(0.4)
                print('border reached-')
            if pos[2] < 0.5:
                mc.start_up(0.05)
            elif pos[2] > 0.5:
                mc.start_down(0.05)

def hl_motion_commander_fly_setpoints(scf):
    with PositionHlCommander(scf, default_height=DEFAULT_HEIGHT) as mc:
        mc.go_to(0.8,0.8,0.5)
        #time.sleep(2)
        mc.go_to(1.4, 1.4, 0.5)
        #time.sleep(2)
        mc.go_to(1.4, 0.2, 0.5)
        #time.sleep(2)
        mc.go_to(0.2, 0.2, 0.5)
        #time.sleep(2)
        mc.go_to(0.2, 1.4, 0.5)
        #time.sleep(2)
        mc.go_to(0.8, 0.8, 0.3)
        #time.sleep(2)
        mc.go_to(0.8, 0.8, 0.1)
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
    mc.go_to(0.8,0.8,0,4)
    while 1:

        while mc.get_position()[0] < 1.4:
            mc.forward(0.05)
        while mc.get_position()[0] > 0.2:
            mc.back(0.05)






def log_pos_callback(timestamp, data, logconf):
    global position_estimate
    position_estimate[0] = data['stateEstimate.x']
    position_estimate[1] = data['stateEstimate.y']
    position_estimate[2] = data['stateEstimate.z']
    #print(data)



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
        #move_linear_simple(scf)
        #move_linear_simple2(scf)
        #move_box_limit(scf)
        #hl_motion_commander_fly_directions((scf))
        hl_motion_commander_fly_frame(scf)
        #time.sleep(10)
        #logconf.stop()
