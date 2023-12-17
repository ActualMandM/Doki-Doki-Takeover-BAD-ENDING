package;

import flixel.FlxSprite;
import sys.FileSystem;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	private var isAnimated:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(char:String)
	{
		if (this.char != char)
		{
			var name:String = 'icons/' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE))
				name = 'icons/icon-' + char; // Older versions of psych engine's support
			if (!Paths.fileExists('images/' + name + '.png', IMAGE))
				name = 'icons/icon-bf-old'; // Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			isAnimated = false;
			flipX = false;
			var xmlPath:String = 'images/' + name + '.xml';
			var path:String = '';
			#if MODS_ALLOWED
			path = Paths.modFolders(xmlPath);
			if (!FileSystem.exists(path))
				path = Paths.getPreloadPath(xmlPath);
			if (FileSystem.exists(path))
				isAnimated = true;
			#else
			path = Paths.getPreloadPath(xmlPath);
			if (Assets.exists(path))
				isAnimated = true;
			#end

			trace(isAnimated);

			loadGraphic(file); // Load stupidly first for getting the file size
			if (!isAnimated)
			{
				loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); // Then load it fr
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
				updateHitbox();

				animation.add(char, [0, 1], 0, false, isPlayer);
				animation.play(char);
			}
			else
			{
				frames = Paths.getSparrowAtlas(name);
				animation.addByPrefix('idle', 'idle', 24, true);
				animation.addByPrefix('losing', 'losing', 24, true);
				animation.play('idle');
				flipX = isPlayer;
			}
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if (char.endsWith('-pixel'))
			{
				antialiasing = false;
			}
		}
	}

	public function updateIconAnim(losing:Bool)
	{
		if (isAnimated)
			animation.play((losing ? 'losing' : 'idle'));
		else
			animation.curAnim.curFrame = (losing ? 1 : 0);
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String
	{
		return char;
	}
}
