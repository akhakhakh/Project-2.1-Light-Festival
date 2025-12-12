using Godot;
using System;
using System.Collections.Generic;

public partial class BeatManagerEasyLevel : Node
{
	[Export] public AudioStream Music;
	[Export] public float FallTime = 2.5f;       // time for notes to reach hit lane
	[Export] public float GlobalOffset = 1.4f;  // in secs [1.4f OG]
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

	// Track if music has been started
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
		
		  //load music if not assigned 
		if (Music == null)
		{
			Music = GD.Load<AudioStream>("res://rhythmgame_folder/rhythmgame_assets/music/WeWishYouAMerryChristmas.wav");
		}
		_musicPlayer.Stream = Music;

		//load the beat map for Rhythm Hell
		LoadEasyWeWishBeatMap();

		GD.Print($"BeatManager ready. Waiting to start Music");
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
			GD.Print($"🎵 Music Started - {_beatMap.Count} notes)");
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

	private void LoadEasyWeWishBeatMap()
	{
		//blue lane notes
		float[] blueTimes = { 0.60566902160645f, 3.68811798095703f, 6.56739234924316f, 8.18988704681396f, 12.2736959457397f, 15.3880729675293f, 16.9786396026611f, 19.399320602417f, 20.9985942840576f, 23.422176361084f, 27.4537410736084f, 28.2316093444824f, 33.0323371887207f, 36.230884552002f, 37.8330612182617f, 42.5989570617676f, 45.0312461853027f, 45.800407409668f, 51.4312477111816f, 54.6530151367188f, 57.0330619812012f, 60.1996841430664f, 65.0845794677734f, 69.8533782958984f, 72.2305221557617f, 73.8414077758789f, 76.2214508056641f, 79.4112930297852f, 82.6011352539063f, 85.0218124389648f, 90.1302032470703f, 92.574104309082f };

		//green lane notes
		float[] greenTimes = { -0.19541954994202f, 2.93056678771973f, 5.83306121826172f, 7.41201782226563f, 11.4116554260254f, 16.1572341918945f, 20.1800899505615f, 24.2319736480713f, 29.0530166625977f, 32.2312469482422f, 34.6316108703613f, 37.0319709777832f, 38.6109313964844f, 43.4319725036621f, 46.6218147277832f, 47.4316101074219f, 52.2323341369629f, 56.2000465393066f, 59.4421310424805f, 62.6319732666016f, 64.2312469482422f, 66.6751480102539f, 68.2221755981445f, 71.4323348999023f, 73.031608581543f, 76.9993209838867f, 78.6537399291992f, 81.8755111694336f, 85.8316116333008f, 89.0417709350586f, 93.4042205810547f };

		//red lane notes
		float[] redTimes = { 1.42707490921021f, 4.33827686309814f, 8.95614528656006f, 10.6628122329712f, 14.6334247589111f, 18.5895233154297f, 21.8519268035889f, 25.0098419189453f, 26.7484359741211f, 31.4649887084961f, 35.4326972961426f, 39.4120178222656f, 41.0519256591797f, 48.2210884094238f, 49.0541038513184f, 53.8316116333008f, 57.8544654846191f, 60.9891624450684f, 69.0755081176758f, 75.4319763183594f, 77.8207244873047f, 81.0308837890625f, 84.2845840454102f, 87.4541015625f, 91.7933349609375f };

		//yellow lane notes
		float[] yellowTimes = { -0.96167802810669f, 2.1933331489563f, 5.09582757949829f, 9.80947875976563f, 13.0631742477417f, 13.9484348297119f, 17.7565078735352f, 22.632698059082f, 25.8544673919678f, 29.8105659484863f, 30.5797271728516f, 33.8653526306152f, 40.2334251403809f, 41.7775497436523f, 44.2011337280273f, 49.863899230957f, 50.6417694091797f, 53.0305213928223f, 55.4947395324707f, 58.7078018188477f, 61.7902526855469f, 63.4533767700195f, 65.9930648803711f, 67.4733352661133f, 70.6312484741211f, 74.6424942016602f, 80.1775512695313f, 83.4225387573242f, 86.6646270751953f, 88.2435836791992f, 90.9951477050781f, 94.1936950683594f };

		// Normal mode
		int step = 1; //default is 1

		AddNotes(blueTimes, "blue", step);
		AddNotes(greenTimes, "green", step);
		AddNotes(redTimes, "red", step);
		AddNotes(yellowTimes, "yellow", step);

		//Sort by time so notes spawn in order
		_beatMap.Sort((a, b) => a.time.CompareTo(b.time));

		GD.Print($"Loaded {_beatMap.Count} notes for Easy We Wish");
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
		LoadEasyWeWishBeatMap();

		GD.Print("BeatManager reset");
	}
}
