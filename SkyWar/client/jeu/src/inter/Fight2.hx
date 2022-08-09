package inter;
import inter.Fight;
import Datas;
import mt.bumdum.Lib;
import mt.bumdum.Trick;


class Fight2 extends Fight {//}


	var grid:Array<Array<flash.MovieClip>>;
	var mcIsle:flash.MovieClip;

	public function new(isle:Isle,data:DataFight){
		super(isle,data);
		isle.root._visible = false;
		isle.bg._visible = false;



	}
	override function placeBuildings(data:DataFight){
		buildIsle(data);
		super.placeBuildings(data);
	}
	override function linkBld(o:DataBuilding){

		var mc:McMiniBuilding = cast grid[o._x][o._y];
		var car = BuildingLogic.get(o._type);
		mc.data = o;
		mc.life = o._life;
		mc.lifeMax = car.life;
		mc.bx = mc._x;
		mc.by = mc._y;
		mc.tx = mc._x+mcIsle._x;
		mc.ty = mc._y+mcIsle._y;
		mc.fet = 1;
		mc.sid = Type.enumIndex(o._type)+100;
		mc.id = o._id;
		blds.push(mc);
		ents.push(mc);
	}

	override function placeUnits(data:DataFight){

		// UNITS
		for( i in 0...2 ){
			var sens = -(i*2-1);

			// ATTACH
			var ec = 24;
			var ec = 28;
			var ma = 40;
			var trj = 150;
			var trjx = -sens*50;
			var trjy = 0;

			var a = [];
			for( o in data._ships ){
				if( (i==0) == (o._owner==data._defenderId) )a.push(o);
			}


			var ymax = Math.ceil( Math.pow(Math.sqrt(a.length), 1.1)  );
			var xmax = Math.ceil( a.length/ymax );
			var y = 0;
			var x = 0;

			var by = (Cs.mch-(ec*ymax))*0.5;

			for( o in a ){

				var tx = Cs.mcw*i+(5+ma+x*ec)*sens;
				var ty = by+y*ec;
				var mc = attachShip(o,tx,ty);
				mc._xscale = -sens*100;
				mc.sx = mc.tx - sens*(xmax*ec+30);
				mc._x = mc.sx;

				var player = Game.me.getPlayer(o._owner);
				Col.setColor(mc.smc,Cs.COLORS[player._color]);

				y++;
				if(y==ymax){
					y = 0;
					x++;
				}
			}

		}


	}
	override function genShip(data:DataShip,tx,ty){

		var mc:McMiniShip = cast dm.empty(Fight.DP_SHIPS);
		mc.dm = new mt.DepthManager(mc);
		mc.smc = mc.dm.attach("mcMapShip",0);
		mc.smc.gotoAndStop(Type.enumIndex(data._type)+1);

		return mc;
	}

	override function update(){
		super.update();
	}

	function buildIsle(data:DataFight){
		var pgr = isle.pl.getGrid();

		// LAND
		var ec = 22;
		mcIsle = dm.empty(Fight.DP_SHIPS);
		var idm = new mt.DepthManager(mcIsle);
		var xMin = 999;
		var yMin = 999;
		var xMax = 0;
		var yMax = 0;
		grid = [];
		for( x in 0...Cns.GRID_MAX ){
			grid[x] = [];
			for( y in 0...Cns.GRID_MAX ){
				if(pgr[x][y]!=null){
					var mc = idm.attach("mcIconesBatiments",Fight.DP_SHIPS);
					grid[x][y] = mc;
					mc._x = x*ec;
					mc._y = y*ec;
					mc.stop();
					mc.smc.stop();
					if(x>xMax)xMax = x;
					if(y>yMax)yMax = y;
					if(x<xMin)xMin = x;
					if(y<yMin)yMin = y;
				}
			}
		}

		var ww = (xMax-xMin)*ec;
		var hh = (yMax-yMin)*ec;
		mcIsle._x = (Cs.mcw-ww)*0.5 - xMin*ec;
		mcIsle._y = (Cs.mch-hh)*0.5 - xMin*ec;
		Filt.glow(mcIsle,2,4,0xFFA800);

		// GEN BLD
		for( o in data._bld ){
			var mc = grid[o._x][o._y];
			isle.displayBld(mc,o);
			idm.over(mc);
		}



	}

	override function remove(){
		mcIsle.removeMovieClip();
		isle.root._visible = true;
		isle.bg._visible = true;
		super.remove();
	}



//{
}















