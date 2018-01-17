#This shell script runs the program that parses out
#what music I played in a  given month, as captrured by iTunes. See format below
#SHIT THAT STILL NEEDS TO BE DONE:
#Create a program to update the music played index.
#Automate the process of getting iTunes file to the server

MonthPrep=$(date +"%m")

Month=`expr $MonthPrep - 1`

Year=$(date +"%Y")

perl /var/www/Data/Music/code/iTunesPlayListing/iTunesPlayListing.pl $Month $Year

