library(ggplot2)
library(dplyr)
library(themedubois)
library(extrafont)
#font_import()

d <- read.csv('data.csv')

d <- d %>%
  mutate(color = ifelse(Year < 1875, 'white1', 
                        ifelse(Year > 1898, 'white2', 'black')))

p <- ggplot(d) +
  geom_line(aes(x = Year, y = Property.Valuation, group = 1), size = 1.8) +
  geom_line(aes(x = Year, y = Property.Valuation, color = (color == 'black'), group = 2), size = 1.4) +
  scale_color_manual(values = c('#D6C8B7', 'black')) +
  scale_y_continuous(limits = c(0, max(d$Property.Valuation)),
                     breaks = seq(0, 4.8e6, 1e5), expand = c(0, 0),
                     labels=c("", "", "", "", "$           ", "", "$           ", "", "", "", "1,000,000",
                              "", "", "", "$           ", "", "$           ", "", "", "", "2,000,000",
                              "", "", "", "$           ", "", "$           ", "", "", "", "3,000,000",
                              "", "", "", "$           ", "", "$           ", "", "", "", "4,000,000",
                              "", "", "", "$           ", "", "$           ", "", "DOLLARS"
                              )) +
  scale_x_continuous(limits = c(1870, 1900), breaks = seq(1870, 1900, 5),
                     minor_breaks = seq(1870, 1900, 1),
                     expand = c(0,0)) +
  ggtitle("VALUATION OF TOWN AND CITY PROPERTY OWNED\nBY AFRICAN AMERICANS IN GEORGIA.") +
  theme(legend.position="none",
        text = element_text(family = "Jefferies", color = '#373535'),
        plot.background = element_rect(fill = "#D6C8B7"),
        panel.background = element_rect(fill = "#D6C8B7", color = '#373535',
                                        size = 0.2),
        panel.grid.major = element_line(size = 0.05, linetype = 'solid',
                                        colour = "#BB4A1D"), 
        panel.grid.minor = element_line(size = 0.05, linetype = 'solid',
                                        colour = "#BB4A1D"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = 9),
        axis.text.y = element_text(hjust = -0.3),
        axis.ticks = element_blank(),
        plot.title = element_text(lineheight = .7, hjust = 0.5, size = 14, vjust = 4.5),
        plot.margin = margin(0.6,0.6,0.6,0.8, "cm")) +
  annotate('text', label = "POLITICAL\n             UNREST.", x = 1876, y = 2.3e6, lineheight = .8,
           size = 3.5, family = "Jefferies", color = '#373535', alpha = 0.6) +
  annotate('text', label = "RISE OF\n       THE NEW\n                     INDUSTRIALISM.", lineheight = .8,
           x = 1884, y = 4.2e6,  size = 3.5, family = "Jefferies", color = '#373535', alpha = 0.6) +
  annotate('text', label = "DISENFRANCHISEMENT\n  AND\n   PROSCRIPTIVE\n    LAWS.", 
           x = 1896.5, y = 2.3e6,  size = 3.5, family = "Jefferies", color = '#373535', alpha = 0.6, lineheight = .8,) +
  annotate('text', label = "LYNCHING.", x = 1892, y = 1.65e6, lineheight = .8,
           size = 3.5, family = "Jefferies", color = '#373535', alpha = 0.6) +
  annotate('text', label = "KU-KLUXISM.", x = 1872, y = 6e5, angle = 90, lineheight = .8,
           size = 3.5, family = "Jefferies", color = '#373535', alpha = 0.6) +
  annotate('text', label = "FINANCIAL PANIC.", x = 1894, y = 8e5, angle = 90, lineheight = .8,
           size = 3.5, family = "Jefferies", color = '#373535', alpha = 0.6)

ggsave('my_plot.tiff', p, device = "tiff", dpi = 300)

