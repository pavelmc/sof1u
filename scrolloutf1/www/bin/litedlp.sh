#!/bin/bash

exit 2;

#####################################################
# AUTHOR: MARIUS GOLOGAN (marius.gologan@gmail.com) #
#####################################################

# version 2 DRAFT - not (necessary) optimized

dlp=/tmp/LiteDLP$$;
expr=/var/www/expressions.cfg;
empty=


	. /var/www/security.cfg
	test $Lite_DLP_score = 10 && exit 2;
	test "$Lite_DLP_score" = "$empty" && exit 2;


####### prepare unique temp, working folder
test -d $dlp || mkdir $dlp;
test -f $expr || touch $expr;

####### alert
function alert() {

case "$ext" in
	avi|3gp|flv|mov|divx|qt|m[13][vu]|mp[veag0-9]|wm[avd]?|wa[xv]|midi?|r[mia]|a[si][xf][fc]?|au|snd|ivf|wmz|wvx|wpl	)

		output=`echo "$file_name.$ext" | tr "X" " "`
		echo "LiteDLP: $output TYPE FOUND" 1>&2;
	;;

	*)

		test "$from_internal" != "$empty" && (
		output=`echo "Score $score"`
		echo "LiteDLP: $output DATA FOUND" 1>&2;
		)
	;;
	esac
}



####### function images
function images() {
case $1 in
	jpg|jpeg|bmp|png|tif|tiff|gif|pbm|pgm   )
	tesseract "$path_file" $dlp/$file_name > /dev/null && rm -f "$path_file";
	;;
esac
}

####### function test archive and extract

function archive() {
case $1 in
	xlsx|docx|pptx|ppsx )
	cd $dlp
		unzip -o "$path_file" -d "$dlp/$file_name$$" > /dev/null && rm -f "$path_file";
		# && type "$ext";
	;;

	zip|7z|arj|gz|tar|wim|bzip2|gzip|xz|cab|rar|lha|lzh )
	cd $dlp
		7z e "$path_file" -y > /dev/null && rm -f "$path_file";
	;;

esac

}



####### function test file type and convert to text
function type() {

case $1 in

	pdf )
		### convert pdf to text
		pdftotext "$path_file" "$path_file.txt";

		### extract images from pdf
		pdfimages -p -q "$path_file" "$dlp/";
		rm -f "$path_file"

		image_files=`find $dlp -type f \( -o -name "*.pbm" -o -name "*.jpg" -o -name "*.tif" -o -name "*.gif" \)`;
		echo "$image_files" |\
			while read path_file
			do
				# get file name and extension
				 file=`echo "$path_file" | awk -F "/" '{print $NF}'`;
				 file_name=`echo "$file" | sed 's/^\(.*\)\.\([a-zA-Z0-9]\{2,5\}\)$/\1/'`;
				 ext=`echo "$file" | sed 's/.*\.\([a-zA-Z0-9]\{2,5\}\)$/\1/'`;

				# call functions depending on each extension
						case "$ext" in
							jpg|bmp|tif|tiff|png|gif|pbm|pgm|ppm						)
							images "$ext";
								rm -f "$image";
								rm -f "$path_file";
							;;
						esac
			done
		rm -f "$path_file"
	;;
	xls )
		xls2csv "$path_file" | sed 's/^"\|","\|",,"\|"$\|",,*"\|,"\|,,*\|",/ /g' | sed 's/  */ /g' > "$path_file.txt";
		rm -f "$path_file"
	;;
	doc )
		catdoc "$path_file" > "$path_file.txt";
		rm -f "$path_file"
	;;
	pp[st] )
		ppthtml "$path_file" > "$path_file.txt";
		rm -f "$path_file"
	;;
	avi|3gp|flv|mov|divx|qt|m[13][vu]|mp[veag0-9]|wm[avd]?|wa[xv]|midi?|r[mia]|a[si][xf][fc]?|au|snd|ivf|wmz|wvx|wpl	)
	test $Header_and_attachments_filter -le 4 && alert;
	rm -f "$path_file"
	;;
	esac
}


####### lookup for keywords
function lookup() {

		exp_found=`fgrep -Foriwasm$Lite_DLP_score -f "$expr" "$dlp" --include=*.xml --include=*.txt --include=*.msg --include=*.fpage |\
		grep -v "^$" | awk -F "/" '{print $NF}' | sed 's/.txt//g'`
		details=`echo "$exp_found" | sort | uniq -c`
		score=`echo "$exp_found" | wc -l`

		test $score -gt $Lite_DLP_score && alert && printf "\n`echo "$details" | tr "X" " "`\nScore = $score\n";

}


function from_net() {
	# Load some values

	. /var/www/traffic.cfg

		my_domains=`echo "${domain[*]}" | tr " " "|"`
		from=`awk "/^Received:/,/^$/" "$dlp/msg$$.msg" | grep -Em1 "^(Return-Path|Sender|From):"`
		from_internal=`echo "$from" | grep -iE "$my_domains"`

		# check for spam trapped email
		to=`awk "/^Received:/,/^$/" "$dlp/msg$$.msg" | grep -Em1 "^(To|Sender|From):"`


		test "$from_internal" = "$empty" && ( rm -fr $dlp && exit 0 );
}

# search engine for files and subfolders
function search() {

	file_list=`find $dlp -type f | grep -v "\.msg" | grep -v "^ $" | grep -v "^$" `;
	# echo "$file_list" >> /tmp/file_list

	echo "$file_list" | grep -v "\.msg" |grep -v "^$" | grep -v "^ *$" |\
	while read path_file
	do
		# get file name and extension
		 file=`echo "$path_file" | awk -F "/" '{print $NF}'`;
		 file_name=`echo "$file" | sed 's/^\(.*\)\.\([a-zA-Z0-9]\{2,5\}\)$/\1/'`;
		 ext=`echo "$file" | sed 's/.*\.\([a-zA-Z0-9]\{2,5\}\)$/\1/'`;

		# call functions depending on each extension

	file_type=`file "$path_file"`;
	# echo "$file_type" >> /tmp/file_type;

# detect archives
	echo "$file_type" | grep " Microsoft Excel 20" > /dev/null && (ext="xlsx" && archive "$ext");
	echo "$file_type" | grep " Microsoft Word 20" > /dev/null  && (ext="docx" && archive "$ext");
	echo "$file_type" | grep " Zip archive data" > /dev/null  && (ext="zip" && archive "$ext");
	echo "$file_type" | grep " gzip compressed data" > /dev/null  && (ext="gz" && archive "$ext");
	echo "$file_type" | grep " 7-zip archive data" > /dev/null  && (ext="7z" && archive "$ext");
	echo "$file_type" | grep " tar archive" > /dev/null  && (ext="tar" && archive "$ext");
	echo "$file_type" | grep " LHa " > /dev/null  && (ext="lha" && archive "$ext");

# detect documents
	echo "$file_type" | grep "Composite Document File V2 Document" > /dev/null  && (ext="xls" && type "$ext" );
	echo "$file_type" | grep " Microsoft Excel, " > /dev/null && (ext="xls" && type "$ext" );
	echo "$file_type" | grep " Microsoft Office Word, " > /dev/null  && (ext="doc" && type "$ext" );
	echo "$file_type" | grep " PDF document, " > /dev/null  && (ext="pdf" && type "$ext" );
	echo "$file_type" | grep " Microsoft Office PowerPoint" > /dev/null  && (ext="ppt" && type "$ext" );

# detect images
	echo "$file_type" | grep "TIFF image data" > /dev/null  && (ext="tif" && images "$ext" );
	echo "$file_type" | grep "JPEG image data" > /dev/null  && (ext="jpg" && images "$ext" );
	echo "$file_type" | grep "PNG image data" > /dev/null  && (ext="png" && images "$ext" );
	echo "$file_type" | grep "GIF image data" > /dev/null  && (ext="gif" && images "$ext" );
#	echo "$file_type" | grep "Windows Enhanced Metafile" > /dev/null  && (ext="emf" && images "$ext" );
#	echo "$file_type" | grep "Netpbm PBM " > /dev/null  && (ext="pbm" && images "$ext" );
#	echo "$file_type" | grep "Netpbm PPM " > /dev/null  && (ext="ppm" && images "$ext" );
#	echo "$file_type" | grep "Netpbm PGM " > /dev/null  && (ext="pgm" && images "$ext" );

# detect audio
	echo "$file_type" | grep " Audio file with ID3 version " > /dev/null  && (ext="mp3" && type "$ext" );
	echo "$file_type" | grep " MPEG .*kbps" > /dev/null  && (ext="mp3" && type "$ext" );
	echo "$file_type" | grep " WAVE audio" > /dev/null  && (ext="wav" && type "$ext" );

# detect video
	echo "$file_type" | grep " 3GPP" > /dev/null  && (ext="3gp" && type "$ext" );
	echo "$file_type" | grep " MPEG v4 system" > /dev/null  && (ext="mp4" && type "$ext" );
	echo "$file_type" | grep " Macromedia Flash Video" > /dev/null  && (ext="flv" && type "$ext" );
	echo "$file_type" | grep " data, AVI, " > /dev/null  && (ext="avi" && type "$ext" );

	done

}



####### SCAN
case $1 in
scan)
	### see if the email comes from internal or external network

	# extract all attachments from all email files
		munpack -q $2/* -C $dlp > /dev/null 2>&1
		awk '/^Received:/,/\tname=|attachment|filename=/' "$2/../email.txt" > "$dlp/msg$$.msg" # >/dev/null 2>&1

		from_net $1 $2;
		search $1 $2;
		search $1 $2;
		search $1 $2;
		lookup;
;;
esac

####### exit 2 is expected by amavis

# done with the uniquie temp folder
rm -fr $dlp;

exit 2;
