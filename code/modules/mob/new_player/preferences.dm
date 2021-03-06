#define UI_OLD 0
#define UI_NEW 1

var/global/list/special_roles = list( //keep synced with the defines BE_* in setup.dm --rastaf
//some autodetection here.
	"traitor" = IS_MODE_COMPILED("traitor"),
	"operative" = IS_MODE_COMPILED("nuclear"),
	"changeling" = IS_MODE_COMPILED("changeling"),
	"wizard" = IS_MODE_COMPILED("wizard"),
	"malf AI" = IS_MODE_COMPILED("malfunction"),
	"revolutionary" = IS_MODE_COMPILED("revolution"),
	"alien candidate" = 1, //always show
	"pai candidate" = 1, // -- TLE
	"cultist" = IS_MODE_COMPILED("cult"),
	"infested monkey" = IS_MODE_COMPILED("monkey"),
)
/*
var/global/list/special_roles = list( //keep synced with the defines BE_* in setup.dm --rastaf
//some autodetection here.
	"traitor" = ispath(text2path("/datum/game_mode/traitor")),
	"operative" = ispath(text2path("/datum/game_mode/nuclear")),
	"changeling" = ispath(text2path("/datum/game_mode/changeling")),
	"wizard" = ispath(text2path("/datum/game_mode/wizard")),
	"malf AI" = ispath(text2path("/datum/game_mode/malfunction")),
	"revolutionary" = ispath(text2path("/datum/game_mode/revolution")),
	"alien candidate" = 1, //always show
	"cultist" = ispath(text2path("/datum/game_mode/cult")),
	"infested monkey" = ispath(text2path("/datum/game_mode/monkey")),
)
*/
var/const
	BE_TRAITOR   =(1<<0)
	BE_OPERATIVE =(1<<1)
	BE_CHANGELING=(1<<2)
	BE_WIZARD    =(1<<3)
	BE_MALF      =(1<<4)
	BE_REV       =(1<<5)
	BE_ALIEN     =(1<<6)
	BE_CULTIST   =(1<<7)
	BE_MONKEY    =(1<<8)
	BE_PAI       =(1<<9)

datum/preferences
	var
		real_name
		be_random_name = 0
		gender = MALE
		age = 30.0
		b_type = "A+"

		//Special role selection
		be_special = 0
		//Play admin midis
		midis = 1
		//Play pregame music
		pregame_music = 1
		//Saved changlog filesize to detect if there was a change
		lastchangelog = 0

		//Just like it sounds
		ooccolor = "#b82e00"
		underwear = 1

		//Hair type
		h_style = "Short Hair"
		datum/sprite_accessory/hair/hair_style
		//Hair color
		r_hair = 0
		g_hair = 0
		b_hair = 0

		//Face hair type
		f_style = "Shaved"
		datum/sprite_accessory/facial_hair/facial_hair_style
		//Face hair color
		r_facial = 0
		g_facial = 0
		b_facial = 0

		//Skin color
		s_tone = 0

		//Eye color
		r_eyes = 0
		g_eyes = 0
		b_eyes = 0

		//UI style
		UI = UI_OLD

		//Mob preview
		icon/preview_icon = null

		//Jobs, uses bitflags
		job_civilian_high = 0
		job_civilian_med = 0
		job_civilian_low = 0

		job_medsci_high = 0
		job_medsci_med = 0
		job_medsci_low = 0

		job_engsec_high = 0
		job_engsec_med = 0
		job_engsec_low = 0

		list/job_alt_titles = new()		// the default name of a job like "Medical Doctor"

		flavor_text = ""

		// slot stuff (Why were they var/var?  --SkyMarshal)
		slotname
		curslot = 0
		disabilities = 0

	New()
		hair_style = new/datum/sprite_accessory/hair/short
		facial_hair_style = new/datum/sprite_accessory/facial_hair/shaved
		randomize_name()
		..()


	proc/ShowChoices(mob/user)
		update_preview_icon()
		user << browse_rsc(preview_icon, "previewicon.png")

		var/dat = "<html><body>"
		dat += "<b>Name:</b> "
		dat += "<a href=\"byond://?src=\ref[user];preferences=1;real_name=input\"><b>[real_name]</b></a> "
		dat += "(<a href=\"byond://?src=\ref[user];preferences=1;real_name=random\">&reg;</A>) "
		dat += "(&reg; = <a href=\"byond://?src=\ref[user];preferences=1;b_random_name=1\">[be_random_name ? "Yes" : "No"]</a>)"
		dat += "<br>"

		dat += "<b>Gender:</b> <a href=\"byond://?src=\ref[user];preferences=1;gender=input\"><b>[gender == MALE ? "Male" : "Female"]</b></a><br>"
		dat += "<b>Age:</b> <a href='byond://?src=\ref[user];preferences=1;age=input'>[age]</a>"

		dat += "<br>"
		dat += "<b>UI Style:</b> <a href=\"byond://?src=\ref[user];preferences=1;UI=input\"><b>[UI == UI_NEW ? "New" : "Old"]</b></a><br>"
		dat += "<b>Play admin midis:</b> <a href=\"byond://?src=\ref[user];preferences=1;midis=input\"><b>[midis == 1 ? "Yes" : "No"]</b></a><br>"

		if((user.client) && (user.client.holder) && (user.client.holder.rank) && (user.client.holder.rank == "Game Master"))
			dat += "<hr><b>OOC</b><br>"
			dat += "<a href='byond://?src=\ref[user];preferences=1;ooccolor=input'>Change colour</a> <font face=\"fixedsys\" size=\"3\" color=\"[ooccolor]\"><table style='display:inline;'  bgcolor=\"[ooccolor]\"><tr><td>__</td></tr></table></font>"

		dat += "<hr><b>Occupation Choices</b><br>"
		dat += "\t<a href=\"byond://?src=\ref[user];preferences=1;occ=1\"><b>Set Preferences</b></a><br>"

		dat += "<hr><table><tr><td><b>Body</b> "
		dat += "(<a href=\"byond://?src=\ref[user];preferences=1;s_tone=random;underwear=random;age=random;b_type=random;hair=random;h_style=random;facial=random;f_style=random;eyes=random\">&reg;</A>)" // Random look
		dat += "<br>"
		dat += "Blood Type: <a href='byond://?src=\ref[user];preferences=1;b_type=input'>[b_type]</a><br>"
		dat += "Skin Tone: <a href='byond://?src=\ref[user];preferences=1;s_tone=input'>[-s_tone + 35]/220<br></a>"

		if(!IsGuestKey(user.key))
			dat += "Underwear: <a href =\"byond://?src=\ref[user];preferences=1;underwear=1\"><b>[underwear == 1 ? "Yes" : "No"]</b></a><br>"
		dat += "</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64></td></tr></table>"

		dat += "<hr><b>Hair</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;hair=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)]\"><table style='display:inline;' bgcolor=\"#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]\"><tr><td>__</td></tr></table></font> "

		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;h_style=input'>[h_style]</a>"

		dat += "<hr><b>Facial</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;facial=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)]\"><table  style='display:inline;' bgcolor=\"#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]\"><tr><td>__</td></tr></table></font> "

		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;f_style=input'>[f_style]</a>"

		dat += "<hr><b>Eyes</b><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;eyes=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]\"><table  style='display:inline;' bgcolor=\"#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]\"><tr><td>__</td></tr></table></font>"

		dat += "<hr><b>Disabilities: </b><br>"
		dat += "Need Glasses? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=0\">[disabilities & (1<<0) ? "Yes" : "No"]</a><br>"
		dat += "Seizures? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=1\">[disabilities & (1<<1) ? "Yes" : "No"]</a><br>"
		dat += "Coughing? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=2\">[disabilities & (1<<2) ? "Yes" : "No"]</a><br>"
		dat += "Tourettes/Twitching? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=3\">[disabilities & (1<<3) ? "Yes" : "No"]</a><br>"
		dat += "Nervousness? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=4\">[disabilities & (1<<4) ? "Yes" : "No"]</a><br>"
		dat += "Trenna's Disorder? (Deafness) <a href=\"byond://?src=\ref[user];preferences=1;disabilities=5\">[disabilities & (1<<5) ? "Yes" : "No"]</a><br>"

		dat += "<hr><b>Flavor Text</b><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;flavor_text=1'>Change</a><br>"
		if(lentext(flavor_text) <= 40)
			dat += "[flavor_text]"
		else
			dat += "[copytext(flavor_text, 1, 37)]..."

		dat += "<hr>"
		if(!jobban_isbanned(user, "Syndicate"))
			var/n = 0
			for (var/i in special_roles)
				if(special_roles[i]) //if mode is available on the server
					dat += "<b>Be [i]:</b> <a href=\"byond://?src=\ref[user];preferences=1;be_special=[n]\"><b>[src.be_special&(1<<n) ? "Yes" : "No"]</b></a><br>"
				n++
		else
			dat += "<b>You are banned from being syndicate.</b>"
			src.be_special = 0
		dat += "<hr>"

		// slot options
		if (!IsGuestKey(user.key))
			if(!curslot)
				curslot = 1
				slotname = savefile_getslots(user)[1]
			dat += "<a href='byond://?src=\ref[user];preferences=1;saveslot=[curslot]'>Save Slot [curslot] ([slotname])</a><br>"
			dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot2=1'>Load</a><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;createslot=1'>Create New Slot</a><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;reset_all=1'>Reset Setup</a><br>"
		dat += "</body></html>"

		user << browse(dat, "window=preferences;size=300x710")
	proc/loadsave(mob/user)
		var/dat = "<body>"
		dat += "<tt><center>"

		var/list/slots = savefile_getslots(user)
		for(var/slot=1, slot<=slots.len, slot++)
			dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot=[slot]'>Load Slot [slot] ([slots[slot]]) </a><a href='byond://?src=\ref[user];preferences=1;removeslot=[slot]'>(R)</a><br><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot=CLOSE'>Close</a><br>"
		dat += "</center></tt>"
		user << browse(dat, "window=saves;size=300x640")
	proc/closesave(mob/user)
		user << browse(null, "window=saves;size=300x640")

	proc/GetAltTitle(datum/job/job)
		return job_alt_titles.Find(job.title) > 0 \
			? job_alt_titles[job.title] \
			: job.title

	proc/SetAltTitle(datum/job/job, new_title)
		// remove existing entry
		if(job_alt_titles.Find(job.title))
			job_alt_titles -= job.title
		// add one if it's not default
		if(job.title != new_title)
			job_alt_titles[job.title] = new_title

	proc/SetChoices(mob/user, changedjob)
		var/HTML = "<body>"
		HTML += "<tt><center>"
		HTML += "<b>Choose occupation chances</b><br>Unavailable occupations are in red.<br>"
		for(var/datum/job/job in job_master.occupations)
			var/rank = job.title
			if(jobban_isbanned(user, rank))
				HTML += "<font color=red>[rank]</font><br>"
				continue
			if((job_civilian_low & ASSISTANT) && (rank != "Assistant"))
				HTML += "<font color=orange>[rank]</font><br>"
				continue
			if((rank in command_positions) || (rank == "AI"))//Bold head jobs
				HTML += "<b>[rank]<a href=\"byond://?src=\ref[user];preferences=1;occ=1;job=[rank]\"></b>"
			else
				HTML += "[rank]<a href=\"byond://?src=\ref[user];preferences=1;occ=1;job=[rank]\">"

			if(rank == "Assistant")//Assistant is special
				if(job_civilian_low & ASSISTANT)
					HTML += "<font color=green>\[Yes]</font>"
				else
					HTML += "<font color=red>\[No]</font>"
				HTML += "</a><br>"
				continue

			if(GetJobDepartment(job, 1) & job.flag)
				HTML += "<font color=blue>\[High]</font>"
			else if(GetJobDepartment(job, 2) & job.flag)
				HTML += "<font color=green>\[Medium]</font>"
			else if(GetJobDepartment(job, 3) & job.flag)
				HTML += "<font color=orange>\[Low]</font>"
			else
				HTML += "<font color=red>\[NEVER]</font>"
			if(job.alt_titles)
				HTML += "</a> <a href=\"byond://?src=\ref[user];preferences=1;alt_title=1;job=\ref[job]\">\[[GetAltTitle(job)]\]</a><br>"
			else
				HTML += "</a><br>"

		HTML += "<br>"
		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=0;job=cancel\">\[Done\]</a>"
		HTML += "</center></tt>"

		user << browse(null, "window=preferences")
		user << browse(HTML, "window=mob_occupation;size=350x600")
		return


	proc/SetJob(mob/user, role)
		var/datum/job/job = job_master.GetJob(role)
		if(!job)
			user << browse(null, "window=mob_occupation")
			ShowChoices(user)
			return

		if(role == "Assistant")
			if(job_civilian_low & job.flag)
				job_civilian_low &= ~job.flag
			else
				job_civilian_low |= job.flag
			SetChoices(user)
			return 1

		if(GetJobDepartment(job, 1) & job.flag)
			SetJobDepartment(job, 1)
		else if(GetJobDepartment(job, 2) & job.flag)
			SetJobDepartment(job, 2)
		else if(GetJobDepartment(job, 3) & job.flag)
			SetJobDepartment(job, 3)
		else//job = Never
			SetJobDepartment(job, 4)

		SetChoices(user)
		return 1


	proc/GetJobDepartment(var/datum/job/job, var/level)
		if(!job || !level)	return 0
		switch(job.department_flag)
			if(CIVILIAN)
				switch(level)
					if(1)
						return job_civilian_high
					if(2)
						return job_civilian_med
					if(3)
						return job_civilian_low
			if(MEDSCI)
				switch(level)
					if(1)
						return job_medsci_high
					if(2)
						return job_medsci_med
					if(3)
						return job_medsci_low
			if(ENGSEC)
				switch(level)
					if(1)
						return job_engsec_high
					if(2)
						return job_engsec_med
					if(3)
						return job_engsec_low
		return 0


	proc/SetJobDepartment(var/datum/job/job, var/level)
		if(!job || !level)	return 0
		switch(level)
			if(1)//Only one of these should ever be active at once so clear them all here
				job_civilian_high = 0
				job_medsci_high = 0
				job_engsec_high = 0
				return 1
			if(2)//Set current highs to med, then reset them
				job_civilian_med |= job_civilian_high
				job_medsci_med |= job_medsci_high
				job_engsec_med |= job_engsec_high
				job_civilian_high = 0
				job_medsci_high = 0
				job_engsec_high = 0

		switch(job.department_flag)
			if(CIVILIAN)
				switch(level)
					if(2)
						job_civilian_high = job.flag
						job_civilian_med &= ~job.flag
					if(3)
						job_civilian_med |= job.flag
						job_civilian_low &= ~job.flag
					else
						job_civilian_low |= job.flag
			if(MEDSCI)
				switch(level)
					if(2)
						job_medsci_high = job.flag
						job_medsci_med &= ~job.flag
					if(3)
						job_medsci_med |= job.flag
						job_medsci_low &= ~job.flag
					else
						job_medsci_low |= job.flag
			if(ENGSEC)
				switch(level)
					if(2)
						job_engsec_high = job.flag
						job_engsec_med &= ~job.flag
					if(3)
						job_engsec_med |= job.flag
						job_engsec_low &= ~job.flag
					else
						job_engsec_low |= job.flag
		return 1


	proc/process_link(mob/user, list/link_tags)
		if(link_tags["occ"])
			if(link_tags["cancel"])
				user << browse(null, "window=\ref[user]occupation")
				return
			else if(link_tags["job"])
				SetJob(user, link_tags["job"])
			else
				if(job_master)
					SetChoices(user)

			return 1

		if(link_tags["alt_title"] && link_tags["job"])
			var/datum/job/job = locate(link_tags["job"])
			var/choices = list(job.title) + job.alt_titles
			var/choice = input("Pick a title for [job.title].", "Character Generation", GetAltTitle(job)) as anything in choices | null
			if(choice)
				SetAltTitle(job, choice)
				SetChoices(user)

		if(link_tags["real_name"])
			var/new_name

			switch(link_tags["real_name"])
				if("input")
					new_name = input(user, "Please select a name:", "Character Generation")  as text
					var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\")
					for(var/c in bad_characters)
						new_name = dd_replacetext(new_name, c, "")
					if(!new_name || (new_name == "Unknown") || (new_name == "floor") || (new_name == "wall") || (new_name == "r-wall"))
						alert("Don't do this")
						return

				if("random")
					randomize_name()

			if(new_name)
				if(length(new_name) >= 26)
					new_name = copytext(new_name, 1, 26)
				real_name = new_name

		if(link_tags["age"])
			switch(link_tags["age"])
				if("input")
					var/new_age = input(user, "Please select type in age: 20-45", "Character Generation")  as num
					if(new_age)
						age = max(min(round(text2num(new_age)), 45), 20)
				if("random")
					age = rand (20, 45)

		if(link_tags["b_type"])
			switch(link_tags["b_type"])
				if("input")
					var/new_b_type = input(user, "Please select a blood type:", "Character Generation")  as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if(new_b_type)
						b_type = new_b_type
				if("random")
					b_type = pickweight ( list ("A+" = 31, "A-" = 7, "B+" = 8, "B-" = 2, "AB+" = 2, "AB-" = 1, "O+" = 40, "O-" = 9))


		if(link_tags["hair"])
			switch(link_tags["hair"])
				if("input")
					var/new_hair = input(user, "Please select hair color.", "Character Generation") as color
					if(new_hair)
						r_hair = hex2num(copytext(new_hair, 2, 4))
						g_hair = hex2num(copytext(new_hair, 4, 6))
						b_hair = hex2num(copytext(new_hair, 6, 8))
				if("random")
					randomize_hair_color("hair")

		if(link_tags["facial"])
			switch(link_tags["facial"])
				if("input")
					var/new_facial = input(user, "Please select facial hair color.", "Character Generation") as color
					if(new_facial)
						r_facial = hex2num(copytext(new_facial, 2, 4))
						g_facial = hex2num(copytext(new_facial, 4, 6))
						b_facial = hex2num(copytext(new_facial, 6, 8))
				if("random")
					randomize_hair_color("facial")

		if(link_tags["eyes"])
			switch(link_tags["eyes"])
				if("input")
					var/new_eyes = input(user, "Please select eye color.", "Character Generation") as color
					if(new_eyes)
						r_eyes = hex2num(copytext(new_eyes, 2, 4))
						g_eyes = hex2num(copytext(new_eyes, 4, 6))
						b_eyes = hex2num(copytext(new_eyes, 6, 8))
				if("random")
					randomize_eyes_color()

		if(link_tags["s_tone"])
			switch(link_tags["s_tone"])
				if("random")
					randomize_skin_tone()
				if("input")
					var/new_tone = input(user, "Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text
					if(new_tone)
						s_tone = max(min(round(text2num(new_tone)), 220), 1)
						s_tone = -s_tone + 35

		if(link_tags["h_style"])
			switch(link_tags["h_style"])

				// New and improved hair selection code, by Doohl
				if("random") // random hair selection

					randomize_hair(gender) // call randomize_hair() proc with var/gender parameter
					// see preferences_setup.dm for proc

				if("input") // input hair selection

					// Generate list of hairs via typesof()
					var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair

					// List of hair names
					var/list/hairs = list()

					// loop through potential hairs
					for(var/x in all_hairs)
						var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
						hairs.Add(H.name) // add hair name to hairs
						del(H) // delete the hair after it's all done

					// prompt the user for a hair selection, the selection being anything in list hairs
					var/new_style = input(user, "Select a hair style", "Character Generation")  as null|anything in hairs

					// if new style selected (not cancel)
					if(new_style)
						h_style = new_style

						for(var/x in all_hairs) // loop through all_hairs again. Might be slightly CPU expensive, but not significantly.
							var/datum/sprite_accessory/hair/H = new x // create new hair datum
							if(H.name == new_style)
								hair_style = H // assign the hair_style variable a new hair datum
								break
							else
								del(H) // if hair H not used, delete. BYOND can garbage collect, but better safe than sorry

		if(link_tags["ooccolor"])
			var/ooccolor = input(user, "Please select OOC colour.", "OOC colour") as color

			if(ooccolor)
				src.ooccolor = ooccolor

		if(link_tags["f_style"])
			switch(link_tags["f_style"])

				// see above for commentation. This is just a slight modification of the hair code for facial hairs
				if("random")

					randomize_facial(gender)

				if("input")

					var/list/all_fhairs = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
					var/list/fhairs = list()
					for(var/x in all_fhairs)
						var/datum/sprite_accessory/facial_hair/H = new x
						fhairs.Add(H.name)
						del(H)

					var/new_style = input(user, "Select a facial hair style", "Character Generation")  as null|anything in fhairs
					if(new_style)
						f_style = new_style
						for(var/x in all_fhairs)
							var/datum/sprite_accessory/facial_hair/H = new x
							if(H.name == new_style)
								facial_hair_style = H
								break
							else
								del(H)

		if(link_tags["gender"])
			if(gender == MALE)
				gender = FEMALE
			else
				gender = MALE

		if(link_tags["UI"])
			if(UI == UI_OLD)
				UI = UI_NEW
			else
				UI = UI_OLD

		if(link_tags["midis"])
			midis = (midis+1)%2

		if(link_tags["underwear"])
			if(!IsGuestKey(user.key))
				switch(link_tags["underwear"])
					if("random")
						if(prob (75))
							underwear = 1
						else
							underwear = 0
					if("input")
						if(underwear == 1)
							underwear = 0
						else
							underwear = 1

		if(link_tags["be_special"])
			src.be_special^=(1<<text2num(link_tags["be_special"])) //bitwize magic, sorry for that. --rastaf0

		if(link_tags["b_random_name"])
			be_random_name = !be_random_name

		if(link_tags["flavor_text"])
			var/msg = input(usr,"Set the flavor text in your 'examine' verb. Don't metagame!","Flavor Text",html_decode(flavor_text)) as message

			if(msg != null)
				msg = copytext(msg, 1, MAX_MESSAGE_LEN)
				msg = html_encode(msg)

				flavor_text = msg

		// slot links
		if(!IsGuestKey(user.key))
			if(link_tags["saveslot"])
				var/slot = text2num(link_tags["saveslot"])

				savefile_save(user, slot)

			else if(link_tags["loadslot"])
				var/slot = text2num(link_tags["loadslot"])
				if(link_tags["loadslot"] == "CLOSE")
					closesave(user)
					return
				if(!savefile_load(user, slot))
					alert(user, "You do not have a savefile.")
				else
					curslot = slot
					slotname = savefile_getslots(user)[curslot]
					loadsave(user)
		if(link_tags["removeslot"])
			var/slot = text2num(link_tags["removeslot"])
			if(!slot)
				return

			savefile_removeslot(user, slot)

			usr << "Slot [slot] Deleted."
			curslot = 1
			slotname = savefile_getslots(user)[curslot]
			loadsave(usr)
		if(link_tags["loadslot2"])
			loadsave(user)
		if(link_tags["createslot"])
			var/list/slots = savefile_getslots(user)
			var/count = slots.len
			count++
			if(count > 10)
				usr << "You have reached the character limit."
				return
			slotname = input(usr,"Choose a name for your slot","Name","Slot "+num2text(count))

			curslot = savefile_createslot(user, slotname)

			if(!savefile_load(user, count))
				alert(user, "You do not have a savefile.")
			else
				closesave(user)

		if(link_tags["reset_all"])
			gender = MALE
			randomize_name()

			age = 30
			job_civilian_high = 0
			job_civilian_med = 0
			job_civilian_low = 0
			job_medsci_high = 0
			job_medsci_med = 0
			job_medsci_low = 0
			job_engsec_high = 0
			job_engsec_med = 0
			job_engsec_low = 0
			job_alt_titles = new()
			underwear = 1
			be_special = 0
			be_random_name = 0
			r_hair = 0.0
			g_hair = 0.0
			b_hair = 0.0
			r_facial = 0.0
			g_facial = 0.0
			b_facial = 0.0
			h_style = "Short Hair"
			f_style = "Shaved"
			r_eyes = 0.0
			g_eyes = 0.0
			b_eyes = 0.0
			s_tone = 0.0
			b_type = "A+"
			UI = UI_OLD
			midis = 1
			disabilities = 0
		if(link_tags["disabilities"])
			disabilities ^= (1<<text2num(link_tags["disabilities"])) //MAGIC

		ShowChoices(user)

	proc/copy_to(mob/living/carbon/human/character, safety = 0)
		if(be_random_name)
			randomize_name()
		character.real_name = real_name

		character.flavor_text = flavor_text

		character.gender = gender

		character.age = age
		character.dna.b_type = b_type
		character.be_syndicate = be_special

		character.r_eyes = r_eyes
		character.g_eyes = g_eyes
		character.b_eyes = b_eyes

		character.r_hair = r_hair
		character.g_hair = g_hair
		character.b_hair = b_hair

		character.r_facial = r_facial
		character.g_facial = g_facial
		character.b_facial = b_facial

		character.s_tone = s_tone

		character.h_style = h_style
		character.f_style = f_style

		switch (UI)
			if(UI_OLD)
				character.UI = 'screen1_old.dmi'
			if(UI_NEW)
				character.UI = 'screen1.dmi'

		character.hair_style = hair_style
		character.facial_hair_style = facial_hair_style

		character.underwear = underwear == 1 ? pick(1,2,3,4,5) : 0

		character.update_face()
		character.update_body()

		if(!safety)//To prevent run-time errors due to null datum when using randomize_appearance_for()
			spawn(10)
				if(character&&character.client)
					character.client.midis = midis
					character.client.ooccolor = ooccolor
					character.client.be_alien = be_special&BE_ALIEN
					character.client.be_pai = be_special&BE_PAI

	proc/copydisabilities(mob/living/carbon/human/character)
		if(disabilities & 1)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,GLASSESBLOCK,toggledblock(getblock(character.dna.struc_enzymes,GLASSESBLOCK,3)),3)
		if(disabilities & 2)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,HEADACHEBLOCK,toggledblock(getblock(character.dna.struc_enzymes,HEADACHEBLOCK,3)),3)
		if(disabilities & 4)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,COUGHBLOCK,toggledblock(getblock(character.dna.struc_enzymes,COUGHBLOCK,3)),3)
		if(disabilities & 8)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,TWITCHBLOCK,toggledblock(getblock(character.dna.struc_enzymes,TWITCHBLOCK,3)),3)
		if(disabilities & 16)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,NERVOUSBLOCK,toggledblock(getblock(character.dna.struc_enzymes,NERVOUSBLOCK,3)),3)
		if(disabilities & 32)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,DEAFBLOCK,toggledblock(getblock(character.dna.struc_enzymes,DEAFBLOCK,3)),3)
		//if(disabilities & 64)
			//mute
		//if(disabilities & 128)
			//character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,BLINDBLOCK,toggledblock(getblock(character.dna.struc_enzymes,BLINDBLOCK,3)),3)
		character.disabilities = disabilities

#undef UI_OLD
#undef UI_NEW