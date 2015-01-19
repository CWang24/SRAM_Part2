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
### Part B
I select the 16 output curves and export them to the file [final.csv] ().
Based on that, I wrote the [2.pl](). This 2.pl reads the original [cmd.txt]() first. Then record every store and load instruction with corresponding information. And save the result to @stores and @loads for future search and compare.
Then I read the [final.csv]() file. After reading each line, I do a search of address, then do the comparison to see whether the original data matches with the curve.
After running the 2.pl, you will see the following on the screen.

```
These are the previous store operations: 3E 01DF 1B D981 04 0000 05 0001 3C 0000 3D 0001 3E 0002 3F 0003
These are the previous load operations: 3E 1B 04 05 3C 3D 3E 3F
This is the 1 th load operation
At time: 8.100000000000001e-08s,
/Q15 Y  voltage is : 4.769173537690983e-08V,  logic 0;
/Q14 Y  voltage is : 4.499431426169047e-08V,  logic 0;
/Q13 Y  voltage is : 4.499763652345857e-08V,  logic 0;
/Q12 Y  voltage is : 4.499330422286358e-08V,  logic 0;
/Q11 Y  voltage is : 4.499734898606711e-08V,  logic 0;
/Q10 Y  voltage is : 4.49996779898771e-08V,  logic 0;
/Q9 Y  voltage is : 4.499964022576939e-08V,  logic 0;
/Q8 Y  voltage is : 4.498507223752111e-08V,  logic 0;
/Q7 Y  voltage is : 4.498568913752264e-08V,  logic 0;
/Q6 Y  voltage is : 4.498529899670549e-08V,  logic 0;
/Q5 Y  voltage is : 4.499601501038737e-08V,  logic 0;
/Q4 Y  voltage is : 4.498322587376798e-08V,  logic 0;
/Q3 Y  voltage is : 4.498312785523406e-08V,  logic 0;
/Q2 Y  voltage is : 4.498518690581983e-08V,  logic 0;
/Q1 Y  voltage is : 1.799999931154078V,  logic 1;
/Q0 Y  voltage is : 4.591569925471063e-08V,  logic 0;
The 16bits data we get is: 00000000000000010, convert to hex is 2.
Since we are loading from 3E, the data stores at address 3E is CORRECT.
 It should be 0002, and it is 2 actually.
This is the 2 th load operation
at time: 8.950000000000001e-08s,
/Q15 Y  voltage is : 1.799999940872926V,  logic 1;
/Q14 Y  voltage is : 1.79999994157321V,  logic 1;
/Q13 Y  voltage is : 2.70608968379603e-09V,  logic 0;
```
