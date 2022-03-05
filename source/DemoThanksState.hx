package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxTimer;

using StringTools;

class DemoThanksState extends MusicBeatState
{
	var thanks:FlxSprite;
	var streamer:FlxSprite;
	var canproceed:Bool = false;

	var stage:Int = 0;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		thanks = new FlxSprite(-260, 0).loadGraphic(Paths.image('thankyou/fullmodpic'));
		thanks.screenCenter();
		thanks.antialiasing = ClientPrefs.globalAntialiasing;
		thanks.alpha = 0;
		add(thanks);

		streamer = new FlxSprite(-260, 0).loadGraphic(Paths.image('thankyou/sketchystreamer'));
		streamer.screenCenter();
		streamer.antialiasing = ClientPrefs.globalAntialiasing;
		streamer.alpha = 0;
		add(streamer);

		FlxTween.tween(thanks, {alpha: 1}, 3, {ease: FlxEase.linear, onComplete: function(twn:FlxTween)
		{
			canproceed = true;
		}});

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (canproceed && controls.ACCEPT)
		{
			canproceed = false;
			switch(stage)
			{
				case 0:
					FlxTween.tween(thanks, {alpha: 0}, 1, {ease: FlxEase.linear});
					FlxTween.tween(streamer, {alpha: 1}, 3, {ease: FlxEase.linear, onComplete: function(twn:FlxTween)
					{
						stage = 1;
						canproceed = true;
					}});
				case 1:
					MusicBeatState.switchState(new CreditsState());
			}
		}

		super.update(elapsed);
	}

	
}
