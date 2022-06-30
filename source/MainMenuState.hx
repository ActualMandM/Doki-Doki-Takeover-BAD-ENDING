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

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxText>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var optionShit:Array<String> = [
		'story mode',
		'freeplay',
		#if ACHIEVEMENTS_ALLOWED 'awards',
		#end
		'credits',
		'options'
	];

	var textShit:Array<String> = [
		'Story Mode',
		'Freeplay',
		#if ACHIEVEMENTS_ALLOWED 'Achievements',
		#end
		'Credits',
		'Options'
	];

	public static var firstStart:Bool = true;
	var focused:Bool = true;

	var funnyTimer:FlxTimer;
	var logo:FlxSprite;
	var logoBl:FlxSprite;
	var vignette:FlxSprite;
	var oof:FlxSprite;
	var backdrop:FlxBackdrop;

	var debugKeys:Array<FlxKey>;

	override function create()
	{
		if (!ClientPrefs.storycomplete)
		{
			optionShit.remove('freeplay');
			textShit.remove('Freeplay');
		}
		else
		{
			//I'm making sure it SAVES. Im tired of this dumb game not saving settings
			ClientPrefs.storycomplete = true;
			ClientPrefs.firststart = false;
			ClientPrefs.saveSettings();
		}

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		backdrop = new FlxBackdrop(Paths.image('scrolling_BG'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = ClientPrefs.globalAntialiasing;
		add(backdrop);

		var random:Int = FlxG.random.int(1, 100);
		trace(random);

		if (random == 64)
		{
			//Can't let my child go to waste :)
			var fumo:FlxSprite = new FlxSprite(-100, -250).loadGraphic(Paths.image('Fumo'));
			fumo.screenCenter();
			fumo.x += 100;
			add(fumo);
		}
		else
		{
			var ghostdoki:FlxSprite = new FlxSprite(460, 0).loadGraphic(Paths.image('GhostDokis'));
			ghostdoki.antialiasing = ClientPrefs.globalAntialiasing;
			add(ghostdoki);
		}

		logo = new FlxSprite(-260, 0).loadGraphic(Paths.image('Credits_LeftSide'));
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		add(logo);
		if (firstStart)
			FlxTween.tween(logo, {x: -60}, 1.2, {
				ease: FlxEase.elasticOut,
				onComplete: function(flxTween:FlxTween)
				{
					firstStart = false;
					changeItem();
				}
			});
		else
			logo.x = -60;

		logoBl = new FlxSprite(-160, -40);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);
		if (firstStart)
			FlxTween.tween(logoBl, {x: 40}, 1.2, {
				ease: FlxEase.elasticOut,
				onComplete: function(flxTween:FlxTween)
				{
					firstStart = false;
					changeItem();
				}
			});
		else
			logoBl.x = 40;

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxText = new FlxText(-350, 370 + (i * 50), 0, textShit[i]);
			menuItem.setFormat(Paths.font('riffic.ttf'), 27, FlxColor.WHITE, LEFT);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.setBorderStyle(OUTLINE, 0xFF444444, 2);
			menuItem.ID = i;
			menuItems.add(menuItem);

			if (firstStart)
				FlxTween.tween(menuItem, {x: 50}, 1.2 + (i * 0.2), {
					ease: FlxEase.elasticOut,
					onComplete: function(flxTween:FlxTween)
					{
						firstStart = false;
						changeItem();
					}
				});
			else
				menuItem.x = 50;
		}

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "DDTO BAD ENDING v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		oof = new FlxSprite(0, 0).loadGraphic(Paths.image('DonTabOut'));
		oof.screenCenter();
		oof.alpha = 0.0001;
		add(oof);

		vignette = new FlxSprite(0, 0).loadGraphic(Paths.image('menuvignette'));
		vignette.alpha = 0.6;
		add(vignette);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
		{
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2]))
			{ // It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement()
	{
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		if (!selectedSomethin)
		{
			var ctrl = FlxG.keys.justPressed.CONTROL;

			#if debug
			if (FlxG.keys.justPressed.O)
			{
				trace('unlock all');
				ClientPrefs.storycomplete = true;
				ClientPrefs.firststart = false;
				ClientPrefs.saveSettings();
			}

			if (FlxG.keys.justPressed.P)
			{
				trace('lock all');
				ClientPrefs.storycomplete = false;
				ClientPrefs.firststart = true;
				ClientPrefs.saveSettings();
			}
			#end


			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}
			
			if (ctrl && curSelected == 0)
			{
				openSubState(new GameplayChangersSubstate());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				menuItems.forEach(function(txt:FlxText)
				{
					if (curSelected != txt.ID)
					{
						FlxTween.tween(txt, {alpha: 0}, 1.3, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								txt.kill();
							}
						});
					}
					else
					{
						if (FlxG.save.data.flashing)
						{
							FlxFlicker.flicker(txt, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								goToState();
							});
						}
						else
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								goToState();
							});
						}
					}
				});
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys) && ClientPrefs.storycomplete)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story_mode' | 'story mode':
				PlayState.storyPlaylist = ['STAGNANT', 'MARKOV', 'HOME'];
				PlayState.isStoryMode = true;
				PlayState.storyDifficulty = 0;
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-hard', PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			case 'freeplay':
				MusicBeatState.switchState(new FreeplayState());
			#if MODS_ALLOWED
			case 'mods':
				MusicBeatState.switchState(new ModsMenuState());
			#end
			case 'awards':
				MusicBeatState.switchState(new AchievementsMenuState());
			case 'credits':
				if (FlxG.keys.pressed.G)
				{
					CoolUtil.browserLoad('https://www.youtube.com/watch?v=0MW9Nrg_kZU');
					FlxG.resetState();
				}
				else
					MusicBeatState.switchState(new CreditsState());
			case 'options':
				#if MODS_ALLOWED
				if (FlxG.keys.pressed.M && ClientPrefs.storycomplete)
					MusicBeatState.switchState(new ModsMenuState());
				else
				#end
				MusicBeatState.switchState(new options.OptionsState());
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= optionShit.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = optionShit.length - 1;

		menuItems.forEach(function(txt:FlxText)
		{
			txt.setBorderStyle(OUTLINE, 0xFF444444, 2);

			if (txt.ID == curSelected)
				txt.setBorderStyle(OUTLINE, 0xFFFF0513, 2);

			txt.updateHitbox();
		});
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
	}

	override public function onFocusLost():Void
	{
		trace('we tabbed out');
		if (focused == true)
		{
			focused = false;
			funnyTimer = new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				FlxTween.tween(oof, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			});
		}
		super.onFocusLost();
	}

	override public function onFocus():Void
	{
		trace('we tabbed in');
		if (focused == false)
		{
			funnyTimer.cancel();
			focused = true;
			FlxTween.tween(oof, {alpha: 0.0001}, 0.1, {ease: FlxEase.circOut});
		}
		super.onFocus();
	}
}
