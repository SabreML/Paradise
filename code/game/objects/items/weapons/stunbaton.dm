/obj/item/melee/baton
	name = "stunbaton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	var/base_icon = "stunbaton"
	item_state = "baton"
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	origin_tech = "combat=2"
	attack_verb = list("beaten")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	/// How many life ticks does the stun last for
	var/stunforce = 7
	/// Is the baton currently turned on
	var/enabled = FALSE
	/// How much power does it cost to stun someone
	var/hitcost = 1000
	/// Chance for the baton to stun when thrown at someone
	var/throw_hit_chance = 35
	var/obj/item/stock_parts/cell/high/cell = null

/obj/item/melee/baton/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/melee/baton/loaded/Initialize(mapload) //this one starts with a cell pre-installed.
	cell = new(src)
	return ..()

/obj/item/melee/baton/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/melee/baton/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return FIRELOSS

/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/throw_impact(atom/hit_atom)
	..()
	if(enabled && prob(throw_hit_chance) && isliving(hit_atom))
		baton_stun(hit_atom)

/**
  * Removes the specified amount of charge from the batons power cell.
  *
  * If `src` is a cyborg baton, this removes the charge from the borg's internal power cell instead.
  * Arguments:
  * * amount - The amount of battery charge to be used.
  */
/obj/item/melee/baton/proc/deductcharge(amount)
	// Cyborg baton
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R.cell?.charge < (hitcost + amount))
			enabled = FALSE
			update_icon()
			playsound(src, "sparks", 75, TRUE, -1)
		if(R.cell.use(amount))
			return TRUE
		else
			return FALSE
	// Regular baton
	if(cell?.charge < (hitcost + amount)) // If after the deduction the baton doesn't have enough charge for a stun hit it turns off.
		enabled = FALSE
		update_icon()
		playsound(src, "sparks", 75, TRUE, -1)
	if(cell.use(amount))
		return TRUE
	else
		return FALSE

/obj/item/melee/baton/update_icon()
	if(enabled)
		icon_state = "[base_icon]_active"
	else if(!cell)
		icon_state = "[base_icon]_nocell"
	else
		icon_state = "[base_icon]"

/obj/item/melee/baton/examine(mob/user)
	. = ..()
	if(isrobot(loc))
		. += "<span class='notice'>This baton is drawing power directly from your own internal charge.</span>"
	if(cell)
		. += "<span class='notice'>The baton is [round(cell.percent())]% charged.</span>"
	else
		. += "<span class='warning'>The baton does not have a power source installed.</span>"


/obj/item/melee/baton/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = I
		if(cell)
			to_chat(user, "<span class='warning'>[src] already has a cell!</span>")
			return
		if(C.maxcharge < hitcost)
			to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
			return
		if(!user.unEquip(I))
			return
		I.loc = src
		cell = I
		to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
		update_icon()

/obj/item/melee/baton/screwdriver_act(mob/living/user, obj/item/I)
	if(!cell)
		to_chat(user, "<span class='warning'>There's no cell installed!</span>")
		return
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return

	cell.update_icon()
	cell.loc = get_turf(src)
	cell = null
	to_chat(user, "<span class='notice'>You remove the cell from [src].</span>")
	enabled = FALSE
	update_icon()

/obj/item/melee/baton/attack_self(mob/user)
	// Cyborg baton
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R?.cell?.charge >= hitcost)
			enabled = !enabled
			to_chat(user, "<span class='notice'>[src] is now [enabled ? "on" : "off"].</span>")
			playsound(src, "sparks", 75, TRUE, -1)
		else
			enabled = FALSE
			to_chat(user, "<span class='warning'>You do not have enough reserve power to charge [src]!</span>")

	// Regular baton
	else if(cell?.charge >= hitcost)
		enabled = !enabled
		to_chat(user, "<span class='notice'>[src] is now [enabled ? "on" : "off"].</span>")
		playsound(src, "sparks", 75, TRUE, -1)
	else
		enabled = FALSE
		if(!cell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is out of charge.</span>")
	update_icon()
	add_fingerprint(user)


/obj/item/melee/baton/attack(mob/M, mob/living/user)
	if(enabled && (CLUMSY in user.mutations) && prob(50))
		user.visible_message("<span class='danger'>[user] accidentally hits [user.p_them()]self with [src]!</span>",
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		user.Weaken(stunforce * 3)
		deductcharge(hitcost)
		return

	if(isrobot(M)) // Can't stunbaton borgs
		return ..()

	if(!isliving(M))
		return
	var/mob/living/L = M

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(check_martial_counter(H, user))
			return

	if(user.a_intent == INTENT_HARM)
		if(enabled)
			baton_stun(L, user)
		return ..() // Whack them too if in harm intent

	if(!enabled)
		L.visible_message("<span class='warning'>[user] has prodded [L] with [src]. Luckily it was off.</span>",
			"<span class='danger'>[L == user ? "You prod yourself" : "[user] has prodded you"] with [src]. Luckily it was off.</span>")
		return

	baton_stun(L, user)
	user.do_attack_animation(L)


/obj/item/melee/baton/proc/baton_stun(mob/living/L, mob/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(L, 'sound/weapons/genhit.ogg', 50, TRUE)
			return
		H.forcesay(GLOB.hit_appends)

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.shock_internal_organs(33)

	L.Stun(stunforce)
	L.Weaken(stunforce)
	L.Stuttering(stunforce)

	if(user)
		L.lastattacker = user.real_name
		L.lastattackerckey = user.ckey
		L.visible_message("<span class='danger'>[user] has stunned [L] with [src]!</span>",
			"<span class='userdanger'>[L == user ? "You stun yourself" : "[user] has stunned you"] with [src]!</span>")
		add_attack_logs(user, L, "stunned")
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	deductcharge(hitcost)


/obj/item/melee/baton/emp_act(severity)
	. = ..()
	if(cell)
		deductcharge(1000 / severity)

/obj/item/melee/baton/wash(mob/user, atom/source)
	if(enabled && cell?.charge > 0)
		flick("baton_active", source)
		user.Stun(stunforce)
		user.Weaken(stunforce)
		user.SetStuttering(stunforce)
		deductcharge(hitcost)
		user.visible_message("<span class='warning'>[user] shocks [user.p_them()]self while attempting to wash the active [src]!</span>",
							"<span class='userdanger'>You unwisely attempt to wash [src] while it's still on.</span>")
		playsound(src, "sparks", 50, TRUE)
		return TRUE
	..()

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod_nocell"
	base_icon = "stunprod"
	item_state = "prod"
	force = 3
	throwforce = 5
	stunforce = 5
	hitcost = 2000
	throw_hit_chance = 10
	slot_flags = SLOT_BACK
	var/obj/item/assembly/igniter/sparkler = null

/obj/item/melee/baton/cattleprod/Initialize(mapload)
	. = ..()
	sparkler = new(src)

/obj/item/melee/baton/cattleprod/Destroy()
	QDEL_NULL(sparkler)
	return ..()

/obj/item/melee/baton/cattleprod/baton_stun()
	if(sparkler.activate())
		return ..()
