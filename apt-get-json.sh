#!/bin/bash
apt-get upgrade -s -q | 
	sed -n -e  '
		# make label for kept back packages 
		s/\(.*kept.*\)/#kept-back/
		# make label for upgradeable packages
		s/\(.*be upgraded.*\)/#upgradeable/
		# remove all lines which are not labels or do not hold package names
		/\(#kept-back\|#upgradeable\|\s\{2\}\)/!d
		# for lines having package names (having 2 spaces in first position)
		/\s\{2\}/{
			# copy line to hold buffer
			h
			# switch buffers
			x
			# remove new line from buffer
			s/\n//
			# remove all two sequential empty spaces
			s/\s\{2\}//
			# put each word into a new line with two empty spaces in front
			s/\s\?\(\S*\)/  \1\n/g
			# print 
			p
		}
		# print line for all lines not holding package names
		/\s\{2\}/!p' | 
	sed -e '
		/^\s*$/d
		/^#/{
			# put label into holdspace
			h
			# delete to start another cycle
			d
		}
		# append package name into holdspace
		G
		# make json string from package name and package status
		s/^\s\s\(.*\)\n#\(.*\)/{\\"name\\":\\"\1\\",\\"status\\":\\"\2\\"}/' | 
		# replace all new line by ,
	tr  '\n' ',' | 
	sed '
		# make json array from line and wrap it into a json object
		s/\(.*\),/\1/' |
	xargs printf '{"packages": [%b]}'
