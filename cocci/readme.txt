1. Introduction of the script files.
 In /cocci directory, there are six script files and two subdirectory that are important to know (ignore the rest):
 (1)/testdir: A directory that stors the files that are to parsed. Any file in this directoy or subdirectoy will be parsed.
 (2)startcocci_linux.sh: Shellscript to start the parsing. This script will clearn the files that are left from the last parsing and invoke the right cocci script(pattern_match_linux.cocci) to parse the source files. This one is specifc for Linux and Android source code.
 (3)startcocci_freebsd.sh: Shellscript of starting the parsing. This script will clearn the files that are left from the last parsing and invoke the right cocci script(pattern_match_fressbsd.cocci) to parse the source files. This one is specifc for FreeBSD source code.
 (4)pattern_match_linux.cocci: Coccinelle script file that stores the rules we added for the pattern matching. This one is specific for Linux and Android, because they use the same transfer functions.
 (5)pattern_match_FreeBSD.cocci: Coccinelle script file that stores the rules we added for the pattern matching. This one is specific for FreeBSD, because it uses different transfer functions.
 (4)copy_files.py: Python script that helps to copy the suspicious souce code files to a specifc subdirectory, so as to facilitate the manual analysis.
 (5)/outcome: This directory will be created after parsing, and suspicous source files will be copied here for manual analysis.
 (6)resut.txt: This file will be created after parsing, reports and statistical data will be stored in this file.

2. How to use.
(1) Install Coccinelle on the machine.
  Mac OS:  “brew install coccinelle”
  Ubuntu:  “apt-get install coccinelle”
(2) Copy the files that are to be parsed to /testdir
(3) Run “./startcocci_linux.sh”  for Linux or Android parsing
    Run “./startcocci_freebsd.sh”  for FreeBSD parsing 
(4) Check the result from result.txt
(5) See the corresponding source files from /outcome