function [pval, F_stats] = CalAgeRate(data, dependVar, thres)
% CalAgeRateGlobal Calculates p-values for aging rates
% Inputs:
%   data - A structure containing demographic and other data, must include 'age'
%   dependVar - Dependent variable for analysis, can be vector or
%   matrix
%   thres - Age threshold for seperating Aging I and Aging II group
% Outputs:
%   F stats - the likelihood of additional regressor giving a significantly better fit to the data
%   pval - p-values from the statistical tests

young = find(data.age < thres);  
old = find(data.age >= thres);  
num_young = length(young);
num_old = length(old);


age = data.age; % continuous variable
age_category = age >= thres; % categorical variable, 0 for age < thres, and 1 for age >= thres (in our case age thres is 60)
age_interaction = age .* (age >= thres); % additional regressor trying to explain difference in age rate





current_roi = dependVar(:)';
    
% Organize variables into a table for the current ROI
tbl_old = table(current_roi', age, age_category,  'VariableNames', {'ROI', 'Age', 'Age_Category'});
    
% Fit the linear model for the current ROI
lm_old = fitlm(tbl_old, 'ROI ~ Age + Age_Category');
summary_old = anova(lm_old, 'summary');

% Organize variables into a table for the current ROI
tbl_new = table(current_roi', age, age_category, age_interaction, 'VariableNames', {'ROI', 'Age', 'Age_Category', 'Age_Interaction'});
    
% Fit the linear model with additional regressor for the current ROI
lm_new = fitlm(tbl_new, 'ROI ~ Age + Age_Category + Age_Interaction'); 
summary_new = anova(lm_new, 'summary');

    
% calculate the residue sum of squares for partial model and full model
n = height(data);
p2 = 4;
p1 = 3;
df1 = p2-p1;
df2 = n-p2;


% caculate the F stats and its corresponding p values
RSS1 = summary_old{3, ['SumSq']};
RSS2 = summary_new{3, ['SumSq']};
F_stats = ((RSS1- RSS2)/RSS2)*((n-p2)/(p2-p1));
pval = 1 - fcdf(F_stats,df1, df2);


end
