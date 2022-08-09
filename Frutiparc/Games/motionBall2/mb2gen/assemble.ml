open Printf
open Dungeon
open Level

type room_data = {
	rbumpers : (Level.item * pos) list;
	r_left : Dungeon.path;
	r_right : Dungeon.path;
	r_up : Dungeon.path;
	r_down : Dungeon.path;
}

type room =
	| RData of room_data
	| RBonusFound of bonus
	| RObjectFound of obj
	| REnd

let start_pos = ref { x = -1; y = -1 }

let single_way = DoorNeed Green (** hack **)

let split l sep =
	try
		let p = String.index l sep in
		String.sub l 0 p , String.sub l (p+1) (String.length l - p - 1)
	with
		Not_found -> l , ""

let decode data =
	let b = BitCodec.decode_b64 data in
	let decode_path() =
		match BitCodec.read b 2 with
		| 0 -> Closed
		| 1 -> Opened
		| 2 -> Invisible
		| 3 -> single_way
		| _ -> failwith "Invalid data"
	in
	let rec decode_bumpers() =
		let bt = BitCodec.read b 4 in
		if bt = 0 then
			[]
		else 
			let bv = (match bt with
				| 1 -> BNormal
				| 2 -> BTime
				| 3 -> BDeath
				| 4 -> BMagnet
				| 5 -> BShadow
				| 6 -> BBlock
				| 7 -> BHole
				| 8 -> BRed
				| 9 -> BBlue
				| 10 -> BTeleport
				| 11 -> Interupt
				| 12 -> IBlockRed
				| 13 -> IBlockBlue
				| 14 -> Zapper
				| _ -> failwith "Invalid data")
			in
			let x = BitCodec.read b !Level.pos_nbits in
			let y = BitCodec.read b !Level.pos_nbits in
			(bv,{ x = x; y = y}) :: (decode_bumpers())
	in
	let rl = decode_path() in
	let rr = decode_path() in
	let ru = decode_path() in
	let rd = decode_path() in
	ignore(BitCodec.read b 1);
	{	
		rbumpers = decode_bumpers();
		r_left = rl;
		r_right = rr;
		r_up = ru;
		r_down = rd;
	}

let rec handle x y l =
	let rtype, rdata = split l '=' in
	match rtype with
	| "NONE" -> None
	| "DATA" -> Some (RData (decode rdata))
	| "ITEM" ->
		Some (
			match rdata with
			| "KEY" -> RBonusFound Key
			| "ORANGE" -> RBonusFound Orange
			| "BLUE" -> RObjectFound Blue
			| "METAL" -> RObjectFound Metal
			| "VIOLET" -> RObjectFound Violet
			| "GREEN" -> RObjectFound Green
			| "RED" -> RBonusFound RedBall
			| "MAP" -> RBonusFound Map
			| "RADAR" -> RBonusFound Radar
			| "BIGTIME" -> RBonusFound BigTime
			| "SMALLTIME" -> RBonusFound SmallTime
			| _ -> failwith ("Invalid item : "^rdata)
		)
	| "START" ->
		start_pos := { x = x; y = y };
		Some (RData (decode rdata))
	| "END" ->
		Some REnd
	| _ ->
		failwith ("Invalid room type : "^rtype)

let convert_room rooms x y =
	let get_path x y dir =
		if x < 0 || x >= Dungeon.fixed_width || y < 0 || y >= Dungeon.fixed_height then
			Closed
		else
			match rooms.(x).(y) with
			| None -> Closed
			| Some r ->
				match r with
				| RData r ->
					let p = (match dir with
						| Up -> r.r_up
						| Left -> r.r_left
						| Right -> r.r_right
						| Down -> r.r_down)
					in
					(match p with
					| Closed -> Closed
					| Invisible | Opened | DoorNeed _ -> Opened)
				| RBonusFound _
				| RObjectFound _ ->
					Closed
				| REnd ->
					Closed
	in
	let convert_room rt =
		{
			rtype = Some rt;
			rup = get_path x (y-1) Down;
			rdown = get_path x (y+1) Up;
			rleft = get_path (x-1) y Right;
			rright = get_path (x+1) y Left;
			rpos = { x = x; y = y }
		}
	in
	match rooms.(x).(y) with
	| None ->
		{
			rtype = None;
			rup = Closed;
			rdown = Closed;
			rleft = Closed;
			rright = Closed;
			rpos = { x = x; y = y };
		}
	| Some r ->
		match r with
		| RData d ->
			{
				rtype = Some Normal;
				rup = d.r_up;
				rleft = d.r_left;
				rright = d.r_right;
				rdown = d.r_down;
				rpos = { x = x; y = y }
			}
		| RObjectFound it ->
			convert_room (ObjectFound it)
		| RBonusFound it ->
			convert_room (BonusFound it)
		| REnd ->
			convert_room End

let get_exit_pos rooms = 
	let p = ref { x = -1; y = -1 } in
	try
		for x = 0 to Dungeon.fixed_width - 1 do
			for y = 0 to Dungeon.fixed_height - 1 do
				match rooms.(x).(y) with
				| Some REnd -> 
					p:= { x = x; y = y };
					raise Exit
				| _ -> ()
			done;
		done;
		failwith "No END";
	with
		| Exit ->
			!p

let convert_level rooms x y =
	match rooms.(x).(y) with
	| None -> None
	| Some (RData r) -> 
		Some r.rbumpers
	| _ -> None

let make f =
	eprintf "Loading %s\n" f;
	let rooms = Array.init Dungeon.fixed_width (fun _ -> Array.create Dungeon.fixed_height None) in
	let ch = (try open_in f with Sys_error _ -> failwith ("File not found : " ^ f)) in
	let x = ref 0 in
	let y = ref 0 in
	while !y < Dungeon.fixed_height do
		let l = (try input_line ch with _ -> failwith "Incomplete file") in
		if l <> "" && l.[0] <> '#' then begin
			rooms.(!x).(!y) <- handle !x !y l;
			incr x;
			if !x = Dungeon.fixed_width then begin
				x := 0;
				incr y;
			end
		end;
	done;
	if !start_pos.x = -1 then failwith "No start !";
	let b = BitCodec.encode_b64() in
	let d = {
		dmap = Array.init Dungeon.fixed_width (fun x -> Array.init Dungeon.fixed_height (fun y -> convert_room rooms x y));
		dwidth = Dungeon.fixed_width;
		dheight = Dungeon.fixed_height;
		dstart = !start_pos;
		dexit = get_exit_pos rooms;
		dist = 0;
		dist_table = [||]
	} in
	Dungeon.encode b d;
	BitCodec.flush b;
	for x = 0 to Dungeon.fixed_width - 1 do
		for y = 0 to Dungeon.fixed_height - 1 do
			Level.encode_room b (convert_level rooms x y)
		done;
	done;
	printf "dseed=%s&ddata=%s" (Filename.basename f) (BitCodec.to_string b)

;;
try
	Random.self_init();
	let seed = Random.int max_int in
	Random.init seed;
	Level.load_bumpers();
	if Array.length Sys.argv < 2 then begin
		printf "dseed=%d&" seed;
		Level.make();
		eprintf "Done.\n"
	end else begin
		(match Sys.argv.(1) with
		| "-classic" ->
			printf "dseed=%d&" seed;
			Level.make_classic (int_of_string Sys.argv.(2));
		| file ->
			make file);
		eprintf "Done.\n"
	end
with
	Failure msg ->
		flush stdout;
		prerr_endline msg