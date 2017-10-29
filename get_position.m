function [real_pose, im_pose] = get_position(cam)
    if evalin( 'base', 'exist(''Q'',''var'') == 1' )
        Q = evalin('base','Q');
    else
        Q = calibration_live(cam);
        assignin('base', 'Q', Q);
    end
    im_pose = color_detection(snapshot(cam));
    real_pose = convert3D(im_pose, Q);
end

function pose = color_detection(im)
    %fh = figure(1);

    im = abs(im(:,:,2)-im(:,:,1));
    %subplot(121);
    %imshow(im)

    im = imbinarize(im, 'global');

    se = strel('disk',20);
    im = imclose(im, se);
    %subplot(122);
    %imshow(im)

    stats = regionprops('table',im,'Centroid','MajorAxisLength','MinorAxisLength');
    centers = stats.Centroid;
    diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);

    %% find the sphero

    if length(diameters)>1
        [~, sphero_id] = max(diameters);
        pose = centers(sphero_id,:); % maybe vector are on axis 1 !
    else
        pose = centers;
    end

    %hold on;plot(pose(1), pose(2), '.r')
end

function [res ] = convert3D ( coord, Q)
    res = Q * [coord 1]';
    res = res(1:2) ./ res(end);
end