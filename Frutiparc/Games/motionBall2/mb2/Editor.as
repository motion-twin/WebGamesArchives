import mb2.Const;

class mb2.Editor {

	static var ITEM_NAMES = [
		"bnormal",
		"btime",
		"bdeath",
		"bmagnet",
		"bshadow",
		"wall",
		"hole",
		"red",
		"blue",
		"bteleport",
		"interupt",
		"interred",
		"interblue",
		"zapper"
	];

	static var TYPELIST = [
		"DATA",
		"START",
		"END",
		"ORANGE",
		"GREEN",
		"VIOLET",
		"BLUE",
		"RED",
		"METAL",
		"KEY",
		"MAP",
		"RADAR",
		"SMALLTIME",
		"BIGTIME"
	];

	var items;
	var map_mc;
	var bumpers;
	var doors;
	var curitem;
	var levels;
	var pressed;
	var pos_x;
	var pos_y;
	var cType;
	var pos_txt;
	var background;
	var bumper_plan;

	var clipboard;

	var gomme;
	var load;
	var save;
	var cursor;
	var butSwap;
	var data;
	var map_x;
	var map_y;
	var dmanager;
	var map_dmanager;
	var map_pos_x,map_pos_y;

	var root_mc;

	var mcType;


	function Editor(root_mc) {
		this.root_mc = root_mc;
		bumpers = new Array();
		var bord = root_mc.borders;
		doors = [bord.door1,bord.door2,bord.door3,bord.door4];
		curitem = -1;
		dmanager = new asml.DepthManager(root_mc);

		bumper_plan = 1;
		items = new Array();
		var i;
		var me : Editor = this;
		for(i=0;i<ITEM_NAMES.length;i++)
			init_item(i);
		for(i=0;i<4;i++) 
			init_door(i);
		levels = new Array();
		for(i=0;i<8;i++)
			levels[i] = new Array();
		pressed = false;
		pos_x = 0;
		pos_y = 0;
		cType = 0;
		pos_txt = Std.getVar(root_mc,"pos_txt");
		pos_txt.text = pos_x + ","+pos_y;

		map_x = 0;
		map_y = 0;

		root_mc.onMouseMove = function() { me.onMouseMove() };
		root_mc.onMouseDown = function() { me.onMouseDown() };

		mcType = Std.getVar(root_mc,"mcType");
		background = Std.getVar(root_mc,"bg");
		background.gotoAndStop(1);

		gomme = Std.getVar(root_mc,"gomme");
		load = Std.getVar(root_mc,"load");
		save = Std.getVar(root_mc,"save");
		cursor = Std.getVar(root_mc,"cursor");
		butSwap = Std.getVar(root_mc,"butSwap");
		gomme.onMouseDown = function () { me.select_gomme() };
		load.onPress = function () { me.do_load() };
		save.onPress = function () { me.do_save() };
		butSwap.onPress = function() { me.swap_type() };

		data = Std.attachMC(root_mc,"data",20000);
		data._x = 80;
		data._y = 40;
		data._visible = false;
		cursor._visible = false;
	}

	function initMap() {
		levels[pos_x][pos_y] = level_data();
		map_mc = Std.createEmptyMC(root_mc,19999);
		map_dmanager = new asml.DepthManager(map_mc);
		map_mc._xscale = 100 / 8;
		map_mc._yscale = 100 / 8;
		cursor._visible = false;

		var x,y;
		for(x=0;x<8;x++)
			for(y=0;y<8;y++) {
				map_x = x * 610;
				map_y = y * 410;

				var bg = map_dmanager.attach("background",0);
				bg._x = map_x;
				bg._y = map_y;
				bg.gotoAndStop(1);
			}
		map_pos_x = 0;
		map_pos_y = 0;
		bumper_plan = 1;
	}


	function updateMap() {
		if( map_pos_y >= 8 )
			return;

		map_x = map_pos_x * 610;
		map_y = map_pos_y * 410;

		var old_doors = doors;
		var old_dman = dmanager;
		dmanager = map_dmanager;
		var bord = dmanager.attach("borders",0);
		bord._x = map_x;
		bord._y = map_y;				
		doors = [bord.door1,bord.door2,bord.door3,bord.door4];
		data_level(levels[map_pos_x][map_pos_y]);
		bumpers = new Array();

		dmanager = old_dman;
		doors = old_doors;

		map_pos_x++;
		if( map_pos_x == 8 ) {
			map_pos_x = 0;
			map_pos_y++;
			bumper_plan++;
		}
	}

	function killMap() {
		cursor._visible = true;
		bumper_plan = 1;
		map_mc.removeMovieClip();
		map_x = 0;
		map_y = 0;
		data_level(levels[pos_x][pos_y]);
		map_mc = null;
	}

	function init_item(i) {
		var me = this;
		var mc = Std.getVar(root_mc,ITEM_NAMES[i]);
		mc.name = ITEM_NAMES[i];
		mc.mask = Std.attachMC(root_mc,mc.name,i+10000);
		mc.mask.stop();
		mc.mask._alpha = 40;
		mc.mask._visible = false;		
		if( mc.name == "hole" || mc.name == "wall" ) {
			mc.dx = 40 / Const.DELTA;
			mc.dy = mc.dx;
		} else {
			mc.dx = Math.ceil((mc._width / 2) / Const.DELTA) * 2;
			mc.dy = Math.ceil((mc._height / 2) / Const.DELTA) * 2;
		}
		mc.index = i;
		mc.onPress = function () { me.select_item(mc) };
		mc.stop();
		items.push(mc);
	}

	function init_door(i) {
		var me = this;
		doors[i].gotoAndStop("nodoor0");
		doors[i].state = 0;
		doors[i].onPress = function () { me.toggle_door(i) };
	}

	function level_data() {
		if( bumpers.length == 0 && doors[0].state == 0 && doors[1].state == 0 && doors[2].state == 0 && doors[3].state == 0 && cType==0 )
			return {type:"DATA"};

		var bc = new ext.util.MTBitcodec();
		bc.write(2,doors[0].state);
		bc.write(2,doors[1].state);
		bc.write(2,doors[2].state);
		bc.write(2,doors[3].state);
		bc.write(1,1);
		var i;
		for(i=0;i<bumpers.length;i++) {
			var b = bumpers[i];
			if( b != undefined && b.index != -1 ) {
				bc.write(4,b.index+1);
				bc.write(Const.POS_NBITS,b.px);
				bc.write(Const.POS_NBITS,b.py);
			}
		}
		bc.write(4,0);
		return { type : TYPELIST[cType], data : bc.toString() };
	}

	function dungeon_data() {
		levels[pos_x][pos_y] = level_data();
		var s = "";
		var x,y;
		for(y=0;y<8;y++){
			for(x=0;x<8;x++){
				var info = levels[x][y];
				switch(info.type){
					case "START":
					case "END":
					case "DATA":
						if(info.data!=undefined)
							s += info.type+"="+info.data
						else
							s += "NONE"
						break;
					case undefined:
						s += "NONE"
						break;
					default :
						s += "ITEM="+info.type
						break;
				}
				s+="\n"
			}
		}
		return s;
	}

	function data_level(lvl) {
		var str = lvl.data

		var i;
		for(i=0;i<bumpers.length;i++)
			bumpers[i].removeMovieClip();
		bumpers = new Array();
		
		if( lvl.type == undefined ) {
			cType = 0;
			mcType.gotoAndStop(1);
		} else {
			cType = getTypeIndex(lvl.type)
			mcType.gotoAndStop(lvl.type)	
		}

		if( str == null || str == undefined ) {
			for(i=0;i<4;i++) {
				doors[i].state = 0;
				update_door(doors[i]);
			}
			return;
		}

		
		var bc = new ext.util.MTBitcodec(str);		
		for(i=0;i<4;i++) {
			doors[i].state = bc.read(2);
			update_door(doors[i]);
		}
		if( bc.read(1) == 1 ) {
			while(true) {
				var t = bc.read(4);
				if( t == 0 )
					break;
				var px = bc.read(Const.POS_NBITS);
				var py = bc.read(Const.POS_NBITS);
				add_bumper(t-1,px,py);
			}
		}
	}

	function data_dungeon(txt) {
		var lvls = new Array()
		var x,y;
		for(x=0;x<8;x++)
			lvls[x] = new Array();
		for(y=0;y<8;y++)
			for(x=0;x<8;x++) {
				lvls[x][y] = new Object();
				var hIndex = txt.indexOf("=")
				if( hIndex == -1 )
					hIndex = txt.length;				
				var p = txt.indexOf("\n");
				if( p == -1 )
					p = txt.indexOf("\r");
				if( p == -1 )
					p = txt.length;
				var h = txt.substr(0,Math.min(hIndex,p));

				var line = txt.substr(hIndex+1,p-(hIndex+1));
				txt = txt.substr(p+1);
				
				switch(h){
					case "START":
					case "END":
					case "DATA":
						lvls[x][y].data = line;
						lvls[x][y].type = h;
						break;
					case "NONE":
						lvls[x][y].type = "DATA";
						break;
					case "ITEM":
						lvls[x][y].type = line;
						break;
				}
			}
		levels = lvls;
		data_level(levels[pos_x][pos_y]);
		return null;
	}

	function update_door(d) {		
		switch(d.state) {
		case 0:
			d._alpha = 100;
			d.gotoAndStop("nodoor0");
			break;
		case 1:
			d.gotoAndStop("opened");
			d.porteA.stop();
			d.porteB.stop();
			d._alpha = 100;
			break;
		case 2:
			d._alpha = 50;
			d.gotoAndStop("on");
			d.porteA.stop();
			d.porteB.stop();
			break;
		case 3:
			d._alpha = 100;
			d.gotoAndStop(50);
			break;
		}
	}

	function select_item(mc) {
		items[curitem]._alpha = 100;
		gomme._alpha = 100;
		mc._alpha = 50;
		curitem = mc.index;
		cursor.mask._visible = false;
		cursor.mask = items[curitem].mask;
	}

	function toggle_door(i) {
		var d = doors[i];
		d.state++;
		d.state%=4;
		update_door(d);
	}

	function select_gomme() {
		if( gomme.hitTest(_xmouse,_ymouse,true) ) {
			items[curitem]._alpha = 100;
			gomme._alpha = 50;
			curitem = -1;
			cursor._visible = false;
			cursor.mask._visible = false;
		} else if( !data._visible && !map_mc._visible ) {
			var i;
			for(i=0;i<bumpers.length;i++)
				if( bumpers[i].hitTest(_xmouse,_ymouse,true) ) {
					bumpers[i].removeMovieClip();
					bumpers.splice(i,1);
					i--;
					return;
				}
		}
	}

	function do_save() {
		if( data._visible ) {
			data._visible = false;
			return;
		}
		data.text.text = dungeon_data();
		data.mode = true;
		data._visible = true;
	}

	function do_load() {
		if( data._visible ) {
			data._visible = false;
			return;
		}
		data.text.text = "";
		data.mode = false;
		data._visible = true;
	}

	function swap_type(){
		cType = (cType+1) % TYPELIST.length;
		mcType.gotoAndStop(TYPELIST[cType]);
	}

	function data_action(data_txt,mode) {
		if( !mode && data.text.text != "" ) { // LOAD
			var r = data_dungeon(data.text.text);
			if( r != null ) {
				data.text.text = r;
				return;
			}
		}	
		data._visible = false;
	}

	function onMouseMove() {
		if( curitem == -1 )
			return;
		if( data._visible || map_mc._visible || !(_xmouse > Const.BORDER_SIZE && _ymouse > Const.BORDER_SIZE && _xmouse < Const.LVL_WIDTH-Const.BORDER_SIZE && _ymouse < Const.LVL_HEIGHT-Const.BORDER_SIZE) ) {
			cursor._visible = false;
			cursor.mask._visible = false;
			return;
		}
		cursor._visible = true;
		cursor.mask._visible = true;
		var mc = items[curitem];
		var px = int(_xmouse/Const.DELTA);
		var py = int(_ymouse/Const.DELTA);
		if( mc.name == "hole" || mc.name == "wall" || mc.name == "interred" || mc.name == "interblue" ) {
			px -= (px-Const.BORDER_CSIZE)%10;
			py -= (py-Const.BORDER_CSIZE)%10;
		} else {
			px -= mc.dx/2;
			py -= mc.dy/2;
		}
		cursor.px = px;
		cursor.py = py;
		
		cursor._x = (px + mc.dx / 2) * Const.DELTA;
		cursor._y = (py + mc.dy / 2) * Const.DELTA;
		cursor.mask._x = cursor._x;
		cursor.mask._y = cursor._y;
	}

	function onMouseDown() {
		if( !cursor._visible )
			return;
		add_bumper(curitem,cursor.px,cursor.py);
	}

	function main() {
		var old_x = pos_x;
		var old_y = pos_y;
		
		if( data._visible )
			return;

		if( Key.isDown(Key.ESCAPE) ) {
			if( pressed ) {
				updateMap();
				return;
			}
			pressed = true;
			initMap();
			return;
		}
		else if( map_mc != null )
			killMap();

		if( Key.isDown("C".charCodeAt(0)) )
			clipboard = level_data();

		if( Key.isDown("V".charCodeAt(0)) && clipboard != undefined )
			data_level(clipboard);

		if( Key.isDown("X".charCodeAt(0)) )
			data_level({ data : "uiaabYoECJKaKzAlswMdkXGWmCqdhekWa", type : "DATA" });

		pos_txt.text = pos_x + ","+pos_y;

		if( Key.isDown(Key.DOWN) ) {
			if( pressed || pos_y == 7 ) return; 
			pos_y++;
		} else if( Key.isDown(Key.UP) ) {
			if( pressed || pos_y == 0 ) return; 
			pos_y--;
		} else if( Key.isDown(Key.LEFT) ) {
			if( pressed || pos_x == 0 ) return; 
			pos_x--;
		} else if( Key.isDown(Key.RIGHT) ) {
			if( pressed || pos_x == 7 ) return; 
			pos_x++;
		} else {
			pressed = false;
			return;
		}
		
		pressed = true;
		levels[old_x][old_y] = level_data();
		data_level(levels[pos_x][pos_y]);
	}

	function add_bumper(index, px, py) {
		var base_mc = items[index];
		var mc = dmanager.attach(base_mc.name,bumper_plan);
		if( mc == undefined )
			return;
		mc.index = index;
		mc.px = px;
		mc.py = py;

		mc._x = (px + base_mc.dx / 2) * Const.DELTA + map_x;
		mc._y = (py + base_mc.dy / 2) * Const.DELTA + map_y;

		if( index == 13 )
			mc.gotoAndStop( 1 + ((px - base_mc.dx/2) + (py - base_mc.dy/2)) % 7 );
		else
			mc.stop();
		bumpers.push(mc);
	}

	function getTypeIndex(str){
		var i;
		for(i=0;i<TYPELIST.length;i++)
			if( str == TYPELIST[i] ) 
				return i;
	}

}
