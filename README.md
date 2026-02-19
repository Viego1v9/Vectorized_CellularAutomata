# Vectorized approach for a Cellular Automata 2D prey-predator system implemented in MATLAB


  ### About:
  The program simulates a prey-predator cellular automata with a reproducing mechanic for a given number of iterations as well as a hunger timer for predators. It utilizes a combination of circshift and matrix masks for every degree of freedom, to avoid iterating through the whole matrix.


 ### Quick explanation of how the code works:
 The initial number of prey and predators are placed randomly on the NxN matrix and have a value of 1 and -1 respectively ( 0 indicate the position isnt occupied). A while loop with 3 conditions(1st condition imposes a limit to the iterations and the other 2 stop the simulation when all prey or predators are dead)is used to run the main parts of the simulation simulate the motion with 4 degrees of freedom(up,down,left,right). Using a combination of a masked matrix and circshift the prey/predators able to move to their desired direction(which is decided randomly on every iteration) are chosen and first their original position is removed and a new matrix holding their new position is added to the original matrix(Environment)  thus simulating the motion of all prey/predators. This process is repeated 4 times for all 4 directions(degrees of freedom).At the end the program plots some graphs of interest.

### Requirements:
  Matlab R2020b was used thus the same or a higher version is required to run correctly.
