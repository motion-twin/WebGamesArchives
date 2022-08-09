import haxe.Log;
import mt.bumdum9.Lib;


class SquareNumBlock extends McSquareNumBlock {
	
	public static var MARGIN = 88;
	public static var EC = 90;
	
	public var num:Int;
	public var px:Int;
	public var py:Int;
	public var id:Int;
	public function new(x, y, num,id) {
		super();
		this.px = x;
		this.py = y;
		this.num = num;
		this.id = id;
		
		var red = id == 4;
		
		gotoAndStop(red?2:1);
		field.text = Std.string(num + 1);
		field.filters = [new flash.filters.GlowFilter(red?0xB91D59:0x672DB6, 1, 8, 8, 170)];
		majPos();
	}
	public function majPos() {
		x = MARGIN + px* EC;
		y = MARGIN + py* EC;
	}
	
	public function light() {
		Col.setColor(this, 0, 40);
	}
	public function unlight() {
		Col.setColor(this, 0, 0);
	}
}

class SquareNum extends Game{//}


	var blocks:Array<SquareNumBlock>;
	var results:Array<McSquareSum>;
	var swap:Array<SquareNumBlock>;
	var coef:Float;
	
	override function init(dif:Float) {
	
		gameTime =  800;
		super.init(dif);
		
		var sums = 1 + Math.round(dif * 5);
		
		//
		bg = new BgSquareNum();
		dm.add(bg, 0);
		//
		
		
		//
		blocks = [];
		var nums = [];
		for( i in 0...9 ) nums.push(i);
		Arr.shuffle(nums);
		
		// GEN PUZZLE;
		for( i in 0...9 ) {
			var mc = new SquareNumBlock(i % 3, Std.int(i / 3), nums[i],i);
	
			blocks.push(mc);
			dm.add(mc, 1);
			var me = this;
			if( i != 4 ) mc.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.clickBlock(mc); } );


			
		}
		
		//
		var ma = SquareNumBlock.MARGIN;
		var ec = SquareNumBlock.EC;
		results = [];
		for( i in 0...sums ) {
			var mc = new McSquareSum();
			dm.add(mc, 1);
			if( i < 3 ) {
				mc.x = ma + ec * 3 - 6 ;
				mc.y = ma + i*ec;
			}else {
				mc.x = ma + (i-3)*ec;
				mc.y = ma + ec * 3 - 10;
			}
			mc.arr.gotoAndStop(i<3?1:2);
			results.push(mc);
		}
		
		//
		coef = 0;
		maj();
		
	}

	
	override function update(){
		super.update();
	
		if( win ) {
			coef = (coef + 0.05) % 1;
			var c = coef;
			var a = [];
			for( mc in blocks ) {
				var color = Col.getRainbow2(c);
				Col.setColor( mc, color, -100 );
				c += 0.05;
			}
			for( mc in results ) {
				var color = Col.getRainbow2(c);
				Col.setColor( mc, color, -100 );
				c += 0.05;
			}

		}

	}

	
	function clickBlock(mc:SquareNumBlock) {
		if( swap.length == 2 ) return ;
		mc.light();
		swap.push(mc);
		if( swap.length == 2 ) {

			var a = [swap[1].id, swap[0].id];
			for( i in 0...2 ) {
				var mc = swap[i];
				dm.over(mc);
				var fx = new mt.fx.Tween(swap[i], swap[1 - i].x, swap[1 - i].y);
				fx.curveInOut();
				if( i == 0 ) fx.onFinish = maj;
				mc.id = a[i];
			}
			blocks.sort(order);
		}
	}
	
	function order(a:SquareNumBlock,b:SquareNumBlock) {
		if( a.id < b.id ) return -1;
		return 1;
	}

	function maj() {
		
		if(swap!=null)for( mc in swap ) mc.unlight();
		swap = [];
		
		var success = true;
		
		for( i in 0...2 ){
			for( a in 0...3 ) {
				var sum = 0;
				for( b in 0... 3) {
					switch(i) {
						case 0 : sum += blocks[a * 3 + b].num+1;
						case 1 : sum += blocks[b * 3 + a].num+1;
					}
				}
				
				var ok = sum == 15;
				
				var mc = results[i * 3 + a];
				if( mc == null ) continue;
				mc.gotoAndStop(ok?2:1 );
				mc.field.text = Std.string(sum);
				if(!ok) success = false;
				
			}
		}
		
		if( success ) setWin(true, 30 );
		
	}



//{
}

