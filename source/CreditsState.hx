package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<AlphabetText>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('credits/bg'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<AlphabetText>();
		add(grpOptions);

		var pisspoop:Array<Array<String>> = [
			// Name - Icon name - Description - Link
			['Team TBD'],
			[
				'SirDusterBuster',
				'duster',
				'Team TBD Lead, Director/Main Artist/Animator',
				'https://twitter.com/SirDusterBuster'
			],
			[
				'Sun Spirit',
				'jorge',
				'Team TBD Lead, Director/Programmer',
				'https://twitter.com/Jorge_SunSpirit'
			],
			[
				'HighPoweredKeyz',
				'hpk',
				'Team TBD Lead, Chromatic Creator',
				'https://twitter.com/HighPoweredArt'
			],
			[
				'M&M',
				'mandm',
				'Programmer',
				'https://linktr.ee/ActualMandM'
			],
			[
				'DuskieWhy',
				'duskie',
				'Shader Programmer',
				'https://twitter.com/DuskieWhy'
			],
			[
				'Matt$', // animal showed this as MATTS
				'matt',
				'Musician - STAGNANT and MARKOV',
				'https://twitter.com/matt_currency'
			],
			[
				'JACKALRUIN',
				'jackie',
				'Musician - Menu Music and HOME',
				'https://www.youtube.com/@JACKALRUIN'
			],
			[
				'Flootena',
				'floot',
				'Charting - MARKOV',
				'https://twitter.com/FlootenaDX'
			],
			[
				'Chompo',
				'chompo',
				'Charting - STAGNANT and HOME',
				'https://twitter.com/MrChompsALot'
			],
			[
				'Crim',
				'crim',
				'Artist',
				'https://twitter.com/ScrimbloCrimbo'
			],
			[
				'Raze',
				'raze',
				'Animator',
				'https://www.youtube.com/channel/UCC550GafkWljtqAq0UDbYeQ'
			],
			[
				'Grand Hammer 6',
				'grand',
				'Artist/Animator',
				'https://twitter.com/GrandHammer6'
			],
			[
				'Ito', 
				'ito', 
				'Background Artist', 
				'https://twitter.com/ItoSaihara_'
			],
			[
				'Carimelle', 
				'carimelle', 
				'Monika VA', 
				'https://twitter.com/carimellevo'
			],
			[''],
			['Additional Credits'],
			[
				'Psych Engine',
				'psych',
				'Shadow Mario, Riveren, bb-panzu, shubs, CrowPlexus, Keoiki, SqirraRNG, EliteMasterEric, PolybiusProxy, Tahir, iFlicky, KadeDev, superpowers04, CheemAndFriends',
				'https://github.com/ShadowMario/FNF-PsychEngine',
			],
			[
				'Funkin\' Crew',
				'psych',
				'ninjamuffin99, PhantomArcade, Kawai Sprite, evilsk8r, EliteMasterEric',
				'https://funkin.me/',
			]
		];

		for (i in pisspoop)
			creditsStuff.push(i);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);

			var optionText:AlphabetText = new AlphabetText(0, 70 * i, 0, creditsStuff[i][0]);
			optionText.setFormat(CoolUtil.getFont('chicken'), 84, FlxColor.BLACK, CENTER);
			optionText.antialiasing = ClientPrefs.globalAntialiasing;
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.yAdd -= 70;

			if (isSelectable)
			{
				optionText.x -= 70;
			}
			else
			{
				optionText.setFormat(CoolUtil.getFont('animal'), 72, FlxColor.BLACK, CENTER);
				optionText.screenCenter(X);
			}

			optionText.forceX = optionText.x;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (isSelectable)
			{
				var icon:AttachedSprite = new AttachedSprite('credits/icons/' + creditsStuff[i][1], 'idle');
				icon.animation.addByPrefix('select', 'select', 24, false);
				icon.xAdd = optionText.width + 10;
				icon.yAdd = -optionText.height / 2;
				icon.sprTracker = optionText;
				icon.scale.set(0.85, 0.85);
				icon.updateHitbox();
				icon.animation.play('idle');
				icon.ID = i;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);

				if (curSelected == -1)
					curSelected = i;
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2.4;
		add(descText);

		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			if (creditsStuff[curSelected][1].toLowerCase() == 'jorge' && FlxG.keys.pressed.G)
				CoolUtil.browserLoad('https://www.youtube.com/watch?v=0MW9Nrg_kZU');
			else
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		do
		{
			curSelected = FlxMath.wrap(curSelected + change, 0, creditsStuff.length - 1);
		}
		while (unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
				item.alpha = (item.targetY == 0 ? 1 : 0.6);
		}

		if (!unselectableCheck(curSelected))
		{
			for (icon in iconArray)
				icon.animation.play(icon.ID == curSelected ? 'select' : 'idle');
		}

		descText.text = creditsStuff[curSelected][2];
	}

	inline private function unselectableCheck(num:Int):Bool
		return creditsStuff[num].length <= 1;
}
