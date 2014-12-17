function process_mirflickr25k( imageDir, objectDir, start_index, step )

tic;

% load vl_feat parameters
params = defaultParams('objectness-release-v2.2/');

%imageDir = '/Users/elliotstaobjClassudt/Documents/MIRFLICKR-25000/images/';
%tagDir = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/tags/';
%objectDir = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/objects/';

numboxes = 4;
box_confidence_threshold = 0.5;    % lower numbers are ignored
box_overlap_threshold = 0.25; % don't want boxes overlapping too much

% image files are listed as numbers and we only care about 0-24999
for count = start_index:(start_index+step-1)
    %disp(count);
    imagePath = [imageDir num2str(count) '.jpg'];
    % tagPath = [tagDir num2str(count) '.txt'];
    im = imread(imagePath);
    boxes = runObjectness(im,numboxes);
    % for visualization, can comment out when actually running.
    % figure,imshow(im),drawBoxes(boxes);

    % folder to save cropped images and descriptors
    objects_save_folder = fullfile(objectDir, sprintf('%05d',count));
    % check to see if folder exists
    if( exist(objects_save_folder,'dir') )
        delete( fullfile( objects_save_folder, '*' ) )
    else
        mkdir(objects_save_folder)
    end
    
    obj_count = 0;
    skip_box_check = zeros(1,size(boxes,1));    % remembers if box was skipped
    for idx = 1:size(boxes,1)
        score = boxes(idx,5);
        if score < box_confidence_threshold
            continue
        end
        % check for overlap
        % this preferences the boxes higher confidence (lower row number)
        if idx > 1
            for subcount = 1:idx-1
                % first check to see if the box being compared with was 
                % previously disregarded
                if skip_box_check(subcount) == 1
                    continue;
                end
                % then check to see if they overlap
                if boxes_overlap( boxes(subcount,1:4), boxes(idx,1:4) ) > box_overlap_threshold
                    skip_box_check(idx) = 1;
                end
            end
        end
        if skip_box_check(idx) == 1
            % skip this box if there is overlap
            continue
        end
        obj_count = obj_count+1;

        xmin = boxes(idx,1);
        ymin = boxes(idx,2);
        xmax = boxes(idx,3);
        ymax = boxes(idx,4);
        width = xmax-xmin;
        height = ymax-ymin;
        rect = [xmin ymin width height];
        I2 = imcrop(im, rect);
        % for visualization of cropped area
%        I2 = rgb2gray(I2);
%        figure,imshow(I2);
        % save cropped area
        imwrite( I2, fullfile( objects_save_folder, ['object_' sprintf('%02d',obj_count) '.jpg'] ) );
        % convert the cropped area to greyscale single precision
        I2 = single(rgb2gray(I2)); % needed for the vl_dsift
        step_vl = round(sqrt(height*width/300)-0.5);
        if step_vl < 1
            step_vl = 1;
        end
        [f,d] = vl_dsift(I2,'step',step_vl);
        % save sift data
        save( fullfile( objects_save_folder, ['object_' sprintf('%02d',obj_count) '.mat'] ), 'd' )
    end
end
toc;

for count = 1:4
    beep;
    pause(0.25);
end

