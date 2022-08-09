package iso;

import Iso;
import Manager;
import Common;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.Color;
import mt.deepnight.SpriteLib;
import mt.deepnight.RandList;
import mt.deepnight.Tweenie;
import mt.deepnight.Lib;

class Skin extends Sprite {
	public var torso	: DSprite;
	public var legs		: DSprite;
	public var head		: DSprite; // container face + hairs
	public var face		: Sprite; // container eyes + mouth
	public var eyes		: DSprite;
	public var mouth	: DSprite;
	public var hairs	: Bitmap;
	public var arms		: DSprite;
	public var legsAnim	: DSprite;
	public var shirt	: Bitmap;
	public var trousers	: Bitmap;
	
	public function new() {
		super();
	}
	
	public function setEyesColor(c:Int) {
		var c = Color.capInt(c, 1, 0.4);
		//eyes.filters = [ Color.getColorizeMatrixFilter(c, 0.7, 0.3) ]; // TODO
	}
}

enum StudentAnim {
	SA_Talk;
	SA_Laugh;
	SA_EvilLaugh;
	SA_Write;
	SA_Yawn;
	SA_Smile;
	SA_Happy;
	SA_VeryHappy;
	SA_Grin;
	SA_Sad;
	SA_Surprise;
	SA_Surprise2;
	SA_SurpriseSad;
	SA_Evil;
	SA_EvilGrin;
	SA_Tongue;
	SA_EvilEyes;
	SA_Sneeze;
	SA_Cry;
	SA_EyesClosed;
	SA_Bored;
	SA_Tired;
	SA_TalkHandUp;
}

//enum EyeFrames {
	//E_Normal;
	//E_Closed;
	//E_BlinkEnd;
	//E_Tired;
//}

class Student extends Iso {
	static var SKIN_COLORS = [
		0x753931, 0x774A2F, 0x6D6138, 0x683E49, 0x6A433C,
	];
	
	static var HAIR_COLORS = [
		0xC25323, 0xB45E38, 0xC9714B, 0x683520, 0x623C3C, 0x2D3C57, 0x582121,
		0xEACC26, 0x422311, 0x35152E, 0xFFE75E,
	];
	
	static var HAIR_COLORS_SPECIAL = [
		0xAB0C0C, 0x9BC223, 0x1ECEBC, 0xB194EF, 0x3FD68E, 0xE232D0, 0xB923F1, 0x5992FB, 0xBEE34F, 0x4268FF, 0xDDACDD, 0x8ED7D5
	];
	
	static var EYE_COLORS = [ 0x7791e3, 0x485c9d, 0xD0F307, 0xFF7A17, 0xF1696C ];
	
	static var TROUSERS_COLORS = [
		0x6A72A6, 0x725649, 0x2E3943, 0x528FA7, 0x693D3D, 0xA3AFC7, 0x445F41,
	];
	static var SHIRT_COLORS_M = [
		0x377BB3, 0xAE723C, 0x1B2230, 0x800000, 0x462F51, 0xDAE3EB, 0xF9E2CC, 0xD0D3F4, 0xE2221D, 0xF4860B, 0xB59515, 0x2262A8, 0x5E3298,
	];
	static var SHIRT_COLORS_F = [
		0x8EEB12, 0xDF79DF, 0xEA5381, 0x48D7F4, 0xFFAD3E, 0xA589F8, 0xA80606, 0x129C3F, 0xF0A6F9, 0x1D1B2E,
	];
	
	public var data			: logic.Student;
	
	public var bar			: LifeJauge;
	public var buffIcon		: DSprite;
	public var debuffIcon	: DSprite;
	public var halo			: lib.GoodBad;
	//public var knowledge	: Jauge;
	public var rseed		: mt.Rand;
	public var subjects		: Array<Int>;
	public var skin			: Skin;
	public var overArms		: Iso;
	public var armFrame		: Int;
	public var mouthFrame	: Int;
	public var canSit		: Bool;
	var allowWaitAnim		: Bool;
	var look				: { dx:Int, dy:Int };
	
	public var stuff		: Iso; // trousse et cartable
	
	//public var cache		: Bitmap;
	public var photo		: BitmapData;
	public var wid			: Int;
	public var hei			: Int;
	var fl_redraw			: Bool;
	var currentAnim			: Null<{a:StudentAnim, t:Int}>;
	public var waitingCpt	: Int;
	
	public var late			: Bool;
	public var newbie		: Bool;
	
	public var color		: Int;
	public var skinColor	: Int;
	
	var sleepBubble		: lib.Bulle;
	
	public function new(d:logic.Student) {
		super( new DSprite(Manager.ME.chars) );
		wid = 17;
		hei = 25;
		data = d;
		rseed = new mt.Rand(data.id);
		fl_static = false;
		mouthFrame = 2;
		yr = 0.9;
		headY = 12;
		subjects = new Array();
		look = { dx:0, dy:0 };
		yOffset = -3;
		fl_redraw = true;
		armFrame = 8;
		speechColor = male() ? 0xCAF3FF : 0xFFD5FF;
		speed = 0.14 + Math.random()*0.09;
		waitingCpt = 0;
		late = false;
		newbie = false;
		allowWaitAnim = true;
		canSit = false;

		var table = getTable();
		if( table!=null ) {
			stuff = new Iso(table.cx, table.cy);
			// Trousse
			var mc = if(male()) new lib.TrousseG() else new lib.TrousseF();
			stuff.addFurnMc(mc, -9, -10);
			mc.gotoAndStop( rseed.random(mc.totalFrames)+1 );
			// Cartable
			var mc = if(male()) new lib.CartableG() else new lib.CartableF();
			stuff.addFurnMc(mc, -7, -8);
			mc.filters = [ Color.getSaturationFilter(-0.4) ];
			mc.gotoAndStop( rseed.random(mc.totalFrames)+1 );
		}
		
		// Halo (pet)
		halo = new lib.GoodBad();
		halo.gotoAndStop(1);
		halo._sub.gotoAndStop(2);
		//halo.blendMode = flash.display.BlendMode.ADD;
		halo.alpha = 0.8;
		halo.visible = false;
		var hs = new Sprite();
		hs.addChild(halo);
		addLinkedSprite("halo", hs, 3,headY*2-15);
		
		var jw = Math.ceil( 10 + 15*Math.min(1, data.kMax/20) );
		bar = new LifeJauge();
		bar.life = data.life;
		bar.resist = data.boredom;
		bar.compact = true;
		bar.maxWidth = 40;
		bar.maxResist = data.maxBoredom;
		bar.update();
		addLinkedSprite("bar", bar, -bar.width*0.5, 0);
		
		buffIcon = man.tiles.getSprite("buffIcons", 0);
		buffIcon.setCenter(0,0);
		buffIcon.alpha = 0;
		man.gscroller.addChild(buffIcon);
		debuffIcon = man.tiles.getSprite("buffIcons", 1);
		debuffIcon.setCenter(0,0);
		debuffIcon.alpha = 0;
		man.gscroller.addChild(debuffIcon);
		
		//cache = new Bitmap( new BitmapData(wid,hei,true,0x0) );
		//cache.x = Std.int(-wid*0.5);
		//sprite.addChild(cache);
		
		sleepBubble = new lib.Bulle();
		sleepBubble.x = -1;
		sleepBubble.y = 12;
		sleepBubble.visible = false;
		sleepBubble.gotoAndPlay(Std.random(sleepBubble.totalFrames)+1);
		
		//filterTarget = cache;
		//photo = cache.bitmapData.clone();
		
		initSkin();
		setShadow(true);
		
		man.sdm.add(overArms.sprite, Const.DP_ITEMS);
		man.isos.push(overArms);
		
		sprite.addChild(skin);
		sprite.addChild(sleepBubble);
		
		photo = new BitmapData(23,hei, true, 0x0);
	}
	
	override public function destroy() {
		super.destroy();
		//cache.bitmapData.dispose();
		if( photo!=null )
			photo.dispose();
	}
	
	
	public inline function syncData() {
		var id = data.id;
		var sdata = man.solver.getStudent(data.id);
		sdata.solver = null;
		data = man.createCopy(sdata);
		sdata.solver = man.solver;
		data.solver = man.solver;
	}

	
	override function updateButton() {
		super.updateButton();
		if( button!=null )
			button.visible = atSeat() && !man.lockActions && man.potentialTargets.length==0;
	}
	
	public function updateStuffPosition() {
		if( stuff==null )
			return;
		var table = getTable();
		stuff.cx = table.cx;
		stuff.cy = table.cy;
	}
	
	public function setStuffVisibility(b:Bool) {
		if( stuff==null )
			return;
		if( b ) {
			man.tw.terminate(stuff.sprite);
			stuff.fl_visible = true;
			stuff.sprite.alpha = 0;
			man.tw.create(stuff.sprite, "alpha", 1, TEaseIn, 500);
		}
		else {
			man.tw.terminate(stuff.sprite);
			stuff.sprite.alpha = 1;
			man.tw.create(stuff.sprite, "alpha", 0, TEaseIn, 500).onEnd = function() {
				stuff.fl_visible = b;
			}
		}
	}
	
	public inline function male() {
		return data.gender!=1;
	}
	public inline function female() {
		return !male();
	}
	
	override function setAlpha(v) {
		super.setAlpha(v);
		if( skin!=null )
			overArms.alpha = v;
		return v;
	}
	
	override function applyVisibility(d:Int) { // WARNING: pas d'appel à super();
		super.applyVisibility(d);
		if( bar!=null )
			setBarVisibility(fl_visible);
		if(skin!=null)
			overArms.fl_visible = fl_visible;
	}
	
	public function setPet(v:Bool) {
		halo.visible = v;
	}
	
	public function setHostile(v:Bool) {
		//bar.setHostile(v);
	}
	
	public function setBarVisibility(b:Bool) {
		if( isDone() )
			b = false;
		bar.visible = b;
	}
	
	public inline function getTable() {
		return Lambda.filter(man.isos, function(i) return i.collides && i.cx==data.seat.x && i.cy==data.seat.y+1).first();
	}
	
	public function setDone() {
		setBarVisibility(false);
		getTable().sprite.filters = [
			Color.getContrastFilter(-0.3),
		];
	}
	
	public inline function isDone() {
		return data.life<=0;
	}
	
	public function getPetAction() : Null<TActionData> {
		return data.petAction.k ? Common.getTActionData(data.petAction.a) : null;
	}
	
	public function getClosePoint() {
		var pt = getPoint();
		if( man.getStudentAt(cx+1, cy)!=null && !man.getPathCollision(man.tpf, cx-1,cy) )
			pt.x--;
		else
			pt.x++;
		return pt;
	}
	
	public function getFrontPoint() {
		var pt = getPoint();
		pt.y = Const.RHEI-4;
		return pt;
	}
	
	override public function toString() {
		return data.firstname+"#"+data.id+"@"+cx+","+cy;
	}
	
	public function lookAt(x:Float,y:Float) {
		look = { dx:(x<0 ? -1 : 1), dy:(y<0 ? -1 : 1) };
		skin.face.x = 0;
		skin.face.y = 0;
		skin.head.scaleX = 1;
		skin.head.x = 0;
		skin.head.y = 0;
		skin.hairs.y = -1;
		skin.mouth.alpha = 1;
		skin.head.filters = [ getSkinFilter() ];
		if (x<0) {
			// gauche
			skin.face.x -= 1;
		}
		if (x>0) {
			// droite
			skin.head.scaleX = -1;
			skin.head.x += 2;
		}
		if (y<0) {
			// haut
			skin.face.y -= 1;
			skin.hairs.y -= 1;
		}
		if (y>0) {
			// bas
			skin.head.x -= 1;
			skin.head.y += 1;
			skin.head.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.6, 0,0) ];
			skin.mouth.alpha = 0.35;
		}
		waitingCpt+=32*3;
		invalidate();
	}
	
	public inline function isSpecial() {
		return data.fromUser != null ;
	}
	
	public function initSkin() {
		rseed.initSeed(data.id);
		var suffix = data.gender == 0 ? "_m" : "_f";
		skin = new Skin();
		
		var armsType = rseed.random(100)<40 ? "arms_full" : "arms_short";
		
		skin.addChild( skin.torso = man.chars.getSprite("torso") );
		skin.addChild( skin.legs = man.chars.getSprite("legs") );

		// Peau
		skinColor = SKIN_COLORS[rseed.random(SKIN_COLORS.length)];
		skin.torso.filters = [ getSkinFilter() ];
		skin.legs.filters = [ getSkinFilter() ];
		
		// vêtement bas
		skin.trousers = new Bitmap( new BitmapData(wid,hei, true, 0x0) );
		skin.trousers.x = Std.int(-wid*0.5);
		man.chars.drawIntoBitmap(skin.trousers.bitmapData, 0,0, "trousers"+suffix, man.chars.getRandomFrame("trousers"+suffix, rseed.random), 0,0);
		var c = TROUSERS_COLORS[rseed.random(TROUSERS_COLORS.length)];
		Color.paintBitmapGrays(skin.trousers.bitmapData, Color.makeNicePalette(c));
		skin.addChild(skin.trousers);
				
		// vêtement haut
		skin.shirt = new Bitmap( new BitmapData(wid,hei, true, 0x0) );
		skin.shirt.x = Std.int(-wid*0.5);
		man.chars.drawIntoBitmap(skin.shirt.bitmapData, 0,0, "shirt"+suffix, man.chars.getRandomFrame("shirt"+suffix, rseed.random), 0,0);
		var c = if (data.gender == 0) SHIRT_COLORS_M[rseed.random(SHIRT_COLORS_M.length)] else SHIRT_COLORS_F[rseed.random(SHIRT_COLORS_F.length)];
		Color.paintBitmapGrays(skin.shirt.bitmapData, Color.makeNicePalette(c));
		skin.addChild(skin.shirt);

		skin.addChild( skin.arms = man.chars.getSprite(armsType) );
		skin.addChild( skin.legsAnim = man.chars.getSprite("legs_anim") );
		skin.arms.filters = [ getSkinFilter() ];
		
		skin.addChild( skin.head = man.chars.getSprite("head", rseed.random(4)) );
		
		skin.face = new Sprite();
		skin.head.addChild(skin.face);
		skin.head.filters = [ getSkinFilter() ];
		
		skin.eyes = man.chars.getSprite("eyes");
		skin.face.addChild(skin.eyes);
		skin.setEyesColor( EYE_COLORS[rseed.random(EYE_COLORS.length)] );
		skin.eyes.setFrame(0);
		
		// Bouche
		mouthFrame = male() ? rseed.irange(10,20) : rseed.irange(10,21);
		skin.face.addChild( skin.mouth = man.chars.getSprite("mouth"+suffix, mouthFrame) );
		
		
		// Cheveux
		var frame =
			if( male() )	!isSpecial() ? rseed.irange(0,13) : rseed.irange(14,21) // garçon
			else			!isSpecial() ? rseed.irange(0,13) : rseed.irange(14,23); // fille
		skin.hairs = new Bitmap( new BitmapData(23,hei, true, 0x0) );
		skin.head.addChild(skin.hairs);
		skin.hairs.x = Std.int(-wid*0.5);
		skin.hairs.y = -1;
		man.chars.drawIntoBitmap(skin.hairs.bitmapData, 0,0, "hair"+suffix, frame, 0,0);
		if( isSpecial() )
			this.color = HAIR_COLORS_SPECIAL[rseed.random(HAIR_COLORS_SPECIAL.length)];
		else
			this.color = HAIR_COLORS[rseed.random(HAIR_COLORS.length)];
		Color.paintBitmapGrays(skin.hairs.bitmapData, Color.makeNicePalette(this.color));
		
		overArms = new Iso( man.chars.getSprite(armsType) );
		overArms.yOffset = yOffset;
		overArms.layer = 1;
	}
	
	public function getSkinFilter() {
		return Color.getColorizeMatrixFilter(skinColor, 0.6, 0.4);
	}
	
	public function updatePhoto() {
		//var clone = new Student(data);
		//clone.initSkin();
		var m = new flash.geom.Matrix();
		m.translate(Std.int(wid*0.5), 0);
		photo.fillRect(photo.rect, 0x0);
		photo.draw(skin, m);
		//clone.destroy();
	}


	public function getBmpHead() : BitmapData {
		var head = new BitmapData(wid,hei,true,0x0) ;
		var m = new flash.geom.Matrix() ;
		m.translate(Std.int(wid*0.5), 0) ;
		head.fillRect(head.rect, 0x0) ;
		head.draw(skin.head, m) ;

		return head ;
	}
	
	override function followPath(p) {
		super.followPath(p);
		
		stand();
		lookAt(0,0);
		skin.arms.playAnim("walk");
		skin.legsAnim.playAnim("walk");
	}
	
	public inline function seatBack(?s:Float) {
		goto(data.seat, s);
	}
	
	override public function goto(pt, ?s:Float) {
		resetPose();
		super.goto(pt, s);
		lookAt(0,0);
	}
	
	public inline function atSeat() {
		return canSit && move==null && path.length==0 && waitingAt(data.seat);
	}
	
	override function onArrive() {
		super.onArrive();
		man.cm.signal("student");
		
		skin.arms.stopAnim(0);
		skin.legsAnim.stopAnim(0);
		invalidate();
		
		if ( waitingAt(Const.EXIT) )
			fl_visible = false;
			
		if ( atSeat() )
			sit();
		else
			stand();
	}
	
	public function talkTo(s:Student) {
		lookAt(0,0);
		if (s.cx<cx)
			lookAt(-1,0);
		if (s.cx>cx)
			lookAt(1,0);
	}
	
	function sit() {
		if(skin!=null) {
			overArms.sprite.visible = true;
			skin.arms.visible = false;
			sprite.scaleX = 1;
			setAnim();
			invalidate();
		}
	}
	
	function stand() {
		if (skin!=null) {
			overArms.sprite.visible = false;
			skin.arms.visible = true;
			invalidate();
		}
	}
	
	override function getInCasePos() {
		return
			if ( atSeat() )
				{ xr:0.5, yr:0.95 };
			else
				super.getInCasePos();
	}
	
	public inline function invalidate() {
		fl_redraw = true;
	}

	
	public function setRandomAnim() {
		var a = Type.createEnumIndex(StudentAnim, Std.random(Type.getEnumConstructs(StudentAnim).length));
		setAnim(a);
	}
	
	public function setAnim(?a:StudentAnim) {
		resetPose();
		if( a!=null ) {
			lookAt(0,0);
			currentAnim = {a:a, t:0};
			switch( a ) {
				case SA_Talk :
					skin.mouth.playAnim("talk");
				case SA_Write :
					skin.arms.playAnim("write");
				case SA_Yawn :
					skin.mouth.setFrame(0);
					skin.eyes.setFrame(1);
				case SA_Bored :
					skin.eyes.setFrame(7);
					skin.mouth.setFrame(19);
					skin.arms.setFrame(9);
				case SA_Tired :
					skin.eyes.setFrame(1);
					skin.mouth.setFrame(0);
					skin.arms.setFrame(9);
				case SA_EyesClosed :
					skin.eyes.setFrame(1);
				case SA_Smile :
					skin.mouth.setFrame(2);
				case SA_Sad :
					skin.mouth.setFrame(3);
				case SA_Happy :
					skin.eyes.setFrame(10);
					skin.mouth.setFrame(1);
				case SA_VeryHappy :
					skin.mouth.setFrame(1);
				case SA_Grin :
					skin.mouth.setFrame(4);
				case SA_Laugh :
					skin.mouth.setFrame(1);
				case SA_EvilLaugh :
					skin.mouth.setFrame(4);
					skin.eyes.setFrame(9);
				case SA_Surprise :
					skin.mouth.setFrame(0);
					skin.eyes.setFrame(10);
				case SA_Surprise2 :
					skin.eyes.setFrame(10);
					skin.mouth.setFrame(6);
				case SA_SurpriseSad :
					skin.mouth.setFrame(8);
					skin.eyes.setFrame(10);
				case SA_Evil :
					skin.mouth.setFrame(2);
					skin.eyes.setFrame(9);
				case SA_EvilGrin :
					skin.mouth.setFrame(4);
					skin.eyes.setFrame(9);
				case SA_Tongue :
					skin.mouth.setFrame(7);
					skin.eyes.setFrame(10);
				case SA_EvilEyes :
					skin.mouth.setFrame(18);
					skin.eyes.setFrame(13);
				case SA_Sneeze :
					skin.eyes.setFrame(1);
					skin.mouth.setFrame(0);
				case SA_Cry :
					skin.eyes.setFrame(1);
					skin.mouth.setFrame(8);
				case SA_TalkHandUp :
					skin.arms.setFrame(11);
			}
		}
		invalidate();
	}
	
	public inline function is(s:SState) {
		return data.hasState(s);
	}
	
	function resetPose() {
		currentAnim = null;
		skin.mouth.visible = true;
		skin.mouth.stopAnim(mouthFrame);
		skin.eyes.stopAnim(0);
		skin.eyes.y = 0;
		if( atSeat() ) {
			skin.arms.visible = false;
			skin.arms.stopAnim(armFrame);
			overArms.sprite.visible = true;
		}
		else
			skin.arms.stopAnim(0);
		skin.head.y = 0;
		sprite.blendMode = flash.display.BlendMode.NORMAL;
		invalidate();
	}
	
	public function updateBuffIcons() {
		buffIcon.x = bar.x-10;
		buffIcon.y = bar.y;
		debuffIcon.x = buffIcon.x - (buffIcon.alpha>0 ? 8 : 0);
		debuffIcon.y = buffIcon.y;
		buffIcon.visible = debuffIcon.visible = fl_visible;
	}
	
	public function updatePose() {
		resetPose();
		allowWaitAnim = true;
		
		var hadBuff = buffIcon.alpha>0;
		var hadDebuff = debuffIcon.alpha>0;
		var buff = false;
		var debuff = false;
		if( !isDone() )
			for( s in data.states )
				if( Common.getStateData(s).cleanable > 0 )
					buff = true;
				else
					debuff = true;
		buffIcon.alpha = buff ? 1 : 0;
		debuffIcon.alpha = debuff ? 1 : 0;
		
		// Anim buff
		if( !hadBuff && buff ) {
			buffIcon.scaleX = buffIcon.scaleY = 3;
			man.tw.create(buffIcon, "scaleX", 1, TBurnIn, 700).onUpdate = function() {
				buffIcon.scaleY = buffIcon.scaleX;
			}
		}
		
		// Anim debuff
		if( !hadDebuff && debuff ) {
			debuffIcon.scaleX = debuffIcon.scaleY = 3;
			man.tw.create(debuffIcon, "scaleX", 1, TBurnIn, 700).onUpdate = function() {
				debuffIcon.scaleY = debuffIcon.scaleX;
			}
		}
		
		updateBuffIcons();
		
		// Attention
		if( atSeat() ) {
			if( data.boredom<=0 ) {
				skin.mouth.setFrame(2);
				skin.arms.stopAnim(10) ;
			}
			else if( data.boredom>=4 ) {
				skin.mouth.setFrame(3);
				skin.arms.stopAnim(9) ;
			}
		}
		
		// Hostile (bouche)
		//if( data.hostile )
			//skin.mouth.setFrame(2);
		
		// Colère
		if( is(SState.Angry) ) {
			skin.mouth.setFrame(3);
			skin.eyes.setFrame(9);
		}

		// Boude
		if( is(SState.Sulk) ) {
			skin.eyes.setFrame(3);
		}
	
		// Travail personnel
		if( atSeat() && is(SState.Book) ) {
			lookAt(0,1);
			setAnim(SA_Write);
		}
	
		// Exercice
		if( atSeat() && man.solver.hasCurrentExercice() && !isDone() )
			setAnim(SA_Write);
	
		// Rire
		if( is(SState.Lol) )
			setAnim(SA_Laugh);

		// Mal au crâne
		if( is(SState.Headache) ) {
			skin.eyes.setFrame(1);
			skin.mouth.setFrame(0);
		}

		// Bavardage
		if( is(SState.Speak) ) {
			if( atSeat() )
				setAnim(SA_Talk);
			var with = man.getStudent( data.speakers.first() );
			if( atSeat() && with!=null && with.atSeat() )
				lookAt(with.sprite.x-sprite.x, 0);
		}

		// Main levée
		if( atSeat() && data.handUp!=null )
			skin.arms.setFrame(11);
			
		// Hostile (yeux)
		if( data.hostile )
			skin.eyes.setFrame(9);
	
		// Chante/siffle
		if( is(SState.Singing) ) {
			if( atSeat() )
				setAnim(SA_Talk);
			skin.mouth.setFrame(6);
		}
			
		// Inoffensif
		if( is(SState.Harmless) ) {
			skin.eyes.setFrame(14);
			skin.mouth.setFrame(1);
		}

		// Tétanisé
		if( is(SState.Tetanised) ) {
			allowWaitAnim = false;
			skin.eyes.setFrame(12);
			skin.mouth.visible = false;
			skin.arms.setFrame(0);
		}
		
		// Ramollo
		if( is(SState.Doughy) ) {
			skin.eyes.setFrame(3);
			skin.mouth.setFrame(5);
		}
		
		// Largué
		if( is(SState.Inverted) ) {
			skin.eyes.setFrame(10);
			skin.mouth.setFrame(6);
		}

		// Débile
		if( is(SState.Slowed) ) {
			skin.eyes.setFrame(14);
			skin.mouth.setFrame(7);
		}

		// KO
		if( is(SState.KO) ) {
			allowWaitAnim = false;
			lookAt(0,1);
			skin.eyes.setFrame(11);
			skin.mouth.visible = false;
			skin.arms.setFrame(0);
			skin.arms.visible = true;
			overArms.sprite.visible = false;
		}

		// Endormi
		if( atSeat() && is(SState.Asleep) ) {
			allowWaitAnim = false;
			sleepBubble.visible = true;
			skin.mouth.visible = false;
			skin.eyes.setFrame(1);
			skin.arms.stopAnim(8);
			lookAt(0,0);
		}
		else {
			skin.mouth.visible = true;
			sleepBubble.visible = false;
		}
		
		// Vaincu
		if( isDone() ) {
			sprite.filters = [
				Color.getContrastFilter(-0.3),
				Color.getSaturationFilter(0.1),
				//Color.getColorizeMatrixFilter(0xF5E4AF, 0.5, 0.5),
			];
		}
		
		// Invisibilité
		if( is(SState.Invisibility) ) {
			alpha = 0.3;
			sprite.blendMode = flash.display.BlendMode.ADD;
		}
	}
	
	
	override function updateLinkedSprites() {
		super.updateLinkedSprites();
		
		if( halo.visible )
			halo.y = Math.sin(uid+man.time*0.13) * 1.5 - 2;
	}
	
	
	public override function update() {
		var old = getFloatPoint();
		var oldH = ch;

		super.update();
		
		if (skin==null)
			return;
			
		if (currentAnim!=null) {
			// Anim
			currentAnim.t++;
			switch( currentAnim.a ) {
				case SA_Talk, SA_TalkHandUp  :
					var closed = skin.mouth.getFrame() == mouthFrame;
					if( closed && currentAnim.t>=2 ) {
						skin.mouth.setFrame(Std.random(2));
						currentAnim.t = 0;
					}
					else if( !closed && currentAnim.t>3+Std.random(3) ) {
						skin.mouth.setFrame(mouthFrame);
						currentAnim.t = 0;
					}
				case SA_Laugh :
					skin.mouth.setFrame(1);
					if (currentAnim.t>2) {
						currentAnim.t = 0;
						skin.head.y = skin.head.y==0 ? 1 : 0;
						skin.arms.y = skin.arms.y==0 ? -1 : 0;
					}
				case SA_EvilLaugh :
					skin.mouth.setFrame(4);
					if (currentAnim.t>2) {
						currentAnim.t = 0;
						skin.head.y = skin.head.y==0 ? 1 : 0;
						skin.arms.y = skin.arms.y==0 ? -1 : 0;
					}
				case SA_Cry :
					if (currentAnim.t>=4) currentAnim.t = 0;
					if (currentAnim.t==0) lookAt(-1,0);
					if (currentAnim.t==2) lookAt(0,0);
					//if (currentAnim.t==2) lookAt(1,0);
					//if (currentAnim.t==3) lookAt(1,0);
				default :
			}
			invalidate();
		}
		if( currentAnim==null && allowWaitAnim ) {
			// Anim d'attente
			if( waitingCpt--<=0 ) {
				lookAt(Lib.irnd(0,2)-1, 0);
				if( skin.eyes.getFrame()==0 )
					skin.eyes.playAnim("eyes_blink",1);
				waitingCpt = Lib.irnd(30,100);
			}
		}
		invalidate();
		
		if( move!=null ) {
			sleepBubble.visible = false;
			if( (man.time+uid)%6==0 ) {
				var pt = getGlobalCoords();
				var panning = Math.min(1, Math.max(-1, pt.x/(Const.WID*0.5) - 1));
				if( Std.random(100)<60 )
					Manager.SBANK.footstep01().play(0.8,panning);
				else
					Manager.SBANK.footstep02().play(0.8,panning);
			}
			
		}
		
		if( !man.cm.turbo ) {
			// Pleurs
			if( fl_visible && cd.has("forceCry") ) {
				skin.eyes.setFrame(1);
				skin.mouth.setFrame(8);
				if( !cd.hasSet("cry", 4) )
					man.fx.cry(this, 3);
			}
			
			// Criterium
			if( fl_visible && is(SState.TicTic) && !cd.has("criterium") ) {
				Manager.SBANK.criterium().play( Lib.rnd(0.1, 0.7), Lib.rnd(-0.2, 0.2) );
				man.fx.word(this, Tx.S_CriteriumNoise, 0xFFFFFF, Lib.rnd(0,10,true));
				cd.set("criterium", Lib.rnd(2,25));
			}
			
			// Ramollo
			if( fl_visible && is(SState.Doughy) && !cd.hasSet("doughy",50) )
				man.fx.bubbles(this);
			
			// Chante
			if( fl_visible && (uid+man.time)%30==0 && is(SState.Singing) ) {
				var a = Tx.S_SingNoise.split(",");
				man.fx.words(this, a, Std.random(3)+1, 0.7);
			}
			
			// Travail perso
			if( atSeat() && is(SState.Book) && !cd.hasSet("bookFx", Lib.rnd(10,20)) )
				man.fx.sparks(this, -3,11, Lib.irnd(1,4), 0xE9E7DC);
		}
		
		var pt = getFloatPoint();
		if ( old.x!=pt.x || old.y!=pt.y || oldH!=ch )
			invalidate();
			
		//knowledge.scaleX = sprite.scaleX;
		//bar.scaleX = sprite.scaleX;
		//knowledge.visible = !data.done(); // utiliser data.success pour compter les tours
			
		if ( fl_redraw ) {
			updateBuffIcons();
			
			var m = new flash.geom.Matrix();
			m.translate(Std.int(wid*0.5), 0);
			
			overArms.xr = xr;
			overArms.yr = yr-1;
			overArms.cx = cx;
			overArms.cy = cy+1;
			overArms.tmp_xr = tmp_xr;
			overArms.tmp_yr = tmp_yr;
			overArms.ch = ch;
			overArms.sprite.setFrame(skin.arms.frame);
			overArms.sprite.transform.colorTransform = sprite.transform.colorTransform;
			overArms.sprite.blendMode = sprite.blendMode;
			overArms.sprite.filters = skin.arms.filters;
			if( isDone() )
				overArms.sprite.filters = sprite.filters;
			
			//cache.bitmapData.fillRect(cache.bitmapData.rect, 0x0);
			//cache.bitmapData.draw(skin, m);
			fl_redraw = false;
		}
	}
}


