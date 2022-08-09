package ev;
import mt.bumdum.Lib;

typedef SlotShop = { >flash.MovieClip, field:flash.TextField, fieldGold:flash.TextField, item:flash.MovieClip, id:Int, price:Int, flInv:Bool };

class Trader extends Event {//}
	static var ITEMS_STD = [
		{ id:5,		price:150,	flInv:false		},	// LEATHER ARMOR
		{ id:6,  	price:400,	flInv:false		},	// IRON ARMOR
		{ id:7,  	price:80,	flInv:false		},	// KNIFE
		{ id:8,  	price:180,	flInv:false		},	// KATANA
		{ id:10,  	price:25,	flInv:false		},	// FOOD
		{ id:14,  	price:35,	flInv:true		},	// POTION
		{ id:11,  	price:15,	flInv:false		},	// SHURIKEN x3
		{ id:13,  	price:15,	flInv:false		},	// SAC-A-DOS
		{ id:25,	price:30,	flInv:true		},	// SCROLL FIRE
		{ id:26,  	price:30,	flInv:true		},	// SCROLL ICE
		{ id:29,  	price:30,	flInv:true		},	// SCROLL CHAOS
		{ id:30,  	price:30,	flInv:true		},	// SCROLL TELEPORT
		{ id:32,  	price:40,	flInv:true		},	// OS
	];

	public var flFirst:Bool;

	var bg:flash.MovieClip;
	var mcPanel:{>flash.MovieClip,field:flash.TextField};

	var slots:Array<SlotShop>;


	//var dm:mt.DepthManager;

	public function new(?first){
		flFirst = first;
		super();
		bg = Game.me.dm.attach("mcBlack",Game.DP_FADER);
		bg._alpha = 0;

		spc = 0.1;
		slots = [];
		Game.me.displayItems(false);

	}



	override function update(){
		super.update();

		switch(step){
			case 0 :
				bg._alpha = coef*50;
				if(coef==1){
					bg.onPress = leave;
					attachPanel();
					step++;
				}

			case 1 :
				if( flash.Key.isDown(flash.Key.LEFT) )	leave();
				if( flash.Key.isDown(flash.Key.RIGHT) )	leave();
				if( flash.Key.isDown(flash.Key.UP) )	leave();
				if( flash.Key.isDown(flash.Key.DOWN) )	leave();
				if( flash.Key.isDown(flash.Key.SPACE) )	leave();
			case 2 :
				bg._alpha = (1-coef)*50;
				if(coef==1){
					bg.removeMovieClip();
					kill();
					step++;
				}

		}
	}
	public function attachPanel(){
		mcPanel = cast Game.me.dm.attach("mcPanel",Game.DP_INTER);
		mcPanel._x = (Cs.mcw-mcPanel._width)*0.5;
		mcPanel._y = Cs.bh + ((Cs.mch-Cs.bh)-mcPanel._height)*0.5;
		mcPanel.smc.onPress = function(){};
		mcPanel.smc.useHandCursor = false;
		KKApi.registerButton( mcPanel.smc );


		var seed = new mt.Rand(Game.me.did+Game.me.cfl.id);

		var dm = new mt.DepthManager(mcPanel);
		var a = ITEMS_STD.copy();
		var list = [];
		for( i in 0...4 ){
			var o = a[seed.random(a.length)];
			list.push(o);
			a.remove(o);
		}

		var id = 0;
		slots = [];
		for( o in list ){
			var mc:SlotShop = cast dm.attach("slotShop",0);
			mc._x = 8+(id%2)*115;
			mc._y = 8+Math.floor(id/2)*35;
			mc.field.text = Lang.ITEMS[o.id];
			mc.fieldGold.text = Std.string(o.price);
			mc.item.gotoAndStop(o.id+1);
			mc.id = o.id;
			mc.flInv = o.flInv;
			mc.price = o.price;
			id++;
			slots.push(mc);
		}

		updateSlots();

	}
	public function updateSlots(){
		var flNoRoom = false;

		var str = Lang.TRADER[0];
		var n = 0;

		for( mc in slots ){

			var flOk = mc.price<= Game.me.gold;
			if( flOk ){
				if( mc.flInv && Game.me.inventory.length>=Game.me.bagSize ){
					flNoRoom = true;
					flOk = false;
				}
			}

			if( mc.id==13 && Game.me.bagSize>3 ) flOk = false; // BAGPACK


			if( flOk ){
				mc._alpha = 100;
				mc.smc.onPress = callback( buy, mc );
				mc.smc.onRollOver = callback( select, mc );
				mc.smc.onRollOut = callback( unselect, mc );
				mc.smc.onDragOver = mc.smc.onRollOver;
				mc.smc.onDragOut = mc.smc.onRollOut;
				KKApi.registerButton( mc.smc );
				n++;

			}else{
				mc._alpha = 20;
				mc.smc.onPress = null;
				mc.smc.onRollOver = null;
				mc.smc.onRollOut = null;
				mc.smc.onDragOver = null;
				mc.smc.onDragOut = null;
				mc.smc.useHandCursor = false;
				mc.smc._alpha = 0;
				KKApi.registerButton( mc.smc );

			}
		}


		if(n==0){
			str = Lang.TRADER[1];
			if( flNoRoom ) str = Lang.TRADER[2];
		}
		mcPanel.field.text = str;


	}

	function select(mc:flash.MovieClip){
		mc.smc._alpha = 20;
	}
	function unselect(mc:flash.MovieClip){
		mc.smc._alpha = 0;
	}
	function buy(mc){
		Game.me.flMute = true;
		Game.me.pickUp(mc.id);
		Game.me.flMute = false;
		Game.me.gold -= mc.price;
		Game.me.lureGold -= mc.price;
		Game.me.displayGold();
		updateSlots();
	}

	function leave(){
		coef = 0;
		step = 2;

		mcPanel.removeMovieClip();
	}


//{
}









