boot/getServices()
	return list("/service/cool", "/service/other")

world/New()
	fdel("some_file.log")
	log = file("some_file.log")
	mud = new()
	mud.setState(BOOT_STATE_BOOT)

var/boot/mud

proc/blockUntilRunning(client/C)
	while(!mud || mud.getState() != BOOT_STATE_RUNNING)
		sleep(1)
service
	cool
		name = "cool"
		bootHook()
			world.log << "[src].bootHook"
			return 1

		initHook()
			world.log << "[src].initHook"
			return new/serviceWarning("Danger will robinson, DANGER!")

		runHook()
			world.log << "[src].runHook"
			return 1

		haltHook()
			world.log << "[src].haltHook"
			return 1

	other
		name = "other"
		bootHook()
			world.log << "[src].bootHook"
			return new/serviceCritical("Something went wrong with the flux capacitor!")

		haltHook()
			world.log << "[src].haltHook"
			return 1

client/New()
	blockUntilRunning(src)

	src << "Game is now running!"

client/Command(T)
	mud.setState(BOOT_STATE_HALTING)
