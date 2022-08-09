
class frutibandas.Time {

    public var hours   : Number;
    public var minutes : Number;
    public var seconds : Number;
    
    public function Time(h:Number, m:Number, s:Number)
    {
        this.hours   = h;
        this.minutes = m;
        this.seconds = s;
    }

    public function toString() : String
    {
        var result : String = "";
        
        if (this.hours < 10) result += "0";
        result += string(this.hours) + ":";

        if (this.minutes < 10) result += "0";
        result += string(this.minutes) + ":";
        
        if (this.seconds < 10) result += "0";
        result += string(this.seconds);

        return result;
    }

    public static function fromMillis( millis : Number ) : frutibandas.Time 
    {
        var rest    : Number = millis;
        var hours   : Number = Math.floor( rest / 3600000 );
        rest = rest - (hours * 3600000);
        var minutes : Number = Math.floor( rest / 60000 );
        rest = rest - (minutes * 60000);
        var seconds : Number = Math.round( rest / 1000 );
        rest = rest - (seconds * 1000);

        return new Time(hours, minutes, seconds);
    }
}

