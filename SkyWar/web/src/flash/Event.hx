import GEvent;

class Event extends flash.display.Sprite {
	public static var W = 28;
	public static var DEFAULT_Y = 30;
	public var gameEvent : GEvent;
	var p1 : Null<Int>;
	var p2 : Null<Int>;
	
	public function new( e:GEvent ){
		super();
		gameEvent = e;
		switch (e.kind){
			case Frag(killerId, deadId):
				p1 = killerId;
				p2 = deadId;
				draw(Progression.getPlayerColor(deadId), "pastille_mort.png", 4, 5);
				
			case IsleWon(playerId):
				p1 = playerId;
				draw(Progression.getPlayerColor(playerId), "pastille_colonisation.png", 4, 5);
				
			case IsleRaz(killerId, looserId):
				p1 = killerId;
				p2 = looserId;
				draw(Progression.getPlayerColor(killerId), "pastille_destruction.png", 3, 3);
				// draw(Progression.getPlayerColor(looserId), "pastille_perte.png");

			case Giveup(playerId):
				p1 = playerId;
				draw(Progression.getPlayerColor(playerId), "pastille_abandon.png", 3, 4);
		}
		x = Progression.tickToX(gameEvent.tick) - (width / 2);
		y = DEFAULT_Y;
		var me = this;
		addEventListener(flash.events.MouseEvent.MOUSE_OVER, callback(showTip,true));
		addEventListener(flash.events.MouseEvent.MOUSE_OUT, callback(showTip,false));
	}

	function draw( color:{bg:UInt, fg:UInt}, image, imgx=0, imgy=0 ){
		Progression.fillEllipse(this, 0x61686c, 0, 0, 28, 28);
		Progression.fillEllipse(this, color.bg, 2, 2, 24, 24);
		var img = new flash.display.Loader();
		img.load(new flash.net.URLRequest("/gfx/"+image));
		img.x = imgx;
		img.y = imgy;
		if (color.fg != 0){
			var container = new flash.display.Sprite();
			/* NOTE: origin FG = 0xfcf8f8; */
			var r = (color.fg >> 16 & 0xFF) / 0xfc;
			var g = (color.fg >> 8 & 0xFF) / 0xf8;
			var b = (color.fg & 0xFF) / 0xf8;
			container.filters = [
				new flash.filters.ColorMatrixFilter(
					[ r, 0, 0, 0, 0,
					  0, g, 0, 0, 0,
					  0, 0, b, 0, 0,
					  0, 0, 0, 1, 0,
					]
				)
			];
			container.addChild(img);
			addChild(container);
		}
		else
		{
			addChild(img);
		}
	}

	function showTip( b:Bool, _ ){
		if (!b){
			Tip.hide();
			return;
		}
		var text = ""; // Std.string(gameEvent.tick)+": ";
		switch (gameEvent.kind){
			case Frag(killerId, deadId):
				text += "<b>"+Progression.getPlayerName(deadId)+"</b> est supprimé par <b>"+Progression.getPlayerName(killerId)+"</b>";
				
			case IsleWon(playerId):
				text += "<b>"+Progression.getPlayerName(playerId)+"</b> colonise une nouvelle île";
				
			case IsleRaz(killerId, looserId):
				text += "<b>"+Progression.getPlayerName(killerId)+"</b> neutralise une île de <b>"+Progression.getPlayerName(looserId)+"</b>";

			case Giveup(playerId):
				text += "<b>"+Progression.getPlayerName(playerId)+"</b> abandonne la partie";
		}
		Tip.show(text);
	}

	public function filter( forPlayerId:Int ) : Bool {
		return p1 == forPlayerId || p2 == forPlayerId;
	}
}