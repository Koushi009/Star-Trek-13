
/obj/machinery/computer/transporter_control
	name = "transporter control station"
	icon = 'StarTrek13/icons/trek/star_trek.dmi'
	icon_state = "helm"
	dir = 4
	icon_keyboard = null
	icon_screen = null
	layer = 4.5
	var/list/retrievable = list()
	var/list/linked = list()
	var/list/tricorders = list()

/obj/machinery/computer/transporter_control/New()
	. = ..()
	link_to()

/obj/machinery/computer/transporter_control/proc/link_to()
	for(var/obj/machinery/trek/transporter/T in get_area(src))
		src.linked += T
		T.transporter_controller = src

/obj/machinery/computer/transporter_control/proc/activate_pads(area/thearea)
	for(var/obj/machinery/trek/transporter/T in linked)
		T.teleport_target = thearea
		T.Send()

/obj/machinery/computer/transporter_control/proc/get_available_turfs(var/area/A)
	if(!A)
		return
	var/list/available_turfs = list()
	for(var/turf/T in get_area_turfs(A.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				available_turfs += T


/obj/machinery/computer/transporter_control/attack_hand(mob/user)
	var/A
	var/B
	B = input(user, "Mode:","Transporter Control",B) in list("send object","retrieve away team member", "cancel")
	switch(B)
		if("send object")
			A = input(user, "Target", "Transporter Control", A) as null|anything in GLOB.teleportlocs
			playsound(src.loc, 'StarTrek13/sound/borg/machines/transporter.ogg', 40, 4)
			var/area/thearea = GLOB.teleportlocs[A]
			if(!thearea)
				return
			for(var/obj/machinery/trek/transporter/T in linked)
				for(var/mob/M in T.loc)
					retrievable += M
			/*playsound(src.loc, 'StarTrek13/sound/borg/machines/transporter.ogg', 40, 4)
			var/list/L = list()
			for(var/turf/T in get_area_turfs(thearea.type))
				if(!T.density)
					var/clear = 1
					for(var/obj/O in T)
						if(O.density)
							clear = 0
							break						ravioli ravioli what is this spaghetti codey
					if(clear)
						L+=T
			if(!L || !L.len)
				usr << "No area available."
			var/list/available_turfs = get_available_turfs(GLOB.teleportlocs[A])
			if(!available_turfs || !available_turfs.len)
				usr << "No area available."
			else*/
			activate_pads(thearea)

                        //                T.icon_state = "transporter" //erroroneus meme!
                                //        playsound(src.loc, 'StarTrek13/sound/borg/machinesalert2.ogg', 40, 4)
                                //        user << "Transport pattern buffer initialization failure."
		if("retrieve away team member")
			var/C = input(user, "Beam someone back", "Transporter Control") as anything in retrievable
			if(!C in retrievable)
				return
			var/atom/movable/target = C
			playsound(src.loc, 'StarTrek13/sound/borg/machines/transporter.ogg', 40, 4)
			retrievable -= target
			for(var/obj/machinery/trek/transporter/T in linked)
				animate(target,'StarTrek13/icons/trek/star_trek.dmi',"transportout")
				playsound(target.loc, 'StarTrek13/sound/borg/machines/transporter2.ogg', 40, 4)
				playsound(src.loc, 'StarTrek13/sound/borg/machines/transporter.ogg', 40, 4)
				var/obj/machinery/trek/transporter/Z = pick(linked)
				target.forceMove(Z.loc)
				target.alpha = 255
				//Z.rematerialize(target)
				animate(Z,'StarTrek13/icons/trek/star_trek.dmi',"transportin")
                        //        Z.alpha = 255
				break
		if("cancel")
			return

/obj/machinery/computer/transporter_control/attackby(obj/I, mob/user)
	if(istype(I, /obj/item/device/tricorder))
		if(!I in tricorders)
			var/obj/item/device/tricorder/S = I
			S.transporter_controller = src
			tricorders += I
			user << "Successfully linked [I] to [src], you may now tag items for transportation"
		else
			user << "[I] is already linked to [src]!"
	else
		return 0

/obj/machinery/trek/transporter
	name = "transporter pad"
	density = 0
	anchored = 1
	can_be_unanchored = 0
	icon = 'StarTrek13/icons/trek/star_trek.dmi'
	icon_state = "transporter"
	anchored = TRUE
	var/turf/teleport_target
	var/obj/machinery/computer/transporter_control/transporter_controller = null

/obj/machinery/trek/transporter/proc/Warp(mob/living/target)
	if(!target.buckled)
		target.forceMove(get_turf(src))

/obj/machinery/trek/transporter/proc/Send()
	if(teleport_target == null)
		teleport_target = GLOB.teleportlocs[pick(GLOB.teleportlocs)]
	flick("alien-pad", src)
	for(var/mob/living/target in loc)
		target.forceMove(teleport_target)

/obj/machinery/trek/transporter/proc/Retrieve(mob/living/target)
	flick("alien-pad", src)
	new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)
	Warp(target)

/*
/obj/structure/trek/transporter
	name = "transporter pad"
	density = 0
	anchored = 1
	can_be_unanchored = 0
	icon = 'StarTrek13/icons/trek/star_trek.dmi'
	icon_state = "transporter"
	var/target_loc = list() //copied
	var/obj/machinery/computer/transporter_control/transporter_controller = null

/obj/structure/trek/transporter/proc/teleport(var/mob/M, available_turfs)
	animate(M,'StarTrek13/icons/trek/star_trek.dmi',"transportout")
	usr << M
	M.dir = 1
	transporter_controller.retrievable += M
	if(M in transporter_controller.retrievable)
		transporter_controller.retrievable -= M
	M.alpha = 0
	M.forceMove(pick(available_turfs))
//	animate(M)
	if(ismob(M))
		var/mob/living/L = M
		L.Stun(3)
		animate(M,'StarTrek13/icons/trek/star_trek.dmi',"transportin") //test with flick, not sure if it'll work! SKREE
	icon_state = "transporter"

/obj/structure/trek/transporter/proc/teleport_all(available_turfs)
	icon_state = "transporter_on"
	for(var/mob/M in get_turf(src))
		if(M != src)
			//anim(M.loc,'icons/obj/machines/borg_decor.dmi',"transportin")
			teleport(M, available_turfs)
			rematerialize(M)
	icon_state = "transporter"


/obj/structure/trek/transporter/proc/rematerialize(var/atom/movable/thing)
	//var/atom/movable/target = Target
	icon_state = "transporter_on"
	thing.alpha = 255
	playsound(thing.loc, 'StarTrek13/sound/borg/machines/transporter2.ogg', 40, 4)
	icon_state = "transporter"*/