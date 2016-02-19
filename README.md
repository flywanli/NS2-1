# ECEN-602 Programming Assignment 4
----------------------------------

Team Number: 10
Member 1 # Sama, Avani 
Member 2 # Li, Wan  
---------------------------------------

Design:
--------------------
For the ns2.tcl
●	Command line is in the following format: ns ns2.tcl <TCP Flavour(all Caps)> <case number>
●	Open Ns trace File, NAM file, out_<flavour><case>
●	Initializes Nodes, Data flow, Agents, Links, Application
●	Proc Finish{} writes throughput of both the sources and executes NAM file
●	Proc Record{} calculates throughput at each 0.5 sec interval and put in file 1 and file  2
which is then added to the total throughput i.e. throughput1 and 2 respectively and display average on the terminal window
●	Both sources start sending data from 0 to 400 seconds, finish is run at 400 sec


Implementation:
-----------------------------------------
●	Command line is in the following format: ns ns2.tcl <TCP Flavour(all Caps)> <case number>

