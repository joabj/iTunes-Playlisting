#!/usr/bin/perl

#This program opens the iTunes music library file (which is an XML file), 
#scans the contents
#and prints out the name of each song that has been played at least once, 
#all in chronological order. 
#To run the file the command is "perl iTunesPlayListing.pl [00 MONTH] [0000 YEAR]"

#This is an incredibly stupid program, written way long ago. 
#It doesn't even parse the (crazy Apple) XML, rather it just 
#uses the verbose XML for brute force pattern recognition
#Then again, it is speedy, I'll give it that.

#Onto the code: This section opens the iTunes library and initializes some variables:

$SongNumber = 0;
$MonthCompare = 0;

#This is the interactive approach, disabled for now
#print "Full name of the file to parse?\n";
#print "(Must be in current directory, with no spaces)\n";
#$File = <STDIN>;
#print "Year to Start?\n";
#$YearStart = <STDIN>;
#chomp $YearStart;
#print "Year to Stop?\n";
#$YearStop = <STDIN>;
#chomp $YearStop;

#NOTE you must put this program where the Apple Music Library XML file is, or 
#put in the complete path below
$File = "iTunes Music Library.xml";
chomp $file;

$MonthStart = $ARGV[0];
chomp $MonthStart;

$YearStart = $ARGV[1];
chomp $YearStart;

#Date and time treatments
#This puts a name to the month. 
#Also it corrects the problem of rolling back to the previous year, for the job that runs in January 
#Also, adds the leading 0 for the name page

use Switch;

switch($MonthStart){
   case 0  {$MonthName = "December";
		    $YearStart = $YearStart - 1;
			$MonthStart = 12;}	
   case 1  { $MonthName = "January";
			 $MonthStart = 0 . $MonthStart;}
   case 2  { $MonthName = "February";
			 $MonthStart = 0 . $MonthStart;}
   case 3  { $MonthName = "March";
			 $MonthStart = 0 . $MonthStart;}
   case 4  { $MonthName = "April";
			 $MonthStart = 0 . $MonthStart;}
   case 5  { $MonthName = "May";
			 $MonthStart = 0 . $MonthStart;}
   case 6  { $MonthName = "June";
			 $MonthStart = 0 . $MonthStart;}
   case 7  { $MonthName = "July";
			 $MonthStart = 0 . $MonthStart;}
   case 8  { $MonthName = "August";
			 $MonthStart = 0 . $MonthStart;}
   case 9  { $MonthName = "September";
			 $MonthStart = 0 . $MonthStart;}
   case 10 { $MonthName = "October"}
   case 11 { $MonthName = "November"}
   case 12 { $MonthName = "December"}
   else    { print "Not Properly Fornmed\n";
			exit;}
}


print "$MonthStart $YearStart from $File ...\n"; 

open (FILE, "/var/www/Data/Music/iTunes/$File");

#The program goes through the iTunes Library file line-by-line. If the line contains the name of the song
#artist, album, date played or UTC date played, it grabs the line, regex outs the XML markup and all the 
#Mac/DOS encodings, and saves as the info as a variable. 

while (<FILE>) {
	chomp;
		if (/Name</) {

#Converts line from Mac to Unix format:
			$prep = s/\r/\n/g;
#Converts line from DOS to Unix format
			$prep = s/\r$//g;
#Removes excess tabs
			$prep = s/\t//g;
			$prep = s/<key>Name<\/key><string>//;
			$prep = s/<\/string>//;
			$Song = "$_";
					}

		elsif (/>Artist</){
			$prep = s/\r/\n/g;
			$prep = s/\r$//g;
			$prep = s/\t//g;
			$prep = s/<key>Artist<\/key><string>//;
			$prep = s/<\/string>//;
			$Artist = "$_";
					}

		elsif (/Album</){
			$prep = s/\r/\n/g;
			$prep = s/\r$//g;
			$prep = s/\t//g;
			$prep = s/<key>Album<\/key><string>//;
			$prep = s/<\/string>//;
			$Album = "$_";
				}

		elsif (/Play Date</){
			$prep = s/\r/\n/g;
			$prep = s/\r$//g;
			$prep = s/\t//g;
			$prep = s/<key>Play Date<\/key><integer>//;
			$prep = s/<\/integer>//;
			$Play_Date_Number = "$_";
				}

#This is where the magic happens..... 
#Note here that only if the song was actually played does iTunes give it a UTC "date played" stamp.
#So only if this program finds this tag, does it save the info from the last rounds of the search (artist, name, album, 
#etc) as a single song entry, in a multidimensional array of songs. iTunes saves info about each song in the exact same 
#order. So we know that artist, album, etc. will preceed the date played. If the song isn't played then this info will get
#replaced by info on the next song as the while loop continues through the XML file. 

		elsif (/UTC</){
			$prep = s/\r/\n/g;
			$prep = s/\r$//g;
			$prep = s/\t//g;
			$prep = s/<key>Play Date UTC<\/key><date>//;
			$prep = s/<\/date>//;
			$prep = s/T/ /;
			$prep = s/Z/ /;
			$Play_Date = "$_";


#This part breaks the date into numeric bits (month and year now only) can do day as the third element of the array.
			$prep = s/[0-9][0-9]:[0-0][0-9]:[0-9][0-9]//;
			@date = split /-/, $_;
			$year = $date[0];
			$month = $date[1];

#This checks to see if the song was played within the period registered, then
#prints it if it does...

			if (($year == $YearStart) && ($month == $MonthStart)) {


#All the song names, along with their artist, album, last play-time etc. is stored in a multidimensional array.....


			$InfoBit = 0;

			$song[$SongNumber][$InfoBit] = "$Play_Date_Number";			
			$InfoBit++;

			$song[$SongNumber][$InfoBit] = "$Play_Date";
			$InfoBit++;

			$song[$SongNumber][$InfoBit] =  "$Song";
			$InfoBit++;

			$song[$SongNumber][$InfoBit] = "$Artist";
			$InfoBit++;

			$song[$SongNumber][$InfoBit] = "$Album";
				$SongNumber++
									
								}
				}
	}


#Done with the XML file....

close FILE;



$TotalSongs = $#song;

#Now time to sort the the array in chronological older, oldest to newest....

@sortedsongs = sort {$a->[0] <=> $b->[0] } @song;

$marker = 0;

#Print the results out on a Web page, using the HTML table format....
#Open File


$FileName = "$YearStart-$MonthStart.html";
open(my $fw, '>', "[PATH]$FileName");

#print "Content-type: text/html\n\n";
		#preceeding line only needed if this programs runs under cgi
#NOTE: if some one else actually is foolish enough to try running this program, 
#they should at least replace my info with their own
print $fw "<!doctype html>\n<head>\n<Title>Music Played, $MonthName $YearStart<\/Title>\n";
print $fw "<meta description=\"Music I listened to in $MonthName $YearStart\"></meta>\n";
print $fw "<meta charset=utf-8>\n";
print $fw "<meta property=\"og:title\" content=\"Music Played, $MonthName $YearStart\" \/>\n";
print $fw "<meta property=\"og:site_name\" content=\"Joab Jackson, Web site\"\/>\n";
print $fw "<meta property=\"og:url\" content=\"http:\/\/www.joabj.com\/Data\/Music\/$FileName\" \/>\n";
print $fw "<meta property=\"og:image\" content=\"http:\/\/joabj.com\/Photos\/2012\/1209-SA-Bushwick-Jukebox.jpg\" \/>\n";
print $fw "<meta property=\"og:description\" content=\"Music Joab Jackson listened in to in $MonthName $YearStart\" \/>\n";
print $fw "<meta property=\"og:type\" content=\"List\" \/>\n";
print $fw "<meta property=\"og:locale\" content=\"en_US\" \/>\n";
print $fw "<meta property=\"article:author\" content=\"Joab Jackson\" \/>\n";	
print $fw "<link rel=\"shortcut icon\" href=\"\/Favicon.ico\" \/><!--For IE-->\n";	
print $fw "<style rel=\"stylesheet\" type=\"text\/css\">\n";
print $fw "\@import url(\/SiteStyle\/Index.css);\n";
print $fw "\@import url(\/SiteStyle/\Story.css);\n";
print $fw "\@import url(\/SiteStyle\/Table.css);\n";
print $fw  "<\/style>\n<\/head>\n<body>\n";

print $fw "<!--#include virtual=\"\/SiteStyle\/Header.txt\"-->\n";
print $fw "<!--#include virtual=\"\/SiteStyle\/Banner.txt\"-->\n";
print $fw "<h2><a href=\/Data\/Music>Music<\/a></h2>\n";			
print $fw "<p class=\"section-subhed\">Data<\/p>\n";
print $fw "<\/div>\n";
print $fw "<div id=item>\n";
print $fw "<link href=\'http:\/\/fonts.googleapis.com\/css?family=Fenix\' rel=\'stylesheet\' type=\'text\/css\'>\n";
print $fw "<hed>What I listened to<\/hed>\n";
print $fw "<p class=\"date\">$MonthName $YearStart<\/p>\n";
print $fw "<center>\n";
print $fw "<table ID=TableMain>\n";
print $fw "<tr><th>TIME:<\/th><th>SONG:<\/th><th>ARTIST:<\/th><th>ALBUM:<\/th><\/tr>\n";

for ($i=0; $i <= $TotalSongs; $i++) {

print $fw "<tr><td id=TableMain>$sortedsongs[$marker][1] <\/td><td id=TableMain>$sortedsongs[$marker][2] ";
print $fw "<\/td><td id=TableMain>$sortedsongs[$marker][3] <\/td><td id=TableMain>$sortedsongs[$marker][4] <\/td><\/tr>\n";

$marker++;
}

print $fw "	<\/table>\n";
print $fw "	<br>\n";
print $fw "	<table id=TableMain><tr><th>Total number of songs played in $MonthName $YearStart:<\/th><\/tr><tr><td id=TableMain>$TotalSongs<\/td><\/table>\n";
print $fw "	<\/center><\/article><\/div>\n";
print $fw "	<br>	<img id=ImageCenter src=\/Tilde-Color.jpg  height=27 width=60><\/p>\n"; 
print $fw "	<center><h2><a href=\/Data\/Music>Back<\/a>\</h2><\/center><br>\n";
print $fw "<!--#include virtual=\"/SiteStyle\/Footer.txt\"-->\n";
print $fw "	<\/body>\n";
print $fw "	<\/html>\n";

close $fh;

#This part appends the directory listing
print "Appending PlayListing index file...\n"; 

open(my $fd, ">>/var/www/Data/Music/PlayListings.txt");
print $fd "<li><a href=\/Data\/Music\/PlayListing\/$FileName>$YearStart, $MonthName<\/a><\/li>\n";
close $fd;

















