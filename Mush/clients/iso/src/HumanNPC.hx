
import fx.PointFire;
import mt.Timer;
import Protocol;
import Dirs;
import Types;

using Ex;

import Grid;

class SingleVanity extends ElementEx
{
	public var ofsX:Float;
	public var ofsY:Float;
	
	public var setup : PixSetup;
	public var npc : HumanNPC;
	
	public function new(npc:HumanNPC,idx:String){
		super();
		
		ofsX = ofsY = 0;
		this.npc = npc;
		setup = Data.frame( idx );
		Data.setup(this, setup.sheet,setup.frame, setup.index );
		
		var slice = Data.slices.get(setup.index);
		
		if(slice.autoAnim && hasAnim(idx))
			play(idx);
			
		npc.getGrid().addPostFx(this);
	}

	public function stick(){
		x = npc.el.x + ofsX;
		y = npc.el.y + ofsY;
	}
	
	public function trackY(){
		x = ((npc.el.x +ofsX) * 0.2 + x*0.8);
		y = npc.el.y + ofsY;
	}
	
	public function track( d:Float = 0.2){
		x = (npc.el.x + ofsX) * d + x * (1.0 - d);
		y = (npc.el.y + ofsY) * d + y * (1.0 - d);
	}
	
	public function trackSteep(){
		x = (npc.el.x+ofsX) * 0.5 + x*0.5;
		y = (npc.el.y+ofsY) * 0.5 + y*0.5;
	}
	
	public function isVisible(){
		return npc.visible && npc.laid == false;
	}
	
	public function update(){
	}
}

class HoveringCloud extends SingleVanity
{
	public function new(npc){
		super(npc,"FX_CLOUD");
		ofsY = -20;
	}
	
	public override function update() {
		super.update();
		visible = isVisible() && npc.data.vanities.has( HoveringCloud );
		if(visible) trackY();
	}
}

class Ring extends SingleVanity
{
	var v = 0.0;
	public function new(npc)
	{
		super(npc,"FX_RING");
		ofsY = -25;
	}
	
	public override function update()
	{
		super.update();
		v++;
		visible = isVisible() && npc.data.vanities.has( Ring );
		if (visible)
		{
			trackSteep();
			y += Math.cos( v * 0.1 ) * 0.75;
		}
	}
}

class Gears extends SingleVanity
{
	public function new(npc)
	{
		super(npc,"FX_GEARS");
		ofsY = -25;
		ofsX += 8;
	}
	
	public override function update()
	{
		super.update();
		visible = isVisible() && npc.data.vanities.has( Gears );
		if (visible) stick();
	}
}



class RayOfLight extends SingleVanity{
	public function new(npc){
		super(npc, "FX_RAY_OF_LIGHT");
		ofsY = -20;
	}
	
	public override function update() {
		super.update();
		visible = isVisible() && npc.data.vanities.has( RayOfLight );
		if(visible) trackY();
	}
}

class Thinking extends SingleVanity{
	public function new(npc){
		super(npc, "FX_THINKING");
		ofsY = -20;
	}
	
	public override function update() {
		super.update();
		visible = isVisible() && npc.data.vanities.has( Thinking );
		if(visible) stick();
	}
}

class Music extends SingleVanity{
	public function new(npc){
		super(npc, "FX_MUSIC");
		ofsY = -20;
	}
	
	public override function update() {
		super.update();
		visible = isVisible() && npc.data.vanities.has( Music );
		if(visible) trackY();
	}
}

class Drone extends SingleVanity{
	public function new(npc){
		super(npc, "FX_DRONE");
		ofsY = -30;
	}
	
	public override function update() {
		super.update();
		visible = isVisible() && npc.data.vanities.has( Drone );
		if(visible) track();
	}
}

class Citrouille extends SingleVanity{
	public function new(npc){
		super(npc, "FX_CITROUILLE");
	}
	
	var obs  =  false;
	var superForm = false;
	public var pfs : Array<fx.PointFire>;
	
	var spin = 0;
	public override function update() {
		super.update();
		visible = isVisible() && (npc.data.diseases.has( CITROUILLITE.index() ) || npc.data.vanities.has(SuperCitrouille));
		
		spin++;
		if( spin%30 == 0 ){
			//trace( npc.data );
			//trace( isVisible() );
			//trace( npc.data.diseases.has( CITROUILLITE.index() ) );
			//trace( npc.data.vanities.has(SuperCitrouille) );
		}
		superForm = npc.data.vanities.has(SuperCitrouille);
		if ( superForm ){
			if( pfs == null ){
				pfs = [new PointFire(npc), new PointFire(npc)];
			}
		}
		else {
			if ( pfs != null) {
				for( pf in pfs ) pf.dispose();
				pfs = null;
			}
		}
		
		var bs = npc.isBackSide();
		if ( bs != obs) {
			if ( !bs ) 	goto('FX_CITROUILLE');
			else 		goto('FX_CITROUILLE_BACK');
		}
		obs = bs;
		
		ofsY = -20;
		
		var oz = 3.9;
	
		if( pfs != null)
		//	switch(npc.curDir) 
		{
			//case LEFT:
			//case DOWN:	
			//case UP:	
			//case RIGHT:	
			//default:
			pfs[0].ofs.set( 0, -0.2,oz);
			pfs[1].ofs.set( 0, 0.2,oz);
		}
		
		ofsY += ( Std.int( npc.el.x + npc.el.y ) & 1 == 0) ? 1 : 0;
		stick();
		
		if ( pfs != null) {
			for (pf in pfs) {
				pf.update();
				pf.visible = visible;
			}
		}
	}
}

class Xmas extends SingleVanity
{
	public function new(npc)
	{
		super(npc,"FX_XMASBALL");
		ofsY = -18;
		ofsX += 1;
		/*
		switch(npc.curDir) {
			case 
		}
		*/
	}
	
	public override function update()
	{
		super.update();
		visible = isVisible() && npc.data.vanities.has( XmasBall );
		if (visible) stick();
	}
}

class HumanNPC extends Entity
{
	public var hid : HeroId;
	var sel : Select;
	public var set (default, set_set) : CharSet;
	public var data: Protocol.ClientChar;
	public var curChair : DepInfos;
	public var mark : Bool;
	public static var forceMutant = false;
	public var oldPos : V2I;
	public var curDir : E_DIRS;
	public var laid:Bool;
	
	var hearts : Pool<ElementEx>;
	public var vanities : Array<SingleVanity>;
	
	public var vc : Citrouille;
	
	public inline function getRid() return grid.getRid();
	public function new(gr, data)
	{
		hid = data.id;
		oldPos = new V2I();
		super(gr, PLAYER);
		te.el.mouseEnabled = false;
		Main.allHumanNPC.pushBack(this);
		this.data = data;
		mark = true;
		wpList = new List();
		
		hearts = new Pool( function()
		{
			var e = Data.getElement("FX_HEART2");
			Debug.ASSERT(e != null);
			grid.addPostFx(e);
			return e;
		});

		vanities = [];
		vanities.push( new HoveringCloud(this));
		vanities.push( new Ring(this));
		vanities.push( new Gears(this));
		vanities.push( new RayOfLight(this));
		vanities.push( new Thinking(this));
		vanities.push( new Music(this));
		vanities.push( new Drone(this));
		vanities.push( new Xmas(this));
		vanities.push( vc = new Citrouille(this));
		randDir();
	}
		
	public override function getEntitySet()
	{
		var a = super.getEntitySet();
		if ( a != null && vc != null && vc.pfs != null) {
			for( pf in vc.pfs )
				a.pushBack( pf );
		}
		return a;
	}
	
	public static function getAll()
	{
		return ALL;
	}
	
	public function getTile()
	{
		var p = getGridPos();
		return grid.get( p.x,p.y);
	}
	
	public function getChar() return hid;
	public function setChar(v:HeroId)
	{
		var ov = v;
		var n = getFrame(v,this);
		
		set = CS_UP;
		doSetup( Data.mkSetup( n ));
		
		if( sel == null)
			sel = Main.ship.selectables.pushBack( new Select(grid,this) );
		
		doInput();

		if ( data.room == OUTER_SPACE )
		{
			if(Protocol.heroesList[data.id.index()].base_gender == Male)
				te.el.play("COSMO_MALE");
			else
				te.el.play("COSMO_FEMALE");

		}
		
		return hid = ov;
	}
	
	
	public var turretMask : flash.display.Sprite;
	
	public function circa( to:Tile )
	{
		var p = to.getGridPos();
		var mp = getGridPos();
		var tgt = [];
		for (i in E_DIRS.array())
		{
			var lx = p.x + Dirs.LIST[i.index()].x;
			var ly = p.y + Dirs.LIST[i.index()].y;
			
			if ( grid.isPathable( lx, ly) )
				tgt.pushBack( {x:lx,y:ly} );
		}
		
		var np = tgt.random();
		if ( np != null)
			setPos( np.x, np.y );
	}
	
	public function layDown( item : _ItemDesc )
	{
		var dep : DepInfos = grid.getDepByUid( item.uid ).first();
		if ( dep != null)
		{
			var p = dep.tile.getGridPos();
			setPos( p.x, p.y);
			
			var datSpl = dep.xml.has.data? dep.xml.att.data.split(';'):[];
			var ofsXL = datSpl.find(function(s) return s.startsWith( "ofsx"));
			var ofsYL = datSpl.find(function(s) return s.startsWith( "ofsy"));
			
			var ofsX = (ofsXL != null) ? Std.parseInt(ofsXL.split("_")[1]) : 0;
			var ofsY = (ofsYL != null) ? Std.parseInt(ofsYL.split("_")[1]) : 0;
			
			if ( datSpl.has("flipped"))
			{
				te.el.goto(getFrame(hid,this) + "_LAID_FLIPPED");
				te.el.x += ofsX;
				te.el.y += ofsY;
			}
			else
			{
				te.el.x += ofsX;
				te.el.y += ofsY;
				te.el.goto(getFrame(hid,this) + "_LAID");
			}
			laid = true;
		}
		
		Main.grid().dirtSort();
	}
	
	public function isPlayer() return false;
	public function onTurret( upDown : Bool )
	{
		turretMask = null;
		
		if (  !upDown )
		{
			var spr = new flash.display.Sprite();
			
			var w = 60;
			spr.graphics.beginFill(0x000000,1.0);
			spr.graphics.drawEllipse (0, 0, w, 50);
			spr.graphics.endFill();
			spr.x -= w/2;
			spr.y -= 45;
			
			turretMask = spr;
		}
		
		if ( turretMask != null)
		{
			el.addChild(  turretMask );
			el.mask = turretMask;
		}
	}
	
	public function set_set(s)
	{
		var oldS  = set;
		set = s;
		var d = getDir();
		changeDir(d);
		switch(s)
		{
			default:
			case CS_UP:
			clearFromUse();
			wpList.clear();
			
			case CS_RUNNING:
			clearFromUse();
		}
		//Debug.MSG("set is " + set+" dir is "+ d);
		return set;
	}
	
	public function clearFromUse()
	{
		if( curChair != null)
		{
			curChair.te.el.visible = true;
			curChair = null;
		}
		
		if ( turretMask != null && turretMask.parent != null)
		{
			el.mask = null;
			el.removeChild(turretMask);
		}
	}
	
	public function getMyFrame() return getFrame( hid, this);
	
	public override function undoInput()
	{
		if( grid!= null)
			grid.input.clean( te.el );
		sel.grid = null;
	}
	
	public function jumpInDep(dep:DepInfos)
	{
		var hasPad = false;
		var chair :DepInfos= null;
		
		var d = dep.pad.random();
		if ( d != null)
		{
			Main.ship.kickBlocker( grid, getGridPos(), d );
			setPos( d.x, d.y);
			hasPad = true;
			chair = grid.getChair( d.x,d.y );
		}
			
		changeDir( dep.dir );
		
		var isTurret = dep != null && (dep.iid == TURRET_COMMAND);
		if( chair != null )
		{
			var hideChair = (hid == TERRENCE_ARCHER) || mutant();
			curChair = chair;
			
			if( hideChair )
				curChair.te.el.visible = false;
			
			if (isTurret )
				onTurret( 	dep.baseSetup.index == "turret_alpha");
				
			if (curChair != null || isTurret)
				set = CS_SIT;
		}
		else if ( isTurret )
		{
			onTurret( 	dep.baseSetup.index == "turret_alpha");
			set = CS_SIT;
		}
		else
			set = CS_UP;
	}
	
	public override function doInput()
	{
		sel.grid = grid;
		grid.input.register( ON_ENTER, te.el, sel.Player_onEnter );
		grid.input.register( ON_RELEASE, te.el, sel.Player_onRelease );
		grid.input.register( ON_OUT, te.el, sel.Player_onOut );
	}
	
	function getDir() : Dirs.E_DIRS
	{
		if ( curDir == null) return RIGHT;
		return curDir;
	}
	
	public function randDir()
	{
		for(x in 0...[1,2,3].random())
			turn();
	}
	
	public function changeDir(dir:Dirs.E_DIRS)
	{
		if(set!=null)
		switch(set)
		{
			default:
			
			var b = set.index() * 4;
			if ( mutant() )
			{
				b = 0;
			}
			
			if ( te.setup == null) return;
			te.setup.frame = switch(dir)
			{
				case UP:  b+3;
				case LEFT:  b+2;
				case RIGHT:  b+0;
				case DOWN:  b+1;
			}
			
			te.el.goto( te.setup.frame, te.setup.index );
			
			case CS_RUNNING:
			if ( te.el.anim != null)
				te.el.anim.stop();
				
			try
			{
				var fr = null;
				switch(dir)
					{
						case RIGHT:	fr = "#"+getFrame(hid,this)+"_WALK_RIGHT";
						case LEFT:	fr = "#"+getFrame(hid,this)+"_WALK_LEFT";
						case UP:	fr = "#"+getFrame(hid,this)+"_WALK_UP";
						case DOWN:	fr = "#"+getFrame(hid,this)+"_WALK_DOWN";
					}
				te.el.play(fr);
				#if debug
				//trace("using anim " + fr);
				#end
			}
			catch(d:Dynamic)
			{
				#if debug
				//trace("arg:" + d);
				#end
			}
				
			te.el.anim.goto(0);
		}
		curDir = dir;
		//Debug.MSG(Date.now().getTime()+" switching dir to "+dir+" "+Std.string(haxe.Stack.callStack()));
	}
	
	public function isBackSide()
	{
		if ( curDir == null) return true;
		
		return switch(curDir) {
			case UP, LEFT:true;
			default:false;
		}
	}
	
	public function turn( left:Bool = false)
	{
		changeDir( E_DIRS.createI( MathEx.posMod((getDir().index() + (left?1:-1) ) , 4  ) ));
	}
	
	public function changeChar()
	{
		if (!mutant())
			setChar(EnumEx.next( hid, HeroId ));
	}
	
	public function mutant()
	{
		if ( HumanNPC.forceMutant ) return true;
		
		return data.mutant;
	}
	
	//returns the frmae index
	
	public static function getFrame( hid:HeroId, ?npc : HumanNPC ) : String
	{
		var hId = Protocol.heroesIdList[hid.index()].id;
		var fr = Std.string(hId);
		if ( npc != null && npc.data.skin != 0 )
			fr += "$" + npc.data.skin;
			
		var hGraph = Data.slices.get( fr );
		var n : String = fr;
		
		if ( hGraph == null)
			n = "CHAR_ANON_FEMALE";
			
		if ( npc!=null ? npc.mutant() : false )
			n = "MUTATED";
		
		return n;
	}
	
	public function lookBusy()
	{
		var p = getGridPos();
		var tgt = [];
		for (i in E_DIRS.array())
		{
			var lx = p.x + Dirs.LIST[i.index()].x;
			var ly = p.y + Dirs.LIST[i.index()].y;
			
			var np = Main.grid().getNpc(lx, ly);
			
			if ( np != null)
			{
				tgt.pushBack( { x:lx, y:ly } );
				break;
			}
			
			for ( dep in grid.dependancies)
			{
				if (dep.pad.test( function(d) return d.x == lx && d.y == ly ))
				{
					tgt.pushBack( { x:lx, y:ly } );
					//Debug.MSG(dep.te.setup.index + "is interesting");
					//break;
				}
				
				if ( 	dep.gameData != NoData
				&&		dep.gameData != Decal
				&& 		dep.data.test( function(d) return d.x == lx && d.y == ly ))
				{
					tgt.pushBack( { x:lx, y:ly } );
					//Debug.MSG(dep.te.setup.index + "is interesting");
					//break;
				}
			}
		}
		
		var d = tgt.random();
		
		if ( d != null)
		{
			if ( d.x == p.x && d.y < p.y )
				changeDir( UP);
			else if ( d.x == p.x && d.y > p.y )
				changeDir( DOWN);
			else if (  d.y == p.y && d.x < p.x )
				changeDir( LEFT);
			else if ( d.y == p.y && d.x > p.x  )
				changeDir( RIGHT);
			else
			{
				//Debug.MSG("nothing of interest circa me");
				//changeDir( E_DIRS.random() );
			}
		}
		else
		{
			//Debug.MSG("nothing of interest");
			//changeDir( E_DIRS.random() );
			/*
			var d = oldPos;
			if ( d.x == p.x && d.y < p.y )
				changeDir( DOWN);
			else if ( d.x == p.x && d.y > p.y )
				changeDir( UP);
			else if (  d.y == p.y && d.x < p.x )
				changeDir( RIGHT);
			else if ( d.y == p.y && d.x > p.x  )
				changeDir( LEFT);
			else if ( d.y >= p.y )
				changeDir( UP);
			else
				changeDir( DOWN);
				*/
		}
		
		Main.grid().dirtSort();
	}
	
	public override function setPos(x:Int, y:Int)
	{
		oldPos.copy(getGridPos());
		super.setPos( x, y );
		
		if ( set != CS_RUNNING)
		{
			var dep  = grid.getDepPad( x, y );
			if (dep!= null && dep.gameData == Chair)
			{
				var setup = dep.te.setup;
				var sl = Data.slices.get( setup.index );
				set = CS_SIT;
				if ( sl.dir != null)
					changeDir( sl.dir );
			}
		}
		if (laid) laid = false;
	}
	
	public function warpTo( t : Tile)
	{
		set = CS_UP;
		var st = t.getGridPos();
		setPos( st.x, st.y);
	}
	
	var wpList : List<Tile>;
	var tgtDep : DepInfos;

	static var D = 0.33333;
	static var D_LIM = 0.2;
	
	var previousTile : Tile;
	
	
	public override function update()
	{
		super.update();
		var gt = getTile();
		if ( (set == CS_RUNNING) && previousTile != gt && gt !=null && previousTile != null)
			Main.ship.kickBlocker( grid, previousTile.getGridPos() , gt.getGridPos() );
		
		previousTile =  getTile();
					
		if(wpList.length > 0)
		{
			var curPos : V2D = pos.toGridF();
			var tgt : Tile = wpList.first();
			var tgtPos = tgt.getGridPos();
			var tgtPosF : V2D = tgt.getGridPos().toV2D();
			
			var s = new V2D();
			V2D.sub( s, tgtPosF, curPos );
			V2D.normalize(s);
			
			var r = new V2D();
			V2D.add( r, curPos, V2D.scale( s, D , s ));
			
			var cr0 = V2D.cross( tgtPosF, curPos );
			var cr1 = V2D.cross( tgtPosF, r );
			
			if ( !MathEx.sameSign(cr0,cr1) || tgtPosF.isNear( curPos, D_LIM ) )
			{
				var tp = tgt.getGridPos();
				wpList.pop();
				setPos( tp.x, tp.y);
				
				if (wpList.length <= 0)
				{
					if ( tgtDep!=null)
					{
						var t  = tgtDep;
						tgtDep = null;
						jumpInDep( t );
					}
					else
					{
						lookBusy();
						set = CS_UP;
					}
				}
				else
				{
					var n = wpList.first().getGridPos();
					var pm = pointMe( tp, n);
					if (getDir() != pm )
						changeDir(pm);
				}
			}
			else
				setPosf( r );
		}
		
		
		updateVanities();
	}
	
	public function updateVanities()
	{
		if ( data.vanities.has( TrailingHearts ))
		{
			heartTimer -= Timer.deltaT;
			if ( heartTimer < 0 )
			{
				var p = hearts.create();
				p.data.life = 20;
				p.x = el.x;
				p.y = el.y;
				
				var a = Dice.rollF(0, Math.PI);
				var da = 10;
				var ay = Math.sin(a)*da;
				var ax = Math.cos(a)*da;
				
				var dx = 0; Dice.roll( -6, 6);
				p.x += dx + ax;
				
				var dy = 10 + Dice.roll( - 4 , 6);
				p.y -= dy + ay;
				p.alpha = 1.0;
				p.data.ry = p.y;
				//heartTimer = 0.5;
				heartTimer = 0.15;
			}
			
		}
		
		
		for ( p in hearts.used)
		{
			if ( p == null ) continue;
			p.data.ry--;
			p.y = Std.int( p.data.ry );
			p.data.life -= 1;
			p.alpha -= 0.05;
			if ( p.data.life < 0 )
				hearts.destroy( p );
		}
	
		vanities.iter(function(v) {
			v.update();
			v.visible = v.visible && v.npc.el.visible;
		});
	}
	
	public override function onGridChange( from:Grid, to  :Grid)
	{
		super.onGridChange(from,to);
		
		for ( v in vanities)
		{
			v.detach();
			from.remPostFx(v);
			to.addPostFx( v );
		}
		
		for ( h in hearts.used)
		{
			var v =  h;
			v.detach();
			
			from.remPostFx(v);
			to.addPostFx( v );
		}
	}
	
	var heartTimer = 0.0;
	
	public static function pointMe( from:  V2I, to : V2I ) : E_DIRS
	{
		var fromF = from.toV2D();
		var toF = to.toV2D();
		
		var diff = V2D.normalize( V2D.sub(new V2D(), toF, fromF) );
		var angle = Math.atan2(diff.y, diff.x);
		
		angle = MathEx.normAngle( angle);
		if ( angle < 0 )
			angle += Math.PI * 2;
			
		if ( angle < Math.PI / 4 && angle > - Math.PI / 4)
			return RIGHT;
			
		if ( angle >= Math.PI / 4 && angle <  3 * Math.PI / 4 )
			return DOWN;

		if ( 	angle >= 3 * Math.PI / 4
		&&		angle < 5 * Math.PI / 4 )
			return LEFT;
			
		return UP;
	}
	
	public function walkTo( x:Int, y:Int, ?dep:DepInfos )
	{
		if ( wpList.length>0 )
		{
			var l  = wpList.last();
			if ( l!=null && l.getGridPos().x == x && l.getGridPos().y == y)
				return;
		}
		
		var ai = grid.getAi();
		ai.updateWeights();
		
		var grp = getGridPos();
		if ( !grid.isWalkable( grp.x, grp.y))
		{
			var t = grid.nearestWalkable( grp.x, grp.y );
			if ( t != null)
				grp = t.getGridPos();
		}
		
		ai.mkPathFrom( AIView.mkNid( grp.x, grp.y ) );
		
		if ( !grid.isWalkable( x, y ) )
		{
			var nw =  grid.nearestWalkable( x, y);
			if ( nw == null)
				return;
				
			var p = nw.getGridPos();
			if (p != null)
			{
				x = p.x;
				y = p.y;
			}
			else
			{
				Debug.MSG("no nearest free ?");
			}
		}
		
		var folo = ai.dijkstra.comp.pathTo( AIView.mkNid( x, y ));
		if ( folo != null)
		{
			wpList = folo.map( function(nid) {
				var p = AIView.nid2Coo( nid);
				return grid.get( p.x,p.y);
			});
			
			var pm = pointMe(getGridPos(), new V2I(x, y));
			changeDir(pm);
			set = CS_RUNNING;
		}
		else
		{
			Debug.MSG("no path from " + grp + " to " + x + " " + y);
		}
		
		tgtDep =  dep;
		
		var pix = grid.gridToView(x, y);
		if ( Player.DYN_VP.has( Protocol.roomList[ Main.ship.curRoom.index() ].type ))
			Main.focusPosition( pix.x,pix.y);
	}
	
	public function chainTp( p : List<Tile> )
	{
		if ( p.length <= 0 )
			return;
		
		var h = p.pop();
		warpTo( h );
				
		if ( p.length != 0)
			haxe.Timer.delay( function()
			{
				chainTp( p );
			},50);
	}
	
	public function getUp()
	{
		var st = getGridPos();
		var nf = grid.nearestWalkable(st.x,st.y);
		if ( nf != null) warpTo(nf);
		else
		{
			var rf = grid.randomFree();
			if ( rf != null) warpTo( rf);
			else
				setPos(0, 0);
		}
	}
	
	
	public function refresh( d : ClientChar )
	{
		setChar( hid );
		resetPos();
		
		//if ( Std.int(d.life) < Std.int( data.life ) )
		//	onHurt();
			
		mark = true;
		data = d;
	}
}