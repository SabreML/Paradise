// Airlock painter

/obj/item/painter/airlock
	name = "airlock painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on a completed airlock to change its paintjob."
	icon_state = "airlock_painter"
	var/paint_setting

	// All the different paint jobs that an airlock painter can apply.
	// If the airlock you're using it on is glass, the new paint job will also be glass
	var/list/available_paint_jobs = list(
		"Atmospherics" = /obj/machinery/door/airlock/atmos,
		"Command" = /obj/machinery/door/airlock/command,
		"Engineering" = /obj/machinery/door/airlock/engineering,
		"External" = /obj/machinery/door/airlock/external,
		"External Maintenance"= /obj/machinery/door/airlock/maintenance/external,
		"Freezer" = /obj/machinery/door/airlock/freezer,
		"Maintenance" = /obj/machinery/door/airlock/maintenance,
		"Medical" = /obj/machinery/door/airlock/medical,
		"Mining" = /obj/machinery/door/airlock/mining,
		"Public" = /obj/machinery/door/airlock/public,
		"Research" = /obj/machinery/door/airlock/research,
		"Science" = /obj/machinery/door/airlock/science,
		"Security" = /obj/machinery/door/airlock/security,
		"Standard" = /obj/machinery/door/airlock)

/obj/item/painter/airlock/afterattack(atom/target, mob/user, proximity, params)
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		A.change_paintjob(src, user)

/obj/item/painter/airlock/attack_self(mob/user)
	paint_setting = input(user, "Please select a paintjob.") as null|anything in available_paint_jobs
	if(!paint_setting)
		return
	to_chat(user, "<span class='notice'>The [paint_setting] paint setting has been selected.</span>")
