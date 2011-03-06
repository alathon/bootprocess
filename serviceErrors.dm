serviceError
	var/name
	var/die
	New(msg, die)
		if(msg) src.name = msg
		if(die) src.die = die
		else die = 0 // Don't die by defalt

serviceWarning
	parent_type = /serviceError

serviceCritical
	parent_type = /serviceError
