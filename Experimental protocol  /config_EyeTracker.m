%% Configure EyeTracker

function allgood= config_EyeTracker(run, Calibration_folder, ptb)
ShowCursor;

if run==0

    line1= 'We are going to track how your eyes move, \n please follow the instructions carefully:';
    line2= '\n when a white and red dot appears, follow it with your eyes';
    line3= '\n\n This procedure will be repeated at the beginning of every session.';

    Instructions= o_ptb.stimuli.visual.Text([line1 line2 line3]);
    Instructions.font= 'Helvetica';
    Instructions.size= 40;
    Instructions.vspacing= 1.2;
    ptb.draw(Instructions)
    ptb.flip();
    WaitSecs(1);
    KbStrokeWait;

end

WaitSecs(1);

ptb.flip();

ptb.setup_eyetracker();  % initialize eyetracker
WaitSecs(1);

ptb.eyetracker_verify_eye_positions(); % verify the position of the eyes in the screen
WaitSecs(1);

WaitSecs(1);

% calibration and save results in Path_Eye folder
run_name = num2str(run);

folder_name= fullfile(Calibration_folder, run_name);

mkdir(folder_name);
ptb.eyetracker_calibrate(folder_name);

WaitSecs(1);

if run== 0

    line1= 'Now we are recording 5 minutes of brain activity, while you are doing nothing.';
    line2= '\n Please, keep your eyes on the black cross.';
    line3= '\n Try to refrain from movements and sit still.';
    line4= '\n\n Thank you for your cooperation!';

    allgood= o_ptb.stimuli.visual.Text([line1 line2 line3 line4]);
    allgood.font= 'Helvetica';
    allgood.size= 40;
    allgood.vspacing= 1.2;

else

    allgood= o_ptb.stimuli.visual.Text(char(strjoin("Alles gut! \n\n We Are ready to start session number " + run_name +...
        " \n\n please, keep your eyes on the black cross")));
    allgood.font= 'Helvetica';
    allgood.size= 40;
    allgood.vspacing= 1.2;

end
end
