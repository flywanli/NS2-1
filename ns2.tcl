if { $argc != 2 } {
        puts "Invalid usage!"
        puts "For example: ns $argv0 <TCP_Flavor> <case_no>"
        puts "Please try again."
    }
set flavor [lindex $argv 0]
set case [lindex $argv 1]
if {$case > 3 || $case < 1} { 
	puts "Invalid case $case" 
   	exit
}
global flav, delay
set delay 0
switch $case {
	global delay
	1 {set delay "12.5ms"}
	2 {set delay "20ms"}
	3 {set delay "27.5ms"}
}
if {$flavor == "SACK"} {
	set flav "Sack1"
} elseif {$flavor == "VEGAS"} {
	set flav "Vegas"
} else {
	puts "Invalid TCP Flavor $flavor"
	exit
}

#        Initialization        
#===================================

set f1 [open out1.tr w]
set f2 [open out2.tr w]
#Create a ns simulator
set ns [new Simulator]
set file "out_$flavor$case"
#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile


set thruput1 0
set thruput2 0
set counter 0
 #===================================
#        Nodes Definition        
#===================================
#Create 6 nodes
set src1 [$ns node]
set src2 [$ns node]
set R1 [$ns node]
set R2 [$ns node]
set rcv1 [$ns node]
set rcv2 [$ns node]

#Define different colors for data flows
$ns color 1 Blue
$ns color 2 Red

#===================================
#        Agents Definition        
#===================================
#Setup a TCP connection
set tcp1 [new Agent/TCP/$flav]
set tcp2 [new Agent/TCP/$flav]
$ns attach-agent $src1 $tcp1
$ns attach-agent $src2 $tcp2

$tcp1 set class_ 1
$tcp2 set class_ 2


#===================================
#        Links Definition        
#===================================
#Createlinks between nodes
$ns duplex-link $R1 $R2 1.0Mb 5ms DropTail
$ns duplex-link $src1 $R1 10.0Mb 5ms DropTail  
$ns duplex-link $rcv1 $R2 10.0Mb 5ms DropTail  
$ns duplex-link $src2 $R1 10.0Mb $delay DropTail  
$ns duplex-link $rcv2 $R2 10.0Mb $delay DropTail  

#Give node position (for NAM)
$ns duplex-link-op $R1 $R2 orient right
$ns duplex-link-op $src1 $R1 orient right-down
$ns duplex-link-op $src2 $R1 orient right-up
$ns duplex-link-op $R2 $rcv1 orient right-up
$ns duplex-link-op $R2 $rcv2 orient right-down




#===================================
#        Applications Definition        
#===================================
#Setup a FTP Application over TCP connection
set ftp1 [new Application/FTP]
set ftp2 [new Application/FTP]



$ftp1 attach-agent $tcp1
$ftp2 attach-agent $tcp2



set sink1 [new Agent/TCPSink]
set sink2 [new Agent/TCPSink]
$ns attach-agent $rcv1 $sink1
$ns attach-agent $rcv2 $sink2

$ns connect $tcp1 $sink1
$ns connect $tcp2 $sink2



#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns nf tracefile namfile file thruput1 thruput2 counter
   # global f1
    $ns flush-trace
    #close $f1
    puts "Avg throughput for Src1=[expr $thruput1/$counter] MBits/sec\n"
	puts "Avg throughput for Src2=[expr $thruput2/$counter] MBits/sec\n"
    close $tracefile
    close $namfile
    exec nam out.nam &
    #exec xgraph out1.tr out2.tr-geometry 800x400 &
    exit 0
}

 proc record {} {
         global sink1 sink2 f1 f2 thruput1 thruput2 counter
         #Get an instance of the simulator
         set ns [Simulator instance]
         #Set the time after which the procedure should be called again
         set time 0.5
         #How many bytes have been received by the traffic sinks?
         set bw1 [$sink1 set bytes_]
         set bw2 [$sink2 set bytes_]
        
         #Get the current time
         set now [$ns now]
         #Calculate the bandwidth (in MBit/s) and write it to the files
         puts $f1 "$now [expr $bw1/$time*8/1000000]"
         puts $f2 "$now [expr $bw2/$time*8/1000000]"
         set thruput1 [expr $thruput1+ $bw1/$time*8/1000000 ]
         set thruput2 [expr $thruput2+ $bw2/$time*8/1000000 ]
         set counter [expr $counter + 1]


        #Reset the bytes_ values on the traffic sinks
        $sink1 set bytes_ 0
        $sink2 set bytes_ 0
        #Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}

$ns at 0 "record"
$ns at 0 "$ftp1 start"
$ns at 0 "$ftp2 start"
$ns at 400 "$ftp1 stop"
$ns at 400 "$ftp2 stop"
$ns at 400 "finish"
$ns color 1 Blue
$ns color 2 Red
set tf1 [open "$file-S1.tr" w]
$ns trace-queue  $src1  $R1  $tf1

set tf2 [open "$file-S2.tr" w]
$ns trace-queue  $src2  $R1  $tf2

$ns run



