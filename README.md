# SRAM_Part2

### Part A
For the detail of the code, please refer to the commends in [1.pl] ()
The main output part is as follows:
```Perl
   if($row_elements[0]eq"STORE")
   {
   print OUT  "$time   @address @address_bar @data @data_bar 1 0 0 0 1 0 1;STORE $addr $row_elements[$geshu]\n";
   $time=$time+4.5;   #time for precharge
   print OUT  "$time   @address @address_bar @data @data_bar 1 1 1 1 1 0 1;STORE $addr $row_elements[$geshu]\n";
   $time=$time+3;     #time for writing
   print OUT  "$time   @address @address_bar @data @data_bar 1 1 1 0 1 0 1;STORE $addr $row_elements[$geshu]\n";
   $time=$time+1;   #time for the WL to fully return to 0, so that we can precharge again.
   }
   else
   {
   print OUT "$time   @address @address_bar 0 0 0 0 F F F F 0 0 0 0 0 1 1;LOAD $addr R1\n";
   $time=$time+4.5;  #time for precharging through to the out and ~out
   print OUT "$time   @address @address_bar 0 0 0 0 F F F F 0 0 1 1 1 0 1;LOAD $addr R1\n";
   $time=$time+1;  #time for reading, let the value in cell discharge BL or ~BL by delta V.
   print OUT "$time   @address @address_bar 0 0 0 0 F F F F 0 0 1 0 1 0 1;LOAD $addr R1\n";
   $time=$time+1;    #time for the WL to fully return to 0, so that we can precharge again.
   print OUT "$time   @address @address_bar 0 0 0 0 F F F F 1 0 0 0 1 0 1;LOAD $addr R1\n";
   $time=$time+2;   }#time for sensing and latching whilte precharging at the same time but only for BL and ~BL, not gonna reach out and ~out.
 $count=$count+1;
 }
```

As you can see, every store operation needs 3 stages, while every load operation needs 4.<br />

Using this perl script, I generate the vector file: [SRAM.vec](in the attachment)
Then I run the simulation with this .vec file:
This is the output waveform:
![image] (https://dl.dropboxusercontent.com/s/q4kg9ns9enu3qil/image1.png?dl=0)
