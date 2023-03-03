package data;

enum CitizenObjective
{
	BE_A_GHOUL;
	BANK_THIEF(toolKey:String);
	ASSEMBLE_TOOL(key:String);
	WALKER(dist:Int);
	CITIZEN_BAN(uid:Int);	
	INFECT_CITIZEN(uid:Int);
	AGRESSION(uid:Int);
}

enum CityObjective
{
	BUILD_BUILDING(bkey:String);
	SURVIVORS_AT_DAY(survivors:Int, day:Int);
	MAP_EXPLORATION(percent:Float);
	EVOLUTION(bkey:String, level:Int);
}
