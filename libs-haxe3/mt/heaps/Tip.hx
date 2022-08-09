package mt.heaps;

import h2d.Font;
import h2d.Scene;
import hxd.res.FontBuilder;
import mt.Metrics;

class Tip {
	
	static var tipTimer = 0.0;
	static var tipSp : h2d.Sprite = null;
	static var tipDecay = false;
	static var tipSpawn = 0.0;
	
	//sizes are in pxi
	public static var conf = {
		fontName 	: "helvetica",
		fontSize 	: 8,
		textColor 	: 0xFF050505,
		
		bgColor 	: 0xffdc94,
		bgAlpha		: 1.0,
		lineColor 	: 0x0,
		lineWidth 	: 1,
		margin		: 4,		
		scene 		: null,
		maxWidth	: 100,
	};
	
	static inline function pxi(v:Float) {
		return Math.round(mt.Metrics.vpx2px(v));
	}
	
	static var ox = -1.0;
	static var oy = -1.0;
	
	public static function show( x : Int, y : Int, label : String) {
		
		if ( conf.scene ==null ) throw "please set conf.scene";
		if ( label == null || label.length==0 || label == "null" ) return;
		
		tipTimer = 1.0;
		tipDecay = false;
		
		if ( tipSp == null ) {
			tipSp = new h2d.Sprite(conf.scene);
			var bg = new h2d.Graphics(tipSp);
			bg.name = "bg";
			
			var t = new h2d.Text( hxd.res.FontBuilder.getFont(conf.fontName,pxi(conf.fontSize)), tipSp );
			t.name = "label";
			t.color = h3d.Vector.fromColor(conf.textColor|(0xff<<24));
			t.maxWidth = pxi(conf.maxWidth);
		}
		else {
			if( conf.scene != tipSp.getScene()){
				tipSp.remove();
				conf.scene.addChild(tipSp);
			}
		}
		
		var bg : h2d.Graphics = cast tipSp.findByName("bg");
		
		var lbl : h2d.Text = cast tipSp.findByName("label");
		if ( lbl.text == label && tipSp.visible == true && ox == x && oy == y) 
			return;//...abusive
		
		ox = x;
		oy = y;
		bg.clear();
		lbl.text = label;
		
		var margin = pxi(conf.margin);
		var b : h2d.col.Bounds = lbl.getBounds(tipSp);
		bg.lineStyle(pxi(conf.lineWidth));
		bg.beginFill(conf.bgColor,conf.bgAlpha);
		bg.drawRect( b.x-margin, b.y-margin, b.width+margin*2, b.height+margin*2 );
		bg.endFill();
		
		mt.heaps.fx.Lib.setAlpha( tipSp, 1.0 );
		
		tipSp.x = x;
		tipSp.y = y;
		tipSp.visible = true;
		
		var mw = mt.Metrics.w();
		var mh = mt.Metrics.h();
		
		var side = x < mw * 0.5;
		
		if ( side )
			tipSp.x += pxi(16);
		
		var scene = tipSp.getScene();
		var bnd = tipSp.getBounds(scene);
		
		var tipWidth = tipSp.width;
		var tipHeight = tipSp.height;
		
		
		while( bnd.yMax >= mh ){
			tipSp.y -= tipHeight * 0.5;
			bnd = tipSp.getBounds(scene,bnd);
		}
		
		while( bnd.xMax >= mw ){
			tipSp.x -= tipWidth * 0.5;
			bnd = tipSp.getBounds(scene,bnd);
		}
		
		while( bnd.xMin <= 0 ){
			tipSp.x += tipWidth * 0.5;
			bnd = tipSp.getBounds(scene,bnd);
		}
		
		while( bnd.yMin <= 0 ){
			tipSp.y += tipHeight * 0.5;
			bnd = tipSp.getBounds(scene,bnd);
		}
			
		tipSpawn = Math.max( 0.5, tipSpawn);
		
		tipSp.x = Std.int(tipSp.x);
		tipSp.y = Std.int(tipSp.y);
		
		ox = tipSp.x;
		oy = tipSp.y;
		
		tipSp.toFront();
	}
	
	public static function dispose() {
		if (tipSp != null) {
			tipSp.visible = false;
			tipSp.dispose();
			tipSp = null;
		}
	}
	public static function hide(label : String,?force=false) {
		if ( tipSp == null) return;
		
		var lbl : h2d.Text = cast tipSp.findByName("label");
		if ( force||lbl.text == label ){
			tipDecay = true;
			tipSpawn = 1.0;
			tipTimer = 1.0;
		}
	}
	public static function update() {
		if( tipSp!=null) {
			if ( tipSpawn >= 0 )
				tipSpawn -= hxd.Timer.deltaT;
				
			if ( tipSpawn <= 0 && !tipDecay )
				mt.heaps.fx.Lib.setAlpha( tipSp, 1.0 );
				
			if( tipDecay )
				tipTimer -= hxd.Timer.deltaT;
				
			if ( tipSp.visible && tipDecay && tipTimer <= 1.0) {
				tipSp.visible = false;
				mt.heaps.fx.Lib.setAlpha( tipSp, tipTimer );
				tipTimer = 0.0;
			}
		}
	}
}