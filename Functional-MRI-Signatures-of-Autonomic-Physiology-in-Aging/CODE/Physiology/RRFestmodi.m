function [respresp respTdev respSdev] = RRFestmodi(dt)

% add temporal and dispersive derivatives to the respiratory response function in Catie's 2009 paper 
% bases reported in "Chen, J.E., Lewis, L.D., Chang, C., Tian, Q., Fultz, N.E., Ohringer, N.A., Rosen, B.R. and Polimeni, J.R., 2020. Resting-state “physiological networks”. NeuroImage, 213, p.116707."

t = [0:dt:50]';
respresp = 0.6*t.^2.1.*exp(-t/1.6) - 0.0023*t.^(3.54).*exp(-t/4.25);  
respTdev(:,1) = -3/8*t.^(2.1).*exp(-t/1.6)+1.26*t.^(1.1).*exp(-t/1.6);   
respTdev(:,2) = 0.0023*3.54*t.^(2.54).*exp(-t/4.25) + 0.0023.*t.^(3.54).*exp(-t/4.25)*(-1/4.25);   
respSdev(:,1) = 0.6*t.^(2.1).*t/(1.6^2).*exp(-t/1.6);   
respSdev(:,2) = 0.0023*t.^(3.54).*t/(4.25^2).*exp(-t/4.25);   

end