/spell/targeted/projectile/dumbfire/ice_missile
	name = "Ice Missile"
	abbreviation = "IM"
	desc = "This spell conjures an icy projectile that will fly in the direction you're facing and shatter on collision with anything, freezing the victim."
	user_type = USER_TYPE_WIZARD

	proj_type = /obj/item/projectile/spell_projectile/ice_missile

	school = "evocation"
	charge_max = 500
	spell_flags = NEEDSCLOTHES
	invocation = "Fri'z! Ai Scr'Eim!"
	invocation_type = SpI_SHOUT
	range = 40
	cooldown_min = 20 //10 deciseconds reduction per rank

	spell_flags = 0
	spell_aspect_flags = SPELL_WATER
	duration = 20
	proj_step_delay = 0

	amt_dam_brute = 25

	level_max = list(Sp_TOTAL = 5, Sp_SPEED = 4, Sp_POWER = 2)

	hud_state = "wiz_fireball"

/spell/targeted/projectile/dumbfire/ice_missile/prox_cast(var/list/targets, spell_holder)
	for(var/mob/living/M in targets)
		playsound(M,'sound/effects/icebarrage.ogg',40,1)
		apply_spell_damage(M)
		M.bodytemperature -= 5
		M.color = "#00aedb"
		spawn(4 SECONDS)
		if(M.color == "#00aedb")
			M.color = ""
		to_chat(world, "[M]")

		if (spell_levels[Sp_POWER] == 2)
			M.stunned = 4
			to_chat(M, "<span class='notice'>A magical force stops you from moving!</span>")
			return targets
		else
			to_chat(M, "<span class='notice'>Holy shit it's freezing!</span>")
			return targets

/spell/targeted/projectile/dumbfire/ice_missile/choose_prox_targets(mob/user = usr, var/atom/movable/spell_holder)
	var/list/targets = ..()
	for(var/mob/living/M in targets)
		if(M.lying)
			targets -= M
	return targets

/spell/targeted/projectile/dumbfire/ice_missile/empower_spell()
	spell_levels[Sp_POWER]++

	var/explosion_description = ""
	switch(spell_levels[Sp_POWER])
		if(0)
			name = "Ice Missile"
			explosion_description = "It will now shatter on impact."
		if(1)
			name = "Ice Blitz"
			explosion_description = "The ice blitz will no longer only fly in the direction you're facing. Now you're able to shoot it wherever you want."
			spell_flags |= WAIT_FOR_CLICK
			dumbfire = 0
		if (2)
			name = "Ice Barrage"
			explosion_description = "The ice barrage will no longer only fly in the direction you're facing. Now you're able to shoot it wherever you want, freezing victims in the area in place."
			spell_flags |= WAIT_FOR_CLICK
			dumbfire = 0
		else
			return

	return "You have improved Ice Missile into [name]. [explosion_description]"

/spell/targeted/projectile/dumbfire/ice_missile/is_valid_target(var/atom/target)
	if(!istype(target))
		return 0
	if(target == holder)
		return 0

	return (isturf(target) || isturf(target.loc))

/spell/targeted/projectile/dumbfire/ice_missile/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_POWER)
		return "Make the spell targetable."
	return ..()

//PROJECTILE

/obj/item/projectile/spell_projectile/ice_missile
	name = "ice_2"
	icon_state = "ice_2"
	animate_movement = 2
	linear_movement = 0

/obj/item/projectile/spell_projectile/ice_missile/to_bump(var/atom/A)
	if(!isliving(A))
		forceMove(get_turf(A))
	return ..()

/proc/barrage(atom/A, var/duration, var/range)
	if(!A || !duration)
			return
	var/mob/caster = new
	var/spell/aoe_turf/ring_of_fire = new /spell/aoe_turf/ring_of_fire
	caster.invisibility = 101
	caster.setDensity(FALSE)
	caster.anchored = 1
	caster.flags = INVULNERABLE
	caster.add_spell(ring_of_fire)
	ring_of_fire.spell_flags = 0
	ring_of_fire.invocation_type = SpI_NONE
	ring_of_fire.range = range ? range : 3		//how big
	//ring_of_fire.sleeptime = duration			//for how long
	caster.forceMove(get_turf(A))
	spawn()
		ring_of_fire.perform(caster, skipcharge = 1, ignore_timeless = ignore_timeless)
		qdel(caster)