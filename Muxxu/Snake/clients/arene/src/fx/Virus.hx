package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;



class Virus extends CardFx {//}
	
	public static var me:Virus;
	public static var tag:FTag;
	public static var board:SP;
	
	
	public function new(ca) {
		super(ca);
		me = this;

		
	}
	

	override function update() {
		super.update();
		

	}
	
	
	public function onFruitVanish(fr:Fruit) {
		
		tag = null;
		for ( t in fr.data.tags ) {
			switch(t) {
				case Red, Green, Blue, Yellow, Pink, Orange : tag = t;
				default :
			}
		}	
		card.fxUse();
		
		
		var n = 80;
		var o = { r:n, g:0, b:0 };
		if( tag == Green ) o = { r:0, g:n, b:0 };
		if( tag == Blue ) o = { r:0, g:0, b:n };
		if( tag == Pink ) o = { r:n, g:0, b:n };
		if( tag == Orange ) o = { r:n, g:n>>1, b:0 };
		if( tag == Yellow ) o = { r:n, g:n, b:0 };

		card.gfx.illus.filters = [];
		Filt.grey( card.gfx.illus, tag == null?0:1, null, o);
		
		/*
		if( board != null ) card.sprite.removeChild(board);
		board = new SP();
		card.sprite.addChild(board);
		
		
		for ( i in 0...2 ) {
			var y = 0;
			for ( t in tags ) {
				var f = Cs.getField(0xFFFFFF, 8, -1, "nokia");
				f.text = Lang.FRUIT_TAGS[Type.enumIndex(t)];
				board.addChild(f);
				f.y = y * 10 - 20;
				f.x = - 20;
				
				y++;
				Filt.glow(f, 2, 4, 0);
				
				if ( i == 0 ) f.alpha = 0.05;
				if ( i == 1 ) f.blendMode = flash.display.BlendMode.OVERLAY;
				
			}
		}
		*/
		
		
	}
	
	public function isOk (data:DataFruit) {
		if ( tag == null ) return true;
		for ( t in data.tags ) if ( t == tag ) return false;
		return true;
		 
	}
	
	override function kill() {
		super.kill();
		me = null;
	}

	
	

	
//{
}












