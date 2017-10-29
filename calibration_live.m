function [Q, P] = calibration_live(cam)
    ss  = snapshot(cam);
    fh = figure(1);
    image(ss);

    hold on
    [x, y] = getpts(fh);
    points = [x y];
    plot(points(:,1), points(:,2), '.r', 'MarkerSize', 20)

    %%%%%%%%%%%%%%%%%%%
    % Modify the pattern here


    a = 6; pose = [0 0; a 0 ; 0 a; a a]; % identify square (2x2 points) in a Z shape order starting from origin, a=41 correspond to the classroom floor pattern
    %pose = [-3 -3 ; 0 -3 ; 3 -3 ; -3 0 ; 0 0 ; 3 0 ; -3 3 ; 0 3 ; 3 3]; % same for a 3x3 square centered in 0
    
    % manual position input
%     pose = zeros(size(points));
%     for i=1:length(points)
%         prompt = strcat('Point #', num2str(i), ' planar coordinates : ');
%         pose(i, :) = input(prompt);
%     end


    %%%%%%%%%%%%%%%%%%%%

    [~, S, V] = svd(DLT_system(points, pose));

    ker = V(:,end);
    H = reshape(ker, 3, 3)'

    load('OnePlus5_calibrationSession.mat'); % load the calibration parameters expoted by matlab camera calibrator
    A = calibrationSession.CameraParameters.IntrinsicMatrix';
    
    %% more details on DLT pose estimation on https://github.com/smaillot/3D_pose_estimation

    G = A^-1 * H;
    R1 = G(:,1);
    R2 = G(:,2);
    R3 = cross(R1, R2);
    t = G(:,3);

    l = sqrt(norm(R1) * norm(R2));
    R1 = R1 / l;
    R2 = R2 / l;
    t = t / l
    c = R1 + R2;
    d = cross(c, R3);
    R1 = 1 / sqrt(2) * (c / norm(c) + d / norm(d));
    R2 = 1 / sqrt(2) * (c / norm(c) - d / norm(d));
    R3 = cross(R1, R2);
    R = [R1, R2, R3]

    C = -R'*t
    P = A * [R, t]

    %%

    Q = invert_P(P);
    close(fh)
end

function A = DLT_system(u, x)
    A = [];
    for i=1:length(u)
        A = [A ; DLT_point2vec(u(i,:), x(i,:))];
    end
end

function A = DLT_point2vec(u, x)
    A = kron(eye(2), [x,1]);
    A = [A , -u' * [x,1]];
end

function Q = invert_P ( P )
    Q = pinv(P(:,[1 2 4]));
end