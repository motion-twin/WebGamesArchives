package browser;
import Protocole;
import mt.bumdum9.Lib;

private enum DisplayMode {
	DM_SUBSCRIBE;
	DM_DRAFT;
	DM_SCORE;
	
}

private typedef PlayerSlot = { base:SP, av:Avatar, data:_DraftPlayer, fields:Array<TF>, id:Int, dmo:DisplayMode, avs:Int, shade:McSquare, nextAutoPick:Null<Float>  };

class Draft extends Browser {//}
	
	var now:Float;
	var wait:Bool;
	var read:Bool;

	
	var slots:Array<PlayerSlot>;
	var mySlot:PlayerSlot;
	
	#if !dev
	var protocol : tora.Protocol ;
	var pingTimer : haxe.Timer ;
	var lastPing : Null<Int> ;
	#end
	
	var draftTimer:TF;
	
	
	public function new(data) {
		super(data);
		haxe.Log.setColor(0xFF0000);
		action = updateDraft;
		
		mojoBox.visible = false;
		mojoMin = 1;
		slots = [];

		switch( data._draft._step ) {
			case DST_WAIT:
				displayDraftRules();
				displayPrizes();
			
			case DST_SUBSCRIBE:
				
				displayDraftRules();
				displayPrizes();
				displayCentralText( Lang.DRAFT_DESC_OPEN);
				
				var but = addBut(Lang.I_SUBSCRIBE, subscribe);
				but.addNote("500", true);
				but.x -= 20;
				
				for( dp in data._draft._players ) {
					var data = { _data:dp, _cards:0, _packs:0, _score:0, _cardDetails:[], _per:null };
					addSlot(data,DM_SUBSCRIBE);
				}
				
				
			case DST_DRAFT:
				initNav();
				displayDraftTimer();
				connect();
				
				
			case DST_PLAY(players):
				initNav();
				mojoBox.visible = true;
				var a = players.copy();
				a.sort(sortByScore);
				
				for( pl in players ) {
					var num = 1;
					for( pl2 in a ) {
						if( pl2 == pl ) break;
						else num++;
					}
					addSlot(pl, DM_SCORE, num);
				}
				displayDraftTimer();
				
		}
		
	}
	function sortByScore(a:_DraftPlayer, b:_DraftPlayer) {
		if( a._score > b._score ) return -1;
		return 1;
		
	}
	function cleanMess() {
		while(handCards.length > 0) handCards[0].kill();
		while(hand.length > 0) hand[0].kill();
		while(slots.length > 0 ) slots.pop().base.visible = false;
	}
	
	function displayDraftRules() {
		initScroller(Lang.rep(Lang.DRAFT_TEASING, Std.string(Data.DRAFT_TIME_OPEN), Std.string(Data.DRAFT_TIME_CLOSE) ) );
		scroll.y = 71+6;
		
		var ma = 16;
		var f = Cs.getField(0x888888, 8, -1, "nokia");
		f.multiline = true;
		f.wordWrap = true;
		f.x = ma;
		f.y =  7;
		f.width = Cs.mcw-2*ma;
		f.htmlText = Lang.DRAFT_RULES;
		f.height = f.textHeight+6;
		dm.add(f, 1);
	}
	function displayDraftTimer() {
		var f  = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		dm.add(f, Browser.DP_BG_INTER);
		f.width = 120;
		f.x = Cs.mcw-f.width;
		f.y = 82+6;
		f.text = "!!";
		f.textColor = Gfx.col("green_0");
		draftTimer = f;
	}
	function displayAbort() {
		cleanMess();
		displayCentralText(Lang.ABORT, 0);
		addBut(Lang.QUIT, Main.refresh);
		
	}
	function displayDisconnect() {
		cleanMess();
		displayCentralText(Lang.DISCONNECT, 0);
		addBut(Lang.RECONNECT, Main.refresh);
	}
	
	function displayPrizes() {
		var sp = new SP();
		sp.x = 10;
		sp.y = 88+10+6;
		dm.add(sp, 10);
		var ww = 70;
		
		var green = Gfx.col("green_0");
		var textColor = Col.brighten(green, 60);
		var textColor = 0xFFFFFF;
		var y = 0;
		var red = 0xFE7878;
		for( i in 0...4 ) {
		
			if( i == 0 ) {
				var f = Cs.getField(0xFFFFFF, 8, -1, "nokia");
				f.text = Lang.PRIZES;
				f.x = 1;
				sp.addChild(f);
		
			}else{
			
				var f = Cs.getField(textColor,8,-1,"nokia");
				f.x = 1;
				f.y = y;
				f.text = Lang.POS[i-1] + ">";
				var f2 = Cs.getField(textColor, 8, 1, "nokia");
				f2.x = f.x;
				f2.y = y;
				f2.width = ww-12;
				f2.text = Std.string(Data.DRAFT_PRIZES[i-1]);
				f.alpha = f2.alpha = 1;
				f.blendMode = f2.blendMode = flash.display.BlendMode.OVERLAY;
				
				var icon = new pix.Element();
				icon.drawFrame(Gfx.main.get("icon_token"),0,0);
				icon.x = f2.x+f2.width;
				icon.y = f2.y+2;
				sp.addChild(icon);
				
				sp.addChild(f);
				sp.addChild(f2);
			}
			//sp.graphics.lineStyle(1, 0xFFFFFF);
			red = Col.brighten(red, -20);
			sp.graphics.beginFill(red );
			sp.graphics.drawRect(0, y, ww, 12);
			sp.graphics.endFill();
			
			y += 12;
		}
		/*
		var ma = -2;
		sp.graphics.lineStyle(1, 0xFFFFFF);
		sp.graphics.drawRect(ma, ma, ww-(1.5*ma), 12*4-(1.5*ma));
		*/
		sp.filters = [new flash.filters.DropShadowFilter(2,225,0,0.25,0,0)];
		
		
	}
	
	function updateDraft() {
		now = Main.now();
		
		var ddr = data._draft;
		var timeLeft = ddr._timeLimit - now;
	
		if( timeLeft <= 0 ) {
			//Main.refresh();
			return;
		}
		
		switch( ddr._step ) {
			case DST_WAIT:
				displayCentralText( Lang.rep(Lang.DRAFT_DESC_CLOSE, Std.string(Data.DRAFT_PLAYER_MAX), Std.string(Data.DRAFT_TIME_OPEN), Std.string(Data.DRAFT_TIME_CLOSE), Cs.formatTime(timeLeft)));

			case DST_SUBSCRIBE:
				var left = Std.string( Data.DRAFT_PLAYER_MAX - data._draft._players.length );
				displayCentralText( Lang.rep(Lang.DRAFT_DESC_OPEN, Cs.formatTime(timeLeft), left ));
				
			case DST_DRAFT:
				if( !wait ) updateSelection();
				for( slot in slots ) majSlotChrono(slot);
				draftTimer.visible = slots.length < Data.DRAFT_PLAYER_MAX;
				
			case DST_PLAY(players):
			
				updateSelection();
		}
		

		if( draftTimer != null ) draftTimer.text = Lang.DRAFT_LEFT_TIME +" "+Cs.formatTime( timeLeft );

		for( hc in handCards ) hc.update();
		
	}
	function majCentralInstruction() {
		
		
		if( read ) 	return;
		
		// PAS ASSEZ DE JOUEURS
		var dif = Data.DRAFT_PLAYER_MAX - slots.length;
		if( dif > 0 ) {
			displayCentralText(Lang.rep(Lang.WAITING_NEW_PLAYERS,Std.string(dif)));
			setTitle(Lang.PLEASE_WAIT) ;
			return;
		}
	
		// VEUILLEZ PATIENTER
		if( mySlot.data._packs > 0 ) {
			displayCentralText(Lang.PLEASE_WAIT,0);
			setTitle(Lang.PLEASE_WAIT) ;
			return;
		}
		
		// EN ATTENTE DE "JOUEUR"
		var name = "nobody";
		for( i in 0...Data.DRAFT_PLAYER_MAX ) {
			var slot = getNextSlot(mySlot, -(1 + i));
			if( slot.data._packs > 0 ) {
				name = slot.data._data._name;
				break;
			}
		}
		displayCentralText(Lang.WAITING_FOR_PLAYER+name);
		setTitle(Lang.PLEASE_WAIT) ;
			
	}


	function setTitle(t : String) {
		flash.external.ExternalInterface.call("_title", t) ;
	}
	
	
	// SERVER
	function connect() {
		displayCentralText(Lang.SERVER_CONNECT, 0);
		wait = false;
		read = false;
		#if dev
			var slots = [];
			for( i in 0...Data.DRAFT_PLAYER_MAX ) slots.push( {
				_data: { _name:["bumdum", "Irvie", "Warp", "Deepnight", "Yota", "Hiko"][i],
					_avatar:"hale.gif",
					_id:i,
					_rank:10 + Std.random(50) },
				_cards:0,
				_cardDetails:[],
				_packs:1,
				_score:0,
				_per:null,
			});
			var me = this;
			// SIMULATION
			//*
			haxe.Timer.delay( function() { me.receive(MSG_INIT([], slots.splice(0, 1) )); }, 500);
			haxe.Timer.delay( function() { me.receive(MSG_NEW_PLAYER(slots[0])); }, 1000);
			haxe.Timer.delay( function() { me.receive(MSG_PACK([RUNE_VITAMIN, VINE_LEAF, GREEN_HOUSE, SMALL_BELLS], 0, Main.now()+Data.getDraftPickTime(8) )); }, 1000);
			//haxe.Timer.delay( function() { me.receive(MSG_ABORTED);} , 2000);
			

			/*/
			haxe.Timer.delay( function() { me.receive(MSG_INIT([ARROSOIR,RUNE_VITAMIN,VINE_LEAF], [GREEN_HOUSE, SMALL_BELLS], slots )); }, 500);
			//haxe.Timer.delay( function() { me.receive(MSG_PACK([RUNE_VITAMIN, VINE_LEAF, GREEN_HOUSE, SMALL_BELLS])); }, 1000);
			haxe.Timer.delay( function() { me.receive(MSG_PASS(1+Std.random(Data.DRAFT_PLAYER_MAX-1),0,9)); }, 3000);
			haxe.Timer.delay( function() { me.receive(MSG_PASS(1+Std.random(Data.DRAFT_PLAYER_MAX-1),0,9)); }, 6000);
			
			haxe.Timer.delay( function() { me.receive(MSG_PASS(1+Std.random(Data.DRAFT_PLAYER_MAX-1),0,9)); }, 13000);
			haxe.Timer.delay( function() { me.receive(MSG_PASS(1+Std.random(Data.DRAFT_PLAYER_MAX-1),0,9)); }, 16000);
			haxe.Timer.delay( function() { me.receive(MSG_PASS(1 + Std.random(Data.DRAFT_PLAYER_MAX-1),0, 9)); }, 19000);
			//*/
			
			
			/*
			typedef _DraftPlayer = {
				_id:Int,
				_data:_DataPlayer,
				_cards:Int,
				_packs:Int,
				_score:Int,
			}
			*/
			
			
		#else
			protocol = Codec.connect(data._draft._serverUrl, CMD_HELLO, receive) ;
			pingTimer = new haxe.Timer(10000) ;
			pingTimer.run = nextPing;
		#end
		
	}
	
	#if !dev
	function nextPing() {
		if( lastPing != null ) {

			displayDisconnect();
			pingTimer.stop() ;
			try {
			protocol.close() ;
			} catch(e : Dynamic) {}
			return;
		}
		lastPing = Std.random(0x10000);
		Codec.send(protocol, data._draft._serverUrl, CMD_PING(lastPing)) ;
	}
	#end
	
	function receive(msg:_DraftMsg) {
		
		switch(msg) {
			
			case MSG_INIT( cards, pl ) :
				for( data in pl ) {
					var slot = addSlot(data, DM_DRAFT);
					if( slot.data._per != null ) startChrono(slot, data._per);
				}
				var a = [];
				for( type in cards ) a.push( { _type:type, _available:true } );
				nav.set(a);
				/*
				if (pack.length > 0)
					receive(MSG_PACK(pack, mySlot.data._data._id));
				*/
				
				
				majCentralInstruction() ;
			
			case MSG_PACK(cards, to, per ):
				if (mySlot.data._data._id != to)
					return ;

				read = true;
				displayCentralText("");
				var from = getSlotCenter(mySlot.id, -1);
				var sleep = 0;
				for( type in cards ) {
					var hc = new HandCard( { _type:type, _available:true } );
					hc.x = from.x;
					hc.y = from.y;
					hc.moveToHand();
					hc.setSleep(sleep);
					sleep += 3;
				}
				for( hc in hand ) hc.moveToHand();
				
				startChrono(mySlot, per);

				setTitle(Lang.DRAFT_CHOOSE) ;
				
				/* // ### ### ### ### ### ### ### ### ###  TODO : 
				 si on attendait un pack, faire un "tut" ==> previent du lancement du draft et en cas d'attente 
				*/

				
			case MSG_PICK(type, to):
				if (mySlot.data._data._id != to)
					return ;
			
				for( hc in hand ) if( hc.data._type == type ) selectCard(hc);
				if( wait ) wait = false;
				
			case MSG_PASS(pid, to, cards) :			// MSG_ANIM_PASS


				var slot = getSlot(pid);
				if( slot!=mySlot )pick(slot);
				
				if( pid == mySlot.data._data._id ) return;
				if( to == mySlot.data._data._id && mySlot.data._packs == 0 ) return;
				
				// PASS ANIM
				var from = getSlotCenter(slot.id, 0);
				var next = getSlotCenter(slot.id, 1);
				
				for( i in 0...cards ) {
					var card = new pix.Element();
					card.drawFrame(Gfx.main.get("medium_card"));
					card.x = from.x;
					card.y = from.y;
					
					dm.add(card, 5);
					
					var e = new mt.fx.Tween(card, next.x, next.y);
					e.setSin(10);
					e.curveInOut();
					e.onFinish = card.kill ;
					
					new mt.fx.Sleep(e, (cards - i) * 5  );
				}
				
					
				
			case MSG_NEW_PLAYER(data):
				
				addSlot(data,DM_DRAFT);
				majCentralInstruction();
				
			case MSG_END_DRAFT :
				Main.refresh();
			
			case MSG_MULTI(msgs) :
				for (m in msgs)
					receive(m) ;
					
			#if !dev
			case MSG_PINGED(id) :
				if (lastPing == id)
					lastPing = null ;
			#end
				
			case MSG_ABORTED :
				displayAbort();

			case MSG_OK : //nothing to do
			
				
			default:
		}
		
	}
	function send(msg:_DraftCmd,?f) {

		wait = true;
		
		#if dev
			switch( msg ) {
				case CMD_CHOOSE(t) :
					var me = this;
					//haxe.Timer.delay( function() { me.receive(MSG_CONFIRM(null)); }, 500);
					haxe.Timer.delay( function() { me.receive(MSG_PICK(t,0)); }, 500);
					
					// AUTO ANSWER
					var cards = [];
					var a = Type.getEnumConstructs(_CardType);
					for( i in 0...10 ) cards.push(Type.createEnum(_CardType,a[Std.random(Data.CARDS.length)]));
					haxe.Timer.delay( function() { me.receive(MSG_PASS(0,1,9)); }, 500);
					haxe.Timer.delay( function() { me.receive(MSG_PACK(cards,0,Main.now()+10000)); }, 800);
					
				default:
		
			}
			
		#else
			Codec.send(protocol, data._draft._serverUrl, msg) ;
		#end
		
				
		
	}
	
	//
	function getSlot(pid:Int) {
		for( sl in slots ) if( sl.data._data._id == pid ) return sl;
		return null;
	}
	
	function pick(slot:PlayerSlot) {
		slot.data._cards++;
		slot.data._packs--;
		majSlot(slot);
		
		var slot2 = getNextSlot(slot);
		slot2.data._packs++;
		majSlot(slot2);
		

		if( slot.data._packs > 0 ) 		startChrono(slot,now + Data.getDraftPickTime(10-slot.data._cards) );
		else							stopChrono(slot);
		
		if( slot2.data._packs == 1 ) 	startChrono(slot2,now + Data.getDraftPickTime(10-slot2.data._cards) );

		//
		majCentralInstruction();
	}
	
	function getNextSlot(slot:PlayerSlot,inc=1) {
		return slots[Std.int(Num.sMod(slot.id + inc,Data.DRAFT_PLAYER_MAX)) ];
	}
	
	// SUBSCRIBE
	function subscribe() {
		buts.pop().kill();
		displayCentralText(Lang.PLEASE_WAIT,0);
		action = null;
		//var data:_GSubscribeSend = { _id:data._draft._pKey };
		#if dev
			var me = this;
			haxe.Timer.delay( function() { me.subscribeRecept(MSG_SUBSCRIBE(false, true, true)) ; }, 1000 );
		#else
			protocol = Codec.connect(data._draft._serverUrl, CMD_SUBSCRIBE(data._draft._pKey), subscribeRecept) ;
			//Codec.load(Main.domain + "/subscribe", data, subscribeRecept) ;
		#end
		
	}
	function subscribeRecept(data:_DraftMsg) {
		var th = this ;
		var errFunc = function(fmoney, ffull, fconnect) {
			var str = Lang.col(Lang.DRAFT_SUBSCRIBE_ERROR[0],"#FF4444");
			if( fmoney ) str += "\n\n"+Lang.DRAFT_SUBSCRIBE_ERROR[1];
			if( ffull ) 	str += "\n\n"+Lang.DRAFT_SUBSCRIBE_ERROR[2];
			if( fconnect ) 	str += "\n\n"+Lang.DRAFT_SUBSCRIBE_ERROR[2];
			th.displayCentralText(str);
			haxe.Timer.delay( Main.refresh, 4000 );
		}
		
		switch(data) {
			case MSG_SUBSCRIBE(ok, nomoney, full) :
				if( ok )
					Main.refresh();
				else
					errFunc(nomoney, full, false) ;
			default :
				errFunc(false, false, true) ;
		}
	}
	
	// PLAYER SLOT
	static var SLOT_WIDTH = 60;
	static var SLOT_HEIGHT = 43;
	
	function newPlayerSlot( data:_DraftPlayer, id:Int, dmo:DisplayMode, ?pos:Int ) {
	
		var ww = SLOT_WIDTH;
		var hh = SLOT_HEIGHT;
		
		var base = new SP();
		dm.add(base, Browser.DP_CARDS);
		
		var th = 10;
		if( dmo == DM_SCORE ) th *= 2;
		var avs = hh - th;
		
		var slot:PlayerSlot = { base:base, data:data, av:null, fields:[], id:id, dmo:dmo, avs:avs, shade:null, nextAutoPick:null  };
		
		// BG
		var gfx = base.graphics;
		var c = id / Data.DRAFT_PLAYER_MAX;
		var color = Col.getRainbow((0.5+c*0.8)%1);
		gfx.beginFill(color);
		gfx.drawRect(0,0, ww, hh);
		gfx.endFill();
		gfx.beginFill(Col.brighten(color,-80));
		gfx.drawRect(0, 0, ww, 10);
		gfx.endFill();
		
		// SCORE
		if( dmo == DM_SCORE ) {
			gfx.beginFill(Col.brighten(color,-40));
			gfx.drawRect(0, 10, ww, 10);
			gfx.endFill();
			
			var f = Cs.getField(Col.brighten(color,80), 8, -1, "nokia");
			f.y = 8;
			f.htmlText = Lang.col(pos+"> ", "#FFFFFF") + data._score;
			base.addChild(f);

		}
		
		// GLOW
		Filt.glow(base, 2, 40, 0xFFFFFF);
		
		// NAME
		var f = Cs.getField(Col.brighten(color,140), 8, -1, "nokia");
		f.text = data._data._name;
		f.y = -2;
		base.addChild(f);
		
		// AVATAR
		slot.av = new Avatar(avs, data._data._avatar );
		slot.av.y = th;
		base.addChild(slot.av);
		
		slot.shade = new McSquare();
		slot.base.addChild(slot.shade);
		slot.shade.scaleX = slot.avs / 100;
		slot.shade.scaleY = slot.shade.scaleX;
		slot.shade.stop();
		
		slot.shade.y = th;
		Col.setColor(slot.shade,color,-40);
		slot.shade.alpha = 0.75;
		// CARACS
		var frames = [0, 1, 2];
		if( dmo == DM_SCORE ) frames = [0, 2];
		
		for( i in 0...frames.length ) {

			// ICON
			var el = new pix.Element();
			el.drawFrame(Gfx.main.get(frames[i], "icon_draft"),0,0);
			el.x = avs + 1 ;
			el.y = th  + 1 +i * 11;
			
			// FIELD
			var f = Cs.getField(0xFFFFFF, 8, -1, "nokia");
			f.y = el.y -2;
			f.filters = [ new flash.filters.GlowFilter(0, 0.1, 2, 2, 40) ];
			slot.fields.push(f);

			base.addChild(el);
			base.addChild(f);
			
		}
		
		// CHRONO
		//if( dmo == DM_DRAFT && data._packs > 0 ) startChrono(slot);
		
		// BUT
		if( dmo == DM_SCORE ){
			var but = new But();
			but.x = ww * 0.5;
			but.setTransp(ww, hh);
			slot.base.addChild(but);
			var me = this;
			//but.actionOver = function() { me.displayHint("les cartes de "+data._data._name); };
			but.actionOver = function() { me.displayPlayerCards(slot); };
			but.actionOut = displayMyCards;
			buts.push(but);
		}
		//
		majSlot(slot);

		
		return slot;

	}
	function addSlot(data:_DraftPlayer,dmo:DisplayMode,?pos:Int) {
		var slot = newPlayerSlot(data, slots.length, dmo,pos);
		slots.push(slot);
		var pos = getSlotTrgPos(slot.id);
		slot.base.x = pos.x;
		slot.base.y = pos.y+80;
		
		if( data._data._id == this.data._me._id ) mySlot = slot;
		
		// PLACEMENT
		for( slot in slots ) {
			var p = getSlotTrgPos(slot.id);
			new mt.fx.Tween(slot.base, p.x, p.y).curveInOut();
		}
		
		return slot;
	
	}
	function getSlotTrgPos(id) {
		var max = slots.length;
		var ec = 6;
		var mx =  Std.int((Cs.mcw -( SLOT_WIDTH * max + ec * (max - 1)))*0.5);
		return {
			x : mx+(SLOT_WIDTH+ec) * id,
			y : Cs.mch - (SLOT_HEIGHT + ec),
		}
	}
	function majSlot(slot:PlayerSlot) {
		var data = slot.data;
		var a = [ data._cards, data._packs, data._data._rank * 0.1 ];
		if( slot.dmo == DM_SCORE ) a = [ data._cards, data._data._rank * 0.1 ];
		for( i in 0...a.length ) {
			var f = slot.fields[i];
			var str = Std.string(a[i]);
			f.text = str.substr(0, 3);
			var ma = 6;
			var ww = Std.int((SLOT_WIDTH - (slot.avs+ma))*0.5);
			f.x = slot.avs+ ma +ww -Std.int(f.textWidth * 0.5);
			
		}
	}
	
	function startChrono(slot:PlayerSlot,n) {
		slot.nextAutoPick = n;
		Col.setPercentColor(slot.av, 0, 0 );
	}
	function stopChrono(slot:PlayerSlot) {
		slot.nextAutoPick = null;
		slot.shade.gotoAndStop(1);
		Col.setPercentColor(slot.av, 0, 0 );
	}
	
	function majSlotChrono(slot:PlayerSlot) {
		
		if( slot.nextAutoPick == null ) return;
		
		var timeLeft = slot.nextAutoPick- now;
		var timeMax = Data.getDraftPickTime(10 - slot.data._cards);
		var c = 1-timeLeft / timeMax;
		c = Num.mm(0, c, 1);
	
		slot.shade.gotoAndStop(Std.int(c * 160) + 1);
		
		/*
		if( slot == mySlot && timeLeft < 3000 ) {
			var cc = 0.5 + Snk.cos((timeMax-timeLeft) * 0.02) * 0.5;
			Col.setPercentColor(slot.av, cc, 0xFF0000 );
		}
		*/
		
	}
	
	//
	function displayPlayerCards(slot:PlayerSlot) {
		displayHint("les cartes de " + slot.data._data._name);
		nav.set(slot.data._cardDetails);
		
	}
	function displayMyCards() {
		displayHint("");
		nav.set(data._cards);
	}
	
	// CLICK
	override function click(e) {
		
		switch(data._draft._step) {
			case DST_DRAFT:
				if( wait || !read ) return;
				if( selection != null ) {
					var me = this;
					send( CMD_CHOOSE(selection.data._type) );
				}
			case DST_PLAY(players):
				super.click(e);
			default:
			
		}
		

	}
	function selectCard(card:HandCard) {
		read = false;
		pick(mySlot);
		//
		removeCard(card);
		
		var next = getSlotCenter(mySlot.id, 1);
		var me = this;
		var a = hand.copy();
		for( hc in a ) {
			if( hc == card ) continue;
			hc.moveTo(next.x,next.y);
			//hc.onDest = function() { hc.kill(); me.hand.remove(hc); };
			//hand.remove(hc);
			hand.remove(hc);
			handCards.push(hc);
			hc.onDest = hc.kill;
		}

	}
	
	// TOLS
	override function getHandY() {
		return super.getHandY() - 19;
	}
	function getSlotCenter(id, inc) {
		var slot = slots[Std.int(Num.sMod(id + inc,Data.DRAFT_PLAYER_MAX)) ];
		return {x:slot.base.x+SLOT_WIDTH*0.5,y:slot.base.y+SLOT_HEIGHT*0.5}
	}
	
	//
	override function initFade() {
		super.initFade();
		
		draftTimer.visible = false;
		
		// SLOTS
		var sleep = 0;
		for( sl in slots ) {
			var e = new mt.fx.Tween( sl.base, sl.base.x, sl.base.y + 100 );
			e.curveIn(2);
			new mt.fx.Sleep(e, (sl == mySlot)?18:sleep);
			dm.over(sl.base);
			sleep++;
		}
	}

	override function displayNotAvailable() {
		displayHint(Lang.DRAFT_CARD_NOT_AVAILABLE, 0.2);
	}
	
//{
}


















