package mt.flash;

private typedef Table<T> = #if flash10 flash.Vector<T> #else Array<T> #end

// Use http://www.superflashbros.net/as3sfxr/ for settings

// haXe port by Tong http://disktree.spektral.at/git/?a=summary&p=sfxr

class Sfxr {

	public var waveType	: UInt;

	public var sampleRate : UInt;

	public var bitDepth	: UInt;

	public var masterVolume : Float;

	public var attackTime : Float;
	public var sustainTime : Float;
	public var sustainPunch : Float;
	public var decayTime : Float;

	public var startFrequency : Float;
	public var minFrequency : Float;

	public var slide : Float;
	public var deltaSlide : Float;

	public var vibratoDepth : Float;
	public var vibratoSpeed : Float;

	public var changeAmount : Float;
	public var changeSpeed : Float;

	public var squareDuty : Float;
	public var dutySweep : Float;

	public var repeatSpeed : Float;

	public var phaserOffset : Float;
	public var phaserSweep : Float;

	public var lpFilterCutoff : Float;
	public var lpFilterCutoffSweep : Float;
	public var lpFilterResonance : Float;

	public var hpFilterCutoff : Float;
	public var hpFilterCutoffSweep : Float;

	var _waveData : flash.utils.ByteArray;
	var _waveDataPos : UInt;
	var _waveDataLength : UInt;
	var _waveDataBytes : UInt;

	var _envelopeVolume : Float;
	var _envelopeStage : Int;
	var _envelopeTime : Float;
	var _envelopeLength : Float;
	var _envelopeLength0 : Float;
	var _envelopeLength1 : Float;
	var _envelopeLength2 : Float;
	var _envelopeOverLength0 : Float;
	var _envelopeOverLength1 : Float;
	var _envelopeOverLength2 : Float;
	var _envelopeFullLength : Float;

	var _phase : Float;
	var _pos : Float;
	var _period : Float;
	var _periodTemp : Float;
	var _maxPeriod : Float;

	var _slide : Float;
	var _deltaSlide : Float;

	var _vibratoPhase : Float;
	var _vibratoSpeed : Float;
	var _vibratoAmplitude : Float;

	var _changeAmount : Float;
	var _changeTime : Float;
	var _changeLimit : Float;

	var _squareDuty : Float;
	var _dutySweep : Float;

	var _repeatTime : Float;
	var _repeatLimit : Float;

	var _phaserOffset : Float;
	var _phaserDeltaOffset : Float;
	var _phaserInt : Int;
	var _phaserPos : Int;
	var _phaserBuffer : Table<Float>;

	var _lpFilterPos : Float;
	var _lpFilterOldPos : Float;
	var _lpFilterDeltaPos : Float;
	var _lpFilterCutoff : Float;
	var _lpFilterDeltaCutoff : Float;
	var _lpFilterDamping : Float;

	var _hpFilterPos : Float;
	var _hpFilterCutoff : Float;
	var _hpFilterDeltaCutoff : Float;

	var _noiseBuffer : Table<Float>;
	var _superSample : Float;
	var _sample : Float;
	var _sampleCount : UInt;
	var _bufferSample : Float;

	public function new( waveType : UInt = 0, sampleRate : UInt = 44100, bitDepth : UInt = 16, masterVolume : Float = 0.5 ) {
		this.waveType = waveType;
		this.sampleRate = sampleRate;
		this.bitDepth = bitDepth;
		this.masterVolume = masterVolume;
		attackTime = sustainTime = sustainPunch = decayTime = startFrequency = minFrequency = slide = deltaSlide = vibratoDepth = vibratoSpeed = changeAmount = changeSpeed = squareDuty = dutySweep = repeatSpeed = phaserSweep = lpFilterCutoff = lpFilterCutoffSweep = lpFilterResonance = hpFilterCutoff = hpFilterCutoffSweep = 0.0;
	}

	public function validate() {
		if( waveType > 3 ) waveType = 0;
		if( sampleRate != 22050 ) sampleRate = 44100;
		if( bitDepth != 8 ) bitDepth = 16;
		masterVolume = clamp1(masterVolume);
		attackTime = clamp1(attackTime);
		sustainTime = clamp1(sustainTime);
		sustainPunch = clamp1(sustainPunch);
		decayTime = clamp1(decayTime);
		startFrequency = clamp1(startFrequency);
		minFrequency = clamp1(minFrequency);
		slide = clamp2(slide);
		deltaSlide = clamp2(deltaSlide);
		vibratoDepth = clamp1(vibratoDepth);
		vibratoSpeed = clamp1(vibratoSpeed);
		changeAmount = clamp2(changeAmount);
		changeSpeed = clamp1(changeSpeed);
		squareDuty = clamp1(squareDuty);
		dutySweep = clamp2(dutySweep);
		repeatSpeed = clamp1(repeatSpeed);
		phaserOffset = clamp2(phaserOffset);
		phaserSweep = clamp2(phaserSweep);
		lpFilterCutoff = clamp1(lpFilterCutoff);
		lpFilterCutoffSweep = clamp2(lpFilterCutoffSweep);
		lpFilterResonance = clamp1(lpFilterResonance);
		hpFilterCutoff = clamp1(hpFilterCutoff);
		hpFilterCutoffSweep = clamp2(hpFilterCutoffSweep);
	}

	public function setSettings( s : String ) {
		var values = s.split(",");
		for( i in 0...values.length )
			if( values[i] == "" )
				values[i] = "0";
		waveType = 				Std.parseInt(values[0]);
		attackTime =  			Std.parseFloat(values[1]);
		sustainTime =  			Std.parseFloat(values[2]);
		sustainPunch =  		Std.parseFloat(values[3]);
		decayTime =  			Std.parseFloat(values[4]);
		startFrequency =  		Std.parseFloat(values[5]);
		minFrequency =  		Std.parseFloat(values[6]);
		slide =  				Std.parseFloat(values[7]);
		deltaSlide =  			Std.parseFloat(values[8]);
		vibratoDepth =  		Std.parseFloat(values[9]);
		vibratoSpeed =  		Std.parseFloat(values[10]);
		changeAmount =  		Std.parseFloat(values[11]);
		changeSpeed =  			Std.parseFloat(values[12]);
		squareDuty =  			Std.parseFloat(values[13]);
		dutySweep =  			Std.parseFloat(values[14]);
		repeatSpeed =  			Std.parseFloat(values[15]);
		phaserOffset =  		Std.parseFloat(values[16]);
		phaserSweep =  			Std.parseFloat(values[17]);
		lpFilterCutoff =  		Std.parseFloat(values[18]);
		lpFilterCutoffSweep =  	Std.parseFloat(values[19]);
		lpFilterResonance =  	Std.parseFloat(values[20]);
		hpFilterCutoff =  		Std.parseFloat(values[21]);
		hpFilterCutoffSweep =  	Std.parseFloat(values[22]);
		masterVolume = 			Std.parseFloat(values[23]);
		validate();
	}

	public function clone() {
		var out = new Sfxr();
		out.copyFrom( this );
		return out;
	}

	public function copyFrom( synth : Sfxr ) {
		waveType = 				synth.waveType;
		attackTime =            synth.attackTime;
		sustainTime =           synth.sustainTime;
		sustainPunch =          synth.sustainPunch;
		decayTime =             synth.decayTime;
		startFrequency =        synth.startFrequency;
		minFrequency =          synth.minFrequency;
		slide =                 synth.slide;
		deltaSlide =            synth.deltaSlide;
		vibratoDepth =          synth.vibratoDepth;
		vibratoSpeed =          synth.vibratoSpeed;
		changeAmount =          synth.changeAmount;
		changeSpeed =           synth.changeSpeed;
		squareDuty =            synth.squareDuty;
		dutySweep =             synth.dutySweep;
		repeatSpeed =           synth.repeatSpeed;
		phaserOffset =          synth.phaserOffset;
		phaserSweep =           synth.phaserSweep;
		lpFilterCutoff =        synth.lpFilterCutoff;
		lpFilterCutoffSweep =   synth.lpFilterCutoffSweep;
		lpFilterResonance =     synth.lpFilterResonance;
		hpFilterCutoff =        synth.hpFilterCutoff;
		hpFilterCutoffSweep =   synth.hpFilterCutoffSweep;
		masterVolume = 			synth.masterVolume;
		validate();
	}

	public function getWavFile() : flash.utils.ByteArray {
		reset(true);
		var soundLength = _envelopeFullLength;
		if( bitDepth == 16 ) soundLength *= 2;
		if( sampleRate == 22050 ) soundLength /= 2;
		var filesize = 36 + soundLength;
		var blockAlign = bitDepth / 8;
		var bytesPerSec = sampleRate * blockAlign;
		var wav = new flash.utils.ByteArray();
		var Endian = flash.utils.Endian;
		// Header
		wav.endian = Endian.BIG_ENDIAN;
		wav.writeUnsignedInt( 0x52494646 ); // Chunk ID "RIFF"
		wav.endian = Endian.LITTLE_ENDIAN;
		wav.writeUnsignedInt( Std.int( filesize ) ); // Chunck Data Size
		wav.endian = Endian.BIG_ENDIAN;
		wav.writeUnsignedInt( 0x57415645 ); // RIFF Type "WAVE"
		// Format Chunk
		wav.endian = Endian.BIG_ENDIAN;
		wav.writeUnsignedInt(0x666D7420); // Chunk ID "fmt "
		wav.endian = Endian.LITTLE_ENDIAN;
		wav.writeUnsignedInt(16); // Chunk Data Size
		wav.writeShort(1); // Compression Code PCM
		wav.writeShort(1); // Number of channels
		wav.writeUnsignedInt(sampleRate); // Sample rate
		wav.writeUnsignedInt( Std.int( bytesPerSec ) );	// Average bytes per second
		wav.writeShort( Std.int( blockAlign ) ); // Block align
		wav.writeShort( bitDepth );	// Significant bits per sample
		// Data Chunk
		wav.endian = Endian.BIG_ENDIAN;
		wav.writeUnsignedInt(0x64617461); // Chunk ID "data"
		wav.endian = Endian.LITTLE_ENDIAN;
		wav.writeUnsignedInt( Std.int( soundLength ) ); // Chunk Data Size
		synthWave( wav, Std.int( _envelopeFullLength ) );
		wav.position = 0;
		return wav;
	}


	function synthWave( buffer : flash.utils.ByteArray, length : Int, waveData : Bool = false ) {
		var finished = false;
		var Math = Math;
		_sampleCount = 0;
		_bufferSample = 0.0;
		for( i in 0...length ) {
			if( finished )
				return false;
			if( _repeatLimit != 0 ) {
				if( ++_repeatTime >= _repeatLimit ) {
					_repeatTime = 0;
					reset( false );
				}
			}
			if( _changeLimit != 0 ) {
				if( ++_changeTime >= _changeLimit ) {
					_changeLimit = 0;
					_period *= _changeAmount;
				}
			}
			_slide += _deltaSlide;
			_period = _period * _slide;
			if( _period > _maxPeriod ) {
				_period = _maxPeriod;
				if( minFrequency > 0.0 ) finished = true;
			}
			_periodTemp = _period;
			if( _vibratoAmplitude > 0.0 ) {
				_vibratoPhase += _vibratoSpeed;
				_periodTemp = _period * (1.0 + Math.sin(_vibratoPhase) * _vibratoAmplitude);
			}
			_periodTemp = Std.int( _periodTemp );
			if( _periodTemp < 8 ) _periodTemp = 8;
			_squareDuty += _dutySweep;
			if(_squareDuty < 0.0) _squareDuty = 0.0;
			else if(_squareDuty > 0.5) _squareDuty = 0.5;
			if( ++_envelopeTime > _envelopeLength ){
				_envelopeTime = 0;
				_envelopeLength = switch( ++_envelopeStage ) {
				case 1 :  _envelopeLength1;
				case 2 :  _envelopeLength2;
				}
			}
			_envelopeVolume = switch( _envelopeStage ) {
			case 0 : _envelopeTime * _envelopeOverLength0;
			case 1 : 1.0 + (1.0-_envelopeTime*_envelopeOverLength1) * 2.0 * sustainPunch;
			case 2 : 1.0 - _envelopeTime * _envelopeOverLength2;
			case 3 :
				finished = true;
				0.0;
			}
			_phaserOffset += _phaserDeltaOffset;
			_phaserInt = Std.int(_phaserOffset);
			if( _phaserInt < 0 ) _phaserInt = -_phaserInt;
			else if( _phaserInt > 1023 ) _phaserInt = 1023;
			if( _hpFilterDeltaCutoff != 0.0 ) {
				_hpFilterCutoff *- _hpFilterDeltaCutoff;
				if(_hpFilterCutoff < 0.00001 ) _hpFilterCutoff = 0.00001;
				else if( _hpFilterCutoff > 0.1 ) _hpFilterCutoff = 0.1;
			}
			_superSample = 0.0;
			for( j in 0...8 ) {
				_sample = 0.0;
				_phase++;
				if( _phase >= _periodTemp ) {
					_phase = _phase % _periodTemp;
					if( waveType == 3 ) {
						for( n in 0...32 )
							_noiseBuffer[n] = Math.random()*2.0 - 1.0;
					}
				}
				_pos = (_phase) / _periodTemp;
				switch(waveType) {
				case 0: _sample = (_pos < _squareDuty) ? 0.5 : -0.5;
				case 1: _sample = 1.0 - _pos * 2.0;
				case 2: _sample = Math.sin(_pos * Math.PI * 2.0);
				}
				_lpFilterOldPos = _lpFilterPos;
				_lpFilterCutoff *= _lpFilterDeltaCutoff;
				 if(_lpFilterCutoff < 0.0) _lpFilterCutoff = 0.0;
				else if(_lpFilterCutoff > 0.1) _lpFilterCutoff = 0.1;
				if(lpFilterCutoff != 1.0) {
					_lpFilterDeltaPos += (_sample - _lpFilterPos) * _lpFilterCutoff * 4;
					_lpFilterDeltaPos -= _lpFilterDeltaPos * _lpFilterDamping;
				} else {
					_lpFilterPos = _sample;
					_lpFilterDeltaPos = 0.0;
				}
				_lpFilterPos += _lpFilterDeltaPos;
				_hpFilterPos += _lpFilterPos - _lpFilterOldPos;
				_hpFilterPos -= _hpFilterPos * _lpFilterCutoff;
				_sample = _hpFilterPos;
				_phaserBuffer[_phaserPos&1023] = _sample;
				_sample += _phaserBuffer[(_phaserPos - _phaserInt + 1024) & 1023];
				_phaserPos = (_phaserPos + 1) & 1023;
				_superSample += _sample;
			}
			_superSample = masterVolume * masterVolume * _envelopeVolume * _superSample / 8.0;
			if(_superSample > 1.0) 	_superSample = 1.0;
			if(_superSample < -1.0) _superSample = -1.0;
			if( waveData ) {
				buffer.writeFloat(_superSample);
				buffer.writeFloat(_superSample);
			} else {
				_bufferSample += _superSample;
				_sampleCount++;
				if(sampleRate == 44100 || _sampleCount == 2) {
					_bufferSample /= _sampleCount;
					_sampleCount = 0;
					if( bitDepth == 16 ) buffer.writeShort(Std.int(32000.0 * _bufferSample));
					else buffer.writeByte( Std.int( _bufferSample * 127 ) + 128 );
					_bufferSample = 0.0;
				}
			}
		}
		return true;
	}


	function reset( total : Bool ) {
		_period = 100.0 / ( startFrequency * startFrequency + 0.001 );
		_maxPeriod = 100.0 / ( minFrequency * minFrequency + 0.001 );
		_slide = 1.0 - slide * slide * slide * 0.01;
		_deltaSlide = -deltaSlide * deltaSlide * deltaSlide * 0.000001;
		_squareDuty = 0.5 - squareDuty * 0.5;
		_dutySweep = -dutySweep * 0.00005;
		if( changeAmount > 0.0 )
			_changeAmount = 1.0 - changeAmount*changeAmount * 0.9;
		else
			_changeAmount = 1.0 + changeAmount * changeAmount * 10.0;
		_changeTime = 0;
		_changeLimit = ( changeSpeed == 1.0 ) ? 0 : (1.0 - changeSpeed) * (1.0 - changeSpeed) * 20000 + 32;
		if( total ) {
			_phase = 0;
			_lpFilterPos = _lpFilterDeltaPos = 0.0;
			_lpFilterCutoff = lpFilterCutoff * lpFilterCutoff * lpFilterCutoff * 0.1;
			_lpFilterDeltaCutoff = 1.0 + lpFilterCutoffSweep * 0.0001;
			_lpFilterDamping = 5.0 / (1.0 + lpFilterResonance * lpFilterResonance * 20.0) * (0.01 + _lpFilterCutoff);
			if( _lpFilterDamping > 0.8 ) _lpFilterDamping = 0.8;
			_hpFilterPos = 0.0;
			_hpFilterCutoff = hpFilterCutoff * hpFilterCutoff * 0.1;
			_hpFilterDeltaCutoff = 1.0 + hpFilterCutoffSweep * 0.0003;
			_vibratoPhase = 0.0;
			_vibratoSpeed = vibratoSpeed * vibratoSpeed * 0.01;
			_vibratoAmplitude = vibratoDepth * 0.5;
			_envelopeVolume = 0.0;
			_envelopeStage = 0;
			_envelopeTime = 0;
			_envelopeLength0 = attackTime * attackTime * 100000.0;
			_envelopeLength1 = sustainTime * sustainTime * 100000.0;
			_envelopeLength2 = decayTime * decayTime * 100000.0;
			_envelopeLength = _envelopeLength0;
			_envelopeFullLength = _envelopeLength0 + _envelopeLength1 + _envelopeLength2;
			_envelopeOverLength0 = 1.0 / _envelopeLength0;
			_envelopeOverLength1 = 1.0 / _envelopeLength1;
			_envelopeOverLength2 = 1.0 / _envelopeLength2;
			_phaserOffset = phaserOffset * phaserOffset * 1020.0;
			if( phaserOffset < 0.0 ) _phaserOffset = -_phaserOffset;
			_phaserDeltaOffset = phaserSweep * phaserSweep;
			if( _phaserDeltaOffset < 0.0 ) _phaserDeltaOffset = -_phaserDeltaOffset;
			_phaserPos = 0;
			if( _phaserBuffer == null ) _phaserBuffer = new Table();
			if( _noiseBuffer == null ) _noiseBuffer = new Table();
			for( i in 0...1024 ) _phaserBuffer[i] = 0.0;
			for( i in 0...32 ) _noiseBuffer[i] = Math.random() * 2.0 - 1.0;
			_repeatTime = 0;
			if( repeatSpeed == 0.0 ) _repeatLimit = 0;
			else _repeatLimit = Std.int((1.0-repeatSpeed) * (1.0-repeatSpeed) * 20000) + 32;
		}
	}

	inline function clamp1( v : Float ) : Float {
		return (v > 1.0) ? 1.0 : ((v < 0.0) ? 0.0 : v);
	}

	inline function clamp2( v : Float ) : Float {
		return (v > 1.0) ? 1.0 : ((v < -1.0) ? -1.0 : v);
	}

	static var AS3_DATA = "s238:EAAuAAAAAAgAA1NmeAtmbGFzaC5tZWRpYQVTb3VuZAZPYmplY3QMZmxhc2guZXZlbnRzD0V2ZW50RGlzcGF0Y2hlcgUWARYDGAIWBgAFBwECBwIEBwEFBwQHAwAAAAAAAAAAAAAAAAABAQIIAwABAAAAAQIBAQQBAAMAAQEFBgPQMEcAAAEBAQYHBtAw0EkARwAAAgIBAQUX0DBlAGADMGAEMGACMGACWAAdHR1oAUcAAA";
	static var AS3_BYTES : haxe.io.Bytes = null;

	public function buildSWFSound() {
		var rate = switch( sampleRate ) {
			case 22050: 2;
			case 44100: 3;
			default: throw "Unsupported freq "+sampleRate;
		};
		var is16Bits = switch( bitDepth ) {
			case 8: false;
			case 16: true;
			default: throw "Unsupported bits "+bitDepth;
		};
		var stereo = false;
		var bytes = new flash.utils.ByteArray();
		bytes.endian = flash.utils.Endian.LITTLE_ENDIAN;
		reset(true);
		synthWave( bytes, Std.int(_envelopeFullLength) );
		var wave = haxe.io.Bytes.ofData(bytes);

		var swf = new haxe.io.BytesOutput();
		swf.writeString("FWS");
		swf.writeByte(0x09);  // version
		var o = new haxe.io.BytesOutput();
		for( b in [0x78,0x00,0x05,0x5F,0x00,0x00,0x0F,0xA0,0x00,0x00,0x0C] ) // header
			o.writeByte(b);
		o.writeUInt16(1);  // #frames

		// Sandbox
		o.writeUInt16((69 << 6) | 4);
		o.writeUInt30(8);

		// AS3
		if( AS3_BYTES == null )
			AS3_BYTES =  haxe.Unserializer.run(AS3_DATA);
		o.writeUInt16((72 << 6) | 63);
		o.writeUInt30(AS3_BYTES.length);
		o.write(AS3_BYTES);

		// DefineSound tag
		o.writeUInt16((14 << 6) | 63);
		o.writeUInt30(2 + 1 + 4 + wave.length);
		o.writeUInt16(1);  // sound (character) ID
		o.writeByte((3 << 4) | (rate << 2) | ((is16Bits?1:0) << 1) | (stereo?1:0));
		o.writeUInt30(wave.length >> ((is16Bits?1:0) + (stereo?1:0))); // samples
		o.write(wave);  // data

		// SymbolClass
		var cname = "Sfx";
		o.writeUInt16((76 << 6) | (2 + 2 + cname.length + 1));
		o.writeUInt16(1); // 1 class
		o.writeUInt16(1); // sound ID
		o.writeString(cname);
		o.writeByte(0);

		// ShowFrame
		o.writeUInt16((1 << 6) | 0);

		// end tag
		o.writeUInt16(0);

		// finalize
		var swfbytes = o.getBytes();
		swf.writeUInt30( swfbytes.length + 8 ); // filesize
		swf.write(swfbytes);
		return swf.getBytes();
	}

	#if flash9
	static var cache = new Hash<flash.media.Sound>();
	static var pendingLoaders = new List();
	public static function play( settings : String, ?delay : Float = 0 ) {
		var sound = cache.get(settings);
		if( sound != null ) {
			if( delay == 0 )
				sound.play();
			else
				haxe.Timer.delay(function() sound.play(),Std.int(delay * 1000));
			return;
		}
		var s = new Sfxr();
		s.setSettings(settings);
		var timer = haxe.Timer.stamp();
		var l = new flash.display.Loader();
		pendingLoaders.add(l);
		var domain = new flash.system.ApplicationDomain();
		l.contentLoaderInfo.addEventListener(flash.events.Event.INIT,function(_) {
			pendingLoaders.remove(l);
			var cl : Class<flash.media.Sound> = domain.getDefinition("Sfx");
			cache.set(settings,Type.createInstance(cl,[]));
			delay -= haxe.Timer.stamp() - timer;
			if( delay < 0 ) delay = 0;
			play(settings,delay);
		});
		l.loadBytes(s.buildSWFSound().getData(),new flash.system.LoaderContext(false,domain));
	}
	#end

}
