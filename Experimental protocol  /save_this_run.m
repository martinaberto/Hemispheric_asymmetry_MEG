%% Part 3 SAVE DATA and INFO 
% 1. Save eye tracker data
% 2. Save list of stimuli presented in this run

% save eye movements data
ptb.save_eyetracker_data(strjoin(Path_Eye + 'eyetracker_run_'+ run+ '.mat'));

% save list of stimuli that were presented in this run
save(strjoin(Path_Data + "run" + string(run)+ "_" ...
    + experiment(design(1,run))+ string(design(2,run))+ ".mat"), 'trials', 'beeps');

clearvars trials;

if run~= length(design)
    
    line1= 'This session is over! ';
    line2= '\n\n We hope everything was fine! Let us know if you need a break.';
    line3= '\n\n Thank you for your patience!';

    Instructions= o_ptb.stimuli.visual.Text([line1 line2 line3]);
    Instructions.font= 'Helvetica';
    Instructions.size= 40;
    Instructions.color= 0;
    Instructions.destination_rect= [0 0 1710 1160];
    Instructions.vspacing= 1.2;
    ptb.draw(Instructions)
    ptb.flip();

    KbStrokeWait;
    clearvars line* Instructions

end
