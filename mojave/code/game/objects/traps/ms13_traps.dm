/obj/effect/mine/ms13
	icon = 'mojave/icons/objects/ms_traps.dmi'

/obj/effect/mine/ms13/explosive
	name = "explosive mine"
	desc = "Looks incredibly dangerous..."
	icon_state = "frag_primed"
	var/inactive_state = "frag_armed"
	/// The devastation range of the resulting explosion.
	var/range_devastation = 0
	/// The heavy impact range of the resulting explosion.
	var/range_heavy = 1
	/// The light impact range of the resulting explosion.
	var/range_light = 2
	/// The flame range of the resulting explosion.
	var/range_flame = 0
	/// The flash range of the resulting explosion.
	var/range_flash = 3

	arm_delay = 5 SECONDS

/obj/effect/mine/ms13/explosive/Initialize(mapload)
	. = ..()
	if(arm_delay)
		armed = FALSE
		icon_state = inactive_state
		addtimer(CALLBACK(src, PROC_REF(now_armed)), arm_delay)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/mine/ms13/explosive/examine(mob/user)
	. = ..()
	if(!armed)
		. += "\t<span class='information'>It appears to be inactive...</span>"

/// The effect of the mine
/obj/effect/mine/ms13/explosive/mineEffect(mob/victim)
	explosion(src, range_devastation, range_heavy, range_light, range_flame, range_flash)

/// If the landmine was previously inactive, this beeps and displays a message marking it active
/obj/effect/mine/ms13/explosive/now_armed()
	armed = TRUE
	icon_state = initial(icon_state)
	playsound(src, 'mojave/sound/ms13machines/frag_mine_arm.ogg', 40, FALSE, -2)
	visible_message(span_danger("\The [src] beeps softly, indicating it is now active."), vision_distance = COMBAT_MESSAGE_RANGE)

/obj/effect/mine/ms13/explosive/on_entered(datum/source, atom/movable/AM)
	. = ..()

/obj/effect/mine/ms13/explosive/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	triggermine()

/// When something sets off a mine
/obj/effect/mine/ms13/explosive/triggermine(atom/movable/triggerer)
	if(iseffect(triggerer))
		return
	if(triggered) //too busy detonating to detonate again
		return
	if(triggerer)
		visible_message(span_danger("[triggerer] sets off [icon2html(src, viewers(src))] [src]!"))
	else
		visible_message(span_danger("[icon2html(src, viewers(src))] [src] detonates!"))

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	if(ismob(triggerer))
		mineEffect(triggerer)
	triggered = TRUE
	SEND_SIGNAL(src, COMSIG_MINE_TRIGGERED, triggerer)
	new /obj/effect/turf_decal/ms13/boommark (src, 1)
	qdel(src)

/obj/effect/spawner/random/ms13/minefield
	name = "Explosive mines"
	spawn_loot_chance = 50
	spawn_scatter_radius = 4 
	spawn_loot_count = 1 // fucking broken seemingly
	spawn_all_loot = TRUE
	loot = list(
		/obj/effect/mine/ms13/explosive = 60
	)

/obj/effect/spawner/random/ms13/guaranteed/minefield
	name = "Explosive mines"
	spawn_scatter_radius = 4
	spawn_all_loot = TRUE
	loot = list(
		/obj/effect/mine/ms13/explosive
	)
