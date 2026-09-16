//Heliomatrix

(
Server.local.options.sampleRate = 48000;
s.options.outDevice = "sonible ml:1    ";
s.options.numWireBufs = 64 * 1024;
s.options.memSize = 8192 * 256;
s.reboot;
)

SerialPort.devices

(
SerialPort.closeAll;
~port = SerialPort.new("/dev/tty.usbserial-1120", 115200);
~arduinoData = [];
~values = [];
CmdPeriod.doOnce({Tdef(\getData).stop;SerialPort.closeAll;});
)

(
~bus = Bus.audio(s, 2);

(
SynthDef(\reverb, {
	arg distBlend = 0, size = 20, revtime = 5, revBlend = 0.2, lo = -1, hi = 1, cutoff = 100;
	var sig, clip;
	sig = In.ar(~bus, 2);
	//sig = sig.blend(Wrap.ar(sig, -0.15, 0.15), distBlend);
	//clip = Clip.ar(sig, -0.15, 0.15);
	sig = LPF.ar(sig, cutoff, 1, 0);
	sig = sig.blend(GVerb.ar(sig, size, revtime), revBlend) ! 2;
	Out.ar(0, sig);
}).add;
)
)


~reverbBus = Synth(\reverb);
~reverbBus.stop;

MIDIClient.init;
MIDIIn.connectAll;

(

MIDIdef.cc(\cutoffControl, {
	arg val, num, chan, src;
	var cutValue = val.linlin(0, 127, 100, 2000);
	~reverbBus.set(\cutoff, cutValue);
}, 100);

/*MIDIdef.cc(\blendControl, {
	arg val, num, chan, src;
	var blendValue = val.linlin(0, 127, 0.0, 0.9);
	~reverbBus.set(\revBlend, blendValue);
}, 100);*/

MIDIdef.cc(\revtimeControl, {
	arg val, num, chan, src;
	var revtimeVal = val.linlin(0, 127, 0.1, 10.0);
	~reverbBus.set(\revtime, revtimeVal);
}, 101);

MIDIdef.cc(\distControl, {
	arg val, num, chan, src;
	var distVal = val.linlin(0, 127, 0, 1);
	~reverbBus.set(\distBlend, distVal);
}, 102);
)

(
SynthDef(\synthi, {
	arg gate = 0, att = 0.1, rel = 0.1, freq = 0, amp, cutoff = 800;
    var sig, env;
	env = EnvGen.ar(Env.asr(att, 1, rel), gate, doneAction: 2);
	sig = SinOsc.ar(freq * (1..20), 0, amp.lag(1) / ((1..20)));
	sig = sig * env;
	sig = Splay.ar(sig, 1, 1);
    sig = LPF.ar(sig, cutoff.lag(0.1), 0.1);
    Out.ar(~bus, sig);
}).add;
~synths = nil ! 128;
)

(
Tdef(\updateScale, {
    loop {
        ~scales = (
            major: [48 + ~o2, 60 + ~o1] +.x [
                0 + ~a,
                2 + ~b,
                4 + ~c,
                5 + ~d,
                7 + ~e,
                9 + ~f,
                11 + ~g
			] ++ [72 + ~a + ~o1] ++ [74 + ~b + ~o1],
			minor: [48 + ~o2, 60 + ~o1] +.x [
				0 + ~a,
                2 + ~b,
                3 + ~c,
                5 + ~d,
                7 + ~e,
                8 + ~f,
                10 + ~g
            ] ++ [72 + ~a + ~o1] ++ [74 + ~b + ~o1],
        );
		~currentScale = ~scales[~scaletype];
        //"~currentScale: %".format(~currentScale).postln;
        0.1.wait;
    }
});

~a = 0; ~b = 0; ~c = 0; ~d = 0; ~e = 0; ~f = 0; ~g = 0; ~o1 = 0; ~o2 = 0
)

// initialisierung
~scaletype = \major;

// starte Skalen
Tdef(\updateScale).play;
Tdef(\updateScale).stop


//////////////////////////////////////////////
// MIDI-Setup
MIDIClient.init;
MIDIIn.connectAll;

(
MIDIFunc.cc({ |val, num, chan, src|
    if (num == 1, {
        ~scaletype = \major;
    });
    if (num == 2, {
        ~scaletype = \minor;
    });
    /*if (num == 3, {
        ~currentScale = ~scales[\pentatonic];
    });
    if (num == 4, {
        ~currentScale = ~scales[\custom];
    });*/
	if (num == 10, {
        ~a = -1;
    });
	if (num == 11, {
        ~a = 0;
    });
	if (num == 12, {
        ~a = 1;
    });
	if (num == 13, {
        ~b = -1;
    });
	if (num == 14, {
        ~b = 0;
    });
	if (num == 15, {
        ~b = 1;
    });
	if (num == 16, {
        ~c = -1;
    });
	if (num == 17, {
        ~c = 0;
    });
	if (num == 18, {
        ~c = 1;
    });
	if (num == 19, {
        ~d = -1;
    });
	if (num == 20, {
        ~d = 0;
    });
	if (num == 21, {
        ~d = 1;
    });
	if (num == 22, {
        ~e = -1;
    });
	if (num == 23, {
        ~e = 0;
    });
	if (num == 24, {
        ~e = 1;
    });
	if (num == 25, {
        ~f = -1;
    });
	if (num == 26, {
        ~f = 0;
    });
	if (num == 27, {
        ~f = 1;
    });
	if (num == 28, {
        ~g = -1;
    });
	if (num == 29, {
        ~g = 0;
    });
	if (num == 30, {
        ~g = 1;
    });
	if (num == 31, {
        ~o1 = 0;
		~o2 = 0;
    });
	if (num == 32, {
        ~o1 = 12;
		~o2 = -12
    });
	if (num == 33, {
        ~o1 = 0;
		~o2 = 0
    });
	if (num == 34, {
        ~o1 = -12;
		~o2 = -12
    });
	if (num == 35, {
        ~o1 = 0;
		~o2 = 0
    });
	if (num == 36, {
        ~o1 = 12;
		~o2 = 12
    });
});
)
//////////////////////////////////////////////

(
Tdef(\getData, {
	~arduinoData = [];
	~values = [];
	loop{
		var data;
		data = ~port.read;
		case
		{data == nil} {nil}

		{(data.asAscii.isAlpha.not) && (data.asAscii.isPrint)}
		{~arduinoData = ~arduinoData.add(data.asAscii.asString)}

		{(data.asAscii.isAlpha)}
		{
			~values = ("[".catList(~arduinoData)++"]").interpret;
			~arduinoData = [];
		}

		{true}{nil};
	}
}).play;
)

~values;
~values.size;

(
Window.closeAll;
w = Window.new(bounds: Rect(380, 1580, 420, 260)).front;
~views = 128.collect { arg n;
	var row = n div: 16;
	var col = n % 16;
	CompositeView(w, Rect(10 + (col * 25), 10 + (row * 30), 25, 25))
		.background_(Color.gray(0.5));
};
)

(
Tdef(\changeColors, {
    loop{
        ~views.do{
            arg view, index;
            var grayVal, trig, amp, cutoff, trigcutoff;
            grayVal = ~values[index].linlin(50, 600, 0, 1);
            amp = ~values[index].linlin(50, 600, 0.5, 0);
            cutoff = ~values[index].linlin(50, 600, 6000, 800);
            trig = (~values[index] < 590).if {1} {0};
            view.background_(Color.gray(grayVal));

            (trig == 1).if {
                ~synths[index].isNil.if {
                    var scaleFreqs = ~currentScale.collect { |note| note.midicps };
                    var diffPerRow = 1 / 16;
                    var transposedFreqs = scaleFreqs.collect { |freq| freq - (index * diffPerRow) };
					//var transposedFreqs = scaleFreqs.collect { |freq| freq + (index * diffPerRow) };
                    var selectedFreq = transposedFreqs[index % transposedFreqs.size];

					//var selectedFreq = (((0..7)/8).collect { |n| ~currentScale + n }).flat.collect;
					//"~currentFreq: %".format(selectedFreq).postln;
                    ~synths[index] = Synth(\synthi, [gate: 1, freq: selectedFreq])
                }{
                    ~synths[index].set(\amp, amp, \cutoff, cutoff)
                }
            }{
                ~synths[index].set(\gate, 0);
				~synths[index] = nil;
            }
        };
        0.1.wait;

    }
}).play(AppClock);
)


Tdef(\changeColors).stop


262.0630653006 - 130.8127826503;

269.0630653006 - 137.8127826503;
