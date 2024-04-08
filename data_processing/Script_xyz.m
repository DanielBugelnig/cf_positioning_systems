
clear all;

% Import Data
file_path_xyz_loco = "C:\Users\danie\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take_09012024_square\s_square_h_075\take_s_square_h075_lo.csv";
file_path_xyz_optitrack = "C:\Users\danie\OneDrive - Alpen-Adria Universität Klagenfurt\Dokumente\AAU\Studienassistenz\Crazyflies\Data evaluation\Take_09012024_square\s_square_h_075\take_s_square_h075_op.csv";

%Extract Data
%for whole file
data_xyz_l = readmatrix(file_path_xyz_loco)';   %Loco Positioning Data

x_l = data_xyz_l(1,:);
y_l = data_xyz_l(2,:);
z_l = data_xyz_l(3,:);


data_xyz_o = readmatrix(file_path_xyz_optitrack);   %Optitrack Positioning Data
x_o = data_xyz_o(:,5)';
y_o = data_xyz_o(:,3)';
z_o = data_xyz_o(:,4)';

[optitrack_x, loco_x, t, error_x, offset_t_opt_x, offset_opt_x] = synchronize(x_l, x_o,0.01);
plotting(t,optitrack_x,loco_x,'X Coordinate [t]');

[optitrack_y, loco_y, t, error_y, offset_t_opt_y, offset_opt_y] = synchronize(y_l, y_o,0.01);
plotting(t,optitrack_y,loco_y,'Y Coordinate [t]');

[optitrack_z, loco_z, t, error_z, offset_t_opt_z, offset_opt_z] = synchronize(z_l, z_o,0.01);
plotting(t,optitrack_z,loco_z,'Z Coordinate [t]');


[optitrack_x,optitrack_y,optitrack_z, loco_x, loco_y, loco_z, t, error, offset_t, offset_opt_z] = synchronize(z_l, z_o,0.01);






function [optitrack_x_cut,optitrack_y_cut,optitrack_z_cut, loco_x,loco_y,loco_z, t,error_optimized, offset_t_opt, offset_optimized] = synchronize(loco_x,loco_y,loco_z, optitrack_x,optitrack_y,optitrack_z,T)
    length_l = length(loco_x);
    t = 0:T:T*(length_l-1);
    error_optimized = 100;
    for offset_t = 1 : length(optitrack)-length_l
        for offset = -300 : 300
            optitrack_x_cut = offset/1000 + optitrack_x(offset_t:offset_t+length_l-1);
            optitrack_y_cut = offset/1000 + optitrack_y(offset_t:offset_t+length_l-1);
            optitrack_z_cut = offset/1000 + optitrack_z(offset_t:offset_t+length_l-1);
            err_mean  = (1/(3*length_l)) * (sum(abs(loco_x - optitrack_x_cut))+ sum(abs(loco_y - optitrack_y_cut)) + sum(abs(loco_z - optitrack_z_cut)));
            if err_mean <= error_optimized
                error_optimized = err_mean;
                offset_t_optimized = offset_t;
                offset_optimized = offset/1000;
            end
        end
    end
    optitrack_x_cut = optitrack_x(offset_t_optimized:offset_t_optimized+length_l-1);
    optitrack_y_cut = optitrack_y(offset_t_optimized:offset_t_optimized+length_l-1);
    optitrack_z_cut = optitrack_z(offset_t_optimized:offset_t_optimized+length_l-1);
    offset_t_opt = offset_t_optimized * T;
    loco_x = loco_x - offset_optimized;
    loco_y = loco_y - offset_optimized;
    loco_z = loco_z - offset_optimized;

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







