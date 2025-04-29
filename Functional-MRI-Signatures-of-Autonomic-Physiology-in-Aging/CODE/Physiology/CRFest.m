function [cardresp cardTdev cardSdev] = CRFest(dt)  

% add temporal and dispersive derivatives to the cardiac response function in Catie's 2009 paper 
% bases reported in "Chen, J.E., Lewis, L.D., Chang, C., Tian, Q., Fultz, N.E., Ohringer, N.A., Rosen, B.R. and Polimeni, J.R., 2020. Resting-state “physiological networks”. NeuroImage, 213, p.116707."

t = [0:dt:30]';
cardresp = 0.6*t.^2.7.*exp(-t/1.6) - 16/sqrt(2*pi*9).*exp(-(t-12).^2/18);  
cardTdev(:,1) = 0.6*2.7*t.^(1.7).*exp(-t/1.6)+0.6*t.^2.7.*exp(-t/1.6)*(-1/1.6);    
cardTdev(:,2) = 16/sqrt(2*pi*9).*exp(-(t-12).^2/18)*(-1/18)*2.*(t-12);    
cardSdev(:,1) = 0.6*t.^2.7.*exp(-t/1.6).*t/(1.6^2);
cardSdev(:,2) = 16/sqrt(2*pi*9).*exp(-(t-12).^2/18).*(t-12).^2/(18^2);  

end