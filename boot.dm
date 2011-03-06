var/const
	BOOT_STATE_BOOT = 1
	BOOT_STATE_INIT = 2
	BOOT_STATE_RUNNING = 3
	BOOT_STATE_HALTING = 4

boot
	var
		__bootparams
		__state
		list/__services = new()
		datum/__logger

		dieOnCrit = FALSE
		dieOnWarn = FALSE

	proc/setLogger(datum/D)
		if(!hascall(D, "logMsg")) return
		__logger = D
		logMsg("Logger set to [D](\ref[D])")

	proc/logMsg(n)
		if(__logger)
			__logger:logMsg(n)
		else
			world.log << n

	proc/getServices()

	proc/getState()
		return __state

	proc/setState(n)
		if(n == BOOT_STATE_BOOT)
			__boot()
		else if(n == BOOT_STATE_INIT)
			__init()
		else if(n == BOOT_STATE_RUNNING)
			__run()
		else if(n == BOOT_STATE_HALTING)
			__halt()

	proc/getService(n)
		for(var/service/S in __services)
			if(cmptext(n, S.name)) return S
		return null

	proc/handleCritical(service/S, serviceCritical/C)
		if(istype(C))
			logMsg("\[CRITICAL@[__state]\]: [C]")
		if(dieOnCrit)
			return 0
		else
			return !C.die

	proc/handleWarning(service/S, serviceWarning/W)
		if(istype(W))
			logMsg("\[WARNING@[__state]\]: [W]")
		if(dieOnWarn)
			return 0
		else
			return !W.die


	proc/forceHalt(m)
		logMsg("\[FORCEHALT@[__state]\]: [m]")
		del world

	proc/__serviceReturn(service/S, n)
		if(istype(n, /serviceCritical))
			. = handleCritical(S, n)
		else if(istype(n, /serviceWarning))
			. = handleWarning(S, n)
		else if(n != 1)
			var/serviceCritical/C = new("Non-compliant service [S]")
			. = handleCritical(S, C)
		else
			. = 1

		if(!.)
			forceHalt("Service halting world")

	proc/__boot()
		__state = BOOT_STATE_BOOT
		logMsg("---Booting up game---")
		for(var/tpath in getServices())
			var/realpath = text2path(tpath)
			var/service/S = new realpath(__bootparams)
			. = S.bootHook()
			__serviceReturn(S,.)
			__services += S
			logMsg("Service [S] booted")
		logMsg("---Done booting game---")
		setState(BOOT_STATE_INIT)

	proc/__init()
		__state = BOOT_STATE_INIT
		logMsg("---Initializing game---")
		for(var/service/S in __services)
			. = S.initHook(__bootparams)
			__serviceReturn(S,.)
		logMsg("---Done initializing game---")
		setState(BOOT_STATE_RUNNING)

	proc/__run()
		__state = BOOT_STATE_RUNNING
		logMsg("---Running game---")
		for(var/service/S in __services)
			. = S.runHook()
			__serviceReturn(S,.)

	proc/__halt(halt_method)
		__state = BOOT_STATE_HALTING
		logMsg("---Halting game---")
		for(var/service/S in __services)
			var/Sname = S.name
			. = S.haltHook(halt_method)
			__serviceReturn(S,.)
			logMsg("Service [Sname] halted")
		logMsg("---Done halting game---")
