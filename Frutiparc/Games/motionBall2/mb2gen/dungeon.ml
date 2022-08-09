open Printf

type pos = {
	mutable x : int;
	mutable y : int;
}

type obj =
	| Green
	| Blue
	| Metal
	| Violet

type bonus =
	| Orange
	| RedBall
	| Map
	| Radar
	| Key
	| SmallTime
	| BigTime

type direction =
	| Up
	| Down
	| Left 
	| Right

type room_type =
	| Normal
	| Start
	| End
	| ObjectFound of obj
	| ObjectNeeded of obj
	| BonusFound of bonus

type path =
	| Opened
	| Closed
	| Invisible
	| DoorNeed of obj

type imp_path =
	| NotYet
	| Path of direction
	| TooMuch

type room = {
	mutable rtype : room_type option;
	mutable rup : path;
	mutable rdown : path;
	mutable rleft : path;
	mutable rright : path;
	rpos : pos;
}

type dungeon = {
	dmap : room array array;
	dwidth : int;
	dheight : int;
	mutable dstart : pos;
	mutable dexit : pos;
	mutable dist : int;
	mutable dist_table : (int * obj list) list array array;
}

exception Retry of string
exception Move_out


let fixed_width = 8
let fixed_height = 8

let objects = [| Green; Blue; Metal; Violet |] 
let objects_count = Array.length objects

let bonuses = [| Orange; RedBall; Map; Radar; Key; SmallTime; BigTime |]
let bonus_counts = [| (1, 1); (1, 1); (1,1); (1, 1); (0, 99); (0, 99); (0, 2) |]
let bonus_probas = [| 10; 10; 10; 10; 6; 7; 2 |]
let bonus_min_count = Array.fold_left (fun acc (min,_) -> acc + min) 0 bonus_counts

let can_block_only_door = function
	| Green
	| Blue -> Random.bool()
	| Metal
	| Violet -> false

let can_have_invisible_door = function
	| Orange
	| RedBall -> Random.bool()
	| Map -> false
	| Radar
	| Key
	| SmallTime -> Random.int 4  = 0
	| BigTime ->
		true

let dirs = [Up;Down;Left;Right]
let adirs = [|Up;Down;Left;Right|]
let null_pos = { x = -1; y = -1 }
let retries = Hashtbl.create 0

let print_retries () =
	Hashtbl.iter (fun s n -> printf "%s : %d\n" s n) retries

let submit_retry s =
	let n = (try Hashtbl.find retries s with Not_found -> 0) in
	Hashtbl.replace retries s (n+1)

let new_table d ival =
	Array.init d.dwidth (fun _ -> Array.create d.dheight ival)

let new_room x y = {
	rtype = None;
	rpos = { x = x; y = y; };
	rup = Closed;
	rdown = Closed;
	rleft = Closed;
	rright = Closed;
}

let room d p =
	d.dmap.(p.x).(p.y)

let rtype d p =
	(room d p ).rtype

let rand_pos d =
	{
		x = Random.int d.dwidth;
		y = Random.int d.dheight;
	}

let ashuffle a =
	let len = Array.length a in	
	for i = 0 to len-1 do
		let p = Random.int (len-i) + i in
		let tmp = a.(p) in
		a.(p) <- a.(i);
		a.(i) <- tmp;
	done

let shuffle a =
	ashuffle a;
	Array.to_list a

let scan a f =
	for x = 0 to Array.length a -1 do
		for y = 0 to Array.length a.(x) - 1 do
			f { x = x ; y = y } a.(x).(y)
		done;
	done

let make_list max =
	let rec loop = function
		| n when n = max -> []
		| n -> n :: loop (n+1)
	in
	loop 0

let move d p = function
	| Up when p.y = 0 -> raise Move_out
	| Down when p.y = d.dheight - 1 -> raise Move_out
	| Left when p.x = 0 -> raise Move_out
	| Right when p.x = d.dwidth - 1 -> raise Move_out
	| Up -> { x = p.x; y = p.y - 1 }
	| Down -> { x = p.x; y = p.y + 1 }
	| Left -> { x = p.x - 1; y = p.y }
	| Right -> { x = p.x + 1; y = p.y }

let dinv = function
	| Up -> Down
	| Down -> Up
	| Left -> Right
	| Right -> Left

let set_path d p dir pval = 
	let r = d.dmap.(p.x).(p.y) in
	match dir with
	| Up -> r.rup <- pval
	| Left -> r.rleft <- pval
	| Right -> r.rright <- pval
	| Down -> r.rdown <- pval

let get_room_path r = function
	| Up -> r.rup
	| Left -> r.rleft
	| Right -> r.rright
	| Down -> r.rdown

let get_path d p dir = 
	let r = d.dmap.(p.x).(p.y) in
	get_room_path r dir

let new_dungeon width height =
	let null_room = new_room (-1) (-1) in
	let m = Array.init width (fun i -> Array.init height (fun j -> new_room i j)) in
	{
		dmap = m;
		dist = 0;
		dwidth = width;
		dheight = height;
		dstart = null_pos;
		dexit = null_pos;
		dist_table = Array.create 0 (Array.create 0 []);
	}

let char_obj = function
	| Green -> 'G'
	| Blue -> 'B'
	| Metal -> 'M'
	| Violet -> 'V'

let char_bonus = function
	| Orange -> 'O'
	| RedBall -> 'R'
	| Map -> 'C'
	| Radar -> 'X'
	| Key -> 'K'
	| BigTime -> 'T'
	| SmallTime -> 't'

let char_path horiz = function
	| Opened -> ' '
	| Closed when horiz -> '\205'
	| Closed -> '\186'
	| Invisible when horiz -> '-' 
	| Invisible -> '|'
	| DoorNeed obj -> Char.lowercase (char_obj obj)

let char_rtype = function
	| None -> assert false
	| Some t ->
		match t with
		| Normal -> ' '
		| Start -> 'S'
		| End -> 'E'
		| ObjectFound obj -> char_obj obj
		| ObjectNeeded obj -> Char.lowercase (char_obj obj)
		| BonusFound bon -> char_bonus bon

let print_dungeon d =
	for j = 0 to d.dheight - 1 do
		for i = 0 to d.dwidth - 1 do
			let room = d.dmap.(i).(j) in
			match room.rtype with
			| None -> eprintf "\176\176\176"
			| Some _ -> eprintf "\201%c\187" (char_path true room.rup)
		done;
		eprintf "\n";
		for i = 0 to d.dwidth - 1 do
			let room = d.dmap.(i).(j) in
			match room.rtype with
			| None -> eprintf "\176\176\176"
			| Some _ -> eprintf "%c%c%c" (char_path false room.rleft) (char_rtype room.rtype) (char_path false room.rright)
		done;
		eprintf "\n";
		for i = 0 to d.dwidth - 1 do
			let room = d.dmap.(i).(j) in
			match room.rtype with
			| None -> eprintf "\176\176\176"
			| Some _ -> eprintf "\200%c\188" (char_path true room.rdown)
		done;
		eprintf "\n";
	done

let almost_close d p =
	let rec loop b = function
		| [] -> ()
		| dir :: l when b && get_path d p dir <> Closed ->
			set_path d p dir Closed;
			set_path d (move d p dir) (dinv dir) Closed;
			loop b l
		| dir :: l when get_path d p dir <> Closed ->
			loop true l
		| _ :: l ->
			loop b l
	in
	loop false (shuffle adirs)

let rec random_room d rt =
	let p = rand_pos d in
	match rtype d p with
	| None ->
		d.dmap.(p.x).(p.y).rtype <- Some rt;
		p
	| Some _ ->
		random_room d rt

let rec gen_room d p =
	let rec loop ep = function
		| [] -> ep
		| dir :: l ->
			try
				let np = move d p dir in
				match rtype d np with
				| None ->
					d.dmap.(np.x).(np.y).rtype <- Some Normal;
					set_path d p dir Opened;
					set_path d np (dinv dir) Opened;
					let np = gen_room d np in
					if Random.int 3 = 0 then
						loop np l
					else
						np
				| Some _ -> loop ep l
			with
				Move_out -> loop ep l
	in
	loop p (shuffle adirs)

let rec gen_path d s =
	let p = rand_pos d in
	let rec loop = function
		| [] -> gen_path d s
		| Up :: l when p.y = 0 -> loop l
		| Left :: l when p.x = 0 -> loop l
		| Down :: l when p.y = d.dheight - 1 -> loop l
		| Right :: l when p.x = d.dwidth - 1 -> loop l
		| dir :: l when get_path d p dir = s -> loop l
		| dir :: l ->
			set_path d p dir s;
			let p = move d p dir in
			set_path d p (dinv dir) s;
	in
	if rtype d p = None then
		gen_path d s
	else
		loop (shuffle adirs)

let gen_path_map d sp =
	let m = new_table d (-1) in
	let rec loop p n =
		m.(p.x).(p.y) <- n;
		List.iter (fun dir ->
			if get_path d p dir <> Closed then begin
				let p2 = move d p dir in
				let n2 = m.(p2.x).(p2.y) in
				if n2 = -1 || n2 > (n+1) then loop p2 (n+1)
			end
		) dirs
	in
	loop sp 0;
	m

let rec gen_objects d m =
	let tot_dist = ref 0 in
	let obj_count = ref 0 in
	let objects_found = ref [] in
	let objects_rooms = ref [] in
	let mtbl = new_table d (-1) in
	let rec loop p acc =
		let n = m.(p.x).(p.y) in
		mtbl.(p.x).(p.y) <- !tot_dist;
		incr tot_dist;
		let rec next flag acc = function
			| [] ->
				let nways = List.fold_left (fun acc dir -> if get_path d p dir = Closed then acc else acc + 1) 0 dirs in
				if nways = 1 && !obj_count < objects_count then begin
					objects_found := (p,!obj_count) :: !objects_found;				
					let pl = Array.create (Random.int 3 + 1) !obj_count in
					incr obj_count;
					Array.append pl acc;
				end else
					acc
			| dir :: l when get_path d p dir = Closed ->
				next flag acc l
			| dir :: l ->
				let p2 = move d p dir in
				if mtbl.(p2.x).(p2.y) = -1 then begin
					let n2 = m.(p2.x).(p2.y) in
					let gen_door() = 
						if Array.length acc > 0 && Random.int 6 = 0 then begin
							ashuffle acc;
							objects_rooms := (p,dir,acc.(0)) :: !objects_rooms;
							Array.sub acc 1 (Array.length acc - 1);
						end else
							acc		
					in
					let acc = gen_door() in
					if n2 > n && (not flag || Random.int 4 <> 0) then begin
						let acc2 = loop p2 acc in
						incr tot_dist;
						next true acc2 l;
					end else
						next true acc l;
				end else
					next flag acc l
		in
		if p = d.dexit then raise Exit;
		next false acc (shuffle adirs);
	in
	try
		ignore(loop d.dstart [||]);
		raise (Retry "exit not found")
	with
		Exit ->
			if !obj_count <> objects_count then raise (Retry "not enough objects found");
			for i = 0 to objects_count - 1 do
				if not (List.exists (fun (_,_,n) -> n = i) !objects_rooms) then raise (Retry "not enough objects used");
			done;
			let otable = Array.of_list (make_list objects_count) in
			ashuffle otable;
			List.iter (fun (p,dir,n) ->
				let obj = objects.( otable.(n) ) in
				if can_block_only_door obj then begin
					set_path d p dir (DoorNeed obj);
					set_path d (move d p dir) (dinv dir) (DoorNeed obj);
				end else
					d.dmap.(p.x).(p.y).rtype <- Some (ObjectNeeded obj);
			) !objects_rooms;
			List.iter (fun (p,n) -> d.dmap.(p.x).(p.y).rtype <- Some (ObjectFound objects.(otable.(n)))) !objects_found

let dist_objects_min d p =
	let rec loop ((dmin,olist) as min) = function
		| [] -> min
		| x :: l when dmin = -1 -> loop x l
		| (dist,_) :: _ as l when dmin > dist -> loop (dist,olist) l
		| (_,ol) :: _ as l when List.length ol < List.length olist -> loop (dmin,ol) l
		| ((dist,ol) as x) :: l when dist = dmin && List.length ol = List.length olist -> loop x l
		| _ :: l -> loop min l
	in
	loop (-1,[]) d.dist_table.(p.x).(p.y)

let check_difficulty d =
	let m = new_table d [] in
	let rec linclude l1 l2 =
		match l1, l2 with
		| [] , _ -> true
		| x :: l , [] -> false
		| x :: l , x2 :: l2 when x2 < x -> linclude l1 l2
		| x :: l , x2 :: l2 ->
			if x2 == x then
				linclude l l2
			else
				false
	in
	let rec add_sort x = function
		| [] -> [x]
		| x2 :: l when x2 = x -> x2 :: l
		| x2 :: l when x2 < x -> x2 :: (add_sort x l)
		| x2 :: l -> x :: x2 :: l
	in
	let rec leq l1 l2 = 
		match l1 , l2 with
		| [] , [] -> true
		| x :: l , x2 :: l2 when x = x2 -> leq l l2
		| _ , _ -> false
	in
	let rec loop objs dist p =
		let objs = (match rtype d p with
			| Some (ObjectFound obj) -> add_sort obj objs
			| _ -> objs) in
		m.(p.x).(p.y) <- (dist,objs) :: m.(p.x).(p.y);
		let next_room dir = 
			match get_path d p dir with
			| Closed -> ()
			| DoorNeed obj when not (List.exists ((=) obj) objs) -> ()
			| Invisible 
			| DoorNeed _
			| Opened ->
				let p2 = move d p dir in
				if List.for_all (fun (_,objs2) -> not (linclude objs objs2)) m.(p2.x).(p2.y)
					|| not (List.exists (fun (dist2,objs2) -> leq objs objs2 && dist2 <= dist + 1) m.(p2.x).(p2.y))
					then
					loop objs (dist+1) p2
		in
		match rtype d p with
		| Some (ObjectNeeded o) when List.exists ((=) o) objs ->
			List.iter next_room dirs
		| Some (ObjectNeeded _) ->
			()
		| Some (BonusFound Map) ->
			List.iter next_room dirs
		| _ ->
			List.iter next_room dirs
	in
	loop [] 0 d.dstart;
	d.dist_table <- m;
	let dist , obj_list = dist_objects_min d d.dexit in
	if dist < d.dwidth * d.dheight * 40 / 100 then raise (Retry "not enough difficulty");
	if List.length obj_list <> objects_count then raise (Retry "not enough objects for ending level")

let gen_objects_final d =
	let imp_list = ref [] in
	let is_impass ?excl_dir p =
		let rec loop tpath = function
			| [] -> tpath
			| dir :: dirs when excl_dir = Some dir ->
				loop tpath dirs
			| dir :: dirs ->
				match get_path d p dir with
				| Closed ->
					loop tpath dirs
				| _ when tpath = NotYet ->
					loop (Path dir) dirs
				| _ ->
					TooMuch
		in
		loop (match rtype d p with
				| Some Normal -> NotYet
				| _ -> TooMuch) dirs
	in
	let rec impass_start p dir =
		let p2 = move d p dir in
		let dir2 = dinv dir in
		match is_impass ~excl_dir:dir2 p2 with
		| Path dir -> impass_start p2 dir
		| NotYet -> assert false
		| TooMuch -> p2 , dir2
	in
	let check p =
		let loop dir =
			match get_path d p dir with
			| DoorNeed obj ->
				let p2 = move d p dir in
				(* remove the other side door *)
				if fst (dist_objects_min d p) < fst (dist_objects_min d p2) then set_path d p2 (dinv dir) Opened
			| _ -> ()
		in
		List.iter loop dirs;
		match is_impass p with
		| Path dir ->
			imp_list := (p,impass_start p dir) :: !imp_list;
		| _ -> ()
	in
	scan d.dmap (fun p _ -> check p);
	let imps = Array.of_list !imp_list in
	ashuffle imps;
	if Array.length imps < bonus_min_count then raise (Retry "not enough impass for bonuses");
	let bonus_tbl = Array.create (Array.length imps) (-1) in
	let proba_tot = ref 0 in
	let bpos = ref 0 in
	let counts = Array.mapi (fun n (min,max) ->
		for i = 1 to min do
			bonus_tbl.(!bpos) <- n;
			if bonuses.(n) = Map && fst (dist_objects_min d (fst imps.(!bpos))) > 10 then raise (Retry "map is too far");
			incr bpos;
		done;
		if max > min then proba_tot := !proba_tot + bonus_probas.(n);
		max - min
	) bonus_counts in
	while !bpos < Array.length imps do
		let p = ref (Random.int !proba_tot) in
		let pos = ref 0 in
		while !p > bonus_probas.(!pos) || counts.(!pos) = 0 do
			while counts.(!pos) = 0 do
				incr pos;
			done;
			if !p > bonus_probas.(!pos) then begin
				p := !p - bonus_probas.(!pos);
				incr pos;
			end;
		done;
		bonus_tbl.(!bpos) <- !pos;
		counts.(!pos) <- counts.(!pos) - 1;
		if counts.(!pos) = 0 then proba_tot := !proba_tot - bonus_probas.(!pos);
		incr bpos;
	done;
	Array.iteri (fun n (p,(sp,dir)) ->
		let b = bonuses.( bonus_tbl.(n) ) in
		d.dmap.(p.x).(p.y).rtype <- Some (BonusFound b);
		if can_have_invisible_door b then set_path d sp dir Invisible
	) imps

let rec gen_dungeon w h =
	let d = new_dungeon w h in
	let sp = random_room d Start in	
	ignore(gen_room d sp);
	let ep = rand_pos d in
	d.dstart <- sp;
	d.dexit <- ep;
	d.dmap.(ep.x).(ep.y).rtype <- Some End;
	for i = 0 to (w * h) / 6 do
		gen_path d Opened;
		gen_path d Closed;
	done;
	almost_close d ep;
	let m = gen_path_map d sp in
	let count = ref 0 in
	scan m (fun p s ->
		if s = -1 then
			d.dmap.(p.x).(p.y).rtype <- None
		else begin
			if d.dmap.(p.x).(p.y).rtype = None then d.dmap.(p.x).(p.y).rtype <- Some Normal;
			incr count
		end);
	if rtype d ep <> Some End || rtype d sp <> Some Start then raise (Retry "exit or start erased");
	if !count < w * h * 3 / 4 then raise (Retry "not enough superficy");
	let rec gen_objects_rec counter =
		try
			gen_objects d m;
			(* do not add any statement because objects will not be erased is retry *)
		with
			Retry s when counter < 50 ->
				submit_retry s;
				gen_objects_rec (counter+1)
	in
	gen_objects_rec 0;
	check_difficulty d;
	gen_objects_final d;
	d

let rec gen_dungeon_rec w h = 
	try
		gen_dungeon w h
	with
		Retry s ->
			submit_retry s;
			gen_dungeon_rec w h

let calc_bits n =
	let rec loop n =
		if n <= 0 then 0 else 1 + loop (n lsr 1)
	in
	loop (n-1)

let encode b d =
	let encode_nbits = BitCodec.write b in
	let encode_bonus = function
		| Orange -> encode_nbits 3 0
		| RedBall -> encode_nbits 3 1
		| Map -> encode_nbits 3 2
		| Radar -> encode_nbits 3 3
		| Key -> encode_nbits 3 4
		| BigTime -> encode_nbits 3 6
		| SmallTime -> encode_nbits 3 5
	in
	let encode_object = function
		| Green -> encode_nbits 2 0
		| Blue -> encode_nbits 2 1
		| Metal -> encode_nbits 2 2
		| Violet -> encode_nbits 2 3
	in
	let encode_path = function
		| Opened -> encode_nbits 2 0
		| Closed -> encode_nbits 2 1
		| Invisible -> encode_nbits 2 2
		| DoorNeed o ->
			encode_nbits 2 3;
			encode_object o;
	in
	let encode_room r =
		match r.rtype with
		| None -> encode_nbits 3 0
		| Some t ->
			(match t with
			| Normal
			| Start ->
				encode_nbits 3 1
			| End ->
				encode_nbits 3 2				
			| ObjectFound o ->
				encode_nbits 3 3;
				encode_object o
			| BonusFound b ->
				encode_nbits 3 4;
				encode_bonus b
			| ObjectNeeded o ->
				encode_nbits 3 5;
				encode_object o;
			);
			encode_path r.rleft;
			encode_path r.rright;
			encode_path r.rup;
			encode_path r.rdown
	in
	encode_nbits 7 d.dwidth;
	encode_nbits 7 d.dheight;
	encode_nbits 7 d.dstart.x;
	encode_nbits 7 d.dstart.y;
	scan d.dmap (fun p r -> encode_room r)

let make() =
	let d = gen_dungeon_rec fixed_width fixed_height in
	print_dungeon d;
	d

let make_empty w h =
	let d = new_dungeon w h in
	d.dstart <- { x = 0; y = 0 };
	d.dexit <- { x = 0; y = 0 };
	d.dist_table <- Array.init w (fun _ -> Array.create h []);
	for x = 0 to w - 1 do
		for y = 0 to h - 1 do
			d.dmap.(x).(y).rtype <- Some Normal;
		done;
	done;
	d
