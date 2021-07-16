
/datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	result = null
	required_reagents = list(/datum/reagent/consumable/drink/milk/soymilk = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	result_amount = 1

/datum/chemical_reaction/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/tofu(location)

/datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list(/datum/reagent/consumable/drink/milk/soymilk = 2, /datum/reagent/consumable/cocoa = 2, /datum/reagent/consumable/sugar = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)

/datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list(/datum/reagent/consumable/drink/milk = 2, /datum/reagent/consumable/cocoa = 2, /datum/reagent/consumable/sugar = 2)
	result_amount = 1

/datum/chemical_reaction/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/chocolatebar(location)

/datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	result = /datum/reagent/consumable/soysauce
	required_reagents = list(/datum/reagent/consumable/drink/milk/soymilk = 1, /datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/water = 8)
	result_amount = 10

/datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	result = null
	required_reagents = list(/datum/reagent/consumable/drink/milk = 40)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	result_amount = 1

/datum/chemical_reaction/cheesewheel/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/sliceable/cheesewheel(location)

/datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	id = "syntiflesh"
	result = null
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/medicine/cryoxadone = 1)
	result_amount = 1

/datum/chemical_reaction/syntiflesh/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/reagent_containers/food/snacks/meat/syntiflesh(location)

/datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	result = /datum/reagent/consumable/hot_ramen
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/dry_ramen = 3)
	result_amount = 3

/datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	result = /datum/reagent/consumable/hell_ramen
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/hot_ramen = 6)
	result_amount = 6

/datum/chemical_reaction/dough
	name = "Dough"
	id = "dough"
	result = null
	required_reagents = list(/datum/reagent/water = 10, /datum/reagent/consumable/flour = 15)
	result_amount = 1
	mix_message = "The ingredients form a dough."

/datum/chemical_reaction/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/food/snacks/dough(location)

///Cookies by Ume

/datum/chemical_reaction/cookiedough
	name = "Dough"
	id = "dough"
	result = null
	required_reagents = list(/datum/reagent/consumable/drink/milk = 10, /datum/reagent/consumable/flour = 10, /datum/reagent/consumable/sugar = 5)
	result_amount = 1
	mix_message = "The ingredients form a dough. It smells sweet and yummy."

/datum/chemical_reaction/cookiedough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/food/snacks/cookiedough(location)


/datum/chemical_reaction/corn_syrup
	name = "corn_syrup"
	id = "corn_syrup"
	result = /datum/reagent/consumable/corn_syrup
	required_reagents = list(/datum/reagent/consumable/corn_starch = 1, /datum/reagent/acid = 1)
	result_amount = 2
	min_temp = T0C + 100
	mix_message = "The mixture forms a viscous, clear fluid!"

/datum/chemical_reaction/vhfcs
	name = "vhfcs"
	id = "vhfcs"
	result = /datum/reagent/consumable/vhfcs
	required_reagents = list(/datum/reagent/consumable/corn_syrup = 1)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 1)
	result_amount = 1
	mix_message = "The mixture emits a sickly-sweet smell."

/datum/chemical_reaction/cola
	name = "cola"
	id = "cola"
	result = /datum/reagent/consumable/drink/cold/space_cola
	required_reagents = list(/datum/reagent/carbon = 1, /datum/reagent/oxygen = 1, /datum/reagent/water = 1, /datum/reagent/consumable/sugar = 1)
	result_amount = 4
	mix_message = "The mixture begins to fizz."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/fake_cheese
	name = "Fake cheese"
	id = "fake_cheese"
	result = /datum/reagent/consumable/fake_cheese
	required_reagents = list(/datum/reagent/vomit = 5, /datum/reagent/consumable/drink/milk = 5)
	result_amount = 5
	mix_message = "The mixture curdles up."

/datum/chemical_reaction/fake_cheese/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='notice'>A faint cheese-ish smell drifts through the air...</span>")

/datum/chemical_reaction/weird_cheese
	name = "Weird cheese"
	id = "weird_cheese"
	result = null
	required_reagents = list(/datum/reagent/greenvomit = 5, /datum/reagent/consumable/drink/milk = 5)
	result_amount = 1
	mix_message = "The disgusting mixture sloughs together horribly, emitting a foul stench."
	mix_sound = 'sound/goonstation/misc/gurggle.ogg'

/datum/chemical_reaction/weird_cheese/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/reagent_containers/food/snacks/weirdcheesewedge(location)

/datum/chemical_reaction/hydrogenated_soybeanoil
	name = "Partially hydrogenated space-soybean oil"
	id = "hydrogenated_soybeanoil"
	result = /datum/reagent/consumable/hydrogenated_soybeanoil
	required_reagents = list(/datum/reagent/consumable/soybeanoil = 1, /datum/reagent/hydrogen = 1)
	result_amount = 2
	min_temp = T0C + 250
	mix_message = "The mixture emits a burnt, oily smell."

/datum/chemical_reaction/meatslurry
	name = "Meat Slurry"
	id = "meatslurry"
	result = /datum/reagent/consumable/meatslurry
	required_reagents = list(/datum/reagent/consumable/corn_starch = 1, /datum/reagent/blood = 1)
	result_amount = 2
	mix_message = "The mixture congeals into a bloody mass."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/gravy
	name = "Gravy"
	id = "gravy"
	result = /datum/reagent/consumable/gravy
	required_reagents = list(/datum/reagent/consumable/porktonium = 1, /datum/reagent/consumable/corn_starch = 1, /datum/reagent/consumable/drink/milk = 1)
	result_amount = 3
	min_temp = T0C + 100
	mix_message = "The substance thickens and takes on a meaty odor."

/datum/chemical_reaction/enzyme
	name = "Universal enzyme"
	id = "enzyme"
	result = /datum/reagent/consumable/enzyme
	required_reagents = list(/datum/reagent/vomit = 1, /datum/reagent/consumable/sugar = 1)
	result_amount = 2
	min_temp = T0C + 480
	mix_message = "The mixture emits a horrible smell as you heat up the contents. Luckily, enzymes don't stink."
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/enzyme2
	name = "Universal enzyme"
	id = "enzyme"
	result = /datum/reagent/consumable/enzyme
	required_reagents = list(/datum/reagent/greenvomit = 1, /datum/reagent/consumable/sugar = 1)
	result_amount = 2
	min_temp = T0C + 480
	mix_message = "The mixture emits a horrible smell as you heat up the contents. Luckily, enzymes don't stink."
	mix_sound = 'sound/goonstation/misc/fuse.ogg'
