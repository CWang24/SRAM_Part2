#!/usr/local/bin/perl
$file = 'cmd.txt';
open(INFO,$file)||die"$!";
@lines=<INFO>;
close(INFO);
foreach $row (@lines)
{
chomp $row;
@row_elements=split(/\s+/,$row);
 if ($row_elements[1]=~/H/)                                       #address
 {chop($row_elements[1]);}
 else                                                             #if find a binary address
 {$row_elements[1]=sprintf("%X", oct( "0b$row_elements[1]"));}    #convert it to hex
 $bl=0;                                                           #give $bl an error000 value first, if no modify $bl, we can report error000
 $No_of_row_elements=@row_elements;
 if(($row_elements[2]=~"#")||($No_of_row_elements==2))
 {$bl=1;}
 if (($row_elements[2]==2)||($row_elements[2]==4)||($row_elements[2]==1))
 {$bl=$row_elements[2];}
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
   $data=substr($row_elements[$geshu],1); #knock off # sign
   push @stores,$addr,$data; #I create @stores to put all the info of every store instruction with the format: addr1,data1,addr2,data2...
   }
   else
   {push @loads,$addr;} #I create @stores to put all the info of every store instruction with the format: addr1,addr2...
 $count=$count+1;
 }
}
print "These are the info of previous store operations: @stores\n";
print "These are the info of previous load operations: @loads\n";
$file = 'final.csv';
open(CURVE,$file)||die"$!";
@data_lines=<CURVE>;
close(CURVE);
#print @data_lines;
$load_order=0;       #since the .csv file does not include the info of load addr, i have to recall the @loads with this order number.
foreach $data_line (@data_lines)
{
chomp $data_line;
if ($data_line=~/Q/)
{@value_name=split(/,/,$data_line);} #get the time from the first line
else
{
print"This is the load operation No. $load_order \n";
@data_line_elements=split(/,/,$data_line);
print "At time: $data_line_elements[0]s, \n";
@data_get=0; #use this to store the 1bits, for future convertion to HEX
$countt=1;
while ($countt<=31)
{
 print "$value_name[$countt]  voltage is : $data_line_elements[$countt]V, ";
 if ($data_line_elements[$countt]>0.9)      #so it's logic high
 { print " logic 1; \n";
   push @data_get,'1';
 }
 else
 { print " logic 0; \n";
   push @data_get,'0';
 }
$countt=$countt+2;
}
$real_data=join('',@data_get);   #converte @ to $, for the convenience of binary to hex convertion
print "The 16bits data we get is: $real_data, ";
$real_data=sprintf("%X", oct( "0b$real_data"));      #go on converte it to hex for the convenience of comparing
print "convert to hex is $real_data.\n";
print"Since we are loading from $loads[$load_order-1], ";
 $flag=0;
 $store_order=0;
 $No_stores=@stores;     #sequence in @stores
 $counttt=0;
 while($counttt<=$No_stores)
 {
  if($loads[$load_order-1] eq $stores[$counttt])  #to find a matching of address
  {
   if($real_data == $stores[$counttt+1])    #conparing the data
   {
   $flag=1;
   print "the data stores at address $loads[$load_order-1] is CORRECT.\nIt should be $stores[$counttt+1], and it is $real_data actually.\n \n";
   }
   else
   {
   $error_addr=$counttt+1;
   }
  }
  $counttt=$counttt+2;
 }
 if($flag==0)
 {print "the data stores at address $loads[$load_order-1] is WRONG.\nIt should be $stores[$error_addr], but it is $real_data actually.\n \n";}
}
$load_order=$load_order+1;
}
