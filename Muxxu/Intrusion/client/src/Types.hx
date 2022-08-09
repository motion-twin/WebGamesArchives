typedef MCField = {
	> flash.MovieClip,
	field	: flash.TextField,
}

typedef MCFile = {
	> MCField,
	icon	: flash.MovieClip,
	icon2	: flash.MovieClip,
	bg		: flash.MovieClip,
	hit		: flash.MovieClip,
	bar		: MCField,
}

typedef MCNode = {
	> MCField,
	base	: flash.MovieClip,
	shield	: flash.MovieClip,
	sicon	: flash.MovieClip,
}

typedef TargetMC = {
	> flash.MovieClip,
	c1	: flash.MovieClip,
	c2	: flash.MovieClip,
	c3	: flash.MovieClip,
}

typedef HistoryLine = {col:Int,str:String};

enum AnimType {
	A_PlayFrames;
	A_FadeIn;
	A_FadeOut;
	A_FadeRemove;
	A_Text;
	A_HtmlText;
	A_EraseText;
	A_Delete;
	A_Shake;
	A_Blink;
	A_StrongBlink;
	A_Connect;
	A_Auth;
	A_Decrypt;
	A_BubbleIn;
	A_Move;
	A_Bump;
	A_BlurIn;
	A_MenuIn;
}

//enum DamageType {
//	D_Overwrite;
//	D_Corrupt;
//	D_Spam;
//}

typedef Antivirus = {
	key		: String,
	diff	: Int,
	minLevel: Int,
	max		: Int,
	desc	: String,
	power	: Int,
}


typedef Anim = {
	mc	: flash.MovieClip,
	spd	: Float,
	x	: Int,
	y	: Int,
	tx	: Int,
	ty	: Int,
	txt	: String,
	t	: Float,
	type: AnimType,
	kill: Bool,
	data: Float,
	cb	: Void->Void,
	fl_killFilters	: Bool,
}

enum AnimFxType {
	AFX_PopUp;
	AFX_Binary;
	AFX_PlayFrames;
	AFX_Spark;
}

typedef AnimFx = {
	type	: AnimFxType,
	mc		: flash.MovieClip,
	dx		: Float,
	dy		: Float,
	gx		: Float,
	gy		: Float,
	timer	: Float,
	data	: Float,
}

//enum FileFamily {
//	F_Music;
//	F_Video;
//	F_AntiVirus;
//	F_Data;
//}

enum EffectType {
	E_SkipAction;
	E_Masked;
	E_Shield;
	E_Immune;
	E_Gathered;
	E_Disabled;
	E_CShield;
	E_Counter;
	E_Revenge;
	E_Weaken;
	E_Encoded;
	E_Exploit;
	E_Copy;
	E_Corrupt;
	E_Dot;
	E_DotLength;
	E_Splash;
	E_Tag;

	E_PackMoney;
	E_PackMana;
	E_PackLife;

	E_Mission;
	E_Target;
}

enum UserEffectType {
	UE_MoveFurtivity;
	UE_Furtivity;
	UE_Charge;
	UE_Shield;
	UE_Combo;

	// effets de virus très spécifiques
	UE_SilentDeath;
	UE_SwitchDeck;
	UE_DamageBurst;
}

enum BarAnim {
	BA_Normal;
	BA_Chaotic;
	BA_Slow;
}


typedef LocalSettings = {
	version		: Int,
	wheelSpeed	: Int,
	shortcuts	: Array<Int>,
}

