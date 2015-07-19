#-----------------------------------
#                       Shreya Patel
#                             131054
#-----------------------------------
#        Initialization        
#-----------------------------------
#Create a ns simulator(Lan simulation)
set ns [new Simulator]

#define color for data flows
$ns color 1 Red
$ns color 2 Blue
$ns color 3 Green

#Open the NS trace files
set tracefile1 [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile1

#Open the nam trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile

#-----------------------------------
#        Termination        
#-----------------------------------
#Define the finish procedure
proc finish {} {
    global ns tracefile1 namfile
    $ns flush-trace
    close $tracefile1
    close $namfile
    exec nam out.nam &
    exit 0
}

#-----------------------------------
#        Nodes Definition        
#-----------------------------------
#Create eleven nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]

#In same color nodes box shape for source node and round shape for receiver node
$n1 color Red
$n1 shape box
$n10 color Red

$n2 color Blue
$n2 shape box
$n7 color Blue

$n8 color Green
$n8 shape box
$n0 color Green

#-----------------------------------
#        Links Definition        
#-----------------------------------
#Createlinks between nodes
$ns duplex-link $n2 $n1 2.0Mb 50ms DropTail
$ns duplex-link $n1 $n0 2.0Mb 50ms DropTail
$ns duplex-link $n0 $n3 2.0Mb 50ms DropTail
$ns duplex-link $n3 $n2 2.0Mb 50ms DropTail
set lan [$ns newLan "$n2 $n9 $n4" 1.0Mb 100ms LL Queue/Drop Tail MAC/Csma/Cd Channel]
$ns duplex-link $n4 $n5 1.0Mb 70ms DropTail
$ns duplex-link $n4 $n6 1.0Mb 70ms DropTail
$ns duplex-link $n5 $n6 1.0Mb 70ms DropTail
$ns duplex-link $n6 $n7 2.0Mb 30ms DropTail
$ns duplex-link $n6 $n8 2.0Mb 30ms DropTail
$ns duplex-link $n9 $n10 2.0Mb 30ms DropTail

#Give node position (for nam)
$ns duplex-link-op $n2 $n1 orient left
$ns duplex-link-op $n1 $n0 orient up
$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n3 $n2 orient down
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n4 $n6 orient right-down
$ns duplex-link-op $n5 $n6 orient down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n9 $n10 orient right-down

#-----------------------------------
#        Agents Definition        
#-----------------------------------
#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp $null
$udp set fid_ 1

#Setup a TCP connection
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 2
$tcp set packet_size_ 552

#Setup a UDP1 connection
set udp1 [new Agent/UDP]
$ns attach-agent $n8 $udp1
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp1 $null
$udp1 set fid_ 3

#-----------------------------------
#        Applications Definition        
#-----------------------------------
#Setup a CBR Application over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate _ 0.01Mb
$cbr set random_ false

#Setup a FTP Application over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#Setup a CBR1 Application over UDP1 connection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate _ 0.01Mb
$cbr1 set random_ false

#-----------------------------------
#             Schedule
#-----------------------------------
#Scheduling the events
$ns at 0.1 "$cbr start"
$ns at 0.1 "$ftp start"
$ns at 0.1 "$cbr1 start"
$ns at 125.0 "$cbr1 stop"
$ns at 125.0 "$ftp stop"
$ns at 125.0 "$cbr stop"

#End the program
$ns at 125.0 "finish"

#Start the the simulation process
$ns run




