package st;
import mt.bumdum.Lib;

class Move extends State{//}

	var flBack:Bool;

	var att:Fighter;
	var def:Fighter;

	var tx:Float;
	var ty:Float;
	var sx:Float;
	var sy:Float;



	public function new(aid,?did,dx=0) {
		super();
		flBack = did==null;

		att = Game.me.getFighter(aid);
		def = Game.me.getFighter(did);
		if( def == null ) def = Game.me.getCadaver(did);

		setMain();

		sx = att.x;
		sy = att.y;

		if(flBack){
			att.setSens(-1);
			tx = att.bx;
			ty = (att.by + att.y )*0.5;
			
			if( !Game.me.isFree(tx,ty) ){
				var p = Game.me.getFreePos(att.team);
				tx = p.x;
				ty = p.y;
			}
			
		}else{
			var m = 30;
			//att.bx = Num.mm( m, att.x, Cs.mcw-m);
			att.bx = Cs.mcw*0.5 + (120+Math.random ()*50)*att.side;
			att.by = att.y;

			var lim = 30;
			var dif = att.bx-Cs.mcw*0.5;
			if( dif*att.side > 0 && Math.abs(dif)-50>lim){
				 att.bx -= att.side * lim;
			}

			tx = def.x - ( def.getRange() + att.getRange() + dx )*def.side;
			ty = def.y  ;
		}

		var dx = tx-sx;
		var dy = ty-sy;
		var dist = Math.sqrt(dx*dx+dy*dy);
		cs = 20/dist;
		if( cs < 1 ){
			att.recal();
			att.playAnim("run");
		}

		//trace("startMove");

	}



	override function update() {
		super.update();
		att.x = sx*(1-coef) + tx*coef;
		att.y = sy*(1-coef) + ty*coef;
		if( coef==1 ){
			if(flBack){
				att.setSens(1);
				att.backToNormal();
			}
			//trace("endMove");
			end();
			kill();
		}



	}



//{
}