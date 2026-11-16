clear;
clc;
close all;

% Folded Dipole antenna parameters
c0 = 3e8;
f_mhz = 400;
lambda = c0 / (f_mhz * 1e6);

dipole_length = lambda / 2;
wire_radius = lambda / 400;

% Excitation
V_real = 1;
V_imag = 0;

% Parallel wire spacing
spacing = [lambda/100, lambda/20, lambda/4];
spacing_labels = {'100', '20', '4'};

% Segmentation
nseg_dipole = 21;
nseg_connectors = [1, 3, 15];

% Geometry coordinates
x_left = -dipole_length / 2;
x_right = dipole_length / 2;

% Feed location
feed_tag = 1;
feed_segment = (nseg_dipole + 1) / 2;

out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'models', 'folded_dipole');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

for k = 1:length(spacing)

    s = spacing(k);

    filename = fullfile(out_dir, ['Folded_Dipole_lambda_', ...
                spacing_labels{k}, '.nec']);

    fid = fopen(filename, 'w');
    if fid < 0
        error('Could not open %s for writing.', filename);
    end

    fprintf(fid, 'CM Folded Dipole Antenna Geometry\n');
    fprintf(fid, 'CE\n');

    % First parallel wire (fed)
    fprintf(fid, ...
        'GW 1 %d %.8f 0 0 %.8f 0 0 %.8f\n', ...
        nseg_dipole, x_left, x_right, wire_radius);

    % Second parallel wire
    fprintf(fid, ...
        'GW 2 %d %.8f %.8f 0 %.8f %.8f 0 %.8f\n', ...
        nseg_dipole, x_left, s, x_right, s, wire_radius);

    % Left connecting wire
    fprintf(fid, ...
        'GW 3 %d %.8f 0 0 %.8f %.8f 0 %.8f\n', ...
        nseg_connectors(k), ...
        x_left, x_left, s, wire_radius);

    % Right connecting wire
    fprintf(fid, ...
        'GW 4 %d %.8f 0 0 %.8f %.8f 0 %.8f\n', ...
        nseg_connectors(k), ...
        x_right, x_right, s, wire_radius);

    fprintf(fid, 'GE 0\n');

    % Voltage excitation at center of first wire
    fprintf(fid, 'EX 0 %d %d 0 %.6f %.6f\n', ...
        feed_tag, feed_segment, V_real, V_imag);

    % Frequency
    fprintf(fid, 'FR 0 1 0 0 %.6f 0\n', f_mhz);

    % Radiation pattern
    fprintf(fid, 'RP 0 37 72 1000 0 0 5 5 0 0\n');

    fprintf(fid, 'EN\n');

    fclose(fid);

    fprintf('Created: %s | spacing = %.6f m\n', ...
            filename, s);

end
