package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;

	private var idleAnim:String;
	private var textureLoaded:String = null;

	private var ddtoStyled:Bool = true;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);

		var skin:String = 'NOTE_splashes_doki';

		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
		{
			skin = PlayState.SONG.splashSkin;
			ddtoStyled = false;
		}
		
		loadAnims(skin);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0, noteStyle:String = '')
	{
		if (texture == null)
		{
			if (noteStyle != null)
			{
				switch (noteStyle)
				{
					case 'poem':
						texture = 'poemUI/noteSplashes';
						ddtoStyled = false;
					default:
						texture = 'NOTE_splashes_doki';
						ddtoStyled = true;
				}
			}
			else
			{
				texture = 'NOTE_splashes_doki';
				ddtoStyled = true;
			}

			if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			{
				texture = PlayState.SONG.splashSkin;
				ddtoStyled = false;
			}
		}

		if (textureLoaded != texture)
			loadAnims(texture);

		if (ddtoStyled)
		{
			setPosition(x - 25, y - 25);
			alpha = 1;
			flipX = FlxG.random.bool(0.5);
			angle = FlxG.random.float(0, 45);
			offset.set(width * 0.3, height * 0.3);
		}
		else
		{
			setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
			alpha = 0.6;
			colorSwap.hue = hueColor;
			colorSwap.saturation = satColor;
			colorSwap.brightness = brtColor;
			offset.set(10, 10);
		}

		var animNum:Int = 2 /* FlxG.random.int(1, 2)*/;
		animation.play('note' + note + '-' + animNum, true);

		if (animation.curAnim != null)
			animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String)
	{
		frames = Paths.getSparrowAtlas(skin);

		for (i in /*1*/ 2...3)
		{
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
		{
			if (animation.curAnim.finished)
				kill();
		}

		super.update(elapsed);
	}
}
