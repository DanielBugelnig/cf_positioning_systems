import logging
import sys
import time
from threading import Event
import threading
import numpy as np
from datetime import date

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.positioning.motion_commander import MotionCommander
from cflib.utils import uri_helper
from cflib.positioning.position_hl_commander import PositionHlCommander


URI = uri_helper.uri_from_env(default='radio://0/80/2M/E7E7E7E7E7')

DEFAULT_HEIGHT = 0.5
deck_attached_event = Event()
logging_rate = 10 #in ms

logging.basicConfig(level=logging.ERROR)

x_coordinates = np.zeros(10000)
y_coordinates = np.empty(10000)
z_coordinates = np.empty(10000)
timestamp_ = np.empty(10000)
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

def hl_mc_fly_line(scf,z):
    with PositionHlCommander(scf, default_height=DEFAULT_HEIGHT) as mc:
        mc.go_to(0,0,z)
        mc.go_to(-1,-1,z)
        mc.go_to(1,1,z)
        mc.go_to(0,0,z)
        mc.go_to(0, 0, 0.2)




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

def param_deck_bcloco(_, value_str):
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
                                         cb=param_deck_bcloco)
        time.sleep(1)

        logconf = LogConfig(name='Position', period_in_ms=logging_rate)
        logconf.add_variable('stateEstimate.x', 'float')
        logconf.add_variable('stateEstimate.y', 'float')
        logconf.add_variable('stateEstimate.z', 'float')
        scf.cf.log.add_config(logconf)
        logconf.data_received_cb.add_callback(log_pos_callback)

        if not deck_attached_event.wait(timeout=5):
            print('No flow deck detected!')
            sys.exit(1)
        height = 1
        logconf.start()
#       hl_motion_commander_fly_setpoints(scf)
        hl_mc_fly_line(scf, height)
        logconf.stop()
#       Öffne die Datei zum Schreiben ('w' steht für write, 'a' steht für append)
        with open('x_coordinates.txt', 'w') as file:
            # Schreibe Text in die Datei
            print("Test Fly: hl_mc_fly_line, height at " + str(height) + "meter",file=file)
            print("Date: ", date.today(),file=file)
            print("logging-rate: " + str(logging_rate),file=file)
            for i in range(len(x_coordinates)):
                if x_coordinates[i] != 0.0:
                    print(x_coordinates[i], file=file)

                else:
                    break

        with open('y_coordinates.txt', 'w') as file:
                    # Schreibe Text in die Datei
                    print("Test Fly: hl_mc_fly_line, height at " + str(height) + "meter", file=file)
                    print("Date: ", date.today(), file=file)
                    print("logging-rate: " + str(logging_rate), file=file)
                    for i in range(len(y_coordinates)):
                        if y_coordinates[i] != 0.0:
                            print(y_coordinates[i], file=file)

                        else:
                            break

        with open('z_coordinates.txt', 'w') as file:
            # Schreibe Text in die Datei
            print("Test Fly: hl_mc_fly_line, height at " + str(height) + "meter", file=file)
            print("Date: ", date.today(), file=file)
            print("logging-rate: " + str(logging_rate), file=file)
            for i in range(len(z_coordinates)):
                if z_coordinates[i] != 0.0:
                    print(z_coordinates[i], file=file)

                else:
                    break
