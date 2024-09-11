 %% Script 1: SETUP: "preparation" script

% This script is divided in 3 parts:
% 1. Set Path; Get and save participant info; Randomize blocks
% 2. Configure o_PTB
% 3. Display Instruction (text); Create the target sound (BEEP) and play it 3 times (for participant)

clear all global;
restoredefaultpath

%% Part 1

% 1. Set the path to what you will need
% 2. Get participants information and save them in a table
% 3. Randomize runs order for this participant and create a "design matrix"
%    (in case the exp crashes, half way, you can start from there
% 4. Create folders in which you store results
% 5. Save table with participant info and design in the folder

% 1. Set the path

% Locate o_ptb and add it to your path

addpath('/home/mb_auditory_statistics/o_ptb/');

% Locate your stimuli
sounds_path= fullfile(fileparts(pwd), 'Excerpts_exp', filesep);

% Locate and initialize Psychtoolbox / Configure o_ptb
o_ptb.init_ptb('/home/mb_auditory_statistics/Psychtoolbox-3/Psychtoolbox/'); % initialize Psychtoolbox
PsychDefaultSetup(1);

% 2.  Collect participant's information

% Open Prompt window
info= string(inputdlg({'Participant number (i.e. 01, 02, 03...)', ...
    'Age (y)', 'Sex (F; M)', 'Handness (R; L)'},'Auditory Statistics MEG', [1 70; 1 70; 1 70; 1 70]));

% Create a table with participant's information

Subj= info(1);
Age= info(2);
Sex= info(3);
Handness= info(4);

sub_info= table(Subj, Age, Sex, Handness);

% 3. Create a design matrix
experiment= ["LOCAL", "STATISTICS"]; % two version of the experiment
design= [ones(1,3),2*ones(1,3); repmat([40 209 478], [1,2]); [48, 56, 80, 88, 96, 104]]; % 2 experiment (1 or 2); 3 durations (40, 209, 478ms);
design = design(:,randperm(size(design,2))); % randomize the order of the columns to randomize blocks across participants

% 4. Create Folders in which you save the data

% Folder for Presentation info
Path_Data= fullfile(fileparts(pwd), 'Data', Subj, filesep);

% Folder for Eyetracker data
Path_Eye= fullfile(Path_Data, 'Eyetracker', filesep);
Calibration_folder= fullfile(Path_Eye, 'Calibration', filesep);

% prevent matlab to overwrite data if I accidentally put wrong subject's number
if ~isfolder(Path_Data)
    mkdir(Path_Data)
    mkdir(Path_Eye)
    mkdir(Calibration_folder);
else
    Path_Data= fullfile(fileparts(pwd), 'Data', strjoin(Subj +'_2') , filesep);
    Path_Eye= fullfile(Path_Data, 'Eyetracker', filesep);
    Calibration_folder= fullfile(Path_Eye, 'Calibration', filesep);
    
    mkdir(Path_Data);
    mkdir(Path_Eye);
    mkdir(Calibration_folder);
end

% 5. Write table with subj info in subj folder and save design matrix
writetable(sub_info, strjoin(Path_Data + "Subj_info.csv"));
save(strjoin(Path_Data + "exp_order.mat"), 'design');

clearvars("Subj", "Age", "Sex", "Handness", "info", "sub_info");

%% Part 2
% Configuration of o_ptb

ptb_cfg = o_ptb.PTB_Config(); % initialize o_ptb

% Screen
ptb_cfg.fullscreen = true;
ptb_cfg.hide_mouse = true; %false;

ptb_cfg.real_experiment_sbg_cdk(true);

ptb = o_ptb.PTB.get_instance(ptb_cfg);

% Setup Screen, Response, audio, and triggers (default)

ListenChar(-1)

ptb.setup_screen;
ptb.setup_audio;
ptb.setup_trigger;

%% Part 3

% 1. Display the instructions
% 2. Have participants listen to the target sound (BBEP) 3 times

% Instruction screen

HideCursor;

line1= 'Welcome!';
line2= '\n Thank you for participating in this study!';
line3= '\n\n This experiment will be divided in small sessions, lasting few minutes each.';
line4= '\n\n In each session, you will hear different sequences of sounds.';
line5= '\n Embedded in every sound sequences, you will hear some "BEEPs".';
line6= '\n\n  Your task consists of pressing the yellow button whenever you hear one BEEP.';
line7= '\n\n Now you will listen to the BEEPs three times.';
line8= '\n Remember this sound, as it will be your target throughout the experiment.';
line9= '\n\n Press a button to listen.';

Instructions= o_ptb.stimuli.visual.Text([line1 line2 line3 line4 line5 line6 line7 line8 line9]);
Instructions.font= 'Helvetica';
Instructions.size= 40;
Instructions.vspacing= 1.2;

ptb.draw(Instructions)
ptb.flip();

KbStrokeWait;

ptb.flip();

WaitSecs(1);

% 2. Create and play the beep

% Create Beep/Pure tone with a frequency of 2000Hz
fs= 20000; % samping rate of sound textures
BEEP= (MakeBeep(2000,0.05,fs));
BEEP= (BEEP./rms(BEEP)*0.2);

% Make people listen to the target sound 3 times
BEEP_1= o_ptb.stimuli.auditory.FromMatrix(BEEP, fs);

% here play beeps 3 times, once every 3 seconds
for b=1:3 
    
    ptb.prepare_audio(BEEP_1, (b-1)*3, b>1);
    
end

WaitSecs(1);
ptb.schedule_audio;
ptb.play_without_flip;

WaitSecs(3);

clearvars Instructions line* BEEP fs

ptb.flip();

% end of preparation script