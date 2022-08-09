using mt.gx.Ex;
import flash.ui.Keyboard;


enum NMY_TYPE
{
	NT_HANDLE;
	NT_BAD_HANDLE;
	NT_SWARM;
	
	NT_TORCH;
	NT_BLADE;
	
	NT_MASSIVE;
}

typedef K = Keyboard


typedef KdoDef = { mc:ark.gfx.InGamePK, tok:api.AKProtocol.SecureInGamePrizeTokens ,frame:Int} ;
typedef KdoDefSrc = { mc:ark.gfx.InGamePK, tok:api.AKProtocol.SecureInGamePrizeTokens, taken : Bool,frame:Int } ;


enum CharPowers {
	CP_DOUBLE_JUMP;
	CP_WALL_STICK;
	CP_SUPER_JUMP;
	
	CP_KICK;
	CP_CANCEL;
}

typedef RectI = { x:Int, y:Int, width:Int, height:Int };

enum LD_PATTERN{
	LDPage(p:Int);
	LDGen(nb:Int);
}

typedef Vol<T> = mt.flash.Volatile<T>;

enum Restager
{
	RandPlatform( seed : Int );
	FixedPlatform( cx : Int, cy : Int );
	Fixed;
}