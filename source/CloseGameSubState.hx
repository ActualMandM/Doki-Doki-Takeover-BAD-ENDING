package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class CloseGameSubState extends MusicBeatSubstate
{
	var curSelected:Int = 1;
	var selectGrp:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

	public function new()
	{
		super();

		var background:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		background.alpha = 0.5;
		add(background);

		var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image('popup_blank'));
		box.antialiasing = ClientPrefs.globalAntialiasing;
		box.updateHitbox();
		box.screenCenter();
		add(box);

		var text:FlxText = new FlxText(0, box.y + 76, box.frameWidth * 0.95, 'Are you sure you want to\nexit the game?');
		text.setFormat(CoolUtil.getFont('aller'), 32, FlxColor.BLACK, FlxTextAlign.CENTER);
		text.screenCenter(X);
		text.antialiasing = ClientPrefs.globalAntialiasing;
		add(text);

		var textYes:FlxText = new FlxText(box.x + (box.width * 0.18), box.y + (box.height * 0.65), 0, 'Yes');
		textYes.setFormat(CoolUtil.getFont('riffic'), 48, FlxColor.WHITE, FlxTextAlign.CENTER);
		textYes.antialiasing = ClientPrefs.globalAntialiasing;
		textYes.setBorderStyle(OUTLINE, 0xFFFF0513, 4);
		textYes.ID = 0;

		var textNo:FlxText = new FlxText(box.x + (box.width * 0.7), box.y + (box.height * 0.65), 0, 'No');
		textNo.setFormat(CoolUtil.getFont('riffic'), 48, FlxColor.WHITE, FlxTextAlign.CENTER);
		textNo.antialiasing = ClientPrefs.globalAntialiasing;
		textNo.setBorderStyle(OUTLINE, 0xFFFF0513, 3);
		textNo.ID = 1;

		selectGrp.add(textYes);
		selectGrp.add(textNo);
		add(selectGrp);

		changeItem();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (controls.BACK)
			selectItem();

		if (controls.UI_LEFT_P)
			changeItem(-1);
		if (controls.UI_RIGHT_P)
			changeItem(1);

		if (controls.ACCEPT)
			selectItem(curSelected);
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += huh;

		if (curSelected >= selectGrp.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = selectGrp.length - 1;

		selectGrp.forEach(function(txt:FlxText)
		{
			if (txt.ID == curSelected)
				txt.setBorderStyle(OUTLINE, 0xFFFF0513, 3);
			else
				txt.setBorderStyle(OUTLINE, 0xFF444444, 3);
		});
	}

	function selectItem(selection:Int = 1):Void
	{
		if (selection == 0)
		{
			Sys.exit(0);
		}
		else
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MainMenuState.curSelected = 0;
			MusicBeatState.resetState();
			close();
		}
	}
}
