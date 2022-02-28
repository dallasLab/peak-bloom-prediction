# Required libraries
library(tidyr)
library(dplyr)
library(ggplot2)

# Download predictions and past data, only include relevant columns
predictions <- read.csv("peak_bloom_predictions.csv") %>% 
  dplyr::select(year, kyoto, liestal, vancouver, washingtondc) %>% 
  tidyr::pivot_longer(!year, names_to = "location", values_to = "predict_doy") %>% 
  dplyr::mutate(type = "Predicted") %>% 
  dplyr::mutate(bloom_doy = predict_doy-188) 

# Reduce kyoto dataset to comparable years
kyoto <- read.csv("data/kyoto.csv") %>% 
  dplyr::select(location, year, bloom_doy) %>% 
  dplyr::filter(year > 1850) 

liestal <- read.csv("data/liestal.csv") %>% 
  dplyr::select(location, year, bloom_doy)

washingtondc <- read.csv("data/washingtondc.csv")%>% 
  dplyr::select(location, year, bloom_doy)

observations <- rbind(kyoto, liestal, washingtondc) %>% 
  dplyr::mutate(type = "Past")

predictions <- predictions %>% 
  dplyr::select(location, year, bloom_doy, type)

# Combine observed and predicted data frames
all_doys <- rbind(observations, predictions) 

# Plote the time series of past and predicted data for each location
pdf("Time_series_plot.pdf")
ggplot(data = all_doys, aes(x = year, y = bloom_doy, color = type))+
  geom_line(size = 1.5)+
  facet_wrap(~location)+
  theme(panel.background = element_blank(),
        panel.border = element_rect(color = "black", fill = NA),
        strip.background = element_rect(fill = "lavenderblush1"),
        strip.text = element_text(color = "black", size = 12),
        axis.title = element_text(color = "black", size = 16, face = "bold"),
        axis.text = element_text(color = "black", size = 12),
        legend.key = element_blank(),
        legend.background = element_blank(),
        legend.title = element_text(color = "black", face = "bold"),
        legend.position = c(0.09,0.4))+
  scale_color_manual(values = c("gray", "hotpink"))+
  scale_x_continuous(breaks = c(1850,1900,1950,2021), limits = c(1850, 2032))+
  labs(x = "Year", y = "Peak bloom (days since Jan 1st)", color = "Data Type")
dev.off()
