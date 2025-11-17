using Godot;
using System;
using System.Collections.Generic;

public partial class BeatManager : Node
{
	[Export] public AudioStream Music;
	[Export] public float FallTime = 2.2f;       // time for notes to reach hit lane
	[Export] public bool NormalMode = true;        // Enable normal mode (normal notes)
	[Export] public float GlobalOffset = 1.4f;  // in secs [1.4f OG]
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

		//load music if not assigned 
		if (Music == null)
		{
			Music = GD.Load<AudioStream>("res://rhythmgame_folder/rhythmgame_assets/music/Rhythm Hell.wav");
		}
		_musicPlayer.Stream = Music;

		//load the beat map for Rhythm Hell
		LoadRhythmHellBeatMap();

		GD.Print($"BeatManager ready. Waiting to start Music)");
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
			GD.Print($"🎵 Music Started ({(NormalMode ? "Normal" : "Hard")} Mode - {_beatMap.Count} notes)");
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

	private void LoadRhythmHellBeatMap()
	{
		//blue lane notes
		float[] blueTimes = { 2.52533321380615f, 6.55733375549316f, 10.5573337554932f, 14.5040004730225f, 14.6533325195313f, 15.5493324279785f, 15.6986663818359f, 15.9333332061768f, 16.0719993591309f, 19.76266746521f, 22.8666675567627f, 27.2293327331543f, 30.823998260498f, 34.5786674499512f, 34.7173316955566f, 35.0159996032715f, 35.282666015625f, 35.4640014648437f, 35.6453330993652f, 35.9333351135254f, 36.1466682434082f, 36.2533348083496f, 36.3706672668457f, 40.4133346557617f };

		//green lane notes
		float[] greenTimes = { 3.03733329772949f, 7.0586669921875f, 7.28266696929932f, 11.5600002288818f, 11.8053329467773f, 14.9200008392334f, 15.0479991912842f, 15.282666015625f, 15.5813339233398f, 16.296000289917f, 18.8026664733887f, 19.9119995117188f, 20.0826671600342f, 23.2080009460449f, 23.346667098999f, 23.9226673126221f, 24.3279998779297f, 26.792000579834f, 27.7200000762939f, 28.1253326416016f, 31.1759994506836f, 31.858666229248f, 34.8453338623047f, 34.9839981079102f, 35.1546676635742f, 35.3999984741211f, 35.5706680297852f, 35.741333770752f, 35.8693321228027f, 36.0186660766602f, 36.1359985351562f, 36.2533348083496f };

		//red lane notes
		float[] redTimes = { 3.56000022888184f, 7.54933338165283f, 10.7919996261597f, 11.0266664505005f, 14.5040004730225f, 14.6533325195313f, 15.5600002288818f, 15.7093341827393f, 15.9333332061768f, 16.0826671600342f, 19.0373332977295f, 19.1973331451416f, 19.3893325805664f, 20.274666595459f, 20.4026668548584f, 23.5493324279785f, 23.7093341827393f, 24.1146667480469f, 27.0159996032715f, 27.9333332061768f, 31.5280006408691f, 32.231999206543f };

		//yellow lane notes
		float[] yellowTimes = { 4.07199983596802f, 8.06133346557617f, 12.0613334655762f, 26.5893333435059f, 27.4639995574951f };

		// Normal mode
		int step = 1; //default is 1

		AddNotes(blueTimes, "blue", step);
		AddNotes(greenTimes, "green", step);
		AddNotes(redTimes, "red", step);
		AddNotes(yellowTimes, "yellow", step);

		//Sort by time so notes spawn in order
		_beatMap.Sort((a, b) => a.time.CompareTo(b.time));

		GD.Print($"Loaded {_beatMap.Count} notes for Rhythm Hell");
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