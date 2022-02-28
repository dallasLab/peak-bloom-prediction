# Required libraries
library(tidyr)
library(dplyr)
library(ggplot2)

# Download predictions and past data, only include relevant columns
predictions <- read.csv("cherry_predictions.csv") %>% 
  dplyr::select(year, kyoto, liestal, vancouver, washingtondc) %>% 
  tidyr::pivot_longer(!year, names_to = "location", values_to = "bloom_doy") %>% 
  dplyr::mutate(type = "Predicted") 

kyoto <- read.csv("data/kyoto.csv") %>% 
  dplyr::select(year, location, bloom_doy) #%>% 
  dplyr::filter(year > 1890) # Reduce dataset to comparable years for visualization

liestal <- read.csv("data/liestal.csv") %>% 
  dplyr::select(year, location, bloom_doy)

washingtondc <- read.csv("data/washingtondc.csv")%>% 
  dplyr::select(year, location, bloom_doy)

observations <- rbind(kyoto, liestal, washingtondc) %>% 
  dplyr::mutate(type = "Past")

# Combine observed and predicted data frames
all_doys <- rbind(observations, predictions) 

# Modify labels for plot
locations_labs <- c("Kyoto", "Liestal", "Vancouver", "Washington DC")
names(locations_labs) <- c("kyoto", "liestal", "vancouver", "washingtondc")

# Plot the time series of past and predicted data for each location
pdf("Time_series_plot.pdf")
ggplot(data = all_doys, aes(x = year, y = bloom_doy, color = type))+
  geom_line(size = 1)+
  facet_wrap(~location, labeller = labeller(location = locations_labs))+
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
  scale_x_continuous(breaks = c(1900,1925,1950,1975,2000,2021), limits = c(1900, 2032))+
  labs(x = "Year", y = "Peak bloom (days since Jan 1st)", color = "Data Type")
dev.off()
