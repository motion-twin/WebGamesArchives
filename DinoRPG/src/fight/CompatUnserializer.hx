package fight;
import Fight;

class CompatUnserializer extends haxe.Unserializer {

	inline static function e( v : Enum<Dynamic> ) : Enum<Dynamic> {
		return v;
	}

	override function unserializeEnum( edecl : Enum<Dynamic>, tag ) : Dynamic {
		try {
			return super.unserializeEnum(edecl,tag);
		} catch( error : Dynamic ) {
			return switch( edecl ) {
			case e(_Property): cast _PNothing;
			case e(_LifeEffect): cast _LNormal;
			case e(_Effect): cast _EBack;
			case e(_GroupEffect): cast _GrShower;
			case e(_SuperEffect): cast _SFDefault(1); // hope it exists...
			case e(_GotoEffect): cast _GNormal;
			case e(_History): cast _HPause(0);
			case e(_EndBehaviour): cast _EBStand;
			case e(_Status): cast _SSleep;
			case e(_AddFighterEffect): cast _AFStand;
			default: neko.Lib.rethrow(error);
			}
		}
	}

	public static function run(s) : Dynamic {
		return new CompatUnserializer(s).unserialize();
	}

}