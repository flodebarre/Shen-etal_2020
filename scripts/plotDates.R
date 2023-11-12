# Plot the results obtained in sra-S1.csv: key dates for the patients

# Load data ####
m <- read.csv("../data/sra-S1.csv")

# Format dates as dates
for(col in c("Collection_date_Shen", "Onset_date", "Hospitalization_date")){
  m[, col] <- as.Date(m[, col])
}

# Compute estimated onset date
m$Estimated_Onset <- m$Collection_date_Shen - m$Days_after_onset_Shen

# Plot ####

fname <- "plotDates.png" # File name

png(fname, width = 8, height = 6, units = "in", res = 200)

xx <- rev(seq_len(nrow(m))) # Positions of the patients (actually as y)
rg <- range(c(m$Onset_date, m$Estimated_Onset, m$Hospitalization_date, m$Collection_date_Shen)) # Range of dates, to fix x range

# Colors
cols <- MetBrewer::met.brewer("Java", 4) 
names(cols) <- c("hosp", "onset_estim", "onset", "collection")
cexx <- 2 # Point size

dates <- seq(rg[1], rg[2], by = "day") # Dates for x axis

par(las = 1, mai = c(1.5, 2.25, 0.75, 0.25))

# Initialize plot
plot(m$Onset_date, xx, axes = FALSE, 
     xlim = rg, ylim = c(0.75, max(xx) + 0.25), 
     xlab = "", ylab = "", type = "n")

# Plot grid for days
for(dd in dates){
  abline(v = dd, col = gray(0.9))
}

axis(1, at = dates, labels = format(dates, "%b %d"))
axis(2, lwd = 0, at = xx, labels = paste0("nCov", seq_along(xx), "|", m$Isolate, "|", m$Host_age, m$Host_sex, ifelse(m$Date_certainty == 0, "*", "")), family = "mono")

title(main = "Shen et al. (2020)'s patients")

# Segments to identify isolates / patients
segments(x0 = m$Onset_date, y0 = xx, x1 = m$Collection_date_Shen, y1 = xx, 
         col = gray(0.85), lwd = 7)
# Segments to link dates
dy <- 0.22 # position of this other segment
colDelta <- gray(0.6) # Color of the link
lDelta <- 2 # Line type of the link
segments(x0 = m$Estimated_Onset, x1 = m$Collection_date_Shen, y0 = xx + dy, y1 = xx + dy, 
         col = colDelta, lty = lDelta)
for(col in c("Estimated_Onset", "Collection_date_Shen")){
  segments(x0 = m[, col], x1 = m[, col], 
           y0 = xx, y1 = xx + dy, 
           col = colDelta, lty = lDelta)
}

# Add points
points(m$Onset_date, xx, pch = 16, cex = cexx, col = cols["onset"])
points(m$Hospitalization_date, xx, pch = 15, col = cols["hosp"], cex = cexx)
points(m$Collection_date_Shen, xx, pch = 18, col = cols["collection"], cex = cexx)
points(m$Estimated_Onset, xx, pch = 1, cex = cexx, col = cols["onset_estim"], lwd = 3)

# Legend and comments
par(xpd = TRUE)
legend(x = mean(dates), y = -0.75, yjust = 1, xjust = 0.5, 
       col = c(cols["onset"], cols["hosp"], cols["collection"], cols["onset_estim"]), legend = c("Symptoms onset", "Hospitalization", "Sample collection (Shen et al.)", "Estimated onset (Shen et al.)"), pch = c(16, 15, 18, 1), pt.cex = cexx, ncol = 2, lwd = c(1, 1, 1, 3), lty = 0, 
       text.width = c(5, 8), x.intersp = 0)

text(x = dates[1] - 3, y = -2.5, labels = "* Patient assignation, and therefore his onset and hospitalization dates, are not certain.", adj = 0)

par(xpd = FALSE)
dev.off()

system(paste("open", fname))
