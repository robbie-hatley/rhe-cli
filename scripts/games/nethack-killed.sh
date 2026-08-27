grep 'killed' '/var/games/nethack/logfile' | awk -F killed '{print"killed"$NF}' | sort | uniq
