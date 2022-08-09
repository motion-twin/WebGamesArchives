package en.mob;

import flash.display.BlendMode;
import mt.deepnight.retro.SpriteLibBitmap;

class Ghost extends en.Mob {
	static inline var FACE_OFFSETS = [0,3,-3,-5,-7,-8,-8,-7,-6,-4];
	
	var immaterial		: Bool;
	var baseSpeed		: Float;
	var face			: BSprite;
	var teint			: flash.filters.ColorMatrixFilter;
	var trackDistance	: Int;
	
	public function new(x,y) {
		super(x,y);
		
		maxPathLen = 15;
		baseScore = 15;
		trackDistance = 150;
		
		radius = 8;
		initLife(15);
		
		face = game.char.getRandom("ghostFace", rseed.random);
		sprite.addChild(face);
		
		sprite.swap("ghost");
		sprite.setCenter(0.5, 1);
		teint = mt.deepnight.Color.getColorizeMatrixFilter(mt.deepnight.Color.randomColor(rseed.rand(), 0.6, 0.6), 0.8, 0.2);
		sprite.filters = [teint];
		
		setImmaterial(false);
	}

	override function getLoot() { return api.AKApi.const(1); }
	override function getXp() { return api.AKApi.const(4); }

	function setImmaterial(b:Bool) {
		if( immaterial==b )
			return;
		cd.set("dephase", 30);
		immaterial = b;
		collides = !immaterial;
		weight = immaterial ? 0 : 1;
		fx.spawnSmoke(this, -20);
		sprite.blendMode = immaterial ? BlendMode.ADD : BlendMode.NORMAL;
		if( immaterial )
			sprite.filters = [ new flash.filters.BlurFilter(4,4), teint ];
		else
			sprite.filters = [teint];
		strength = immaterial ? 0 : 5;
		setShadow(!immaterial);
		setSpeed( immaterial ? 1.1 : 0.7 );
		
		baseScore = immaterial ? -100 : 20;
		updateTargetScore();
	}
	
	override function canBeHit() {
		return !immaterial;
	}
	
	override public function onTouchEntity(e:Entity) {
		if( !immaterial )
			super.onTouchEntity(e);
	}
	
	override function defaultAI() {
		var d = distance(hero);
		
		if( d<=trackDistance || cd.has("sawHero") ) {
			if( !immaterial && !sightCheck(hero) )
				setImmaterial(true);
			if( !cd.has("sawHero") ) {
				cd.set("dodge", rnd(20,40));
				setImmaterial(true);
			}
			cd.set("sawHero", 30);
			if( immaterial && sightCheck(hero) && !cd.has("dodge") )
				setImmaterial(false);
			gotoDumb(hero.xx, hero.yy);
			if( !immaterial )
				decisionCD(15);
		}
		else {
			if( immaterial && !getCollision(cx,cy) )
				setImmaterial(false);
			wander();
			decisionCD(30);
		}
	}
	
	override function update() {
		if( cd.has("slow") )
			cd.unset("slow");
			
		super.update();
		
		//if( !cd.has("dephase") && immaterial && !getCollision(cx,cy) )
			//setImmaterial(false);
			
		sprite.alpha = immaterial ? 0.5 : 1;
		face.y = FACE_OFFSETS[sprite.frame]-3;
	}
}
