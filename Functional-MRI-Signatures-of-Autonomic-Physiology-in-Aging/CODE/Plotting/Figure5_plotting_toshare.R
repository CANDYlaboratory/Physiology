library(ggpmisc)
library(R.matlab)
library(ggplot2)
library(RColorBrewer)
library(ggpubr)
library(patchwork)
library(tidyverse)
library(dplyr)

result<- readMat('/Users/fanjiawen/Downloads/Subjects_400_all_metrics.mat')
subjects<-read.csv('/Users/fanjiawen/Downloads/sorted_subjects_400.csv', sep=',' )

# get all the metrics
age<- subjects$age
sex <- subjects$sex
hbi_lags <-result$hbi.min.loc ;
hbi_min <-abs(result$hbi.min.pk)
rv_lags <-result$rv.min.loc
Brain_volume <-result$BV 
Ventricular_volume <-result$Ventricular.volume
Mean_cortical_thickness <-result$Total.thickness
Cerebral_WMV <-result$Cerebral.WM
Cortical_GM <-result$Cortical.GM
Mean_cortical_ATT <-result$ATT.vert
Mean_cortical_CBF <-result$CBF.vert

data <- data.frame(age, rv_lags, hbi_lags, hbi_min, Brain_volume, Ventricular_volume, Mean_cortical_thickness, Cerebral_WMV, Cortical_GM, Mean_cortical_ATT, Mean_cortical_CBF)







# --------------------plot the Age vs. Normalized Structural Metrics --------------------------- 

# use data from age in 36-40 range as the starting point
averages_young <- data %>%
  filter(age >= 36, age <= 40) %>%
  summarise(across(-age, mean, na.rm = TRUE))

# use data from age in 36-40 range as the ending point
averages_old <- data %>%
  filter(age >= 85, age <= 90) %>%
  summarise(across(-age, mean, na.rm = TRUE))

# Initial normalization based on these averages
data_normalized <- data %>%
  mutate(across(-age, ~ {
    metric_name <- cur_column()
    baseline_avg <- averages_young[[metric_name]]
    end_avg <- averages_old[[metric_name]]
    if (baseline_avg > end_avg) {
      ((. - end_avg) / (baseline_avg - end_avg) * 100)
    } else {
      ((. - baseline_avg) / (end_avg - baseline_avg) * 100)
    }
  }))

#----------------------------------- create the figure 5 left panel figure ------------------------------------------------------#
# Create plots for each metric and adjust based on the smooth fit
data_rescaled <- data_normalized

for(metric in names(data_normalized)[-1]) {
  plot <- ggplot(data_normalized, aes(x = age, y = !!sym(metric))) +
    geom_smooth(method = "loess", se = FALSE)
  
  # extract data
  built_plot <- ggplot_build(plot)
  y_values <- built_plot$data[[1]]$y
  
  # Calculate scaling factors based on smooth curve
  min_y <- min(y_values, na.rm = TRUE)
  max_y <- max(y_values, na.rm = TRUE)
  
  # Adjust the scaling
  data_rescaled[[metric]] <- (data_rescaled[[metric]] - min_y) / (max_y - min_y) * 100
}

# Convert to long format for plotting
data_long_rescaled <- pivot_longer(data_rescaled, cols = -age, names_to = "Metric", values_to = "Value")


color_New <- c("#FFA500", "#D9D9D9","#C21807", "#F781BF",  "#4DAF4A", "#80B1D3","#FFED6F", "#B3DE69", "#A65628" ,"#CCEBC5")

# plot the trajectory in the order of significance value (highest to lowest)
custom_order <- c("hbi_min", "Ventricular_volume", "rv_lags", "hbi_lags", "Cerebral_WMV", "Brain_volume", "Mean_cortical_ATT", "Mean_cortical_thickness","Mean_cortical_CBF",  "Cortical_GM")

# Reorder the factor levels according to custom_order
data_long_rescaled$Metric <- factor(data_long_rescaled$Metric, levels = custom_order)


g <- ggplot(data_long_rescaled, aes(x = age, y = Value, color = Metric, fill = Metric)) +
  geom_smooth(method = "loess", se = TRUE, linewidth = 1, alpha = 0.1) +
  scale_color_manual(values = color_New) +
  scale_fill_manual(values = color_New) +
  labs(title = "Age vs. Normalized Structural Metrics", x = "Age", y = "Normalized Metric Value (0-100)") +
  theme_classic() +
  theme(legend.position = "bottom", plot.title = element_text(hjust = 0.5))

# Create the all metrics in one figure plot
print(g)


# -------------- create figure 5 right panel figure and add a dashed line for individual metric -----------------------------------------------#

# Now, filter and add a dashed fitted line for each metric where age < 60
models_data <- data_long_rescaled %>%
  filter(age < 60) %>%
  group_by(Metric) %>%
  summarize(
    intercept = coef(lm(Value ~ age, data = cur_data()))[1],
    slope = coef(lm(Value ~ age, data = cur_data()))[2],
    .groups = 'drop'
  )


# Create the individual plot
g1 <- ggplot(data_long_rescaled, aes(x = age, y = Value, color = Metric, fill = Metric)) +
  geom_smooth(method = "loess", se = TRUE, linewidth = 1) +
  geom_abline(data = models_data, aes(intercept = intercept, slope = slope, color = Metric), linetype = "dashed") +
  scale_color_manual(values = color_New) +
  scale_fill_manual(values = color_New) +
  facet_wrap(~ Metric, scales = "free_y", ncol = 3) +
  labs(title = "Age vs. Normalized Structural Metrics", x = "Age", y = "Normalized Metric Value (0-100)") +
  theme_classic() +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5))

print(g1)
