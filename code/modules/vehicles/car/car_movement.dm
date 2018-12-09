/obj/vehicle/car/Move(var/turf/destination, mob/user as mob)

	if(!on)
		to_chat(user, "<span class='warning'>The car seems to be turned off.</span>")
		return 0
	else
		if(world.time > l_move_time + move_delay)
			var/old_loc = get_turf(src)
			if(mechanical && on && powered && cell.charge < charge_use)
				turn_off()

			var/init_anc = anchored
			anchored = 0
			if(!..())
				anchored = init_anc
				return 0

			set_dir(get_dir(old_loc, loc))
			anchored = init_anc

			if(mechanical && on && powered)
				cell.use(charge_use)

			//Dummy loads do not have to be moved as they are just an overlay
			//See load_object() proc in cargo_trains.dm for an example
			if(load && !istype(load, /datum/vehicle_dummy_load))
				load.forceMove(loc)
				load.set_dir(dir)
			return 1
		else
			return 0


/obj/vehicle/car/Bump(atom/Obstacle)
	if(!istype(Obstacle, /atom/movable))
		return
	var/atom/movable/A = Obstacle

	if(!A.anchored)
		var/turf/T = get_step(A, dir)
		if(isturf(T))
			A.Move(T)	//bump things away when hit

	if(istype(A, /mob/living))
		var/mob/living/M = A
		visible_message("<span class='danger'>[src] knocks over [M]!</span>")
		playsound(src.loc, 'sound/vehicles/car_hit.ogg', 80, 0, 10)
		M.apply_effects(2, 2)				// Knock people down for a short moment
		M.apply_damages(1 / move_delay)		// Smaller amount of damage than a tug, since this will always be possible because Quads don't have safeties.
		var/list/throw_dirs = list(1, 2, 4, 8, 5, 6, 9, 10)
		if(!emagged)						// By the power of Bumpers TM, it won't throw them ahead of the quad's path unless it's emagged or the person turns.
			health -= round(M.mob_size / 2)
			throw_dirs -= dir
			throw_dirs -= get_dir(M, src) //Don't throw it AT the quad either.
		else
			health -= round(M.mob_size / 4) // Less damage if they actually put the point in to emag it.
			var/turf/T2 = get_step(A, pick(throw_dirs))
			M.throw_at(T2, 1, 1, src)
			playsound(src.loc, 'sound/vehicles/car_hit.ogg', 80, 0, 10)
			if(istype(load, /mob/living/carbon/human))
				var/mob/living/D = load
				to_chat(D, "<span class='danger'>You hit [M]!</span>")
				add_attack_logs(D,M,"Ran over with [src.name]")

	/*
	//Eh, i'll figure this out. - Cass
		if(istype(A, /obj/structure))
			if(emagged)
				if(istype(A, /obj/structure/barricade))
					var/obj/structure/barricade/B = A
					playsound(src.loc, 'sound/effects/woodcrash.ogg', 80, 0, 11025)
					B.dismantle()
					return
				else if(istype(A, /obj/structure/table))
					var/obj/structure/table/T = A
					playsound(src.loc, 'sound/effects/woodcrash.ogg', 80, 0, 11025)
					T.break_to_parts()
					return
				else if(istype(A, /obj/structure/grille))
					var/obj/structure/grille/G = A
					playsound(src.loc, 'sound/effects/grillehit.ogg', 80, 1)
					G.health = 0
					G.healthcheck()
					return
				else if(istype(A, /obj/structure/table/rack))
					var/obj/structure/table/rack/R = A
					playsound(src.loc, 'sound/effects/grillehit.ogg', 80, 1)
					R.break_to_parts()
					return
				else if(istype(A, /obj/machinery/door/window/))
					var/obj/machinery/door/window/W = A
					W.shatter(1)
					for(var/mob/living/C in buckled_mobs)
						shake_camera(C, 3, 1)
					return
				else if(istype(A, /obj/structure/window/))
					var/obj/structure/window/W = A
					W.hit(10)
					for(var/mob/living/C in buckled_mobs)
						shake_camera(C, 3, 1)
					return
			else
				return
	*/


/obj/vehicle/car/RunOver(var/mob/living/carbon/human/H)
	..()
	var/list/throw_dirs = list(1, 2, 4, 8, 5, 6, 9, 10)
	if(!emagged)
		throw_dirs -= dir
	var/turf/T = get_step(H, pick(throw_dirs))
	H.throw_at(T, 1, 1, src)