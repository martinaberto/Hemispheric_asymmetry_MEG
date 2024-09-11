%% Script 2: RUN THE EXPERIMENT
% This script will play experiment in a loop

KbStrokeWait;

%% Record 5 min resting state

allgood= config_EyeTracker(0, Calibration_folder, ptb);
HideCursor;

ptb.flip();
ptb.draw(allgood) % display text with instructions for resting state recording
ptb.flip();

KbStrokeWait;

fix_cross= o_ptb.stimuli.visual.FixationCross(); %  fixation cross appears at the center of the script
fix_cross.color= 0;
ptb.draw(fix_cross);
ptb.flip()

ptb.start_eyetracker();

WaitSecs(5*60);

ptb.stop_eyetracker();

ptb.save_eyetracker_data(strjoin(Path_Eye + 'eyetracker_resting.mat'));


%%

% ListenChar(-1)
%
% ptb.setup_screen;
% ptb.setup_audio;
% ptb.setup_trigger;

for run= 1:length(design)

    allgood= config_EyeTracker(run, Calibration_folder, ptb); % calibrate eye movement
    HideCursor;

    ptb.flip();

    ptb.draw(allgood) % display text that everything is good and we can start
    ptb.flip();

    KbStrokeWait; % wait for press

    fix_cross= o_ptb.stimuli.visual.FixationCross(); %  fixation cross appears at the center of the screen
    fix_cross.color= 0;
    ptb.draw(fix_cross);
    ptb.flip()

    [trials,  beeps]= soundstream(design(1,run),design(2,run)); % soundstream function creates randomized list of sound to present

    if run==1
        triggers= repmat([16 32 64], [1, length(trials)/3]); % list of triggers (only created once at first iteration, because it is the same everytime)
    end

    starting_trigger=  design(3,run);

    ptb.prepare_trigger(starting_trigger, 0, false);

    p=2; % play first sound and first trigger after 2 seconds from starting trigger and then every 0.5 secs

    for s= 1:length(trials)

        excerpt = o_ptb.stimuli.auditory.Wav(strjoin(sounds_path + trials(s))); % load sound excerpt
        excerpt.rms= 0.01;

        ptb.prepare_audio(excerpt, p, s >1); % put it in the buffer; retain the preceeding audio (excluding for the first sound)

        ptb.prepare_trigger(triggers(s), p, true); % put also trigger in the buffer

        p= p+0.5; % play one sound and one trigger every 0.5 s; so at every iteration, p increases of 0.5

    end

    % beeps will occur randomely between 2s and 106s after the first stimulus.
    % the variable "beeps" tells us how many beeps there will be (up to 2) and when they occur (in seconds)

    for n= 1:length(beeps)

        ptb.prepare_audio(BEEP_1, beeps(n), true); % put beep sound that I had created in script s01 in the buffer
        ptb.prepare_trigger(8, beeps(n), true); % prepare trigger to signal the beep occureance

    end

    % schedule sounds and triggers
    ptb.schedule_audio;
    ptb.schedule_trigger;

    ptb.start_eyetracker(); % start acquiring eye movements 

    ptb.play_without_flip; % play sounds and triggers

    KbStrokeWait; % wait for press
    KbStrokeWait; % this again, so I have to press space twice for it to start. In case someone presses accidentally

    ptb.stop_eyetracker(); % ending eyetracker acquisition

    save_this_run; % this calls another script where it saves eyetracker data and list of presented stimuli
    % It will also display a screen saying the run is over

end

% 2. At the end, display text to tell participant it is over

WaitSecs(2);
ptb.flip();

Inst= o_ptb.stimuli.visual.Text('The Experiment is over. \n\n Thank you for your collaboration!');
Inst.font= 'Helvetica';
Inst.size= 40;
Inst.vspacing= 1.2;
ptb.draw(Inst)
ptb.flip();

KbStrokeWait;
sca; close all; clc; ListenChar(0); ShowCursor;

% THE END