typedef Event = {
	var time : Float;
	var event : EventKind;
}

enum EventKind {
	YardDone(i:db.Isle);
	TravelDone(t:db.Travel);
	SearchDone(u:db.GameUser);
	PopUpdate(i:db.Isle);
}
