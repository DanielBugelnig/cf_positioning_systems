
clear all;

% Import Data
file_path_x_loco = 'C:\Users\Daniel Bugelnig\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take 1_fly_line_height_1\x_coordinates_loco.csv';
file_path_y_loco= 'C:\Users\Daniel Bugelnig\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take 1_fly_line_height_1\y_coordinates_loco.csv';
file_path_z_loco = 'C:\Users\Daniel Bugelnig\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take 1_fly_line_height_1\z_coordinates_loco.csv';
file_path_xyz_loco = '';
file_path_xyz_optitrack = 'C:\Users\Daniel Bugelnig\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take 1_fly_line_height_1\xyz_coordinates_optitrack.csv';

%Extract Data
%for whole file
% data_xyz_l = readmatrix(file_path_xyz_loco)';   %Loco Positioning Data
% x_l = data_xyz_o(:,1)';
% y_l = data_xyz_o(:,2)';
% z_l = data_xyz_o(:,3)';

%For separate files
x_l = readmatrix(file_path_x_loco)';    % Use readmatrix to import the CSV file as a matrix
y_l = readmatrix(file_path_y_loco)';
z_l = readmatrix(file_path_z_loco)';

data_xyz_o = readmatrix(file_path_xyz_optitrack);   %Optitrack Positioning Data
x_o = data_xyz_o(:,5)';
y_o = data_xyz_o(:,3)';
z_o = data_xyz_o(:,4)';
clear data_xyz_o;

[optitrack_x, loco_x, t, error_x, offset_t_opt_x, offset_opt_x] = synchronize(x_l, x_o,0.01);
plotting(t,optitrack_x,loco_x,'X Coordinate [t]');

[optitrack_y, loco_y, t, error_y, offset_t_opt_y, offset_opt_y] = synchronize(y_l, y_o,0.01);
plotting(t,optitrack_y,loco_y,'Y Coordinate [t]');

[optitrack_z, loco_z, t, error_z, offset_t_opt_z, offset_opt_z] = synchronize(z_l, z_o,0.01);
plotting(t,optitrack_z,loco_z,'Z Coordinate [t]');

    
    






function [optitrack_cut, loco, t,error_optimized, offset_t_opt, offset_optimized] = synchronize(loco, optitrack,T)
    length_l = length(loco);
    t = 0:T:T*(length_l-1);
    error_optimized = 100;
    for offset_t = 1 : length(optitrack)-length_l
        for offset = -300 : 300
            optitrack_cut = offset/1000 + optitrack(offset_t:offset_t+length_l-1);
            err_mean  = (1/length_l) * sum(abs(loco - optitrack_cut));
            if err_mean <= error_optimized
                error_optimized = err_mean;
                offset_t_optimized = offset_t;
                offset_optimized = offset/1000;
            end
        end
    end
    optitrack_cut = optitrack(offset_t_optimized:offset_t_optimized+length_l-1);
    offset_t_opt = offset_t_optimized * T;
    loco = loco - offset_optimized;

end

function plotting(t, optitrack, loco, y_label)
    figure;
    plot(t, optitrack,'LineWidth', 2.5, 'LineStyle','-','Color','green')
    hold on
    plot(t, loco, 'LineWidth', 2.5,'LineStyle',':','Color','blue')
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    xlabel('t [s]','FontSize',12,'FontWeight','bold') 
    ylabel(y_label,'FontSize',12,'FontWeight','bold') 
    title('Positioning Data Comparison')
    legend({'Optitrack','Loco'},'Location','best')
    box off
end







