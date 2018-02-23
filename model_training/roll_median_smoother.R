t <- function(data, window) {
    d <- rollmedian(x = zoo(order.by = data$timestamp,
                            x = data$count),
                    k = window)

    d <- data.frame(timestamp=index(d),
                    count=coredata(d))
    lines(d, col=(window-1)/12+1, type='l')
}

plot(d, type='l')
for(i in seq(1, 101, 12)) t(data=d, window=i)
legend(x=mean(range(d$timestamp)), y=90,
       legend = paste("window=",seq(1, 101, 12)),
       col=1:9,lty = 1,lwd = 3, box.lty = 0)
dev.off()
