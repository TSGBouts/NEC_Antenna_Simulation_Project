clear;
clc;
close all;

% Beverage (traveling-wave) antenna parameters
c0 = 3e8;
f_mhz = 10;
lambda = c0 / (f_mhz * 1e6);
wire_length = 5 * lambda;

% Excitation and common segmentation
V_real = 1;
V_imag = 0;
feed_tag = 2;
feed_segment = 1;
load_tag = 3;
nseg_horizontal = 100;

% Ground type, height (m), wire radius (m), load (ohm), vertical segments
% GN 2 is the Sommerfeld-Norton finite-conductivity ground model.
cases = {
    'perfect', lambda/4,     lambda/400, 200, 8;
    'perfect', lambda/4,     lambda/400, 250, 8;
    'perfect', lambda/4,     lambda/400, 318, 8;
    'perfect', lambda/4,     lambda/400, 400, 8;
    'norton',  lambda/4,     lambda/400, 200, 8;
    'norton',  lambda/4,     lambda/400, 250, 8;
    'norton',  lambda*0.067, lambda/400, 250, 1;
    'norton',  lambda*0.067, 0.001,      500, 1
};

out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'models', 'traveling_wave');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

for k = 1:size(cases, 1)
    ground = cases{k, 1};
    height = cases{k, 2};
    wire_radius = cases{k, 3};
    R = cases{k, 4};
    nseg_vertical = cases{k, 5};

    filename = fullfile(out_dir, sprintf('Beverage_%s_h%gm_a%gmm_R%d.nec', ...
        ground, height, wire_radius*1000, R));
    fid = fopen(filename, 'w');
    if fid < 0
        error('Could not open %s for writing.', filename);
    end

    fprintf(fid, 'CM Traveling Wave Antenna Geometry\nCE\n');
    fprintf(fid, 'GW 1 %d %.8f 0 %.8f %.8f 0 %.8f %.8f\n', ...
        nseg_horizontal, 0, height, wire_length, height, wire_radius);
    fprintf(fid, 'GW 2 %d 0 0 0 0 0 %.8f %.8f\n', ...
        nseg_vertical, height, wire_radius);
    fprintf(fid, 'GW 3 %d %.8f 0 %.8f %.8f 0 0 %.8f\n', ...
        nseg_vertical, wire_length, height, wire_length, wire_radius);
    fprintf(fid, 'GE 1\n');

    if strcmp(ground, 'perfect')
        fprintf(fid, 'GN 1\n');
    else
        fprintf(fid, 'GN 2 0 0 0 14 0.01\n');
    end

    % Far-end resistor and near-end voltage source, both at ground-side segments.
    fprintf(fid, 'LD 0 %d %d %d %.6f 0 0\n', ...
        load_tag, nseg_vertical, nseg_vertical, R);
    fprintf(fid, 'EX 0 %d %d 0 %.6f %.6f\n', ...
        feed_tag, feed_segment, V_real, V_imag);
    fprintf(fid, 'FR 0 1 0 0 %.6f 0\n', f_mhz);
    fprintf(fid, 'RP 0 91 72 1000 0 0 1 5 0 0\n');
    fprintf(fid, 'EN\n');
    fclose(fid);
    fprintf('Created: %s\n', filename);
end
