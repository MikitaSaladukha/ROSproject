from tkinter import *

root = Tk()
root.title("Turtlebot3 Q-learning control")

def start_from_null():
    #print("Start from null")
    with open('commands.txt', 'w') as f:
        f.write('start_from_null')

def start_from_existing():
    #print("Start from existing")
    with open('commands.txt', 'w') as f:
        f.write('start_from_existing')
def pauseQ():
    #print("pauseQ")
    with open('commands.txt', 'w') as f:
        f.write('pauseQ')

def continueQ():
    #print("Continue")
    with open('commands.txt', 'w') as f:
        f.write('continueQ')

add_loc = Button(root, text="start with new q-table", command=start_from_null)
add_loc.grid(row=0, column=1)

add_loc = Button(root, text="continue with existing q-table", command=start_from_existing)
add_loc.grid(row=1, column=1)

add_loc = Button(root, text="pause", command=pauseQ)
add_loc.grid(row=2, column=1)

add_loc = Button(root, text="continue", command=continueQ)
add_loc.grid(row=3, column=1)

root.mainloop()