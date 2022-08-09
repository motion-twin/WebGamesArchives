package ui;

import mt.MLib;
import mt.data.GetText;
import com.*;
import com.Protocol;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

typedef MButton = {
	var scale	: Float;
	var i		: h2d.Interactive;
	var bg		: BatchElement;
	var icon	: BatchElement;
	var tf		: TextBatchElement;
	//var counter	: TextBatchElement;
}

class MassMenu extends H2dProcess {
	public static var CURRENT : MassMenu;

	var shotel(get,null)	: com.SHotel; inline function get_shotel() return Game.ME.shotel;
	var buttons				: Map<String, MButton>;
	var sb					: SpriteBatch;
	var tsb					: SpriteBatch;
	var bwid = 128;

	public function new() {
		super(Game.ME);
		Main.ME.uiWrapper.add(root, Const.DP_BARS);

		CURRENT = this;
		name = "MassMenu";
		root.y = h();
		buttons = new Map();

		sb = new h2d.SpriteBatch(Assets.tiles.tile, root);
		sb.filter = true;

		tsb = new h2d.SpriteBatch(Assets.fontTiny.tile, root);
		tsb.filter = true;

		createButton("validate", Lang.t._("Validate waiting clients"), "iconLeave", 1, function() {
			Game.ME.runSolverCommand( DoValidateAll );
		});

		createButton("repair", Lang.t._("Repair every rooms"), "iconClean", 1, onRepairAll);

		createButton("skip", Lang.t._("Empty the hotel"), "moneyGem", 0.75, function() {
			var q = new ui.Question();
			q.addText( Lang.t._("Checkout every clients immediatly (you will still get their full payment)?") );
			q.addButton( Lang.t._("Confirm (::n:: GEMS)", {n:getSkipAllCost()}), "moneyGem", function() {
				Game.ME.runSolverCommand( DoSkipAllClients );
			});
			q.addCancel();
		});

		refresh();
	}

	function getSkipAllCost() {
		return com.GameData.getSkipAllCost( shotel.getSkipAllClients(Game.ME.serverTime).length );
	}


	public function refresh() {
		if( Game.ME.isVisitMode() )
			return;

		var n = 0;
		for(c in shotel.clients)
			if( c.done )
				n++;
		setVisibility("validate", n>0);
		//setCounter("validate", n);
		setPos("validate", 0, -bwid);

		if( isVisible("validate") )
			setVisibility("repair", false);
		else {
			var n = 0;
			for(r in shotel.rooms)
				if( r.damages>0 && !r.working && !r.constructing && !r.hasClient() )
					n++;
			setVisibility("repair", n>0);
			//setCounter("repair", n);
			setPos("repair", 0, -bwid);
		}

		var cost = getSkipAllCost();
		setVisibility("skip", shotel.featureUnlocked("gems") && cost>0);
		//setCounter("skip", cost);
		setPos("skip", 0, isVisible("repair") || isVisible("validate") ? -bwid*1.75 : -bwid*0.75);
	}

	//function setCounter(id:String, ?v=0) {
		//var e = getButton(id);
		//var tf = e.counter;
		//tf.text = v==0 ? "" : Std.string(v);
		//tf.x = e.bg.width*0.5 - tf.textWidth*tf.scaleX*0.5;
	//}

	function setPos(id:String, x:Float, y:Float) {
		var e = getButton(id);
		var bwid = bwid*e.scale;
		e.bg.setPos(x+bwid*0.5, y+bwid*0.5);
		e.i.setPos(x, y);
		e.icon.setPos(e.bg.x, e.bg.y-4);
		e.tf.x = e.bg.x + bwid*0.5 + 5;
		e.tf.y = e.bg.y - e.tf.textHeight*e.tf.scaleY*0.5;
	}

	inline function isVisible(id:String) return getButton(id).bg.visible;

	function setVisibility(id:String, v:Bool) {
		var e = getButton(id);
		e.bg.visible = e.icon.visible = e.tf.visible = e.i.visible = v;
	}



	function createButton(id:String, label:LocaleString, iconId:String, scale:Float, cb:Void->Void) {
		var bwid = bwid*scale;

		var bg = Assets.tiles.addBatchElement(sb, "btnBlankBig",1, 0.5,0.5);
		bg.setScale( bwid/bg.width );

		var icon = Assets.tiles.addBatchElement(sb, iconId,0, 0.5,0.5);
		icon.setScale( bwid*0.6/icon.width );

		var tf = Assets.createBatchText(tsb, Assets.fontTiny, 20, label);
		tf.maxWidth = 200/tf.scaleX;
		tf.dropShadow = { color:0x0, alpha:1, dx:2, dy:3 }

		//var ctf = Assets.createBatchText(tsb, Assets.fontTiny, 24, "?");

		var i = new h2d.Interactive(bwid, bwid, root);
		//i.backgroundColor = alpha(0xFF00FF,0.5);
		i.onClick = function(_) {
			Assets.SBANK.click1(1);
			ui.SideMenu.closeAll();
			cb();
		}

		buttons.set(id, {
			scale	: scale,
			i		: i,
			icon	: icon,
			bg		: bg,
			tf		: tf,
			//counter	: ctf,
		});

		setVisibility(id, false);
	}

	inline function getButton(id:String) return buttons.get(id);


	override function onDispose() {
		super.onDispose();

		sb.dispose();
		sb = null;

		tsb.dispose();
		tsb = null;

		buttons = null;

		if( CURRENT==this )
			CURRENT = null;
	}


	function onRepairAll() {
		var all = shotel.rooms.filter( function(r) return r.damages>0 && !r.working && !r.constructing );
		all.sort( function(a,b) {
			if( a.type!=R_Bedroom && b.type==R_Bedroom )
				return -1;
			if( a.type==R_Bedroom && b.type!=R_Bedroom )
				return 1;
			return Reflect.compare(a.damages, b.damages);
		});

		var stock = shotel.countStock(R_StockSoap);
		var cmds = [];
		while( stock>0 && all.length>0 ) {
			var r = all.shift();
			if( stock>=r.damages ) {
				stock-=r.damages;
				cmds.push( DoRepairRoom(r.cx, r.cy) );
			}
			else
				break;
		}
		if( cmds.length>0 )
			Game.ME.chainCommands(cmds);

		// Missing rooms
		if( all.length>0 )
			if( all.length==1 )
				new ui.Notification(Lang.t._("You don't have enough SOAP: a couldn't be repaired."), Const.TEXT_BAD, "iconRemove");
			else
				new ui.Notification(Lang.t._("You don't have enough SOAP: some rooms couldn't be repaired."), Const.TEXT_BAD, "iconRemove");
	}


	override function onResize() {
		super.onResize();

		root.setScale( Main.getScale(bwid, hcm()>=9 ? 1.1 : 0.85) );

		tw.terminateWithoutCallbacks(root.y);
		root.x = 10;
		root.y = h()-10;
	}

	override function update() {
		super.update();

		var canShow = !Game.ME.isPlayingLogs && !Game.ME.tuto.isRunning();
		if( root.visible && !canShow )
			root.visible = false;

		if( !root.visible && canShow ) {
			root.visible = true;
			root.y = h()+200;
			tw.create(root.y, h()-10, 350);
		}
	}
}
