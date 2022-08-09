package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class Scanner extends CardFx {//}
	
	
	var box:flash.display.Sprite;
	var grid:flash.display.Sprite;
	var stats:flash.display.Sprite;
	var field:flash.text.TextField;
	var title:flash.text.TextField;
	var flip:Int;
	
	public function new(ca) {
		super(ca);
		flip = 0;
	}
	

	override function update() {
		super.update();
		flip++;
		var near = sn.getNearestFruit();
		majScan(near);
		
		//if( box!=null ) box.visible = flip % 4 < 2;
		//if( box != null ) box.visible = flip % 2 == 0;
		
		if ( !card.active ) vanish();
		
		
		
	}
	
	public function majScan(fr:Fruit) {
		var cur = fr;
		if( box == null ) {
			box = new flash.display.Sprite();
			Stage.me.dm.add( box, Stage.DP_FX );
			
			grid = new flash.display.Sprite();
			Stage.me.dm.add(grid, Stage.DP_FX);
			grid.alpha = 0.75;
			grid.blendMode = flash.display.BlendMode.ADD;
			
			field = Cs.getField(0xFFFFFF,8,0);
			field.width = 30;
			
			title = Cs.getField(0xFFFFFF,8,0);
			title.width = 100;
			
			box.addChild(field);
			box.addChild(title);
			
			stats = new flash.display.Sprite();
			box.addChild(stats);
			
			
			Filt.glow(grid, 2, 1, 0x226600);
			Filt.glow(box, 2, 1, 0x228800);
			
			//box.blendMode = flash.display.BlendMode.ADD;
			
		
			
		}
		if( fr == null ) {
			box.visible = false;
			return;
		}
		
		box.visible = true;
		box.x = Std.int(fr.x);
		box.y = Std.int(fr.y);
		grid.x = box.x;
		grid.y = box.y;

		// RECT
		grid.graphics.clear();
		grid.graphics.lineStyle(1, 0xFFFFFF);
		var r = fr.box.clone();
		r.inflate(2, 2);
		
		var dif = 9 - (r.height + r.y);
		if( dif > 0 ) r.inflate(dif,dif);
		
		
		grid.graphics.drawRect( r.x, r.y, r.width, r.height );
		
		
		
		// GRID
		grid.graphics.lineStyle(1, 0xFFFFFF,0.15);
		var ec = 3;
		var xmax = Std.int(r.width / ec);
		for( x in 0...xmax) {
			var px = r.x + x * ec;
			grid.graphics.moveTo(px,r.y);
			grid.graphics.lineTo(px,r.y+r.height);
		}
		var ymax = Std.int(r.height / ec);
		for( y in 0...ymax) {
			var py = r.y + y * ec;
			grid.graphics.moveTo(r.x,py);
			grid.graphics.lineTo(r.x+r.width,py);
		}
		
		
		// SIDE
		var side = (fr.x < Stage.me.width * 0.5)?0:1;

		// FIELD SCORE
		//field.text = fr.data.name.toUpperCase();
		field.text = Std.string(fr.data.score);
		var sc = Std.int( Fruit.getAverageScore(fr.data.rank)*fr.data.score * 0.1 );
		field.text = Std.string(sc);
		field.width = field.textWidth + 4;
		field.y = r.y - 2;
		
		// FIELD TITLE
		//var name = fr.data.name;
		var name = Data.TEXT[Fruit.getId(fr.data.rank)].fruit;
		title.text = Lang.killLatin(name).toUpperCase();
		title.width = title.textWidth + 4;
		title.y = r.y - 9;
		
		// STATS
		stats.y = field.y + 11;
		stats.graphics.clear();
		var a = [fr.data.vit, fr.data.cal, fr.data.sta, ];
		var color = [ 0xFFCCCC, 0xFFFFCC, 0xCCCCFF ];
		//var color = [ 0xDD0000, 0xFFFF22, 0x2222FF ];
		
		var ma = 3;
		
		var max = 0;
		var size = 2;
		for( n in a ) max = Std.int(Math.max(n, max));
		
		for( i in 0...3 ) {
			var val  = a[i];
			var y = i * (size+1);
			//stats.graphics.lineStyle(size, color[i] ,1,null,null,flash.display.CapsStyle.SQUARE);
			stats.graphics.lineStyle(size, color[i] ,1);
			stats.graphics.moveTo(ma,y);
			stats.graphics.lineTo(ma + val, y);
			
		}
	
		switch(side) {
			case 0 :
			
				field.x = r.x + r.width;
				stats.x = r.x + r.width;
				stats.scaleX = 1;
				title.x = r.x-2;
				
			case 1 :
				field.x = 1 + r.x - field.width;
				stats.x = 1 + r.x;
				stats.scaleX = -1;
				title.x = r.width+r.x+4-title.width;
		}
		
		
		
	}
	
	override function kill() {
		super.kill();
		if(box.parent!=null)box.parent.removeChild(box);
		if(grid.parent!=null)grid.parent.removeChild(grid);
	}
	
	
//{
}












