package exp;

import mt.deepnight.Color;
import mt.deepnight.RandList;
import ExploreProtocol;

typedef Bitmap = flash.display.Bitmap;
typedef BitmapData = flash.display.BitmapData;

class Room implements haxe.Public {
	static var STAR_COLORS = [0xE1BD7B, 0xF1B49E, 0xFFFFBB, 0xFFB0B0];
	static var BG_COLORS = [0x368189, 0x326C89, 0x3D4285, 0xC16233, 0x77559F, 0xAB6FAC, 0x8B3F3F, 0x916339];
	static var GALAXY_COLORS = [0xAB7154, 0xAA0000, 0xCC6133, 0xAD942C, 0x8A56A9, 0xBE4183, 0x314E79, 0x6480CA, 0x2D99AC, ];
	static var SUN_COLORS = [0xFF7900, 0xD6A229, 0xFF0000, 0x00A6FF, 0xE38FEF, 0x99D807];
	static var GRID_WID = 32;
	
	var man				: Manager;
	var seed			: Int;
	var rseed			: mt.Rand;
	var pt0				: flash.geom.Point;
	var quality			: Float;

	var viewPort		: flash.geom.Rectangle;
	var entrance		: flash.geom.Point;
	var center			: flash.geom.Point;
	var exitDist		: Int;
	var wallRadiusX		: Int;
	var wallRadiusY		: Int;
	var width			: Int;
	var height			: Int;
	var starColor		: Int;
	var sunColor		: Int;
	var bgColor			: Int;
	var galaxyColors	: Array<Int>;

	var entities		: List<Entity>;
	var layers			: Array<ZLayer>;
	var sun				: Null<ZLayer>;
	var buttons			: List<Button>;
	var orbitalObjects	: Array<Entity>;
	
	var grid			: Array<Array<Bool>>;
	var randValues		: Array<Float>;
	
	var timerStack		: Array<{t:Int, name:String}>;
	
	var planetInfos		: Array<{e:Entity, infos:SystemPlanetInfos}>;
	var systemInfos		: Array<{e:Entity, infos:SystemInfos}>;
	
	
	public function new(s:Int) {
		man = Manager.ME;
		seed = s;
		rseed = new mt.Rand(seed);
		rseed.initSeed(seed);
		timerStack = new Array();
		
		planetInfos = new Array();
		systemInfos = new Array();
		
		//Color.drawPalette(man.test.graphics, GALAXY_COLORS);
		
		viewPort = new flash.geom.Rectangle(0,0, man.buffer.width, man.buffer.height);
		pt0 = new flash.geom.Point(0,0);
		buttons = new List();
		layers = new Array();
		entities = new List();
		setSize(2200,2200);
		quality = 1;
		orbitalObjects = new Array();
		
		starColor = STAR_COLORS[rseed.random(STAR_COLORS.length)];
		bgColor = BG_COLORS[rseed.random(BG_COLORS.length)];

		initRandom();
		randValues = new Array();
		for( i in 0...150 )
			randValues[i] = rseed.rand();
	}
	
	inline function time(?name:String) {
		//if( name!=null )
			//timerStack.push( {t:flash.Lib.getTimer(), name:name} );
		//else {
			//var t = timerStack.pop();
			//trace( (flash.Lib.getTimer()-t.t)+"ms ("+t.name+")" );
		//}
	}
	
	
	function getPlanetEntity(inf:SystemPlanetInfos) {
		for( p in planetInfos )
			if( p.infos.id==inf.id )
				return p.e;
		return null;
	}
	
	function getSystemEntity(inf:SystemInfos) {
		for( s in systemInfos )
			if( s.infos.id==inf.id )
				return s.e;
		return null;
	}
	
	function setSize(w,h) {
		width = height = w;
		center = new flash.geom.Point( width*0.5, height*0.5 );
		entrance = new flash.geom.Point(center.x, center.y);
		exitDist = Std.int( Math.min(w*0.5, h*0.5) - 100 );
		wallRadiusX = Std.int(w*0.5);
		wallRadiusY = Std.int(h*0.5);
		grid = new Array();
		for(x in 0...Std.int(width/GRID_WID)) {
			grid[x] = new Array();
			for(y in 0...Std.int(height/GRID_WID)) {
				grid[x][y] = false;
			}
		}
	}
	
	public function destroy() {
		while( layers.length>0 )
			layers.splice(0,1)[0].destroy();
		for( e in entities )
			e.spr.parent.removeChild(e.spr);
		buttons = new List();
	}
	
	function initRandom(?seed2=0.0) {
		rseed.initSeed(seed + Std.int(seed2));
	}
	
	inline function randomPoint(?minDist=0.0, ?maxDist=-1.) {
		if( maxDist<0 )
			if( exitDist>0 )
				maxDist = exitDist;
			else
				maxDist = width*0.5;
		var a = rseed.rand()*Math.PI*2;
		return {
			x : center.x + Math.cos(a) * (minDist + rseed.rand()*(maxDist-minDist)),
			y : center.y + Math.sin(a) * (minDist + rseed.rand()*(maxDist-minDist)),
		}
	}
	
	inline function randomGridPoint(?minDist=0.0, ?maxDist=-1.) {
		if( maxDist<0 )
			if( exitDist>0 )
				maxDist = exitDist;
			else
				maxDist = width*0.5;
				
		var pt = {x:0,y:0};
		var tries = 250;
		do {
			var a = rseed.rand()*Math.PI*2;
			pt = {
				x : Std.int( (center.x + Math.cos(a) * (minDist + rseed.rand()*(maxDist-minDist)))/GRID_WID ),
				y : Std.int( (center.y + Math.sin(a) * (minDist + rseed.rand()*(maxDist-minDist)))/GRID_WID ),
			}
		}while( tries-->0 && grid[pt.x][pt.y] );
		grid[pt.x][pt.y] = true;

		return gridToMap(pt);
	}
	
	inline function gridToMap(pt:{x:Int, y:Int}) {
		return {
			x	: Std.int( pt.x*GRID_WID + GRID_WID*0.5 + randValues[(pt.x*2+pt.y)%randValues.length]*GRID_WID*0.40 ),
			y	: Std.int( pt.y*GRID_WID + GRID_WID*0.5 + randValues[(pt.x+pt.y*2)%randValues.length]*GRID_WID*0.40 ),
		}
	}
	
	inline function mapToGrid(pt:{x:Int, y:Int}) {
		return {
			x	: Std.int( pt.x/GRID_WID ),
			y	: Std.int( pt.y/GRID_WID ),
		}
	}
	
	public function finalize() {
		if( orbitalObjects.length>0 )
			exitDist = getOrbitDist( orbitalObjects.length-1 ) + 100;
		
		if( exitDist>0 ) {
			var disc = new flash.display.Sprite();
			disc.graphics.lineStyle(1, Manager.REACTOR_COLOR, 0.5);
			var wid = 600;
			var fullWid = wid+32*2;
			disc.graphics.drawCircle(0,0, wid*0.5);
			var bd = new flash.display.BitmapData(fullWid, fullWid, true, 0x0);
			var m = new flash.geom.Matrix();
			m.translate(bd.width*0.5, bd.height*0.5);
			bd.draw(disc, m);

			var stripes = new flash.display.Sprite();
			var g = stripes.graphics;
			g.lineStyle(10,0xffffff, 1);
			for( i in 0...100 ) {
				var a = Math.PI*2 * (i/100);
				g.moveTo(fullWid*0.5, fullWid*0.5);
				g.lineTo(fullWid*0.5+Math.cos(a)*fullWid*0.5, fullWid*0.5+Math.sin(a)*fullWid*0.5);
			}
			man.root.stage.quality = flash.display.StageQuality.BEST;
			bd.draw(stripes, flash.display.BlendMode.ERASE);
			man.root.stage.quality = Manager.QUALITY;

			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(Manager.REACTOR_COLOR,1, 8,8, 3, 2));
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.BlurFilter(2,2,2));
			
			var l = new ZLayer(this, bd, 1, (exitDist*2)/wid);
			l.xOffset = center.x;
			l.yOffset = center.y;
			l.fl_hideZoom = true;
			l.cont.blendMode = flash.display.BlendMode.ADD;
		}
		
		//if( wallRadiusX!=0 ) {
			//var disc = new flash.display.Sprite();
			//disc.graphics.beginFill(0xffffff,1);
			//var wid = 600;
			//var fullWid = wid+32*2;
			//disc.graphics.drawCircle(0,0, wid*0.5);
			//var bd = new flash.display.BitmapData(fullWid, fullWid, true, 0x0);
			//var m = new flash.geom.Matrix();
			//m.translate(bd.width*0.5, bd.height*0.5);
			//bd.draw(disc, m);
			//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(0xE90C0C, 0.5, 16,16, 1,1, false, true));
			//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.BlurFilter(2,2,2));
			//var l = new ZLayer(this, bd, 1, (wallRadiusX*2)/wid, (wallRadiusY*2)/wid);
			//l.xOffset = center.x;
			//l.yOffset = center.y;
			//l.fl_hideZoom = true;
		//}
		
		// cercles orbites
		if( orbitalObjects.length>0 ) {
			var orbitCircles = new flash.display.Sprite();
			orbitCircles.graphics.lineStyle(1, bgColor,1, flash.display.LineScaleMode.NONE);
			orbitCircles.blendMode = flash.display.BlendMode.ADD;
			
			for(i in 0...orbitalObjects.length) {
				var e = orbitalObjects[i];
				if( e!=null )
					orbitCircles.graphics.drawCircle(0,0, getOrbitDist(i));
			}
			var l = new ZLayer(this, orbitCircles, 1);
			l.xOffset = center.x;
			l.yOffset = center.y;
		}
		
		// entités
		for( e in entities )
			man.fdm.add(e.spr, Manager.DP_PLANET);
			
		// Plans
		if( layers.length>0 ) {
			//if( layerLimit>0 ) {
				//layers.sort( function(a,b) return -Reflect.compare(a.fl_optional, b.fl_optional) );
				//while( layers.length>layerLimit && layers[0].fl_optional )
					//layers.splice(0,1);
			//}
			
			// Z-sort
			layers.sort( function(a,b) return Reflect.compare(a.z, b.z) );
			for( l in layers )
				man.buffer.dm.add(l.cont, Manager.DP_ZLAYERS);
		}
	}
	
	public function generateSector(infos:SectorInfos) {
		time("generateSector");
		setSize(infos.width*GRID_WID, infos.height*GRID_WID);
		exitDist = -1; //400;
		
		//initRandom();
		//var bmp = makeGasPlanet(rseed.rand()*0.5+0.5);
		//var spr = new flash.display.Sprite();
		//spr.addChild(bmp);
		//var l = new ZLayer(this, spr, 1.1);
		//l.xOffset = center.x;
		//l.yOffset = center.y+50;
		//l.cont.blendMode = flash.display.BlendMode.NORMAL;
		
		initStars(1);
		initClouds( bgColor, [0.7, 0.4] );
		
		//var wrap = new flash.display.Sprite();
		//for(i in 0...50) {
			//var spr = man.lib.getSprite("asteroid");
			//spr.setCenter(0.5,0.5);
			//var pt = randomGridPoint(100,200);
			//spr.width = spr.height = GRID_WID;
			//spr.x = pt.x;
			//spr.y = pt.y;
			//wrap.addChild(spr);
		//}
		//new ZLayer(this, wrap, 1);
		
		// galaxie
		initRandom();
		initGalaxyColors();
		var size = quality*0.8+0.2;
		var scale = if( Manager.UPSCALE==1 ) rseed.rand()*1+1.25 else rseed.rand()*0.75+0.50;
		scale += 1/size-1;
		for( z in [1, 0.75, 0.65] ) {
			var g = makeGalaxyCloud( size + rseed.rand()*0.3 );
			g.colorTransform(g.rect, new flash.geom.ColorTransform(1,1,1, 0.6 + (1-quality)*0.3));
			var l = new ZLayer(this, g, z, false, scale);
			l.xOffset = center.x;
			l.yOffset = center.y;
		}
		
		//makeRockCloud( 60 );
		
		//var l = makeMaelstrom(rseed.rand()*0.5+0.5, starColor, 6, 0.5, 0.1);
		//l.xOffset = rseed.random(Std.int(bounds.width));
		//l.yOffset = rseed.random(Std.int(bounds.height));
		//for(i in 0...1) {
				//var scale = rseed.rand()*0.7 + 0.5;
				//var scale = 1;
				//var a = rseed.rand()*Math.PI*2;
				//var xf = Math.cos(a);
				//var yf = Math.sin(a);
				//makeRockBelt( 40, "asteroid", function() {
					//var a = rseed.rand()*Math.PI*2;
					//var d = scale*200;
					//return {
						//x:center.x+Math.cos(a)*d*xf + rseed.rand()*10,
						//y:center.y+Math.cos(a)*d*yf + rseed.rand()*10,
						//z:Math.sin(a)*0.15+0.85
					//}
				//} );
		//}
		
		var radius = 500;

		// Systèmes
		initRandom();
		for( si in man.infos.systems ) {
			var pt = gridToMap({x:si.x, y:si.y});
			switch( si.status ) {
				case SystemStatus.SLocked(cost) : // Non-débloqué
					var icon = man.lib.getSprite("system",2);
					icon.setCenter(0.5,0.5);
					var e = new Entity(this, icon);
					entities.add(e);
					e.dataId = si.id;
					e.scale = 1;
					e.x = pt.x;
					e.y = pt.y;
					e.name = si.name;
					systemInfos.push({e:e, infos:si});
					
					var b = new Button(e.spr);
					b.onClick = function() man.moveShip(e);
					b.padding = 10;
					buttons.add(b);
					
				case SystemStatus.SOpen : // Ouvert
					var unexp = Lambda.filter( si.planets, function(p) return p.status==SystemPlanetStatus.PUnexplored ).length;
					var active = Lambda.filter( si.planets, function(p) return p.status==SystemPlanetStatus.PActive ).length;

					var spr = new flash.display.Sprite();
					spr.graphics.beginFill(0xff0000, 0);
					spr.graphics.drawRect(-10,-10,20,20);
					
					var e = new Entity(this, spr);
					entities.add(e);
					e.dataId = si.id;
					e.x = pt.x;
					e.y = pt.y;
					var wrapper = new flash.display.Sprite();
					e.setExternal(wrapper);
					wrapper.cacheAsBitmap = true;
					systemInfos.push({e:e, infos:si});
					
					var icon = man.lib.getSprite("system", (active>0 ? 1 : 0));
					wrapper.addChild(icon);
					icon.scaleX = icon.scaleY = 2;
					icon.setCenter(0.5,0.5);
					
					if( unexp >0 ) {
						var c = man.lib.getSprite("counter");
						c.setCenter(0.5,0.5);
						c.x = 7;
						c.y = 4;
						var tf = man.makeField(0xFFFFFF);
						tf.text = Std.string( unexp );
						tf.width = 10;
						tf.x = -2-Std.int(tf.textWidth*0.5);
						tf.y = -6;
						//tf.alpha = 0.6;
						tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,1, 2,2,1) ];
						c.addChild(tf);
						icon.addChild(c);
					}
					
					var tf = man.makeField(0xCCD6EC);
					wrapper.addChild(tf);
					tf.width = 300;
					tf.text = si.name;
					tf.width = tf.textWidth+6;
					tf.height = tf.textHeight+3;
					tf.x = Std.int(-tf.textWidth*0.5*tf.scaleX);
					tf.y = 16;
					
					var b = new Button(e.spr);
					b.onClick = function() man.moveShip(e);
					b.padding = 15;
					buttons.add(b);
			}
		}
		/*
		var n = 10 + rseed.random(30);
		for( i in 0...n ) {
			var icon = man.lib.getSprite("system",1);
			icon.setCenter(0.5,0.5);

			//var a = rseed.rand()*Math.PI*2;
			//var d = rseed.random(400)+50;
			var e = new Entity(this, icon);
			e.scale = 2;
			entities.add(e);
			var pt = randomGridPoint(0,radius);
			e.x = pt.x;
			e.y = pt.y;
			//e.x = center.x + Math.cos(a)*d;
			//e.y = center.y + Math.sin(a)*d;
		}*/
		
		/*
		// Systèmes solaires
		initRandom();
		var n = 5 + rseed.random(5);
		for( i in 0...n ) {
			var spr = new flash.display.Sprite();
			spr.graphics.beginFill(0xff0000, 0);
			spr.graphics.drawRect(-10,-10,20,20);
			
			var e = new Entity(this, spr);
			entities.add(e);
			var pt = randomGridPoint(0,radius);
			e.x = pt.x;
			e.y = pt.y;
			
			var tf = man.makeField(0x80FF00);
			tf.width = 300;
			tf.text = makeSystemName();
			tf.width = tf.textWidth+6;
			tf.height = tf.textHeight+3;
			tf.x = Std.int(-tf.textWidth*0.5*tf.scaleX);
			tf.y = 16;
			
			var wrapper = new flash.display.Sprite();
			e.setExternal(wrapper);
			wrapper.addChild(tf);
			wrapper.cacheAsBitmap = true;
			
			var icon = man.lib.getSprite("system");
			wrapper.addChild(icon);
			icon.scaleX = icon.scaleY = 2;
			icon.setCenter(0.5,0.5);
			
			var b = new Button(e.spr);
			b.onClick = function() man.moveShip(e, callback(man.onArriveSystem, e));
			b.padding = 10;
			//b.onClick = function() man.moveShip(e);
			buttons.add(b);
		}
		*/
		time();
	}
	
	public function generateCommon() {
		time("generateCommon");
		wallRadiusX = wallRadiusY = 0;
		exitDist = -1;
		initRandom();
		if( rseed.random(100)<60 ) {
			var l = makeMaelstrom(rseed.rand()*0.3+0.9, starColor, 6, 0.5, 0.2);
			l.xOffset = rseed.random(width);
			l.yOffset = rseed.random(height);
		}
		time();
	}
	
	public function generateSolarStars() {
		wallRadiusX = wallRadiusY = 0;
		exitDist = -1;
		
		initRandom();
		initStars(0.4);
		initClouds( bgColor, [0.7, 0.3] );
	}
	
	
	public function generateSolarSystem(infos:SystemInfos) {
		time("generateSolarSystem");
		exitDist = 500;
		var a = rseed.rand()*Math.PI*2;
		entrance = new flash.geom.Point(center.x + 200*Math.cos(a), center.y + 200*Math.sin(a));
		
		bgColor = Color.getRainbowColor( rseed.rand(), 0.25+rseed.rand()*0.35, 0.15+rseed.rand()*0.4 );
		
		// grand soleil
		sunColor = SUN_COLORS[rseed.random(SUN_COLORS.length)];
		sun = makeSun(sunColor, 0.6+rseed.rand()*0.9, 0.85);
		
		// Soleils secondaires
		var extraSuns = new mt.deepnight.RandList();
		extraSuns.add(0, 150);
		extraSuns.add(1, 45);
		extraSuns.add(2, 10);
		extraSuns.add(3, 1);
		extraSuns.add(4, 1);
		var nsuns = extraSuns.draw(rseed.random);
		for(i in 0...nsuns) {
			var z = rseed.rand()*0.4+0.4;
			var s = makeSun(SUN_COLORS[rseed.random(SUN_COLORS.length)], z*(rseed.rand()*0.2+0.4), z);
			var a = rseed.rand()*Math.PI*2;
			var d = rseed.rand()*350 + 100;
			s.xOffset = center.x + Math.cos(a)*d;
			s.yOffset = center.y + Math.sin(a)*d;
		}
		
		for( p in infos.planets ) {
			switch( p.kind ) {
				case SystemPlanetKind.SPlanet : addPlanet(p);
				case SystemPlanetKind.SGas : addGasPlanet(p);
			}
		}
		
		// débris spatiaux
		initRandom();
		if( rseed.random(100)<50 )
			makeRockCloud( rseed.random(60) + 20 );
		
		// galaxie
		initRandom();
		if( rseed.random(100)<70 ) {
			var size = quality*0.8+0.2;
			var scale = if( Manager.UPSCALE==1 ) rseed.rand()*1+0.50 else rseed.rand()*0.75+0.50;
			scale += 1/size-1;
			//var s = rseed.rand()*1 + 0.5;
			var bz = rseed.rand()*0.4 + 0.2;
			var pt = {x:center.x+rseed.rand()*100*rseed.sign(), y:center.y+rseed.rand()*100*rseed.sign()}
			var zeds = if (nsuns<2) [bz+0.15, bz] else [bz];
			galaxyColors = [];
			var base = Color.saturationInt(bgColor, 0.3);
			for( i in 0...zeds.length )
				galaxyColors.push( Color.hueInt(base, rseed.rand()*0.3*rseed.sign()) );

			for( z in zeds ) {
				var g = makeGalaxyCloud( size );
				g.colorTransform(g.rect, new flash.geom.ColorTransform(1,1,1, 0.5));
				var l = new ZLayer(this, g, z, false, scale);
				l.xOffset = pt.x;
				l.yOffset = pt.y;
			}
		}
		time();
	}
	
	
	
	
	
	function show() {
		setVisible(true);
	}
	function hide() {
		setVisible(false);
	}
	function setVisible(b:Bool) {
		for( l in layers )
			l.cont.visible = b;
		for( e in entities )
			e.spr.visible = b;
	}
	function debugPalette(a:Array<Int>) {
		for(i in 0...a.length) {
			var g = man.test.graphics;
			g.beginFill(a[i], 1);
			g.drawRect(50+i*16, 50, 16,16);
			g.endFill();
		}
	}
	
	public function snapshot(?at:flash.geom.Point) {
		time("snaphot");
		if( at==null )
			at = new flash.geom.Point(viewPort.x, viewPort.y);
		var bd = new flash.display.BitmapData(width, height, true, 0x0);
		var old = viewPort.clone();
		viewPort.x = at.x;
		viewPort.y = at.y;
		viewPort.width = width;
		viewPort.height = height;
		update();
		for(l in layers) {
			if( l.fl_hideZoom )
				continue;
			if( !l.fl_repeat)
				bd.draw(l.cont, l.cont.transform.matrix, l.cont.blendMode);
			else {
				for( y in 0...2 ) {
					for( x in 0...2 ) {
						var m = l.cont.transform.matrix.clone();
						m.translate(x*l.cont.width, y*l.cont.height);
						bd.draw(l.cont, m, l.cont.blendMode);
					}
				}
			}
		}
		for(e in entities)
			bd.draw(e.spr, e.spr.transform.matrix);
		//bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.GlowFilter(0x0,1, 64,64, 1,1, true));
		//bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.DropShadowFilter(0,0, 0x0,1, 64,64, 1,1, true));
		viewPort = old;
		update();
		
		time();
		return bd;
	}
	
	inline function makeStarfield(bd:flash.display.BitmapData, density:Float, wid:Int, margin:Int) {
		var n = Std.int( density * 0.0015 * bd.width*bd.height * 1/quality );
		for( i in 0...n )
			bd.fillRect( new flash.geom.Rectangle(margin+rseed.random(bd.width-margin*2), margin+rseed.random(bd.height-margin*2), wid,wid), Color.addAlphaChannel(0x808080, rseed.random(64)+192) );
	}
	
	function initStars(density:Float) {
		time("initStars d="+density);
		initRandom();
		var w = if(Manager.UPSCALE==1) 450 else 300;
		var zmin = 0.1;
		var zmax = 0.4;
		var n = Math.ceil(6*quality);
		var zeds = new Array();
		for(i in 0...n)
			zeds.push( Math.round( (zmin + (i/(n-1))*(zmax-zmin))*100 ) / 100 );
		for(z in zeds) {
			var sf = new flash.display.BitmapData(w, w, true,0x0);
			makeStarfield(sf, density*(0.1+1-z/zmax), Math.round(2*z/zmax), 4);
			
			var l = new ZLayer( this, sf, z, true );
			l.cont.blendMode = flash.display.BlendMode.NORMAL;
			var bd = l.bd;
			bd.colorTransform( bd.rect, new flash.geom.ColorTransform(1,1,1, z/(zmax*1.3)) );
			var c = Color.interpolateInt(bgColor, starColor, z/zmax);
			bd.applyFilter( bd, bd.rect, pt0, Color.getColorizeMatrixFilter(c, 1,0) );
			bd.applyFilter( bd, bd.rect, pt0, new flash.filters.GlowFilter(c, 1, 2,2, 2, 2) );
			bd.applyFilter( bd, bd.rect, pt0, new flash.filters.GlowFilter(c, z/zmax, 8,8, 2, 2) );
		}
		time();
	}
	

	function initGrid(size:Float, alpha:Float, z:Float) {
		var w = Std.int(size * man.lib.getRectangle("hex", 0).width);
		var h = Std.int(size * man.lib.getRectangle("hex", 0).height);
		var grid = new flash.display.BitmapData(w,h, true, 0x0);
		
		var spr = man.lib.getSprite("hex");
		spr.setCenter(0,0);
		var m = new flash.geom.Matrix();
		m.scale(size,size);
		grid.draw(spr,m);
		
		var ct = new flash.geom.ColorTransform();
		ct.color = bgColor;
		ct.alphaMultiplier = alpha;
		grid.colorTransform( grid.rect, ct );
		var l = new ZLayer(this, grid, z, true);
		return l;
	}
	
	function initClouds(col:Int, zeds:Array<Float>) {
		initRandom(col);
		time("clouds");
		var w = Std.int(200 + 250* 1/Manager.UPSCALE);
		var noise = new flash.display.BitmapData(w,w,true,0x0);
		noise.noise(1,0x60, 0xb0, 7, true);
		noise.colorTransform( noise.rect, new flash.geom.ColorTransform(1,1,1, 0.15+rseed.rand()*0.15) );
		for(z in zeds) {
			var perlin = new flash.display.BitmapData(w,w, true, 0x0);
			var pw = Std.int( w*0.2 + w*0.3*z );
			perlin.perlinNoise(pw,pw, 2, rseed.random(99999), true, true, 1, true);
			perlin.draw(noise, new flash.geom.ColorTransform(1,1,1, 0.3));
			var cut = 0.5;
			var thr = Color.rgbaToInt({r:Std.int(255*cut), g:0, b:0, a:255});
			perlin.threshold(perlin, perlin.rect, pt0, "<=", thr, 0x0, 0xffff0000, true);
			perlin.colorTransform(perlin.rect, new flash.geom.ColorTransform(1,1,1, 1, -255*cut,-255*cut,-255*cut));//0.5*Math.min(z,1)););
			//perlin.colorTransform( perlin.rect, new flash.geom.ColorTransform(1/cut, 1/cut, 1/cut, 0.5*Math.min(z,1)) );

			var f = Color.getColorizeMatrixFilter(col, 0.5, 0);
			perlin.applyFilter(perlin, perlin.rect, new flash.geom.Point(0,0), f);
			
			var l = new ZLayer( this, perlin, z, true );
		}
		noise.dispose();
		time();
	}
	
	
	function initGalaxyColors() {
		galaxyColors = GALAXY_COLORS.copy();
	}
	
	function addGasPlanet(infos:SystemPlanetInfos) {
		var orbitId = infos.distance;
		initRandom(orbitId);
		var sizes = new mt.deepnight.RandList();
		sizes.add(1.0, 5);
		sizes.add(0.8, 10);
		sizes.add(0.7, 20);
		sizes.add(0.6, 50);
		sizes.add(0.5, 100);
		sizes.add(0.4, 80);
		sizes.add(0.3, 20);
		sizes.add(0.2, 10);
		sizes.add(0.1, 5);
		var size = sizes.draw(rseed.random) * 0.4 + 0.3;
		//var bd = makeGasPlanet(rseed.rand()*0.3+0.4);
		//var bd = makeGasPlanet(0.2);
		//var bmp = new Bitmap(bd);
		var bmp = makeGasPlanet(size);
		bmp.x = -bmp.width*0.5;
		bmp.y = -bmp.height*0.5;
		
		var spr = new flash.display.Sprite();
		spr.addChild(bmp);
		
		var e = new Entity(this, spr);
		entities.add(e);
		var pt = getOrbitCoord(orbitId);
		e.x = pt.x;
		e.y = pt.y;
		e.name = infos.name;
		
		var b = new Button(e.spr);
		buttons.add(b);
		b.padding = -10;
		b.onClick = function() man.moveShip(e);

		orbitalObjects[orbitId] = e;
		planetInfos.push({e:e, infos:infos});
	}
	
	function makeGasPlanet(size:Float) {
		time("makeGasPlanet");
		var w = Std.int(size*200);
		var sharpness = rseed.rand();
		
		var baseTex = new BitmapData(w,w, false, 0x0);
		var octaves = Std.int( Math.max(1, (rseed.random(4)+1)*quality ) );
		baseTex.perlinNoise(Std.int(w*2),Std.int(size*(8+64*(1-sharpness))), octaves, safePerlinSeed(rseed), false, false, true);
		var tex = new BitmapData(w,w, false, 0x0);
		var m = new flash.geom.Matrix();
		m.translate(-w*0.5,-w*0.5);
		m.rotate( rseed.sign()*rseed.rand()*Math.PI*0.15 );
		m.translate(w*0.5,w*0.5);
		tex.draw(baseTex, m);
		tex.applyFilter(tex, tex.rect, pt0, new flash.filters.BlurFilter(4,4));
		
		
		var noise = new BitmapData(w,w,false,0x0);
		noise.noise(rseed.random(9999), 0x0, 0xFFFFFF, 1, true);
		
		var distort = new BitmapData(w,w, false, 0x0);
		var octaves = Std.int( Math.max(1, (rseed.random(5)+1)*quality ) );
		distort.perlinNoise(Math.ceil(32*size), Math.ceil(16*size), octaves, safePerlinSeed(rseed), false, true, true);
		distort.draw(noise, new flash.geom.ColorTransform(1,1,1, 0.1));
		tex.applyFilter(tex, tex.rect, pt0,
			new flash.filters.DisplacementMapFilter(distort, pt0, 1,1, 1,Math.ceil(size*(rseed.random(16)+10)), flash.filters.DisplacementMapFilterMode.CLAMP, 0x0, 1));
		if( rseed.random(100)<60 )
			tex.applyFilter(tex, tex.rect, pt0, new flash.filters.BlurFilter(Math.ceil(size*8),0));
		noise.noise(rseed.random(9999), 0x0, 0xFFFFFF, 1, true);
		tex.draw(noise, new flash.geom.ColorTransform(1,1,1, rseed.rand()*0.05));
		
		// déformation sphérique
		var spherize = new BitmapData(w,w, true, 0x0);
		var ss = 0.45;
		var grad = new flash.display.Sprite();
		var m = new flash.geom.Matrix();
		m.createGradientBox(2*w*ss,2*w*ss, Math.PI*0.5, w*(0.5-ss), w*(0.5-ss));
		grad.graphics.beginGradientFill(flash.display.GradientType.LINEAR, [0x0,0xff0000], [1,1], [0,255], m);
		grad.graphics.drawCircle(w*0.5, w*0.5, w*ss);
		spherize.draw(grad);
		grad.graphics.clear();
		var m = new flash.geom.Matrix();
		m.createGradientBox(2*w*ss,2*w*ss, 0, w*(0.5-ss), w*(0.5-ss));
		grad.graphics.beginGradientFill(flash.display.GradientType.LINEAR, [0x0,0x00ff00], [1,1], [0,255], m);
		grad.graphics.drawCircle(w*0.5, w*0.5, w*ss);
		spherize.draw(grad, flash.display.BlendMode.SCREEN);
		spherize.applyFilter(spherize, spherize.rect, pt0, new flash.filters.BlurFilter(32,32,1));
		tex.applyFilter(tex, tex.rect, pt0,
			new flash.filters.DisplacementMapFilter(spherize, pt0, 2,1, -40*size,-80*size, flash.filters.DisplacementMapFilterMode.CLAMP) );
			
		// masque rond
		var disc = new flash.display.Sprite();
		var b = 4;
		disc.graphics.beginFill(0xFFFFFF, 1);
		disc.graphics.drawCircle(w*0.5, w*0.5, w*0.5-b);
		disc.filters = [ new flash.filters.BlurFilter(b,b) ];
		
		// assemblage
		var bd = new BitmapData(w,w,true,0x0);
		var mask = bd;
		bd.draw(disc);
		bd.copyPixels(tex, tex.rect, pt0, mask, pt0, false);
		bd.applyFilter( bd, bd.rect, pt0, new flash.filters.GlowFilter(0x0,0.55, Math.ceil(size*64),Math.ceil(size*64),2, 1, true) );
		bd.applyFilter( bd, bd.rect, pt0, new flash.filters.DropShadowFilter(Std.int(50*size),220, 0x0,0.8, Math.ceil(size*64),Math.ceil(size*64), 1, 1, true) );
		bd.applyFilter( bd, bd.rect, pt0, Color.getContrastFilter(0.2) );
		
		// couleur
		var col = Color.getRainbowColor(rseed.rand(), 0.10+rseed.rand()*0.40, 0.7+rseed.rand()*0.1);
		var pal = Color.makeNicePalette(col, Color.desaturateInt(Color.capBrightnessInt(bgColor, 0.15), 0.5));
		Color.paintBitmapGrays(bd, pal);
		bd.applyFilter( bd, bd.rect, pt0, Color.getContrastFilter(0.4) );

		// speculaire
		disc.graphics.clear();
		disc.graphics.beginFill(0xFFFFFF, 0.6+rseed.rand()*0.3);
		disc.graphics.drawCircle(w*0.38, w*0.38, w*0.15);
		var b = Math.max(16, Math.ceil(size*32));
		disc.filters = [ new flash.filters.BlurFilter(b,b) ];
		bd.draw(disc, flash.display.BlendMode.OVERLAY);
		
		// halo
		var wrapper = new Bitmap(bd);
		wrapper.filters = [
			new flash.filters.GlowFilter(Color.brightnessInt(col,0.2), 0.3, Std.int(8*size),Std.int(8*size), 1),
			new flash.filters.GlowFilter(Color.brightnessInt(col,-0.5), 0.6, Std.int(64*size),Std.int(64*size), 2),
		];
		//var margin = 32;
		//var final = new BitmapData(bd.width+margin*2, bd.height+margin*2, false, 0x0);
		//var m = new flash.geom.Matrix();
		//m.translate(margin,margin);
		//final.draw(bd, m);
		//final.applyFilter(final, final.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(col,0.2), 0.3, Std.int(8*size),Std.int(8*size), 1));
		//final.applyFilter(final, final.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(col,-0.5), 0.6, Std.int(64*size),Std.int(64*size), 2));
		
		//var bmp = new Bitmap(final); bmp.x = 200+w*2; man.test.addChild(bmp);
		
		baseTex.dispose();
		tex.dispose();
		noise.dispose();
		spherize.dispose();
		//bd.dispose();
		
		time();
		
		return wrapper;
	}
	
	
	function makeSystemName() {
		var a = ["Andromeda","Daedelus","Syrius","Motion","Orion","Gemini","Seti","Centauri"];
		var roman = ["II","III","IV","V","VI","VII","IX","X","XI"];
		var n =
			if( rseed.random(100)<50 )
				String.fromCharCode( "A".code + rseed.random(26) ) + "-" + (rseed.random(9)+1);
			else
				roman[ rseed.random(roman.length) ] + " ";
		return
			a[ rseed.random(a.length) ] + " " +
			n;
	}

	
	function makePlanetName() {
		var a = ["Omega","Alpha","Gamma","Epsilon","Twino","Endo","Corelia"];
		var b = ["Prime", "Centauri", "Beta"];
		var n = ["II","III","IV","V","VI","VII","IX","X","XI"];
		var c =
			if( rseed.random(100)<50 )
				String.fromCharCode( "A".code + rseed.random(26) ) + "-" + (rseed.random(9)+1);
			else
				n[ rseed.random(n.length) ] + " ";
		return
			a[ rseed.random(a.length) ] + " " +
			b[ rseed.random(b.length) ] + " " +
			c;
	}
	
	
	inline function getOrbitDist(orbitId:Int) {
		return Std.int( 160 + orbitId*80 + randValues[orbitId]*20 );
	}
	
	inline function getOrbitAng(orbitId:Int) {
		//return 0;
		return randValues[0]*Math.PI*2 + orbitId*Math.PI*0.8+ randValues[orbitId]*Math.PI*0.4;
	}
	
	inline function getOrbitCoord(orbitId:Int) {
		var a = getOrbitAng(orbitId);
		var d = getOrbitDist(orbitId);
		return {
			x : center.x + Math.cos(a)*d,
			y : center.y + Math.sin(a)*d,
		}
	}
	
	function addPlanet(infos:SystemPlanetInfos) {
		var size = switch(infos.size) {
			case 1 : 0.07;
			case 2 : 0.25;
			case 3 : 0.50;
			case 4 : 1.00;
			default : 0.5;
		}
		var orbitId = infos.distance;
		initRandom(orbitId);
		
		var ang = getOrbitAng(orbitId);
		var d = getOrbitDist(orbitId);
		
		var wrapper = new flash.display.Sprite();
		var c0 = Color.getRainbowColor(rseed.rand());
		
		var bd = man.lib.getBitmapData("planet", man.lib.getRandomFrame("planet",rseed.random), 16);
		var bmp = new flash.display.Bitmap(bd, flash.display.PixelSnapping.ALWAYS, true);
		wrapper.addChild(bmp);
		bmp.scaleX = bmp.scaleY = size + if(Manager.UPSCALE==1) 0.5 else 0;
		bmp.x = Std.int(-bmp.width*0.5);
		bmp.y = Std.int(-bmp.height*0.5);
		var biome = Common.Data.getBiome( infos.biome );
		var c0 = if( biome.exploreColors.length>=1 ) biome.exploreColors[0] else 0x0;
		var c1 = if( biome.exploreColors.length>=2 ) biome.exploreColors[1] else c0;
		var c2 = if( biome.exploreColors.length>=3 ) biome.exploreColors[2] else c1;
		var r = Color.makeNicePalette(c0);
		var g = Color.makeNicePalette(c1);
		var b = Color.makeNicePalette(c2);
		Color.paintBitmap(bd, r,g,b);
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(5, -45, 0x0,0.4, 4,4,1, 1, true));
		
		var e = new Entity(this, wrapper);
		entities.add(e);
		e.dataId = infos.id;
		e.x = center.x + Math.cos(ang)*d;
		e.y = center.y + Math.sin(ang)*d;
		e.spr.cacheAsBitmap = true;
		e.name = infos.name;
		
		function addIcon(name) {
			var icon = man.lib.getSprite(name);
			icon.setCenter(0.5,0.5);
			icon.x = Std.int(bmp.width*0.2);
			icon.y = Std.int(-bmp.height*0.2);
			e.spr.addChild(icon);
			return icon;
		}
		var showName = false;
		switch( infos.status ) {
			case SystemPlanetStatus.PAbandonned, SystemPlanetStatus.PForbidden:
				var icon = addIcon("deleted");
				icon.x = icon.y = 0;
				bd.applyFilter(bd, bd.rect, pt0, Color.getSaturationFilter(-0.9));
				bd.applyFilter(bd, bd.rect, pt0, Color.getColorizeMatrixFilter(0x0, 0.5, 0.5));
				bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(bgColor,-0.7), 0.7, 16,16, 1, 2));
				
			case SystemPlanetStatus.PActive, SystemPlanetStatus.PInvited:
				addIcon("flag");
				showName = true;
				bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(bgColor,0.5), 0.9, 8,8, 1));
				bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(bgColor,0.5), 0.7, 32,32, 1));
				
			case SystemPlanetStatus.PUnexplored :
				addIcon("unknown");
				bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(bgColor,0.5), 0.9, 8,8, 1));
				bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(bgColor,0.5), 0.7, 32,32, 1));
		}
		
		// Halo
		//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(bgColor,0.5), 0.9, 8,8, 1));
		//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(bgColor,0.5), 0.7, 32,32, 1));

		if( showName ) {
			var tf = man.makeField(0xffffff);
			tf.text = infos.name;
			tf.x = Std.int(- tf.textWidth*0.5);
			tf.y = Std.int(bmp.height*0.3);
			wrapper.addChild(tf);
		}
		
		if( rseed.random(100)<15 )
			addRocksAround(c0, e.x, e.y, 20,60);
		
		var b = new Button(e.spr);
		buttons.add(b);
		b.onClick = function() man.moveShip(e);
		
		orbitalObjects[orbitId] = e;
		
		planetInfos.push({e:e, infos:infos});
	}
	
	/*
	function makePlanets(n:Int) {
		initRandom(n);
		
		var minDist = 150 + rseed.random(100);
		var maxDist = width*0.5 * 0.7 - minDist;
		
		for(i in 0...n) {
			var d = minDist + maxDist * (i/n) + rseed.rand()*20*(rseed.random(2)*2-1);
			var ang = rseed.rand()*(Math.PI*2);
			var wrapper = new flash.display.Sprite();
			
			var wrapper = new flash.display.Sprite();
			var c0 = Color.getRainbowColor(rseed.rand());

			var col = 0x9A8561;
			trace(man.lib.getGroup("planet"));
			var bd = man.lib.getBitmapData("planet", 2, 16);
			var bmp = new flash.display.Bitmap(bd, flash.display.PixelSnapping.ALWAYS, true);
			wrapper.addChild(bmp);
			bmp.scaleX = bmp.scaleY = rseed.rand()*0.65+0.35 + if(Manager.UPSCALE==1) 0.5 else 0;
			bmp.x = Std.int(-bmp.width*0.5);
			bmp.y = Std.int(-bmp.height*0.5);
			var r = Color.makeNicePalette(c0);
			var g = Color.makeNicePalette(Color.getRainbowColor(rseed.rand()));
			var b = r;
			//Color.paintBitmap(bd, r,g,b);
			bd.applyFilter(bd, bd.rect, pt0, Color.getSaturationFilter(-0.7));
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.DropShadowFilter(5, -45, 0x0,0.4, 4,4,1, 1, true));
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(col,-0.5), 1, 2,2, 2));
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(bgColor,0.5), 0.9, 8,8, 1));
			bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(bgColor,0.5), 0.7, 32,32, 1));
			
			var p = new Entity(this, wrapper);
			entities.add(p);
			p.x = center.x + Math.cos(ang)*d;
			p.y = center.y + Math.sin(ang)*d;
			p.spr.cacheAsBitmap = true;
			p.name = makePlanetName();
			
			if( rseed.random(100)<15 )
				addRocksAround(c0, p.x, p.y, 20,60);
			
			var b = new Button(p.spr);
			buttons.add(b);
			b.onClick = function() man.moveShip(p);
		
			exitDist = Std.int(d+100);
			d+=60 + rseed.random(50);
		}
		
	}
	*/
	
	
	function addRocksAround(color:Int, x:Float,y:Float, minDist:Int, maxDist:Int) {
		addRocks( 2+rseed.random(20), "asteroid", 0.20, Color.desaturateInt(color, 0.7), function() {
			var a = rseed.rand()*Math.PI*2;
			var d = minDist + rseed.random(maxDist-minDist);
			return {x:x+Math.cos(a)*d, y:y+Math.sin(a)*d, z:rseed.rand()*0.1+0.9};
		} );
	}
	
	function makeRockCloud(n:Int) {
		var patterns = [
			function() {// nuage solaire (large)
				addRocks( n, "asteroid", 0.40, function() {
					var a = rseed.rand()*Math.PI*2;
					var d = 100 + rseed.random(500);
					return {x:center.x+Math.cos(a)*d, y:center.y+Math.sin(a)*d, z:rseed.rand()*0.6+0.4};
				} );
			},
			function() { // nuage solaire (proche)
				addRocks( n, "asteroid", 0.40, Color.desaturateInt(sunColor, 0.5), function() {
					var a = rseed.rand()*Math.PI*2;
					var d = 50 + rseed.random(100);
					return {x:center.x+Math.cos(a)*d, y:center.y+Math.sin(a)*d, z:rseed.rand()*0.4+0.6};
				} );
			},
			function() { // ceinture solaire 3d
				var scale = rseed.rand()*0.5 + 0.5;
				var a = rseed.rand()*Math.PI*2;
				var xf = Math.cos(a);
				var yf = Math.sin(a);
				addRocks( n, "asteroid", 0.35, function() {
					var a = rseed.rand()*Math.PI*2;
					var d = scale*220;
					return {
						x:center.x+Math.cos(a)*d*xf + rseed.rand()*30,
						y:center.y+Math.cos(a)*d*yf + rseed.rand()*30,
						z:Math.sin(a)*0.15+0.85
					}
				} );
			},
			function() { // nuage ex-centré
				var pt = randomPoint(100);
				var z = rseed.rand()*0.6 + 0.4;
				addRocks( n, "asteroid", rseed.rand()*0.20+0.30, function() {
					var a = rseed.rand()*Math.PI*2;
					var d = 50 + rseed.random(150);
					return {x:pt.x+Math.cos(a)*d, y:pt.y+Math.sin(a)*d, z:z-rseed.rand()*0.29};
				} );
			},
			function() { // spirale Z
				var cpt = 0;
				var turns = rseed.rand()*2 + 1.5;
				var aoff = rseed.rand()*Math.PI;
				addRocks( n, "asteroid", 0.6, function() {
					var step = cpt/n + rseed.rand()*0.05;
					cpt++;
					var a = aoff + step * Math.PI*2 * turns;
					var d = 50 + step*150;
					return {
						x:center.x+Math.cos(a)*d + rseed.rand()*30,
						y:center.y+Math.sin(a)*d + rseed.rand()*30,
						z:0.2 + step*0.8
					};
				} );
			}
		];
		patterns[3]();
		//patterns[ rseed.random(patterns.length) ]();
	}
	
	function addRocks(n:Int, sprId:String, size:Float, ?color:Int, posFunc:Void->{x:Float,y:Float,z:Float}) {
		if( color==null )
			//color = Color.desaturateInt( BG_COLORS[rseed.random(BG_COLORS.length)], 0.5 );
			color = Color.desaturateInt( Color.getRainbowColor(Math.random()), 0.7 );
		for(i in 0...Std.int(n*quality)) {
			var pos = posFunc();
			var spr = man.lib.getSprite(sprId, man.lib.getRandomFrame(sprId, rseed.random));
			spr.setCenter(0.5,0.5);
			spr.rotation = rseed.random(360);
			spr.filters = [
				Color.getColorizeMatrixFilter(color, 0.5, 0.8),
				Color.getColorizeMatrixFilter(bgColor, 1-pos.z, pos.z),
			];
			var l = new ZLayer(this, spr, pos.z, 0.05*size+pos.z*size*0.95);
			l.xOffset = pos.x;
			l.yOffset = pos.y;
			l.fl_snapPixel = false;
			l.cont.blendMode = flash.display.BlendMode.NORMAL;
		}
		
	}
	
	function makeSunBitmap(col:Int, size:Float) {
		var wid = Math.ceil(size*80);
		var filterRadius = Math.ceil(size*96);
		var totalWid = wid + filterRadius*2;
		var core = new flash.display.Sprite();
		core.graphics.beginFill(0x0,1);
		core.graphics.drawCircle(filterRadius + wid*0.5, filterRadius + wid*0.5, wid*0.5);
		
		var sun = new flash.display.BitmapData( totalWid, totalWid, true, 0x0);
		sun.draw( core );

		var disp = new flash.display.BitmapData( totalWid, totalWid, true, 0x0);
		disp.perlinNoise(6,6,2, safePerlinSeed(rseed), false, true, true);
		
		var mask = new flash.display.BitmapData( totalWid, totalWid, true, 0x0 );
		mask.draw(core);
		mask.applyFilter( mask, mask.rect, pt0, new flash.filters.BlurFilter(8,8,2));
		mask.applyFilter( mask, mask.rect, pt0, new flash.filters.DisplacementMapFilter(disp, pt0, 1,0, size*10,size*10) );

		var tex = new flash.display.BitmapData( totalWid, totalWid, true, 0x0);
		tex.perlinNoise(size*8,size*8,1, safePerlinSeed(rseed), false, false, true);
		tex.copyChannel( mask, mask.rect, pt0, flash.display.BitmapDataChannel.ALPHA, flash.display.BitmapDataChannel.ALPHA );
		
		sun.fillRect(sun.rect, 0xffffffff);
		sun.copyChannel( mask, mask.rect, pt0, 8,8 );
		sun.applyFilter(sun, sun.rect, pt0, new flash.filters.GlowFilter(Color.lighten(col,0.4),1, size*32,size*32, 1, 1, true) );
		//sun.applyFilter(sun, sun.rect, pt0, new flash.filters.GlowFilter(Color.lighten(col,0.5),1, size*16,size*16, 2) );
		//sun.applyFilter(sun, sun.rect, pt0,
			//new flash.filters.DisplacementMapFilter(disp, pt0, 1,0, 20,20)
		//);
		sun.draw(tex, new flash.geom.ColorTransform(1,1,1, 0.05+rseed.rand()*0.15), flash.display.BlendMode.NORMAL);
		sun.applyFilter(sun, sun.rect, pt0, new flash.filters.GlowFilter(Color.lighten(col,0.4),0.7, size*16,size*16, 1, 2) );
		//sun.applyFilter(sun, sun.rect, pt0, new flash.filters.GlowFilter(Color.lighten(col,0.8),0.85, size*24,size*24, 2) );
		sun.applyFilter(sun, sun.rect, pt0, new flash.filters.GlowFilter(Color.lighten(col,0.4),1, size*96,size*96, 2, 2) );
		
		sun.applyFilter(sun, sun.rect, pt0, Color.getContrastFilter(0.2) );
		//sun.applyFilter(sun, sun.rect, pt0, new flash.filters.BlurFilter(size*16,size*16) );
			//,
			//,
		//];
		disp.dispose();
		mask.dispose();
		tex.dispose();
		return sun;
	}
	
	function makeSun(col:Int, size:Float, z:Float) {
		initRandom(col+size);
		var bd = makeSunBitmap(col, size);
		var l = new ZLayer(this, bd, z, false);
		l.xOffset = center.x;
		l.yOffset = center.y;
		l.cont.blendMode = flash.display.BlendMode.SCREEN;
		return l;
	}
	
	function makeGalaxyCloud(size:Float) {
		var w = Math.ceil(500*size);
		var h = Math.ceil(500*size);
		var disp = Std.int( size * (rseed.random(64)+64) );
		
		// base
		var galaxy = new flash.display.BitmapData(w,h, true, 0x0);
		var cont = new flash.display.Bitmap(galaxy);
		var s = safePerlinSeed(rseed);
		var pw = size*(rseed.random(32)+16);
		galaxy.perlinNoise( pw,pw, 3, s, false, true, true);
		var distort = new flash.display.BitmapData(w,h, false, 0xffffff);
		var pw = size*(rseed.random(16)+32);
		distort.perlinNoise( pw,pw, 1, safePerlinSeed(rseed), false, true, true );
		galaxy.applyFilter(
			galaxy, galaxy.rect, new flash.geom.Point(0,0),
			new flash.filters.DisplacementMapFilter(
				distort, pt0,
				flash.display.BitmapDataChannel.RED, flash.display.BitmapDataChannel.RED,
				rseed.random(32),rseed.random(32),
				flash.filters.DisplacementMapFilterMode.WRAP
			)
		);
		//root.addChild( new flash.display.Bitmap(distort) );
		distort.dispose();
		
		// mask de base
		var mask = new flash.display.BitmapData(w,h, true, 0x0);
		var s = new flash.display.Sprite();
		var g = s.graphics;
		var blur = Std.int( size * (rseed.random(48)+16) );
		var margin = Std.int( 0.5*(blur+disp) );
		for( i in 0...Math.ceil(size*15) ) {
			g.clear();
			g.beginFill(0xffffff, 0.2 + rseed.rand()*0.8);
			var r = Math.ceil(size * (rseed.random(16)+32));
			g.drawCircle(margin+r+rseed.random(mask.width-r*2-margin*2), margin+r+rseed.random(mask.height-r*2-margin*2), r);
			mask.draw(s);
		}
		mask.applyFilter( mask, mask.rect, pt0, new flash.filters.BlurFilter(blur,blur, 2) );
		
		// distorsion
		var distort = new flash.display.BitmapData(w,h, false, 0xffffff);
		var pw = size*(rseed.random(16)+32);
		distort.perlinNoise( pw,pw, 1, safePerlinSeed(rseed), false, true, true );
		mask.applyFilter(
			mask, mask.rect, new flash.geom.Point(0,0),
			new flash.filters.DisplacementMapFilter(
				distort, pt0,
				flash.display.BitmapDataChannel.RED, flash.display.BitmapDataChannel.RED,
				disp,disp,
				flash.filters.DisplacementMapFilterMode.WRAP
			)
		);
		//root.addChild( new flash.display.Bitmap(distort) );
		distort.dispose();

		// masquage
		galaxy.copyChannel(mask, mask.rect, pt0, flash.display.BitmapDataChannel.ALPHA, flash.display.BitmapDataChannel.ALPHA);
		//root.addChild( new flash.display.Bitmap(mask) );
		mask.dispose();
		
		// noise
		var noise = new flash.display.BitmapData(w,h,true,0x0);
		noise.noise(1,0x60, 0xb0, 7, true);
		noise.colorTransform( noise.rect, new flash.geom.ColorTransform(1,1,1, 0.15+rseed.rand()*0.15) );
		galaxy.copyPixels(noise, galaxy.rect, pt0, galaxy,  pt0, true);
		noise.dispose();
		
		//var ct = new flash.geom.ColorTransform();
		//ct.alphaMultiplier = 0.65;
		//galaxy.colorTransform(galaxy.rect, ct);
		var gcol = galaxyColors.splice(rseed.random(galaxyColors.length), 1)[0];
		galaxy.applyFilter(galaxy, galaxy.rect, pt0, Color.getColorizeMatrixFilter(gcol, 0.6, 0.4));
		return galaxy;
	}
	
	
	function makeFlatGalaxy(scale:Float, count:Int, z:Float) {
		initRandom(z+scale+count);
		var g = makeGalaxyCloud(1);
		var ct = new flash.geom.ColorTransform(1,1,1, 1.0 - (count-1)*0.15);
		for( i in 0...count-1 ) {
			var g2 = makeGalaxyCloud(1);
			g2.colorTransform( g2.rect, new flash.geom.ColorTransform(1,1,1, 0.65));
			g.draw(g2, ct, flash.display.BlendMode.ADD);
			g2.dispose();
		}
		
		var l = new ZLayer(this, g, z, scale);
		l.xOffset = center.x;
		l.yOffset = center.y;
		return l;
	}
	
	
	function makeMaelstromBitmap(size:Float, color:Int, rotate:Float, turns:Float, thickness:Float, dir:Int) {
		var bd = new flash.display.BitmapData(Std.int(size*500),Std.int(size*500), true, 0x0);
		var alphaPerlin = bd.clone();
		alphaPerlin.perlinNoise(128,128, 1, safePerlinSeed(rseed), false, false, true);
		//alphaPerlin.colorTransform( alphaPerlin.rect, new flash.geom.ColorTransform(2,2,2));
		//var bmp = new flash.display.Bitmap(alphaPerlin);
		//bmp.x = 500;
		//man.test.addChild(bmp);
		
		var brushes = [];
		for(i in 0...man.lib.countFrames("brush")) {
			var b = man.lib.getSprite("brush", i);
			b.setCenter(0.5,0.5);
			brushes.push(b);
		}

		if( size<1 )
			thickness*=size;
		
		var cx = bd.width*0.5;
		var cy = bd.height*0.5;
		var steps = 200;
		var baseAng = rotate*Math.PI*2;
		var bm = new flash.geom.Matrix();
		var radiusX = bd.width * (rseed.rand()*0.10 + 0.40);
		var radiusY = bd.height * (rseed.rand()*0.10 + 0.40);
		//var radiusX = bd.width * 0.5;
		//var radiusY = bd.height * 0.5;
		bm.translate(16,16);
		var brush = brushes[rseed.random(brushes.length)];
		for(i in 0...steps) {
			//var brush = brushes[1];
			var step = i/steps;
			var ang = baseAng + dir * step * (turns * Math.PI*2);
			
			var x = cx + Math.cos(ang) * (step * radiusX);
			var y = cy + Math.sin(ang) * (step * radiusY);
			//var s = ( 0.7 + (1-step) * rseed.rand() * 1 );
			var s = thickness * (1 + (Math.sin(step*Math.PI)) * rseed.rand()*1);
			
			var m = new flash.geom.Matrix();
			if( rseed.random(100)<50 ) m.scale(-1,1);
			if( rseed.random(100)<50 ) m.scale(1,-1);
			m.scale(s*0.6, s);
			
			m.rotate(ang + Math.PI*(0.50+0.10*thickness));
			m.translate(x, y);
			m.translate( (rseed.random(2)*2-1) * rseed.random(3), (rseed.random(2)*2-1) * rseed.random(6));
			var ct = new flash.geom.ColorTransform();
			ct.color = color;
			var p = alphaPerlin.getPixel(Std.int(x),Std.int(y));
			ct.alphaMultiplier = Math.max(0., p/0xffffff) * (1-step);
			bd.draw( brush, m, ct, flash.display.BlendMode.NORMAL);
		}
		
		//bd.applyFilter(bd, bd.rect, pt0, new flash.filters.GlowFilter(color,rseed.rand()*0.7, 64,64,3, 1));
		
		//var n = 200;
		//while( n>0 ) {
			//var x = rseed.random(bd.width);
			//var y = rseed.random(bd.height);
			//var p = bd.getPixel32(x,y);
			//if( p>>24 >= 0x30 ) {
				//bd.setPixel(x,y, Color.brightnessInt(p, 0.7));
				//n--;
			//}
		//}
		
		return bd;
	}
	
	function makeMaelstrom(size:Float, color:Int, count:Int, thickness:Float, z:Float) {
		var size = quality*size;
		initRandom();
		var r = rseed.rand();
		var dir = rseed.sign();
		var bd = new flash.display.BitmapData(Std.int(size*500),Std.int(size*500),true, 0x0);
		for( i in 0...count ) {
			var r = (i+1)/count;// + rseed.rand()*0.1;
			var bd2 = makeMaelstromBitmap(size, color, r, 1.5+rseed.rand()*0.5, thickness*(0.55+rseed.rand()*0.65), dir );
			var ct = new flash.geom.ColorTransform();
			ct.alphaMultiplier = rseed.rand()*0.5 + 0.4;
			bd.draw( bd2, ct, flash.display.BlendMode.ADD );
			bd2.dispose();
			//r+=0.3;
		}
		var scale = 1/size;
		var l = new ZLayer(this, bd, z, scale);
		l.xOffset = center.x;
		l.yOffset = center.y;
		l.cont.blendMode = flash.display.BlendMode.ADD;
		return l;
	}
	
	
	function safePerlinSeed(rseed:mt.Rand) {
		var bug = [346,514,1155,1519,1690,1977,2327,2337,2399,2860,2999,3099,4777,4952,5673,6265, 7185,7259,7371,7383,7717,7847,8032,8350,8676,8963,8997,9080,9403,9615,9685];
		var h = new IntHash();
		for( b in bug )
			h.set(b, true);
		var s = rseed.random(9999);
		while( h.exists(s) )
			s = rseed.random(9999);
		return s;
	}
	
	public function update() {
		for( e in entities )
			e.update();
		for( l in layers )
			l.update();
	}
}
