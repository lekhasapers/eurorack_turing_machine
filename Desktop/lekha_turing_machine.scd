s.boot;

"clear".postln
( //random sequence generator
SynthDef(\turingMachine, { |amp = 0.5, gate = 1|

	var trig = Dust.ar(0.1);
	var env = Decay2.ar(trig, 0.3, 0.6); //no clippy
	var freq = IRand(36, 84).midicps;
	var osc = FSinOsc.ar(freq); //ring filter, fast sine wave gen as opposed to sinosc boring!
	var sig = env * osc;
	var reverb = FreeVerb.ar(sig,0.8,0.9,0.5);

    Out.ar(0, reverb ! 2);
}).add;
)


(
var lengths = [2, 3, 6, 12, 16];
var length = lengths.choose;
var sequenceLength = length;
var probability = 0.2; //  probability of change, near-continuously evolving pattern as per the turing machine's 'big knob'
var noteRange = [45, 65];


var generateSequence = { |length|
	Array.fill(length, { noteRange[0].rand2(noteRange[1]) }); //.dup(2)
};

var sequence = generateSequence.(sequenceLength);

var mutateSequence = { |seq, prob|
    seq.collect { |note, i|
        if(prob.coin, { noteRange[0].rand2(noteRange[1]) }, { note })
    };
};


Pbind(
    \instrument, \turingMachine,
    \freq, Pfunc({ |event|
        sequence = mutateSequence.(sequence, probability);
        sequence.wrapAt(event.delta % sequenceLength).midicps;
    }),
    \dur,Pwhite(0.5, 0.75, inf), //modulate dur by Pfsm -- take away from turing parameters?
    \amp, 0.5
).play;
)