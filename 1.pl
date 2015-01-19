#!/usr/local/bin/perl
$file = 'cmd.txt';
open(INFO,$file)||die"$!";
@lines=<INFO>;
close(INFO);
$file1 = 'SRAM.vec';
open(OUT,">$file1");
#print the head of .vec file
print OUT "radix 2 4 2 4 4 4 4 4 4 4 4 4 1 1 1 1 1 1 1\n";
print OUT "io  i  i  i  i  i  i  i  i  i  i  i  i  i  i  i  i  i  i  i\n";
print OUT "vname A[5:4] A[3:0] ~A[5:4] ~A[3:0] data[15:12] data[11:8] data[7:4] data[3:0] ~data[15:12] ~data[11:8] ~data[7:4] ~data[3:0]  read_en write_en   precharge_en WL_en  clk  clk_bar reset  \n";
print OUT "slope 0.01\nvih 1.8\ntunit ns\n";
#let's read this cmd file~~
$time=0;
foreach $row (@lines)
{
chomp $row;
@row_elements=split(/\s+/,$row);
 if ($row_elements[1]=~/H/)                                       #address
 { chop($row_elements[1]);}
 else                                                             #if find a binary address
 {$row_elements[1]=sprintf("%X", oct( "0b$row_elements[1]"));}    #convert it to hex
 $errorCMD=0;                                                     #burst length?
 $bl=0;                                                           #give $bl an error000 value first, if no modify $bl, we can report error000
 $No_of_row_elements=@row_elements;
 if(($row_elements[2]=~"#")||($No_of_row_elements==2))
 {$bl=1;}
 if (($row_elements[2]==2)||($row_elements[2]==4)||($row_elements[2]==1))
 {$bl=$row_elements[2];}
  if ($bl==0)                                                      #if bl is not 1 2 4
 {print"Error000: Command $row has invalid burst length.\n";
 $errorCMD=1;}
   if(((($bl==2)&($No_of_row_elements!=5))||(($bl==4)&($No_of_row_elements!=7)))&($row_elements[0]eq"STORE"))
 {print"Error001: Command $row doesn’t provide sufficient data.\n";
 $errorCMD=1;}
  $addr=hex($row_elements[1]);
 if((($bl==2)&($addr%2!=0))||(($bl==4)&($addr%4!=0)))
 {$errorCMD=1;
 print"Error002: Command $row is not aligned properly.\n";}
 ########## $errorCMD=0;
 #finish reading this row, now let's go on output to .vec file
 $count=0;
  while(($count<$bl)&($errorCMD==0))
  {
   $addr=sprintf("%X", hex($row_elements[1])+$count);
   if(length($addr)==1)
   {$addr="0".$addr;}                         #add 0 before address
   @address=split(//,$addr);
   $addr_bar=sprintf("%X",255-hex($addr));    #get addr_bar
   @address_bar=split(//,$addr_bar);
   $geshu=$No_of_row_elements-$bl+$count;
   $data=substr($row_elements[$geshu],1); #knock off # sign
   @data=split(//,$data);                 #add space sign
   $data_bar=sprintf("%X",65535-hex($data));  #get data_bar
   @data_bar=split(//,$data_bar);                             #add space sign
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

}
print OUT "$time   @address @address_bar 0 0 0 0 F F F F 0 0 0 0 0 1 1;last line to create a negtive edge for clk\n";
