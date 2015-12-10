# Connect-Four
An implement for Connect-Four Game.

# Version
v. 1.0.1

# License
MIT

# Feature
This game uses Tcl/Tk as the GUI library and, meanwhile, provides a command-line version.

The game supports Computer v.s. Computer, Human v.s. Computer and Human v.s. Human.


# Agents
Three kinds of agents are developed.

   Human Agent for human player,
   Computer Agent whose action pattern is random completely, and
   Intelligent Agent who use min-max algorithm with alpha-beta pruning technique.


# Evaluation System
Evaluation System is designed for Intelligent Agent to determine its action.

This system uses min-max algorithm with alpha-beta pruning technique.

The IntelCompAgent#iq decides the search depth of min-max algorithm. The bigger the value of this variable is, the more intelligent the agent would be.

The evaluation function employed in this system is defined based on the following rules:

    +1 for any 4-slot line where one slot is occupied by the *current* agent and the rest are empty.
    +4 for any 4-slot line where two slots are occupied by the *current* agent and the rest are empty.
    +8 for any 4-slot line where three slots are occupied by the *current* agent and the rest one is empty.
    +infinite for any 4-slot line where four slots are all occupied by the *current* agent (the win case).
    -1 for any 4-slot line where one slot is occupied by the *opposite* agent and the rest are empty.
    -4 for any 4-slot line where two slots are occupied by the *opposite* agent and the rest are empty.
    -8 for any 4-slot line where three slots are occupied by the *opposite* agent and the rest one is empty.
    -infinite for any 4-slot line where four slots are all occupied by the *opposite* agent (the lose case).


# Usage
Environment: Ruby 2.0.0

Run _*main.rb*_ .

# Thanks
Have a good day.
