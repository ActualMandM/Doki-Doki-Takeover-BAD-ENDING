package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.math.FlxMath;

class AlphabetText extends FlxText
{
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Float = 0;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var isMenuItem:Bool = false;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
		forceX = Math.NEGATIVE_INFINITY;
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
			y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);

			if (forceX != Math.NEGATIVE_INFINITY)
				x = forceX;
			else
				x = FlxMath.lerp(x, (targetY * 20) + 90 + xAdd, lerpVal);
		}

		super.update(elapsed);
	}
}
