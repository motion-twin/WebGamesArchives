package en;

import com.Protocol;
import mt.MLib;
import mt.data.GetText;
import b.Room;
import b.*;
import com.*;
import h2d.SpriteBatch;
import h2d.TextBatchElement;

import mt.deepnight.Color;
import mt.deepnight.slb.*;

class Client extends Entity {
	public static var ALL : Array<Client> = [];

	public var sclient(get,null)	: com.SClient;

	public var id					: Int;
	public var hapBase				: Null<BatchElement>;
	public var hapValue				: Null<h2d.TextBatchElement>;
	public var emitIcon				: Null<HSpriteBE>;
	public var serviceReq			: Null<BatchElement>;
	var wanderTx					: Float;
	var luggage						: Null<BatchElement>;
	var vipStar						: Null<BatchElement>;
	var bubbles						: Array<{ t:Float, bg:BatchElement, tf:TextBatchElement }>;
	var bubbleArrow					: Null<BatchElement>;
	var floating					: Bool;
	public var arrivalAnim			: Float;
	public var type(get,never)		: ClientType; inline function get_type() return sclient.type;


	private function new(cid:Int, ?r:b.Room) {
		super(r);

		floating = true;
		id = cid;
		ALL.push(this);
		dir = Std.random(2)*2-1;
		wid = 100;
		hei = 120;
		wanderTx = -1;
		bubbles = [];
		arrivalAnim = 1;

		refreshEmitIcon();

		cd.set("chat", Const.seconds(5));
		cd.set("emitFx", 5);

		updateHappiness();
		updateAffect();
	}

	override function initSprite() {
		spr = new mt.deepnight.slb.HSpriteBE(game.monstersSb0, Assets.monsters0, "monsterEyeIdle");
	}

	function toString() return "Client("+sclient+")";

	public function get_sclient() return shotel==null ? null : shotel.getClient(id);

	public function isWalking() {
		return MLib.fabs(dx)>=walkSpeed*2 && !isDragged() || cd.has("persistWalk");
	}

	public function refreshEmitIcon() {
		if( emitIcon!=null ) {
			emitIcon.dispose();
			emitIcon = null;
		}

		if( sclient.emit==null )
			return;

		emitIcon = Assets.tiles.hbe_get(game.tilesFrontSb, Assets.getAffectIcon(sclient.emit));
		emitIcon.setCenterRatio(0.5,0.5);
		emitIcon.visible = false;
		emitIcon.alpha = 0.6;

	}

	//public static function getById(id:Int) {
		//for(e in ALL)
			//if( e.id==id )
				//return e;
		//return null;
	//}

	public function onUnselect() {
	}

	public function onSelect() {
	}

	public function onRelocate() {
		if( serviceReq!=null ) {
			serviceReq.remove();
			serviceReq = null;
			room.updateGiftPositions();
		}

		cd.set("chat", Const.seconds(5));
		wanderTx = -1;
	}

	public function onSpecialAction() {
	}

	public function updateHappiness(?happyOverride:Int) {
		if( isWaiting() ) {
			setHappiness();
			return;
		}

		setHappiness( happyOverride!=null ? happyOverride : sclient.getHappiness() );
	}

	function updateAffect() {
		if( emitIcon!=null ) {
			var x = hapBase!=null && hapBase.visible ? centerX + 70 : centerX;
			var y = hapBase!=null && hapBase.visible ? yy - hei + 20 : yy - hei - 20;
			if( isWaiting() && isVip() )
				x+=15;
			x += Math.sin(time*0.07)*6;
			y += Math.cos(time*0.06)*5;

			emitIcon.x = x;
			emitIcon.y = y-6;
		}
	}

	public inline function isVip() return !destroyAsked && sclient!=null && sclient.isVip();

	public inline function hasServiceRequest() {
		return !destroyAsked && !game.isVisitMode() && !cd.has("tempRoom") && sclient.hasServiceRequest( game.serverTime );
	}

	public inline function isSleeping() {
		return !destroyAsked && shotel.featureUnlocked("miniGame") &&
			sclient.hasMiniGameRequest(game.serverTime) &&
			!cd.has("tempRoom") &&
			( !game.tuto.isRunning() || game.tuto.isRunning("miniGame") );
	}


	public function setHappiness(?h:Null<Int>) {
		if( hapBase!=null ) {
			hapBase.remove();
			hapBase = null;
			hapValue.dispose();
			hapValue = null;
		}

		if( h!=null ) {
			h = MLib.min(h, shotel.getMaxHappiness());
			hapBase = Assets.tiles.addBatchElement(game.tilesFrontSb, -10, "whiteBubble",0, 0.5, 0.5);
			hapBase.visible = false;
			var bg = -1;
			var txt = 0xffffff;
			if( h<0 ) { bg = 0xFF0404; }
			else if( h<10 ) { bg = 0x880000; }
			else if( h<15 ) { bg = 0xE16000; }
			else if( h<20 ) { bg = 0xFFB722; }
			else if( h<25 ) { bg = 0x4BB7D6; }
			else { bg = 0x8DBE1B; }
			if( bg!=-1 )
				hapBase.color = h3d.Vector.fromColor(Color.addAlphaF(bg));
			hapValue = Assets.createBatchText(Game.ME.textSbTiny, Assets.fontTiny, 22);
			hapValue.textColor = Color.addAlphaF(txt);
			hapValue.text = sclient.happinessMaxed() ? "MAX" : Std.string(h);
			hapValue.scaleX = hapValue.scaleY = hapValue.text.length>=3 ? 1.8 : 2.3;
			hapValue.dropShadow = { color:Color.brightnessInt(bg, -0.2), alpha:0.5, dx:0, dy:2 }
		}
	}

	public inline function isSelected() {
		return !destroyAsked && switch( game.selection ) {
			case S_Client(c) : c==this;
			default : false;
		}
	}

	public inline function isDone() return !destroyAsked && sclient!=null && sclient.done;

	override function set_room(r) {
		//if( room!=null && !room.destroyAsked )
			//room.onClientLeave(this);

		super.set_room(r);

		//if( room!=null )
			//room.onClientArrive(this);

		return room;
	}

	public inline function isWaiting() return !destroyAsked && sclient!=null && sclient.isWaiting();


	public function iaWander() {
		if( !stable )
			return;

		if( !cd.has("wait") )
			if( wanderTx==-1 || MLib.fabs(xx-wanderTx)<20 ) {
				cd.set("wait", Const.seconds(rnd(2, 5)));
				var old = wanderTx;
				var tries = 30;
				while( MLib.fabs(old-wanderTx)<40 && tries-->0 )
					wanderTx = room.globalLeft + room.wid*rnd(0.3, 0.7);
			}
			else {
				if( xx>wanderTx ) dir = -1;
				if( xx<wanderTx ) dir = 1;
				dx+=dir*walkSpeed;
			}

	}

	public function iaGoto(tx:Float, ?endDir=0, ?run=false) {
		if( cd.has("wait") && isInLobby() )
			return;

		tx = room.globalLeft + tx;
		var s = run || MLib.fabs(tx-xx)>=100 ? runSpeed : walkSpeed;
		if( MLib.fabs(tx-xx)<=20 )
			s*=0.35;

		if( tx>xx+5 ) {
			dx+=s;
			dir = 1;
		}
		else if( tx<xx-5 ) {
			dx-=s;
			dir = -1;
		}
		else if( endDir!=0 ) {
			dx*=0.3;
			dir = endDir;
		}
	}


	public function setLuggage(b:Bool) {
		if( !b && luggage!=null ) {
			luggage.remove();
			luggage = null;
		}

		if( b && luggage==null ) {
			luggage = Assets.tiles.addBatchElement(game.tilesSb, "clientLuggage",0, 0.5, 1);
			luggage.x = xx;
			luggage.y = yy;
			luggage.scaleX = luggage.scaleY = 0.6;
		}
	}


	public function say(str:String, ?col=-1, ?important=true) {
		var p = 5;
		var bg = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, -11, "uiDialBox",0);

		var tf = Assets.createBatchText(Game.ME.textSbTiny, Assets.fontTiny, 28, str);
		tf.x = tf.y = p;
		tf.maxWidth = 200;
		tf.textColor = col!=-1 ? col : (important ? 0x35316C : 0x8B7A61);

		bg.width = 0;
		bg.height = Std.int( tf.textHeight*tf.scaleY + p*2 );

		bubbles.insert(0, { t:Const.seconds(4), bg:bg, tf:tf });
		updateBubbles();

		var s = tf.scaleX;
		game.tw.create(tf.scaleX, 0>s, 300).onUpdate = function() {
			bg.width = Std.int( tf.textWidth*tf.scaleX + p*2 );
		}

		cd.set("chat", Const.seconds(20));
	}


	public function sayOne(all:Array<LocaleString>) {
		var a = all.copy();
		var str : String = null;
		while( str==null ) {
			if( a.length==0 )
				str = all[0];
			else {
				var s = a.splice(Std.random(a.length),1)[0];
				if( !cd.has(s) )
					str = s;
			}
		}

		cd.set(str, Const.seconds(20));
		say(str);
	}



	public function giveFeedback() {
		if( destroyAsked || sclient==null || Game.ME.tuto.isRunning() )
			return;

		var h = sclient.getCappedHappiness();
		//var like = sclient.likes[Std.random(sclient.likes.length)]; // TODO
		var dislike = sclient.dislikes[Std.random(sclient.dislikes.length)]; // TODO
		var t = Lang.t;
		var max = shotel.getMaxHappiness();

		if( h>=max*0.83 )
			sayOne([
				t._("Best hotel ever! I love it!"),
				t._("Such a lovely bedroom!"),
				t._("I will definitely recommend this hotel!"),
				t._("Such a fabulous place!"),
				t._("This hotel is totally EPIC!"),
				t._("I love my bedroom!!"),
				t._("Wow! Best hotel ever!!"),
				t._("I totally LOVE this place!"),
				t._("Amazing hotel!"),
			]);
		else if( h>=max*0.66 ) {
			sayOne([
				t._("I like this place."),
				t._("Nice hotel."),
				t._("I like my bedroom."),
				t._("Nice bedroom."),
				t._("Pretty cool."),
			]);
		}
		else if( h>=max*0.33 ) {
			var all = new mt.RandList();
			for(a in sclient.likes)
				if( !sclient.hasHappinessMod(HM_PresenceOfLike(a)) )
					all.add( t._("I want ::affect::.", {affect:mt.Utf8.uppercase(Lang.getAffect(a))}), 10 );
				else
					all.add( t._("I need more ::affect::...", {affect:mt.Utf8.uppercase(Lang.getAffect(a))}), 3 );

			for(a in sclient.dislikes)
				if( sclient.hasHappinessMod(HM_PresenceOfDislike(a)) )
					all.add( t._("I don't like ::affect::!!", {affect:mt.Utf8.uppercase(Lang.getAffect(a))}), 6 );

			if( all.length()==0 )
				say( t._("Is this really a hotel?") );
			else
				say(all.draw());
		}
		else {
			var all = new mt.RandList();
			for(a in sclient.likes)
				if( !sclient.hasHappinessMod(HM_PresenceOfLike(a)) )
					all.add( t._("I want ::affect::!!", {affect:mt.Utf8.uppercase(Lang.getAffect(a))}), 3 );

			for(a in sclient.dislikes)
				if( !sclient.hasHappinessMod(HM_PresenceOfDislike(a)) )
					all.add( t._("I don't like ::affect::!!!", {affect:mt.Utf8.uppercase(Lang.getAffect(a))}), 10 );

			if( all.length()==0 )
				say( t._("I HATE this place!") );
			else
				say(all.draw());
		}
	}


	public function getName() {
		if( type!=C_Inspector )
			return sclient.name;
		else
			return Lang.t._("Number ::n::", { n:shotel.level + (isDone()?-1:0) });
	}



	override function unregister() {
		onUnselect();

		if( game.tw!=null )
			Game.ME.tw.terminateWithoutCallbacks(spr.alpha);

		super.unregister();

		if( vipStar!=null ) {
			vipStar.remove();
			vipStar = null;
		}

		if( luggage!=null ) {
			luggage.remove();
			luggage = null;
		}

		if( serviceReq!=null ) {
			serviceReq.remove();
			serviceReq = null;
		}

		if( hapBase!=null ) {
			hapBase.remove();
			hapBase = null;
			hapValue.dispose();
			hapValue = null;
		}

		if( emitIcon!=null ) {
			emitIcon.remove();
			emitIcon = null;
		}

		for(b in bubbles) {
			game.tw.terminateWithoutCallbacks(b.tf.scaleX);
			b.bg.remove();
			b.tf.dispose();
		}
		bubbles = null;

		if( bubbleArrow!=null ) {
			bubbleArrow.remove();
			bubbleArrow = null;
		}

		ALL.remove(this);
	}


	override function postUpdate() {
		super.postUpdate();

		if( Assets.SCALE != 1 )
			spr.scale( Assets.SCALE );

		if( vipStar!=null ) {
			vipStar.visible = true;
			vipStar.setPos(spr.x + (isWaiting()?-15:0), spr.y-hei + Math.cos(time*0.2)*5);
		}

		spr.scaleX *= arrivalAnim;
		spr.scaleY *= arrivalAnim;
		if( arrivalAnim!=1 )
			spr.alpha = arrivalAnim;

		if( floating && !isSleeping() ) {
			spr.x += Math.sin(game.ftime*0.07+id*0.2)*9;
			spr.y -= 10 + Math.cos(game.ftime*0.1+id*0.3)*10;
		}

		if( luggage!=null ) {
			var s = 0.1 + Math.cos(id*0.5 + time*0.2)*0.05;
			luggage.x += (xx-luggage.x)*s;
			luggage.y = yy;
		}

		// Emote
		if( hapBase!=null && hapValue!=null ) {
			hapBase.visible = !cd.has("tempRoom") && !game.hideUI;
			hapBase.x = centerX-70 + Math.cos(time*0.1)*6;
			hapBase.y = yy-hei-10 + Math.sin(time*0.2)*2;
			hapValue.visible = hapBase.visible;
			hapValue.x = hapBase.x-hapValue.textWidth*hapValue.scaleX*0.5;
			hapValue.y = hapBase.y-hapValue.textHeight*hapValue.scaleY*0.5 - 10;
		}


		// Service icon & animation
		if( serviceReq!=null ) {
			serviceReq.x = room.globalLeft + 60;
			var m = game.getMouse();
			var s = MLib.fmin( 105/serviceReq.tile.height, 105/serviceReq.tile.width );

			// Search corresponding service/stock room
			if( !cd.has("serviceCheck") ) {
				var d = 5;
				cd.set("serviceCheck",d);
				cd.unset("serviceCheckOk");
				for(r in shotel.rooms)
					if( r.type==sclient.serviceType && !r.constructing && !r.working )
						switch( r.type ) {
							case R_Laundry :
								cd.set("serviceCheckOk", d);
								break;
							case R_StockBeer, R_StockPaper, R_StockSoap :
								if( r.data>0 ) {
									cd.set("serviceCheckOk", d);
									break;
								}
							default :
						}
			}

			var canBeDone = cd.has("serviceCheckOk");
			if( isOverServiceReq(m.sx, m.sy) ) {
				// Mouse over
				if( canBeDone) {
					serviceReq.scaleX = serviceReq.scaleY = s*1.3+Math.cos(time*0.2)*0.1;
					serviceReq.rotation = Math.cos(time*0.4)*0.04;
				}
				serviceReq.alpha = 1;
			}
			else {
				if( canBeDone ) {
					// Jump around!
					serviceReq.y = room.globalBottom - room.padding - MLib.fabs(Math.sin(time*0.15)*20);
					serviceReq.setScale(s);
					serviceReq.rotation = Math.cos(time*0.2)*0.04;
					serviceReq.alpha = 1;
				}
				else {
					// Cannot complete this service
					serviceReq.y = room.globalBottom - room.padding;
					serviceReq.setScale(s*0.65);
					serviceReq.rotation = 0;
					serviceReq.alpha = 0.6;
				}
			}
		}
	}

	public function clearBubbles() {
		for(b in bubbles) {
			game.tw.terminateWithoutCallbacks(b.tf.scaleX);
			b.bg.remove();
			b.tf.dispose();
		}
		bubbles = [];
		updateBubbles();
	}

	function updateBubbles() {
		// Timer
		var i = 0;
		while(i<bubbles.length) {
			bubbles[i].t--;
			if( bubbles[i].t<0 ) {
				var b = bubbles[i];
				game.tw.terminateWithoutCallbacks(b.tf.scaleX);
				b.bg.remove();
				b.tf.dispose();
				bubbles.splice(i,1);
			}
			else
				i++;
		}

		//var bdy = Math.cos(game.time*0.10+id*17)*8 - (20*1/game.totalScale);
		#if responsive
		var sc = Main.getScale(30, 0.3)/Game.ME.totalScale;
		#else
		var sc = 0.85/Game.ME.totalScale;
		#end
		var bdy = 0;
		var y = yy-hei*0.75;
		for(b in bubbles) {
			// Sprite
			//b.bg.scaleX = b.bg.scaleY = sc;
			//b.tf.scaleX = b.tf.scaleY = sc;
			y-=b.bg.height;
			b.bg.x = Std.int(xx + wid*0.5 + 50);
			b.bg.y = Std.int(y + bdy);
			b.tf.x = b.bg.x + 5;
			b.tf.y = b.bg.y + 5;
			y++;
		}

		// Arrow
		if( bubbles.length>0 && bubbleArrow==null ) {
			bubbleArrow = Assets.tiles.addBatchElement(Game.ME.tilesSb, "uiDialArrow",0, 0.5, 0);
			bubbleArrow.rotation = Math.PI*0.5;
		}
		if( bubbles.length==0 && bubbleArrow!=null ) {
			bubbleArrow.remove();
			bubbleArrow = null;
		}
		if( bubbleArrow!=null ) {
			bubbleArrow.x = Std.int( xx+wid*0.5 + 50 );
			bubbleArrow.y = Std.int( yy-hei*0.75 - 10*sc + bdy );
			bubbleArrow.scaleX = bubbleArrow.scaleY = 0.5*sc;
		}
	}


	override function updateHandIcon() {
		var iconId : String = null;
		var scale = 0.7;
		if( sclient.hasFlag("hand_beer") )		{ iconId = "itemBeer"; scale = 0.9; }
		if( sclient.hasFlag("hand_souvenir") )	{ iconId = "gift"; scale = 0.8; }
		if( sclient.hasFlag("hand_cold") )		{ iconId = "itemIcecube"; scale = 1; }
		if( sclient.hasFlag("hand_heat") )		{ iconId = "itemRadiator"; scale = 0.9; }
		if( sclient.hasFlag("hand_noise") )		{ iconId = "itemRadio"; scale = 0.9; }
		if( sclient.hasFlag("hand_odor") )		{ iconId = "itemCheese"; scale = 1; }

		if( iconId!=null && handIcon==null && !isWaiting() ) {
			handIcon = Assets.tiles.addBatchElement(game.tilesFrontSb, iconId, 0, 0.5, 0.5);
		}

		if( iconId==null && handIcon!=null ) {
			handIcon.remove();
			handIcon = null;
		}

		if( handIcon!=null ) {
			handIcon.x = handX + (spr.x-xx);
			handIcon.y = handY + ( isWalking() ? Math.cos(time*0.3)*7 : 0 ) + (spr.y-yy);
			handIcon.scaleX = scale*dir;
			handIcon.scaleY = scale;
			handIcon.rotation = Math.cos(time*0.08)*0.05 + dir*0.1;
			handIcon.visible = spr.visible && !isDragged();
			handIcon.alpha = spr.alpha;
		}
	}

	public function canBeDragged() {
		return !isDone() && !cd.has("tempRoom");
	}

	public function goToRoomTemporarily(r:b.Room) {
		if( room.is(R_Bedroom) )
			room.openDoor(false);
		game.fx.smokeBomb(this);
		room = r;
		cd.set("tempRoom", Const.seconds(1.3));
		cd.onComplete("tempRoom", goBackToRealRoom);

		cd.set("tempRoomFx", Const.seconds(1.3)*0.72);
		cd.onComplete("tempRoomFx", function() {
			var r = game.hotelRender.getRoomAt(sclient.room.cx, sclient.room.cy);
			game.fx.moveClient(centerX, centerY, r.globalLeft+wid*0.5, r.globalCenterY);
		});
	}

	public function getRealRoom() : Null<b.Room> {
		return
			if( destroyAsked || sclient==null )
				return null;
			else
				game.hotelRender.getRoomAt(sclient.room.cx, sclient.room.cy);
	}

	public function isInRealRoom() {
		return sclient!=null && sclient.room!=null && sclient.room.cx==room.rx && sclient.room.cy==room.ry;
	}

	public function isInLobby() {
		return room!=null && room.is(R_Lobby);
	}

	public function goBackToRealRoom() {
		var r = game.hotelRender.getRoomAt(sclient.room.cx, sclient.room.cy);
		if( room==r )
			return;

		cd.unset("tempRoom");
		room = r;
		room.updateHud();
		if( room.isSelected() )
			game.refreshSelectionUi();

		setPos( room.globalLeft + wid*0.5, room.globalBottom );
		room.openDoor(true);
		//setPos( room.globalLeft + rnd(0.3, 0.7)*room.wid, room.globalBottom );
		game.fx.smokeBomb(this);
	}


	public function isOverServiceReq(x,y) {
		return serviceReq!=null && mt.deepnight.Lib.distanceSqr(x, y, serviceReq.x, serviceReq.y-30)<=60*60;
	}

	public function isOver(x,y) {
		return x>=xx-wid*0.6 && x<=xx+wid*0.6 && y>=yy-hei && y<=yy;
	}

	override function update() {
		super.update();

		// Arrival animation
		if( arrivalAnim!=1 ) {
			arrivalAnim+=(1-arrivalAnim)*0.12;
			if( MLib.fabs(1-arrivalAnim)<=0.05 ) {
				spr.alpha = 1;
				arrivalAnim = 1;
			}
		}

		// Emit particles
		if( emitIcon!=null ) {
			emitIcon.visible = !cd.has("tempRoom") && !isDone() && !game.hideUI && !isDragged();
			if( emitIcon.visible && !cd.has("emitFx") && sclient.emit!=null ) {
				game.fx.affectEmit(this, emitIcon.x, emitIcon.y, sclient.emit);
				cd.set("emitFx", ALL.length>15 ? 20 : 12);
			}
		}

		// Service
		var hasService = hasServiceRequest();
		if( room!=null && room.is(R_Bedroom) && serviceReq==null && hasService ) {
			var k = switch( sclient.serviceType ) {
				case R_Laundry : "laundryBasket";
				case R_StockPaper, R_StockBeer, R_StockSoap : Assets.getStockIconId(sclient.serviceType);
				default : "iconTodoRed";
			}
			serviceReq = Assets.tiles.addBatchElement(game.tilesFrontSb, -10, k,0, 0.5, 1);
			serviceReq.y = room.globalBottom;
			#if trailer
			serviceReq.visible = false;
			#end
		}
		if( !hasService && serviceReq!=null ) {
			serviceReq.remove();
			serviceReq = null;
			room.updateGiftPositions();
		}

		// Sleeping minigame
		if( isSleeping() ) {
			game.fx.sleeping(this);
			if( !game.cd.hasSet("sleepSound", Const.seconds(rnd(6,10))) ) { // warning: use game cooldown to avoid multiple Sfx at the same time
				mt.flash.Sfx.playOne([
					Assets.SBANK.sleep1,
					Assets.SBANK.sleep2,
				], rnd(0.08, 0.15));
			}
		}

		updateBubbles();
		updateAffect();

		// VIP star
		if( isVip() ) {
			if( vipStar==null ) {
				vipStar = Assets.tiles.addBatchElement(Game.ME.tilesFrontSb, -2, "iconVip",0, 0.5,1);
				vipStar.setScale(1.2);
			}
			vipStar.visible = !isDragged();
			game.fx.vipSparks(this);
		}


		// Leave luggage
		setLuggage( isDone() );
		if( luggage!=null )
			luggage.alpha = spr.alpha;
	}
}

