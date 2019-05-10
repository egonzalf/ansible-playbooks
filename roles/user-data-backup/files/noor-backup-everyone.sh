#!/bin/bash

##############################################################################
## NOOR backup for every user under /home/
## will exclude listed files and files bigger than 50mb
## This is meant to be run as root
##############################################################################

MAXSIZE="1.2G"
# get the local machine name
hostname=$(hostname -s)

# Exclude pattern for rsync
excludelist=/tmp/.noor-exclude.list
cat > $excludelist << EOF
*.o
*.cu_o
#.svn/
#.git/
#*.so
#*.a
#*.la
*.pyo
#*.pyc
# Asuming user is doing backup on his/her own.
.ssh/
/noor-backup/
EOF

DSTHOST="dm.kaust.edu.sa"
remotepath="/datawaha/ecrc/gonzalea/ALLECRC/$hostname"

# lower priority
renice -n 5 -p $$ || true

for userdir in `find /home/ -maxdepth 1 -type d `; do
	# get username and check uid
	username=$(basename $userdir)
	id=$(id -u $username 2>/dev/null )
	[ -n "$id" ] && [ $id -gt 100000 ] || continue;

	#TODO: backup only recent files
	#find /path/to/dir -mtime -366 > /tmp/rsyncfiles # files younger than 1 year
	#rsync -Ravh --files-from=/tmp/rsyncfiles / root@www.someserver.com:/root/backup

	last=`lastlog -u $username -t 180` # did she/he connect in last 180 days
	if [ "a$last" == "a" ]; then
		# no 
		echo "User [$username] has not connected in last 180 days"
		continue
	fi


	# Check if user can connect passworless.
	# This indicates that a personal back must be working.No need for this
	if sudo -u $username ssh -o "NumberOfPasswordPrompts 0" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $DSTHOST ls /rcsdata/ecrc/$username/$hostname 1>&2 2>/dev/null
	then
		echo "User [$username] must be doing backup."
		continue
	fi

	echo "Backing up User [$username]."
	# create remote directory, just in case
	ssh -i /home/gonzalea/.ssh/id_rsa -o "NumberOfPasswordPrompts 0" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no gonzalea@$DSTHOST "mkdir -p $remotepath/$username"

	# ionice to avoid stressing the system (best-effort)
	# use delete-delay because is more efficient than delete-after
	ionice -c 2 -n 6 -t rsync -e 'ssh -i /home/gonzalea/.ssh/id_rsa -o "NumberOfPasswordPrompts 0" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' -az -vv --exclude-from=$excludelist --delete-delay --delete-excluded --max-size=$MAXSIZE $userdir/ gonzalea@$DSTHOST:$remotepath/$username || continue;

	sleep 5
done
