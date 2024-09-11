function [trials,  beeps]= soundstream(exp,duration)

% This function creates list of sound excerpts to present for each 'trial'
% and will randomely choose how many beeps there will be (up to 2) and
% where to put them

n= randi(3); % randomely select how many beeps there will be; up to 3
samples_vector= 2:0.1:322;
samples_vector(1:5:length(samples_vector))= []; % make sure they are not completely in synch with the triggers/sounds 
samples_vector= samples_vector(randperm(length(samples_vector)));

beeps= sort(samples_vector(randi(length(samples_vector), 1, n))); % locate them randomely in the 322s stream


trials= [];

for rep=1:6

    load('textures_pairs.mat', 'textures');

    for i= 1:length(textures)

        % Randomized trials order
        vector= 1:length(textures);
        row= randi(length(vector));
        texture= textures(row, :);

        % same starting point (randomely selected)
        n= ceil(5000 /duration);
        start_point= 1:n-1;
        excerpt= randi(length(start_point));

        % select two random exemplars
        exemplars_vector= 1:4;
        ex1= randi(4);
        exemplars_vector(ex1)= [];
        exemplar2_pos= randi(length(exemplars_vector));
        ex2= exemplars_vector(exemplar2_pos);

        repeated= strjoin(string(duration)+ "_ex"+ string(ex1) + "_" + string(excerpt)+ "_"+ string(texture.name1));
        if exp== 1
            novel= strjoin(string(duration)+ "_ex"+ string(ex2) + "_" + string(excerpt)+ "_"+ string(texture.name1));
        elseif exp==2
            novel= strjoin(string(duration)+ "_ex"+ string(ex1) + "_" + string(excerpt)+ "_"+ string(texture.name2));
        end

        trials= [trials, repeated, repeated, novel];
        textures(row, :)= [];

    end
end

end
