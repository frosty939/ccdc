#!/bin/bash

https://askubuntu.com/questions/275965/how-to-list-all-variables-names-and-their-current-values
# view environment variables
	env
	<OR>
	printenv

# view shell variables
	( set -o posix ; set ) | less
		# the () follows similar rules to math.
		#completes the part in the () before piping to less
