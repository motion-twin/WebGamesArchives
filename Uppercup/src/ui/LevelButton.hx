package ui;

import mt.deepnight.slb.BSprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

class LevelButton extends Button {
	var sl				: m.StageSelect;
	var lid				: Int;
	var face			: Bitmap;
	var stars			: Bitmap;
	var isFinal			: Bool;
	var initDone		: Bool;

	var bgId			: String;

	public function new(p, sl:m.StageSelect, lid:Int) {
		super(p, "", function() sl.selectLevel(lid, true));
		this.sl = sl;

		this.lid = lid;
		initDone = false;

		wrapper.blendMode = LAYER;
		hasClickFeedback = false;

		setSize(60,60);
		face = new Bitmap();

		stars = new Bitmap();
		content.addChild(stars);

		unselect();
	}


	function getTeam() {
		return TeamInfos.getByLevel(lid, m.Global.ME.variant);
	}

	function setStars(n:Int) {
		if( n==0 )
			return;

		stars.bitmapData = new BitmapData(n*16,20,true, 0x0);

		for(i in 0...n)
			sl.tiles.drawIntoBitmap(stars.bitmapData, i*16, 0, "miniStar", 0);
	}


	public function init(nbStars) {
		if( initDone )
			return;

		setStars(nbStars);
		var team = getTeam();
		initDone = true;

		setBitmapLabel(Std.string(lid));
		label.visible = face.visible;

		setBg( m.Global.ME.tiles.get("Ui_Thumb"), true );

		face.bitmapData = new BitmapData(60,60,true, 0x0);
		content.addChild(face);
		if( team.isTutorial() ) {
			m.Global.ME.tiles.drawIntoBitmap(face.bitmapData, 30,30, "iconTuto", 0.5, 0.5);
		}
		else {
			m.Global.ME.tiles.drawIntoBitmap(face.bitmapData, 21,23, "bouille");
			m.Global.ME.tiles.drawIntoBitmap(face.bitmapData, 0,0, "hairCuts", team.hairFrame);
		}
		face.bitmapData.applyFilter(face.bitmapData, face.bitmapData.rect, new flash.geom.Point(), new flash.filters.DropShadowFilter(4,90, 0x0,0.3, 0,0) );
		face.y = -15;

		setBgId(bgId);
	}


	function setBgId(id:String) {
		bgId = id;
		if( initDone )
			setBg( m.Global.ME.tiles.get(bgId) );
	}

	public function setFinal() {
		isFinal = true;
		setBgId( "Ui_ThumbGold" );
	}

	override function setBitmapLabel(s:String) {
		setFont("small", 16);
		setFontColor(0xFFFFFF);
		setLabel(s);
		tf.width = tf.textWidth+3;
		tf.height = tf.textHeight+3;
		tf.visible = false;
		tf.filters = [ new flash.filters.GlowFilter(0x2D0000,0.7, 2,2,4) ];

		if( label!=null ) {
			label.bitmapData.dispose();
			label.bitmapData = null;
			label.parent.removeChild(label);
		}
		label = mt.deepnight.Lib.flatten(tf);
		content.addChild(label);
		var bd = label.bitmapData;
		label.bitmapData = mt.deepnight.Lib.scaleBitmap(bd, 4, LOW, true);
		label.scaleX = label.scaleY = 0.5;
	}

	public function select() {
		if( isFinal )
			setBgId( "Ui_ThumbGoldSelected" );
		else
			setBgId( "Ui_ThumbSelected" );
		addState("selected");
	}

	public function unselect() {
		if( isFinal )
			setBgId( "Ui_ThumbGold" );
		else
			setBgId( "Ui_Thumb" );
		removeState("selected");
	}

	public function lock() {
		face.visible = false;
		if( isFinal )
			setBgId( "Ui_ThumbGoldLocked" );
		else
			setBgId( "Ui_ThumbLocked" );

		if( initDone )
			label.visible = false;
		disable();
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);

		if( initDone ) {
			label.x = Std.int( w*0.5 - label.width*0.5 );
			label.y = Std.int( -label.height+2 );
		}

		if( hasState("selected") && initDone )
			sprBg.y+=1;

		stars.x = Std.int(7);
		stars.y = Std.int(h-15-(hasState("selected") ? 0 : 1));
	}

	override function destroy() {
		super.destroy();

		if( face.bitmapData!=null ) {
			face.bitmapData.dispose();
			face.bitmapData = null;
		}
		face = null;

		if( stars.bitmapData!=null ) {
			stars.bitmapData.dispose();
			stars.bitmapData = null;
		}
		stars = null;

		sl = null;
	}
}
