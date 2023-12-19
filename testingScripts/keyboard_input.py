#################################
# this small script tests threading
#################################
import threading
import time

def user_input_listener(x):
    while x[0] != 'c':
        x[0]= input()


# Start the user input listener in a separate thread
x=[2]
input_thread = threading.Thread(target=user_input_listener, args=(x,))
input_thread.start()

# Your main program logic goes here
y=0
while x[0] != 'c':
    print(y)
    y += 1
    time.sleep(2)

input_thread.join()
exit()
# test
