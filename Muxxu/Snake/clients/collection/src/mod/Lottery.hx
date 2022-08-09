package mod;
import Protocole;
import mt.bumdum9.Lib;
using mt.deepnight.SuperMovie;


class Lottery extends Module{//}

	static var BY = 42;
	static var BH = 80;
	static var FH = 12;
	
	public var desc:flash.text.TextField;
	
	public function new( ) {
		
		super();
	
		// BG
		var g = graphics;
		g.beginFill(Gfx.col("green_0",-10));
		g.drawRect(0, BY, mcw, BH);
		g.drawRect(0, mch-FH, mcw, FH);
		
		// DESC
		var f = Snk.getField(Gfx.col("green_0",30), 8, -1, "nokia" );
		
		f.width = 180;
		f.height = 80;
		f.multiline = true;
		f.wordWrap = true;
		addChild(f);
		desc = f;
		setDesc(Lang.LOTTERY_DESC);
		
		// TITLE
		var field =  Snk.getField(Gfx.col("green_0", 50), 20, -1, "upheaval");
		field.text = Lang.COLLECTION_TITLE_LOTTERY;
		field.width = field.textWidth+4;
		field.x = Std.int((mcw - field.width) * 0.5);
		addChild(field);
				
		// PREVIOUS WINNER
		var f = Snk.getField(Gfx.col("green_0",50), 8, -1, "nokia" );
		f.y = mch - (FH+1);
		f.x = 2;
		f.width = 200;
		f.htmlText = Lang.YESTERDAY_WINNER+"<font color='#FFFFFF'><a href='"+ Main.data._lotteryWinner._url+"'>" + Main.data._lotteryWinner._name+"</a></font>";
		addChild(f);
		
		
		// LOTERINE
		var el = new pix.Element();
		el.drawFrame( Gfx.collection.get(1, "perso"), 1, 1);
		el.x = mcw;
		el.y = mch;
		addChild(el);
		
		// CARD
		displayCard();
		
		
	}
	
	function setDesc(str) {
		desc.text = str;
		desc.width = 200;
		desc.height = desc.textHeight+4;
		desc.x = Std.int((mcw - desc.width) * 0.5) - 30;
		desc.y = BY + BH + Std.int((76 - desc.height) * 0.5);
	}
	
	function displayCard() {
		var card = new GfxCard(2);
		card.setType(Main.data._lotteryCard);
		card.x = 48;
		card.y = BY+40;
		card.coef = 0.25;
		card.majSprite();

		//
		card.onOver( callback(setDesc, Data.TEXT[Type.enumIndex(Main.data._lotteryCard)].desc ) );
		card.onOut( callback(setDesc, Lang.LOTTERY_DESC ) );
		
		//addEventListener( fmash
		
		var first = Snk.getField(0xFFFFFF, 20, -1, "upheaval" );
		first.text = Lang.DAILY_CARD;
		first.width = first.textWidth;
		first.x = card.x + 30;
		first.y = card.y -34;
		
		var d = Main.data;
		var a = Lang.LOTTERY_STATS;

		var c = 0.0 ;
		if( d._tickets > 0 && d._totalTickets > 0 ) c = d._tickets / d._totalTickets;

		
		var b = [ d._tickets, d._totalTickets, c*100 ];
		
		for( id in 0...3 ) {
			var title = Snk.getField(0xFFFFFF, 8, -1, "nokia" );
			title.text = a[id];
			title.x = first.x;
			title.y = first.y + (id+1) * 12 + 10;
			
			var val = Snk.getField(0xFFFFFF, 8, -1, "nokia" );
			val.x = title.x + 100;
			val.y = title.y;
			val.text = Std.string(b[id]);
			val.width = val.textWidth + 4;
			if( id == 2 ) {
				var str = val.text;
				var a = str.split(".");
				if(a.length > 1) {
					a[1] = a[1].substr(0, 2);
					str = a.join(".");
				}
				val.text = str + "%";
				val.width = val.textWidth + 4;
			}else {
				var icon = new pix.Element();
				icon.drawFrame(Gfx.collection.get("ticket"), 0, 0 );
				icon.x = val.x + val.width ;
				icon.y = val.y + 2 ;
				addChild(icon);
			}
			
			addChild(title);
			addChild(val);
			
		}
		
		addChild(first);
		addChild(card);
	}


	
//{
}








