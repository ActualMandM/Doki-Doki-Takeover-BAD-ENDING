package;

import flixel.addons.display.FlxBackdrop;
#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	var curSelected:Int = 0;
	var isDiffSelect:Bool = false;
	var curDifficulty:Int = 0;

	var sayori:FlxSprite;
	var natsuki:FlxSprite;
	var yuri:FlxSprite;

	var diff:FlxSprite;

	var sayoritween:FlxTween;
	var natsukitween:FlxTween;
	var yuritween:FlxTween;
	var redStatic:FlxSprite;
	var redoverlay:FlxSprite;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var songname:FlxText;
	var diffstuff:FlxText;
	var vignette:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.setDirectoryFromWeek();

		var evilSpace:FlxBackdrop = new FlxBackdrop(Paths.image('bigmonika/Sky', 'doki'));
		evilSpace.velocity.set(-10, 0);
		evilSpace.antialiasing = ClientPrefs.globalAntialiasing;
		add(evilSpace);

		bg = new FlxSprite().loadGraphic(Paths.image('bigmonika/BG', 'doki'));
		bg.setPosition(-239, -3);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		redStatic = new FlxSprite(0, 0);
		redStatic.frames = Paths.getSparrowAtlas('ruinedclub/HomeStatic', 'doki');
		redStatic.antialiasing = ClientPrefs.globalAntialiasing;
		redStatic.animation.addByPrefix('hard', 'HomeStatic', 24);
		redStatic.animation.play('hard');
		redStatic.alpha = 0.001;
		add(redStatic);

		natsuki = new FlxSprite().loadGraphic(Paths.image('freeplay/natsu', 'preload'));
		natsuki.setPosition(37, 0);
		natsuki.antialiasing = ClientPrefs.globalAntialiasing;
		add(natsuki);

		yuri = new FlxSprite().loadGraphic(Paths.image('freeplay/yuri', 'preload'));
		yuri.setPosition(177, 0);
		yuri.antialiasing = ClientPrefs.globalAntialiasing;
		add(yuri);

		sayori = new FlxSprite().loadGraphic(Paths.image('freeplay/sayso', 'preload'));
		sayori.setPosition(107, 0);
		sayori.antialiasing = ClientPrefs.globalAntialiasing;
		add(sayori);


		vignette = new FlxSprite(0, 0).loadGraphic(Paths.image('menuvignette'));
		vignette.alpha = 0.8;
		add(vignette);

		redoverlay = new FlxSprite(0, 0);
		redoverlay.frames = Paths.getSparrowAtlas('ruinedclub/HomeStatic', 'doki');
		redoverlay.antialiasing = ClientPrefs.globalAntialiasing;
		redoverlay.animation.addByPrefix('hard', 'HomeStatic', 24);
		redoverlay.animation.play('hard');
		redoverlay.alpha = 0.001;
		add(redoverlay);



		songname = new FlxText(0, 550, 0, 'hueh', 50);
		songname.screenCenter(X);
		songname.font = CoolUtil.getFont('animal');
		songname.color = 0xFFFFFFFF;
		songname.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
		songname.antialiasing = ClientPrefs.globalAntialiasing;
		add(songname);

		diffstuff = new FlxText(0, 600, 1280, 'hueh', 72);
		diffstuff.font = CoolUtil.getFont('animal');
		diffstuff.color = 0xFFFFFFFF;
		diffstuff.alignment = CENTER;
		diffstuff.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 1);
		diffstuff.antialiasing = ClientPrefs.globalAntialiasing;
		diffstuff.visible = false;
		diffstuff.screenCenter(X);
		add(diffstuff);

		diff = new FlxSprite(453, 580);
		diff.frames = Paths.getSparrowAtlas('freeplay/difficulties', 'preload');
		diff.antialiasing = ClientPrefs.globalAntialiasing;
		diff.animation.addByPrefix('hard', 'Hard', 24);
		diff.animation.addByPrefix('unfair', 'Unfair', 24);
		diff.animation.play('hard');
		diff.updateHitbox();
		diff.visible = false;
		add(diff);

		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 56, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if (curSelected >= songs.length)
			curSelected = 0;

		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");


		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		super.create();
	}

	override function closeSubState()
	{
		changeSelection(0);
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	var instPlaying:Int = -1;

	private static var vocals:FlxSound = null;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2)
		{ // No decimals, add an empty space
			ratingSplit.push('');
		}

		while (ratingSplit[1].length < 2)
		{ // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 3;

		if (rightP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			if (!isDiffSelect)
				changeSelection(-shiftMult);
			else
				changeDiff(1);
		}
		if (leftP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			if (!isDiffSelect)
				changeSelection(shiftMult);
			else
				changeDiff(-1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (!isDiffSelect)
				MusicBeatState.switchState(new MainMenuState());
			else
			{
				isDiffSelect = false;
				diffstuff.visible = false;
				// Hide diff select here
			}
		}

		if (ctrl)
		{
			openSubState(new GameplayChangersSubstate());
		}
		else if (space)
		{
			if (instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}
		else if (accepted)
		{
			if (isDiffSelect)
			{
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				trace(poop);

				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());

				if (FlxG.keys.pressed.SHIFT)
				{
					LoadingState.loadAndSwitchState(new ChartingState());
				}
				else
				{
					LoadingState.loadAndSwitchState(new PlayState());
				}

				FlxG.sound.music.volume = 0;

				destroyFreeplayVocals();
			}
			else
			{
				changeDiff();
				isDiffSelect = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				diffstuff.visible = true;
				//Make difficulty thingie visible here
			}
		}
		else if (controls.RESET)
		{
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length - 1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffstuff.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();

		swapstyle(curDifficulty);

	}

	function swapstyle(hueh:Int)
	{
		redoverlay.alpha = 0.7;
		FlxTween.cancelTweensOf(redoverlay);
		FlxTween.tween(redoverlay, {alpha: 0.0001}, 0.25);
		if (CoolUtil.difficulties[curDifficulty].toLowerCase() == 'unfair' && hueh == 1)
		{
			trace("funny harder moder ");
			redStatic.alpha = 1;
			natsuki.loadGraphic(Paths.image('freeplay/natsuunfair', 'preload'));
			yuri.loadGraphic(Paths.image('freeplay/yuriunfair', 'preload'));
			sayori.loadGraphic(Paths.image('freeplay/saysounfair', 'preload'));
		}
		else
		{
			trace("goku goes supersaiyan ");
			redStatic.alpha = 0.001;
			natsuki.loadGraphic(Paths.image('freeplay/natsu', 'preload'));
			yuri.loadGraphic(Paths.image('freeplay/yuri', 'preload'));
			sayori.loadGraphic(Paths.image('freeplay/sayso', 'preload'));
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if (diffStr != null)
			diffStr = diffStr.trim(); // Fuck you HTML5

		if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1)
						diffs.remove(diffs[i]);
				}
				--i;
			}

			if (diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}

		songname.text = songs[curSelected].songName.toLowerCase();
		songname.screenCenter(X);

		if (sayoritween != null)
		{
			sayoritween.cancel();
			natsukitween.cancel();
			yuritween.cancel();	
		}


		switch (songs[curSelected].songName.toLowerCase())
		{
			case 'stagnant':
				yuritween = FlxTween.tween(yuri, {x: 177}, 0.25);
				natsukitween = FlxTween.tween(natsuki, {x: 37}, 0.25);
				
				yuritween = FlxTween.color(yuri, 0.25, yuri.color, 0xFF444444);
				natsukitween = FlxTween.color(natsuki, 0.25, natsuki.color, 0xFF444444);
				sayoritween = FlxTween.color(sayori, 0.25, sayori.color, 0xFFffffff);
			case 'home':
				yuritween = FlxTween.tween(yuri, {x: 177}, 0.25);
				natsukitween = FlxTween.tween(natsuki, {x: 107}, 0.25);

				yuritween = FlxTween.color(yuri, 0.25, yuri.color, 0xFF444444);
				natsukitween = FlxTween.color(natsuki, 0.25, natsuki.color, 0xFFffffff);
				sayoritween = FlxTween.color(sayori, 0.25, sayori.color, 0xFF444444);
			case 'markov':
				yuritween = FlxTween.tween(yuri, {x: 107}, 0.25);
				natsukitween = FlxTween.tween(natsuki, {x: 37}, 0.25);

				yuritween = FlxTween.color(yuri, 0.25, yuri.color, 0xFFffffff);
				natsukitween = FlxTween.color(natsuki, 0.25, natsuki.color, 0xFF444444);
				sayoritween = FlxTween.color(sayori, 0.25, sayori.color, 0xFF444444);
			default:
				yuritween = FlxTween.tween(yuri, {x: 177}, 0.25);
				natsukitween = FlxTween.tween(natsuki, {x: 37}, 0.25);

				yuritween = FlxTween.color(yuri, 0.25, yuri.color, 0xFF444444);
				natsukitween = FlxTween.color(natsuki, 0.25, natsuki.color, 0xFF444444);
				sayoritween = FlxTween.color(sayori, 0.25, sayori.color, 0xFF444444);
		}

	}

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if (this.folder == null)
			this.folder = '';
	}
}