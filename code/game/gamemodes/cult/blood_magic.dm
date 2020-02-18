/datum/action/innate/blood_magic //Blood magic handles the creation of blood spells (formerly talismans)
	name = "Prepare Blood Magic"
	button_icon_state = "blood_magic_carve"
	background_icon_state = "bg_demon"
	desc = "Prepare blood magic by carving runes into your flesh. This is easier with an <b>empowering rune</b>."
	var/list/spells = list()
	var/channeling = FALSE

/datum/action/innate/blood_magic/Grant()
	..()
	button.screen_loc = DEFAULT_BLOODSPELLS
	button.moved = DEFAULT_BLOODSPELLS

/datum/action/innate/blood_magic/Remove()
	for(var/X in spells)
		qdel(X)
	..()

/datum/action/innate/blood_magic/IsAvailable()
	if(!iscultist(owner))
		return FALSE
	return ..()

/*
/datum/action/innate/blood_magic/proc/Positioning()
	var/list/screen_loc_split = splittext(button.screen_loc,",")
	var/list/screen_loc_X = splittext(screen_loc_split[1],":")
	var/list/screen_loc_Y = splittext(screen_loc_split[2],":")
	var/pix_X = text2num(screen_loc_X[2])
	for(var/datum/action/innate/blood_spell/B in spells)
		if(B.button.locked)
			var/order = pix_X+spells.Find(B)*31
			B.button.screen_loc = "[screen_loc_X[1]]:[order],[screen_loc_Y[1]]:[screen_loc_Y[2]]"
			B.button.moved = B.button.screen_loc
re-enable this to have the buttons start out above the inventory bar

*/

/datum/action/innate/blood_magic/Activate()
	var/rune = FALSE
	var/limit = RUNELESS_MAX_BLOODCHARGE
	for(var/obj/effect/rune/empower/R in range(1, owner))
		rune = TRUE
		break
	if(rune)
		limit = MAX_BLOODCHARGE
	if(spells.len >= limit)
		if(rune)
			to_chat(owner, "<span class='cultitalic'>You cannot store more than [MAX_BLOODCHARGE] spells. <b>Pick a spell to remove.</b></span>")
		else
			to_chat(owner, "<span class='cultitalic'><b><u>You cannot store more than [RUNELESS_MAX_BLOODCHARGE] spells without an empowering rune! Pick a spell to remove.</b></u></span>")
		var/nullify_spell = input(owner, "Choose a spell to remove.", "Current Spells") as null|anything in spells
		if(nullify_spell)
			qdel(nullify_spell)
		return
	var/entered_spell_name
	var/datum/action/innate/blood_spell/BS
	var/list/possible_spells = list()
	for(var/I in subtypesof(/datum/action/innate/blood_spell))
		var/datum/action/innate/blood_spell/J = I
		var/cult_name = initial(J.name)
		possible_spells[cult_name] = J
	possible_spells += "(REMOVE SPELL)"
	entered_spell_name = input(owner, "Pick a blood spell to prepare...", "Spell Choices") as null|anything in possible_spells
	if(entered_spell_name == "(REMOVE SPELL)")
		var/nullify_spell = input(owner, "Choose a spell to remove.", "Current Spells") as null|anything in spells
		if(nullify_spell)
			qdel(nullify_spell)
		return
	BS = possible_spells[entered_spell_name]
	if(QDELETED(src) || owner.incapacitated() || !BS || (rune && !(locate(/obj/effect/rune/empower) in range(1, owner))) || (spells.len >= limit))
		return
	to_chat(owner,"<span class='warning'>You begin to carve unnatural symbols into your flesh!</span>")
	SEND_SOUND(owner, sound('sound/weapons/slice.ogg',0,1,10))
	if(!channeling)
		channeling = TRUE
	else
		to_chat(owner, "<span class='cultitalic'>You are already invoking blood magic!</span>")
		return
	if(do_after(owner, 100 - rune*60, target = owner))
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.bleed(40 - rune*32)
		var/datum/action/innate/blood_spell/new_spell = new BS(owner)
		new_spell.Grant(owner, src)
		spells += new_spell
		//Positioning() also enable this for the action buttons moving downwards
		to_chat(owner, "<span class='warning'>Your wounds glow with power, you have prepared a [new_spell.name] invocation!</span>")
	channeling = FALSE

/datum/action/innate/blood_spell //The next generation of talismans, handles storage/creation of blood magic
	name = "Blood Magic"
	button_icon_state = "telerune"
	background_icon_state = "bg_demon"
	desc = "Fear the Old Blood."
	var/charges = 1
	var/magic_path = null
	var/obj/item/melee/blood_magic/hand_magic
	var/datum/action/innate/blood_magic/all_magic
	var/base_desc //To allow for updating tooltips
	var/invocation = "Hoi there something's wrong!"
	var/health_cost = 0

/datum/action/innate/blood_spell/Grant(mob/living/owner, datum/action/innate/blood_magic/BM)
	if(health_cost)
		desc += "<br>Deals <u>[health_cost] damage</u> to your arm per use."
	base_desc = desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	all_magic = BM
	..()

/datum/action/innate/blood_spell/Remove()
	if(all_magic)
		all_magic.spells -= src
	if(hand_magic)
		qdel(hand_magic)
		hand_magic = null
	..()

/datum/action/innate/blood_spell/IsAvailable()
	if(!iscultist(owner) || owner.incapacitated()  || !charges)
		return FALSE
	return ..()

/datum/action/innate/blood_spell/Activate()
	if(magic_path) //If this spell flows from the hand
		if(!hand_magic)
			hand_magic = new magic_path(owner, src)
			if(!owner.put_in_hands(hand_magic))
				qdel(hand_magic)
				hand_magic = null
				to_chat(owner, "<span class='warning'>You have no empty hand for invoking blood magic!</span>")
				return
			to_chat(owner, "<span class='notice'>Your wounds glow as you invoke the [name].</span>")
			return
		if(hand_magic)
			qdel(hand_magic)
			hand_magic = null
			to_chat(owner, "<span class='warning'>You snuff out the spell, saving it for later.</span>")



//the spell list

/datum/action/innate/blood_spell/stun
	name = "Stun"
	desc = "Empowers your hand to stun and mute a victim on contact."
	button_icon_state = "blood_magic_stun"
	magic_path = "/obj/item/melee/blood_magic/stun"
	health_cost = 10

/datum/action/innate/blood_spell/teleport
	name = "Teleport"
	desc = "Empowers your hand to teleport yourself or another cultist to a teleport rune on contact."
	button_icon_state = "blood_magic_teleport"
	magic_path = "/obj/item/melee/blood_magic/teleport"
	health_cost = 7

/datum/action/innate/blood_spell/emp
	name = "Electromagnetic Pulse"
	desc = "Emits a large electromagnetic pulse."
	button_icon_state = "emp"
	health_cost = 10
	invocation = "Ta'gh fara'qha fel d'amar det!"

/datum/action/innate/blood_spell/emp/Activate()
	owner.visible_message("<span class='warning'>[owner]'s hand flashes a bright blue!</span>", \
						 "<span class='cultitalic'>You speak the cursed words, emitting an EMP blast from your hand.</span>")
	empulse(owner, 2, 5)
	owner.whisper(invocation, language = /datum/language/common)
	charges--
	if(charges<=0)
		qdel(src)

/datum/action/innate/blood_spell/shackles
	name = "Shadow Shackles"
	desc = "Empowers your hand to start handcuffing victim on contact, and mute them if successful."
	button_icon_state = "blood_magic_shackles"
	charges = 4
	magic_path = "/obj/item/melee/blood_magic/shackles"

/datum/action/innate/blood_spell/construction
	name = "Twisted Construction"
	desc = "Empowers your hand to corrupt certain metalic objects.<br><u>Converts:</u><br>Plasteel into runed metal<br>50 metal into a construct shell<br>Living cyborgs into constructs after a delay<br>Cyborg shells into construct shells<br>Airlocks into brittle runed airlocks after a delay (harm intent)"
	button_icon_state = "blood_magic_transmute"
	magic_path = "/obj/item/melee/blood_magic/construction"
	health_cost = 12

/datum/action/innate/blood_spell/equipment
	name = "Summon Equipment"
	desc = "Allows you to summon a ritual dagger, or empowers your hand to summon combat gear onto a cultist you touch, including cult armor, a cult bola, and a cult sword."
	button_icon_state = "blood_magic_equip"
	magic_path = "/obj/item/melee/blood_magic/armor"

/datum/action/innate/blood_spell/equipment/Activate()
	var/choice = alert(owner,"Choose your equipment type",,"Combat Equipment","Ritual Dagger","Cancel")
	if(choice == "Ritual Dagger")
		var/turf/T = get_turf(owner)
		owner.visible_message("<span class='warning'>[owner]'s hand glows red for a moment.</span>", \
			"<span class='cultitalic'>Red light begins to shimmer and take form within your hand!</span>")
		var/obj/O = new /obj/item/melee/cultblade/dagger(T)
		if(owner.put_in_hands(O))
			to_chat(owner, "<span class='warning'>A ritual dagger appears in your hand!</span>")
		else
			owner.visible_message("<span class='warning'>A ritual dagger appears at [owner]'s feet!</span>", \
				 "<span class='cultitalic'>A ritual dagger materializes at your feet.</span>")
		SEND_SOUND(owner, sound('sound/magic/cult_spell.ogg',0,1,25))
		charges--
		desc = base_desc
		desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
		if(charges<=0)
			qdel(src)
	else if(choice == "Combat Equipment")
		..()

/datum/action/innate/blood_spell/horror
	name = "Hallucinations"
	desc = "Gives hallucinations to a target at range. A silent and invisible spell."
	button_icon_state = "blood_magic_horror"
	var/obj/effect/proc_holder/horror/PH
	charges = 4

/datum/action/innate/blood_spell/horror/New()
	PH = new()
	PH.attached_action = src
	..()

/datum/action/innate/blood_spell/horror/Destroy()
	var/obj/effect/proc_holder/horror/destroy = PH
	. = ..()
	if(destroy  && !QDELETED(destroy))
		QDEL_NULL(destroy)

/datum/action/innate/blood_spell/horror/Activate()
	PH.toggle(owner) //the important bit
	return TRUE

/obj/effect/proc_holder/horror
	active = FALSE
	ranged_mousepointer = 'icons/effects/cult_target.dmi'
	var/datum/action/innate/blood_spell/attached_action

/obj/effect/proc_holder/horror/Destroy()
	var/datum/action/innate/blood_spell/AA = attached_action
	. = ..()
	if(AA && !QDELETED(AA))
		QDEL_NULL(AA)

/obj/effect/proc_holder/horror/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability(user, "<span class='cult'>You dispel the magic...</span>")
	else
		add_ranged_ability(user, "<span class='cult'>You prepare to horrify a target...</span>")

/obj/effect/proc_holder/horror/InterceptClickOn(mob/living/user, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated() || !iscultist(user))
		user.ranged_ability.remove_ranged_ability(user)
		return
	var/turf/T = get_turf(ranged_ability_user)
	if(!isturf(T))
		return FALSE
	if(target in view(7, get_turf(ranged_ability_user)))
		if(!ishuman(target) || iscultist(target))
			return
		var/mob/living/carbon/human/H = target
		H.hallucination = max(H.hallucination, 120)
		SEND_SOUND(ranged_ability_user, sound('sound/effects/ghost.ogg',0,1,50))
		var/image/C = image('icons/effects/cult_effects.dmi', H, "bloodsparkles", ABOVE_MOB_LAYER)
		add_alt_appearance(HUDType = ANTAG_HUD_CULT, "cult_apoc", C, NONE)
		addtimer(CALLBACK(H,/atom/.proc/remove_alt_appearance,"cult_apoc",TRUE), 2400, TIMER_OVERRIDE|TIMER_UNIQUE)
		to_chat(ranged_ability_user,"<span class='cult'><b>[H] has been cursed with living nightmares!</b></span>")
		attached_action.charges--
		attached_action.desc = attached_action.base_desc
		attached_action.desc += "<br><b><u>Has [attached_action.charges] use\s remaining</u></b>."
		attached_action.UpdateButtonIcon()
		if(attached_action.charges <= 0)
			user.ranged_ability.remove_ranged_ability(user, "<span class='cult'>You have exhausted the spell's power!</span>")
			qdel(src)

/datum/action/innate/blood_spell/veiling
	name = "Conceal Presence"
	desc = "Alternates between hiding and revealing nearby cult structures and runes."
	invocation = "Kla'atu barada nikt'o!"
	button_icon_state = "blood_magic_veiling"
	charges = 10
	var/revealing = FALSE //if it reveals or not

/datum/action/innate/blood_spell/veiling/Activate()
	if(!revealing)
		owner.visible_message("<span class='warning'>Thin grey dust falls from [owner]'s hand!</span>", \
			"<span class='cultitalic'>You invoke the veiling spell, hiding nearby runes.</span>")
		charges--
		SEND_SOUND(owner, sound('sound/magic/smoke.ogg',0,1,25))
		owner.whisper(invocation, language = /datum/language/common)
		for(var/obj/effect/rune/R in range(5,owner))
			R.conceal()
		//for(var/obj/structure/cult/functional/S in range(5,owner))
			//S.conceal()
		for(var/turf/simulated/floor/engine/cult/T  in range(5,owner))
			T.realappearance.alpha = 0
		for(var/obj/machinery/door/airlock/cult/AL in range(5, owner))
			AL.conceal()
		revealing = TRUE
		name = "Reveal Runes"
		button_icon_state = "blood_magic_revealing"
	else
		owner.visible_message("<span class='warning'>A flash of light shines from [owner]'s hand!</span>", \
			 "<span class='cultitalic'>You invoke the counterspell, revealing nearby runes.</span>")
		charges--
		owner.whisper(invocation, language = /datum/language/common)
		SEND_SOUND(owner, sound('sound/misc/enter_blood.ogg',0,1,25))
		for(var/obj/effect/rune/R in range(7,owner)) //More range in case you weren't standing in exactly the same spot
			R.reveal()
		//for(var/obj/structure/cult/functional/S in range(6,owner))
		//	S.reveal()
		for(var/turf/simulated/floor/engine/cult/T  in range(6,owner))
			T.realappearance.alpha = initial(T.realappearance.alpha)
		for(var/obj/machinery/door/airlock/cult/AL in range(6, owner))
			AL.reveal()
		revealing = FALSE
		name = "Conceal Runes"
		button_icon_state = "blood_magic_veiling"
	if(charges<= 0)
		qdel(src)
	desc = base_desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	UpdateButtonIcon()


// The "magic hand" items
/obj/item/melee/blood_magic
	name = "\improper magical aura"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/items.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	flags = ABSTRACT | DROPDEL

	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/invocation
	var/uses = 1
	var/health_cost = 0 //The amount of health taken from the user when invoking the spell
	var/datum/action/innate/blood_spell/source

/obj/item/melee/blood_magic/New(loc, spell)
	source = spell
	uses = source.charges
	health_cost = source.health_cost
	..()

/obj/item/melee/blood_magic/Destroy()
	if(!QDELETED(source))
		if(uses <= 0)
			source.hand_magic = null
			qdel(source)
			source = null
		else
			source.hand_magic = null
			source.charges = uses
			source.desc = source.base_desc
			source.desc += "<br><b><u>Has [uses] use\s remaining</u></b>."
			source.UpdateButtonIcon()
	..()

/obj/item/melee/blood_magic/attack_self(mob/living/user)
	afterattack(user, user, TRUE)

/obj/item/melee/blood_magic/attack(mob/living/M, mob/living/carbon/user)
	if(!iscarbon(user) || !iscultist(user))
		uses = 0
		qdel(src)
		return
	add_attack_logs(user, M, "used a cult spell on", source.name, "")
	M.lastattacker = user.real_name
	//M.lastattackerckey = user.ckey

/obj/item/melee/blood_magic/afterattack(atom/target, mob/living/carbon/user, proximity)
	. = ..()
	if(invocation)
		user.whisper(invocation, language = /datum/language/common)
	if(health_cost && iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(health_cost, BRUTE, pick("l_arm", "r_arm"))
	if(uses <= 0)
		qdel(src)
	else if(source)
		source.desc = source.base_desc
		source.desc += "<br><b><u>Has [uses] use\s remaining</u></b>."
		source.UpdateButtonIcon()

//The spell effects

//stun
/obj/item/melee/blood_magic/stun
	name = "Stunning Aura"
	desc = "Will stun and mute a victim on contact."
	color = RUNE_COLOR_RED
	invocation = "Fuu ma'jin!"

/obj/item/melee/blood_magic/stun/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!isliving(target) || !proximity)
		return
	var/mob/living/L = target
	if(iscultist(target))
		return
	if(iscultist(user))
		user.visible_message("<span class='warning'>[user] holds up [user.p_their()] hand, which explodes in a flash of red light!</span>", \
							"<span class='cultitalic'>You attempt to stun [L] with the spell!</span>")

		user.mob_light(_color = LIGHT_COLOR_BLOOD_MAGIC, _range = 3, _duration = 2)

		var/obj/item/nullrod/N = locate() in target
		if(N)
			target.visible_message("<span class='warning'>[target]'s holy weapon absorbs the talisman's light!</span>", \
								   "<span class='userdanger'>Your holy weapon absorbs the blinding light!</span>")
		else
			to_chat(user, "<span class='cultitalic'>In a brilliant flash of red, [L] falls to the ground!</span>")
			L.Weaken(10)
			L.Stun(10)
			L.flash_eyes(1,1)
			if(issilicon(target))
				var/mob/living/silicon/S = L
				S.emp_act(EMP_HEAVY)
			else if(iscarbon(target))
				var/mob/living/carbon/C = L
				C.silent += 6
				C.stuttering += 15
				C.cultslurring += 15
				C.Jitter(15)
		uses--
	..()


//Teleportation
/obj/item/melee/blood_magic/teleport
	name = "Teleporting Aura"
	color = RUNE_COLOR_TELEPORT
	desc = "Will teleport a cultist to a teleport rune on contact."
	invocation = "Sas'so c'arta forbici!"

/obj/item/melee/blood_magic/teleport/afterattack(atom/target, mob/living/carbon/user, proximity)
	var/list/potential_runes = list()
	var/list/teleportnames = list()
	var/list/duplicaterunecount = list()
	if(!iscultist(target) || !proximity)
		to_chat(user, "<span class='warning'>You can only teleport adjacent cultists with this spell!</span>")
		return
	if(iscultist(user))
		for(var/R in teleport_runes)
			var/obj/effect/rune/teleport/T = R
			var/resultkey = T.listkey
			if(resultkey in teleportnames)
				duplicaterunecount[resultkey]++
				resultkey = "[resultkey] ([duplicaterunecount[resultkey]])"
			else
				teleportnames.Add(resultkey)
				duplicaterunecount[resultkey] = 1
			potential_runes[resultkey] = T

		if(!potential_runes.len)
			to_chat(user, "<span class='warning'>There are no valid runes to teleport to!</span>")
			log_game("Teleport talisman failed - no other teleport runes")
			return ..(user, 0)

		if(!is_level_reachable(user.z))
			to_chat(user, "<span class='cultitalic'>You are not in the right dimension!</span>")
			log_game("Teleport talisman failed - user in away mission")
			return ..(user, 0)
		uses--
		var/input_rune_key = input(user, "Choose a rune to teleport to.", "Rune to Teleport to") as null|anything in potential_runes //we know what key they picked
		var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
		if(!src || QDELETED(src) || !user || user.l_hand != src && user.r_hand != src || user.incapacitated() || !actual_selected_rune)
			return ..(user, 0)

		user.visible_message("<span class='warning'>Dust flows from [user]'s hand, and [user.p_they()] disappear[user.p_s()] in a flash of red light!</span>", \
							"<span class='cultitalic'>You speak the words of the talisman and find yourself somewhere else!</span>")
		user.forceMove(get_turf(actual_selected_rune))
		return ..()
//spell doesn't vanish

/*

		var/list/potential_runes = list()
		var/list/teleportnames = list()
		for(var/R in GLOB.teleport_runes)
			var/obj/effect/rune/teleport/T = R
			potential_runes[avoid_assoc_duplicate_keys(T.listkey, teleportnames)] = T

		if(!potential_runes.len)
			to_chat(user, "<span class='warning'>There are no valid runes to teleport to!</span>")
			log_game("Teleport talisman failed - no other teleport runes")
			return

		var/turf/T = get_turf(src)
		if(is_away_level(T.z))
			to_chat(user, "<span class='cultitalic'>You are not in the right dimension!</span>")
			log_game("Teleport spell failed - user in away mission")
			return

		var/input_rune_key = input(user, "Choose a rune to teleport to.", "Rune to Teleport to") as null|anything in potential_runes //we know what key they picked
		var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
		if(QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !actual_selected_rune || !proximity)
			return
		var/turf/dest = get_turf(actual_selected_rune)
		if(is_blocked_turf(dest, TRUE))
			to_chat(user, "<span class='warning'>The target rune is blocked. You cannot teleport there.</span>")
			return
		uses--
		var/turf/origin = get_turf(user)
		var/mob/living/L = target
		if(do_teleport(L, dest, channel = TELEPORT_CHANNEL_CULT))
			origin.visible_message("<span class='warning'>Dust flows from [user]'s hand, and [user.p_they()] disappear[user.p_s()] with a sharp crack!</span>", \
				"<span class='cultitalic'>You speak the words of the talisman and find yourself somewhere else!</span>", "<i>You hear a sharp crack.</i>")
			dest.visible_message("<span class='warning'>There is a boom of outrushing air as something appears above the rune!</span>", null, "<i>You hear a boom.</i>")
		..()

*/




//Shackles
/obj/item/melee/blood_magic/shackles
	name = "Shackling Aura"
	desc = "Will start handcuffing a victim on contact, and mute them if successful."
	invocation = "In'totum Lig'abis!"
	color = "#000000" // black

/obj/item/melee/blood_magic/shackles/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscultist(user) && iscarbon(target) && proximity)
		var/mob/living/carbon/C = target
		if(C.get_num_arms(FALSE) >= 2 || C.get_arm_ignore())
			CuffAttack(C, user)
		else
			user.visible_message("<span class='cultitalic'>This victim doesn't have enough arms to complete the restraint!</span>")
			return
		..()

/obj/item/melee/blood_magic/shackles/proc/CuffAttack(mob/living/carbon/C, mob/living/user)
	if(!C.handcuffed)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
		C.visible_message("<span class='danger'>[user] begins restraining [C] with dark magic!</span>", \
								"<span class='userdanger'>[user] begins shaping dark magic shackles around your wrists!</span>")
		if(do_mob(user, C, 30))
			if(!C.handcuffed)
				C.handcuffed = new /obj/item/restraints/handcuffs/energy/cult/used(C)
				C.update_handcuffed()
				C.silent += 5
				to_chat(user, "<span class='notice'>You shackle [C].</span>")
				add_attack_logs(user, C, "shackled")
				uses--
			else
				to_chat(user, "<span class='warning'>[C] is already bound.</span>")
		else
			to_chat(user, "<span class='warning'>You fail to shackle [C].</span>")
	else
		to_chat(user, "<span class='warning'>[C] is already bound.</span>")


/obj/item/restraints/handcuffs/energy/cult //For the shackling spell
	name = "shadow shackles"
	desc = "Shackles that bind the wrists with sinister magic."
	trashtype = /obj/item/restraints/handcuffs/energy/used
	flags = DROPDEL

/obj/item/restraints/handcuffs/energy/cult/used/dropped(mob/user)
	user.visible_message("<span class='danger'>[user]'s shackles shatter in a discharge of dark magic!</span>", \
							"<span class='userdanger'>Your [src] shatters in a discharge of dark magic!</span>")
	. = ..()


//Construction: Converts 50 metal to a construct shell, plasteel to runed metal, airlock to brittle runed airlock, a borg to a construct, or borg shell to a construct shell
/obj/item/melee/blood_magic/construction
	name = "Twisting Aura"
	desc = "Corrupts certain metalic objects on contact."
	invocation = "Ethra p'ni dedol!"
	color = "#000000" // black
	var/channeling = FALSE

/obj/item/melee/blood_magic/construction/examine(mob/user)
	. = ..()
	. += {"<u>A sinister spell used to convert:</u>\n
	Plasteel into runed metal\n
	[METAL_TO_CONSTRUCT_SHELL_CONVERSION] metal into a construct shell\n
	Living cyborgs into constructs after a delay\n
	Cyborg shells into construct shells\n
	Airlocks into brittle runed airlocks after a delay (harm intent)"}

/obj/item/melee/blood_magic/construction/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag && iscultist(user))
		if(channeling)
			to_chat(user, "<span class='cultitalic'>You are already invoking twisted construction!</span>")
			return
		var/turf/T = get_turf(target)
		if(istype(target, /obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/candidate = target
			if(candidate.use(METAL_TO_CONSTRUCT_SHELL_CONVERSION))
				uses--
				to_chat(user, "<span class='warning'>A dark cloud emanates from your hand and swirls around the metal, twisting it into a construct shell!</span>")
				new /obj/structure/constructshell(T)
				SEND_SOUND(user, sound('sound/magic/cult_spell.ogg',0,1,25))
			else
				to_chat(user, "<span class='warning'>You need [METAL_TO_CONSTRUCT_SHELL_CONVERSION] metal to produce a construct shell!</span>")
				return
		else if(istype(target, /obj/item/stack/sheet/plasteel))
			var/obj/item/stack/sheet/plasteel/candidate = target
			var/quantity = candidate.amount
			if(candidate.use(quantity))
				uses --
				new /obj/item/stack/sheet/runed_metal(T,quantity)
				to_chat(user, "<span class='warning'>A dark cloud emanates from you hand and swirls around the plasteel, transforming it into runed metal!</span>")
				SEND_SOUND(user, sound('sound/magic/cult_spell.ogg',0,1,25))
		else if(istype(target,/mob/living/silicon/robot))
			var/mob/living/silicon/robot/candidate = target
			if(candidate.mmi)
				channeling = TRUE
				user.visible_message("<span class='danger'>A dark cloud emanates from [user]'s hand and swirls around [candidate]!</span>")
				playsound(T, 'sound/machines/airlock_alien_prying.ogg', 80, TRUE)
				var/prev_color = candidate.color
				candidate.color = "black"
				if(do_after(user, 90, target = candidate))
					candidate.emp_act(EMP_HEAVY)
					var/construct_class = alert(user, "Please choose which type of construct you wish to create.",,"Juggernaut","Wraith","Artificer")
					if(QDELETED(candidate))
						channeling = FALSE
						return
					user.visible_message("<span class='danger'>The dark cloud receedes from what was formerly [candidate], revealing a\n [construct_class]!</span>")
					switch(construct_class)
						if("Juggernaut")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/armoured, candidate, user, 0, T)
						if("Wraith")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith, candidate, user, 0, T)
						if("Artificer")
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/builder, candidate, user, 0, T)
					SEND_SOUND(user, sound('sound/magic/cult_spell.ogg',0,1,25))
					uses--
					candidate.mmi = null
					qdel(candidate)
					channeling = FALSE
				else
					channeling = FALSE
					candidate.color = prev_color
					return
			else
				uses--
				to_chat(user, "<span class='warning'>A dark cloud emanates from you hand and swirls around [candidate] - twisting it into a construct shell!</span>")
				new /obj/structure/constructshell(T)
				SEND_SOUND(user, sound('sound/magic/cult_spell.ogg',0,1,25))
				qdel(candidate)
		else if(istype(target,/obj/machinery/door/airlock))
			channeling = TRUE
			playsound(T, 'sound/machines/airlockforced.ogg', 50, TRUE)
			do_sparks(5, TRUE, target)
			if(do_after(user, 50, target = user))
				if(QDELETED(target))
					channeling = FALSE
					return
				target.narsie_act()
				uses--
				user.visible_message("<span class='warning'>Black ribbons suddenly emanate from [user]'s hand and cling to the airlock - twisting and corrupting it!</span>")
				SEND_SOUND(user, sound('sound/magic/cult_spell.ogg',0,1,25))
				channeling = FALSE
			else
				channeling = FALSE
				return
		else
			to_chat(user, "<span class='warning'>The spell will not work on [target]!</span>")
			return
		..()

//Armor: Gives the target a basic cultist combat loadout
/obj/item/melee/blood_magic/armor
	name = "Arming Aura"
	desc = "Will equipt cult combat gear onto a cultist on contact."
	color = "#33cc33" // green

/obj/item/melee/blood_magic/armor/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscarbon(target) && proximity)
		uses--
		var/mob/living/carbon/C = target
		C.visible_message("<span class='warning'>Otherworldly armor suddenly appears on [C]!</span>")
		C.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/alt(user), slot_wear_suit)
		C.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(user), slot_back)
		C.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(user), slot_shoes)
		if(C == user)
			qdel(src) //Clears the hands
		C.put_in_hands(new /obj/item/melee/cultblade(user))
		C.put_in_hands(new /obj/item/restraints/legcuffs/bola/cult(user))
		..()