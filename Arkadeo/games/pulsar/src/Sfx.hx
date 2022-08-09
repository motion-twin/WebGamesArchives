
#if sound
import flash.media.Sound;

@:sound("ExploBad_A.wav") 	class Explo_A 			extends Sound { }
@:sound("ExploBad_A.wav") 	class ExploBad_A 		extends Sound { }
@:sound("ExploBad_B.wav") 	class ExploBad_B 		extends Sound { }
@:sound("ExploBad_C.wav") 	class ExploBad_C 		extends Sound { }

@:sound("ExploCell.wav") 	class ExploCell 		extends Sound { }
@:sound("ExploEgg.wav") 	class ExploEgg 			extends Sound { }
@:sound("HitBad_A.wav") 	class HitBad_A 			extends Sound { }
@:sound("HitBad_B.wav") 	class HitBad_B 			extends Sound { }
@:sound("HitBad_C.wav") 	class HitBad_C 			extends Sound { }

@:sound("HitShield_A.wav") 	class HitShield_A 		extends Sound { }
@:sound("HitWall_A.wav") 	class HitWall_A 		extends Sound { }
@:sound("PopBad_A.wav") 	class PopBad_A 			extends Sound { }
@:sound("PopSpawn_A.wav") 	class PopSpawn_A 		extends Sound { }
@:sound("Shoot_A.wav") 		class Shoot_A 			extends Sound { }
@:sound("Shoot_B.wav") 		class Shoot_B 			extends Sound { }
@:sound("Shoot_C.wav") 		class Shoot_C 			extends Sound { }
@:sound("ShootTank_A.wav") 	class ShootTank_A 		extends Sound { }

@:sound("SpawnBonus.wav") 	class SpawnBonus 		extends Sound { }
@:sound("CatchBonus.wav") 	class CatchBonus 		extends Sound { }

class Sfx  {//}
	
	
	static var sounds = mt.data.Sounds.directory("sfx");
	
	
	static var bank:Array<flash.media.Sound>;
	
	static var lastId:Int;
	static var lastTimer:Int;
	
	public static function init() {

	
		bank = [];
		bank.push( new ExploBad_A() );			// 0
		bank.push( new Shoot_A() );			// 1
		bank.push( new Shoot_B() );			// 2
		bank.push( new Shoot_C() );			// 3
		
		bank.push( new ExploBad_A() );		// 4
		bank.push( new ExploBad_B() );		// 5
		bank.push( new ExploCell() );		// 6
		
		bank.push( new HitBad_A() );		// 7
		bank.push( new HitBad_B() );		// 8
		bank.push( new HitBad_C() );		// 9
		
		bank.push( new HitWall_A() );		// 10
		bank.push( new PopBad_A() );		// 11
		bank.push( new PopSpawn_A() );		// 12
		bank.push( new ShootTank_A() );		// 13
		
		bank.push( new HitShield_A() );		// 14
		bank.push( new ExploEgg() );		// 15
		bank.push( new ExploBad_C() );		// 16
		
		bank.push( new SpawnBonus() );		// 17
		bank.push( new CatchBonus() );		// 18
	}
	
	public static function play(id, vol = 1.0) {
		if( vol < 0.1 || !Cs.SOUND_FX ) return;
		
		if( lastTimer == Game.me.timer && lastId == id ) return;
			
		lastTimer = Game.me.timer;
		lastId = id;
		
		var st = new flash.media.SoundTransform(vol);
		st.volume = vol * 0.25;
		
	
		switch(id) {
			case 0 :
			case 1 :
				id += Std.random(3);
				
			case 5 :
		}
		var snd = bank[id];
		//trace(snd);
		snd.play(0, 0, st);
	}
	
	function modPitch(snd:flash.media.Sound) {
		var a = new flash.utils.ByteArray();
		snd.extract(a, snd.length);
	}
	
	
	
//{
}

class Pitcher {
	
	
	static var BLOCK_SIZE = 3072;
	
	var _base:flash.media.Sound;
	var _sound:flash.media.Sound;
	var _target:flash.utils.ByteArray;
	var _position: Float;
	var _rate: Float;
		
	
	public function new (snd:flash.media.Sound,rate) {
		_base = snd;
		_rate = rate;
		
		_target = new flash.utils.ByteArray();
		_position = 0.0;


		_sound = new flash.media.Sound();
		
		_sound.addEventListener( flash.events.SampleDataEvent.SAMPLE_DATA, sampleData );
		var chan = _sound.play();
		if( chan != null ) 	chan.addEventListener(flash.events.Event.SOUND_COMPLETE, kill);
		else kill(null);
		
		
		
	
	}
	
	function sampleData( event: flash.events.SampleDataEvent ){
	
		//-- REUSE INSTEAD OF RECREATION
		_target.position = 0;
		
		//-- SHORTCUT
		var data = event.data;
		
		var scaledBlockSize = BLOCK_SIZE * _rate;
		var positionInt = _position;
		var alpha:Float = _position - positionInt;

		var positionTargetNum = alpha;
		var positionTargetInt = -1;

		//-- COMPUTE NUMBER OF SAMPLES NEED TO PROCESS BLOCK (+2 FOR INTERPOLATION)
		var need = Math.ceil( scaledBlockSize ) + 2;
		
		//-- EXTRACT SAMPLES
		var read = _base.extract( _target, need, positionInt );

		/*
		if( positionInt >= _base.length ) {
			kill(null);
			return;
		}
		*/
		
		var n = read == need ? BLOCK_SIZE :Std.int( read / _rate);

		var l0: Float = 0;
		var r0: Float = 0;
		var l1: Float = 0;
		var r1: Float = 0;

		//for( var i: int = 0 ; i < n ; ++i )
		var i = 0;
		while( i<n ) {
			
			//-- AVOID READING EQUAL SAMPLES, IF RATE < 1.0
			if( Std.int( positionTargetNum ) != positionTargetInt ){
				positionTargetInt = Std.int(positionTargetNum);
				
				//-- SET TARGET READ POSITION
				_target.position = positionTargetInt << 3;

				//-- READ TWO STEREO SAMPLES FOR LINEAR INTERPOLATION
				l0 = _target.readFloat();
				r0 = _target.readFloat();

				l1 = _target.readFloat();
				r1 = _target.readFloat();
			}
			
			//-- WRITE INTERPOLATED AMPLITUDES INTO STREAM
			data.writeFloat( l0 + alpha * ( l1 - l0 ) );
			data.writeFloat( r0 + alpha * ( r1 - r0 ) );
			
			//-- INCREASE TARGET POSITION
			positionTargetNum += _rate;
			
			//-- INCREASE FRACTION AND CLAMP BETWEEN 0 AND 1
			alpha += _rate;
			while( alpha >= 1.0 ) --alpha;
			
			i++;
		}
		
		//-- FILL REST OF STREAM WITH ZEROs
		if( i < BLOCK_SIZE ){
			while( i < BLOCK_SIZE ){
				data.writeFloat( 0.0 );
				data.writeFloat( 0.0 );
				++i;
			}
		}

		//-- INCREASE SOUND POSITION
		_position += Std.int(scaledBlockSize);
	}
	
	function kill(e) {
		_sound.removeEventListener( flash.events.SampleDataEvent.SAMPLE_DATA, sampleData );
		
	}
}

#end
