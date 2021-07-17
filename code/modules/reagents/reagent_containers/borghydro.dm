#define BORGHYPO_REFILL_VALUE 5

/obj/item/reagent_containers/borghypo
	name = "Cyborg Hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/hypo.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	var/mode = 1
	var/charge_cost = 50
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in seconds)
	var/bypass_protection = 0 //If the hypospray can go through armor or thick material

	var/list/datum/reagents/reagent_list = list()
	var/list/reagents_types = list(/datum/reagent/medicine/salglu_solution, /datum/reagent/medicine/epinephrine, /datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/charcoal, /datum/reagent/medicine/hydrocodone)

/obj/item/reagent_containers/borghypo/surgeon
	reagents_types = list(/datum/reagent/medicine/styptic_powder, /datum/reagent/medicine/epinephrine, /datum/reagent/medicine/salbutamol)

/obj/item/reagent_containers/borghypo/crisis
	reagents_types = list(/datum/reagent/medicine/salglu_solution, /datum/reagent/medicine/epinephrine, /datum/reagent/medicine/sal_acid)

/obj/item/reagent_containers/borghypo/syndicate
	name = "syndicate cyborg hypospray"
	desc = "An experimental piece of Syndicate technology used to produce powerful restorative nanites used to very quickly restore injuries of all types. Also metabolizes potassium iodide, for radiation poisoning, and hydrocodone, for field surgery and pain relief."
	icon_state = "borghypo_s"
	charge_cost = 20
	recharge_time = 2
	reagents_types = list(/datum/reagent/medicine/syndicate_nanites, /datum/reagent/medicine/potass_iodide, /datum/reagent/medicine/hydrocodone)
	bypass_protection = 1

/obj/item/reagent_containers/borghypo/New()
	..()
	for(var/R in reagents_types)
		add_hypo_reagent(R)

	START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/reagent_containers/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
	charge_tick++
	if(charge_tick < recharge_time)
		return FALSE
	charge_tick = 0

	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell)
			var/datum/reagents/RG = reagent_list[mode]
			if(!refill_borghypo(RG, reagents_types[mode], R)) 	//If the storage is not full recharge reagents and drain power.
				for(var/i in 1 to reagent_list.len)     	//if active mode is full loop through the list and fill the first one that is not full
					RG = reagent_list[i]
					if(refill_borghypo(RG, reagents_types[i], R))
						break
	//update_icon()
	return TRUE

// Use this to add more chemicals for the borghypo to produce.
/obj/item/reagent_containers/borghypo/proc/add_hypo_reagent(reagent)
	reagents_types |= reagent
	var/datum/reagents/RG = new(30)
	RG.my_atom = src
	reagent_list += RG

	var/datum/reagents/R = reagent_list[reagent_list.len]
	R.add_reagent(reagent, 30)

/obj/item/reagent_containers/borghypo/proc/refill_borghypo(datum/reagents/RG, reagent, mob/living/silicon/robot/R)
	if(RG.total_volume < RG.maximum_volume)
		RG.add_reagent(reagent, BORGHYPO_REFILL_VALUE)
		R.cell.use(charge_cost)
		return TRUE
	return FALSE

/obj/item/reagent_containers/borghypo/attack(mob/living/carbon/human/M, mob/user)
	var/datum/reagents/R = reagent_list[mode]
	if(!R.total_volume)
		to_chat(user, "<span class='warning'>The injector is empty.</span>")
		return
	if(!istype(M))
		return
	if(R.total_volume && M.can_inject(user, TRUE, user.zone_selected, penetrate_thick = bypass_protection))
		to_chat(user, "<span class='notice'>You inject [M] with the injector.</span>")
		to_chat(M, "<span class='notice'>You feel a tiny prick!</span>")

		R.add_reagent(M) // TODO: Test
		if(M.reagents)
			var/datum/reagent/injected = GLOB.chemical_reagents_list[reagents_types[mode]]
			var/contained = injected.name
			var/trans = R.trans_to(M, amount_per_transfer_from_this)
			add_attack_logs(user, M, "Injected with [name] containing [contained], transfered [trans] units", injected.harmless ? ATKLOG_ALMOSTALL : null)
			to_chat(user, "<span class='notice'>[trans] units injected. [R.total_volume] units remaining.</span>")

/obj/item/reagent_containers/borghypo/attack_self(mob/user)
	playsound(loc, 'sound/effects/pop.ogg', 50, 0)		//Change the mode
	mode++
	if(mode > reagent_list.len)
		mode = 1

	charge_tick = 0 //Prevents wasted chems/cell charge if you're cycling through modes.
	var/datum/reagent/R = GLOB.chemical_reagents_list[reagents_types[mode]]
	to_chat(user, "<span class='notice'>Synthesizer is now producing '[R.name]'.</span>")
	return

/obj/item/reagent_containers/borghypo/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		var/empty = TRUE

		for(var/datum/reagents/RS in reagent_list)
			var/datum/reagent/R = locate() in RS.reagent_list
			if(R)
				. += "<span class='notice'>It currently has [R.volume] units of [R.name] stored.</span>"
				empty = FALSE

		if(empty)
			. += "<span class='notice'>It is currently empty. Allow some time for the internal syntheszier to produce more.</span>"

/obj/item/reagent_containers/borghypo/basic
	name = "Basic Medical Hypospray"
	desc = "A very basic medical hypospray, capable of providing simple medical treatment in emergencies."
	reagents_types = list(/datum/reagent/medicine/salglu_solution, /datum/reagent/medicine/epinephrine)

#undef BORGHYPO_REFILL_VALUE
