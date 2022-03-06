package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FlashingState extends MusicBeatState
{
	var warnText:FlxText;

	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width, "Hey!\n
			We recommend you to beat the festival week!\n
			Press ENTER to go to DDTO's download page.", 32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			FlxTween.tween(warnText, {alpha: 0}, 1, {
				onComplete: function(twn:FlxTween)
				{
					// TODO: change URL based on if the build is going on GB or GJ
					CoolUtil.browserLoad('https://gamebanana.com/mods/47364');
					TitleState.hasPassedFlashing = true;
					MusicBeatState.switchState(new TitleState());
				}
			});
		}

		super.update(elapsed);
	}
}
