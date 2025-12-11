using Godot;
using System;
using System.Collections.Generic;

public partial class BeatManagerMedium : Node
{
	[Export] public AudioStream Music;
	[Export] public float FallTime = 1.5f;       // FASTER fall time for 186 BPM (was 2.2f)
	[Export] public bool NormalMode = false;        // Enable normal mode (normal notes)
	[Export] public float GlobalOffset = 1.2f;  // Adjusted offset for faster song
	[Export] public float TimingScale = 1.0f;   // multiplier to fix drift (no change)

	//signal to spawn notes
	[Signal] public delegate void SpawnButtonEventHandler(string buttonColor);
	
	//Signal for when song finishes
	[Signal] public delegate void SongFinishedEventHandler();
	
	public enum MusicMode { None, Menu, Gameplay };
	public MusicMode CurrentMode { get; private set; } = MusicMode.None;

	//music player
	private AudioStreamPlayer _musicPlayer;

	//beat map: List of (time, color) pairs
	private List<(float time, string color)> _beatMap = new List<(float time, string color)>();

	//track which notes have been spawned
	private int _nextNoteIndex = 0;

	//Track if music has been started
	private bool _musicStarted = false;
	
	//Track if music has been finished
	private bool _songFinished = false;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		//create music player
		_musicPlayer = new AudioStreamPlayer();
		AddChild(_musicPlayer);
		
		//Connect to finished signal
		_musicPlayer.Finished += OnMusicFinished;

		//load music
		if (Music == null)
		{
			Music = GD.Load<AudioStream>("res://rhythmgame_folder/rhythmgame_assets/music/Deck The Halls Christmas.wav");
		}
		_musicPlayer.Stream = Music;

		//load the beat map for Jingle Bells
		LoadDeckTheHallBeatMap();

		GD.Print($"BeatManager_Medium ready. Waiting to start Music");
	}
	
	//Called when the song is finished
	private void OnMusicFinished()
	{
		if (_songFinished)
			return; // Prevent multiple calls
		
		_songFinished = true;
		GD.Print("Song finished! Preparing results...");
		
		// Emit signal to notify other scripts
		EmitSignal(SignalName.SongFinished);
		
		// Wait 2 seconds for final notes to land, then go to results
		GetTree().CreateTimer(2.0).Timeout += GoToResultsScreen;
	}
	
	private void GoToResultsScreen()
	{
		GD.Print("Going to results screen...");
		
		// Change to your results/winning scene
		GetTree().ChangeSceneToFile("res://rhythmgame_folder/rhythmgame_scenes/win_menu/win_scene.tscn");
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
			GD.Print($"Deck The Hall Started - {_beatMap.Count} notes)");
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

	private void LoadDeckTheHallBeatMap()
	{
		//blue lane notes
		float[] blueTimes = { 4.56040811538696f, 6.45863962173462f, 8.24077129364014f, 10.8530158996582f, 12.0488433837891f, 15.5666675567627f, 18.2659854888916f, 20.1758270263672f, 22.1611347198486f, 25.3161449432373f, 29.7453517913818f, 30.8947410583496f, 31.5158729553223f, 32.8597297668457f, 34.7144203186035f, 36.6678009033203f, 38.4383201599121f, 39.7270278930664f, 40.3046264648438f, 42.2551002502441f, 45.3927001953125f, 46.6088447570801f, 47.888843536377f, 51.0554656982422f, 56.0477561950684f, 61.6698875427246f, 63.6958312988281f, 64.8800430297852f, 66.1803665161133f, 68.6242599487305f, 71.7821731567383f, 73.0621795654297f, 75.5786361694336f, 77.4014053344727f, 79.3025360107422f, 81.0817718505859f, 82.7797241210938f, 85.2004089355469f, 86.9593200683594f, 88.3786392211914f, 90.2449417114258f, 91.4727020263672f, 92.7091598510742f, 93.9891586303711f, 95.1849899291992f, 97.1151504516602f, 99.6635360717773f, 102.116142272949f, 104.867706298828f };

		//green lane notes
		float[] greenTimes = { 2.65056705474854f, 3.89863967895508f, 7.02462577819824f, 8.94317436218262f, 10.1825399398804f, 13.9267578125f, 14.5856227874756f, 17.6680717468262f, 19.0032196044922f, 20.8579139709473f, 22.7996826171875f, 24.0361442565918f, 24.7530612945557f, 27.1534233093262f, 28.9761905670166f, 32.134105682373f, 34.09619140625f, 35.3645820617676f, 37.2424926757813f, 41.593334197998f, 43.4828567504883f, 44.7628555297852f, 47.2793197631836f, 47.8975524902344f, 49.0817680358887f, 51.6011352539063f, 55.3975982666016f, 56.6340599060059f, 59.1418151855469f, 61.1155090332031f, 63.0775985717773f, 64.3256683349609f, 66.1803665161133f, 67.5038986206055f, 69.210563659668f, 71.163948059082f, 72.388801574707f, 74.2551040649414f, 76.7744674682617f, 79.8975524902344f, 82.2021331787109f, 83.9407272338867f, 85.8070297241211f, 86.982536315918f, 88.2944641113281f, 90.787712097168f, 92.7091598510742f, 93.3477096557617f, 94.8308868408203f, 96.4330596923828f, 98.3516082763672f, 100.249839782715f, 103.001403808594f, 106.71369934082f };

		//red lane notes
		float[] redTimes = { 5.79687070846558f, 13.264988899231f, 16.9859867095947f, 20.1874370574951f, 23.4411334991455f, 24.6572780609131f, 27.8122901916504f, 32.8800468444824f, 35.9305686950684f, 39.1407241821289f, 40.2930145263672f, 42.246395111084f, 44.1126976013184f, 48.4519271850586f, 50.4691619873047f, 52.9449882507324f, 54.1059875488281f, 57.9895248413086f, 60.537914276123f, 61.6466674804688f, 63.6958312988281f, 64.8684387207031f, 65.5621337890625f, 68.0466690063477f, 70.5544204711914f, 73.6571884155273f, 76.1214065551758f, 78.6814041137695f, 81.7116088867188f, 84.5821762084961f, 86.3614044189453f, 89.5744705200195f, 91.4814071655273f, 92.0793228149414f, 94.0007705688477f, 95.80322265625f, 97.7217712402344f, 100.847755432129f, 105.796508789063f, 107.674423217773f };

		//yellow lane notes
		float[] yellowTimes = { 3.29201793670654f, 5.10317468643188f, 7.66317462921143f, 9.57301616668701f, 11.4393196105957f, 12.6670751571655f, 16.4635372161865f, 17.6477546691895f, 19.6417694091797f, 21.5312919616699f, 25.977912902832f, 26.5555095672607f, 28.4537410736084f, 30.3200454711914f, 31.5158729553223f, 33.4547386169434f, 37.8839454650879f, 40.9983215332031f, 42.9371871948242f, 44.1214065551758f, 46.0428581237793f, 49.7116088867188f, 52.3354644775391f, 53.5312919616699f, 54.7561454772949f, 57.348072052002f, 58.5961456298828f, 59.8122901916504f, 62.4361457824707f, 63.0979156494141f, 64.3459854125977f, 65.5621337890625f, 66.7782745361328f, 69.8839492797852f, 72.4091186523438f, 74.9923324584961f, 78.03125f, 80.4432220458984f, 83.3428115844727f, 86.3614044189453f, 87.5456237792969f, 89.0084838867188f, 90.79931640625f, 92.0473937988281f, 93.3390045166016f, 94.5435409545898f, 96.7726516723633f, 99.0336990356445f, 100.847755432129f, 103.950523376465f, 108.5712890625f };

		// Normal mode
		int step = 1; //default is 1

		AddNotes(blueTimes, "blue", step);
		AddNotes(greenTimes, "green", step);
		AddNotes(redTimes, "red", step);
		AddNotes(yellowTimes, "yellow", step);

		//Sort by time so notes spawn in order
		_beatMap.Sort((a, b) => a.time.CompareTo(b.time));

		GD.Print($"Loaded {_beatMap.Count} notes for Deck The Hall - 100 BPM!");
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
	
	public void Reset()
	{
		_nextNoteIndex = 0;
		_musicStarted = false;

		if (_musicPlayer != null)
			_musicPlayer.Stop();

		_beatMap.Clear();
		LoadDeckTheHallBeatMap();

		GD.Print("BeatManager reset");
	}
}
