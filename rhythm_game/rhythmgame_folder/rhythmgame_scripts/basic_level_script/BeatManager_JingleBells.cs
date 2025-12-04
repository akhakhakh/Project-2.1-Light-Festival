using Godot;
using System;
using System.Collections.Generic;

public partial class BeatManager_JingleBells : Node
{
	[Export] public AudioStream Music;
	[Export] public float FallTime = 2.5f;       // FASTER fall time for 186 BPM (was 2.2f)
	[Export] public bool NormalMode = false;        // Enable normal mode (normal notes)
	[Export] public float GlobalOffset = 1.2f;  // Adjusted offset for faster song
	[Export] public float TimingScale = 1.0f;   // multiplier to fix drift (no change)

	//signal to spawn notes
	[Signal] public delegate void SpawnButtonEventHandler(string buttonColor);

	public enum MusicMode { None, Menu, Gameplay };
	public MusicMode CurrentMode { get; private set; } = MusicMode.None;

	//music player
	private AudioStreamPlayer _musicPlayer;

	//beat map: List of (time, color) pairs
	private List<(float time, string color)> _beatMap = new List<(float time, string color)>();

	//track which notes have been spawned
	private int _nextNoteIndex = 0;

	// Track if music has been started
	private bool _musicStarted = false;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		//create music player
		_musicPlayer = new AudioStreamPlayer();
		AddChild(_musicPlayer);

		//load music - UPDATE THIS PATH to your Jingle Bells audio file
		if (Music == null)
		{
			Music = GD.Load<AudioStream>("res://rhythmgame_folder/rhythmgame_assets/music/Jingle Bells.wav");
		}
		_musicPlayer.Stream = Music;

		//load the beat map for Jingle Bells
		LoadJingleBellsBeatMap();

		GD.Print($"BeatManagerJingleBells ready. Waiting to start Music");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (_nextNoteIndex < _beatMap.Count)
		{
			float currentTime = (float)_musicPlayer.GetPlaybackPosition();
			var (spawnTime, color) = _beatMap[_nextNoteIndex];

			//spawn note early by FallTime so it reaches the lane by beat
			if (currentTime >= spawnTime)
			{
				EmitSignal(SignalName.SpawnButton, color);
				_nextNoteIndex++;
			}
		}
	}

	public void StartMusic()
	{
		if (!_musicStarted)
		{
			_musicPlayer.Play();
			_musicStarted = true;
			GD.Print($"Jingle Bells Started ({(NormalMode ? "Normal" : "Hard")} Mode - {_beatMap.Count} notes)");
		}
	}

	// Public method to stop music (called on game over)
	public void StopMusic()
	{
		if (_musicPlayer != null && _musicPlayer.Playing)
		{
			_musicPlayer.Stop();
			GD.Print("Music stopped - Game Over");
		}
	}

	private void LoadJingleBellsBeatMap()
	{
		//blue lane notes
		float[] blueTimes = { 3.21655321121216f, 5.0509295463562f, 6.96947860717773f, 9.55269813537598f, 11.38707447052f, 13.3172330856323f, 14.5014514923096f, 16.4751472473145f, 19.6011333465576f, 22.0740585327148f, 24.2944679260254f, 25.9140586853027f, 27.1853523254395f, 27.8122901916504f, 29.7018146514893f, 32.134105682373f, 34.7144203186035f, 36.603946685791f, 37.2221755981445f, 39.1204071044922f, 40.9228553771973f, 42.1709289550781f, 44.1852607727051f, 45.4014053344727f, 47.8772354125977f, 49.7638549804688f, 51.0670738220215f, 51.569206237793f, 52.9217681884766f, 54.0972785949707f, 54.7155113220215f, 57.3161468505859f, 59.118595123291f, 61.0835838317871f, 62.9498901367188f, 64.2502059936523f, 66.7144241333008f, 69.2424926757813f, 71.686393737793f, 74.214469909668f, 76.1765518188477f, 78.7452621459961f, 81.0730590820313f, 83.2151031494141f, 85.1684799194336f, 86.3730163574219f, 88.2712478637695f, 89.5309295654297f, 90.8428573608398f, 92.1025390625f, 93.2954635620117f, 94.5116119384766f, 95.7161483764648f, 97.0832214355469f, 98.3835372924805f, 99.6635360717773f, 100.923217773438f };

		//green lane notes
		float[] greenTimes = { 3.80285692214966f, 6.00004529953003f, 7.59931945800781f, 8.9228572845459f, 10.0867576599121f, 12.2404079437256f, 15.099365234375f, 17.6477546691895f, 18.9799995422363f, 21.4993648529053f, 23.0347843170166f, 25.200044631958f, 27.1621322631836f, 28.3898868560791f, 30.8424949645996f, 33.4460334777832f, 35.9421768188477f, 38.4151039123535f, 39.6428565979004f, 42.8849449157715f, 44.1852607727051f, 46.5653076171875f, 47.2154655456543f, 50.4691619873047f, 52.9014511108398f, 55.9955101013184f, 58.5235824584961f, 60.4972801208496f, 61.6902046203613f, 62.9702072143555f, 64.8161926269531f, 66.1165084838867f, 68.5923385620117f, 70.4151000976563f, 72.9751052856445f, 74.8849411010742f, 76.1649398803711f, 78.0631713867188f, 79.3228607177734f, 81.7232208251953f, 83.8449401855469f, 85.8186416625977f, 88.8807678222656f, 90.8428573608398f, 92.6975479125977f, 93.6147384643555f, 94.8424911499023f, 96.0702514648438f, 97.3705673217773f, 98.9930648803711f, 100.900001525879f };

		//red lane notes
		float[] redTimes = { 2.91759634017944f, 5.0509295463562f, 6.39478445053101f, 8.9228572845459f, 11.3986845016479f, 13.9151477813721f, 17.0295238494873f, 20.1235828399658f, 22.7155094146729f, 24.6137409210205f, 26.4365081787109f, 27.1853523254395f, 30.2881183624268f, 32.7842636108398f, 35.3239440917969f, 37.1989555358887f, 41.541088104248f, 45.9238548278809f, 48.4635391235352f, 49.0933799743652f, 51.5256690979004f, 55.3453521728516f, 57.9140586853027f, 59.118595123291f, 61.1155090332031f, 62.3403625488281f, 64.2502059936523f, 67.3326568603516f, 69.5936965942383f, 72.4004058837891f, 75.450927734375f, 77.4014053344727f, 80.4635391235352f, 82.7681198120117f, 85.1249465942383f, 86.982536315918f, 88.2509307861328f, 89.5309295654297f, 90.1288452148438f, 92.0793228149414f, 94.2677993774414f, 95.4491119384766f, 96.6971893310547f, 98.3632202148438f, 99.6432189941406f, 100.400772094727f };

		//yellow lane notes
		float[] yellowTimes = { 4.44140577316284f, 5.70108842849731f, 8.18562316894531f, 10.4466667175293f, 12.7193193435669f, 14.5217685699463f, 15.8017692565918f, 18.2892055511475f, 20.8811340332031f, 23.3453521728516f, 27.1853523254395f, 29.0400447845459f, 31.4926528930664f, 34.0642623901367f, 37.8520164489746f, 40.3133316040039f, 43.471248626709f, 44.1649436950684f, 47.2154655456543f, 49.113697052002f, 52.3151473999023f, 53.4993667602539f, 54.1175956726074f, 56.6456680297852f, 59.7397270202637f, 60.5175971984863f, 61.6698875427246f, 62.3403625488281f, 63.620361328125f, 65.5185928344727f, 67.9944229125977f, 71.0652618408203f, 73.6165542602539f, 75.4712448120117f, 76.8151016235352f, 79.9410858154297f, 82.2021331787109f, 84.5183258056641f, 85.8389587402344f, 87.5253067016602f, 88.9010848999023f, 90.1491622924805f, 91.4814071655273f, 92.7207717895508f, 93.9456253051758f, 95.1617660522461f, 96.4417724609375f, 97.7014541625977f, 99.0017700195313f, 100.345626831055f };

		// Normal mode
		int step = 1; //default is 1

		AddNotes(blueTimes, "blue", step);
		AddNotes(greenTimes, "green", step);
		AddNotes(redTimes, "red", step);
		AddNotes(yellowTimes, "yellow", step);

		//Sort by time so notes spawn in order
		_beatMap.Sort((a, b) => a.time.CompareTo(b.time));

		GD.Print($"Loaded {_beatMap.Count} notes for Jingle Bells (Glee) - 186 BPM!");
	}

	private void AddNotes(float[] times, string color, int step)
	{
		for (int i = 0; i < times.Length; i += step)
		{
			//apply timing scale + global offset
			float spawnTime = (times[i] * TimingScale) - FallTime + GlobalOffset;
			_beatMap.Add((spawnTime, color));
		}
	}
}
