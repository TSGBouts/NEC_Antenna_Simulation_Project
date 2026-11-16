clear;
clc;
close all;

% Discone antenna parameters (dimensions in metres)
lambda = 1;
c0 = 3e8;
f_mhz = (c0 / lambda) * 1e-6;
n_arm = 8;
feed_denominators = [20, 100];

% Excitation
V_real = 1;
V_imag = 0;

% Disc and cone parameters
wire_radius = lambda / 400;
disc_extent = 0.34 * lambda;
cone_extent = 0.5 * lambda;
cone_half_angle = pi / 6;
nseg_disc = 16;
nseg_cone = 24;
feed_tag = 2*n_arm + 1;

out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'models', 'discone');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

phi = (2*pi/n_arm) * (0:n_arm-1);
disc_inside = zeros(n_arm, 3);
disc_outside = [disc_extent*cos(phi(:)), ...
                disc_extent*sin(phi(:)), zeros(n_arm, 1)];

for denominator = feed_denominators
    feed_length = lambda / denominator;
    cone_top = [zeros(n_arm, 2), -feed_length*ones(n_arm, 1)];
    cone_bottom = [cone_extent*sin(cone_half_angle)*cos(phi(:)), ...
                   cone_extent*sin(cone_half_angle)*sin(phi(:)), ...
                   (-feed_length - cone_extent*cos(cone_half_angle))*ones(n_arm, 1)];

    filename = fullfile(out_dir, sprintf('Discone_Antenna_feed_lambda%d.nec', denominator));
    fid = fopen(filename, 'w');
    if fid < 0
        error('Could not open %s for writing.', filename);
    end
    fprintf(fid, 'CM Discone Antenna Geometry\nCE\n');
    for k = 1:n_arm
        fprintf(fid, 'GW %d %d %.6f %.6f %.6f %.6f %.6f %.6f %.6f\n', ...
            k, nseg_disc, disc_inside(k,:), disc_outside(k,:), wire_radius);
        fprintf(fid, 'GW %d %d %.6f %.6f %.6f %.6f %.6f %.6f %.6f\n', ...
            n_arm+k, nseg_cone, cone_top(k,:), cone_bottom(k,:), wire_radius);
    end
    fprintf(fid, 'GW %d 1 %.6f %.6f %.6f %.6f %.6f %.6f %.6f\n', ...
        feed_tag, disc_inside(1,:), cone_top(1,:), wire_radius);
    fprintf(fid, 'GE 0\n');
    fprintf(fid, 'EX 0 %d 1 0 %.6f %.6f\n', feed_tag, V_real, V_imag);
    fprintf(fid, 'FR 0 1 0 0 %.6f 0\n', f_mhz);
    fprintf(fid, 'RP 0 37 72 1000 0 0 5 5 0 0\n');
    fprintf(fid, 'EN\n');
    fclose(fid);
    fprintf('Created: %s\n', filename);
end
