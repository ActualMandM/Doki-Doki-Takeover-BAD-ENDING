package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxCamera;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Exit to Menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var bg:FlxSprite;
	var logo:FlxSprite;
	var logoBl:FlxSprite;

	var levelInfo:FlxText;
	var levelDifficulty:FlxText;
	var blueballedTxt:FlxText;
	var practiceText:FlxText;
	var chartingText:FlxText;

	var canPress:Bool = true;

	public static var transCamera:FlxCamera;

	public function new(x:Float, y:Float)
	{
		super();

		if (PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Toggle Practice Mode');
			menuItemsOG.insert(3, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length)
		{
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('ghost'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play();

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.antialiasing = ClientPrefs.globalAntialiasing;
		levelInfo.setFormat(CoolUtil.getFont('aller'), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelInfo.borderSize = 1.25;
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		levelDifficulty.setFormat(CoolUtil.getFont('aller'), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelDifficulty.borderSize = 1.25;
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		blueballedTxt = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.antialiasing = ClientPrefs.globalAntialiasing;
		blueballedTxt.setFormat(CoolUtil.getFont('aller'), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		blueballedTxt.borderSize = 1.25;
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.antialiasing = ClientPrefs.globalAntialiasing;
		practiceText.setFormat(CoolUtil.getFont('aller'), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		practiceText.borderSize = 1.25;
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		chartingText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.antialiasing = ClientPrefs.globalAntialiasing;
		chartingText.setFormat(CoolUtil.getFont('aller'), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		chartingText.borderSize = 1.25;
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		logo = new FlxSprite(-260, 0).loadGraphic(Paths.image('Credits_LeftSide'));
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		add(logo);

		FlxTween.tween(logo, {x: -60}, 1.2, {
			ease: FlxEase.elasticOut
		});

		logoBl = new FlxSprite(-160, -40);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, true);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);

		FlxTween.tween(logoBl, {x: 40}, 1.2, {
			ease: FlxEase.elasticOut
		});

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:FlxText = new FlxText(-350, 370 + (i * 50), 0, menuItems[i]);
			songText.setFormat(CoolUtil.getFont('riffic'), 27, FlxColor.WHITE, LEFT);
			songText.antialiasing = ClientPrefs.globalAntialiasing;
			songText.setBorderStyle(OUTLINE, 0xFF444444, 2);
			songText.ID = i;
			grpMenuShit.add(songText);

			FlxTween.tween(songText, {x: 50}, 1.2 + (i * 0.2), {
				ease: FlxEase.elasticOut
			});
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 2]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			if (difficultyChoices.contains(daSelected))
			{
				var name:String = PlayState.SONG.song.toLowerCase();
				var poop = Highscore.formatSong(name, curSelected);
				PlayState.SONG = Song.loadFromJson(poop, name);
				PlayState.storyDifficulty = curSelected;
				CustomFadeTransition.nextCamera = transCamera;
				MusicBeatState.resetState();
				FlxG.sound.music.volume = 0;
				PlayState.changedDifficulty = true;
				PlayState.chartingMode = false;
				return;
			}

			switch (daSelected.toLowerCase())
			{
				case "resume":
					closeMenu();
				case 'change difficulty':
					menuItems = difficultyChoices;
					regenMenu();
				case 'toggle practice mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "restart song":
					restartSong();
				case 'toggle botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case "exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					if (PlayState.isStoryMode)
					{
						MusicBeatState.switchState(new MainMenuState());
					}
					else
					{
						MusicBeatState.switchState(new FreeplayState());
					}
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;

				case 'back':
					menuItems = menuItemsOG;
					regenMenu();
			}
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if (noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		grpMenuShit.forEach(function(txt:FlxText)
		{
			if (txt.ID == curSelected)
				txt.setBorderStyle(OUTLINE, 0xFFFF0513, 2);
			else
				txt.setBorderStyle(OUTLINE, 0xFF444444, 2);
		});
	}

	function closeMenu()
	{
		// Tweens!
		FlxG.sound.play(Paths.sound('confirmMenu'));
		canPress = false;

		FlxTween.cancelTweensOf(logo);
		FlxTween.cancelTweensOf(logoBl);
		FlxTween.cancelTweensOf(bg);

		FlxTween.cancelTweensOf(levelInfo);
		FlxTween.cancelTweensOf(levelDifficulty);
		FlxTween.cancelTweensOf(blueballedTxt);
		FlxTween.cancelTweensOf(practiceText);

		for (i in 0...grpMenuShit.length)
		{
			FlxTween.cancelTweensOf(grpMenuShit.members[i]);
			FlxTween.tween(grpMenuShit.members[i], {x: -350}, 0.5, {ease: FlxEase.quartInOut});
		}

		FlxTween.tween(logo, {x: -500}, 0.7, {ease: FlxEase.quartInOut});
		FlxTween.tween(logoBl, {x: -500}, 0.7, {ease: FlxEase.quartInOut});
		FlxTween.tween(bg, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});

		FlxTween.tween(levelInfo, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelDifficulty, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(blueballedTxt, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(practiceText, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});

		new FlxTimer().start(0.6, function(tmr:FlxTimer)
		{
			close();
		});
	}

	function regenMenu():Void
	{
		for (i in 0...grpMenuShit.members.length)
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);

		for (i in 0...menuItems.length)
		{
			var songText:FlxText = new FlxText(50, 370 + (i * 50), 0, menuItems[i]);
			songText.setFormat(CoolUtil.getFont('riffic'), 27, FlxColor.WHITE, LEFT);
			songText.antialiasing = ClientPrefs.globalAntialiasing;
			songText.setBorderStyle(OUTLINE, 0xFF444444, 2);
			songText.ID = i;
			grpMenuShit.add(songText);
		}

		curSelected = 0;
		changeSelection();
	}
}