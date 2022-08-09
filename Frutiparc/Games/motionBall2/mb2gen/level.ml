open Printf
open Dungeon

type item =
	| BNormal
	| BTime
	| BDeath
	| BMagnet
	| BShadow
	| BBlock
	| BHole
	| BRed
	| BBlue
	| BTeleport
	| Interupt
	| IBlockRed
	| IBlockBlue
	| Zapper
	| ClassicExit

type collide =
	| CNone
	| CBorder
	| CBumper
	| CRedBlue
	| CBlock
	| CHole

let dbg = ref false

let delta = ref 0
let cwidth = ref 0
let cheight = ref 0
let cborder = ref 0
let ball_ray = ref 0.
let red_cwidth = ref 0
let red_cheight = ref 0
let red_ctbl = ref [||]
let pos_nbits = ref 0

let door_size = 110
let pi = 3.14159

let cur_x = ref 0
let cur_y = ref 0

let block_mask = 1 lsl 16
let hole_mask = 1 lsl 17
let bit_mask = 0xFFFF

let nbumpers = 7
let max_bumper_time = 3
let bumpers_tbl = Array.create nbumpers [||]

let classic = ref false
let classic_enter = ref null_pos
let classic_exit = ref null_pos
let classic_exit_tbl = Array.create 10 (Array.create 10 true)

let bumper_for_object = function
	| Green -> BBlock
	| Blue -> BHole
	| Metal -> BMagnet
	| Violet -> BShadow

let collide_for_object = function
	| Green -> CBlock
	| Blue -> CHole
	| Metal
	| Violet -> assert false

let new_table w h v =
	Array.init w (fun _ -> Array.create h v)

let special_ctbl = new_table 10 10 true

let log s =
	prerr_endline s;
	flush stderr

let all_dirs f = List.iter f [Up;Down;Left;Right]

let fill a f =
	for x = 0 to Array.length a -1 do
		for y = 0 to Array.length a.(x) - 1 do
			Array.unsafe_set (Array.unsafe_get a x) y (f { x = x ; y = y })
		done;
	done

let scan a f =
	for x = 0 to Array.length a -1 do
		for y = 0 to Array.length a.(x) - 1 do
			f { x = x ; y = y } (Array.unsafe_get (Array.unsafe_get a x) y)
		done;
	done

let transl p tbl =
	let w = Array.length tbl in
	let h = Array.length tbl.(0) in
	if w mod 2 = 1 || h mod 2 = 1 then failwith "Invalid table";
	{ x = p.x + w / 2; y = p.y + h / 2; }

let random = Random.int

let random2 min max =
	if max <= min then
		max
	else
		random (max - min + 1) + min

let move p = function
	| Up -> { x = p.x; y = p.y - 1 }
	| Down -> { x = p.x; y = p.y + 1 }
	| Left -> { x = p.x - 1; y = p.y }
	| Right -> { x = p.x + 1; y = p.y }

let rpath r = function
	| Up -> r.rup
	| Left -> r.rleft
	| Right -> r.rright
	| Down -> r.rdown

let path d p =
	rpath d.dmap.(p.x).(p.y)

let compute_dists d =
	let m = new_table Dungeon.fixed_width Dungeon.fixed_height (-1) in
	let rec loop p n =
		m.(p.x).(p.y) <- n;
		all_dirs (fun dir ->
			if path d p dir <> Closed then begin
				let p2 = move p dir in
				let n2 = m.(p2.x).(p2.y) in
				if n2 = -1 || n2 > (n+1) then loop p2 (n+1)
			end
		)
	in
	loop d.dstart 0;
	let tot = ref 0 in
	let nroom = ref 0 in
	scan m (fun _ n -> if n != -1 then begin incr nroom; tot := !tot + n; end);
	m , !tot / !nroom
	
let new_col_table() =
	let ctbl = new_table !cwidth !cheight CNone in
	for x = 0 to !cborder - 1 do
		for y = 0 to !cheight - 1 do
			ctbl.(x).(y) <- CBorder;
			ctbl.(!cwidth - x - 1).(y) <- CBorder;
		done;
	done;
	for y = 0 to !cborder - 1 do
		for x = 0 to !cwidth - 1 do
			ctbl.(x).(y) <- CBorder;
			ctbl.(x).(!cheight - y - 1) <- CBorder;
		done;
	done;
	ctbl

let gen_pos ctbl btbl txt =	
	let rec loop n = 
		if n = 100 then raise (Retry txt);
		let px = random2 !cborder (!cwidth - !cborder * 2 - Array.length btbl) in
		let py = random2 !cborder (!cheight - !cborder * 2 - Array.length btbl.(0)) in
		try
			scan btbl (fun p c -> if c && ctbl.(px+p.x).(py+p.y) <> CNone then raise Exit);
			{ x = px; y = py; }
		with
			Exit -> loop (n+1)
	in
	loop 0

let compute_room_tbl ctbl spos =
	let fdelta = float_of_int !delta in
	let demi_delta = fdelta /. 2. in
	let bray = !ball_ray +. demi_delta in
	let cb = !cborder / 2 in
	let m = new_table !cwidth  !cheight (-1) in
	for y = cb to !cheight - 1 - cb do
		for x = cb to !cwidth  - 1 - cb do	
			let sx = (float_of_int x +. 0.5) *. fdelta in
			let sy = (float_of_int y +. 0.5) *. fdelta in
			let rec loop n acc =
				if n = 32 then
					acc
				else
					let ang = (float_of_int n) *. 2. *. pi /. 32. in
					let px = int_of_float ((sx +. cos(ang) *. bray ) /. fdelta) in
					let py = int_of_float ((sy +. sin(ang) *. bray ) /. fdelta) in
					match Array.unsafe_get (Array.unsafe_get ctbl px) py with
					| CNone | CRedBlue ->
						loop (n+1) acc
					| CHole ->
						loop (n+1) (acc lor hole_mask)
					| CBlock ->
						loop (n+1) (acc lor block_mask)
					| _ ->
						-1
			in
			Array.unsafe_set (Array.unsafe_get m x) y (loop 0 0)
		done
	done;
	let get x y =
		Array.unsafe_get (Array.unsafe_get m x) y
	in
	let rec loop x y acc =
		let b = get x y in
		let acc = acc lor (b land (hole_mask lor block_mask)) in
		Array.unsafe_set (Array.unsafe_get m x) y (if b = -1 then 1 else ((b+1) lor acc));
		if ((get (x-1) y) land bit_mask) = 0 then loop (x-1) y acc;
		if ((get (x+1) y) land bit_mask) = 0 then loop (x+1) y acc;
		if ((get x (y-1)) land bit_mask) = 0 then loop x (y-1) acc;
		if ((get x (y+1)) land bit_mask) = 0 then loop x (y+1) acc;
	in
	loop spos.x spos.y 0;
	m

let fill_pos ctbl btbl p v =
	scan btbl (fun p2 c -> if c then ctbl.(p.x+p2.x).(p.y+p2.y) <- v)

let print_room lvl nreds nbumpers ctbl mtbl =
	eprintf "Level : %d - POS = %d , %d - reds : %d - bumpers : %d\n" lvl !cur_x !cur_y nreds nbumpers;
	for y = 0 to !cheight - 1 do
		for x = 0 to !cwidth - 1 do
			prerr_char (match ctbl.(x).(y) , mtbl.(x).(y) with
				| CNone , 1 -> ' '
				| CNone , _ -> '.'
				| CBorder , _ -> '#'
				| CBumper , _ -> '*'
				| CRedBlue , _ -> 'o'
				| CBlock, _ -> '#'
				| CHole , _ -> '"')
		done;
		prerr_newline();
	done

let fill_doors r ctbl =
	let blist = ref [] in
	let spos = ref { x = -1; y = -1 } in
	let fill_door r sx sy dx dy dpx dpy =
		if r <> Closed then begin
			for x = 0 to dx - 1 do
				for y = 0 to dy - 1 do
					ctbl.(x+sx).(y+sy) <- CNone;
				done;
			done;
			match r with
			| Opened 
			| Invisible ->
				spos := { x = sx + dpx; y = sy + dpy }
			| Closed
			| DoorNeed _ ->
				()
		end;
	in
	let wall_xmax = (!cwidth - !cborder * 2) / 10 - 1 in
	let wall_ymax = (!cheight - !cborder * 2) / 10 - 1 in
	let blist = ref [] in
	let fill_block path sx sy ex ey =
		match path with
		| DoorNeed t ->
			let c = collide_for_object t in
			let b = bumper_for_object t in
			for x = sx to ex do
				for y = sy to ey do
					let sx = !cborder + x * 10 in
					let sy = !cborder + y * 10 in
					blist := (b,{ x = sx; y = sy; }) :: !blist;
					for i = 0 to 9 do
						for j = 0 to 9 do
							ctbl.(sx+i).(sy+j) <- c;
						done;
					done;
				done;
			done;
		| _ -> ()
	in
	let cb = !cborder - 1 in
	let door_csize = (door_size + !delta - 1) / !delta in
	let door_x = (!cwidth - door_csize) / 2 in
	let door_y = (!cheight - door_csize) / 2 in
	fill_door r.rleft 1 door_y cb door_csize (cb - 1) (door_csize / 2);
	fill_door r.rright (!cwidth - !cborder) door_y cb door_csize (1 - cb) (door_csize / 2);
	fill_door r.rup door_x 1 door_csize cb (door_csize / 2) (cb - 1);
	fill_door r.rdown door_x (!cheight - !cborder) door_csize cb (door_csize / 2) (1 - cb);
	fill_block r.rleft 1 0 1 wall_ymax;
	fill_block r.rright (wall_xmax - 1) 0 (wall_xmax - 1) wall_ymax;
	fill_block r.rup 0 1 wall_xmax 1;
	fill_block r.rdown 0 (wall_ymax - 1) wall_xmax (wall_ymax - 1);
	assert (!spos.x <> -1);
	!spos , !blist

let calc_mask obj =
	0xFFFFFF - (match obj with
	| None -> 0
	| Some Green -> block_mask
	| Some Blue -> hole_mask
	| _ -> assert false)

let check_red p mtbl obj =
	let mask = calc_mask obj in
	for x = 0 to !red_cwidth - 1 do
		for y = 0 to !red_cheight - 1 do
			if mtbl.(p.x + x).(p.y + y) land mask <> 1 then raise (Retry "check red");
		done;
	done

let put_redblue mtbl ctbl obj =
	let rec loop n = 
		if n = 0 then raise (Retry "put redblue");
		let p = gen_pos ctbl !red_ctbl "redblue" in
		try
			check_red p mtbl obj;
			fill_pos ctbl !red_ctbl p CRedBlue;
			p
		with
			Retry _  -> loop (n-1)
	in
	loop 100

let rec gen_redblues mtbl ctbl obj n t =
	if n <= 0 then
		[]
	else
		let p = put_redblue mtbl ctbl obj in
		(t,p) :: (gen_redblues mtbl ctbl obj (n - 1) t)

let check_doors r mtbl obj =
	let mask = calc_mask obj in
	let check_door r sx sy dx dy =
		if r <> Closed then begin
			let mask = (match r with DoorNeed obj -> mask land (calc_mask (Some obj)) | _ -> mask) in
			for x = 0 to dx - 1 do
				for y = 0 to dy - 1 do
					if mtbl.(x+sx).(y+sy) land mask <> 1 then raise (Retry "check door");
				done;
			done;
		end
	in
	let cb = !cborder - 1 in
	let door_csize = (door_size + !delta - 1) / !delta - 6 in
	let door_x = (!cwidth - door_csize) / 2 in
	let door_y = (!cheight - door_csize) / 2 in
	check_door r.rleft cb door_y 1 door_csize;
	check_door r.rright (!cwidth - !cborder) door_y 1 door_csize;
	check_door r.rup door_x cb door_csize 1;
	check_door r.rdown door_x (!cheight - !cborder) door_csize 1

let fill_wall blist x y ctbl c btype =
	let sx = !cborder + x * 10 in
	let sy = !cborder + y * 10 in
	if ctbl.(sx).(sy) = CNone then begin
		blist := (btype,{ x = sx; y = sy; }) :: !blist;
		for i = 0 to 9 do
			for j = 0 to 9 do
				ctbl.(i + sx).(j + sy) <- c;
			done;
		done;
	end

let object_needed (d,p) obj =
	List.for_all (fun (_,l) ->
		List.exists (( = ) obj) l
	) d.dist_table.(p.x).(p.y)

let gen_separators r ctbl btype ecart =
	let xmin = 0 in
	let ymin = 0 in
	let xmax = ((!cwidth - !cborder*2) / 10) in
	let ymax = ((!cheight - !cborder*2) / 10) in
	let xdoor = xmax / 2 - 1 in
	let xdoor2 = xmax / 2 + 1 in
	let ydoor = ymax / 2 - 1 in
	let ydoor2 = ymax / 2 + 1 in
	let blist = ref [] in
	let rec loop horiz n =
		if n = 0 then () else
		let yp = random2 (ymin+1+ecart/2) (ymax-2-(ecart-1)/2) in
		let xp = random2 (xmin+1+ecart/2) (xmax-2-(ecart-1)/2) in
		if (not horiz) && xp >= xdoor && xp <= xdoor2 && (r.rup <> Closed || r.rdown <> Closed) then loop horiz (n-1) else
		if horiz && yp >= ydoor && yp <= ydoor2 && (r.rleft <> Closed || r.rright <> Closed) then loop horiz (n-1) else
		if (not horiz) && not ((xp >= xdoor2 && r.rright <> Closed) || (xp <= xdoor && r.rleft <> Closed)) then loop horiz (n-1) else
		if horiz && not ((yp >= ydoor2 && r.rdown <> Closed) || (yp <= ydoor && r.rup <> Closed)) then loop horiz (n-1) else
		match horiz with
		| true ->
			for x = xmin to xmax - 1 do
				if x < xp-(ecart/2) || x > xp+(ecart-1)/2 then fill_wall blist x yp ctbl CBorder btype
			done;
		| false ->
			for y = ymin to ymax - 1 do
				if y < yp-(ecart/2) || y > yp+(ecart-1)/2 then fill_wall blist xp y ctbl CBorder btype;
			done;
	in
	let horiz = Random.bool() in
	loop horiz 2;
	if !blist <> [] then loop (not horiz) 2;
	!blist

let gen_object_need ctbl obj =
	let blist = ref [] in
	let c = collide_for_object obj in
	let b = bumper_for_object obj in
	let xmax = (!cwidth - !cborder*2) / 10 - 1 in
	let ymax = (!cheight - !cborder*2) / 10 - 1 in
	let xsize = random2 (if obj = Blue then 4 else 3) (xmax - 2) - 1 in
	let ysize = random2 (if obj = Blue then 4 else 3) (ymax - 2) - 1 in
	let xp = random2 1 (xmax - 1 - xsize) in
	let yp = random2 1 (ymax - 1 - ysize) in
	for i = xp to xp+xsize do
		fill_wall blist i yp ctbl c b;
		fill_wall blist i (yp+ysize) ctbl c b;
	done;
	for j = yp to yp+ysize do
		fill_wall blist xp j ctbl c b;
		fill_wall blist (xp+xsize) j ctbl c b;
	done;
	let p = {
		x = xp*10 + (xsize+1)*5 + !red_cwidth / 2;
		y = yp*10 + (ysize+1)*5 + !red_cheight / 2;
	} in
	fill_pos ctbl !red_ctbl p CRedBlue;
	(BRed,p) :: !blist

let gen_exit ctbl =
	try
		let px , py = (!classic_exit).x, (!classic_exit).y in
		scan classic_exit_tbl (fun p c -> if c && ctbl.(px+p.x).(py+p.y) <> CNone then raise Exit);
		let p = { x = px; y = py } in
		fill_pos ctbl classic_exit_tbl p CHole;		
	with
		Exit -> failwith "cannot put exit"

let gen_normal_room dp r lvl obj =
	let min_bumpers = (lvl * 1 / 3) + 5 in
	let max_bumpers = (lvl * 3 / 3) + 7 in
	let nbumpers = min (random2 min_bumpers max_bumpers) 30 in
	let available_btime = ref max_bumper_time in
	let available_magnet = ref (if object_needed dp Metal && random 2 = 0 then min (random2 0 4) (random2 0 4) else min (random2 0 1) (random2 0 1)) in
	let available_shadow = ref (if object_needed dp Violet && random 3 = 0 then min (random2 0 2) (random2 0 2) else 0) in
	let ctbl = new_col_table() in
	let spos , blist = (match !classic with
		| false -> 
			let p , bl = fill_doors r ctbl in			
			(if lvl = 0 then { x = !cwidth / 2; y = !cheight / 2 } else p) , bl
		| true -> 
			let p = !classic_enter in
			if random2 0 5 <> 0 then begin
				available_magnet := 0;
				available_shadow := 0;
			end;
			{ x = p.x + 5; y = p.y + 5}, [])
	in
	let blist = ref blist in
	if !classic then begin
		gen_exit ctbl;
		blist := (ClassicExit,!classic_exit) :: !blist;
	end;
	(match obj with
	| None -> ()
	| Some obj ->
		blist := !blist @ (gen_object_need ctbl obj)
	);
	if not !classic then blist := !blist @ (gen_separators r ctbl (if random 3 = 0 then BHole else BBlock) (max (5-lvl/4) 1));
	let bumpers = Array.init nbumpers (fun _ ->
		if random(100) < lvl * 100 / 40 then begin
			if !available_magnet > 0 then begin
				decr available_magnet;
				BMagnet , bumpers_tbl.(3)
			end else if !available_shadow > 0 then begin
				decr available_shadow;
				BShadow , bumpers_tbl.(4)
			end else if !available_btime > 0 && random 5 <> 0 then begin
				decr available_btime;
				BTime , bumpers_tbl.(1)
			end else
				BDeath , bumpers_tbl.(2)
		end else
			BNormal , bumpers_tbl.(0)
	) in
	Array.iter (fun (btype,btbl) ->
		let rec get_pos() =
			let pos = gen_pos ctbl btbl "bumper" in
			match btype with
			(* too much near from the borders -- doors *)
			| BMagnet | BDeath when pos.x < 15 || pos.y < 15 || pos.x > !cwidth - 15 || pos.y > !cheight - 15 -> get_pos()
			| _ -> pos
		in
		let pos = get_pos() in
		fill_pos ctbl btbl pos CBumper;
		blist := (btype,pos) :: !blist;
	) bumpers;
	let min_reds = lvl / 3 + 1 in
	let max_reds = (lvl * 2 / 3) + 1 in
	let mtbl = compute_room_tbl ctbl spos in 
	let nblues , nreds =
		match !classic with
		| false -> min (random2 0 4) (random2 0 4) - 1 , min (random2 min_reds max_reds) 10
		| true -> min (random2 0 3) (random2 0 3) - 1 , min (random2 (lvl * 2 / 3) lvl) 10
	in
	List.iter (fun (t,p) -> if t = BRed then check_red p mtbl obj) !blist;
	check_doors r mtbl obj;
	blist := !blist @ (gen_redblues mtbl ctbl obj nreds BRed) @ (gen_redblues mtbl ctbl obj nblues BBlue);
(*//if !dbg then print_room lvl nreds nbumpers ctbl mtbl;*)
	!blist

let gen_special_room r obj = 
	let ctbl = new_col_table() in
	let btype , btbl , nbumpers = (match obj with
		| Metal -> BMagnet , bumpers_tbl.(3) , 20
		| Violet -> BShadow , bumpers_tbl.(4) , 20
		| _ -> assert false
	) in
	let spos , blist = fill_doors r ctbl in
	let blist = ref blist in
	blist := !blist @ (gen_separators r ctbl BHole 3);
	for i = 1 to nbumpers do
		let pos = gen_pos ctbl btbl "spe-bumper" in
		fill_pos ctbl btbl pos CBumper;
		blist := (btype,pos) :: !blist;
	done;
	let ndeaths = random2 2 5 in
	let deathtbl = bumpers_tbl.(2) in
	for i = 1 to ndeaths do
		let pos = gen_pos ctbl deathtbl "death" in
		fill_pos ctbl deathtbl pos CBumper;
		blist := (BDeath,pos) :: !blist;
	done;
	let nreds = random2 4 10 in
	let mtbl = compute_room_tbl ctbl spos in 
	List.iter (fun (t,p) -> if t = BRed then check_red p mtbl None) !blist;
	check_doors r mtbl None;
	blist := !blist @ (gen_redblues mtbl ctbl None nreds BRed);
	if !dbg then print_room (-1) nreds (nbumpers + ndeaths) ctbl mtbl;
	!blist
	
let gen_room dp lvl r =
	match r.rtype with
	| None -> None
	| Some rt ->
		match rt with
		| End
		| ObjectFound _
		| BonusFound _ ->
			None
		| Start
		| Normal ->
			Some (gen_normal_room dp r lvl None)
		| ObjectNeeded obj ->
			match obj with
			| Green | Blue ->
				Some (gen_normal_room dp r lvl (Some obj))
			| Violet when random 4 <> 0 ->
				Some (gen_special_room r obj)
			| Metal when random 3 <> 0 ->
				Some (gen_special_room r obj)
			| Violet | Metal ->
				Some (gen_normal_room dp r lvl None)

let rec gen_room_rec dp dist r count =
	if count = 0 then failwith (sprintf "Aborted at pos %d %d" !cur_x !cur_y);
	try
		let lvl = (match dist with
			| -1 -> -1
			| 0 -> 0
			| _ -> 1 + random2 (dist * 2 / 3) dist) in
		gen_room dp dist r
	with
		Retry msg ->
			if !dbg then prerr_endline msg;
			gen_room_rec dp dist r (count - 1)

let rec gen_room_lvl_rec dp lvl r count =
	if count = 0 then failwith (sprintf "Aborted at pos %d %d" !cur_x !cur_y);
	try
		gen_room dp lvl r
	with
		Retry msg ->
			if !dbg then prerr_endline msg;
			gen_room_lvl_rec dp lvl r (count - 1)

let encode_room b r =
	let encode_nbits = BitCodec.write b in	
	let encode_item (t,pos) = 
		encode_nbits 4 (match t with
			| BNormal -> 1
			| BTime -> 2
			| BDeath -> 3
			| BMagnet -> 4
			| BShadow -> 5
			| BBlock -> 6
			| BHole -> 7
			| BRed -> 8
			| BBlue -> 9
			| BTeleport -> 10
			| Interupt -> 11
			| IBlockRed -> 12
			| IBlockBlue -> 13
			| Zapper -> 14
			| ClassicExit -> 15);
		encode_nbits !pos_nbits pos.x;
		encode_nbits !pos_nbits pos.y;
	in
	match r with
	| None ->
		encode_nbits 1 0
	| Some rlist ->
		encode_nbits 1 1;
		List.iter encode_item rlist;
		encode_nbits 4 0

let load_bumpers() =
	let file = "bumpers.txt" in
	let ch = open_in file in
	let data = input_line ch in
	close_in ch;
	let b = BitCodec.decode_b64 data in
	delta := BitCodec.read b 5;
	cwidth := BitCodec.read b 10;
	cheight := BitCodec.read b 10;
	cborder := BitCodec.read b 5;
	red_cwidth := BitCodec.read b 5;
	red_cheight := BitCodec.read b 5;
	ball_ray := float_of_int (BitCodec.read b 8) /. 10. *. 1.3;
	for i = 0 to nbumpers - 1 do 
		let width = BitCodec.read b 5 in
		let height = BitCodec.read b 5 in
		let coltable = new_table width height false in
		bumpers_tbl.(i) <- coltable;
		fill coltable (fun _ -> BitCodec.read b 1 = 1);
	done;
	red_ctbl := new_table !red_cwidth !red_cheight true;
	pos_nbits := Dungeon.calc_bits (max !cwidth !cheight)

let make() =
	log "Generating dungeon...";
	let ddata = Dungeon.make () in
	let dists , dmoy = compute_dists ddata in
	let b = BitCodec.encode_b64() in
	Dungeon.encode b ddata;
	BitCodec.flush b;
	prerr_string "Generating rooms";
	scan ddata.dmap (fun p r ->
		prerr_char '.';
		flush stderr;
		cur_x := p.x;
		cur_y := p.y;
		let r = gen_room_rec (ddata,{x=p.x;y=p.y}) (dists.(p.x).(p.y) * 10 / dmoy) r 1000 in
		encode_room b r;
	);
	let s = BitCodec.to_string b in
	let dlen = String.length s in
	eprintf "Size : %d - Avg : %d\n" dlen (dlen / (Dungeon.fixed_width * Dungeon.fixed_height));
	print_endline ("ddata="^s);
	()

let random_exit() =
	let xmax = (!cwidth - !cborder*2) / 10 - 1 in
	let ymax = (!cheight - !cborder*2) / 10 -1 in
	let px = !cborder + (random2 0 xmax) * 10 in
	let py = !cborder + (random2 0 ymax) * 10 in
	{ x = px; y = py }

let make_classic choice_rooms =
	let nrooms = 100 in
	classic := true;
	classic_enter := { x = !cwidth / 2 - 3; y = !cheight / 2 - 3 };
	classic_exit := random_exit();
	log "Generatic classic rooms...";
	let ddata = Dungeon.make_empty nrooms choice_rooms in
	let b = BitCodec.encode_b64() in
	Dungeon.encode b ddata;
	BitCodec.flush b;
	for j = 0 to nrooms - 1 do 
		for i = 0 to choice_rooms - 1 do
			let r = gen_room_lvl_rec (ddata,{x = j; y = i}) (j/2) ddata.dmap.(j).(i) 1000 in
			prerr_char '.';
			flush stderr;
			encode_room b r;
		done;
		classic_enter := !classic_exit;
		classic_exit := random_exit();
	done;
	let s = BitCodec.to_string b in
	let dlen = String.length s in
	eprintf "Size : %d - Avg : %d\n" dlen (dlen / (choice_rooms * nrooms));
	print_endline ("ddata="^s);
	()
